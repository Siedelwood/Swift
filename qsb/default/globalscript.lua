-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Trage hier den Pfad ein, under dem deine Lua-Dateien liegen.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";

-- -------------------------------------------------------------------------- --

function Mission_InitPlayers()
end

function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

-- 
function Mission_FirstMapAction()
    -- Läd die QSB
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
    Script.Load(g_ContentPath.. "knighttitlerequirments.lua");

    API.Install();
    InitKnightTitleTables();

    -- Mapeditor-Einstellungen werden geladen
    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end

    -- Debug-Mode wird gestartet
    API.ActivateDebugMode(true, false, true, true);

    -- Hier kannst Du Deine Quests starten. Du kannst hier auch weitere
    -- Lua-Dateien laden, die deine Quests enthalten.
    -- Beispiel:
    -- Script.Load(g_ContentPath.. "myscriptfile.lua");
end
