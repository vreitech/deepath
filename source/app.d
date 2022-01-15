import vibe.vibe;
import deepath.helpers;
import deepath.mere;
import deepath.formreq;

void main()
{
	debug { setLogLevel(LogLevel.debug_); }
	debug { mixin(logFunctionBorders!()); }

	logInfo("Creating stash.");
	auto stash = new mereStash;
	logInfo("Initializing stash...");
	if (!mereStash.one.doInit()) {
		logError(`Stash initialization failed! Exitting...`);
		return;
	}
	stash.one.httpServerSettings.port = 8088;
	stash.one.httpServerSettings.bindAddresses = ["::1", "127.0.0.1"];
	stash.one.httpClientSettings.defaultKeepAliveTimeout = 1200.seconds;
	stash.one.httpClientSettings.connectTimeout = 5.seconds;
	stash.one.httpClientSettings.readTimeout = 5.seconds;
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
