-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

function Mission_FirstMapAction()
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/questsystembehavior.lua");
    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end
    Mission_OnQsbLoaded();
end

function Mission_InitPlayers()
end

function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

function Mission_InitMerchants()
end

function Mission_LoadFiles()
    return {};
end

function Mission_OnQsbLoaded()
    API.ActivateDebugMode(true, false, true, true);

    Logic.SetKnightTitle(3, 3);
    SetDiplomacyState(1, 2, 1);
    SetDiplomacyState(1, 3, -2);
end

-- -------------------------------------------------------------------------- --

-- > CreateStealGoldTestQuest()

function CreateStealGoldTestQuest()
    AddQuest {
        Name        = "StealGoldTestQuest",
        Suggestion  = "We must steal some gold to successfully test the behavior.",
        Success     = "This is a success!",
        Receiver    = 1,

        Goal_StealGold(250, -1, true, true),
        Trigger_Time(0),
    }
end

-- > CreateStealFromBuildingTestQuest()

function CreateStealFromBuildingTestQuest()
    AddQuest {
        Name        = "StealFromBuildingTestQuest",
        Suggestion  = "We must steal from this building to successfully test the behavior.",
        Success     = "This is a success!",
        Receiver    = 1,

        Goal_StealFromBuilding("Target1", true),
        Trigger_Time(0),
    }
end

-- > CreateInfiltrateBuildingTestQuest()

function CreateInfiltrateBuildingTestQuest()
    AddQuest {
        Name        = "InfiltrateBuildingTestQuest",
        Suggestion  = "We must infiltrate the building to successfully test the behavior.",
        Success     = "This is a success!",
        Receiver    = 1,

        Goal_SpyOnBuilding("Target2", true),
        Trigger_Time(0),
    }
end

-- > CreateCollectValuablesTestQuest()

function CreateCollectValuablesTestQuest()
    AddQuest {
        Name        = "CollectValuablesTestQuest",
        Suggestion  = "We must find some missing stuff.",
        Success     = "This is a success!",
        Receiver    = 1,

        Goal_FetchItems("Item", "-", 300),
        Trigger_Time(0),
    }
end

-- > CreateDestroySpawnedEntitiesTestQuest()

function CreateDestroySpawnedEntitiesTestQuest()
    AddQuest {
        Name        = "DestroySpawnedEntitiesTestQuest",
        Suggestion  = "We must kill some nastey beasts.",
        Success     = "This is a success!",
        Receiver    = 1,

        Goal_DestroySpawnedEntities("Pack", 12, true),
        Trigger_Time(0),
    }
end

