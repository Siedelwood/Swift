-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Local Script - <MAPNAME>                                               # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Trage hier den Pfad ein, under dem deine Lua-Dateien liegen. Kommentiere
-- die Originalzeile am besten nur aus. Vergiss nicht, später den alten Pfad
-- wiederherzustellen, wenn die Map live geht.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";

-- Wird aufgerufen, sobald das Spiel gewonnen ist.
function Mission_LocalVictory()
end

-- Wird aufgerufen, wenn das Spiel gestartet wird.
function Mission_LocalOnMapStart()
    -- Läd die QSB
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
    -- Läd eigene Aufstiegsbedingungen
    -- Script.Load(g_ContentPath.. "knighttitlerequirments.lua");
    
    -- QSB wird gestartet. Nicht verändern!
    API.Install();
    InitKnightTitleTables();
end

