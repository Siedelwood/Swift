-- Core API ----------------------------------------------------------------- --

---
-- TODO: Add doc
--
-- @within Anwenderfunktionen
--
function API.Install()
    Swift:LoadCore();
    Swift:LoadPlugins();
end

function API.ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
    Swift:ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell);
end

function API.RegisterScriptEvent(_Name, _Action)
    return Swift:CreateScriptEvent(_Name, _Action);
end

function API.RemoveScriptEvent(_ID)
    return Swift:RemoveScriptEvent(_ID);
end

function API.SendScriptEvent(_ID, ...)
    Swift:DispatchScriptEvent(_ID, unpack(arg));
end

