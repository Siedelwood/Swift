--- 
-- Legacy Conversion of Swift_MOD_MapLoaderMap
--

ExternalEvilHeroes = {
	Global = {},
    Local = {
        Data = {
			CrimsonSabatt = {
				ActionPoints = 450,
				RechargeTime = 450,
				AbilityIcon = {11, 7},
			},
			RedPrince = {
				ActionPoints = 150,
				RechargeTime = 150,
				AbilityIcon = {5, 16},
			}
		},
	},

    Text = {},

    UpgradeCosts = {
        [Entities.B_Bakery]					= {4,2},
        [Entities.B_Dairy]					= {4,2},
        [Entities.B_Butcher]				= {4,2},
        [Entities.B_SmokeHouse]				= {4,2},
        [Entities.B_Soapmaker]				= {4,2},
        [Entities.B_BroomMaker]				= {4,2},
        [Entities.B_Pharmacy]				= {4,2},
        [Entities.B_Weaver]					= {4,2},
        [Entities.B_Tanner]					= {4,2},
        [Entities.B_Baths]					= {7,2},
        [Entities.B_Tavern]					= {7,2},
        [Entities.B_Theatre]				= {7,2},
        [Entities.B_SwordSmith]				= {8,2},
        [Entities.B_BowMaker]				= {8,2},
        [Entities.B_Barracks]				= {8,2},
        [Entities.B_BarracksArchers]		= {8,2},
        [Entities.B_SiegeEngineWorkshop]	= {8,2},
        [Entities.B_Blacksmith]				= {7,2},
        [Entities.B_CandleMaker]			= {7,2},
        [Entities.B_Carpenter]				= {7,2},
        [Entities.B_BannerMaker]			= {7,2},

        [Entities.B_HerbGatherer]			= {2,1},
        [Entities.B_Woodcutter]				= {2,1},
        [Entities.B_StoneQuarry]			= {2,1},
        [Entities.B_IronMine]				= {2,1},
        [Entities.B_HuntersHut]				= {2,1},
        [Entities.B_FishingHut]				= {2,1},
        [Entities.B_CattleFarm]				= {3,1},
        [Entities.B_GrainFarm]				= {3,1},
        [Entities.B_SheepFarm]				= {3,1},
        [Entities.B_Beekeeper]				= {3,1},

    }
}

-- Global Script ------------------------------------------------------------ --

function ExternalEvilHeroes.Global:Install()
end

function ExternalEvilHeroes.Global:UseCustomKnightAbility(_Hero)
	local EntityID = GetID(_Hero);
	local PlayerID = Logic.EntityGetPlayer(EntityID);
	local EntityType = Logic.GetEntityType(EntityID);
	if EntityType == Entities.U_KnightSabatta then
		self:CrimsonSabattKnightAbility(EntityID, PlayerID);
	elseif EntityType == Entities.U_KnightRedPrince then
		self:RedPrinceKnightAbility(EntityID, PlayerID);
	end
end

function ExternalEvilHeroes.Global:RedPrinceKnightAbility(_EntityID, _PlayerID)
    -- Get enemies
    local SettlersInArea = self:GetInfectableSettlers(_EntityID, 1500);
    if #SettlersInArea == 0 then
        Logic.ExecuteInLuaLocalState("ExternalEvilHeroes.Local.Data.RedPrince.ActionPoints = ExternalEvilHeroes.Local.Data.RedPrince.RechargeTime");
        return;
    end
    -- Infect
    -- TODO Create an actual plague
    for i= 1, #SettlersInArea, 1 do
        Logic.MakeSettlerIll(SettlersInArea[i]);
    end
    Logic.ExecuteInLuaLocalState(string.format("HeroAbilityFeedback(%d)", _EntityID));
	Logic.ExecuteInLuaLocalState(string.format("GUI.SendCommandStationaryDefend(%d)", _EntityID));
    self:SpawnAura(_EntityID, EGL_Effects.E_Knight_Wisdom_Aura);
end

function ExternalEvilHeroes.Global:CrimsonSabattKnightAbility(_EntityID, _PlayerID)
    -- Get enemies
    local EnemiesInArea = self:GetEnemiesInArea(_EntityID, 1000);
    if #EnemiesInArea == 0 then
        Logic.ExecuteInLuaLocalState("ExternalEvilHeroes.Local.Data.CrimsonSabatt.ActionPoints = ExternalEvilHeroes.Local.Data.CrimsonSabatt.RechargeTime");
        return;
    end
    -- Convert
    Logic.ChangeSettlerPlayerID(EnemiesInArea[1], _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format("HeroAbilityFeedback(%d)", _EntityID));
	Logic.ExecuteInLuaLocalState(string.format("GUI.SendCommandStationaryDefend(%d)", _EntityID));
    self:SpawnAura(_EntityID, EGL_Effects.E_Knight_Wisdom_Aura);
end

function ExternalEvilHeroes.Global:GetEnemiesInArea(_Hero, _Area)
    local EntityID = GetID(_Hero);
    local PlayerID = Logic.EntityGetPlayer(EntityID);
	local x, y, z  = Logic.EntityGetPos(EntityID);

	local EnemiesInArea = {};
    for i= 1, 8, 1 do
        if i ~= PlayerID and GetDiplomacyState(i, PlayerID) == -2 then
            local Found = {Logic.GetPlayerEntitiesInArea(i, Entities.U_MilitaryLeader, x, y, _Area, 16)};
            if table.remove(Found, 1) > 0 then
                EnemiesInArea = Array_Append(EnemiesInArea, Found);
            end
        end
	end
	return EnemiesInArea;
end

function ExternalEvilHeroes.Global:GetInfectableSettlers(_Hero, _Area)
    local EntityID = GetID(_Hero);
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    local OtherPlayers = {1, 2, 3, 4, 5, 6, 7, 8};
    table.remove(OtherPlayers, PlayerID);

    local Targets = API.GetEntitiesOfCategoriesInTerritories(
        OtherPlayers,
        {EntityCategories.Worker, EntityCategories.Spouse},
        {Logic.GetTerritories()}
    );

    for i= #Targets, 1, -1 do
        if GetDistance(_Hero, Targets[i]) > _Area then
            table.remove(Targets, i);
        end
    end
    return Targets;
end

function ExternalEvilHeroes.Global:SpawnAura(_Hero, _Aura)
    local x,y,z = Logic.EntityGetPos(GetID(_Hero));
    local ID = Logic.CreateEffect(_Aura, x, y, 0);
    StartSimpleJobEx( function(_ID, _Hero, _Time)
        if Logic.GetTime() > _Time or Logic.IsEntityMoving(GetID(_Hero)) then
            Logic.DestroyEffect(_ID);
            return true;
        end
    end, ID, _Hero, Logic.GetTime()+2);
end

-- Local Script ------------------------------------------------------------- --

function ExternalEvilHeroes.Local:Install()
    self:ShowRedPrinceAbilityExplaination();
	self:OverrideMethods();
    self:OverwriteComputePrices();
	self:OverrideEntityHurt();
end

function ExternalEvilHeroes.Local:OverrideEntityHurt()
    GameCallback_Feedback_EntityHurt_Orig_Legacy_EvilHero = GameCallback_Feedback_EntityHurt;
    GameCallback_Feedback_EntityHurt = function(_HurtPlayerID, _HurtEntityID, _HurtingPlayerID, _HurtingEntityID, _DamageReceived, _DamageDealt)
        GameCallback_Feedback_EntityHurt_Orig_Legacy_EvilHero(_HurtPlayerID, _HurtEntityID, _HurtingPlayerID, _HurtingEntityID, _DamageReceived, _DamageDealt);
        ExternalEvilHeroes.Local:SetActiveAbilityInformation(_HurtPlayerID, _HurtEntityID, _HurtingPlayerID, _HurtingEntityID, _DamageReceived, _DamageDealt);
    end
end

function ExternalEvilHeroes.Local:OverrideMethods()
    -- Feedback --

    g_MilitaryFeedback.Knights[Entities.U_KnightSabatta]	  = "H_Knight_Sabatt";
    g_HeroAbilityFeedback.Knights[Entities.U_KnightSabatta]   = "Sabatta";
    g_MilitaryFeedback.Knights[Entities.U_KnightRedPrince]    = "H_Knight_RedPrince";
    g_HeroAbilityFeedback.Knights[Entities.U_KnightRedPrince] = "RedPrince";

    -- Ability --

    GUI_Knight.AbilityProgressUpdate_Legacy_EvilHero = GUI_Knight.AbilityProgressUpdate;
    GUI_Knight.AbilityProgressUpdate = function()
        if not ExternalEvilHeroes.Local:SetKnightAbilityProgressUpdate() then
            GUI_Knight.AbilityProgressUpdate_Legacy_EvilHero();
        end
    end

    GUI_Knight.StartAbilityUpdate_Legacy_EvilHero = GUI_Knight.StartAbilityUpdate;
    GUI_Knight.StartAbilityUpdate = function()
        if not ExternalEvilHeroes.Local:SetKnightAbilityUpdate() then
            GUI_Knight.StartAbilityUpdate_Legacy_EvilHero();
        end
    end

    GUI_Knight.StartAbilityMouseOver_Legacy_EvilHero = GUI_Knight.StartAbilityMouseOver;
    GUI_Knight.StartAbilityMouseOver = function()
        if not ExternalEvilHeroes.Local:SetKnightAbilityTooltip() then
            GUI_Knight.StartAbilityMouseOver_Legacy_EvilHero();
        end
    end

    GUI_Knight.StartAbilityClicked_Legacy_EvilHero = GUI_Knight.StartAbilityClicked;
    GUI_Knight.StartAbilityClicked = function()
        if not ExternalEvilHeroes.Local:SetKnightAbilityAction() then
            GUI_Knight.StartAbilityClicked_Legacy_EvilHero();
        end
    end

    GUI_BuildingButtons.UpgradeClicked_Legacy_EvilHero = GUI_BuildingButtons.UpgradeClicked;
    GUI_BuildingButtons.UpgradeClicked = function()
        if ExternalEvilHeroes.Local:RedPrinceUpgradeBuildingClicked() then
            GUI_BuildingButtons.UpgradeClicked_Legacy_EvilHero();
        end
    end

    GUI_Merchant.OfferClicked_Legacy_EvilHero = GUI_Merchant.OfferClicked;
    GUI_Merchant.OfferClicked = function(_ButtonIndex)
        if not ExternalEvilHeroes.Local:ShowSabattPassiveAbilityInformation(_ButtonIndex) then
            GUI_Merchant.OfferClicked_Legacy_EvilHero(_ButtonIndex);
        end
    end

    GameCallback_Feedback_TaxCollectionFinished_Legacy_EvilHero = GameCallback_Feedback_TaxCollectionFinished;
    GameCallback_Feedback_TaxCollectionFinished = function(_PlayerID, _TaxCollected, _SkillBonus)
        if ExternalEvilHeroes.Local:RedPrincePassiveAbility(_PlayerID, _TaxCollected, _SkillBonus) then
            GameCallback_Feedback_TaxCollectionFinished_Legacy_EvilHero(_PlayerID, _TaxCollected, _SkillBonus);
        end
    end

    self:RedPrinceGetBuildingUpgradeCosts();

    -- Recharge Time
    StartSimpleJobEx(function()
        if ExternalEvilHeroes.Local.Data.CrimsonSabatt.ActionPoints < ExternalEvilHeroes.Local.Data.CrimsonSabatt.RechargeTime then
            ExternalEvilHeroes.Local.Data.CrimsonSabatt.ActionPoints = ExternalEvilHeroes.Local.Data.CrimsonSabatt.ActionPoints +1;
		end
		if ExternalEvilHeroes.Local.Data.RedPrince.ActionPoints < ExternalEvilHeroes.Local.Data.RedPrince.RechargeTime then
            ExternalEvilHeroes.Local.Data.RedPrince.ActionPoints = ExternalEvilHeroes.Local.Data.RedPrince.ActionPoints +1;
        end
    end);
end

function ExternalEvilHeroes.Local:SetActiveAbilityInformation(_HurtPlayerID, _HurtEntityID, _HurtingPlayerID, _HurtingEntityID, _DamageReceived, _DamageDealt)
    if Logic.GetEntityType(_HurtingEntityID) == Entities.U_KnightSabatta then
        if _HurtPlayerID > 0 then
            StartKnightVoiceForActionSpecialAbility(Entities.U_KnightSabatta);
        end
    end
end

function ExternalEvilHeroes.Local:ShowSabattPassiveAbilityInformation(_ButtonIndex)
    StartKnightVoiceForPermanentSpecialAbility(Entities.U_KnightSabatt);
    return true;
end

function ExternalEvilHeroes.Local:RedPrincePassiveAbility(_PlayerID, _TotalTaxAmountCollected, _AdditionalTaxesByAbility)
    local KnightID = Logic.GetKnightID(_PlayerID);
    if Logic.GetEntityType(KnightID) == Entities.U_KnightRedPrince then
        if Logic.GetHeadquarters(_PlayerID) > 0 then
            if _TotalTaxAmountCollected > 0 then
                local BonusOnTax = math.ceil(_TotalTaxAmountCollected * 0.2);
                GUI.SendScriptCommand("AddGood(Goods.G_Gold,"..BonusOnTax..",".._PlayerID..")")
                if _PlayerID == GUI.GetPlayerID() and Logic.GetCurrentTurn() > 10 then
                    GUI_FeedbackWidgets.GoldAdd(BonusOnTax, nil, {6,8});
                end
                StartKnightVoiceForPermanentSpecialAbility(Entities.U_KnightRedPrince);
            end
        end
        return true;
    end
end

function ExternalEvilHeroes.Local:RedPrinceUpgradeBuildingClicked()
    local PlayerID = GUI.GetPlayerID();
    local KnightID = Logic.GetKnightID(PlayerID);
    if Logic.GetEntityType(KnightID) == Entities.U_KnightRedPrince then
        local EntityID = GUI.GetSelectedEntity();
        if Logic.CanCancelUpgradeBuilding(EntityID) then
            Sound.FXPlay2DSound("ui\\menu_click");
            GUI.CancelBuildingUpgrade(EntityID);
            XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/BuildingButtons",1);
            return;
        end

        local Costs = GUI_BuildingButtons.GetUpgradeCosts();
        local CanBuyBoolean, CanNotBuyString = AreCostsAffordable(Costs);

        if CanBuyBoolean == true then
            Sound.FXPlay2DSound("ui\\menu_click");
            GUI.UpgradeBuilding(EntityID, 0);
            if ExternalEvilHeroes.UpgradeCosts[Logic.GetEntityType(EntityID)] ~= nil then
                local normCosts = Logic.GetBuildingUpgradeCostByGoodType(EntityID , Goods.G_Wood, 0);
                local baseCosts = ExternalEvilHeroes.UpgradeCosts[Logic.GetEntityType(EntityID)][1];
                local incrCosts = ExternalEvilHeroes.UpgradeCosts[Logic.GetEntityType(EntityID)][2];
                local UpgradeLevel = Logic.GetUpgradeLevel(EntityID)+1;
                local fullCosts = baseCosts + (incrCosts*UpgradeLevel);
                local toSubtract = fullCosts - normCosts;

                if toSubtract > 0 then
                    GUI.SendScriptCommand("RemoveResourcesFromPlayer(Goods.G_Wood,"..toSubtract..","..PlayerID..")");
                end
            end
        else
            Message(CanNotBuyString);
        end
        return true;
    end
end

function ExternalEvilHeroes.Local:RedPrinceGetBuildingUpgradeCosts()
    GUI_BuildingButtons.GetUpgradeCosts_Legacy_EvilHero = GUI_BuildingButtons.GetUpgradeCosts;
    GUI_BuildingButtons.GetUpgradeCosts = function()
        local PlayerID = GUI.GetPlayerID();
        local KnightID = Logic.GetKnightID(PlayerID);
        if Logic.GetEntityType(KnightID) == Entities.U_KnightRedPrince then
            local EntityID = GUI.GetSelectedEntity();
            local UpgradeLevel = Logic.GetUpgradeLevel(EntityID)+1;
            local StoneCost = Logic.GetBuildingUpgradeCostByGoodType(EntityID , Goods.G_Stone, 0);
            local GoldCost = Logic.GetBuildingUpgradeCostByGoodType(EntityID , Goods.G_Gold, 0);
            local WoodCost;

            if ExternalEvilHeroes.UpgradeCosts[Logic.GetEntityType(EntityID)] ~= nil then
                local BaseCosts = ExternalEvilHeroes.UpgradeCosts[Logic.GetEntityType(EntityID)][1];
                local IncrCosts = ExternalEvilHeroes.UpgradeCosts[Logic.GetEntityType(EntityID)][2];
                WoodCost = BaseCosts + (IncrCosts*UpgradeLevel);
            else
                WoodCost = Logic.GetBuildingUpgradeCostByGoodType(EntityID , Goods.G_Wood, 0);
            end
            return {Goods.G_Gold, GoldCost, Goods.G_Stone, StoneCost, Goods.G_Wood, WoodCost};
        end
        return GUI_BuildingButtons.GetUpgradeCosts_Legacy_EvilHero();
    end
end

function ExternalEvilHeroes.Local:SetKnightAbilityProgressUpdate()
    local WidgetID   = XGUIEng.GetCurrentWidgetID();
    local PlayerID   = GUI.GetPlayerID();
    local KnightID   = GUI.GetSelectedEntity();
    local KnightType = Logic.GetEntityType(KnightID);

	local TotalRechargeTime;
	local ActionPoints;
	if KnightType == Entities.U_KnightSabatta then
        TotalRechargeTime  = self.Data.CrimsonSabatt.RechargeTime;
		ActionPoints       = self.Data.CrimsonSabatt.ActionPoints;
	elseif KnightType == Entities.U_KnightRedPrince then
		TotalRechargeTime  = self.Data.RedPrince.RechargeTime;
		ActionPoints       = self.Data.RedPrince.ActionPoints;
	end

	if TotalRechargeTime ~= nil and ActionPoints ~= nil then
		local TimeAlreadyCharged = ActionPoints or TotalRechargeTime;
        TimeAlreadyCharged = (TimeAlreadyCharged > TotalRechargeTime and TotalRechargeTime) or TimeAlreadyCharged;
        if TimeAlreadyCharged == TotalRechargeTime then
            XGUIEng.SetMaterialColor(WidgetID, 0, 255, 255, 255, 0);
        else
            XGUIEng.SetMaterialColor(WidgetID, 0, 255, 255, 255, 150);
            local Progress = math.floor((TimeAlreadyCharged / TotalRechargeTime) * 100);
            XGUIEng.SetProgressBarValues(WidgetID, Progress + 10, 110);
		end
		return true;
	end
end

function ExternalEvilHeroes.Local:SetKnightAbilityUpdate()
    local WidgetID   = "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/StartAbility";
    local KnightID   = GUI.GetSelectedEntity();
    local KnightType = Logic.GetEntityType(KnightID);

	local Icon = {1, 1};
	local RechargeTime;
    local ActionPoints;
    local Disabled;
	if KnightType == Entities.U_KnightSabatta then
        if type(self.Data.CrimsonSabatt.AbilityIcon) == "table" then
            Icon = self.Data.CrimsonSabatt.AbilityIcon;
		end
        RechargeTime = self.Data.CrimsonSabatt.RechargeTime;
        ActionPoints = self.Data.CrimsonSabatt.ActionPoints;
        if not self:AreEnemyBattalionsInArea(KnightID, 1000) then
            Disabled = true;
        end
	elseif KnightType == Entities.U_KnightRedPrince then
		if type(self.Data.RedPrince.AbilityIcon) == "table" then
            Icon = self.Data.RedPrince.AbilityIcon;
		end
        RechargeTime = self.Data.RedPrince.RechargeTime;
        ActionPoints = self.Data.RedPrince.ActionPoints;
        if not self:AreInfectableSettlersInArea(KnightID, 1500) then
            Disabled = true;
        end
	end

	if RechargeTime ~= nil and ActionPoints ~= nil then
		-- API.InterfaceSetIcon(WidgetID, Icon, nil, Icon[3]);
		SetIcon(WidgetID, Icon);
        if Disabled or ActionPoints < RechargeTime then
            XGUIEng.DisableButton(WidgetID, 1);
        else
            XGUIEng.DisableButton(WidgetID, 0);
        end
        return true;
	end
end

function ExternalEvilHeroes.Local:SetKnightAbilityAction()
    local KnightID   = GUI.GetSelectedEntity();
    local PlayerID   = GUI.GetPlayerID();
    local KnightType = Logic.GetEntityType(KnightID);
    local KnightName = Logic.GetEntityName(KnightID);

	local Hero;
	if KnightType == Entities.U_KnightSabatta then
        Hero = "CrimsonSabatt";
	elseif KnightType == Entities.U_KnightRedPrince then
		Hero = "RedPrince";
	end

	if Hero then
		GUI.SendScriptCommand("ExternalEvilHeroes.Global:UseCustomKnightAbility('" ..KnightName.."')");
		self.Data[Hero].ActionPoints = 0;
		return true;
	end
end

function ExternalEvilHeroes.Local:SetKnightAbilityTooltip()
    local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
    local KnightID = GUI.GetSelectedEntity();
    local KnightType = Logic.GetEntityType(KnightID);

    local TooltipTextKey
    local DisabledTooltipTextKey
    if KnightType == Entities.U_KnightSabatta then
        local RechargeTime = self.Data.CrimsonSabatt.RechargeTime;
        local ActionPoints = self.Data.CrimsonSabatt.ActionPoints;
        TooltipTextKey = "AbilityConvertCrimsonSabatt";
        DisabledTooltipTextKey = TooltipTextKey;

        if ActionPoints < RechargeTime then
            DisabledTooltipTextKey = "AbilityNotReady";
        end
    elseif KnightType == Entities.U_KnightRedPrince then
        local RechargeTime = self.Data.CrimsonSabatt.RechargeTime;
        local ActionPoints = self.Data.CrimsonSabatt.ActionPoints;
        TooltipTextKey = "AbilityPlagueRedPrince";
        DisabledTooltipTextKey = TooltipTextKey;

        if ActionPoints < RechargeTime then
            DisabledTooltipTextKey = "AbilityNotReady";
        end
    end

    local TooltipTitle    = XGUIEng.GetStringTableText("UI_ObjectNames/" .. TooltipTextKey);
    local TooltipText     = XGUIEng.GetStringTableText("UI_ObjectDescription/" .. TooltipTextKey);
    local TooltipDisabled = XGUIEng.GetStringTableText("UI_ButtonDisabled/" .. DisabledTooltipTextKey);

    -- Behebt einen Schreibfehler in den Spieldateien.
    TooltipTitle = TooltipTitle:gsub("verison", "version");
    API.InterfaceSetTooltipNormal(TooltipTitle, TooltipText, TooltipDisabled);
    return true;
end

function ExternalEvilHeroes.Local:OverwriteComputePrices()
    ComputePrice_Orig_CrimsonSabatt = ComputePrice;
    ComputePrice = function(_BuildingID, _OfferID, _PlayerID, _TraderType)
        local PlayerID = GUI.GetPlayerID();
        local Hero = Logic.GetKnightID(PlayerID);
        local HeroName = Logic.GetEntityName(Hero);
        local KnightType = Logic.GetEntityType(Hero);
        if KnightType ~= Entities.U_KnightSabatta then
            return ComputePrice_Orig_CrimsonSabatt(_BuildingID, _OfferID, _PlayerID, _TraderType);
        else
            local TraderPlayerID = Logic.EntityGetPlayer(_BuildingID);
            local Type = Logic.GetGoodOfOffer(_BuildingID, _OfferID, _PlayerID, _TraderType);
            local BasePrice = (MerchantSystem.BasePrices[Type] or 3);

            local TraderAbility = 0.8;
            local OfferCount = Logic.GetOfferCount(_BuildingID, _OfferID, _PlayerID, _TraderType);
            if OfferCount > 8 then
                OfferCount = 8; 
            end
            local Modifier = math.ceil(BasePrice / 4);
            local Result = (BasePrice + (Modifier * OfferCount)) * TraderAbility;
            return math.floor(Result + 0.5);
        end
    end

    ComputeSellingPrice_CrimsonSabatt = GUI_Trade.ComputeSellingPrice;
    GUI_Trade.ComputeSellingPrice = function(_TargetPlayerID, _GoodType, _GoodAmount)
        local PlayerID = GUI.GetPlayerID();
        local Hero = Logic.GetKnightID(PlayerID);
        local HeroName = Logic.GetEntityName(Hero);
        local KnightType = Logic.GetEntityType(Hero);
        if KnightType ~= Entities.U_KnightSabatta then
            return ComputeSellingPrice_CrimsonSabatt(_TargetPlayerID, _GoodType, _GoodAmount);
        else
            if _GoodType == Goods.G_Gold then
                return 0;
            end
            local Waggonload = MerchantSystem.Waggonload;
            local BasePrice  = MerchantSystem.BasePrices[_GoodType];
            local GoodsSoldToTargetPlayer = 0;
            if  g_Trade.SellToPlayers[_TargetPlayerID] ~= nil
            and g_Trade.SellToPlayers[_TargetPlayerID][_GoodType] ~= nil then
                GoodsSoldToTargetPlayer = g_Trade.SellToPlayers[_TargetPlayerID][_GoodType];
            end
            local Modifier = math.ceil(BasePrice / 4);
            local MaxPriceToSubtractPerWaggon = BasePrice - Modifier;
            local WaggonsToSell = math.ceil(_GoodAmount / Waggonload);
            local WaggonsSold = math.ceil(GoodsSoldToTargetPlayer / Waggonload);
            local PriceToSubtract = 0;
            for i = 1, WaggonsToSell do
                PriceToSubtract = PriceToSubtract + math.min(WaggonsSold * Modifier, MaxPriceToSubtractPerWaggon);
                WaggonsSold = WaggonsSold + 1;
            end

            local TraderAbility = 1.2;
            local Result = ((WaggonsToSell * BasePrice) - PriceToSubtract) * TraderAbility;
            return math.floor(Result + 0.5);
        end
    end
end

function ExternalEvilHeroes.Local:AreEnemyBattalionsInArea(_Hero, _Area)
    local EntityID = GetID(_Hero);
    local PlayerID = Logic.EntityGetPlayer(EntityID);
	local x, y, z  = Logic.EntityGetPos(EntityID);

	local EnemiesInArea = {};
    for i= 1, 8, 1 do
        if i ~= PlayerID and Diplomacy_GetRelationBetween(i, PlayerID) == -2 then
            local Found = {Logic.GetPlayerEntitiesInArea(i, Entities.U_MilitaryLeader, x, y, _Area, 1)};
            if Found[1] > 0 then
                return true;
            end
        end
	end
	return false;
end

function ExternalEvilHeroes.Local:AreInfectableSettlersInArea(_Hero, _Area)
    local EntityID = GetID(_Hero);
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    local OtherPlayers = {1, 2, 3, 4, 5, 6, 7, 8};
    table.remove(OtherPlayers, PlayerID);

    local Targets = API.GetEntitiesOfCategoriesInTerritories(
        OtherPlayers,
        {EntityCategories.Worker, EntityCategories.Spouse},
        {Logic.GetTerritories()}
    );

    for k, v in pairs(Targets) do
        if GetDistance(_Hero, v) <= _Area then
            return true;
        end
    end
    return false;
end

function ExternalEvilHeroes.Local:ShowRedPrinceAbilityExplaination()
    StartSimpleJobEx(function()
        if Logic.GetTime() > 3 then
            local PlayerID = API.GetControllingPlayer();
            local KnightID = Logic.GetKnightID(PlayerID);
            local TerritoryID = GetTerritoryUnderEntity(KnightID);
            local TerritoryOwner = Logic.GetTerritoryPlayerID(TerritoryID);
            if TerritoryOwner ~= 0 and TerritoryOwner ~= PlayerID then
                StartKnightVoiceForActionSpecialAbility(Entities.U_KnightRedPrince);
                return true;
            end
        end
    end);
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("ExternalEvilHeroes");

