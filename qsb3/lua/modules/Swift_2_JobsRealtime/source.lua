-- -------------------------------------------------------------------------- --
-- Module Realtime                                                            --
-- -------------------------------------------------------------------------- --

ModuleJobsRealtime = {
    Properties = {
        Name = "ModuleJobsRealtime",
    },

    Global = {},
    Local = {},
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        RealTimeWaitActiveFlag = {};
        RealTimeWaitID = 0;
        SecondsSinceGameStart = 0;
        LastTimeStamp = 0;
    },
};

function ModuleJobsRealtime.Global:OnGameStart()
    StartSimpleHiResJobEx( function()
        ModuleJobsRealtime.Shared:EventOnEveryRealTimeSecond();
    end);
end

function ModuleJobsRealtime.Local:OnGameStart()
    StartSimpleHiResJobEx( function()
        ModuleJobsRealtime.Shared:EventOnEveryRealTimeSecond();
    end);
end

function ModuleJobsRealtime.Shared:EventOnEveryRealTimeSecond()
    if not self.LastTimeStamp then
        self.LastTimeStamp = math.floor(Framework.TimeGetTime());
    end
    local CurrentTimeStamp = math.floor(Framework.TimeGetTime());

    -- Eine Sekunde ist vergangen
    if self.LastTimeStamp ~= CurrentTimeStamp then
        self.LastTimeStamp = CurrentTimeStamp;
        self.SecondsSinceGameStart = self.SecondsSinceGameStart +1;
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleJobsRealtime);

