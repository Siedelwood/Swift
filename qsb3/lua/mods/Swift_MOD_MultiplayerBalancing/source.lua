--[[
Swift_MOD_CampaignMap/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModMultiplayerBalancing = {
    Global = {},
    Local  = {},
    Shared = {}
}

-- - Global ----------------------------------------------------------------- --

function ModMultiplayerBalancing.Global:OnGameStart()

end

function ModMultiplayerBalancing.Global:OnEvent(_ID, _Event, ...)

end

-- - Local ------------------------------------------------------------------ --

function ModMultiplayerBalancing.Local:OnGameStart()

end

function ModMultiplayerBalancing.Local:OnEvent(_ID, _Event, ...)

end

-- - Shared ----------------------------------------------------------------- --

function ModMultiplayerBalancing.Local:LoadConfiguration()
    -- FIXME: Other folders?
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/config.lua");
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModMultiplayerBalancing);

