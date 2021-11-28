--[[
Swift_2_DestructionControl/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleDestructionControl = {
    Properties = {
        Name = "ModuleDestructionControl",
    },

    Global = {},
    Local = {
        NamedEntities = {},
        EntityTypes = {},
        EntityCategories = {},
        InArea = {},
        OnTerritory = {},
    },
}

-- Global ------------------------------------------------------------------- --

function ModuleDestructionControl.Global:OnGameStart()
end

-- Local -------------------------------------------------------------------- --

function ModuleDestructionControl.Local:OnGameStart()
    for i= 1, 8 do
        self.NamedEntities[i] = {};
        self.EntityTypes[i] = {};
        self.EntityCategories[i] = {};
        self.InArea[i] = {};
        self.OnTerritory[i] = {};
    end
    self:OverrideCanPlayerPlaceBuilding();
end

function ModuleDestructionControl.Local:OverrideCanPlayerPlaceBuilding()
    GameCallback_GUI_DeleteEntityStateBuilding_Orig_DestructionControl = GameCallback_GUI_DeleteEntityStateBuilding;
    GameCallback_GUI_DeleteEntityStateBuilding = function(_BuildingID)
        if ModuleDestructionControl.Local:CanPlayerKnockdownBuilding(_BuildingID) then
            return GameCallback_GUI_DeleteEntityStateBuilding_Orig_DestructionControl(_BuildingID);
        end
    end
end

function ModuleDestructionControl.Local:CanPlayerKnockdownBuilding(_BuildingID)
    local PlayerID1 = GUI.GetPlayerID();
    local PlayerID2 = Logic.EntityGetPlayer(_BuildingID);
    local EntityType = Logic.GetEntityType(_BuildingID);
    local ScriptName = Logic.GetEntityName(_BuildingID);
    local TerritoryID = GetTerritoryUnderEntity(_BuildingID);
    local x,y,z = Logic.EntityGetPos(_BuildingID);
    if PlayerID1 == PlayerID2 and Logic.IsConstructionComplete(_BuildingID) == 1 then
        if table.contains(self.NamedEntities[PlayerID1], ScriptName) then
            GUI.CancelBuildingKnockDown(_BuildingID);
            return false;
        end
        if table.contains(self.EntityTypes[PlayerID1], EntityType) then
            GUI.CancelBuildingKnockDown(_BuildingID);
            return false;
        end
        if API.IsEntityInAtLeastOneCategory(_BuildingID, unpack(self.EntityCategories[PlayerID1])) then
            GUI.CancelBuildingKnockDown(_BuildingID);
            return false;
        end
        for k,v in pairs(self.InArea[PlayerID1]) do
            if API.GetDistance(v[1], _BuildingID) <= v[2] then
                return false;
            end
        end
        if table.contains(self.OnTerritory[PlayerID1], TerritoryID) then
            GUI.CancelBuildingKnockDown(_BuildingID);
            return false;
        end
    end
    return true;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleDestructionControl);

