-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Swift 3                                                               # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- TODO: Add doc
--
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

QSB.Version = "Version 3.0.0 XX/XX/20XX ALPHA";
QSB.Language = "de";
QSB.HumanPlayerID = 1;

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
    m_PluginRegister      = {};
    m_BehaviorRegister    = {};
    m_ScriptEventRegister = {};
    m_LoadActionRegister  = {};
    m_Language            = "de";
    m_Environment         = "global";
    m_HistoryEdition      = false;
    m_LogLevel            = 4;
};

function Swift:LoadCore()
    self:OverrideString();
    self:OverrideTable();
    self:DetectEnvironment();
    self:DetectLanguage();

    if self:IsGlobalEnvironment() then
        self:DetectHistoryEdition();
    end

    if self:IsLocalEnvironment() then
        
    end

    Swift:RegisterLoadAction(function ()
        Swift:RestoreAfterLoad();
    end);
    
    self:LoadExternFiles();
end

function Swift:LoadPlugins()
    for i= 1, #self.m_PluginRegister, 1 do
        if self.m_PluginRegister[i].OnGameStart then
            self.m_PluginRegister[i]:OnGameStart();
        end
    end
end

function Swift:RegisterPlugins(_Plugin)
    if (type(_Plugin) ~= "table") then
        assert(false, "Plugins must be tables!");
        return;
    end
    if _Plugin.Properties == nil or _Plugin.Properties.Name == nil then
        assert(false, "Expected name for plugin!");
        return;
    end
    table.insert(self.m_PluginRegister, _Plugin);
end

function Swift:IsPluginRegistered(_Name)
    for k, v in pairs(self.m_PluginRegister) do
        return v.Properties and v.Properties.Name == _Name;
    end
end

function Swift:LoadBehaviors()
    for i= 1, #self.m_BehaviorRegister, 1 do
        -- TODO
    end
end

function Swift:RegisterBehavior(_Behavior)
    if (type(_Behavior) ~= "table") then
        assert(false, "Behavior must be tables!");
        return;
    end
    -- TODO: Implement fix
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

function Swift:OverrideTable()
    ---
    -- TODO: Add doc
    -- @within table
    --
    table.contains = function (t, e)
        for k, v in ipairs(t) do
            if v == e then return true; end
        end
        return false;
    end

    ---
    -- TODO: Add doc
    -- @within table
    --
    table.copy = function (t1, t2)
        t1 = t1 or {};
        t2 = t2 or {};
        for k, v in pairs(t1) do
            if "table" == type(v) then
                t2[k] = t2[k] or {};
                for kk, vv in pairs(table.copy(v, t2[k])) do
                    t2[k][kk] = t2[k][kk] or vv;
                end
            else
                t2[k] = v;
            end
        end
        return t2;
    end

    ---
    -- TODO: Add doc
    -- @within table
    --
    table.invert = function (t1)
        local t2 = {};
        for i= #t1, 1, -1 do
            table.insert(t2, t1[i]);
        end
        return t2;
    end

    ---
    -- TODO: Add doc
    -- @within table
    --
    table.push = function (t, e)
        table.insert(t, 1, e);
    end

    ---
    -- TODO: Add doc
    -- @within table
    --
    table.pop = function (t, e)
        return table.remove(t, 1);
    end
end

-- Lua base functions

function Swift:OverrideString()
    -- TODO: Implement!

    ---
    -- TODO: Add doc
    -- @within string
    --
    string.contains = function (self, s)
        return self:find(s) ~= nil;
    end

    ---
    -- TODO: Add doc
    -- @within string
    --
    string.indexOf = function (self, s)
        return self:find(s);
    end
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
    -- Plugin actions
    for i= 1, #self.m_PluginRegister, 1 do
        if self.m_PluginRegister[i].OnSaveGameLoaded then
            self.m_PluginRegister[i]:OnSaveGameLoaded();
        end
    end
end

function Swift:RestoreAfterLoad()
    debug("Loading save game");
    self:OverrideString();
    self:OverrideTable();
    if self:IsGlobalEnvironment() then
    end
    if self:IsLocalEnvironment() then
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

function Swift:CreateScriptEvent(_Name, _Action)
    local ID = 1;
    for k, v in pairs(self.m_ScriptEventRegister) do
        if v and v.Name == _Name then
            return 0;
        end
        ID = ID +1;
    end
    debug(string.format("Create script event %s", _Name));
    self.m_ScriptEventRegister[ID] = {_Name, _Action};
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
    for i= 1, #self.m_PluginRegister, 1 do
        if self.m_PluginRegister[i].OnEvent then
            debug(string.format(
                "Dispatching script event %s for plugin %s",
                self.m_ScriptEventRegister[_ID].Name,
                self.m_PluginRegister[i].Properties.Name
            ));
            self.m_PluginRegister[i]:OnEvent(self.m_ScriptEventRegister[_ID], unpack(arg));
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
    for i= 1, #self.m_PluginRegister, 1 do
        if self.m_PluginRegister[i].OnLanguageSelected then
            self.m_PluginRegister[i]:OnLanguageSelected(_Language);
        end
    end
end

