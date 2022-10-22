--[[
Swift_2_LifestockBreeding/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht die Aufzucht von Nutztieren wie Schafe und Kühe durch den Spieler.
-- 
-- Kosten für die Aufzucht oder die benötigte Menge an Tieren um mit der
-- Zucht zu beginnen, sind frei konfigurierbar.
--
-- Zusätzlich können die Tiere kleiner gespawnt werden und wachsen dann mit
-- der Zeit automatisch. Diese Funktionalität kann abgeschaltet werden.
-- 
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- <li><a href="Swift_1_InterfaceCore.api.html">(1) Interface Core</a></li>
-- <li><a href="Swift_1_ScriptingValueCore.api.html">(1) Scripting Value Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field AnimalBreed Ein Nutztier wurde erzeugt. (Parameter: EntityID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Erlaube oder verbiete dem Spieler Kühe zu züchten.
--
-- @param[type=boolean] _Flag Kuhzucht aktiv/inaktiv
-- @within Anwenderfunktionen
--
-- @usage
-- -- Es können keine Kühe gezüchtet werden
-- API.UseBreedCattle(false);
--
function API.ActivateCattleBreeding(_Flag)
    if GUI then
        return;
    end

    ModuleLifestockBreeding.Global.Sheep.Breeding = _Flag == true;
    Logic.ExecuteInLuaLocalState("ModuleLifestockBreeding.Local.Sheep.Breeding = " ..tostring(_Flag == true));
    if _Flag ~= true then
        local Price = MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Sheep]
        MerchantSystem.BasePrices[Goods.G_Sheep] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Sheep] = " ..Price);
    else
        local Price = ModuleLifestockBreeding.Global.Sheep.MoneyCost;
        MerchantSystem.BasePrices[Goods.G_Sheep] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Sheep] = " ..Price);
    end
end

---
-- Erlaube oder verbiete dem Spieler Schafe zu züchten.
--
-- @param[type=boolean] _Flag Schafzucht aktiv/inaktiv
-- @within Anwenderfunktionen
--
-- @usage
-- -- Schafsaufzucht ist erlaubt
-- API.UseBreedSheeps(true);
--
function API.ActivateSheepBreeding(_Flag)
    if GUI then
        return;
    end

    ModuleLifestockBreeding.Global.Cattle.Breeding = _Flag == true;
    Logic.ExecuteInLuaLocalState("ModuleLifestockBreeding.Local.Cattle.Breeding = " ..tostring(_Flag == true));
    if _Flag ~= true then
        local Price = MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Cow];
        MerchantSystem.BasePrices[Goods.G_Cow] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Cow] = " ..Price);
    else
        local Price = ModuleLifestockBreeding.Global.Cattle.MoneyCost;
        MerchantSystem.BasePrices[Goods.G_Cow] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Cow] = " ..Price);
    end
end

---
-- Konfiguriert die Zucht von Kühen.
--
-- Mögliche Optionen:
-- <table>
-- <tr>
-- <td><b>Option</b></td>
-- <td><b>Datentyp</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>RequiredAmount</td>
-- <td>number</td>
-- <td>Mindestanzahl an Tieren, die sich im Gebiet befinden müssen.
-- (Default: 2)</td>
-- </tr>
-- <tr>
-- <td>QuantityBoost</td>
-- <td>number</td>
-- <td>Menge an Sekunden, die jedes Tier im Gebiet die Zuchtauer verkürzt.
-- (Default: 15)</td>
-- </tr>
-- <tr>
-- <td>AreaSize</td>
-- <td>number</td>
-- <td>Größe des Gebietes, in dem Tiere für die Zucht vorhanden sein müssen.
-- (Default: 3000)</td>
-- </tr>
-- <tr>
-- <td>UseCalves</td>
-- <td>boolean</td>
-- <td>Gezüchtete Tiere erscheinen zuerst als Kälber und wachsen. Dies ist rein
-- kosmetisch und hat keinen Einfluss auf die Produktion. (Default: true)</td>
-- </tr>
-- <tr>
-- <td>CalvesSize</td>
-- <td>number</td>
-- <td>Bestimmt die initiale Größe der Kälber. Werden Kälber nicht benutzt, wird
-- diese Option ignoriert. (Default: 0.4)</td>
-- </tr>
-- <tr>
-- <td>FeedingTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden zwischen den Fütterungsperioden. Am Ende
-- jeder Periode wird pro züchtendem Gatter 1 Getreide abgezogen, wenn das
-- Gebäude nicht pausiert ist. (Default: 45)</td>
-- </tr>
-- <tr>
-- <td>BreedingTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden, bis ein neues Tier erscheint. Wenn für
-- eine Fütterung kein Getreide da ist, wird der Zähler zur letzten Fütterung
-- zurückgesetzt. (Default: 240)</td>
-- </tr>
-- <tr>
-- <td>GrothTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden zwischen den Wachstumsschüben eines
-- Kalbs. Jeder Wachstumsschub ist +0.1 Gößenänderung. (Default: 45)</td>
-- </tr>
-- </table>
-- 
-- @param[type=table] _Data Konfiguration der Zucht
-- @within Anwenderfunktionen
--
-- @usage
-- API.ConfigureCattleBreeding{
--     -- Es werden keine Tiere benötigt
--     RequiredAmount = 0,
--     -- Mindestzeit sind 2 Minuten
--     BreedingTimer = 2*60
-- }
--
function API.ConfigureCattleBreeding(_Data)
    if _Data.CalvesSize then
        ModuleLifestockBreeding.Global.Cattle.CalvesSize = _Data.CalvesSize;
    end
    if _Data.RequiredAmount then
        ModuleLifestockBreeding.Global.Cattle.RequiredAmount = _Data.RequiredAmount;
    end
    if _Data.QuantityBoost then
        ModuleLifestockBreeding.Global.Cattle.QuantityBoost = _Data.QuantityBoost;
    end
    if _Data.AreaSize then
        ModuleLifestockBreeding.Global.Cattle.AreaSize = _Data.AreaSize;
    end
    if _Data.UseCalves then
        ModuleLifestockBreeding.Global.Cattle.UseCalves = _Data.UseCalves;
    end
    if _Data.FeedingTimer then
        ModuleLifestockBreeding.Global.Cattle.FeedingTimer = _Data.FeedingTimer;
    end
    if _Data.BreedingTimer then
        ModuleLifestockBreeding.Global.Cattle.BreedingTimer = _Data.BreedingTimer;
    end
    if _Data.GrothTimer then
        ModuleLifestockBreeding.Global.Cattle.GrothTimer = _Data.GrothTimer;
    end
end

function API.ConfigureSheepBreeding(_Data)
    if _Data.CalvesSize then
        ModuleLifestockBreeding.Global.Sheep.CalvesSize = _Data.CalvesSize;
    end
    if _Data.RequiredAmount then
        ModuleLifestockBreeding.Global.Sheep.RequiredAmount = _Data.RequiredAmount;
    end
    if _Data.QuantityBoost then
        ModuleLifestockBreeding.Global.Sheep.QuantityBoost = _Data.QuantityBoost;
    end
    if _Data.AreaSize then
        ModuleLifestockBreeding.Global.Sheep.AreaSize = _Data.AreaSize;
    end
    if _Data.UseCalves then
        ModuleLifestockBreeding.Global.Sheep.UseCalves = _Data.UseCalves;
    end
    if _Data.FeedingTimer then
        ModuleLifestockBreeding.Global.Sheep.FeedingTimer = _Data.FeedingTimer;
    end
    if _Data.BreedingTimer then
        ModuleLifestockBreeding.Global.Cattle.BreedingTimer = _Data.BreedingTimer;
    end
    if _Data.GrothTimer then
        ModuleLifestockBreeding.Global.Sheep.GrothTimer = _Data.GrothTimer;
    end
end



---
-- Erlaube oder verbiete dem Spieler Schafe zu züchten.
--
-- Wenn der Spieler keine Schafe züchten soll, kann ihm dieses Recht durch
-- diese Funktion genommen werden. Natürlich kann das Recht auf diesem Weg
-- auch wieder zurückgegeben werden.
--
-- @param[type=boolean] _Flag Schafzucht aktiv/inaktiv
-- @within Anwenderfunktionen
--
-- @usage
-- -- Schafsaufzucht ist erlaubt
-- API.UseBreedSheeps(true);
--
function API.UseBreedSheeps(_Flag)
    if GUI then
        return;
    end

    ModuleLifestockBreeding.Global.Sheep.Breeding = _Flag == true;
    Logic.ExecuteInLuaLocalState("ModuleLifestockBreeding.Local.Sheep.Breeding = " ..tostring(_Flag == true));
    if _Flag ~= true then
        local Price = MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Sheep]
        MerchantSystem.BasePrices[Goods.G_Sheep] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Sheep] = " ..Price);
    else
        local Price = ModuleLifestockBreeding.Global.Sheep.MoneyCost;
        MerchantSystem.BasePrices[Goods.G_Sheep] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Sheep] = " ..Price);
    end
end

---
-- Erlaube oder verbiete dem Spieler Kühe zu züchten.
--
-- Wenn der Spieler keine Kühe züchten soll, kann ihm dieses Recht durch
-- diese Funktion genommen werden. Natürlich kann das Recht auf diesem Weg
-- auch wieder zurückgegeben werden.
--
-- @param[type=boolean] _Flag Kuhzucht aktiv/inaktiv
-- @within Anwenderfunktionen
--
-- @usage
-- -- Es können keine Kühe gezüchtet werden
-- API.UseBreedCattle(false);
--
function API.UseBreedCattle(_Flag)
    if GUI then
        return;
    end

    ModuleLifestockBreeding.Global.Cattle.Breeding = _Flag == true;
    Logic.ExecuteInLuaLocalState("ModuleLifestockBreeding.Local.Cattle.Breeding = " ..tostring(_Flag == true));
    if _Flag ~= true then
        local Price = MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Cow];
        MerchantSystem.BasePrices[Goods.G_Cow] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Cow] = " ..Price);
    else
        local Price = ModuleLifestockBreeding.Global.Cattle.MoneyCost;
        MerchantSystem.BasePrices[Goods.G_Cow] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Cow] = " ..Price);
    end
end

---
-- Aktiviert oder deaktiviert den "Baby Mode" für Schafe.
--
-- Ist der Modus aktiv, werden neu gekaufte Tiere mit 40% ihrer Große erzeugt
-- und wachseln allmählich heran. Dies ist nur kosmetisch und hat keinen
-- Einfluss auf ihre Funktion.
--
-- @param[type=boolean] _Flag Baby Mode aktivieren/deaktivieren
-- @within Anwenderfunktionen
--
-- @usage
-- -- Schafe werden verkleinert erzeugt und wachsen mit der Zeit
-- API.SetSheepUseCalves(true);
--
function API.SetSheepUseCalves(_Flag)
    if GUI then
        return;
    end
    ModuleLifestockBreeding.Global.Sheep.UseCalves = _Flag == true;
end

---
-- Setzt die Dauer des Fütterungsintervals für Schafe.
--
-- Das Fütterungsinterval bestimmt, wie viele Sekunden es dauert, bis ein
-- Getreide durch Zucht verbraucht wird.
--
-- <b>Hinweis:</b> Das Interval ist auf 45 Sekunden voreingestellt und kann
-- nicht unter 15 Sekunden gesenkt werden.
--
-- @param[type=number] _Timer Fütterungsinterval
-- @within Anwenderfunktionen
--
-- @usage
-- -- Es wird alle 60 Sekunden Getreide verbraucht.
-- API.SetSheepFeedingInvervalForBreeding(60);
--
function API.SetSheepFeedingInvervalForBreeding(_Timer)
    if GUI then
        return;
    end
    if type(_Timer) ~= "number" or _Timer < 15 then 
        error("API.SetSheepFeedingInvervalForBreeding: Time ist to short! Must be at least 15 seconds!");
        return;
    end
    ModuleLifestockBreeding.Global.Sheep.FeedingTimer = _Timer;
end

---
-- Aktiviert oder deaktiviert den "Baby Mode" für Kühe.
--
-- Ist der Modus aktiv, werden neu gekaufte Tiere mit 40% ihrer Große erzeugt
-- und wachseln allmählich heran. Dies ist nur kosmetisch und hat keinen
-- Einfluss auf ihre Funktion.
--
-- @param[type=boolean] _Flag Baby Mode aktivieren/deaktivieren
-- @within Anwenderfunktionen
--
-- @usage
-- -- Kühe werden verkleinert erzeugt und wachsen mit der Zeit
-- API.SetCattleUseCalves(true);
--
function API.SetCattleUseCalves(_Flag)
    if GUI then
        return;
    end
    ModuleLifestockBreeding.Global.Cattle.UseCalves = _Flag == true;
end

---
-- Setzt die Dauer des Fütterungsintervals für Kühe.
--
-- Das Fütterungsinterval bestimmt, wie viele Sekunden es dauert, bis ein
-- Getreide durch Zucht verbraucht wird.
--
-- <b>Hinweis:</b> Das Interval ist auf 45 Sekunden voreingestellt und kann
-- nicht unter 15 Sekunden gesenkt werden.
--
-- @param[type=number] _Timer Fütterungsinterval
-- @within Anwenderfunktionen
--
-- @usage
-- -- Es wird alle 60 Sekunden Getreide verbraucht.
-- API.SetCattleFeedingInvervalForBreeding(60);
--
function API.SetCattleFeedingInvervalForBreeding(_Timer)
    if GUI then
        return;
    end
    if type(_Timer) ~= "number" or _Timer < 15 then 
        error("API.SetCattleFeedingInvervalForBreeding: Time ist to short! Must be at least 15 seconds!");
        return;
    end
    ModuleLifestockBreeding.Global.Cattle.FeedingTimer = _Timer;
end

---
-- Stellt die benötigte Menge an Kühen ein.
--
-- Sind weniger Kühe als angegeben im Einzugsbereich des Gatters, können
-- keine neuen Kühe gezüchtet werden.
--
-- <b>Hinweis:</b> Die Mindestmenge ist standardmäßig auf 2 eingestellt.
--
-- @param[type=number] _Amount Menge an Kühen
-- @within Anwenderfunktionen
-- @see API.SetCatchmentAreaForPasture
--
-- @usage
-- -- Es werden keine Kühe benötigt, um zu züchten.
-- API.SetRequiredCattleInCatchmentArea(0);
--
function API.SetRequiredCattleInCatchmentArea(_Amount)
    if GUI then
        return;
    end
    if type(_Amount) ~= "number" or _Amount < 0 then
        error("API.SetRequiredCattleInCatchmentArea: Amount can not be lower than 0!");
        return;
    end
    ModuleLifestockBreeding.Global.Cattle.MinAmountNearby = _Amount;
end

---
-- Stellt die benötigte Menge an Schafen ein.
--
-- Sind weniger Schafe als angegeben im Einzugsbereich des Gatters, können
-- keine neuen Schafe gezüchtet werden.
--
-- <b>Hinweis:</b> Die Mindestmenge ist standardmäßig auf 2 eingestellt.
--
-- @param[type=number] _Amount Menge an Schafen
-- @within Anwenderfunktionen
-- @see API.SetCatchmentAreaForPasture
--
-- @usage
-- -- Es werden keine Schafe benötigt, um zu züchten.
-- API.SetRequiredCattleInCatchmentArea(0);
--
function API.SetRequiredSheepInCatchmentArea(_Amount)
    if GUI then
        return;
    end
    if type(_Amount) ~= "number" or _Amount < 0 then
        error("API.SetRequiredSheepInCatchmentArea: Amount can not be lower than 0!");
        return;
    end
    ModuleLifestockBreeding.Global.Sheep.MinAmountNearby = _Amount;
end

---
-- Legt die Größe des Einzugsbereich des Gatters fest.
--
-- Im eingestellten Gebiet muss sich die Mindestmenge an Tieren aufhalten,
-- damit gezüchtet werden kann.
--
-- <b>Hinweis:</b> Der Einzugsbereich ist standardmäßig auf 3000 eingestellt
-- und kann nicht unter 800 gesenkt werden.
--
-- @param[type=number] _AreaSize Einzugsbereich des Gatters
-- @within Anwenderfunktionen
-- @see API.SetRequiredAnimalsInCatchmentArea
--
-- @usage
-- -- Es zählen nur Tiere innerhalb des Gatters.
-- API.SetSizeOfCatchmentAreaOfPasture(800);
-- -- Tiere auf der ganzen Map zählen.
-- API.SetSizeOfCatchmentAreaOfPasture(Logic.WorldGetSize());
--
function API.SetSizeOfCatchmentAreaOfPasture(_AreaSize)
    if GUI then
        return;
    end
    if type(_AreaSize) ~= "number" or _AreaSize < 800 then
        error("API.SetSizeOfCatchmentAreaOfPasture: Amount must be at least 800!");
        return;
    end
    ModuleLifestockBreeding.Global.AreaSizeNearby = _AreaSize;
end

