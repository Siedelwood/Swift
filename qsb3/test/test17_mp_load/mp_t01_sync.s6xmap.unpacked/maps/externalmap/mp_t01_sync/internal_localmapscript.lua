-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Local Script - <MAPNAME>                                               # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_LoadFiles
-- --------------------------------
-- Läd zusätzliche Dateien aus der Map.Die Dateien
-- werden in der angegebenen Reihenfolge geladen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_LoadFiles()
    return {};
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_LocalVictory
-- --------------------------------
-- Diese Funktion wird aufgerufen, wenn die Mission
-- gewonnen ist.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_LocalVictory()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_FirstMapAction
-- --------------------------------
-- Die FirstMapAction wird am Spielstart aufgerufen.
-- Starte von hier aus deine Funktionen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_LocalOnMapStart()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_LocalOnQsbLoaded
-- --------------------------------
-- Die QSB ist im lokalen Skript initialisiert.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_MP_LocalOnQsbLoaded()
    Input.EnableDebugMode(1);
    Input.EnableDebugMode(2);
    Input.EnableDebugMode(3);
    LogTable();
end

function LogTable()
    API.StartJob(function()
        if Logic.GetTime() > 2 then
            Framework.WriteToLog(table.tostring(QSB.ScriptCommands));
            Framework.WriteToLog(table.tostring(Swift.m_ScriptCommandRegister));
            return true;
        end
    end);
end

function CallTestFunction()
    API.SendScriptCommand(QSB.ScriptCommands.TestFunction, 123, "abc");
end

function CallTestFunction2()
    API.SendScriptCommand(QSB.ScriptCommands.TestFunction, 456, "def");
end

