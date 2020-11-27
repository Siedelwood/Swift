-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Swift 3                                                               # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

API = API or {};
QSB = QSB or {};

QSB.Version = "Version 3.0.0 XX/XX/20XX ALPHA";
QSB.Language = "de";
QSB.HumanPlayerID = 1;
QSB.ScriptEvents = {};

Swift = Swift or {};

ParameterType = ParameterType or {};
g_QuestBehaviorVersion = 1;
g_QuestBehaviorTypes = {};

---
-- AddOn Versionsnummer
-- @local
--
g_GameExtraNo = 0;
if Framework then
    g_GameExtraNo = Framework.GetGameExtraNo();
elseif MapEditor then
    g_GameExtraNo = MapEditor.GetGameExtraNo();
end

-- Core  -------------------------------------------------------------------- --

Swift = {
    m_ModuleRegister            = {};
    m_BehaviorRegister          = {};
    m_ScriptEventRegister       = {};
    m_LoadActionRegister        = {};
    m_Language                  = "de";
    m_Environment               = "global";
    m_HistoryEdition            = false;
    m_LogLevel                  = 4;
};

function Swift:LoadCore()
    self:OverrideString();
    self:OverrideTable();
    self:DetectEnvironment();
    self:DetectLanguage();

    if self:IsGlobalEnvironment() then
        self:DetectHistoryEdition();
        self:InitalizeDebugModeGlobal();
        self:InitalizeEventsGlobal();
    end

    if self:IsLocalEnvironment() then
        self:InitalizeDebugModeLocal();
    end

    Swift:RegisterLoadAction(function ()
        Swift:RestoreAfterLoad();
    end);
    self:LoadExternFiles();
    -- Must be done last
    self:LoadBehaviors();
end

-- Modules

function Swift:LoadModules()
    for i= 1, #self.m_ModuleRegister, 1 do
        if self.m_ModuleRegister[i].OnGameStart then
            self.m_ModuleRegister[i]:OnGameStart();
        end
    end
end

function Swift:RegisterModules(_Module)
    if (type(_Module) ~= "table") then
        assert(false, "Modules must be tables!");
        return;
    end
    if _Module.Properties == nil or _Module.Properties.Name == nil then
        assert(false, "Expected name for Module!");
        return;
    end
    table.insert(self.m_ModuleRegister, _Module);
end

function Swift:IsModuleRegistered(_Name)
    for k, v in pairs(self.m_ModuleRegister) do
        return v.Properties and v.Properties.Name == _Name;
    end
end

-- Behavior

function Swift:LoadBehaviors()
    for i= 1, #self.m_BehaviorRegister, 1 do
        local Behavior = self.m_BehaviorRegister[i];

        if not _G["b_" .. Behavior.Name].new then
            _G["b_" .. Behavior.Name].new = function(self, ...)
                local arg = {...};
                local behavior = table.copy(self);
                -- Raw parameters
                behavior.i47ya_6aghw_frxil = {};
                -- Overhead parameters
                behavior.v12ya_gg56h_al125 = {};
                for i= 1, #arg, 1 do
                    table.insert(behavior.v12ya_gg56h_al125, arg[i]);
                    if self.Parameter and self.Parameter[i] ~= nil then
                        behavior:AddParameter(i-1, arg[i]);
                    else
                        table.insert(behavior.i47ya_6aghw_frxil, arg[i]);
                    end
                end
                return behavior;
            end
        end
    end
end

function Swift:RegisterBehavior(_Behavior)
    if type(_Behavior) ~= "table" or _Behavior.Name == nil then
        assert(false, "Behavior is invalid!");
        return;
    end
    if _Behavior.RequiresExtraNo and _Behavior.RequiresExtraNo > g_GameExtraNo then
        return;
    end
    if not _G["b_" .. _Behavior.Name] then
        error(string.format("Behavior %s does not exist!", _Behavior.Name), true);
        return;
    end

    for i= 1, #g_QuestBehaviorTypes, 1 do
        if g_QuestBehaviorTypes[i].Name == _Behavior.Name then
            return;
        end
    end
    table.insert(g_QuestBehaviorTypes, _Behavior);
    table.insert(self.m_BehaviorRegister, _Behavior);
end

-- Load files

function Swift:LoadExternFiles()
    if Mission_LoadFiles then
        local FilesList = Mission_LoadFiles();
        for i= 1, #FilesList, 1 do
            if type(FilesList[i]) == "function" then
                FilesList[i]();
            else
                Script.Load(FilesList[i]);
            end
        end
    end
end

-- Environment Detection

function Swift:DetectEnvironment()
    self.m_Environment = (nil ~= GUI and "local") or "global";
end

function Swift:IsGlobalEnvironment()
    return "global" == self.m_Environment;
end

function Swift:IsLocalEnvironment()
    return "local" == self.m_Environment;
end

-- History Edition

function Swift:DetectHistoryEdition()
    local EntityID = Logic.CreateEntity(Entities.U_NPC_Amma_NE, 100, 100, 0, 8);
    MakeInvulnerable(EntityID);
    if Logic.GetEntityScriptingValue(EntityID, -68) == 8 then
        Logic.ExecuteInLuaLocalState("Swift.m_HistoryEdition = true");
        self.m_HistoryEdition = true;
    end
    DestroyEntity(EntityID);
end

function Swift:IsHistoryEdition()
    return true == self.m_HistoryEdition;
end

-- Logging

LOG_LEVEL_ALL     = 4;
LOG_LEVEL_INFO    = 3;
LOG_LEVEL_WARNING = 2;
LOG_LEVEL_ERROR   = 1;
LOG_LEVEL_OFF     = 0;

function Swift:Log(_Text, _Verbose)
    Framework.WriteToLog(_Text);
    if _Verbose then
        if self:IsGlobalEnvironment() then
            Logic.ExecuteInLuaLocalState(string.format(
                [[GUI.AddStaticNote("%s")]],
                _Text
            ));
            return;
        end
        GUI.AddStaticNote(_text);
    end
end

function Swift:SetLogLevel(_Level)
    if self:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState(string.format(
            [[Swift.m_LogLevel = %d]],
            _Level
        ));
        self.m_LogLevel = _Level;
    end
end

function debug(_Text, _Verbose)
    if Swift.m_LogLevel >= 4 then
        Swift:Log("DEBUG: " .._Text, _Verbose);
    end
end
function info(_Text, _Verbose)
    if Swift.m_LogLevel >= 3 then
        Swift:Log("INFO: " .._Text, _Verbose);
    end
end
function warn(_Text, _Verbose)
    if Swift.m_LogLevel >= 2 then
        Swift:Log("WARNING: " .._Text, _Verbose);
    end
end
function error(_Text, _Verbose)
    if Swift.m_LogLevel >= 1 then
        Swift:Log("ERROR: " .._Text, _Verbose);
    end
end

-- Lua base functions

function Swift:OverrideTable()
    API.OverrideTable();
end

function Swift:OverrideString()
    API.OverrideString();
end

-- Save Game Callback

function Swift:RegisterLoadAction(_Action)
    if (type(_Action) ~= "function") then
        assert(false, "Action must be a function!");
        return;
    end
    table.insert(self.m_LoadActionRegister, _Action);
end

function Swift:CallSaveGameActions()
    -- Core actions
    for i= 1, #self.m_LoadActionRegister, 1 do
        self.m_LoadActionRegister[i](self);
    end
    -- Module actions
    for i= 1, #self.m_ModuleRegister, 1 do
        if self.m_ModuleRegister[i].OnSaveGameLoaded then
            self.m_ModuleRegister[i]:OnSaveGameLoaded();
        end
    end
end

function Swift:RestoreAfterLoad()
    debug("Loading save game");
    self:OverrideString();
    self:OverrideTable();
    if self:IsGlobalEnvironment() then
        self:GlobalRestoreDebugAfterLoad();
    end
    if self:IsLocalEnvironment() then
        self:LocalRestoreDebugAfterLoad();
    end
end

do
    if Mission_OnSaveGameLoaded then
        local Mission_OnSaveGameLoaded_Orig = Mission_OnSaveGameLoaded;
        Mission_OnSaveGameLoaded = function()
            Mission_OnSaveGameLoaded_Orig();
            Logic.ExecuteInLuaLocalState([[Swift:CallSaveGameActions()]]);
            Swift:CallSaveGameActions();
        end
    end
end

-- Script Events

function Swift:InitalizeEventsGlobal()
    QSB.ScriptEvents.QuestFailure = Swift:CreateScriptEvent("Event_QuestFailure", nil);
    QSB.ScriptEvents.QuestInterrupt = Swift:CreateScriptEvent("Event_QuestInterrupt", nil);
    QSB.ScriptEvents.QuestReset = Swift:CreateScriptEvent("Event_QuestReset", nil);
    QSB.ScriptEvents.QuestSuccess = Swift:CreateScriptEvent("Event_QuestSuccess", nil);
    QSB.ScriptEvents.QuestTrigger = Swift:CreateScriptEvent("Event_QuestTrigger", nil);
end

function Swift:CreateScriptEvent(_Name, _Function)
    local ID = 1;
    for k, v in pairs(self.m_ScriptEventRegister) do
        if v and v.Name == _Name then
            return 0;
        end
        ID = ID +1;
    end
    debug(string.format("Create script event %s", _Name));
    self.m_ScriptEventRegister[ID] = {_Name, _Function};
    return ID;
end

function Swift:RemoveScriptEvent(_ID)
    if self.m_ScriptEventRegister[_ID] then
        debug(string.format("Remove script event %s", self.m_ScriptEventRegister[_ID].Name));
    end
    self.m_ScriptEventRegister[_ID] = nil;
end

function Swift:DispatchScriptEvent(_ID, ...)
    if not self.m_ScriptEventRegister[_ID] then
        return;
    end
    for i= 1, #self.m_ModuleRegister, 1 do
        if self.m_ModuleRegister[i].OnEvent then
            debug(string.format(
                "Dispatching script event %s for Module %s",
                self.m_ScriptEventRegister[_ID].Name,
                self.m_ModuleRegister[i].Properties.Name
            ));
            self.m_ModuleRegister[i]:OnEvent(self.m_ScriptEventRegister[_ID], unpack(arg));
        end
    end
end

-- Language

function Swift:DetectLanguage()
    self.m_Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    self:ChangeSystemLanguage(self.m_Language);
end

function Swift:ChangeSystemLanguage(_Language)
    self.m_Language = _Language;
    QSB.Language = _Language;
    -- TODO: Change defaults of Swift here
    for i= 1, #self.m_ModuleRegister, 1 do
        if self.m_ModuleRegister[i].OnLanguageSelected then
            self.m_ModuleRegister[i]:OnLanguageSelected(_Language);
        end
    end
end

-- Utils

function Swift:ToBoolean(_Input)
    if type(_Input) == "boolean" then
        return _Input;
    end
    if string.find(string.lower(tostring(_Input)), "^[tjy\\+].*$") then
        return true;
    end
    return false;
end

