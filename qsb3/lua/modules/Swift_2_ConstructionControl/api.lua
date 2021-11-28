--[[
Swift_2_ConstructionControl/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Mit diesem Bundle kann der Bau von Gebäudetypen oder Gebäudekategorien
-- unterbunden werden. Verbote können für bestimmte Bereiche (kreisförmige
-- Gebiete um ein Zentrum) oder ganze Territorien vereinbart werden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_0_Core.api.html">(0) Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Untersagt den Bau des Typs im Territorium.
--
-- @param[type=number] _PlayerID   ID des Spielers
-- @param[type=number] _Type      Entity Type
-- @param[type=number] _Territory Territorium
-- @within Anwenderfunktionen
--
-- @usage API.BanTypeAtTerritory(1, Entities.B_Bakery, 2);
--
function API.BanTypeAtTerritory(_PlayerID, _Type, _Territory)
    if GUI then
        return;
    end
    if not ModuleConstructionControl.Global.TerritoryBlockEntities[_PlayerID][_Type] then
        ModuleConstructionControl.Global.TerritoryBlockEntities[_PlayerID][_Type] = {};
    end
    if table.contains(ModuleConstructionControl.Global.TerritoryBlockEntities[_PlayerID][_Type], _Territory) then
        return;
    end
    table.insert(ModuleConstructionControl.Global.TerritoryBlockEntities[_PlayerID][_Type], _Territory);
end

---
-- Untersagt den Bau der Kategorie im Territorium.
--
-- @param[type=number] _PlayerID       ID des Spielers
-- @param[type=number] _EntityCategory Entitykategorie
-- @param[type=number] _Territory      Territorium
-- @within Anwenderfunktionen
--
-- @usage API.BanCategoryAtTerritory(EntityCategories.AttackableBuilding, 2);
--
function API.BanCategoryAtTerritory(_PlayerID, _EntityCategory, _Territory)
    if GUI then
        return;
    end
    if not ModuleConstructionControl.Global.TerritoryBlockCategories[_PlayerID][_EntityCategory] then
        ModuleConstructionControl.Global.TerritoryBlockCategories[_PlayerID][_EntityCategory] = {};
    end
    if table.contains(ModuleConstructionControl.Global.TerritoryBlockCategories[_PlayerID][_EntityCategory], _Territory) then
        return;
    end
    table.insert(ModuleConstructionControl.Global.TerritoryBlockCategories[_PlayerID][_EntityCategory], _Territory);
end

---
-- Untersagt den Bau des Typs im Gebiet.
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Type      Entity Type
-- @param[type=number] _Center    Gebietszentrum
-- @param[type=number] _Area      Gebietsgröße
-- @within Anwenderfunktionen
--
-- @usage API.BanTypeInArea(1, Entities.B_Bakery, "groundZero", 4000);
--
function API.BanTypeInArea(_PlayerID, _Type, _Center, _Area)
    if GUI then
        return;
    end
    if not ModuleConstructionControl.Global.AreaBlockEntities[_PlayerID][_Type] then
        ModuleConstructionControl.Global.AreaBlockEntities[_PlayerID][_Type] = {};
    end
    for k, v in pairs(ModuleConstructionControl.Global.AreaBlockEntities[_PlayerID][_Type]) do
        if v[1] == _Center then
            return;
        end
    end
    table.insert(ModuleConstructionControl.Global.AreaBlockEntities[_PlayerID][_Type], {_Center, _Area});
end

---
-- Untersagt den Bau der Kategorie im Gebiet.
--
-- @param[type=number] _PlayerID       ID des Spielers
-- @param[type=number] _EntityCategory Entitykategorie
-- @param[type=number] _Center         Gebietszentrum
-- @param[type=number] _Area           Gebietsgröße
-- @within Anwenderfunktionen
--
-- @usage API.BanTypeInArea(1, EntityCategories.CityBuilding, "groundZero", 4000);
--
function API.BanCategoryInArea(_PlayerID, _EntityCategory, _Center, _Area)
    if GUI then
        return;
    end
    if not ModuleConstructionControl.Global.AreaBlockCategories[_PlayerID][_EntityCategory] then
        ModuleConstructionControl.Global.AreaBlockCategories[_PlayerID][_EntityCategory] = {};
    end
    for k, v in pairs(ModuleConstructionControl.Global.AreaBlockCategories[_PlayerID][_EntityCategory]) do
        if v[1] == _Center then
            return;
        end
    end
    table.insert(ModuleConstructionControl.Global.AreaBlockCategories[_PlayerID][_EntityCategory], {_Center, _Area});
end

---
-- Gibt einen Typ zum Bau im Territorium wieder frei.
--
-- @param[type=number] _PlayerID   ID des Spielers
-- @param[type=number] _Type      Entity Type
-- @param[type=number] _Territory Territorium
-- @within Anwenderfunktionen
--
-- @usage API.UnbanTypeAtTerritory(1, Entities.B_Bakery, 1);
--
function API.UnbanTypeAtTerritory(_PlayerID, _Type, _Territory)
    if GUI then
        return;
    end
    if not ModuleConstructionControl.Global.TerritoryBlockEntities[_PlayerID][_Type] then
        return;
    end
    for i= #ModuleConstructionControl.Global.TerritoryBlockEntities[_PlayerID][_Type], 1, -1 do
        if ModuleConstructionControl.Global.TerritoryBlockEntities[_PlayerID][_Type][i] == _Territory then
            table.remove(ModuleConstructionControl.Global.TerritoryBlockEntities[_PlayerID][_Type], i);
        end
    end
end

---
-- Gibt eine Kategorie zum Bau im Territorium wieder frei.
--
-- @param[type=number] _PlayerID       ID des Spielers
-- @param[type=number] _EntityCategory Entitykategorie
-- @param[type=number] _Territory      Territorium
-- @within Anwenderfunktionen
--
-- @usage API.UnbanCategoryAtTerritory(EntityCategories.AttackableBuilding, 1);
--
function API.UnbanCategoryAtTerritory(_PlayerID, _EntityCategory, _Territory)
    if GUI then
        return;
    end
    if not ModuleConstructionControl.Global.TerritoryBlockCategories[_PlayerID][_EntityCategory] then
        return;
    end
    for i= #ModuleConstructionControl.Global.TerritoryBlockCategories[_PlayerID][_EntityCategory], 1, -1 do
        if ModuleConstructionControl.Global.TerritoryBlockCategories[_PlayerID][_EntityCategory][i] == _Territory then
            table.remove(ModuleConstructionControl.Global.TerritoryBlockCategories[_PlayerID][_EntityCategory], i);
        end
    end
end

---
-- Gibt einen Typ zum Bau im Gebiet wieder frei.
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Type      Entity Type
-- @param[type=number] _Center    Gebietszentrum
-- @within Anwenderfunktionen
--
-- @usage API.UnbanTypeInArea(Entities.B_Bakery, "groundZero");
--
function API.UnbanTypeInArea(_PlayerID, _Type, _Center)
    if GUI then
        return;
    end
    if not ModuleConstructionControl.Global.AreaBlockEntities[_PlayerID][_Type] then
        return;
    end
    for i= #ModuleConstructionControl.Global.AreaBlockEntities[_PlayerID][_Type], 1, -1 do
        if ModuleConstructionControl.Global.AreaBlockEntities[_PlayerID][_Type][i][1] == _Center then
            table.remove(ModuleConstructionControl.Global.AreaBlockEntities[_PlayerID][_Type], i);
        end
    end
end

---
-- Gibt eine Kategorie zum Bau im Gebiet wieder frei.
--
-- @param[type=number] _PlayerID       ID des Spielers
-- @param[type=number] _EntityCategory Entitykategorie
-- @param[type=number] _Center         Gebietszentrum
-- @within Anwenderfunktionen
--
-- @usage API.UnbanCategoryInArea(EntityCategories.CityBuilding, "groundZero");
--
function API.UnbanCategoryInArea(_PlayerID, _EntityCategory, _Center)
    if GUI then
        return;
    end
    if not ModuleConstructionControl.Global.AreaBlockCategories[_PlayerID][_EntityCategory] then
        return;
    end
    for i= #ModuleConstructionControl.Global.AreaBlockCategories[_PlayerID][_EntityCategory], 1, -1 do
        if ModuleConstructionControl.Global.AreaBlockCategories[_PlayerID][_EntityCategory][i][1] == _Center then
            table.remove(ModuleConstructionControl.Global.AreaBlockCategories[_PlayerID][_EntityCategory], i);
        end
    end
end

