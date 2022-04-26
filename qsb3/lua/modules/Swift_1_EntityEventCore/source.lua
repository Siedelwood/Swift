--[[
Swift_1_EntityEventCore/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleEntityEventCore = {
    Properties = {
        Name = "ModuleEntityEventCore",
    },

    Global = {
        RegisteredEntities = {},
        AttackedEntities = {},
        OverkillEntities = {},
        DisableThiefStorehouseHeist = false,
        DisableThiefCathedralSabotage = false,
        DisableThiefCisternSabotage = false,

        -- Those are animal types that are automatically spawned by the game
        -- without triggering a callback. They are spawned in every climate
        -- zone by spawner or by buildings.
        SharedAnimalTypes = {
            "A_Bees",
            "A_Chicken",
            "A_Chicken02",
            "A_Chicken03",
            "A_X_Cat",
            "A_X_Dog",
            "A_X_Rabbit",
            "A_X_WildBoar_Child",
            "A_X_WildBoar_Female",
            "A_X_WildBoar_Male",
        },

        -- Those are resource types that are automatically spawned by the game
        -- without triggering a callback. They are spawned when an animal is
        -- killed (either by men or animal).
        SharedResourceTypes = {
            "R_WildBoar_Child",
            "R_WildBoar_Female",
            "R_WildBoar_Male",
            "R_DeadCow",
            "R_DeadSheep",
            "R_ResourceTree_Grow",
            "R_ResourceTree_GrowStatic",
            "R_ResourceTree_KnockdownStatic",
            "R_ResourceTree_Respawn",
            "R_ResourceTree_RespawnStatic",
            "R_ResourceTreeStatic",
            "XD_TreeStump_Respawn",
            "XD_TreeStump_RespawnStatic",
            "XD_TreeStump1",
        },

        -- Those are "fluctuating" spawner entities that are keep appearing
        -- and disappearing depending of if they have resources spawned. Sadly
        -- they change their ID every time they do it.
        SpawnerTypes = {
            "S_AxisDeer_AS",
            "S_Deer_ME",
            "S_FallowDeer_SE",
            "S_Gazelle_NA",
            "S_Herbs",
            "S_Moose_NE",
            "S_RawFish",
            "S_Reindeer_NE",
            "S_WildBoar",
            "S_Zebra_NA",
        },
    },
    Local = {},
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        ReplacementEntityID = {},
        HighestEntityID = 0,
    };
}

-- Global ------------------------------------------------------------------- --

function ModuleEntityEventCore.Global:OnGameStart()
    QSB.ScriptEvents.EntityRegistered = API.RegisterScriptEvent("Event_EntityRegistered");
    QSB.ScriptEvents.EntityDestroyed = API.RegisterScriptEvent("Event_EntityDestroyed");
    QSB.ScriptEvents.EntityHurt = API.RegisterScriptEvent("Event_EntityHurt");
    QSB.ScriptEvents.EntityKilled = API.RegisterScriptEvent("Event_EntityKilled");
    QSB.ScriptEvents.EntityOwnerChanged = API.RegisterScriptEvent("Event_EntityOwnerChanged");
    QSB.ScriptEvents.EntityResourceChanged = API.RegisterScriptEvent("Event_EntityResourceChanged");

    QSB.ScriptEvents.ThiefInfiltratedBuilding = API.RegisterScriptEvent("Event_ThiefInfiltratedBuilding");
    QSB.ScriptEvents.ThiefDeliverEarnings = API.RegisterScriptEvent("Event_ThiefDeliverEarnings");
    QSB.ScriptEvents.BuildingConstructed = API.RegisterScriptEvent("Event_BuildingConstructed");
    QSB.ScriptEvents.BuildingUpgraded = API.RegisterScriptEvent("Event_BuildingUpgraded");

    self.ClimateShort = self:GetClimateZoneShort();
    self:StartTriggers();
    self:OverrideCallback();
    self:OverrideLogic();

    local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, 5, 5, 0, 0);
    Logic.DestroyEntity(ID);
end

function ModuleEntityEventCore.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:OnSaveGameLoaded();
    elseif _ID == QSB.ScriptEvents.EntityHurt then
        self.AttackedEntities[arg[1]] = {arg[3], 100};
    elseif _ID == QSB.ScriptEvents.EntityRegistered then
        ModuleEntityEventCore.Shared:SaveHighestEntity(arg[1]);
    end
end

function ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(_EntityID)
    if _EntityID and IsExisting(_EntityID) then
        if not self.RegisteredEntities[_EntityID] then
            self.RegisteredEntities[_EntityID] = true;
            API.SendScriptEvent(QSB.ScriptEvents.EntityRegistered, _EntityID);
            Logic.ExecuteInLuaLocalState(string.format(
                "API.SendScriptEvent(QSB.ScriptEvents.EntityRegistered, %d)",
                _EntityID
            ))
        end
    end
end

function ModuleEntityEventCore.Global:UnregisterEntityAndTriggerEvent(_EntityID)
    if _EntityID and self.RegisteredEntities[_EntityID] then
        self.RegisteredEntities[_EntityID] = nil;
        API.SendScriptEvent(QSB.ScriptEvents.EntityDestroyed, _EntityID);
        Logic.ExecuteInLuaLocalState(string.format(
            "API.SendScriptEvent(QSB.ScriptEvents.EntityDestroyed, %d)",
            _EntityID
        ))
    end
end

function ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(_OldID, _OldOwnerID, _NewID, _NewOwnerID)
    _OldID = (type(_OldID) ~= "table" and {_OldID}) or _OldID;
    _NewID = (type(_NewID) ~= "table" and {_NewID}) or _NewID;
    assert(#_OldID == #_NewID, "Sums of entities with changed owner does not add up!");
    for i=1, #_OldID do
        API.SendScriptEvent(QSB.ScriptEvents.EntityOwnerChanged, _OldID[i], _OldOwnerID, _NewID[i], _NewOwnerID);
        Logic.ExecuteInLuaLocalState(string.format(
            "API.SendScriptEvent(QSB.ScriptEvents.EntityOwnerChanged, %d)",
            _OldID[i],
            _OldOwnerID,
            _NewID[i],
            _NewOwnerID
        ));
    end
end

function ModuleEntityEventCore.Global:OnSaveGameLoaded()
    self:OverrideLogic();
end

function ModuleEntityEventCore.Global:CleanTaggedAndDeadEntities()
    -- check if entity should no longer be considered attacked
    for k,v in pairs(self.AttackedEntities) do
        self.AttackedEntities[k][2] = v[2] - 1;
        if v[2] <= 0 then
            self.AttackedEntities[k] = nil;
        else
            -- Send killed event for knights
            if IsExisting(k) and IsExisting(v[1]) and Logic.IsKnight(k) then
                if not self.OverkillEntities[k] and Logic.KnightGetResurrectionProgress(k) ~= 1 then
                    local PlayerID1 = Logic.EntityGetPlayer(k);
                    local PlayerID2 = Logic.EntityGetPlayer(v[1]);
                    API.SendScriptEvent(QSB.ScriptEvents.EntityKilled, k, PlayerID1, v[1], PlayerID2);
                    Logic.ExecuteInLuaLocalState(string.format(
                        "API.SendScriptEvent(QSB.ScriptEvents.EntityKilled, %d, %d, %d, %d)",
                        k,
                        PlayerID1,
                        v[1],
                        PlayerID2
                    ));
                    self.OverkillEntities[k] = 50;
                    self.AttackedEntities[k] = nil;
                end
            end
        end
    end
    -- unregister overkill entities
    for k,v in pairs(self.OverkillEntities) do
        self.OverkillEntities[k] = v - 1;
        if v <= 0 then
            self.OverkillEntities[k] = nil;
        end
    end

    -- unregister dead entities if not already unregistered
    for k,v in pairs(self.RegisteredEntities) do
        if not IsExisting(v) then
            self:UnregisterEntityAndTriggerEvent(v);
        end
    end
end

function ModuleEntityEventCore.Global:OverrideCallback()
    GameCallback_SettlerSpawned_Orig_QSB_EntityCore = GameCallback_SettlerSpawned
    GameCallback_SettlerSpawned = function(_PlayerID, _EntityID)
        GameCallback_SettlerSpawned_Orig_QSB_EntityCore(_PlayerID, _EntityID);
        ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(_EntityID);
    end

    GameCallback_OnBuildingConstructionComplete_Orig_QSB_EntityCore = GameCallback_SettlerSpawned
    GameCallback_OnBuildingConstructionComplete = function(_PlayerID, _EntityID)
        GameCallback_OnBuildingConstructionComplete_Orig_QSB_EntityCore(_PlayerID, _EntityID);
        ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(_EntityID);
        ModuleEntityEventCore.Global:TriggerConstructionCompleteEvent(_PlayerID, _EntityID);
    end

    GameCallback_FarmAnimalChangedPlayerID_Orig_QSB_EntityCore = GameCallback_FarmAnimalChangedPlayerID;
    GameCallback_FarmAnimalChangedPlayerID = function(_PlayerID, _NewEntityID, _OldEntityID)
        GameCallback_FarmAnimalChangedPlayerID_Orig_QSB_EntityCore(_PlayerID, _NewEntityID, _OldEntityID);
        local OldPlayerID = Logic.EntityGetPlayer(_OldEntityID);
        local NewPlayerID = Logic.EntityGetPlayer(_NewEntityID);
        ModuleEntityEventCore.Global:UnregisterEntityAndTriggerEvent(_OldEntityID);
        ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(_NewEntityID);
        ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(_OldEntityID, OldPlayerID, _NewEntityID, NewPlayerID);
    end

    GameCallback_EntityCaptured_Orig_QSB_EntityCore = GameCallback_EntityCaptured;
    GameCallback_EntityCaptured = function(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        GameCallback_EntityCaptured_Orig_QSB_EntityCore(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        ModuleEntityEventCore.Global:UnregisterEntityAndTriggerEvent(_OldEntityID);
        ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(_NewEntityID);
        ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID);
    end

    GameCallback_CartFreed_Orig_QSB_EntityCore = GameCallback_CartFreed;
    GameCallback_CartFreed = function(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        GameCallback_CartFreed_Orig_QSB_EntityCore(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID);
        ModuleEntityEventCore.Global:UnregisterEntityAndTriggerEvent(_OldEntityID);
        ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(_NewEntityID);
        ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID);
    end

    GameCallback_OnThiefDeliverEarnings_Orig_QSB_EntityCore = GameCallback_OnThiefDeliverEarnings;
    GameCallback_OnThiefDeliverEarnings = function(_ThiefPlayerID, _ThiefID, _BuildingID, _GoodAmount)
        GameCallback_OnThiefDeliverEarnings_Orig_QSB_EntityCore(_ThiefPlayerID, _ThiefID, _BuildingID, _GoodAmount);
        local BuildingPlayerID = Logic.EntityGetPlayer(_BuildingID);
        ModuleEntityEventCore.Global:TriggerThiefDeliverEarningsEvent(_ThiefID, _ThiefPlayerID, _BuildingID, BuildingPlayerID, _GoodAmount);
    end

    GameCallback_OnThiefStealBuilding_Orig_QSB_EntityCore = GameCallback_OnThiefStealBuilding;
    GameCallback_OnThiefStealBuilding = function(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID)
        ModuleEntityEventCore.Global:TriggerThiefStealFromBuildingEvent(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID);
    end

    GameCallback_OnBuildingUpgradeFinished_Orig_QSB_EntityCore = GameCallback_OnBuildingUpgradeFinished;
	GameCallback_OnBuildingUpgradeFinished = function(_PlayerID, _EntityID, _NewUpgradeLevel)
		GameCallback_OnBuildingUpgradeFinished_Orig_QSB_EntityCore(_PlayerID, _EntityID, _NewUpgradeLevel);
        ModuleEntityEventCore.Global:TriggerUpgradeCompleteEvent(_PlayerID, _EntityID, _NewUpgradeLevel);
    end
end

function ModuleEntityEventCore.Global:OverrideLogic()    
    self.Logic_CreateConstructionSite = Logic.CreateConstructionSite;
    Logic.CreateConstructionSite = function(...)
        local ID = self.Logic_CreateConstructionSite(unpack(arg));
        ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(ID);
        return ID;
    end

    self.Logic_CreateEntity = Logic.CreateEntity;
    Logic.CreateEntity = function(...)
        local ID = self.Logic_CreateEntity(unpack(arg));
        ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(ID);
        return ID;
    end

    self.Logic_CreateEntityOnUnblockedLand = Logic.CreateEntityOnUnblockedLand;
    Logic.CreateEntityOnUnblockedLand = function(...)
        local ID = self.Logic_CreateEntityOnUnblockedLand(unpack(arg));
        ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(ID);
        return ID;
    end

    self.Logic_CreateBattalion = Logic.CreateBattalion;
    Logic.CreateBattalion = function(...)
        local ID = self.Logic_CreateBattalion(unpack(arg));
        ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(ID);
        return ID;
    end

    self.Logic_CreateBattalionOnUnblockedLand = Logic.CreateBattalionOnUnblockedLand;
    Logic.CreateBattalionOnUnblockedLand = function(...)
        local ID = self.Logic_CreateBattalionOnUnblockedLand(unpack(arg));
        ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(ID);
        return ID;
    end

    self.Logic_ChangeEntityPlayerID = Logic.ChangeEntityPlayerID;
    Logic.ChangeEntityPlayerID = function(...)
        local OldID = arg[1];
        local OldPlayerID = Logic.EntityGetPlayer(arg[1]);
        local NewID = self.Logic_ChangeEntityPlayerID(unpack(arg));
        local NewPlayerID = Logic.EntityGetPlayer(NewID[1]);
        ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(OldID, OldPlayerID, NewID, NewPlayerID);
        return NewID;
    end

    self.Logic_ChangeSettlerPlayerID = Logic.ChangeSettlerPlayerID;
    Logic.ChangeSettlerPlayerID = function(...)
        local OldID = {arg[1]};
        OldID = Array_Append(OldID, API.GetGroupSoldiers(arg[1]));
        local OldPlayerID = Logic.EntityGetPlayer(arg[1]);
        local NewID = {self.Logic_ChangeSettlerPlayerID(unpack(arg))};
        NewID = Array_Append(NewID, API.GetGroupSoldiers(NewID[1]));
        local NewPlayerID = Logic.EntityGetPlayer(NewID[1]);
        ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(OldID, OldPlayerID, NewID, NewPlayerID);
        return NewID[1];
    end
end

function ModuleEntityEventCore.Global:TriggerThiefDeliverEarningsEvent(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID, _GoodAmount)
    API.SendScriptEvent(QSB.ScriptEvents.ThiefDeliverEarnings, _ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID, _GoodAmount);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.ThiefDeliverEarnings, %d, %d, %d, %d, %d)",
        _ThiefID,
        _ThiefPlayerID,
        _BuildingID,
        _BuildingPlayerID,
        _GoodAmount
    ));
end

function ModuleEntityEventCore.Global:TriggerThiefStealFromBuildingEvent(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID)
    local HeadquartersID = Logic.GetHeadquarters(_BuildingPlayerID);
    local CathedralID = Logic.GetCathedral(_BuildingPlayerID);
    local StorehouseID = Logic.GetStoreHouse(_BuildingPlayerID);
    local IsVillageStorehouse = Logic.IsEntityInCategory(StorehouseID, EntityCategories.VillageStorehouse) == 0;
    local BuildingType = Logic.GetEntityType(_BuildingID);

    -- Aus Lagerhaus stehlen
    if StorehouseID == _BuildingID and (not IsVillageStorehouse or HeadquartersID == 0) then
        if not self.DisableThiefStorehouseHeist then
            GameCallback_OnThiefStealBuilding_Orig_QSB_EntityCore(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID);
        end
    end
    -- Kirche sabotieren
    if CathedralID == _BuildingID then
        if not self.DisableThiefCathedralSabotage then
            GameCallback_OnThiefStealBuilding_Orig_QSB_EntityCore(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID);
        end
    end
    -- Brunnen sabotieren
    if Framework.GetGameExtraNo() > 0 and BuildingType == Entities.B_Cistern then
        if not self.DisableThiefCisternSabotage then
            GameCallback_OnThiefStealBuilding_Orig_QSB_EntityCore(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID);
        end
    end

    -- Send event
    API.SendScriptEvent(QSB.ScriptEvents.ThiefInfiltratedBuilding, _ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.ThiefInfiltratedBuilding, %d, %d, %d, %d)",
        _ThiefID,
        _ThiefPlayerID,
        _BuildingID,
        _BuildingPlayerID
    ));
end

function ModuleEntityEventCore.Global:TriggerConstructionCompleteEvent(_PlayerID, _EntityID)
    API.SendScriptEvent(QSB.ScriptEvents.BuildingConstructed, _PlayerID, _EntityID);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.BuildingConstructed, %d, %d)",
        _PlayerID,
        _EntityID
    ));
end

function ModuleEntityEventCore.Global:TriggerUpgradeCompleteEvent(_PlayerID, _EntityID, _NewUpgradeLevel)
    API.SendScriptEvent(QSB.ScriptEvents.BuildingUpgraded, _PlayerID, _EntityID, _NewUpgradeLevel);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.BuildingUpgraded, %d, %d, %d)",
        _PlayerID,
        _EntityID,
        _NewUpgradeLevel
    ));
end

function ModuleEntityEventCore.Global:StartTriggers()
    function ModuleEntityEventCore_Trigger_EveryTurn()
        if Logic.GetCurrentTurn() > 0 then
            ModuleEntityEventCore.Global:CheckOnSpawnerEntities();
            ModuleEntityEventCore.Global:CheckOnNonTrackableEntities();
            ModuleEntityEventCore.Global:CleanTaggedAndDeadEntities();
        end
    end
    Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "ModuleEntityEventCore_Trigger_EveryTurn", 1);

    -- Why did I even put this here... This trigger is dead... :(
    function ModuleEntityEventCore_Trigger_EntityCreated()
        local EntityID = Event.GetEntityID();
        ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(EntityID);
    end
    Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "ModuleEntityEventCore_Trigger_EntityCreated", 1);

    function ModuleEntityEventCore_Trigger_EntityDestroyed()
        local EntityID1 = Event.GetEntityID();
        local PlayerID1 = Event.GetPlayerID();
        ModuleEntityEventCore.Global:UnregisterEntityAndTriggerEvent(EntityID1);
        if ModuleEntityEventCore.Global.AttackedEntities[EntityID1] ~= nil then
            local EntityID2 = ModuleEntityEventCore.Global.AttackedEntities[EntityID1][1];
            local PlayerID2 = Logic.EntityGetPlayer(EntityID2);
            ModuleEntityEventCore.Global.AttackedEntities[EntityID1] = nil;

            API.SendScriptEvent(QSB.ScriptEvents.EntityKilled, EntityID1, PlayerID1, EntityID2, PlayerID2);
            Logic.ExecuteInLuaLocalState(string.format(
                "API.SendScriptEvent(QSB.ScriptEvents.EntityKilled, %d, %d, %d, %d);",
                EntityID1,
                PlayerID1,
                EntityID2,
                PlayerID2
            ));
        end
    end
    Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "ModuleEntityEventCore_Trigger_EntityDestroyed", 1);
end

function ModuleEntityEventCore.Global:GetAllEntitiesOfType(_Type)
    local ResultList = {};
    for i= 1, 8 do
        local n,eID = Logic.GetPlayerEntities(i, _Type, 1);
        if (n > 0) then
            local firstEntity = eID;
            repeat
                table.insert(ResultList,eID)
                eID = Logic.GetNextEntityOfPlayerOfType(eID);
            until (firstEntity == eID);
        end
    end
    return ResultList;
end

function ModuleEntityEventCore.Global:CheckOnNonTrackableEntities()
    -- -- Buildings
    for i= 1, 8 do
        local Buildings = {Logic.GetPlayerEntitiesInCategory(i, EntityCategories.AttackableBuilding)};
        for j= 1, #Buildings do
            self:RegisterEntityAndTriggerEvent(Buildings[j]);
        end
        local Walls = {Logic.GetPlayerEntitiesInCategory(i, EntityCategories.AttackableBuilding)};
        for j= 1, #Walls do
            self:RegisterEntityAndTriggerEvent(Walls[j]);
        end
    end
    -- -- Ambiend and Resources
    for i= 1, #self.SharedAnimalTypes do
        if Logic.GetCurrentTurn() % 10 == i and Entities[self.SharedAnimalTypes[i]] then
            local FoundEntities = Logic.GetEntitiesOfType(Entities[self.SharedAnimalTypes[i]]);
            for j= 1, #FoundEntities do
                self:RegisterEntityAndTriggerEvent(FoundEntities[j]);
            end
        end
    end
    for i= 1, #self.SharedResourceTypes do
        if Logic.GetCurrentTurn() % 10 == i and Entities[self.SharedAnimalTypes[i]] then
            local FoundEntities = Logic.GetEntitiesOfType(Entities[self.SharedResourceTypes[i]]);
            for j= 1, #FoundEntities do
                self:RegisterEntityAndTriggerEvent(FoundEntities[j]);
            end
        end
    end
    for k, v in pairs(Entities) do
        local TypesToSearch = {};
        if string.find(k, "^A_" ..self.ClimateShort.. "_") or string.find(k, "^R_" ..self.ClimateShort.. "_") then
            if Entities[k] then
                table.insert(TypesToSearch, v);
            end
        end
        for i= 1, #TypesToSearch do
            if Logic.GetCurrentTurn() % 10 == i then
                local FoundEntities = Logic.GetEntitiesOfType(TypesToSearch[i]);
                for j= 1, #FoundEntities do
                    self:RegisterEntityAndTriggerEvent(FoundEntities[j]);
                end
            end
        end
    end
end

function ModuleEntityEventCore.Global:GetClimateZoneShort()
    local ClimateZone = Logic.GetClimateZone();
    local Suffix = ""

    if ClimateZone ==  ClimateZones.Generic
    or ClimateZone == ClimateZones.MiddleEurope then
        Suffix = "ME"
    elseif ClimateZone == ClimateZones.NorthEurope then
        Suffix = "NE"
    elseif ClimateZone == ClimateZones.SouthEurope then
        Suffix = "SE"
    elseif ClimateZone == ClimateZones.NorthAfrica then
        Suffix = "NA"
    elseif ClimateZone == ClimateZones.Asia then
        Suffix = "AS"
    end
    return Suffix;
end

function ModuleEntityEventCore.Global:CheckOnSpawnerEntities()
    -- Get spawners
    local SpawnerEntities = {};
    for i= 1, #self.SpawnerTypes do
        if Entities[self.SpawnerTypes[i]] then
            if Logic.GetCurrentTurn() % 10 == i then
                for k, v in pairs(Logic.GetEntitiesOfType(Entities[self.SpawnerTypes[i]])) do
                    self:RegisterEntityAndTriggerEvent(v);
                    table.insert(SpawnerEntities, v);
                end
            end
        end
    end
    -- Check spawned entities
    for i= 1, #SpawnerEntities do
        for k, v in pairs{Logic.GetSpawnedEntities(SpawnerEntities[i])} do
            self:RegisterEntityAndTriggerEvent(v);
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleEntityEventCore.Local:OnGameStart()
    QSB.ScriptEvents.EntityRegistered = API.RegisterScriptEvent("Event_EntityRegistered");
    QSB.ScriptEvents.EntityDestroyed = API.RegisterScriptEvent("Event_EntityDestroyed");
    QSB.ScriptEvents.EntityHurt = API.RegisterScriptEvent("Event_EntityHurt");
    QSB.ScriptEvents.EntityKilled = API.RegisterScriptEvent("Event_EntityKilled");
    QSB.ScriptEvents.EntityOwnerChanged = API.RegisterScriptEvent("Event_EntityOwnerChanged");
    QSB.ScriptEvents.EntityResourceChanged = API.RegisterScriptEvent("Event_EntityResourceChanged");

    QSB.ScriptEvents.ThiefInfiltratedBuilding = API.RegisterScriptEvent("Event_ThiefInfiltratedBuilding");
    QSB.ScriptEvents.ThiefDeliverEarnings = API.RegisterScriptEvent("Event_ThiefDeliverEarnings");
    QSB.ScriptEvents.BuildingConstructed = API.RegisterScriptEvent("Event_BuildingConstructed");
    QSB.ScriptEvents.BuildingUpgraded = API.RegisterScriptEvent("Event_BuildingUpgraded");

    self:StartTriggers();
end

function ModuleEntityEventCore.Local:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.EntityRegistered then
        ModuleEntityEventCore.Shared:SaveHighestEntity(arg[1]);
    end
end

function ModuleEntityEventCore.Local:StartTriggers()
    GameCallback_Feedback_EntityHurt_Orig_QSB_EntityCore = GameCallback_Feedback_EntityHurt;
    GameCallback_Feedback_EntityHurt = function(_HurtPlayerID, _HurtEntityID, _HurtingPlayerID, _HurtingEntityID, _DamageReceived, _DamageDealt)
        GameCallback_Feedback_EntityHurt_Orig_QSB_EntityCore(_HurtPlayerID, _HurtEntityID, _HurtingPlayerID, _HurtingEntityID, _DamageReceived, _DamageDealt);

        API.SendScriptCommand(
            QSB.ScriptCommands.SendScriptEvent,
            QSB.ScriptEvents.EntityHurt,
            _HurtEntityID,
            _HurtPlayerID,
            _HurtingEntityID,
            _HurtingPlayerID,
            _DamageDealt,
            _DamageReceived
        );
        -- GUI.SendScriptCommand(string.format(
        --     "API.SendScriptEvent(QSB.ScriptEvents.EntityHurt, %d, %d, %d, %d, %d, %d)",
        --     _HurtEntityID,
        --     _HurtPlayerID,
        --     _HurtingEntityID,
        --     _HurtingPlayerID,
        --     _DamageDealt,
        --     _DamageReceived
        -- ));
        API.SendScriptEvent(QSB.ScriptEvents.EntityHurt, _HurtEntityID, _HurtPlayerID, _HurtingEntityID, _HurtingPlayerID, _DamageDealt, _DamageReceived);
    end

    GameCallback_Feedback_MineAmountChanged_Orig_QSB_EntityCore = GameCallback_Feedback_MineAmountChanged;
    GameCallback_Feedback_MineAmountChanged = function(_MineID, _GoodType, _TerritoryID, _PlayerID, _Amount)
        GameCallback_Feedback_MineAmountChanged_Orig_QSB_EntityCore(_MineID, _GoodType, _TerritoryID, _PlayerID, _Amount);

        API.SendScriptCommand(
            QSB.ScriptCommands.SendScriptEvent,
            QSB.ScriptEvents.EntityResourceChanged,
            _MineID,
            _GoodType,
            _Amount
        );
        -- GUI.SendScriptCommand(string.format(
        --     "API.SendScriptEvent(QSB.ScriptEvents.EntityResourceChanged, %d, %d, %d)",
        --     _MineID,
        --     _GoodType,
        --     _Amount
        -- ));
        API.SendScriptEvent(QSB.ScriptEvents.EntityResourceChanged, _MineID, _GoodType, _Amount);
    end
end

-- Shared ------------------------------------------------------------------- --

function ModuleEntityEventCore.Shared:SaveHighestEntity(_ID)
    if _ID > 131072 then
		local OldID = (_ID - math.floor(_ID/65536)*65536) + 65536;
		self.ReplacementEntityID[OldID] = _ID
	else
		self.HighestEntityID = _ID;
	end
end

function ModuleEntityEventCore.Shared:GetHighestEntity()
    return self.HighestEntityID;
end

function ModuleEntityEventCore.Shared:GetReplacementID(_ID)
    return self.ReplacementEntityID[_ID];
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleEntityEventCore);

