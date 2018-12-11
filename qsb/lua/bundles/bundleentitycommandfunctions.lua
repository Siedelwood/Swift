-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntityCommandFunctions                                 # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Stellt Hilfsfunktionen bereit um Entities Befehle zu erteilen oder sie
-- zu bewegen.
--
-- Das wichtigste Auf einen Blick:
-- <ul>
-- <li>
-- <a href="#API.CommandAttack">Befehle für Entities</a>
-- </li>
-- <li>
-- <a href="#API.MoveAndLookAt">Entities bewegen</a>
-- </li>
-- <li>
-- <a href="#API.PlaceAndLookAt">Entities platzieren</a>
-- </li>
-- </ul>
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleEntityCommandFunctions = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

-- Setzt ein Entity oder ein Battalion an eine neue Position.
--
-- <p><b>Alias:</b> SetPosition</p>
--
-- @param _Entity   [string|number] Entity zum versetzen
-- @param _Position [string|number|table] Neue Position
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetPostion("hakim", "hakimPos1");
--
function API.SetPosition(_Entity, _Position)
    if GUI then
        local Subject = (type(_Entity) ~= "string" and _Entity) or "'" .._Entity.. "'";
        local Position = _Position;
        if type(Position) == "table" then
            Position = "{X= " ..tostring(Position.X).. ", Y= " ..tostring(Position.Y).. "}";
        end
        API.Bridge("API.SetPosition(" ..Subject.. ", " ..Position.. ")")
        return;
    end
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) ~= "string" and _Entity) or "'" .._Entity.. "'";
        API.Dbg("API.SetPosition: Entity " ..Subject.. " does not exist!");
        return;
    end
    local Position = API.LocateEntity(_Position)
    if not API.ValidatePosition(Position) then
        API.Dbg("API.SetPosition: Position is invalid!");
        return;
    end
    return BundleEntityCommandFunctions.Global:SetPosition(_Entity, Position);
end
SetPosition = API.SetPosition;

---
-- Das Entity wird relativ zu einem Winkel zum Ziel bewegt.
--
-- <p><b>Alias:</b> MoveEntityToPositionToAnotherOne</p>
--
-- @param _Entity       [string|number] Zu bewegendes Entity
-- @param _Position     [string|number] Ziel
-- @param _Distance     [number] Entfernung zum Ziel
-- @param _Angle        [number] Winkel
-- @param _moveAsEntity [boolean] Blocking ignorieren
-- @within Anwenderfunktionen
--
-- @usage
-- API.MoveToPosition("hakim", "saraya", 300, 0);
--
function API.MoveToPosition(_Entity, _Position, _Distance, _Angle, _moveAsEntity)
    if GUI then
        API.Bridge("API.MoveToPosition(" ..GetID(_Entity).. ", " ..GetID(_Position).. ", " .._Distance.. ", " .._Angle.. ", " ..tostring(_moveAsEntity).. ")")
        return;
    end
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) ~= "string" and _Entity) or "'" .._Entity.. "'";
        API.Dbg("API.MoveToPosition: Entity " ..Subject.. " does not exist!");
        return;
    end
    if not IsExisting(_Position) then
        local Subject = (type(_Position) ~= "string" and _Position) or "'" .._Position.. "'";
        API.Dbg("API.MoveToPosition: Entity " ..Subject.. " does not exist!");
        return;
    end
    return BundleEntityCommandFunctions.Global:MoveToPosition(_Entity, _Position, _Distance, _Angle, _moveAsEntity)
end
MoveEntityToPositionToAnotherOne = API.MoveToPosition;

---
-- Das Entity wird relativ zu einem Winkel zum Ziel bewegt und schaut es
-- anschließend an.
--
-- <p><b>Alias:</b> MoveEx</br></p>
-- <p><b>Alias:</b> MoveEntityFaceToFaceToAnotherOne</p>
--
-- @param _Entity       [string|number] Zu bewegendes Entity
-- @param _Position     [string|number] Ziel
-- @param _Distance     [number] Entfernung zum Ziel
-- @param _moveAsEntity [boolean] Blocking ignorieren
-- @within Anwenderfunktionen
--
-- @usage
-- API.MoveAndLookAt("hakim", "saraya", 300);
--
function API.MoveAndLookAt(_Entity, _Position, _Distance, _moveAsEntity)
    if GUI then
        API.Bridge("API.MoveAndLookAt(" ..GetID(_Entity).. ", " ..GetID(_Position).. ", " .._Distance.. ", " ..tostring(_moveAsEntity).. ")")
        return;
    end
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) ~= "string" and _Entity) or "'" .._Entity.. "'";
        API.Dbg("API.MoveAndLookAt: Entity " ..Subject.. " does not exist!");
        return;
    end
    if not IsExisting(_Position) then
        local Subject = (type(_Position) ~= "string" and _Position) or "'" .._Position.. "'";
        API.Dbg("API.MoveAndLookAt: Entity " ..Subject.. " does not exist!");
        return;
    end
    return BundleEntityCommandFunctions.Global:MoveAndLookAt(_Entity, _Position, _Distance, _moveAsEntity)
end
MoveEntityFaceToFaceToAnotherOne = API.MoveAndLookAt;
MoveEx = API.MoveAndLookAt;

---
-- Das Entity wird relativ zu einem Winkel zum Zielpunkt gesetzt.
--
-- <p><b>Alias:</b> PlaceEntityToPositionToAnotherOne</p>
--
-- @param _Entity          [string|number|table] Entity das bewegt wird
-- @param _Position        [string|number|table] Position zu der bewegt wird
-- @param _Distance        [number] Entfernung
-- @param _Angle           [number] Winkel
-- @within Anwenderfunktionen
--
-- @usage
-- API.PlaceToPosition("hakim", "saraya", 300, 45);
--
function API.PlaceToPosition(_Entity, _Position, _Distance, _Angle)
    if GUI then
        API.Bridge("API.PlaceToPosition(" ..GetID(_Entity).. ", " ..GetID(_Position).. ", " .._Distance.. ", " .._Angle.. ")")
        return;
    end
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) ~= "string" and _Entity) or "'" .._Entity.. "'";
        API.Dbg("API.PlaceToPosition: Entity " ..Subject.. " does not exist!");
        return;
    end
    if not IsExisting(_Position) then
        local Subject = (type(_Position) ~= "string" and _Position) or "'" .._Position.. "'";
        API.Dbg("API.PlaceToPosition: Entity " ..Subject.. " does not exist!");
        return;
    end
    local Position = BundleEntityCommandFunctions.Shared:GetRelativePosition(_Position, _Distance, _Angle, true);
    API.SetPosition(_Entity, Position);
end
PlaceEntityToPositionToAnotherOne = API.PlaceToPosition;

---
-- Das Entity wird relativ zu einem Winkel zum Zielpunkt gesetzt und schaut
-- das Ziel an.
--
-- <p><b>Alias:</b> PlaceEntityFaceToFaceToAnotherOne</p>
-- <p><b>Alias:</b> SetPositionEx<br></p>
--
-- @param _Entity          [string|number|table] Entity das bewegt wird
-- @param _Position        [string|number|table] Position zu der bewegt wird
-- @param _Distance        [number] Entfernung
-- @within Anwenderfunktionen
--
-- @usage
-- API.PlaceAndLookAt("hakim", "saraya", 300);
--
function API.PlaceAndLookAt(_Entity, _Position, _Distance)
    if GUI then
        API.Bridge("API.PlaceAndLookAt(" ..GetID(_Entity).. ", " ..GetID(_Position).. ", " .._Distance.. ")")
        return;
    end
    API.PlaceToPosition(_Entity, _Position, _Distance, 0);
    LookAt(_Entity, _Position);
end
PlaceEntityFaceToFaceToAnotherOne = API.PlaceAndLookAt;
SetPositionEx = API.PlaceAndLookAt;

---
-- Das Entity greift ein anderes Entity an, sofern möglich.
--
-- <p><b>Alias:</b> Attack</p>
--
-- @param_Entity  [string|number] Angreifendes Entity
-- @param _Target [string|number] Angegriffenes Entity
-- @within Anwenderfunktionen
--
-- @usage
-- API.CommandAttack("hakim", "marcus");
--
function API.CommandAttack(_Entity, _Target)
    if GUI then
        API.Bridge("API.CommandAttack(" ..GetID(_Entity).. ", " ..GetID(_Target).. ")")
        return;
    end
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.CommandAttack: Entity " ..Subject.. " does not exist!");
        return;
    end
    if not IsExisting(_Target) then
        local Subject = (type(_Target) == "string" and "'" .._Target.. "'") or _Target;
        API.Dbg("API.CommandAttack: Target " ..Subject.. " does not exist!");
        return;
    end
    return BundleEntityCommandFunctions.Global:Attack(_Entity, _Target);
end
Attack = API.CommandAttack;

---
-- Ein Entity oder ein Battalion wird zu einer Position laufen und
-- alle gültigen Ziele auf dem Weg angreifen.
--
-- <p><b>Alias:</b> AttackMove</p>
--
-- @param _Entity   [string|number] Angreifendes Entity
-- @param _Position [string] Skriptname, EntityID oder Positionstable
-- @within Anwenderfunktionen
--
-- @usage
-- API.CommandAttackMove("hakim", "area");
--
function API.CommandAttackMove(_Entity, _Position)
    if GUI then
        API.Dbg("API.CommandAttackMove: Cannot be used from local script!");
        return;
    end
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.CommandAttackMove: Entity " ..Subject.. " does not exist!");
        return;
    end
    local Position = API.LocateEntity(_Position)
    if not API.ValidatePosition(Position) then
        API.Dbg("API.CommandAttackMove: Position is invalid!");
        return;
    end
    return BundleEntityCommandFunctions.Global:AttackMove(_Entity, Position);
end
AttackMove = API.CommandAttackMove;

---
-- Bewegt das Entity zur Zielposition.
--
-- <p><b>Alias:</b> Move</p>
--
-- @param _Entity   [string|number] Bewegendes Entity
-- @param _Position [table] Positionstable
-- @within Anwenderfunktionen
--
-- @usage
-- API.CommandMove("hakim", "pos");
--
function API.CommandMove(_Entity, _Position)
    if GUI then
        API.Dbg("API.CommandMove: Cannot be used from local script!");
        return;
    end
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.CommandMove: Entity " ..Subject.. " does not exist!");
        return;
    end
    local Position = API.LocateEntity(_Position)
    if not API.ValidatePosition(Position) then
        API.Dbg("API.CommandMove: Position is invalid!");
        return;
    end
    return BundleEntityCommandFunctions.Global:Move(_Entity, Position);
end
Move = API.CommandMove;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleEntityCommandFunctions = {
    Global = {
        Data = {}
    },
    Shared = {
        Data = {}
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function BundleEntityCommandFunctions.Global:Install()
end

-- Setzt ein Entity oder ein Battalion an eine neue Position.
--
-- @param _Entity   [string|number] Entity zum versetzen
-- @param _Position [string|number|table] Neue Position
-- @within Internal
-- @local
--
function BundleEntityCommandFunctions.Global:SetPosition(_Entity,_Position)
    if not IsExisting(_Entity)then
        return
    end
    local EntityID = GetEntityId(_Entity);
    Logic.DEBUG_SetSettlerPosition(EntityID, _Position.X, _Position.Y);
    if Logic.IsLeader(EntityID) == 1 then
        local soldiers = {Logic.GetSoldiersAttachedToLeader(EntityID)};
        if soldiers[1] > 0 then
            for i=1,#soldiers do
                Logic.DEBUG_SetSettlerPosition(soldiers[i], _Position.X, _Position.Y);
            end
        end
    end
end

---
-- Das Entity wird relativ zu einem Winkel zum Zielpunkt bewegt.
--
-- @param _Entity       [string|number] Zu bewegendes Entity
-- @param _Position     [string|number] Ziel
-- @param _Distance     [number] Entfernung zum Ziel
-- @param _Angle        [number] Winkel
-- @param _moveAsEntity [boolean] Blocking ignorieren
-- @within Internal
-- @local
--
function BundleEntityCommandFunctions.Global:MoveToPosition(_Entity, _Position, _Distance, _Angle, _moveAsEntity)
    if not IsExisting(_Entity)then
        return
    end
    if not _Distance then
        _Distance = 0;
    end
    local eID = GetID(_Entity);
    local tID = GetID(_Position);
    local pos = BundleEntityCommandFunctions.Shared:GetRelativePos(_Position, _Distance);
    if type(_Angle) == "number" then
        pos = BundleEntityCommandFunctions.Shared:GetRelativePos(_Position, _Distance, _Angle);
    end

    if _moveAsEntity then
        Logic.MoveEntity(eID, pos.X, pos.Y);
    else
        Logic.MoveSettler(eID, pos.X, pos.Y);
    end

    StartSimpleJobEx( function(_EntityID, _TargetID)
        if not Logic.IsEntityMoving(_EntityID) then
            LookAt(_EntityID, _TargetID);
            return true;
        end
    end, eID, tID);
end

---
-- Das Entity wird relativ zu einem Winkel zum Zielpunkt bewegt und schaut
-- das Ziel anschließend an.
--
-- @param _Entity       [string|number] Zu bewegendes Entity
-- @param _Position     [string|number] Ziel
-- @param _Distance     [number] Entfernung zum Ziel
-- @param _moveAsEntity [boolean] Blocking ignorieren
-- @within Internal
-- @local
--
function BundleEntityCommandFunctions.Global:MoveAndLookAt(_Entity, _Position, _Distance, _moveAsEntity)
    if not IsExisting(_Entity)then
        return
    end
    if not _Distance then
        _Distance = 0;
    end

    self:MoveToPosition(_Entity, _Position, _Distance, 0, _moveAsEntity);
    StartSimpleJobEx( function(_EntityID, _TargetID)
        if not Logic.IsEntityMoving(_EntityID) then
            LookAt(_EntityID, _TargetID);
            return true;
        end
    end, GetID(_Entity), GetID(_Position));
end

---
-- Das Entity greift ein anderes Entity an, sofern möglich.
--
-- @param_Entity  [string|number] Angreifendes Entity
-- @param _Target [string|number] Angegriffenes Entity
-- @within Internal
-- @local
--
function BundleEntityCommandFunctions.Global:Attack(_Entity, _Target)
    local EntityID = GetID(_Entity);
    local TargetID = GetID(_Target);
    Logic.GroupAttack(EntityID, TargetID);
end

---
-- Ein Entity oder ein Battalion wird zu einer Position laufen und
-- alle gültigen Ziele auf dem Weg angreifen.
--
-- @param _Entity   [string|number] Angreifendes Entity
-- @param _Position [string] Skriptname, EntityID oder Positionstable
-- @within Internal
-- @local
--
function BundleEntityCommandFunctions.Global:AttackMove(_Entity, _Position)
    local EntityID = GetID(_Entity);
    Logic.GroupAttackMove(EntityID, _Position.X, _Position.Y);
end

---
-- Bewegt das Entity zur Zielposition.
--
-- @param _Entity   [string|number] Bewegendes Entity
-- @param _Position [table] Positionstable
-- @within Internal
-- @local
--
function BundleEntityCommandFunctions.Global:Move(_Entity, _Position)
    local EntityID = GetID(_Entity);
    Logic.MoveSettler(EntityID, _Position.X, _Position.Y);
end


-- Shared ----------------------------------------------------------------------

---
-- Errechnet eine Position relativ im angegebenen Winkel und Position zur
-- Basisposition. Die Basis kann ein Entity oder eine Positionstabelle sein.
--
-- @param _target          [string|number|table] Basisposition
-- @param _distance        [number] Entfernung
-- @param _angle           [number] Winkel
-- @param _buildingRealPos [boolean] Gebäudemitte statt Gebäudeeingang
-- @return [table] Position
-- @within Internal
-- @local
--
function BundleEntityCommandFunctions.Shared:GetRelativePos(_target,_distance,_angle,_buildingRealPos)
    if not type(_target) == "table" and not IsExisting(_target)then
        return
    end
    if _angle == nil then
        _angle = 0;
    end

    local pos1;
    if type(_target) == "table" then
        local pos = _target;
        local ori = 0+_angle;
        pos1 = { X= pos.X+_distance * math.cos(math.rad(ori)),
                 Y= pos.Y+_distance * math.sin(math.rad(ori))};
    else
        local eID = GetID(_target);
        local pos = GetPosition(eID);
        local ori = Logic.GetEntityOrientation(eID)+_angle;
        if Logic.IsBuilding(eID) == 1 and not _buildingRealPos then
            x, y = Logic.GetBuildingApproachPosition(eID);
            pos = {X= x, Y= y};
            ori = ori -90;
        end
        pos1 = { X= pos.X+_distance * math.cos(math.rad(ori)),
                 Y= pos.Y+_distance * math.sin(math.rad(ori))};
    end
    return pos1;
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleEntityCommandFunctions");

