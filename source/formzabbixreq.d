module deepath.formzabbixreq;

import deepath.helpers;
import binary.pack;
import vibe.data.json;
import vibe.core.log : logDebug, logInfo, logError, logException;
import std.conv : to;

ubyte[] formZabbixReq(string hostname, string key, Json message)
{
    debug { mixin(logFunctionBorders!()); }

    auto q = message.toString;
    Json body = Json(
        ["request": Json("sender data"), "data": Json("message")]
        );
    return cast(ubyte[])("ZBXD\x01") ~ pack!`<L`(body.toString.length) ~ cast(ubyte[])(body.toString);
}