module deepath.mixins;

template logFunctionBorders()
{
    const char[] logFunctionBorders = `logDebug("-> " ~ __MODULE__ ~ " " ~ __FUNCTION__);` ~
    ` scope(exit) logDebug("<- " ~ __MODULE__ ~ " " ~ __FUNCTION__);`;
}

T getFromYaml(T)(in Node yamlConfig, in string configParameter, in T defaultValue) {
        return configParameter in yamlConfig ? yamlConfig[configParameter].as!T : defaultValue;
}