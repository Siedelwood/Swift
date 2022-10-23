--[[
Swift_0_Core/Bugfixes

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- This portion of the QSB is reserved for fixing bugs in the game.

-- Initalize bugfixes in global env
function Swift:InitalizeBugfixesGlobal()
    self:FixResourceSlotsInStorehouses();
end

-- Reload bugfixes after loading in global env
function Swift:GlobalRestoreBugfixesAfterLoad()
    
end

-- Adds salt and dye to all storehouses. This fixes the problem that luxury
-- can not be sold to AI players.
function Swift:FixResourceSlotsInStorehouses()
    for i= 1, 8 do
        local StoreHouseID = Logic.GetStoreHouse(i);
        if StoreHouseID ~= 0 then
            Logic.AddGoodToStock(StoreHouseID, Goods.G_Salt, 0, true, true);
            Logic.AddGoodToStock(StoreHouseID, Goods.G_Dye, 0, true, true);
        end
    end
end

-- -------------------------------------------------------------------------- --

-- Initalize bugfixes in local env
function Swift:InitalizeBugfixesLocal()
    -- self:FixInteractiveObjectClicked();
end

function Swift:FixInteractiveObjectClicked()
    GUI_Interaction.InteractiveObjectClicked = function()
        local ButtonNumber = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()));
        local ObjectID = g_Interaction.ActiveObjectsOnScreen[ButtonNumber];
        if ObjectID == nil or not Logic.InteractiveObjectGetAvailability(ObjectID) then
            return;
        end
        local PlayerID = GUI.GetPlayerID();
        local Costs = {Logic.InteractiveObjectGetEffectiveCosts(ObjectID, PlayerID)};
        local CanNotBuyString = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources");

        -- Check activation costs
        local Affordable = true;
        if Affordable and Costs ~= nil and Costs[1] ~= nil then
            if Costs[1] == Goods.G_Gold then
                CanNotBuyString = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_G_Gold");
            end
            if Costs[1] ~= Goods.G_Gold and Logic.GetGoodCategoryForGoodType(Costs[1]) ~= GoodCategories.GC_Resource then
                error("Only resources can be used as costs for objects!");
                Affordable = false;
            end
            Affordable = Affordable and GetPlayerGoodsInSettlement(Costs[1], PlayerID, false) >= Costs[2];
        end
        if Affordable and Costs ~= nil and Costs[3] ~= nil then
            if Costs[3] == Goods.G_Gold then
                CanNotBuyString = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_G_Gold");
            end
            if Costs[3] ~= Goods.G_Gold and Logic.GetGoodCategoryForGoodType(Costs[3]) ~= GoodCategories.GC_Resource then
                error("Only resources can be used as costs for objects!");
                Affordable = false;
            end
            Affordable = Affordable and GetPlayerGoodsInSettlement(Costs[3], PlayerID, false) >= Costs[4];
        end
        if not Affordable then
            Message(CanNotBuyString);
            return;
        end

        -- Check click override
        if not GUI_Interaction.InteractionClickOverride
        or not GUI_Interaction.InteractionClickOverride(ObjectID) then
            Sound.FXPlay2DSound( "ui\\menu_click");
        end
        -- Check feedback speech override
        if not GUI_Interaction.InteractionSpeechFeedbackOverride
        or not GUI_Interaction.InteractionSpeechFeedbackOverride(ObjectID) then
            GUI_FeedbackSpeech.Add("SpeechOnly_CartsSent", g_FeedbackSpeech.Categories.CartsUnderway, nil, nil);
        end
        -- Check action override and perform action
        if not Mission_Callback_OverrideObjectInteraction
        or not Mission_Callback_OverrideObjectInteraction(ObjectID, PlayerID, Costs) then
            GUI.ExecuteObjectInteraction(ObjectID, PlayerID);
        end
    end
end

-- Reload bugfixes after loading in local env
function Swift:LocalRestoreBugfixesAfterLoad()
    
end

