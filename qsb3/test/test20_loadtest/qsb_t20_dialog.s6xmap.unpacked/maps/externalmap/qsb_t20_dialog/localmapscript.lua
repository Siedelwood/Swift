--[[
    ***********************************************************************
    Lokales Skript

    Kartenname: Ein neuer Horizont
    Autor:      totalwarANGEL
    Version:    1.0
    ***********************************************************************     
]]

Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/development.lua");

function Mission_LocalVictory()
end

function Mission_LoadFiles()
    if gvMission.MapIsInDevelopmentMode then
        local Path = gvMission.ContentPath;
        Path = "E:/Repositories/swift/qsb3/test/test20_loadtest/qsb_t20_dialog.s6xmap.unpacked/" ..Path;
        gvMission.ContentPath = Path;
    end
    return {
    };
end

function Mission_LocalOnQsbLoaded()
end

-- -------------------------------------------------------------------------- --

