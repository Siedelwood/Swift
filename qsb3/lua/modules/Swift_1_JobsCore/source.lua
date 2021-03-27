-- -------------------------------------------------------------------------- --
-- Module Job                                                                 --
-- -------------------------------------------------------------------------- --

ModuleJobsCore = {
    Properties = {
        Name = "ModuleJobsCore",
    },

    Global = {};
    Local = {},
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        EventJobID = 0;
        EventJobs = {
            [Events.LOGIC_EVENT_DIPLOMACY_CHANGED]         = {},
            [Events.LOGIC_EVENT_ENTITY_CREATED]            = {},
            [Events.LOGIC_EVENT_ENTITY_DESTROYED]          = {},
            [Events.LOGIC_EVENT_ENTITY_HURT_ENTITY]        = {},
            [Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY] = {},
            [Events.LOGIC_EVENT_EVERY_SECOND]              = {},
            [Events.LOGIC_EVENT_EVERY_TURN]                = {},
            [Events.LOGIC_EVENT_GOODS_TRADED]              = {},
            [Events.LOGIC_EVENT_PLAYER_DIED]               = {},
            [Events.LOGIC_EVENT_RESEARCH_DONE]             = {},
            [Events.LOGIC_EVENT_TRIBUTE_PAID]              = {},
            [Events.LOGIC_EVENT_WEATHER_STATE_CHANGED]     = {},
        };
    };
};

function ModuleJobsCore.Global:OnGameStart()
    ModuleJobsCore.Shared:InstallEventJobs();
end

function ModuleJobsCore.Local:OnGameStart()
    ModuleJobsCore.Shared:InstallEventJobs();
end

function ModuleJobsCore.Shared:TriggerEventJobs(_Type)
    for k, v in pairs(self.EventJobs[_Type]) do
        if type(v) == "table" then
            if v.Active == false then
                self.EventJobs[_Type][k] = nil;
            else
                if v.Enabled then
                    if v.Function then
                        local Arguments = table.copy(v.Arguments or {});
                        Arguments = Array_Append(Arguments, v.Arguments or {});
                        if v.Function(unpack(Arguments)) == true then
                            self.EventJobs[_Type][k] = nil;
                        end
                    end
                end
            end
        end
    end
end

function ModuleJobsCore.Shared:InstallEventJobs()
    Trigger.RequestTrigger(
        Events.LOGIC_EVENT_EVERY_SECOND,
        "",
        "ModuleEventJob_OnEverySecond",
        1
    );

    Trigger.RequestTrigger(
        Events.LOGIC_EVENT_EVERY_TURN,
        "",
        "ModuleEventJob_OnEveryTurn",
        1
    );

    Trigger.RequestTrigger(
        Events.LOGIC_EVENT_ENTITY_DESTROYED,
        "",
        "ModuleEventJob_OnEntityDestroyed",
        1
    );

    Trigger.RequestTrigger(
        Events.LOGIC_EVENT_ENTITY_CREATED,
        "",
        "ModuleEventJob_OnEntityCreated",
        1
    );

    Trigger.RequestTrigger(
        Events.LOGIC_EVENT_ENTITY_HURT_ENTITY,
        "",
        "ModuleEventJob_OnEntityHurtEntity",
        1
    );
end

ModuleEventJob_OnDiplomacyChanged = function()
    ModuleJobsCore.Shared:TriggerEventJobs(Events.LOGIC_EVENT_DIPLOMACY_CHANGED);
end
ModuleEventJob_OnEntityDestroyed = function()
    local PlayerID = Event.GetPlayerID();
    local EntityID = Event.GetEntityID();
    ModuleJobsCore.Shared:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_DESTROYED, PlayerID, EntityID);
end
ModuleEventJob_OnEntityHurtEntity = function()
    local PlayerID1 = Event.GetPlayerID1();
    local EntityID1 = Event.GetEntityID1();
    local PlayerID2 = Event.GetPlayerID2();
    local EntityID2 = Event.GetEntityID2();
    ModuleJobsCore.Shared:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, PlayerID1, EntityID1, PlayerID2, EntityID2);
end
ModuleEventJob_OnEverySecond = function()
    ModuleJobsCore.Shared:TriggerEventJobs(Events.LOGIC_EVENT_EVERY_SECOND);
end
ModuleEventJob_OnEveryTurn = function()
    ModuleJobsCore.Shared:TriggerEventJobs(Events.LOGIC_EVENT_EVERY_TURN);
end

-- FIXME: Useless?
ModuleEventJob_OnEntityCreated = function()
    local PlayerID = Event.GetPlayerID();
    local EntityID = Event.GetEntityID();
    ModuleJobsCore.Shared:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_CREATED, PlayerID, EntityID);
end
ModuleEventJob_OnEntityInRangeOfEntity = function()
    ModuleJobsCore.Shared:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY);
end
ModuleEventJob_OnGoodsTraded = function()
    ModuleJobsCore.Shared:TriggerEventJobs(Events.LOGIC_EVENT_GOODS_TRADED);
end
ModuleEventJob_OnPlayerDied = function()
    ModuleJobsCore.Shared:TriggerEventJobs(Events.LOGIC_EVENT_PLAYER_DIED);
end
ModuleEventJob_OnResearchDone = function()
    ModuleJobsCore.Shared:TriggerEventJobs(Events.LOGIC_EVENT_RESEARCH_DONE);
end
ModuleEventJob_OnTributePaied = function()
    ModuleJobsCore.Shared:TriggerEventJobs(Events.LOGIC_EVENT_TRIBUTE_PAID);
end
ModuleEventJob_OnWatherChanged = function()
    ModuleJobsCore.Shared:TriggerEventJobs(Events.LOGIC_EVENT_WEATHER_STATE_CHANGED);
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleJobsCore);

