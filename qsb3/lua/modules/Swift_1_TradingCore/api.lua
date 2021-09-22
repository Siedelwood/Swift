-- Trading API -------------------------------------------------------------- --

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
-- Ein NPC-Spieler kann verschiedenen Spielern verschiedene Angebote machen. Das
-- bedeutet Spieler A kann Brote erhalten und Spieler B stattdessen Würste.
--
-- @param[type=number] _VendorID    Spieler-ID des Verkäufers
-- @param[type=number] _ReceiverID  Spieler-ID des Angebotempfängers
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
function API.AddGoodOffer(_VendorID, _ReceiverID, _OfferType, _OfferAmount, _RefreshRate)
    _OfferType = (type(_OfferType) == "string" and Goods[_OfferType]) or _OfferType;
    
    local VendorStoreID = Logic.GetStoreHouse(_VendorID);
    local ReceiverHeroID = Logic.GetKnightID(_ReceiverID);
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
    -- Offer amount (Crimson Sabatt hack)
    local WaggonLoad = 9;
    if ReceiverHeroID ~= 0 and Logic.GetEntityType(ReceiverHeroID) == Entities.U_KnightSabatta then
        WaggonLoad = 10;
    end
    if _OfferType == Goods.G_Cow or _OfferType == Goods.G_Sheep then
        WaggonLoad = 5;
    end

    return Logic.AddGoodTraderOffer(
        VendorStoreID,
        _OfferAmount,
        Goods.G_Gold,
        0,
        _OfferType,
        WaggonLoad,
        _ReceiverID,
        _RefreshRate,
        MarketerType,
        Entities.U_ResourceMerchant
    );
end
-- Compability option
function AddOffer(_Merchant, _NumberOfOffers, _GoodType, _RefreshRate, _PlayerID)
    local VendorID = Logic.EntityGetPlayer(GetID(_Merchant));
    return API.AddGoodOffer(VendorID, _PlayerID, _GoodType, _NumberOfOffers, _RefreshRate);
end

---
-- Lässt einen NPC-Spieler einem anderen Spieler Söldner anbieten.
--
-- Ein NPC-Spieler kann verschiedenen Spielern verschiedene Angebote machen. Das
-- bedeutet Spieler A kann Schwertkämpfer erhalten und Spieler B stattdessen
-- Bogenschützen.
--
-- <b>Hinweis</b>: Stadtlagerhäuser können keine Söldner anbieten!
--
-- @param[type=number] _VendorID    Spieler-ID des Verkäufers
-- @param[type=number] _ReceiverID  Spieler-ID des Angebotempfängers
-- @param[type=number] _OfferType   Typ der Söldner
-- @param[type=number] _OfferAmount Menge an Söldnern
-- @param[type=number] _RefreshRate (Optional) Regenerationsrate des Angebot
-- @within Anwenderfunktionen
--
-- @usage -- Spieler 2 bietet Spieler 1 Sölder an
-- API.AddMercenaryOffer(2, 1, Entities.U_MilitaryBandit_Melee_SE, 3);
--
function API.AddMercenaryOffer(_VendorID, _ReceiverID, _OfferType, _OfferAmount, _RefreshRate)
    _OfferType = (type(_OfferType) == "string" and Entities[_OfferType]) or _OfferType;
    
    local VendorStoreID = Logic.GetStoreHouse(_VendorID);

    -- Refresh rate
    if _RefreshRate == nil then
        _RefreshRate = MerchantSystem.RefreshRates[_OfferType] or 0;
    end
    -- Soldier count (Display hack for unusual mercenaries)
    local SoldierCount = 3;
    local TypeName = Logic.GetEntityTypeName(_OfferType) or "";
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
        _ReceiverID,
        _RefreshRate
    );
end
-- Compability option
function AddMercenaryOffer(_Mercenary, _Amount, _Type, _RefreshRate, _PlayerID)
    local VendorID = Logic.EntityGetPlayer(GetID(_Mercenary));
    return API.AddMercenaryOffer(VendorID, _PlayerID or 1, _Type, _Amount, _RefreshRate);
end

---
-- Lässt einen NPC-Spieler einem anderen Spieler einen Entertainer anbieten.
--
-- Ein NPC-Spieler kann verschiedenen Spielern verschiedene Angebote machen. Das
-- bedeutet Spieler A kann Stälzengänger erhalten und Spieler B stattdessen
-- Gewichtheber.
--
-- @param[type=number] _VendorID    Spieler-ID des Verkäufers
-- @param[type=number] _ReceiverID  Spieler-ID des Angebotempfängers
-- @param[type=number] _OfferType   Typ des Entertainer
-- @within Anwenderfunktionen
--
-- @usage -- Spieler 2 bietet Spieler 1 einen Feuerschlucker an
-- API.AddEntertainerOffer(2, 1, Entities.NA_FireEater);
--
function API.AddEntertainerOffer(_VendorID, _ReceiverID, _OfferType)
    _OfferType = (type(_OfferType) == "string" and Entities[_OfferType]) or _OfferType;
    
    local VendorStoreID = Logic.GetStoreHouse(_VendorID);
    return Logic.AddEntertainerTraderOffer(
        VendorStoreID,
        1,
        Goods.G_Gold,
        0,
        _OfferType,
        _ReceiverID,
        0
    );
end
-- Compability option
function AddEntertainerOffer(_Merchant, _EntertainerType, _PlayerID)
    local VendorID = Logic.EntityGetPlayer(GetID(_Merchant));
    return API.AddEntertainerOffer(VendorID, _PlayerID or 1, _EntertainerType);
end

