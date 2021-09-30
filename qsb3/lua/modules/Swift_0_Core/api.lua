--[[
Swift_0_Core/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Stellt wichtige Kernfunktionen bereit.
--
-- @within Beschreibung
-- @set sort=true
--
Swift = Swift or {};

QSB.Metatable = {Init = false, Weak = {}, Metas = {}, Key = 0};

---
-- Installiert Swift.
--
-- @within Anwenderfunktionen
-- @local
--
function API.Install()
    Swift:LoadCore();
    Swift:LoadModules();
    collectgarbage("collect");
end

---
-- Prüft, ob das laufende Spiel in der History Edition gespielt wird.
--
-- @return[type=boolean] Spiel ist History Edition
-- @within Anwenderfunktionen
--
function API.IsHistoryEdition()
    return Swift:IsHistoryEdition();
end

---
-- Prüft, ob das laufende Spiel eine Multiplayerpartie in der History Edition
-- ist.
--
-- <b>Hinweis</b>: Es ist unmöglich, dass Original und History Edition in einer
-- Partie aufeinander treffen, da die alten Server längst abgeschaltet und die
-- Option zum LAN-Spiel in der HE nicht verfügbar ist.
--
-- @return[type=boolean] Spiel ist History Edition
-- @within Anwenderfunktionen
--
function API.IsHistoryEditionNetworkGame()
    return API.IsHistoryEdition() and Framework.IsNetworkGame();
end

-- Lua base functions

function API.OverrideTable()
    ---
    -- Vergleicht zwei Tables anhand der übergebenen Vergleichsfunktion.
    -- @param[type=table]    t1 Table 1
    -- @param[type=table]    t2 Table 2
    -- @param[type=function] fx Vergleichsfunktion
    -- @within table
    --
    table.compare = function(t1, t2, fx)
        assert(type(t1) == "table");
        assert(type(t2) == "table");
        fx = fx or function(t1, t2)
            return tostring(t1) < tostring(t2);
        end
        assert(type(fx) == "function");
        return fx(t1, t2);
    end

    ---
    -- Prüft, ob ein Table identisch zu einem anderen ist. Zwei Tables sind
    -- gleich, wenn ihre Inhalte gleich sind.
    -- @param[type=table] t1 Table 1
    -- @param[type=table] t2 Table 2
    -- @within table
    --
    table.equals = function(t1, t2)
        assert(type(t1) == "table");
        assert(type(t2) == "table");
        for k, v in pairs(t1) do
            if type(v) == "table" then
                if not t2[k] or not table.equals(t2[k], v) then
                    return false;
                end
            elseif type(v) ~= "thread" and type(v) ~= "userdata" then
                if not t2[k] or t2[k] ~= v then
                    return false;
                end
            end
        end
        return true;
    end
    
    ---
    -- Prüft, ob ein Element in einer eindimensionenen Table enthalten ist.
    -- @param[type=table] t Table
    -- @param             e Element
    -- @within table
    --
    table.contains = function (t, e)
        assert(type(t) == "table");
        for k, v in ipairs(t) do
            if v == e then return true; end
        end
        return false;
    end

    ---
    -- Erzeugt eine Deep Copy der Tabelle und schreibt alle Werte optional in
    -- eine weitere Tabelle.
    -- @param[type=table] t1 Quelle
    -- @param[type=table] t2 (Optional) Ziel
    -- @return[type=table] Deep Copy
    -- @within table
    --
    table.copy = function (t1, t2)
        t2 = t2 or {};
        assert(type(t1) == "table");
        assert(type(t2) == "table");
        return Swift:CopyTable(t1, t2);
    end

    ---
    -- Kehr die Reihenfolge aller Elemente in einer Array Table um.
    -- @param[type=table] t1 Table
    -- @return[type=table] Invertierte Table
    -- @within table
    --
    table.invert = function (t1)
        assert(type(t1) == "table");
        local t2 = {};
        for i= #t1, 1, -1 do
            table.insert(t2, t1[i]);
        end
        return t2;
    end

    ---
    -- Fügt ein Element am Anfang einer Tabelle ein.
    -- @param[type=table] t Table
    -- @param             e Element
    -- @within table
    --
    table.push = function (t, e)
        assert(type(t) == "table");
        table.insert(t, 1, e);
    end

    ---
    -- Entfernt das erste Element einer Table und gibt es zurück.
    -- @param[type=table] t Table
    -- @return Element
    -- @within table
    --
    table.pop = function (t)
        assert(type(t) == "table");
        return table.remove(t, 1);
    end

    ---
    -- Serialisiert eine Table als String. Funktionen, Threads und Upvalues
    -- können nicht serialisiert werden.
    -- @param[type=table] t Table
    -- @return[type=string] Serialisierte Table
    -- @within table
    --
    table.tostring = function(t)
        return Swift:ConvertTableToString(t);
    end

    ---
    -- Setzt die Metatable für die übergebene Table.
    -- @param[type=table] t    Table
    -- @param[type=table] meta Metatable
    -- @within table
    --
    table.setMetatable = function(t, meta)
        assert(type(t) == "table");
        assert(type(meta) == "table" or meta == nil);
    
        local oldmeta = meta;
        meta = {};
        for k,v in pairs(oldmeta) do
            meta[k] = v;
        end
        oldmeta = getmetatable(t);
        setmetatable(t, meta);
        local k = 0;
        if oldmeta and oldmeta.KeySave and t == QSB.Metatable.Weak[oldmeta.KeySave] then
            k = oldmeta.KeySave;
            if meta == nil then
                QSB.Metatable.Weak[k] = nil;
                QSB.Metatablele.Metas[k] = nil;
                return;
            end
        else
            k = QSB.Metatable.Key + 1;
            QSB.Metatable.Key = k;
        end
        QSB.Metatable.Weak[k] = t;
        QSB.Metatable.Metas[k] = meta;
        meta.KeySave = k;
    end

    ---
    -- Erneuert alle Metatables und deren Referenzen.
    -- @within table
    -- @local
    --
    table.restoreMetatables = function()
        for k, tab in pairs(QSB.Metatable.Weak) do
            setmetatable(tab, QSB.Metatable.Metas[k]);
        end
        setmetatable(QSB.Metatable.Weak, {__mode = "v"});
        setmetatable(QSB.Metatable.Metas, {__mode = "v"});
    end
    table.restoreMetatables();
end

function API.OverrideString()
    -- TODO: Implement!

    ---
    -- Gibt true zurück, wenn der Teil-String enthalten ist.
    -- @param[type=string] s Pattern
    -- @return[type=boolean] Pattern vorhanden
    -- @within string
    --
    string.contains = function (self, s)
        return self:find(s) ~= nil;
    end

    ---
    -- Gibt die Position des Teil-String im String zurück.
    -- @param[type=string] s Pattern
    -- @return[type=number] Startindex
    -- @return[type=number] Endindex
    -- @within string
    --
    string.indexOf = function (self, s)
        return self:find(s);
    end
end

-- Debug

---
-- Aktiviert oder deaktiviert Optionen des Debug Mode.
--
-- <b>Hinweis:</b> Du kannst alle Optionen unbegrenzt oft beliebig ein-
-- und ausschalten.
--
-- @param[type=boolean] _CheckAtRun       Custom Behavior prüfen an/aus
-- @param[type=boolean] _TraceQuests      Quest Trace an/aus
-- @param[type=boolean] _DevelopingCheats Cheats an/aus
-- @param[type=boolean] _DevelopingShell  Eingabeaufforderung an/aus
-- @within Debug
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
-- Prüft, ob der Debug Behavior überprüfen darf.
--
-- <b>Hinweis:</b> Module müssen die Behandlung dieser Option selbst
-- inmpelentieren. Das Core Modul übernimmt diese Aufgabe nicht!
--
-- @return[type=boolean] Option Aktiv
-- @within Debug
--
function API.IsDebugBehaviorCheckActive()
    return Swift.m_CheckAtRun == true;
end

---
-- Prüft, ob Quest Trace benutzt wird.
--
-- @return[type=boolean] Option Aktiv
-- @within Debug
--
function API.IsDebugQuestTraceActive()
    return Swift.m_TraceQuests == true;
end

---
-- Prüft, ob die Cheats aktiviert sind.
--
-- @return[type=boolean] Option Aktiv
-- @within Debug
--
function API.IsDebugCheatsActive()
    return Swift.m_DevelopingCheats == true;
end

---
-- Prüft, ob die Eingabeaufforderung aktiv ist.
--
-- <b>Hinweis:</b> Viele Kommandos müssen von Modulen implementiert werden.
-- Siehe die Doku dieser Module.
--
-- @return[type=boolean] Option Aktiv
-- @within Debug
--
function API.IsDebugShellActive()
    return Swift.m_DevelopingShell == true;
end

-- Script Events

---
-- Legt ein neues Script Event an.
--
-- @param[type=string]   _Name     Identifier des Event
-- @return[type=number] ID des neuen Script Event
-- @within Event
--
function API.RegisterScriptEvent(_Name)
    return Swift:CreateScriptEvent(_Name, nil);
end

---
-- Legt eine neue Reaktion zu einem Skriptevent an.
--
-- @param[type=number]   ID        ID des Event
-- @param[type=function] _Function Funktionsreferenz
-- @return[type=number] ID der neuen Reaktion
-- @within Event
--
function API.RegisterScriptEventAction(_ID, _Function)
    return Swift:CreateScriptEventAction(_ID, _Function);
end

---
-- Deaktiviert oder aktiviert eine Reaktion auf ein Event.
--
-- @param[type=number]  _EventID  ID des Event
-- @param[type=number]  _ActionID ID der Reaktion
-- @param[type=boolean] _Flag     Inaktiv Flag
-- @within Event
--
function API.DisableScriptEventAction(_EventID, _ActionID, _Flag)
    return Swift:SetScriptEventActionActive(_EventID, _ActionID, not _Flag);
end

---
-- Sendet das Script Event mit der übergebenen ID und überträgt optional
-- Parameter.
--
-- @param[type=number] _ID ID des Event
-- @param              ... Optionale Parameter
-- @within Event
--
function API.SendScriptEvent(_ID, ...)
    Swift:DispatchScriptEvent(_ID, unpack(arg));
end

-- Base API

---
-- Speichert den Wert der Custom Variable im globalen und lokalen Skript.
--
-- Des weiteren wird in beiden Umgebungen ein Event ausgelöst, wenn der Wert
-- gesetzt wird. Das Event bekommt den Namen der Variable, den alten Wert und
-- den neuen Wert übergeben.
--
-- @param[type=boolean] _Name  Name der Custom Variable
-- @param               _Value Neuer Wert
-- @within Sonstige
--
-- @usage local Value = API.ObtainCustomVariable("MyVariable", 0);
--
function API.SaveCustomVariable(_Name, _Value)
    Swift:SetCustomVariable(_Name, _Value);
end

---
-- Gibt den aktuellen Wert der Custom Variable zurück oder den Default-Wert.
-- @param[type=boolean] _Name    Name der Custom Variable
-- @param               _Default (Optional) Defaultwert falls leer
-- @return Wert
-- @within Sonstige
--
-- @usage local Value = API.ObtainCustomVariable("MyVariable", 0);
--
function API.ObtainCustomVariable(_Name, _Default)
    local Value = QSB.CustomVariable[_Name];
    if not Value and _Default then
        Value = _Default;
    end
    return Value;
end

---
-- Ermittelt den lokalisierten Text anhand der eingestellten Sprache der QSB.
--
-- Wird ein normaler String übergeben, wird dieser sofort zurückgegeben. Bei
-- einem Table mit einem passenden Sprach-Key (de, en) wird die entsprechende
-- Sprache zurückgegeben. Sollte ein Nested Table übergeben werden, werden alle
-- Texte innerhalb des Tables rekursiv übersetzt als Table zurückgegeben. Alle
-- anderen Werte sind nicht in der Rückgabe enthalten.
--
-- @param _Text Anzeigetext (String oder Table)
-- @return Übersetzten Text oder Table mit Texten
-- @within Anwenderfunktionen
--
-- @usage -- Einstufige Table
-- local Text = API.Localize({de = "Deutsch", en = "English"});
-- -- Rückgabe: "Deutsch"
--
-- -- Mehrstufige Table
-- API.Localize{{de = "Deutsch", en = "English"}, {{1,2,3,4, de = "A", en = "B"}}}
-- -- Rückgabe: {"Deutsch", {"A"}}
--
function API.Localize(_Text)
    return Swift:Localize(_Text);
end

---
-- Stellt die angegebene Sprache zur Verwendung durch die QSB ein.
--
-- Alle von der QSB erzeugten Texte werden der übergebenen Sprache angepasst.
--
-- @param _Language Genutzte Sprache
-- @within Anwenderfunktionen
--
function API.ChangeDesiredLanguage(_Language)
    if GUI or type(_Language) ~= "string" or _Language:len() ~= 2 then
        return;
    end
    Swift:ChangeSystemLanguage(_Language);
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
-- @within Sonstige
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
-- @within Sonstige
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
-- Fügt eine Bedingung für Quicksaves hinzu.
--
-- Die Bedingungsfunktion erwartet keine Parameter und muss true zurückgeben,
-- kein Quicksave möglich sein soll.
--
-- <b>Hinweis:</b> Nur im lokalen Skript möglich!
--
-- @param[type=function] _Function Bedingungsprüfung
-- @within Anwenderfunktionen
--
function API.AddBlockQuicksaveCondition(_Function)
    if not GUI or type(_Function) ~= "function" then
        return;
    end
    Swift:AddBlockQuicksaveCondition(_Function);
end

---
-- Gibt die ID des Quests mit dem angegebenen Namen zurück. Existiert der
-- Quest nicht, wird nil zurückgegeben.
--
-- <p><b>Alias:</b> GetQuestID</p>
--
-- @param[type=string] _Name Name des Quest
-- @return[type=number] ID des Quest
-- @within Quest
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
-- @within Quest
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
-- @within Quest
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
-- @within Quest
--
function API.FailQuest(_QuestName, _NoMessage)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            Logic.DEBUG_AddNote("fail quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Fail();
        Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestFailure, QuestID);
        Logic.ExecuteInLuaLocalState(string.format(
            "Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestFailure, %d)",
            QuestID
        ));
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
-- @within Quest
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
        Logic.ExecuteInLuaLocalState(string.format(
            "Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestReset, %d)",
            QuestID
        ));
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
-- @within Quest
--
function API.StartQuest(_QuestName, _NoMessage)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            Logic.DEBUG_AddNote("start quest " .._QuestName);
        end
        Quest:SetMsgKeyOverride();
        Quest:SetIconOverride();
        Quest:Trigger();
        Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestTrigger, QuestID);
        Logic.ExecuteInLuaLocalState(string.format(
            "Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestTrigger, %d)",
            QuestID
        ));
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
-- @within Quest
--
function API.StopQuest(_QuestName, _NoMessage)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            Logic.DEBUG_AddNote("interrupt quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Interrupt(-1);
        Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestInterrupt, QuestID);
        Logic.ExecuteInLuaLocalState(string.format(
            "Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestInterrupt, %d)",
            QuestID
        ));
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
-- @within Quest
--
function API.WinQuest(_QuestName, _NoMessage)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            Logic.DEBUG_AddNote("win quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Success();
        Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestSuccess, QuestID);
        Logic.ExecuteInLuaLocalState(string.format(
            "Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestSuccess, %d)",
            QuestID
        ));
    end
end
WinQuestByName = API.WinQuest;

function API.IsLoadscreenVisible()
    return Swift.m_LoadScreenHidden ~= true;
end

-- Entity

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
-- @within Entity
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
    -- TODO: Logging
    if Logic.IsEntityTypeInCategory(_Type, EntityCategories.Soldier) == 1 then
        return CreateBattalion(player, _Type, pos.X, pos.Y, 1, name, orientation);
    else
        return CreateEntity(player, _Type, pos, name, orientation);
    end
end
ReplaceEntity = API.ReplaceEntity;

---
-- Gibt den Typen des Entity zurück.
--
-- <b>Alias</b>: GetType
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Typ des Entity
-- @within Anwenderfunktionen
--
function API.GetEntityType(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return Logic.GetEntityType(EntityID);
    end
    error("API.EntityGetType: _Entity (" ..tostring(_Entity).. ") must be a leader with soldiers!");
    return 0;
end
GetType = API.GetEntityType

---
-- Gibt den Typnamen des Entity zurück.
--
-- <b>Alias</b>: GetTypeName
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=string] Typname des Entity
-- @within Anwenderfunktionen
--
function API.GetEntityTypeName(_Entity)
    if not IsExisting(_Entity) then
        error("API.GetEntityTypeName: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    return Logic.GetEntityTypeName(API.GetEntityType(_Entity));
end
GetTypeName = API.GetEntityTypeName;

---
-- Setzt das Entity oder das Battalion verwundbar oder unverwundbar.
--
-- <b>Alias</b>: SetVulnerable
-- 
-- @param               _Entity Entity (Scriptname oder ID)
-- @param[type=boolean] _Flag Verwundbar
-- @within Anwenderfunktionen
--
function API.SetEntityVulnerableFlag(_Entity, _Flag)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    local VulnerabilityFlag = (_Flag and 1) or 0;
    if EntityID > 0 then
        if API.CountSoldiersOfGroup(EntityID) > 0 then
            for k, v in pairs(API.GetGroupSoldiers(EntityID)) do
                Logic.SetEntityInvulnerabilityFlag(v, VulnerabilityFlag);
            end
        end
        Logic.SetEntityInvulnerabilityFlag(EntityID, VulnerabilityFlag);
    end
end
SetVulnerable = API.SetEntityVulnerableFlag;

MakeVulnerable = function(_Entity)
    API.SetEntityVulnerableFlag(_Entity, false);
end
MakeInvulnerable = function(_Entity)
    API.SetEntityVulnerableFlag(_Entity, true);
end

---
-- Rotiert ein Entity, sodass es zum Ziel schaut.
--
-- <p><b>Alias:</b> LookAt</p>
--
-- @param _entity         Entity (Skriptname oder ID)
-- @param _entityToLookAt Ziel (Skriptname oder ID)
-- @param[type=number]    _offsetEntity Winkel Offset
-- @within Entity
-- @usage API.LookAt("Hakim", "Alandra")
--
function API.LookAt(_entity, _entityToLookAt, _offsetEntity)
    local entity = GetID(_entity);
    local entityTLA = GetID(_entityToLookAt);
    if not IsExisting(entity) or not IsExisting(entityTLA) then
        warn("API.LookAt: One entity is invalid or dead!");
        return;
    end
    local eX, eY = Logic.GetEntityPosition(entity);
    local eTLAX, eTLAY = Logic.GetEntityPosition(entityTLA);
    local orientation = math.deg(math.atan2((eTLAY - eY) , (eTLAX - eX)));
    if Logic.IsBuilding(entity) == 1 then
        orientation = orientation - 90;
    end
    _offsetEntity = _offsetEntity or 0;
    info("API.LookAt: Entity " ..entity.. " is looking at " ..entityTLA);
    Logic.SetOrientation(entity, API.Round(orientation + _offsetEntity));
end
LookAt = API.LookAt;

---
-- Lässt zwei Entities sich gegenseitig anschauen.
--
-- <p><b>Alias:</b> ConfrontEntities</p>
--
-- @param _entity         Entity (Skriptname oder ID)
-- @param _entityToLookAt Ziel (Skriptname oder ID)
-- @within Entity
-- @usage API.Confront("Hakim", "Alandra")
--
function API.Confront(_entity, _entityToLookAt)
    API.LookAt(_entity, _entityToLookAt);
    API.LookAt(_entityToLookAt, _entity);
end
ConfrontEntities = API.LookAt;

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
-- @within Position
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
        warn("API.GetDistance: Distance could not be calculated!");
        return -1;
    end
    local xDistance = (_pos1.X - _pos2.X);
    local yDistance = (_pos1.Y - _pos2.Y);
    return math.sqrt((xDistance^2) + (yDistance^2));
end
GetDistance = API.GetDistance;

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

    -- Macht Waren lagerbar im Lagerhaus
    if resCat == GoodCategories.GC_Resource or _good == Goods.G_None then
        local TypeName = Logic.GetGoodTypeName(_good);
        local Category = Logic.GetGoodCategoryForGoodType(_good);
        local SHID = Logic.GetStoreHouse(_player);
        local HQID = Logic.GetHeadquarters(_player);
        if SHID ~= 0 and Logic.GetIndexOnInStockByGoodType(SHID, _good) == -1 then
            local CreateSlot = true;
            if _good ~= Goods.G_Gold or (_good == Goods.G_Gold and HQID == 0) then
                info(
                    "API.SendCart: creating stock for " ..TypeName.. " in" ..
                    "storehouse of player " .._player.. "."
                );
                Logic.AddGoodToStock(SHID, _good, 0, true, true);
            end
        end
    end

    info("API.SendCart: Creating cart ("..
        tostring(_position) ..","..
        tostring(_player) ..","..
        Logic.GetGoodTypeName(_good) ..","..
        tostring(_amount) ..","..
        tostring(_cartOverlay) ..","..
        tostring(_ignoreReservation) ..
    ")");

    if resCat == GoodCategories.GC_Resource then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_ResourceMerchant, x, y,orientation,_player)
    elseif _good == Goods.G_Medicine then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Medicus, x, y,orientation,_player)
    elseif _good == Goods.G_Gold or _good == Goods.G_None or _good == Goods.G_Information then
        if _cartOverlay then
            ID = Logic.CreateEntityOnUnblockedLand(_cartOverlay, x, y,orientation,_player)
        else
            ID = Logic.CreateEntityOnUnblockedLand(Entities.U_GoldCart, x, y,orientation,_player)
        end
    else
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Marketer, x, y,orientation,_player)
    end
    info("API.SendCart: Executing hire merchant...");
    Logic.HireMerchant( ID, _player, _good, _amount, _player, _ignoreReservation)
    info("API.SendCart: Cart has been send successfully.");
    return ID
end
SendCart = API.SendCart;

---
-- Setzt die Gesundheit des Entity. Optional kann die Gesundheit relativ zur
-- maximalen Gesundheit geändert werden.
--
-- <b>Alias</b>: SetHealth
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number]  _Health   Neue aktuelle Gesundheit
-- @param[type=boolean] _Relative (Optional) Relativ zur maximalen Gesundheit
-- @within Anwenderfunktionen
--
function API.ChangeEntityHealth(_Entity, _Health, _Relative)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
        if type(_Health) ~= "number" or _Health < 0 then
            error("API.ChangeEntityHealth: _Health " ..tostring(_Health).. "must be 0 or greater!");
            return
        end
        _Health = (_Health > MaxHealth and MaxHealth) or _Health;
        if Logic.IsLeader(EntityID) == 1 then
            for k, v in pairs(API.GetGroupSoldiers(EntityID)) do
                API.ChangeEntityHealth(v, _Health, _Relative);
            end
        else
            local OldHealth = Logic.GetEntityHealth(EntityID);
            local NewHealth = _Health;
            if _Relative then
                _Health = (_Health < 0 and 0) or _Health;
                _Health = (_Health > 100 and 100) or _Health;
                NewHealth = math.ceil((MaxHealth) * (_Health/100));
            end
            if NewHealth > OldHealth then
                Logic.HealEntity(EntityID, NewHealth - OldHealth);
            elseif NewHealth < OldHealth then
                Logic.HurtEntity(EntityID, OldHealth - NewHealth);
            end
        end
        return;
    end
    error("API.ChangeEntityHealth: _Entity (" ..tostring(_Entity).. ") does not exist!");
end
SetHealth = API.ChangeEntityHealth;

---
-- Gibt alle Kategorien zurück, zu denen das Entity gehört.
--
-- <b>Alias</b>: GetCategories
--
-- @param              _Entity Entity (Skriptname oder ID)
-- @return[type=table] Kategorien des Entity
-- @within Internal
-- @local
--
function API.GetEntityCategoyList(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetEntityCategoyList: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return {};
    end
    local Categories = {};
    for k, v in pairs(EntityCategories) do
        if Logic.IsEntityInCategory(EntityID, v) == 1 then 
            Categories[#Categories+1] = v;
        end
    end
    return Categories;
end
GetCategories = API.GetEntityCategoyList;

---
-- Prüft, ob das Entity mindestens eine der Kategorien hat.
--
-- <b>Alias</b>: IsInCategory
--
-- @param              _Entity Entity (Skriptname oder ID)
-- @param[type=number] ...     Liste mit Kategorien
-- @return[type=boolean] Entity hat Kategorie
-- @within Internal
-- @local
--
function API.IsEntityInAtLeastOneCategory(_Entity, ...)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        for k, v in pairs(arg) do
            if Inside(v, API.GetEntityCategoyList(_Entity)) then
                return true;
            end
        end
        return;
    end
    error("API.IsEntityInAtLeastOneCategory: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return false;
end
IsInCategory = API.IsEntityInAtLeastOneCategory;

---
-- Gibt die aktuelle Tasklist des Entity zurück.
--
-- <b>Alias</b>: GetTask
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Tasklist
-- @within Anwenderfunktionen
--
function API.GetEntityTaskList(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetEntityTaskList: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    local CurrentTask = Logic.GetCurrentTaskList(EntityID) or "";
    return TaskLists[CurrentTask];
end
GetTask = API.GetEntityTaskList;

---
-- Weist dem Entity ein Neues Model zu.
--
-- <b>Alias</b>: SetModel
--
-- @param              _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _NewModel Neues Model
-- @param[type=number] _AnimSet  (optional) Animation Set
-- @within Anwenderfunktionen
--
function API.SetEntityModel(_Entity, _NewModel, _AnimSet)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.SetEntityModel: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if type(_NewModel) ~= "number" or _NewModel < 1 then
        error("API.SetEntityModel: _NewModel (" ..tostring(_NewModel).. ") is wrong!");
        return;
    end
    if _AnimSet and (type(_AnimSet) ~= "number" or _AnimSet < 1) then
        error("API.SetEntityModel: _AnimSet (" ..tostring(_AnimSet).. ") is wrong!");
        return;
    end
    if not _AnimSet then
        Logic.SetModel(EntityID, _NewModel);
    else
        Logic.SetModelAndAnimSet(EntityID, _NewModel, _AnimSet);
    end
end
SetModel = API.SetEntityModel;

---
-- Setzt die aktuelle Tasklist des Entity.
--
-- <b>Alias</b>: SetTask
--
-- @param              _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _NewTask Neuer Task
-- @within Anwenderfunktionen
--
function API.SetEntityTaskList(_Entity, _NewTask)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.SetEntityTaskList: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if type(_NewTask) ~= "number" or _NewTask < 1 then
        error("API.SetEntityTaskList: _NewTask (" ..tostring(_NewTask).. ") is wrong!");
        return;
    end
    Logic.SetTaskList(EntityID, _NewTask);
end
SetTask = API.SetEntityTaskList;

---
-- Gibt die Ausrichtung des Entity zurück.
--
-- <b>Alias</b>: GetOrientation
--
-- @param               _Entity  Entity (Scriptname oder ID)
-- @return[type=number] Ausrichtung in Grad
-- @within Anwenderfunktionen
--
function API.GetEntityOrientation(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return API.Round(Logic.GetEntityOrientation(EntityID));
    end
    error("API.GetEntityOrientation: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return 0;
end
GetOrientation = API.GetEntityOrientation;

---
-- Setzt die Ausrichtung des Entity.
--
-- <b>Alias</b>: SetOrientation
--
-- @param               _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _Orientation Neue Ausrichtung
-- @within Anwenderfunktionen
--
function API.SetEntityOrientation(_Entity, _Orientation)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        if type(_Orientation) ~= "number" then
            error("API.SetEntityOrientation: _Orientation is wrong!");
            return
        end
        Logic.SetOrientation(EntityID, API.Round(_Orientation));
    else
        error("API.SetEntityOrientation: _Entity (" ..tostring(_Entity).. ") does not exist!");
    end
end
SetOrientation = API.SetEntityOrientation;

---
-- Gibt die Menge an Rohstoffen des Entity zurück. Optional kann
-- eine neue Menge gesetzt werden.
--
-- <b>Alias</b>: GetResource
--
-- @param _Entity  Entity (Scriptname oder ID)
-- @return[type=number] Menge an Rohstoffen
-- @within Anwenderfunktionen
--
function API.GetResourceAmount(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return Logic.GetResourceDoodadGoodAmount(EntityID);
    end
    error("API.GetResourceAmount: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return 0;
end
GetResource = API.GetResourceAmount

---
-- Setzt die Menge an Rohstoffen des Entity.
--
-- <b>Alias</b>: SetResource
--
-- @param              _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _Amount Menge an Rohstoffen
-- @within Anwenderfunktionen
--
function API.SetResourceAmount(_Entity, _Amount)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 or Logic.GetResourceDoodadGoodType(EntityID) > 0 then
        if type(_Amount) ~= "number" or _Amount < 0 then
            error("API.SetResourceAmount: _Amount must be 0 or greater!");
            return
        end
        if Logic.GetResourceDoodadGoodAmount(EntityID) == 0 then
            EntityID = API.ReplaceEntity(EntityID, Logic.GetEntityType(EntityID));
        end
        Logic.SetResourceDoodadGoodAmount(EntityID, _Amount);
    else
        error("API.SetResourceAmount: _Entity (" ..tostring(_Entity).. ") does not exist or is not a resource entity!");
    end
end
SetResource = API.SetResourceAmount;

-- Position

---
-- Lokalisiert ein Entity auf der Map. Es können sowohl Skriptnamen als auch
-- IDs verwendet werden. Wenn das Entity nicht gefunden wird, wird eine
-- Tabelle mit XYZ = 0 zurückgegeben.
--
-- <p><b>Alias:</b> GetPosition</p>
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=table] Positionstabelle {X= x, Y= y, Z= z}
-- @within Position
-- @usage local Position = API.LocateEntity("Hans")
--
function API.LocateEntity(_Entity)
    if _Entity == nil then
        return {X= 1, Y= 1, Z= 1};
    end
    if (type(_Entity) == "table") then
        return _Entity;
    end
    if (not IsExisting(_Entity)) then
        warn("API.LocateEntity: Entity (" ..tostring(_Entity).. ") does not exist!");
        return {X= 0, Y= 0, Z= 0};
    end
    local x, y, z = Logic.EntityGetPos(GetID(_Entity));
    return {X= API.Round(x), Y= API.Round(y), Z= API.Round(y)};
end
GetPosition = API.LocateEntity;

---
-- Bestimmt die Durchschnittsposition mehrerer Entities.
--
-- <p><b>Alias:</b> GetAveragePosition</p>
--
-- @param ... Positionen mit Komma getrennt
-- @return[type=table] Durchschnittsposition aller Positionen
-- @within Position
-- @usage local Center = API.GetGeometricFocus("Hakim", "Marcus", "Alandra");
--
function API.GetGeometricFocus(...)
    local SumX = 0;
    local SumY = 0;
    local SumZ = 0;
    for i= 1, #arg, 1 do
        local Position = arg[i];
        if type(arg[i]) ~= "table" then
            Position = GetPosition(arg[i]);
        end
        SumX = SumX + Position.X;
        SumY = SumY + Position.Y;
        if Position.Z then
            SumZ = SumZ + Position.Z;
        end
    end
    return {
        X= 1/#arg * SumX,
        Y= 1/#arg * SumY,
        Z= 1/#arg * SumZ
    };
end
GetAveragePosition = API.GetGeometricFocus;

---
-- Gib eine Position auf einer Linie im relativen Abstand zur ersten Position
-- zurück.
--
-- @param               _Pos1       Erste Position
-- @param               _Pos2       Zweite Position
-- @param[type=number]  _Percentage Entfernung zu Erster Position
-- @return[type=table] Position auf Linie
-- @within Position
-- @usage local Position = API.GetLinePosition("HQ1", "HQ2", 0.75);
--
function API.GetLinePosition(_Pos1, _Pos2, _Percentage)
    if _Percentage > 1 then
        _Percentage = _Percentage / 100;
    end

    if not API.ValidatePosition(_Pos1) and not IsExisting(_Pos1) then
        error("API.GetLinePosition: _Pos1 does not exist or is invalid position!");
        return;
    end
    local Pos1 = _Pos1;
    if type(Pos1) ~= "table" then
        Pos1 = GetPosition(Pos1);
    end

    if not API.ValidatePosition(_Pos2) and not IsExisting(_Pos2) then
        error("API.GetLinePosition: _Pos1 does not exist or is invalid position!");
        return;
    end
    local Pos2 = _Pos2;
    if type(Pos2) ~= "table" then
        Pos2 = GetPosition(Pos2);
    end

	local dx = Pos2.X - Pos1.X;
	local dy = Pos2.Y - Pos1.Y;
    return {X= Pos1.X+(dx*_Percentage), Y= Pos1.Y+(dy*_Percentage)};
end

---
-- Gib Positionen im gleichen Abstand auf der Linie zurück.
--
-- @param               _Pos1    Erste Position
-- @param               _Pos2    Zweite Position
-- @param[type=number]  _Periode Anzahl an Positionen
-- @return[type=table] Positionen auf Linie
-- @within Position
-- @usage local PositionList = API.GetLinePosition("HQ1", "HQ2", 6);
--
function API.GetLinePositions(_Pos1, _Pos2, _Periode)
    local PositionList = {};
    for i= 0, 100, (1/_Periode)*100 do
        local Section = API.GetLinePosition(_Pos1, _Pos2, i);
        table.insert(PositionList, Section);
    end
    return PositionList;
end

---
-- Gibt eine Position auf einer Kreisbahn um einen Punkt zurück.
--
-- @param               _Target          Entity oder Position
-- @param[type=number]  _Distance        Entfernung um das Zentrum
-- @param[type=number]  _Angle           Winkel auf dem Kreis
-- @return[type=table] Position auf Kreisbahn
-- @within Position
-- @usage local Position = API.GetCirclePosition("HQ1", 3000, -45);
--
function API.GetCirclePosition(_Target, _Distance, _Angle)
    if not API.ValidatePosition(_Target) and not IsExisting(_Target) then
        error("API.GetCirclePosition: _Target does not exist or is invalid position!");
        return;
    end

    local Position = _Target;
    local Orientation = 0+ (_Angle or 0);
    if type(_Target) ~= "table" then
        local EntityID = GetID(_Target);
        Orientation = Logic.GetEntityOrientation(EntityID)+(_Angle or 0);
        Position = GetPosition(EntityID);
    end

    local Result = {
        X= Position.X+_Distance * math.cos(math.rad(Orientation)),
        Y= Position.Y+_Distance * math.sin(math.rad(Orientation)),
        Z= Position.Z
    };
    return Result;
end
API.GetRelatiePos = API.GetCirclePosition;

---
-- Gibt Positionen im gleichen Abstand auf der Kreisbahn zurück.
--
-- @param               _Target          Entity oder Position
-- @param[type=number]  _Distance        Entfernung um das Zentrum
-- @param[type=number]  _Periode         Anzahl an Positionen
-- @param[type=number]  _Offset          Start Offset
-- @return[type=table] Positionend auf Kreisbahn
-- @within Position
-- @usage local PositionList = API.GetCirclePosition("Position", 3000, 6, 45);
--
function API.GetCirclePositions(_Target, _Distance, _Periode, _Offset)
    local Periode = Round(360 / _Periode, 0);
    local PositionList = {};
    for i= (Periode + _Offset), (360 + _Offset) do
        local Section = API.GetCirclePosition(_Target, _Distance, i);
        table.insert(PositionList, Section);
    end
    return PositionList;
end

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
-- @within Position
--
function API.ValidatePosition(_pos)
    if type(_pos) == "table" then
        if (_pos.X ~= nil and type(_pos.X) == "number") and (_pos.Y ~= nil and type(_pos.Y) == "number") then
            local world = {Logic.WorldGetSize()}
            if _pos.Z and _pos.Z < 0 then
                return false;
            end
            if _pos.X <= world[1] and _pos.X > 0 and _pos.Y <= world[2] and _pos.Y > 0 then
                return true;
            end
        end
    end
    return false;
end
IsValidPosition = API.ValidatePosition;

-- Group

---
-- Gibt die Mänge an Soldaten zurück, die dem Entity unterstehen
--
-- <b>Alias</b>: CoundSoldiers
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=number] Menge an Soldaten
-- @within Anwenderfunktionen
--
function API.CountSoldiersOfGroup(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.CountSoldiersOfGroup: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    if Logic.IsLeader(EntityID) == 0 then
        return 0;
    end
    local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
    return SoldierTable[1];
end
CoundSoldiers = API.CountSoldiersOfGroup;

---
-- Gibt die IDs aller Soldaten zurück, die zum Battalion gehören.
--
-- <b>Alias</b>: GetSoldiers
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=table] Liste aller Soldaten
-- @within Anwenderfunktionen
--
function API.GetGroupSoldiers(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetGroupSoldiers: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return {};
    end
    if Logic.IsLeader(EntityID) == 0 then
        return {};
    end
    local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
    table.remove(SoldierTable, 1);
    return SoldierTable;
end
GetSoldiers = API.GetGroupSoldiers;

---
-- Gibt den Leader des Soldaten zurück.
--
-- <b>Alias</b>: GetLeader
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=number] Menge an Soldaten
-- @within Anwenderfunktionen
--
function API.GetGroupLeader(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetGroupLeader: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Soldier) == 0 then 
        return 0;
    end
    return Logic.SoldierGetLeaderEntityID(EntityID);
end
GetLeader = API.GetGroupLeader;

---
-- Heilt das Entity um die angegebene Menge an Gesundheit.
--
-- <b>Alias</b>: HealEntity
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number]  _Amount   Geheilte Gesundheit
-- @within Anwenderfunktionen
--
function API.GroupHeal(_Entity, _Amount)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 or Logic.IsLeader(EntityID) == 1 then
        error("API.GroupHeal: _Entity (" ..tostring(_Entity).. ") must be an existing leader!");
        return;
    end
    if type(_Amount) ~= "number" or _Amount < 0 then
        error("API.GroupHeal: _Amount (" ..tostring(_Amount).. ") must greatier than 0!");
        return;
    end
    API.ChangeEntityHealth(EntityID, Logic.GetEntityHealth(EntityID) + _Amount);
end
HealEntity = API.GroupHeal;

---
-- Verwundet ein Entity oder ein Battallion um die angegebene
-- Menge an Schaden. Bei einem Battalion wird der Schaden solange
-- auf Soldaten aufgeteilt, bis er komplett verrechnet wurde.
--
-- <b>Alias</b>: HurtEntity
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number] _Damage   Schaden
-- @param[type=string] _Attacker Angreifer
-- @within Anwenderfunktionen
--
function API.GroupHurt(_Entity, _Damage, _Attacker)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GroupHurt: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if API.IsEntityInAtLeastOneCategory(EntityID, EntityCategories.Soldier) then
        API.GroupHurt(API.GetGroupLeader(EntityID), _Damage);
        return;
    end

    local EntityToHurt = EntityID;
    local IsLeader = Logic.IsLeader(EntityToHurt) == 1;
    if IsLeader then
        EntityToHurt = API.GetGroupSoldiers(EntityToHurt)[1];
    end
    if type(_Damage) ~= "number" or _Damage < 0 then
        error("API.GroupHurt: _Damage (" ..tostring(_Damage).. ") must be greater than 0!");
        return;
    end

    local Health = Logic.GetEntityHealth(EntityToHurt);
    if EntityToHurt then
        if Health <= _Damage then
            _Damage = _Damage - Health;
            Logic.HurtEntity(EntityToHurt, Health);
            Swift:TriggerEntityKilledCallbacks(EntityToHurt, _Attacker);
            if IsLeader and _Damage > 0 then
                API.GroupHurt(EntityToHurt, _Damage);
            end
        else
            Logic.HurtEntity(EntityToHurt, _Damage);
            Swift:TriggerEntityKilledCallbacks(EntityToHurt, _Attacker);
        end
    end
end
HurtEntity = API.GroupHurt;

