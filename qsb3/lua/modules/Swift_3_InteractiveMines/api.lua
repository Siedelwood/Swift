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
-- Erstelle eine verschüttete Mine eines bestimmten Typs. Es können zudem eine
-- Bedingung und zwei verschiedene Callbacks vereinbart werden.
--
-- Minen können als "nicht auffüllbar" markiert werden. In diesem Fall werden
-- sie zusammenstützen, sobald die Rohstoffe verbraucht sind.
--
-- Verschüttete Minen können durch einen Helden in normale Minen umgewandelt
-- werden. FÜr diese Umwandlung können Kosten anfallen, müssen aber nicht. Es
-- dürfen immer maximal 2 Waren als Kosten verwendet werden.
--
-- Es können weitere Funktionen hinzugefügt werden, um die Mine anzupassen:
-- <ul>
-- <li><u>Bedingung:</u> Eine Funktion, die true oder false zurückgeben muss.
-- Mit dieser Funktion wird bestimmt, ob die Mine gebaut werden darf.</li>
-- <li><u>Callback Aktivierung:</u> Eine Funktion, die ausgeführt wird, wenn
-- die Mine erfolgreich aktiviert wurde (evtl. Kosten bezahlt und/oder
-- Bedingung erfüllt).</li>
-- <li><u>Callback Erschöpft:</u> Eine Funktion, die ausgeführt wird, sobald
-- die Rohstoffe der Mine erschöpft sind.</li>
-- </ul>
--
-- @param[type=string]   _Position         Script Entity, die mit Mine ersetzt wird
-- @param[type=number]   _Type             Typ der Mine
-- @param[type=table]    _Costs            (optional) Kostentabelle
-- @param[type=boolean]  _NotRefillable    (optional) Die Mine wird weiterhin überwacht
-- @param[type=function] _Condition        (optional) Bedingungsfunktion
-- @param[type=function] _CreationCallback (optional) Funktion nach Kauf ausführen
-- @param[type=function] _CallbackDepleted (optional) Funktion nach Ausbeutung ausführen
-- @within Anwenderfunktionen
--
-- @usage
-- -- Beispiel für eine Mine
-- API.CreateIOMine("mine", Entities.B_IronMine, {Goods.G_Wood, 20}, true)
-- -- Die Mine kann für 20 Holz erschlossen werden. Sobald die Rohstoffe
-- -- erschöpft sind, stürzt die Mine zusammen.
--
function API.CreateIOMine(_Position, _Type, _Costs, _NotRefillable, _Condition, _CreationCallback, _CallbackDepleted)
    if GUI then
        return;
    end
    if not IsExisting(_Position) then
        error("API.CreateIOMine: _Position (" ..tostring(_Position).. ") does not exist!");
        return;
    end
    if GetNameOfKeyInTable(Entities, _Type) == nil then
        error("API.CreateIOMine: _Type (" ..tostring(_Type).. ") is wrong!");
        return;
    end
    if _Costs and (type(_Costs) ~= "table" or #_Costs %2 ~= 0) then
        error("API.CreateIOMine: _Costs has the wrong format!");
        return;
    end
    if _Condition and type(_Condition) ~= "function" then
        error("API.CreateIOMine: _Condition must be a function!");
        return;
    end
    if _CreationCallback and type(_CreationCallback) ~= "function" then
        error("API.CreateIOMine: _CreationCallback must be a function!");
        return;
    end
    if _CallbackDepleted and type(_CallbackDepleted) ~= "function" then
        error("API.CreateIOMine: _CallbackDepleted must be a function!");
        return;
    end
    ModuleInteractiveMines.Global:CreateIOMine(_Position, _Type, _Costs, _NotRefillable, _Condition, _CreationCallback, _CallbackDepleted);
end

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

function API.SetMineCrumbleAction(_ScriptName, _CrumbleAction)
    if GUI then
        return;
    end
    if not IsExisting(_ScriptName) then
        error("API.SetObjectIcon: Object " ..tostring(_ScriptName).. " does not exist!");
        return;
    end
    ModuleInteractiveMines.Global:SetObjectLambda(_ScriptName, "MineCrumble", _CrumbleAction);
end

