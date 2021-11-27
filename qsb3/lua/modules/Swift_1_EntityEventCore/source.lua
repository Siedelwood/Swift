--[[
Swift_1_DisplayCore/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

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

function ModuleEntityEventCore.Global:OnGameStart()
    QSB.ScriptEvents.EntityCreated = API.RegisterScriptEvent("Event_EntityCreated");
    QSB.ScriptEvents.EntityDestroyed = API.RegisterScriptEvent("Event_EntityDestroyed");
    QSB.ScriptEvents.EntityHurt = API.RegisterScriptEvent("Event_EntityHurt");
    QSB.ScriptEvents.EntityKilled = API.RegisterScriptEvent("Event_EntityKilled");
    QSB.ScriptEvents.EntityOwnerChanged = API.RegisterScriptEvent("Event_EntityOwnerChanged");

    self:StartTriggers();
    self:OverrideCallback();
    self:OverrideLogic();
end

function ModuleEntityEventCore.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:OnSaveGameLoaded();
    elseif _ID == QSB.ScriptEvents.EntityHurt then
        self.AttackedEntities[arg[1]] = {arg[3], 100};
    end
end

function ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(_EntityID)
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

function ModuleEntityEventCore.Global:UnregisterEntityAndTriggerEvent(_EntityID)
    if _EntityID and self.RegisteredEntities[_EntityID] then
        self.RegisteredEntities[_EntityID] = nil;
        API.SendScriptEvent(QSB.ScriptEvents.EntityDestroyed, _EntityID);
        Logic.ExecuteInLuaLocalState(string.format(
            "API.SendScriptEvent(QSB.ScriptEvents.EntityDestroyed, %d);",
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
            "API.SendScriptEvent(QSB.ScriptEvents.EntityOwnerChanged, %d);",
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

function ModuleEntityEventCore.Global:OverrideCallback()
    GameCallback_SettlerSpawned_Orig_Swift_EntityCore = GameCallback_SettlerSpawned
    GameCallback_SettlerSpawned = function(_PlayerID, _EntityID)
        GameCallback_SettlerSpawned_Orig_Swift_EntityCore(_PlayerID, _EntityID);
        ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(_EntityID);
    end

    GameCallback_OnBuildingConstructionComplete_Orig_Swift_EntityCore = GameCallback_SettlerSpawned
    GameCallback_OnBuildingConstructionComplete = function(_PlayerID, _EntityID)
        GameCallback_OnBuildingConstructionComplete_Orig_Swift_EntityCore(_PlayerID, _EntityID);
        ModuleEntityEventCore.Global:RegisterEntityAndTriggerEvent(_EntityID);
    end

    GameCallback_FarmAnimalChangedPlayerID_Orig_Swift_EntityCore = GameCallback_FarmAnimalChangedPlayerID;
    GameCallback_FarmAnimalChangedPlayerID = function(_PlayerID, _NewEntityID, _OldEntityID)
        GameCallback_FarmAnimalChangedPlayerID_Orig_Swift_EntityCore(_PlayerID, _NewEntityID, _OldEntityID);
        ModuleEntityEventCore.Global.RegisteredEntities[_OldEntityID] = nil;
        ModuleEntityEventCore.Global.RegisteredEntities[_NewEntityID] = true;
        local OldPlayerID = Logic.EntityGetPlayer(_OldEntityID);
        local NewPlayerID = Logic.EntityGetPlayer(_NewEntityID);
        ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(_OldEntityID, OldPlayerID, _NewEntityID, NewPlayerID);
    end

    GameCallback_EntityCaptured_Orig_Swift_EntityCore = GameCallback_EntityCaptured;
    GameCallback_EntityCaptured = function(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        GameCallback_EntityCaptured_Orig_Swift_EntityCore(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        ModuleEntityEventCore.Global.RegisteredEntities[_OldEntityID] = nil;
        ModuleEntityEventCore.Global.RegisteredEntities[_NewEntityID] = true;
        ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID);
    end
    
    GameCallback_CartFreed_Orig_Swift_EntityCore = GameCallback_CartFreed;
    GameCallback_CartFreed = function(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        GameCallback_CartFreed_Orig_Swift_EntityCore(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID);
        ModuleEntityEventCore.Global.RegisteredEntities[_OldEntityID] = nil;
        ModuleEntityEventCore.Global.RegisteredEntities[_NewEntityID] = true;
        ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID);
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

function ModuleEntityEventCore.Global:StartTriggers()
    function ModuleEntityEventCore_Trigger_EveryTurn()
        ModuleEntityEventCore.Global:CheckOnSpawnerEntities();
        ModuleEntityEventCore.Global:CheckOnNonTrackableEntities();
        ModuleEntityEventCore.Global:CleanTaggedAndDeadEntities();
    end
    Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "ModuleEntityEventCore_Trigger_EveryTurn", 1);

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

function ModuleEntityEventCore.Global:CheckOnNonTrackableEntities()
    -- Buildings
    for i= 1, 8 do
        for k, v in pairs{Logic.GetPlayerEntitiesInCategory(i, EntityCategories.AttackableBuilding)} do
            self:RegisterEntityAndTriggerEvent(v);
        end
    end
end

function ModuleEntityEventCore.Global:CheckOnSpawnerEntities()
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

function ModuleEntityEventCore.Local:OnGameStart()
    QSB.ScriptEvents.EntityCreated = API.RegisterScriptEvent("Event_EntityCreated");
    QSB.ScriptEvents.EntityDestroyed = API.RegisterScriptEvent("Event_EntityDestroyed");
    QSB.ScriptEvents.EntityHurt = API.RegisterScriptEvent("Event_EntityHurt");
    QSB.ScriptEvents.EntityKilled = API.RegisterScriptEvent("Event_EntityKilled");
    QSB.ScriptEvents.EntityOwnerChanged = API.RegisterScriptEvent("Event_EntityOwnerChanged");

    self:StartTriggers();
end

function ModuleEntityEventCore.Local:OnEvent(_ID, _Event, ...)
end

function ModuleEntityEventCore.Local:StartTriggers()
    GameCallback_Feedback_EntityHurt_Orig_Swift_EntityCore = GameCallback_Feedback_EntityHurt;
    GameCallback_Feedback_EntityHurt = function(_HurtPlayerID, _HurtEntityID, _HurtingPlayerID, _HurtingEntityID, _DamageReceived, _DamageDealt)
        GameCallback_Feedback_EntityHurt_Orig_Swift_EntityCore(_HurtPlayerID, _HurtEntityID, _HurtingPlayerID, _HurtingEntityID, _DamageReceived, _DamageDealt);

        GUI.SendScriptCommand(string.format(
            "API.SendScriptEvent(QSB.ScriptEvents.EntityHurt, %d, %d, %d, %d, %d, %d);",
            _HurtEntityID,
            _HurtPlayerID,
            _HurtingEntityID,
            _HurtingPlayerID,
            _DamageDealt,
            _DamageReceived
        ));
        API.SendScriptEvent(QSB.ScriptEvents.EntityHurt, _HurtEntityID, _HurtPlayerID, _HurtingEntityID, _HurtingPlayerID, _DamageDealt, _DamageReceived);
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleEntityEventCore);

