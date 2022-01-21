module deepath.formzabbixreq;

import deepath.helpers;
import binary.pack;
import vibe.data.json;
import vibe.core.log : logDebug, logInfo, logError, logException;
import std.conv : to;

ubyte[] formZabbixReq(Json message)
{
    debug { mixin(logFunctionBorders!()); }

    auto q = message.toString;
    return cast(ubyte[])("ZBXD\x01") ~ pack!`<L`(message.toString.length) ~ cast(ubyte[])(message.toString);
}