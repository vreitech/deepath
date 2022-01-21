module deepath.mere;

import vibe.http.server : HTTPServerSettings;
import vibe.http.router : URLRouter;
import vibe.core.log : logDebug, logInfo, logError, logException;
import dyaml;
import deepath.helpers;

template Singleton()
{
    static typeof(this) one()
    {
        if (!isInstanced)
        {
            synchronized(typeof(this).classinfo)
            {
                if (!instance)
                {
                    instance = new typeof(this)();
                }
                isInstanced = true;
            }
        }
        return instance;
    }

    private static bool isInstanced = false;
    private __gshared typeof(this) instance;
}

class mereStash
{
    mixin Singleton;
    public HTTPServerSettings httpServerSettings;
//    public HTTPClientSettings httpClientSettings;
    public URLRouter router;
    public Node[string] endpoints;

    public this() {}
    public bool doInit() @safe
    {
        debug { mixin(logFunctionBorders!()); }
        this.httpServerSettings = new HTTPServerSettings;
//        this.httpClientSettings = new HTTPClientSettings;
        this.router = new URLRouter;

        return true;
    }
}