--[[
Swift_2_LifestockBreeding/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleLifestockBreeding = {
    Properties = {
        Name = "ModuleLifestockBreeding",
    },

    Global = {
        AnimalChildren = {},
        Cattle = {
            RequiredAmount = 2,
            QuantityBoost = 15,
            AreaSize = 3000,
            GrothTimer = 45,
            FeedingTimer = 45,
            BreedingTimer = 4*60,
            BabySize = 0.4,
            UseCalves = true,

            PastureRegister = {},
            Breeding = true,
            MoneyCost = 300,
        },
        Sheep = {
            RequiredAmount = 2,
            QuantityBoost = 15,
            AreaSize = 3000,
            GrothTimer = 45,
            FeedingTimer = 45,
            BreedingTimer = 4*60,
            BabySize = 0.4,
            UseCalves = true,

            PastureRegister = {},
            Breeding = true,
            MoneyCost = 300,
        },
    },
    Local = {
        Cattle = {
            Breeding = true,
            MoneyCost = 300,
        },
        Sheep = {
            Breeding = true,
            MoneyCost = 300,
        },
    },
    Shared = {
        Text = {
            BreedingActive = {
                Title = {
                    de = "Zucht aktiv",
                    en = "Breeding active",
                    fr = "Élevage actif",
                },
                Text = {
                    de = "- Klicken um Zucht zu stoppen",
                    en = "- Click to stop breeding",
                    fr = "- Cliquez pour arrêter l'élevage",
                },
                Disabled = {
                    de = "Zucht ist gesperrt!",
                    en = "Breeding is locked!",
                    fr = "L'élevage est bloqué!",
                },
            },
            BreedingInactive = {
                Title = {
                    de = "Zucht gestoppt",
                    en = "Breeding stopped",
                    fr = "Élevage stoppé",
                },
                Text = {
                    de = "- Klicken um Zucht zu starten {cr}- Benötigt Platz {cr}- Benötigt Getreide",
                    en = "- Click to allow breeding {cr}- Requires space {cr}- Requires grain",
                    fr = "- Cliquez pour démarrer l'élevage {cr}- Nécessite de l'espace {cr}- Nécessite des céréales",
                },
                Disabled = {
                    de = "Zucht ist gesperrt!",
                    en = "Breeding is locked!",
                    fr = "L'élevage est bloqué!",
                },
            },
        },
    }
}

-- Global ------------------------------------------------------------------- --

function ModuleLifestockBreeding.Global:OnGameStart()
    MerchantSystem.BasePricesOrigModuleLifestockBreeding                = {};
    MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Sheep] = MerchantSystem.BasePrices[Goods.G_Sheep];
    MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Cow]   = MerchantSystem.BasePrices[Goods.G_Cow];

    MerchantSystem.BasePrices[Goods.G_Sheep] = ModuleLifestockBreeding.Global.Sheep.MoneyCost;
    MerchantSystem.BasePrices[Goods.G_Cow]   = ModuleLifestockBreeding.Global.Cattle.MoneyCost;

    QSB.ScriptEvents.AnimalBreed = API.RegisterScriptEvent("Event_AnimalBreed");

    for i= 1, 8 do
        self.Cattle.PastureRegister[i] = {};
        self.Sheep.PastureRegister[i] = {};
    end
    for k, v in pairs(Logic.GetEntitiesOfType(Entities.B_CattlePasture)) do
        local PlayerID = Logic.EntityGetPlayer(v);
        self:RegisterNewPasture(v, PlayerID);
    end
    for k, v in pairs(Logic.GetEntitiesOfType(Entities.B_SheepPasture)) do
        local PlayerID = Logic.EntityGetPlayer(v);
        self:RegisterNewPasture(v, PlayerID);
    end

    StartSimpleJobEx(function()
        ModuleLifestockBreeding.Global:AnimalBreedController();
    end);
    StartSimpleJobEx(function()
        ModuleLifestockBreeding.Global:AnimalGrouthController();
    end);
end

function ModuleLifestockBreeding.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.BuildingConstructed then
        self:RegisterNewPasture(arg[1], arg[2]);
    end
end

function ModuleLifestockBreeding.Global:RegisterNewPasture(_BuildingID, _PlayerID)
    local ScriptName = API.CreateEntityName(_BuildingID);
    if Logic.GetEntityType(_BuildingID) == Entities.B_CattlePasture then
        self.Cattle.PastureRegister[_PlayerID][ScriptName] = {0, false};
    else
        self.Sheep.PastureRegister[_PlayerID][ScriptName] = {0, false};
    end
end

function ModuleLifestockBreeding.Global:SpawnAnimal(_Pasture, _Shrink)
    local PastureID = GetID(_Pasture);
    local PlayerID = Logic.EntityGetPlayer(PastureID);
    local x, y = Logic.GetBuildingApproachPosition(PastureID);
    if Logic.GetEntityType(PastureID) == Entities.B_CattlePasture then
        self:SpawnCattle(x, y, PlayerID, _Shrink);
    else
        self:SpawnSheep(x, y, PlayerID, _Shrink);
    end
end

function ModuleLifestockBreeding.Global:SpawnCattle(_X, _Y, _PlayerID, _Shrink)
    local ID = Logic.CreateEntity(Entities.A_X_Cow01, _X, _Y, 0, _PlayerID);
    if _Shrink == true then
        API.SetFloat(ID, QSB.ScriptingValue.Size, self.Cattle.BabySize);
        table.insert(self.AnimalChildren, {ID, self.Cattle.GrothTimer});
    end
    API.SendScriptEvent(QSB.ScriptEvents.AnimalBreed, ID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.AnimalBreed, %d)]],
        ID
    ));
end

function ModuleLifestockBreeding.Global:SpawnSheep(_X, _Y, _PlayerID, _Shrink)
    local Type = Entities.A_X_Sheep01;
    if not Framework.IsNetworkGame() then
        Type = Entities["A_X_Sheep0" ..math.random(1, 2)];
    end
    local ID = Logic.CreateEntity(Type, _X, _Y, 0, _PlayerID);
    if _Shrink == true then
        API.SetFloat(ID, QSB.ScriptingValue.Size, self.Sheep.BabySize);
        table.insert(self.AnimalChildren, {ID, self.Sheep.GrothTimer});
    end
    API.SendScriptEvent(QSB.ScriptEvents.AnimalBreed, ID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.AnimalBreed, %d)]],
        ID
    ));
end

function ModuleLifestockBreeding.Global:CalculateAnimalBreedingTimer(_Pasture, _Animals)
    if Logic.GetEntityType(GetID(_Pasture)) == Entities.B_CattlePasture then
        return self:CalculateCattleBreedingTimer(_Animals);
    else
        return self:CalculateSheepBreedingTimer(_Animals);
    end
end

function ModuleLifestockBreeding.Global:CalculateCattleBreedingTimer(_Animals)
    if self.Cattle.RequiredAmount <= _Animals then
        local Time = self.Cattle.BreedingTimer - (_Animals * self.Cattle.QuantityBoost);
        return (Time < 30 and 30) or Time;
    end
    return -1;
end

function ModuleLifestockBreeding.Global:CalculateSheepBreedingTimer(_Animals)
    if self.Sheep.RequiredAmount <= _Animals then
        local Time = self.Sheep.BreedingTimer - (_Animals * self.Sheep.QuantityBoost);
        return (Time < 30 and 30) or Time;
    end
    return -1;
end

function ModuleLifestockBreeding.Global:IsAnimalNeeded(_Pasture, _PlayerID)
    if Logic.GetEntityType(GetID(_Pasture)) == Entities.B_CattlePasture then
        return self:GetCattlePastureDelta(_PlayerID) < 1;
    else
        return self:GetSheepPastureDelta(_PlayerID) < 1;
    end
end

function ModuleLifestockBreeding.Global:IsCattleNeeded(_PlayerID)
    return self:GetCattlePastureDelta(_PlayerID) < 1;
end

function ModuleLifestockBreeding.Global:IsSheepNeeded(_PlayerID)
    return self:GetSheepPastureDelta(_PlayerID) < 1;
end

function ModuleLifestockBreeding.Global:GetCattlePastureDelta(_PlayerID)
    local AmountOfCattle = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.CattlePasture)};
    local AmountOfPasture = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.B_CattlePasture);
    return #AmountOfCattle / (AmountOfPasture * 5);
end

function ModuleLifestockBreeding.Global:GetSheepPastureDelta(_PlayerID)
    local AmountOfSheep = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.SheepPasture)};
    local AmountOfPasture = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.B_SheepPasture);
    return #AmountOfSheep / (AmountOfPasture * 5);
end

function ModuleLifestockBreeding.Global:CountAnimalsNearby(_Pasture)
    if Logic.GetEntityType(GetID(_Pasture)) == Entities.B_CattlePasture then
        return self:CountCattleNearby(_Pasture);
    else
        return self:CountSheepsNearby(_Pasture);
    end
end

function ModuleLifestockBreeding.Global:CountCattleNearby(_Pasture)
    local PastureID = GetID(_Pasture)
    local PlayerID  = Logic.EntityGetPlayer(PastureID);
    local x, y, z   = Logic.EntityGetPos(PastureID);
    local AreaSize  = self.Cattle.AreaSize;
    local Cattle    = {Logic.GetPlayerEntitiesInArea(PlayerID, Entities.A_X_Cow01, x, y, AreaSize, 16)};
    table.remove(Cattle, 1);
    return #Cattle;
end

function ModuleLifestockBreeding.Global:CountSheepsNearby(_Pasture)
    local PastureID = GetID(_Pasture)
    local PlayerID  = Logic.EntityGetPlayer(PastureID);
    local x, y, z   = Logic.EntityGetPos(PastureID);
    local AreaSize  = self.Sheep.AreaSize;
    local Sheeps1   = {Logic.GetPlayerEntitiesInArea(PlayerID, Entities.A_X_Sheep01, x, y, AreaSize, 16)};
    local Sheeps2   = {Logic.GetPlayerEntitiesInArea(PlayerID, Entities.A_X_Sheep02, x, y, AreaSize, 16)};
    table.remove(Sheeps1, 1);
    table.remove(Sheeps2, 1);
    return #Sheeps1 + #Sheeps2;
end

function ModuleLifestockBreeding.Global:AnimalBreedController()
    for PlayerID = 1, 8, 1 do
        for _,Animal in pairs{"Cattle", "Sheep"} do
            for k, v in pairs(self[Animal].PastureRegister[PlayerID]) do
                if IsExisting(k) then
                    if self[Animal].Breeding then
                        -- Controls the consumption of grain for the pasture.
                        -- As long as grain is available the timer is counting up and
                        -- 1 grain is removed in each feeding cycle. If grain is out
                        -- the cycle resets itself.
                        if self:IsAnimalNeeded(k, PlayerID) and Logic.IsBuildingStopped(GetID(k)) == false then
                            self[Animal].PastureRegister[PlayerID][k][1] = v[1] +1;
                            local FeedingTime = self[Animal].FeedingTimer;
                            if v[1] > 0 then
                                if FeedingTime > 0 and Logic.GetTime() % FeedingTime == 0 then
                                    if GetPlayerResources(Goods.G_Grain, PlayerID) > 0 then
                                        AddGood(Goods.G_Grain, -1, PlayerID);
                                    else
                                        self[Animal].PastureRegister[PlayerID][k][1] = v[1] - FeedingTime;
                                    end
                                end
                            end
                        end
                        -- Spawns a new animal when enough was fed.
                        -- If the feeding counter is high enough and a new animal
                        -- is still needed then the animal is creaded
                        local AmountNearby = self:CountAnimalsNearby(k);
                        local TimeTillNext = self:CalculateAnimalBreedingTimer(k, AmountNearby);
                        if TimeTillNext > -1 and v[1] >= TimeTillNext then
                            if self:IsAnimalNeeded(k, PlayerID) then
                                self:SpawnAnimal(k, self[Animal].UseCalves);
                                self[Animal].PastureRegister[PlayerID][k][1] = 0;
                            end
                        end
                    end
                else
                    self[Animal].PastureRegister[PlayerID][k] = nil;
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
                    local GrothTimer = self.Sheep.GrothTimer;
                    if Logic.GetEntityType(GetID(k)) == Entities.A_X_Cow01 then
                        GrothTimer = self.Cattle.GrothTimer;
                    end
                    self.AnimalChildren[k][2] = GrothTimer;
                    local Scale = API.GetFloat(v[1], QSB.ScriptingValue.Size);
                    if Scale < 1 then
                        API.SetFloat(v[1], QSB.ScriptingValue.Size, math.min(1, Scale + 0.1));
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

    MerchantSystem.BasePrices[Goods.G_Sheep] = ModuleLifestockBreeding.Local.Sheep.MoneyCost;
    MerchantSystem.BasePrices[Goods.G_Cow]   = ModuleLifestockBreeding.Local.Cattle.MoneyCost;

    QSB.ScriptEvents.AnimalBreed = API.RegisterScriptEvent("Event_AnimalBreed");

    self:InitBuyLifestockButton();
end

function ModuleLifestockBreeding.Local:ToggleBreedingState(_BarrackID)
    local BuildingEntityType = Logic.GetEntityType(_BarrackID);
    if BuildingEntityType == Entities.B_CattlePasture then
        GUI.SetStoppedState(_BarrackID, not Logic.IsBuildingStopped(_BarrackID));
    elseif BuildingEntityType == Entities.B_SheepPasture then
        GUI.SetStoppedState(_BarrackID, not Logic.IsBuildingStopped(_BarrackID));
    end
end

function ModuleLifestockBreeding.Local:InitBuyLifestockButton()
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

    local Position = {XGUIEng.GetWidgetLocalPosition("/InGame/Root/Normal/BuildingButtons/BuyCatapultCart")};
    API.AddBuildingButtonByTypeAtPosition(
        Entities.B_CattlePasture,
        Position[1], Position[2],
        function(_WidgetID, _EntityID)
            ModuleLifestockBreeding.Local:ToggleBreedingState(_EntityID);
        end,
        function(_WidgetID, _EntityID)
            local Description = API.Localize(ModuleLifestockBreeding.Shared.Text.BreedingActive);
            if Logic.IsBuildingStopped(_EntityID) then
                Description = API.Localize(ModuleLifestockBreeding.Shared.Text.BreedingInactive);
            end
            API.SetTooltipCosts(Description.Title, Description.Text, Description.Disabled, {Goods.G_Grain, 1}, false);
        end,
        function(_WidgetID, _EntityID)
            local Icon = {4, 13};
            if Logic.IsBuildingStopped(_EntityID) then
                Icon = {4, 12};
            end
            SetIcon(_WidgetID, Icon);
            local DisableState = (ModuleLifestockBreeding.Local.Cattle.Breeding and 0) or 1;
            XGUIEng.DisableButton(_WidgetID, DisableState);
        end
    );
    API.AddBuildingButtonByTypeAtPosition(
        Entities.B_SheepPasture,
        Position[1], Position[2],
        function(_WidgetID, _EntityID)
            ModuleLifestockBreeding.Local:ToggleBreedingState(_EntityID);
        end,
        function(_WidgetID, _EntityID)
            local Description = API.Localize(ModuleLifestockBreeding.Shared.Text.BreedingActive);
            if Logic.IsBuildingStopped(_EntityID) then
                Description = API.Localize(ModuleLifestockBreeding.Shared.Text.BreedingInactive);
            end
            API.SetTooltipCosts(Description.Title, Description.Text, Description.Disabled, {Goods.G_Grain, 1}, false);
        end,
        function(_WidgetID, _EntityID)
            local Icon = {4, 13};
            if Logic.IsBuildingStopped(_EntityID) then
                Icon = {4, 12};
            end
            SetIcon(_WidgetID, Icon);
            local DisableState = (ModuleLifestockBreeding.Local.Sheep.Breeding and 0) or 1;
            XGUIEng.DisableButton(_WidgetID, DisableState);
        end
    );
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleLifestockBreeding);

