--[[
    ***********************************************************************
    Global Skript

    Kartenname: Ein neuer Horizont
    Autor:      totalwarANGEL
    Version:    1.0
    ***********************************************************************     
]]

Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/development.lua");

function Mission_FirstMapAction()
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/questsystembehavior.lua");
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
    if gvMission.MapIsInDevelopmentMode then
        local Path = gvMission.ContentPath;
        Path = "E:/Repositories/swift/qsb3/test/test20_loadtest/qsb_t20_dialog.s6xmap.unpacked/" ..Path;
        gvMission.ContentPath = Path;
    end
    return {
        gvMission.ContentPath.. "testcases.lua",
    };
end

function Mission_OnQsbLoaded()
    API.ActivateDebugMode(true, false, true, true);
    OnMapIsReady();
end

-- -------------------------------------------------------------------------- --

