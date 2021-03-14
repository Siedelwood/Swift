-- -------------------------------------------------------------------------- --
-- Module Realtime                                                            --
-- -------------------------------------------------------------------------- --

ModuleRealtime = {
    Properties = {
        Name = "ModuleRealtime",
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

function ModuleRealtime.Global:OnGameStart()
    StartSimpleHiResJobEx( function()
        ModuleRealtime.Shared:EventOnEveryRealTimeSecond();
    end);
end

function ModuleRealtime.Local:OnGameStart()
    StartSimpleHiResJobEx( function()
        ModuleRealtime.Shared:EventOnEveryRealTimeSecond();
    end);
end

function ModuleRealtime.Shared:EventOnEveryRealTimeSecond()
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

Swift:RegisterModules(ModuleRealtime);

