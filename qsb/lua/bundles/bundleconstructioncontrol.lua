-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleConstructionControl                                    # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Bundle kann der Bau von Gebäudetypen oder Gebäudekategorien
-- unterbunden werden. Verbote können für bestimmte Bereiche (kreisförmige
-- Gebiete um ein Zentrum) oder ganze Territorien vereinbart werden.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleConstructionControl = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Untersagt den Bau des Typs im Territorium.
--
-- @param[type=number] _type      Entitytyp
-- @param[type=number] _territory Territorium
-- @within Anwenderfunktionen
--
-- @usage API.BanTypeAtTerritory(Entities.B_Bakery, 1);
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
-- @param[type=number] _eCat      Entitykategorie
-- @param[type=number] _territory Territorium
-- @within Anwenderfunktionen
--
-- @usage API.BanCategoryAtTerritory(EntityCategories.AttackableBuilding, 2);
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
-- @param[type=number] _type   Entitytyp
-- @param[type=string] _center Gebietszentrum
-- @param[type=number] _area   Gebietsgröße
-- @within Anwenderfunktionen
--
-- @usage API.BanTypeInArea(Entities.B_Bakery, "groundZero", 4000);
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
-- @param[type=number] _eCat   Entitytyp
-- @param[type=string] _center Gebietszentrum
-- @param[type=number] _area   Gebietsgröße
-- @within Anwenderfunktionen
--
-- @usage API.BanTypeInArea(EntityCategories.CityBuilding, "groundZero", 4000);
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
-- @param[type=number] _type      Entitytyp
-- @param[type=number] _territory Territorium
-- @within Anwenderfunktionen
--
-- @usage API.UnbanTypeAtTerritory(Entities.B_Bakery, 1);
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
    for i= #BundleConstructionControl.Global.Data.TerritoryBlockEntities[_type], 1, -1 do
        if BundleConstructionControl.Global.Data.TerritoryBlockEntities[_type][i] == _territory then
            table.remove(BundleConstructionControl.Global.Data.TerritoryBlockEntities[_type], i);
            break;
        end
    end
end

---
-- Gibt eine Kategorie zum Bau im Territorium wieder frei.
--
-- @param[type=number] _eCat      Entitykategorie
-- @param[type=number] _territory Territorium
-- @within Anwenderfunktionen
--
-- @usage API.UnbanCategoryAtTerritory(EntityCategories.AttackableBuilding, 1);
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
    for i= #BundleConstructionControl.Global.Data.TerritoryBlockCategories[_eCat], 1, -1 do
        if BundleConstructionControl.Global.Data.TerritoryBlockCategories[_eCat][i] == _territory then
            table.remove(BundleConstructionControl.Global.Data.TerritoryBlockCategories[_eCat], i);
            break;
        end
    end
end

---
-- Gibt einen Typ zum Bau im Gebiet wieder frei.
--
-- @param[type=number] _type   Entitytyp
-- @param[type=string] _center Gebiet
-- @within Anwenderfunktionen
--
-- @usage API.UnbanTypeInArea(Entities.B_Bakery, "groundZero");
--
function API.UnbanTypeInArea(_type, _center)
    if GUI then
        local Center = (type(_center) == "string" and "'" .._center.. "'") or _center;
        GUI.SendScriptCommand("API.UnbanTypeInArea(" .._eCat.. ", " ..Center.. ")");
        return;
    end

    if not BundleConstructionControl.Global.Data.AreaBlockEntities[_center] then
        return;
    end
    for i= #BundleConstructionControl.Global.Data.AreaBlockEntities[_center], 1, -1 do
        if BundleConstructionControl.Global.Data.AreaBlockEntities[_center][i][1] == _type then
            table.remove(BundleConstructionControl.Global.Data.AreaBlockEntities[_center], i);
            break;
        end
    end
end

---
-- Gibt eine Kategorie zum Bau im Gebiet wieder frei.
--
-- @param[type=number] _eCat   Entitykategorie
-- @param[type=string] _center Gebiet
-- @within Anwenderfunktionen
--
-- @usage API.UnbanCategoryInArea(EntityCategories.CityBuilding, "groundZero");
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
    for i= #BundleConstructionControl.Global.Data.AreaBlockCategories[_center], 1, -1 do
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
-- @param[type=number] _PlayerID Spieler
-- @param[type=number] _Type     Gebäudetyp
-- @param[type=number] _x        X-Position
-- @param[type=number] _y        Y-Position
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

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleConstructionControl");

