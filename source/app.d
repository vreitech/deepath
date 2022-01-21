import vibe.vibe;
import std.algorithm.searching : canFind;
//import core.time;
//import std.datetime.date;
//import std.datetime.systime;
//import std.typecons;
//import std.conv;
import deepath.helpers;
import deepath.mere;
import deepath.formzabbixreq;
import dyaml;

void main() {
	debug { setLogLevel(LogLevel.debug_); }
	debug { mixin(logFunctionBorders!()); }

	logInfo("Reading YAML config.");
	Node ymlConfig;
	const string ymlConfigFile = `config.yml`;
	try {
		ymlConfig = Loader.fromFile(ymlConfigFile).load();
	} catch (Exception e) {
		logException(e, "Opening YAML config file");
		return;
	}
	logInfo("YAML config has been read.");

	logInfo("Creating stash.");
	auto stash = new mereStash;
	logInfo("Initializing stash...");
	if (!stash.one.doInit()) {
		logError(`Stash initialization failed! Exitting...`);
		return;
	}
	stash.one.httpServerSettings.bindAddresses = ["::1", "127.0.0.1"];
	stash.one.httpServerSettings.port = getFromYaml!ushort(ymlConfig, 8088, "httpServerSettings", "port");
	stash.one.httpServerSettings.keepAliveTimeout = getFromYaml(
		ymlConfig, 10, "httpServerSettings", "keepAliveTimeout"
		).seconds;
	stash.one.httpClientSettings.defaultKeepAliveTimeout = getFromYaml(
		ymlConfig, 0, "httpClientSettings", "defaultKeepAliveTimeout"
		).seconds;
	stash.one.httpClientSettings.connectTimeout = getFromYaml(
		ymlConfig, 5, "httpClientSettings", "connectTimeout"
		).seconds;
	stash.one.httpClientSettings.readTimeout = getFromYaml(
		ymlConfig, 5, "httpClientSettings", "readTimeout"
		).seconds;
	if ("appSettings" in ymlConfig)	{
		if ("endpoints" in ymlConfig["appSettings"]) {
			foreach (Node endpoint; ymlConfig["appSettings"]["endpoints"].mappingKeys) {
				if ("server" in ymlConfig["appSettings"]["endpoints"][endpoint]
				&& "port" in ymlConfig["appSettings"]["endpoints"][endpoint]) {
					stash.one.endpoints ~= endpoint.as!string;
					logDebug("proper endpoint '%s'", endpoint.as!string);
				} else {
					logDebug("broken endpoint '%s'", endpoint.as!string);
				}
			}
		} else {
			logError("Missed 'appSettings.endpoints' section in config. Exitting...");
			return;
		}
	} else {
		logError("Missed 'appSettings' section in config. Exitting...");
		return;
	}
	logInfo("Stash initialized.");
	debug { logDebug(
		"stash.one.httpServerSettings.keepAliveTimeout == %s", stash.one.httpServerSettings.keepAliveTimeout
		); }
	debug { logDebug(
		"stash.one.httpClientSettings.defaultKeepAliveTimeout == %s", stash.one.httpClientSettings.defaultKeepAliveTimeout
		); }

	logInfo("Declaring routes...");
	stash.one.router.get(`/`, &mainPage);
	stash.one.router.get(`/trigger/:endpoint`, &getJsonReq);
	stash.one.router.get(`/css/*`, serveStaticFiles(`./public/css/`));
	stash.one.router.get(`*`, serveStaticFiles(`./public/`));
	logInfo("Routes declared.");
	debug { logDebug(`All routes: %s`, stash.one.router.getAllRoutes()); }

	logInfo("Start listening interface(s)...");
	auto listener = listenHTTP(stash.one.httpServerSettings, stash.one.router);
	scope (exit) {
		listener.stopListening();
	}

	logInfo("Interface(s) are listening.");
	runApplication();
}

void mainPage(HTTPServerRequest req, HTTPServerResponse res) @safe {
	debug { mixin(logFunctionBorders!()); }

	res.writeBody("Hello, World!");
}

void getJsonReq(HTTPServerRequest req, HTTPServerResponse res) {
	debug { mixin(logFunctionBorders!()); }

	debug { logDebug("Method: %s", req.method); }

	Json result = Json.emptyObject;
	scope (exit) { res.writeJsonBody(result); }

	auto stash = new mereStash;

	if (!canFind(stash.one.endpoints, req.params["endpoint"])) {
		result["status"] = false;
		result["message"] = "Wrong endpoint";
		return;
	}

	if (req.contentType != `application/json`) {
		result["status"] = false;
		result["message"] = "Wrong Content-Type";
		return;
	}

	result["status"] = true;
	result["message"] = "OK";
	result["data"] = req.json;

	auto connZabbix = connectTCP(`127.0.0.1`, 5554);
	connZabbix.write(formZabbixReq(req.json));
	connZabbix.close();
}