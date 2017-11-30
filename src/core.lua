-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Synfonia Core                                                         # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
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
-- Wie die einzelnen Bundles ist auch das Framework in einen User- und einen
-- Application-Space aufgeteilt. Der User-Space enthält Funktionen innerhalb
-- der Bibliothek "API". Alle Bundles ergänzen ihre User-Space-Funktionen dort.
-- Außer den Aliases auf API-Funktionen und den Behavior-Funktionen sind keine
-- anderen öffentlichen Funktionen für den Anwendern sichtbar zu machen!
--
-- Im Application-Space liegen die privaten Funktionen und Variablen, die
-- nicht in der Dokumentation erscheinen. Sie sind mit einem Local-Tag zu
-- versehen! Der Nutzer soll diese Funktionen in der Regel nicht anfassen,
-- daher muss er auch nicht wissen, dass es sie gibt!
--
-- Ziel der Teilung zwischen User-Space und Application-Space ist es, dem
-- Anwender eine saubere und leicht verständliche Oberfläche zu Bieten, mit
-- der er einfach arbeiten kann. Kenntnis über die komplexen Prozesse hinter
-- den Kulissen sind dafür nicht notwendig.
--
-- @module Core
--

API = API or {};
QSB = QSB or {};

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
-- User Space                                                                 --
-- -------------------------------------------------------------------------- --

-- Tables --------------------------------------------------------------------

---
-- Kopiert eine komplette Table und gibt die Kopie zurück. Wenn ein Ziel
-- angegeben wird, ist die zurückgegebene Table eine vereinigung der 2
-- angegebenen Tables.
-- Die Funktion arbeitet rekursiv und ist für beide Arten von Index. Die
-- Funktion kann benutzt werden, um Klassen zu instanzieren.
--
-- Alias: CopyTableRecursive
--
-- @param _Source    Quelltabelle
-- @param _Dest      Zieltabelle
-- @return table
-- @within Table-Funktionen
--
function API.InstanceTable(_Source, _Dest)
    _Dest = _Dest or {};
    for k, v in pairs(_Source) do
        _Dest[k] = (type(v) == "table" and API.InstanceTable(v)) or v;
    end
    return _Dest;
end
CopyTableRecursive = API.InstanceTable;

---
-- Sucht in einer Table nach einem Wert. Das erste Aufkommen des Suchwerts
-- wird als Erfolg gewertet.
--
-- @param _Data     Datum, das gesucht wird
-- @param _Table    Tabelle, die durchquert wird
-- @return boolean
-- @within Table-Funktionen
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
-- @param _Table Tabelle, die gedumpt wird
-- @param _Name Optionaler Name im Log
-- @within Table-Funktionen
--
function API.DumpTable(_Table, _Name)
    local Dump = "{\n";
    if _Name then
        Dump = _Name.. " = " ..Dump;
    end
    for k, f in pairs(_Table) do
        if type(v) == "table" then
            Dump = Dump.. "[" ..k.. "] = " .. API.DumpTable(v);
        elseif type(v) == "string" then
            Dump = Dump.. "[" ..k.. "] = \"" ..v.. "\"\n";
        else
            Dump = Dump.. "[" ..k.. "] = " ..tostring(v).. "\n";
        end
    end
    Dump = Dump.. "}\n";

    API.Log("Dump of Table:")
    Framework.WriteToLog(Dump);
end

-- Quests ----------------------------------------------------------------------

---
-- Gibt die ID des Quests mit dem angegebenen Namen zurück. Existiert der
-- Quest nicht, wird nil zurückgegeben.
--
-- Alias: GetQuestID
--
-- @param _Name     Identifier des Quest
-- @return number
-- @within Quest-Funktionen
--
function API.GetQuestID(_Name)
    for i=1, Quests[0] do
        if Quests[i].Identifier == _Name then
            return i;
        end
    end
end
GetQuestID = API.GetQuestID;

---
-- Prüft, ob die ID zu einem Quest gehört bzw. der Quest existiert. Es kann
-- auch ein Questname angegeben werden.
--
-- Alias: IsValidQuest
--
-- @param _QuestID   ID oder Name des Quest
-- @return boolean
-- @within Quest-Funktionen
--
function API.IsValidateQuest(_QuestID)
    return Quests[_QuestID] ~= nil or Quests[self:GetQuestID(_QuestID)] ~= nil;
end
IsValidQuest = API.IsValidateQuest;

---
-- Lässt eine Liste von Quests fehlschlagen.
--
-- Der Status wird auf Over und das Resultat auf Failure gesetzt.
--
-- Alias: FailQuestsByName
--
-- @param ...  Liste mit Quests
-- @within Quest-Funktionen
--
function API.FailAllQuests(...)
    for i=1, #args, 1 do
        API.FailQuest(args[i]);
    end
end
FailQuestsByName = API.FailAllQuests;

---
-- Lässt den Quest fehlschlagen.
--
-- Der Status wird auf Over und das Resultat auf Failure gesetzt.
--
-- Alias: FailQuestByName
--
-- @param _QuestName  Name des Quest
-- @within Quest-Funktionen
--
function API.FailQuest(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if Quest.RemoveNPCMarkers then
            Quest:RemoveNPCMarkers();
        end
        Quest:RemoveQuestMarkers();
        Quest:Fail();
    end
end
FailQuestByName = API.FailQuest;

---
-- Startet eine Liste von Quests neu.
--
-- Alias: StartQuestsByName
--
-- @param ...  Liste mit Quests
-- @within Quest-Funktionen
--
function API.RestartAllQuests(...)
    for i=1, #args, 1 do
        API.RestartQuest(args[i]);
    end
end
StartQuestsByName = API.RestartAllQuests;

---
-- Startet den Quest neu.
--
-- Der Quest muss beendet sein um ihn wieder neu zu starten. Wird ein Quest
-- neu gestartet, müssen auch alle Trigger wieder neu ausgelöst werden, außer
-- der Quest wird manuell getriggert.
--
-- Alias: StartQuestByName
--
-- @param _QuestName  Name des Quest
-- @within Quest-Funktionen
--
function API.RestartQuest(_QuestName)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
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
StartQuestByName = API.StartQuest;

---
-- Startet eine Liste von Quests.
--
-- Alias: StartQuestsByName
--
-- @param ...  Liste mit Quests
-- @within Quest-Funktionen
--
function API.StartAllQuests(...)
    for i=1, #args, 1 do
        API.StartQuest(args[i]);
    end
end
StartQuestsByName = API.StartAllQuests;

---
-- Startet den Quest sofort, sofern er existiert.
--
-- Dabei ist es unerheblich, ob die Bedingungen zum Start erfüllt sind.
--
-- Alias: StartQuestByName
--
-- @param _QuestName  Name des Quest
-- @within Quest-Funktionen
--
function API.StartQuest(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        Quest:SetMsgKeyOverride();
        Quest:SetIconOverride();
        Quest:Trigger();
    end
end
StartQuestByName = API.StartQuest;

---
-- Unterbricht eine Liste von Quests.
--
-- Alias: StopQuestsByName
--
-- @param ...  Liste mit Quests
-- @within Quest-Funktionen
--
function API.StopAllQuests(...)
    for i=1, #args, 1 do
        API.StopQuest(args[i]);
    end
end
StopQuestwByName = API.StopAllQuests;

---
-- Unterbricht den Quest.
--
-- Der Status wird auf Over und das Resultat auf Interrupt gesetzt. Sind Marker
-- gesetzt, werden diese entfernt.
--
-- Alias: StopQuestByName
--
-- @param _QuestName  Name des Quest
-- @within Quest-Funktionen
--
function API.StopQuest(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if Quest.RemoveNPCMarkers then
            Quest:RemoveNPCMarkers();
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
-- Alias: WinQuestsByName
--
-- @param ...  Liste mit Quests
-- @within Quest-Funktionen
--
function API.WinAllQuests(...)
    for i=1, #args, 1 do
        API.WinQuest(args[i]);
    end
end
WinQuestsByName = API.WinAllQuests;

---
-- Gewinnt den Quest.
--
-- Der Status wird auf Over und das Resultat auf Success gesetzt.
--
-- Alias: WinQuestByName
--
-- @param _QuestName  Name des Quest
-- @within Quest-Funktionen
--
function API.WinQuest(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if Quest.RemoveNPCMarkers then
            Quest:RemoveNPCMarkers();
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
-- Alias: GUI_Note
--
-- @param _Message Anzeigetext
-- @within Message-Funktionen
--
function API.Note(_Message)
    _Message = tostring(_Message);
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
-- @param _Message Anzeigetext
-- @within Message-Funktionen
--
function API.StaticNote(_Message)
    _Message = tostring(_Message);
    if not GUI then
        Logic.ExecuteInLuaLocalState('GUI.AddStaticNote("' .._Message.. '")');
        return;
    end
    GUI.AddStaticNote(_Message);
end

---
-- Löscht alle Nachrichten im Debug Window.
--
-- @within Message-Funktionen
--
function API.ClearNotes()
    if not GUI then
        Logic.ExecuteInLuaLocalState('GUI.ClearNotes()');
        return;
    end
    GUI.ClearNotes();
end

---
-- Schreibt eine einzelne Zeile Text ins Log. Vor dem Text steh, ob aus dem
-- globalen oder lokalen Skript geschrieben wurde und bei welchem Turn des
-- Spiels die Nachricht gesendet wurde.
--
-- @param _Message Nachricht für's Log
-- @within Message-Funktionen
--
function API.Log(_Message)
    local Env  = (GUI and "Local") or "Global";
    local TUrn = Logic.GetTimeMs();
    Framework.WriteToLog(Env.. ":" ..Turn.. ": " .._Message);
end

---
-- Schreibt eine Nachricht in das Nachrichtenfenster unten in der Mitte.
--
-- @param _Message Anzeigetext
-- @within Message-Funktionen
--
function API.Message(_Message)
    _Message = tostring(_Message);
    if not GUI then
        Logic.ExecuteInLuaLocalState('Message("' .._Message.. '")');
        return;
    end
    Message(_Message);
end

-- Entities --------------------------------------------------------------------

---
-- Ermittelt alle Entities in der Kategorie auf dem Territorium und gibt
-- sie als Liste zurück.
--
-- @param _player    PlayerID [0-8] oder -1 für alle
-- @param _category  Kategorie, der die Entities angehören
-- @param _territory Zielterritorium
-- @within Entity-Funktionen
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

-- Overwrite -------------------------------------------------------------------

---
-- Hängt eine Funktion an Mission_OnSaveGameLoaded an, sodass sie nach dem
-- Laden eines Spielstandes ausgeführt wird.
--
-- @param _Function Funktion, die ausgeführt werden soll
-- @within Overwrite-Funktionen
--
function API.AddSaveGameAction(_Function)
    return QsbFramework:AddSaveGameAction(_Function)
end

-- -------------------------------------------------------------------------- --
-- Application Space                                                          --
-- -------------------------------------------------------------------------- --

QsbFramework = {
    Data = {
        Append = {
            Functions = {},
            Fields = {},
        }
    }
}

---
-- Initialisiert alle verfügbaren Bundles und führt ihre Install-Methode aus.
-- Bundles werden immer getrennt im globalen und im lokalen Skript gestartet.
-- @within QsbFramework Class
-- @local
--
function QsbFramework:InitalizeBundles()
    for k,v in pairs(self.Data.BundleInitializerList) do
        if not GUI then
            self:SetupGobal_HackCreateQuest();
            self:SetupGlobal_HackQuestSystem();
            if v.Global ~= nil and v.Global.Install ~= nil then
                v.Global:Install();
            end
        else
            if v.Local ~= nil and v.Local.Install ~= nil then
                v.Local:Install();
            end
        end
    end
end

---
-- FIXME
-- @local
--
function QsbFramework:SetupGobal_HackCreateQuest()
    CreateQuest = function(_QuestName, _QuestGiver, _QuestReceiver, _QuestHidden, _QuestTime, _QuestDescription, _QuestStartMsg, _QuestSuccessMsg, _QuestFailureMsg)
        local Triggers = {}
        local Goals = {}
        local Reward = {}
        local Reprisal = {}
        local NumberOfBehavior = Logic.Quest_GetQuestNumberOfBehaviors(_QuestName)
        for i=0,NumberOfBehavior-1 do
            local BehaviorName = Logic.Quest_GetQuestBehaviorName(_QuestName, i)
            local BehaviorTemplate = GetBehaviorTemplateByName(BehaviorName)
            assert( BehaviorTemplate, "No template for name: " .. BehaviorName .. " - using an invalid QuestSystemBehavior.lua?!" )
            local NewBehavior = {}
            Table_Copy(NewBehavior, BehaviorTemplate)
            local Parameter = Logic.Quest_GetQuestBehaviorParameter(_QuestName, i)
            for j=1,#Parameter do
                NewBehavior:AddParameter(j-1, Parameter[j])
            end
            if (NewBehavior.GetGoalTable ~= nil) then
                Goals[#Goals + 1] = NewBehavior:GetGoalTable()
                Goals[#Goals].Context = NewBehavior
                Goals[#Goals].FuncOverrideIcon = NewBehavior.GetIcon
                Goals[#Goals].FuncOverrideMsgKey = NewBehavior.GetMsgKey
            end
            if (NewBehavior.GetTriggerTable ~= nil) then
                Triggers[#Triggers + 1] = NewBehavior:GetTriggerTable()
            end
            if (NewBehavior.GetReprisalTable ~= nil) then
                Reprisal[#Reprisal + 1] = NewBehavior:GetReprisalTable()
            end
            if (NewBehavior.GetRewardTable ~= nil) then
                Reward[#Reward + 1] = NewBehavior:GetRewardTable()
            end
        end
        if (#Triggers == 0) or (#Goals == 0) then
            return
        end
        if ValidateQuestName(_QuestName) then
            local QuestID = QuestTemplate:New(_QuestName, _QuestGiver, _QuestReceiver,
                                                    Goals,
                                                    Triggers,
                                                    assert( tonumber(_QuestTime) ),
                                                    Reward,
                                                    Reprisal,
                                                    nil, nil,
                                                    (not _QuestHidden or ( _QuestStartMsg and _QuestStartMsg ~= "") ),
                                                    (not _QuestHidden or ( _QuestSuccessMsg and _QuestSuccessMsg ~= "") or ( _QuestFailureMsg and _QuestFailureMsg ~= "") ),
                                                    _QuestDescription, _QuestStartMsg, _QuestSuccessMsg, _QuestFailureMsg)
            g_QuestNameToID[_QuestName] = QuestID
        else
            dbg("Quest '"..tostring(questName).."': invalid questname! Contains forbidden characters!");
        end
    end
end

---
-- FIXME
-- @local
--
function QsbFramework:SetupGlobal_HackQuestSystem()
    QuestTemplate.Trigger_Orig_QSB_Core = QuestTemplate.Trigger
    QuestTemplate.Trigger = function(_quest)
        QuestTemplate.Trigger_Orig_QSB_Core(_quest);
        for i=1,_quest.Objectives[0] do
            if _quest.Objectives[i].Type == Objective.Custom2 and _quest.Objectives[i].Data[1].SetDescriptionOverwrite then
                local Desc = _quest.Objectives[i].Data[1]:SetDescriptionOverwrite(_quest);
                SetQuestDescriptionText(_quest.Identifier, Desc);
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
-- Registiert ein Bundle, sodass es initialisiert wird.
--
-- @param _Bundle Name des Moduls
-- @within QsbFramework Class
-- @local
--
function QsbFramework:RegisterBundle(_Bundle)
    if not _G[_Bundle] and not GUI then
        local text = string.format("Error while initialize bundle '%s': does not exist!", tostring(_Bundle));
        assert(false, text);
        return;
    end
    table.insert(self.Data.BundleInitializerList, _G[_Bundle]);
end

---
-- Bereitet ein Behavior für den Einsatz im Assistenten und im Skript vor.
-- Erzeugt zudem den Konstruktor.
--
-- @param _Behavior    Behavior-Objekt
-- @within QsbFramework Class
-- @local
--
function QsbFramework:RegisterBehavior(_Behavior)
    if _Behavior.RequiresExtraNo and _Behavior.RequiresExtraNo > g_GameExtraNo then
        return;
    end

    if not _G["b_" .. _Behavior.Name] then
        dbg("AddQuestBehavior: can not find ".. _Behavior.Name .."!");
        return;
    end

    if not _G["b_" .. _Behavior.Name].new then
        _G["b_" .. _Behavior.Name].new = function(self, ...)
            local behavior = self:CopyTableRecursive(self);
            if self.Parameter then
                for i=1,table.getn(self.Parameter) do
                    behavior:AddParameter(i-1, arg[i]);
                end
            end
            return behavior;
        end
    end

    -- _G[_Behavior.Name] = function(...)
    --     return _G["b_" .. _Behavior.Name]:new(...);
    -- end
    table.insert(g_QuestBehaviorTypes, _Behavior);
end

---
-- Prüft, ob der Questname formal korrekt ist. Questnamen dürfen i.d.R. nur
-- die Zeichen A-Z, a-7, 0-9, - und _ enthalten.
--
-- @param _Name     Quest
-- @return boolean
-- @within QsbFramework Class
-- @local
--
function QsbFramework:CheckQuestName(_Name)
    return not string.find(__quest_, "[ \"§$%&/\(\)\[\[\?ß\*+#,;:\.^\<\>\|]");
end

---
-- Ändert den Text des Beschreibungsfensters eines Quests. Die Beschreibung
-- wird erst dann aktualisiert, wenn der Quest ausgeblendet wird.
--
-- @param _Text   Neuer Text
-- @param _Quest  Identifier des Quest
-- @within QsbFramework Class
-- @local
--
function QsbFramework:ChangeCustomQuestCaptionText(_Text, _Quest)
    _Quest.QuestDescription = Umlaute(__text_);
    Logic.ExecuteInLuaLocalState([[
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/BGDeco",0)
        local identifier = "]].._Quest.Identifier..[["
        for i=1, Quests[0] do
            if Quests[i].Identifier == identifier then
                local text = Quests[i].QuestDescription
                XGUIEng.SetText("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/Text", "]].._Text..[[")
                break;
            end
        end
    ]]);
end

---
-- Hängt eine Funktion an Mission_OnSaveGameLoaded an, sodass sie nach dem
-- Laden eines Spielstandes ausgeführt wird.
--
-- @param _Function Funktion, die ausgeführt werden soll
-- @local
--
function QsbFramework:AddSaveGameAction(_Function)
    if not Mission_OnSaveGameLoaded_Orig_QSB_Append then
        Mission_OnSaveGameLoaded_Orig_QSB_Append = Mission_OnSaveGameLoaded;
        Mission_OnSaveGameLoaded = function()
            Mission_OnSaveGameLoaded_Orig_QSB_Append();

            for i=1, #self.Data.Overwrite.Functions.SaveGame, 1 do
                self.Data.Overwrite.Functions.SaveGame[i]();
            end
        end
    end

    self.Data.Append.Functions.SaveGame = self.Data.Append.Functions.SaveGame or {};
    table.insert(self.Data.Append.Functions.SaveGame, _Function);
end

---
-- Wandelt underschiedliche Darstellungen einer Boolean in eine echte um.
--
-- @param _Input Boolean-Darstellung
-- @return boolean
-- @local
--
function QsbFramework:ToBoolean(_Input)
    local Suspicious = tostring(_Input);
    if Suspicious == true or Suspicious == "true" or Suspicious == "Yes" or Suspicious == "On" or Suspicious == "+" then
        return true;
    end
    if Suspicious == false or Suspicious == "false" or Suspicious == "No" or Suspicious == "Off" or Suspicious == "-" then
        return false;
    end
    return false;
end
