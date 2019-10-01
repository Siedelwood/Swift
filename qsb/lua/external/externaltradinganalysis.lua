-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia ExternalTradingAnalysis                                      # --
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
-- @within Modulbeschreibung
-- @set sort=true
--
ExternalTradingAnalysis = {};

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
        API.Fatal("Can not execute API.GetOfferInformation in local script!");
        return;
    end
    return ExternalTradingAnalysis.Global:GetStorehouseInformation(_PlayerID);
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
        API.Fatal("Can not execute API.GetOfferCount in local script!");
        return;
    end
    return ExternalTradingAnalysis.Global:GetOfferCount(_PlayerID);
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
        API.Fatal("Can not execute API.IsGoodOrUnitOffered in local script!");
        return;
    end
    local OfferID, TraderID = ExternalTradingAnalysis.Global:GetOfferAndTrader(_PlayerID, _GoodOrEntityType);
    return OfferID ~= 1 and TraderID ~= 1;
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
        API.Bridge("API.RemoveTradeOffer(" .._PlayerID.. ", " .._GoodOrEntityType.. ")");
        return;
    end
    return ExternalTradingAnalysis.Global:RemoveTradeOffer(_PlayerID, _GoodOrEntityType);
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
        API.Bridge("API.ModifyTradeOffer(" .._PlayerID.. ", " .._GoodOrEntityType.. ", " .._NewAmount.. ")");
        return;
    end
    return ExternalTradingAnalysis.Global:ModifyTradeOffer(_PlayerID, _GoodOrEntityType, _NewAmount);
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

ExternalTradingAnalysis = {
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
function ExternalTradingAnalysis.Global:Install()
    self.OverwriteOfferFunctions();
    self.OverwriteBasePricesAndRefreshRates();
end

---
-- Überschreibt die Funktionen für Standardangebote.
--
-- @within Internal
-- @local
--
function ExternalTradingAnalysis.Global:OverwriteOfferFunctions()
    ---
    -- Erzeugt ein Handelsangebot für Waren und gibt die ID zurück.
    --
    -- <b>Hinweis</b>: Jeder Angebotstyp kann nur 1 Mal pro Lagerhaus
    -- angeboten werden.
    --
    -- @param[type=number] _Merchant  Handelsgebäude
    -- @param[type=number] _NumberOfOffers Anzahl an Angeboten
    -- @param[type=number] _GoodType Warentyp
    -- @param[type=number] _RefreshRate Erneuerungsrate
    -- @param[type=number] _optionalPlayersPlayerID Optionale Spieler-ID
    -- @return[type=number] Offer ID
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
        local OfferID, TraderID = ExternalTradingAnalysis.Global:GetOfferAndTrader(PlayerID, _GoodType);
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

        ExternalTradingAnalysis.Global.Data.PlayerOffersAmount[PlayerID][_GoodType] = _NumberOfOffers;
        return Logic.AddGoodTraderOffer(MerchantID,_NumberOfOffers,Goods.G_Gold,0,_GoodType,offerAmount,_optionalPlayersPlayerID,_RefreshRate,MarketerType,Entities.U_ResourceMerchant);
    end

    ---
    -- Erzeugt ein Handelsangebot für Söldner und gibt die ID zurück.
    --
    -- <b>Hinweis</b>: Jeder Angebotstyp kann nur 1 Mal pro Lagerhaus
    -- angeboten werden.
    --
    -- @param[type=number] _Mercenary Handelsgebäude
    -- @param[type=number] _Amount Anzahl an Angeboten
    -- @param[type=number] _Type Soldatentyp
    -- @param[type=number] _RefreshRate Erneuerungsrate
    -- @param[type=number] _optionalPlayersPlayerID Optionale Spieler-ID
    -- @return[type=number] Offer ID
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
        local OfferID, TraderID = ExternalTradingAnalysis.Global:GetOfferAndTrader(PlayerID, _Type);
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

        ExternalTradingAnalysis.Global.Data.PlayerOffersAmount[PlayerID][_Type] = _Amount;
        return Logic.AddMercenaryTraderOffer(MercenaryID, _Amount, Goods.G_Gold, 3, _Type ,amount,_optionalPlayersPlayerID,_RefreshRate);
    end

    ---
    -- Erzeugt ein Handelsangebot für Entertainer und gibt die
    -- ID zurück.
    --
    -- <b>Hinweis</b>: Jeder Angebotstyp kann nur 1 Mal pro Lagerhaus
    -- angeboten werden.
    --
    -- @param[type=number] _Merchant Handelsgebäude
    -- @param[type=number] _EntertainerType Typ des Entertainer
    -- @param[type=number] _optionalPlayersPlayerID Optionale Spieler-ID
    -- @return[type=number] Offer ID
    -- @within Originalfunktionen
    --
    AddEntertainerOffer = function(_Merchant, _EntertainerType, _optionalPlayersPlayerID)
        local MerchantID = GetID(_Merchant);
        local NumberOfOffers = 1;

        local PlayerID = Logic.EntityGetPlayer(MerchantID);
        local OfferID, TraderID = ExternalTradingAnalysis.Global:GetOfferAndTrader(PlayerID, _EntertainerType);
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

        ExternalTradingAnalysis.Global.Data.PlayerOffersAmount[PlayerID][_EntertainerType] = 1;
        return Logic.AddEntertainerTraderOffer(MerchantID,NumberOfOffers,Goods.G_Gold,0,_EntertainerType, _optionalPlayersPlayerID,0);
    end
end

---
-- Fügt fehlende Einträge für Militäreinheiten bei den Basispreisen
-- und Erneuerungsraten hinzu, damit diese gehandelt werden können.
-- @within Internal
-- @local
--
function ExternalTradingAnalysis.Global:OverwriteBasePricesAndRefreshRates()
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
-- @param[type=number] _PlayerID Player ID
-- @return[type=table] Angebotsinformationen
-- @within Internal
-- @local
--
-- @usage ExternalTradingAnalysis.Global:GetStorehouseInformation(2);
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
function ExternalTradingAnalysis.Global:GetStorehouseInformation(_PlayerID)
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
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=number] Menge an Angeboten
-- @within Internal
-- @local
--
function ExternalTradingAnalysis.Global:GetOfferCount(_PlayerID)
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
-- @param[type=number] _PlayerID Player ID
-- @param[type=number] _GoodOrEntityType Warentyp oder Entitytyp
-- @return[type=number] Offer ID
-- @return[type=number] Trader ID
-- @return[type=number] Storehouse ID
-- @within Internal
-- @local
--
function ExternalTradingAnalysis.Global:GetOfferAndTrader(_PlayerID, _GoodOrEntityType)
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
-- @param[type=number] _BuildingID Building ID
-- @param[type=number] _TraderID Trader ID
-- @return[type=number] Händlertyp
-- @within Internal
-- @local
--
function ExternalTradingAnalysis.Global:GetTraderType(_BuildingID, _TraderID)
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
-- @param[type=number] _PlayerID Player ID
-- @param[type=number] _GoodOrEntityType Warentyp oder Entitytyp
-- @within Internal
-- @local
--
function ExternalTradingAnalysis.Global:RemoveTradeOffer(_PlayerID, _GoodOrEntityType)
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
-- @param[type=number] _PlayerID	     Händlergebäude
-- @param[type=number] _GoodOrEntityType ID des Händlers im Gebäude
-- @param[type=number] _NewAmount        Neue Menge an Angeboten
-- @within Internal
-- @local
--
function ExternalTradingAnalysis.Global:ModifyTradeOffer(_PlayerID, _GoodOrEntityType, _NewAmount)
    local OfferID, TraderID, BuildingID = self:GetOfferAndTrader(_PlayerID, _GoodOrEntityType);
    if not IsExisting(BuildingID) then
        return;
    end

    -- Menge == -1 oder Menge == nil bedeutet Maximum
    if _NewAmount == nil or _NewAmount == -1 then
        _NewAmount = self.Data.PlayerOffersAmount[_PlayerID][_GoodOrEntityType];
    end
    -- Werte größer als das Maximum werden nicht erneuert!
    if self.Data.PlayerOffersAmount[_PlayerID][_GoodOrEntityType] and self.Data.PlayerOffersAmount[_PlayerID][_GoodOrEntityType] < _NewAmount then
        _NewAmount = self.Data.PlayerOffersAmount[_PlayerID][_GoodOrEntityType];
    end
    Logic.ModifyTraderOffer(BuildingID, OfferID, _NewAmount, TraderID);
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("ExternalTradingAnalysis");

