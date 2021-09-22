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
    "Swift_1_MilitaryCore/source.lua",
    "Swift_1_MilitaryCore/api.lua",
    "Swift_1_MilitaryCore/behavior.lua",
    "Swift_1_ScriptingValueCore/source.lua",
    "Swift_1_ScriptingValueCore/api.lua",
    "Swift_1_SoundCore/source.lua",
    "Swift_1_SoundCore/api.lua",
    "Swift_1_TradingCore/source.lua",
    "Swift_1_TradingCore/api.lua",
    "Swift_2_InteractionCore/source.lua",
    "Swift_2_InteractionCore/api.lua",
    "Swift_2_InteractionCore/behavior.lua",
    "Swift_2_KnightTitleRequirements/source.lua",
    "Swift_2_KnightTitleRequirements/api.lua",
    "Swift_2_KnightTitleRequirements/requirements.lua",
    "Swift_2_QuestCore/source.lua",
    "Swift_2_QuestCore/api.lua",
    "Swift_2_SelectionCore/source.lua",
    "Swift_2_SelectionCore/api.lua",
    "Swift_2_WeatherCore/source.lua",
    "Swift_2_WeatherCore/api.lua",
    "Swift_4_ExtendedCamera/source.lua",
    "Swift_4_ExtendedCamera/api.lua",
    "Swift_4_JobsRealtime/source.lua",
    "Swift_4_JobsRealtime/api.lua",
    "Swift_4_TextWindow/source.lua",
    "Swift_4_TextWindow/api.lua",
    "Swift_4_Typewriter/source.lua",
    "Swift_4_Typewriter/api.lua",
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

