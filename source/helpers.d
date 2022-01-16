module deepath.helpers;

import core.vararg;
import dyaml;
import vibe.core.log : logDebug, logInfo, logError, logException;
import std.typecons;
import std.conv;

template logFunctionBorders()
{
    const char[] logFunctionBorders = `logDebug("-> " ~ __MODULE__ ~ " " ~ __FUNCTION__);` ~
    ` scope(exit) logDebug("<- " ~ __MODULE__ ~ " " ~ __FUNCTION__);`;
}

T getFromYaml(T)(in Node yamlConfig, in T defaultValue, in string[] configParameters ...) {
    debug { mixin(logFunctionBorders!()); }

    Node node = yamlConfig;
    foreach (string parameter; configParameters)
    {
        parameter in node ? logDebug("%s yes", parameter) : logDebug("%s no", parameter);
        if (parameter in node)
        {
            node = node[parameter];
        } else {
            return defaultValue;
        }
    }
    return node.as!T;
}