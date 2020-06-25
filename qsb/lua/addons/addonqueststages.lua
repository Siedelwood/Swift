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


function API.CreateQuestSeries(_Data)
    if GUI then
        return;
    end
    return AddOnQuestStages.Global:CreateStagedQuest(_Data);
end
AddQuestSeries = API.CreateQuestSeries;


function API.GetQuestProgress(_QuestName)
    if GUI then
        return;
    end
    return AddOnQuestStages.Global:GetQuestProgress(_QuestName);
end
GetQuestProgress = API.GetQuestProgress;

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
    self:OverrideMethods();
end

---
-- Erstellt einen Main Quest mit seinen Sub Quests.
--
-- @param[type=table] _Data Beschreibung
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:CreateStagedQuest(_Data)   
    if not _Data.Stages then
        return;
    end
    -- Behavior zum Prüfen der Quest States der Subquests.
    table.insert(
        _Data,
        Goal_MapScriptFunction(self:GetCheckStagesInlineGoal(_Data.Name))
    )
    -- Quest erstellen
    local Name = API.CreateQuest(_Data);
    if not Name then
        return;
    end
    -- Unsichtbarkeit erzwingen
    Quests[GetQuestID(Name)].Visible = false;
    -- Subquests erstellen/verlinken
    self.Data.StagesForQuest[Name] = {};
    for i= 1, #_Data.Stages, 1 do
        if type(_Data.Stages[i]) == "string" then
            self:LinkExternQuestAsStage(_Data.Stages[i], Name, i);
        elseif type(_Data.Stages[i]) == "table" then
            self:CreateQuestStage(_Data.Stages[i], Name, i);
        end
    end
end

---
-- Gibt den Index des aktuell aktiven Sub Quest zurück.
--
-- @param[type=string] _QuestName  Name Main Quest
-- @return[type=number] Aktiver Subquest
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:GetCurrentQuestStage(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest ~= nil and self.Data.StagesForQuest[_QuestName] ~= nil then
        for i= 1, #self.Data.StagesForQuest[_QuestName], 1 do
            if Quests[GetQuestID(self.Data.StagesForQuest[_QuestName][i])].State == QuestState.Active then
                return i;
            end
        end
    end
    return 0;
end

---
-- Zählt wievele Sub Quests zum Main Quest zugeordnet sind.
--
-- @param[type=string] _QuestName  Name Main Quest
-- @return[type=number] Anzahl Stages
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:GetAmountOfQuestStages(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest ~= nil and self.Data.StagesForQuest[_QuestName] ~= nil then
        return #self.Data.StagesForQuest[_QuestName];
    end
    return 0;
end

---
-- Gibt den Fortschritt des Main Quest anhand der bereits abgeschlossenen
-- Sub Quests zurück.
--
-- @param[type=string] _QuestName  Name Main Quest
-- @return[type=number] Fortschritt in Prozent (0 ... 1)
-- @return[type=number] Aktueller Stage
-- @return[type=number] Höchst möglicher State
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:GetQuestProgress(_QuestName)
    local CurrentStage = self:GetCurrentQuestStage(_QuestName);
    local StageAmount  = self:GetAmountOfQuestStages(_QuestName);
    if StageAmount == 0 then
        return 0, 0, 0;
    end
    return CurrentStage / StageAmount, CurrentStage, StageAmount;
end

---
-- Erstellt das Behavior für die Prüfung der Subquests.
--
-- @param[type=string] _QuestName  Name Main Quest
-- @return[type=function] Behavior
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:GetCheckStagesInlineGoal(_QuestName)
    return 
    function ()
        local StageList = AddOnQuestStages.Global.Data.StagesForQuest[_QuestName];
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
        local StageQuest = Quests[GetQuestID(StageList[#StageList])];
        if StageQuest.Result == QuestResult.Success then
            return true;
        end
    end;
end

---
-- Integriert einen extern erzeugten Quest als Stage eines Main Quest.
--
-- @param[type=table]  _ExternName Name Sub Quest
-- @param[type=string] _QuestName  Name Main Quest
-- @param[type=number] _Index      Index des Stages
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:LinkExternQuestAsStage(_ExternName, _QuestName, _Index)
    local Extern = Quests[GetQuestID(_ExternName)];
    local Parent = Quests[GetQuestID(_QuestName)];

    if not Extern or Extern.State ~= QuestState.Inactive then
        return;
    end

    local LinkTrigger
    local Waittime = 0 + ((Extern[14] ~= nil and 6) or 0);
    if _Index == 1 then
        LinkTrigger = Trigger_OnQuestActive(_QuestName, Waittime):GetTriggerTable();
    else
        local LastName = self.Data.StagesForQuest[_QuestName][_Index -1];
        local LastQuest = Quests[GetQuestID(LastName)];
        Waittime = Waittime + (((LastQuest[15] ~= nil or LastQuest[15] ~= nil) and 6) or 0);
        if self:ContainsBriefing(LastQuest) then
            LinkTrigger = Trigger_Briefing(LastName, Waittime):GetTriggerTable();
        else
            LinkTrigger = Trigger_OnQuestSuccess(LastName, Waittime):GetTriggerTable();
        end
    end

    table.insert(Extern.Triggers, LinkTrigger);
    table.insert(self.Data.StagesForQuest[_QuestName], _ExternName);
end

---
-- Erstellt einen Subquest aus der übergebenen Beschreibung.
--
-- @param[type=table]  _Data      Subquest Daten
-- @param[type=string] _QuestName Name Main Quest
-- @param[type=number] _Index     Index des Stages
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:CreateQuestStage(_Data, _QuestName, _Index)
    local Name = _QuestName.. "_Stage_" .._Index;
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

    local Waittime = 0 + ((_Data.Suggestion ~= nil and 6) or 0);
    if _Index == 1 then
        table.insert(QuestDescription, Trigger_OnQuestActive(_QuestName, Waittime));
    else
        local LastName = self.Data.StagesForQuest[_QuestName][_Index -1];
        local LastQuest = Quests[GetQuestID(LastName)];
        Waittime = Waittime + (((LastQuest[15] ~= nil or LastQuest[15] ~= nil) and 6) or 0);
        if self:ContainsBriefing(LastQuest) then
            table.insert(QuestDescription, Trigger_Briefing(LastName, Waittime));
        else
            table.insert(QuestDescription, Trigger_OnQuestSuccess(LastName, Waittime));
        end
    end

    API.CreateQuest(QuestDescription);
    table.insert(self.Data.StagesForQuest[_QuestName], Name);
end

---
-- Pfüft, ob ein Briefing an den übergebenen Quest angehangen ist.
--
-- @param[type=table]  _Quest Quest
-- @return[type=boolean] Briefing enthalten
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:ContainsBriefing(_Quest)
    if BundleBriefingSystem then
        for i= 1, _Quest.Rewards[0], 1 do
            if _Quest.Reprisals[i][1] == Reward.Custom and _Quest.Reprisals[i][2][1].Name == "Reward_Briefing" then
                return true;
            end
        end
        for i= 1, _Quest.Reprisals[0], 1 do
            if _Quest.Reprisals[i][1] == Reprisal.Custom and _Quest.Reprisals[i][2][1].Name == "Reprisal_Briefing" then
                return true;
            end
        end
    end
    return false;
end

---
-- Überschreibt das Mapping der Konsolenbefehle des Debugs.
--
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:OverrideMethods()
    -- FailQuest überschreiben
    API.FailQuest_Orig_AddOnQuestStages = API.FailQuest;
    API.FailQuest = function(_QuestName, _Verbose)
        local CurrentStage = AddOnQuestStages.Global:GetCurrentQuestStage(_QuestName);
        local StageAmount  = AddOnQuestStages.Global:GetAmountOfQuestStages(_QuestName);
        
        if StageAmount > 0 then
            for k, v in pairs(AddOnQuestStages.Global.Data.StagesForQuest[_QuestName]) do
                API.StopQuest_Orig_AddOnQuestStages(v, true);
            end
        end
        API.FailQuest_Orig_AddOnQuestStages(_QuestName, _Verbose);
    end
    FailQuestByName = API.FailQuest;

    -- RestartQuest überschreiben
    API.RestartQuest_Orig_AddOnQuestStages = API.RestartQuest;
    API.RestartQuest = function(_QuestName, _Verbose)
        local CurrentStage = AddOnQuestStages.Global:GetCurrentQuestStage(_QuestName);
        local StageAmount  = AddOnQuestStages.Global:GetAmountOfQuestStages(_QuestName);
        
        if StageAmount > 0 then
            for k, v in pairs(AddOnQuestStages.Global.Data.StagesForQuest[_QuestName]) do
                API.StopQuest_Orig_AddOnQuestStages(v, true);
                API.RestartQuest_Orig_AddOnQuestStages(v, true);
            end
        end
        API.RestartQuest_Orig_AddOnQuestStages(_QuestName, _Verbose);
    end
    RestartQuestByName = API.RestartQuest;

    -- StartQuest überschreiben
    API.StartQuest_Orig_AddOnQuestStages = API.StartQuest;
    API.StartQuest = function(_QuestName, _Verbose)
        local CurrentStage = AddOnQuestStages.Global:GetCurrentQuestStage(_QuestName);
        local StageAmount  = AddOnQuestStages.Global:GetAmountOfQuestStages(_QuestName);
        
        if StageAmount > 0 then
            for k, v in pairs(AddOnQuestStages.Global.Data.StagesForQuest[_QuestName]) do
                API.StopQuest_Orig_AddOnQuestStages(v, true);
            end
            API.StartQuest_Orig_AddOnQuestStages(
                AddOnQuestStages.Global.Data.StagesForQuest[_QuestName][1],
                _Verbose
            );
        end
        API.StartQuest_Orig_AddOnQuestStages(_QuestName, _Verbose);
    end
    StartQuestByName = API.StartQuest;

    -- StopQuest überschreiben
    API.StopQuest_Orig_AddOnQuestStages = API.StopQuest;
    API.StopQuest = function(_QuestName, _Verbose)
        local CurrentStage = AddOnQuestStages.Global:GetCurrentQuestStage(_QuestName);
        local StageAmount  = AddOnQuestStages.Global:GetAmountOfQuestStages(_QuestName);
        
        if StageAmount > 0 then
            for k, v in pairs(AddOnQuestStages.Global.Data.StagesForQuest[_QuestName]) do
                API.StopQuest_Orig_AddOnQuestStages(v, true);
            end
        end
        API.StopQuest_Orig_AddOnQuestStages(_QuestName, _Verbose);
    end
    StopQuestByName = API.StopQuest;

    -- WinQuest überschreiben
    API.WinQuest_Orig_AddOnQuestStages = API.WinQuest;
    API.WinQuest = function(_QuestName, _Verbose)
        local CurrentStage = AddOnQuestStages.Global:GetCurrentQuestStage(_QuestName);
        local StageAmount  = AddOnQuestStages.Global:GetAmountOfQuestStages(_QuestName);
        
        if StageAmount > 0 then
            for k, v in pairs(AddOnQuestStages.Global.Data.StagesForQuest[_QuestName]) do
                API.StopQuest_Orig_AddOnQuestStages(v, true);
            end
        end
        API.WinQuest_Orig_AddOnQuestStages(_QuestName, _Verbose);
    end
    WinQuestByName = API.WinQuest;
end

-- -------------------------------------------------------------------------- --

Core:RegisterAddOn("AddOnQuestStages");

