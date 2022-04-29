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
    Mission_OnQsbLoaded();
end

-- -------------------------------------------------------------------------- --
-- In dieser Funktion können eigene Funktionrn aufgerufen werden. Sie werden
-- atomatisch dann gestartet, wenn die QSB vollständig geladen wurde.
function Mission_OnQsbLoaded()
    -- Testmodus aktivieren
    -- (Auskommentieren, wenn nicht benötigt)
    API.ActivateDebugMode(true, false, true, true);
    -- Assistenten Quests starten
    -- (Auskommentieren, wenn nicht benötigt)
    -- CreateQuests();

    TEST_COMMAND = API.RegisterScriptCommand("TestFunction", TestFunction);
    CreateTestIOs();
    CreateTestNPCs();
end

-- -------------------------------------------------------------------------- --
-- IO

function CreateTestIOs()
    for i= 1, 2 do
        API.SetupObject {
            Name     = "IO" ..i,
            Distance = 1500,
            Costs    = {Goods.G_Wood, 5},
            Reward   = {Goods.G_Gold, 1000},
            Player   = i,
            Callback = function(_Data, _KnightID, _PlayerID)
                API.Note("Player " .._PlayerID.. " has activated " .._Data.Name);
            end
        };
        API.InteractiveObjectActivate(NPC1, 1, i);
    end
end

-- -------------------------------------------------------------------------- --
-- NPC

function CreateTestNPCs()
    for i= 1, 2 do
        MyNpc = API.NpcCompose {
            Name              = "NPC" ..i,
            Player            = i,
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
