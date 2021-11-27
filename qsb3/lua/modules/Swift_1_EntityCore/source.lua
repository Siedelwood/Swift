--[[
Swift_1_DisplayCore/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleEntityCore = {
    Properties = {
        Name = "ModuleEntityCore",
    },

    Global = {
        RegisteredEntities = {},
        AttackedEntities = {},

        SpawnerTypes = {
            "S_AxisDeer_AS",
            "S_Bear",
            "S_Bear_Black",
            "S_BearBlack",
            "S_Deer_ME",
            "S_FallowDeer_SE",
            "S_Gazelle_NA",
            "S_Herbs",
            "S_LionPack_NA",
            "S_Moose_NE",
            "S_PolarBear_NE",
            "S_Reindeer_NE",
            "S_TigerPack_AS",
            "S_WildBoar",
            "S_WolfPack",
            "S_Zebra_NA",
            "B_NPC_BanditsHQ_AS",
            "B_NPC_BanditsHQ_ME",
            "B_NPC_BanditsHQ_NA",
            "B_NPC_BanditsHQ_NE",
            "B_NPC_BanditsHQ_SE",
            "B_NPC_BanditsHutBig_AS",
            "B_NPC_BanditsHutBig_ME",
            "B_NPC_BanditsHutBig_NA",
            "B_NPC_BanditsHutBig_NE",
            "B_NPC_BanditsHutBig_SE",
            "B_NPC_BanditsHutSmall_AS",
            "B_NPC_BanditsHutSmall_ME",
            "B_NPC_BanditsHutSmall_NA",
            "B_NPC_BanditsHutSmall_NE",
            "B_NPC_BanditsHutSmall_SE",
            "B_NPC_Barracks_AS",
            "B_NPC_Barracks_ME",
            "B_NPC_Barracks_NA",
            "B_NPC_Barracks_NE",
            "B_NPC_Barracks_SE",
        },
    },
    Local = {},
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
}

-- Global ------------------------------------------------------------------- --

function ModuleEntityCore.Global:OnGameStart()
    QSB.ScriptEvents.EntityCreated = API.RegisterScriptEvent("Event_EntityCreated");
    QSB.ScriptEvents.EntityDestroyed = API.RegisterScriptEvent("Event_EntityDestroyed");
    QSB.ScriptEvents.EntityHurt = API.RegisterScriptEvent("Event_EntityHurt");
    QSB.ScriptEvents.EntityKilled = API.RegisterScriptEvent("Event_EntityKilled");

    self:StartTriggers();
    self:OverrideCallback();
    self:OverrideLogic();
end

function ModuleEntityCore.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:OnSaveGameLoaded();
    elseif _ID == QSB.ScriptEvents.EntityHurt then
        self.AttackedEntities[arg[1]] = {arg[3], 100};
    end
end

function ModuleEntityCore.Global:RegisterEntityAndTriggerEvent(_EntityID)
    if _EntityID and IsExisting(_EntityID) then
        if not self.RegisteredEntities[_EntityID] then
            self.RegisteredEntities[_EntityID] = true;
            API.SendScriptEvent(QSB.ScriptEvents.EntityCreated, _EntityID);
            Logic.ExecuteInLuaLocalState(string.format(
                "API.SendScriptEvent(QSB.ScriptEvents.EntityCreated, %d);",
                _EntityID
            ))
        end
    end
end

function ModuleEntityCore.Global:UnregisterEntityAndTriggerEvent(_EntityID)
    if _EntityID and self.RegisteredEntities[_EntityID] then
        self.RegisteredEntities[_EntityID] = nil;
        API.SendScriptEvent(QSB.ScriptEvents.EntityDestroyed, _EntityID);
        Logic.ExecuteInLuaLocalState(string.format(
            "API.SendScriptEvent(QSB.ScriptEvents.EntityDestroyed, %d);",
            _EntityID
        ))
    end
end

function ModuleEntityCore.Global:OnSaveGameLoaded()
    self:OverrideLogic();
end

function ModuleEntityCore.Global:CleanTaggedAndDeadEntities()
    for k,v in pairs(self.AttackedEntities) do
        self.AttackedEntities[k][2] = v[2] - 1;
        if v[2] <= 0 then
            self.AttackedEntities[k] = nil;
        end
    end
    for k,v in pairs(self.RegisteredEntities) do
        if not IsExisting(v) then
            self:UnregisterEntityAndTriggerEvent(v);
        end
    end
end

function ModuleEntityCore.Global:OverrideCallback()
    GameCallback_SettlerSpawned_Orig_Swift_EntityCore = GameCallback_SettlerSpawned
    GameCallback_SettlerSpawned = function(_PlayerID, _EntityID)
        GameCallback_SettlerSpawned_Orig_Swift_EntityCore(_PlayerID, _EntityID);
        ModuleEntityCore.Global:RegisterEntityAndTriggerEvent(_EntityID);
    end

    GameCallback_OnBuildingConstructionComplete_Orig_Swift_EntityCore = GameCallback_SettlerSpawned
    GameCallback_OnBuildingConstructionComplete = function(_PlayerID, _EntityID)
        GameCallback_OnBuildingConstructionComplete_Orig_Swift_EntityCore(_PlayerID, _EntityID);
        ModuleEntityCore.Global:RegisterEntityAndTriggerEvent(_EntityID);
    end

    -- Farm Animals that changing their owner musn't trigger as created or destroyed  entity!
    GameCallback_FarmAnimalChangedPlayerID_Orig_Swift_EntityCore = GameCallback_FarmAnimalChangedPlayerID;
    GameCallback_FarmAnimalChangedPlayerID = function(_PlayerID, _NewEntityID, _OldEntityID)
        GameCallback_FarmAnimalChangedPlayerID_Orig_Swift_EntityCore(_PlayerID, _NewEntityID, _OldEntityID);
        ModuleEntityCore.Global.RegisteredEntities[_OldEntityID] = nil;
        ModuleEntityCore.Global.RegisteredEntities[_NewEntityID] = true;
    end
    -- Captured entities musn't trigger as created or destroyed entity!
    GameCallback_EntityCaptured_Orig_Swift_EntityCore = GameCallback_EntityCaptured;
    GameCallback_EntityCaptured = function(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        GameCallback_EntityCaptured_Orig_Swift_EntityCore(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        ModuleEntityCore.Global.RegisteredEntities[_OldEntityID] = nil;
        ModuleEntityCore.Global.RegisteredEntities[_NewEntityID] = true;
    end
    -- Rescured entities musn't trigger as created or destroyed  entity!
    GameCallback_CartFreed_Orig_Swift_EntityCore = GameCallback_CartFreed;
    GameCallback_CartFreed = function(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        GameCallback_CartFreed_Orig_Swift_EntityCore(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID);
        ModuleEntityCore.Global.RegisteredEntities[_OldEntityID] = nil;
        ModuleEntityCore.Global.RegisteredEntities[_NewEntityID] = true;
    end
end

function ModuleEntityCore.Global:OverrideLogic()
    self.Logic_CreateConstructionSite = Logic.CreateConstructionSite;
    Logic.CreateConstructionSite = function(...)
        local ID = self.Logic_CreateConstructionSite(unpack(arg));
        ModuleEntityCore.Global:RegisterEntityAndTriggerEvent(ID);
        return ID;
    end

    self.Logic_CreateEntity = Logic.CreateEntity;
    Logic.CreateEntity = function(...)
        local ID = self.Logic_CreateEntity(unpack(arg));
        ModuleEntityCore.Global:RegisterEntityAndTriggerEvent(ID);
        return ID;
    end

    self.Logic_CreateEntityOnUnblockedLand = Logic.CreateEntityOnUnblockedLand;
    Logic.CreateEntityOnUnblockedLand = function(...)
        local ID = self.Logic_CreateEntityOnUnblockedLand(unpack(arg));
        ModuleEntityCore.Global:RegisterEntityAndTriggerEvent(ID);
        return ID;
    end

    self.Logic_CreateBattalion = Logic.CreateBattalion;
    Logic.CreateBattalion = function(...)
        local ID = self.Logic_CreateBattalion(unpack(arg));
        ModuleEntityCore.Global:RegisterEntityAndTriggerEvent(ID);
        return ID;
    end

    self.Logic_CreateBattalionOnUnblockedLand = Logic.CreateBattalionOnUnblockedLand;
    Logic.CreateBattalionOnUnblockedLand = function(...)
        local ID = self.Logic_CreateBattalionOnUnblockedLand(unpack(arg));
        ModuleEntityCore.Global:RegisterEntityAndTriggerEvent(ID);
        return ID;
    end
end

function ModuleEntityCore.Global:StartTriggers()
    function ModuleEntityCore_Trigger_EveryTurn()
        ModuleEntityCore.Global:CheckOnSpawnerEntities();
        ModuleEntityCore.Global:CheckOnNonTrackableEntities();
        ModuleEntityCore.Global:CleanTaggedAndDeadEntities();
    end
    Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "ModuleEntityCore_Trigger_EveryTurn", 1);

    function ModuleEntityCore_Trigger_EntityCreated()
        local EntityID = Event.GetEntityID();
        ModuleEntityCore.Global:RegisterEntityAndTriggerEvent(EntityID);
    end
    Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "ModuleEntityCore_Trigger_EntityCreated", 1);

    function ModuleEntityCore_Trigger_EntityDestroyed()
        local EntityID1 = Event.GetEntityID();
        ModuleEntityCore.Global:UnregisterEntityAndTriggerEvent(EntityID1);
        if ModuleEntityCore.Global.AttackedEntities[EntityID1] ~= nil then
            local EntityID2 = ModuleEntityCore.Global.AttackedEntities[EntityID1][1];

            API.SendScriptEvent(QSB.ScriptEvents.EntityKilled, EntityID1, EntityID2);
            Logic.ExecuteInLuaLocalState(string.format(
                "API.SendScriptEvent(QSB.ScriptEvents.EntityKilled, %d, %d);",
                EntityID1,
                EntityID2
            ));
        end
    end
    Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "ModuleEntityCore_Trigger_EntityDestroyed", 1);
end

function ModuleEntityCore.Global:CheckOnNonTrackableEntities()
    -- Buildings
    for i= 1, 8 do
        for k, v in pairs{Logic.GetPlayerEntitiesInCategory(i, EntityCategories.AttackableBuilding)} do
            self:RegisterEntityAndTriggerEvent(v);
        end
    end
end

function ModuleEntityCore.Global:CheckOnSpawnerEntities()
    -- Get spawners
    local SpawnerEntities = {};
    for i= 1, #self.SpawnerTypes do
        if Entities[self.SpawnerTypes[i]] then
            for k, v in pairs{Logic.GetEntities(Entities[self.SpawnerTypes[i]])} do
                self:RegisterEntityAndTriggerEvent(v);
                table.insert(SpawnerEntities, v);
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

function ModuleEntityCore.Local:OnGameStart()
    QSB.ScriptEvents.EntityCreated = API.RegisterScriptEvent("Event_EntityCreated");
    QSB.ScriptEvents.EntityDestroyed = API.RegisterScriptEvent("Event_EntityDestroyed");
    QSB.ScriptEvents.EntityHurt = API.RegisterScriptEvent("Event_EntityHurt");
    QSB.ScriptEvents.EntityKilled = API.RegisterScriptEvent("Event_EntityKilled");

    self:StartTriggers();
end

function ModuleEntityCore.Local:OnEvent(_ID, _Event, ...)
end

function ModuleEntityCore.Local:StartTriggers()
    GameCallback_Feedback_EntityHurt_Orig_Swift_EntityCore = GameCallback_Feedback_EntityHurt;
    GameCallback_Feedback_EntityHurt = function(_HurtPlayerID, _HurtEntityID, _HurtingPlayerID, _HurtingEntityID, _DamageReceived, _DamageDealt)
        GameCallback_Feedback_EntityHurt_Orig_Swift_EntityCore(_HurtPlayerID, _HurtEntityID, _HurtingPlayerID, _HurtingEntityID, _DamageReceived, _DamageDealt);

        GUI.SendScriptCommand(string.format(
            "API.SendScriptEvent(QSB.ScriptEvents.EntityHurt, %d, %d, %d, %d);",
            _HurtEntityID,
            _HurtingEntityID,
            _DamageDealt,
            _DamageReceived
        ));
        API.SendScriptEvent(QSB.ScriptEvents.EntityHurt, _HurtEntityID, _HurtingEntityID, _DamageDealt, _DamageReceived);
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleEntityCore);

