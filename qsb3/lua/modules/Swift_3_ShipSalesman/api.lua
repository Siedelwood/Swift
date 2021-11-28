--[[
Swift_3_ShipSalesment/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Mit diesem Bundle wird ein Fahrender Händler angeboten der periodisch den
-- Hafen mit einem Schiff anfährt. Dabei kann der Fahrtweg frei mit Wegpunkten
-- bestimmt werden. Es können auch mehrere Spieler zu Händlern gemacht werden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_JobsCore.api.html">(1) JobsCore</a></li>
-- <li><a href="Swift_1_TradingCore.api.html">(1) TradingCore</a></li>
-- <li><a href="Swift_2_Quests.api.html">(2) Quests</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field TradeShipArrived Ein Handelsschiff ist am Hafen angekommen (Parameter: TraderPlayerID, PartnerPlayerID, ShipID)
-- @field TradeShipLeft    Ein Handelsschiff hat den Hafen verlassen (Parameter: TraderPlayerID, PartnerPlayerID, ShipID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

QSB.ShipWaypointDistance = 300;

---
-- Erstellt einen fahrender Händler mit zufälligen Angeboten.
--
-- Soll immer das selbe angeboten werden, darf es nur genauso viele Angebote
-- geben, wie als Maximum gesetzt wird.
--
-- Es kann mehr als einen fahrender Händler auf der Map geben.
--
-- <h5>Angebote</h5>
-- Es können Waren, Soldaten oder Entertainer angeboten werden. Aus allen
-- definierten Angeboten werden zufällig Angebote in der angegebenen Mange
-- ausgesucht und gesetzt.
--
-- <h5>Routen</h5>
-- Um die Route anzugeben, wird ein Name eingegeben. Es werden alle fortlaufend
-- nummerierte Punkte mit diesem Namen gesucht. Alternativ kann auch eine
-- Liste von Punkten angegeben werden. Es muss mindestens 2 Punkte geben.
--
-- <b>Alias</b>: TravelingSalesmanActivate
--
-- @param[type=table]  _Description Definition des Händlers
-- @within Anwenderfunktionen
--
-- @usage local TraderDescription = {
--     PlayerID        = 2,       -- Player ID des Hafen
--     PartnerPlayerID = 1,       -- Player ID des Spielers
--     Path            = "SH2WP", -- Pfad (auch als Table einzelner Punkte möglich)
--     Duration        = 150,     -- Ankerzeit in Sekunden (Standard: 360)
--     Interval        = 3,       -- Monate zwischen zwei Anfarten (Standard: 2)
--     OfferCount      = 4,       -- Anzahl Angebote (1 bis 4) (Standard: 4)
--     NoIce           = true,    -- Schiff kommt nicht im Winter (Standard: false)
--     Offers          = {
--         -- Angebot, Menge
--         {"G_Gems", 5},
--         {"G_Iron", 5},
--         {"G_Beer", 2},
--         {"G_Stone", 5},
--         {"G_Sheep", 1},
--         {"G_Cheese", 2},
--         {"G_Milk", 5},
--         {"G_Grain", 5},
--         {"G_Broom", 2},
--         {"U_CatapultCart", 1},
--         {"U_MilitarySword", 3},
--         {"U_MilitaryBow", 3}
--     },
-- };
-- API.TravelingSalesmanCreate(TraderDescription);
--
function API.TravelingSalesmanCreate(_TraderDescription)
    if GUI then
        return;
    end
    if type(_TraderDescription) ~= "table" then
        error("API.TravelingSalesmanCreate: _TraderDescription must be a table!");
        return;
    end
    if type(_TraderDescription.PlayerID) ~= "number" or _TraderDescription.PlayerID < 1 or _TraderDescription.PlayerID > 8 then
        error("API.TravelingSalesmanCreate: _TraderDescription.PlayerID (" ..tostring(_TraderDescription.PlayerID).. ") is wrong!");
        return;
    end
    if type(_TraderDescription.PartnerPlayerID) ~= "number" or _TraderDescription.PartnerPlayerID < 1 or _TraderDescription.PartnerPlayerID > 8 then
        error("API.TravelingSalesmanCreate: _TraderDescription.PartnerPlayerID (" ..tostring(_TraderDescription.PartnerPlayerID).. ") is wrong!");
        return;
    end
    if type(_TraderDescription.Duration) ~= "number" or _TraderDescription.Duration < 60 then
        error("API.TravelingSalesmanCreate: _TraderDescription.Duration (" ..tostring(_TraderDescription.Duration).. ") must be at least 60 seconds!");
        return;
    end
    if type(_TraderDescription.Interval) ~= "number" or _TraderDescription.Interval < 1 then
        error("API.TravelingSalesmanCreate: _TraderDescription.Interval (" ..tostring(_TraderDescription.Interval).. ") must be at least 1 month!");
        return;
    end
    if type(_TraderDescription.OfferCount) ~= "number" or _TraderDescription.OfferCount < 1 or _TraderDescription.OfferCount > 4 then
        error("API.TravelingSalesmanCreate: _TraderDescription.Duration (" ..tostring(_TraderDescription.OfferCount).. ") is wrong!");
        return;
    end
    if type(_TraderDescription.Offers) ~= "table" or #_TraderDescription.Offers < _TraderDescription.OfferCount then
        error("API.TravelingSalesmanCreate: _TraderDescription.Offers must have at least " .._TraderDescription.OfferCount.." entries!");
        return;
    end
    for i= 1, #_TraderDescription.Offers, 1 do
        if Goods[_TraderDescription.Offers[i][1]] == nil and Entities[_TraderDescription.Offers[i][1]] == nil then
            error("API.TravelingSalesmanCreate: _TraderDescription.Offers[" ..i.. "][1] is invalid good type!");
            return;
        end
        if type(_TraderDescription.Offers[i][2]) ~= "number" or _TraderDescription.Offers[i][2] < 1 then
            error("API.TravelingSalesmanCreate: _TraderDescription.Offers[" ..i.. "][2] amount must be at least 1!");
            return;
        end
    end

    API.TravelingSalesmanDispose(_TraderDescription.PlayerID);
    _TraderDescription.Offers = API.ConvertOldOfferFormat(_TraderDescription.Offers);
    _TraderDescription.Duration = _TraderDescription.Duration or (6 * 60);
    _TraderDescription.Interval = _TraderDescription.Interval or 2;
    _TraderDescription.OfferCount = _TraderDescription.OfferCount or 4;

    local Harbor = QSB.TradeShipHarbor:New(_TraderDescription.PlayerID)
        :SetPartnerPlayerID(_TraderDescription.PartnerPlayerID)
        :SetPath(_TraderDescription.Path or _TraderDescription.Waypoints)
        :SetDuration(_TraderDescription.Duration)
        :SetInterval(_TraderDescription.Interval)
        :SetNoIce(_TraderDescription.NoIce == true)
        :SetOfferCount(_TraderDescription.OfferCount);

    local OffersString = "";
    for i= 1, #_TraderDescription.Offers, 1 do
        Harbor:AddOffer(_TraderDescription.Offers[i][1], _TraderDescription.Offers[i][2]);       
        OffersString = OffersString .. "(" ..tostring(_TraderDescription.Offers[i][1]).. ", " .._TraderDescription.Offers[i][2].. "){cr}";
    end
    Harbor:SetActive(true);
    ModuleShipSalesment.Global:RegisterHarbor(Harbor);

    info("API.TravelingSalesmanCreate: creating habor for player " .._TraderDescription.PlayerID.. "{cr}"..
         "Partner: " .._TraderDescription.PartnerPlayerID.. "{cr}"..
         "Duration: " .._TraderDescription.Duration.. "{cr}"..
         "Interval: " .._TraderDescription.Interval.. "{cr}"..
         "Offers per period: " .._TraderDescription.OfferCount.. "{cr}"..
         "Offer types:{cr}" ..OffersString);
end
TravelingSalesmanCreate = API.TravelingSalesmanCreate;

---
-- Konvertiert die Angebote, falls sie im alten Format angegeben wurden.
-- @param[type=table] _Offers Angebotsliste
-- @return Umgeformte Angebote
-- @within Anwenderfunktionen
-- @local
--
function API.ConvertOldOfferFormat(_Offers)
    if type(_Offers[1][1]) ~= "table" then
        return _Offers;
    end
    local Offers = {};
    for i= 1, #_Offers, 1 do
        for j= 1, #_Offers[i], 1 do
            local Found = false;
            for k= 1, #Offers, 1 do
                if Offers[k][1] == _Offers[i][j][1] then
                    Found = true;
                    break;
                end
            end
            if (not Found) then
                table.insert(Offers, _Offers[i][j]);
            end
        end
    end
    return Offers;
end
ConvertOldOfferFormat = API.ConvertOldOfferFormat;

---
-- Entfernt den fahrenden Händler von dem Spieler. Der Spieler bleibt
-- erhalten wird aber nicht mal als fahrender Händler fungieren.
--
-- <b>Hinweis</b>: Wenn gerade ein Schiff unterwegs ist oder im Hafen liegt,
-- wird es sofort gelöscht!
--
-- <b>Alias</b>: TravelingSalesmanDeactivate
--
-- @param[type=number] _PlayerID Spieler-ID des Händlers
-- @within Anwenderfunktionen
--
-- @usage API.TravelingSalesmanDispose(2);
--
function API.TravelingSalesmanDispose(_PlayerID)
    if GUI then
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.TravelingSalesmanDispose: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    local Harbor = ModuleShipSalesment.Global.Harbors[_PlayerID];
    if Harbor then
        info("API.TravelingSalesmanDispose: Deleting habor of player " .._PlayerID);
        Harbor:Dispose();
    end
    ModuleShipSalesment.Global.Harbors[_PlayerID] = nil;
end
TravelingSalesmanDeactivate = API.TravelingSalesmanDispose;

---
-- Deaktiviert einen fahrenden Händler. Der aktuelle Zyklus wird noch beendet,
-- aber danach kommt der Händler nicht mehr wieder.
--
-- <b>Alias</b>: TravelingSalesmanYield
--
-- @param[type=number] _PlayerID Spieler-ID des Händlers
-- @within Anwenderfunktionen
--
-- @usage API.TravelingSalesmanYield(2);
--
function API.TravelingSalesmanYield(_PlayerID)
    if GUI then
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.TravelingSalesmanYield: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    local Harbor = ModuleShipSalesment.Global.Harbors[_PlayerID];
    if Harbor then
        info("API.TravelingSalesmanYield: Suspending habor of player " .._PlayerID);
        Harbor:SetActive(false);
    end
end
API.TravelingSalesmanDeactivate = API.TravelingSalesmanYield;
TravelingSalesmanYield = API.TravelingSalesmanYield;

---
-- Aktiviert einen fahrenden Händler, der zuvor deaktiviert wurde.
--
-- <b>Alias</b>: TravelingSalesmanResume
--
-- @param[type=number] _PlayerID Spieler-ID des Händlers
-- @within Anwenderfunktionen
--
-- @usage API.TravelingSalesmanResume(2);
--
function API.TravelingSalesmanResume(_PlayerID)
    if GUI then
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.TravelingSalesmanResume: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    local Harbor = ModuleShipSalesment.Global.Harbors[_PlayerID];
    if Harbor then
        info("API.TravelingSalesmanResume: Resuming habor of player " .._PlayerID);
        Harbor:SetActive(true);
    end
end
API.TravelingSalesmanActivate = API.TravelingSalesmanResume;
TravelingSalesmanResume = API.TravelingSalesmanResume;

