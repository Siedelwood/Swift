-- Quests ----------------------------------------------------------------------

-- API Stuff --

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
function API.IsValidQuest(_QuestID)
    return Quests[_QuestID] ~= nil or Quests[API.GetQuestID(_QuestID)] ~= nil;
end
IsValidQuest = API.IsValidQuest;

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
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Anwenderfunktionen
--
function API.FailQuest(_QuestName, _NoMessage)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if not _NoMessage then
            API.Note("fail quest " .._QuestName);
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
-- ein Standardbehavior in einem Bundle verändert, muss auch diese Funktion
-- angepasst oder überschrieben werden.
--
-- <p><b>Alias:</b> RestartQuestByName</p>
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Anwenderfunktionen
--
function API.RestartQuest(_QuestName, _NoMessage)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            API.Note("restart quest " .._QuestName);
        end

        if Quest.Objectives then
            local questObjectives = Quest.Objectives;
            for i = 1, questObjectives[0] do
                local objective = questObjectives[i];
                objective.Completed = nil
                local objectiveType = objective.Type;

                if objectiveType == Objective.Deliver then
                    local data = objective.Data;
                    data[3] = nil;
                    data[4] = nil;
                    data[5] = nil;

                elseif g_GameExtraNo and g_GameExtraNo >= 1 and objectiveType == Objective.Refill then
                    objective.Data[2] = nil;

                elseif objectiveType == Objective.Protect or objectiveType == Objective.Object then
                    local data = objective.Data;
                    for j=1, data[0], 1 do
                        data[-j] = nil;
                    end

                elseif objectiveType == Objective.DestroyEntities and objective.Data[1] == 2 and objective.DestroyTypeAmount then
                    objective.Data[3] = objective.DestroyTypeAmount;
                elseif objectiveType == Objective.DestroyEntities and objective.Data[1] == 3 then
                    objective.Data[4] = nil;

                elseif objectiveType == Objective.Distance then
                    if objective.Data[1] == -65565 then
                        objective.Data[4].NpcInstance = nil;
                    end

                elseif objectiveType == Objective.Custom2 and objective.Data[1].Reset then
                    objective.Data[1]:Reset(Quest, i);
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

        Quest.Result = nil;
        local OldQuestState = Quest.State;
        Quest.State = QuestState.NotTriggered;
        Logic.ExecuteInLuaLocalState("LocalScriptCallback_OnQuestStatusChanged("..Quest.Index..")");
        if OldQuestState == QuestState.Over then
            StartSimpleJobEx(_G[QuestTemplate.Loop], Quest.QueueID);
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
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Anwenderfunktionen
--
function API.StartQuest(_QuestName, _NoMessage)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if not _NoMessage then
            API.Note("start quest " .._QuestName);
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
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Anwenderfunktionen
--
function API.StopQuest(_QuestName, _NoMessage)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if not _NoMessage then
            API.Note("interrupt quest " .._QuestName);
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
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Anwenderfunktionen
--
function API.WinQuest(_QuestName, _NoMessage)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if not _NoMessage then
            API.Note("win quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Success();
    end
end
WinQuestByName = API.WinQuest;

-- Core Stuff --

---
-- Prüft, ob der Questname formal korrekt ist. Questnamen dürfen i.d.R. nur
-- die Zeichen A-Z, a-7, 0-9, Umlaute und _ enthalten.
--
-- @param[type=string] _Name Name des Quest
-- @return[type=boolean] Questname ist fehlerfrei
-- @within Internal
-- @local
--
function Core:CheckQuestName(_Name)
    return string.find(_Name, "^[A-Za-z0-9_ ÄÖÜäöüß]+$") ~= nil;
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
    if _Quest and _Quest.Visible then
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
end

