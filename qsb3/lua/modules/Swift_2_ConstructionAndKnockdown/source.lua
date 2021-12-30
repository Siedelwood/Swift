--[[
Swift_2_ConstructionAndKnockdown/API

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
        ConstructionConditionCounter = 0,
        ConstructionConditions = {},
        KnockdownConditionCounter = 0,
        KnockdownConditions = {},
    },
    Local = {},
}

-- Global ------------------------------------------------------------------- --

function ModuleConstructionControl.Global:OnGameStart()
    self:OverrideCanPlayerPlaceBuilding();

    API.StartHiResJob(function()
        ModuleConstructionControl.Global:CheckAllBuildingKnockdownState();
    end);
end

function ModuleConstructionControl.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.EntityCreated then
        self:OnEntityCreated(arg[1]);
    end
end

function ModuleConstructionControl.Global:OverrideCanPlayerPlaceBuilding()
    GameCallback_CanPlayerPlaceBuilding_Orig_ConstructionControl = GameCallback_CanPlayerPlaceBuilding;
    GameCallback_CanPlayerPlaceBuilding = function(_PlayerID, _Type, _x, _y)
        if not ModuleConstructionControl.Global:CheckConstructionConditions(_PlayerID, _Type, _x, _y) then
            return false;
        end
        return GameCallback_CanPlayerPlaceBuilding_Orig_ConstructionControl(_PlayerID, _Type, _x, _y);
    end
end

function ModuleConstructionControl.Global:OnEntityCreated(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local EntityType = Logic.GetEntityType(_EntityID);
    local x, y, z = Logic.EntityGetPos(_EntityID);
    if Logic.IsEntityInCategory(_EntityID, EntityCategories.Wall) == 1 then
        if not self:CheckConstructionConditions(PlayerID, EntityType, x, y) then
            -- Destroy entity
            if Logic.IsConstructionComplete(_EntityID) == 1 then
                Logic.HurtEntity(_EntityID, Logic.GetEntityHealth(_EntityID));
            else
                Logic.DestroyEntity(_EntityID);
            end
            -- Cancel state
            Logic.ExecuteInLuaLocalState(string.format(
                [[if GUI.GetPlayerID() == %d then GUI.CancelState() end]],
                PlayerID
            ));
        end
    end
end

function ModuleConstructionControl.Global:CheckAllBuildingKnockdownState()
    for i= 1, 8 do
        local Buildings = {Logic.GetPlayerEntitiesInCategory(i, EntityCategories.AttackableBuilding)};
        Buildings = Array_Append(Buildings, {Logic.GetPlayerEntitiesInCategory(i, EntityCategories.PalisadeSegment)});
        Buildings = Array_Append(Buildings, {Logic.GetPlayerEntitiesInCategory(i, EntityCategories.Wall)});
        for k, v in pairs(Buildings) do
            if Logic.IsBuildingBeingKnockedDown(v) and not self:CheckKnockdownConditions(v) then
                Logic.ExecuteInLuaLocalState(string.format([[GUI.CancelBuildingKnockDown(%d)]], v));
            end
        end
    end
end

function ModuleConstructionControl.Global:GenerateConstructionConditionID()
    self.ConstructionConditionCounter = self.ConstructionConditionCounter +1;
    return self.ConstructionConditionCounter;
end

function ModuleConstructionControl.Global:CheckConstructionConditions(_PlayerID, _Type, _x, _y)
    for k, v in pairs(self.ConstructionConditions) do
        if not v(_PlayerID, _Type, _x, _y) then
            return false;
        end
    end
    return true;
end

function ModuleConstructionControl.Global:GenerateKnockdownConditionID()
    self.KnockdownConditionCounter = self.KnockdownConditionCounter +1;
    return self.KnockdownConditionCounter;
end

function ModuleConstructionControl.Global:CheckKnockdownConditions(_EntityID)
    for k, v in pairs(self.KnockdownConditions) do
        if IsExisting(_EntityID) and not v(_EntityID) then
            return false;
        end
    end
    return true;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleConstructionControl);

