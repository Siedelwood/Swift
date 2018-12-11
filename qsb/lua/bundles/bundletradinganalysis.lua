-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleTradingAnalysis                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle bietet einige Funktionen zum untersuchen und
-- zur Manipulation von Handelsangeboten. Die bekannten Funktionen, wie z.B.
-- AddOffer, werden erweitert, sodass sie Angebote für einen Spieler mit einer
-- anderen ID als 1 erstellen können. Ein kann Händler nicht mehr
-- mehrere Angebote des gleichen Typs anbieten. Außerdem werden einige
-- Preise und Erneuerungsraten hinzugefügt.
--
-- Das wichtigste auf einen Blick:
-- <ul>
-- <li><a href="#API.GetOfferCount">Angebote zählen</a></li>
-- <li><a href="#API.IsGoodOrUnitOffered">Angebote prüfen</a></li>
-- <li><a href="#API.RemoveTradeOffer">Angebote einzeln löschen</a></li>
-- <li><a href="#API.ModifyTradeOffer">Angebote modifizieren</a></li>
-- </ul>
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleTradingAnalysis = {};

API = API or {};
QSB = QSB or {};

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
    return BundleTradingAnalysis.Global:GetStorehouseInformation(_PlayerID);
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
    return BundleTradingAnalysis.Global:GetOfferCount(_PlayerID);
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
    local OfferID, TraderID = BundleTradingAnalysis.Global:GetOfferAndTrader(_PlayerID, _GoodOrEntityType);
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
    return BundleTradingAnalysis.Global:RemoveTradeOffer(_PlayerID, _GoodOrEntityType);
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
    return BundleTradingAnalysis.Global:ModifyTradeOffer(_PlayerID, _GoodOrEntityType, _NewAmount);
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleTradingAnalysis = {
    Global = {
        Data = {
            PlayerOffersAmount = {
                [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {},
            };
        },
    },
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function BundleTradingAnalysis.Global:Install()
    self.OverwriteOfferFunctions();
    self.OverwriteBasePricesAndRefreshRates();
end

---
-- Überschreibt die Funktionen für Standardangebote.
--
-- @within Internal
-- @local
--
function BundleTradingAnalysis.Global:OverwriteOfferFunctions()
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
        local OfferID, TraderID = BundleTradingAnalysis.Global:GetOfferAndTrader(PlayerID, _GoodType);
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

        BundleTradingAnalysis.Global.Data.PlayerOffersAmount[PlayerID][_GoodType] = _NumberOfOffers;
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
        local OfferID, TraderID = BundleTradingAnalysis.Global:GetOfferAndTrader(PlayerID, _Type);
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

        BundleTradingAnalysis.Global.Data.PlayerOffersAmount[PlayerID][_Type] = _Amount;
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
        local OfferID, TraderID = BundleTradingAnalysis.Global:GetOfferAndTrader(PlayerID, _EntertainerType);
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

        BundleTradingAnalysis.Global.Data.PlayerOffersAmount[PlayerID][_EntertainerType] = 1;
        return Logic.AddEntertainerTraderOffer(MerchantID,NumberOfOffers,Goods.G_Gold,0,_EntertainerType, _optionalPlayersPlayerID,0);
    end
end

---
-- Fügt fehlende Einträge für Militäreinheiten bei den Basispreisen
-- und Erneuerungsraten hinzu, damit diese gehandelt werden können.
-- @within Internal
-- @local
--
function BundleTradingAnalysis.Global:OverwriteBasePricesAndRefreshRates()
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
-- @usage BundleTradingAnalysis.Global:GetStorehouseInformation(2);
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
function BundleTradingAnalysis.Global:GetStorehouseInformation(_PlayerID)
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
function BundleTradingAnalysis.Global:GetOfferCount(_PlayerID)
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
function BundleTradingAnalysis.Global:GetOfferAndTrader(_PlayerID, _GoodOrEntityType)
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
function BundleTradingAnalysis.Global:GetTraderType(_BuildingID, _TraderID)
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
function BundleTradingAnalysis.Global:RemoveTradeOffer(_PlayerID, _GoodOrEntityType)
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
function BundleTradingAnalysis.Global:ModifyTradeOffer(_PlayerID, _GoodOrEntityType, _NewAmount)
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

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleTradingAnalysis");
