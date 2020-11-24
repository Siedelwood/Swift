-- Job API ------------------------------------------------------------------ --

function API.YieldJob(_JobID)
    for k, v in pairs(PluginJobs.m_EventJobs) do
        if PluginJobs.m_EventJobs[k][_JobID] then
            PluginJobs.m_EventJobs[k][_JobID].Enabled = false;
        end
    end
end
YieldJob = API.YieldJob;

function API.ResumeJob(_JobID)
    for k, v in pairs(PluginJobs.m_EventJobs) do
        if PluginJobs.m_EventJobs[k][_JobID] then
            PluginJobs.m_EventJobs[k][_JobID].Enabled = true;
        end
    end
end
ResumeJob = API.ResumeJob;

function API.JobIsRunning(_JobID)
    for k, v in pairs(PluginJobs.m_EventJobs) do
        if PluginJobs.m_EventJobs[k][_JobID] then
            if  PluginJobs.m_EventJobs[k][_JobID].Active == true 
            and PluginJobs.m_EventJobs[k][_JobID].Enabled == true then
                return true;
            end
        end
    end
    return false;
end
JobIsRunning = API.JobIsRunning;

function API.EndJob(_JobID)
    for k, v in pairs(PluginJobs.m_EventJobs) do
        if PluginJobs.m_EventJobs[k][_JobID] then
            PluginJobs.m_EventJobs[k][_JobID].Active = false;
            return;
        end
    end
end
EndJob = API.EndJob;

function API.StartJobByEventType(_EventType, _Function, ...)
    local Function = _Function;
    if type(Function) == "string" then
        Function = _G[Function];
    end
    if type(Function) ~= "function" and type(_Function) == "string" then
        error(string.format("API.StartJobByEventType: Can not find function for name '%s'!", _Function))
        return;
    elseif type(Function) ~= "function" and type(_Function) ~= "string" then
        error("API.StartJobByEventType: Received illegal reference as function!");
        return;
    end

    PluginJobs.m_EventJobID = PluginJobs.m_EventJobID +1;
    local ID = PluginJobs.m_EventJobID
    PluginJobs.m_EventJobs[_EventType][ID] = {
        Function = Function,
        Arguments = table.copy(arg);
        Active = true,
        Enabled = true,
    }
    return ID;
end

function API.StartJob(_Function, ...)
    return API.StartJobByEventType(Events.LOGIC_EVENT_EVERY_SECOND, _Function, unpack(arg));
end
StartSimpleJob = API.StartJob;
StartSimpleJobEx = API.StartJob;

function API.StartHiResJob(_Function, ...)
    return API.StartJobByEventType(Events.LOGIC_EVENT_EVERY_TURN, _Function, unpack(arg));
end
StartSimpleHiResJob = API.StartHiResJob;
StartSimpleHiResJobEx = API.StartHiResJob;

