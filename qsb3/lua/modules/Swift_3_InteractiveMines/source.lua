--[[
Swift_3_InteractiveMines/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

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
            MineCondition = {},
            MineConstructed = {},
            MineDepleted = {},
        }
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
    QSB.ScriptEvents.InteractiveMineActivated = API.RegisterScriptEvent("Event_InteractiveMineActivated");
    QSB.ScriptEvents.InteractiveMineDepleted = API.RegisterScriptEvent("Event_InteractiveMineDepleted");

    API.StartHiResJob(function()
        ModuleInteractiveMines.Global:ControlIOMines();
    end);
end

function ModuleInteractiveMines.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.ObjectReset then
        if IO[arg[1]] and IO[arg[1]].IsInteractiveMine then
            self:ResetIOMine(arg[1], IO[arg[1]].Type);
        end
    elseif _ID == QSB.ScriptEvents.ObjectDelete then
        ReplaceEntity(arg[1], IO[arg[1]].Type);
    end
end

function ModuleInteractiveMines.Global:CreateIOMine(
    _Position,
    _Type,
    _Title,
    _Text,
    _Costs,
    _NotRefillable,
    _Condition,
    _ConstructionAction,
    _DepletedAction
)
    local BlockerID = self:ResetIOMine(_Position, _Type);
    local Icon = {14, 10};
    if g_GameExtraNo >= 1 then
        if _Type == Entities.R_IronMine then
            Icon = {14, 10};
        end
        if _Type == Entities.R_StoneMine then
            Icon = {14, 10};
        end
    end

    API.SetupObject {
        Name                 = _Position,
        IsInteractiveMine    = true,
        Title                = _Title or ModuleInteractiveMines.Shared.Text.Title,
        Text                 = _Text or ModuleInteractiveMines.Shared.Text.Text,
        Texture              = Icon,
        Type                 = _Type,
        Crumbles             = _NotRefillable,
        Costs                = _Costs,
        InvisibleBlocker     = BlockerID,
        Distance             = 1200,
        AdditionalCondition  = _Condition,
        AdditionalAction     = _ConstructionAction,
        DepletionAction      = _DepletedAction,
        Condition            = function(_Data)
            if _Data.AdditionalAction then
                return _Data:AdditionalAction();
            end
            return true;
        end,
        Action               = function(_Data, _KnightID, _PlayerID)
            ReplaceEntity(_Data.Name, _Data.Type);
            DestroyEntity(_Data.InvisibleBlocker);
            if _Data.AdditionalAction then
                _Data:AdditionalAction(_KnightID, _PlayerID);
            end

            API.SendScriptEvent(QSB.ScriptEvents.InteractiveMineActivated, _Data.Name, _KnightID, _PlayerID);
            Logic.ExecuteInLuaLocalState(string.format(
                [[API.SendScriptEvent(%d, "%s", %d, %d)]],
                QSB.ScriptEvents.InteractiveMineActivated,
                _Data.Name,
                _KnightID,
                _PlayerID
            ));
        end
    };
end

function ModuleInteractiveMines.Global:ResetIOMine(_ScriptName, _Type)
    if IO[_ScriptName] then
        DestroyEntity(IO[_ScriptName].InvisibleBlocker);
    end
    local EntityID = ReplaceEntity(_ScriptName, Entities.XD_ScriptEntity);
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
                if v.DepletionAction then
                    v:DepletionAction();
                end

                API.SendScriptEvent(QSB.ScriptEvents.InteractiveMineDepleted, k);
                Logic.ExecuteInLuaLocalState(string.format(
                    [[API.SendScriptEvent(%d, "%s")]],
                    QSB.ScriptEvents.InteractiveMineDepleted,
                    k
                ));
            end
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleInteractiveMines.Local:OnGameStart()
    QSB.ScriptEvents.InteractiveMineActivated = API.RegisterScriptEvent("Event_InteractiveMineActivated");
    QSB.ScriptEvents.InteractiveMineDepleted = API.RegisterScriptEvent("Event_InteractiveMineDepleted");
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleInteractiveMines);

