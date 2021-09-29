--[[
Swift_3_DialogSystem/Behavior

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet den enthaltenen Dialog.
--
-- Jeder Dialog braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Dialog
-- @param[type=string] _Dialog Funktionsname als String
-- @within Reprisal
--
function Reprisal_Dialog(...)
    return b_Reprisal_Dialog:new(...);
end

b_Reprisal_Dialog = {
    Name = "Reprisal_Dialog",
    Description = {
        en = "Reprisal: Calls a function to start an new dialog briefing.",
        de = "Lohn: Ruft die Funktion auf und startet den enthaltenen Dialog.",
    },
    Parameter = {
        { ParameterType.Default, en = "Briefing function", de = "Funktion mit Briefing" },
    },
}

function b_Reprisal_Dialog:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_Dialog:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.DialogName = _Parameter;
    elseif (_Index == 1) then
        self.Function = _Parameter;
    end
end

function b_Reprisal_Dialog:CustomFunction(_Quest)
    _G[self.Function](self, self.DialogName, _Quest.ReceivingPlayer);
end

function b_Reprisal_Dialog:Debug(_Quest)
    if self.DialogName == nil or self.DialogName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    if not type(_G[self.Function]) == "function" then
        error(_Quest.Identifier..": "..self.Name..": '"..self.Function.."' was not found!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(b_Reprisal_Dialog);

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet den enthaltenen Dialog.
--
-- Jeder Dialog braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Dialog
-- @param[type=string] _Dialog Funktionsname als String
-- @within Reward
--
function Reward_Dialog(...)
    return b_Reward_Dialog:new(...);
end

b_Reward_Dialog = Swift:CopyTable(b_Reprisal_Dialog);
b_Reward_Dialog.Name = "Reward_Dialog";
b_Reward_Dialog.Description.en = "Reward: Calls a function to start an new dialog briefing.";
b_Reward_Dialog.Description.de = "Lohn: Ruft die Funktion auf und startet den enthaltenen Dialog.";
b_Reward_Dialog.GetReprisalTable = nil;

b_Reward_Dialog.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

b_Reward_Dialog.CustomFunction = function(self, _Quest)
    _G[self.Function](self, self.DialogName, _Quest.ReceivingPlayer);
end

Swift:RegisterBehavior(b_Reward_Dialog);

-- -------------------------------------------------------------------------- --

---
-- Prüft, ob ein Dialog beendet ist und startet dann den Quest.
--
-- @param[type=string] _Name     Bezeichner des Dialog
-- @param[type=number] _Waittime (optional) Wartezeit in Sekunden
-- @within Trigger
--
function Trigger_Dialog(...)
    return b_Trigger_Dialog:new(...);
end

b_Trigger_Dialog = {
    Name = "Trigger_Dialog",
    Description = {
        en = "Trigger: Checks if an dialog has concluded and starts the quest if so.",
        de = "Ausloeser: Prüft, ob ein Dialog beendet ist und startet dann den Quest.",
    },
    Parameter = {
        { ParameterType.Default, en = "Dialog name",   de = "Name des Dialog" },
        { ParameterType.Number,  en = "Wait time",     de = "Wartezeit" },
    },
}

function b_Trigger_Dialog:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_Dialog:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.DialogName = _Parameter;
    elseif (_Index == 2) then
        _Parameter = _Parameter or 0;
        self.WaitTime = _Parameter * 1;
    end
end

function b_Trigger_Dialog:CustomFunction(_Quest)
    if API.GetCinematicEventStatus(self.DialogName) == CinematicEventStatus.Concluded then
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

function b_Trigger_Dialog:Debug(_Quest)
    if self.WaitTime < 0 then
        error(string.format("%s: %s: Wait time must be 0 or greater!", _Quest.Identifier, self.Name));
        return true;
    end
    if self.DialogName == nil or self.DialogName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    local EventPlayerID = API.GetCinematicEventPlayerID(self.DialogName);
    if EventPlayerID ~= _Quest.ReceivingPlayer then
        error(string.format(
            "%s: %s: Dialog '%s' is for player %d but quest is for player %d!",
            _Quest.Identifier,
            self.Name,
            self.DialogName,
            EventPlayerID,
            _Quest.ReceivingPlayer
        ));
        return true;
    end
    return false;
end

Swift:RegisterBehavior(b_Trigger_Dialog);

