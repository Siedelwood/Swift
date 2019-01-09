-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Pfad an das Verzeichnis anpassen, in dem die Skripte liegen.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";
Script.Load(g_ContentPath.. "internmapscript.lua");

-- Triggere deine Quests auf "MissionStartQuest".
-- Rufe GlobalMissionScript_SetIntro auf um eine Intro zu setzen.
-- Rufe GlobalMissionScript_SetCredits auf um die Credits einzustellen.
-- "MissionStartQuest" wird auf Intro und/oder Credits warten.

-- In dieser Funktion können Spieler initialisiert werden.
function InitPlayers()
end

-- Diese Funktion setzt den Startmonat.
function SetStartingMonth()
    Logic.SetMonthOffset(3);
end

-- In dieser Funktion kannst Du zusätzliche Skripte laden.
function InitMissionScript()
end

-- Diese Funktion wird aufgerufen, sobald die Map bereit ist.
function FirstMapAction()
    API.ActivateDebugMode(true, false, true, true);
end