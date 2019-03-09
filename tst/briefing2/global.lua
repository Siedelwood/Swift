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
    Script.Load("E:/Repositories/symfonia/var/qsb.lua");

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

    Briefing01()
end

-- -------------------------------------------------------------------------- --

function Briefing01()
    local Briefing = {
        HideBorderPins = true,
        ShowSky = true,
        RestoreGameSpeed = true,
        RestoreCamera = true,
    }
    local AP = API.AddPages(Briefing);

    AP {
        Title    = "Title 1",
        Text     = "Text 1",
        Position = "pos1",
        Duration = 2.0,
        Zoom     = 1000,
        Rotation = -40,
        Angle    = 48,
        FadeIn   = 3,
        Action   = function(_Data)
        end
    }
    AP {
        Title    = "Title 2",
        Text     = "Text 2",
        Position = "pos3",
        Zoom     = 2000,
        Rotation = 40,
        Angle    = 12,
        Duration = 10.0,
        FlyTime  = 10.0,
        FadeOut  = 3,
        Action   = function(_Data)
        end
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    API.StartBriefing(Briefing)
end

function Briefing02()
    local Briefing = {
        HideBorderPins = true,
        ShowSky = true,
        RestoreGameSpeed = true,
        RestoreCamera = true,
    }
    local AP = API.AddPages(Briefing);

    AP {
        Title    = "Title 3",
        Text     = "Text 3",
        Position = {"pos3", 1000},
        LookAt   = {"pos4", 0},
        Duration = 10.0,
        FadeIn   = 3,
        Action   = function(_Data)
        end
    }
    AP {
        Title    = "Title 4",
        Text     = "Text 4",
        Position = {"pos1", 1000},
        LookAt   = {"pos2", 0},
        Duration = 10.0,
        FadeOut  = 3,
        Action   = function(_Data)
        end
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    API.StartBriefing(Briefing)
end