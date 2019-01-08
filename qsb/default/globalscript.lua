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

-- Stelle hier den Startmonat ein
-- (1 bis 12 für Januar bis Dezember)
g_MapStartingMonth = 3;

-- Auf true setzen, wenn eine Cutscene den Quests vorangestellt werden soll.
-- (Name der Funktion bei g_MapIntroName in "" eintragen)
g_MapUseIntro = false;
g_MapIntroName = "IntroCutsceneFunctionName";

-- Auf true setzen, wenn Credits angezeigt werden sollen.
-- Muss ebenfalls im lokalen Skript true sein!
g_MapUseCredits = false;

-- WICHTIGER Hinweis:
-- Wenn Du die Quests im Skript erzeugst, müssen die initialen Quests immer
-- mit Trigger_OnQuestSuccess auf "MissionStartQuest" getriggert werden!
-- Wenn du eine Intro Cutscene verwendest, ändert sich der Trigger zu
-- Trigger_Briefing!

-- Initialisiere hier deine Quests.
function Mission_SetupFinished()
    -- Initaler Quest wird gestartet
    Mission_QuestOnGameStart();

    -- Hier kannst Du Deine Quests starten. Du kannst hier auch weitere
    -- Lua-Dateien laden, die deine Quests enthalten. Benutze dafür immer
    -- g_ContentPath!
    -- Beispiel:
    -- Script.Load(g_ContentPath.. "myscriptfile.lua");
end

-- Trage hier Funktionen ein, die ausgeführt werden sollen, nachdem die Quests
-- initialisiert wurden und das Spiel gestartet ist.
function Mission_SecondMapAction()
    
end

-- -------------------------------------------------------------------------- --
-- Quests                                                                     --
-- -------------------------------------------------------------------------- --

-- Platz für Quests

-- -------------------------------------------------------------------------- --
-- Briefings                                                                  --
-- -------------------------------------------------------------------------- --

-- Platz für Briefings

-- -------------------------------------------------------------------------- --
-- Cutscenes                                                                  --
-- -------------------------------------------------------------------------- --

-- Platz für Cutscenes

-- -------------------------------------------------------------------------- --

-- Ab hier NICHTS mehr ändern!

function Mission_InitPlayers()
end

function Mission_SetStartingMonth()
    Logic.SetMonthOffset(g_MapStartingMonth);
end

function Mission_FirstMapAction()
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
    Script.Load(g_ContentPath.. "knighttitlerequirments.lua");
    API.Install();
    InitKnightTitleTables();

    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end
    if g_DbgCheckQuests or g_DbgQuestTrace or g_DbgCheatCodes or g_DbgCmdInput then
        API.ActivateDebugMode(g_DbgCheckQuests, g_DbgQuestTrace, g_DbgCheatCodes, g_DbgCmdInput);
    end
    CreateQuests();
    Mission_SetupFinished();
    Mission_SecondMapAction();
end

g_CreditsBoxesFinished = (g_MapUseCredits == false and true) or false;
function Mission_Trigger_WaitingForCreditsFinished()
    return g_CreditsBoxesFinished == true;
end

function Mission_Reward_DisplayUI()
    API.Bridge("Mission_LocalDisplayUI(1)");
end

function Mission_QuestOnGameStart()
    if BundleQuestGeneration then
        local Behaviors = {
            Goal_InstantSuccess(),
            Trigger_Time(0),
        };
        if g_MapUseIntro then
            table.insert(Behaviors, Reward_Briefing(g_MapIntroName));
        end
        if g_MapUseCredits then
            table.insert(Behaviors, Reward_MapScriptFunction("Mission_Reward_DisplayUI"));
            table.insert(Behaviors, Trigger_MapScriptFunction("Mission_Trigger_WaitingForCreditsFinished"));
        end
        API.CreateQuest { Name = "MissionStartQuest",  unpack(Behaviors)};
    end
end