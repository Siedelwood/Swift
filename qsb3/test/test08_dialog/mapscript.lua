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

-- > BriefingAnimationTest([[foo]], 1)

function BriefingAnimationTest(_Name, _PlayerID)
    local Briefing = {
        HideBorderPins = true,
        ShowSky = true,
        RestoreGameSpeed = true,
        RestoreCamera = true,
        SkippingAllowed = true,
        DisableReturn = false,
    }
    local AP = API.AddBriefingPages(Briefing);

    Briefing.PageAnimations = {
        ["Page1"] = {
            {"pos4", -60, 2000, 35, "pos4", -30, 2000, 25, 30}
        },
        ["Page3"] = {
            PurgeOld = true,
            {"pos2", -45, 6000, 35, "pos2", -45, 3000, 35, 30},
        }
    }

    AP{
        Name     = "Page1",
        Title    = "Page 1",
        Text     = "This is page 1!",
        Position = "pos4",
    }
    AP{
        Title    = "Page 2",
        Text     = "This is page 2!",
        Duration = 5,
    }
    AP{
        Name     = "Page3",
        Title    = "Page 3",
        Text     = "This is page 3!",
    }
    AP{
        Title    = "Page 4",
        Text     = "This is page 4!",
    }
    AP{
        Title    = "Page 5",
        Text     = "This is page 5!",
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    API.StartBriefing(Briefing, _Name, _PlayerID)
end

function CreateTestNPCDialogQuest()
    ReplaceEntity("npc1", Entities.U_KnightSabatta);
    
    AddQuest {
        Name        = "TestNpcQuest3",
        Suggestion  = "Speak to this npc.",
        Receiver    = 1,

        Goal_NPC("npc1", "-"),
        Reward_Dialog("TestDialog", "CreateTestNPCDialogBriefing"),
        Trigger_Time(0),
    }
end

function CreateTestNPCDialogBriefing(_Name, _PlayerID)
    local Dialog = {
        DisableFow = true,
        DisableBoderPins = true,
    };
    local AP, ASP = API.AddDialogPages(Dialog);

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
        Target = "npc1",
        Zoom   = 0.1,
    }
    AP {
        Text   = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor.",
        Sender = -1,
        Target = "npc1",
        Zoom   = 0.1,
    }
    AP {
        Text   = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
        Sender = -1,
        Target = "npc1",
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

    Dialog.Starting = function(_Data)
        -- Mach was tolles hier.
    end
    Dialog.Finished = function(_Data)
        -- Mach was tolles hier.
    end
    API.StartDialog(Dialog, _Name, _PlayerID);
end