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

function CreateTestNPCDialogQuest()
    ReplaceEntity("npc1", Entities.U_KnightSabatta);
    
    AddQuest {
        Name        = "TestNpcQuest3",
        Suggestion  = "Speak to this npc.",
        Receiver    = 1,

        Goal_NPC("npc1", "-"),
        Reward_MapScriptFunction(CreateTestNPCDialogBriefing, "TestDialog", 1),
        Trigger_Time(0),
    }
end

function CreateTestNPCDialogBriefing(_Name, _PlayerID)
    local Dialog = {};
    local AP = API.AddDialogPages(Dialog);

    AP {
        Name   = "StartPage",
        Text   = "Das ist ein Test!",
        Sender = -1,
        Target = "npc1",
        Zoom   = 0.1,
        MC     = {
            {"Machen wir weiter...", "ContinuePage"},
            {"Schluss jetzt!", "EndPage"}
        }
    }

    AP {
        Name   = "ContinuePage",
        Text   = "Wunderbar! Es scheint zu funktionieren.",
        Sender = 1,
        Target = Logic.GetKnightID(_PlayerID),
        Zoom   = 0.1,
    }
    AP {
        Text   = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr.",
        Sender = -1,
        Target = Logic.GetKnightID(_PlayerID),
        Anchor = "npc1",
        Zoom   = 0.1,
    }
    AP {
        Text   = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor.",
        Sender = -1,
        Target = Logic.GetKnightID(_PlayerID),
        Anchor = Logic.GetKnightID(_PlayerID),
        Zoom   = 0.1,
    }
    AP {
        Text   = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
        Sender = -1,
        Target = Logic.GetKnightID(_PlayerID),
        Anchor = "npc1",
        Zoom   = 0.1,
    }
    AP("StartPage");

    AP {
        Name   = "EndPage",
        Text   = "Gut, dann eben nicht!",
        Sender = -1,
        Target = "npc1",
        Zoom   = 0.1,
    }


    return API.StartDialog(Dialog, _Name, _PlayerID);
end

function CreateTestNPCQuest()
    AddQuest {
        Name        = "TestNpcQuest1",
        Suggestion  = "Speak to this npc.",
        Success     = "You done well!",
        Receiver    = 1,

        Goal_NPC("npc1", "-"),
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
        PlayerID = 1,
        Callback = function(_Npc, _Hero)
            API.Note("It work's!");
        end,
    }

    -- Player 1 isn't allowed to speak to this npc.
    API.NpcCompose {
        Name     = "npc2",
        PlayerID = 2,
        Callback = function(_Npc, _Hero)
            API.Note("It does not work!");
        end,
    }
end

function CreateTestObject()
    CreateObject {
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
    CreateObject {
        Name     = "IO1",
        Distance = 1000,
        Text     = "Bockwurst",
        Texture  = {1, 4},
        Condition = function(_Data)
            return false;
        end,
        Callback = function(_Data)
            API.Note("it work's!");
        end,
    }
end