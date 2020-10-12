-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnQuestStages                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht das Zusammenfassen mehrerer Quests unter einem Main Quest.
--
-- Diese Funktionalität kann ausschließlich für im Skript erstellte Quests
-- genutzt werden. Im Assistenten können Subquests nicht abgebildet werden.
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
-- @field Both    Erfolg und Misserfolg werden geleichermaßen akzeptiert.
--
QSB.ResultType = {
    Success = 1,
    Failure = 2,
    Both    = 3,
}

---
-- Vordefinierte Funktionen für MSF Behavior. Diese Funktionen können nur im
-- Skript und nicht im Assistenten bentuzt werden!
--
-- Als Parameter werden immer Questname und, falls benötigt, Stage übergeben.
--
-- @field Goal_ReachStage        Prüft, ob die Phase erreicht wurde.
-- @field Reprisal_PreviousStage Kehr zur vorherigen Phase zurück.
-- @field Reprisal_NextStage     Springt zur nächsten Phase vor.
-- @field Reward_PreviousStage   Kehr zur vorherigen Phase zurück.
-- @field Reward_NextStage       Springt zur nächsten Phase vor.
-- @field Trigger_OnStage        Prüft, ob die Phase erreicht wurde.
--
-- @usage -- Phase als Goal prüfen (schlägt nur bei Fehler fehl)
-- Goal_MapScriptFunction(QSB.MainQuest.Goal_ReachStage, "MyQuest", 3)
-- -- Phase zurück (Reprisal)
-- Reprisal_MapScriptFunction(QSB.MainQuest.Reprisal_PreviousStage, "MyQuest")
-- -- Phase vor (Reprisal)
-- Reprisal_MapScriptFunction(QSB.MainQuest.Reprisal_NextStage, "MyQuest")
-- -- Phase zurück (Reward)
-- Reward_MapScriptFunction(QSB.MainQuest.Reward_PreviousStage, "MyQuest")
-- -- Phase vor (Reward)
-- Reward_MapScriptFunction(QSB.MainQuest.Reward_NextStage, "MyQuest")
-- -- Phase als Trigger prüfen
-- Trigger_MapScriptFunction(QSB.MainQuest.Trigger_OnStage, "MyQuest", 5)
--
QSB.MainQuest = {};

function QSB.MainQuest.Goal_ReachStage(_QuestName, _Stage)
    local D, C, M = API.GetMainQuestProgress(_QuestName);
    if M == 0 and M < _Stage then
        return false;
    elseif C >= _Stage then
        return true;
    end
    return nil;
end

function QSB.MainQuest.Reprisal_PreviousStage(_QuestName)
    API.RevertMainQuest(_QuestName);
end

function QSB.MainQuest.Reprisal_NextStage(_QuestName)
    API.ForwardMainQuest(_QuestName);
end

function QSB.MainQuest.Reward_PreviousStage(_QuestName)
    API.RevertMainQuest(_QuestName);
end

function QSB.MainQuest.Reward_NextStage(_QuestName)
    API.ForwardMainQuest(_QuestName);
end

function QSB.MainQuest.Trigger_OnStage(_QuestName, _Stage)
    local D, C, M = API.GetMainQuestProgress(_QuestName);
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
-- Die erzeugten Aufträge (Sub Quests) starten aufeinander folgend, sobald der
-- übergeordnete Auftrag (Main Quest) aktiv ist. Der nachfolgende Sub Quests
-- startet, sobald der Vorgänger abgeschlossen ist. Das erwartete Ergebnis
-- kann gesetzt werden und ist per Default auf Erfolg gesetzt. Wenn ein Sub
-- Quest abgeschlossen wird und nicht das erwartete Ergebnis hat, dann schlägt
-- der Mainquest fehl. Der Main Quest wird erfolgreich abgeschlossen, sobald
-- der letzte Sub Quest beendet ist.
--
-- <b>Hinweis</b>: Main Quests eignen sich nur für lineare Abläufe. Es kann
-- keine Verzweigungen innerhalb des Ablaufes geben. Wenn verzweigt werden
-- soll, müssen mehrere Main Quests paralel laufen!
--
-- Es ist nicht vorgesehen, dass Main Quests sichtbar sind oder Texte anzeigen.
-- Es ist trotzdem möglich, <u>sollte aber unterlassen werden</u>. 
--
-- Es ist nicht notwendig einen Trigger für die Sub Quests zu setzen. Der
-- Trigger wird automatisch generiert. Es können aber zusätzliche Trigger
-- angegeben werden. Wird ein Briefing im Vorgänger verwendet, wird der
-- Trigger Trigger_Briefing verwendet, sonst ein OnQuest Trigger. Je nach
-- eingestellten Ergebnis wird entsprechend verknüpft.
--
-- Main Quests können auch ineinander verschachtelt werden. Man kann also
-- innerhalb einer Questreihe eine untergeordnete Questreige angeben.
--
-- <b>Alias</b>: AddMainQuest
--
-- @param[type=table] _Data Daten des Quest
-- @return[type=string] Name des Main Quest oder nil bei Fehler
-- @within Anwenderfunktionen
--
-- @usage API.CreateMainQuest {
--     Name        = "MainQuest",
--     Stages      = {
--         {
--             Suggestion  = "Wir benötigen einen höheren Titel!",
--
--             Goal_KnightTitle("Mayor"),
--         },
--         {
--             -- Mit dem Typ Both wird Fehlschlag ignoriert und der nächste
--             -- Quest startet nach diesem Quest.
--             Result      = QSB.ResultType.Both,
--
--             Suggestion  = "Wir benötigen außerdem mehr Asche! Und das sofort...",
--             Success     = "Geschafft!",
--             Failure     = "Versagt!",
--             Time        = 3 * 60,
--
--             Goal_Produce("G_Gold", 5000),
--
--             -- Main Quest wird gewonnen. Der Nachfolger startet nicht mehr.
--             Reward_QuestSuccess("MainQuest"),
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
function API.CreateMainQuest(_Data)
    if GUI then
        return;
    end
    return AddOnQuestStages.Global:CreateMainQuest(_Data);
end
AddMainQuest = API.CreateMainQuest;

---
-- Gibt den Fortschritt eines Main Quest zurück.
--
-- Kann der Fortschritt nicht bestimmt werden, wird 0, 0, 0 zurückgegeben.
--
-- <b>Alias</b>: GetQuestProgress
--
-- @param[type=string] _QuestName Name des Quest
-- @return[type=number] Relativer Fortschritt (0 ... 1)
-- @return[type=number] Index des aktiven Sub Quest
-- @return[type=number] Maximalanzahl Sub Quests
-- @within Anwenderfunktionen
-- @usage local Progress, Current, Max = API.GetMainQuestProgress("MyQuest");
--
function API.GetMainQuestProgress(_QuestName)
    if GUI then
        return;
    end
    return AddOnQuestStages.Global:GetMainQuestProgress(_QuestName);
end
GetQuestProgress = API.GetMainQuestProgress;

---
-- Spult einen Main Quest um einen Sub Quest vor.
--
-- Im Erfolgsfall wird eine Zahl größer 0 zurückgegeben. Tritt ein
-- Fehler auf stattdessen 0.
--
-- <b>Alias</b>: ForwardMainQuest
--
-- @param[type=string] _QuestName  Name Main Quest
-- @return[type=number] Index des Sub Quest
-- @within Anwenderfunktionen
--
function API.ForwardMainQuest(_QuestName)
    if GUI then
        return;
    end
    return AddOnQuestStages.Global:ForwardMainQuest(_QuestName);
end
ForwardMainQuest = API.ForwardMainQuest;

---
-- Setzt einen Main Quest um einen Sub Quest zurück.
--
-- Im Erfolgsfall wird eine Zahl größer 0 zurückgegeben. Tritt ein
-- Fehler auf stattdessen 0.
--
-- <b>Alias</b>: RevertMainQuest
--
-- @param[type=string] _QuestName  Name Main Quest
-- @return[type=number] Index des Sub Quest
-- @within Anwenderfunktionen
--
function API.RevertMainQuest(_QuestName)
    if GUI then
        return;
    end
    return AddOnQuestStages.Global:RevertMainQuest(_QuestName);
end
RevertMainQuest = API.RevertMainQuest;

---
-- Gibt den Skriptnamen des Sub Quest auf dem Index zurück.
--
-- <b>Alias</b>: GetSubQuestName
--
-- Wird kein Sub Quest gefunden, wird nil zurückgegeben
--
-- @param[type=string] _QuestName  Name Main Quest
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
-- Erstellt einen Main Quest mit seinen Sub Quests.
--
-- @param[type=table] _Data Beschreibung
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:CreateMainQuest(_Data)   
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
        self:CreateQuestStage(_Data.Stages[i], Name, i);
    end
    return Name;
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
            if Quests[GetQuestID(self.Data.StagesForQuest[_QuestName][i].Name)].State == QuestState.Active then
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
function AddOnQuestStages.Global:GetMainQuestProgress(_QuestName)
    local CurrentStage = self:GetCurrentQuestStage(_QuestName);
    local StageAmount  = self:GetAmountOfQuestStages(_QuestName);
    if StageAmount == 0 then
        return 0, 0, 0;
    end
    return CurrentStage / StageAmount, CurrentStage, StageAmount;
end

---
-- Spult einen Main Quest um einen Sub Quest vor.
--
-- @param[type=string] _QuestName  Name Main Quest
-- @return[type=number] Index des Sub Quest
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:ForwardMainQuest(_QuestName)
    local D, C, M = self:GetMainQuestProgress(_QuestName);
    if M > 0 and C+1 <= M then
        local Current = self.Data.StagesForQuest[_QuestName][C].Name;
        local Next    = self.Data.StagesForQuest[_QuestName][C+1].Name;
        API.StopQuest(Current, true);
        API.StartQuest(Next, true);
        return C+1;
    end
    return 0;
end

---
-- Setzt einen Main Quest um einen Sub Quest zurück.
--
-- @param[type=string] _QuestName  Name Main Quest
-- @return[type=number] Index des Sub Quest
-- @within Internal
-- @local
--
function AddOnQuestStages.Global:RevertMainQuest(_QuestName)
    local D, C, M = self:GetMainQuestProgress(_QuestName);
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
        local StageList = self.Data.StagesForQuest[_QuestName];
        for i= 1, #StageList, 1 do
            local StageQuest = Quests[GetQuestID(StageList[i].Name)];
            -- Nicht existierender Sub Quest bedeutet Fehlschlag
            if not StageQuest then
                return false;
            end
            -- Nicht erwartetes Resultat eines Sub Quest bedeutet Fehlschlag,
            if StageQuest.State == QuestState.Over and StageQuest.Result ~= QuestResult.Interrupted then
                if StageList[i].Result == QSB.ResultType.Success and StageQuest.Result ~= QuestResult.Success then
                    return false;
                end
                if StageList[i].Result == QSB.ResultType.Failure and StageQuest.Result ~= QuestResult.Failure then
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
        Stages      = _Data.Stages,
        Result      = _Data.Result or QSB.ResultType.Success,
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
            if PrevStageData.Result == QSB.ResultType.Success and QuestBriefingType == 1 then
                BriefingTriggerType = "Success";
            elseif PrevStageData.Result == QSB.ResultType.Failure and QuestBriefingType ==  2 then
                BriefingTriggerType = "Failure";
            end
            table.insert(QuestDescription, Trigger_Briefing(PrevStageData.Name, BriefingTriggerType, Waittime));
        else
            -- Bestimmen, welcher Trigger genutzt wird.
            if PrevStageData.Result == QSB.ResultType.Success then
                table.insert(QuestDescription, Trigger_OnQuestSuccess(PrevStageData.Name, Waittime));
            elseif PrevStageData.Result == QSB.ResultType.Failure then
                table.insert(QuestDescription, Trigger_OnQuestFailure(PrevStageData.Name, Waittime));
            else
                table.insert(QuestDescription, Trigger_OnQuestOver(PrevStageData.Name, Waittime));
            end
        end
    end

    if QuestDescription.Stages then
        self:CreateMainQuest(QuestDescription);
    else
        API.CreateQuest(QuestDescription);
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
        local CurrentStage = AddOnQuestStages.Global:GetCurrentQuestStage(_QuestName);
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
        local CurrentStage = AddOnQuestStages.Global:GetCurrentQuestStage(_QuestName);
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
        local CurrentStage = AddOnQuestStages.Global:GetCurrentQuestStage(_QuestName);
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
        local CurrentStage = AddOnQuestStages.Global:GetCurrentQuestStage(_QuestName);
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
        local CurrentStage = AddOnQuestStages.Global:GetCurrentQuestStage(_QuestName);
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
        if API.ForwardMainQuest(FoundQuests[1]) > 0 then
            API.Note("forwarded quest '" ..FoundQuests[1].. "'");
            return "forwarded quest '" ..FoundQuests[1].. "'";
        end
    elseif _Flag == 2 then
        if API.RevertMainQuest(FoundQuests[1]) > 0 then
            API.Note("reverted quest '" ..FoundQuests[1].. "'");
            return "reverted quest '" ..FoundQuests[1].. "'";
        end
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterAddOn("AddOnQuestStages");

