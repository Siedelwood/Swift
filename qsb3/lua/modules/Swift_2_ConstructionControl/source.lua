--[[
Swift_2_ConstructionControl/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleConstructionControl = {
    Properties = {
        Name = "ModuleConstructionControl",
    },

    Global = {
        TerritoryBlockCategories = {},
        TerritoryBlockEntities = {},
        AreaBlockCategories = {},
        AreaBlockEntities = {},
    },
    Local = {},
}

-- Global ------------------------------------------------------------------- --

function ModuleConstructionControl.Global:OnGameStart()
    for i= 1, 8 do
        self.TerritoryBlockCategories[i] = {};
        self.TerritoryBlockEntities[i] = {};
        self.AreaBlockCategories[i] = {};
        self.AreaBlockEntities[i] = {};
    end
    self:OverrideCanPlayerPlaceBuilding();
end

function ModuleConstructionControl.Global:OverrideCanPlayerPlaceBuilding()
    GameCallback_CanPlayerPlaceBuilding_Orig_ConstructionControl = GameCallback_CanPlayerPlaceBuilding;
    GameCallback_CanPlayerPlaceBuilding = function(_PlayerID, _Type, _x, _y)
        if not ModuleConstructionControl.Global:CanPlayerPlaceCategoryAtTerritory(_PlayerID, _Type, _x, _y) then
            return false;
        end
        if not ModuleConstructionControl.Global:CanPlayerPlaceTypeAtTerritory(_PlayerID, _Type, _x, _y) then
            return false;
        end
        if not ModuleConstructionControl.Global:CanPlayerPlaceCategoryInArea(_PlayerID, _Type, _x, _y) then
            return false;
        end
        if not ModuleConstructionControl.Global:CanPlayerPlaceTypeInArea(_PlayerID, _Type, _x, _y) then
            return false;
        end
        return GameCallback_CanPlayerPlaceBuilding_Orig_ConstructionControl(_PlayerID, _Type, _x, _y);
    end
end

function ModuleConstructionControl.Global:CanPlayerPlaceCategoryAtTerritory(_PlayerID, _Type, _x, _y)
    for i= 1, 8 do
        if i == _PlayerID then
            for k, v in pairs(self.TerritoryBlockCategories[i]) do
                if Logic.IsEntityTypeInCategory(_Type, k) == 1 then
                    for _, TerritoryID in pairs(v) do
                        if Logic.GetTerritoryAtPosition(_x, _y) == TerritoryID then
                            return false;
                        end
                    end
                end
            end
        end
    end
    return true;
end

function ModuleConstructionControl.Global:CanPlayerPlaceTypeAtTerritory(_PlayerID, _Type, _x, _y)
    for i= 1, 8 do
        if i == _PlayerID then
            for k, v in pairs(self.TerritoryBlockEntities[i]) do
                if k == _Type then
                    for _, TerritoryID in pairs(v) do
                        if Logic.GetTerritoryAtPosition(_x, _y) == TerritoryID then
                            return false;
                        end
                    end
                end
            end
        end
    end
    return true;
end

function ModuleConstructionControl.Global:CanPlayerPlaceCategoryInArea(_PlayerID, _Type, _x, _y)
    for i= 1, 8 do
        if i == _PlayerID then
            for k, v in pairs(self.AreaBlockCategories[i]) do
                if Logic.IsEntityTypeInCategory(_Type, k) == 1 then
                    for _, AreaData in pairs(v) do
                        if API.GetDistance(AreaData[1], {X= _x, Y= _y}) < AreaData[2] then
                            return false;
                        end
                    end
                end
            end
        end
    end
    return true;
end

function ModuleConstructionControl.Global:CanPlayerPlaceTypeInArea(_PlayerID, _Type, _x, _y)
    for i= 1, 8 do
        if i == _PlayerID then
            for k, v in pairs(self.AreaBlockEntities[i]) do
                if k == _Type then
                    for _, AreaData in pairs(v) do
                        if API.GetDistance(AreaData[1], {X= _x, Y= _y}) < AreaData[2] then
                            return false;
                        end
                    end
                end
            end
        end
    end
    return true;
end

-- Local -------------------------------------------------------------------- --

function ModuleConstructionControl.Local:OnGameStart()
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleConstructionControl);

