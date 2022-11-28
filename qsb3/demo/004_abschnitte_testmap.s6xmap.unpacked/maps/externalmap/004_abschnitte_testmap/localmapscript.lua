--[[
    ***********************************************************************
    Lokales Skript

    Kartenname: Grundstruktur
    Autor:      totalwarANGEL
    Version:    2.0
    ***********************************************************************     
]]

-- Läd das Skript mit der Variable des Entwicklungsmodus
Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/development.lua");

-- Diese Funktion nicht löschen!!
function Mission_LocalVictory()
end

function Mission_LoadFiles()
    -- Prüfe, ob der Entwicklungsmodus gesetzt ist
    if gvMission.DevelopmentMode then
        -- Der Pfad wird auf dein System umgestellt. Alle Inhalte der Map (z.B
        -- Skripte, Grafiken) werden nicht aus dem Kartenarchiv sondern aus dem
        -- Dateisystem deines Rechners geladen.
        -- (Der Testpfad muss an dein System angepasst werden)
        gvMission.ContentPath = "E:/Repositories/swift/qsb3/demo/004_abschnitte_testmap.s6xmap.unpacked/" ..gvMission.ContentPath;
    end
    -- Hier werden alle zusätzlichen Skripte geladen
    return {
        gvMission.ContentPath.. "knighttitlerequirements.lua",

        -- Hier wird das lokale Hauptskript geladen
        gvMission.ContentPath.. "inc/local/localmapscript.lua",
    };
end

function Mission_LocalOnQsbLoaded()
    -- Funktion in inc/local/localmapscript.lua aufrufen
    OnMapHasBeenPrepared();
end

