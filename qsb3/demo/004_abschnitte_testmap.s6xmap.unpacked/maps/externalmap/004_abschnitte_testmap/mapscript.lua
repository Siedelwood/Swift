--[[
    ***********************************************************************
    Global Skript

    Kartenname: Grundstruktur
    Autor:      totalwarANGEL
    Version:    2.0
    ***********************************************************************     
]]

-- Läd das Skript mit der Variable des Entwicklungsmodus
Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/development.lua");

-- Diese Funktion nicht löschen!!
function Mission_FirstMapAction()
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/questsystembehavior.lua");

    -- Mapeditor-Einstellungen werden geladen
    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end
    Mission_OnQsbLoaded();
end

function Mission_InitPlayers()
end

function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

function Mission_InitMerchants()
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

        -- Die weiteren Skripte werden vor dem Hauptskript geladen
        -- (Das Namenschema kann sich an einer Einteilung in Abschnitte
        -- orientieren, muss es allerdings nicht. Wichtig ist, eine ggf.
        -- wichtige Reihenfolge einzuhalten.)
        gvMission.ContentPath.. "inc/global/q1_abschnitt1.lua",
        gvMission.ContentPath.. "inc/global/q2_abschnitt2.lua",

        -- Hier wird das globale Hauptskript geladen
        gvMission.ContentPath.. "inc/global/globalmapscript.lua",
    };
end

function Mission_OnQsbLoaded()
    API.ActivateDebugMode(true, false, true, true);

    -- Funktion in inc/global/globalmapscript.lua aufrufen
    OnMapHasBeenPrepared();
end

