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
end

-- -------------------------------------------------------------------------- --
-- In dieser Funktion können eigene Funktionrn aufgerufen werden. Sie werden
-- atomatisch dann gestartet, wenn die QSB vollständig geladen wurde.
function Mission_MP_OnQSBLoaded()
    -- Testmodus aktivieren
    -- (Auskommentieren, wenn nicht benötigt)
    API.ActivateDebugMode(true, false, true, true);
    -- Assistenten Quests starten
    -- (Auskommentieren, wenn nicht benötigt)
    -- CreateQuests();

    TEST_COMMAND = API.RegisterScriptCommand("TestFunction", TestFunction);
    CreateTestIOs();
    CreateTestNPCs();
    CreateTestBriefingQuests();
    CreateTestDialogQuests();
end

-- -------------------------------------------------------------------------- --
-- Briefing

function CreateTestBriefingQuests()
    for k,v in pairs(API.GetActivePlayers()) do
        API.CreateQuest {
            Name        = "BriefingQuest" ..v,
            Sender      = v,
            Receiver    = v,
            Suggestion  = "Da ist so ein bärtiger Typ... (Player " ..v.. ")",

            Goal_NPC("NPC_Briefing" ..v),
            Reward_Briefing("P" ..v.. "_Briefing1", "TestBriefing"),
            Trigger_Time(5)
        }
    end
end

function TestBriefing(_Name, _PlayerID)
    local Briefing = {
        DisableFoW = true,
        EnableSky = true,
        DisableBoderPins = true,
    };
    local AP, ASP, AAN = API.AddBriefingPages(Briefing);
    local HeroID = QSB.Npc.LastHeroEntityID;

    ASP("NPC", "Was für ein wunderschöner Tag, um stundenlang zu beten, auf"..
        "das mein Bart noch länger werde?", "NPC_Briefing" .._PlayerID, true);
    AP {
        Name  = "ChoicePage1",
        Title = "",
        Text  = "",
        MC    = {
            {"Viel Glück!", "Option1"},
            {"Schon Haarwuchsmittel probiert?", "Option2"},
        }
    }

    local Page = ASP("Held", "Tu, was du nicht lassen kannst.", HeroID, true);
    Page.Name = "Option1";
    ASP("NPC", "Allah wird mir Kraft geben!", "NPC_Briefing" .._PlayerID, true);
    AP();
    local Page = ASP("Held", "Ich kenne ein gutes Haarwuchsmittel", HeroID, true);
    Page.Name = "Option2";
    ASP("NPC", "Wirklich? Danke!", "NPC_Briefing" .._PlayerID, true);

    API.StartBriefing(Briefing, _Name, _PlayerID);
end

-- -------------------------------------------------------------------------- --
-- Dialog

function CreateTestDialogQuests()
    for k, v in pairs(API.GetActivePlayers()) do
        API.CreateQuest {
            Name        = "DialogQuest" ..v,
            Sender      = v,
            Receiver    = v,
            Suggestion  = "Eine Nonne hat meine Stadt besucht. (Player " ..v.. ")",

            Goal_NPC("NPC_Dialog" ..v),
            Reward_Dialog("P" ..v.. "_Dialog1", "TestDialog"),
            Trigger_Time(5)
        }
    end
end

function TestDialog(_Name, _PlayerID)
    local Dialog = {
        DisableFoW = true,
        EnableSky = true,
        DisableBoderPins = true,
    };
    local AP, ASP, AAN = API.AddDialogPages(Dialog);
    local HeroID = QSB.Npc.LastHeroEntityID;

    ASP(6, "NPC_Dialog" .._PlayerID, "Gott hat mich erleuchtet. Ich werde".. 
        " nicht mehr sündigen und die Kerzen in Frieden lassen.", true);
    AP {
        Sender       = _PlayerID,
        Title        = "",
        Text         = "",
        Target       = HeroID,
        DialogCamera = true,
        MC           = {
            {"Urgh! Mir wird schlecht.", "Option1"},
            {"Hätte noch Reserven.", "Option2"},
        }
    }

    local Page = ASP(_PlayerID, HeroID, "Ähm... ja. Schön für dich! Ich muss"..
        " mal reiern gehen...", true);
    Page.Name = "Option1";
    ASP(6, "NPC_Dialog" .._PlayerID, "Ich hab ein Mittel gegen Übelkeit.", true);
    AP();
    local Page = ASP(_PlayerID, HeroID, "Nicht doch! Ich hab noch welche in"..
        " meinem Keller vorrätig. Die müssen weg, bevor sie ablaufen", true);
    Page.Name = "Option2";
    ASP(6, "NPC_Dialog" .._PlayerID, "Der Herr stellt mich auf die Probe!"..
        " Doch ich bleibe stark!", true);

    API.StartDialog(Dialog, _Name, _PlayerID);
end

-- -------------------------------------------------------------------------- --
-- IO

function CreateTestIOs()
    for k,v in pairs(API.GetActivePlayers()) do
        API.SetupObject {
            Name     = "IO" ..v,
            Distance = 1500,
            Costs    = {Goods.G_Wood, 5},
            Reward   = {Goods.G_Gold, 1000},
            Player   = v,
            Callback = function(_Data, _KnightID, _PlayerID)
                API.Note("Player " .._PlayerID.. " has activated " .._Data.Name);
            end
        };
    end
end

-- -------------------------------------------------------------------------- --
-- NPC

function CreateTestNPCs()
    for k,v in pairs(API.GetActivePlayers()) do
        MyNpc = API.NpcCompose {
            Name              = "NPC" ..v,
            Player            = v,
            WrongPlayerAction = function(_Data, _PlayerID, _KnightID)
                API.Note("Player ".._PlayerID.. " can not talk to " .._Data.Name);
            end,
            Callback          = function(_Data, _PlayerID, _KnightID)
                API.Note("Player " .._PlayerID.. " has talked to " .._Data.Name);
            end
        }
    end
end

-- -------------------------------------------------------------------------- --
-- General communication

function TestFunction(_Number, _String)
    local Text = "TestFunction :: Param1: " .._Number.. " Param2: " .._String;
    API.Note(Text);
end

function CallTestFunction()
    Logic.ExecuteInLuaLocalState("CallTestFunction()");
end

function CallTestFunction2()
    Logic.ExecuteInLuaLocalState("CallTestFunction2()");
end
