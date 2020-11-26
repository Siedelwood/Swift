-- Core API ----------------------------------------------------------------- --

---
-- TODO: Add doc
--
-- @within Anwenderfunktionen
--
function API.Install()
    Swift:LoadCore();
    Swift:LoadModules();
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

