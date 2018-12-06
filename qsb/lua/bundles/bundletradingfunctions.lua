-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleTradingFunctions                                       # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle bietet einige (experientelle) Funktionen zum untersuchen und
-- zur Manipulation von Handelsangeboten. Die bekannten Funktionen, wie z.B.
-- AddOffer, werden erweitert, sodass sie Angebote für einen Spieler mit einer
-- anderen ID als 1 erstellen können. Außerdem kann ein Händler nicht mehr
-- mehrere Angebote des gleichen Typs anbieten.
--
-- Zudem wird ein fliegender Händler angeboten, der periodisch den Hafen mit
-- einem Schiff anfährt. Dabei kann der Fahrtweg frei mit Wegpunkten bestimmt
-- werden. Es können auch mehrere Spieler zu Händlern gemacht werden.
--
-- <p><a href="#API.TravelingSalesmanActivate">Schiffshändler aktivieren</a></p>
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleTradingFunctions = {};

API = API or {};
QSB = QSB or {};

QSB.TravelingSalesman = {
	Harbors = {}
};

QSB.TraderTypes = {
    GoodTrader        = 0,
    MercenaryTrader   = 1,
    EntertainerTrader = 2,
    Unknown           = 3,
};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Gibt die Handelsinformationen des Spielers aus. In dem Objekt stehen
-- ID des Spielers, ID des Lagerhaus, Menge an Angeboten insgesamt und
-- alle Angebote der Händlertypen.
--
-- @param _PlayerID [number] Player ID
-- @return [table] Angebotsinformationen
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
-- -- }
--
function API.GetOfferInformation(_PlayerID)
    if GUI then
        API.Log("Can not execute API.GetOfferInformation in local script!");
        return;
    end
    return BundleTradingFunctions.Global:GetStorehouseInformation(_PlayerID);
end

---
-- Gibt die Menge an Angeboten im Lagerhaus des Spielers zurück. Wenn
-- der Spieler kein Lagerhaus hat, wird 0 zurückgegeben.
--
-- @param _PlayerID [number] ID des Spielers
-- @return [number] Anzahl angebote
-- @within Anwenderfunktionen
--
function API.GetOfferCount(_PlayerID)
    if GUI then
        API.Log("Can not execute API.GetOfferCount in local script!");
        return;
    end
    return BundleTradingFunctions.Global:GetOfferCount(_PlayerID);
end

---
-- Gibt zurück, ob das Angebot vom angegebenen Spieler im Lagerhaus zum
-- Verkauf angeboten wird.
--
-- @param _PlayerID [number] Player ID
-- @param _GoodOrEntityType [number] Warentyp oder Entitytyp
-- @return [boolean] Ware wird angeboten
-- @within Anwenderfunktionen
--
function API.IsGoodOrUnitOffered(_PlayerID, _GoodOrEntityType)
    if GUI then
        API.Log("Can not execute API.IsGoodOrUnitOffered in local script!");
        return;
    end
    local OfferID, TraderID = BundleTradingFunctions.Global:GetOfferAndTrader(_PlayerID, _GoodOrEntityType);
    return OfferID ~= 1 and TraderID ~= 1;
end

---
-- Entfernt das Angebot vom Lagerhaus des Spielers, wenn es vorhanden
-- ist. Es wird immer nur das erste Angebot des Typs entfernt.
--
-- @param _PlayerID [number] Player ID
-- @param _GoodOrEntityType [number] Warentyp oder Entitytyp
-- @within Anwenderfunktionen
--
function API.RemoveTradeOffer(_PlayerID, _GoodOrEntityType)
    if GUI then
        API.Bridge("API.RemoveTradeOffer(" .._PlayerID.. ", " .._GoodOrEntityType.. ")");
        return;
    end
    return BundleTradingFunctions.Global:RemoveTradeOffer(_PlayerID, _GoodOrEntityType);
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
-- @param _PlayerID	[number] Händlergebäude
-- @param _GoodOrEntityType	[number] ID des Händlers im Gebäude
-- @param _NewAmount [number] Neue Menge an Angeboten
-- @within Anwenderfunktionen
--
function API.ModifyTradeOffer(_PlayerID, _GoodOrEntityType, _NewAmount)
    if GUI then
        API.Bridge("API.ModifyTradeOffer(" .._PlayerID.. ", " .._GoodOrEntityType.. ", " .._NewAmount.. ")");
        return;
    end
    return BundleTradingFunctions.Global:ModifyTradeOffer(_PlayerID, _GoodOrEntityType, _NewAmount);
end

---
-- Erstellt einen fliegenden Händler mit zufälligen Angeboten.
--
-- Soll immer das selbe angeboten werden, darf nur ein Angebotsblock
-- definiert werden.
-- Es kann mehr als einen fliegenden Händler auf der Map geben.
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
-- -- Jetzt kann ein fliegender Händler erzeugt werden
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
    return BundleTradingFunctions.Global:TravelingSalesman_Create(_PlayerID, _Offers, _Appearance, _Waypoints, _Reversed, _RotationMode);
end
ActivateTravelingSalesman = API.TravelingSalesmanActivate;

---
-- Zerstört den fliegenden Händler. Der Spieler wird dabei natürlich
-- nicht zerstört.
--
-- <b>Alias</b>: DeactivateTravelingSalesman
--
-- @param _PlayerID [number] Spieler-ID des Händlers
-- @within Anwenderfunktionen
--
function API.TravelingSalesmanDeactivate(_PlayerID)
    if GUI then
        API.Bridge("API.TravelingSalesmanDeactivate(" .._PlayerID.. ")");
        return;
    end
    return BundleTradingFunctions.Global:TravelingSalesman_Disband(_PlayerID);
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
function API.TravelingSalesmanDiplomacyOverride(_PlayerID, _Flag)
    if GUI then
        API.Bridge("API.TravelingSalesmanDiplomacyOverride(" .._PlayerID.. ", " ..tostring(_Flag).. ")");
        return;
    end
    return BundleTradingFunctions.Global:TravelingSalesman_AlterDiplomacyFlag(_PlayerID, _Flag);
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

BundleTradingFunctions = {
    Global = {
        Data = {
            PlayerOffersAmount = {
                [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {},
            };
        },
    },
    Local = {
        Data = {}
    },
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:Install()
    self.OverwriteOfferFunctions();
    self.OverwriteBasePricesAndRefreshRates();

    TravelingSalesman_Control = BundleTradingFunctions.Global.TravelingSalesman_Control;
end

---
-- Überschreibt die Funktionen für Standardangebote.
--
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:OverwriteOfferFunctions()
    ---
    -- Erzeugt ein Handelsangebot für Waren und gibt die ID zurück.
    --
    -- <b>Hinweis</b>: Jeder Angebotstyp kann nur 1 Mal pro Lagerhaus
    -- angeboten werden.
    --
    -- @param _Merchant [number] Handelsgebäude
    -- @param _NumberOfOffers [number] Anzahl an Angeboten
    -- @param _GoodType [number] Warentyp
    -- @param _RefreshRate [number] Erneuerungsrate
    -- @param _optionalPlayersPlayerID [number] Optionale Spieler-ID
    -- @return [number] Offer ID
    -- @within Originalfunktionen
    --
    AddOffer = function(_Merchant, _NumberOfOffers, _GoodType, _RefreshRate, _optionalPlayersPlayerID)
        local MerchantID = GetID(_Merchant);
        if type(_GoodType) == "string" then
            _GoodType = Goods[_GoodType];
        else
            _GoodType = _GoodType;
        end

        local PlayerID = Logic.EntityGetPlayer(MerchantID);
        local OfferID, TraderID = BundleTradingFunctions.Global:GetOfferAndTrader(PlayerID, _GoodType);
        if OfferID ~= -1 and TraderID ~= -1 then
            API.Warn("Good offer for good type " .._GoodType.. " already exists for player " ..PlayerID.. "!");
            return;
        end


        AddGoodToTradeBlackList(PlayerID, _GoodType);
        local MarketerType = Entities.U_Marketer;
        if _GoodType == Goods.G_Medicine then
            MarketerType = Entities.U_Medicus;
        end
        if _RefreshRate == nil then
            _RefreshRate = MerchantSystem.RefreshRates[_GoodType];
            if _RefreshRate == nil then
                _RefreshRate = 0;
            end
        end
        if _optionalPlayersPlayerID == nil then
            _optionalPlayersPlayerID = 1;
        end
        local offerAmount = 9;

        BundleTradingFunctions.Global.Data.PlayerOffersAmount[PlayerID][_GoodType] = _NumberOfOffers;
        return Logic.AddGoodTraderOffer(MerchantID,_NumberOfOffers,Goods.G_Gold,0,_GoodType,offerAmount,_optionalPlayersPlayerID,_RefreshRate,MarketerType,Entities.U_ResourceMerchant);
    end

    ---
    -- Erzeugt ein Handelsangebot für Söldner und gibt die ID zurück.
    --
    -- <b>Hinweis</b>: Jeder Angebotstyp kann nur 1 Mal pro Lagerhaus
    -- angeboten werden.
    --
    -- @param _Mercenary [number] Handelsgebäude
    -- @param _Amount [number] Anzahl an Angeboten
    -- @param _Type [number] Soldatentyp
    -- @param _RefreshRate [number] Erneuerungsrate
    -- @param _optionalPlayersPlayerID [number] Optionale Spieler-ID
    -- @return [number] Offer ID
    -- @within Originalfunktionen
    --
    AddMercenaryOffer = function(_Mercenary, _Amount, _Type, _RefreshRate, _optionalPlayersPlayerID)
        local MercenaryID = GetID(_Mercenary);
        if _Type == nil then
            _Type = Entities.U_MilitaryBandit_Melee_ME;
        end
        if _RefreshRate == nil then
            _RefreshRate = MerchantSystem.RefreshRates[_Type];
            if _RefreshRate == nil then
                _RefreshRate = 0;
            end
        end

        local PlayerID = Logic.EntityGetPlayer(MercenaryID);
        local OfferID, TraderID = BundleTradingFunctions.Global:GetOfferAndTrader(PlayerID, _Type);
        if OfferID ~= -1 and TraderID ~= -1 then
            API.Warn("Mercenary offer for type " .._Type.. " already exists for player " ..PlayerID.. "!");
            return;
        end

        local amount = 3;
        local typeName = Logic.GetEntityTypeName(_Type);
        if string.find(typeName,"MilitaryBow") or string.find(typeName,"MilitarySword") then
            amount = 6;
        elseif string.find(typeName,"Cart") then
            amount = 0;
        end
        if _optionalPlayersPlayerID == nil then
            _optionalPlayersPlayerID = 1;
        end

        BundleTradingFunctions.Global.Data.PlayerOffersAmount[PlayerID][_Type] = _Amount;
        return Logic.AddMercenaryTraderOffer(MercenaryID, _Amount, Goods.G_Gold, 3, _Type ,amount,_optionalPlayersPlayerID,_RefreshRate);
    end

    ---
    -- Erzeugt ein Handelsangebot für Entertainer und gibt die
    -- ID zurück.
    --
    -- <b>Hinweis</b>: Jeder Angebotstyp kann nur 1 Mal pro Lagerhaus
    -- angeboten werden.
    --
    -- @param _Merchant [number] Handelsgebäude
    -- @param _EntertainerType [number] Typ des Entertainer
    -- @param _optionalPlayersPlayerID [number] Optionale Spieler-ID
    -- @return [number] Offer ID
    -- @within Originalfunktionen
    --
    AddEntertainerOffer = function(_Merchant, _EntertainerType, _optionalPlayersPlayerID)
        local MerchantID = GetID(_Merchant);
        local NumberOfOffers = 1;

        local PlayerID = Logic.EntityGetPlayer(MerchantID);
        local OfferID, TraderID = BundleTradingFunctions.Global:GetOfferAndTrader(PlayerID, _EntertainerType);
        if OfferID ~= -1 and TraderID ~= -1 then
            API.Warn("Entertainer offer for type " .._EntertainerType.. " already exists for player " ..PlayerID.. "!");
            return;
        end

        if _EntertainerType == nil then
            _EntertainerType = Entities.U_Entertainer_NA_FireEater;
        end
        if _optionalPlayersPlayerID == nil then
            _optionalPlayersPlayerID = 1;
        end

        BundleTradingFunctions.Global.Data.PlayerOffersAmount[PlayerID][_EntertainerType] = 1;
        return Logic.AddEntertainerTraderOffer(MerchantID,NumberOfOffers,Goods.G_Gold,0,_EntertainerType, _optionalPlayersPlayerID,0);
    end
end

---
-- Fügt fehlende Einträge für Militäreinheiten bei den Basispreisen
-- und Erneuerungsraten hinzu, damit diese gehandelt werden können.
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:OverwriteBasePricesAndRefreshRates()
    MerchantSystem.BasePrices[Entities.U_CatapultCart] = MerchantSystem.BasePrices[Entities.U_CatapultCart] or 1000;
    MerchantSystem.BasePrices[Entities.U_BatteringRamCart] = MerchantSystem.BasePrices[Entities.U_BatteringRamCart] or 450;
    MerchantSystem.BasePrices[Entities.U_SiegeTowerCart] = MerchantSystem.BasePrices[Entities.U_SiegeTowerCart] or 600;
    MerchantSystem.BasePrices[Entities.U_AmmunitionCart] = MerchantSystem.BasePrices[Entities.U_AmmunitionCart] or 180;
    MerchantSystem.BasePrices[Entities.U_MilitarySword_RedPrince] = MerchantSystem.BasePrices[Entities.U_MilitarySword_RedPrince] or 150;
    MerchantSystem.BasePrices[Entities.U_MilitarySword] = MerchantSystem.BasePrices[Entities.U_MilitarySword] or 150;
    MerchantSystem.BasePrices[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.BasePrices[Entities.U_MilitaryBow_RedPrince] or 220;
    MerchantSystem.BasePrices[Entities.U_MilitaryBow] = MerchantSystem.BasePrices[Entities.U_MilitaryBow] or 220;

    MerchantSystem.RefreshRates[Entities.U_CatapultCart] = MerchantSystem.RefreshRates[Entities.U_CatapultCart] or 270;
    MerchantSystem.RefreshRates[Entities.U_BatteringRamCart] = MerchantSystem.RefreshRates[Entities.U_BatteringRamCart] or 190;
    MerchantSystem.RefreshRates[Entities.U_SiegeTowerCart] = MerchantSystem.RefreshRates[Entities.U_SiegeTowerCart] or 220;
    MerchantSystem.RefreshRates[Entities.U_AmmunitionCart] = MerchantSystem.RefreshRates[Entities.U_AmmunitionCart] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.RefreshRates[Entities.U_MilitarySword_RedPrince] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitarySword] = MerchantSystem.RefreshRates[Entities.U_MilitarySword] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow] or 150;

    if g_GameExtraNo >= 1 then
        MerchantSystem.BasePrices[Entities.U_MilitaryBow_Khana] = MerchantSystem.BasePrices[Entities.U_MilitaryBow_Khana] or 220;
        MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] or 150;
        MerchantSystem.BasePrices[Entities.U_MilitarySword_Khana] = MerchantSystem.BasePrices[Entities.U_MilitarySword_Khana] or 150;
        MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] = MerchantSystem.RefreshRates[Entities.U_MilitarySword_Khana] or 150;
    end
end

---
-- Gibt die Handelsinformationen des Spielers aus. In dem Objekt stehen
-- ID des Spielers, ID des Lagerhaus, Menge an Angeboten insgesamt und
-- alle Angebote der Händlertypen.
--
-- @param _PlayerID [number] Player ID
-- @return [table] Angebotsinformationen
-- @within Internal
-- @local
--
-- @usage BundleTradingFunctions.Global:GetStorehouseInformation(2);
--
-- -- Ausgabe:
-- -- Info = {
-- --      Player = 2,
-- --      Storehouse = 26796.
-- --      OfferCount = 2,
-- --      {
-- --          Händler-ID, Angebots-ID, Angebotstyp, Wagenladung, Angebotsmenge
-- --          {0, 0, Goods.G_Gems, 9, 2},
-- --          {0, 1, Goods.G_Milk, 9, 4},
-- --      },
-- -- }
--
function BundleTradingFunctions.Global:GetStorehouseInformation(_PlayerID)
    local BuildingID = Logic.GetStoreHouse(_PlayerID);

    local StorehouseData = {
        Player      = _PlayerID,
        Storehouse  = BuildingID,
        OfferCount  = 0,
        {},
    };

    local NumberOfMerchants = Logic.GetNumberOfMerchants(Logic.GetStoreHouse(2));
    local AmountOfOffers = 0;

    if BuildingID ~= 0 then
        for Index = 0, NumberOfMerchants, 1 do
            local Offers = {Logic.GetMerchantOfferIDs(BuildingID, Index, _PlayerID)};
            for i= 1, #Offers, 1 do
                local type, goodAmount, offerAmount, prices = 0, 0, 0, 0;
                if Logic.IsGoodTrader(BuildingID, Index) then
                    type, goodAmount, offerAmount, prices = Logic.GetGoodTraderOffer(BuildingID, Offers[i], _PlayerID);
                    if type == Goods.G_Sheep or type == Goods.G_Cow then
                        goodAmount = 5;
                    end
                elseif Logic.IsMercenaryTrader(BuildingID, Index) then
                    type, goodAmount, offerAmount, prices = Logic.GetMercenaryOffer(BuildingID, Offers[i], _PlayerID);
                elseif Logic.IsEntertainerTrader(BuildingID, Index) then
                    type, goodAmount, offerAmount, prices = Logic.GetEntertainerTraderOffer(BuildingID, Offers[i], _PlayerID);
                end

                AmountOfOffers = AmountOfOffers +1;
                local OfferData = {Index, Offers[i], type, goodAmount, offerAmount};
                table.insert(StorehouseData[1], OfferData);
            end
        end
    end

    StorehouseData.OfferCount = AmountOfOffers;
    return StorehouseData;
end

---
-- Gibt die Menge an Angeboten im Lagerhaus des Spielers zurück. Wenn
-- der Spieler kein Lagerhaus hat, wird 0 zurückgegeben.
--
-- @param _PlayerID [number] ID des Spielers
-- @return [number]
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:GetOfferCount(_PlayerID)
    local Offers = self:GetStorehouseInformation(_PlayerID);
    if Info then
        return Offers.OfferCount;
    end
    return 0;
end

---
-- Gibt Offer ID und Trader ID und ID des Lagerhaus des Angebots für
-- den Spieler zurück. Es wird immer das erste Angebot zurückgegeben.
--
-- @param _PlayerID [number] Player ID
-- @param _GoodOrEntityType [number] Warentyp oder Entitytyp
-- @return [number] Offer ID
-- @return [number] Trader ID
-- @return [number] Storehouse ID
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:GetOfferAndTrader(_PlayerID, _GoodOrEntityType)
    local Info = self:GetStorehouseInformation(_PlayerID);
    if Info then
        for j=1, #Info[1], 1 do
            if Info[1][j][3] == _GoodOrEntityType then
                return Info[1][j][2], Info[1][j][1], Info.Storehouse;
            end
        end
    end
    return -1, -1, -1;
end

---
-- Gibt den Typ des Händlers mit der ID im Gebäude zurück.
--
-- @param _BuildingID [number] Building ID
-- @param _TraderID [number] Trader ID
-- @return number
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:GetTraderType(_BuildingID, _TraderID)
    if Logic.IsGoodTrader(BuildingID, _TraderID) == true then
        return QSB.TraderTypes.GoodTrader;
    elseif Logic.IsMercenaryTrader(BuildingID, _TraderID) == true then
        return QSB.TraderTypes.MercenaryTrader;
    elseif Logic.IsEntertainerTrader(BuildingID, _TraderID) == true then
        return QSB.TraderTypes.EntertainerTrader;
    else
        return QSB.TraderTypes.Unknown;
    end
end

---
-- Entfernt das Angebot vom Lagerhaus des Spielers, wenn es vorhanden ist.
-- Es wird immer nur das erste Angebot des Typs entfernt.
--
-- @param _PlayerID [number] Player ID
-- @param _GoodOrEntityType [number] Warentyp oder Entitytyp
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:RemoveTradeOffer(_PlayerID, _GoodOrEntityType)
    local OfferID, TraderID, BuildingID = self:GetOfferAndTrader(_PlayerID, _GoodOrEntityType);
    if not IsExisting(BuildingID) then
        return;
    end
    -- Wird benötigt, weil bei RemoveOffer die Trader-IDs vertauscht sind.
    local MappedTraderID = (TraderID == 1 and 2) or (TraderID == 2 and 1) or 0;
    Logic.RemoveOffer(BuildingID, MappedTraderID, OfferID);
end

---
-- Ändert die aktuelle Menge des Angebots im Händelrgebäude.
--
-- Der eingetragene Wert darf die maximale Menge an Angeboten des Typs im
-- Lagerhaus nicht überschreiten.
--
-- <b>Hinweis</b>: Wird eine höherer Wert gesetzt, als das ursprüngliche
-- Maximum, regenerieren sich die zusätzlichen Angebote nicht.
--
-- @param _PlayerID	[number] Händlergebäude
-- @param _GoodOrEntityType	[number] ID des Händlers im Gebäude
-- @param _NewAmount [number] Neue Menge an Angeboten
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:ModifyTradeOffer(_PlayerID, _GoodOrEntityType, _NewAmount)
    local OfferID, TraderID, BuildingID = self:GetOfferAndTrader(_PlayerID, _GoodOrEntityType);
    if not IsExisting(BuildingID) then
        return;
    end

    -- Werte größer als das Maximum werden nicht erneuert!
    if self.Data.PlayerOffersAmount[_PlayerID][_GoodOrEntityType] and self.Data.PlayerOffersAmount[_PlayerID][_GoodOrEntityType] < _NewAmount then
        _NewAmount = self.Data.PlayerOffersAmount[_PlayerID][_GoodOrEntityType];
    end
    Logic.ModifyTraderOffer(BuildingID, OfferID, _NewAmount, TraderID);
end

---
-- Gibt den ersten menschlichen Spieler zurück. Ist das globale
-- Gegenstück zu GUI.GetPlayerID().
--
-- @return number
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:TravelingSalesman_GetHumanPlayer()
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
-- Erstellt einen fliegenden Händler mit zufälligen Angeboten. Soll
-- immer das selbe angeboten werden, muss nur ein Angebotsblock
-- definiert werden.
-- Es kann mehrere fliegende Händler auf der Map geben.
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
function BundleTradingFunctions.Global:TravelingSalesman_Create(_PlayerID, _Offers, _Appearance, _Waypoints, _Reversed, _RotationMode)
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
-- Zerstört den fliegenden Händler. Der Spieler wird dabei natürlich
-- nicht zerstört.
--
-- @param _PlayerID [number] Spieler-ID des Händlers
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:TravelingSalesman_Disband(_PlayerID)
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
function BundleTradingFunctions.Global:TravelingSalesman_AlterDiplomacyFlag(_PlayerID, _Flag)
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
function BundleTradingFunctions.Global:TravelingSalesman_NextOffer(_PlayerID)
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
function BundleTradingFunctions.Global:TravelingSalesman_DisplayMessage(_PlayerID)
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
-- Setzt die Angebote für den aktuellen Besuch des Fliegenden Händlers.
--
-- @param _PlayerID [number] Spieler-ID des Händlers
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:TravelingSalesman_AddOffer(_PlayerID)
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
-- Steuert alle fliegenden Händler auf der Map.
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global.TravelingSalesman_Control()
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
                    BundleTradingFunctions.Global:TravelingSalesman_AddOffer(k)
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
                        SetDiplomacyState(BundleTradingFunctions.Global:TravelingSalesman_GetHumanPlayer(),k,DiplomacyStates.EstablishedContact);
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

-- Local Script ----------------------------------------------------------------

---
-- Initialisiert das Bundle im lokalen Skript.
-- @within Internal
-- @local
--
function BundleTradingFunctions.Local:Install()

end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleTradingFunctions");
