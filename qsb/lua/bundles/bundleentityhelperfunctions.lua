-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntityHelperFunctions                                  # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Stellt Hilfsfunktionen bereit um die Eigenschaften von Entities zu
-- ermitteln oder zu verändern.
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
-- Kategorien. Dabei kann für eine Partei oder für mehrere Parteien gesucht
-- werden.
--
-- <p><b>Alias:</b> GetEntitiesOfCategoriesInTerritories<br></p>
-- <p><b>Alias:</b> EntitiesInCategories</p>
--
-- @param _player      PlayerID [0-8] oder Table mit PlayerIDs (Einzelne Spielernummer oder Table)
-- @param _category    Kategorien oder Table mit Kategorien (Einzelne Kategorie oder Table)
-- @param _territory   Zielterritorium oder Table mit Territorien (Einzelnes Territorium oder Table)
-- @return[type=table] Liste mit Resultaten
-- @within Anwenderfunktionen
--
-- @usage
-- local Result = API.GetEntitiesOfCategoriesInTerritories({1, 2, 3}, EntityCategories.Hero, {5, 12, 23, 24});
--
function API.GetEntitiesOfCategoriesInTerritories(_player, _category, _territory)
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
GetEntitiesOfCategoriesInTerritories = API.GetEntitiesOfCategoriesInTerritories;
EntitiesInCategories = API.GetEntitiesOfCategoriesInTerritories;

---
-- Gibt alle Entities zurück, deren Name mit dem Prefix beginnt.
--
-- <p><b>Alias:</b> GetEntitiesNamedWith</p>
--
-- @param[type=string] _Prefix Präfix des Skriptnamen
-- @return[type=table] Liste mit Entities
-- @within Anwenderfunktionen
--
-- @usage
-- -- Alle Entities mit "entranceCave" -> entranceCave1, entranceCave2, ...
-- local Result = API.GetEntitiesByPrefix("entranceCave");
--
function API.GetEntitiesByPrefix(_Prefix)
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
GetEntitiesNamedWith = API.GetEntitiesByPrefix;

---
-- Setzt die Menge an Rohstoffen und die durchschnittliche Auffüllmenge
-- in einer Mine.
--
-- <p><b>Alias:</b> SetResourceAmount</p>
--
-- @param              _Entity       Rohstoffvorkommen (Skriptname oder ID)
-- @param[type=number] _StartAmount  Menge an Rohstoffen
-- @param[type=number] _RefillAmount Minimale Nachfüllmenge (> 0)
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetResourceAmount("mine1", 250, 150);
--
function API.SetResourceAmount(_Entity, _StartAmount, _RefillAmount)
    if GUI or not IsExisting(_Entity) then
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
-- @param               _target          Basisposition (Skriptname, ID oder Position)
-- @param[type=number]  _distance        Entfernung
-- @param[type=number]  _angle           Winkel
-- @param[type=boolean] _buildingRealPos Gebäudemitte statt Gebäudeeingang
-- @return[type=table] Position
-- @within Anwenderfunktionen
--
-- @usage
-- local RelativePostion = API.GetRelativePosition("pos1", 1000, 32);
--
function API.GetRelativePosition(_target, _distance, _angle, _buildingRealPos)
    if not API.ValidatePosition(_target) and not IsExisting(_target) then
        return;
    end
    return BundleEntityHelperFunctions.Shared:GetRelativePos(_target, _distance, _angle, _buildingRealPos);
end
GetRelativePos = API.GetRelativePosition;

---
-- Gibt den Skriptnamen des Entity zurück.
--
-- <p><b>Alias:</b> GetEntityName</p>
--
-- @param[type=number] _entity Gesuchtes Entity
-- @return[type=string] Skriptname
-- @within Anwenderfunktionen
--
-- @usage
-- local Name = API.EntityGetName(SomeEntityID);
--
function API.EntityGetName(_entity)
    if not IsExisting(_entity) then
        return nil;
    end
    return Logic.GetEntityName(GetID(_entity));
end
GetEntityName = API.EntityGetName;

---
-- Setzt den Skriptnamen des Entity.
--
-- <p><b>Alias:</b> SetEntityName</p>
--
-- @param[type=number] _entity Entity
-- @param[type=string] _name   Skriptname
-- @return[type=string] Skriptname
-- @within Anwenderfunktionen
--
-- @usage
-- API.EntitySetName(SomeEntityID, "myEntity");
--
function API.EntitySetName(_entity, _name)
    if GUI or IsExisting(_name) then
        return;
    end
    return Logic.SetEntityName(GetID(_entity), _name);
end
SetEntityName = API.EntitySetName;

---
-- Ermittelt den Helden eines Spielers, ders dem Basis-Entity am nächsten ist.
--
-- Im Fehlerfall wird 0 zurückgegeben.
--
-- <p><b>Alias:</b> GetClosestKnight</p>
--
-- @param[type=number] _eID      Basis-Entity
-- @param[type=number] _playerID Besitzer der Helden
-- @return[type=number] Nächstes Entity
-- @within Anwenderfunktionen
--
-- @usage
-- local Knight = API.GetKnightNearby(GetID("IO1"), 1);
--
function API.GetKnightNearby(_eID, _playerID)
    local Knights = {};
    Logic.GetKnights(_playerID, Knights);
    return API.GetEntityNearby(_eID, Knights);
end
GetClosestKnight = API.GetKnightNearby;

---
-- Ermittelt aus einer liste von Entity-IDs das Entity, dass dem Basis-Entity
-- am nächsten ist.
--
-- Im Fehlerfall wird 0 zurückgegeben.
--
-- <p><b>Alias:</b> GetClosestEntity</p>
--
-- @param[type=number] _eID      Basis-Entity
-- @param[type=table]  _entities Liste von Entities
-- @return[type=number] Nächstes Entity
-- @within Anwenderfunktionen
--
-- @usage
-- local EntityList = API.GetEntitiesOfCategoriesInTerritories({1, 2, 3}, EntityCategories.Hero, {5, 12, 23, 24});
-- local Knight = API.GetEntityNearby(GetID("IO1"), EntityList);
--
function API.GetEntityNearby(_eID, _entities)
    if not IsExisting(_eID) or #_entities == 0 then
        return 0;
    end
    return BundleEntityHelperFunctions.Shared:GetNearestEntity(_eID,_entities);
end
GetClosestEntity = API.GetEntityNearby;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleEntityHelperFunctions = {
    Global = {
        Data = {
            RefillAmounts = {},
        }
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
                if RefillRandom > 0 then
                    if Logic.GetResourceDoodadGoodType(_TargetID) == Goods.G_Iron then
                        Logic.SetModel(_TargetID, Models.Doodads_D_SE_ResourceIron);
                    else
                        Logic.SetModel(_TargetID, Models.R_ResorceStone_Scaffold);
                    end
                end
            end
        end
    end
end

-- Setzt die Menge an Rohstoffen und die durchschnittliche Auffüllmenge
-- in einer Mine.
--
-- @param              _Entity       Rohstoffvorkommen (Skriptname oder ID)
-- @param[type=number] _StartAmount  Menge an Rohstoffen
-- @param[type=number] _RefillAmount Minimale Nachfüllmenge (> 0)
-- @return[type=boolean] Operation erfolgreich
-- @within Internal
-- @local
--
function BundleEntityHelperFunctions.Global:SetResourceAmount(_Entity, _StartAmount, _RefillAmount)
    assert(type(_StartAmount) == "number");
    assert(type(_RefillAmount) == "number");

    local EntityID = GetID(_Entity);
    if not IsExisting(EntityID) or Logic.GetResourceDoodadGoodType(EntityID) == 0 then
        fatal("SetResourceAmount: Resource entity is invalid!");
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

-- Shared ----------------------------------------------------------------------

---
-- Errechnet eine Position relativ im angegebenen Winkel und Position zur
-- Basisposition. Die Basis kann ein Entity oder eine Positionstabelle sein.
--
-- @param               _target          Basisposition (Skriptname, ID oder Position)
-- @param[type=number]  _distance        Entfernung
-- @param[type=number]  _angle           Winkel
-- @param[type=boolean] _buildingRealPos Gebäudemitte statt Gebäudeeingang
-- @return[type=table] Position
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
-- @param[type=number] _eID      Basis-Entity
-- @param[type=table]  _entities Liste von Entities
-- @return[type=number] Nächstes Entity
-- @within Internal
-- @local
--
function BundleEntityHelperFunctions.Shared:GetNearestEntity(_eID,_entities)
    local bestDistance = Logic.WorldGetSize();
    local best = 0;
    for i=1,#_entities do
        if IsExisting(_entities[i]) then
            local distanceBetween = Logic.GetDistanceBetweenEntities(_entities[i], _eID);
            if distanceBetween < bestDistance and _entities[i] ~= _eID then
                bestDistance = distanceBetween;
                best = _entities[i];
            end
        end
    end
    return best;
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleEntityHelperFunctions");

