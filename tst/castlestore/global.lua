--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_InitPlayers
----------------------------------
-- Diese Funktion kann benutzt werden um für die AI
-- Vereinbarungen zu treffen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_InitPlayers()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_SetStartingMonth
----------------------------------
-- Diese Funktion setzt einzig den Startmonat.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_InitMerchants
----------------------------------
-- Hier kannst du Hдndler und Handelsposten vereinbaren.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_InitMerchants()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_LoadFiles
----------------------------------
-- Läd zusätzliche Dateien
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_LoadFiles()
    return {
        "E:/Repositories/symfonia/tst/castlestore/knighttitlerequirements.lua",
    };
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_FirstMapAction
----------------------------------
-- Die FirstMapAction wird am Spielstart aufgerufen.
-- Starte von hier aus deine Funktionen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_FirstMapAction()
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/questsystembehavior.lua");

    if Framework.IsNetworkGame() ~= true then
        Startup_Player()
        Startup_StartGoods()
        Startup_Diplomacy()
    end
    
    API.ActivateDebugMode(true, false, true, true)
    
    AddGood(Goods.G_Gold,   500, 1)
    AddGood(Goods.G_Grain,   10, 1)
    AddGood(Goods.G_Carcass, 10, 1)
    AddGood(Goods.G_RawFish, 10, 1)
    AddGood(Goods.G_Milk,    10, 1)

    SetEntityName(Logic.GetHeadquarters(1), "HQ1");
    
    -- -----

    API.CastleStoreCreate(1);

    -- ReplaceEntity("IORR3", Entities.B_Cistern, 2);
    
    InteractiveObjectDeactivate("IORR1");
    InteractiveObjectDeactivate("IORR2");
    InteractiveObjectDeactivate("IORR3");
    InteractiveObjectDeactivate("IORR4");
    InteractiveObjectDeactivate("IORR5");

    API.CreateQuest {
        Name = "Test1",
        Suggestion = "Guck mal hier!",
        QuestNotes = true,

        Goal_NoChange(),
        Trigger_Time(5)
    };

    API.CreateQuest {
        Name = "Test2",
        Suggestion = "Guck auch mal hier!",
        QuestNotes = true,

        Goal_NoChange(),
        Trigger_Time(5),
    };

    API.CreateQuest {
        Name = "Test3",
        Suggestion = "Guck trotzdem mal hier!",
        QuestNotes = false,

        Goal_NoChange(),
        Trigger_Time(5),
    };

    -- API.PushGlobalQuestInfo("- Das ist normale Nachricht 1!");
    -- API.PushImportantGlobalQuestInfo("- Das ist wichtige Nachricht 1!");
    -- API.PushGlobalQuestInfo("- Das ist normale Nachricht 2!");
    -- API.PushImportantQuestInfo("Test2", "- Das ist wichtige Nachricht 2!");

    API.SetShowQuestInfo(true);
end

function SomeFunction(_Question, _Answer)
    API.Note(_Question.." ".._Answer);
end