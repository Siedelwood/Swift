--[[
Swift_2_InteractionCore/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Es werden Schatztruhen mit zufälligem Inhalt erzeugt. Diese Truhen werden
-- aktiviert und der Inhalt wird in einem Karren abtransportiert.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_2_Interaction.api.html">(1) Interaction</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge an Waren
-- des angegebenen Typs.
--
-- Die Menge der Ware ist dabei zufällig und liegt zwischen dem Minimalwert
-- und dem Maximalwert. Optional kann eine Funktion angegeben werden, die
-- ausgeführt wird, wenn die Truhe geöffnet wird. Diese Funktion verhält sich
-- wie das Callback eines interaktiven Objektes.
--
-- @param[type=string]   _Name     Name der zu ersetzenden Script Entity
-- @param[type=number]   _Good     Warentyp
-- @param[type=number]   _Min      Mindestmenge
-- @param[type=number]   _Max      (Optional) Maximalmenge
-- @param[type=function] _Callback (Optional) Callback-Funktion
-- @within Anwenderfunktionen
--
-- @usage
-- -- Normale Truhe
-- API.CreateRandomChest("chest", Goods.G_Gems, 100, 300);
-- -- Truhe mit Aktion
-- API.CreateRandomChest("chest", Goods.G_Gems, 100, 300, OnChestOpened);
--
function API.CreateRandomChest(_Name, _Good, _Min, _Max, _Callback)
    if GUI then
        return;
    end
    if not IsExisting(_Name) then
        error("API.CreateRandomChest: _Name (" ..tostring(_Name).. ") does not exist!");
        return;
    end
    if GetNameOfKeyInTable(Goods, _Good) == nil then
        error("API.CreateRandomChest: _Good (" ..tostring(_Good).. ") is wrong!");
        return;
    end
    if type(_Min) ~= "number" or _Min < 1 then
        error("API.CreateRandomChest: _Min (" ..tostring(_Min).. ") is wrong!");
        return;
    end

    if type(_Max) ~= "number" then
        if not _Callback and type(_Max) == "function" then
            _Callback = _Max;
        end
        _Max = _Min;
    else
        if type(_Max) ~= "number" or _Max < 1 then
            error("API.CreateRandomChest: _Max (" ..tostring(_Max).. ") is wrong!");
            return;
        end
        if _Max < _Min then
            error("API.CreateRandomChest: _Max (" ..tostring(_Max).. ") must be greather then _Min (" ..tostring(_Min).. ")!");
            return;
        end
    end
    ModuleInteractiveChests.Global:CreateRandomChest(_Name, _Good, _Min, _Max, _Callback, false);
end
CreateRandomChest = API.CreateRandomChest;

---
-- Erstellt ein beliebiges IO mit einer zufälligen Menge an Waren
-- des angegebenen Typs.
--
-- Die Menge der Ware ist dabei zufällig und liegt zwischen dem Minimalwert
-- und dem Maximalwert. Optional kann eine Funktion angegeben werden, die
-- ausgeführt wird, wenn der Schatz gefunden wird. Diese Funktion verhält sich
-- wie das Callback eines interaktiven Objektes.
--
-- @param[type=string]   _Name     Name des Script Entity
-- @param[type=number]   _Good     Warentyp
-- @param[type=number]   _Min      Mindestmenge
-- @param[type=number]   _Max      (Optional) Maximalmenge
-- @param[type=function] _Callback (Optional) Callback-Funktion
-- @within Anwenderfunktionen
--
-- @usage
-- -- Normale Ruine
-- API.CreateRandomTreasure("well1", Goods.G_Gems, 100, 300);
-- -- Ruine mit Aktion
-- API.CreateRandomTreasure("well1", Goods.G_Gems, 100, 300, OnTreasureDiscovered);
--
function API.CreateRandomTreasure(_Name, _Good, _Min, _Max, _Callback)
    if GUI then
        return;
    end
    if not IsExisting(_Name) then
        error("API.CreateRandomTreasure: _Name (" ..tostring(_Name).. ") does not exist!");
        return;
    end
    if GetNameOfKeyInTable(Goods, _Good) == nil then
        error("API.CreateRandomTreasure: _Good (" ..tostring(_Good).. ") is wrong!");
        return;
    end
    if type(_Min) ~= "number" or _Min < 1 then
        error("API.CreateRandomTreasure: _Min (" ..tostring(_Min).. ") is wrong!");
        return;
    end

    if type(_Max) ~= "number" then
        if not _Callback and type(_Max) == "function" then
            _Callback = _Max;
        end
        _Max = _Min;
    else
        if type(_Max) ~= "number" or _Max < 1 then
            error("API.CreateRandomTreasure: _Max (" ..tostring(_Max).. ") is wrong!");
            return;
        end
        if _Max < _Min then
            error("API.CreateRandomTreasure: _Max (" ..tostring(_Max).. ") must be greather then _Min (" ..tostring(_Min).. ")!");
            return;
        end
    end
    ModuleInteractiveChests.Global:CreateRandomChest(_Name, _Good, _Min, _Max, _Callback, false, true);
end
CreateRandomTreasure = API.CreateRandomTreasure;

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge Gold.
--
-- @param[type=string] _Name Name der zu ersetzenden Script Entity
-- @within Anwenderfunktionen
--
-- @usage
-- API.CreateRandomGoldChest("chest")
--
function API.CreateRandomGoldChest(_Name)
    if GUI then
        return;
    end
    if not IsExisting(_Name) then
        error("API.CreateRandomGoldChest: _Name (" ..tostring(_Name).. ") does not exist!");
        return;
    end
    ModuleInteractiveChests.Global:CreateRandomGoldChest(_Name);
end
CreateRandomGoldChest = API.CreateRandomGoldChest;

---
-- Erstellt eine Schatztruhe mit einer zufälligen Art und Menge
-- an Gütern.
--
-- Güter können seien: Eisen, Fisch, Fleisch, Getreide, Holz,
-- Honig, Kräuter, Milch, Stein, Wolle.
--
-- @param[type=string] _Name Name der zu ersetzenden Script Entity
-- @within Anwenderfunktionen
--
-- @usage
-- API.CreateRandomResourceChest("chest")
--
function API.CreateRandomResourceChest(_Name)
    if GUI then
        return;
    end
    if not IsExisting(_Name) then
        error("API.CreateRandomResourceChest: _Name (" ..tostring(_Name).. ") does not exist!");
        return;
    end
    ModuleInteractiveChests.Global:CreateRandomResourceChest(_Name);
end
CreateRandomResourceChest = API.CreateRandomResourceChest;

---
-- Erstellt eine Schatztruhe mit einer zufälligen Art und Menge
-- an Luxusgütern.
--
-- Luxusgüter können seien: Salz, Farben (, Edelsteine, Musikinstrumente
-- Weihrauch)
--
-- @param[type=string] _Name Name der zu ersetzenden Script Entity
-- @within Anwenderfunktionen
--
-- @usage
-- API.CreateRandomLuxuryChest("chest")
--
function API.CreateRandomLuxuryChest(_Name)
    if GUI then
        return;
    end
    if not IsExisting(_Name) then
        error("API.CreateRandomLuxuryChest: _Name (" ..tostring(_Name).. ") does not exist!");
        return;
    end
    ModuleInteractiveChests.Global:CreateRandomLuxuryChest(_Name);
end
CreateRandomLuxuryChest = API.CreateRandomLuxuryChest;

