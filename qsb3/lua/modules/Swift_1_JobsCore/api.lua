-- Job API ------------------------------------------------------------------ --

---
-- Dieses Modul erweitert die standardmäßig vorhandenen Jobs. Du kannst für
-- jedes (in Siedler implementierte) Event einen Job als Funktionsreferenz
-- oder Inline Job schreiben.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_0_Core.api.html">(0) Core</a></li>
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
        if ModuleJobsCore.Shared.EventJobs[_EventType] then
            ModuleJobsCore.Shared.EventJobs[_EventType][ID] = {
                Function = Function,
                Arguments = table.copy(arg or {});
                Active = true,
                Enabled = true,
            }
        end
    end
    return ID;
end

---
-- Fügt eine Funktion als Job hinzu, die einmal pro Sekunde ausgeführt
-- wird. Die Argumente werden an die Funktion übergeben.
--
-- Die Funktion kann als Referenz, Inline oder als String übergeben werden.
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
    local Function = _Function;
    if type(Function) == "string" then
        Function = _G[Function];
    end
    if type(Function) ~= "function" then
        error("API.StartJob: _Function must be a function!");
        return;
    end
    return API.StartJobByEventType(Events.LOGIC_EVENT_EVERY_SECOND, Function, unpack(arg));
end
StartSimpleJob = API.StartJob;
StartSimpleJobEx = API.StartJob;

---
-- Fügt eine Funktion als Job hinzu, die zehn Mal pro Sekunde ausgeführt
-- wird. Die Argumente werden an die Funktion übergeben.
--
-- Die Funktion kann als Referenz, Inline oder als String übergeben werden.
--
-- @param _Function Funktion (Funktionsreferenz oder String)
-- @param ...       Liste von Argumenten
-- @return[type=number] Job ID
-- @within Anwenderfunktionen
-- @see API.StartJob
--
function API.StartHiResJob(_Function, ...)
    local Function = _Function;
    if type(Function) == "string" then
        Function = _G[Function];
    end
    if type(Function) ~= "function" then
        error("API.StartHiResJob: _Function must be a function!");
        return;
    end
    return API.StartJobByEventType(Events.LOGIC_EVENT_EVERY_TURN, Function, unpack(arg));
end
StartSimpleHiResJob = API.StartHiResJob;
StartSimpleHiResJobEx = API.StartHiResJob;

---
-- Startet einen Zeitstrahl-Job.
--
-- Ein Zeitstrahl hat Stationen, an denen eine Aktion ausgeführt wird. Jede
-- Station muss mindestens eine Sekunde nach der vorherigen liegen.
--
-- Jede Aktion eines Zeitstrahls erhält die Table des aktuellen Ereignisses
-- als Argument. So können Parameter an die Funktion übergeben werden.
--
-- @param[type=table] _Description Beschreibung
-- @return[type=number] ID des Zeitstrahls
-- @within Anwenderfunktionen
-- @see API.StartJob
--
-- @usage JobID = API.StartTimelineJob {
--     {Time = 5, Action = MyFirstAction},
--     -- MySecondAction erhält "BOCKWURST" als Parameter
--     {Time = 15, Action = MySecondAction, "BOCKWURST"},
--     -- Inline-Funktion
--     {Time = 30, Action = function() end},
-- }
--
function API.StartTimelineJob(_Data)
    -- check params
    for i= 1, #_Data do
        if type(_Data[i]) ~= "table" then
            error("API.StartTimelineJob: _Data[" ..i.. "] must be a table!");
            return;
        end
        if #_Data[i] < 2 then
            error("API.StartTimelineJob: _Data[" ..i.. "] has too few entries!");
            return;
        end
        if type(_Data[i][1]) ~= "number" or _Data[i][1] < 0 then
            error("API.StartTimelineJob: _Data[" ..i.. "][1] must be a number equal oder greater than 0!");
            return;
        end
        if type(_Data[i][2]) ~= "function" then
            error("API.StartTimelineJob: _Data[" ..i.. "][2] must be a function!");
            return;
        end
    end

    -- start job
    local JobID = API.StartJob(
        function(_JobID, _Time)
            if not ModuleJobsCore.Shared.TimeLineData[_JobID] then
                return true;
            end
            if #ModuleJobsCore.Shared.TimeLineData[_JobID] == 0 then
                ModuleJobsCore.Shared.TimeLineData[_JobID] = nil;
                return true;
            end
            if ModuleJobsCore.Shared.TimeLineData[_JobID][1].Time == _Time then
                local Data = table.remove(ModuleJobsCore.Shared.TimeLineData[_JobID], 1);
                Data.Action(unpack(Data));
            end
        end,
        -- little hack to get the job ID into the job
        ModuleJobsCore.Shared.EventJobID +1,
        math.floor(Logic.GetTime())
    );
    ModuleJobsCore.Shared.TimeLineData[JobID] = _Data;
    return JobID;
end

---
-- Gibt die real vergangene Zeit seit dem Spielstart in Sekunden zurück.
-- @return[type=number] Vergangene reale Zeit
-- @within Anwenderfunktionen
--
-- @usage local RealTime = API.RealTimeGetSecondsPassedSinceGameStart();
--
function API.RealTimeGetSecondsPassedSinceGameStart()
    return ModuleJobsCore.Shared.SecondsSinceGameStart;
end

---
-- Wartet die angebene Zeit in realen Sekunden und führt anschließend das
-- Callback aus. Die Ausführung erfolgt asynchron. Das bedeutet, dass das
-- Skript weiterläuft.
--
-- @param[type=number] _Waittime Wartezeit in realen Sekunden
-- @param[type=function] _Action Callback-Funktion
-- @param ... Liste der Argumente
-- @return[type=number] ID der Verzögerung
-- @within Anwenderfunktionen
--
-- @usage API.StartRealTimeJob(
--     30,
--     function()
--         Logic.DEBUG_AddNote("Zeit abgelaufen!");
--     end
-- )
--
function API.StartRealTimeJob(_Waittime, _Action, ...)
    local ID = API.StartJob( function(_StartTime, _Delay, _Callback, _Arguments)
        if (ModuleJobsCore.Shared.SecondsSinceGameStart >= _StartTime + _Delay) then
            if #_Arguments > 0 then
                _Callback(unpack(_Arguments));
            else
                _Callback();
            end
            return true;
        end
    end, ModuleJobsCore.Shared.SecondsSinceGameStart, _Waittime, _Action, {...});
    return ID;
end

