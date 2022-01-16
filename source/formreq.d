module deepath.formreq;

import deepath.helpers;
import binary.pack;
import vibe.data.json;
import vibe.core.log : logDebug, logInfo, logError, logException;

byte[] formReq()
{
    debug { mixin(logFunctionBorders!()); }

    return [0];
}