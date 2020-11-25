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

