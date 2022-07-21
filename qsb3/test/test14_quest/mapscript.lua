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

    TestVariable = "placeholders";

    CreateStaticQuest()
    CreateEntriesQuest()
end

-- -------------------------------------------------------------------------- --

-- > CreateStaticQuest()

function CreateStaticQuest()
    AddQuest {
        Name        = "StaticQuest",
        Suggestion  = "This can be any type of visible quest.",
        Success     = "This will never be seen.",
        Receiver    = 1,

        Goal_NoChange(),
        Trigger_Time(0),
    }
end

-- > CreateEntriesQuest()

function CreateEntriesQuest()
    AddQuest {
        Name        = "EntriesQuest",
        Receiver    = 1,

        Goal_InstantSuccess(),
        Reward_JournalEnable("StaticQuest", true),
        Reward_JournalWrite("StaticQuest", "Entry1", "Some important information."),
        Reward_JournalWrite("StaticQuest", "Entry2", "Another information noteworthy."),
        Reward_JournalWrite("StaticQuest", "Entry3", "This shouls also be remembered."),
        Reward_JournalWrite("StaticQuest", "Entry4", "This {green}Text{@color:255,255,255,255} hase some {v:TestVariable} that are filtered out."),
        Trigger_Time(0),
    }
end

-- > CreateHighlightEntryQuest()

function CreateHighlightEntryQuest()
    AddQuest {
        Name        = "HighlightEntryQuest",
        Receiver    = 1,

        Goal_InstantSuccess(),
        Reward_JournaHighlight("StaticQuest", "Entry1", true),
        Trigger_Time(0),
    }
end

-- > CreateUnhighlightEntryQuest()

function CreateUnhighlightEntryQuest()
    AddQuest {
        Name        = "UnhighlightEntryQuest",
        Receiver    = 1,

        Goal_InstantSuccess(),
        Reward_JournaHighlight("StaticQuest", "Entry1", false),
        Trigger_Time(0),
    }
end

-- > CreateRemoveSingleEntryQuest()

function CreateRemoveSingleEntryQuest()
    AddQuest {
        Name        = "RemoveSingleEntryQuest",
        Receiver    = 1,

        Goal_InstantSuccess(),
        Reward_JournalRemove("StaticQuest", "Entry3"),
        Trigger_Time(0),
    }
end

