--[[
Swift_4_InteractiveMines/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Der Spieler kann eine Stein- oder Eisenmine erzeugen, die zuerst durch
-- Begleichen der Kosten aufgebaut werden muss, bevor sie genutzt werden kann.
-- <br>Optional kann die Mine einstürzen, wenn sie erschöpft wurde.
-- 
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- <li><a href="Swift_2_Interaction.api.html">(2) Interaction</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Erstelle eine verschüttete Eisenmine.
--
-- Werden keine Materialkosten bestimmt, benötigt der Bau der Mine 500 Gold und
-- 20 Holz.
--
-- @param[type=string]   _Position       Script Entity, die mit Mine ersetzt wird
-- @param[type=number]   _Cost1Type      (optional) Kostenware 1
-- @param[type=number]   _Cost1Amount    (optional) Kostenmenge 1
-- @param[type=number]   _Cost2Type      (optional) Kostenware 2
-- @param[type=number]   _Cost2Amount    (optional) Kostenmenge 2
-- @param[type=boolean]  _NotRefillable  (optional) Mine wird nach Ausbeutung zerstört
-- @param[type=function] _Condition      (optional) Bedingung um Mine zu bauen
-- @param[type=function] _Action         (optional) Aktion wenn Mine gebaut wird
-- @param[type=function] _DepletedAction (optional) Aktion wenn Mine leer ist
-- @within Anwenderfunktionen
-- @see API.CreateIOStoneMine
--
-- @usage
-- -- Beispiel für eine Mine
-- API.CreateIOIronMine("mine", Goods.G_Wood, 20)
-- -- Beispiel mit Bedingung
-- local CheckCondition = function(_Data)
--     retur gvMission.KnowsAboutArchitecture == true;
-- end
-- API.CreateIOIronMine("mine", Goods.G_Wood, 20, nil, nil, false, CheckCondition);
--
function API.CreateIOIronMine(
    _Position,
    _Cost1Type,
    _Cost1Amount,
    _Cost2Type,
    _Cost2Amount, 
    _NotRefillable,
    _Condition,
    _Action,
    _DepletedAction
)
    if GUI then
        return;
    end
    if not IsExisting(_Position) then
        error("API.CreateIOIronMine: _Position (" ..tostring(_Position).. ") does not exist!");
        return;
    end
    if _Cost1Type then
        if GetNameOfKeyInTable(Goods, _Cost1Type) == nil then
            error("API.CreateIOIronMine: _Cost1Type (" ..tostring(_Cost1Type).. ") is wrong!");
            return;
        end
        if _Cost1Amount and (type(_Cost1Amount) ~= "number" or _Cost1Amount < 1) then
            error("API.CreateIOIronMine: _Cost1Amount must be above 0!");
            return;
        end
    end
    if _Cost2Type then
        if GetNameOfKeyInTable(Goods, _Cost2Type) == nil then
            error("API.CreateIOIronMine: _Cost2Type (" ..tostring(_Cost2Type).. ") is wrong!");
            return;
        end
        if _Cost2Amount and (type(_Cost2Amount) ~= "number" or _Cost2Amount < 1) then
            error("API.CreateIOIronMine: _Cost2Amount must be above 0!");
            return;
        end
    end

    local Costs = {Goods.G_Gold, 500, Goods.G_Wood, 20};
    if _Cost1Type then
        Costs = {_Cost1Type, _Cost1Amount};
    end
    if _Cost1Type and _Cost2Type then
        table.insert(Costs, _Cost2Type);
        table.insert(Costs, _Cost2Amount);
    end

    ModuleInteractiveMines.Global:CreateIOMine(
        _Position,
        Entities.R_IronMine,
        Costs,
        _NotRefillable,
        _Condition,
        _Action,
        _DepletedAction
    );
end

---
-- Erstelle eine verschüttete Steinmine.
--
-- Werden keine Materialkosten bestimmt, benötigt der Bau der Mine 500 Gold und
-- 20 Holz.
--
-- @param[type=string]   _Position       Script Entity, die mit Mine ersetzt wird
-- @param[type=number]   _Cost1Type      (optional) Kostenware 1
-- @param[type=number]   _Cost1Amount    (optional) Kostenmenge 1
-- @param[type=number]   _Cost2Type      (optional) Kostenware 2
-- @param[type=number]   _Cost2Amount    (optional) Kostenmenge 2
-- @param[type=boolean]  _NotRefillable  (optional) Mine wird nach Ausbeutung zerstört
-- @param[type=function] _Condition      (optional) Bedingung um Mine zu bauen
-- @param[type=function] _Action         (optional) Aktion wenn Mine gebaut wird
-- @param[type=function] _DepletedAction (optional) Aktion wenn Mine leer ist
-- @within Anwenderfunktionen
-- @see API.CreateIOIronMine
--
-- @usage
-- -- Beispiel für eine Mine
-- API.CreateIOStoneMine("mine", Goods.G_Wood, 20)
-- -- Beispiel mit Bedingung
-- local CheckCondition = function(_Data)
--     retur gvMission.KnowsAboutArchitecture == true;
-- end
-- API.CreateIOStoneMine("mine", Goods.G_Wood, 20, nil, nil, false, CheckCondition);
--
function API.CreateIOStoneMine(
    _Position,
    _Cost1Type,
    _Cost1Amount,
    _Cost2Type, 
    _Cost2Amount,
    _NotRefillable,
    _Condition,
    _Action,
    _DepletedAction
)
    if GUI then
        return;
    end
    if not IsExisting(_Position) then
        error("API.CreateIOStoneMine: _Position (" ..tostring(_Position).. ") does not exist!");
        return;
    end
    if _Cost1Type then
        if GetNameOfKeyInTable(Goods, _Cost1Type) == nil then
            error("API.CreateIOStoneMine: _Cost1Type (" ..tostring(_Cost1Type).. ") is wrong!");
            return;
        end
        if _Cost1Amount and (type(_Cost1Amount) ~= "number" or _Cost1Amount < 1) then
            error("API.CreateIOStoneMine: _Cost1Amount must be above 0!");
            return;
        end
    end
    if _Cost2Type then
        if GetNameOfKeyInTable(Goods, _Cost2Type) == nil then
            error("API.CreateIOStoneMine: _Cost2Type (" ..tostring(_Cost2Type).. ") is wrong!");
            return;
        end
        if _Cost2Amount and (type(_Cost2Amount) ~= "number" or _Cost2Amount < 1) then
            error("API.CreateIOStoneMine: _Cost2Amount must be above 0!");
            return;
        end
    end

    local Costs = {Goods.G_Gold, 500, Goods.G_Wood, 20};
    if _Cost1Type then
        Costs = {_Cost1Type, _Cost1Amount};
    end
    if _Cost1Type and _Cost2Type then
        table.insert(Costs, _Cost2Type);
        table.insert(Costs, _Cost2Amount);
    end

    ModuleInteractiveMines.Global:CreateIOMine(
        _Position,
        Entities.R_StoneMine,
        Costs,
        _NotRefillable,
        _Condition,
        _Action,
        _DepletedAction
    );
end

