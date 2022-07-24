--[[
Swift_0_Core/Bugfixes

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- This portion of the QSB is reserved for fixing bugs in the game.

-- Initalize bugfixes in global env
function Swift:InitalizeBugfixesGlobal()
    self:AddResourceSlotsToStorehouses();
end

-- Reload bugfixes after loading in global env
function Swift:GlobalRestoreBugfixesAfterLoad()
    
end

-- Adds salt and dye to all storehouses. This fixes the problem that luxury
-- can not be sold to AI players.
function Swift:AddResourceSlotsToStorehouses()
    for i= 1, 8 do
        local StoreHouseID = Logic.GetStoreHouse(i);
        if StoreHouseID ~= 0 then
            Logic.AddGoodToStock(StoreHouseID, Goods.G_Salt, 0, true, true);
            Logic.AddGoodToStock(StoreHouseID, Goods.G_Dye, 0, true, true);
        end
    end
end

-- -------------------------------------------------------------------------- --

-- Initalize bugfixes in local env
function Swift:InitalizeBugfixesLocal()
    
end

-- Reload bugfixes after loading in local env
function Swift:LocalRestoreBugfixesAfterLoad()
    
end

