-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleConstructionControl                                    # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es Gebiete oder Territorien auf der Map zu definieren, auf der ein
-- Gebäude oder ein Typ nicht gebaut bzw. nicht abgerissen werden darf.
--
-- @module BundleConstructionControl
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Fügt ein Entity hinzu, dass nicht abgerissen werden darf.
--
-- @param _entry Nicht abreißbares Entity
-- @within Public
--
function API.AddEntity(_entity)
    if not GUI then
        API.Bridge([[
            API.AddEntity("]].._entity..[[")
        ]]);
    else
        if not Inside(_enitry, BundleConstructionControl.Local.Data.Entities) then
            table.insert(BundleConstructionControl.Local.Data.Entities, _entity);
        end
    end
end

---
-- Fügt einen Entitytyp hinzu, der nicht abgerissen werden darf.
--
-- @param _entry Nicht abreißbarer Typ
-- @within Public
--
function API.AddEntityType(_entity)
    if not GUI then
        API.Bridge([[
            API.AddEntityType(]].._entity..[[)
        ]]);
    else
        if not Inside(_enitry, BundleConstructionControl.Local.Data.EntityTypes) then
            table.insert(BundleConstructionControl.Local.Data.EntityTypes, _entity);
        end
    end
end

---
-- Fügt eine Kategorie hinzu, die nicht abgerissen werden darf.
--
-- @param _entry Nicht abreißbare Kategorie
-- @within Public
--
function API.AddCategory(_entity)
    if not GUI then
        API.Bridge([[
            API.AddCategory(]].._entity..[[)
        ]]);
    else
        if not Inside(_enitry, BundleConstructionControl.Local.Data.EntityCategories) then
            table.insert(BundleConstructionControl.Local.Data.EntityCategories, _entity);
        end
    end
end

---
-- Fügt ein Territory hinzu, auf dem nichts abgerissen werden kann.
--
-- @param _entry Geschütztes Territorium
-- @within Public
--
function API.AddTerritory(_entity)
    if not GUI then
        API.Bridge([[
            API.AddTerritory(]].._entity..[[)
        ]]);
    else
        if not Inside(_enitry, BundleConstructionControl.Local.Data.OnTerritory) then
            table.insert(BundleConstructionControl.Local.Data.OnTerritory, _entity);
        end
    end
end

---
-- Entfernt ein Entity, dass nicht abgerissen werden darf.
--
-- @param _entry Nicht abreißbares Entity
-- @within Public
--
function API.RemoveEntity(_entry)
    if not GUI then
        API.Bridge([[
            API.RemoveEntity("]].._entry..[[")
        ]]);
    else
        for i=1,#BundleConstructionControl.Local.Data.Entities do
            if BundleConstructionControl.Local.Data.Entities[i] == _entry then
                table.remove(BundleConstructionControl.Local.Data.Entities, i);
                return;
            end
        end
    end
end

---
-- Entfernt einen Entitytyp, der nicht abgerissen werden darf.
--
-- @param _entry Nicht abreißbarer Typ
-- @within Public
--
function API.RemoveEntityType(_entry)
    if not GUI then
        API.Bridge([[
            API.RemoveEntityType(]].._entry..[[)
        ]]);
    else
        for i=1,#BundleConstructionControl.Local.Data.EntityTypes do
            if BundleConstructionControl.Local.Data.EntityTypes[i] == _entry then
                table.remove(BundleConstructionControl.Local.Data.EntityTypes, i);
                return;
            end
        end
    end
end

---
-- Entfernt eine Kategorie, die nicht abgerissen werden darf.
--
-- @param _entry Nicht abreißbare Kategorie
-- @within Public
--
function API.RemoveCategory(_entry)
    if not GUI then
        API.Bridge([[
            API.RemoveCategory(]].._entry..[[)
        ]]);
    else
        for i=1,#BundleConstructionControl.Local.Data.EntityCategories do
            if BundleConstructionControl.Local.Data.EntityCategories[i] == _entry then
                table.remove(BundleConstructionControl.Local.Data.EntityCategories, i);
                return;
            end
        end
    end
end

---
-- Entfernt ein Territory, auf dem nichts abgerissen werden kann.
--
-- @param _entry Geschütztes Territorium
-- @within Public
--
function API.RemoveTerritory(_entry)
    if not GUI then
        API.Bridge([[
            API.RemoveTerritory(]].._entry..[[)
        ]]);
    else
        for i=1,#BundleConstructionControl.Local.Data.OnTerritory do
            if BundleConstructionControl.Local.Data.OnTerritory[i] == _entry then
                table.remove(BundleConstructionControl.Local.Data.OnTerritory, i);
                return;
            end
        end
    end
end

---
-- Untersagt den Bau des Typs im Territorium.
--
-- @param _type      Entitytyp
-- @param _territory Territorium
-- @within Public
--
function API.BanTypeAtTerritory(_type, _territory)
    if GUI then
        local Territory = (type(_center) == "string" and "'" .._territory.. "'") or _territory;
        GUI.SendScriptCommand("API.BanTypeAtTerritory(" .._type.. ", " ..Territory.. ")");
        return;
    end
    if type(_territory) == "string" then
        _territory = GetTerritoryIDByName(_territory);
    end

    BundleConstructionControl.Global.Data.TerritoryBlockEntities[_type] = BundleConstructionControl.Global.Data.TerritoryBlockEntities[_type] or {};
    if not Inside(_territory, BundleConstructionControl.Global.Data.TerritoryBlockEntities[_type]) then
        table.insert(BundleConstructionControl.Global.Data.TerritoryBlockEntities[_type], _territory);
    end
end

---
-- Untersagt den Bau der Kategorie im Territorium.
--
-- @param _eCat      Entitykategorie
-- @param _territory Territorium
-- @within Public
--
function API.BanCategoryAtTerritory(_eCat, _territory)
    if GUI then
        local Territory = (type(_center) == "string" and "'" .._territory.. "'") or _territory;
        GUI.SendScriptCommand("API.BanTypeAtTerritory(" .._eCat.. ", " ..Territory.. ")");
        return;
    end
    if type(_territory) == "string" then
        _territory = GetTerritoryIDByName(_territory);
    end

    BundleConstructionControl.Global.Data.TerritoryBlockCategories[_eCat] = BundleConstructionControl.Global.Data.TerritoryBlockCategories[_eCat] or {};
    if not Inside(_territory, BundleConstructionControl.Global.Data.TerritoryBlockCategories[_eCat]) then
        table.insert(BundleConstructionControl.Global.Data.TerritoryBlockCategories[_eCat], _territory);
    end
end

---
-- Untersagt den Bau des Typs im Gebiet.
--
-- @param _type   Entitytyp
-- @param _center Gebietszentrum
-- @param _area   Gebietsgröße
-- @within Public
--
function API.BanTypeInArea(_type, _center, _area)
    if GUI then
        local Center = (type(_center) == "string" and "'" .._center.. "'") or _center;
        GUI.SendScriptCommand("API.BanTypeInArea(" .._type.. ", " ..Center.. ", " .._area.. ")");
        return;
    end

    BundleConstructionControl.Global.Data.AreaBlockEntities[_center] = BundleConstructionControl.Global.Data.AreaBlockEntities[_center] or {};
    if not Inside(_type, BundleConstructionControl.Global.Data.AreaBlockEntities[_center], true) then
        table.insert(BundleConstructionControl.Global.Data.AreaBlockEntities[_center], {_type, _area});
    end
end

---
-- Untersagt den Bau der Kategorie im Gebiet.
--
-- @param _eCat   Entitykategorie
-- @param _center Gebietszentrum
-- @param _area   Gebietsgröße
-- @within Public
--
function API.BanCategoryInArea(_eCat, _center, _area)
    if GUI then
        local Center = (type(_center) == "string" and "'" .._center.. "'") or _center;
        GUI.SendScriptCommand("API.BanCategoryInArea(" .._eCat.. ", " ..Center.. ", " .._area.. ")");
        return;
    end

    BundleConstructionControl.Global.Data.AreaBlockCategories[_center] = BundleConstructionControl.Global.Data.AreaBlockCategories[_center] or {};
    if not Inside(_eCat, BundleConstructionControl.Global.Data.AreaBlockCategories[_center], true) then
        table.insert(BundleConstructionControl.Global.Data.AreaBlockCategories[_center], {_eCat, _area});
    end
end

---
-- Gibt einen Typ zum Bau im Territorium wieder frei.
--
-- @param _type      Entitytyp
-- @param _territory Territorium
-- @within Public
--
function API.UnBanTypeAtTerritory(_type, _territory)
    if GUI then
        local Territory = (type(_center) == "string" and "'" .._territory.. "'") or _territory;
        GUI.SendScriptCommand("API.UnBanTypeAtTerritory(" .._type.. ", " ..Territory.. ")");
        return;
    end
    if type(_territory) == "string" then
        _territory = GetTerritoryIDByName(_territory);
    end

    if not BundleConstructionControl.Global.Data.TerritoryBlockEntities[_type] then
        return;
    end
    for i=1, BundleConstructionControl.Global.Data.TerritoryBlockEntities[_type], 1 do
        if BundleConstructionControl.Global.Data.TerritoryBlockEntities[_type][i] == _type then
            table.remove(BundleConstructionControl.Global.Data.TerritoryBlockEntities[_type], i);
            break;
        end
    end
end

---
-- Gibt eine Kategorie zum Bau im Territorium wieder frei.
--
-- @param _ecat      Entitykategorie
-- @param _territory Territorium
-- @within Public
--
function API.UnBanCategoryAtTerritory(_eCat, _territory)
    if GUI then
        local Territory = (type(_center) == "string" and "'" .._territory.. "'") or _territory;
        GUI.SendScriptCommand("API.UnBanTypeAtTerritory(" .._eCat.. ", " ..Territory.. ")");
        return;
    end
    if type(_territory) == "string" then
        _territory = GetTerritoryIDByName(_territory);
    end

    if not BundleConstructionControl.Global.Data.TerritoryBlockCategories[_eCat] then
        return;
    end
    for i=1, BundleConstructionControl.Global.Data.TerritoryBlockCategories[_eCat], 1 do
        if BundleConstructionControl.Global.Data.TerritoryBlockCategories[_eCat][i] == _type then
            table.remove(BundleConstructionControl.Global.Data.TerritoryBlockCategories[_eCat], i);
            break;
        end
    end
end

---
-- Gibt einen Typ zum Bau im Gebiet wieder frei.
--
-- @param _type   Entitytyp
-- @param _center Gebiet
-- @within Public
--
function API.UnBanTypeInArea (_type, _center)
    if GUI then
        local Center = (type(_center) == "string" and "'" .._center.. "'") or _center;
        GUI.SendScriptCommand("API.UnBanTypeInArea(" .._eCat.. ", " ..Center.. ")");
        return;
    end

    if not BundleConstructionControl.Global.Data.AreaBlockEntities[_center] then
        return;
    end
    for i=1, BundleConstructionControl.Global.Data.AreaBlockEntities[_center], 1 do
        if BundleConstructionControl.Global.Data.AreaBlockEntities[_center][i][1] == _type then
            table.remove(BundleConstructionControl.Global.Data.AreaBlockEntities[_center], i);
            break;
        end
    end
end

---
-- Gibt eine Kategorie zum Bau im Gebiet wieder frei.
--
-- @param _eCat   Entitykategorie
-- @param _center Gebiet
-- @within Public
--
function API.UnBanCategoryInArea(_eCat, _center)
    if GUI then
        local Center = (type(_center) == "string" and "'" .._center.. "'") or _center;
        GUI.SendScriptCommand("API.UnBanCategoryInArea(" .._type.. ", " ..Center.. ")");
        return;
    end

    if not BundleConstructionControl.Global.Data.AreaBlockCategories[_center] then
        return;
    end
    for i=1, BundleConstructionControl.Global.Data.AreaBlockCategories[_center], 1 do
        if BundleConstructionControl.Global.Data.AreaBlockCategories[_center][i][1] == _eCat then
            table.remove(BundleConstructionControl.Global.Data.AreaBlockCategories[_center], i);
            break;
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleConstructionControl = {
    Global = {
        Data = {
            TerritoryBlockCategories = {},
            TerritoryBlockEntities = {},
            AreaBlockCategories = {},
            AreaBlockEntities = {},
        }
    },
    Local = {
        Data = {
            Entities = {},
            EntityTypes = {},
            EntityCategories = {},
            OnTerritory = {},
        }
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Private
-- @local
--
function BundleConstructionControl.Global:Install()
    Core:AppendFunction(
        "GameCallback_CanPlayerPlaceBuilding",
        BundleConstructionControl.Global.CanPlayerPlaceBuilding
    );
end

---
-- Verhindert den Bau von Entities in Gebieten und Territorien.
--
-- @param _PlayerID Spieler
-- @param _Type     Gebäudetyp
-- @param _x        X-Position
-- @param _y        Y-Position
-- @within Private
-- @local
--
function BundleConstructionControl.Global.CanPlayerPlaceBuilding(_PlayerID, _Type, _x, _y)
    -- Auf Territorium ---------------------------------------------

    -- Prüfe Kategorien
    for k,v in pairs(BundleConstructionControl.Global.Data.TerritoryBlockCategories) do
        if v then
            for key, val in pairs(v) do
                if val and Logic.GetTerritoryAtPosition(_x, _y) == val then
                    if Logic.IsEntityTypeInCategory(_Type, k) == 1 then
                        return false;
                    end
                end
            end
        end
    end

    -- Prüfe Typen
    for k,v in pairs(BundleConstructionControl.Global.Data.TerritoryBlockEntities) do
        if v then
            for key,val in pairs(v) do
                GUI_Note(tostring(Logic.GetTerritoryAtPosition(_x, _y) == val));
                if val and Logic.GetTerritoryAtPosition(_x, _y) == val then
                    if _Type == k then
                        return false;
                    end
                end
            end
        end
    end

    -- In einem Gebiet ---------------------------------------------

    -- Prüfe Kategorien
    for k, v in pairs(BundleConstructionControl.Global.Data.AreaBlockCategories) do
        if v then
            for key, val in pairs(v) do
                if Logic.IsEntityTypeInCategory(_Type, val[1]) == 1 then
                    if GetDistance(k, {X= _x, Y= _y}) < val[2] then
                        return false;
                    end
                end
            end
        end
    end

    -- Prüfe Typen
    for k, v in pairs(BundleConstructionControl.Global.Data.AreaBlockEntities) do
        if v then
            for key, val in pairs(v) do
                if _Type == val[1] then
                    if GetDistance(k, {X= _x, Y= _y}) < val[2] then
                        return false;
                    end
                end
            end
        end
    end

    return true;
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Private
-- @local
--
function BundleConstructionControl.Local:Install()
    Core:AppendFunction(
        "GameCallback_GUI_DeleteEntityStateBuilding",
        BundleConstructionControl.Local.DeleteEntityStateBuilding
    );
end

---
-- Verhindert den Abriss von Entities.
--
-- @param _BuildingID EntityID des Gebäudes
-- @within Private
-- @local
--
function BundleConstructionControl.Local.DeleteEntityStateBuilding(_BuildingID)
    local eType = Logic.GetEntityType(_BuildingID);
    local eName = Logic.GetEntityName(_BuildingID);
    local tID   = GetTerritoryUnderEntity(_BuildingID);

    if Logic.IsConstructionComplete(_BuildingID) == 1 then
        -- Prüfe auf Namen
        if Inside(eName, BundleConstructionControl.Local.Data.Entities) then
            GUI.CancelBuildingKnockDown(_BuildingID);
            return;
        end

        -- Prüfe auf Typen
        if Inside(eType, BundleConstructionControl.Local.Data.EntityTypes) then
            GUI.CancelBuildingKnockDown(_BuildingID);
            return;
        end

        -- Prüfe auf Territorien
        if Inside(tID, BundleConstructionControl.Local.Data.OnTerritory) then
            GUI.CancelBuildingKnockDown(_BuildingID);
            return;
        end

        -- Prüfe auf Category
        for k,v in pairs(BundleConstructionControl.Local.Data.EntityCategories) do
            if Logic.IsEntityInCategory(_BuildingID, v) == 1 then
                GUI.CancelBuildingKnockDown(_BuildingID);
                return;
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleConstructionControl");
