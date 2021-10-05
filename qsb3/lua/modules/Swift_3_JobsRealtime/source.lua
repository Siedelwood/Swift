--[[
Swift_3_JobsRealtime/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

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

-- This triggers a quest message after an certain amount of time has passed in
-- the real world. The game speed does not affect this.
function ModuleQuests.Global:GetWaitTimeInlineTrigger(_Ancestor, _AncestorWt)
    return {
        Triggers.Custom2, {
            {QuestName = _Ancestor, WaitTime = _AncestorWt or 1,},
            function(_Data, _Quest)
                if not _Data.QuestName then
                    return true;
                end
                local QuestID = GetQuestID(_Data.QuestName);
                if (Quests[QuestID] and Quests[QuestID].State == QuestState.Over and Quests[QuestID].Result ~= QuestResult.Interrupted) then
                    _Data.WaitTimeTimer = _Data.WaitTimeTimer or ModuleJobsRealtime.Shared.SecondsSinceGameStart;
                    if ModuleJobsRealtime.Shared.SecondsSinceGameStart >= _Data.WaitTimeTimer + _Data.WaitTime then
                        return true;
                    end
                end
                return false;
            end
        }
    };
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleJobsRealtime);

