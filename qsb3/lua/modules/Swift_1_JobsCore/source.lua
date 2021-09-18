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
            [Events.LOGIC_EVENT_ENTITY_CREATED]            = {},
            [Events.LOGIC_EVENT_ENTITY_DESTROYED]          = {},
            [Events.LOGIC_EVENT_ENTITY_HURT_ENTITY]        = {},
            [Events.LOGIC_EVENT_EVERY_SECOND]              = {},
            [Events.LOGIC_EVENT_EVERY_TURN]                = {},
        };
        RealTimeWaitActiveFlag = {};
        RealTimeWaitID = 0;
        SecondsSinceGameStart = 0;
        LastTimeStamp = 0;
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
                        local Arguments = Swift:CopyTable(v.Arguments or {});
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

    Trigger.RequestTrigger(
        Events.LOGIC_EVENT_EVERY_TURN,
        "",
        "ModuleEventJob_RealtimeController",
        1
    );
end

-- Real Time

function ModuleEventJob_RealtimeController()
    if not ModuleJobsCore.Shared.LastTimeStamp then
        ModuleJobsCore.Shared.LastTimeStamp = math.floor(Framework.TimeGetTime());
    end
    local CurrentTimeStamp = math.floor(Framework.TimeGetTime());

    if ModuleJobsCore.Shared.LastTimeStamp ~= CurrentTimeStamp then
        ModuleJobsCore.Shared.LastTimeStamp = CurrentTimeStamp;
        ModuleJobsCore.Shared.SecondsSinceGameStart = ModuleJobsCore.Shared.SecondsSinceGameStart +1;
    end
end

-- Event Jobs

ModuleEventJob_OnEntityDestroyed = function()
    local EntityID = Event.GetEntityID();
    local PlayerID = Event.GetPlayerID();
    ModuleJobsCore.Shared:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_DESTROYED, PlayerID, EntityID);
end
ModuleEventJob_OnEntityHurtEntity = function()
    local EntityID1 = Event.GetEntityID1();
    local PlayerID1 = Logic.EntityGetPlayer(EntityID1);
    local EntityID2 = Event.GetEntityID2();
    local PlayerID2 = Logic.EntityGetPlayer(EntityID2);
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

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleJobsCore);

