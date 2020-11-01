-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Local Script - <MAPNAME>                                               # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/development.lua");

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_LoadFiles
-- --------------------------------
-- Läd zusätzliche Dateien aus der Map.Die Dateien
-- werden in der angegebenen Reihenfolge geladen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_LoadFiles()
    if gvMission.DevelopmentMode then
        -- Pfad an dein System anpassen!
        gvMission.ContentPath = "E:/Repositories/symfonia/dmc/004_abschnitte_testmap.s6xmap.unpacked/" ..gvMission.ContentPath;
    end
    return {
        gvMission.ContentPath.. "knighttitlerequirements.lua",
        
        gvMission.ContentPath.. "inc/local/x_localmapscript.lua",
    };
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
function Mission_LocalOnQsbLoaded()
    X_MapIsReady();
end