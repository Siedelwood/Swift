-- Core API ----------------------------------------------------------------- --

---
-- TODO: add doc
--
-- @within Beschreibung
-- @set sort=true
--
Swift = Swift or {};

---
-- TODO: Add doc
--
-- @within Anwenderfunktionen
--
function API.Install()
    Swift:LoadCore();
    Swift:LoadModules();
end

-- Lua base functions

function API.OverrideTable()
    ---
    -- TODO: Add doc
    -- @within table
    --
    table.contains = function (t, e)
        for k, v in ipairs(t) do
            if v == e then return true; end
        end
        return false;
    end

    ---
    -- TODO: Add doc
    -- @within table
    --
    table.copy = function (t1, t2)
        return Swift:CopyTable(t1, t2);
    end

    ---
    -- TODO: Add doc
    -- @within table
    --
    table.invert = function (t1)
        local t2 = {};
        for i= #t1, 1, -1 do
            table.insert(t2, t1[i]);
        end
        return t2;
    end

    ---
    -- TODO: Add doc
    -- @within table
    --
    table.push = function (t, e)
        table.insert(t, 1, e);
    end

    ---
    -- TODO: Add doc
    -- @within table
    --
    table.pop = function (t, e)
        return table.remove(t, 1);
    end

    ---
    -- TODO: Add doc
    -- @within table
    --
    table.tostring = function(t)
        assert(type(t) == "table");
        local s = "{";
        for k, v in pairs(t) do
            local key;
            if (tonumber(k)) then
                key = ""..k;
            else
                key = "\""..k.."\"";
            end
            if type(v) == "table" then
                s = s .. "[" .. key .. "] = " .. table.tostring(v) .. ", ";
            elseif type(v) == "number" then
                s = s .. "[" .. key .. "] = " .. v .. ", ";
            elseif type(v) == "string" then
                s = s .. "[" .. key .. "] = \"" .. v .. "\", ";
            elseif type(v) == "boolean" or type(v) == "nil" then
                s = s .. "[" .. key .. "] = " .. tostring(v) .. ", ";
            else
                s = s .. "[" .. key .. "] = \"" .. tostring(v) .. "\", ";
            end
        end
        s = s .. "}";
        return s;
    end
end

function API.OverrideString()
    -- TODO: Implement!

    ---
    -- TODO: Add doc
    -- @within string
    --
    string.contains = function (self, s)
        return self:find(s) ~= nil;
    end

    ---
    -- TODO: Add doc
    -- @within string
    --
    string.indexOf = function (self, s)
        return self:find(s);
    end
end

---
-- TODO: Add doc
--
-- @within Anwenderfunktionen
--
function API.ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
    Swift:ActivateDebugMode(
        _CheckAtRun == true,
        _TraceQuests == true,
        _DevelopingCheats == true,
        _DevelopingShell == true
    );
end

---
-- TODO: Add doc
--
-- @within Anwenderfunktionen
--
function API.IsDebugBehaviorCheckActive()
    return Swift.m_CheckAtRun == true;
end

---
-- TODO: Add doc
--
-- @within Anwenderfunktionen
--
function API.IsDebugQuestTraceActive()
    return Swift.m_TraceQuests == true;
end

---
-- TODO: Add doc
--
-- @within Anwenderfunktionen
--
function API.IsDebugCheatsActive()
    return Swift.m_DevelopingCheats == true;
end

---
-- TODO: Add doc
--
-- @within Anwenderfunktionen
--
function API.IsDebugShellActive()
    return Swift.m_DevelopingShell == true;
end

---
-- TODO: Add doc
--
-- @within Anwenderfunktionen
--
function API.RegisterScriptEvent(_Name, _Function)
    return Swift:CreateScriptEvent(_Name, _Function);
end

---
-- TODO: Add doc
--
-- @within Anwenderfunktionen
--
function API.RemoveScriptEvent(_ID)
    return Swift:RemoveScriptEvent(_ID);
end

---
-- TODO: Add doc
--
-- @within Anwenderfunktionen
--
function API.SendScriptEvent(_ID, ...)
    Swift:DispatchScriptEvent(_ID, unpack(arg));
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
    return Swift:ToBoolean(_Value);
end
AcceptAlternativeBoolean = API.ToBoolean;

---
-- Rundet eine Dezimalzahl kaufmännisch ab.
--
-- <b>Hinweis</b>: Es wird manuell gerundet um den Rundungsfehler in der
-- History Edition zu umgehen.
--
-- <p><b>Alias:</b> Round</p>
--
-- @param[type=string] _Value         Zu rundender Wert
-- @param[type=string] _DecimalDigits Maximale Dezimalstellen
-- @return[type=number] Abgerundete Zahl
-- @within Anwenderfunktionen
--
function API.Round(_Value, _DecimalDigits)
    _DecimalDigits = _DecimalDigits or 2;
    _DecimalDigits = (_DecimalDigits < 0 and 0) or _DecimalDigits;
    local Value = tostring(_Value);
    if tonumber(Value) == nil then
        return 0;
    end
    local s,e = Value:find(".", 1, true);
    if e then
        local Overhead = nil;
        if Value:len() > e + _DecimalDigits then
            if _DecimalDigits > 0 then
                local TmpNum;
                if tonumber(Value:sub(e+_DecimalDigits+1, e+_DecimalDigits+1)) >= 5 then
                    TmpNum = tonumber(Value:sub(e+1, e+_DecimalDigits)) +1;
                    Overhead = (_DecimalDigits == 1 and TmpNum == 10);
                else
                    TmpNum = tonumber(Value:sub(e+1, e+_DecimalDigits));
                end
                Value = Value:sub(1, e-1);
                if (tostring(TmpNum):len() >= _DecimalDigits) then
                    Value = Value .. "." ..TmpNum;
                end
            else
                local NewValue = tonumber(Value:sub(1, e-1));
                if tonumber(Value:sub(e+_DecimalDigits+1, e+_DecimalDigits+1)) >= 5 then
                    NewValue = NewValue +1;
                end
                Value = NewValue;
            end
        else
            Value = (Overhead and (tonumber(Value) or 0) +1) or
                     Value .. string.rep("0", Value:len() - (e + _DecimalDigits))
        end
    end
    return tonumber(Value);
end
Round = API.Round;

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
-- Prüft den angegebenen Questnamen auf verbotene Zeichen.
--
-- <p><b>Alias:</b> IsValidQuestName</p>
--
-- @param[type=number] _Name Name des Quest
-- @return[type=boolean] Name ist gültig
-- @within Anwenderfunktionen
--
function API.IsValidQuestName(_Name)
    return string.find(_Name, "^[A-Za-z0-9_ @ÄÖÜäöüß]+$") ~= nil;
end
IsValidQuestName = API.IsValidQuestName;

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
            Logic.DEBUG_AddNote("fail quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Fail();
        Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestFailure, QuestID);
    end
end
FailQuestByName = API.FailQuest;

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
            Logic.DEBUG_AddNote("restart quest " .._QuestName);
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

        -- Quest Output zurücksetzen
        if Quest.Visible_OrigDebug then
            Quest.Visible = Quest.Visible_OrigDebug;
            Quest.Visible_OrigDebug = nil;
        end
        if Quest.ShowEndMessage then
            Quest.ShowEndMessage = Quest.ShowEndMessage_OrigDebug;
            Quest.ShowEndMessage_OrigDebug = nil;
        end
        if Quest.QuestStartMsg_OrigDebug then
            Quest.QuestStartMsg = Quest.QuestStartMsg_OrigDebug;
            Quest.QuestStartMsg_OrigDebug = nil;
        end
        if Quest.QuestSuccessMsg_OrigDebug then
            Quest.QuestSuccessMsg = Quest.QuestSuccessMsg_OrigDebug;
            Quest.QuestSuccessMsg_OrigDebug = nil;
        end
        if Quest.QuestFailureMsg_OrigDebug then
            Quest.QuestFailureMsg = Quest.QuestFailureMsg_OrigDebug;
            Quest.QuestFailureMsg_OrigDebug = nil;
        end

        Quest.Result = nil;
        local OldQuestState = Quest.State;
        Quest.State = QuestState.NotTriggered;
        Logic.ExecuteInLuaLocalState("LocalScriptCallback_OnQuestStatusChanged("..Quest.Index..")");
        if OldQuestState == QuestState.Over then
            StartSimpleJobEx(_G[QuestTemplate.Loop], Quest.QueueID);
        end
        Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestReset, QuestID);
        return QuestID, Quest;
    end
end
RestartQuestByName = API.RestartQuest;

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
            Logic.DEBUG_AddNote("start quest " .._QuestName);
        end
        Quest:SetMsgKeyOverride();
        Quest:SetIconOverride();
        Quest:Trigger();
        Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestTrigger, QuestID);
    end
end
StartQuestByName = API.StartQuest;

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
            Logic.DEBUG_AddNote("interrupt quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Interrupt(-1);
        Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestInterrupt, QuestID);
    end
end
StopQuestByName = API.StopQuest;

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
            Logic.DEBUG_AddNote("win quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Success();
        Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestSuccess, QuestID);
    end
end
WinQuestByName = API.WinQuest;

