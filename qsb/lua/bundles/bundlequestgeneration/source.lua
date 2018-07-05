-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleQuestGeneration                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Bundle können Aufträge per Skript erstellt werden.
--
-- Normaler Weise werden Aufträge im Questassistenten erzeugt. Dies ist aber
-- statisch und das Kopieren von Aufträgen ist nicht möglich. Wenn Aufträge
-- im Skript erzeugt werden, verschwinden alle diese Nachteile. Aufträge
-- können im Skript kopiert und angepasst werden. Es ist ebenfalls machbar,
-- die Aufträge in Sequenzen zu erzeugen.
--
-- @within Modulbeschreibung
-- @set sort=false
--
BundleQuestGeneration = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erstellt einen Quest.
--
-- Ein Quest braucht immer wenigstens ein Goal und einen Trigger. Hat ein Quest
-- keinen Namen, erhält er automatisch einen mit fortlaufender Nummerierung.
--
-- Ein Quest besteht aus verschiedenen Eigenschaften und Behavior, die nicht
-- alle zwingend gesetzt werden müssen. Behavior werden einfach nach den
-- Eigenschaften nacheinander angegeben.
-- <p><u>Eigenschaften:</u></p>
-- <ul>
-- <li>Name: Der eindeutige Name des Quests</li>
-- <li>Sender: PlayerID des Auftraggeber (Default 1)</li>
-- <li>Receiver: PlayerID des Auftragnehmer (Default 1)</li>
-- <li>Suggestion: Vorschlagnachricht des Quests</li>
-- <li>Success: Erfolgsnachricht des Quest</li>
-- <li>Failure: Fehlschlagnachricht des Quest</li>
-- <li>Description: Aufgabenbeschreibung (Nur bei Custom)</li>
-- <li>Time: Zeit bis zu, Fehlschlag/Abschluss</li>
-- <li>Loop: Funktion, die während der Laufzeit des Quests aufgerufen wird</li>
-- <li>Callback: Funktion, die nach Abschluss aufgerufen wird</li>
-- </ul>
--
-- <p><b>Alias:</b> AddQuest</p>
--
-- @param _Data [table] Questdefinition
-- @return [string] Name des Quests
-- @return [number] Gesamtzahl Quests
-- @within Anwenderfunktionen
--
-- @usage
-- AddQuest {
--     Name        = "ExampleQuest",
--     Suggestion  = "Wir müssen das Kloster finden.",
--     Success     = "Dies sind die berümten Heilermönche.",
--
--     Goal_DiscoverPlayer(4),
--     Reward_Diplomacy(1, 4, "EstablishedContact"),
--     Trigger_Time(0),
-- }
--
function API.AddQuest(_Data)
    if GUI then
        API.Log("API.AddQuest: Could not execute in local script!");
        return;
    end
    return BundleQuestGeneration.Global:NewQuest(_Data);
end
AddQuest = API.AddQuest;

---
-- DO NOT USE THIS FUNCTION!
-- @within Deprecated
-- @local
--
function API.StartQuests()
    if GUI then
        API.Brudge("API.StartQuests()");
        return;
    end
    return BundleQuestGeneration.Global:StartQuests();
end
StartQuests = API.StartQuests;

---
-- Erzeugt eine Nachricht im Questfenster.
--
-- Der erzeugte Quest wird immer fehlschlagen. Der angezeigte Test ist die
-- Failure Message. Der Quest wird immer nach Ablauf der Wartezeit nach
-- Abschluss des Ancestor Quest gestartet bzw. unmittelbar, wenn es keinen
-- Ancestor Quest gibt. Das Callback ist eine Funktion, die zur Anzeigezeit
-- des Quests ausgeführt wird.
--
-- Alle Paramater sind optional und können von rechts nach links weggelassen
-- oder mit nil aufgefüllt werden.
--
-- <b>Alias</b>: QuestMessage
--
-- @param _Text       [string] Anzeigetext der Nachricht
-- @param _Sender     [number] Sender der Nachricht
-- @param _Receiver   [number] Receiver der Nachricht
-- @param _Ancestor   [string] Vorgänger-Quest
-- @param _AncestorWt [number] Wartezeit
-- @param _Callback   [function] Callback
-- @return [number] QuestID
-- @return [table] Quest
-- @within Anwenderfunktionen
--
-- @usage
-- API.QuestMessage("Das ist ein Text", 4, 1);
--
function API.QuestMessage(_Text, _Sender, _Receiver, _Ancestor, _AncestorWt, _Callback)
    if GUI then
        API.Log("API.QuestMessage: Could not execute in local script!");
        return;
    end
    return BundleQuestGeneration.Global:QuestMessage(_Text, _Sender, _Receiver, _Ancestor, _AncestorWt, _Callback);
end
QuestMessage = API.QuestMessage;

---
-- Erzeugt aus einer Table mit Daten eine Reihe von Nachrichten, die nach
-- einander angezeigt werden.
--
-- Der Vorgänger-Quest und die Wartezeit müssen nur beim ersten Eintrag
-- angegeben werden. Ab dem zweiten Eintrag werden sie ermittelt, sollten
-- sie nicht angegeben sein. Es können Einträge von rechts nach links
-- weggelassen werden.
--
-- Diese Funktion ist geeignet um Dialoge zu konfigurieren!
--
-- <b>Alias</b>: QuestDialog
--
-- Einzelne Einträge pro Quest:
-- <ul>
-- <li>Anzeigetext der Nachricht</li>
-- <li>PlayerID des Sender der Nachricht</li>
-- <li>PlayerID des Empfängers der Nachricht</li>
-- <li>Name des vorangegangenen Quest</li>
-- <li>Wartezeit bis zum Start</li>
-- </ul>
--
-- @param _Messages [table] Liste der anzuzeigenden Nachrichten
-- @return [table] List of generated Quests
-- @within Anwenderfunktionen
--
-- @usage
-- API.QuestDialog{
--     {"Hallo, wie geht es dir?", 1, 4},
--     {"Mir geht es gut, wie immer!", 1, 1},
--     {"Das ist doch schön.", 1, 4},
-- };
--
function API.QuestDialog(_Messages)
    if GUI then
        API.Log("API.QuestDialog: Could not execute in local script!");
        return;
    end

    local QuestID, Quest
    local GeneratedQuests = {};
    for i= 1, #_Messages, 1 do
        if i > 1 then
            _Messages[i][4] = _Messages[i][4] or Quest.Identifier;
            _Messages[i][5] = _Messages[i][5] or 12;
        end
        QuestID, Quest = API.QuestMessage(unpack(_Messages[i]));
        table.insert(GeneratedQuests, {QuestID, Quest});
    end
    return GeneratedQuests;
end
QuestDialog = API.QuestDialog;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleQuestGeneration = {
    Global = {
        Data = {
            GenerationList = {},
            QuestMessageID = 0,
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
-- @within Internal
-- @local
--
function BundleQuestGeneration.Global:Install()

end

---
-- Erzeugt eine Nachricht im Questfenster.
--
-- Der erzeugte Quest wird immer fehlschlagen. Der angezeigte Test ist die
-- Failure Message. Der Quest wird immer nach Ablauf der Wartezeit nach
-- Abschluss des Ancestor Quest gestartet bzw. unmittelbar, wenn es keinen
-- Ancestor Quest gibt. Das Callback ist eine Funktion, die zur Anzeigezeit
-- des Quests ausgeführt wird.
--
-- Alle Paramater sind optional und können von rechts nach links weggelassen
-- oder mit nil aufgefüllt werden.
--
-- @param _Text       [string] Anzeigetext der Nachricht
-- @param _Sender     [number] Sender der Nachricht
-- @param _Receiver   [number] Receiver der Nachricht
-- @param _Ancestor   [string] Vorgänger-Quest
-- @param _AncestorWt [number] Wartezeit
-- @param _Callback   [function] Callback
-- @return [number] QuestID
-- @return [table] Quest
--
-- @within Internal
-- @local
--
function BundleQuestGeneration.Global:QuestMessage(_Text, _Sender, _Receiver, _Ancestor, _AncestorWt, _Callback)
    self.Data.QuestMessageID = self.Data.QuestMessageID +1;

    -- Trigger-Nachbau
    local OnQuestOver = {
        Triggers.Custom2,{{QuestName = _Ancestor}, function(_Data)
            if not _Data.QuestName then
                return true;
            end
            local QuestID = GetQuestID(_Data.QuestName);
            if (Quests[QuestID].State == QuestState.Over and Quests[QuestID].Result ~= QuestResult.Interrupted) then
                return true;
            end
            return false;
        end}
    }

    -- Lokalisierung
    local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    if type(_Text) == "table" then
        _Text = _Text[Language];
    end
    assert(type(_Text) == "string");

    return QuestTemplate:New(
        "QSB_QuestMessage_" ..self.Data.QuestMessageID,
        (_Sender or 1),
        (_Receiver or 1),
        {{ Objective.NoChange,}},
        { OnQuestOver },
        (_AncestorWt or 1),
        nil, nil, _Callback, nil, false, (_Text ~= nil), nil, nil,
        _Text, nil
    );
end

---
-- Erzeugt einen Quest und trägt ihn in die GenerationList ein.
--
-- @param _Data [table] Daten des Quest.
-- @return [string] Name des erzeugten Quests
-- @return [number] Gesamtanzahl Quests
-- @within Internal
-- @local
--
function BundleQuestGeneration.Global:NewQuest(_Data)
    local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
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
    self:StartQuests();
    return _Data.Name, Quests[0];
end

---
-- Fügt dem Quest mit der ID in der GenerationList seine Behavior hinzu.
--
-- <b>Achtung: </b>Diese Funktion wird vom Code aufgerufen!
--
-- @param _ID   [number] Id des Quests
-- @param _Data [table] Quest Data
-- @within Internal
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
-- DO NOT USE THIS FUNCTION!--
-- @within Deprecated
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

            -- Quest wurde erzeugt
            Quests[QuestID].IsGenerated = true;
        end
    end
end

---
-- Validiert alle Quests in der GenerationList. Verschiedene Standardfehler
-- werden geprüft.
--
-- @within Internal
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
-- @param _List [table] Liste der Quests
-- @within Internal
-- @local
--
function BundleQuestGeneration.Global:DebugQuest(_List)
    return true;
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleQuestGeneration.Local:Install()

end

Core:RegisterBundle("BundleQuestGeneration");
