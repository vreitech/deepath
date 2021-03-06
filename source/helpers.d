module deepath.helpers;

import core.vararg;
import vibe.core.log : logDebug, logInfo, logError, logException;
import dyaml;

template logFunctionBorders()
{
    const char[] logFunctionBorders = `logDebug("-> " ~ __MODULE__ ~ " " ~ __FUNCTION__);` ~
    ` scope(exit) logDebug("<- " ~ __MODULE__ ~ " " ~ __FUNCTION__);`;
}

T getFromYaml(T)(in Node yamlConfig, in T defaultValue, in string[] configParameters ...) @safe
{
    debug { mixin(logFunctionBorders!()); }

    Node node = yamlConfig;
    foreach (string parameter; configParameters)
    {
        debug { parameter in node ? logDebug("%s is present", parameter) : logDebug("%s is NOT present", parameter); }
        if (parameter in node)
        {
            node = node[parameter];
        } else {
            return defaultValue;
        }
    }
    return node.as!T;
}