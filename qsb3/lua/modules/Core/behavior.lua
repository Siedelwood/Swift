-- Core Behavior ------------------------------------------------------------ --

---
-- TODO: add doc
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Aktiviert den Debug.
--
-- @param[type=boolean] _CheckAtRun Prüfe Quests zur Laufzeit
-- @param[type=boolean] _TraceQuests Aktiviert Questverfolgung
-- @param[type=boolean] _DevelopingCheats Aktiviert Cheats
-- @param[type=boolean] _DevelopingShell Aktiviert Eingabe
-- @see API.ActivateDebugMode
--
-- @within Reward
--
function Reward_DEBUG(...)
    return b_Reward_DEBUG:new(...);
end

b_Reward_DEBUG = {
    Name = "Reward_DEBUG",
    Description = {
        en = "Reward: Start the debug mode. See documentation for more information.",
        de = "Lohn: Startet den Debug-Modus. Für mehr Informationen siehe Dokumentation.",
    },
    Parameter = {
        { ParameterType.Custom,     en = "Check quest while runtime", de = "Quests zur Laufzeit prüfen" },
        { ParameterType.Custom,     en = "Use quest trace", de = "Questverfolgung" },
        { ParameterType.Custom,     en = "Activate developing cheats", de = "Cheats aktivieren" },
        { ParameterType.Custom,     en = "Activate developing shell", de = "Eingabe aktivieren" },
    },
}

function b_Reward_DEBUG:GetRewardTable(__quest_)
    return { Reward.Custom, {self, self.CustomFunction} }
end

function b_Reward_DEBUG:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.CheckWhileRuntime = API.ToBoolean(_Parameter);
    elseif (_Index == 1) then
        self.UseQuestTrace = API.ToBoolean(_Parameter);
    elseif (_Index == 2) then
        self.DevelopingCheats = API.ToBoolean(_Parameter);
    elseif (_Index == 3) then
        self.DevelopingShell = API.ToBoolean(_Parameter);
    end
end

function b_Reward_DEBUG:CustomFunction(__quest_)
    API.ActivateDebugMode(self.CheckWhileRuntime, self.UseQuestTrace, self.DevelopingCheats, self.DevelopingShell);
end

function b_Reward_DEBUG:GetCustomData(_Index)
    return {"true","false"};
end

Swift:RegisterBehavior(b_Reward_DEBUG);

