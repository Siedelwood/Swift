--[[
Swift_3_InteractiveMines/API

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
-- @param[type=string]  _Position      Script Entity, die mit Mine ersetzt wird
-- @param[type=number]  _Cost1Type     (optional) Kostenware 1
-- @param[type=number]  _Cost1Amount   (optional) Kostenmenge 1
-- @param[type=number]  _Cost2Type     (optional) Kostenware 2
-- @param[type=number]  _Cost2Amount   (optional) Kostenmenge 2
-- @param[type=boolean] _NotRefillable (optional) Mine wird nach Ausbeutung zerstört
-- @within Anwenderfunktionen
-- @see API.CreateIOMine
--
-- @usage
-- -- Beispiel für eine Mine
-- API.CreateIOMine("mine", Goods.G_Wood, 20)
--
function API.CreateIOIronMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable)
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
    ModuleInteractiveMines.Global:CreateIOIronMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable);
end

---
-- Erstelle eine verschüttete Steinmine.
--
-- @param[type=string]  _Position      Script Entity, die mit Mine ersetzt wird
-- @param[type=number]  _Cost1Type     (optional) Kostenware 1
-- @param[type=number]  _Cost1Amount   (optional) Kostenmenge 1
-- @param[type=number]  _Cost2Type     (optional) Kostenware 2
-- @param[type=number]  _Cost2Amount   (optional) Kostenmenge 2
-- @param[type=boolean] _NotRefillable (optional) Mine wird nach Ausbeutung zerstört
-- @within Anwenderfunktionen
-- @see API.CreateIOMine
--
-- @usage
-- -- Beispiel für eine Mine
-- API.CreateIOMine("mine", Goods.G_Wood, 20)
--
function API.CreateIOStoneMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable)
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
    ModuleInteractiveMines.Global:CreateIOStoneMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable);
end

---
-- Fügt eine Bedingung für die Aktivierung der Mine hinzu.
--
-- @param[type=string]   _ScriptName Scriptname der Mine
-- @param[type=function] _Condition  Zu prüfende Bedingung
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetMineCondition("mine", function(_ScriptName)
--     return MeineBedingungIstErfüllt == true;
-- end);
--
function API.SetMineCondition(_ScriptName, _Condition)
    if GUI then
        return;
    end
    if not IsExisting(_ScriptName) then
        error("API.SetObjectIcon: Object " ..tostring(_ScriptName).. " does not exist!");
        return;
    end
    ModuleInteractiveMines.Global:SetObjectLambda(_ScriptName, "MineCondition", _Condition);
end

---
-- Fügt eine Funktion hinzu, die bei Aktivierung ausgeführt wird.
--
-- @param[type=string]   _ScriptName Scriptname der Mine
-- @param[type=function] _Action     Funktion zum Ausführen
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetMineAction("mine", function(_ScriptName, _KnightID, _PlayerID)
--     MachWas();
-- end);
--
function API.SetMineAction(_ScriptName, _Action)
    if GUI then
        return;
    end
    if not IsExisting(_ScriptName) then
        error("API.SetObjectIcon: Object " ..tostring(_ScriptName).. " does not exist!");
        return;
    end
    ModuleInteractiveMines.Global:SetObjectLambda(_ScriptName, "MineAction", _Action);
end

---
-- Fügt eine Funktion hinzu, die ausgeführt wird, wenn die Mine erschöpft ist.
--
-- @param[type=string]   _ScriptName    Scriptname der Mine
-- @param[type=function] _CrumbleAction Funktion zum Ausführen
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetMineDepletedAction("mine", function(_ScriptName)
--     MachWas();
-- end);
--
function API.SetMineDepletedAction(_ScriptName, _CrumbleAction)
    if GUI then
        return;
    end
    if not IsExisting(_ScriptName) then
        error("API.SetObjectIcon: Object " ..tostring(_ScriptName).. " does not exist!");
        return;
    end
    ModuleInteractiveMines.Global:SetObjectLambda(_ScriptName, "MineDepleted", _CrumbleAction);
end

