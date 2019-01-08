-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Local Script - <MAPNAME>                                               # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Trage hier den Pfad ein, under dem deine Lua-Dateien liegen.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";

-- Wird aufgerufen, sobald das Spiel gewonnen ist.
function Mission_LocalVictory()
end

-- Wird aufgerufen, wenn das Spiel gestartet wird.
function Mission_LocalOnMapStart()
    -- Läd die QSB
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
    Script.Load(g_ContentPath.. "knighttitlerequirments.lua");
    
    API.Install();
    InitKnightTitleTables();
end

