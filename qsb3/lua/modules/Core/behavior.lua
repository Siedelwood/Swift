-- Core Behavior ------------------------------------------------------------ --

---
-- TODO: add doc
--
-- @within Beschreibung
-- @set sort=true
--
Swift = Swift or {};

function Swift:InstallBehaviorGlobal()
    self:OverrideQuestMarkers();
    self:OverrideIsObjectiveCompleted();
end

function Swift:InstallBehaviorLocal()
    self:OverrideDisplayQuestObjective();
end

function Swift:OverrideQuestMarkers()
    QuestTemplate.RemoveQuestMarkers = function(self)
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if self.Objectives[i].Data[4] then
                    DestroyQuestMarker(self.Objectives[i].Data[2]);
                end
            end
        end
    end
    QuestTemplate.ShowQuestMarkers = function(self)
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if self.Objectives[i].Data[4] then
                    ShowQuestMarker(self.Objectives[i].Data[2]);
                end
            end
        end
    end

    function ShowQuestMarker(_Entity)
        local eID = GetID(_Entity);
        local x,y = Logic.GetEntityPosition(eID);
        local Marker = EGL_Effects.E_Questmarker_low;
        if Logic.IsBuilding(eID) == 1 then
            Marker = EGL_Effects.E_Questmarker;
        end
        DestroyQuestMarker(_Entity);
        Questmarkers[eID] = Logic.CreateEffect(Marker, x, y, 0);
    end
    function DestroyQuestMarker(_Entity)
        local eID = GetID(_Entity);
        if Questmarkers[eID] ~= nil then
            Logic.DestroyEffect(Questmarkers[eID]);
            Questmarkers[eID] = nil;
        end
    end
end

function Swift:OverrideIsObjectiveCompleted()
    QuestTemplate.IsObjectiveCompleted_Orig_QSB_CoreBehavior = QuestTemplate.IsObjectiveCompleted;
    QuestTemplate.IsObjectiveCompleted = function(self, objective)
        local objectiveType = objective.Type;
        if objective.Completed ~= nil then
            return objective.Completed;
        end
        local data = objective.Data;

        -- Solves the problem that special entities and construction sites
        -- let the script beleave that the player is still alive.
        if objectiveType == Objective.DestroyAllPlayerUnits then
            local PlayerEntities = GetPlayerEntities(data, 0);
            local IllegalEntities = {};
            
            for i= #PlayerEntities, 1, -1 do
                local Type = Logic.GetEntityType(PlayerEntities[i]);
                if Logic.IsEntityInCategory(PlayerEntities[i], EntityCategories.AttackableBuilding) == 0 or Logic.IsEntityInCategory(PlayerEntities[i], EntityCategories.Wall) == 0 then
                    if Logic.IsConstructionComplete(PlayerEntities[i]) == 0 then
                        table.insert(IllegalEntities, PlayerEntities[i]);
                    end
                end
                local IndestructableEntities = {Entities.XD_ScriptEntity, Entities.S_AIHomePosition, Entities.S_AIAreaDefinition};
                if table.contains(IndestructableEntities, Type) then
                    table.insert(IllegalEntities, PlayerEntities[i]);
                end
            end

            if #PlayerEntities == 0 or #PlayerEntities - #IllegalEntities == 0 then
                objective.Completed = true;
            end
        elseif objectiveType == Objective.Distance then
            objective.Completed = Swift:IsQuestPositionReached(self, objective);
        else
            return self:IsObjectiveCompleted_Orig_QSB_CoreBehavior(objective);
        end
    end
end

function Swift:OverrideDisplayQuestObjective()
    GUI_Interaction.DisplayQuestObjective_Orig_QSB_CoreBehavior = GUI_Interaction.DisplayQuestObjective
    GUI_Interaction.DisplayQuestObjective = function(_QuestIndex, _MessageKey)
        local Quest, QuestType = GUI_Interaction.GetPotentialSubQuestAndType(_QuestIndex);
        if QuestType == Objective.Distance then
            if Quest.Objectives[1].Data[1] == -65566 then
                Quest.Objectives[1].Data[1] = Logic.GetKnightID(Quest.ReceivingPlayer);
            end
        end
        GUI_Interaction.DisplayQuestObjective_Orig_QSB_CoreBehavior(_QuestIndex, _MessageKey);
    end
end

function Swift:IsQuestPositionReached(_Quest, _Objective)
    local IDdata2 = GetID(_Objective.Data[1]);
    if IDdata2 == -65566 then
        _Objective.Data[1] = Logic.GetKnightID(_Quest.ReceivingPlayer);
        IDdata2 = _Objective.Data[1];
    end
    local IDdata3 = GetID(_Objective.Data[2]);
    _Objective.Data[3] = _Objective.Data[3] or 2500;
    if not (Logic.IsEntityDestroyed(IDdata2) or Logic.IsEntityDestroyed(IDdata3)) then
        if Logic.GetDistanceBetweenEntities(IDdata2,IDdata3) <= _Objective.Data[3] then
            DestroyQuestMarker(IDdata3);
            return true;
        end
    else
        DestroyQuestMarker(IDdata3);
        return false;
    end
end

function Swift:GetInputFromQuest(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if not Quest then
        return;
    end
    return Quest.InputDialogResult;
end

-- DEBUG -------------------------------------------------------------------- --

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

-- GOALS -------------------------------------------------------------------- --



-- REPRISALS ---------------------------------------------------------------- --



-- REWARDS ------------------------------------------------------------------ --



-- TRIGGERS ----------------------------------------------------------------- --



