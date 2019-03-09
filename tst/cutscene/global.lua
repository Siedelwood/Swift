-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Trage hier den Pfad ein, wo Deine Inhalte liegen.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";

-- Globaler Namespace für Deine Variablen
g_Mission = {};

-- -------------------------------------------------------------------------- --

-- Läd die Kartenskripte der Mission.
function Mission_LoadFiles()
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
    Script.Load(g_ContentPath.. "knighttitlerequirements.lua");

    -- Füge hier weitere Skriptdateien hinzu.
end

-- Setzt Voreinstellungen für KI-Spieler.
-- (Spielerfarbe, AI-Blacklist, etc)
function Mission_InitPlayers()
end

-- Setzt den Monat, mit dem das Spiel beginnt.
function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

-- Setzt Handelsangebote der Nichtspielerparteien.
function Mission_InitMerchants()
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

    API.ActivateDebugMode(true, false, true, true);

    -- Startet die Mapeditor-Quests
    CreateQuests();

    -- Hier kannst Du Deine Funktionen aufrufen:

    Cutscene01();
end

-- -------------------------------------------------------------------------- --

function Cutscene01()
    local Cutscene = {
        RestoreGameSpeed = false,
        HideBorderPins   = true,
        TransperentBars  = false,
        FastForward      = true,

        {
            Flight  = "c01_f01",
            Title   = "Flight 1",
            Text    = "Das ist ein Test!",
            Action  = nil,
            FadeIn  = 3.0,
            FadeOut = nil,
        },
        {
            Flight  = "c01_f02",
            Title   = "Flight 2",
            Text    = "Das ist ein Test!",
            Action  = nil,
            FadeIn  = nil,
            FadeOut = nil,
        },
        {
            Flight  = "c01_f03",
            Title   = "Flight 3",
            Text    = "Das ist ein Test!",
            Action  = nil,
            FadeIn  = nil,
            FadeOut = 3.0,
        },

        Finished = nil;
    };
    return API.CutsceneStart(Cutscene);
end