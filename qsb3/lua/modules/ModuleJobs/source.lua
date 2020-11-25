-- -------------------------------------------------------------------------- --
-- Module Job                                                                 --
-- -------------------------------------------------------------------------- --

ModuleJobs = {
    Properties = {
        Name = "Job",
    },

    m_EventJobID = 0;
    m_EventJobs = {
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

function ModuleJobs:OnGameStart()
    self:InstallEventJobs();
end

function ModuleJobs:TriggerEventJobs(_Type)
    for k, v in pairs(self.m_EventJobs[_Type]) do
        if type(v) == "table" then
            if v.Active == false then
                self.m_EventJobs[_Type][k] = nil;
            else
                if v.Enabled then
                    if v.Function then
                        local Arguments = table.copy(arg);
                        Arguments = Array_Append(Arguments, v.Arguments or {});
                        if v.Function(unpack(Arguments)) == true then
                            self.m_EventJobs[_Type][k] = nil;
                        end
                    end
                end
            end
        end
    end
end

function ModuleJobs:InstallEventJobs()
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
    ModuleJobs:TriggerEventJobs(Events.LOGIC_EVENT_DIPLOMACY_CHANGED);
end
ModuleEventJob_OnEntityDestroyed = function()
    local PlayerID = Event.GetPlayerID();
    local EntityID = Event.GetEntityID();
    ModuleJobs:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_DESTROYED, PlayerID, EntityID);
end
ModuleEventJob_OnEntityHurtEntity = function()
    local PlayerID1 = Event.GetPlayerID1();
    local EntityID1 = Event.GetEntityID1();
    local PlayerID2 = Event.GetPlayerID2();
    local EntityID2 = Event.GetEntityID2();
    ModuleJobs:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, PlayerID1, EntityID1, PlayerID2, EntityID2);
end
ModuleEventJob_OnEverySecond = function()
    ModuleJobs:TriggerEventJobs(Events.LOGIC_EVENT_EVERY_SECOND);
end
ModuleEventJob_OnEveryTurn = function()
    ModuleJobs:TriggerEventJobs(Events.LOGIC_EVENT_EVERY_TURN);
end
ModuleEventJob_OnEntityCreated = function()
    local PlayerID = Event.GetPlayerID();
    local EntityID = Event.GetEntityID();
    ModuleJobs:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_CREATED, PlayerID, EntityID);
end

-- FIXME: Useless?
ModuleEventJob_OnEntityInRangeOfEntity = function()
    ModuleJobs:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY);
end
ModuleEventJob_OnGoodsTraded = function()
    ModuleJobs:TriggerEventJobs(Events.LOGIC_EVENT_GOODS_TRADED);
end
ModuleEventJob_OnPlayerDied = function()
    ModuleJobs:TriggerEventJobs(Events.LOGIC_EVENT_PLAYER_DIED);
end
ModuleEventJob_OnResearchDone = function()
    ModuleJobs:TriggerEventJobs(Events.LOGIC_EVENT_RESEARCH_DONE);
end
ModuleEventJob_OnTributePaied = function()
    ModuleJobs:TriggerEventJobs(Events.LOGIC_EVENT_TRIBUTE_PAID);
end
ModuleEventJob_OnWatherChanged = function()
    ModuleJobs:TriggerEventJobs(Events.LOGIC_EVENT_WEATHER_STATE_CHANGED);
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleJobs);

