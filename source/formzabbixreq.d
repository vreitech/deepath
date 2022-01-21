module deepath.formzabbixreq;

import deepath.helpers;
import binary.pack;
import vibe.data.json;
import vibe.core.log : logDebug, logInfo, logError, logException;
import std.conv : to;

ubyte[] formZabbixReq(string hostname, string key, Json message)
{
    debug { mixin(logFunctionBorders!()); }

    Json body = Json([
        "request": Json("sender data"), "data": serializeToJson([[
            "host": hostname,
            "key": key,
            "value": message.to!string
            ]])
        ]);
    return cast(ubyte[])("ZBXD\x01") ~ pack!`<L`(body.toString.length) ~ cast(ubyte[])(body.toString);
}