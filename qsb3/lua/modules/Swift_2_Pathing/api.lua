--[[
Swift_2_MilitaryLimit/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- 
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_0_Core.api.html">(0) Core</a></li>
-- <li><a href="Swift_1_JobsCore.api.html">(1) JobsCore</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field EntityArrived      Ein Entity hat das Ziel erreicht. (Parameter: EntityID, TargetID, TargetX, TargetY)
-- @field EntityStuck        Ein Entity kann das Ziel nicht erreichen. (Parameter: EntityID, TargetID, TargetX, TargetY)
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
-- @param               _Target         Ziel (Skriptname, ID oder Position)
-- @param[type=boolean] _IgnoreBlocking Direkten Weg benutzen
-- @within Position
--
function API.MoveEntity(_Entity, _Target, _IgnoreBlocking)
    local ID1 = GetID(_Entity);
    if not IsExisting(ID1) then
        error("API.MoveEntity: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end

    local TargetID = 0;
    local Target;
    if type(_Target) ~= "table" then
        local ID2 = GetID(_Target);
        if not IsExisting(ID2) then
            error("API.MoveEntity: target '" ..tostring(_Target).. "' does not exist!");
            return;
        end
        TargetID = ID2;
        local x,y,z = Logic.EntityGetPos(ID2);
        if Logic.IsBuilding(ID2) == 1 then
            x,y = Logic.GetBuildingApproachPosition(ID2);
        end
        Target = {X= x, Y= y};
    else
        if not IsValidPosition(_Target) then
            error("API.MoveEntity: target position is invalid!");
            return;
        end
        Target = _Target;
    end

    if _IgnoreBlocking then
        if Logic.IsSettler(ID1) == 1 then
            Logic.SetTaskList(ID1, TaskLists.TL_NPC_WALK);
        end
        Logic.MoveEntity(ID1, Target.X, Target.Y);
    else
        Logic.MoveSettler(ID1, Target.X, Target.Y);
    end

    return API.StartHiResJob(
        function(_ID1, _ID2, _X, _Y)
            ModulePathing.Global:MoveEntityController(_ID1, _ID2, _X, _Y)
        end,
        ID1,
        TargetID,
        Target.X,
        Target.Y
    );
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
-- @param               _Target         Ziel (Skriptname, ID oder Position)
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
    local ID2 = GetID(_LookAt);
    if not IsExisting(ID2) then
        error("API.MoveEntityAndLookAt: entity '" ..tostring(_LookAt).. "' does not exist!");
        return;
    end
    local ID3 = GetID(_Target);
    if not IsExisting(ID3) then
        error("API.MoveEntityAndLookAt: entity '" ..tostring(_Target).. "' does not exist!");
        return;
    end
    ModulePathing.Global.MovingEntities[ID1] = ID2;
    API.MoveEntity(_Entity, _Target, _IgnoreBlocking);
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
-- @param                _Target         Ziel (Skriptname, ID oder Position)
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
    ModulePathing.Global.MovingEntities[ID1] = _Action;
    API.MoveEntity(_Entity, _Target, _IgnoreBlocking);
end

