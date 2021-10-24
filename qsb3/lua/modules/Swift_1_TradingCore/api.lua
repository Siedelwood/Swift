--[[
Swift_1_TradingCore/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Modul zum Überschreiben des Verhaltens von Händlern. Es können Angebote im
-- eigenen Lagerhaus und in fremden Lagerhäusern beeinflusst werden.
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
-- Events, auf die reagiert werden kann.
--
-- @field GoodsPurchased Güter werden bei einem Händler gekauft (Parameter: TraderType, OfferIndex, GoodType, PlayerID, TraderPlayerID, OfferGoodAmount, Price)
-- @field GoodsSold      Güter werden im eigenen Lagerhaus verkauft (Parameter: GoodType, PlayerID, TargetPlayerID, GoodAmount, Price)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Setzt die Funktion zur Kalkulation des Preisfaktors des Helden. Die Änderung
-- betrifft nur den angegebenen Spieler.
-- Die Funktion muss den angepassten Preis zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Price</td><td>number</td><td></td>Basispreis</tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.PurchaseSetTraderAbilityForPlayer(2, MyCalculationFunction);
--
function API.PurchaseSetTraderAbilityForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTradingCore.Local.Lambda.PurchaseTraderAbility[_PlayerID] = _Function;
    else
        ModuleTradingCore.Local.Lambda.PurchaseTraderAbility.Default = _Function;
    end
end

---
-- Setzt die allgemeine Funktion zur Kalkulation des Preisfaktors des Helden.
-- Die Funktion muss den angepassten Preis zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Price</td><td>number</td><td></td>Basispreis</tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.PurchaseSetDefaultTraderAbility(MyCalculationFunction);
--
function API.PurchaseSetDefaultTraderAbility(_Function)
    API.PurchaseSetTraderAbilityForPlayer(nil, _Function);
end

---
-- Setzt die Funktion zur Bestimmung des Basispreis. Die Änderung betrifft nur
-- den angegebenen Spieler.
-- Die Funktion muss den Basispreis der Ware zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.PurchaseSetBasePriceForPlayer(2, MyCalculationFunction);
--
function API.PurchaseSetBasePriceForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTradingCore.Local.Lambda.PurchaseBasePrice[_PlayerID] = _Function;
    else
        ModuleTradingCore.Local.Lambda.PurchaseBasePrice.Default = _Function;
    end
end

---
-- Setzt die Funktion zur Bestimmung des Basispreis.
-- Die Funktion muss den Basispreis der Ware zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_PurchaseCount</td><td>number</td><td>Zahl bereits gekaufter Angebote</td></tr>
-- <tr><td>_Price</td><td>number</td><td></td>Aktueller Preis</tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.PurchaseSetDefaultBasePrice(MyCalculationFunction);
--
function API.PurchaseSetDefaultBasePrice(_Function)
    API.PurchaseSetBasePriceForPlayer(nil, _Function);
end

---
-- Setzt die Funktion zur Berechnung der Preisinflation. Die Änderung betrifft
-- nur den angegebenen Spieler.
-- Die Funktion muss den von der Inflation beeinflussten Preis zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_PurchaseCount</td><td>number</td><td>Zahl bereits gekaufter Angebote</td></tr>
-- <tr><td>_Price</td><td>number</td><td></td>Aktueller Preis</tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.PurchaseSetInflationForPlayer(2, MyCalculationFunction);
--
function API.PurchaseSetInflationForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTradingCore.Local.Lambda.PurchaseInflation[_PlayerID] = _Function;
    else
        ModuleTradingCore.Local.Lambda.PurchaseInflation.Default = _Function;
    end
end

---
-- Setzt die Funktion zur Berechnung der Preisinflation.
-- Die Funktion muss den von der Inflation beeinflussten Preis zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_Amount</td><td>number</td><td>Verkaufte Menge</td></tr>
-- <tr><td>_UnitPrice</td><td>number</td><td>Stückpreis</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.PurchaseSetDefaultInflation(MyCalculationFunction);
--
function API.PurchaseSetDefaultInflation(_Function)
    API.PurchaseSetInflationForPlayer(nil, _Function)
end

---
-- Setzt eine Funktion zur Festlegung spezieller Ankaufsbedingungen. Diese
-- Bedingungen betreffen nur den angegebenen Spieler.
-- Die Funktion muss true zurückgeben, wenn gekauft werden darf.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_Amount</td><td>number</td><td>Verkaufte Menge</td></tr>
-- <tr><td>_UnitPrice</td><td>number</td><td>Stückpreis</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Function Evaluationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.PurchaseSetConditionForPlayer(2, MyCalculationFunction);
--
function API.PurchaseSetConditionForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTradingCore.Local.Lambda.PurchaseAllowed[_PlayerID] = _Function;
    else
        ModuleTradingCore.Local.Lambda.PurchaseAllowed.Default = _Function;
    end
end

---
-- Setzt eine Funktion zur Festlegung spezieller Verkaufsbedingungen.
-- Die Funktion muss true zurückgeben, wenn verkauft werden darf.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_Amount</td><td>number</td><td>Verkaufte Menge</td></tr>
-- <tr><td>_UnitPrice</td><td>number</td><td>Stückpreis</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Evaluationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.PurchaseSetDefaultCondition(MyCalculationFunction);
--
function API.PurchaseSetDefaultCondition(_Function)
    API.PurchaseSetConditionForPlayer(nil, _Function)
end

---
-- Setzt die Funktion zur Bestimmung des Basispreis. Die Änderung betrifft nur
-- den angegebenen Spieler.
-- Die Funktion muss den Basispreis der Ware zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Warentyp</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.SaleSetBasePriceForPlayer(2, MyCalculationFunction);
--
function API.SaleSetBasePriceForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTradingCore.Local.Lambda.SaleBasePrice[_PlayerID] = _Function;
    else
        ModuleTradingCore.Local.Lambda.SaleBasePrice.Default = _Function;
    end
end

---
-- Setzt die Funktion zur Bestimmung des Basispreis.
-- Die Funktion muss den Basispreis der Ware zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Warentyp</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.SaleSetDefaultBasePrice(MyCalculationFunction);
--
function API.SaleSetDefaultBasePrice(_Function)
    API.SaleSetBasePriceForPlayer(nil, _Function);
end

---
-- Setzt die Funktion zur Berechnung des minimalen Verkaufserlös. Die Änderung
-- betrifft nur den angegebenen Spieler.
-- Die Funktion muss den von der Deflation beeinflussten Erlös zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Price</td><td>number</td><td>Verkaufspreis</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.SaleSetDeflationForPlayer(2, MyCalculationFunction);
--
function API.SaleSetDeflationForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTradingCore.Local.Lambda.SaleDeflation[_PlayerID] = _Function;
    else
        ModuleTradingCore.Local.Lambda.SaleDeflation.Default = _Function;
    end
end

---
-- Setzt die Funktion zur Berechnung des minimalen Verkaufserlös.
-- Die Funktion muss den von der Deflation beeinflussten Erlös zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Price</td><td>number</td><td>Verkaufspreis</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.SaleSetDefaultDeflation(MyCalculationFunction);
--
function API.SaleSetDefaultDeflation(_Function)
    API.SaleSetDeflationForPlayer(nil, _Function);
end

---
-- Setzt eine Funktion zur Festlegung spezieller Verkaufsbedingungen. Diese
-- Bedingungen betreffen nur den angegebenen Spieler.
-- Die Funktion muss true zurückgeben, wenn verkauft werden darf.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_Amount</td><td>number</td><td>Verkaufte Menge</td></tr>
-- <tr><td>_UnitPrice</td><td>number</td><td>Preis pro Stück</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Function Evaluationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.SaleSetConditionForPlayer(2, MyCalculationFunction);
--
function API.SaleSetConditionForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTradingCore.Local.Lambda.SaleAllowed[_PlayerID] = _Function;
    else
        ModuleTradingCore.Local.Lambda.SaleAllowed.Default = _Function;
    end
end

---
-- Setzt eine Funktion zur Festlegung spezieller Verkaufsbedingungen.
-- Die Funktion muss true zurückgeben, wenn verkauft werden darf.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_Amount</td><td>number</td><td>Verkaufte Menge</td></tr>
-- <tr><td>_UnitPrice</td><td>number</td><td>Preis pro Stück</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Evaluationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.SaleSetDefaultCondition(MyCalculationFunction);
--
function API.SaleSetDefaultCondition(_Function)
    API.SaleSetConditionForPlayer(nil, _Function);
end

---
-- Lässt einen NPC-Spieler einem anderen Spieler Waren anbieten.
--
-- @param[type=number] _VendorID    Spieler-ID des Verkäufers
-- @param[type=number] _OfferType   Typ der Angebote
-- @param[type=number] _OfferAmount Menge an Angeboten
-- @param[type=number] _RefreshRate (Optional) Regenerationsrate des Angebot
-- @within Anwenderfunktionen
--
-- @usage -- Spieler 2 bietet Spieler 1 Brot an
-- API.AddGoodOffer(2, 1, Goods.G_Bread, 2);
-- -- Spieler 2 bietet Spieler 3 Eisen an
-- API.AddGoodOffer(2, 3, Goods.G_Iron, 4, 180);
--
function API.AddGoodOffer(_VendorID, _OfferType, _OfferAmount, _RefreshRate)
    _OfferType = (type(_OfferType) == "string" and Goods[_OfferType]) or _OfferType;
    local OfferID, TraderID = ModuleTradingCore.Global:GetOfferAndTrader(_VendorID, _OfferType);
    if OfferID ~= -1 and TraderID ~= -1 then
        warn(string.format(
            "Good offer for type %s already exists for player %d!",
            Logic.GetGoodTypeName(_OfferType),
            _VendorID
        ));
        return;
    end
    
    local VendorStoreID = Logic.GetStoreHouse(_VendorID);
    AddGoodToTradeBlackList(_VendorID, _OfferType);

    -- Good cart type
    local MarketerType = Entities.U_Marketer;
    if _OfferType == Goods.G_Medicine then
        MarketerType = Entities.U_Medicus;
    end
    -- Refresh rate
    if _RefreshRate == nil then
        _RefreshRate = MerchantSystem.RefreshRates[_OfferType] or 0;
    end

    return Logic.AddGoodTraderOffer(
        VendorStoreID,
        _OfferAmount,
        Goods.G_Gold,
        0,
        _OfferType,
        9,
        1,
        _RefreshRate,
        MarketerType,
        Entities.U_ResourceMerchant
    );
end
-- Compability option
function AddOffer(_Merchant, _NumberOfOffers, _GoodType, _RefreshRate)
    local VendorID = Logic.EntityGetPlayer(GetID(_Merchant));
    return API.AddGoodOffer(VendorID, _GoodType, _NumberOfOffers, _RefreshRate);
end

---
-- Lässt einen NPC-Spieler einem anderen Spieler Söldner anbieten.
--
-- <b>Hinweis</b>: Stadtlagerhäuser können keine Söldner anbieten!
--
-- @param[type=number] _VendorID    Spieler-ID des Verkäufers
-- @param[type=number] _OfferType   Typ der Söldner
-- @param[type=number] _OfferAmount Menge an Söldnern
-- @param[type=number] _RefreshRate (Optional) Regenerationsrate des Angebot
-- @within Anwenderfunktionen
--
-- @usage -- Spieler 2 bietet Spieler 1 Sölder an
-- API.AddMercenaryOffer(2, 1, Entities.U_MilitaryBandit_Melee_SE, 3);
--
function API.AddMercenaryOffer(_VendorID, _OfferType, _OfferAmount, _RefreshRate)
    _OfferType = (type(_OfferType) == "string" and Entities[_OfferType]) or _OfferType;
    local OfferID, TraderID = ModuleTradingCore.Global:GetOfferAndTrader(_VendorID, _OfferType);
    if OfferID ~= -1 and TraderID ~= -1 then
        warn(string.format(
            "Mercenary offer for type %s already exists for player %d!",
            Logic.GetEntityTypeName(_OfferType),
            _VendorID
        ));
        return;
    end
    
    local VendorStoreID = Logic.GetStoreHouse(_VendorID);

    -- Refresh rate
    if _RefreshRate == nil then
        _RefreshRate = MerchantSystem.RefreshRates[_OfferType] or 0;
    end
    -- Soldier count (Display hack for unusual mercenaries)
    local SoldierCount = 3;
    local TypeName = Logic.GetEntityTypeName(_OfferType);
    if string.find(TypeName, "MilitaryBow") or string.find(TypeName, "MilitarySword") then
        SoldierCount = 6;
    elseif string.find(TypeName,"Cart") then
        SoldierCount = 0;
    end

    return Logic.AddMercenaryTraderOffer(
        VendorStoreID,
        _OfferAmount,
        Goods.G_Gold,
        0,
        _OfferType,
        SoldierCount,
        1,
        _RefreshRate
    );
end
-- Compability option
function AddMercenaryOffer(_Mercenary, _Amount, _Type, _RefreshRate)
    local VendorID = Logic.EntityGetPlayer(GetID(_Mercenary));
    return API.AddMercenaryOffer(VendorID, _Type, _Amount, _RefreshRate);
end

---
-- Lässt einen NPC-Spieler einem anderen Spieler einen Entertainer anbieten.
--
-- @param[type=number] _VendorID    Spieler-ID des Verkäufers
-- @param[type=number] _OfferType   Typ des Entertainer
-- @within Anwenderfunktionen
--
-- @usage -- Spieler 2 bietet Spieler 1 einen Feuerschlucker an
-- API.AddEntertainerOffer(2, 1, Entities.NA_FireEater);
--
function API.AddEntertainerOffer(_VendorID, _OfferType)
    _OfferType = (type(_OfferType) == "string" and Entities[_OfferType]) or _OfferType;
    local OfferID, TraderID = ModuleTradingCore.Global:GetOfferAndTrader(_VendorID, _OfferType);
    if OfferID ~= -1 and TraderID ~= -1 then
        warn(string.format(
            "Entertainer offer for type %s already exists for player %d!",
            Logic.GetEntityTypeName(_OfferType),
            _VendorID
        ));
        return;
    end
    
    local VendorStoreID = Logic.GetStoreHouse(_VendorID);
    return Logic.AddEntertainerTraderOffer(
        VendorStoreID,
        1,
        Goods.G_Gold,
        0,
        _OfferType,
        1,
        0
    );
end
-- Compability option
function AddEntertainerOffer(_Merchant, _EntertainerType)
    local VendorID = Logic.EntityGetPlayer(GetID(_Merchant));
    return API.AddEntertainerOffer(VendorID, _EntertainerType);
end

---
-- Gibt die Handelsinformationen des Spielers aus. In dem Objekt stehen
-- ID des Spielers, ID des Lagerhaus, Menge an Angeboten insgesamt und
-- alle Angebote der Händlertypen.
--
-- @param[type=number] _PlayerID Player ID
-- @return[type=table] Angebotsinformationen
-- @within Anwenderfunktionen
--
-- @usage local Info = API.GetOfferInformation(2);
--
-- -- Info enthält:
-- -- Info = {
-- --      Player = 2,
-- --      Storehouse = 26796.
-- --      OfferCount = 2,
-- --      {
-- --          Händler-ID, Angebots-ID, Angebotstyp, Wagenladung, Angebotsmenge
-- --          {0, 0, Goods.G_Gems, 9, 2},
-- --          {0, 1, Goods.G_Milk, 9, 4},
-- --      },
-- -- };
--
function API.GetOfferInformation(_PlayerID)
    if GUI then
        return;
    end
    return ModuleTradingCore.Global:GetStorehouseInformation(_PlayerID);
end

---
-- Gibt die Menge an Angeboten im Lagerhaus des Spielers zurück. Wenn
-- der Spieler kein Lagerhaus hat, wird 0 zurückgegeben.
--
-- @param[type=number] _PlayerID Player ID
-- @return[type=number] Anzahl angebote
-- @within Anwenderfunktionen
--
-- @usage -- Angebote von Spieler 5 zählen
-- local Count = API.GetOfferCount(5);
--
function API.GetOfferCount(_PlayerID)
    if GUI then
        return;
    end
    return ModuleTradingCore.Global:GetOfferCount(_PlayerID);
end

---
-- Gibt zurück, ob das Angebot vom angegebenen Spieler im Lagerhaus zum
-- Verkauf angeboten wird.
--
-- @param[type=number] _PlayerID Player ID
-- @param[type=number] _GoodOrEntityType Warentyp oder Entitytyp
-- @return[type=boolean] Ware wird angeboten
-- @within Anwenderfunktionen
--
-- @usage -- Wird die Ware angeboten?
-- if API.IsGoodOrUnitOffered(4, Goods.G_Bread) then
--     API.Note("Brot wird von Spieler 4 angeboten.");
-- end
--
function API.IsGoodOrUnitOffered(_PlayerID, _GoodOrEntityType)
    if GUI then
        return;
    end
    local OfferID, TraderID = ModuleTradingCore.Global:GetOfferAndTrader(_PlayerID, _GoodOrEntityType);
    return OfferID ~= 1 and TraderID ~= 1;
end

---
-- Gibt die aktuelle Anzahl an Angeboten des Typs zurück.
--
-- @param[type=number] _PlayerID Player ID
-- @param[type=number] _GoodOrEntityType Warentyp oder Entitytyp
-- @return[type=number] Menge an Angeboten
-- @within Anwenderfunktionen
--
-- @usage -- Wird die Ware angeboten?
-- local CurrentAmount = API.IsGoodOrUnitOffered(4, Goods.G_Bread);
--
function API.GetTradeOfferWaggonAmount(_PlayerID, _GoodOrEntityType)
    local Amount = -1;
    local OfferInfo = ModuleTradingCore.Global:GetStorehouseInformation(_PlayerID);
    for i= 1, #OfferInfo[4] do
        if OfferInfo[4][i][3] == _GoodOrEntityType and OfferInfo[4][i][5] > 0 then
            Amount = OfferInfo[4][i][5];
        end
    end
    return Amount;
end

---
-- Entfernt das Angebot vom Lagerhaus des Spielers, wenn es vorhanden
-- ist. Es wird immer nur das erste Angebot des Typs entfernt.
--
-- @param[type=number] _PlayerID Player ID
-- @param[type=number] _GoodOrEntityType Warentyp oder Entitytyp
-- @within Anwenderfunktionen
--
-- @usage -- Keinen Käse mehr verkaufen
-- API.RemoveTradeOffer(7, Goods.G_Cheese);
--
function API.RemoveTradeOffer(_PlayerID, _GoodOrEntityType)
    if GUI then
        return;
    end
    return ModuleTradingCore.Global:RemoveTradeOffer(_PlayerID, _GoodOrEntityType);
end

---
-- Ändert die aktuelle Menge des Angebots im Händelrgebäude.
--
-- Es kann ein beliebiger positiver Wert gesetzt werden. Es gibt keine
-- Beschränkungen.
--
-- <b>Hinweis</b>: Wird eine höherer Wert gesetzt, als das ursprüngliche
-- Maximum, regenerieren sich die zusätzlichen Angebote nicht.
--
-- @param[type=number] _PlayerID Player ID
-- @param[type=number] _GoodOrEntityType ID des Händlers im Gebäude
-- @param[type=number] _NewAmount Neue Menge an Angeboten
-- @within Anwenderfunktionen
--
-- @usage -- Angebote voll auffüllen
-- API.ModifyTradeOffer(7, Goods.G_Cheese, -1);
-- API.ModifyTradeOffer(7, Goods.U_MilitarySword);
-- -- 2 Angebote auffüllen
-- API.ModifyTradeOffer(7, Goods.G_Dye, 2);
--
function API.ModifyTradeOffer(_PlayerID, _GoodOrEntityType, _NewAmount)
    if GUI then
        return;
    end
    return ModuleTradingCore.Global:ModifyTradeOffer(_PlayerID, _GoodOrEntityType, _NewAmount);
end

