--[[
Swift_3_BriefingSystem/Behavior

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
--
-- @set sort=true
--

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet das enthaltene Briefing.
--
-- Jedes Briefing braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Briefing
-- @param[type=string] _Briefing Funktionsname als String
-- @within Reprisal
--
function Reprisal_Briefing(...)
    return b_Reprisal_Briefing:new(...);
end

b_Reprisal_Briefing = {
    Name = "Reprisal_Briefing",
    Description = {
        en = "Reprisal: Calls a function to start an new briefing.",
        de = "Lohn: Ruft die Funktion auf und startet das enthaltene Briefing.",
    },
    Parameter = {
        { ParameterType.Default, en = "Briefing function", de = "Funktion mit Briefing" },
    },
}

function b_Reprisal_Briefing:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_Briefing:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.BriefingName = _Parameter;
    elseif (_Index == 1) then
        self.Function = _Parameter;
    end
end

function b_Reprisal_Briefing:CustomFunction(_Quest)
    _G[self.Function](self, self.BriefingName, _Quest.ReceivingPlayer);
end

function b_Reprisal_Briefing:Debug(_Quest)
    if self.BriefingName == nil or self.BriefingName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    if not type(_G[self.Function]) == "function" then
        error(_Quest.Identifier..": "..self.Name..": '"..self.Function.."' was not found!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(b_Reprisal_Briefing);

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet das enthaltene Briefing.
--
-- Jedes Briefing braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Briefing
-- @param[type=string] _Briefing Funktionsname als String
-- @within Reward
--
function Reward_Briefing(...)
    return b_Reward_Briefing:new(...);
end

b_Reward_Briefing = Swift:CopyTable(b_Reprisal_Briefing);
b_Reward_Briefing.Name = "Reward_Briefing";
b_Reward_Briefing.Description.en = "Reward: Calls a function to start an new briefing.";
b_Reward_Briefing.Description.de = "Lohn: Ruft die Funktion auf und startet das enthaltene Briefing.";
b_Reward_Briefing.GetReprisalTable = nil;

b_Reward_Briefing.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

b_Reward_Briefing.CustomFunction = function(self, _Quest)
    _G[self.Function](self, self.BriefingName, _Quest.ReceivingPlayer);
end

Swift:RegisterBehavior(b_Reward_Briefing);

-- -------------------------------------------------------------------------- --

---
-- Prüft, ob ein Briefing beendet ist und startet dann den Quest.
--
-- @param[type=string] _Name     Bezeichner des Briefing
-- @param[type=number] _Waittime (optional) Wartezeit in Sekunden
-- @within Trigger
--
function Trigger_Briefing(...)
    return b_Trigger_Briefing:new(...);
end

b_Trigger_Briefing = {
    Name = "Trigger_Briefing",
    Description = {
        en = "Trigger: Checks if an briefing has concluded and starts the quest if so.",
        de = "Ausloeser: Prüft, ob ein Briefing beendet ist und startet dann den Quest.",
    },
    Parameter = {
        { ParameterType.Default, en = "Briefing name",   de = "Name des Briefing" },
        { ParameterType.Number,  en = "Wait time",     de = "Wartezeit" },
    },
}

function b_Trigger_Briefing:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_Briefing:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.BriefingName = _Parameter;
    elseif (_Index == 2) then
        _Parameter = _Parameter or 0;
        self.WaitTime = _Parameter * 1;
    end
end

function b_Trigger_Briefing:CustomFunction(_Quest)
    if API.GetCinematicEventStatus(self.BriefingName) == CinematicEventStatus.Concluded then
        if self.WaitTime and self.WaitTime > 0 then
            self.WaitTimeTimer = self.WaitTimeTimer or Logic.GetTime();
            if Logic.GetTime() >= self.WaitTimeTimer + self.WaitTime then
                return true;
            end
        else
            return true;
        end
    end
    return false;
end

function b_Trigger_Briefing:Debug(_Quest)
    if self.WaitTime < 0 then
        error(string.format("%s: %s: Wait time must be 0 or greater!", _Quest.Identifier, self.Name));
        return true;
    end
    if self.BriefingName == nil or self.BriefingName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    local EventPlayerID = API.GetCinematicEventPlayerID(self.BriefingName);
    if EventPlayerID ~= _Quest.ReceivingPlayer then
        error(string.format(
            "%s: %s: Dialog '%s' is for player %d but quest is for player %d!",
            _Quest.Identifier,
            self.Name,
            self.BriefingName,
            EventPlayerID,
            _Quest.ReceivingPlayer
        ));
        return true;
    end
    return false;
end

Swift:RegisterBehavior(b_Trigger_Briefing);

