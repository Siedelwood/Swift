-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleConstructionControl                                    # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es Gebiete oder Territorien auf der Map zu definieren, auf der ein
-- Gebäude nicht gebaut oder nicht abgerissen werden darf.
--
-- Das wichtigste Auf einen Blick:
-- <ul>
-- <li>
-- Den Abriss für bestimmte Entities steuern.<br>
-- <a href="#API.ProtectCategory">Entities beschützen</a>,
-- <a href="#API.UnprotectCategory">Schutz aufheben</a>
-- </li>
-- <li>
-- Den Bau von Gebäuden an bestimmten Orten steuern.<br>
-- <a href="#API.BanCategoryInArea">Bau verbieten</a>,
-- <a href="#API.UnbanCategoryInArea">Bau erlauben</a>
-- </li>
-- </ul>
--
-- @within Modulbeschreibung
-- @set sort=false
--
BundleConstructionControl = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Fügt ein Entity hinzu, dass nicht abgerissen werden darf.
--
-- @param _entity [string] Nicht abreißbares Entity
-- @within Anwenderfunktionen
--
function API.ProtectEntity(_entity)
    if not GUI then
        API.Bridge([[
            API.ProtectEntity("]].._entity..[[")
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
-- @param _entity [number] Nicht abreißbarer Typ
-- @within Anwenderfunktionen
--
function API.ProtectEntityType(_entity)
    if not GUI then
        API.Bridge([[
            API.ProtectEntityType(]].._entity..[[)
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
-- @param _entity [number] Nicht abreißbare Kategorie
-- @within Anwenderfunktionen
--
function API.ProtectCategory(_entity)
    if not GUI then
        API.Bridge([[
            API.ProtectCategory(]].._entity..[[)
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
-- @param _entity [number] Geschütztes Territorium
-- @within Anwenderfunktionen
--
function API.ProtectTerritory(_entity)
    if not GUI then
        API.Bridge([[
            API.ProtectTerritory(]].._entity..[[)
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
-- @param _entry [string] Nicht abreißbares Entity
-- @within Anwenderfunktionen
--
function API.UnprotectEntity(_entry)
    if not GUI then
        API.Bridge([[
            API.UnprotectEntity("]].._entry..[[")
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
-- @param _entry [number] Nicht abreißbarer Typ
-- @within Anwenderfunktionen
--
function API.UnprotectEntityType(_entry)
    if not GUI then
        API.Bridge([[
            API.UnprotectEntityType(]].._entry..[[)
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
-- @param _entry [number] Nicht abreißbare Kategorie
-- @within Anwenderfunktionen
--
function API.UnprotectCategory(_entry)
    if not GUI then
        API.Bridge([[
            API.UnprotectCategory(]].._entry..[[)
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
-- @param _entry [number] Geschütztes Territorium
-- @within Anwenderfunktionen
--
function API.UnprotectTerritory(_entry)
    if not GUI then
        API.Bridge([[
            API.UnprotectTerritory(]].._entry..[[)
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
-- @param _type      [number] Entitytyp
-- @param _territory [number] Territorium
-- @within Anwenderfunktionen
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
-- @param _eCat      [number] Entitykategorie
-- @param _territory [number] Territorium
-- @within Anwenderfunktionen
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
-- @param _type   [number] Entitytyp
-- @param _center [string] Gebietszentrum
-- @param _area   [number] Gebietsgröße
-- @within Anwenderfunktionen
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
-- @param _eCat   [number] Entitytyp
-- @param _center [string] Gebietszentrum
-- @param _area   [number] Gebietsgröße
-- @within Anwenderfunktionen
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
-- @param _type      [number] Entitytyp
-- @param _territory [number] Territorium
-- @within Anwenderfunktionen
--
function API.UnbanTypeAtTerritory(_type, _territory)
    if GUI then
        local Territory = (type(_center) == "string" and "'" .._territory.. "'") or _territory;
        GUI.SendScriptCommand("API.UnbanTypeAtTerritory(" .._type.. ", " ..Territory.. ")");
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
-- @param _eCat      [number] Entitykategorie
-- @param _territory [number] Territorium
-- @within Anwenderfunktionen
--
function API.UnbanCategoryAtTerritory(_eCat, _territory)
    if GUI then
        local Territory = (type(_center) == "string" and "'" .._territory.. "'") or _territory;
        GUI.SendScriptCommand("API.UnbanTypeAtTerritory(" .._eCat.. ", " ..Territory.. ")");
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
-- @param _type   [number] Entitytyp
-- @param _center [string] Gebiet
-- @within Anwenderfunktionen
--
function API.UnbanTypeInArea (_type, _center)
    if GUI then
        local Center = (type(_center) == "string" and "'" .._center.. "'") or _center;
        GUI.SendScriptCommand("API.UnbanTypeInArea(" .._eCat.. ", " ..Center.. ")");
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
-- @param _eCat   [number] Entitykategorie
-- @param _center [string] Gebiet
-- @within Anwenderfunktionen
--
function API.UnbanCategoryInArea(_eCat, _center)
    if GUI then
        local Center = (type(_center) == "string" and "'" .._center.. "'") or _center;
        GUI.SendScriptCommand("API.UnbanCategoryInArea(" .._type.. ", " ..Center.. ")");
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
-- @within Internal
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
-- @within Internal
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
-- @within Internal
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
-- @within Internal
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

