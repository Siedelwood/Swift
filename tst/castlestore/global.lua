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
    
    API.ActivateDebugMode(true, true, true, true)
    
    AddGood(Goods.G_Gold,   500, 1)
    AddGood(Goods.G_Grain,   10, 1)
    AddGood(Goods.G_Carcass, 10, 1)
    AddGood(Goods.G_RawFish, 10, 1)
    AddGood(Goods.G_Milk,    10, 1)

    SetEntityName(Logic.GetHeadquarters(1), "HQ1");
    
    -----
    
    API.CastleStoreCreate(1);
    
    CreateObject {
        Name = "IO1",
        Costs = {Goods.G_Wood, 55, Goods.G_RawFish, 55},
        Waittime = 5,
    }

    CreateObject {
        Name = "IO2",
        Costs = {Goods.G_Wool, 55, Goods.G_Milk, 55},
        Waittime = 5,
    }

    CreateObject {
        Name = "IO3",
        Costs = {Goods.G_Carcass, 55, Goods.G_Herb, 55},
        Waittime = 5,
    }

    CreateObject {
        Name = "IO4",
        Costs = {Goods.G_Stone, 55, Goods.G_Grain, 55},
        Waittime = 5,
    }

    AddQuest {
        Name = "ObjectTestQuest",
        Visible = true,
        EndMessage = true,
        Sender = 8,

        Goal_ActivateSeveralObjects("IO1", "IO2", "IO3", "IO4"),
        Trigger_Time(5)
    }

    AddQuest {
        Name = "TradeTestQuest",
        Visible = true,
        EndMessage = true,
        Sender = 2,

        Goal_Deliver("G_Wood", 100),
        Reward_MapScriptFunction("SomeFunction", "Was ist lecker?", "Bockwurst"),
        Trigger_Time(5)
    }
end

function SomeFunction(_Behavior, _Quest)
    local Question = _Behavior:expose(1);
    local Answer   = _Behavior:expose(2);
    API.Note(Question.. " " ..Answer);
end