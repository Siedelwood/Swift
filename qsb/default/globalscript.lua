-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Trage hier den Pfad ein auf dem die Inhalte liegen.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";

-- Globaler Namespace für deine Missionsvariablen.
g_Mission = {};

-- -------------------------------------------------------------------------- --

-- In dieser Funktion kannst Du deine Skripte laden.
function Mission_LoadFiles()
    Script.Load(g_ContentPath.. "/questsystembehavior.lua");
    Script.Load(g_ContentPath.. "/knighttitlerequirements.lua");

    -- Lade hier weitere Skripte!
end

-- Setzt Einstellungen für die Spielparteien.
-- (KI-Blacklist, Farben, ect.)
function Mission_InitPlayers()
end

-- Setzt den Monat in dem das Spiel beginnt.
function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

-- Nutze diese Funktion um Aktionen zu Spielstart auszuführen.
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

    -- Erzeugt die Editor-Quests
    CreateQuests();

    -- Rufe hier Deine Funktionen auf!
    
end

-- -------------------------------------------------------------------------- --

