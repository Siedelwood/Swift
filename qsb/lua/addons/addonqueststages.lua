-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnQuestStages                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht das Zusammenfassen mehrerer Quests unter einem Staged Quest.
--
-- Diese Funktionalität kann ausschließlich für im Skript erstellte Quests
-- genutzt werden. Im Assistenten können Stages nicht abgebildet werden!
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnQuestStages = {};

API = API or {};
QSB = QSB or {};

---
-- Die Abschlussarten eines Quest Stage.
--
-- @field Success Phase muss erfolgreich abgeschlossen werden.
-- @field Failure Phase muss fehlschlagen.
-- @field Ignore  Erfolg und Misserfolg werden geleichermaßen akzeptiert.
--
QSB.StageResult = {
    Success = 1,
    Failure = 2,
    Ignore  = 3,
}

---
-- Vordefinierte Funktionen für MSF Behavior. Diese Funktionen können nur im
-- Skript und nicht im Assistenten bentuzt werden!
--
-- Als Parameter werden immer Questname und, falls benötigt, Stage übergeben.
--
-- @field Goal_ReachStage            Prüft, ob die Phase erreicht wurde.
-- @field Reprisal_RevertStage       Kehr zur vorherigen Phase zurück.
-- @field Reprisal_NextStage         Springt zur nächsten Phase vor.
-- @field Reprisal_NextStageByResult Setzt Ergebnis und Springt zur nächsten Phase vor.
-- @field Reward_RevertStage         Kehr zur vorherigen Phase zurück.
-- @field Reward_NextStage           Springt zur nächsten Phase vor.
-- @field Reward_NextStageByResult   Setzt Ergebnis und Springt zur nächsten Phase vor.
-- @field Trigger_OnStage            Prüft, ob die Phase erreicht wurde.
--
-- @usage -- Phase als Goal prüfen (schlägt nur bei Fehler fehl)
-- Goal_MapScriptFunction(QSB.StagedQuest.Goal_ReachStage, "MyQuest", 3)
-- -- Phase zurück (Reprisal)
-- Reprisal_MapScriptFunction(QSB.StagedQuest.Reprisal_RevertStage, "MyQuest")
-- -- Phase vor (Reprisal)
-- Reprisal_MapScriptFunction(QSB.StagedQuest.Reprisal_NextStage, "MyQuest")
-- -- Phase vor und Resultat des aktuellen Stage setzen (Reprisal)
-- Reprisal_MapScriptFunction(QSB.StagedQuest.Reprisal_NextStageByResult, "MyQuest", QSB.StageResult.Success)
-- -- Phase zurück (Reward)
-- Reward_MapScriptFunction(QSB.StagedQuest.Reward_RevertStage, "MyQuest")
-- -- Phase vor (Reward)
-- Reward_MapScriptFunction(QSB.StagedQuest.Reward_NextStage, "MyQuest")
-- -- Phase vor und Resultat des aktuellen Stage setzen (Reward)
-- Reward_MapScriptFunction(QSB.StagedQuest.Reward_NextStageByResult, "MyQuest", QSB.StageResult.Success)
-- -- Phase als Trigger prüfen
-- Trigger_MapScriptFunction(QSB.StagedQuest.Trigger_OnStage, "MyQuest", 5)
--
QSB.StagedQuest = {};

function QSB.StagedQuest.Goal_ReachStage(_QuestName, _Stage)
    local C = API.GetCurrentQuestStage(_QuestName);
    local M = API.GetAmountOfQuestStages(_QuestName);
    if M == 0 and M < _Stage then
        return false;
    elseif C >= _Stage then
        return true;
    end
    return nil;
end

function QSB.StagedQuest.Reprisal_RevertStage(_QuestName)
    API.RevertStagedQuest(_QuestName);
end

function QSB.StagedQuest.Reprisal_NextStage(_QuestName)
    API.ForwardStagedQuest(_QuestName);
end

function QSB.StagedQuest.Reprisal_NextStageByResult(_QuestName, _Result)
    API.ForwardStagedQuest(_QuestName, _Result);
end

function QSB.StagedQuest.Reward_RevertStage(_QuestName)
    API.RevertStagedQuest(_QuestName);
end

function QSB.StagedQuest.Reward_NextStage(_QuestName)
    API.ForwardStagedQuest(_QuestName);
end

function QSB.StagedQuest.Reward_NextStageByResult(_QuestName, _Result)
    API.ForwardStagedQuest(_QuestName, _Result);
end

function QSB.StagedQuest.Trigger_OnStage(_QuestName, _Stage)
    local C = API.GetCurrentQuestStage(_QuestName);
    local M = API.GetAmountOfQuestStages(_QuestName);
    if M > 0 and M >= _Stage and C >= _Stage then
        return true;
    end
    return false;
end

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erstellt eine Reihe aufeinanderfolgender Aufträge, zusammengefasst under
-- einem übergeordneten Auftrag.
--
-- Die erzeugten Aufträge (Stages) starten aufeinander folgend, sobald der
-- übergeordnete Auftrag (Staged Quest) aktiv ist. Der nachfolgende Stage
-- startet, sobald der Vorgänger abgeschlossen ist. Das erwartete Ergebnis
-- kann gesetzt werden und ist per Default auf Erfolg gesetzt. Wenn ein Stage
-- abgeschlossen wird und nicht das erwartete Ergebnis hat, dann schlägt
-- der StagedQuest fehl. Der Staged Quest wird erfolgreich abgeschlossen, sobald
-- der letzte Stage beendet ist.
--
-- <b>Hinweis</b>: Staged Quests eignen sich nur für lineare Abläufe. Es kann
-- keine Verzweigungen innerhalb des Ablaufes geben. Wenn verzweigt werden
-- soll, müssen mehrere Staged Quests paralel laufen!
--
-- Es ist nicht vorgesehen, dass Staged Quests sichtbar sind oder Texte anzeigen.
-- Es ist trotzdem möglich, <u>sollte aber unterlassen werden</u>. 
--
-- Es ist nicht notwendig einen Trigger für die Stage zu setzen. Der
-- Trigger wird automatisch generiert. Es können aber zusätzliche Trigger
-- angegeben werden. Wird ein Briefing im Vorgänger verwendet, wird der
-- Trigger Trigger_Briefing verwendet, sonst ein OnQuest Trigger. Je nach
-- eingestellten Ergebnis wird entsprechend verknüpft.
--
-- Staged Quests können auch ineinander verschachtelt werden. Man kann also
-- innerhalb einer Questreihe eine untergeordnete Questreige angeben.
--
-- <b>Alias</b>: AddStagedQuest
--
-- @param[type=table] _Data Daten des Quest
-- @return[type=string] Name des Staged Quest oder nil bei Fehler
-- @within Anwenderfunktionen
--
-- @usage API.CreateStagedQuest {
--     Name        = "StagedQuest",
--     Stages      = {
--         {
--             Suggestion  = "Wir benötigen einen höheren Titel!",
--
--             Goal_KnightTitle("Mayor"),
--         },
--         {
--             -- Mit dem Typ Ignore wird Fehlschlag ignoriert und der nächste
--             -- Quest startet nach diesem Quest.
--             Result      = QSB.StageResult.Ignore,
--
--             Suggestion  = "Wir benötigen außerdem mehr Asche! Und das sofort...",
--             Success     = "Geschafft!",
--             Failure     = "Versagt!",
--             Time        = 3 * 60,
--
--             Goal_Produce("G_Gold", 5000),
--
--             -- Staged Quest wird gewonnen. Der Nachfolger startet nicht mehr.
--             Reward_QuestSuccess("StagedQuest"),
--         },
--         {
--             Suggestion  = "Dann versuchen wir es mit Eisen...",
--             Success     = "Geschafft!",
--             Failure     = "Versagt!",
--             Time        = 3 * 60,
--
--             Goal_Produce("G_Iron", 50),
--         }
--     },
--
--     -- Wenn ein Quest nicht das erwartete Ergebnis hat, Fehlschlag.
--     Reprisal_Defeat(),
--
--     -- Wenn alles erfüllt wird, ist das Spiel gewonnen.
--     Reward_VictoryWithParty(),
-- };
--
function API.CreateStagedQuest(_Data)
    if GUI or type(_Data) ~= "table" then
        return;
    end
    if _Data.Stages == nil or #_Data.Stages == 0 then
        error(string.format("API.CreateStagedQuest: Staged quest '%s' is missing it's stages!", tostring(_Data.Name)));
        return;
    end
    return AddOnQuestStages.Global:CreateStagedQuest(_Data);
end
AddStagedQuest = API.CreateStagedQuest;

---
-- Gibt den Index des aktuell aktiven Stages eines Staged Quest zurück.
--
-- Ist ein Staged Quest bereits abgeschlossen wird immer der Index des letzten
-- Stage zurückgegeben.
--
-- <b>Alias</b>: GetQuestStage
--
-- @param[type=string] _QuestName Name des Quest
-- @return[type=number] Relativer Fortschritt (0 ... 1)
-- @within Anwenderfunktionen
--
-- @usage local CurrentStage = API.GetCurrentQuestStage("MyQuest");
--
function API.GetCurrentQuestStage(_QuestName)
    if GUI then
        return 0;
    end
    local Quest = Quests[GetQuestID(_QuestName)];
    if not API.IsValidQuest(_QuestName) then
        error(string.format("API.GetCurrentQuestStage: Quest '%s' does not exist!", tostring(_QuestName)));
        return 0;
    end
    if AddOnQuestStages.Global.Data.StagesForQuest[_QuestName] == nil then
        error(string.format("API.GetCurrentQuestStage: Quest '%s' is not a staged quest!", tostring(_QuestName)));
        return 0;
    end
    return AddOnQuestStages.Global:GetCurrentQuestStage(_QuestName);
end
GetQuestStage = API.GetCurrentQuestStage;

---
-- Gibt die Anzahl der Stages eines Staged Quest zurück.
--
-- <b>Alias</b>: CountQuestStages
--
-- @param[type=string] _QuestName Name des Quest
-- @return[type=number] Relativer Fortschritt (0 ... 1)
-- @within Anwenderfunktionen
-- @usage local Stages = API.GetAmountOfQuestStages("MyQuest");
--
function API.GetAmountOfQuestStages(_QuestName)
    if GUI then
        return 0;
    end
    if not API.IsValidQuest(_QuestName) then
        error(string.format("API.GetAmountOfQuestStages: Quest '%s' does not exist!", tostring(_QuestName)));
        return 0;
    end
    if AddOnQuestStages.Global.Data.StagesForQuest[_QuestName] == nil then
        error(string.format("API.GetAmountOfQuestStages: Quest '%s' is not a staged quest!", tostring(_QuestName)));
        return 0;
    end
    return AddOnQuestStages.Global:GetAmountOfQuestStages(_QuestName);
end
CountQuestStages = API.GetAmountOfQuestStages;

---
-- Gibt den Fortschritt eines Staged Quest zurück.
--
-- Kann der Fortschritt nicht bestimmt werden, wird 0 zurückgegeben.
--
-- <b>Alias</b>: GetQuestProgress
--
-- @param[type=string] _QuestName Name des Quest
-- @return[type=number] Relativer Fortschritt (0 ... 1)
-- @within Anwenderfunktionen
--
-- @usage -- Fortschritt ermitteln
-- local Progress = API.GetStagedQuestProgress("MyQuest");
-- -- Fortschritt in % ermitteln
-- local Progress = API.Round(API.GetStagedQuestProgress("MyQuest") * 100, 0);
--
function API.GetStagedQuestProgress(_QuestName)
    if GUI then
        return 0;
    end
    if not API.IsValidQuest(_QuestName) then
        error(string.format("API.GetStagedQuestProgress: Quest '%s' does not exist!", tostring(_QuestName)));
        return 0;
    end
    if AddOnQuestStages.Global.Data.StagesForQuest[_QuestName] == nil then
        error(string.format("API.GetStagedQuestProgress: Quest '%s' is not a staged quest!", tostring(_QuestName)));
        return 0;
    end
    -- Es wäre theoretisch möglich durch Veränderung der Daten hier eine
    -- Division durch 0 herbeizuführen. Da es aber nicht möglich ist, einen
    -- Staged Quest ohne Stages zu erzeugen, wird das hier vernachlässigt.
    return API.GetCurrentQuestStage(_QuestName) / API.GetAmountOfQuestStages(_QuestName);
end
GetQuestProgress = API.GetStagedQuestProgress;

---
-- Spult einen Staged Quest um einen Stage vor.
--
-- Im Erfolgsfall wird eine Zahl größer 0 zurückgegeben. Tritt ein
-- Fehler auf stattdessen 0.
--
-- <b>Alias</b>: ForwardStagedQuest
--
-- @param[type=string] _QuestName  Name Staged Quest
-- @param[type=number] _Result     (Optional) Resultat des Stage
-- @return[type=number] Index des Stage
-- @within Anwenderfunktionen
--
function API.ForwardStagedQuest(_QuestName, _Result)
    if GUI then
        return;
    end
    if not API.IsValidQuest(_QuestName) then
        error(string.format("API.ForwardStagedQuest: Quest '%s' does not exist!", tostring(_QuestName)));
        return 0;
    end
    if AddOnQuestStages.Global.Data.StagesForQuest[_QuestName] == nil then
        error(string.format("API.ForwardStagedQuest: Quest '%s' is not a staged quest!", tostring(_QuestName)));
        return 0;
    end
    return AddOnQuestStages.Global:ForwardStagedQuest(_QuestName, _Result);
end
ForwardStagedQuest = API.ForwardStagedQuest;

---
-- Setzt einen Staged Quest um einen Stage zurück.
--
-- Im Erfolgsfall wird eine Zahl größer 0 zurückgegeben. Tritt ein
-- Fehler auf stattdessen 0.
--
-- <b>Alias</b>: RevertStagedQuest
--
-- @param[type=string] _QuestName  Name Staged Quest
-- @return[type=number] Index des Stage
-- @within Anwenderfunktionen
--
function API.RevertStagedQuest(_QuestName)
    if GUI then
        return;
    end
    if not API.IsValidQuest(_QuestName) then
        error(string.format("API.RevertStagedQuest: Quest '%s' does not exist!", tostring(_QuestName)));
        return 0;
    end
    if AddOnQuestStages.Global.Data.StagesForQuest[_QuestName] == nil then
        error(string.format("API.RevertStagedQuest: Quest '%s' is not a staged quest!", tostring(_QuestName)));
        return 0;
    end
    return AddOnQuestStages.Global:RevertStagedQuest(_QuestName);
end
RevertStagedQuest = API.RevertStagedQuest;

---
-- Gibt den Skriptnamen des Stage auf dem Index zurück.
--
-- <b>Alias</b>: GetSubQuestName
--
-- Wird kein Stage gefunden, wird nil zurückgegeben
--
-- @param[type=string] _QuestName  Name Staged Quest
-- @return[type=string] Quest Name
-- @within Anwenderfunktionen
--
function API.GetSubQuestName(_QuestName, _Index)
    if GUI then
        return;
    end
    if AddOnQuestStages.Global.Data.StagesForQuest[_QuestName] then
        if AddOnQuestStages.Global.Data.StagesForQuest[_QuestName][_Index] then
            return AddOnQuestStages.Global.Data.StagesForQuest[_QuestName][_Index].Name;
        end
    end
    return nil;
end
GetSubQuestName = API.GetSubQuestName;

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
-- Erstellt einen Staged Quest mit seinen Stages.
--
-- @param[type=table] _Data Beschreibung
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:CreateStagedQuest(_Data)   
    if not _Data.Stages then
        return;
    end
    -- Behavior zum Prüfen der Quest States der Stages.
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
    -- Stages erstellen/verlinken
    self.Data.StagesForQuest[Name] = {};
    for i= 1, #_Data.Stages, 1 do
        self:CreateQuestStage(_Data.Stages[i], Name, i);
    end
    return Name;
end

---
-- Gibt den Index des aktuell aktiven Stage zurück.
--
-- Wenn der Staged Quest bereits beendet ist, ist der aktuelle Stage immer der
-- letzte Stage des Quest.
--
-- @param[type=string] _QuestName Name des Staged Quest
-- @return[type=number] Aktiver Stage
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:GetCurrentQuestStage(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest ~= nil and self.Data.StagesForQuest[_QuestName] ~= nil then
        if Quest.State ~= QuestState.Over then
            for i= 1, #self.Data.StagesForQuest[_QuestName], 1 do
                if Quests[GetQuestID(self.Data.StagesForQuest[_QuestName][i].Name)].State == QuestState.Active then
                    return i;
                end
            end
            return 0;
        end
        return #self.Data.StagesForQuest[_QuestName];
    end
    return 0;
end

---
-- Zählt wievele Stages zum Staged Quest zugeordnet sind.
--
-- @param[type=string] _QuestName  Name des Staged Quest
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
-- Gibt den Fortschritt des Staged Quest anhand der bereits abgeschlossenen
-- Stages zurück.
--
-- @param[type=string] _QuestName  Name des Staged Quest
-- @return[type=number] Fortschritt in Prozent (0 ... 1)
-- @return[type=number] Aktueller Stage
-- @return[type=number] Höchst möglicher State
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:GetStagedQuestProgress(_QuestName)
    local StageAmount  = self:GetAmountOfQuestStages(_QuestName);
    if StageAmount == 0 then
        return 0, 0, 0;
    end
    local CurrentStage = self:GetCurrentQuestStage(_QuestName);
    return CurrentStage / StageAmount, CurrentStage, StageAmount;
end

---
-- Spult einen Staged Quest um einen Stage vor.
--
-- @param[type=string] _QuestName   Name des Staged Quest
-- @param[type=number] _StageResult (Optional) Resultat des Stage
-- @return[type=number] Index des Stage
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:ForwardStagedQuest(_QuestName, _StageResult)
    local D, C, M = self:GetStagedQuestProgress(_QuestName);
    if M > 0 and C+1 <= M then
        local Current = self.Data.StagesForQuest[_QuestName][C].Name;
        local Next    = self.Data.StagesForQuest[_QuestName][C+1].Name;
        -- Quest gewinnen, wenn das gewünschte Ergebnis Erfolg oder egal ist.
        if self.Data.StagesForQuest[_QuestName][C].Result == QSB.StageResult.Success
        or self.Data.StagesForQuest[_QuestName][C].Result == QSB.StageResult.Ignore
        or _StageResult == QSB.StageResult.Success then
            API.WinQuest(Current, true);
        end
        -- Quest verlieren, wenn das gewünschte Ergebnis Niederlage ist.
        if self.Data.StagesForQuest[_QuestName][C].Result == QSB.StageResult.Failure
        or _StageResult == QSB.StageResult.Failure then
            API.FailQuest(Current, true);
        end
        -- Nächste Quest starten
        API.StartQuest(Next, true);
        return C+1;
    end
    return 0;
end

---
-- Setzt einen Staged Quest um einen Stage zurück.
--
-- @param[type=string] _QuestName  Name des Staged Quest
-- @return[type=number] Index des Stage
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:RevertStagedQuest(_QuestName)
    local D, C, M = self:GetStagedQuestProgress(_QuestName);
    if M > 0 and C-1 > 0 then
        local Current  = self.Data.StagesForQuest[_QuestName][C].Name;
        local Previous = self.Data.StagesForQuest[_QuestName][C-1].Name;
        API.StopQuest(Current, true);
        API.RestartQuest(Previous, true);
        API.RestartQuest(Current, true);
        return C-1;
    end
    return 0;
end

---
-- Erstellt das Behavior für die Prüfung der Stage.
--
-- @param[type=string] _QuestName  Name des Staged Quest
-- @return[type=function] Behavior
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:GetCheckStagesInlineGoal(_QuestName)
    return 
    function ()
        local StageList = self.Data.StagesForQuest[_QuestName];
        for i= 1, #StageList, 1 do
            local StageQuest = Quests[GetQuestID(StageList[i].Name)];
            -- Nicht existierender Stage bedeutet Fehlschlag
            if not StageQuest then
                return false;
            end
            -- Nicht erwartetes Resultat eines Stage bedeutet Fehlschlag,
            if StageQuest.State == QuestState.Over and StageQuest.Result ~= QuestResult.Interrupted then
                if StageList[i].Result == QSB.StageResult.Success and StageQuest.Result ~= QuestResult.Success then
                    self:AbortFollowingStages(_QuestName);
                    return false;
                end
                if StageList[i].Result == QSB.StageResult.Failure and StageQuest.Result ~= QuestResult.Failure then
                    self:AbortFollowingStages(_QuestName);
                    return false;
                end
            end
        end
        -- Erfolg, wenn letzter Stage beendet ist.
        local StageQuest = Quests[GetQuestID(StageList[#StageList].Name)];
        if StageQuest.State == QuestState.Over and StageQuest.Result ~= QuestResult.Interrupted then
            return true;
        end
    end;
end

---
-- 
--
-- @param[type=string] _QuestName  Name des Staged Quest
-- @return[type=function] Behavior
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:AbortFollowingStages(_QuestName)
    local Current = API.GetCurrentQuestStage(_QuestName);
    local Maximum = API.GetAmountOfQuestStages(_QuestName);
    for i= 1, #self.Data.StagesForQuest[_QuestName], 1 do
        API.StopQuest(self.Data.StagesForQuest[_QuestName][i].Name, true);
    end
end

---
-- Erstellt einen Stage aus der übergebenen Beschreibung.
--
-- @param[type=table]  _Data      Stage Daten
-- @param[type=string] _QuestName Name des Staged Quest
-- @param[type=number] _Index     Index des Stages
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:CreateQuestStage(_Data, _QuestName, _Index)
    local Name = _Data.Name or _QuestName.. "@Stage" .._Index;
    local Parent = Quests[GetQuestID(_QuestName)];

    local QuestDescription = {
        Name        = Name,
        Stages      = _Data.Stages,
        Result      = _Data.Result or QSB.StageResult.Success,
        Sender      = _Data.Sender or Parent.SendingPlayer,
        Receiver    = _Data.Receiver or Parent.ReceivingPlayer,
        Time        = _Data.Time,
        Suggestion  = _Data.Suggestion,
        Success     = _Data.Success,
        Failure     = _Data.Failure,
        Description = _Data.Description,
        Loop        = _Data.Loop,
        Callback    = _Data.Callback,
    };
    for i= 1, #_Data do
        table.insert(QuestDescription, _Data[i]);
    end

    local Waittime = 0 + ((_Data.Suggestion ~= nil and 6) or 0);
    if _Index == 1 then
        table.insert(QuestDescription, Trigger_OnQuestActive(_QuestName, Waittime));
    else
        local PrevStageData = self.Data.StagesForQuest[_QuestName][_Index -1];
        local PrevQuestData = Quests[GetQuestID(PrevStageData.Name)];
        Waittime = Waittime + (((PrevQuestData[15] ~= nil or PrevQuestData[15] ~= nil) and 6) or 0);
        local QuestBriefingType = self:ContainsBriefing(PrevStageData);
        if QuestBriefingType > 0 then
            -- Einschränkung für Briefing Trigger bestimmen.
            local BriefingTriggerType = "All";
            if PrevStageData.Result == QSB.StageResult.Success and QuestBriefingType == 1 then
                BriefingTriggerType = "Success";
            elseif PrevStageData.Result == QSB.StageResult.Failure and QuestBriefingType ==  2 then
                BriefingTriggerType = "Failure";
            end
            table.insert(QuestDescription, Trigger_Briefing(PrevStageData.Name, BriefingTriggerType, Waittime));
        else
            -- Bestimmen, welcher Trigger genutzt wird.
            if PrevStageData.Result == QSB.StageResult.Success then
                table.insert(QuestDescription, Trigger_OnQuestSuccess(PrevStageData.Name, Waittime));
            elseif PrevStageData.Result == QSB.StageResult.Failure then
                table.insert(QuestDescription, Trigger_OnQuestFailure(PrevStageData.Name, Waittime));
            else
                table.insert(QuestDescription, Trigger_OnQuestOver(PrevStageData.Name, Waittime));
            end
        end
    end

    if QuestDescription.Stages then
        self:CreateStagedQuest(QuestDescription);
    else
        local QuestName = API.CreateQuest(QuestDescription);
        local Quest = Quests[GetQuestID(QuestName)];
        if Quest then
            Quests[GetQuestID(QuestName)].SkipFunction = _Data.Skip;
        end
    end
    table.insert(self.Data.StagesForQuest[_QuestName], QuestDescription);
end

---
-- Pfüft, ob ein Briefing in den übergebenen Questdaten vorhanden ist.
--
-- @param[type=table]  _Description Quest Daten
-- @return[type=number] Briefing Typ
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:ContainsBriefing(_Description)
    if BundleBriefingSystem then
        for i= 1, #_Description, 1 do
            if _Description[i].Name then
                if _Description[i].Name == "Reward_Briefing" then
                    return 1;
                elseif _Description[i].Name == "Reprisal_Briefing" then
                    return 2;
                end
            end
        end
    end
    return 0;
end

---
-- Überschreibt das Mapping der Konsolenbefehle des Debugs.
--
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:OverrideMethods()
    table.insert(AddOnQuestDebug.Global.Data.DebugCommands, {
        "forward", self.SetQuestState, 1
    });
    table.insert(AddOnQuestDebug.Global.Data.DebugCommands, {
        "revert",  self.SetQuestState, 2
    });

    -- FailQuest überschreiben
    API.FailQuest_Orig_AddOnQuestStages = API.FailQuest;
    API.FailQuest = function(_QuestName, _Verbose)
        local StageAmount  = AddOnQuestStages.Global:GetAmountOfQuestStages(_QuestName);
        
        if StageAmount > 0 then
            for k, v in pairs(AddOnQuestStages.Global.Data.StagesForQuest[_QuestName]) do
                API.StopQuest_Orig_AddOnQuestStages(v.Name, true);
            end
        end
        API.FailQuest_Orig_AddOnQuestStages(_QuestName, _Verbose);
    end
    FailQuestByName = API.FailQuest;

    -- RestartQuest überschreiben
    API.RestartQuest_Orig_AddOnQuestStages = API.RestartQuest;
    API.RestartQuest = function(_QuestName, _Verbose)
        local StageAmount  = AddOnQuestStages.Global:GetAmountOfQuestStages(_QuestName);
        
        if StageAmount > 0 then
            for k, v in pairs(AddOnQuestStages.Global.Data.StagesForQuest[_QuestName]) do
                API.StopQuest_Orig_AddOnQuestStages(v.Name, true);
                API.RestartQuest_Orig_AddOnQuestStages(v.Name, true);
            end
        end
        API.RestartQuest_Orig_AddOnQuestStages(_QuestName, _Verbose);
    end
    RestartQuestByName = API.RestartQuest;

    -- StartQuest überschreiben
    API.StartQuest_Orig_AddOnQuestStages = API.StartQuest;
    API.StartQuest = function(_QuestName, _Verbose)
        local StageAmount  = AddOnQuestStages.Global:GetAmountOfQuestStages(_QuestName);
        
        if StageAmount > 0 then
            for k, v in pairs(AddOnQuestStages.Global.Data.StagesForQuest[_QuestName]) do
                API.StopQuest_Orig_AddOnQuestStages(v.Name, true);
            end
            API.StartQuest_Orig_AddOnQuestStages(
                AddOnQuestStages.Global.Data.StagesForQuest[_QuestName][1].Name,
                _Verbose
            );
        end
        API.StartQuest_Orig_AddOnQuestStages(_QuestName, _Verbose);
    end
    StartQuestByName = API.StartQuest;

    -- StopQuest überschreiben
    API.StopQuest_Orig_AddOnQuestStages = API.StopQuest;
    API.StopQuest = function(_QuestName, _Verbose)
        local StageAmount  = AddOnQuestStages.Global:GetAmountOfQuestStages(_QuestName);
        
        if StageAmount > 0 then
            for k, v in pairs(AddOnQuestStages.Global.Data.StagesForQuest[_QuestName]) do
                API.StopQuest_Orig_AddOnQuestStages(v.Name, true);
            end
        end
        API.StopQuest_Orig_AddOnQuestStages(_QuestName, _Verbose);
    end
    StopQuestByName = API.StopQuest;

    -- WinQuest überschreiben
    API.WinQuest_Orig_AddOnQuestStages = API.WinQuest;
    API.WinQuest = function(_QuestName, _Verbose)
        local StageAmount  = AddOnQuestStages.Global:GetAmountOfQuestStages(_QuestName);
        
        if StageAmount > 0 then
            for k, v in pairs(AddOnQuestStages.Global.Data.StagesForQuest[_QuestName]) do
                API.StopQuest_Orig_AddOnQuestStages(v.Name, true);
            end
        end
        API.WinQuest_Orig_AddOnQuestStages(_QuestName, _Verbose);
    end
    WinQuestByName = API.WinQuest;
end

---
-- Überschreibt das Mapping der Konsolenbefehle des Debugs.
--
-- @param[type=table]   _Data Befehl
-- @param[type=boolean] _Flag Index
-- @within Internal
-- @local
--
function AddOnQuestStages.Global.SetQuestState(_Data, _Flag)
    local FoundQuests = AddOnQuestDebug.Global.FindQuestNames(_Data[2], true);
    if #FoundQuests ~= 1 then
        API.Note("Unable to find quest containing '" .._Data[2].. "'");
        return "Unable to find quest containing '" .._Data[2].. "'";
    end
    if _Flag == 1 then
        if API.ForwardStagedQuest(FoundQuests[1]) > 0 then
            API.Note("forwarded quest '" ..FoundQuests[1].. "'");
            return "forwarded quest '" ..FoundQuests[1].. "'";
        end
    elseif _Flag == 2 then
        if API.RevertStagedQuest(FoundQuests[1]) > 0 then
            API.Note("reverted quest '" ..FoundQuests[1].. "'");
            return "reverted quest '" ..FoundQuests[1].. "'";
        end
    end
end

---
-- Bricht den Slave Quest des Random Request ab.
-- @param[type=table] _Quest     Quest Data
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:OnQuestSkipped(_Quest)
    if self.Data.StagesForQuest[_Quest.Identifier] then
        for k, v in pairs(self.Data.StagesForQuest[_Quest.Identifier]) do
            API.SkipSingleQuest(v.Name);
        end
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterAddOn("AddOnQuestStages");

