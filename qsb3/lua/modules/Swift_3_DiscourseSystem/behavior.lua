--[[
Swift_3_DiscourseSystem/Behavior

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Fügt Behavior zur Steuerung von Discourses hinzu.
--
-- @set sort=true
--

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet das enthaltene Discourse.
--
-- Jedes Discourse braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Discourse
-- @param[type=string] _Discourse Funktionsname als String
-- @within Reprisal
--
function Reprisal_Discourse(...)
    return B_Reprisal_Discourse:new(...);
end

B_Reprisal_Discourse = {
    Name = "Reprisal_Discourse",
    Description = {
        en = "Reprisal: Calls a function to start an new briefing.",
        de = "Lohn: Ruft die Funktion auf und startet das enthaltene Discourse.",
    },
    Parameter = {
        { ParameterType.Default, en = "Discourse name",     de = "Name des Discourse" },
        { ParameterType.Default, en = "Discourse function", de = "Funktion mit Discourse" },
    },
}

function B_Reprisal_Discourse:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function B_Reprisal_Discourse:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.DiscourseName = _Parameter;
    elseif (_Index == 1) then
        self.Function = _Parameter;
    end
end

function B_Reprisal_Discourse:CustomFunction(_Quest)
    _G[self.Function](self.DiscourseName, _Quest.ReceivingPlayer);
end

function B_Reprisal_Discourse:Debug(_Quest)
    if self.DiscourseName == nil or self.DiscourseName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    if not type(_G[self.Function]) == "function" then
        error(_Quest.Identifier..": "..self.Name..": '"..self.Function.."' was not found!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Reprisal_Discourse);

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet das enthaltene Discourse.
--
-- Jedes Discourse braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Discourse
-- @param[type=string] _Discourse Funktionsname als String
-- @within Reward
--
function Reward_Discourse(...)
    return B_Reward_Discourse:new(...);
end

B_Reward_Discourse = Swift:CopyTable(B_Reprisal_Discourse);
B_Reward_Discourse.Name = "Reward_Discourse";
B_Reward_Discourse.Description.en = "Reward: Calls a function to start an new briefing.";
B_Reward_Discourse.Description.de = "Lohn: Ruft die Funktion auf und startet das enthaltene Discourse.";
B_Reward_Discourse.GetReprisalTable = nil;

B_Reward_Discourse.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Swift:RegisterBehavior(B_Reward_Discourse);

-- -------------------------------------------------------------------------- --

---
-- Prüft, ob ein Discourse beendet ist und startet dann den Quest.
--
-- @param[type=string] _Name     Bezeichner des Discourse
-- @param[type=number] _Waittime (optional) Wartezeit in Sekunden
-- @within Trigger
--
function Trigger_Discourse(...)
    return B_Trigger_Discourse:new(...);
end

B_Trigger_Discourse = {
    Name = "Trigger_Discourse",
    Description = {
        en = "Trigger: Checks if an briefing has concluded and starts the quest if so.",
        de = "Auslöser: Prüft, ob ein Discourse beendet ist und startet dann den Quest.",
    },
    Parameter = {
        { ParameterType.Default,  en = "Discourse name", de = "Name des Discourse" },
        { ParameterType.PlayerID, en = "Player ID",     de = "Player ID" },
        { ParameterType.Number,   en = "Wait time",     de = "Wartezeit" },
    },
}

function B_Trigger_Discourse:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function B_Trigger_Discourse:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.DiscourseName = _Parameter;
    elseif (_Index == 1) then
        self.PlayerID = _Parameter * 1;
    elseif (_Index == 2) then
        _Parameter = _Parameter or 0;
        self.WaitTime = _Parameter * 1;
    end
end

function B_Trigger_Discourse:CustomFunction(_Quest)
    if API.GetCinematicEventStatus(self.DiscourseName, self.PlayerID) == CinematicEventStatus.Concluded then
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

function B_Trigger_Discourse:Debug(_Quest)
    if self.WaitTime < 0 then
        error(string.format("%s: %s: Wait time must be 0 or greater!", _Quest.Identifier, self.Name));
        return true;
    end
    if self.PlayerID < 1 or self.PlayerID > 8 then
        error(string.format("%s: %s: Player-ID must be between 1 and 8!", _Quest.Identifier, self.Name));
        return true;
    end
    if self.DiscourseName == nil or self.DiscourseName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Trigger_Discourse);

