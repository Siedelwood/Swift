-- -------------------------------------------------------------------------- --
-- Trading Core                                                               --
-- -------------------------------------------------------------------------- --

ModuleTradingCore = {
    Properties = {
        Name = "ModuleTradingCore",
    },

    Global = {
        Lambda = {},
        Event = {},
    },
    Local = {
        Lambda = {
            PurchaseTraderAbility = {},
            PurchaseBasePrice     = {},
            PurchaseInflation     = {},
            PurchaseAllowed       = {},
            SaleBasePrice         = {},
            SaleDeflation         = {},
            SaleAllowed           = {},
        },
        ShowKnightTraderAbility = true;
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {},
};

-- Global ------------------------------------------------------------------- --

function ModuleTradingCore.Global:OnGameStart()
    QSB.ScriptEvents.GoodsSold = API.RegisterScriptEvent("Event_GoodsSold", nil);
    QSB.ScriptEvents.GoodsPurchased = API.RegisterScriptEvent("Event_GoodsPurchased", nil);
end

function ModuleTradingCore.Global:SendEventGoodsPurchased(_TraderType, _Good, _P1, _P2, _Amount, _Price)
    API.SendScriptEvent(QSB.ScriptEvents.GoodsPurchased, _TraderType, _Good, _P1, _P2, _Amount, _Price);
end

function ModuleTradingCore.Global:SendEventGoodsSold(_Good, _P1, _P2, _Amount, _Price)
    API.SendScriptEvent(QSB.ScriptEvents.GoodsSold, _Good, _P1, _P2, _Amount, _Price);
end

-- Local -------------------------------------------------------------------- --

function ModuleTradingCore.Local:OnGameStart()
    QSB.ScriptEvents.GoodsSold = API.RegisterScriptEvent("Event_GoodsSold", nil);
    QSB.ScriptEvents.GoodsPurchased = API.RegisterScriptEvent("Event_GoodsPurchased", nil);

    self:OverrideMerchantComputePurchasePrice();
    self:OverrideMerchantComputeSellingPrice();
    self:OverrideMerchantSellGoodsClicked();
    self:OverrideMerchantPurchaseOfferClicked();
end

function ModuleTradingCore.Local:OverrideMerchantPurchaseOfferClicked()
    -- Set special conditions
    local PurchaseAllowedLambda = function(_P1, _P2, _Type, _Good, _Amount)
        return true;
    end
    self.Lambda.PurchaseAllowed.Default = PurchaseAllowedLambda;
    
    GUI_Merchant.OfferClicked = function(_ButtonIndex)
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local PlayerID   = GUI.GetPlayerID();
        local BuildingID = g_Merchant.ActiveMerchantBuilding;
        if BuildingID == 0 or BuyLock.Locked then
            return;
        end
        local PlayersMarketPlaceID  = Logic.GetMarketplace(PlayerID);
        local TraderPlayerID        = Logic.EntityGetPlayer(BuildingID);
        local TraderType            = g_Merchant.Offers[_ButtonIndex].TraderType;
        local OfferIndex            = g_Merchant.Offers[_ButtonIndex].OfferIndex;

        local CanBeBought = true;
        local GoodType, OfferGoodAmount, OfferAmount, AmountPrices = 0,0,0,0;
        if TraderType == g_Merchant.GoodTrader then
            GoodType, OfferGoodAmount, OfferAmount, AmountPrices = Logic.GetGoodTraderOffer(BuildingID, OfferIndex, PlayerID);
            if Logic.GetGoodCategoryForGoodType(GoodType) == GoodCategories.GC_Resource then
                if Logic.GetPlayerUnreservedStorehouseSpace(PlayerID) < OfferGoodAmount then
                    CanBeBought = false;
                    local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_MerchantStorehouseSpace");
                    Message(MessageText);
                end
            elseif Logic.GetGoodCategoryForGoodType(GoodType) == GoodCategories.GC_Animal then
                CanBeBought = true;
            else
                if Logic.CanFitAnotherMerchantOnMarketplace(PlayersMarketPlaceID) == false then
                    CanBeBought = false;
                    local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_MerchantMarketplaceFull");
                    Message(MessageText);
                end
            end
        elseif TraderType == g_Merchant.EntertainerTrader then
            GoodType, OfferGoodAmount, OfferAmount, AmountPrices = Logic.GetEntertainerTraderOffer(storehouse,offers[offerIndex],player);
            if Logic.CanFitAnotherEntertainerOnMarketplace(PlayersMarketPlaceID) == false then
                CanBeBought = false;
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_MerchantMarketplaceFull");
                Message(MessageText);
            end
        elseif TraderType == g_Merchant.MercenaryTrader then
            GoodType, OfferGoodAmount, OfferAmount, AmountPrices = Logic.GetMercenaryOffer(BuildingID, OfferIndex, PlayerID);
            local GoodTypeName        = Logic.GetGoodTypeName(GoodType);
            local CurrentSoldierCount = Logic.GetCurrentSoldierCount(PlayerID);
            local CurrentSoldierLimit = Logic.GetCurrentSoldierLimit(PlayerID);
            local SoldierSize;
            if GoodType == Entities.U_Thief then
                SoldierSize = 1;
            elseif string.find(GoodTypeName, "U_MilitarySword")
            or     string.find(GoodTypeName, "U_MilitaryBow") then
                SoldierSize = 6;
            elseif string.find(GoodTypeName, "Cart") then
                SoldierSize = 0;
            else
                SoldierSize = OfferGoodAmount;
            end
            if (CurrentSoldierCount + SoldierSize) > CurrentSoldierLimit then
                CanBeBought = false;
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_SoldierLimitReached");
                Message(MessageText);
            end
        end

        -- Special sales conditions
        if not ModuleTradingCore.Local.Lambda.PurchaseAllowed[TraderPlayerID] then
            CanBeBought = ModuleTradingCore.Local.Lambda.PurchaseAllowed[TraderPlayerID](TraderType, GoodType, PlayerID, TargetID, OfferGoodAmount, Price);
        else
            CanBeBought = ModuleTradingCore.Local.Lambda.PurchaseAllowed.Default(TraderType, GoodType, PlayerID, TargetID, OfferGoodAmount, Price);
        end
        if not CanBeBought then
            local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_GenericNotReadyYet");
            Message(MessageText);
            return;
        end

        if CanBeBought == true then
            local Price = ComputePrice( BuildingID, OfferIndex, PlayerID, TraderType);
            local GoldAmountInCastle = GetPlayerGoodsInSettlement(Goods.G_Gold, PlayerID);
            local PlayerSectorType = PlayerSectorTypes.Civil;
            local IsReachable = CanEntityReachTarget(PlayerID, Logic.GetStoreHouse(TraderPlayerID), Logic.GetStoreHouse(PlayerID), nil, PlayerSectorType);
            if IsReachable == false then
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_GenericUnreachable");
                Message(MessageText);
                return;
            end
            if Price <= GoldAmountInCastle then
                if Logic.GetGoodCategoryForGoodType(GoodType) == GoodCategories.GC_Animal then
                    local AnimalType = Entities.A_X_Sheep01;
                    if GoodType == Goods.G_Cow then
                        AnimalType = Entities.A_X_Cow01;
                    end
                    for i=1,5 do
                        GUI.CreateEntityAtBuilding(BuildingID, AnimalType, 0);
                    end
                end
                BuyLock.Locked = true;
                GUI.ChangeMerchantOffer(BuildingID, PlayerID, OfferIndex, Price);
                GUI.BuyMerchantOffer(BuildingID, PlayerID, OfferIndex);
                Sound.FXPlay2DSound("ui\\menu_click");
                if ModuleTradingCore.Local.ShowKnightTraderAbility then
                    StartKnightVoiceForPermanentSpecialAbility(Entities.U_KnightTrading);
                end

                API.SendScriptEvent(QSB.ScriptEvents.GoodsBought, TraderType, GoodType, PlayerID, TargetID, OfferGoodAmount, Price);
                GUI.SendScriptCommand(string.format(
                    "ModuleTradingCore.Global:SendEventGoodsPurchased(%d, %d, %d, %d, %d, %d)",
                    TraderType,
                    GoodType,
                    PlayerID,
                    TargetID,
                    OfferGoodAmount,
                    Price
                ));
            else
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_G_Gold");
                Message(MessageText);
            end
        end
    end
end

function ModuleTradingCore.Local:OverrideMerchantSellGoodsClicked()
    -- Set special conditions
    local SaleAllowedLambda = function(_P1, _P2, _Good, _Amount, _Price)
        return true;
    end
    self.Lambda.SaleAllowed.Default = SaleAllowedLambda;

    GUI_Trade.SellClicked = function()
        Sound.FXPlay2DSound( "ui\\menu_click");
        if g_Trade.GoodAmount == 0 then
            return;
        end
        local PlayerID = GUI.GetPlayerID();
        local ButtonIndex = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetWidgetsMotherID(XGUIEng.GetCurrentWidgetID())));
        local TargetID = g_Trade.TargetPlayers[ButtonIndex];
        local PlayerSectorType = PlayerSectorTypes.Civil;
        if g_Trade.GoodType == Goods.G_Gold then
            PlayerSectorType = PlayerSectorTypes.Thief;
        end
        local IsReachable = CanEntityReachTarget(TargetID, Logic.GetStoreHouse(PlayerID), Logic.GetStoreHouse(TargetID), nil, PlayerSectorType);
        if IsReachable == false then
            local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_GenericUnreachable");
            Message(MessageText);
            return;
        end
        if g_Trade.GoodType == Goods.G_Gold then
            -- check for treasury space in castle
        elseif Logic.GetGoodCategoryForGoodType(g_Trade.GoodType) == GoodCategories.GC_Resource then
            local SpaceForNewGoods = Logic.GetPlayerUnreservedStorehouseSpace(TargetID);
            if SpaceForNewGoods < g_Trade.GoodAmount then
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_TargetFactionStorehouseSpace");
                Message(MessageText);
                return;
            end
        else
            if Logic.GetNumberOfTradeGatherers(PlayerID) >= 1 then
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_TradeGathererUnderway");
                Message(MessageText);
                return;
            end
            if Logic.CanFitAnotherMerchantOnMarketplace(Logic.GetMarketplace(TargetID)) == false then
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_TargetFactionMarketplaceFull");
                Message(MessageText);
                return;
            end
        end
    
        local Price;
        if Logic.PlayerGetIsHumanFlag(TargetID) then
            Price = 0;
        else
            Price = GUI_Trade.ComputeSellingPrice(TargetID, g_Trade.GoodType, g_Trade.GoodAmount);
            Price = Price / g_Trade.GoodAmount;
        end

        -- Special sales conditions
        local CanBeSold = true;
        if not ModuleTradingCore.Local.Lambda.SaleAllowed[TargetID] then
            CanBeSold = ModuleTradingCore.Local.Lambda.SaleAllowed[TargetID](PlayerID, TargetID, g_Trade.GoodType, g_Trade.GoodAmount, Price);
        else
            CanBeSold = ModuleTradingCore.Local.Lambda.SaleAllowed.Default(PlayerID, TargetID, g_Trade.GoodType, g_Trade.GoodAmount, Price);
        end
        if not CanBeSold then
            local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_GenericNotReadyYet");
            Message(MessageText);
            return;
        end

        GUI.StartTradeGoodGathering(PlayerID, TargetID, g_Trade.GoodType, g_Trade.GoodAmount, Price);
        GUI_FeedbackSpeech.Add("SpeechOnly_CartsSent", g_FeedbackSpeech.Categories.CartsUnderway, nil, nil);
        StartKnightVoiceForPermanentSpecialAbility(Entities.U_KnightTrading);
        
        if Price ~= 0 then
            if g_Trade.SellToPlayers[TargetID] == nil then
                g_Trade.SellToPlayers[TargetID] = {};
            end
    
            if g_Trade.SellToPlayers[TargetID][g_Trade.GoodType] == nil then
                g_Trade.SellToPlayers[TargetID][g_Trade.GoodType] = g_Trade.GoodAmount;
            else
                g_Trade.SellToPlayers[TargetID][g_Trade.GoodType] = g_Trade.SellToPlayers[TargetID][g_Trade.GoodType] + g_Trade.GoodAmount;
            end

            API.SendScriptEvent(QSB.ScriptEvents.GoodsSold, g_Trade.GoodType, PlayerID, TargetID, g_Trade.GoodAmount, Price);
            GUI.SendScriptCommand(string.format(
                "ModuleTradingCore.Global:SendEventGoodsSold(%d, %d, %d, %d, %d)",
                g_Trade.GoodType,
                PlayerID,
                TargetID,
                g_Trade.GoodAmount,
                Price
            ));
        end
    end
end

function ModuleTradingCore.Local:OverrideMerchantComputePurchasePrice()
    -- Override factor of hero ability
    local AbilityTraderLambda = function(_BasePrice, _PlayerID, _TraderPlayerID)
        local Modifier = Logic.GetKnightTraderAbilityModifier(_PlayerID);
        return math.ceil(_BasePrice / Modifier);
    end
    self.Lambda.PurchaseTraderAbility.Default = AbilityTraderLambda;

    -- Override base price calculation
    local BasePriceLambda = function(_GoodType, _PlayerID, _TraderPlayerID)
        local BasePrice = MerchantSystem.BasePrices[_GoodType];
        return (BasePrice == nil and 3) or BasePrice;
    end
    self.Lambda.PurchaseBasePrice.Default = BasePriceLambda;

    -- Override max inflation
    local InflationLambda = function(_OfferCount, _Price, _PlayerID, _TraderPlayerID)
        _OfferCount = (_OfferCount > 8 and 8) or _OfferCount;
        local Result = _Price + (math.ceil(_Price / 4) * _OfferCount);
        return (Result < _Price and _Price) or Result;
    end
    self.Lambda.PurchaseInflation.Default = InflationLambda;
    
    -- Override function
    ComputePrice = function(BuildingID, OfferID, PlayerID, TraderType)
        local TraderPlayerID = Logic.EntityGetPlayer(BuildingID);
        local Type = Logic.GetGoodOfOffer(BuildingID, OfferID, PlayerID, TraderType);
        
        -- Calculate the base price
        local BasePrice;
        if ModuleTradingCore.Local.Lambda.PurchaseBasePrice[TraderPlayerID] then
            BasePrice = ModuleTradingCore.Local.Lambda.PurchaseBasePrice[TraderPlayerID](Type, PlayerID, TraderPlayerID)
        else
            BasePrice = ModuleTradingCore.Local.Lambda.PurchaseBasePrice.Default(Type, PlayerID, TraderPlayerID)
        end
        
        -- Calculate price
        local Price
        if ModuleTradingCore.Local.Lambda.PurchaseTraderAbility[TraderPlayerID] then
            Price = ModuleTradingCore.Local.Lambda.PurchaseTraderAbility[TraderPlayerID](BasePrice, PlayerID, TraderPlayerID)
        else
            Price = ModuleTradingCore.Local.Lambda.PurchaseTraderAbility.Default(BasePrice, PlayerID, TraderPlayerID)
        end
        
        -- Invoke price inflation
        local OfferCount = Logic.GetOfferCount(BuildingID, OfferID, PlayerID, TraderType);
        local FinalPrice;
        if ModuleTradingCore.Local.Lambda.PurchaseInflation[TraderPlayerID] then
            FinalPrice = ModuleTradingCore.Local.Lambda.PurchaseInflation[TraderPlayerID](OfferCount, Price, PlayerID, TraderPlayerID);
        else
            FinalPrice = ModuleTradingCore.Local.Lambda.PurchaseInflation.Default(OfferCount, Price, PlayerID, TraderPlayerID);
        end
        return FinalPrice;
    end
end

function ModuleTradingCore.Local:OverrideMerchantComputeSellingPrice()
    -- Override base price calculation
    local BasePriceLambda = function(_GoodType, _PlayerID, _TargetPlayerID)
        local BasePrice = MerchantSystem.BasePrices[_GoodType];
        return (BasePrice == nil and 3) or BasePrice;
    end
    self.Lambda.SaleBasePrice.Default = PriceLambda;

    -- Override max deflation
    local DeflationLambda = function(_Price, _PlayerID, _TargetPlayerID)
        return _Price - math.ceil(_Price / 4);
    end
    self.Lambda.SaleDeflation.Default = DeflationLambda;
    
    GUI_Trade.ComputeSellingPrice = function(_TargetPlayerID, _GoodType, _GoodAmount)
        if _GoodType == Goods.G_Gold then
            return 0;
        end
        local PlayerID = GUI.GetPlayerID();
        local Waggonload = MerchantSystem.Waggonload;
        
        -- Calculate the base price
        local BasePrice;
        if ModuleTradingCore.Local.Lambda.SaleBasePrice[_TargetPlayerID] then
            BasePrice = ModuleTradingCore.Local.Lambda.SaleBasePrice[_TargetPlayerID](_GoodType, PlayerID, _TargetPlayerID);
        else
            BasePrice = ModuleTradingCore.Local.Lambda.SaleBasePrice.Default(_GoodType, PlayerID, _TargetPlayerID);
        end

        local GoodsSoldToTargetPlayer = 0
        if  g_Trade.SellToPlayers[_TargetPlayerID] ~= nil
        and g_Trade.SellToPlayers[_TargetPlayerID][_GoodType] ~= nil then
            GoodsSoldToTargetPlayer = g_Trade.SellToPlayers[_TargetPlayerID][_GoodType];
        end

        -- Calculate the max deflation
        local MaxToSubstract
        if ModuleTradingCore.Local.Lambda.SaleDeflation[_TargetPlayerID] then
            MaxToSubstract = ModuleTradingCore.Local.Lambda.SaleDeflation[_TargetPlayerID](BasePrice, PlayerID, _TargetPlayerID);
        else
            MaxToSubstract = ModuleTradingCore.Local.Lambda.SaleDeflation.Default(BasePrice, PlayerID, _TargetPlayerID);
        end

        local WaggonsToSell = math.ceil(_GoodAmount / Waggonload);
        local WaggonsSold = math.ceil(GoodsSoldToTargetPlayer / Waggonload);

        local PriceToSubtract = 0;
        for i = 1, WaggonsToSell do
            PriceToSubtract = PriceToSubtract + math.min(WaggonsSold * Modifier, MaxToSubstract);
            WaggonsSold = WaggonsSold + 1;
        end

        return (WaggonsToSell * BasePrice) - PriceToSubtract;
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleTradingCore);

