OptLoader_BasePath = "maps/externalmap/" ..Framework.GetCurrentMapName().. "/";
OptLoader_ModuleFiles = {
    "Swift_1_DisplayCore/source.lua",
    "Swift_1_DisplayCore/api.lua",
    "Swift_1_InputOutputCore/source.lua",
    "Swift_1_InputOutputCore/api.lua",
    "Swift_1_InputOutputCore/behavior.lua",
    "Swift_1_InterfaceCore/source.lua",
    "Swift_1_InterfaceCore/api.lua",
    "Swift_1_JobsCore/source.lua",
    "Swift_1_JobsCore/api.lua",
    "Swift_1_ScriptingValueCore/source.lua",
    "Swift_1_ScriptingValueCore/api.lua",
    "Swift_1_SoundCore/source.lua",
    "Swift_1_SoundCore/api.lua",
    "Swift_1_TradingCore/source.lua",
    "Swift_1_TradingCore/api.lua",
    "Swift_2_InteractionCore/source.lua",
    "Swift_2_InteractionCore/api.lua",
    "Swift_2_QuestCore/source.lua",
    "Swift_2_QuestCore/api.lua",
    "Swift_2_TextWindow/source.lua",
    "Swift_2_TextWindow/api.lua",
    "Swift_2_Typewriter/source.lua",
    "Swift_2_Typewriter/api.lua",
    "Swift_2_WeatherCore/source.lua",
    "Swift_2_WeatherCore/api.lua",
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

