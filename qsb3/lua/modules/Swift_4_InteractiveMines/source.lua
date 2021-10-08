--[[
Swift_3_InteractiveMines/Source

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
        Lambda = {
            IO = {
                MineCondition = {},
                MineAction = {},
                MineDepleted = {},
            },
        },
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
    local MineCondition = function(_ScriptName, _EntityID, _PlayerID)
        return true;
    end
    self.Lambda.IO.MineCondition.Default = MineCondition;
    
    local MineAction = function(_ScriptName, _EntityID, _PlayerID)
    end
    self.Lambda.IO.MineAction.Default = MineAction;
    
    local MineDepleted = function(_ScriptName, _EntityID, _PlayerID)
    end
    self.Lambda.IO.MineDepleted.Default = MineDepleted;
    
    API.StartHiResJob(function()
        ModuleInteractiveMines.Global:ControlIOMines();
    end);
end

function ModuleInteractiveMines.Global:SetObjectLambda(_ScriptName, _FieldName, _Lambda)
    local Lambda = _Lambda;
    if Lambda ~= nil and type(Lambda) ~= "function" then
        Lambda = function()
            return _Lambda;
        end;
    end
    self.Lambda.IO[_FieldName][_ScriptName] = Lambda;
end

function ModuleInteractiveMines.Global:CreateIOMine(_Position, _Type, _Costs, _NotRefillable, _Condition, _CreationCallback, _CallbackDepleted)
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

    CreateObject {
        Name                 = _Position,
        Type                 = _Type,
        Crumbles             = _NotRefillable,
        Costs                = _Costs,
        InvisibleBlocker     = BlockerID,
        Distance             = 1500,
    };

    API.SetObjectHeadline(_Position, ModuleInteractiveMines.Shared.Text.Title);
    API.SetObjectDescription(_Position, ModuleInteractiveMines.Shared.Text.Text);
    API.SetIcon(_Position, function(_ScriptName)
        local Icon = {14, 10}
        if g_GameExtraNo >= 1 then
            if IO[_ScriptName].m_Data.Type == Entities.R_IronMine then
                Icon = {14, 10};
            end
            if IO[_ScriptName].m_Data.Type == Entities.R_StoneMine then
                Icon = {14, 10};
            end
        end
        return Icon;
    end);
    API.SetObjectCondition(_Position, function(_Data)
        return ModuleInteractiveMines.Global:ConditionBuildIOMine(_Data.m_Name);
    end);
    API.SetObjectCallback(_Position, function(_Data, _KnightID, _PlayerID)
        ModuleInteractiveMines.Global:ActionBuildIOMine(_Data.m_Name, _KnightID, _PlayerID);
    end);
    self:SetMineConditionLambda(_Position, _Condition);
    self:SetMineActionLambda(_Position, _CreationCallback);
    self:SetMineDepletedLambda(_Position, _CallbackDepleted);
end

function ModuleInteractiveMines.Global:CreateIOIronMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable)
    assert(IsExisting(_Position));
    if _Cost1Type then
        assert(API.TraverseTable(_Cost1Type, Goods));
        assert(type(_Cost1Amount) == "number");
    end
    if _Cost2Type then
        assert(API.TraverseTable(_Cost2Type, Goods));
        assert(type(_Cost2Amount) == "number");
    end

    self:CreateIOMine(
        _Position, Entities.R_IronMine,
        {_Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount},
        _NotRefillable
    );
end

function ModuleInteractiveMines.Global:CreateIOStoneMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable)
    assert(IsExisting(_Position));
    if _Cost1Type then
        assert(API.TraverseTable(_Cost1Type, Goods));
        assert(type(_Cost1Amount) == "number");
    end
    if _Cost2Type then
        assert(API.TraverseTable(_Cost2Type, Goods));
        assert(type(_Cost2Amount) == "number");
    end

    self:CreateIOMine(
        _Position, Entities.R_StoneMine,
        {_Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount},
        _NotRefillable
    );
end

function ModuleInteractiveMines.Global:ConditionBuildIOMine(_ScriptName)
    local Condition = self.Lambda.IO.MineCondition[_ScriptName];
    if Condition == nil then
        Condition = self.Lambda.IO.MineCondition.Default;
    end
    return Condition(IO[_ScriptName]);
end

function ModuleInteractiveMines.Global:ActionBuildIOMine(_ScriptName, _KnightID, _PlayerID)
    ReplaceEntity(_ScriptName, IO[_ScriptName].m_Data.Type);
    DestroyEntity(IO[_ScriptName].m_Data.InvisibleBlocker);
    
    local Action = self.Lambda.IO.MineAction[_ScriptName];
    if Action == nil then
        Action = self.Lambda.IO.MineAction.Default;
    end
    Action(IO[_ScriptName], _KnightID, _PlayerID);
end

function ModuleInteractiveMines.Global:ControlIOMines()
    for k, v in pairs(IO) do
        local EntityID = GetID(k);
        if Logic.GetResourceDoodadGoodType(EntityID) ~= 0 then
            if Logic.GetResourceDoodadGoodAmount(EntityID) == 0 then
                if v.m_Data.Crumbles == true then
                    local Model = Models.Doodads_D_SE_ResourceIron_Wrecked;
                    if v.m_Data.Type == Entities.R_StoneMine then
                        Model = Models.R_ResorceStone_Scaffold_Destroyed;
                    end
                    EntityID = ReplaceEntity(EntityID, Entities.XD_ScriptEntity);
                    Logic.SetVisible(EntityID, true);
                    Logic.SetModel(EntityID, Model);
                end
                
                local DepletedAction = self.Lambda.IO.MineDepleted[k];
                if DepletedAction == nil then
                    DepletedAction = self.Lambda.IO.MineDepleted.Default;
                end
                DepletedAction(IO[k]);
            end
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleInteractiveMines.Local:OnGameStart()
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleInteractiveMines);

