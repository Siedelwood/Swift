-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleTradingFunctions                                       # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle bietet einige (experientelle) Funktionen zum untersuchen und
-- zur Manipulation von Handelsangeboten. Die bekannten Funktionen, wie z.B.
-- AddOffer, werden erweitert, sodass sie Angebote für einen Spieler mit einer
-- anderen ID als 1 erstellen können.
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
    GoodTrader        = 1,
    MercenaryTrader   = 2,
    EntertainerTrader = 3,
    Unknown           = 4,
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
-- @usage local Info = BundleTradingFunctions.Global:GetOfferInformation(2);
--
-- -- Info enthält:
-- -- Info = {
-- --      Player = 2,
-- --      Storehouse = 26796.
-- --      OfferCount = 2,
-- --      {
-- --          {TraderID = 0, OfferID = 0, GoodType = Goods.G_Gems,
-- --           OfferGoodAmount = 9, OfferAmount = 2},
-- --          {TraderID = 0, OfferID = 1, GoodType = Goods.G_Milk,
-- --           OfferGoodAmount = 9, OfferAmount = 4},
-- --      },
-- -- }
--
function API.GetOfferInformation(_PlayerID)
    if GUI then
        API.Log("Can not execute API.GetOfferInformation in local script!");
        return;
    end
    return BundleTradingFunctions.Global:GetOfferInformation(_PlayerID);
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
-- Gibt Offer ID und Trader ID und ID des Lagerhaus des Angebots für
-- den Spieler zurück. Es wird immer das erste Angebot zurückgegeben.
--
-- @param _PlayerID [number] Player ID
-- @param _GoodType [number] Warentyp oder Entitytyp
-- @return [number] ID des Angebots
-- @return [number] ID des Händlers im Gebäude
-- @return [number] Entity ID des Lagerhaus
-- @within Anwenderfunktionen
--
function API.GetOfferAndTrader(_PlayerID, _GoodorEntityType)
    if GUI then
        API.Log("Can not execute API.GetOfferAndTrader in local script!");
        return;
    end
    return BundleTradingFunctions.Global:GetOfferAndTrader(_PlayerID, _GoodorEntityType);
end

---
-- Gibt den Typ des Händlers mit der ID im Gebäude zurück.
--
-- @param _BuildingID [number] Building ID
-- @param _TraderID [number] Trader ID
-- @return [number]
-- @within Anwenderfunktionen
--
function API.GetTraderType(_BuildingID, _TraderID)
    if GUI then
        API.Log("Can not execute API.GetTraderType in local script!");
        return;
    end
    return BundleTradingFunctions.Global:GetTraderType(_BuildingID, _TraderID);
end

---
-- Gibt den Händler des Typs in dem Gebäude zurück.
--
-- @param _BuildingID [number] Entity ID des Handelsgebäudes
-- @param _TraderType [number] Typ des Händlers
-- @return [number]
-- @within Anwenderfunktionen
--
function API.GetTrader(_BuildingID, _TraderType)
    if GUI then
        API.Log("Can not execute API.GetTrader in local script!");
        return;
    end
    return BundleTradingFunctions.Global:GetTrader(_BuildingID, _TraderType);
end

---
-- Entfernt das Angebot mit dem Index für den Händler im Handelsgebäude
-- des Spielers.
--
-- @param _PlayerID [number] Entity ID des Handelsgebäudes
-- @param _TraderType [number] Typ des Händlers
-- @param _OfferIndex [number] Index des Angebots
-- @within Anwenderfunktionen
--
function API.RemoveOfferByIndex(_PlayerID, _TraderType, _OfferIndex)
    if GUI then
        API.Bridge("API.RemoveOfferByIndex(" .._PlayerID.. ", " .._TraderType.. ", " .._OfferIndex.. ")");
        return;
    end
    return BundleTradingFunctions.Global:RemoveOfferByIndex(_PlayerID, _TraderType, _OfferIndex);
end

---
-- Entfernt das Angebot vom Lagerhaus des Spielers, wenn es vorhanden
-- ist. Es wird immer nur das erste Angebot des Typs entfernt.
--
-- @param _PlayerID [number] Player ID
-- @param _GoodorEntityType [number] Warentyp oder Entitytyp
-- @within Anwenderfunktionen
--
function API.RemoveOffer(_PlayerID, _GoodOrEntityType)
    if GUI then
        API.Bridge("API.RemoveOffer(" .._PlayerID.. ", " .._GoodOrEntityType.. ")");
        return;
    end
    return BundleTradingFunctions.Global:RemoveOffer(_PlayerID, _GoodOrEntityType);
end

---
-- Ändert die maximale Menge des Angebots im Händelrgebäude.
-- TODO Muss noch getestet werden!
--
-- @param _PlayerID	[number] Händlergebäude
-- @param _GoodOrEntityType	[number] ID des Händlers im Gebäude
-- @param _NewAmount [number] Neue Menge an Angeboten
-- @within Anwenderfunktionen
--
function API.ModifyTraderOffer(_PlayerID, _GoodOrEntityType, _NewAmount)
    if GUI then
        API.Bridge("API.ModifyTraderOffer(" .._PlayerID.. ", " .._GoodOrEntityType.. ", " .._NewAmount.. ")");
        return;
    end
    return BundleTradingFunctions.Global:ModifyTraderOffer(_PlayerID, _GoodOrEntityType, _NewAmount);
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
function API.TravelingSalesmanActivate(_PlayerID, _Offers, _Waypoints, _Reversed, _Appearance)
    if GUI then
        API.Log("Can not execute API.TravelingSalesmanActivate in local script!");
        return;
    end
    return BundleTradingFunctions.Global:TravelingSalesman_Create(_PlayerID, _Offers, _Appearance, _Waypoints, _Reversed);
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

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleTradingFunctions = {
    Global = {
        Data = {},
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
        local OfferID, TraderID, StorehouseID = BundleTradingFunctions.Global:GetOfferAndTrader(_PlayerID, _GoodType);
        if OfferID then
            API.Dbg("Good offer for good type " .._GoodType.. " already exists for player " .._PlayerID.. "!");
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
        return Logic.AddGoodTraderOffer(MerchantID,_NumberOfOffers,Goods.G_Gold,0,_GoodType,offerAmount,_optionalPlayersPlayerID,_RefreshRate,MarketerType,Entities.U_ResourceMerchant);
    end

    ---
    -- Erzeugt ein Handelsangebot für Söldner und gibt die ID zurück.
    --
    -- @param _Merchant [number] Handelsgebäude
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

        local PlayerID = Logic.EntityGetPlayer(MerchantID);
        local OfferID, TraderID, StorehouseID = BundleTradingFunctions.Global:GetOfferAndTrader(PlayerID, _Type);
        if OfferID then
            API.Dbg("Mercenary offer for type " .._Type.. " already exists for player " ..PlayerID.. "!");
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
        return Logic.AddMercenaryTraderOffer(MercenaryID, _Amount, Goods.G_Gold, 3, _Type ,amount,_optionalPlayersPlayerID,_RefreshRate);
    end

    ---
    -- Erzeugt ein Handelsangebot für Entertainer und gibt die
    -- ID zurück.
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
        local OfferID, TraderID, StorehouseID = BundleTradingFunctions.Global:GetOfferAndTrader(PlayerID, _Type);
        if OfferID then
            API.Dbg("Entertainer offer for type " .._Type.. " already exists for player " ..PlayerID.. "!");
            return;
        end

        if _EntertainerType == nil then
            _EntertainerType = Entities.U_Entertainer_NA_FireEater;
        end
        if _optionalPlayersPlayerID == nil then
            _optionalPlayersPlayerID = 1;
        end
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
    MerchantSystem.BasePrices[Entities.U_MilitarySword_Khana] = MerchantSystem.BasePrices[Entities.U_MilitarySword_Khana] or 150;
    MerchantSystem.BasePrices[Entities.U_MilitarySword] = MerchantSystem.BasePrices[Entities.U_MilitarySword] or 150;
    MerchantSystem.BasePrices[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.BasePrices[Entities.U_MilitaryBow_RedPrince] or 220;
    MerchantSystem.BasePrices[Entities.U_MilitaryBow] = MerchantSystem.BasePrices[Entities.U_MilitaryBow] or 220;

    MerchantSystem.RefreshRates[Entities.U_CatapultCart] = MerchantSystem.RefreshRates[Entities.U_CatapultCart] or 270;
    MerchantSystem.RefreshRates[Entities.U_BatteringRamCart] = MerchantSystem.RefreshRates[Entities.U_BatteringRamCart] or 190;
    MerchantSystem.RefreshRates[Entities.U_SiegeTowerCart] = MerchantSystem.RefreshRates[Entities.U_SiegeTowerCart] or 220;
    MerchantSystem.RefreshRates[Entities.U_AmmunitionCart] = MerchantSystem.RefreshRates[Entities.U_AmmunitionCart] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.RefreshRates[Entities.U_MilitarySword_RedPrince] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] = MerchantSystem.RefreshRates[Entities.U_MilitarySword_Khana] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitarySword] = MerchantSystem.RefreshRates[Entities.U_MilitarySword] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow] or 150;

    if g_GameExtraNo >= 1 then
        MerchantSystem.BasePrices[Entities.U_MilitaryBow_Khana] = MerchantSystem.BasePrices[Entities.U_MilitaryBow_Khana] or 220;
        MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] or 150;
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
-- @usage BundleTradingFunctions.Global:GetOfferInformation(2);
--
-- -- Ausgabe:
-- -- Info = {
-- --      Player = 2,
-- --      Storehouse = 26796.
-- --      OfferCount = 2,
-- --      {
-- --          {TraderID = 0, OfferID = 0, GoodType = Goods.G_Gems,
-- --           OfferGoodAmount = 9, OfferAmount = 2},
-- --          {TraderID = 0, OfferID = 1, GoodType = Goods.G_Milk,
-- --           OfferGoodAmount = 9, OfferAmount = 4},
-- --      },
-- -- }
--
function BundleTradingFunctions.Global:GetOfferInformation(_PlayerID)
    local BuildingID = Logic.GetStoreHouse(_PlayerID);
    if not IsExisting(BuildingID)
    then
        return;
    end

    -- Initialisieren
    local OfferInformation = {
        Player      = _PlayerID,
        Storehouse  = BuildingID,
        OfferCount  = 0,
    };

    -- Angebote aller Händler im Gebäude durchgehen
    local AmountOfOffers = 0;
    local TradersCount = Logic.GetNumberOfMerchants(BuildingID);
    for i= 0, TradersCount-1, 1
    do

        local TraderTypeOffers = {};
        local Offers = {Logic.GetMerchantOfferIDs(BuildingID, i, _PlayerID)};
        for j = 1, #Offers
        do
            AmountOfOffers = AmountOfOffers +1;

            local GoodType, OfferGoodAmount, OfferAmount, AmountPrices;
            local TraderType = Module_TradingTools.Global.GetTraderType(i);
            if TraderType == QSB.TraderTypes.GoodTrader then
                GoodType, OfferGoodAmount, OfferAmount, AmountPrices = Logic.GetGoodTraderOffer(BuildingID, Offers[j], _PlayerID);
            elseif TraderType == QSB.TraderTypes.MercenaryTrader then
                GoodType, OfferGoodAmount, OfferAmount, AmountPrices = Logic.GetMercenaryOffer(BuildingID, Offers[j], _PlayerID);
            else
                GoodType, OfferGoodAmount, OfferAmount, AmountPrices = Logic.GetEntertainerTraderOffer(BuildingID, Offers[j], _PlayerID);
            end

            table.insert(TraderTypeOffers, {
                TraderID        = i,
                OfferID         = Offers[j],
                GoodType        = GoodType,
                OfferGoodAmount = OfferGoodAmount,
                OfferAmount     = OfferAmount,
            });
        end
        table.insert(OfferInformation, TraderTypeOffers);
    end

    -- Menge speichern
    OfferInformation.OfferCount = AmountOfOffers;
    return OfferInformation;
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
    local Offers = self:GetOfferInformation(_PlayerID);
    return Offers.OfferCount;
end

---
-- Gibt Offer ID und Trader ID und ID des Lagerhaus des Angebots für
-- den Spieler zurück. Es wird immer das erste Angebot zurückgegeben.
--
-- @param _PlayerID [number] Player ID
-- @param _GoodType [number] Warentyp oder Entitytyp
-- @return [number] Offer ID
-- @return [number] Trader ID
-- @return [number] Storehouse ID
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:GetOfferAndTrader(_PlayerID, _GoodorEntityType)
    local Info = self:GetOfferInformation(_PlayerID);
    for i=1, #Info, 1 do
        for j=1, #Info, 1 do
          if Info[i][j].GoodType == _GoodorEntityType then
              return Info[i][j].OfferID, Info[i][j].TraderID, Info.Storehouse;
          end
        end
    end
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
    if Logic.IsGoodTrader(BuildingID, _TraderID) == true
    then
        return QSB.TraderTypes.GoodTrader;
    elseif Logic.IsMercenaryTrader(BuildingID, _TraderID) == true
    then
        return QSB.TraderTypes.MercenaryTrader;
    elseif Logic.IsMercenaryTrader(BuildingID, _TraderID) == true
    then
        return QSB.TraderTypes.EntertainerTrader;
    else
        return QSB.TraderTypes.Unknown;
    end
end

---
-- Gibt den Händler des Typs in dem Gebäude zurück.
--
-- @param _BuildingID [number] Entity ID des Handelsgebäudes
-- @param _TraderType [number] Typ des Händlers
-- @return number
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:GetTrader(_BuildingID, _TraderType)
    local TraderID;
    local TradersCount = Logic.GetNumberOfMerchants(BuildingID);
    for i= 0, TradersCount-1, 1
    do
        if self:GetTraderType(BuildingID) == _TraderType
        then
            TraderID = i;
            break;
        end
    end
    return TraderID;
end

---
-- Entfernt das Angebot mit dem Index für den Händler im Handelsgebäude
-- des Spielers.
--
-- @param _PlayerID [number] Player ID des Handelsgebäudes
-- @param _TraderType [number] Typ des Händlers
-- @param _OfferIndex [number] Index des Angebots
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:RemoveOfferByIndex(_PlayerID, _TraderType, _OfferIndex)
    local BuildingID = Logic.GetStoreHouse(_PlayerID);
    if not IsExisting(BuildingID)
    then
        return;
    end

    _OfferIndex = _OfferIndex or 0;
    local TraderID = self:GetTrader(_PlayerID, _TraderType);
    if TraderID ~= nil
    then
        Logic.RemoveOffer(BuildingID, TraderID, _OfferIndex);
    end
end

---
-- Entfernt das Angebot vom Lagerhaus des Spielers, wenn es vorhanden
-- ist. Es wird immer nur das erste Angebot des Typs entfernt.
--
-- @param _PlayerID [number] Player ID
-- @param _GoodorEntityType [number] Warentyp oder Entitytyp
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:RemoveOffer(_PlayerID, _GoodOrEntityType)
    local OfferID, TraderID, Storehouse = self:GetOfferAndTrader(_PlayerID, _GoodOrEntityType);
    if OfferID and TraderID and Storehouse
    then
        Logic.RemoveOffer(Storehouse, TraderID, OfferID);
    end
end

---
-- Ändert die maximale Menge des Angebots im Händelrgebäude.
-- TODO Test this Shit!
--
-- @param _PlayerID	[number] Händlergebäude
-- @param _GoodOrEntityType	[number] ID des Händlers im Gebäude
-- @param _NewAmount [number] Neue Menge an Angeboten
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:ModifyTraderOffer(_PlayerID, _GoodOrEntityType, _NewAmount)
    local TraderID, OfferID, BuildingID = self:GetOfferAndTrader(_PlayerID, _GoodorEntityType);
    if not IsExisting(BuildingID) then
        return;
    end
    Logic.ModifyTraderOffer(BuildingID, TraderID, OfferID, _NewAmount);
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
-- @param _Offers	  Liste an Angeboten
-- @param _Appearance Wartezeit
-- @param _Waypoints  Wegpunktliste Anfahrt
-- @param _Reversed   Wegpunktliste Abfahrt
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:TravelingSalesman_Create(_PlayerID, _Offers, _Appearance, _Waypoints, _Reversed)
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
-- Setzt die Angebote des Fliegenden Händlers.
--
-- @param _PlayerID [number] Spieler-ID des Händlers
-- @within Internal
-- @local
--
function BundleTradingFunctions.Global:TravelingSalesman_AddOffer(_PlayerID)
    MerchantSystem.TradeBlackList[_PlayerID] = {};
    MerchantSystem.TradeBlackList[_PlayerID][0] = #MerchantSystem.TradeBlackList[3];

    local traderId = Logic.GetStoreHouse(_PlayerID);
    local rand = 1;
    if #QSB.TravelingSalesman.Harbors[_PlayerID].Offer > 1 then
        repeat
            rand = math.random(1,#QSB.TravelingSalesman.Harbors[_PlayerID].Offer);
        until (rand ~= QSB.TravelingSalesman.Harbors[_PlayerID].LastOffer);
    end
    QSB.TravelingSalesman.Harbors[_PlayerID].LastOffer = rand;
    local offer = QSB.TravelingSalesman.Harbors[_PlayerID].Offer[rand];
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
                AddOffer(traderId,amount,Goods[offerType],9999);
            else
                if Logic.IsEntityTypeInCategory(Entities[offerType],EntityCategories.Military)== 0 then
                    AddEntertainerOffer(traderId,Entities[offerType]);
                else
                    local amount = offer[i][2];
                    AddMercenaryOffer(traderId,amount,Entities[offerType],9999);
                end
            end
        end
    end

    if QSB.TravelingSalesman.Harbors[_PlayerID].AlterDiplomacy then
        SetDiplomacyState(self:TravelingSalesman_GetHumanPlayer(), _PlayerID, DiplomacyStates.TradeContact);
    end
    ActivateMerchantPermanentlyForPlayer(Logic.GetStoreHouse(_PlayerID), self:TravelingSalesman_GetHumanPlayer());

    local doIt = (IsBriefingActive and not IsBriefingActive()) or true
    if doIt then
        local Text = { de = "Ein Schiff hat angelegt. Es bringt Güter von weit her.",
                       en = "A ship is at the pier. It deliver goods from far away."};
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";

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

