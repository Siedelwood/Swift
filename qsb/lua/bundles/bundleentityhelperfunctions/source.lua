-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntityHelperFunctions                                  # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle enthält häufig gebrauchte Funktionen für Entities.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleEntityHelperFunctions = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Sucht auf den angegebenen Territorium nach Entities mit bestimmten
-- Kategorien. Dabei kann für eine Partei oder für mehrere parteien gesucht
-- werden.
--
-- <p><b>Alias:</b> GetEntitiesOfCategoriesInTerritories<br></p>
-- <p><b>Alias:</b> EntitiesInCategories</p>
--
-- @param _player       [number|table] PlayerID [0-8] oder Table mit PlayerIDs
-- @param _category     [number|table] Kategorien oder Table mit Kategorien
-- @param _territory    [number|table] Zielterritorium oder Table mit Territorien
-- @return [table] Liste mit Resultaten
-- @within Anwenderfunktionen
--
-- @usage
-- local Result = API.GetEntitiesOfCategoriesInTerritories({1, 2, 3}, EntityCategories.Hero, {5, 12, 23, 24});
--
function API.GetEntitiesOfCategoriesInTerritories(_player, _category, _territory)
    return BundleEntityHelperFunctions.Shared:GetEntitiesOfCategoriesInTerritories(_player, _category, _territory);
end
GetEntitiesOfCategoriesInTerritories = API.GetEntitiesOfCategoriesInTerritories;
EntitiesInCategories = API.GetEntitiesOfCategoriesInTerritories;

---
-- Gibt alle Entities zurück, deren Name mit dem Prefix beginnt.
--
-- <p><b>Alias:</b> GetEntitiesNamedWith</p>
--
-- @param _Prefix [string] Präfix des Skriptnamen
-- @return [table] Liste mit Entities
-- @within Anwenderfunktionen
--
-- @usage
-- -- Alle Entities mit "entranceCave" -> entranceCave1, entranceCave2, ...
-- local Result = API.GetEntitiesByPrefix("entranceCave");
--
function API.GetEntitiesByPrefix(_Prefix)
    return BundleEntityHelperFunctions.Shared:GetEntitiesByPrefix(_Prefix);
end
GetEntitiesNamedWith = API.GetEntitiesByPrefix;

-- Setzt die Menge an Rohstoffen und die durchschnittliche Auffüllmenge
-- in einer Mine.
--
-- <p><b>Alias:</b> SetResourceAmount</p>
--
-- @param _Entity       [string|number] Skriptname, EntityID der Mine
-- @param _StartAmount  [number] Menge an Rohstoffen
-- @param _RefillAmount [number] Minimale Nachfüllmenge (> 0)
-- @within User Spase
--
-- @usage
-- API.SetResourceAmount("mine1", 250, 150);
--
function API.SetResourceAmount(_Entity, _StartAmount, _RefillAmount)
    if GUI then
        local Subject = (type(_Entity) ~= "string" and _Entity) or "'" .._Entity.. "'";
        API.Bridge("API.SetResourceAmount(" ..Subject..", " .._StartAmount.. ", " .._RefillAmount.. ")")
        return;
    end
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) ~= "string" and _Entity) or "'" .._Entity.. "'";
        API.Dbg("API.SetResourceAmount: Entity " ..Subject.. " does not exist!");
        return;
    end
    return BundleEntityHelperFunctions.Global:SetResourceAmount(_Entity, _StartAmount, _RefillAmount);
end
SetResourceAmount = API.SetResourceAmount;

---
-- Errechnet eine Position relativ im angegebenen Winkel und Position zur
-- Basisposition. Die Basis kann ein Entity oder eine Positionstabelle sein.
--
-- <p><b>Alias:</b> GetRelativePos</p>
--
-- @param _target          [string|number|table] Basisposition
-- @param _distance        [number] Entfernung
-- @param _angle           [number] Winkel
-- @param _buildingRealPos [boolean] Gebäudemitte statt Gebäudeeingang
-- @return [table] Position
-- @within Anwenderfunktionen
--
-- @usage
-- local RelativePostion = API.GetRelativePosition("pos1", 1000, 32);
--
function API.GetRelativePosition(_target, _distance, _angle, _buildingRealPos)
    if not API.ValidatePosition(_target) then
        if not IsExisting(_target) then
            API.Dbg("API.GetRelativePosition: Target is invalid!");
            return;
        end
    end
    return BundleEntityHelperFunctions.Shared:GetRelativePos(_target, _distance, _angle, _buildingRealPos);
end
GetRelativePos = API.GetRelativePosition;

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
    return BundleEntityHelperFunctions.Global:SetPosition(_Entity, Position);
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
    return BundleEntityHelperFunctions.Global:MoveToPosition(_Entity, _Position, _Distance, _Angle, _moveAsEntity)
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
    return BundleEntityHelperFunctions.Global:MoveAndLookAt(_Entity, _Position, _Distance, _moveAsEntity)
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
    local Position = API.GetRelativePosition(_Position, _Distance, _Angle, true);
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
-- Gibt den Skriptnamen des Entity zurück.
--
-- <p><b>Alias:</b> GetEntityName</p>
--
-- @param _entity [number] Gesuchtes Entity
-- @return [string] Skriptname
-- @within Anwenderfunktionen
--
-- @usage
-- local Name = API.GetEntityName(SomeEntityID);
--
function API.GetEntityName(_entity)
    if not IsExisting(_entity) then
        local Subject = (type(_entity) ~= "string" and _entity) or "'" .._entity.. "'";
        API.Warn("API.GetEntityName: Entity " ..Subject.. " does not exist!");
        return nil;
    end
    return Logic.GetEntityName(GetID(_entity));
end
GetEntityName = API.GetEntityName;

---
-- Setzt den Skriptnamen des Entity.
--
-- <p><b>Alias:</b> SetEntityName</p>
--
-- @param _entity [number] Entity
-- @param _name   [string] Skriptname
-- @return [string] Skriptname
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetEntityName(SomeEntityID, "myEntity");
--
function API.SetEntityName(_entity, _name)
    if GUI then
        API.Bridge("API.SetEntityName(" ..GetID(_EntityID).. ", '" .._name.. "')")
        return;
    end
    if IsExisting(_name) then
        API.Dbg("API.SetEntityName: Entity '" .._name.. "' already exists!");
        return;
    end
    return Logic.SetEntityName(GetID(_entity), _name);
end
SetEntityName = API.SetEntityName;

---
-- Setzt die Orientierung des Entity.
--
-- <p><b>Alias:</b> SetOrientation</p>
--
-- @param _entity [string|number] Gesuchtes Entity
-- @param _ori    [number] Ausrichtung in Grad
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetOrientation("marcus", 52);
--
function API.SetOrientation(_entity, _ori)
    if GUI then
        API.Bridge("API.SetOrientation(" ..GetID(_entity).. ", " .._ori.. ")")
        return;
    end
    if not IsExisting(_entity) then
        local Subject = (type(_entity) ~= "string" and _entity) or "'" .._entity.. "'";
        API.Dbg("API.SetOrientation: Entity " ..Subject.. " does not exist!");
        return;
    end
    return Logic.SetOrientation(GetID(_entity), _ori);
end
SetOrientation = API.SetOrientation;

---
-- Gibt die Orientierung des Entity zurück.
--
-- <p><b>Alias:</b> GetOrientation</p>
--
-- @param _entity [string|number] Gesuchtes Entity
-- @return [number] Orientierung in Grad
-- @within Anwenderfunktionen
--
-- @usage
-- local Orientation = API.GetOrientation("marcus");
--
function API.GetOrientation(_entity)
    if not IsExisting(_entity) then
        local Subject = (type(_entity) ~= "string" and _entity) or "'" .._entity.. "'";
        API.Warn("API.GetOrientation: Entity " ..Subject.. " does not exist!");
        return 0;
    end
    return Logic.GetEntityOrientation(GetID(_entity));
end
GetOrientation = API.GetOrientation;

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
-- API.EntityAttack("hakim", "marcus");
--
function API.EntityAttack(_Entity, _Target)
    if GUI then
        API.Bridge("API.EntityAttack(" ..GetID(_Entity).. ", " ..GetID(_Target).. ")")
        return;
    end
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.EntityAttack: Entity " ..Subject.. " does not exist!");
        return;
    end
    if not IsExisting(_Target) then
        local Subject = (type(_Target) == "string" and "'" .._Target.. "'") or _Target;
        API.Dbg("API.EntityAttack: Target " ..Subject.. " does not exist!");
        return;
    end
    return BundleEntityHelperFunctions.Global:Attack(_Entity, _Target);
end
Attack = API.EntityAttack;

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
-- API.EntityAttackMove("hakim", "area");
--
function API.EntityAttackMove(_Entity, _Position)
    if GUI then
        API.Dbg("API.EntityAttackMove: Cannot be used from local script!");
        return;
    end
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.EntityAttackMove: Entity " ..Subject.. " does not exist!");
        return;
    end
    local Position = API.LocateEntity(_Position)
    if not API.ValidatePosition(Position) then
        API.Dbg("API.EntityAttackMove: Position is invalid!");
        return;
    end
    return BundleEntityHelperFunctions.Global:AttackMove(_Entity, Position);
end
AttackMove = API.EntityAttackMove;

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
-- API.EntityMove("hakim", "pos");
--
function API.EntityMove(_Entity, _Position)
    if GUI then
        API.Dbg("API.EntityMove: Cannot be used from local script!");
        return;
    end
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.EntityMove: Entity " ..Subject.. " does not exist!");
        return;
    end
    local Position = API.LocateEntity(_Position)
    if not API.ValidatePosition(Position) then
        API.Dbg("API.EntityMove: Position is invalid!");
        return;
    end
    return BundleEntityHelperFunctions.Global:Move(_Entity, Position);
end
Move = API.EntityMove;

---
-- Ermittelt den Helden eines Spielers, ders dem Basis-Entity am nächsten ist.
--
-- <p><b>Alias:</b> GetClosestKnight</p>
--
-- @param _eID      [number] Basis-Entity
-- @param _playerID [number] Besitzer der Helden
-- @return [number] Nächstes Entity
-- @within Anwenderfunktionen
--
-- @usage
-- local Knight = API.GetNearestKnight(GetID("IO1"), 1);
--
function API.GetNearestKnight(_eID, _playerID)
    local Knights = {};
    Logic.GetKnights(_playerID, Knights);
    return API.GetNearestEntity(_eID, Knights);
end
GetClosestKnight = API.GetNearestKnight;

---
-- Ermittelt aus einer liste von Entity-IDs das Entity, dass dem Basis-Entity
-- am nächsten ist.
--
-- <p><b>Alias:</b> GetClosestEntity</p>
--
-- @param _eID      [number] Basis-Entity
-- @param _entities [table] Liste von Entities
-- @return [number] Nächstes Entity
-- @within Anwenderfunktionen
--
-- @usage
-- local EntityList = API.GetEntitiesOfCategoriesInTerritories({1, 2, 3}, EntityCategories.Hero, {5, 12, 23, 24});
-- local Knight = API.GetNearestEntity(GetID("IO1"), EntityList);
--
function API.GetNearestEntity(_eID, _entities)
    if not IsExisting(_eID) then
        return;
    end
    if #_entities == 0 then
        API.Dbg("API.GetNearestEntity: The target list is empty!");
        return;
    end
    for i= 1, #_entities, 1 do
        if not IsExisting(_entities[i]) then
            API.Dbg("API.GetNearestEntity: At least one target entity is dead!");
            return;
        end
    end
    return BundleEntityHelperFunctions.Shared:GetNearestEntity(_eID,_entities);
end
GetClosestEntity = API.GetNearestEntity;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleEntityHelperFunctions = {
    Global = {
        Data = {
            RefillAmounts = {},
        }
    },
    Local = {
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
function BundleEntityHelperFunctions.Global:Install()
    BundleEntityHelperFunctions.Global:OverwriteGeologistRefill();
end

---
-- Überschreibt das Auffüll-Callback, wenn es vorhanden ist, um Auffüllmengen
-- auch während des Spiels setzen zu können.
--
-- @within Internal
-- @local
--
function BundleEntityHelperFunctions.Global:OverwriteGeologistRefill()
    if Framework.GetGameExtraNo() >= 1 then
        GameCallback_OnGeologistRefill_Orig_QSBPlusComforts1 = GameCallback_OnGeologistRefill
        GameCallback_OnGeologistRefill = function( _PlayerID, _TargetID, _GeologistID )
            GameCallback_OnGeologistRefill_Orig_QSBPlusComforts1( _PlayerID, _TargetID, _GeologistID )
            if BundleEntityHelperFunctions.Global.Data.RefillAmounts[_TargetID] then
                local RefillAmount = BundleEntityHelperFunctions.Global.Data.RefillAmounts[_TargetID];
                local RefillRandom = RefillAmount + math.random(1, math.floor((RefillAmount * 0.2) + 0.5));
                Logic.SetResourceDoodadGoodAmount(_TargetID, RefillRandom);
            end
        end
    end
end

-- Setzt die Menge an Rohstoffen und die durchschnittliche Auffüllmenge
-- in einer Mine.
--
-- @param _Entity       [string|number] Skriptname, EntityID der Mine
-- @param _StartAmount  [number] Menge an Rohstoffen
-- @param _RefillAmount [number] Minimale Nachfüllmenge (> 0)
-- @return [boolean] Operation erfolgreich
-- @within Internal
-- @local
--
function BundleEntityHelperFunctions.Global:SetResourceAmount(_Entity, _StartAmount, _RefillAmount)
    assert(type(_StartAmount) == "number");
    assert(type(_RefillAmount) == "number");

    local EntityID = GetID(_Entity);
    if not IsExisting(EntityID) or Logic.GetResourceDoodadGoodType(EntityID) == 0 then
        API.Dbg("SetResourceAmount: Resource entity is invalid!");
        return false;
    end
    if Logic.GetResourceDoodadGoodAmount(EntityID) == 0 then
        EntityID = ReplaceEntity(EntityID, Logic.GetEntityType(EntityID));
    end
    Logic.SetResourceDoodadGoodAmount(EntityID, _StartAmount);
    if _RefillAmount then
        self.Data.RefillAmounts[EntityID] = _RefillAmount;
    end
    return true;
end

-- Setzt ein Entity oder ein Battalion an eine neue Position.
--
-- @param _Entity   [string|number] Entity zum versetzen
-- @param _Position [string|number|table] Neue Position
-- @within Internal
-- @local
--
function BundleEntityHelperFunctions.Global:SetPosition(_Entity,_Position)
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
function BundleEntityHelperFunctions.Global:MoveToPosition(_Entity, _Position, _Distance, _Angle, _moveAsEntity)
    if not IsExisting(_Entity)then
        return
    end
    if not _Distance then
        _Distance = 0;
    end
    local eID = GetID(_Entity);
    local tID = GetID(_Position);
    local pos = GetRelativePos(_Position, _Distance);
    if type(_Angle) == "number" then
        pos = BundleEntityHelperFunctions.Shared:GetRelativePos(_Position, _Distance, _Angle);
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
function BundleEntityHelperFunctions.Global:MoveAndLookAt(_Entity, _Position, _Distance, _moveAsEntity)
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
function BundleEntityHelperFunctions.Global:Attack(_Entity, _Target)
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
function BundleEntityHelperFunctions.Global:AttackMove(_Entity, _Position)
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
function BundleEntityHelperFunctions.Global:Move(_Entity, _Position)
    local EntityID = GetID(_Entity);
    Logic.MoveSettler(EntityID, _Position.X, _Position.Y);
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleEntityHelperFunctions.Local:Install()

end



-- Shared ----------------------------------------------------------------------

---
-- Ermittelt alle Entities in den Kategorien auf den Territorien für die
-- Liste von Parteien und gibt sie als Liste zurück.
--
-- @param _player       [number|table] PlayerID [0-8] oder Table mit PlayerIDs
-- @param _category     [number|table] Kategorien oder Table mit Kategorien
-- @param _territory    [number|table] Zielterritorium oder Table mit Territorien
-- @return [table] Liste mit Resultaten
-- @within Internal
-- @local
--
function BundleEntityHelperFunctions.Shared:GetEntitiesOfCategoriesInTerritories(_player, _category, _territory)
    -- Tables erzwingen
    local p = (type(_player) == "table" and _player) or {_player};
    local c = (type(_category) == "table" and _category) or {_category};
    local t = (type(_territory) == "table" and _territory) or {_territory};

    local PlayerEntities = {};
    for i=1, #p, 1 do
        for j=1, #c, 1 do
            for k=1, #t, 1 do
                local Units = API.GetEntitiesOfCategoryInTerritory(p[i], c[j], t[k]);
                PlayerEntities = Array_Append(PlayerEntities, Units);
            end
        end
    end
    return PlayerEntities;
end

---
-- Gibt alle Entities zurück, deren Name mit dem Prefix beginnt.
--
-- @param _Prefix [string] Präfix des Skriptnamen
-- @return [table] Liste mit Entities
-- @within Internal
-- @local
--
function BundleEntityHelperFunctions.Shared:GetEntitiesByPrefix(_Prefix)
    local list = {};
    local i = 1;
    local bFound = true;
    while bFound do
        local entity = GetID(_Prefix ..i);
        if entity ~= 0 then
            table.insert(list, entity);
        else
            bFound = false;
        end
        i = i + 1;
    end
    return list;
end

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
function BundleEntityHelperFunctions.Shared:GetRelativePos(_target,_distance,_angle,_buildingRealPos)
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

---
-- Ermittelt aus einer liste von Entity-IDs das Entity, dass dem Basis-Entity
-- am nächsten ist.
--
-- @param _eID      [number] Basis-Entity
-- @param _entities [table] Liste von Entities
-- @return [number] Nächstes Entity
-- @within Internal
-- @local
--
function BundleEntityHelperFunctions.Shared:GetNearestEntity(_eID,_entities)
    local bestDistance = Logic.WorldGetSize();
    local best = nil;
    for i=1,#_entities do
        local distanceBetween = Logic.GetDistanceBetweenEntities(_entities[i], _eID);
        if distanceBetween < bestDistance and _entities[i] ~= _eID then
            bestDistance = distanceBetween;
            best = _entities[i];
        end
    end
    return best;
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleEntityHelperFunctions");
