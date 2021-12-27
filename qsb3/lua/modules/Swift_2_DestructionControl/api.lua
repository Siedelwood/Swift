--[[
Swift_2_DestructionControl/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht es Gebäude vor dem Abriss zu schützen.
--
-- Es können einzelne Gebäude, Typen oder Kategorien von Gebäuden vor
-- dem Abriss beschützt werden. Ebenso kann jeglicher Abriss von Gebäuden auf
-- einem Territrium komplett unterbunden werden.
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
-- Fügt ein Entity hinzu, dass nicht abgerissen werden darf.
--
-- @param[type=number] _PlayerID   ID des Besitzers
-- @param[type=string] _ScriptName Nicht abreißbares Entity
-- @within Anwenderfunktionen
--
-- @usage API.ProtectEntity(1, "bakery");
--
function API.ProtectEntity(_PlayerID, _ScriptName)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.ProtectEntity(%d, "%s")]],
            _PlayerID,
            _ScriptName
        ));
        return;
    end
    if table.contains(ModuleDestructionControl.Local.NamedEntities[_PlayerID], _ScriptName) then
        return;
    end
    table.insert(ModuleDestructionControl.Local.NamedEntities[_PlayerID], _ScriptName);
end

---
-- Fügt einen Entitytyp hinzu, der nicht abgerissen werden darf.
--
-- @param[type=number] _PlayerID ID des Besitzers
-- @param[type=number] _Type     Nicht abreißbarer Typ
-- @within Anwenderfunktionen
--
-- @usage API.ProtectEntityType(1, Entities.B_Bakery);
--
function API.ProtectEntityType(_PlayerID, _Type)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.ProtectEntityType(%d, %d)]],
            _PlayerID,
            _Type
        ));
        return;
    end
    if table.contains(ModuleDestructionControl.Local.EntityTypes[_PlayerID], _Type) then
        return;
    end
    table.insert(ModuleDestructionControl.Local.EntityTypes[_PlayerID], _Type);
end

---
-- Fügt eine Kategorie hinzu, die nicht abgerissen werden darf.
--
-- @param[type=number] _PlayerID       ID des Besitzers
-- @param[type=number] _EntityCategory Nicht abreißbare Kategorie
-- @within Anwenderfunktionen
--
-- @usage API.ProtectCategory(1, EntityCategories.CityBuilding);
--
function API.ProtectCategory(_PlayerID, _EntityCategory)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.ProtectEntityType(%d, %d)]],
            _PlayerID,
            _EntityCategory
        ));
        return;
    end
    if table.contains(ModuleDestructionControl.Local.EntityCategories[_PlayerID], _EntityCategory) then
        return;
    end
    table.insert(ModuleDestructionControl.Local.EntityCategories[_PlayerID], _EntityCategory);
end

---
-- Fügt ein Gebiet hinzu, in dem nichts abgerissen werden kann.
--
-- @param[type=number] _PlayerID ID des Besitzers
-- @param[type=number] _Center   Gebietszentrum
-- @param[type=number] _Area     Gebietsgröße
-- @within Anwenderfunktionen
--
-- @usage API.ProtectInArea(1, "GroundZero", 3000);
--
function API.ProtectInArea(_PlayerID, _Center, _Area)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.ProtectInArea(%d, "%s", %d)]],
            _PlayerID,
            _Center,
            _Area
        ));
        return;
    end
    if table.contains(ModuleDestructionControl.Local.InArea[_PlayerID], {_Center, _Area}) then
        return;
    end
    table.insert(ModuleDestructionControl.Local.InArea[_PlayerID], {_Center, _Area});
end

---
-- Fügt ein Territory hinzu, auf dem nichts abgerissen werden kann.
--
-- @param[type=number] _PlayerID  ID des Besitzers
-- @param[type=number] _Territory Territorium
-- @within Anwenderfunktionen
--
-- @usage API.ProtectOnTerritory(1, 7);
--
function API.ProtectOnTerritory(_PlayerID, _Territory)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.ProtectEntityType(%d, %d)]],
            _PlayerID,
            _Territory
        ));
        return;
    end
    if table.contains(ModuleDestructionControl.Local.OnTerritory[_PlayerID], _Territory) then
        return;
    end
    table.insert(ModuleDestructionControl.Local.OnTerritory[_PlayerID], _Territory);
end

---
-- Fügt ein Entity hinzu, dass nicht abgerissen werden darf.
--
-- @param[type=number] _PlayerID   ID des Besitzers
-- @param[type=string] _ScriptName Nicht abreißbares Entity
-- @within Anwenderfunktionen
--
-- @usage API.UnprotectEntity(1, "bakery");
--
function API.UnprotectEntity(_PlayerID, _ScriptName)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.UnprotectEntity(%d, "%s")]],
            _PlayerID,
            _ScriptName
        ));
        return;
    end
    for i= #ModuleDestructionControl.Local.NamedEntities[_PlayerID], 1, -1 do
        if ModuleDestructionControl.Local.NamedEntities[_PlayerID][i] == _ScriptName then
            table.remove(ModuleDestructionControl.Local.NamedEntities[_PlayerID], i);
        end
    end
end

---
-- Fügt einen Entitytyp hinzu, der nicht abgerissen werden darf.
--
-- @param[type=number] _PlayerID ID des Besitzers
-- @param[type=number] _Type     Nicht abreißbarer Typ
-- @within Anwenderfunktionen
--
-- @usage API.UnprotectEntityType(1, Entities.B_Bakery);
--
function API.UnprotectEntityType(_PlayerID, _Type)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.UnprotectEntityType(%d, %d)]],
            _PlayerID,
            _Type
        ));
        return;
    end
    for i= #ModuleDestructionControl.Local.EntityTypes[_PlayerID], 1, -1 do
        if ModuleDestructionControl.Local.EntityTypes[_PlayerID][i] == _Type then
            table.remove(ModuleDestructionControl.Local.EntityTypes[_PlayerID], i);
        end
    end
end

---
-- Fügt eine Kategorie hinzu, die nicht abgerissen werden darf.
--
-- @param[type=number] _PlayerID       ID des Besitzers
-- @param[type=number] _EntityCategory Nicht abreißbare Kategorie
-- @within Anwenderfunktionen
--
-- @usage API.UnprotectCategory(1, EntityCategories.CityBuilding);
--
function API.UnprotectCategory(_PlayerID, _EntityCategory)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.UnprotectCategory(%d, %d)]],
            _PlayerID,
            _EntityCategory
        ));
        return;
    end
    for i= #ModuleDestructionControl.Local.EntityCategories[_PlayerID], 1, -1 do
        if ModuleDestructionControl.Local.EntityCategories[_PlayerID][i] == _EntityCategory then
            table.remove(ModuleDestructionControl.Local.EntityCategories[_PlayerID], i);
        end
    end
end

---
-- Fügt ein Gebiet hinzu, in dem nichts abgerissen werden kann.
--
-- @param[type=number] _PlayerID ID des Besitzers
-- @param[type=number] _Center   Gebietszentrum
-- @within Anwenderfunktionen
--
-- @usage API.UnprotectInArea(1, "GroundZero");
--
function API.UnprotectInArea(_PlayerID, _Center)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.UnprotectInArea(%d, "%s")]],
            _PlayerID,
            _Center
        ));
        return;
    end
    for i= #ModuleDestructionControl.Local.InArea[_PlayerID], 1, -1 do
        if ModuleDestructionControl.Local.InArea[_PlayerID][i][1] == _Center then
            table.remove(ModuleDestructionControl.Local.InArea[_PlayerID], i);
        end
    end
end

---
-- Fügt ein Territory hinzu, auf dem nichts abgerissen werden kann.
--
-- @param[type=number] _PlayerID  ID des Besitzers
-- @param[type=number] _Territory Territorium
-- @within Anwenderfunktionen
--
-- @usage API.UnprotectOnTerritory(1, 7);
--
function API.UnprotectOnTerritory(_PlayerID, _Territory)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.UnprotectOnTerritory(%d, %d)]],
            _PlayerID,
            _Territory
        ));
        return;
    end
    for i= #ModuleDestructionControl.Local.OnTerritory[_PlayerID], 1, -1 do
        if ModuleDestructionControl.Local.OnTerritory[_PlayerID][i] == _Territory then
            table.remove(ModuleDestructionControl.Local.OnTerritory[_PlayerID], i);
        end
    end
end

