-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Local Script - <MAPNAME>                                               # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Trage hier den Pfad ein, wo Deine Inhalte liegen.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";

-- Globaler Namespace für Deine Variablen
-- Variablen aus dem globalen Skript werden automatisch referenziert.
-- (g_Mission.Var --> g_Mission.GlobalVariables.Var)
g_Mission = {
    GlobalVariables = Logic.CreateReferenceToTableInGlobaLuaState("g_Mission"),
};

-- -------------------------------------------------------------------------- --
-- Basisfunktionen                                                            --
-- -------------------------------------------------------------------------- --
--      Die folgenden Funktionen setzen die wichtigsten Einstellungen für Deine
--      Map. Hier kannst du Spielerfarben, Handelsangebote und KI-Einstellungen
--      setzen, Funktionen aufrufen und Deine Skripte laden.

-- Läd die Kartenskripte der Mission.
function Mission_LoadFiles()
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
    Script.Load(g_ContentPath.. "knighttitlerequirements.lua");

    -- Füge hier weitere Skriptdateien hinzu.
end

-- Wird aufgerufen, sobald das Spiel gewonnen ist.
function Mission_LocalVictory()
end

-- Wird aufgerufen, wenn das Spiel gestartet wird.
function Mission_LocalOnMapStart()
    Mission_LoadFiles();
    API.Install();
    InitKnightTitleTables();

    -- Hier kannst Du Deine Funktionen aufrufen:

end

