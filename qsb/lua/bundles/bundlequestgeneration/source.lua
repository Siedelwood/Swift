-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Synfonia BundleQuestGeneration                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Modul können Aufträge per Skript erstellt werden.
--
-- 
--
-- @module BundleQuestGeneration
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erstellt einen Quest, startet ihn jedoch noch nicht.
--
-- <b>Alias:</b> AddQuest
--
-- Ein Quest braucht immer wenigstens ein Goal und einen Trigger. Hat ein Quest
-- keinen Namen, erhält er automatisch einen mit fortlaufender Nummerierung.
--
-- Ein Quest besteht aus verschiedenen Parametern und Behavior, die nicht
-- alle zwingend gesetzt werden müssen. Behavior werden einfach nach den
-- Feldern nacheinander aufgerufen.
-- <p><u>Parameter:</u></p>
-- <ul>
-- <li>Name: Der eindeutige Name des Quests</li>
-- <li>Sender: PlayerID des Auftraggeber (Default 1)</li>
-- <li>Receiver: PlayerID des Auftragnehmer (Default 1)</li>
-- <li>Suggestion: Vorschlagnachricht des Quests</li>
-- <li>Success: Erfolgsnachricht des Quest</li>
-- <li>Failure: Fehlschlagnachricht des Quest</li>
-- <li>Description: Aufgabenbeschreibung (Nur bei Custom)</li>
-- <li>Time: Zeit bis zu, Fehlschlag</li>
-- <li>Loop: Funktion, die während der Laufzeit des Quests aufgerufen wird</li>
-- <li>Callback: Funktion, die nach Abschluss aufgerufen wird</li>
-- </ul>
--
-- @param _Data Questdefinition
-- @within User Space
--
function API.AddQuest(_Data)
    return BundleQuestGeneration.Global:NewQuest(_Data);
end
AddQuest = API.AddQuest;

---
-- Startet alle mittels API.AddQuest initalisierten Quests.
--
-- @within User Space
--
function API.StartQuests()
    return BundleQuestGeneration.Global:StartQuests();
end
StartQuests = API.StartQuests;

-- -------------------------------------------------------------------------- --
-- Application Space                                                          --
-- -------------------------------------------------------------------------- --

BundleQuestGeneration = {
    Global = {
        Data = {
            GenerationList = {},
        }
    },
    Local = {
        Data = {}
    },
}

BundleQuestGeneration.Global.Data.QuestTemplate = {
    MSGKeyOverwrite = nil;
    IconOverwrite   = nil;
    Loop            = nil;
    Callback        = nil;
    SuggestionText  = nil;
    SuccessText     = nil;
    FailureText     = nil;
    Description     = nil;
    Identifier      = nil;
    OpenMessage     = true,
    CloseMessage    = true,
    Sender          = 1;
    Receiver        = 1;
    Time            = 0;
    Goals           = {};
    Reprisals       = {};
    Rewards         = {};
    Triggers        = {};
};

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Application Space
-- @local
--
function BundleQuestGeneration.Global:Install()

end

---
-- Erzeugt einen Quest und trägt ihn in die GenerationList ein.
--
-- @param _Data Daten des Quest.
-- @within Application Space
-- @local
--
function BundleQuestGeneration.Global:NewQuest(_Data)
    if not _Data.Name then
        QSB.AutomaticQuestNameCounter = (QSB.AutomaticQuestNameCounter or 0) +1;
        _Data.Name = string.format("AutoNamed_Quest_%d", QSB.AutomaticQuestNameCounter);
    end

    if not Core:CheckQuestName(_Data.Name) then
        dbg("Quest '"..tostring(_Data.Name).."': invalid questname! Contains forbidden characters!");
        return;
    end

    local QuestData = API.InstanceTable(self.Data.QuestTemplate);
    QuestData.Identifier      = _Data.Name;
    QuestData.MSGKeyOverwrite = nil;
    QuestData.IconOverwrite   = nil;
    QuestData.Loop            = _Data.Loop;
    QuestData.Callback        = _Data.Callback;
    QuestData.SuggestionText  = (type(_Data.Suggestion) == "table" and _Data.Suggestion[lang]) or _Data.Suggestion;
    QuestData.SuccessText     = (type(_Data.Success) == "table" and _Data.Success[lang]) or _Data.Success;
    QuestData.FailureText     = (type(_Data.Failure) == "table" and _Data.Failure[lang]) or _Data.Failure;
    QuestData.Description     = (type(_Data.Description) == "table" and _Data.Description[lang]) or _Data.Description;
    QuestData.OpenMessage     = _Data.Visible == true or _Data.Suggestion ~= nil;
    QuestData.CloseMessage    = _Data.EndMessage == true or (_Data.Failure ~= nil or _Data.Success ~= nil);
    QuestData.Sender          = (_Data.Sender ~= nil and _Data.Sender) or 1;
    QuestData.Receiver        = (_Data.Receiver ~= nil and _Data.Receiver) or 1;
    QuestData.Time            = (_Data.Time ~= nil and _Data.Time) or 0;

    if _Data.Arguments then
        QuestData.Arguments = API.InstanceTable(_Data.Arguments);
    end

    table.insert(self.Data.GenerationList, QuestData);
    local ID = #self.Data.GenerationList;
    self:AttachBehavior(ID, _Data);
    return ID;
end

---
-- Fügt dem Quest mit der ID in der GenerationList seine Behavior hinzu.
--
-- <b>Achtung: </b>Diese Funktion wird vom Code aufgerufen!
--
-- @param _ID   Id des Quests
-- @param _Data Quest Data
-- @within Application Space
-- @local
--
function BundleQuestGeneration.Global:AttachBehavior(_ID, _Data)
    local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    for k,v in pairs(_Data) do
        if k ~= "Parameter" and type(v) == "table" and v.en and v.de then
            _Data[k] = v[lang];
        end
    end

    for k,v in pairs(_Data) do
        if tonumber(k) ~= nil then
            if type(v) ~= "table" then
                dbg(self.Data.GenerationList[_ID].Identifier..": Some behavior entries aren't behavior!");
            else
                if v.GetGoalTable then
                    table.insert(self.Data.GenerationList[_ID].Goals, v:GetGoalTable());

                    local Idx = #self.Data.GenerationList[_ID].Goals;
                    self.Data.GenerationList[_ID].Goals[Idx].Context            = v;
                    self.Data.GenerationList[_ID].Goals[Idx].FuncOverrideIcon   = self.Data.GenerationList[_ID].Goals[Idx].Context.GetIcon;
                    self.Data.GenerationList[_ID].Goals[Idx].FuncOverrideMsgKey = self.Data.GenerationList[_ID].Goals[Idx].Context.GetMsgKey;
                elseif v.GetReprisalTable then
                    table.insert(self.Data.GenerationList[_ID].Reprisals, v:GetReprisalTable());
                elseif v.GetRewardTable then
                    table.insert(self.Data.GenerationList[_ID].Rewards, v:GetRewardTable());
                elseif v.GetTriggerTable then
                    table.insert(self.Data.GenerationList[_ID].Triggers, v:GetTriggerTable());
                else
                    dbg(self.Data.GenerationList[_ID].Identifier..": Could not obtain behavior table!");
                end
            end
        end
    end
end

---
-- Startet alle Quests in der GenerationList.
--
-- @within Application Space
-- @local
--
function BundleQuestGeneration.Global:StartQuests()
    if not self:ValidateQuests() then
        return;
    end

    while (#self.Data.GenerationList > 0)
    do
        local QuestData = table.remove(self.Data.GenerationList, 1);
        if self:DebugQuest(QuestData) then
            local QuestID, Quest = QuestTemplate:New(
                QuestData.Identifier,
                QuestData.Sender,
                QuestData.Receiver,
                QuestData.Goals,
                QuestData.Triggers,
                assert(tonumber(QuestData.Time)),
                QuestData.Rewards,
                QuestData.Reprisals,
                QuestData.Callback,
                QuestData.Loop,
                QuestData.OpenMessage,
                QuestData.CloseMessage,
                QuestData.Description,
                QuestData.SuggestionText,
                QuestData.SuccessText,
                QuestData.FailureText
            );

            if QuestData.MSGKeyOverwrite then
                Quest.MsgTableOverride = self.MSGKeyOverwrite;
            end
            if QuestData.IconOverwrite then
                Quest.IconOverride = self.IconOverwrite;
            end
            if QuestData.Arguments then
                Quest.Arguments = API.InstanceTable(QuestData.Arguments);
            end
        end
    end
end

---
-- Validiert alle Quests in der GenerationList. Verschiedene Standardfehler
-- werden geprüft.
--
-- @within Application Space
-- @local
--
function BundleQuestGeneration.Global:ValidateQuests()
    for k, v in pairs(self.Data.GenerationList) do
        if #v.Goals == 0 then
            table.insert(self.Data.GenerationList[k].Goals, Goal_InstantSuccess());
        end
        if #v.Triggers == 0 then
            table.insert(self.Data.GenerationList[k].Triggers, Trigger_Time(0));
        end

        if #v.Goals == 0 and #v.Triggers == 0 then
            local text = string.format("Quest '" ..v.Identifier.. "' is missing a goal or a trigger!");
            return false;
        end

        local debugText = ""
        -- check if quest table is invalid
        if not v then
            debugText = debugText .. "quest table is invalid!"
        else
            -- check loop callback
            if v.Loop ~= nil and type(v.Loop) ~= "function" then
                debugText = debugText .. self.Identifier..": Loop must be a function!"
            end
            -- check callback
            if v.Callback ~= nil and type(v.Callback) ~= "function" then
                debugText = debugText .. self.Identifier..": Callback must be a function!"
            end
            -- check sender
            if (v.Sender == nil or (v.Sender < 1 or v.Sender > 8))then
                debugText = debugText .. v.Identifier..": Sender is nil or greater than 8 or lower than 1!"
            end
            -- check receiver
            if (v.Receiver == nil or (v.Receiver < 0 or v.Receiver > 8))then
                debugText = debugText .. self.Identifier..": Receiver is nil or greater than 8 or lower than 0!"
            end
            -- check time
            if (v.Time == nil or type(v.Time) ~= "number" or v.Time < 0)then
                debugText = debugText .. v.Identifier..": Time is nil or not a number or lower than 0!"
            end
            -- check visible
            if type(v.OpenMessage) ~= "boolean" then
                debugText = debugText .. v.Identifier..": Visible need to be a boolean!"
            end
            -- check end message
            if type(v.CloseMessage) ~= "boolean" then
                debugText = debugText .. v.Identifier..": EndMessage need to be a boolean!"
            end
            -- check description
            if (v.Description ~= nil and type(v.Description) ~= "string") then
                debugText = debugText .. v.Identifier..": Description is not a string!"
            end
            -- check proposal
            if (v.SuggestionText ~= nil and type(v.SuggestionText) ~= "string") then
                debugText = debugText .. v.Identifier..": Suggestion is not a string!"
            end
            -- check success
            if (v.SuccessText ~= nil and type(v.SuccessText) ~= "string") then
                debugText = debugText .. v.Identifier..": Success is not a string!"
            end
            -- check failure
            if (v.FailureText ~= nil and type(v.FailureText) ~= "string") then
                debugText = debugText .. v.Identifier..": Failure is not a string!"
            end
        end

        if debugText ~= "" then
            dbg(debugText);
            return false;
        end
    end
    return true;
end


---
-- Dummy-Funktion zur Validierung der Behavior eines Quests
--
-- Diese Funktion muss durch ein Debug Bundle überschrieben werden um Quests
-- in der Initalisiererliste zu testen.
--
-- @param _List Liste der Quests
-- @within Application Space
-- @local
--
function BundleQuestGeneration.Global:DebugQuest(_List)
    return true;
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Application Space
-- @local
--
function BundleQuestGeneration.Local:Install()

end

Core:RegisterBundle("BundleQuestGeneration");

