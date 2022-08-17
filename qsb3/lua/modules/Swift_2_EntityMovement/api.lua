--[[
Swift_2_EntityMovement/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ein Modul für die Bewegung von Entities.
--
-- Es werden Funktionen für den Endanwender sowie eine Wegfindung für andere
-- Module bereitgestellt.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_JobsCore.api.html">(1) JobsCore</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field EntityArrived       Ein Entity hat das Ziel erreicht. (Parameter: EntityID, Position, DataIndex)
-- @field EntityStuck         Ein Entity kann das Ziel nicht erreichen. (Parameter: EntityID, Position, DataIndex)
-- @field EntityAtCheckpoint  Ein Entity hat einen Wegpunkt erreicht. (Parameter: EntityID, Position, DataIndex)
-- @field PathFindingFinished Ein Pfad wurde erfolgreich gefunden (Parameter: PathIndex)
-- @field PathFindingFailed   Ein Pfad konnte nicht ermittelt werden (Parameter: PathIndex)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Bewegt ein Entity zum Zielpunkt.
--
-- Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
-- Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.
--
-- Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
-- wird das Event QSB.ScriptEvents.EntityArrived geworfen.
--
-- @param               _Entity         Bewegtes Entity (Skriptname oder ID)
-- @param               _Target         Ziel (Skriptname oder ID)
-- @param[type=boolean] _IgnoreBlocking Direkten Weg benutzen
-- @within Anwenderfunktionen
--
function API.MoveEntity(_Entity, _Target, _IgnoreBlocking)
    local ID1 = GetID(_Entity);
    if not IsExisting(ID1) then
        error("API.MoveEntity: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end
    local ID2 = GetID(_Target);
    if not IsExisting(ID2) then
        error("API.MoveEntity: entity '" ..tostring(_Target).. "' does not exist!");
        return;
    end
    local Index = ModuleEntityMovement.Global:FillMovingEntityDataForController(
        _Entity, {_Target}, nil, nil, _IgnoreBlocking
    );
    API.StartHiResJob(function(_Index)
        return ModuleEntityMovement.Global:MoveEntityPathController(_Index);
    end, Index);
    return Index;
end

---
-- Bewegt ein Entity zum Zielpunkt und lässt es das Ziel anschauen.
--
-- Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
-- Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.
--
-- Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
-- wird das Event QSB.ScriptEvents.EntityArrived geworfen.
--
-- @param               _Entity         Bewegtes Entity (Skriptname oder ID)
-- @param               _Target         Ziel (Skriptname oder ID)
-- @param               _LookAt         Angeschaute Position (Skriptname, ID oder Position)
-- @param[type=boolean] _IgnoreBlocking Direkten Weg benutzen
-- @within Anwenderfunktionen
--
function API.MoveEntityAndLookAt(_Entity, _Target, _LookAt, _IgnoreBlocking)
    local ID1 = GetID(_Entity);
    if not IsExisting(ID1) then
        error("API.MoveEntityAndLookAt: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end
    local ID2 = GetID(_Target);
    if not IsExisting(ID2) then
        error("API.MoveEntityAndLookAt: entity '" ..tostring(_Target).. "' does not exist!");
        return;
    end
    local Index = ModuleEntityMovement.Global:FillMovingEntityDataForController(
        _Entity, {_Target}, _LookAt, nil, _IgnoreBlocking
    );
    API.StartHiResJob(function(_Index)
        return ModuleEntityMovement.Global:MoveEntityPathController(_Index);
    end, Index);
    return Index;
end

---
-- Bewegt ein Entity zum Zielpunkt und führt die Funktion aus.
--
-- Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
-- Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.
--
-- Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
-- wird das Event QSB.ScriptEvents.EntityArrived geworfen.
--
-- @param                _Entity         Bewegtes Entity (Skriptname oder ID)
-- @param                _Target         Ziel (Skriptname oder ID)
-- @param[type=function] _Action         Funktion wenn Entity ankommt
-- @param[type=boolean]  _IgnoreBlocking Direkten Weg benutzen
-- @within Anwenderfunktionen
--
function API.MoveEntityAndExecute(_Entity, _Target, _Action, _IgnoreBlocking)
    local ID1 = GetID(_Entity);
    if not IsExisting(ID1) then
        error("API.MoveEntityAndExecute: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end
    local ID2 = GetID(_Target);
    if not IsExisting(ID2) then
        error("API.MoveEntityAndExecute: entity '" ..tostring(_Target).. "' does not exist!");
        return;
    end
    local Index = ModuleEntityMovement.Global:FillMovingEntityDataForController(
        _Entity, {_Target}, nil, _Action, _IgnoreBlocking
    );
    API.StartHiResJob(function(_Index)
        return ModuleEntityMovement.Global:MoveEntityPathController(_Index);
    end, Index);
    return Index;
end

---
-- Bewegt ein Entity über den angegebenen Pfad.
--
-- Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
-- Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.
--
-- Jedes Mal wenn das Entity einen Wegpunkt erreicht hat, wird das Event
-- QSB.ScriptEvents.EntityAtCheckpoint geworfen.
--
-- Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
-- wird das Event QSB.ScriptEvents.EntityArrived geworfen.
--
-- @param                _Entity         Bewegtes Entity (Skriptname oder ID)
-- @param                _Targets        Liste mit Wegpunkten
-- @param[type=boolean]  _IgnoreBlocking Direkten Weg benutzen
-- @within Anwenderfunktionen
--
function API.MoveEntityOnCheckpoints(_Entity, _Targets, _IgnoreBlocking)
    local ID1 = GetID(_Entity);
    if not IsExisting(ID1) then
        error("API.MoveEntityOnCheckpoints: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end
    if type(_Targets) ~= "table" then
        error("API.MoveEntityOnCheckpoints: target list must be a table!");
        return;
    end
    local Index = ModuleEntityMovement.Global:FillMovingEntityDataForController(
        _Entity, _Targets, nil, nil, _IgnoreBlocking
    );
    API.StartHiResJob(function(_Index)
        return ModuleEntityMovement.Global:MoveEntityPathController(_Index);
    end, Index);
    return Index;
end

