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
-- <br>Optional kann die Mine einstürzen, wenn sie ausgebeutet wurde.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- <li><a href="Swift_2_ObjectInteraction.api.html">(2) Interaction</a></li>
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
-- @param[type=string]  _Position      Skriptname der Mine
-- @param[type=table]   _Costs         (Optional) Kosten für Aktivierung
-- @param[type=boolean] _NotRefillable (Optional) Mine zerfällt wenn leer
-- @within Anwenderfunktionen
-- @see API.CreateIOStoneMine
--
-- @usage
-- -- Beispiel für eine Mine
-- API.CreateIOIronMine("mine");
-- -- Beispiel für eine Mine mit geänderten kosten
-- API.CreateIOIronMine("mine", {Goods.G_Wood, 15});
--
function API.CreateIOIronMine(_Position, _Costs, _NotRefillable)
    if GUI then
        return;
    end
    if not IsExisting(_Position) then
        error("API.CreateIOIronMine: _Position (" ..tostring(_Position).. ") does not exist!");
        return;
    end

    local Costs = {Goods.G_Gold, 500, Goods.G_Wood, 20};
    if _Costs then
        if _Costs[1] then
            if GetNameOfKeyInTable(Goods, _Costs[1]) == nil then
                error("API.CreateIOIronMine: First cost type (" ..tostring(_Costs[1]).. ") is wrong!");
                return;
            end
            if _Costs[2] and (type(_Costs[2]) ~= "number" or _Costs[2] < 1) then
                error("API.CreateIOIronMine: First cost amount must be above 0!");
                return;
            end
        end
        if _Costs[3] then
            if GetNameOfKeyInTable(Goods, _Costs[3]) == nil then
                error("API.CreateIOIronMine: Second cost type (" ..tostring(_Costs[3]).. ") is wrong!");
                return;
            end
            if _Costs[4] and (type(_Costs[4]) ~= "number" or _Costs[4] < 1) then
                error("API.CreateIOIronMine: Second cost amount must be above 0!");
                return;
            end
        end
        Costs = _Costs;
    end

    ModuleInteractiveMines.Global:CreateIOMine(
        _Position,
        Entities.R_IronMine,
        Costs,
        _NotRefillable
    );
end

---
-- Erstelle eine verschüttete Steinmine.
--
-- Werden keine Materialkosten bestimmt, benötigt der Bau der Mine 500 Gold und
-- 20 Holz.
--
-- @param[type=string]  _Position      Skriptname der Mine
-- @param[type=table]   _Costs         (Optional) Kosten für Aktivierung
-- @param[type=boolean] _NotRefillable (Optional) Mine zerfällt wenn leer
-- @within Anwenderfunktionen
-- @see API.CreateIOIronMine
--
-- @usage
-- -- Beispiel für eine Mine
-- API.CreateIOStoneMine("mine");
-- -- Beispiel für eine Mine mit geänderten kosten
-- API.CreateIOStoneMine("mine", {Goods.G_Wood, 15});
--
function API.CreateIOStoneMine(_Position, _Costs, _NotRefillable)
    if GUI then
        return;
    end
    if not IsExisting(_Position) then
        error("API.CreateIOStoneMine: Position (" ..tostring(_Position).. ") does not exist!");
        return;
    end

    local Costs = {Goods.G_Gold, 500, Goods.G_Wood, 20};
    if _Costs then
        if _Costs[1] then
            if GetNameOfKeyInTable(Goods, _Costs[1]) == nil then
                error("API.CreateIOStoneMine: First cost type (" ..tostring(_Costs[1]).. ") is wrong!");
                return;
            end
            if _Costs[2] and (type(_Costs[2]) ~= "number" or _Costs[2] < 1) then
                error("API.CreateIOStoneMine: First cost amount must be above 0!");
                return;
            end
        end
        if _Costs[3] then
            if GetNameOfKeyInTable(Goods, _Costs[3]) == nil then
                error("API.CreateIOStoneMine: Second cost type (" ..tostring(_Costs[3]).. ") is wrong!");
                return;
            end
            if _Costs[4] and (type(_Costs[4]) ~= "number" or _Costs[4] < 1) then
                error("API.CreateIOStoneMine: Second cost amount must be above 0!");
                return;
            end
        end
        Costs = _Costs;
    end

    ModuleInteractiveMines.Global:CreateIOMine(
        _Position,
        Entities.R_StoneMine,
        Costs,
        _NotRefillable
    );
end

---
-- Fügt eine Funktion als Bedinung für die Aktivierung hinzu.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Data</td><td>table</td><td>Daten des interaktiven Objekt</td></tr>
-- </table>
--
-- <b>Hinweis</b>: Die Funktion muss true zurückgeben, wenn die Mine aktiviert
-- werden darf.
--
-- <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
-- übergeben werden.
--
-- @param[type=string]   _ScriptName Scriptname der Mine
-- @param[type=function] _Function   Funktion als Bedinung
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetIOMineCondition("mine", function(_Data)
--     -- Check something
--     return true;
-- end);
--
function API.SetIOMineCondition(_ScriptName, _Function)
    if GUI then
        return;
    end
    if not _ScriptName then
        ModuleInteractiveMines.Global.Lambda.MineConstructed.Default = _Function;
        return;
    end
    if not IO[_ScriptName] or not IO[_ScriptName].IsInteractiveMine then
        return;
    end
    ModuleInteractiveMines.Global.Lambda.MineCondition[_ScriptName] = _Function;
end

---
-- Setzt die Standartbedingung für alle interaktiven Minen.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Data</td><td>table</td><td>Daten des interaktiven Objekt</td></tr>
-- </table>
--
-- @param[type=function] _Function Funktion als Bedinung
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetIOMineDefaultCondition(function(_Data)
--     -- Check something
--     return true;
-- end);
--
function API.SetIOMineDefaultCondition(_Function)
    if _Function == nil then
        return;
    end
    API.SetIOMineCondition(nil, _Function);
end

---
-- Fügt eine Funktion als Callback nach erfolgreicher Aktivierung hinzu.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Data</td><td>table</td><td>Daten des interaktiven Objekt</td></tr>
-- <tr><td>_KnightID</td><td>number</td><td>ID des nächsten Helden</td></tr>
-- <tr><td>_PlayerID</td><td>number</td><td>ID des Spielers</td></tr>
-- </table>
--
-- <b>Hinweis</b>: Wird diese Aktion überschrieben müssen Mine per Hand ersetzt
-- und der Blocker (InvisibleBlocker) per Hand gelöscht werden.
--
-- <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
-- übergeben werden.
--
-- @param[type=string]   _ScriptName Scriptname der Mine
-- @param[type=function] _Function   Funktion als Aktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetIOMineConstructionAction("mine", function(_Data, _KnightID, _PlayerID)
--     ReplaceEntity(_Data.Name, _Data.Type);
--     DestroyEntity(_Data.InvisibleBlocker);
--     -- Do something
-- end);
--
function API.SetIOMineConstructionAction(_ScriptName, _Function)
    if GUI then
        return;
    end
    if not _ScriptName then
        ModuleInteractiveMines.Global.Lambda.MineConstructed.Default = _Function;
        return;
    end
    if not IO[_ScriptName] or not IO[_ScriptName].IsInteractiveMine then
        return;
    end
    ModuleInteractiveMines.Global.Lambda.MineConstructed[_ScriptName] = _Function;
end

---
-- Setzt die Standartaktion nach Aktivierung für alle interaktiven Minen.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Data</td><td>table</td><td>Daten des interaktiven Objekt</td></tr>
-- <tr><td>_KnightID</td><td>number</td><td>ID des nächsten Helden</td></tr>
-- <tr><td>_PlayerID</td><td>number</td><td>ID des Spielers</td></tr>
-- </table>
--
-- <b>Hinweis</b>: Wird diese Aktion überschrieben müssen Mine per Hand ersetzt
-- und der Blocker (InvisibleBlocker) per Hand gelöscht werden.
--
-- @param[type=function] _Function Aktion nach Aktivierung
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetIOMineDefaultConstructionAction(function(_Data)
--     ReplaceEntity(_Data.Name, _Data.Type);
--     DestroyEntity(_Data.InvisibleBlocker);
--     -- Do something
-- end);
--
function API.SetIOMineDefaultConstructionAction(_Function)
    if _Function == nil then
        return;
    end
    API.SetIOMineConstructionAction(nil, _Function);
end

---
-- Fügt eine Funktion hinzu, die ausgeführt wird, sobald die Mine einstürzt.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Data</td><td>table</td><td>Daten des interaktiven Objekt</td></tr>
-- </table>
--
-- <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
-- übergeben werden.
--
-- @param[type=string]   _ScriptName Scriptname der Mine
-- @param[type=function] _Function   Aktion nach Einsturz
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetIOMineDepletionAction("mine", function(_Data)
--     -- Do something
-- end);
--
function API.SetIOMineDepletionAction(_ScriptName, _Function)
    if GUI then
        return;
    end
    if not _ScriptName then
        ModuleInteractiveMines.Global.Lambda.MineDepleted.Default = _Function;
        return;
    end
    if not IO[_ScriptName] or not IO[_ScriptName].IsInteractiveMine then
        return;
    end
    ModuleInteractiveMines.Global.Lambda.MineDepleted[_ScriptName] = _Function;
end

---
-- Setzt die Standartaktion nach Ausbeutung für alle interaktiven Minen.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Data</td><td>table</td><td>Daten des interaktiven Objekt</td></tr>
-- </table>
--
-- @param[type=function] _Function Aktion nach Einsturz
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetIOMineDefaultDepletionAction(function(_Data)
--     -- Do something
-- end);
--
function API.SetIOMineDefaultDepletionAction(_Function)
    if _Function == nil then
        return;
    end
    API.SetIOMineDepletionAction(nil, _Function);
end

