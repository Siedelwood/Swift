-- -------------------------------------------------------------------------- --
-- Module Text Tools                                                          --
-- -------------------------------------------------------------------------- --

ModuleRealtime = {
    Properties = {
        Name = "ModuleRealtime",
    },

    m_SecondsSinceGameStart = 0;
    m_LastTimeStamp = 0;
};

function ModuleRealtime:OnGameStart()
    StartSimpleHiResJobEx( function()
        ModuleRealtime:EventOnEveryRealTimeSecond();
    end);
end

function ModuleRealtime:EventOnEveryRealTimeSecond()
    if not self.m_LastTimeStamp then
        self.m_LastTimeStamp = math.floor(Framework.TimeGetTime());
    end
    local CurrentTimeStamp = math.floor(Framework.TimeGetTime());

    -- Eine Sekunde ist vergangen
    if self.m_LastTimeStamp ~= CurrentTimeStamp then
        self.m_LastTimeStamp = CurrentTimeStamp;
        self.m_SecondsSinceGameStart = self.m_SecondsSinceGameStart +1;
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleRealtime);

