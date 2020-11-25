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

