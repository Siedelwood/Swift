-- Trading API -------------------------------------------------------------- --

---
-- Setzt die Funktion zur Kalkulation des Preisfaktors des Helden. Die Änderung
-- betrifft nur den angegebenen Spieler.
-- Die Funktion muss den angepassten Preis zurückgeben.
--
-- Die übergebene Funktion erhält den Basispreis, die ID des Spielers und die
-- ID der KI als Parameter.
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
-- Die übergebene Funktion erhält den Basispreis, die ID des Spielers und die
-- ID der KI als Parameter.
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
-- Die übergebene Funktion erhält den Warentyp, die ID des Spielers und die ID
-- der KI als Parameter.
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
-- Die übergebene Funktion erhält den Warentyp, die ID des Spielers und die ID
-- der KI als Parameter.
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
-- Die übergebene Funktion erhält die Zahl bisher gekaufter angebote, den Preis
-- der Ware, ID des Spielers und die ID ID der KI als Parameter.
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
-- Die übergebene Funktion erhält die Zahl bisher gekaufter angebote, den Preis
-- der Ware, ID des Spielers und die ID der KI als Parameter.
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
-- Die übergebene Funktion erhält den Spieler, die KI-Partei, den Angebotstyp,
-- die Menge an Waren und den Stückpreis als Argumente.
--
-- Angebotstypen:
-- <table border="1">
-- <tr><th>Typ</th><th>Variable</th></tr>
-- <tr><td>Söldner</td><td>g_Merchant.MercenaryTrader</td></tr>
-- <tr><td>Unterhalter</td><td>g_Merchant.EntertainerTrader</td></tr>
-- <tr><td>Ware</td><td>g_Merchant.GoodTrader</td></tr>
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
-- Die übergebene Funktion erhält den Spieler, die KI-Partei, die Menge an
-- Waren und den Stückpreis als Argumente.
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
-- Die übergebene Funktion erhält den Warentyp, die ID des Spielers und die ID
-- der KI als Parameter.
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
-- Die übergebene Funktion erhält den Warentyp, die ID des Spielers und die ID
-- der KI als Parameter.
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
-- Die übergebene Funktion erhält den Preis der Ware, ID des Spielers und
-- die ID ID der KI als Parameter.
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
-- Die übergebene Funktion erhält den Preis der Ware, ID des Spielers und
-- die ID der KI als Parameter.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.SaleSetDefaultDeflation(MyCalculationFunction);
--
function API.SaleSetDefaultDeflation(_Function)
    API.SaleSetDeflationForPlayer(nil, _Function)
end

---
-- Setzt eine Funktion zur Festlegung spezieller Verkaufsbedingungen. Diese
-- Bedingungen betreffen nur den angegebenen Spieler.
-- Die Funktion muss true zurückgeben, wenn verkauft werden darf.
--
-- Die übergebene Funktion erhält den Spieler, die KI-Partei, die Menge an
-- Waren und den Stückpreis als Argumente.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Function Evaluationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.SaleSetDeflationForPlayer(2, MyCalculationFunction);
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
-- Die übergebene Funktion erhält den Spieler, die KI-Partei, die Menge an
-- Waren und den Stückpreis als Argumente.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Evaluationsfunktion
-- @within Anwenderfunktionen
--
-- @usage API.SaleSetDefaultDeflation(MyCalculationFunction);
--
function API.SaleSetDefaultCondition(_Function)
    API.SaleSetConditionForPlayer(nil, _Function)
end

