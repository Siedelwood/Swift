-- Core API ----------------------------------------------------------------- --

---
-- TODO: Add doc
--
-- @within Anwenderfunktionen
--
function API.Install()
    Symfonia:LoadCore();
    Symfonia:LoadPlugins();
end

function API.ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
    Symfonia.Debug:ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell);
end

