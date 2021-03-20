-- Job API ------------------------------------------------------------------ --

---
-- Dieses Modul erweitert die standardmäßig vorhandenen Jobs. Du kannst für
-- jedes (in Siedler implementierte) Event einen Job als Funktionsreferenz
-- oder Inline Job schreiben.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="core.api.html">Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Pausiert einen laufenden Job.
--
-- <b>Hinweis</b>: Der Job darf nicht direkt mit Trigger.RequestTrigger
-- gestartet worden sein.
--
-- <b>Alias</b>: YieldJob
--
-- @param[type=number] _JobID Job-ID
-- @within Anwenderfunktionen
--
-- @usage API.YieldJob(SOME_JOB_ID);
--
function API.YieldJob(_JobID)
    if ModuleJobsCore.Shared then
        for k, v in pairs(ModuleJobsCore.Shared.EventJobs) do
            if ModuleJobsCore.Shared.EventJobs[k][_JobID] then
                ModuleJobsCore.Shared.EventJobs[k][_JobID].Enabled = false;
            end
        end
    end
end
YieldJob = API.YieldJob;

---
-- Aktiviert einen angehaltenen Job.
--
-- <b>Hinweis</b>: Der Job darf nicht direkt mit Trigger.RequestTrigger
-- gestartet worden sein.
--
-- <b>Alias</b>: ResumeJob
--
-- @param[type=number] _JobID Job-ID
-- @within Anwenderfunktionen
--
-- @usage API.ResumeJob(SOME_JOB_ID);
--
function API.ResumeJob(_JobID)
    if ModuleJobsCore.Shared then
        for k, v in pairs(ModuleJobsCore.Shared.EventJobs) do
            if ModuleJobsCore.Shared.EventJobs[k][_JobID] then
                ModuleJobsCore.Shared.EventJobs[k][_JobID].Enabled = true;
            end
        end
    end
end
ResumeJob = API.ResumeJob;

---
-- Prüft ob der angegebene Job aktiv und eingeschaltet ist.
--
-- <b>Alias</b>: JobIsRunning
--
-- @param[type=number] _JobID Job-ID
-- @within Anwenderfunktionen
--
-- @usage local Runnint = API.JobIsRunning(SOME_JOB_ID);
--
function API.JobIsRunning(_JobID)
    if ModuleJobsCore.Shared then
        for k, v in pairs(ModuleJobsCore.Shared.EventJobs) do
            if ModuleJobsCore.Shared.EventJobs[k][_JobID] then
                if  ModuleJobsCore.Shared.EventJobs[k][_JobID].Active == true 
                and ModuleJobsCore.Shared.EventJobs[k][_JobID].Enabled == true then
                    return true;
                end
            end
        end
    end
    return false;
end
JobIsRunning = API.JobIsRunning;

---
-- Beendet einen aktiven Job endgültig.
--
-- <b>Alias</b>: EndJob
--
-- @param[type=number] _JobID Job-ID
-- @within Anwenderfunktionen
--
-- @usage API.EndJob(SOME_JOB_ID);
--
function API.EndJob(_JobID)
    if ModuleJobsCore.Shared then
        for k, v in pairs(ModuleJobsCore.Shared.EventJobs) do
            if ModuleJobsCore.Shared.EventJobs[k][_JobID] then
                ModuleJobsCore.Shared.EventJobs[k][_JobID].Active = false;
                return;
            end
        end
    end
end
EndJob = API.EndJob;

---
-- Erzeugt einen neuen Event-Job.
--
-- <b>Hinweis</b>: Nur wenn ein Event Job mit dieser Funktion gestartet wird,
-- können ResumeJob und YieldJob auf den Job angewendet werden.
--
-- <b>Hinweis</b>: Events.LOGIC_EVENT_ENTITY_CREATED funktioniert nicht!
--
-- <b>Hinweis</b>: Wird ein Table als Argument an den Job übergeben, wird eine
-- Kopie angelegt um Speicherprobleme zu verhindern. Es handelt sich also um
-- eine neue Table und keine Referenz!
--
-- @param[type=number]   _EventType Event-Typ
-- @param _Function      Funktion (Funktionsreferenz oder String)
-- @param ...            Optionale Argumente des Job
-- @return[type=number] ID des Jobs
-- @within Anwenderfunktionen
--
-- @usage API.StartJobByEventType(
--     Events.LOGIC_EVENT_EVERY_SECOND,
--     FunctionRefToCall
-- );
--
function API.StartJobByEventType(_EventType, _Function, ...)
    local Function = _Function;
    if type(Function) == "string" then
        Function = _G[Function];
    end
    if type(Function) ~= "function" then
        error("API.StartJobByEventType: Can not find function!")
        return;
    end

    local ID = -1;
    if ModuleJobsCore.Shared then
        ModuleJobsCore.Shared.EventJobID = ModuleJobsCore.Shared.EventJobID +1;
        ID = ModuleJobsCore.Shared.EventJobID;
        ModuleJobsCore.Shared.EventJobs[_EventType] = ModuleJobsCore.Shared.EventJobs[_EventType] or {};
        ModuleJobsCore.Shared.EventJobs[_EventType][ID] = {
            Function = Function,
            Arguments = table.copy(arg);
            Active = true,
            Enabled = true,
        }
    end
    return ID;
end

---
-- Fügt eine Funktion als Job hinzu, die einmal pro Sekunde ausgeführt
-- wird. Die Argumente werden an die Funktion übergeben.
--
-- Die Funktion kann als Referenz, Inline oder als String übergeben werden.
--
-- <b>Alias</b>: StartSimpleJobEx
--
-- <b>Alias</b>: StartSimpleJob
--
-- @param _Function Funktion (Funktionsreferenz oder String)
-- @param ...       Liste von Argumenten
-- @return[type=number] Job ID
-- @within Anwenderfunktionen
--
-- @usage -- Führt eine Funktion nach 15 Sekunden aus.
-- API.StartJob(function(_Time, _EntityType)
--     if Logic.GetTime() > _Time + 15 then
--         MachWas(_EntityType);
--         return true;
--     end
-- end, Logic.GetTime(), Entities.U_KnightHealing)
--
-- -- Startet einen Job
-- StartSimpleJob("MeinJob");
--
function API.StartJob(_Function, ...)
    return API.StartJobByEventType(Events.LOGIC_EVENT_EVERY_SECOND, _Function, unpack(arg));
end
StartSimpleJob = API.StartJob;
StartSimpleJobEx = API.StartJob;

---
-- Fügt eine Funktion als Job hinzu, die zehn Mal pro Sekunde ausgeführt
-- wird. Die Argumente werden an die Funktion übergeben.
--
-- Die Funktion kann als Referenz, Inline oder als String übergeben werden.
--
-- <b>Alias</b>: StartSimpleHiResJobEx
--
-- <b>Alias</b>: StartSimpleHiResJob
--
-- @param _Function Funktion (Funktionsreferenz oder String)
-- @param ...       Liste von Argumenten
-- @return[type=number] Job ID
-- @within Anwenderfunktionen
-- @see API.StartJob
--
function API.StartHiResJob(_Function, ...)
    return API.StartJobByEventType(Events.LOGIC_EVENT_EVERY_TURN, _Function, unpack(arg));
end
StartSimpleHiResJob = API.StartHiResJob;
StartSimpleHiResJobEx = API.StartHiResJob;

