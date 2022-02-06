--[[
Swift_2_EntitySearch/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

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
end

-- Local -------------------------------------------------------------------- --

function ModuleEntitySearch.Local:OnGameStart()
end

-- Shared ------------------------------------------------------------------- --

function ModuleEntitySearch.Shared:IterateEntities(...)
    -- FIX: Die höchste ID vom Trigger ermitteln und speichern lassen. Das ist
    -- nötig, da die Abfrage über alle Spawner möglicher Weise noch nicht durch
    -- ist, wenn der Aufruf ausgeführt wird und somit Entities verpasst werden.
    if not GUI then
        local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, 5, 5, 0, 0);
        Logic.DestroyEntity(ID);
    else
        GUI.SendScriptCommand([[
            local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, 5, 5, 0, 0);
            Logic.DestroyEntity(ID);
        ]]);
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
    for i= 65536, ModuleEntityEventCore.Shared:GetHighestEntity() do
        local ID = ModuleEntityEventCore.Shared:GetReplacementID(i) or i;
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

NOT = function(_ID, _Predicate)
    local Predicate = table.copy(_Predicate);
    local Function = table.remove(Predicate, 1);
    return not Function(_ID, unpack(Predicate));
end

ALL = function(_ID, ...)
    local Predicates = table.copy(arg);
    for i= 1, #Predicates do
        local Predicate = table.remove(Predicates[i], 1);
        if not Predicate(_ID, unpack(Predicates[i])) then
            return false;
        end
    end
    return true;
end

ANY = function(_ID, ...)
    local Predicates = table.copy(arg);
    for i= 1, #Predicates do
        local Predicate = table.remove(Predicates[i], 1);
        if Predicate(_ID, unpack(Predicates[i])) then
            return true;
        end
    end
    return false;
end

QSB.Search.Custom = function(_ID, _Function, ...)
    return _Function(_ID, unpack(arg));
end

QSB.Search.OfID = function(_ID, _EntityID)
    return _ID == _EntityID;
end

QSB.Search.OfPlayer = function(_ID, _PlayerID)
    return Logic.EntityGetPlayer(_ID) == _PlayerID;
end

QSB.Search.OfName = function(_ID, _ScriptName)
    return Logic.GetEntityName(_ID) == _ScriptName;
end

QSB.Search.OfNamePrefix = function(_ID, _Prefix)
    local ScriptName = Logic.GetEntityName(_ID);
    if ScriptName and ScriptName ~= "" then
        return ScriptName:find("^" .._Prefix) ~= nil;
    end
    return false;
end

QSB.Search.OfNameSuffix = function(_ID, _Sufix)
    local ScriptName = Logic.GetEntityName(_ID);
    if ScriptName and ScriptName ~= "" then
        return ScriptName:find(_Sufix .. "$") ~= nil;
    end
    return false;
end

QSB.Search.OfType = function(_ID, _Type)
    return Logic.GetEntityType(_ID) == _Type;
end

QSB.Search.OfCategory = function(_ID, _Category)
    return Logic.IsEntityInCategory(_ID, _Category) == 1;
end

QSB.Search.InArea = function(_ID, _X, _Y, _AreaSize)
    return API.GetDistance(_ID, {X= _X, Y= _Y}) <= _AreaSize;
end

QSB.Search.InTerritory = function(_ID, _Territory)
    return GetTerritoryUnderEntity(_ID) == _Territory;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleEntitySearch);

