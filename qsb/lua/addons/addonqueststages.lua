-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnQuestStages                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Erweitert den mitgelieferten Debug des Spiels um eine Vielzahl nützlicher
-- neuer Möglichkeiten.
--
-- Die wichtigste Neuerung ist die Konsole, die es erlaubt Quests direkt über
-- die Eingabe von Befehlen zu steuern, einzelne Lua-Funktionen im Spiel
-- auszuführen und sogar komplette Skripte zu laden.
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnQuestStages = {};

API = API or {};
QSB = QSB or {};

QSB.StageNameToQuestName = {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --


function API.CreateStagedQuest(_Data)
    if GUI then
        return;
    end
    return BundleQuestGeneration.Global:QuestCreateNewQuest(_Data);
end
AddStagedQuest = API.CreateStagedQuest;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnQuestStages = {
    Global =  {
        Data = {
            StagesForQuest = {}
        },
    },
}

-- Global ----------------------------------------------------------------------

function AddOnQuestStages.Global:Install()

end


function AddOnQuestStages.Global:CreateStagedQuest(_Data)   
    local Name = API.CreateQuest(_Data);
    if not Name or not _Data.Stages then
        return;
    end
    table.insert(Quests[GetQuestID(Name)][4], 1, self:GetCheckStagesInlineGoal());

    self.Data.StagesForQuest[Name] = {};
    for i= 1, #_Data.Stages, 1 do
        if type(_Data.Stages[i]) == "string" then
            self:LinkExternQuestAsStage(_Data.Stages[i], Name, i);
        elseif type(_Data.Stages[i]) == "table" then
            self:CreateQuestStage(_Data.Stages[i], Name, i);
        end
    end
end


function AddOnQuestStages.Global:GetCurrentQuestStage(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest ~= nil and self.Data.StagesForQuest[_QuestName] ~= nil then
        for i= 1, #self.Data.StagesForQuest[_QuestName], 1 do
            if Quests[GetQuestID(Stage)].State == QuestState.Active then
                return i;
            end
        end
    end
    return 0;
end


function AddOnQuestStages.Global:GetAmountOfQuestStage(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest ~= nil and self.Data.StagesForQuest[_QuestName] ~= nil then
        return #self.Data.StagesForQuest[_QuestName];
    end
    return 0;
end


function AddOnQuestStages.Global:GetQuestProgress(_QuestName)
    local CurrentStage = self:GetCurrentQuestStage(_QuestName);
    local StageAmount  = self:GetAmountOfQuestStage(_QuestName);
    if StageAmount == 0 then
        return 0;
    end
    return CurrentStage / StageAmount;
end


function AddOnQuestStages.Global:GetCheckStagesInlineGoal()
    return {
        Objective.Custom2, {
            {},
            function(_Data, _Quest)
                local StageList = AddOnQuestStages.Global.Data.StagesForQuest[_Quest.Identifier];
                for i= 1, #StageList, 1 do
                    local StageQuest = Quests[GetQuestID(StageList[i])];
                    -- Fehlschlag, wenn Stage fehlgeschlagen ist.
                    if not StageQuest or StageQuest.Result == QuestResult.Failure then
                        return false;
                    -- Interrupted sollte eigentlich nicht vorkommen...
                    elseif StageQuest.Result == QuestResult.Interrupted then
                        return false;
                    end
                end
                -- Erfolg, wenn letzter Stage erfolgreich war.
                if StageList[#StageList].Result == QuestResult.Success then
                    return true;
                end
            end
        }
    };
end


function AddOnQuestStages.Global:LinkExternQuestAsStage(_ExternName, _QuestName, _Index)
    local Extern = Quests[GetQuestID(_ExternName)];
    local Parent = Quests[GetQuestID(_QuestName)];

    if not Extern or Extern.State ~= QuestState.Inactive then
        return;
    end

    local LinkTrigger
    local Waittime = 0 + ((Extern[14] ~= nil and 5) or 0);
    if _Index == 1 then
        LinkTrigger = Trigger_OnQuestActive(_QuestName, Waittime):GetTriggerTable();
    else
        local LastName = self.Data.StagesForQuest[_QuestName][_Index -1];
        local LastQuest = Quests[GetQuestID(LastName)];
        Waittime = Waittime + (((LastQuest[15] ~= nil or LastQuest[15] ~= nil) and 5) or 0);
        LinkTrigger = Trigger_OnQuestSuccess(LastName, Waittime):GetTriggerTable();
    end

    table.insert(Extern[5], LinkTrigger);
    table.insert(self.Data.StagesForQuest[_QuestName], _ExternName);
end


function AddOnQuestStages.Global:CreateQuestStage(_Data, _QuestName, _Index)
    local Name = _QuestName.. "_Stage_" ..Index;
    local Parent = Quests[GetQuestID(_QuestName)];

    local QuestDescription = {
        Name        = Name,
        Sender      = _Data.Sender or Parent.SendingPlayer,
        Receiver    = _Data.Receiver or Parent.ReceivingPlayer,
        Time        = _Data.Time,
        Suggestion  = _Data.Suggestion,
        Success     = _Data.Success,
        Failure     = _Data.Failure,
        Description = _Data.Description,
    };
    for i= 1, #_Data do
        table.insert(QuestDescription, _Data[i]);
    end

    local Waittime = 0 + ((_Data.Suggestion ~= nil and 5) or 0);
    if _Index == 1 then
        table.insert(QuestDescription, Trigger_OnQuestActive(_QuestName, Waittime));
    else
        local LastName = self.Data.StagesForQuest[_QuestName][_Index -1];
        local LastQuest = Quests[GetQuestID(LastName)];
        Waittime = Waittime + (((LastQuest[15] ~= nil or LastQuest[15] ~= nil) and 5) or 0);
        table.insert(QuestDescription, Trigger_OnQuestSuccess(LastName, Waittime));
    end

    API.CreateQuest(QuestDescription);
    table.insert(self.Data.StagesForQuest[_QuestName], Name);
end


function AddOnQuestStages.Global:DebugSetQuestState(_QuestName, _Stages, _Flag)
    local CurrentStage = self:GetCurrentQuestStage(_QuestName);
    local StageAmount  = self:GetAmountOfQuestStage(_QuestName);

    if _Flag == 1 then
        for i= 1, #_Stages, 1 do
            API.StopQuest(_Stages[i], true);
        end
        API.WinQuest(_QuestName, true);
        API.Note("win staged quest '" .._QuestName.. "'");
        return "win staged quest '" .._QuestName.. "'"
    elseif _Flag == 2 then
        for i= 1, #_Stages, 1 do
            API.StopQuest(_Stages[i], true);
        end
        API.FailQuest(_QuestName, true);
        API.Note("fail staged quest '" .._QuestName.. "'");
        return "fail staged quest '" .._QuestName.. "'"
    elseif _Flag == 3 then
        for i= 1, #_Stages, 1 do
            API.StopQuest(_Stages[i], true);
        end
        API.StopQuest(_QuestName, true);
        API.Note("interrupt staged quest '" .._QuestName.. "'");
        return "interrupt staged quest '" .._QuestName.. "'";
    elseif _Flag == 4 then
        API.StartQuest(_QuestName, true);
        API.Note("trigger staged quest '" .._QuestName.. "'");
        return "trigger staged quest '" .._QuestName.. "'";
    elseif _Flag == 5 then
        for i= 1, #_Stages, 1 do
            API.StopQuest(_Stages[i], true);
            API.RestartQuest(_Stages[i], true);
        end
        API.RestartQuest(_QuestName, true);
        API.Note("restart staged quest '" .._QuestName.. "'");
        return "restart staged quest '" .._QuestName.. "'";
    elseif _Flag == 6 then
        if CurrentStage == 0 or CurrentStage >= StageAmount then
            return;
        end
        API.WinQuest(self.Data.StagesForQuest[_QuestName][CurrentStage], false);
        API.Note("forwarded stage of '" .._QuestName.. "'");
        return "forwarded stage of '" .._QuestName.. "'";
    elseif _Flag == 7 then
        local Previous = self.Data.StagesForQuest[_QuestName][CurrentStage-1];
        local Current  = self.Data.StagesForQuest[_QuestName][CurrentStage];
        API.StopQuest(Current, true);
        API.RestartQuest(Current);
        API.RestartQuest(Previous);
        API.Note("reverted stage of '" .._QuestName.. "'");
        return "reverted stage of '" .._QuestName.. "'";
    end
end


function AddOnQuestStages.Global:OverrideMethods()
    -- Neue Funktionalität für Debugger
    AddOnQuestDebug.Global.Data.DebugCommands = Array_Append(
        AddOnQuestDebug.Global.Data.DebugCommands,
        {
            {"forward", AddOnQuestDebug.Global.SetQuestState, 6},
            {"return",  AddOnQuestDebug.Global.SetQuestState, 7},
        }
    );
    
    -- Überschreiben der alten Debugger Funktionen
    AddOnQuestDebug.Global.SetQuestState_Orig_AddOnQuestStages = AddOnQuestDebug.Global.SetQuestState;
    AddOnQuestDebug.Global.SetQuestState = function(_Data, _Flag)
        local FoundQuests = AddOnQuestDebug.Global.FindQuestNames(_Data[2], true);
        if FoundQuests ~= 1 then
            AddOnQuestDebug.Global.SetQuestState_Orig_AddOnQuestStages(_Data, _Flag);
            return;
        end
        if not AddOnQuestStages.Global.Data.StagesForQuest[FoundQuests[1]] then
            AddOnQuestDebug.Global.SetQuestState_Orig_AddOnQuestStages(_Data, _Flag);
            return;
        end
        AddOnQuestStages.Global:DebugSetQuestState(
            FoundQuests,
            AddOnQuestStages.Global.Data.StagesForQuest[FoundQuests[1]],
            _Flag
        );
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterAddOn("AddOnQuestStages");

