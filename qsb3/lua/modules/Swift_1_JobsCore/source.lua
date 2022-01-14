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
        EventJobID = 0,
        EventJobs = {};
        TimeLineData = {},
        SecondsSinceGameStart = 0;
        LastTimeStamp = 0;
    };
};

function ModuleJobsCore.Global:OnGameStart()
    ModuleJobsCore.Shared:InstallBaseEventJobs();
end

function ModuleJobsCore.Local:OnGameStart()
    ModuleJobsCore.Shared:InstallBaseEventJobs();
end

function ModuleJobsCore.Shared:CreateEventJob(_Type, _Function, ...)
    self.EventJobID = self.EventJobID +1;
    local ID = Trigger.RequestTrigger(
        _Type,
        "",
        "ModuleJobCore_EventJob_BasicEventJobExecutor",
        1,
        {},
        {self.EventJobID}
    );
    self.EventJobs[self.EventJobID] = {ID, _Function, table.copy(arg)};
    return ID;
end

function ModuleJobsCore.Shared:InstallBaseEventJobs()
    Trigger.RequestTrigger(
        Events.LOGIC_EVENT_EVERY_TURN,
        "",
        "ModuleJobCore_EventJob_RealtimeController",
        1
    );
end

-- Real Time

function ModuleJobCore_EventJob_RealtimeController()
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

function ModuleJobCore_EventJob_BasicEventJobExecutor(_ID)
    if ModuleJobsCore.Shared.EventJobs[_ID] then
        local Parameter = ModuleJobsCore.Shared.EventJobs[_ID][3];
        local Finished = ModuleJobsCore.Shared.EventJobs[_ID][2](unpack(Parameter));
        if Finished then
            ModuleJobsCore.Shared.EventJobs[_ID] = nil;
            return true;
        end
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleJobsCore);

