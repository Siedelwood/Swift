-- -------------------------------------------------------------------------- --
-- Module Quests                                                              --
-- -------------------------------------------------------------------------- --

ModuleQuests = {
    Properties = {
        Name = "ModuleQuests",
    },

    Global = {
        QuestMessageID = 0,
        ExternalTriggerConditions = {},
        ExternalTimerConditions = {},
        ExternalDecisionConditions = {},
    };
    Local = {};
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
};

-- Global Script ---------------------------------------------------------------

function ModuleQuests.Global:OnGameStart()
    Quest_Loop = self.QuestLoop;

    -- Stop quest from triggering when cinematic event takes place
    table.insert(self.ExternalTriggerConditions, function(_PlayerID, _Quest)
        return not API.IsCinematicEventActive(_PlayerID);
    end);
    -- Disable quest timers when cinematic event takes place
    table.insert(self.ExternalTimerConditions, function(_PlayerID, _Quest)
        return not API.IsCinematicEventActive(_PlayerID);
    end);
end

function ModuleQuests.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.ChatClosed then
        if Swift:IsProcessDebugCommands() then
            self:ProcessChatInput(arg[1]);
        end
    end
end

function ModuleQuests.Global:QuestMessage(_Text, _Sender, _Receiver, _AncestorWt, _Callback, _Ancestor, _QuestName)
    self.QuestMessageID = self.QuestMessageID +1;

    -- Lokalisierung
    if _Text then
        _Text = API.ConvertPlaceholders(API.Localize(_Text));
    end

    -- Quest erzeugen
    local _, CreatedQuest = QuestTemplate:New(
        (_QuestName ~= nil and _QuestName) or ("QSB_QuestMessage_" ..self.QuestMessageID),
        (_Sender or 1),
        (_Receiver or 1),
        { {Objective.Dummy} },
        { self:GetWaitTimeInlineTrigger(_Ancestor, _AncestorWt) },
        0, nil, nil, _Callback, nil, false, (_Text ~= nil), nil, nil, _Text, nil
    );
    return CreatedQuest.Identifier;
end

function ModuleQuests.Global:QuestCreateNewQuest(_Data)
    if not _Data.Name then
        QSB.AutomaticQuestNameCounter = (QSB.AutomaticQuestNameCounter or 0) +1;
        _Data.Name = string.format("AutoNamed_Quest_%d", QSB.AutomaticQuestNameCounter);
    end
    if not self:QuestValidateQuestName(_Data.Name) then
        error("Quest '"..tostring(_Data.Name).."': invalid questname! Contains forbidden characters!");
        return;
    end

    -- Questdaten erzeugen
    local QuestData = {
        _Data.Name,
        (_Data.Sender ~= nil and _Data.Sender) or 1,
        (_Data.Receiver ~= nil and _Data.Receiver) or 1,
        {},
        {},
        (_Data.Time ~= nil and _Data.Time) or 0,
        {},
        {},
        _Data.Callback,
        _Data.Loop,
        _Data.Visible == true or _Data.Suggestion ~= nil,
        _Data.EndMessage == true or (_Data.Failure ~= nil or _Data.Success ~= nil),
        API.ConvertPlaceholders((type(_Data.Description) == "table" and API.Localize(_Data.Description)) or _Data.Description),
        API.ConvertPlaceholders((type(_Data.Suggestion) == "table" and API.Localize(_Data.Suggestion)) or _Data.Suggestion),
        API.ConvertPlaceholders((type(_Data.Success) == "table" and API.Localize(_Data.Success)) or _Data.Success),
        API.ConvertPlaceholders((type(_Data.Failure) == "table" and API.Localize(_Data.Failure)) or _Data.Failure)
    };

    -- Daten validieren
    if not self:QuestValidateQuestData(QuestData) then
        error("ModuleQuests: Failed to vaidate quest data. Table has been copied to log.");
        API.DumpTable(QuestData, "Quest");
        return;
    end

    -- Behaviour
    for k,v in pairs(_Data) do
        if tonumber(k) ~= nil then
            if type(v) == "table" then
                if v.GetGoalTable then
                    table.insert(QuestData[4], v:GetGoalTable());

                    local Idx = #QuestData[4];
                    QuestData[4][Idx].Context            = v;
                    QuestData[4][Idx].FuncOverrideIcon   = QuestData[4][Idx].Context.GetIcon;
                    QuestData[4][Idx].FuncOverrideMsgKey = QuestData[4][Idx].Context.GetMsgKey;
                elseif v.GetReprisalTable then
                    table.insert(QuestData[8], v:GetReprisalTable());
                elseif v.GetRewardTable then
                    table.insert(QuestData[7], v:GetRewardTable());
                else
                    table.insert(QuestData[5], v:GetTriggerTable());
                end
            end
        end
    end

    -- Default Goal
    if #QuestData[4] == 0 then
        table.insert(QuestData[4], {Objective.Dummy});
    end
    -- Default Trigger
    if #QuestData[5] == 0 then
        table.insert(QuestData[5], {Triggers.Time, 0 });
    end
    -- Genug Platz Behavior
    if QuestData[11] then
        table.insert(QuestData[5], self:GetFreeSpaceInlineTrigger());
    end

    -- Quest erzeugen
    local QuestID, Quest = QuestTemplate:New(unpack(QuestData, 1, 16));
    Quest.MsgTableOverride = _Data.MSGKeyOverwrite;
    Quest.IconOverride = _Data.IconOverwrite;
    Quest.SkipFunction = _Data.Skip;
    Quest.QuestInfo = _Data.InfoText;
    return _Data.Name, Quests[0];
end

function ModuleQuests.Global:QuestValidateQuestData(_Data)
    return (
        (type(_Data[1]) == "string" and self:QuestValidateQuestName(_Data[1]) and Quests[GetQuestID(_Data[1])] == nil) and
        (type(_Data[2]) == "number" and _Data[2] >= 1 and _Data[2] <= 8) and
        (type(_Data[3]) == "number" and _Data[3] >= 1 and _Data[3] <= 8) and
        (type(_Data[6]) == "number" and _Data[6] >= 0) and
        ((_Data[9] ~= nil and type(_Data[9]) == "function") or (_Data[9] == nil)) and
        ((_Data[10] ~= nil and type(_Data[10]) == "function") or (_Data[10] == nil)) and
        (type(_Data[11]) == "boolean") and
        (type(_Data[12]) == "boolean") and
        ((_Data[13] ~= nil and type(_Data[13]) == "string") or (_Data[13] == nil)) and
        ((_Data[14] ~= nil and type(_Data[14]) == "string") or (_Data[14] == nil)) and
        ((_Data[15] ~= nil and type(_Data[15]) == "string") or (_Data[15] == nil)) and
        ((_Data[16] ~= nil and type(_Data[16]) == "string") or (_Data[16] == nil))
    );
end

function ModuleQuests.Global:QuestValidateQuestName(_Name)
    return string.find(_Name, "^[A-Za-z0-9_ @ÄÖÜäöüß]+$") ~= nil;
end

-- This triggers a quest message after an certain amount of seconds passed.
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
                    _Data.WaitTimeTimer = _Data.WaitTimeTimer or math.floor(Logic.GetTime());
                    if math.floor(Logic.GetTime()) >= _Data.WaitTimeTimer + _Data.WaitTime then
                        return true;
                    end
                end
                return false;
            end
        }
    };
end

-- This prevents from triggering a quest when all slots are occupied. But the
-- mapper who uses this automatic must also keep in mind that they might soft
-- lock the game if fully relying on this trigger without thinking! This is
-- only here to ensure functionality in case of errors and NOT to support the
-- sloth of mappers!
function ModuleQuests.Global:GetFreeSpaceInlineTrigger()
    return {
        Triggers.Custom2, {
            {},
            function(_Data, _Quest)
                local VisbleQuests = 0;
                if Quests[0] > 0 then
                    for i= 1, Quests[0], 1 do
                        if Quests[i].State == QuestState.Active and Quests[i].Visible == true then
                            VisbleQuests = VisbleQuests +1;
                        end
                    end
                end
                return VisbleQuests < 6;
            end
        }
    };
end

-- -------------------------------------------------------------------------- --

function ModuleQuests.Global.QuestLoop(_arguments)
    local self = JobQueue_GetParameter(_arguments);
    if self.LoopCallback ~= nil then
        self:LoopCallback();
    end
    if self.State == QuestState.NotTriggered then
        local triggered = true;
        -- Are triggers active?
        for i= 1, #ModuleQuests.Global.ExternalTriggerConditions, 1 do
            if not ModuleQuests.Global.ExternalTriggerConditions[i](self.ReceivingPlayer, self) then
                triggered = false;
                break;
            end
        end
        -- Normal condition
        if triggered then
            for i = 1, self.Triggers[0] do
                -- Write Trigger to Log
                local Text = ModuleQuests.Global:SerializeBehavior(self.Triggers[i], Triggers.Custom2, 4);
                if Text then
                    debug("Quest '" ..self.Identifier.. "' " ..Text, true);
                end
                -- Check Trigger
                triggered = triggered and self:IsTriggerActive(self.Triggers[i]);
            end
        end
        if triggered then
            self:SetMsgKeyOverride();
            self:SetIconOverride();
            self:Trigger();
        end
    elseif self.State == QuestState.Active then
        -- Do timers tick?
        for i= 1, #ModuleQuests.Global.ExternalTimerConditions, 1 do
            if not ModuleQuests.Global.ExternalTimerConditions[i](self.ReceivingPlayer, self) then
                self.StartTime = self.StartTime +1;
                break;
            end
        end
        -- Are goals checked?
        local CheckBehavior = true;
        for i= 1, #ModuleQuests.Global.ExternalDecisionConditions, 1 do
            if not ModuleQuests.Global.ExternalDecisionConditions[i](self.ReceivingPlayer, self) then
                CheckBehavior = false;
                break;
            end
        end
        if CheckBehavior then
            local allTrue = true;
            local anyFalse = false;
            for i = 1, self.Objectives[0] do
                -- Write Trigger to Log
                local Text = ModuleQuests.Global:SerializeBehavior(self.Objectives[i], Objective.Custom2, 1);
                if Text then
                    debug("Quest '" ..self.Identifier.. "' " ..Text, true);
                end
                -- Check Goal
                local completed = self:IsObjectiveCompleted(self.Objectives[i]);
                
                if self.Objectives[i].Type == Objective.Deliver and completed == nil then
                    if self.Objectives[i].Data[4] == nil then
                        self.Objectives[i].Data[4] = 0;
                    end
                    if self.Objectives[i].Data[3] ~= nil then
                        self.Objectives[i].Data[4] = self.Objectives[i].Data[4] + 1;
                    end
                    
                    local st = self.StartTime;
                    local sd = self.Duration;
                    local dt = self.Objectives[i].Data[4];
                    local sum = self.StartTime + self.Duration - self.Objectives[i].Data[4];
                    if self.Duration > 0 and self.StartTime + self.Duration + self.Objectives[i].Data[4] < Logic.GetTime() then
                        completed = false;
                    end
                else
                    if self.Duration > 0 and self.StartTime + self.Duration < Logic.GetTime() then
                        if completed == nil and
                            (self.Objectives[i].Type == Objective.Protect or self.Objectives[i].Type == Objective.Dummy or self.Objectives[i].Type == Objective.NoChange) then
                            completed = true;
                        elseif completed == nil or self.Objectives[i].Type == Objective.DummyFail then
                            completed = false;
                    end
                    end
                end
                allTrue = (completed == true) and allTrue;
                anyFalse = completed == false or anyFalse;
            end
            if allTrue then
                self:Success();
            elseif anyFalse then
                self:Fail();
            end
        end
    else
        if self.IsEventQuest == true then
            Logic.ExecuteInLuaLocalState("StopEventMusic(nil, "..self.ReceivingPlayer..")");
        end
        if self.Result == QuestResult.Success then
            for i = 1, self.Rewards[0] do
                -- Write Trigger to Log
                local Text = ModuleQuests.Global:SerializeBehavior(self.Rewards[i], Reward.Custom, 3);
                if Text then
                    debug("Quest '" ..self.Identifier.. "' " ..Text, true);
                end
                -- Add Reward
                self:AddReward(self.Rewards[i]);
            end
        elseif self.Result == QuestResult.Failure then
            for i = 1, self.Reprisals[0] do
                -- Write Trigger to Log
                local Text = ModuleQuests.Global:SerializeBehavior(self.Reprisals[i], Reprisal.Custom, 3);
                if Text then
                    debug("Quest '" ..self.Identifier.. "' " ..Text, true);
                end
                -- Add Reward
                self:AddReprisal(self.Reprisals[i]);
            end
        end
        if self.EndCallback ~= nil then
            self:EndCallback();
        end
        return true;
    end
end

function ModuleQuests.Global:SerializeBehavior(_Data, _CustomType, _Typ)
    local BehaviorType = "Objective";
    local BehaTable = Objective;
    if _Typ == 2 then
        BehaviorType = "Reprisal";
        BehaTable = Reprisal;
    elseif _Typ == 3 then
        BehaviorType = "Reward";
        BehaTable = Reward;
    elseif _Typ == 4 then
        BehaviorType = "Trigger";
        BehaTable = Triggers;
    end

    local Info = "Running {";
    local Beha = GetNameOfKeyInTable(BehaTable, _Data.Type);

    if _Data.Type == _CustomType then
        local FunctionName = _Data.Data[1].FuncName;
        Info = Info.. BehaviorType.. "." ..Beha.. "";
        if FunctionName == nil then
            return;
        else
            Info = Info.. ", " ..tostring(FunctionName);
        end
        if _Data.Data and _Data.Data[1].i47ya_6aghw_frxil and #_Data.Data[1].i47ya_6aghw_frxil > 0 then
            for j= 1, #_Data.Data[1].i47ya_6aghw_frxil, 1 do
                Info = Info.. ", (" ..type(_Data.Data[1].i47ya_6aghw_frxil[j]).. ") " ..tostring(_Data.Data[1].i47ya_6aghw_frxil[j]);
            end
        end
    else
        Info = Info.. BehaviorType.. "." ..Beha.. "";
        if _Data.Data then
            if type(_Data.Data) == "table" then
                for j= 1, #_Data.Data do
                    Info = Info.. ", (" ..type(_Data.Data[j]).. ") " ..tostring(_Data.Data[j]);
                end
            else
                Info = Info.. ", (" ..type(_Data.Data).. ") " ..tostring(_Data.Data);
            end
        end
    end
    Info = Info.. "}";
    return Info;
end

-- -------------------------------------------------------------------------- --

function ModuleQuests.Global:FindQuestNames(_Pattern, _ExactName)
    local FoundQuests = FindQuestsByName(_Pattern, _ExactName);
    if #FoundQuests == 0 then
        return {};
    end
    local NamesOfFoundQuests = {};
    for i= 1, #FoundQuests, 1 do
        table.insert(NamesOfFoundQuests, FoundQuests[i].Identifier);
    end
    return NamesOfFoundQuests;
end

function ModuleQuests.Global:ProcessChatInput(_Text)
    local Commands = ModuleInputOutputCore.Shared:CommandTokenizer(_Text);
    for i= 1, #Commands, 1 do
        if Commands[1] == "fail" or Commands[1] == "restart"
        or Commands[1] == "start" or Commands[1] == "stop"
        or Commands[1] == "win" then
            local FoundQuests = self:FindQuestNames(Commands[2], true);
            if #FoundQuests ~= 1 then
                error("Unable to find quest containing '" ..Commands[2].. "'");
                return;
            end
            if Commands[1] == "fail" then
                API.FailQuest(FoundQuests[1]);
                info("fail quest '" ..FoundQuests[1].. "'");
            elseif Commands[1] == "restart" then
                API.RestartQuest(FoundQuests[1]);
                info("restart quest '" ..FoundQuests[1].. "'");
            elseif Commands[1] == "start" then
                API.StartQuest(FoundQuests[1]);
                info("trigger quest '" ..FoundQuests[1].. "'");
            elseif Commands[1] == "stop" then
                API.StopQuest(FoundQuests[1]);
                info("interrupt quest '" ..FoundQuests[1].. "'");
            elseif Commands[1] == "win" then
                API.WinQuest(FoundQuests[1]);
                info("win quest '" ..FoundQuests[1].. "'");
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleQuests);

