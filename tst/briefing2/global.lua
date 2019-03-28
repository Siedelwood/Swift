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

    API.ActivateDebugMode(true, true, true, true);

    -- Startet die Mapeditor-Quests
    CreateQuests();

    -- Hier kannst Du Deine Funktionen aufrufen:
end

-- -------------------------------------------------------------------------- --

function Briefing01()
    local Briefing = {
        HideBorderPins = true,
        ShowSky = true,
        RestoreGameSpeed = true,
        RestoreCamera = true,
        SkippingAllowed = true,
    }
    local AP = API.AddPages(Briefing);

    AP {
        Title    = "Title 1",
        Text     = "Text 1",
        Position = {"pos1", 3000},
        LookAt   = {"pos2", 0},
        Duration = 2.0,
        FadeIn   = 3,
        Action   = function(_Data)
        end
    }
    AP {
        Title     = "Title 2",
        Text      = "Text 2",
        Position  = {"pos3", 3000},
        LookAt    = {"pos4", 0},
        FlyTo     = {
            Position  = {"pos3", 3000},
            LookAt    = {"pos4", 1000},
            Duration  = 10.0
        },
        FadeOut   = 3,
        Action    = function(_Data)
        end
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    return API.StartBriefing(Briefing)
end

function Briefing02()
    local Briefing = {
        HideBorderPins = true,
        ShowSky = true,
        RestoreGameSpeed = true,
        RestoreCamera = true,
    }
    local AP, ASP = API.AddPages(Briefing);

    AP {
        Title    = "Title 1",
        Text     = "Text 1",
        Position = "pos3",
        DialogCamera = true,
        Action   = function(_Data)
        end
    }
    AP {
        Title    = "Title 2",
        Text     = "Text 2",
        Position = "pos4",
        DialogCamera = false,
        Splashscreen = "C:/Users/angermanager/Downloads/shio.png",
        Action   = function(_Data)
        end
    }
    AP {
        Title    = "Title 3",
        Text     = "Text 3",
        Position = Logic.GetKnightID(1),
        DialogCamera = true,
        Action   = function(_Data)
        end
    }
    AP {
        Title    = "Title 4",
        Text     = "Text 4",
        Position = "pos4",
        DialogCamera = false,
        Action   = function(_Data)
        end
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    return API.StartBriefing(Briefing)
end

function Briefing03()
    local Briefing = {
        HideBorderPins = true,
        ShowSky = true,
        RestoreGameSpeed = true,
        RestoreCamera = true,
        SkippingAllowed = false,
    }
    local AP, ASP = API.AddPages(Briefing);
    local CastleID = Logic.GetHeadquarters(1);

    -- Page 1
    ASP(CastleID, "Seite 1", "Das ist Seite 1!", false);
    -- Page 2
    ASP(CastleID, "Seite 2", "Das ist Seite 2!", false);

    local JumpTo7 = function()
        return 7;
    end
    AP {
        Name         = "ChoicePage1",
        position     = CastleID,
        title        = "Auswahl",
        text         = "Eine wichtige Entscheidung muss getroffen werden!",
        DialogCamera = false,
        NoRethink    = true,
        MC           = {
            {"Zu Seite 4 springen", "ResultPage1"},
            {"Remove me", "ResultPage1", Remove = true},
            {"Do not show me", "ResultPage1", Disable = function() return true end},
            {"Zu Seite 7 springen", "ResultPage2"}
        }
    }

    -- Page 4
    local JumpedToPage4 = function()
    end
    ASP("ResultPage1", CastleID, "Seite 4", "Das ist Seite 4!", false, JumpedToPage4);
    -- Page 5
    ASP(CastleID, "Seite 5", "Das ist Seite 5!", false);
    AP("ChoicePage1");

    -- Page 7
    local JumpedToPage7 = function()
    end
    ASP("ResultPage2", CastleID, "Seite 7", "Das ist Seite 7!", false, JumpedToPage7);
    -- Page 8
    ASP(CastleID, "Seite 8", "Das ist Seite 8!", false);

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
        API.StaticNote(_Data:GetPage("ChoicePage1"):GetSelectedAnswer());
    end
    return API.StartBriefing(Briefing)
end

function Briefing04()
    local Briefing = {
        HideBorderPins = true,
        ShowSky = true,
        RestoreGameSpeed = true,
        RestoreCamera = true,
    }
    local AP, ASP = API.AddPages(Briefing);

    AP {
        Title    = "Title 1",
        Text     = "Text 1",
        Position = "pos3",
        DialogCamera = false,
        FadeIn   = 3.0,
        Duration = 5.0,
        Action   = function(_Data)
        end
    }
    AP {
        Title    = "Title 2",
        Text     = "Text 2",
        Position = "pos4",
        DialogCamera = false,
        Duration = 5.0,
        FadeOut  = 3.0,
        Action   = function(_Data)
        end
    }
    AP {
        Title    = "Title 3",
        Text     = "Text 3",
        Position = "pos3",
        DialogCamera = false,
        FadeIn   = 3.0,
        FadeOut  = 3.0,
        Duration = 10.0,
        Action   = function(_Data)
        end
    }
    AP {
        Title    = "Title 4",
        Text     = "Text 4",
        Position = "pos4",
        DialogCamera = false,
        FadeIn   = 3.0,
        Duration = 5.0,
        Action   = function(_Data)
        end
    }
    AP {
        Title    = "Title 5",
        Text     = "Text 5",
        Position = "pos1",
        FadeOut  = 3.0,
        Duration = 5.0,
        DialogCamera = false,
        Action   = function(_Data)
        end
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    return API.StartBriefing(Briefing)
end