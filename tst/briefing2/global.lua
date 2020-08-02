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
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/questsystembehavior.lua");

    -- Mapeditor-Einstellungen werden geladen
    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end

    API.ActivateDebugMode(true, true, true, true);

    API.StartMissionBriefing(Briefing06);

    API.CreateQuest {
        Name = "TestQuest",
        EndMessage = true,
        Goal_InstantSuccess(),
        Trigger_MissionBriefing()
    }
end

-- -------------------------------------------------------------------------- --

function Briefing01()
    local Briefing = {
        HideBorderPins = true,
        ShowSky = true,
        RestoreGameSpeed = true,
        RestoreCamera = true,
        SkippingAllowed = false,
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
        BigBars = false,
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
        Splashscreen = {
            Image     = "C:/Users/angermanager/Downloads/alisa.png",
            Animation = {
                {0, 0, 1, 0.7},
                {0, 0.3, 1, 1},
                20,
            }
        },
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
        Position     = CastleID,
        Title        = "Auswahl",
        Text         = "Eine wichtige Entscheidung muss getroffen werden!",
        DialogCamera = false,
        NoRethink    = true,
        MC           = {
            {ID = 1, "Zu Seite 4 springen", "ResultPage1"},
            {ID = 2, "Remove me", "ResultPage1", Remove = true},
            {ID = 3, "Do not show me", "ResultPage1", Disable = function() return true end},
            {ID = 4, "Zu Seite 7 springen", "ResultPage2"}
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

function Briefing05()
    local Briefing = {
        HideBorderPins = true,
        ShowSky = true,
        RestoreGameSpeed = true,
        RestoreCamera = true,
        SkippingAllowed = true,
    }
    local AP, ASP = API.AddPages(Briefing);

    AP {
        Title       = "Page 1",
        Text        = "This is page 1!",
        Duration    = 10,
        Animations  = {
            {
                Duration = 2 * 60,
                Start = {
                    Position = {"pos4", 0},
                    Rotation = -60,
                    Zoom     = 2000,
                    Angle    = 35,
                },
                End   = {
                    Position = {"pos3", 0},
                    Rotation = -30,
                    Zoom     = 2000,
                    Angle    = 25,
                }
            },
        }
    }

    AP {
        Title       = "Page 2",
        Text        = "This is page 2!",
        Duration    = 10,
    }

    AP {
        Title       = "Page 3",
        Text        = "This is page 3!",
        Duration    = 10,
        Animations  = {
            PurgeOld = true,
            {
                Duration = 2 * 60,
                Start = {
                    Position = {"pos2", 0},
                    Rotation = -45,
                    Zoom     = 6000,
                    Angle    = 35,
                },
                End   = {
                    Position = {"pos2", 0},
                    Rotation = -45,
                    Zoom     = 3000,
                    Angle    = 35,
                }
            },
        }
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    return API.StartBriefing(Briefing)
end

function Briefing06()
    local Briefing = {
        HideBorderPins = true,
        ShowSky = true,
        RestoreGameSpeed = true,
        RestoreCamera = true,
        SkippingAllowed = true,
    }
    local AP, ASP = API.AddPages(Briefing);

    ASP("Page1", "pos4", "Page 1", "This is page 1!", false)
    ASP("pos4", "Page 2", "This is page 2!", false);
    ASP("Page3", "pos4", "Page 3", "This is page 3!", false);
    ASP("pos4", "Page 4", "This is page 4!", false);
    ASP("pos4", "Page 5", "This is page 5!", false);

    Briefing.PageAnimations = {
        ["Page1"] = {
            {"pos4", -60, 2000, 35, "pos4", -30, 2000, 25, 30}
        },
        ["Page3"] = {
            PurgeOld = true,
            {"pos2", -45, 6000, 35, "pos2", -45, 3000, 35, 30},
        }
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    return API.StartBriefing(Briefing)
end