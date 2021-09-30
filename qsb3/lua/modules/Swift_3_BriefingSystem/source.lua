--[[
Swift_3_BriefingSystem/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleBriefingSystem = {
    Properties = {
        Name = "ModuleBriefingSystem",
    },

    Global = {},
    Local = {},
    -- This is a shared structure but the values are asynchronous!
    Shared = {},
};

-- Global ------------------------------------------------------------------- --

function ModuleBriefingSystem.Global:OnGameStart()
    
end

function ModuleBriefingSystem.Global:OnEvent(_ID, _Event, _PlayerID)
    if _ID == QSB.ScriptEvents.EscapePressed then
        
    end
end



-- Local -------------------------------------------------------------------- --

function ModuleBriefingSystem.Local:OnGameStart()

end



-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleBriefingSystem);

