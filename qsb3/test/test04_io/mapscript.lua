-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_LoadFiles
-- --------------------------------
-- Läd zusätzliche Dateien aus der Map. Die Dateien
-- werden in der angegebenen Reihenfolge geladen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_LoadFiles()
    return {};
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_InitPlayers
-- --------------------------------
-- Diese Funktion kann benutzt werden um für die AI
-- Vereinbarungen zu treffen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_InitPlayers()
    -- Beispiel: KI-Skripte für Spieler 2 deaktivieren (nicht im Editor möglich)
    --
    -- DoNotStartAIForPlayer(2);
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_SetStartingMonth
-- --------------------------------
-- Diese Funktion setzt einzig den Startmonat.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_InitMerchants
-- --------------------------------
-- Hier kannst du Hдndler und Handelsposten vereinbaren.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_InitMerchants()
    -- Beispiel: Setzt Handelsangebote für Spieler 3
    --
    -- local SHID = Logic.GetStoreHouse(3);
    -- AddMercenaryOffer(SHID, 2, Entities.U_MilitaryBandit_Melee_NA);
    -- AddMercenaryOffer(SHID, 2, Entities.U_MilitaryBandit_Ranged_NA);
    -- AddOffer(SHID, 1, Goods.G_Beer);
    -- AddOffer(SHID, 1, Goods.G_Cow);

    -- Beispiel: Setzt Tauschangebote für den Handelsposten von Spieler 3
    --
    -- local TPID = GetID("Tradepost_Player3");
    -- Logic.TradePost_SetTradePartnerGenerateGoodsFlag(TPID, true);
    -- Logic.TradePost_SetTradePartnerPlayerID(TPID, 3);
    -- Logic.TradePost_SetTradeDefinition(TPID, 0, Goods.G_Carcass, 18, Goods.G_Milk, 18);
	-- Logic.TradePost_SetTradeDefinition(TPID, 1, Goods.G_Grain, 18, Goods.G_Honeycomb, 18);
    -- Logic.TradePost_SetTradeDefinition(TPID, 2, Goods.G_RawFish, 24, Goods.G_Salt, 12);
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_FirstMapAction
-- --------------------------------
-- Die FirstMapAction wird am Spielstart aufgerufen.
-- Starte von hier aus deine Funktionen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_FirstMapAction()
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/questsystembehavior.lua");

    -- Mapeditor-Einstellungen werden geladen
    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end

    API.ActivateDebugMode(true, false, true, true);
end

function HH_prepareCows()
    local cow = GetPlayerEntities(1, Entities.A_X_Cow01)
    for i = 1, #cow do
        Logic.SetEntityName(cow[i], "IOCow"..i)
        API.CreateObject {
            Name        = "IOCow"..i,
            Title       = "Kuh",
            Text        = "Kuh verkaufen",
            -- Distance    = 300,
            State       = 1,
            Texture     = {3, 16},
            Action      = function(_Data)
                API.Note("It works!");
            end
        }

        -- API.NpcCompose {
        --     Name     = "IOCow"..i,
        --     Callback = function(_Npc, _Hero)
        --         API.SetEntityPlayer("IOCow"..i, 2);
        --         API.Note("It works!");
        --     end,
        -- }
    end
end

function CreateTestMines1()
    API.CreateIOIronMine{
        Position = "ironmine"
    };
    API.CreateIOStoneMine{
        Position = "stonemine"
    };
end

function CreateTestMines2()
    API.CreateIOIronMine{
        Position = "ironmine",
        Costs    = {Goods.G_Wood, 50, Goods.G_Gold, 1500}
    };
    API.CreateIOStoneMine{
        Position = "stonemine",
        Costs    = {Goods.G_Wood, 50, Goods.G_Gold, 1500}
    };
end

function CreateTestChests()
    API.CreateRandomGoldChest("chest1");
    API.CreateRandomChest("chest2", Goods.G_Wood, 10, 30, function()
        API.Note("It just work's!");
    end);
    API.CreateRandomLuxuryChest("chest3");
    -- API.CreateRandomTreasure("IO1", Goods.G_Gold, 200, 400);
end

function CreateTestNPCQuest()
    AddQuest {
        Name        = "TestNpcQuest1",
        Suggestion  = "Speak to this npc.",
        Success     = "You done well!",
        Receiver    = 1,

        Goal_NPC("npc1", "hero"),
        Trigger_Time(0),
    }

    AddQuest {
        Name        = "TestNpcQuest2",
        Suggestion  = "Speak to this npc.",
        Success     = "You done well!",
        Receiver    = 2,

        Goal_NPC("npc2", "-"),
        Trigger_Time(0),
    }
end

function CreateTestNPCs()
    -- Player 1 can speak to this npc.
    API.NpcCompose {
        Name     = "npc1",
        Player   = 1,
        Callback = function(_Npc, _Hero)
            API.Note("It work's!");
        end,
    }

    -- Player 1 isn't allowed to speak to this npc.
    API.NpcCompose {
        Name              = "npc2",
        Player            = 2,
        WrongPlayerAction = function()
            API.Note("I won't talk to you!");
        end,
        Callback          = function(_Npc, _Hero)
            API.Note("It does not work!");
        end,
    }
end

function CreateTestObject()
    API.SetupObject {
        Name     = "IO1",
        Distance = 1000,
        Text     = "Bockwurst",
        Texture  = {1, 1},
        Condition = function(_Data)
            return true;
        end,
        Callback = function(_Data)
            API.Note("it work's!");
        end,
    }
end

function CreateTestObject2()
    API.SetupObject {
        Name     = "IO1",
        Distance = 1000,
        Text     = {de = "Bockwurst", en = "Sausages"},
        Texture  = {1, 4},
        Condition = function(_Data)
            return false;
        end,
        Callback = function(_Data)
            API.Note("it work's!");
        end,
    }
end