-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Trage hier den Pfad ein, wo Deine Inhalte liegen.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";

-- Globaler Namespace für Deine Variablen
gvMission = {};

-- Lade Inhalte aus dem Testpfad. Auf true setzen zum aktivieren.
if false then
    -- Trage hier den Pfad zu Deinem Mapverzeichnis ein. Achte darauf / statt \
    -- zu verwenden. Der Pfad muss mit einem / enden.
    g_ContentPath = "C:/Maps/MapName/";
end

-- -------------------------------------------------------------------------- --
-- Basisfunktionen                                                            --
-- -------------------------------------------------------------------------- --
--      Die folgenden Funktionen setzen die wichtigsten Einstellungen für Deine
--      Map. Hier kannst du Spielerfarben, Handelsangebote und KI-Einstellungen
--      setzen, Funktionen aufrufen und Deine Skripte laden.

-- Läd die Kartenskripte der Mission.
function Mission_LoadFiles()
    -- Die Quest-Bibliothek wird geladen
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
    -- Optional: Füge der Map ein Skript mit namen knighttitlerequirements.lua
    -- hinzu, wenn die Aufstiegsbedingungen geändert werden sollen. 
    Script.Load(g_ContentPath.. "knighttitlerequirements.lua");

    -- Füge hier weitere Skriptdateien hinzu.
end

-- Setzt Voreinstellungen für KI-Spieler.
function Mission_InitPlayers()
    -- Beispiel: KI-Skripte für Spieler 2 deaktivieren (nicht im Editor möglich)
    --
    -- DoNotStartAIForPlayer(2);
end

-- Setzt den Monat, mit dem das Spiel beginnt.
function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

-- Setzt Handelsangebote der Nichtspielerparteien.
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

-- Wird aufgerufen, wenn das Spiel gestartet wird.
function Mission_FirstMapAction()
    Mission_LoadFiles();
    API.Install();
    InitKnightTitleTables();

    -- Mapeditor-Einstellungen werden geladen
    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end

    -- Testmodus aktivieren
    -- API.ActivateDebugMode(true, false, true, true);

    -- Erzeugt im Assistenten erstellte Quests
    CreateQuests();

    -- Startet Quests, die im Skript erzeugt werden
    -- (Falls nicht gebraucht, löschen)
    Mission_StartQuests();

    -- Hier kannst Du Deine Funktionen aufrufen

end

-- -------------------------------------------------------------------------- --
-- Quests                                                                     --
-- -------------------------------------------------------------------------- --
--      Hier kannst Du Quests erzeugen. Füge Deine Quests hinzu, wenn Du Quests
--      im Skript erstellen willst. Arbeitest Du mit dem Assistenten, Aktiviere
--      stattdessen CreateQuests() (siehe oben).

function Mission_StartQuests()
    -- Füge hier die Aufrufe Deiner Quests hinzu.
end

