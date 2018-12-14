-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleTravelingSalesman                                       # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Bundle wird ein Fahrender Händler angeboten der periodisch den
-- Hafen mit einem Schiff anfährt. Dabei kann der Fahrtweg frei mit Wegpunkten
-- bestimmt werden. Es können auch mehrere Spieler zu Händlern gemacht werden.
--
-- <p><a href="#API.TravelingSalesmanActivate">Schiffshändler aktivieren</a></p>
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleTravelingSalesman = {};

API = API or {};
QSB = QSB or {};

QSB.TravelingSalesman = {
	Harbors = {}
};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erstellt einen fahrender Händler mit zufälligen Angeboten.
--
-- Soll immer das selbe angeboten werden, darf nur ein Angebotsblock
-- definiert werden.
-- Es kann mehr als einen fahrender Händler auf der Map geben.
--
-- <b>Alias</b>: ActivateTravelingSalesman
--
-- @param _PlayerID [number] Spieler-ID des Händlers
-- @param _Offers [table] Liste an Angeboten
-- @param _Waypoints [table] Wegpunktliste Anfahrt
-- @param _Reversed [table] Wegpunktliste Abfahrt
-- @param _Appearance [table] Ankunft und Abfahrt
-- @param _RotationMode [boolean] Angebote werden der Reihe nach durchgegangen
-- @within Anwenderfunktionen
--
-- @usage -- Angebote deklarieren
-- local Offers = {
--     {
--         {"G_Gems", 5,},
--         {"G_Iron", 5,},
--         {"G_Beer", 2,},
--     },
--     {
--         {"G_Stone", 5,},
--         {"G_Sheep", 1,},
--         {"G_Cheese", 2,},
--         {"G_Milk", 5,},
--     },
--     {
--         {"G_Grain", 5,},
--         {"G_Broom", 2,},
--         {"G_Sheep", 1,},
--     },
--     {
--         {"U_CatapultCart", 1,},
--         {"U_MilitarySword", 3,},
--         {"U_MilitaryBow", 3,},
--     },
-- };
-- -- Es sind maximal 4 Angebote pro Block erlaubt. Es können Waren, Soldaten
-- -- oder Entertainer angeboten werden. Es wird immer automatisch 1 Block
-- -- selektiert und die ANgebote gesetzt.
--
-- -- Wegpunkte deklarieren
-- local Waypoints = {"WP1", "WP2", "WP3", "WP4"};
-- -- Es gibt nun zwei Möglichkeiten:
-- -- 1. Durch weglassen des Reversed Path werden die Wegpunkte durch das
-- -- Schiff bei der Abfahrt automatisch rückwärts abgefahren.
-- -- 2. Es wird ein anderer Pfad für die Abfahrt deklariert.
--
-- -- Anfahrt und Abfanrtsmonate deklarieren
-- local Appearance = {{4, 6}, {8, 10}};
-- -- Auch hier gibt es 2 Möglichkeiten:
-- -- 1. Neue Anfahrts- und Abfahrtszeiten setzen.
-- -- 2. _Apperance weglassen / nil setzen und den Standard verwenden
-- -- (März bis Mai und August bis Oktober)
--
-- -- Jetzt kann ein fahrender Händler erzeugt werden
-- API.TravelingSalesmanActivate(2, Offers, Waypoints, nil, Appearance);
-- -- Hier ist der Rückweg automatisch die Umkehr des Hinwegs (_Reversed = nil).
--
-- -- _Reversed und _Apperance können in den meisten Fällen immer weggelassen
-- -- bzw. nil sein!
-- API.TravelingSalesmanActivate(2, Offers, Waypoints);
--
function API.TravelingSalesmanActivate(_PlayerID, _Offers, _Waypoints, _Reversed, _Appearance, _RotationMode)
    if GUI then
        API.Log("Can not execute API.TravelingSalesmanActivate in local script!");
        return;
    end
    return BundleTravelingSalesman.Global:TravelingSalesman_Create(_PlayerID, _Offers, _Appearance, _Waypoints, _Reversed, _RotationMode);
end
ActivateTravelingSalesman = API.TravelingSalesmanActivate;

---
-- Zerstört den fahrender Händler. Der Spieler wird dabei natürlich
-- nicht zerstört.
--
-- <b>Alias</b>: DeactivateTravelingSalesman
--
-- @param _PlayerID [number] Spieler-ID des Händlers
-- @within Anwenderfunktionen
--
-- @usage -- Fahrenden Händler von Spieler 2 löschen
-- API.TravelingSalesmanDeactivate(2)
--
function API.TravelingSalesmanDeactivate(_PlayerID)
    if GUI then
        API.Bridge("API.TravelingSalesmanDeactivate(" .._PlayerID.. ")");
        return;
    end
    return BundleTravelingSalesman.Global:TravelingSalesman_Disband(_PlayerID);
end
DeactivateTravelingSalesman = API.TravelingSalesmanDeactivate;

---
-- Legt fest, ob die diplomatischen Beziehungen zwischen dem Spieler und dem
-- Hafen überschrieben werden.
--
-- Die diplomatischen Beziehungen werden überschrieben, wenn sich ein Schiff
-- im Hafen befinden und wenn es abreist. Der Hafen ist "Handelspartner", wenn
-- ein Schiff angelegt hat, sonst "Bekannt".
--
-- Bei diplomatischen Beziehungen geringer als "Bekannt", kann es zu Fehlern
-- kommen. Dann werden Handelsangebote angezeigt, konnen aber nicht durch
-- den Spieler erworben werden.
--
-- <b>Hinweis</b>: Standardmäßig als aktiv voreingestellt.
--
-- <b>Alias</b>: TravelingSalesmanDiplomacyOverride
--
-- @param _PlayerID [number] Spieler-ID des Händlers
-- @param _Flag [boolean] Diplomatie überschreiben
-- @within Anwenderfunktionen
--
-- @usage -- Spieler 2 überschreibt nicht mehr die Diplomatie
-- API.TravelingSalesmanDiplomacyOverride(2, false)
--
function API.TravelingSalesmanDiplomacyOverride(_PlayerID, _Flag)
    if GUI then
        API.Bridge("API.TravelingSalesmanDiplomacyOverride(" .._PlayerID.. ", " ..tostring(_Flag).. ")");
        return;
    end
    return BundleTravelingSalesman.Global:TravelingSalesman_AlterDiplomacyFlag(_PlayerID, _Flag);
end
TravelingSalesmanDiplomacyOverride = API.TravelingSalesmanDiplomacyOverride;

---
-- Legt fest, ob die Angebote der Reihe nach durchgegangen werden (beginnt von
-- vorn, wenn am Ende angelangt) oder zufällig ausgesucht werden.
--
-- <b>Alias</b>: TravelingSalesmanRotationMode
--
-- @param _PlayerID [number] Spieler-ID des Händlers
-- @param _Flag [boolean] Angebotsrotation einschalten
-- @within Anwenderfunktionen
--
-- @usage -- Spieler 2 geht Angebote der Reihe nach durch.
-- API.TravelingSalesmanRotationMode(2, true)
--
function API.TravelingSalesmanRotationMode(_PlayerID, _Flag)
    if GUI then
        API.Bridge("API.TravelingSalesmanRotationMode(" .._PlayerID.. ", " ..tostring(_Flag).. ")");
        return;
    end
    if not QSB.TravelingSalesman.Harbors[_PlayerID] then
        return;
    end
    QSB.TravelingSalesman.Harbors[_PlayerID].RotationMode = _Flag == true;
end
TravelingSalesmanRotationMode = API.TravelingSalesmanRotationMode;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleTravelingSalesman = {
    Global = {
        Data = {},
    },
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function BundleTravelingSalesman.Global:Install()
    TravelingSalesman_Control = BundleTravelingSalesman.Global.TravelingSalesman_Control;
end

---
-- Gibt den ersten menschlichen Spieler zurück. Ist das globale
-- Gegenstück zu GUI.GetPlayerID().
--
-- @return number
-- @within Internal
-- @local
--
function BundleTravelingSalesman.Global:TravelingSalesman_GetHumanPlayer()
    local pID = 1;
    for i=1,8 do
        if Logic.PlayerGetIsHumanFlag(1) == true then
            pID = i;
            break;
        end
    end
    return pID;
end

---
-- Erstellt einen fahrender Händler mit zufälligen Angeboten. Soll
-- immer das selbe angeboten werden, muss nur ein Angebotsblock
-- definiert werden.
-- Es kann mehrere fahrende Händler auf der Map geben.
--
-- @param _PlayerID [number] Spieler-ID des Händlers
-- @param _Offers [table] Liste an Angeboten
-- @param _Appearance [table] Wartezeit
-- @param _Waypoints [table] Wegpunktliste Anfahrt
-- @param _Reversed [table] Wegpunktliste Abfahrt
-- @param _RotationMode [boolean] Wegpunktliste Abfahrt
-- @within Internal
-- @local
--
function BundleTravelingSalesman.Global:TravelingSalesman_Create(_PlayerID, _Offers, _Appearance, _Waypoints, _Reversed, _RotationMode)
    assert(type(_PlayerID) == "number");
    assert(type(_Offers) == "table");
    _Appearance = _Appearance or {{3,5},{8,10}};
    assert(type(_Appearance) == "table");
    assert(type(_Waypoints) == "table");

    if not _Reversed then
        _Reversed = {};
        for i=#_Waypoints, 1, -1 do
            _Reversed[#_Waypoints+1 - i] = _Waypoints[i];
        end
    end

    if not QSB.TravelingSalesman.Harbors[_PlayerID] then
        QSB.TravelingSalesman.Harbors[_PlayerID] = {};

        QSB.TravelingSalesman.Harbors[_PlayerID].Waypoints = _Waypoints;
        QSB.TravelingSalesman.Harbors[_PlayerID].Reversed = _Reversed;
        QSB.TravelingSalesman.Harbors[_PlayerID].SpawnPos = _Waypoints[1];
        QSB.TravelingSalesman.Harbors[_PlayerID].Destination = _Reversed[1];
        QSB.TravelingSalesman.Harbors[_PlayerID].Appearance = _Appearance;
        QSB.TravelingSalesman.Harbors[_PlayerID].Status = 0;
        QSB.TravelingSalesman.Harbors[_PlayerID].Offer = _Offers;
        QSB.TravelingSalesman.Harbors[_PlayerID].LastOffer = 0;
        QSB.TravelingSalesman.Harbors[_PlayerID].AlterDiplomacy = true;
        QSB.TravelingSalesman.Harbors[_PlayerID].RotationMode = _RotationMode == true;
    end
    math.randomseed(Logic.GetTimeMs());

    if not QSB.TravelingSalesman.JobID then
        QSB.TravelingSalesman.JobID = StartSimpleJob("TravelingSalesman_Control");
    end
end

---
-- Zerstört den fahrender Händler. Der Spieler wird dabei natürlich
-- nicht zerstört.
--
-- @param _PlayerID [number] Spieler-ID des Händlers
-- @within Internal
-- @local
--
function BundleTravelingSalesman.Global:TravelingSalesman_Disband(_PlayerID)
    assert(type(_PlayerID) == "number");
    QSB.TravelingSalesman.Harbors[_PlayerID] = nil;
    Logic.RemoveAllOffers(Logic.GetStoreHouse(_PlayerID));
    DestroyEntity("TravelingSalesmanShip_Player" .._PlayerID);
end

---
-- Legt fest, ob die diplomatischen Beziehungen zwischen dem Spieler und dem
-- Hafen überschrieben werden.
--
-- Die diplomatischen Beziehungen werden überschrieben, wenn sich ein Schiff
-- im Hafen befinden und wenn es abreist. Der Hafen ist "Handelspartner", wenn
-- ein Schiff angelegt hat, sonst "Bekannt".
--
-- Bei diplomatischen Beziehungen geringer als "Bekannt", kann es zu Fehlern
-- kommen. Dann werden Handelsangebote angezeigt, konnen aber nicht durch
-- den Spieler erworben werden.
--
-- <b>Hinweis</b>: Standardmäßig als aktiv voreingestellt.
--
-- @param _PlayerID [number] Spieler-ID des Händlers
-- @param _Flag [boolean] Diplomatie überschreiben
-- @within Internal
-- @local
--
function BundleTravelingSalesman.Global:TravelingSalesman_AlterDiplomacyFlag(_PlayerID, _Flag)
    assert(type(_PlayerID) == "number");
    assert(QSB.TravelingSalesman.Harbors[_PlayerID]);
    QSB.TravelingSalesman.Harbors[_PlayerID].AlterDiplomacy = _Flag == true;
end

---
-- Gibt das nächste Angebot des Hafens des Spielers zurück.
--
-- @param _PlayerID [number] ID des Spielers
-- @within Internal
-- @local
--
function BundleTravelingSalesman.Global:TravelingSalesman_NextOffer(_PlayerID)
    local NextOffer;
    -- Angebote werden der Reihe nach durchlaufen und wiederholen sich.
    if QSB.TravelingSalesman.Harbors[_PlayerID].RotationMode then
        QSB.TravelingSalesman.Harbors[_PlayerID].LastOffer = QSB.TravelingSalesman.Harbors[_PlayerID].LastOffer +1
        local OfferIndex = QSB.TravelingSalesman.Harbors[_PlayerID].LastOffer;
        if OfferIndex > #QSB.TravelingSalesman.Harbors[_PlayerID].Offer then
            QSB.TravelingSalesman.Harbors[_PlayerID].LastOffer = 1;
            OfferIndex = 1;
        end
        NextOffer = QSB.TravelingSalesman.Harbors[_PlayerID].Offer[OfferIndex];
    -- Angebote werden zufällig ausgelost, ohne direkte Doppelung.
    else
        local RandomIndex = 1;
        if #QSB.TravelingSalesman.Harbors[_PlayerID].Offer > 1 then
            repeat
                RandomIndex = math.random(1,#QSB.TravelingSalesman.Harbors[_PlayerID].Offer);
            until (RandomIndex ~= QSB.TravelingSalesman.Harbors[_PlayerID].LastOffer);
        end
        QSB.TravelingSalesman.Harbors[_PlayerID].LastOffer = RandomIndex;
        NextOffer = QSB.TravelingSalesman.Harbors[_PlayerID].Offer[RandomIndex];
    end
    return NextOffer;
end

---
-- Informiert den Spieler über die Ankunft eines Schiffes am Hafen.
--
-- @param _PlayerID [number] ID des Spielers
-- @within Internal
-- @local
--
function BundleTravelingSalesman.Global:TravelingSalesman_DisplayMessage(_PlayerID)
    if ((IsBriefingActive and not IsBriefingActive()) or true) then
        -- Prüfe, ob schon existiert und starte ggf. neu
        -- (Konsistenz von Questnamen erhalten!)
        local InfoQuest = Quests[GetQuestID("TravelingSalesman_Info_P" .._PlayerID)];
        if InfoQuest then
            API.RestartQuest("TravelingSalesman_Info_P" .._PlayerID, true);
            InfoQuest:SetMsgKeyOverride();
            InfoQuest:SetIconOverride();
            InfoQuest:Trigger();
            return;
        end

        -- Erzeuge neuen Quest
        -- (Quest existiert nicht und kann gefahrlos erzeugt werden.)
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        local Text = { de = "Ein Schiff hat angelegt. Es bringt Güter von weit her.",
                       en = "A ship is at the pier. It deliver goods from far away."};
        QuestTemplate:New(
            "TravelingSalesman_Info_P" .._PlayerID,
            _PlayerID,
            self:TravelingSalesman_GetHumanPlayer(),
            {{ Objective.Dummy,}},
            {{ Triggers.Time, 0 }},
            0,
            nil, nil, nil, nil, false, true,
            nil, nil,
            Text[lang],
            nil
        );
    end
end

---
-- Setzt die Angebote für den aktuellen Besuch des fahrenden Händlers.
--
-- @param _PlayerID [number] Spieler-ID des Händlers
-- @within Internal
-- @local
--
function BundleTravelingSalesman.Global:TravelingSalesman_AddOffer(_PlayerID)
    MerchantSystem.TradeBlackList[_PlayerID] = {};
    MerchantSystem.TradeBlackList[_PlayerID][0] = #MerchantSystem.TradeBlackList[3];

    local traderId = Logic.GetStoreHouse(_PlayerID);
    local offer = self:TravelingSalesman_NextOffer(_PlayerID);
    Logic.RemoveAllOffers(traderId);

    if #offer > 0 then
        for i=1,#offer,1 do
            local offerType = offer[i][1];
            local isGoodType = false
            for k,v in pairs(Goods)do
                if k == offerType then
                    isGoodType = true
                end
            end

            if isGoodType then
                local amount = offer[i][2];
                AddOffer(traderId,amount,Goods[offerType], 9999);
            else
                if Logic.IsEntityTypeInCategory(Entities[offerType],EntityCategories.Military)== 0 then
                    AddEntertainerOffer(traderId,Entities[offerType]);
                else
                    local amount = offer[i][2];
                    AddMercenaryOffer(traderId,amount,Entities[offerType], 9999);
                end
            end
        end
    end

    if QSB.TravelingSalesman.Harbors[_PlayerID].AlterDiplomacy then
        SetDiplomacyState(self:TravelingSalesman_GetHumanPlayer(), _PlayerID, DiplomacyStates.TradeContact);
    end
    ActivateMerchantPermanentlyForPlayer(Logic.GetStoreHouse(_PlayerID), self:TravelingSalesman_GetHumanPlayer());
    self:TravelingSalesman_DisplayMessage(_PlayerID);
end

---
-- Steuert alle fahrender Händler auf der Map.
-- @within Internal
-- @local
--
function BundleTravelingSalesman.Global.TravelingSalesman_Control()
    for k,v in pairs(QSB.TravelingSalesman.Harbors) do
        if QSB.TravelingSalesman.Harbors[k] ~= nil then
            if v.Status == 0 then
                local month = Logic.GetCurrentMonth();
                local start = false;
                for i=1, #v.Appearance,1 do
                    if month == v.Appearance[i][1] then
                        start = true;
                    end
                end
                if start then
                    local orientation = Logic.GetEntityOrientation(GetID(v.SpawnPos))
                    local ID = CreateEntity(0,Entities.D_X_TradeShip,GetPosition(v.SpawnPos),"TravelingSalesmanShip_Player"..k,orientation);
                    Path:new(ID,v.Waypoints, nil, nil, nil, nil, true, nil, nil, 300);
                    v.Status = 1;
                end
            elseif v.Status == 1 then
                if IsNear("TravelingSalesmanShip_Player"..k,v.Destination,400) then
                    BundleTravelingSalesman.Global:TravelingSalesman_AddOffer(k)
                    v.Status = 2;
                end
            elseif v.Status == 2 then
                local month = Logic.GetCurrentMonth();
                local stop = false;
                for i=1, #v.Appearance,1 do
                    if month == v.Appearance[i][2] then
                        stop = true;
                    end
                end
                if stop then
                    if QSB.TravelingSalesman.Harbors[k].AlterDiplomacy then
                        SetDiplomacyState(BundleTravelingSalesman.Global:TravelingSalesman_GetHumanPlayer(),k,DiplomacyStates.EstablishedContact);
                    end
                    Path:new(GetID("TravelingSalesmanShip_Player"..k),v.Reversed, nil, nil, nil, nil, true, nil, nil, 300);
                    Logic.RemoveAllOffers(Logic.GetStoreHouse(k));
                    v.Status = 3;
                end
            elseif v.Status == 3 then
                if IsNear("TravelingSalesmanShip_Player"..k,v.SpawnPos,400) then
                    DestroyEntity("TravelingSalesmanShip_Player"..k);
                    v.Status = 0;
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleTravelingSalesman");
