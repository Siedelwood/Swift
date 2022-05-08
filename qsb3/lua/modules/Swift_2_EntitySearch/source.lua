--[[
Swift_2_EntitySearch/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

SCP.EntitySearch = {};

ModuleEntitySearch = {
    Properties = {
        Name = "ModuleEntitySearch",
    },

    Global = {},
    Local = {},
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
}

-- Global ------------------------------------------------------------------- --

function ModuleEntitySearch.Global:OnGameStart()
    QSB.ScriptEvents.TriggerEntityTrigger = API.RegisterScriptEvent("Event_TriggerEntityTrigger");
    API.RegisterScriptCommand("Cmd_TriggerEntityTrigger", SCP.EntitySearch.TriggerEntityTrigger);
end

function ModuleEntitySearch.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.TriggerEntityTrigger then
        self:TriggerEntityTrigger();
    end
end

function ModuleEntitySearch.Global:TriggerEntityTrigger()
    local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, 5, 5, 0, 0);
    Logic.DestroyEntity(ID);
end

-- Local -------------------------------------------------------------------- --

function ModuleEntitySearch.Local:OnGameStart()
    QSB.ScriptEvents.TriggerEntityTrigger = API.RegisterScriptEvent("Event_TriggerEntityTrigger");
end

-- Shared ------------------------------------------------------------------- --

function ModuleEntitySearch.Shared:IterateEntities(...)
    if not GUI then
        SCP.EntitySearch.TriggerEntityTrigger();
    else
        Swift:DispatchScriptCommand(
            QSB.ScriptCommands.SendScriptEvent,
            GUI.GetPlayerID(),
            QSB.ScriptCommands.TriggerEntityTrigger
        );
    end

    -- Speichert die Predikate für spätere Prüfung.
    local Predicates = {};
    if arg[1] then
        for j= 1, #arg[1] do
            local Predicate = table.remove(arg[1][j], 1);
            table.insert(Predicates, {Predicate, arg[1][j]});
        end
    end

    -- Iteriert über alle Entities und wendet Predikate an.
    local ResultList = {};
    for i= 65536, ModuleEntityEventCore.Shared.HighestEntityID do
        local ID = ModuleEntityEventCore.Shared.ReplacementEntityID[i] or i;
        local Select = true;
        if IsExisting(ID) then
            for j= 1, #Predicates do
                if not Predicates[j][1](ID, unpack(Predicates[j][2])) then
                    Select = false;
                    break;
                end
            end
            if Select then
                table.insert(ResultList, ID);
            end
        end
    end
    return ResultList;
end

-- Predicates --------------------------------------------------------------- --

QSB.Search = {};

QSB.Search.Custom = function(_ID, _Function, ...)
    return _Function(_ID, unpack(arg));
end

QSB.Search.OfID = function(_ID, ...)
    for i= 1, #arg do
        if _ID == arg[i] then
            return true;
        end
    end
    return false;
end

QSB.Search.OfPlayer = function(_ID, ...)
    for i= 1, #arg do
        if Logic.EntityGetPlayer(_ID) == arg[i] then
            return true;
        end
    end
    return false;
end

QSB.Search.OfName = function(_ID, ...)
    for i= 1, #arg do
        if Logic.GetEntityName(_ID) == arg[i] then
            return true;
        end
    end
    return false;
end

QSB.Search.OfNamePrefix = function(_ID, ...)
    -- FIXME: Bad benchmark!
    local ScriptName = Logic.GetEntityName(_ID);
    for i= 1, #arg do
        if ScriptName and ScriptName ~= "" then
            if ScriptName:find("^" ..arg[i]) ~= nil then
                return true;
            end
        end
    end
    return false;
end

QSB.Search.OfNameSuffix = function(_ID, ...)
    -- FIXME: Bad benchmark!
    local ScriptName = Logic.GetEntityName(_ID);
    for i= 1, #arg do
        if ScriptName and ScriptName ~= "" then
            if ScriptName:find(arg[i] .. "$") ~= nil then
                return true;
            end
        end
    end
    return false;
end

QSB.Search.OfType = function(_ID, ...)
    for i= 1, #arg do
        if Logic.GetEntityType(_ID) == arg[i] then
            return true;
        end
    end
    return false;
end

QSB.Search.OfCategory = function(_ID, ...)
    for i= 1, #arg do
        if Logic.IsEntityInCategory(_ID, arg[i]) == 1 then
            return true;
        end
    end
    return false;
end

QSB.Search.InArea = function(_ID, _X, _Y, _AreaSize)
    -- FIXME: Bad benchmark!
    return API.GetDistance(_ID, {X= _X, Y= _Y}) <= _AreaSize;
end

QSB.Search.InTerritory = function(_ID, ...)
    for i= 1, #arg do
        if GetTerritoryUnderEntity(_ID) == arg[i] then
            return true;
        end
    end
    return false;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleEntitySearch);

