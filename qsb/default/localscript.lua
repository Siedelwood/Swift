-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Local Script - <MAPNAME>                                               # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Wird aufgerufen, sobald das Spiel gewonnen ist.
function Mission_LocalVictory()
end

-- Wird aufgerufen, wenn das Spiel gestartet wird.
function Mission_LocalOnMapStart()
    -- Läd die QSB
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName() .. "/questsystembehavior.lua");
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName() .. "/knighttitlerequirments.lua");
    
    API.Install();
    InitKnightTitleTables();
end

