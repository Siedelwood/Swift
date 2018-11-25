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
-- <p><a href="#API.CreateQuest">Quests erzeugen</a></p>
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
function API.CreateQuest(_Data)
    if GUI then
        API.Log("API.CreateQuest: Could not execute in local script!");
        return;
    end
    return BundleQuestGeneration.Global:QuestCreateNewQuest(_Data);
end
AddQuest = API.CreateQuest;

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
-- @param _AncestorWt [number] Wartezeit
-- @param _Callback   [function] Callback
-- @param _Ancestor   [string] Vorgänger-Quest
-- @return [string] QuestName
-- @within Anwenderfunktionen
--
-- @usage
-- API.CreateQuestMessage("Das ist ein Text", 4, 1);
--
function API.CreateQuestMessage(_Text, _Sender, _Receiver, _AncestorWt, _Callback, _Ancestor)
    if GUI then
        API.Log("API.CreateQuestMessage: Could not execute in local script!");
        return;
    end
    return BundleQuestGeneration.Global:QuestMessage(_Text, _Sender, _Receiver, _AncestorWt, _Callback, _Ancestor);
end
QuestMessage = API.CreateQuestMessage;

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
-- @return [string] Name des letzten Quest
-- @return [table] Namensliste der Quests
-- @within Anwenderfunktionen
--
-- @usage
-- API.CreateQuestDialog{
--     Ancestor = "SomeQuestName",
--     Delay = 12,
--
--     {"Hallo, wie geht es dir?", 4, 1},
--     {"Mir geht es gut, wie immer!", 1, 1},
--     {"Das ist doch schön.", 4, 1},
-- };
--
function API.CreateQuestDialog(_Messages)
    if GUI then
        API.Log("API.CreateQuestDialog: Could not execute in local script!");
        return;
    end

    table.insert(_Messages, {"KEY(NO_MESSAGE)", 1, 1});

    local QuestName;
    local GeneratedQuests = {};
    for i= 1, #_Messages, 1 do
        _Messages[i][4] = _Messages[i][4] or 12;
        if i > 1 then
            _Messages[i][6] = _Messages[i][6] or QuestName;
        else
            _Messages[i][6] = _Messages[i][6] or _Messages.Ancestor;
            _Messages[i][4] = _Messages.Delay or 0;
        end
        if i == #_Messages and #_Messages[i-1] then
            _Messages[i][4] = _Messages[i-1][4];
        end
        QuestName = BundleQuestGeneration.Global:QuestMessage(unpack(_Messages[i]));
        table.insert(GeneratedQuests, QuestName);
    end
    return GeneratedQuests[#GeneratedQuests], GeneratedQuests;
end
QuestDialog = API.CreateQuestDialog;

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
-- @param _AncestorWt [number] Wartezeit
-- @param _Callback   [function] Callback
-- @param _Ancestor   [string] Vorgänger-Quest
-- @return [string] QuestName
--
-- @within Internal
-- @local
--
function BundleQuestGeneration.Global:QuestMessage(_Text, _Sender, _Receiver, _AncestorWt, _Callback, _Ancestor)
    self.Data.QuestMessageID = self.Data.QuestMessageID +1;

    -- Trigger-Nachbau
    local OnQuestOver = {
        Triggers.Custom2, {
            {QuestName = _Ancestor, WaitTime = _AncestorWt or 1,},
                function(_Data)
                local QuestID = GetQuestID(_Data.QuestName);
                if not _Data.QuestName then
                    return true;
                end
                if (Quests[QuestID] and Quests[QuestID].State == QuestState.Over and Quests[QuestID].Result ~= QuestResult.Interrupted) then
                    _Data.WaitTimeTimer = _Data.WaitTimeTimer or API.RealTimeGetSecondsPassedSinceGameStart();
                    if API.RealTimeGetSecondsPassedSinceGameStart() >= _Data.WaitTimeTimer + _Data.WaitTime then
                        return true;
                    end
                end
                return false;
            end
        }
    };

    -- Lokalisierung
    local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    if type(_Text) == "table" then
        _Text = _Text[Language];
    end

    -- Quest erzeugen
    local _, CreatedQuest = QuestTemplate:New(
        "QSB_QuestMessage_" ..self.Data.QuestMessageID,
        (_Sender or 1),
        (_Receiver or 1),
        { {Objective.Dummy} },
        { OnQuestOver },
        0, nil, nil, _Callback, nil, false, (_Text ~= nil), nil, nil, _Text, nil
    );
    return CreatedQuest.Identifier;
end

---
-- Erzeugt einen Quest.
--
-- @param _Data [table] Daten des Quest.
-- @return [string] Name des erzeugten Quests
-- @within Internal
-- @local
--
function BundleQuestGeneration.Global:QuestCreateNewQuest(_Data)
    if not _Data.Name then
        QSB.AutomaticQuestNameCounter = (QSB.AutomaticQuestNameCounter or 0) +1;
        _Data.Name = string.format("AutoNamed_Quest_%d", QSB.AutomaticQuestNameCounter);
    end
    if not Core:CheckQuestName(_Data.Name) then
        dbg("Quest '"..tostring(_Data.Name).."': invalid questname! Contains forbidden characters!");
        return;
    end

    local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";

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
        (type(_Data.Description) == "table" and _Data.Description[lang]) or _Data.Description,
        (type(_Data.Suggestion) == "table" and _Data.Suggestion[lang]) or _Data.Suggestion,
        (type(_Data.Success) == "table" and _Data.Success[lang]) or _Data.Success,
        (type(_Data.Failure) == "table" and _Data.Failure[lang]) or _Data.Failure
    };

    -- Daten validieren
    if not self:QuestValidateQuestData(QuestData) then
        API.Dbg("AddQuest: Error while creating quest. Table has been copied to log.");
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

    -- Quest erzeugen
    local QuestID, Quest = QuestTemplate:New(unpack(QuestData, 1, 16));
    Quest.MsgTableOverride = _Data.MSGKeyOverwrite;
    Quest.IconOverride = _Data.IconOverwrite;
    Quest.Arguments = (_Data.Arguments ~= nil and API.InstanceTable(_Data.Arguments)) or {};
    return _Data.Name;
end

---
-- Validiert die Felder eines Quests.
--
-- @param _Data [table] Daten des Quest.
-- @return [boolean] Quest OK
-- @within Internal
-- @local
--
function BundleQuestGeneration.Global:QuestValidateQuestData(_Data)
    return (
        (type(_Data[1]) == "string" and self:QuestValidateQuestName(_Data[1])) and
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

---
-- Validiert den Namen eines Quests.
--
-- @param _Name [string] Name des Quest.
-- @return [boolean] Name OK
-- @within Internal
-- @local
--
function BundleQuestGeneration.Global:QuestValidateQuestName(_Name)
    return string.find(_Name, "^[A-Za-z0-9_]+$") ~= nil;
end

Core:RegisterBundle("BundleQuestGeneration");
