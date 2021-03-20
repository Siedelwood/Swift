-- Quests API-- ------------------------------------------------------------- --

---
-- Dieses Modul ermöglicht es einen Quest, bzw. Auftrag, per Skript zu 
-- erstellen.
--
-- Normaler Weise werden Aufträge im Questassistenten erzeugt. Dies ist aber
-- statisch und das Kopieren von Aufträgen ist nicht möglich. Wenn Aufträge
-- im Skript erzeugt werden, verschwinden alle diese Nachteile. Aufträge
-- können im Skript kopiert und angepasst werden. Es ist ebenfalls machbar,
-- die Aufträge in Sequenzen zu erzeugen.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_0_Core.api.html">Core</a></li>
-- <li><a href="Swift_1_TextCore.api.html">Core</a></li>
-- <li><a href="Swift_2_JobsRealtime.api.html">Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

QSB.GeneratedQuestDialogs = {};

---
-- Erstellt einen Quest.
--
-- Ein Auftrag braucht immer wenigstens ein Goal und einen Trigger um ihn
-- erstellen zu können. Hat ein Quest keinen Namen, erhält er automatisch
-- einen mit fortlaufender Nummerierung.
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
-- <li>Skip: Funktion, die beim überspringen aufgerufen wird</li>
-- </ul>
--
-- <p><b>Alias:</b> AddQuest</p>
--
-- @param[type=table] _Data Questdefinition
-- @return[type=string] Name des Quests
-- @return[type=number] Gesamtzahl Quests
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
        return;
    end
    if _Data.Name and Quests[GetQuestID(_Data.Name)] then
        error("API.CreateQuest: A quest named " ..tostring(_Data.Name).. " already exists!");
        return;
    end
    return ModuleQuestCore.Global:QuestCreateNewQuest(_Data);
end
AddQuest = API.CreateQuest;

---
-- Erzeugt eine Nachricht im Questfenster.
--
-- Der Quest wird immer nach Ablauf der Wartezeit nach
-- Abschluss des Ancestor Quest gestartet bzw. unmittelbar, wenn es keinen
-- Ancestor Quest gibt. Das Callback ist eine Funktion, die zur Anzeigezeit
-- des Quests ausgeführt wird.
--
-- Alle Paramater sind optional und können von rechts nach links weggelassen
-- oder mit nil aufgefüllt werden.
--
-- <b>Alias</b>: QuestMessage
--
-- @param[type=string]   _Text        Anzeigetext der Nachricht
-- @param[type=number]   _Sender      Sender der Nachricht
-- @param[type=number]   _Receiver    Receiver der Nachricht
-- @param[type=number]   _AncestorWt  Wartezeit
-- @param[type=function] _Callback    Callback
-- @param[type=string]   _Ancestor    Vorgänger-Quest
-- @return[type=string] QuestName
-- @within Anwenderfunktionen
--
-- @usage
-- API.CreateQuestMessage("Das ist ein Text", 4, 1);
--
function API.CreateQuestMessage(_Text, _Sender, _Receiver, _AncestorWt, _Callback, _Ancestor)
    if GUI then
        return;
    end
    if tonumber(_Sender) == nil or _Sender < 1 or _Sender > 8 then
        error("API.GetResourceOfProduct: _Sender is wrong!");
        return;
    end
    if tonumber(_Receiver) == nil or _Receiver < 1 or _Receiver > 8 then
        error("API.GetResourceOfProduct: _Receiver is wrong!");
        return;
    end
    return ModuleQuestCore.Global:QuestMessage(_Text, _Sender, _Receiver, _AncestorWt, _Callback, _Ancestor);
end
QuestMessage = API.CreateQuestMessage;

---
-- Erzeugt aus einer Table mit Daten eine Reihe von Nachrichten, die nach
-- einander angezeigt werden.
--
-- Dabei sind die eingestellten Wartezeiten in Echtzeit gemessen. Somit ist es
-- egal, wie hoch die Spielgeschwindigkeit ist. Die Dialoge warten alle
-- automatisch 12 Sekunden, wenn nichts anderes eingestellt wird.
--
-- Ein Dialog kann als Nachfolge auf einen Quest oder einen anderen Dialog
-- erzeugt werden, indem Ancestor gleich dem Questnamen gesetzt wird. Die
-- Wartezeit ist automatisch 0 Sekunden. Will man eine andere Wartezeit,
-- so muss Delay gesetzt werden.
--
-- Diese Funktion ist geeignet um längere Quest-Dialoge zu konfigurieren!
--
-- <b>Alias</b>: QuestDialog
--
-- Einzelne Parameter pro Eintrag:
-- <ul>
-- <li>Anzeigetext der Nachricht</li>
-- <li>PlayerID des Sender der Nachricht</li>
-- <li>PlayerID des Empfängers der Nachricht</li>
-- <li>Wartezeit zur vorangegangenen Nachricht</li>
-- <li>Action-Funktion der Nachricht</li>
-- </ul>
--
-- @param[type=table] _Messages Liste der anzuzeigenden Nachrichten
-- @return[type=string] Name des letzten Quest
-- @return[type=table] Namensliste der Quests
-- @within Anwenderfunktionen
--
-- @usage
-- API.CreateQuestDialog{
--     Name = "DialogName",
--     Ancestor = "SomeQuestName",
--     Delay = 12,
--
--     {"Hallo, wie geht es dir?", 4, 1, 8},
--     {"Mir geht es gut, wie immer!", 1, 1, 8, SomeCallbackFunction},
--     {"Das ist doch schön.", 4, 1, 8},
-- };
--
function API.CreateQuestDialog(_Messages)
    if GUI then
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
            _Messages[i][7] = _Messages.Name;
            _Messages[i][4] = _Messages[i-1][4];
        end
        QuestName = ModuleQuestCore.Global:QuestMessage(unpack(_Messages[i]));
        table.insert(GeneratedQuests, QuestName);
    end

    -- Benannte Dialoge für spätere Zugriffe speichern.
    if _Messages.Name then
        QSB.GeneratedQuestDialogs[_Messages.Name] = GeneratedQuests;
    end
    return GeneratedQuests[#GeneratedQuests], GeneratedQuests;
end
QuestDialog = API.CreateQuestDialog;

---
-- Unterbricht einen laufenden oder noch nicht gestarteten Quest-Dialog.
--
-- Die Funktion kann entweder anhand eines Dialognamen den Dialog zurücksetzen
-- oder direkt die Table der erzeugten Quests annehmen.
--
-- <b>Alias</b>: QuestDialogInterrupt
--
-- @param[type=string] _Dialog Dialog der abgebrochen wird
-- @within Anwenderfunktionen
--
function API.InterruptQuestDialog(_Dialog)
    if GUI then
        return;
    end

    local QuestDialog = _Dialog;
    if type(QuestDialog) == "string" then
        QuestDialog = QSB.GeneratedQuestDialogs[QuestDialog];
    end
    if QuestDialog == nil then
        error("API.InterruptQuestDialog: Dialog is invalid!");
        return;
    end
    for i= 1, #QuestDialog-1, 1 do
        API.StopQuest(QuestDialog[i], true);
    end
    API.WinQuest(QuestDialog[#QuestDialog], true);
end
QuestDialogInterrupt = API.InterruptQuestDialog;

---
-- Setzt einen Quest-Dialog zurück sodass er erneut gestartet werden kann.
--
-- Die Funktion kann entweder anhand eines Dialognamen den Dialog zurücksetzen
-- oder direkt die Table der erzeugten Quests annehmen.
--
-- <b>Alias</b>: QuestDialogRestart
--
-- @param[type=string] _Dialog Dialog der neu gestartet wird
-- @within Anwenderfunktionen
--
function API.RestartQuestDialog(_Dialog)
    if GUI then
        return;
    end

    local QuestDialog = _Dialog;
    if type(QuestDialog) == "string" then
        QuestDialog = QSB.GeneratedQuestDialogs[QuestDialog];
    end
    if QuestDialog == nil then
        error("API.ResetQuestDialog: Dialog is invalid!");
        return;
    end
    for i= 1, #QuestDialog, 1 do
        Quests[GetQuestID(QuestDialog[i])].Triggers[1][2][1].WaitTimeTimer = nil;
        API.RestartQuest(QuestDialog[i], true);
    end

    local CurrentQuest = Quests[GetQuestID(QuestDialog[1])];
    CurrentQuest:Trigger();
end
QuestDialogRestart = API.RestartQuestDialog;

