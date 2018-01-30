-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntityHelperFunctions                                  # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle enthält häufig gebrauchte Funktionen im Kontext zu Entities.
--
-- @module BundleEntityHelperFunctions
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Ermittelt alle Entities in den Kategorien auf den Territorien für die
-- Liste von Parteien und gibt sie als Liste zurück.
--
-- <b>Alias:</b> GetEntitiesOfCategoriesInTerritories
-- 
-- @param _player       PlayerID [0-8] oder Table mit PlayerIDs
-- @param _category     Kategorien oder Table mit Kategorien
-- @param _territory    Zielterritorium oder Table mit Territorien
-- @return table: Liste mit Entities
-- @within User-Space
--
function API.GetEntitiesOfCategoriesInTerritories(_player, _category, _territory)
    return BundleEntityHelperFunctions:GetEntitiesOfCategoriesInTerritories(_player, _category, _territory);
end
GetEntitiesOfCategoriesInTerritories = API.GetEntitiesOfCategoriesInTerritories;

---
-- Gibt alle Entities zurück, deren Name mit dem Prefix beginnt. 
--
-- <b>Alias:</b> GetEntitiesNamedWith
-- 
-- @param _Prefix Präfix des Skriptnamen
-- @return table: Liste mit Entities
-- @within User-Space
--
function API.GetEntitiesByPrefix(_Prefix)
    return BundleEntityHelperFunctions:GetEntitiesByPrefix(_Prefix);
end
GetEntitiesNamedWith = API.GetEntitiesByPrefix;

-- Setzt die Menge an Rohstoffen und die durchschnittliche Auffüllmenge
-- in einer Mine. 
--
-- <b>Alias:</b> SetResourceAmount
--
-- @param _Entity       Skriptname, EntityID der Mine
-- @param _StartAmount  Menge an Rohstoffen
-- @param _RefillAmount Minimale Nachfüllmenge (> 0)
-- @within User Spase
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
-- <b>Alias:</b> GetRelativePos
-- 
-- @param _target          Basisposition
-- @param _distance        Entfernung
-- @param _angle           Winkel
-- @param _buildingRealPos Gebäudemitte statt Gebäudeeingang
-- @return table: Position
-- @within User-Space
--
function API.GetRelativePos(_target, _distance, _angle, _buildingRealPos)
    if not API.ValidatePosition(_target) then
        if not IsExisting(_target) then
            API.Dbg("API.GetRelativePos: Target is invalid!");
            return;
        end
    end
    return BundleEntityHelperFunctions:GetRelativePos(_target, _distance, _angle, _buildingRealPos);
end
GetRelativePos = API.GetRelativePos;

-- Setzt ein Entity oder ein Battalion an eine neue Position.
--
-- <b>Alias:</b> SetPosition
--
-- @param _Entity   Entity zum versetzen
-- @param _Position Neue Position
-- @within User-Space
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
-- Das Entity wird zum ziel bewegt und kann relativ um das Ziel in einem
-- Winkel bewegt werden. Das Entity wird das Ziel anschießend anschauen.
-- Die Funktion kann auch Schiffe bewegen, indem der letzte Parameter
-- true gesetzt wird.
--
-- <b>Alias:</b> MoveEx
--
-- @param _Entity       Zu bewegendes Entity
-- @param _Position     Ziel
-- @param _Distance     Entfernung zum Ziel
-- @param _Angle        Winkel
-- @param _moveAsEntity Blocking ignorieren
-- @within User-Space
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
MoveEx = API.MoveToPosition;

---
-- Platziert das Entity wird zum ziel bewegt und kann relativ um das Ziel
-- in einem Winkel.
--
-- <b>Alias:</b> SetPositionEx
--
-- @param _Entity       Zu bewegendes Entity
-- @param _Position     Ziel
-- @param _Distance     Entfernung zum Ziel
-- @param _Angle        Winkel
-- @within User-Space
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
    local Position = API.GetRelativePos(_Position, _Distance, _Angle, true);
    API.SetPosition(_Entity, Position);
end
SetPositionEx = API.PlaceToPosition;

---
-- Gibt dem Entity einen eindeutigen Skriptnamen und gibt ihn zurück.
-- Hat das Entity einen Namen, bleibt dieser unverändert und wird
-- zurückgegeben.
--
-- <b>Alias:</b> GiveEntityName
--
-- @param _EntityID Entity ID
-- @return string: Vergebener Name
-- @within User-Space
--
function API.GiveEntityName(_EntityID)
    if IsExisting(_name) then
        API.Dbg("API.GiveEntityName: Entity does not exist!");
        return;
    end
    if GUI then
        API.Bridge("API.GiveEntityName(" ..GetID(_EntityID).. ")")
        return;
    end
    return BundleEntityHelperFunctions.Global:GiveEntityName(_EntityID);
end
GiveEntityName = API.GiveEntityName;

---
-- Gibt den Skriptnamen des Entity zurück.
--
-- <b>Alias:</b> GetEntityName
--
-- @param _entity Gesuchtes Entity
-- @return string: Skriptname
-- @within User-Space
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
-- <b>Alias:</b> SetEntityName
--
-- @param _entity Entity
-- @param _name   Skriptname
-- @return string: Skriptname
-- @within User-Space
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
-- <b>Alias:</b> SetOrientation
--
-- @param _entity Gesuchtes Entity
-- @param _ori    Ausrichtung in Grad
-- @within User-Space
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
-- <b>Alias:</b> GetOrientation
--
-- @param _entity Gesuchtes Entity
-- @return number: Orientierung in Grad
-- @within User-Space
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
-- <b>Alias:</b> Attack
--
-- @param_Entity  Angreifendes Entity
-- @param _Target Angegriffenes Entity
-- @within User-Space
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
-- <b>Alias:</b> AttackMove
--
-- @param _Entity   Angreifendes Entity
-- @param _Position Skriptname, EntityID oder Positionstable
-- @within Application Space
-- @local
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
-- <b>Alias:</b> Move
--
-- @param _Entity   Bewegendes Entity
-- @param _Position Skriptname, EntityID oder Positionstable
-- @within Application Space
-- @local
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
-- Gibt die Battalion-ID (Entity-ID des Leaders) eines Soldaten zurück.
--
-- <b>Alias:</b> GetLeaderBySoldier
--
-- @param _soldier Soldier
-- @return number: ID des Battalion
-- @within User-Space
--
function API.GetLeaderBySoldier(_soldier)
    if not IsExisting(_soldier) then
        local Subject = (type(_soldier) == "string" and "'" .._soldier.. "'") or _Entity;
        API.Dbg("API.GetLeaderBySoldier: Entity " ..Subject.. " does not exist!");
        return;
    end
    return Logic.SoldierGetLeaderEntityID(GetID(_soldier))
end
GetLeaderBySoldier = API.GetLeaderBySoldier;

---
-- Ermittelt den Helden eines Spielers, ders dem Basis-Entity am nächsten ist.
--
-- <b>Alias:</b> GetClosestKnight
-- 
-- @param _eID      Basis-Entity
-- @param _playerID Besitzer der Helden
-- @return number: Nächstes Entity
-- @within User-Space
--
function API.GetNearestKnight(_eID,_playerID)
    local Knights = {};
    Logic.GetKnights(_playerID, Knights);
    return API.GetNearestEntity(_eID, Knights);
end
GetClosestKnight = API.GetNearestKnight;

---
-- Ermittelt aus einer liste von Entity-IDs das Entity, dass dem Basis-Entity
-- am nächsten ist.
--
-- <b>Alias:</b> GetClosestEntity
-- 
-- @param _eID      Basis-Entity
-- @param _entities Liste von Entities
-- @return number: Nächstes Entity
-- @within User-Space
--
function API.GetNearestEntity(_eID, _entities)
    if not IsExisting(_eID) then
        API.Dbg("API.GetNearestEntity: Base entity does not exist!");
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
    return BundleEntityHelperFunctions:GetNearestEntity(_eID,_entities);
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
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Application-Space
-- @local
--
function BundleEntityHelperFunctions.Global:Install()
    BundleEntityHelperFunctions.Global:OverwriteGeologistRefill();
end

---
-- Überschreibt das Auffüll-Callback, wenn es vorhanden ist, um Auffüllmengen
-- auch während des Spiels setzen zu können.
--
-- @within Application-Space
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
-- @param _Entity       Skriptname, EntityID der Mine
-- @param _StartAmount  Menge an Rohstoffen
-- @param _RefillAmount Minimale Nachfüllmenge (> 0)
-- @return boolean: Operation erfolgreich
-- @within Application-Space
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
-- @param _Entity   Entity zum versetzen
-- @param _Position Neue Position
-- @within Application-Space
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
-- Das Entity wird zum ziel bewegt und kann relativ um das Ziel in einem
-- Winkel bewegt werden. Das Entity wird das Ziel anschießend anschauen.
-- Die Funktion kann auch Schiffe bewegen, indem der letzte Parameter
-- true gesetzt wird.
--
-- @param _Entity       Zu bewegendes Entity
-- @param _Position     Ziel
-- @param _Distance     Entfernung zum Ziel
-- @param _Angle        Winkel
-- @param _moveAsEntity Blocking ignorieren
-- @within Application-Space
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
        pos = BundleEntityHelperFunctions:GetRelativePos(_Position, _Distance, _Angle);
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
-- Gibt dem Entity einen eindeutigen Skriptnamen und gibt ihn zurück.
-- Hat das Entity einen Namen, bleibt dieser unverändert und wird
-- zurückgegeben.
--
-- @param _EntityID Entity ID
-- @return string: Vergebener Name
-- @within Application Space
-- @local
--
function BundleEntityHelperFunctions.Global:GiveEntityName(_EntityID)
    if type(_EntityID) == "string" then
        return _EntityID;
    else
        assert(type(_EntityID) == "number");
        local name = Logic.GetEntityName(_EntityID);
        if (type(name) ~= "string" or name == "" ) then
            QSB.GiveEntityNameCounter = (QSB.GiveEntityNameCounter or 0)+ 1;
            name = "GiveEntityName_Entity_"..QSB.GiveEntityNameCounter;
            Logic.SetEntityName(_EntityID, name);
        end
        return name;
    end
end

---
-- Das Entity greift ein anderes Entity an, sofern möglich.
--
-- @param_Entity  Angreifendes Entity
-- @param _Target Angegriffenes Entity
-- @within Application Space
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
-- @param _Entity   Angreifendes Entity
-- @param _Position Positionstable
-- @within Application Space
-- @local
--
function BundleEntityHelperFunctions.Global:AttackMove(_Entity, _Position)
    local EntityID = GetID(_Entity);
    Logic.GroupAttackMove(EntityID, _Position.X, _Position.Y);
end

---
-- Bewegt das Entity zur Zielposition.
--
-- @param _Entity   Bewegendes Entity
-- @param _Position Positionstable
-- @within Application Space
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
-- @within Application-Space
-- @local
--
function BundleEntityHelperFunctions.Local:Install()

end



-- Shared ----------------------------------------------------------------------

---
-- Ermittelt alle Entities in den Kategorien auf den Territorien für die
-- Liste von Parteien und gibt sie als Liste zurück.
-- 
-- @param _player       PlayerID [0-8] oder Table mit PlayerIDs
-- @param _category     Kategorien oder Table mit Kategorien
-- @param _territory    Zielterritorium oder Table mit Territorien
-- @return table: Liste mit Entities
-- @within Application-Space
-- @local
--
function BundleEntityHelperFunctions:GetEntitiesOfCategoriesInTerritories(_player, _category, _territory)
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
-- @param _Prefix Präfix des Skriptnamen
-- @return table: Liste mit Entities
-- @within Application-Space
-- @local
--
function BundleEntityHelperFunctions:GetEntitiesByPrefix(_Prefix)
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
-- @param _target          Basisposition
-- @param _distance        Entfernung
-- @param _angle           Winkel
-- @param _buildingRealPos Gebäudemitte statt Gebäudeeingang
-- @return table: Position
-- @within Application-Space
-- @local
--
function BundleEntityHelperFunctions:GetRelativePos(_target,_distance,_angle,_buildingRealPos)
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
-- @param _eID      Basis-Entity
-- @param _entities Liste von Entities
-- @return number: Nächstes Entity
-- @within Application-Space
-- @local
--
function BundleEntityHelperFunctions:GetNearestEntity(_eID,_entities)
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

