-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Local Script - <MAPNAME>                                               # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Trage hier den Pfad ein auf dem die Inhalte liegen.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";

-- Globaler Namespace für deine Missionsvariablen.
-- Variablen aus dem globalen Skript werden unter g_Mission.GlobalValues
-- automatisch referenziert.
g_Mission = {
    GlobalValues = Logic.CreateReferenceToTableInGlobaLuaState("g_Mission")
};

-- -------------------------------------------------------------------------- --

-- In dieser Funktion kannst Du deine Skripte laden.
function Mission_LoadFiles()
    Script.Load(g_ContentPath.. "/questsystembehavior.lua");
    Script.Load(g_ContentPath.. "/knighttitlerequirements.lua");

    -- Lade hier weitere Skripte!
end

-- Wird aufgerufen, sobald das Spiel gewonnen ist.
function Mission_LocalVictory()
end

-- Wird aufgerufen, wenn das Spiel gestartet wird.
function Mission_LocalOnMapStart()
    Mission_LoadFiles();
    API.Install();
    InitKnightTitleTables();

    -- Rufe hier Deine Funktionen auf!

end

-- -------------------------------------------------------------------------- --

