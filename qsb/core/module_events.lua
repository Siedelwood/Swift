-- Events ----------------------------------------------------------------------

-- API Stuff --

function API.IsLoadscreenVisible()
    return not Core.Data.LoadScreenHidden == true;
end

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
    for k, v in pairs(Core.Data.EventJobs) do
        if Core.Data.EventJobs[k][_JobID] then
            Core.Data.EventJobs[k][_JobID].Enabled = false;
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
    for k, v in pairs(Core.Data.EventJobs) do
        if Core.Data.EventJobs[k][_JobID] then
            Core.Data.EventJobs[k][_JobID].Enabled = true;
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
    for k, v in pairs(Core.Data.EventJobs) do
        if Core.Data.EventJobs[k][_JobID] then
            if Core.Data.EventJobs[k][_JobID].Active == true and Core.Data.EventJobs[k][_JobID].Enabled == true then
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
    for k, v in pairs(Core.Data.EventJobs) do
        if Core.Data.EventJobs[k][_JobID] then
            Core.Data.EventJobs[k][_JobID].Active = false;
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
function API.StartEventJob(_EventType, _Function, ...)
    local Function = _Function;
    if type(Function) == "string" then
        Function = _G[Function];
    end
    if type(Function) ~= "function" and type(_Function) == "string" then
        error(string.format("API.StartEventJob: Can not find function for name '%s'!", _Function));
        return;
    elseif type(Function) ~= "function" and type(_Function) ~= "string" then
        error("API.StartEventJob: Received illegal reference as function!");
        return;
    end

    Core.Data.EventJobID = Core.Data.EventJobID +1;
    local ID = Core.Data.EventJobID
    Core.Data.EventJobs[_EventType][ID] = {
        Function = Function,
        Arguments = API.InstanceTable(arg);
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
    return API.StartEventJob(Events.LOGIC_EVENT_EVERY_SECOND, _Function, unpack(arg));
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
    return API.StartEventJob(Events.LOGIC_EVENT_EVERY_TURN, _Function, unpack(arg));
end
StartSimpleHiResJob = API.StartHiResJob;
StartSimpleHiResJobEx = API.StartHiResJob;

-- Core Stuff --

Core.Data.LoadScreenHidden = false;
Core.Data.EventJobID = 0;
Core.Data.EventJobs = {
    [Events.LOGIC_EVENT_DIPLOMACY_CHANGED]         = {},
    [Events.LOGIC_EVENT_ENTITY_CREATED]            = {},
    [Events.LOGIC_EVENT_ENTITY_DESTROYED]          = {},
    [Events.LOGIC_EVENT_ENTITY_HURT_ENTITY]        = {},
    [Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY] = {},
    [Events.LOGIC_EVENT_EVERY_SECOND]              = {},
    [Events.LOGIC_EVENT_EVERY_TURN]                = {},
    [Events.LOGIC_EVENT_GOODS_TRADED]              = {},
    [Events.LOGIC_EVENT_PLAYER_DIED]               = {},
    [Events.LOGIC_EVENT_RESEARCH_DONE]             = {},
    [Events.LOGIC_EVENT_TRIBUTE_PAID]              = {},
    [Events.LOGIC_EVENT_WEATHER_STATE_CHANGED]     = {},
};

---
-- Führt alle Event Jobs des angegebenen Typen aus und prüft deren Status.
--
-- @param[type=number] _Type Typ des Jobs
-- @within Internal
-- @local
--
function Core:TriggerEventJobs(_Type)
    for k, v in pairs(self.Data.EventJobs[_Type]) do
        if type(v) == "table" then
            if v.Active == false then
                self.Data.EventJobs[_Type][k] = nil;
            else
                if v.Enabled then
                    if v.Function then
                        local Arguments = v.Arguments or {};
                        if v.Function(unpack(Arguments)) == true then
                            self.Data.EventJobs[_Type][k] = nil;
                        end
                    end
                end
            end
        end
    end
end

-- Ein Job, der eine Variable setzt, sobald der Loadscreen beendet ist.
function Core.EventJob_WaitForLoadScreenHidden()
    if XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 0 then
        GUI.SendScriptCommand("Core.Data.LoadScreenHidden = true");
        Core.Data.LoadScreenHidden = true;
        return true;
    end
end

-- Folgende Jobs steuern den Trigger Fix. Prinzipiell wird für jede Art Trigger
-- ein bestimmter Trigger erstellt, der dann die eigentlichen Trigger aufruft
-- und ihren Zustand abfragt.

function Core.EventJob_OnDiplomacyChanged()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_DIPLOMACY_CHANGED);
end
CoreEventJob_OnDiplomacyChanged = Core.EventJob_OnDiplomacyChanged;


function Core.EventJob_OnEntityCreated()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_CREATED);
end
CoreEventJob_OnEntityCreated = Core.EventJob_OnEntityCreated


function Core.EventJob_OnEntityDestroyed()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_DESTROYED);
end
CoreEventJob_OnEntityDestroyed = Core.EventJob_OnEntityDestroyed;


function Core.EventJob_OnEntityHurtEntity()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY);
end
CoreEventJob_OnEntityHurtEntity = Core.EventJob_OnEntityHurtEntity;


function Core.EventJob_OnEntityInRangeOfEntity()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY);
end
CoreEventJob_OnEntityInRangeOfEntity = Core.EventJob_OnEntityInRangeOfEntity;


function Core.EventJob_OnEverySecond()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_EVERY_SECOND);
end
CoreEventJob_OnEverySecond = Core.EventJob_OnEverySecond;


function Core.EventJob_OnEveryTurn()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_EVERY_TURN);
end
CoreEventJob_OnEveryTurn = Core.EventJob_OnEveryTurn;


function Core.EventJob_OnGoodsTraded()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_GOODS_TRADED);
end
CoreEventJob_OnGoodsTraded = Core.EventJob_OnGoodsTraded;


function Core.EventJob_OnPlayerDied()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_PLAYER_DIED);
end
CoreEventJob_OnPlayerDied = Core.EventJob_OnPlayerDied;


function Core.EventJob_OnResearchDone()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_RESEARCH_DONE);
end
CoreEventJob_OnResearchDone = Core.EventJob_OnResearchDone;


function Core.EventJob_OnTributePaied()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_TRIBUTE_PAID);
end
CoreEventJob_OnTributePaied = Core.EventJob_OnTributePaied;


function Core.EventJob_OnWatherChanged()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_WEATHER_STATE_CHANGED);
end
CoreEventJob_OnWatherChanged = Core.EventJob_OnWatherChanged;

