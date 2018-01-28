-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleHelperFunctions                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- 
--
-- @module BundleHelperFunctions
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Entfernt ein Territorium für den angegebenen Spieler aus der Liste
-- der entdeckten Territorien.
--
-- <b>Alias:</b> UndiscoverTerritory
--
-- @param _PlayerID    Spieler-ID
-- @param _TerritoryID Territorium-ID
-- @within User-Space
--
function API.UndiscoverTerritory(_PlayerID, _TerritoryID)
    if GUI then
        API.Bridge("API.UndiscoverTerritory(" .._PlayerID.. ", ".._TerritoryID.. ")")
        return;
    end
    BundleHelperFunctions.Global:UndiscoverTerritory(_PlayerID, _TerritoryID);
end
UndiscoverTerritory = API.UndiscoverTerritory;

---
-- Entfernt alle Territorien einer Partei aus der Liste der entdeckten
-- Territorien. Als Nebeneffekt gild die Partei als unentdeckt.
--
-- <b>Alias:</b> UndiscoverTerritories
--
-- @param _PlayerID       Spieler-ID
-- @param _TargetPlayerID Zielpartei
-- @within User-Space
--
function API.UndiscoverTerritories(_PlayerID, _TargetPlayerID)
    if GUI then
        API.Bridge("API.UndiscoverTerritories(" .._PlayerID.. ", ".._TargetPlayerID.. ")")
        return;
    end
    BundleHelperFunctions.Global:UndiscoverTerritories(_PlayerID, _TargetPlayerID);
end
UndiscoverTerritories = API.UndiscoverTerritories;

---
-- Setzt den Befriedigungsstatus eines Bedürfnisses für alle Gebäude
-- des angegebenen Spielers. Der Befriedigungsstatus ist eine Zahl
-- zwischen 0.0 und 1.0.
--
-- <b>Alias:</b> SetNeedSatisfactionLevel
--
-- @param _Need     Bedürfnis
-- @param _State    Erfüllung des Bedürfnisses
-- @param _PlayerID Partei oder nil für alle
-- @within User-Space
--
function API.SetNeedSatisfaction(_Need, _State, _PlayerID)
    if GUI then
        API.Bridge("API.SetNeedSatisfaction(" .._Need.. ", " .._State.. ", " .._PlayerID.. ")")
        return;
    end
    BundleHelperFunctions.Global:SetNeedSatisfactionLevel(_Need, _State, _PlayerID);
end
SetNeedSatisfactionLevel = API.SetNeedSatisfaction;

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
    return BundleHelperFunctions:GetEntitiesOfCategoriesInTerritories(_player, _category, _territory);
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
    return BundleHelperFunctions:GetEntitiesByPrefix(_Prefix);
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
        API.Bridge("API.SetResourceAmount(" .._Entity..", " .._StartAmount.. ", " .._RefillAmount.. ")")
        return;
    end
    BundleHelperFunctions.Global:SetResourceAmount(_Entity, _StartAmount, _RefillAmount);
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
    return BundleHelperFunctions:GetRelativePos(_target, _distance, _angle, _buildingRealPos);
end
GetRelativePos = API.GetRelativePos;

-- Setzt ein Entity oder ein Battalion an eine neue Position.
--
-- <b>Alias:</b> SetPosition
--
-- @param _Entity   Entity zum versetzen
-- @param _Position Neue Position
-- @within Application-Space
-- @local
--
function API.SetPosition(_Entity,_Position)
    if GUI then
        API.Bridge("API.SetPosition(" .._Entity.. ", " .._Position.. ")")
        return;
    end
    BundleHelperFunctions.Global:SetPosition(_Entity, _Position);
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
    BundleHelperFunctions.Global:MoveToPosition(_Entity, _Position, _Distance, _Angle, _moveAsEntity)
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
-- @within 
--
function API.GiveEntityName(_EntityID)
    if GUI then
        API.Bridge("API.GiveEntityName(" ..GetID(_EntityID).. ")")
        return;
    end
    return BundleHelperFunctions.Global:GiveEntityName(_EntityID);
end
GiveEntityName = API.GiveEntityName;

---
-- Gibt den Skriptnamen des Entity zurück.
--
-- <b>Alias:</b> GetEntityName
--
-- @param _entity Gesuchtes Entity
-- @return string: Skriptname
-- @within 
--
function API.GetEntityName(_entity)
    return Logic.GetEntityName(GetID(_entity));
end
GetEntityName = API.GetEntityName;

---
-- Setzt die Orientierung des Entity.
--
-- <b>Alias:</b> SetOrientation
--
-- @param _entity Gesuchtes Entity
-- @param _ori    Ausrichtung in Grad
-- @within 
--
function API.SetOrientation(_entity, _ori)
    if GUI then
        API.Bridge("API.SetOrientation(" ..GetID(_entity).. ", " .._ori.. ")")
        return;
    end
    if IsExisting(_entity) then
        Logic.SetOrientation(GetID(_entity), _ori);
    end
end
SetOrientation = API.SetOrientation;

---
-- Gibt die Orientierung des Entity zurück.
--
-- <b>Alias:</b> GetOrientation
--
-- @param _entity Gesuchtes Entity
-- @return number: Orientierung in Grad
-- @within 
--
function API.GetOrientation(_entity)
    return Logic.GetEntityOrientation(GetID(_entity));
end
GetOrientation = API.GetOrientation;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleHelperFunctions = {
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
function BundleHelperFunctions.Global:Install()
    BundleHelperFunctions.Global:OverwriteGeologistRefill();
end

---
-- Überschreibt das Auffüll-Callback, wenn es vorhanden ist, um Auffüllmengen
-- auch während des Spiels setzen zu können.
--
-- @within Application-Space
-- @local
--
function BundleHelperFunctions.Global:OverwriteGeologistRefill()
    if Framework.GetGameExtraNo() >= 1 then
        GameCallback_OnGeologistRefill_Orig_QSBPlusComforts1 = GameCallback_OnGeologistRefill
        GameCallback_OnGeologistRefill = function( _PlayerID, _TargetID, _GeologistID )
            GameCallback_OnGeologistRefill_Orig_QSBPlusComforts1( _PlayerID, _TargetID, _GeologistID )
            if BundleHelperFunctions.Global.Data.RefillAmounts[_TargetID] then
                local RefillAmount = BundleHelperFunctions.Global.Data.RefillAmounts[_TargetID];
                local RefillRandom = RefillAmount + math.random(1, math.floor((RefillAmount * 0.2) + 0.5));
                Logic.SetResourceDoodadGoodAmount(_TargetID, RefillRandom);
            end
        end
    end
end

---
-- Entfernt ein Territorium für den angegebenen Spieler aus der Liste
-- der entdeckten Territorien.
--
-- @param _PlayerID    Spieler-ID
-- @param _TerritoryID Territorium-ID
-- @within Application-Space
-- @local
--
function BundleHelperFunctions.Global:UndiscoverTerritory(_PlayerID, _TerritoryID)
    if DiscoveredTerritories[_PlayerID] == nil then
        DiscoveredTerritories[_PlayerID] = {};
    end
    for i=1, #DiscoveredTerritories[_PlayerID], 1 do
        if DiscoveredTerritories[_PlayerID][i] == _TerritoryID then
            table.remove(DiscoveredTerritories[_PlayerID], i);
            break;
        end
    end
end

---
-- Entfernt alle Territorien einer Partei aus der Liste der entdeckten
-- Territorien. Als Nebeneffekt gild die Partei als unentdeckt-
--
-- @param _PlayerID       Spieler-ID
-- @param _TargetPlayerID Zielpartei
-- @within Application-Space
-- @local
--
function BundleHelperFunctions.Global:UndiscoverTerritories(_PlayerID, _TargetPlayerID)
    if DiscoveredTerritories[_PlayerID] == nil then
        DiscoveredTerritories[_PlayerID] = {};
    end
    local Discovered = {};
    for k, v in pairs(DiscoveredTerritories[_PlayerID]) do
        local OwnerPlayerID = Logic.GetTerritoryPlayerID(v);
        if OwnerPlayerID ~= _TargetPlayerID then
            table.insert(Discovered, v);
            break;
        end
    end
    DiscoveredTerritories[_PlayerID][i] = Discovered;
end

---
-- Setzt den Befriedigungsstatus eines Bedürfnisses für alle Gebäude
-- des angegebenen Spielers. Der Befriedigungsstatus ist eine Zahl
-- zwischen 0.0 und 1.0.
--
-- @param _Need     Bedürfnis
-- @param _State    Erfüllung des Bedürfnisses
-- @param _PlayerID Partei oder nil für alle
-- @within Application-Space
-- @local
--
function BundleHelperFunctions.Global:SetNeedSatisfactionLevel(_Need, _State, _PlayerID)
    if not _PlayerID then
        for i=1, 8, 1 do
            Module_Comforts.Global.SetNeedSatisfactionLevel(_Need, _State, i);
        end
    else
        local City = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.CityBuilding)};
        if _Need == Needs.Nutrition or _Need == Needs.Medicine then
            local Rim = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.OuterRimBuilding)};
            City = Array_Append(City, Rim);
        end
        for j=1, #City, 1 do
            if Logic.IsNeedActive(City[j], _Need) then
                Logic.SetNeedState(City[j], _Need, _State);
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
function BundleHelperFunctions.Global:SetResourceAmount(_Entity, _StartAmount, _RefillAmount)
    assert(type(_StartAmount) == "number");
    assert(type(_RefillAmount) == "number");
    
    local EntityID = GetID(_Entity);
    if not IsExisting(EntityID) or Logic.GetResourceDoodadGoodType(EntityID) == 0 then
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
function BundleHelperFunctions.Global:SetPosition(_Entity,_Position)
    if not IsExisting(_Entity)then
        return
    end
    local EntityID = GetEntityId(_Entity);
    local pos = _Position;
    if type(pos) ~= "table" then
        pos = GetPosition(pos);
    end
    if API.IsValidPosition(pos) then
        Logic.DEBUG_SetSettlerPosition(EntityID, pos.X, pos.Y);
        if Logic.IsLeader(EntityID) == 1 then
            local soldiers = {Logic.GetSoldiersAttachedToLeader(EntityID)};
            if soldiers[1] > 0 then
                for i=1,#soldiers do
                    Logic.DEBUG_SetSettlerPosition(soldiers[i], pos.X, pos.Y);
                end
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
function BundleHelperFunctions.Global:MoveToPosition(_Entity, _Position, _Distance, _Angle, _moveAsEntity)
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
        pos = BundleHelperFunctions:GetRelativePos(_Position, _Distance, _Angle);
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
function BundleHelperFunctions.Global:GiveEntityName(_EntityID)
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

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Application-Space
-- @local
--
function BundleHelperFunctions.Local:Install()

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
function BundleHelperFunctions:GetEntitiesOfCategoriesInTerritories(_player, _category, _territory)
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
function BundleHelperFunctions:GetEntitiesByPrefix(_Prefix)
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
function BundleHelperFunctions:GetRelativePos(_target,_distance,_angle,_buildingRealPos)
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

Core:RegisterBundle("BundleHelperFunctions");

