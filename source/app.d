import vibe.core.core : runApplication;
import vibe.http.server;
//import vibe.http.fileserver;
import vibe.core.log : logDebug, logInfo, logError, logException, setLogLevel, LogLevel;
import vibe.data.json;
import core.time : seconds;
import std.algorithm.searching : canFind;
import dyaml;
import deepath.helpers;
import deepath.mere;
import deepath.formzabbixreq;

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
	stash.one.httpServerSettings.bindAddresses = [];
	if(!ymlConfig["httpServerSettings"].containsKey("bindAddresses")
	|| ymlConfig["httpServerSettings"]["bindAddresses"].length == 0) {
		stash.one.httpServerSettings.bindAddresses ~= `127.0.0.1`;
	} else {
        	foreach(address; ymlConfig["httpServerSettings"]["bindAddresses"].sequence) {
			stash.one.httpServerSettings.bindAddresses ~= address.as!string;
			debug { logDebug("%s", address); }
		}
	}
	stash.one.httpServerSettings.port = getFromYaml!ushort(ymlConfig, 8088, "httpServerSettings", "port");
	stash.one.httpServerSettings.keepAliveTimeout = getFromYaml(
		ymlConfig, 10, "httpServerSettings", "keepAliveTimeout"
		).seconds;
	if ("appSettings" in ymlConfig)	{
		if ("endpoints" in ymlConfig["appSettings"]) {
			foreach (endpoint; ymlConfig["appSettings"]["endpoints"].mapping) {
				if ("server" in endpoint.value
				  && "port" in endpoint.value
				  && "hostname" in endpoint.value
				  && "key" in endpoint.value) {
				  	stash.one.endpoints[endpoint.key.as!string] = endpoint.value;
				 	debug { logDebug("proper endpoint '%s'", endpoint.key.as!string); }
				} else {
				 	debug { logDebug("broken endpoint '%s'", endpoint.key.as!string); }
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

	logInfo("Declaring routes...");
	stash.one.router.get(`/`, &mainPage);
	stash.one.router.get(`/trigger/:endpoint`, &getJsonReq);
	//stash.one.router.get(`/css/*`, serveStaticFiles(`./public/css/`));
	//stash.one.router.get(`*`, serveStaticFiles(`./public/`));
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

	auto result = Json.emptyObject;
	result["description"] = "Dispatch HTTP JSON requests to Zabbix trapper";
	res.writeJsonBody(result);
}

void getJsonReq(HTTPServerRequest req, HTTPServerResponse res) {
	debug { mixin(logFunctionBorders!()); }

	debug { logDebug("Method: %s", req.method); }

	auto result = Json.emptyObject;
	scope (exit) { res.writeJsonBody(result); }

	auto stash = new mereStash;

	if (!(req.params["endpoint"] in stash.one.endpoints)) {
		result["status"] = false;
		result["message"] = "Wrong endpoint";
		return;
	}

	if (req.contentType != `application/json`) {
		result["status"] = false;
		result["message"] = "Wrong Content-Type";
		return;
	}

	ubyte[] zabbixReq;
	try {
		zabbixReq = formZabbixReq(
			(stash.one.endpoints[req.params["endpoint"]])["hostname"].as!string,
			(stash.one.endpoints[req.params["endpoint"]])["key"].as!string,
			req.json
			);
	} catch (JSONException e) {
		result["status"] = false;
		result["message"] = "Can't parse body into JSON: " ~ e.msg;
		return;
	}
	
	result["status"] = true;
	result["message"] = "OK";

	auto connZabbix = connectTCP(
		(stash.one.endpoints[req.params["endpoint"]])["server"].as!string,
		(stash.one.endpoints[req.params["endpoint"]])["port"].as!ushort
		);
	connZabbix.write(zabbixReq);
	connZabbix.close();
}
