import vibe.vibe;
//import core.time;
//import std.datetime.date;
//import std.datetime.systime;
//import std.typecons;
//import std.conv;
import deepath.helpers;
import deepath.mere;
import deepath.formreq;
import dyaml;

void main()
{
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
	stash.one.httpClientSettings.defaultKeepAliveTimeout = getFromYaml(ymlConfig, 0, "httpClientSettings", "defaultKeepAliveTimeout").seconds;
	stash.one.httpClientSettings.connectTimeout = getFromYaml(ymlConfig, 5, "httpClientSettings", "connectTimeout").seconds;
	stash.one.httpClientSettings.readTimeout = getFromYaml(ymlConfig, 5, "httpClientSettings", "readTimeout").seconds;
	logInfo("Stash initialized.");

	logInfo("Declaring routes...");
	stash.one.router.get(`/`, &mainPage);
	stash.one.router.get(`/css/*`, serveStaticFiles(`./public/css/`));
	stash.one.router.get(`*`, serveStaticFiles(`./public/`));
	logInfo("Routes declared.");
	debug { logDebug(`All routes: %s`, stash.one.router.getAllRoutes()); }

	logInfo("Start listening interface(s)...");
	auto listener = listenHTTP(stash.one.httpServerSettings, stash.one.router);
	scope (exit)
	{
		listener.stopListening();
	}

	logInfo("Interface(s) are listening.");
	runApplication();
}

void mainPage(HTTPServerRequest req, HTTPServerResponse res)
{
	debug { mixin(logFunctionBorders!()); }

	res.writeBody("Hello, World!");
}
