-- Stock Breeding API ------------------------------------------------------- --

---
-- Ermöglicht die Aufzucht von Nutzrieren wie Schafe und Kühe durch den Spieler.
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
-- Erlaube oder verbiete dem Spieler Schafe zu züchten.
--
-- Wenn der Spieler keine Schafe züchten soll, kann ihm dieses Recht durch
-- diese Funktion genommen werden. Natürlich kann das Recht auf diesem Weg
-- auch wieder zurückgegeben werden.
--
-- <p><b>Alias:</b> UseBreedSheeps</p>
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

    ModuleLifestockBreeding.Global.AllowBreedSheeps = _Flag == true;
    Logic.ExecuteInLuaLocalState("ModuleLifestockBreeding.Local.AllowBreedSheeps = " ..tostring(_Flag == true));
    if _Flag ~= true then
        local Price = MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Sheep]
        MerchantSystem.BasePrices[Goods.G_Sheep] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Sheep] = " ..Price);
    else
        local Price = ModuleLifestockBreeding.Global.SheepMoneyCost;
        MerchantSystem.BasePrices[Goods.G_Sheep] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Sheep] = " ..Price);
    end
end
UseBreedSheeps = API.UseBreedSheeps;

---
-- Erlaube oder verbiete dem Spieler Kühe zu züchten.
--
-- Wenn der Spieler keine Kühe züchten soll, kann ihm dieses Recht durch
-- diese Funktion genommen werden. Natürlich kann das Recht auf diesem Weg
-- auch wieder zurückgegeben werden.
--
-- <p><b>Alias:</b> UseBreedCattle</p>
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

    ModuleLifestockBreeding.Global.AllowBreedCattle = _Flag == true;
    Logic.ExecuteInLuaLocalState("ModuleLifestockBreeding.Local.AllowBreedCattle = " ..tostring(_Flag == true));
    if _Flag ~= true then
        local Price = MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Cow];
        MerchantSystem.BasePrices[Goods.G_Cow] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Cow] = " ..Price);
    else
        local Price = ModuleLifestockBreeding.Global.CattleMoneyCost;
        MerchantSystem.BasePrices[Goods.G_Cow] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Cow] = " ..Price);
    end
end
UseBreedCattle = API.UseBreedCattle;

---
-- Setzt den Typen des verwendeten Schafes.
--
-- Der EntityTyp muss nicht angegeben werden. Folgende Werte sind möglich:
-- <ul>
-- <li>0: Zufällig bei Zucht gewählt</li>
-- <li>1: A_X_Sheep01 (weiß)</li>
-- <li>2: A_X_Sheep02 (grau)</li>
-- </ul>
--
-- <b>Alias</b>: SetSheepType
--
-- @param[type=boolean] _Type Schafstyp
-- @within Anwenderfunktionen
--
-- @usage
-- -- Es wird jedes mal zufällig ausgewählt
-- API.SetSheepType(0);
-- -- Es werden nur graue Schafe erzeugt
-- API.SetSheepType(2);
--
function API.SetSheepType(_Type)
    if GUI then
        return;
    end
    if type(_Type) ~= "number" or _Type > 2 or _Type < 0 then
        log("API.SetCattleNeeded: Needed amount is invalid!", LEVEL_ERROR);
    end
    ModuleLifestockBreeding.Global.SheepType = _Type * (-1);
end
SetSheepType = API.SetSheepType;

---
-- Aktiviert oder deaktiviert den "Baby Mode" für Schafe.
--
-- Ist der Modus aktiv, werden neu gekaufte Tiere mit 40% ihrer Große erzeugt
-- und wachseln allmählich heran. Dies ist nur kosmetisch und hat keinen
-- Einfluss auf ihre Funktion.
--
-- <b>Alias</b>: SetSheepBabyMode
--
-- @param[type=boolean] _Flag Baby Mode aktivieren/deaktivieren
-- @within Anwenderfunktionen
--
-- @usage
-- -- Schafe werden verkleinert erzeugt und wachsen mit der Zeit
-- API.SetSheepBabyMode(true);
--
function API.SetSheepBabyMode(_Flag)
    if GUI then
        return;
    end
    ModuleLifestockBreeding.Global.SheepBaby = _Flag == true;
end
SetSheepBabyMode = API.SetSheepBabyMode;

---
-- Setzt die Dauer des Fütterungsintervals für Schafe.
--
-- Das Fütterungsinterval bestimmt, wie viele Sekunden es dauert, bis ein
-- Getreide durch Zucht verbraucht wird.
--
-- <b>Hinweis:</b> Das Interval ist auf 45 Sekunden voreingestellt und kann
-- nicht unter 15 Sekunden gesenkt werden.
--
-- <b>Alias</b>: SetSheepFeedingTimer
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
    ModuleLifestockBreeding.Global.SheepFeedingTimer = _Timer;
end
SetSheepFeedingTimer = API.SetSheepFeedingInvervalForBreeding;

---
-- Aktiviert oder deaktiviert den "Baby Mode" für Kühe.
--
-- Ist der Modus aktiv, werden neu gekaufte Tiere mit 40% ihrer Große erzeugt
-- und wachseln allmählich heran. Dies ist nur kosmetisch und hat keinen
-- Einfluss auf ihre Funktion.
--
-- <b>Alias</b>: SetCattleBaby
--
-- @param[type=boolean] _Flag Baby Mode aktivieren/deaktivieren
-- @within Anwenderfunktionen
--
-- @usage
-- -- Kühe werden verkleinert erzeugt und wachsen mit der Zeit
-- API.SetCattleBabyMode(true);
--
function API.SetCattleBabyMode(_Flag)
    if GUI then
        return;
    end
    ModuleLifestockBreeding.Global.CattleBaby = _Flag == true;
end
SetCattleBaby = API.SetCattleBaby;

---
-- Setzt die Dauer des Fütterungsintervals für Kühe.
--
-- Das Fütterungsinterval bestimmt, wie viele Sekunden es dauert, bis ein
-- Getreide durch Zucht verbraucht wird.
--
-- <b>Hinweis:</b> Das Interval ist auf 45 Sekunden voreingestellt und kann
-- nicht unter 15 Sekunden gesenkt werden.
--
-- <b>Alias</b>: SetCattleFeedingTimer
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
    ModuleLifestockBreeding.Global.CattleFeedingTimer = _Timer;
end
SetCattleFeedingTimer = API.SetCattleFeedingInvervalForBreeding;

---
-- Stellt die benötigte Menge an Tieren ein.
--
-- Sind weniger Tiere als angegeben im Einzugsbereich des Gatters, können
-- keine neuen Tiere gezüchtet werden.
--
-- <b>Hinweis:</b> Die Mindestmenge ist standardmäßig auf 2 eingestellt.
--
-- <b>Alias</b>: SetBreedingAnimalsAmount
--
-- @param[type=number] _Amount Menge an Tieren
-- @within Anwenderfunktionen
-- @see API.SetCatchmentAreaForPasture
--
-- @usage
-- -- Es werden keine Tiere benötigt um zu züchten.
-- API.SetRequiredAnimalsInCatchmentArea(0);
--
function API.SetRequiredAnimalsInCatchmentArea(_Amount)
    if GUI then
        return;
    end
    if type(_Amount) ~= "number" or _Amount < 0 or _Amount > 5 then
        error("API.SetRequiredAnimalsInCatchmentArea: Amount must be a number between 0 and 5!");
        return;
    end
    ModuleLifestockBreeding.Global.MinAmountNearby = _Amount;
end
SetBreedingAnimalsAmount = API.SetRequiredAnimalsInCatchmentArea;

---
-- Legt die Größe des Einzugsbereich des Gatters fest.
--
-- Im eingestellten Gebiet muss sich die Mindestmenge an Tieren aufhalten,
-- damit gezüchtet werden kann.
--
-- <b>Hinweis:</b> Der Einzugsbereich ist standardmäßig auf 3000 eingestellt
-- und kann nicht unter 800 gesenkt werden.
--
-- <b>Alias</b>: SetBreedingAreaSize
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
SetBreedingAreaSize = API.SetSizeOfCatchmentAreaOfPasture;

