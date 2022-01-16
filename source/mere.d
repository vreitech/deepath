module deepath.mere;

import deepath.helpers;
import vibe.http.server : HTTPServerSettings;
import vibe.http.client : HTTPClientSettings;
import vibe.http.router : URLRouter;
import vibe.core.log : logDebug, logInfo, logError, logException;
import std.file : exists, isFile;
import dyaml;

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
    public HTTPClientSettings httpClientSettings;
    public URLRouter router;

    public this() {}
    public bool doInit()
    {
        debug { mixin(logFunctionBorders!()); }
        this.httpServerSettings = new HTTPServerSettings;
        this.httpClientSettings = new HTTPClientSettings;
        this.router = new URLRouter;

        return true;
    }

/*    void say(string text)
    {
        import std.stdio : writeln;
    
        writeln(text);
    }*/
}