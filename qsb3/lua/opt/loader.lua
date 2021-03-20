OptLoader_BasePath = "maps/externalmap/" ..Framework.GetCurrentMapName().. "/";
OptLoader_ModuleFiles = {
    "Swift_1_JobsCore/source.lua",
    "Swift_1_JobsCore/api.lua",
    "Swift_1_ScriptingValueCore/source.lua",
    "Swift_1_ScriptingValueCore/api.lua",
    "Swift_1_SoundCore/source.lua",
    "Swift_1_SoundCore/api.lua",
    "Swift_1_TextCore/source.lua",
    "Swift_1_TextCore/api.lua",
    "Swift_1_TradingCore/source.lua",
    "Swift_1_TradingCore/api.lua",
    "Swift_2_JobsRealtime/source.lua",
    "Swift_2_JobsRealtime/api.lua",
    "Swift_2_WeatherCore/source.lua",
    "Swift_2_WeatherCore/api.lua",
    "Swift_3_QuestCore/source.lua",
    "Swift_3_QuestCore/api.lua",
}

function OptLoader_SetBasePath(_Path)
    OptLoader_BasePath = _Path;
end

function OptLoader_LoadFiles()
    Script.Load(OptLoader_BasePath.. "lua/modules/Swift_0_Core/swift.lua");
    Script.Load(OptLoader_BasePath.. "lua/modules/Swift_0_Core/api.lua");
    Script.Load(OptLoader_BasePath.. "lua/modules/Swift_0_Core/debug.lua");
    Script.Load(OptLoader_BasePath.. "lua/modules/Swift_0_Core/behavior.lua");

    for i= 1, #OptLoader_ModuleFiles, 1 do
        Script.Load(OptLoader_BasePath.. "lua/modules/" ..OptLoader_ModuleFiles[i]);
    end

    Script.Load(OptLoader_BasePath.. "lua/modules/Swift_0_Core/selfload.lua");
end

