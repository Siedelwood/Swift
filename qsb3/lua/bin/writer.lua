BinWriter_ModuleFiles = {
    "Swift_0_Core/swift.lua",
    "Swift_0_Core/api.lua",
    "Swift_0_Core/debug.lua",
    "Swift_0_Core/behavior.lua",
    "Swift_0_Core/user.lua",

    "Swift_1_DisplayCore/source.lua",
    "Swift_1_DisplayCore/api.lua",
    "Swift_1_EntityEventCore/source.lua",
    "Swift_1_EntityEventCore/api.lua",
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
    "Swift_2_CastleStore/source.lua",
    "Swift_2_CastleStore/api.lua",
    "Swift_2_ConstructionAndKnockdown/source.lua",
    "Swift_2_ConstructionAndKnockdown/api.lua",
    "Swift_2_EntitySearch/source.lua",
    "Swift_2_EntitySearch/api.lua",
    "Swift_2_ExtendedCamera/source.lua",
    "Swift_2_ExtendedCamera/api.lua",
    "Swift_2_KnightTitleRequirements/source.lua",
    "Swift_2_KnightTitleRequirements/api.lua",
    "Swift_2_KnightTitleRequirements/requirements.lua",
    "Swift_2_LifestockBreeding/source.lua",
    "Swift_2_LifestockBreeding/api.lua",
    "Swift_2_Minimap/source.lua",
    "Swift_2_Minimap/api.lua",
    "Swift_2_Minimap/behavior.lua",
    "Swift_2_NpcInteraction/source.lua",
    "Swift_2_NpcInteraction/api.lua",
    "Swift_2_NpcInteraction/behavior.lua",
    "Swift_2_ObjectInteraction/source.lua",
    "Swift_2_ObjectInteraction/api.lua",
    "Swift_2_ObjectInteraction/behavior.lua",
    "Swift_2_Pathing/source.lua",
    "Swift_2_Pathing/api.lua",
    "Swift_2_Quests/source.lua",
    "Swift_2_Quests/api.lua",
    "Swift_2_Selection/source.lua",
    "Swift_2_Selection/api.lua",
    "Swift_2_ShipSalesman/source.lua",
    "Swift_2_ShipSalesman/api.lua",
    "Swift_2_SpeedLimit/source.lua",
    "Swift_2_SpeedLimit/api.lua",
    "Swift_2_MilitaryLimit/source.lua",
    "Swift_2_MilitaryLimit/api.lua",
    "Swift_2_MilitaryLimit/behavior.lua",
    "Swift_2_Typewriter/source.lua",
    "Swift_2_Typewriter/api.lua",
    "Swift_2_WeatherManipulation/source.lua",
    "Swift_2_WeatherManipulation/api.lua",
    "Swift_3_BehaviorCollection/source.lua",
    "Swift_3_BehaviorCollection/api.lua",
    "Swift_3_BehaviorCollection/behavior.lua",
    "Swift_3_BriefingSystem/source.lua",
    "Swift_3_BriefingSystem/api.lua",
    "Swift_3_BriefingSystem/behavior.lua",
    "Swift_3_CutsceneSystem/source.lua",
    "Swift_3_CutsceneSystem/api.lua",
    "Swift_3_CutsceneSystem/behavior.lua",
    "Swift_3_DialogSystem/source.lua",
    "Swift_3_DialogSystem/api.lua",
    "Swift_3_DialogSystem/behavior.lua",
    "Swift_3_GraphVizExport/source.lua",
    "Swift_3_GraphVizExport/api.lua",
    "Swift_3_InteractiveChests/source.lua",
    "Swift_3_InteractiveChests/api.lua",
    "Swift_3_InteractiveMines/source.lua",
    "Swift_3_InteractiveMines/api.lua",
    "Swift_3_InteractiveSites/source.lua",
    "Swift_3_InteractiveSites/api.lua",
    "Swift_3_QuestJournal/source.lua",
    "Swift_3_QuestJournal/api.lua",
    "Swift_3_QuestJournal/behavior.lua",

    "Swift_0_Core/selfload.lua",
};

function BinWriter_LoadSource(_File)
    local fh = io.open("../modules/" .._File, "rt");
    if not fh then
        print("file not found: ../modules/" .._File);
        return "";
    end
    print("loading: ../modules/" .._File);
    fh:seek("set", 0);
    local Contents = fh:read("*all");
    fh:close();
    return Contents;
end

function BinWriter_ConcatSources()
    local Content = "";
    for i= 1, #BinWriter_ModuleFiles, 1 do
        Content = Content .. BinWriter_LoadSource(BinWriter_ModuleFiles[i]);
    end
    return Content;
end

function BinWriter_Write()
    local QsbContent = BinWriter_ConcatSources();
    local fh = io.open("../../var/qsb.lua", "rt");
    if fh ~= nil then
        os.remove("../../var/qsb.lua");
        fh:close();
    end
    local fh = io.open("../../var/qsb.lua", "wt");
    assert(fh, "Output file can not be created!");
    print("write qsb to var");
    fh:write(QsbContent);
    fh:close();
end

BinWriter_Write();

