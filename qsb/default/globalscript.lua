-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Trage hier den Pfad ein, under dem deine Lua-Dateien liegen. Kommentiere
-- die Originalzeile am besten nur aus. Vergiss nicht, später den alten Pfad
-- wiederherzustellen, wenn die Map live geht.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";

-- Lässt den Debug die Quests prüfen, wenn sie ausgeführt werden.
g_DbgCheckQuests = true;
-- Aktiviert die Statusverfolgung der Quests.
g_DbgQuestTrace = false;
-- Aktiviert Cheats
g_DbgCheatCodes = true;
-- Aktiviert Eingabeaufforderung
g_DbgCmdInput = true;

-- -------------------------------------------------------------------------- --

-- Mit dieser Funktion können Spieler von der AI-Initialisierung ausgeschlossen
-- werden. Nutze diese Funktion um eigene AI-Skripte zu starten.
function Mission_InitPlayers()
end

-- Setze den Startmonat mit dem der Wetterzyklus beginnt. Die Zahlen 1 bis 12
-- stehen für die Monate Januar bis Dezember.
function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3); -- 3 == März
end

-- 
function Mission_FirstMapAction()
    -- Läd die QSB
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
    -- Läd eigene Aufstiegsbedingungen
    -- Script.Load(g_ContentPath.. "knighttitlerequirments.lua");
    
    -- QSB wird gestartet. Nicht verändern!
    API.Install();
    InitKnightTitleTables();

    -- Mapeditor-Einstellungen werden geladen. Nicht verändern!
    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end

    -- Debug-Mode wird gestartet. Einstellungen oben ändern!
    API.ActivateDebugMode(g_DbgCheckQuests, g_DbgQuestTrace, g_DbgCheatCodes, g_DbgCmdInput);
    
    -- Mapeditor-Quests starten. Nur, wenn Quests im Editor gemacht werden!
    -- CreateQuests();
    -- Skript-Quests erzeugen. Nur, wenn Quests im Skript gemacht werden!
    Mission_SetupFinished();
end

function Mission_QuestCutsceneStart()
    -- Quest startet Intro Cutscene. Es kann auf "MissionStartQuest" getriggert
    -- werden um automatisch Quests zu starten, wenn die Cutscene beendet ist.
    API.CreateQuest {
        Name       = "MissionStartQuest",
        Visible    = false,
        EndMessage = false,

        Goal_InstantSuccess(),
        Reward_Briefing("C01_Intro"),
        Trigger_Time(0)
    }
end

-- -------------------------------------------------------------------------- --

function Mission_SetupFinished()
    -- Kameraflug am Anfang
    Mission_QuestCutsceneStart();

    -- Questerzeugung aufteilen in Kapitel
    -- Mission_CreateChapter1()
    -- Mission_CreateChapter2()
    -- Mission_CreateChapter3()
end

-- -------------------------------------------------------------------------- --
-- Quests                                                                     --
-- -------------------------------------------------------------------------- --

-- Platz für die Quests

-- -------------------------------------------------------------------------- --
-- Cutscenes                                                                  --
-- -------------------------------------------------------------------------- --

function C01_Intro()
    local cutscene = {
        barStyle = "small",
        disableGlobalInvulnerability = false,
        restoreCamera = false,
        restoreGameSpeed = false,
        disableSkipping = true,
        hideFoW = true,
        showSky = true,
        hideBorderPins = true
    };
    local AF = AddFlights(cutscene);

    -- Cutscene hier erstellen

    -- Beispiel-Flight, später löschen!
    -- Ein Flight besteht aus mehreren Stationen, die alle während der
    -- Duration abgeflogen werden. Die eingestellte Zeit wird für alle
    -- Stationen (außer der Startposition) aufgeteilt.
    -- Für mehr Informationen siehe BeginnersGuide.pdf!
    AF {
        -- Startpostion der Bewegung
        {
            Position = {"marketplace1", 2720, 5800, -20},
            LookAt   = {"marketplace1", -900},
            Text     = "Bla Bla",
        },
        -- Erste Station
        {
            Position = {"marketplace1", 2725, 6100, -32},
            LookAt   = {"marketplace1", -750},
            Text     = "Bla Bla",
            Action   = function()
                -- Eine Aktion, sobald die Bewegung zur Station beginnt.
            end
        },
        -- Zweite Station
        {
            Position = {"marketplace1", 2732, 6200, -48},
            LookAt   = {"marketplace1", -400},
            Text     = "Bla Bla",
        },
        -- Dritte Station
        {
            Position = {"marketplace1", 2735, 6000, -56},
            LookAt   = {"marketplace1", 150},
            Text     = "Bla Bla",
        },
        FadeOut  = 0.5, -- Ausblenden am Ende
        FadeIn   = 0.5, -- Einblenden am Anfang
        Duration = 15,  -- Gesamtdauer des Flight
    };

    cutscene.finished = function()
        -- Funktion, die am Ende aufgerufen wird.
    end
    return StartCutscene(cutscene);
end

