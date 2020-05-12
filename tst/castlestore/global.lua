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
-- Mission_FirstMapAction
----------------------------------
-- Die FirstMapAction wird am Spielstart aufgerufen.
-- Starte von hier aus deine Funktionen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_FirstMapAction()
    local Path = "E:/Repositories/symfonia/qsb/lua";
    Script.Load(Path .. "/loader.lua");
    SymfoniaLoader:Load(Path);
    InitKnightTitleTables();

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
    
    -----

    API.CastleStoreCreate(1);
    
    InteractiveObjectDeactivate("IORR1");
    InteractiveObjectDeactivate("IORR2");
    InteractiveObjectDeactivate("IORR3");
    InteractiveObjectDeactivate("IORR4");
    InteractiveObjectDeactivate("IORR5");

    AddQuest {
        Name = "RandomTestQuest1",
        Sender = 2,

        Goal_RandomRequest(false, false, false, false, false, false, false, false, false, false, false, true, 0),
        Trigger_Time(5),
    }
    AddQuest {
        Name = "RandomTestQuest2",
        Sender = 2,

        Goal_RandomRequest(false, false, false, false, false, false, false, false, false, false, false, true, 0),
        Trigger_Time(5),
    }
    AddQuest {
        Name = "RandomTestQuest3",
        Sender = 2,

        Goal_RandomRequest(false, false, false, false, false, false, false, false, false, false, false, true, 0),
        Trigger_Time(5),
    }
end

function SomeFunction(_Question, _Answer)
    API.Note(_Question.." ".._Answer);
end