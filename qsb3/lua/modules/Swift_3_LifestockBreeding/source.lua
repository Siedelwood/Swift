-- -------------------------------------------------------------------------- --
-- Module Weather                                                             --
-- -------------------------------------------------------------------------- --

ModuleLifestockBreeding = {
    Properties = {
        Name = "ModuleLifestockBreeding",
    },

    Global = {
        AnimalChildren = {},
        GrothTime = 45,
        ShrinkedSize = 0.4,
        MinAmountNearby = 2,
        AreaSizeNearby = 3000,

        AllowBreedCattle = true,
        CattlePastures = {},
        CattleBaby = true,
        CattleFeedingTimer = 45,
        CattleMoneyCost = 300,

        AllowBreedSheeps = true,
        SheepPastures = {},
        SheepBaby = true,
        SheepFeedingTimer = 45,
        SheepMoneyCost = 300,
        SheepType = -1,
    },
    Local = {
        AllowBreedCattle = true,
        AllowBreedSheeps = true,

        Description = {
            BreedingActive = {
                Title = {
                    de = "Zucht aktiv",
                    en = "Breeding active",
                },
                Text = {
                    de = "- Klicken um Zucht zu stoppen",
                    en = "- Click to stop breeding",
                },
                Disabled = {
                    de = "Zucht ist gesperrt!",
                    en = "Breeding is locked!",
                },
            },
            BreedingInactive = {
                Title = {
                    de = "Zucht gestoppt",
                    en = "Breeding stopped",
                },
                Text = {
                    de = "- Klicken um Zucht zu starten {cr}- Benötigt Platz {cr}- Benötigt Getreide",
                    en = "- Click to allow breeding {cr}- Requires space {cr}- Requires grain",
                },
                Disabled = {
                    de = "Zucht ist gesperrt!",
                    en = "Breeding is locked!",
                },
            },
        },
    },
}

-- Global ------------------------------------------------------------------- --

function ModuleLifestockBreeding.Global:OnGameStart()
    MerchantSystem.BasePricesOrigModuleLifestockBreeding                = {};
    MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Sheep] = MerchantSystem.BasePrices[Goods.G_Sheep];
    MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Cow]   = MerchantSystem.BasePrices[Goods.G_Cow];

    MerchantSystem.BasePrices[Goods.G_Sheep] = ModuleLifestockBreeding.Global.SheepMoneyCost;
    MerchantSystem.BasePrices[Goods.G_Cow]   = ModuleLifestockBreeding.Global.CattleMoneyCost;

    StartSimpleJobEx(function()
        ModuleLifestockBreeding.Global:AnimalBreedController();
    end);
    StartSimpleJobEx(function()
        ModuleLifestockBreeding.Global:AnimalGrouthController();
    end);
end

function ModuleLifestockBreeding.Global:GetScale(_Entity)
    local ID = GetID(_Entity);
    local SV = QSB.ScriptingValue.Size;
    local IntVal = Logic.GetEntityScriptingValue(ID, SV);
    return Core:ScriptingValueIntegerToFloat(IntVal);
end

function ModuleLifestockBreeding.Global:SetScale(_Entity, _Scale)
    local ID = GetID(_Entity);
    local SV = QSB.ScriptingValue.Size;
    local IntVal = Core:ScriptingValueFloatToInteger(_Scale);
    Logic.SetEntityScriptingValue(ID, SV, IntVal);
end

function ModuleLifestockBreeding.Global:CreateAnimal(_PastureID, _Type, _Shrink)
    local PlayerID = Logic.EntityGetPlayer(_PastureID);
    local x, y = Logic.GetBuildingApproachPosition(_PastureID);
    local Type = Entities.A_X_Sheep01;
    if not Framework.IsNetworkGame() then
        Type = (_Type > 0 and _Type) or (_Type == 0 and Entities["A_X_Sheep0" ..math.random(1, 2)]) or Entities["A_X_Sheep0" ..(_Type * (-1))];
    end
    local ID = Logic.CreateEntity(Type, x, y, 0, PlayerID);
    if _Shrink == true then
        self:SetScale(ID, self.ShrinkedSize);
        table.insert(self.AnimalChildren, {ID, self.GrothTime});
    end
end

function ModuleLifestockBreeding.Global:BreedingTimeTillNext(_Animals)
    if self.MinAmountNearby <= _Animals then
        local Time = 240 - (_Animals * 15);
        if Time < 30 then
            Time = 30;
        end
        return Time;
    end
    return -1;
end

function ModuleLifestockBreeding.Global:IsCattleNeeded(_PlayerID)
    local AmountOfCattle = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.CattlePasture)};
    local AmountOfPasture = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.B_CattlePasture);
    return #AmountOfCattle < AmountOfPasture * 5;
end

function ModuleLifestockBreeding.Global:IsSheepNeeded(_PlayerID)
    local AmountOfSheep = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.SheepPasture)};
    local AmountOfPasture = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.B_SheepPasture);
    return #AmountOfSheep < AmountOfPasture * 5;
end

function ModuleLifestockBreeding.Global:CountCattleNearby(_PastureID)
    local PlayerID = Logic.EntityGetPlayer(_PastureID);
    local x, y, z  = Logic.EntityGetPos(_PastureID);
    local AreaSize = self.AreaSizeNearby;
    local Cattle   = {Logic.GetPlayerEntitiesInArea(PlayerID, Entities.A_X_Cow01, x, y, AreaSize, 16)};
    table.remove(Cattle, 1);
    return #Cattle;
end

function ModuleLifestockBreeding.Global:CountSheepsNearby(_PastureID)
    local PlayerID = Logic.EntityGetPlayer(_PastureID);
    local x, y, z  = Logic.EntityGetPos(_PastureID);
    local AreaSize = self.AreaSizeNearby;
    local Sheeps1  = {Logic.GetPlayerEntitiesInArea(PlayerID, Entities.A_X_Sheep01, x, y, AreaSize, 16)};
    local Sheeps2  = {Logic.GetPlayerEntitiesInArea(PlayerID, Entities.A_X_Sheep02, x, y, AreaSize, 16)};
    table.remove(Sheeps1, 1);
    table.remove(Sheeps1, 1);
    return #Sheeps1 + #Sheeps2;
end

function ModuleLifestockBreeding.Global:AnimalBreedController()
    for PlayerID = 1, 8, 1 do
        -- Kühe
        if self.AllowBreedCattle then
            local Pastures = GetPlayerEntities(PlayerID, Entities.B_CattlePasture);
            for k, v  in pairs(Pastures) do
                -- Tiere zählen
                local AmountNearby = self:CountCattleNearby(v);
                -- Zuchtzähler
                self.CattlePastures[v] = self.CattlePastures[v] or 0;
                if self:IsCattleNeeded(PlayerID) and Logic.IsBuildingStopped(v) == false then
                    self.CattlePastures[v] = self.CattlePastures[v] +1;
                    -- Alle X Sekunden wird 1 Getreide verbraucht
                    local FeedingTime = self.CattleFeedingTimer;
                    if self.CattlePastures[v] > 0 and FeedingTime > 0 and Logic.GetTime() % FeedingTime == 0 then
                        if GetPlayerResources(Goods.G_Grain, PlayerID) > 0 then
                            AddGood(Goods.G_Grain, -1, PlayerID);
                        else
                            self.CattlePastures[v] = self.CattlePastures[v] - FeedingTime;
                        end
                    end
                end
                -- Kuh spawnen
                local TimeTillNext = self:BreedingTimeTillNext(AmountNearby);
                if TimeTillNext > -1 and self.CattlePastures[v] > TimeTillNext then
                    local x, y, z = Logic.EntityGetPos(v);
                    if self:IsCattleNeeded(PlayerID) then
                        self:CreateAnimal(v, Entities.A_X_Cow01, self.CattleBaby);
                        self.CattlePastures[v] = 0;
                    end
                end
            end
        end

        -- Schafe
        if self.AllowBreedSheeps then
            local Pastures = GetPlayerEntities(PlayerID, Entities.B_SheepPasture);
            for k, v  in pairs(Pastures) do
                -- Tier zählen
                local AmountNearby = self:CountSheepsNearby(v);
                -- Zuchtzähler
                self.SheepPastures[v] = self.SheepPastures[v] or 0;
                if self:IsSheepNeeded(PlayerID) and Logic.IsBuildingStopped(v) == false then
                    self.SheepPastures[v] = self.SheepPastures[v] +1;
                    -- Alle X Sekunden wird 1 Getreide verbraucht
                    local FeedingTime = self.SheepFeedingTimer;
                    if self.SheepPastures[v] > 0 and FeedingTime > 0 and Logic.GetTime() % FeedingTime == 0 then
                        if GetPlayerResources(Goods.G_Grain, PlayerID) > 0 then
                            AddGood(Goods.G_Grain, -1, PlayerID);
                        else
                            self.SheepPastures[v] = self.SheepPastures[v] - FeedingTime;
                        end
                    end
                end
                -- Schaf spawnen
                local TimeTillNext = self:BreedingTimeTillNext(AmountNearby);
                if TimeTillNext > -1 and self.SheepPastures[v] > TimeTillNext then
                    local x, y, z = Logic.EntityGetPos(v);
                    if self:IsSheepNeeded(PlayerID) then
                        self:CreateAnimal(v, self.SheepType, self.SheepBaby);
                        self.SheepPastures[v] = 0;
                    end
                end
            end
        end
    end
end

function ModuleLifestockBreeding.Global:AnimalGrouthController()
    for k, v in pairs(self.AnimalChildren) do
        if v then
            if not IsExisting(v[1]) then
                self.AnimalChildren[k] = nil;
            else
                self.AnimalChildren[k][2] = v[2] -1;
                if v[2] < 0 then
                    self.AnimalChildren[k][2] = self.GrothTime;
                    local Scale = self:GetScale(v[1]);
                    if Scale < 1 then
                        self:SetScale(v[1], Scale + 0.1);
                    else
                        self.AnimalChildren[k] = nil;
                    end
                end
            end
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleLifestockBreeding.Local:OnGameStart()
    MerchantSystem.BasePricesOrigModuleLifestockBreeding                = {};
    MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Sheep] = MerchantSystem.BasePrices[Goods.G_Sheep];
    MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Cow]   = MerchantSystem.BasePrices[Goods.G_Cow];

    MerchantSystem.BasePrices[Goods.G_Sheep] = ModuleLifestockBreeding.Local.SheepMoneyCost;
    MerchantSystem.BasePrices[Goods.G_Cow]   = ModuleLifestockBreeding.Local.CattleMoneyCost;

    self:OverwriteBuySiegeEngine();
end

function ModuleLifestockBreeding.Local:ToggleBreedingState(_BarrackID)
    local BuildingEntityType = Logic.GetEntityType(_BarrackID);
    if BuildingEntityType == Entities.B_CattlePasture then
        GUI.SetStoppedState(_BarrackID, not Logic.IsBuildingStopped(_BarrackID));
    elseif BuildingEntityType == Entities.B_SheepPasture then
        GUI.SetStoppedState(_BarrackID, not Logic.IsBuildingStopped(_BarrackID));
    end
end

function ModuleLifestockBreeding.Local:OverwriteBuySiegeEngine()
    GUI_BuildingButtons.BuySiegeEngineCartMouseOver = function(_EntityType,_TechnologyType)
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local BarrackID = GUI.GetSelectedEntity();
        local BuildingEntityType = Logic.GetEntityType(BarrackID);

        if  BuildingEntityType ~= Entities.B_SiegeEngineWorkshop
        and BuildingEntityType ~= Entities.B_CattlePasture
        and BuildingEntityType ~= Entities.B_SheepPasture then
            return;
        end

        local Costs = {Logic.GetUnitCost(BarrackID, _EntityType)}

        if BuildingEntityType == Entities.B_CattlePasture then
            local Description = ModuleLifestockBreeding.Local.Description.BreedingActive;
            if Logic.IsBuildingStopped(BarrackID) then
                Description = ModuleLifestockBreeding.Local.Description.BreedingInactive;
            end
            API.InterfaceSetTooltipCosts(
                API.Localize(Description.Title), API.Localize(Description.Text), API.Localize(Description.Disabled),
                {Goods.G_Grain, 1},
                false
            );
        elseif BuildingEntityType == Entities.B_SheepPasture then
            local Description = ModuleLifestockBreeding.Local.Description.BreedingActive;
            if Logic.IsBuildingStopped(BarrackID) then
                Description = ModuleLifestockBreeding.Local.Description.BreedingInactive;
            end
            API.InterfaceSetTooltipCosts(
                API.Localize(Description.Title), API.Localize(Description.Text), API.Localize(Description.Disabled),
                {Goods.G_Grain, 1},
                false
            );
        else
            GUI_Tooltip.TooltipBuy(Costs,nil,nil,_TechnologyType);
        end
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GUI_BuildingButtons.BuySiegeEngineCartClicked_Orig_Stockbreeding = GUI_BuildingButtons.BuySiegeEngineCartClicked
    GUI_BuildingButtons.BuySiegeEngineCartClicked = function(_EntityType)
        local BarrackID = GUI.GetSelectedEntity()
        local eType = Logic.GetEntityType(BarrackID)
        if eType == Entities.B_CattlePasture or eType == Entities.B_SheepPasture then
            ModuleLifestockBreeding.Local:ToggleBreedingState(BarrackID);
        else
            GUI_BuildingButtons.BuySiegeEngineCartClicked_Orig_Stockbreeding(_EntityType)
        end
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GUI_BuildingButtons.BuySiegeEngineCartUpdate = function(_Technology)
        local PlayerID = GUI.GetPlayerID();
        local KnightTitle = Logic.GetKnightTitle(PlayerID);
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local EntityID = GUI.GetSelectedEntity();
        local EntityType = Logic.GetEntityType(EntityID);
        local grain = GetPlayerResources(Goods.G_Grain,PlayerID);
        local pos = GetPosition(EntityID);

        if EntityType == Entities.B_SiegeEngineWorkshop then
            XGUIEng.ShowWidget(CurrentWidgetID,1);
            if _Technology == Technologies.R_BatteringRam then
                SetIcon(CurrentWidgetID, {9,5});
            elseif _Technology == Technologies.R_SiegeTower then
                SetIcon(CurrentWidgetID, {9,6});
            elseif _Technology == Technologies.R_Catapult then
                SetIcon(CurrentWidgetID, {9,4});
            end
        elseif EntityType == Entities.B_CattlePasture then
            local Icon = {4, 13};
            if Logic.IsBuildingStopped(EntityID) then
                Icon = {4, 12};
            end
            SetIcon(CurrentWidgetID, Icon);

            if _Technology == Technologies.R_Catapult and ModuleLifestockBreeding.Local.AllowBreedCattle then
                XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons",1);
                XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/BuyCatapultCart",1);

                local DisableState = (ModuleLifestockBreeding.Local.AllowBreedCattle and 0) or 1;
                XGUIEng.DisableButton(CurrentWidgetID, DisableState);
                XGUIEng.ShowWidget(CurrentWidgetID, 1);
            else
                XGUIEng.ShowWidget(CurrentWidgetID, 0);
            end
        elseif EntityType == Entities.B_SheepPasture then
            local Icon = {4, 13};
            if Logic.IsBuildingStopped(EntityID) then
                Icon = {4, 12};
            end
            SetIcon(CurrentWidgetID, Icon)

            if _Technology == Technologies.R_Catapult and ModuleLifestockBreeding.Local.AllowBreedSheeps then
                XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons",1);
                XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/BuyCatapultCart",1);

                local DisableState = (ModuleLifestockBreeding.Local.AllowBreedSheeps and 0) or 1;
                XGUIEng.DisableButton(CurrentWidgetID, DisableState);
                XGUIEng.ShowWidget(CurrentWidgetID, 1);
            else
                XGUIEng.ShowWidget(CurrentWidgetID, 0);
            end
        else
            XGUIEng.ShowWidget(CurrentWidgetID,0);
            return;
        end

        if Logic.IsConstructionComplete(GUI.GetSelectedEntity()) == 0 then
            XGUIEng.ShowWidget(CurrentWidgetID,0);
            return;
        end

        if EntityType ~= Entities.B_SheepPasture and EntityType ~= Entities.B_CattlePasture then
            local TechnologyState = Logic.TechnologyGetState(PlayerID, _Technology);
            if EnableRights == nil or EnableRights == false then
                XGUIEng.DisableButton(CurrentWidgetID,0);
                return
            end
            if TechnologyState == TechnologyStates.Researched then
                XGUIEng.DisableButton(CurrentWidgetID,0);
            else
                XGUIEng.DisableButton(CurrentWidgetID,1);
            end
        end
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    HouseMenuStopProductionClicked_Orig_Stockbreeding = HouseMenuStopProductionClicked;
    HouseMenuStopProductionClicked = function()
        HouseMenuStopProductionClicked_Orig_Stockbreeding();
        local WidgetName = HouseMenu.Widget.CurrentBuilding;
        local EntityType = Entities[WidgetName];
        local PlayerID = GUI.GetPlayerID();
        local Bool = HouseMenu.StopProductionBool;

        if EntityType == Entities.B_CattleFarm then
            local Buildings = GetPlayerEntities(PlayerID, Entities.B_CattlePasture);
            for i=1, #Buildings, 1 do
                GUI.SetStoppedState(Buildings[i], Bool);
            end
        elseif EntityType == Entities.B_SheepFarm then
            local Buildings = GetPlayerEntities(PlayerID, Entities.B_SheepPasture);
            for i=1, #Buildings, 1 do
                GUI.SetStoppedState(Buildings[i], Bool);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleLifestockBreeding);

