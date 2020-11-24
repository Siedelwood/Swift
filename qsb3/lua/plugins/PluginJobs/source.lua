-- -------------------------------------------------------------------------- --
-- Plugin Job                                                                 --
-- -------------------------------------------------------------------------- --

---
-- TODO: add doc
-- @within Plugins
--
PluginJobs = {
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

function PluginJobs:OnGameStart()
    self:InstallEventJobs();
end

function PluginJobs:OnSaveGameLoaded()
end

function PluginJobs:TriggerEventJobs(_Type)
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

function PluginJobs:InstallEventJobs()
    Trigger.RequestTrigger(
        Events.LOGIC_EVENT_EVERY_SECOND,
        "",
        "PluginEventJob_OnEverySecond",
        1
    );

    Trigger.RequestTrigger(
        Events.LOGIC_EVENT_EVERY_TURN,
        "",
        "PluginEventJob_OnEveryTurn",
        1
    );

    Trigger.RequestTrigger(
        Events.LOGIC_EVENT_ENTITY_DESTROYED,
        "",
        "PluginEventJob_OnEntityDestroyed",
        1
    );

    Trigger.RequestTrigger(
        Events.LOGIC_EVENT_ENTITY_HURT_ENTITY,
        "",
        "PluginEventJob_OnEntityHurtEntity",
        1
    );
end

PluginEventJob_OnDiplomacyChanged = function()
    PluginJobs:TriggerEventJobs(Events.LOGIC_EVENT_DIPLOMACY_CHANGED);
end
PluginEventJob_OnEntityDestroyed = function()
    local PlayerID = Event.GetPlayerID();
    local EntityID = Event.GetEntityID();
    PluginJobs:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_DESTROYED, PlayerID, EntityID);
end
PluginEventJob_OnEntityHurtEntity = function()
    local PlayerID1 = Event.GetPlayerID1();
    local EntityID1 = Event.GetEntityID1();
    local PlayerID2 = Event.GetPlayerID2();
    local EntityID2 = Event.GetEntityID2();
    PluginJobs:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, PlayerID1, EntityID1, PlayerID2, EntityID2);
end
PluginEventJob_OnEverySecond = function()
    PluginJobs:TriggerEventJobs(Events.LOGIC_EVENT_EVERY_SECOND);
end
PluginEventJob_OnEveryTurn = function()
    PluginJobs:TriggerEventJobs(Events.LOGIC_EVENT_EVERY_TURN);
end

-- Useless?
PluginEventJob_OnEntityCreated = function()
    local PlayerID = Event.GetPlayerID();
    local EntityID = Event.GetEntityID();
    PluginJobs:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_CREATED, PlayerID, EntityID);
end
PluginEventJob_OnEntityInRangeOfEntity = function()
    PluginJobs:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY);
end
PluginEventJob_OnGoodsTraded = function()
    PluginJobs:TriggerEventJobs(Events.LOGIC_EVENT_GOODS_TRADED);
end
PluginEventJob_OnPlayerDied = function()
    PluginJobs:TriggerEventJobs(Events.LOGIC_EVENT_PLAYER_DIED);
end
PluginEventJob_OnResearchDone = function()
    PluginJobs:TriggerEventJobs(Events.LOGIC_EVENT_RESEARCH_DONE);
end
PluginEventJob_OnTributePaied = function()
    PluginJobs:TriggerEventJobs(Events.LOGIC_EVENT_TRIBUTE_PAID);
end
PluginEventJob_OnWatherChanged = function()
    PluginJobs:TriggerEventJobs(Events.LOGIC_EVENT_WEATHER_STATE_CHANGED);
end

-- -------------------------------------------------------------------------- --

Swift:RegisterPlugins(PluginJobs);

