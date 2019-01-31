-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia Core                                                         # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

--
-- (Alte Beschreibung, die niemand wollte)
--
-- Die Hauptaufgabe des Framework ist es, Funktionen zur Installation und der
-- Verwaltung der einzelnen Bundles bereitzustellen. Bundles sind in sich
-- geschlossene Module, die wenig bis gar keine Abhänigkeiten haben. Damit
-- das funktioniert, muss das Framework auch allgemeingültige Funktionen
-- bereitstellen, auf die Bundles aufbauen können.
--
-- Im Framework werden zudem überschriebene Spielfunktionen angelegt und so
-- aufbereitet, dass Bundles ihre Inhalte einfach ergänzen können. Dies wird
-- jedoch nicht für alle Funktionen des Spiels möglich sein.
--
-- Wie die einzelnen Bundles ist auch das Framework in einen Public und einen
-- Private Space aufgeteilt. Der Public Space enthält Funktionen innerhalb
-- der Bibliothek "API". Alle Bundles ergänzen ihre Public-Funktionen dort.
-- Außer den Aliases auf API-Funktionen, den Behavior-Funktionen und evtl.
-- Klassen von Objekten sind keine anderen Funktionen für den Anwendern
-- sichtbar zu machen!
-- Sinn des Public Space ist es, Funktionsaufrufe, die zum Teil nur in einer
-- Skriptumgebung bekannt sind, zu verallgemeinern. Wird die Funktion nun aus
-- der falschen Umgebung aufgerufen, wird der Aufruf an die richtige Umgebung
-- weitergereicht oder, falls dies nicht möglich ist, abgebrochen. Dies soll
-- Fehler vermeiden.
--
-- Im Private Space liegen die privaten Funktionen und Variablen, die
-- nicht in der Dokumentation erscheinen. Sie sind mit einem Local-Tag zu
-- versehen! Der Nutzer soll diese Funktionen in der Regel nicht anfassen,
-- daher muss er auch nicht wissen, dass es sie gibt!
--
-- Ziel der Teilung zwischen Public Space und Private Space ist es, dem
-- Anwender eine saubere und leicht verständliche Oberfläche zu Bieten, mit
-- der er einfach arbeiten kann. Kenntnis über die komplexen Prozesse hinter
-- den Kulissen sind dafür nicht notwendig.
--

---
-- Hier werden wichtige Basisfunktionen bereitgestellt. Diese Funktionen sind
-- auch in der Minimalkonfiguration der QSB vorhanden und essentiell für alle
-- anderen Bundles.
--
-- @set sort=true
--

API = API or {};
QSB = QSB or {};
QSB.Version = "RE 2.0.0 1/1/2020 (Early Prototype)";

QSB.RealTime_SecondsSinceGameStart = 0;

ParameterType = ParameterType or {};
g_QuestBehaviorVersion = 1;
g_QuestBehaviorTypes = {};

---
-- AddOn Versionsnummer
-- @local
--
g_GameExtraNo = 0;
if Framework then
    g_GameExtraNo = Framework.GetGameExtraNo();
elseif MapEditor then
    g_GameExtraNo = MapEditor.GetGameExtraNo();
end

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Initialisiert alle verfügbaren Bundles und führt ihre Install-Methode aus.
--
-- Bundles werden immer getrennt im globalen und im lokalen Skript gestartet.
-- Diese Funktion muss zwingend im globalen und lokalen Skript ausgeführt
-- werden, bevor die QSB verwendet werden kann.
--
-- @within Anwenderfunktionen
--
function API.Install()
    Core:InitalizeBundles();
end

-- Tables --------------------------------------------------------------------

---
-- Kopiert eine komplette Table und gibt die Kopie zurück. Tables können
-- nicht durch Zuweisungen kopiert werden. Verwende diese Funktion. Wenn ein
-- Ziel angegeben wird, ist die zurückgegebene Table eine Vereinigung der 2
-- angegebenen Tables.
-- Die Funktion arbeitet rekursiv.
--
-- <p><b>Alias:</b> CopyTableRecursive</p>
--
-- @param[type=table] _Source Quelltabelle
-- @param[type=table] _Dest   (optional) Zieltabelle
-- @return[type=table] Kopie der Tabelle
-- @within Anwenderfunktionen
-- @usage Table = {1, 2, 3, {a = true}}
-- Copy = API.InstanceTable(Table)
--
function API.InstanceTable(_Source, _Dest)
    return copy(_Source, _Dest);
end
CopyTableRecursive = API.InstanceTable;

---
-- Sucht in einer eindimensionalen Table nach einem Wert. Das erste Auftreten
-- des Suchwerts wird als Erfolg gewertet.
--
-- Es können praktisch alle Lua-Werte gesucht werden, obwohl dies nur für
-- Strings und Numbers wirklich sinnvoll ist.
--
-- <p><b>Alias:</b> Inside</p>
--
-- @param             _Data Datum, das gesucht wird
-- @param[type=table] _Table Tabelle, die durchquert wird
-- @return[type=booelan] Wert gefunden
-- @within Anwenderfunktionen
-- @usage Table = {1, 2, 3, {a = true}}
-- local Found = API.TraverseTable(3, Table)
--
function API.TraverseTable(_Data, _Table)
    for k,v in pairs(_Table) do
        if v == _Data then
            return true;
        end
    end
    return false;
end
Inside = API.TraverseTable;

---
-- Schreibt ein genaues Abbild der Table ins Log. Funktionen, Threads und
-- Metatables werden als Adresse geschrieben.
--
-- @param[type=table]  _Table Tabelle, die gedumpt wird
-- @param[type=string] _Name Optionaler Name im Log
-- @within Anwenderfunktionen
-- @local
-- @usage Table = {1, 2, 3, {a = true}}
-- API.DumpTable(Table)
--
function API.DumpTable(_Table, _Name)
    local Start = "{";
    if _Name then
        Start = _Name.. " = \n" ..Start;
    end
    Framework.WriteToLog(Start);

    for k, v in pairs(_Table) do
        if type(v) == "table" then
            Framework.WriteToLog("[" ..k.. "] = ");
            API.DumpTable(v);
        elseif type(v) == "string" then
            Framework.WriteToLog("[" ..k.. "] = \"" ..v.. "\"");
        else
            Framework.WriteToLog("[" ..k.. "] = " ..tostring(v));
        end
    end
    Framework.WriteToLog("}");
end

---
-- Konvertiert alle Strings, Booleans und Numbers einer Tabelle in
-- einen String. Die Funktion ist rekursiv, d.h. es werden auch alle
-- Untertabellen mit konvertiert. Alles was kein Number, Boolean oder
-- String ist, wird als Adresse geschrieben.
--
-- @param[type=table] _Table Table zum konvertieren
-- @return[type=string] Converted table
-- @within Anwenderfunktionen
-- @local
--
function API.ConvertTableToString(_Table)
    assert(type(_Table) == "table");
    local TableString = "{";
    for k, v in pairs(_Table) do
        local key;
        if (tonumber(k)) then
            key = ""..k;
        else
            key = "\""..k.."\"";
        end

        if type(v) == "table" then
            TableString = TableString .. "[" .. key .. "] = " .. API.ConvertTableToString(v) .. ", ";
        elseif type(v) == "number" then
            TableString = TableString .. "[" .. key .. "] = " .. v .. ", ";
        elseif type(v) == "string" then
            TableString = TableString .. "[" .. key .. "] = \"" .. v .. "\", ";
        elseif type(v) == "boolean" or type(v) == "nil" then
            TableString = TableString .. "[" .. key .. "] = \"" .. tostring(v) .. "\", ";
        else
            TableString = TableString .. "[" .. key .. "] = \"" .. tostring(v) .. "\", ";
        end
    end
    TableString = TableString .. "}";
    return TableString
end

-- Quests ----------------------------------------------------------------------

---
-- Gibt die ID des Quests mit dem angegebenen Namen zurück. Existiert der
-- Quest nicht, wird nil zurückgegeben.
--
-- <p><b>Alias:</b> GetQuestID</p>
--
-- @param[type=string] _Name Name des Quest
-- @return[type=number] ID des Quest
-- @within Anwenderfunktionen
--
function API.GetQuestID(_Name)
    if type(_Name) == "number" then
        return _Name;
    end
    for k, v in pairs(Quests) do
        if v and k > 0 then
            if v.Identifier == _Name then
                return k;
            end
        end
    end
end
GetQuestID = API.GetQuestID;

---
-- Prüft, ob zu der angegebenen ID ein Quest existiert. Wird ein Questname
-- angegeben wird dessen Quest-ID ermittelt und geprüft.
--
-- <p><b>Alias:</b> IsValidQuest</p>
--
-- @param[type=number] _QuestID ID oder Name des Quest
-- @return[type=boolean] Quest existiert
-- @within Anwenderfunktionen
--
function API.IsValidateQuest(_QuestID)
    return Quests[_QuestID] ~= nil or Quests[API.GetQuestID(_QuestID)] ~= nil;
end
IsValidQuest = API.IsValidateQuest;

---
-- Lässt eine Liste von Quests fehlschlagen.
--
-- Der Status wird auf Over und das Resultat auf Failure gesetzt.
--
-- <p><b>Alias:</b> FailQuestsByName</p>
--
-- @param[type=string] ... Liste mit Quests
-- @within Anwenderfunktionen
-- @local
--
function API.FailAllQuests(...)
    for i=1, #arg, 1 do
        API.FailQuest(arg[i]);
    end
end
FailQuestsByName = API.FailAllQuests;

---
-- Lässt den Quest fehlschlagen.
--
-- Der Status wird auf Over und das Resultat auf Failure gesetzt.
--
-- <p><b>Alias:</b> FailQuestByName</p>
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _Quiet Keine Meldung anzeigen
-- @within Anwenderfunktionen
--
function API.FailQuest(_QuestName, _Quiet)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if not _Quiet then
            API.Info("fail quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Fail();
    end
end
FailQuestByName = API.FailQuest;

---
-- Startet eine Liste von Quests neu.
--
-- <p><b>Alias:</b> StartQuestsByName</p>
--
-- @param[type=string] ... Liste mit Quests
-- @within Anwenderfunktionen
-- @local
--
function API.RestartAllQuests(...)
    for i=1, #arg, 1 do
        API.RestartQuest(arg[i]);
    end
end
RestartQuestsByName = API.RestartAllQuests;

---
-- Startet den Quest neu.
--
-- Der Quest muss beendet sein um ihn wieder neu zu starten. Wird ein Quest
-- neu gestartet, müssen auch alle Trigger wieder neu ausgelöst werden, außer
-- der Quest wird manuell getriggert.
--
-- Alle Änderungen an Standardbehavior müssen hier berücksichtigt werden. Wird
-- ein Standardbehavior in einem Bundle verändern, muss auch diese Funktion
-- angepasst oder überschrieben werden.
--
-- <p><b>Alias:</b> RestartQuestByName</p>
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _Quiet Keine Meldung anzeigen
-- @within Anwenderfunktionen
--
function API.RestartQuest(_QuestName, _Quiet)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _Quiet then
            API.Info("restart quest " .._QuestName);
        end

        if Quest.Objectives then
            local questObjectives = Quest.Objectives;
            for i = 1, questObjectives[0] do
                local objective = questObjectives[i];
                objective.Completed = nil
                local objectiveType = objective.Type;
                if objectiveType == Objective.Deliver then
                    local data = objective.Data;
                    data[3] = nil
                    data[4] = nil
                    data[5] = nil
                elseif g_GameExtraNo and g_GameExtraNo >= 1 and objectiveType == Objective.Refill then
                    objective.Data[2] = nil
                elseif objectiveType == Objective.Protect or objectiveType == Objective.Object then
                    local data = objective.Data;
                    for j=1, data[0], 1 do
                        data[-j] = nil
                    end
                elseif objectiveType == Objective.DestroyEntities and objective.Data[1] ~= 1 and objective.DestroyTypeAmount then
                    objective.Data[3] = objective.DestroyTypeAmount;

                elseif objectiveType == Objective.Distance then
                    if objective.Data[1] == -65565 then
                        objective.Data[4].NpcInstance = nil;
                    end

                elseif objectiveType == Objective.Custom2 and objective.Data[1].Reset then
                    objective.Data[1]:Reset(Quest, i)
                end
            end
        end
        local function resetCustom(_type, _customType)
            local Quest = Quest;
            local behaviors = Quest[_type];
            if behaviors then
                for i = 1, behaviors[0] do
                    local behavior = behaviors[i];
                    if behavior.Type == _customType then
                        local behaviorDef = behavior.Data[1];
                        if behaviorDef and behaviorDef.Reset then
                            behaviorDef:Reset(Quest, i);
                        end
                    end
                end
            end
        end

        resetCustom("Triggers", Triggers.Custom2);
        resetCustom("Rewards", Reward.Custom);
        resetCustom("Reprisals", Reprisal.Custom);

        Quest.Result = nil
        local OldQuestState = Quest.State
        Quest.State = QuestState.NotTriggered
        Logic.ExecuteInLuaLocalState("LocalScriptCallback_OnQuestStatusChanged("..Quest.Index..")")
        if OldQuestState == QuestState.Over then
            Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", QuestTemplate.Loop, 1, 0, { Quest.QueueID })
        end
        return QuestID, Quest;
    end
end
RestartQuestByName = API.RestartQuest;

---
-- Startet eine Liste von Quests.
--
-- <p><b>Alias:</b> StartQuestsByName</p>
--
-- @param[type=string] ... Liste mit Quests
-- @within Anwenderfunktionen
-- @local
--
function API.StartAllQuests(...)
    for i=1, #arg, 1 do
        API.StartQuest(arg[i]);
    end
end
StartQuestsByName = API.StartAllQuests;

---
-- Startet den Quest sofort, sofern er existiert.
--
-- Dabei ist es unerheblich, ob die Bedingungen zum Start erfüllt sind.
--
-- <p><b>Alias:</b> StartQuestByName</p>
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _Quiet Keine Meldung anzeigen
-- @within Anwenderfunktionen
--
function API.StartQuest(_QuestName, _Quiet)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if not _Quiet then
            API.Info("start quest " .._QuestName);
        end
        Quest:SetMsgKeyOverride();
        Quest:SetIconOverride();
        Quest:Trigger();
    end
end
StartQuestByName = API.StartQuest;

---
-- Unterbricht eine Liste von Quests.
--
-- <p><b>Alias:</b> StopQuestsByName</p>
--
-- @param[type=string] ... Liste mit Quests
-- @within Anwenderfunktionen
-- @local
--
function API.StopAllQuests(...)
    for i=1, #arg, 1 do
        API.StopQuest(arg[i]);
    end
end
StopQuestsByName = API.StopAllQuests;

---
-- Unterbricht den Quest.
--
-- Der Status wird auf Over und das Resultat auf Interrupt gesetzt. Sind Marker
-- gesetzt, werden diese entfernt.
--
-- <p><b>Alias:</b> StopQuestByName</p>
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _Quiet Keine Meldung anzeigen
-- @within Anwenderfunktionen
--
function API.StopQuest(_QuestName, _Quiet)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if not _Quiet then
            API.Info("interrupt quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Interrupt(-1);
    end
end
StopQuestByName = API.StopQuest;

---
-- Gewinnt eine Liste von Quests.
--
-- Der Status wird auf Over und das Resultat auf Success gesetzt.
--
-- <p><b>Alias:</b> WinQuestsByName</p>
--
-- @param[type=string] ... Liste mit Quests
-- @within Anwenderfunktionen
-- @local
--
function API.WinAllQuests(...)
    for i=1, #arg, 1 do
        API.WinQuest(arg[i]);
    end
end
WinQuestsByName = API.WinAllQuests;

---
-- Gewinnt den Quest.
--
-- Der Status wird auf Over und das Resultat auf Success gesetzt.
--
-- <p><b>Alias:</b> WinQuestByName</p>
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _Quiet Keine Meldung anzeigen
-- @within Anwenderfunktionen
--
function API.WinQuest(_QuestName, _Quiet)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if not _Quiet then
            API.Info("win quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Success();
    end
end
WinQuestByName = API.WinQuest;

-- Messages --------------------------------------------------------------------

---
-- Schreibt eine Nachricht in das Debug Window. Der Text erscheint links am
-- Bildschirm und ist nicht statisch.
--
-- <p><b>Alias:</b> GUI_Note</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
-- @local
--
function API.Note(_Message)
    _Message = API.EnsureMessage(_Message);
    local MessageFunc = Logic.DEBUG_AddNote;
    if GUI then
        MessageFunc = GUI.AddNote;
    end
    MessageFunc(_Message);
end
GUI_Note = API.Note;

---
-- Schreibt eine Nachricht in das Debug Window. Der Text erscheint links am
-- Bildschirm und verbleibt dauerhaft am Bildschirm.
--
-- <p><b>Alias:</b> GUI_StaticNote</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
--
function API.StaticNote(_Message)
    _Message = API.EnsureMessage(_Message);
    if not GUI then
        Logic.ExecuteInLuaLocalState('GUI.AddStaticNote("' .._Message.. '")');
        return;
    end
    GUI.AddStaticNote(_Message);
end
GUI_StaticNote = API.StaticNote;

---
-- Löscht alle Nachrichten im Debug Window.
--
-- @within Anwenderfunktionen
--
function API.ClearNotes()
    if not GUI then
        Logic.ExecuteInLuaLocalState('GUI.ClearNotes()');
        return;
    end
    GUI.ClearNotes();
end

---
-- Schreibt eine einzelne Zeile Text ins Log. Vor dem Text steht, ob aus dem
-- globalen oder lokalen Skript geschrieben wurde und bei welchem Turn des
-- Spiels die Nachricht gesendet wurde.
--
-- @param[type=string] _Message Text des Log-Eintrag
-- @within Anwenderfunktionen
-- @local
--
function API.Log(_Message)
    local Env  = (GUI and "Local") or "Global";
    local Turn = Logic.GetTimeMs();
    Framework.WriteToLog(Env.. ":" ..Turn.. ": " .._Message);
end

---
-- Schreibt eine Nachricht in das Nachrichtenfenster unten in der Mitte.
--
-- <p><b>Alias:</b> GUI_NoteDown</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
--
function API.Message(_Message)
    _Message = API.EnsureMessage(_Message);
    if not GUI then
        Logic.ExecuteInLuaLocalState('Message("' .._Message.. '")');
        return;
    end
    Message(_Message);
end
GUI_NoteDown = API.Message;

---
-- Ermittelt automatisch den Nachrichtentext, falls eine lokalisierte Table
-- übergeben wird.
--
-- @param[type=string] _Message Anzeigetext
-- @return[type=string] Message
-- @within Anwenderfunktionen
-- @local
--
function API.EnsureMessage(_Message)
    local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    if type(_Message) == "table" then
        _Message = _Message[Language];
    end
    return tostring(_Message);
end

---
-- Schreibt einen FATAL auf den Bildschirm und ins Log.
--
-- <p><b>Alias:</b> fatal</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
-- @local
--
function API.Fatal(_Message)
    if QSB.Log.CurrentLevel <= QSB.Log.Level.FATAL then
        API.StaticNote("FATAL: " .._Message)
    end
    API.Log("FATAL: " .._Message);
end
API.Dbg = API.Fatal;
fatal = API.Fatal;
dbg = API.Fatal;

---
-- Schreibt eine WARNING auf den Bildschirm und ins Log.
--
-- <p><p><b>Alias:</b> warn</p></p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
-- @local
--
function API.Warn(_Message)
    if QSB.Log.CurrentLevel <= QSB.Log.Level.WARNING then
        API.StaticNote("WARNING: " .._Message)
    end
    API.Log("WARNING: " .._Message);
end
warn = API.Warn;

---
-- Schreibt eine INFO auf den Bildschirm und ins Log.
--
-- <p><b>Alias:</b> info</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
-- @local
--
function API.Info(_Message)
    if QSB.Log.CurrentLevel <= QSB.Log.Level.INFO then
        API.Note("INFO: " .._Message)
    end
    API.Log("INFO: " .._Message);
end
info = API.Info;

---
-- Schreibt einen TRACE auf den Bildschirm und ins Log.
--
-- <p><b>Alias:</b> info</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
-- @local
--
function API.Trace(_Message)
    if QSB.Log.CurrentLevel <= QSB.Log.Level.TRACE then
        API.Note("TRACE: " .._Message)
    end
    API.Log("TRACE: " .._Message);
end
trace = API.Trace;

-- Log Levels
QSB.Log = {
    Level = {
        OFF      = 90000,
        FATAL    = 4000,
        WARNING  = 3000,
        INFO     = 2000,
        TRACE    = 1000,
        ALL      = 0,
    },
}

-- Aktuelles Level
QSB.Log.CurrentLevel = QSB.Log.Level.FATAL;

---
-- Setzt das Log-Level für die aktuelle Skriptumgebung.
--
-- Als Voreinstellung werden nur FATAL-Meldungen angezeigt!
--
-- Das Log-Level bestimmt, welche Meldungen ausgegeben und welche unterdrückt
-- werden. Somit können Debug-Meldungen unterdrückt, während Fehlermeldungen
-- angezeigt werden.
--
-- <table border="1">
-- <tr>
-- <th>
-- Level
-- </th>
-- <th>
-- Beschreibung
-- </th>
-- </tr>
-- <td>
-- QSB.Log.Level.OFF
-- </td>
-- <td>
-- Alle Meldungen werden unterdrückt.
-- </td>
-- <tr>
-- <td>
-- QSB.Log.Level.FATAL
-- </td>
-- <td>
-- Es werden nur Fehler angezeigt.
-- </td>
-- </tr>
-- <tr>
-- <td>
-- QSB.Log.Level.WARNING
-- </td>
-- <td>
-- Es werden nur Warnungen und Fehler angezeigt.
-- </td>
-- </tr>
-- <tr>
-- <td>
-- QSB.Log.Level.INFO
-- </td>
-- <td>
-- Es werden Meldungen aller Stufen angezeigt.
-- </td>
-- </tr>
-- </table>
--
-- @param[type=number] _Level Level
-- @within Anwenderfunktionen
-- @local
--
function API.SetLogLevel(_Level)
    assert(type(_Level) == "number");
    QSB.Log.CurrentLevel = _Level;
end

-- Entities --------------------------------------------------------------------

---
-- Sendet einen Handelskarren zu dem Spieler. Startet der Karren von einem
-- Gebäude, wird immer die Position des Eingangs genommen.
--
-- <p><b>Alias:</b> SendCart</p>
--
-- @param _position                        Position (Skriptname oder Positionstable)
-- @param[type=number] _player             Zielspieler
-- @param[type=number] _good               Warentyp
-- @param[type=number] _amount             Warenmenge
-- @param[type=number] _cartOverlay        (optional) Overlay für Goldkarren
-- @param[type=boolean] _ignoreReservation (optional) Marktplatzreservation ignorieren
-- @return[type=number] Entity-ID des erzeugten Wagens
-- @within Anwenderfunktionen
-- @usage -- API-Call
-- API.SendCart(Logic.GetStoreHouse(1), 2, Goods.G_Grain, 45)
-- -- Legacy-Call mit ID-Speicherung
-- local ID = SendCart("Position_1", 5, Goods.G_Wool, 5)
--
function API.SendCart(_position, _player, _good, _amount, _cartOverlay, _ignoreReservation)
    local eID = GetID(_position);
    if not IsExisting(eID) then
        return;
    end
    local ID;
    local x,y,z = Logic.EntityGetPos(eID);
    local resCat = Logic.GetGoodCategoryForGoodType(_good);
    local orientation = 0;
    if Logic.IsBuilding(eID) == 1 then
        x,y = Logic.GetBuildingApproachPosition(eID);
        orientation = Logic.GetEntityOrientation(eID)-90;
    end

    if resCat == GoodCategories.GC_Resource then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_ResourceMerchant, x, y,orientation,_player)
    elseif _good == Goods.G_Medicine then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Medicus, x, y,orientation,_player)
    elseif _good == Goods.G_Gold then
        if _cartOverlay then
            ID = Logic.CreateEntityOnUnblockedLand(_cartOverlay, x, y,orientation,_player)
        else
            ID = Logic.CreateEntityOnUnblockedLand(Entities.U_GoldCart, x, y,orientation,_player)
        end
    else
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Marketer, x, y,orientation,_player)
    end
    Logic.HireMerchant( ID, _player, _good, _amount, _player, _ignoreReservation)
    return ID
end
SendCart = API.SendCart;

---
-- Ersetzt ein Entity mit einem neuen eines anderen Typs. Skriptname,
-- Rotation, Position und Besitzer werden übernommen.
--
-- <b>Hinweis</b>: Die Entity-ID ändert sich und beim Ersetzen von
-- Spezialgebäuden kann eine Niederlage erfolgen.
--
-- <p><b>Alias:</b> ReplaceEntity</p>
--
-- @param _Entity      Entity (Skriptname oder ID)
-- @param[type=number] _Type     Neuer Typ
-- @param[type=number] _NewOwner (optional) Neuer Besitzer
-- @return[type=number] Entity-ID des Entity
-- @within Anwenderfunktionen
-- @usage API.ReplaceEntity("Stein", Entities.XD_ScriptEntity)
--
function API.ReplaceEntity(_Entity, _Type, _NewOwner)
    local eID = GetID(_Entity);
    if eID == 0 then
        return;
    end
    local pos = GetPosition(eID);
    local player = _NewOwner or Logic.EntityGetPlayer(eID);
    local orientation = Logic.GetEntityOrientation(eID);
    local name = Logic.GetEntityName(eID);
    DestroyEntity(eID);
    if Logic.IsEntityTypeInCategory(_Type, EntityCategories.Soldier) == 1 then
        return CreateBattalion(player, _Type, pos.X, pos.Y, 1, name, orientation);
    else
        return CreateEntity(player, _Type, pos, name, orientation);
    end
end
ReplaceEntity = API.ReplaceEntity;

---
-- Rotiert ein Entity, sodass es zum Ziel schaut.
--
-- <p><b>Alias:</b> LookAt</p>
--
-- @param _entity         Entity (Skriptname oder ID)
-- @param _entityToLookAt Ziel (Skriptname oder ID)
-- @param[type=number]    _offsetEntity Winkel Offset
-- @within Anwenderfunktionen
-- @usage API.LookAt("Hakim", "Alandra")
--
function API.LookAt(_entity, _entityToLookAt, _offsetEntity)
    local entity = GetEntityId(_entity);
    local entityTLA = GetEntityId(_entityToLookAt);
    if not IsExisting(entity) or not IsExisting(entityTLA) then
        API.Warn("API.LookAt: One entity is invalid or dead!");
        return;
    end
    local eX, eY = Logic.GetEntityPosition(entity);
    local eTLAX, eTLAY = Logic.GetEntityPosition(entityTLA);
    local orientation = math.deg( math.atan2( (eTLAY - eY) , (eTLAX - eX) ) );
    if Logic.IsBuilding(entity) == 1 then
        orientation = orientation - 90;
    end
    _offsetEntity = _offsetEntity or 0;
    Logic.SetOrientation(entity, orientation + _offsetEntity);
end
LookAt = API.LookAt;

---
-- Lässt zwei Entities sich gegenseitig anschauen.
--
-- @param _entity         Entity (Skriptname oder ID)
-- @param _entityToLookAt Ziel (Skriptname oder ID)
-- @within Anwenderfunktionen
-- @usage API.Confront("Hakim", "Alandra")
--
function API.Confront(_entity, _entityToLookAt)
    API.LookAt(_entity, _entityToLookAt);
    API.LookAt(_entityToLookAt, _entity);
end

---
-- Bestimmt die Distanz zwischen zwei Punkten. Es können Entity-IDs,
-- Skriptnamen oder Positionstables angegeben werden.
--
-- Wenn die Distanz nicht bestimmt werden kann, wird -1 zurückgegeben.
--
-- <p><b>Alias:</b> GetDistance</p>
--
-- @param _pos1 Erste Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @param _pos2 Zweite Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @return[type=number] Entfernung zwischen den Punkten
-- @within Anwenderfunktionen
-- @usage local Distance = API.GetDistance("HQ1", Logic.GetKnightID(1))
--
function API.GetDistance( _pos1, _pos2 )
    if (type(_pos1) == "string") or (type(_pos1) == "number") then
        _pos1 = GetPosition(_pos1);
    end
    if (type(_pos2) == "string") or (type(_pos2) == "number") then
        _pos2 = GetPosition(_pos2);
    end
    if type(_pos1) ~= "table" or type(_pos2) ~= "table" then
        return -1;
    end
    local xDistance = (_pos1.X - _pos2.X);
    local yDistance = (_pos1.Y - _pos2.Y);
    return math.sqrt((xDistance^2) + (yDistance^2));
end
GetDistance = API.GetDistance;

---
-- Prüft, ob eine Positionstabelle eine gültige Position enthält.
--
-- Eine Position ist Ungültig, wenn sie sich nicht auf der Welt befindet.
-- Das ist der Fall bei negativen Werten oder Werten, welche die Größe
-- der Welt übersteigen.
--
-- <p><b>Alias:</b> IsValidPosition</p>
--
-- @param[type=table] _pos Positionstable {X= x, Y= y}
-- @return[type=boolean] Position ist valide
-- @within Anwenderfunktionen
--
function API.ValidatePosition(_pos)
    if type(_pos) == "table" then
        if (_pos.X ~= nil and type(_pos.X) == "number") and (_pos.Y ~= nil and type(_pos.Y) == "number") then
            local world = {Logic.WorldGetSize()}
            if _pos.Z and _pos.Z < 0 then
                return false;
            end
            if _pos.X <= world[1] and _pos.X >= 0 and _pos.Y <= world[2] and _pos.Y >= 0 then
                return true;
            end
        end
    end
    return false;
end
IsValidPosition = API.ValidatePosition;

---
-- Lokalisiert ein Entity auf der Map. Es können sowohl Skriptnamen als auch
-- IDs verwendet werden. Wenn das Entity nicht gefunden wird, wird eine
-- Tabelle mit XYZ = 0 zurückgegeben.
--
-- <p><b>Alias:</b> GetPosition</p>
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=table] Positionstabelle {X= x, Y= y, Z= z}
-- @within Anwenderfunktionen
-- @usage local Position = API.LocateEntity("Hans")
--
function API.LocateEntity(_Entity)
    if (type(_Entity) == "table") then
        return _Entity;
    end
    if (not IsExisting(_Entity)) then
        return {X= 0, Y= 0, Z= 0};
    end
    local x, y, z = Logic.EntityGetPos(GetID(_Entity));
    return {X= x, Y= y, Z= z};
end
GetPosition = API.LocateEntity;

---
-- Aktiviert ein interaktives Objekt, sodass es benutzt werden kann.
--
-- Der State bestimmt, ob es immer aktiviert werden kann, oder ob der Spieler
-- einen Helden benutzen muss. Wird der Parameter weggelassen, muss immer ein
-- Held das Objekt aktivieren.
--
-- <p><b>Alias:</b> InteractiveObjectActivate</p>
--
-- @param[type=string] _ScriptName  Skriptname des IO
-- @param[type=number] _State       Aktivierungszustand
-- @within Anwenderfunktionen
-- @usage API.ActivateIO("Haus1", 0)
-- API.ActivateIO("Hut1")
--
function API.ActivateIO(_ScriptName, _State)
    _State = _State or 0;
    if GUI then
        GUI.SendScriptCommand('API.ActivateIO("' .._ScriptName.. '", ' .._State..')');
        return;
    end
    if not IsExisting(_ScriptName) then
        return
    end
    Logic.InteractiveObjectSetAvailability(GetID(_ScriptName), true);
    for i = 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), i, _State);
    end
end
InteractiveObjectActivate = API.ActivateIO;

---
-- Deaktiviert ein Interaktives Objekt, sodass es nicht mehr vom Spieler
-- aktiviert werden kann.
--
-- <p><b>Alias:</b> InteractiveObjectDeactivate</p>
--
-- @param[type=string] _ScriptName Skriptname des IO
-- @within Anwenderfunktionen
-- @usage API.DeactivateIO("Hut1")
--
function API.DeactivateIO(_ScriptName)
    if GUI then
        GUI.SendScriptCommand('API.DeactivateIO("' .._ScriptName.. '")');
        return;
    end
    if not IsExisting(_ScriptName) then
        return;
    end
    Logic.InteractiveObjectSetAvailability(GetID(_ScriptName), false);
    for i = 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), i, 2);
    end
end
InteractiveObjectDeactivate = API.DeactivateIO;

---
-- Ermittelt alle Entities in der Kategorie auf dem Territorium und gibt
-- sie als Liste zurück.
--
-- <p><b>Alias:</b> GetEntitiesOfCategoryInTerritory</p>
--
-- @param[type=number] _player    PlayerID [0-8] oder -1 für alle
-- @param[type=number] _category  Kategorie, der die Entities angehören
-- @param[type=number] _territory Zielterritorium
-- @within Anwenderfunktionen
-- @usage local Found = API.GetEntitiesOfCategoryInTerritory(1, EntityCategories.Hero, 5)
--
function API.GetEntitiesOfCategoryInTerritory(_player, _category, _territory)
    local PlayerEntities = {};
    local Units = {};
    if (_player == -1) then
        for i=0,8 do
            local NumLast = 0;
            repeat
                Units = { Logic.GetEntitiesOfCategoryInTerritory(_territory, i, _category, NumLast) };
                PlayerEntities = Array_Append(PlayerEntities, Units);
                NumLast = NumLast + #Units;
            until #Units == 0;
        end
    else
        local NumLast = 0;
        repeat
            Units = { Logic.GetEntitiesOfCategoryInTerritory(_territory, _player, _category, NumLast) };
            PlayerEntities = Array_Append(PlayerEntities, Units);
            NumLast = NumLast + #Units;
        until #Units == 0;
    end
    return PlayerEntities;
end
GetEntitiesOfCategoryInTerritory = API.GetEntitiesOfCategoryInTerritory;

---
-- Gibt dem Entity einen eindeutigen Skriptnamen und gibt ihn zurück.
-- Hat das Entity einen Namen, bleibt dieser unverändert und wird
-- zurückgegeben.
-- @param[type=number] _EntityID Entity ID
-- @return[type=string] Skriptname
-- @within Anwenderfunktionen
--
function API.EnsureScriptName(_EntityID)
    if type(_EntityID) == "string" then
        return _EntityID;
    else
        assert(type(_EntityID) == "number");
        local name = Logic.GetEntityName(_EntityID);
        if (type(name) ~= "string" or name == "" ) then
            QSB.GiveEntityNameCounter = (QSB.GiveEntityNameCounter or 0)+ 1;
            name = "EnsureScriptName_Name_"..QSB.GiveEntityNameCounter;
            Logic.SetEntityName(_EntityID, name);
        end
        return name;
    end
end
GiveEntityName = API.EnsureScriptName;

-- Overwrite -------------------------------------------------------------------

---
-- Schickt einen Skriptbefehl an die jeweils andere Skriptumgebung.
--
-- Wird diese Funktion als dem globalen Skript aufgerufen, sendet sie den
-- Befehl an das lokale Skript. Wird diese Funktion im lokalen Skript genutzt,
-- wird der Befehl an das globale Skript geschickt.
--
-- @param[type=string]  _Command Lua-Befehl als String
-- @param[type=boolean] _Flag FIXME Optional für GUI.SendScriptCommand benötigt. Was macht das Flag?
-- @within Anwenderfunktionen
-- @local
--
function API.Bridge(_Command, _Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState(_Command)
    else
        GUI.SendScriptCommand(_Command, _Flag)
    end
end

---
-- Wandelt underschiedliche Darstellungen einer Boolean in eine echte um.
--
-- Jeder String, der mit j, t, y oder + beginnt, wird als true interpretiert.
-- Alles andere als false.
--
-- Ist die Eingabe bereits ein Boolean wird es direkt zurückgegeben.
--
-- <p><b>Alias:</b> AcceptAlternativeBoolean</p>
--
-- @param _Value Wahrheitswert
-- @return[type=boolean] Wahrheitswert
-- @within Anwenderfunktionen
-- @local
--
-- @usage local Bool = API.ToBoolean("+")  --> Bool = true
-- local Bool = API.ToBoolean("no") --> Bool = false
--
function API.ToBoolean(_Value)
    return Core:ToBoolean(_Value);
end
AcceptAlternativeBoolean = API.ToBoolean;

---
-- Registriert eine Funktion, die nach dem laden ausgeführt wird.
--
-- <b>Alias</b>: AddOnSaveGameLoadedAction
--
-- @param[type=function] _Function Funktion, die ausgeführt werden soll
-- @within Anwenderfunktionen
-- @usage SaveGame = function()
--     API.Note("foo")
-- end
-- API.AddSaveGameAction(SaveGame)
--
function API.AddSaveGameAction(_Function)
    if GUI then
        API.Fatal("API.AddSaveGameAction: Can not be used from the local script!");
        return;
    end
    return Core:AppendFunction("Mission_OnSaveGameLoaded", _Function)
end
AddOnSaveGameLoadedAction = API.AddSaveGameAction;

---
-- Fügt eine Beschreibung zu einem selbst gewählten Hotkey hinzu.
--
-- Ist der Hotkey bereits vorhanden, wird -1 zurückgegeben.
--
-- @param[type=string] _Key         Tastenkombination
-- @param[type=string] _Description Beschreibung des Hotkey
-- @return[type=number] Index oder Fehlercode
-- @within Anwenderfunktionen
--
function API.AddHotKey(_Key, _Description)
    if not GUI then
        API.Fatal("API.AddHotKey: Can not be used from the global script!");
        return;
    end
    g_KeyBindingsOptions.Descriptions = nil;
    table.insert(Core.Data.HotkeyDescriptions, {_Key, _Description});
    return #Core.Data.HotkeyDescriptions;
end

---
-- Entfernt eine Beschreibung eines selbst gewählten Hotkeys.
--
-- @param[type=number] _Index Index in Table
-- @within Anwenderfunktionen
--
function API.RemoveHotKey(_Index)
    if not GUI then
        API.Fatal("API.RemoveHotKey: Can not be used from the global script!");
        return;
    end
    if type(_Index) ~= "number" or _Index > #Core.Data.HotkeyDescriptions then
        API.Fatal("API.RemoveHotKey: No candidate found or Index is nil!");
        return;
    end
    Core.Data.HotkeyDescriptions[_Index] = nil;
end

-- Echtzeit --------------------------------------------------------------------

---
-- Gibt die real vergangene Zeit seit dem Spielstart in Sekunden zurück.
-- @return[type=number] Vergangene reale Zeit
-- @within Anwenderfunktionen
--
function API.RealTimeGetSecondsPassedSinceGameStart()
    return QSB.RealTime_SecondsSinceGameStart;
end

---
-- Wartet die angebene Zeit in realen Sekunden und führt anschließend das
-- Callback aus.
--
-- Hinweis: Einmal gestartet, kann wait nicht beendet werden.
--
-- @param[type=number] _Waittime Wartezeit in realen Sekunden
-- @param[type=function] _Action Callback-Funktion
-- @param ... Liste der Argumente
-- @return[type=number] Vergangene reale Zeit
-- @within Anwenderfunktionen
--
function API.RealTimeWait(_Waittime, _Action, ...)
    StartSimpleJobEx( function(_StartTime, _Delay, _Callback, _Arguments)
        if (QSB.RealTime_SecondsSinceGameStart >= _StartTime + _Delay) then
            if #_Arguments > 0 then
                _Callback(unpack(_Arguments));
            else
                _Callback();
            end
            return true;
        end
    end, QSB.RealTime_SecondsSinceGameStart, _Waittime, _Action, {...});
end

-- -------------------------------------------------------------------------- --
-- Object Oriented Programming                                                --
-- -------------------------------------------------------------------------- --

-- Ermöglicht das objektorientierte programmieren in Siedler-Lua. Klassen
-- müssen sich immer direkt in _G befinden, damit className automatisch
-- gesetzt werden kann. Andernfalls muss der Name der Klasse per Hand
-- gesetzt werden.

---
-- Kopiert die Quelltabelle rekursiv in die Zieltabelle. Ist ein Wert im
-- Ziel vorhanden, wird er nicht überschrieben.
--
-- @param[type=table] _Source Quelltabelle
-- @param[type=table] _Dest Zieltabelle
-- @return[type=table] Kindklasse
-- @within OOP
--
function copy(_Source, _Dest)
    _Dest = _Dest or {};
    assert(type(_Source) == "table")
    assert(type(_Dest) == "table")

    for k, v in pairs(_Source) do
        if type(v) == "table" then
            _Dest[k] = _Dest[k] or {};
            for kk, vv in pairs(copy(v)) do
                _Dest[k][kk] = _Dest[k][kk] or vv;
            end
        else
            _Dest[k] = _Dest[k] or v;
        end
    end
    return _Dest;
end

---
-- Fügt einer Table Grundfunktionalität hinzu und macht sie zur Klasse.
--
-- Es handelt sich nicht um Metatables! Dies ist eine Emulation, die einige
-- Features von Metatables auf normalen Tables abbildet. Grund ist die
-- fehlende Speicherbarkeit von Metatables.
--
-- <b>Hinweis</b>: Die Funktionen werden nur dann hinzugefügt, wenn es keine
-- Funktionen gleichen Namens vor dem aufruf von class() im Table gibt.
-- Die Funktionen können nach dem Aufruf von class() überschrieben werden.
-- @param[type=table] _Table Referenz auf Table
-- @return[type=table] Klasse
-- @within OOP
--
function class(_Table)
    -- className hinzufügen
    for k, v in pairs(_G) do
        if v == _Table then
            _Table.className = k;
        end
    end

    -- construct hinzufügen
    _Table.construct = _Table.construct or function(self) end

    -- clone hinzufügen
    _Table.clone = _Table.clone or function(self)
        return copy(self);
    end

    -- toString hinzufügen
    _Table.toString = _Table.toString or function(self)
        local s = "";
        for k, v in pairs(self) do
            s = s .. tostring(k) .. ":" .. tostring(v) .. ";";
        end
        return "{" ..s.. "}";
    end

    -- equals hinzufügen
    _Table.equals = _Table.equals or function(self, _Other)
        -- Anderes Objekt muss table sein.
        if type(_Other) ~= "table" then
            return false;
        end
        -- Gehe Inhalt durch
        for k, v in pairs(self) do
            if v ~= _Other[k] then
                return false;
            end
        end
        return true;
    end

    -- foreach hinzufügen
    _Table.foreach = _Table.foreach or function(self, _Function)
        for k, v in pairs(self) do
            self[k] = _Function(self, k, v) or self[k];
        end
    end

    -- size hinzufügen
    _Table.size = _Table.size or function(self)
        local TableSize = 0;
        for k, v in pairs(self) do
            TableSize = TableSize +1;
        end
        return TableSize;
    end

    -- add hinzufügen
    _Table.add = _Table.add or function(self, _Other)
        local Result = copy(self);
        if type(_Other) == "table" then 
            for k, v in pairs(self) do
                if (v and type(v) == "string") then
                    if tonumber(v) then
                        Result[k] = tostring(tonumber(v) + tonumber(_Other[k]));
                    else
                        Result[k] = v .. _Other[k];
                    end
                elseif (v and type(v) == "number") then
                    Result[k] = self[k] + tonumber(_Other[k]);
                end
            end
        end
        return Result;
    end

    -- sub hinzufügen
    _Table.sub = _Table.sub or function(self, _Other)
        local Result = copy(self);
        if type(_Other) == "table" then 
            for k, v in pairs(self) do
                if (self[k] and type(v) == "string") then
                    if tonumber(v) then
                        Result[k] = tostring(tonumber(v) - tonumber(_Other[k]));
                    else
                        Result[k] = v:gsub(_Other[k], "");
                    end
                elseif (self[k] and type(v) == "number") then
                    Result[k] = self[k] - tonumber(_Other[k]);
                end
            end
        end
        return Result;
    end

    -- mult hinzufügen
    _Table.mult = _Table.mult or function(self, _Other)
        local Result = copy(self);
        if type(_Other) == "table" then 
            for k, v in pairs(self) do
                if (self[k] and type(v) == "string") then
                    if tonumber(v) then
                        Result[k] = tostring(tonumber(v) * tonumber(_Other[k]));
                    end
                elseif (self[k] and type(v) == "number") then
                    Result[k] = self[k] * tonumber(_Other[k]);
                end
            end
        end
        return Result;
    end

    -- divide hinzufügen
    _Table.divide = _Table.divide or function(self, _Other)
        local Result = copy(self);
        if type(_Other) == "table" then 
            for k, v in pairs(self) do
                if (self[k] and type(v) == "string") then
                    if tonumber(v) then
                        Result[k] = tostring(tonumber(v) / tonumber(_Other[k]));
                    end
                elseif (self[k] and type(v) == "number") then
                    Result[k] = v / tonumber(_Other[k]);
                end
            end
        end
        return Result;
    end

    -- mod hinzufügen
    _Table.mod = _Table.mod or function(self, _Other)
        local Result = copy(self);
        if type(_Other) == "table" then 
            for k, v in pairs(self) do
                if (self[k] and type(v) == "string") then
                    if tonumber(v) then
                        Result[k] = tostring(tonumber(v) % tonumber(_Other[k]));
                    end
                elseif (self[k] and type(v) == "number") then
                    Result[k] = v % tonumber(_Other[k]);
                end
            end
        end
        return Result;
    end

    -- pow hinzufügen
    _Table.pow = _Table.pow or function(self, _Other)
        local Result = copy(self);
        if type(_Other) == "table" then 
            for k, v in pairs(self) do
                if (self[k] and type(v) == "string") then
                    if tonumber(v) then
                        Result[k] = tostring(tonumber(v) ^ tonumber(_Other[k]));
                    end
                elseif (self[k] and type(v) == "number") then
                    Result[k] = v ^ tonumber(_Other[k]);
                end
            end
        end
        return Result;
    end

    -- sum hinzufügen
    _Table.sum = _Table.sum or function(self, ...)
        local Result = copy(self);
        if type(arg[1]) == "table" then 
            for k, v in pairs(self) do
                if type(v) == "number" or type(v) == "string" then
                    for i= 1, #arg, 1 do 
                        Result[k] = tonumber(Result[k]) + tonumber(arg[i][k]);
                        if type(v) == "string" then
                            Result[k] = tostring(Result[k]);
                        end
                    end
                end
            end
        end
        return Result;
    end

    return _Table;
end

---
-- Erzeugt eine Ableitung einer Klasse
--
-- @param[type=table] _Parent Referenz auf Klasse
-- @return[type=table] Kindklasse
-- @within OOP
--
function inherit(_Class, _Parent)
    local c = copy(_Parent, _Class);
    c.parent = _Parent;
    return class(c);
end

---
-- Erzeugt eine Instanz der Klasse.
--
-- @param[type=table] _Class Referenz auf Klasse
-- @param ...         Argumente des Konstruktors
-- @return[type=table] Instanz der Klasse
-- @within OOP
--
function new(_Data)
    local instance = copy(_Data[1]);
    table.remove(_Data, 1);

    -- Parent instanzieren
    if instance.parent then
        instance.parent = new(instance.parent, unpack(_Data));
    end
    -- Instanz erzeugen
    instance:construct(unpack(_Data));
    return instance;
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

Core = {
    Data = {
        Overwrite = {
            StackedFunctions = {},
            AppendedFunctions = {},
            Fields = {},
        },
        HotkeyDescriptions = {},
        BundleInitializerList = {},
        InitalizedBundles = {},
    }
}

---
-- Initialisiert alle verfügbaren Bundles und führt ihre Install-Methode aus.
-- Bundles werden immer getrennt im globalen und im lokalen Skript gestartet.
-- @within Internal
-- @local
--
function Core:InitalizeBundles()
    if not GUI then
        self:SetupGobal_HackCreateQuest();
        self:SetupGlobal_HackQuestSystem();

        StartSimpleJobEx(CoreJob_CalculateRealTimeSinceGameStart);
    else
        self:SetupLocal_HackRegisterHotkey();

        StartSimpleJobEx(CoreJob_CalculateRealTimeSinceGameStart);
    end

    for k,v in pairs(self.Data.BundleInitializerList) do
        local Bundle = _G[v];
        if not GUI then
            if Bundle.Global ~= nil and Bundle.Global.Install ~= nil then
                Bundle.Global:Install();
                Bundle.Local = nil;
            end
        else
            if Bundle.Local ~= nil and Bundle.Local.Install ~= nil then
                Bundle.Local:Install();
                Bundle.Global = nil;
            end
        end
        self.Data.InitalizedBundles[v] = true;
        collectgarbage();
    end
end

---
-- Überschreibt CreateQuest für die Anbindung an Symfonia.
-- @within Internal
-- @local
--
function Core:SetupGobal_HackCreateQuest()
    CreateQuest = function(_QuestName, _QuestGiver, _QuestReceiver, _QuestHidden, _QuestTime, _QuestDescription, _QuestStartMsg, _QuestSuccessMsg, _QuestFailureMsg)
        local Triggers = {};
        local Goals = {};
        local Reward = {};
        local Reprisal = {};
        local NumberOfBehavior = Logic.Quest_GetQuestNumberOfBehaviors(_QuestName);

        for i=0, NumberOfBehavior-1, 1 do
            -- Behavior ermitteln
            local BehaviorName = Logic.Quest_GetQuestBehaviorName(_QuestName, i);
            local BehaviorTemplate = GetBehaviorTemplateByName(BehaviorName);
            assert( BehaviorTemplate, "No template for name: " .. BehaviorName .. " - using an invalid QuestSystemBehavior.lua?!");
            local NewBehavior = {};
            Table_Copy(NewBehavior, BehaviorTemplate);
            local Parameter = Logic.Quest_GetQuestBehaviorParameter(_QuestName, i);
            for j=1,#Parameter do
                NewBehavior:AddParameter(j-1, Parameter[j]);
            end

            -- Füge als Goal hinzu
            if (NewBehavior.GetGoalTable ~= nil) then
                Goals[#Goals + 1] = NewBehavior:GetGoalTable();
                Goals[#Goals].Context = NewBehavior;
                Goals[#Goals].FuncOverrideIcon = NewBehavior.GetIcon;
                Goals[#Goals].FuncOverrideMsgKey = NewBehavior.GetMsgKey;
            end
            -- Füge als Trigger hinzu
            if (NewBehavior.GetTriggerTable ~= nil) then
                Triggers[#Triggers + 1] = NewBehavior:GetTriggerTable();
            end
            -- Füge als Reprisal hinzu
            if (NewBehavior.GetReprisalTable ~= nil) then
                Reprisal[#Reprisal + 1] = NewBehavior:GetReprisalTable();
            end
            -- Füge als Reward hinzu
            if (NewBehavior.GetRewardTable ~= nil) then
                Reward[#Reward + 1] = NewBehavior:GetRewardTable();
            end
        end

        -- Prüfe Mindestkonfiguration des Quest
        if (#Triggers == 0) or (#Goals == 0) then
            return;
        end

        -- Erzeuge den Quest
        if Core:CheckQuestName(_QuestName) then
            local QuestID = QuestTemplate:New(
                _QuestName,
                _QuestGiver or 1,
                _QuestReceiver or 1,
                Goals,
                Triggers,
                tonumber(_QuestTime) or 0,
                Reward,
                Reprisal,
                nil, nil,
                (not _QuestHidden or ( _QuestStartMsg and _QuestStartMsg ~= "") ),
                (not _QuestHidden or ( _QuestSuccessMsg and _QuestSuccessMsg ~= "") or ( _QuestFailureMsg and _QuestFailureMsg ~= "") ),
                _QuestDescription,
                _QuestStartMsg,
                _QuestSuccessMsg,
                _QuestFailureMsg
            );
            g_QuestNameToID[_QuestName] = QuestID;
        else
            fatal("Quest '"..tostring(questName).."': invalid questname! Contains forbidden characters!");
        end
    end
end

---
-- Implementiert die vordefinierten Texte für Custom Behavior und den Aufruf
-- der :Interrupt Methode.
-- @within Internal
-- @local
--
function Core:SetupGlobal_HackQuestSystem()
    QuestTemplate.Trigger_Orig_QSB_Core = QuestTemplate.Trigger
    QuestTemplate.Trigger = function(_quest)
        QuestTemplate.Trigger_Orig_QSB_Core(_quest);
        for i=1,_quest.Objectives[0] do
            if _quest.Objectives[i].Type == Objective.Custom2 and _quest.Objectives[i].Data[1].SetDescriptionOverwrite then
                local Desc = _quest.Objectives[i].Data[1]:SetDescriptionOverwrite(_quest);
                Core:ChangeCustomQuestCaptionText(Desc, _quest);
                break;
            end
        end
    end

    QuestTemplate.Interrupt_Orig_QSB_Core = QuestTemplate.Interrupt;
    QuestTemplate.Interrupt = function(_quest)
        QuestTemplate.Interrupt_Orig_QSB_Core(_quest);
        for i=1, _quest.Objectives[0] do
            if _quest.Objectives[i].Type == Objective.Custom2 and _quest.Objectives[i].Data[1].Interrupt then
                _quest.Objectives[i].Data[1]:Interrupt(_quest, i);
            end
        end
        for i=1, _quest.Triggers[0] do
            if _quest.Triggers[i].Type == Triggers.Custom2 and _quest.Triggers[i].Data[1].Interrupt then
                _quest.Triggers[i].Data[1]:Interrupt(_quest, i);
            end
        end
    end
end

---
-- Überschreibt das Hotkey-Register, sodass eigene Hotkeys mit im Menü
-- angezeigt werden können.
-- @within Internal
-- @local
--
function Core:SetupLocal_HackRegisterHotkey()
    function g_KeyBindingsOptions:OnShow()
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        if Game ~= nil then
            XGUIEng.ShowWidget("/InGame/KeyBindingsMain/Backdrop", 1);
        else
            XGUIEng.ShowWidget("/InGame/KeyBindingsMain/Backdrop", 0);
        end

        if g_KeyBindingsOptions.Descriptions == nil then
            g_KeyBindingsOptions.Descriptions = {};
            DescRegister("MenuInGame");
            DescRegister("MenuDiplomacy");
            DescRegister("MenuProduction");
            DescRegister("MenuPromotion");
            DescRegister("MenuWeather");
            DescRegister("ToggleOutstockInformations");
            DescRegister("JumpMarketplace");
            DescRegister("JumpMinimapEvent");
            DescRegister("BuildingUpgrade");
            DescRegister("BuildLastPlaced");
            DescRegister("BuildStreet");
            DescRegister("BuildTrail");
            DescRegister("KnockDown");
            DescRegister("MilitaryAttack");
            DescRegister("MilitaryStandGround");
            DescRegister("MilitaryGroupAdd");
            DescRegister("MilitaryGroupSelect");
            DescRegister("MilitaryGroupStore");
            DescRegister("MilitaryToggleUnits");
            DescRegister("UnitSelect");
            DescRegister("UnitSelectToggle");
            DescRegister("UnitSelectSameType");
            DescRegister("StartChat");
            DescRegister("StopChat");
            DescRegister("QuickSave");
            DescRegister("QuickLoad");
            DescRegister("TogglePause");
            DescRegister("RotateBuilding");
            DescRegister("ExitGame");
            DescRegister("Screenshot");
            DescRegister("ResetCamera");
            DescRegister("CameraMove");
            DescRegister("CameraMoveMouse");
            DescRegister("CameraZoom");
            DescRegister("CameraZoomMouse");
            DescRegister("CameraRotate");

            for k,v in pairs(Core.Data.HotkeyDescriptions) do
                if v then
                    v[1] = (type(v[1]) == "table" and v[1][lang]) or v[1];
                    v[2] = (type(v[2]) == "table" and v[2][lang]) or v[2];
                    table.insert(g_KeyBindingsOptions.Descriptions, 1, v);
                end
            end
        end
        XGUIEng.ListBoxPopAll(g_KeyBindingsOptions.Widget.ShortcutList);
        XGUIEng.ListBoxPopAll(g_KeyBindingsOptions.Widget.ActionList);
        for Index, Desc in ipairs(g_KeyBindingsOptions.Descriptions) do
            XGUIEng.ListBoxPushItem(g_KeyBindingsOptions.Widget.ShortcutList, Desc[1]);
            XGUIEng.ListBoxPushItem(g_KeyBindingsOptions.Widget.ActionList,   Desc[2]);
        end
    end
end

---
-- Prüft, ob das Bundle bereits initalisiert ist.
--
-- @param[type=string] _Bundle Name des Moduls
-- @return[type=boolean] Bundle initalisiert
-- @within Internal
-- @local
--
function Core:IsBundleRegistered(_Bundle)
    return self.Data.InitalizedBundles[Bundle] == true;
end

---
-- Registiert ein Bundle, sodass es initialisiert wird.
--
-- @param[type=string] _Bundle Name des Moduls
-- @within Internal
-- @local
--
function Core:RegisterBundle(_Bundle)
    local text = string.format("Error while initialize bundle '%s': does not exist!", tostring(_Bundle));
    assert(_G[_Bundle] ~= nil, text);
    table.insert(self.Data.BundleInitializerList, _Bundle);
end

---
-- Registiert ein AddOn als Bundle, sodass es initialisiert wird.
--
-- Diese Funktion macht prinziplell das Gleiche wie Core:RegisterBundle und
-- existiert nur zur Übersichtlichkeit.
--
-- @param[type=string] _AddOn Name des Moduls
-- @within Internal
-- @local
--
function Core:RegisterAddOn(_AddOn)
    local text = string.format("Error while initialize addon '%s': does not exist!", tostring(_AddOn));
    assert(_G[_AddOn] ~= nil, text);
    table.insert(self.Data.BundleInitializerList, _AddOn);
end

---
-- Bereitet ein Behavior für den Einsatz im Assistenten und im Skript vor.
-- Erzeugt zudem den Konstruktor.
--
-- @param[type=table] _Behavior Behavior-Objekt
-- @within Internal
-- @local
--
function Core:RegisterBehavior(_Behavior)
    if GUI then
        return;
    end
    if _Behavior.RequiresExtraNo and _Behavior.RequiresExtraNo > g_GameExtraNo then
        return;
    end

    if not _G["b_" .. _Behavior.Name] then
        fatal("AddQuestBehavior: can not find ".. _Behavior.Name .."!");
    else
        if not _G["b_" .. _Behavior.Name].new then
            _G["b_" .. _Behavior.Name].new = function(self, ...)
                local behavior = API.InstanceTable(self);
                behavior.i47ya_6aghw_frxil = {};
                for i= 1, #arg, 1 do
                    if self.Parameter and self.Parameter[i] ~= nil then
                        behavior:AddParameter(i-1, arg[i]);
                    else
                        table.insert(behavior.i47ya_6aghw_frxil, arg[i]);
                    end
                end
                return behavior;
            end
        end

        for i= 1, #g_QuestBehaviorTypes, 1 do
            if g_QuestBehaviorTypes[i].Name == _Behavior.Name then
                return;
            end
        end
        table.insert(g_QuestBehaviorTypes, _Behavior);
    end
end

---
-- Prüft, ob der Questname formal korrekt ist. Questnamen dürfen i.d.R. nur
-- die Zeichen A-Z, a-7, 0-9, - und _ enthalten.
--
-- @param[type=string] _Name Name des Quest
-- @return[type=boolean] Questname ist fehlerfrei
-- @within Internal
-- @local
--
function Core:CheckQuestName(_Name)
    return string.find(_Name, "^[A-Za-z0-9_]+$") ~= nil;
end

---
-- Ändert den Text des Beschreibungsfensters eines Quests. Die Beschreibung
-- wird erst dann aktualisiert, wenn der Quest ausgeblendet wird.
--
-- @param[type=string] _Text Neuer Text
-- @param[type=table] _Quest Quest Table
-- @within Internal
-- @local
--
function Core:ChangeCustomQuestCaptionText(_Text, _Quest)
    _Quest.QuestDescription = _Text;
    Logic.ExecuteInLuaLocalState([[
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/BGDeco",0)
        local identifier = "]].._Quest.Identifier..[["
        for i=1, Quests[0] do
            if Quests[i].Identifier == identifier then
                local text = Quests[i].QuestDescription
                XGUIEng.SetText("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/Text", "]].._Text..[[")
                break
            end
        end
    ]]);
end

---
-- Erweitert eine Funktion um eine andere Funktion.
--
-- Jede hinzugefügte Funktion wird vor der Originalfunktion ausgeführt. Es
-- ist möglich, eine neue Funktion an einem bestimmten Index einzufügen. Diese
-- Funktion ist nicht gedacht, um sie direkt auszuführen. Für jede Funktion
-- im Spiel sollte eine API-Funktion erstellt werden.
--
-- Wichtig: Die gestapelten Funktionen, die vor der Originalfunktion
-- ausgeführt werden, müssen etwas zurückgeben, um die Funktion an
-- gegebener Stelle zu verlassen.
--
-- @param[type=string]   _FunctionName Name der erweiterten Funktion
-- @param[type=function] _StackFunction Neuer Funktionsinhalt
-- @param[type=number]   _Index Reihenfolgeindex
-- @within Internal
-- @local
--
function Core:StackFunction(_FunctionName, _StackFunction, _Index)
    if not self.Data.Overwrite.StackedFunctions[_FunctionName] then
        self.Data.Overwrite.StackedFunctions[_FunctionName] = {
            Original = self:GetFunctionInString(_FunctionName),
            Attachments = {}
        };

        local batch = function(...)
            local ReturnValue;
            for i= 1, #self.Data.Overwrite.StackedFunctions[_FunctionName].Attachments, 1 do
                local Function = self.Data.Overwrite.StackedFunctions[_FunctionName].Attachments[i];
                ReturnValue = Function(unpack(arg));
                if ReturnValue ~= nil then
                    return ReturnValue;
                end
            end
            ReturnValue = self.Data.Overwrite.StackedFunctions[_FunctionName].Original(unpack(arg));
            return ReturnValue;
        end
        self:ReplaceFunction(_FunctionName, batch);
    end

    _Index = _Index or #self.Data.Overwrite.StackedFunctions[_FunctionName].Attachments+1;
    table.insert(self.Data.Overwrite.StackedFunctions[_FunctionName].Attachments, _Index, _StackFunction);
end

---
-- Erweitert eine Funktion um eine andere Funktion.
--
-- Jede hinzugefügte Funktion wird nach der Originalfunktion ausgeführt. Es
-- ist möglich eine neue Funktion an einem bestimmten Index einzufügen. Diese
-- Funktion ist nicht gedacht, um sie direkt auszuführen. Für jede Funktion
-- im Spiel sollte eine API-Funktion erstellt werden.
--
-- @param[type=string]   _FunctionName Name der erweiterten Funktion
-- @param[type=function] _AppendFunction Neuer Funktionsinhalt
-- @param[type=number]   _Index Reihenfolgeindex
-- @within Internal
-- @local
--
function Core:AppendFunction(_FunctionName, _AppendFunction, _Index)
    if not self.Data.Overwrite.AppendedFunctions[_FunctionName] then
        self.Data.Overwrite.AppendedFunctions[_FunctionName] = {
            Original = self:GetFunctionInString(_FunctionName),
            Attachments = {}
        };

        local batch = function(...)
            local ReturnValue = self.Data.Overwrite.AppendedFunctions[_FunctionName].Original(unpack(arg));
            for i= 1, #self.Data.Overwrite.AppendedFunctions[_FunctionName].Attachments, 1 do
                local Function = self.Data.Overwrite.AppendedFunctions[_FunctionName].Attachments[i];
                ReturnValue = Function(unpack(arg))
            end
            return ReturnValue;
        end
        self:ReplaceFunction(_FunctionName, batch);
    end

    _Index = _Index or #self.Data.Overwrite.AppendedFunctions[_FunctionName].Attachments+1;
    table.insert(self.Data.Overwrite.AppendedFunctions[_FunctionName].Attachments, _Index, _AppendFunction);
end

---
-- Überschreibt eine Funktion mit einer anderen.
--
-- Funktionen in einer Tabelle werden überschrieben, indem jede Ebene des
-- Tables mit einem Punkt angetrennt wird.
--
-- @param[type=string]   _FunctionName Name der erweiterten Funktion
-- @param[type=function] _AppendFunction Neuer Funktionsinhalt
-- @local
-- @within Internal
-- @usage A = {foo = function() API.Note("bar") end}
-- B = function() API.Note("muh") end
-- Core:ReplaceFunction("A.foo", B)
-- -- A.foo() == B() => "muh"
--
function Core:ReplaceFunction(_FunctionName, _Function)
    assert(type(_FunctionName) == "string");
    local ref = _G;

    local s, e = _FunctionName:find("%.");
    while (s ~= nil) do
        local SubName = _FunctionName:sub(1, e-1);
        SubName = (tonumber(SubName) ~= nil and tonumber(SubName)) or SubName;

        ref = ref[SubName];
        _FunctionName = _FunctionName:sub(e+1);
        s, e = _FunctionName:find("%.");
    end

    local SubName = (tonumber(_FunctionName) ~= nil and tonumber(_FunctionName)) or _FunctionName;
    ref[SubName] = _Function;
end

---
-- Sucht eine Funktion mit dem angegebenen Namen.
--
-- Ist die Funktionen innerhalb einer Table, so sind alle Ebenen bis zum
-- Funktionsnamen mit anzugeben, abgetrennt durch einen Punkt.
--
-- @param[type=string] _FunctionName Name der erweiterten Funktion
-- @return[type=function] Referenz auf die Funktion
-- @within Internal
-- @local
--
function Core:GetFunctionInString(_FunctionName)
    assert(type(_FunctionName) == "string");
    local ref = _G;

    local s, e = _FunctionName:find("%.");
    while (s ~= nil) do
        local SubName = _FunctionName:sub(1, e-1);
        SubName = (tonumber(SubName) ~= nil and tonumber(SubName)) or SubName;

        ref = ref[SubName];
        _FunctionName = _FunctionName:sub(e+1);
        s, e = _FunctionName:find("%.");
    end

    local SubName = (tonumber(_FunctionName) ~= nil and tonumber(_FunctionName)) or _FunctionName;
    return ref[SubName];
end

---
-- Wandelt underschiedliche Darstellungen einer Boolean in eine echte um.
--
-- Jeder String, der mit j, t, y oder + beginnt, wird als true interpretiert.
-- Alles andere als false.
--
-- Ist die Eingabe bereits ein Boolean wird es direkt zurückgegeben.
--
-- @param[type=string] _Input Boolean-Darstellung
-- @return[type=boolean] Konvertierte Boolean
-- @within Internal
-- @local
--
function Core:ToBoolean(_Input)
    if type(_Input) == "boolean" then
        return _Input;
    end
    if string.find(string.lower(tostring(_Input)), "^[tjy\\+].*$") then
        return true;
    end
    return false;
end

-- Jobs ------------------------------------------------------------------------

-- Dieser Job ermittelt automatisch, ob eine Sekunde reale Zeit vergangen ist
-- und zählt eine Variable hoch, die die gesamt verstrichene reale Zeit hält.

function CoreJob_CalculateRealTimeSinceGameStart()
    if not QSB.RealTime_LastTimeStamp then
        if GUI then
            QSB.RealTime_LastTimeStamp = XGUIEng.GetSystemTime();
        else
            QSB.RealTime_LastTimeStamp = Framework.TimeGetTime();
        end
    end

    local CurrentTimeStamp;
    if GUI then
        CurrentTimeStamp = XGUIEng.GetSystemTime();
    else
        CurrentTimeStamp = Framework.TimeGetTime();
    end

    -- Eine Sekunde ist vergangen
    if QSB.RealTime_LastTimeStamp+1 <= CurrentTimeStamp then
        QSB.RealTime_LastTimeStamp = CurrentTimeStamp;
        QSB.RealTime_SecondsSinceGameStart = QSB.RealTime_SecondsSinceGameStart +1;
    end
end
