-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Local Script - <MAPNAME>                                               # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Trage hier den Pfad ein, wo Deine Inhalte liegen.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";

-- Lade Inhalte aus dem Testpfad. Auf true setzen zum aktivieren.
if false then
    -- Trage hier den Pfad zu Deinem Mapverzeichnis ein. Achte darauf / statt \
    -- zu verwenden. Der Pfad muss mit einem / enden.
    g_ContentPath = "C:/Maps/MapName/";
end

-- Globaler Namespace für Deine Variablen
-- Variablen aus dem globalen Skript werden automatisch referenziert.
-- (gvMission.Var --> gvMission.GlobalVariables.Var)
gvMission = {
    GlobalVariables = Logic.CreateReferenceToTableInGlobaLuaState("gvMission"),
};

-- -------------------------------------------------------------------------- --
-- Basisfunktionen                                                            --
-- -------------------------------------------------------------------------- --
--      Die folgenden Funktionen setzen die wichtigsten Einstellungen für Deine
--      Map. Hier kannst du Spielerfarben, Handelsangebote und KI-Einstellungen
--      setzen, Funktionen aufrufen und Deine Skripte laden.

-- Läd die Kartenskripte der Mission.
function Mission_LoadFiles()
    -- Die Quest-Bibliothek wird geladen
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
    -- Optional: Füge der Map ein Skript mit namen knighttitlerequirements.lua
    -- hinzu, wenn die Aufstiegsbedingungen geändert werden sollen. 
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

