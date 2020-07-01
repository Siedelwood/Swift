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

QSB.StageNameToQuestName = {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erstellt eine Reihe aufeinanderfolgender Aufträge, zusammengefasst under
-- einem übergeordneten Auftrag.
--
-- Die erzeugten Aufträge (Sub Quests) starten aufeinander folgend, sobald der
-- übergeordnete Auftrag (Main Quest) aktiv ist. Der nachfolgende Sub Quests
-- startet, sobald der Vorgänger erfolgreich abgeschlossen ist. Scheitert ein
-- Sub Quests, dann scheitert auch der Main Quest. Der Main Quest ist dann
-- erfolgreich, wenn der letzte Sub Quests erfolgreich ist.
--
-- <b>Hinweis</b>: Main Quests eignen sich nur für lineare Abläufe. Es kann
-- keine Verzweigungen innerhalb des Ablaufes geben. Wenn verzweigt werden
-- soll, müssen mehrere Main Quests paralel laufen!
--
-- Es ist nicht vorgesehen, dass Main Quests sichtbar sind oder Texte anzeigen.
-- Es ist trotzdem möglich, sollte aber unterlassen werden. 
--
-- Es ist nicht notwendig einen Trigger für die Sub Quests zu setzen. Der
-- Trigger wird automatisch generiert. Es können aber zusätzliche Trigger
-- angegeben werden. Der erzeugte Trigger ist i.d.R Trigger_OnQuestSuccess.
-- Wird ein Briefing im Vorgänger verwendet, wird stattdessen Trigger_Briefing
-- verwendet.
--
-- <b>Hinweis</b>: Es ist ebenfalls möglich bereits erstellte Quests und
-- sogar andere Main Quests anzugeben. Dazu wird statt der Definition nur
-- der Name angegeben.
--
-- <b>Alias</b>: AddMainQuest
--
-- @param[type=table] _Data Daten des Quest
-- @return[type=string] Name des Main Quest oder nil bei Fehler
-- @within Anwenderfunktionen
--
-- @usage API.CreateMainQuest {
--     Name        = "MainQuest",
--     Suggestion  = "Das ist die Main Quest.",
--     Success     = "Main Quest abgeschlossen!",
--     Failure     = "Main Quest fehlgeschlagen!",
--
--     Stages      = {
--         {
--             Suggestion  = "Wir benötigen einen höheren Titel!",
--             Goal_KnightTitle("Mayor"),
--         },
--         "ExternQuest1",
--         "ExternQuest2",
--         {
--             Suggestion  = "Wir benötigen außerdem mehr Asche! Und das sofort...",
--             Time        = 2 * 60,
--             Goal_Produce("G_Gold", 5000),
--         }
--     }
-- }
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
-- Wird kein Sub Quest gefunden, wird der name des Main Quest zurückgegeben
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
        return AddOnQuestStages.Global.Data.StagesForQuest[_QuestName][_Index];
    end
    return _QuestName;
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
        if type(_Data.Stages[i]) == "string" then
            self:LinkExternQuestAsStage(_Data.Stages[i], Name, i);
        elseif type(_Data.Stages[i]) == "table" then
            self:CreateQuestStage(_Data.Stages[i], Name, i);
        end
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
        local Current = self.Data.StagesForQuest[_QuestName][C];
        local Next    = self.Data.StagesForQuest[_QuestName][C+1];
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
        local Current  = self.Data.StagesForQuest[_QuestName][C];
        local Previous = self.Data.StagesForQuest[_QuestName][C-1];
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
            local StageQuest = Quests[GetQuestID(StageList[i])];
            -- Fehlschlag, wenn Stage fehlgeschlagen ist.
            if not StageQuest or StageQuest.Result == QuestResult.Failure then
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
            return "forwarded quest '" ..FoundQuests[1].. "'"
        end
    elseif _Flag == 2 then
        if API.RevertMainQuest(FoundQuests[1]) > 0 then
            API.Note("reverted quest '" ..FoundQuests[1].. "'");
            return "reverted quest '" ..FoundQuests[1].. "'"
        end
    end
end

-- -------------------------------------------------------------------------- --

---
-- Vordefinierte Funktionen für MSF Behavior. Diese Funktionen können nur im
-- Skript und nicht im Assistenten bentuzt werden!
--
-- Als Parameter werden immer Questname und Stage übergeben.
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
    API.ForwardMainQuest(_QuestName);
end

function QSB.MainQuest.Reprisal_NextStage(_QuestName)
    API.RevertMainQuest(_QuestName);
end

function QSB.MainQuest.Reward_PreviousStage(_QuestName)
    API.ForwardMainQuest(_QuestName);
end

function QSB.MainQuest.Reward_NextStage(_QuestName)
    API.RevertMainQuest(_QuestName);
end

function QSB.MainQuest.Trigger_OnStage(_QuestName, _Stage)
    local D, C, M = API.GetMainQuestProgress(_QuestName);
    if M > 0 and M >= _Stage and C == _Stage then
        return true;
    end
    return false;
end

-- -------------------------------------------------------------------------- --

Core:RegisterAddOn("AddOnQuestStages");

