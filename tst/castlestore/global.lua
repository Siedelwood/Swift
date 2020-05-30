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

    -- ReplaceEntity("IORR3", Entities.B_Cistern, 2);
    
    InteractiveObjectDeactivate("IORR1");
    InteractiveObjectDeactivate("IORR2");
    InteractiveObjectDeactivate("IORR3");
    InteractiveObjectDeactivate("IORR4");
    InteractiveObjectDeactivate("IORR5");

    API.CreateObject {
        Name        = "IORR3",
        Distance    = 1200,
        Texture     = {1, 8},
        Costs       = {Goods.G_Gold, 100, Goods.G_Stone, 10},
        Callback    = function(_Data, _PlayerID)
            API.Note(_PlayerID.. " has activated object " .._Data.m_Name);
        end,
    }

    API.CreateQuest {
        Name = "TestQuest",
        Visible = true,
        EndMessage = true,
        Goal_ActivateObject("IORR3"),
        Trigger_Time(5)
    }
end

function SomeFunction(_Question, _Answer)
    API.Note(_Question.." ".._Answer);
end