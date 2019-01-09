-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Local Script - <MAPNAME>                                               # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Pfad an das Verzeichnis anpassen, in dem die Skripte liegen.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";
Script.Load(g_ContentPath.. "internlocalmapscript.lua");

-- Diese Funktion wird aufgerufen, sobald die Mission beendet ist.
function OnMissionVictory()
end

-- In dieser Funktion kannst Du zusätzliche Skripte laden.
function InitMissionScript()
end

-- Diese Funktion wird aufgerufen, sobald die Map bereit ist.
function FirstMapAction()
end