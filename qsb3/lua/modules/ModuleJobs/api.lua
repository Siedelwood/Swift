-- Job API ------------------------------------------------------------------ --

---
-- TODO: add doc
-- @within Beschreibung
-- @set sort=true
--
ModuleJobs = ModuleJobs or {};

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
function API.YieldJob(_JobID)
    for k, v in pairs(ModuleJobs.m_EventJobs) do
        if ModuleJobs.m_EventJobs[k][_JobID] then
            ModuleJobs.m_EventJobs[k][_JobID].Enabled = false;
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
function API.ResumeJob(_JobID)
    for k, v in pairs(ModuleJobs.m_EventJobs) do
        if ModuleJobs.m_EventJobs[k][_JobID] then
            ModuleJobs.m_EventJobs[k][_JobID].Enabled = true;
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
function API.JobIsRunning(_JobID)
    for k, v in pairs(ModuleJobs.m_EventJobs) do
        if ModuleJobs.m_EventJobs[k][_JobID] then
            if  ModuleJobs.m_EventJobs[k][_JobID].Active == true 
            and ModuleJobs.m_EventJobs[k][_JobID].Enabled == true then
                return true;
            end
        end
    end
    return false;
end
JobIsRunning = API.JobIsRunning;

---
-- Beendet einen aktiven Job endgültig.
--
-- <b>Alias</b>: ResumeJob
--
-- @param[type=number] _JobID Job-ID
-- @within Anwenderfunktionen
--
function API.EndJob(_JobID)
    for k, v in pairs(ModuleJobs.m_EventJobs) do
        if ModuleJobs.m_EventJobs[k][_JobID] then
            ModuleJobs.m_EventJobs[k][_JobID].Active = false;
            return;
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
-- Kopie angeleigt um Speicherprobleme zu verhindern. Es handelt sich also um
-- eine neue Table und keine Referenz!
--
-- @param[type=number]   _EventType Event-Typ
-- @param _Function      Funktion (Funktionsreferenz oder String)
-- @param ...            Optionale Argumente des Job
-- @return[type=number] ID des Jobs
-- @within Anwenderfunktionen
--
function API.StartJobByEventType(_EventType, _Function, ...)
    local Function = _Function;
    if type(Function) == "string" then
        Function = _G[Function];
    end
    if type(Function) ~= "function" then
        error("API.StartJobByEventType: Can not find function!", true)
        return;
    end

    ModuleJobs.m_EventJobID = ModuleJobs.m_EventJobID +1;
    local ID = ModuleJobs.m_EventJobID;
    ModuleJobs.m_EventJobs[_EventType] = ModuleJobs.m_EventJobs[_EventType] or {};
    ModuleJobs.m_EventJobs[_EventType][ID] = {
        Function = Function,
        Arguments = table.copy(arg);
        Active = true,
        Enabled = true,
    }
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
--
function API.StartHiResJob(_Function, ...)
    return API.StartJobByEventType(Events.LOGIC_EVENT_EVERY_TURN, _Function, unpack(arg));
end
StartSimpleHiResJob = API.StartHiResJob;
StartSimpleHiResJobEx = API.StartHiResJob;

