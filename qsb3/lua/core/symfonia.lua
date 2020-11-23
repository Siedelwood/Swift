-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia 3                                                            # --
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
QSB.HumanPlayerID = 1;
QSB.Language = "de";

Symfonia = Symfonia or {};

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

Symfonia = {
    m_PluginRegister     = {};
    m_BehaviorRegister   = {};
    m_LoadActionRegister = {};
    m_Language           = "de";
    m_Environment        = "global";
    m_HistoryEdition     = false;
    m_LogLevel           = 4;
};

function Symfonia:LoadCore()
    self:DetectEnvironment();
    self:DetectLanguage();

    if self:IsGlobalEnvironment() then
        self:DetectHistoryEdition();
    end

    if self:IsLocalEnvironment() then
        
    end
    
    self:LoadExternFiles();
end

function Symfonia:LoadPlugins()
    for i= 1, #self.m_PluginRegister, 1 do
        if self.m_PluginRegister[i].OnGameStart then
            self.m_PluginRegister[i]:OnGameStart();
        end
    end
end

function Symfonia:RegisterPlugins(_Plugin)
    if (type(_Plugin) ~= "table") then
        assert(false, "Plugins must be tables!");
        return;
    end
    if _Plugin.Name == nil then
        assert(false, "Expected name for plugin!");
        return;
    end
    table.insert(self.m_PluginRegister, _Plugin);
end

function Symfonia:LoadBehaviors()
    for i= 1, #self.m_BehaviorRegister, 1 do
        -- TODO
    end
end

function Symfonia:RegisterBehavior(_Behavior)
    if (type(_Behavior) ~= "table") then
        assert(false, "Behavior must be tables!");
        return;
    end
    -- TODO: Implement fix
    table.insert(self.m_BehaviorRegister, _Behavior);
end

function Symfonia:RegisterLoadAction(_Action)
    if (type(_Action) ~= "function") then
        assert(false, "Action must be a function!");
        return;
    end
    table.insert(self.m_LoadActionRegister, _Action);
end

-- Load files

function Symfonia:LoadExternFiles()
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

function Symfonia:DetectEnvironment()
    self.m_Environment = (nil ~= GUI and "local") or "global";
end

function Symfonia:IsGlobalEnvironment()
    return "global" == self.m_Environment;
end

function Symfonia:IsLocalEnvironment()
    return "local" == self.m_Environment;
end

function Symfonia:DetectLanguage()
    self.m_Language = Network.GetDesiredLanguage();
end

-- History Edition

function Symfonia:DetectHistoryEdition()
    local EntityID = Logic.CreateEntity(Entities.U_NPC_Amma_NE, 100, 100, 0, 8);
    MakeInvulnerable(EntityID);
    if Logic.GetEntityScriptingValue(EntityID, -68) == 8 then
        Logic.ExecuteInLuaLocalState("Symfonia.m_HistoryEdition = true");
        self.m_HistoryEdition = true;
    end
    DestroyEntity(EntityID);
end

function Symfonia:IsHistoryEdition()
    return true == self.m_HistoryEdition;
end

-- Logging

LOG_LEVEL_ALL     = 4;
LOG_LEVEL_INFO    = 3;
LOG_LEVEL_WARNING = 2;
LOG_LEVEL_ERROR   = 1;
LOG_LEVEL_OFF     = 0;

function Symfonia:Log(_Text, _Verbose)
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

function Symfonia:SetLogLevel(_Level)
    if self:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState(string.format(
            [[Symfonia.m_LogLevel = %d]],
            _Level
        ));
        self.m_LogLevel = _Level;
    end
end

function debug(_Text, _Verbose)
    if Symfonia.m_LogLevel >= 4 then
        Symfonia:Log("DEBUG: " .._Text, _Verbose);
    end
end
function info(_Text, _Verbose)
    if Symfonia.m_LogLevel >= 3 then
        Symfonia:Log("INFO: " .._Text, _Verbose);
    end
end
function warn(_Text, _Verbose)
    if Symfonia.m_LogLevel >= 2 then
        Symfonia:Log("WARNING: " .._Text, _Verbose);
    end
end
function error(_Text, _Verbose)
    if Symfonia.m_LogLevel >= 1 then
        Symfonia:Log("ERROR: " .._Text, _Verbose);
    end
end

-- Save Game Callback

function Symfonia:CallSaveGameActions()
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

do
    if Mission_OnSaveGameLoaded then
        local Mission_OnSaveGameLoaded_Orig = Mission_OnSaveGameLoaded;
        Mission_OnSaveGameLoaded = function()
            Mission_OnSaveGameLoaded_Orig();
            Logic.ExecuteInLuaLocalState([[Symfonia:CallSaveGameActions()]]);
            Symfonia:CallSaveGameActions();
        end
    end
end

