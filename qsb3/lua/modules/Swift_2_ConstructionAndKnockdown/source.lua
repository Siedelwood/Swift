--[[
Swift_2_ConstructionAndKnockdown/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

SCP.ConstructionAndKnockdown = {};

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
    Local = {
        WallData = {-1,};
    },
    Shared = {
        WallTypes = {
            "B_PalisadeSegment",
            "B_PalisadeGate",
            "B_WallGate_AS",
            "B_WallSegment_AS",
            "B_WallGate_NA",
            "B_WallSegment_NA",
            "B_WallGate_NE",
            "B_WallSegment_NE",
            "B_WallGate_ME",
            "B_WallSegment_ME",
            "B_WallGate_SE",
            "B_WallSegment_SE",
        }
    }
}

-- Global ------------------------------------------------------------------- --

function ModuleConstructionControl.Global:OnGameStart()
    API.RegisterScriptCommand("Cmd_CheckCancelKnockdown", SCP.ConstructionAndKnockdown.CancelKnockdown);

    self:OverrideCanPlayerPlaceBuilding();
end

function ModuleConstructionControl.Global:OnEvent(_ID, _Event, ...)
end

function ModuleConstructionControl.Global:OverrideCanPlayerPlaceBuilding()
    GameCallback_CanPlayerPlaceBuilding_Orig_ConstructionControl = GameCallback_CanPlayerPlaceBuilding;
    GameCallback_CanPlayerPlaceBuilding = function(_PlayerID, _Type, _x, _y)
        if not ModuleConstructionControl.Global:CheckConstructionConditions(_PlayerID, _Type, _x, _y) then
            return false;
        end
        return GameCallback_CanPlayerPlaceBuilding_Orig_ConstructionControl(_PlayerID, _Type, _x, _y);
    end

    -- As last resort to implement this 'cause all other approaches were to
    -- unreliable to accomplish safe wall erasure.
    API.StartHiResJob(function()
        for i= 1, #ModuleConstructionControl.Shared.WallTypes do
            local Type = Entities[ModuleConstructionControl.Shared.WallTypes[i]];
            if Type then
                local EntityList = Logic.GetEntitiesOfType(Type);
                for j= 1, #EntityList do
                    local PlayerID = Logic.EntityGetPlayer(EntityList[j]);
                    local x,y,z = Logic.EntityGetPos(EntityList[j]);
                    if  Logic.IsConstructionComplete(EntityList[j]) == 0
                    and not self:CheckConstructionConditions(PlayerID, Type, x, y) then
                        Logic.ExecuteInLuaLocalState(string.format([[
                            if GUI.GetPlayerID() == %d then
                                -- TODO: Add message
                                GUI.CancelState()
                            end
                        ]], PlayerID));
                        DestroyEntity(EntityList[j]);
                    end
                end
            end
        end
    end);
end

function ModuleConstructionControl.Global:CheckCancelBuildingKnockdown(_PlayerID, _BuildingID, _State)
    if Logic.EntityGetPlayer(_BuildingID) == _PlayerID and _State == 1 and not self:CheckKnockdownConditions(_BuildingID) then
        Logic.ExecuteInLuaLocalState(string.format([[GUI.CancelBuildingKnockDown(%d)]], _BuildingID));
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

-- Local -------------------------------------------------------------------- --

function ModuleConstructionControl.Local:OnGameStart()
    self:OverrideDeleteEntityStateBuilding();
end

function ModuleConstructionControl.Local:OverrideDeleteEntityStateBuilding()
    GameCallback_GUI_DeleteEntityStateBuilding_Orig_ConstructionControl = GameCallback_GUI_DeleteEntityStateBuilding;
    GameCallback_GUI_DeleteEntityStateBuilding = function(_BuildingID, _State)
        GameCallback_GUI_DeleteEntityStateBuilding_Orig_ConstructionControl(_BuildingID, _State);

        API.BroadcastScriptCommand(QSB.ScriptCommands.CheckCancelKnockdown, GUI.GetPlayerID(), _BuildingID, _State);
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleConstructionControl);

