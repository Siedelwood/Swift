--[[
Swift_4_InteractiveMines/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleInteractiveMines = {
    Properties = {
        Name = "ModuleInteractiveMines",
    },

    Global = {
        Mines = {},
    },
    Local = {},
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        Text = {
            Title = {
                de = "Rohstoffquelle erschließen",
                en = "Construct mine",
            },
            Text = {
                de = "An diesem Ort könnt Ihr eine Rohstoffquelle erschließen!",
                en = "You're able to create a pit at this location!",
            },
        },
    },
};

-- Global ------------------------------------------------------------------- --

function ModuleInteractiveMines.Global:OnGameStart()
    API.StartHiResJob(function()
        ModuleInteractiveMines.Global:ControlIOMines();
    end);
end

function ModuleInteractiveMines.Global:OnEvent(_ID, _Event, _ScriptName)
    if _ID == QSB.ScriptEvents.ObjectReset then
        if IO[_ScriptName] and IO[_ScriptName].IsInteractiveMine then
            self:ResetIOMine(_ScriptName, IO[_ScriptName].Type);
        end
    end
end

function ModuleInteractiveMines.Global:CreateIOMine(
    _Position,
    _Type,
    _Costs,
    _NotRefillable,
    _Condition,
    _CreationCallback,
    _CallbackDepleted
)
    local BlockerID = self:ResetIOMine(_Position, _Type);
    local Icon = {14, 10};
    if g_GameExtraNo >= 1 then
        if IO[_ScriptName].Type == Entities.R_IronMine then
            Icon = {14, 10};
        end
        if IO[_ScriptName].Type == Entities.R_StoneMine then
            Icon = {14, 10};
        end
    end

    CreateObject {
        Name                 = _Position,
        IsInteractiveMine    = true,
        Title                = ModuleInteractiveMines.Shared.Text.Title,
        Text                 = ModuleInteractiveMines.Shared.Text.Text,
        Texture              = Icon,
        Type                 = _Type,
        Crumbles             = _NotRefillable,
        Costs                = _Costs,
        InvisibleBlocker     = BlockerID,
        Distance             = 1500,
        BuildCondition       = _Condition,
        ActionDepleted       = _CallbackDepleted,
        ActionCreated        = _CreationCallback,
        Condition            = function(_Data)
            if _Data.BuildCondition == nil then
                return _Data:BuildCondition();
            end
            return true;
        end,
        Action               = function(_Data, _KnightID, _PlayerID)
            ReplaceEntity(_Data.Name, _Data.Type);
            DestroyEntity(_Data.InvisibleBlocker)
            if _Data.ActionCreated == nil then
                _Data:ActionCreated(_KnightID, _PlayerID);
            end
        end
    };
end

function ModuleInteractiveMines.Global:ResetIOMine(_ScriptName, _Type)
    if IO[_ScriptName] then
        DestroyEntity(IO[_ScriptName].InvisibleBlocker);
    end
    local EntityID = ReplaceEntity(_Position, Entities.XD_ScriptEntity);
    local Model = Models.Doodads_D_SE_ResourceIron_Wrecked;
    if _Type == Entities.R_StoneMine then
        Model = Models.R_SE_ResorceStone_10;
    end
    Logic.SetVisible(EntityID, true);
    Logic.SetModel(EntityID, Model);
    local x, y, z = Logic.EntityGetPos(EntityID);
    local BlockerID = Logic.CreateEntity(Entities.D_ME_Rock_Set01_B_07, x, y, 0, 0);
    Logic.SetVisible(BlockerID, false);
    if IO[_ScriptName] then
        IO[_ScriptName].InvisibleBlocker = BlockerID;
    end
    return BlockerID;
end

function ModuleInteractiveMines.Global:ControlIOMines()
    for k, v in pairs(IO) do
        local EntityID = GetID(k);
        if v.IsInteractiveMine and Logic.GetResourceDoodadGoodType(EntityID) ~= 0 then
            if Logic.GetResourceDoodadGoodAmount(EntityID) == 0 then
                if v.Crumbles == true then
                    local Model = Models.Doodads_D_SE_ResourceIron_Wrecked;
                    if v.Type == Entities.R_StoneMine then
                        Model = Models.R_ResorceStone_Scaffold_Destroyed;
                    end
                    EntityID = ReplaceEntity(EntityID, Entities.XD_ScriptEntity);
                    Logic.SetVisible(EntityID, true);
                    Logic.SetModel(EntityID, Model);
                end
                if v.ActionDepleted then
                    v:ActionDepleted();
                end
            end
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleInteractiveMines.Local:OnGameStart()
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleInteractiveMines);

