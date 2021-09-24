--[[
Swift_0_Core/Swift

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

API = API or {};
QSB = QSB or {};

QSB.Version = "Version 3.0.0 XX/XX/20XX ALPHA";
QSB.Language = "de";
QSB.HumanPlayerID = -1;
QSB.ScriptEvents = {};
QSB.CustomVariable = {};

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
    m_ScriptEventActions        = {};
    m_LoadActionRegister        = {};
    m_Language                  = "de";
    m_Environment               = "global";
    m_HistoryEdition            = false;
    m_NoQuicksaveConditions     = {};
    m_LogLevel                  = 2;
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
        self:InstallBehaviorGlobal();
        self:OverrideQuestSystemGlobal();
    end

    if self:IsLocalEnvironment() then
        self:InitalizeDebugModeLocal();
        self:InitalizeEventsLocal();
        self:InstallBehaviorLocal();
        self:OverrideDoQuicksave();

        -- Human player ID makes only sense in singleplayer context
        if not Framework.IsNetworkGame() then
            local HumanID = GUI.GetPlayerID();
            GUI.SendScriptCommand("QSB.HumanPlayerID = " ..HumanID);
            QSB.HumanPlayerID = HumanID;
        end
        StartSimpleHiResJob("Swift_EventJob_WaitForLoadScreenHidden");
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
        if self:IsGlobalEnvironment() and self.m_ModuleRegister[i]["Global"].OnGameStart then
            self.m_ModuleRegister[i]["Global"]:OnGameStart();
        end
        if self:IsLocalEnvironment() and self.m_ModuleRegister[i]["Local"].OnGameStart then
            self.m_ModuleRegister[i]["Local"]:OnGameStart();
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

-- Quests

function Swift:OverrideQuestSystemGlobal()
    QuestTemplate.Trigger_Orig_QSB_Core = QuestTemplate.Trigger
    QuestTemplate.Trigger = function(_quest)
        QuestTemplate.Trigger_Orig_QSB_Core(_quest);
        for i=1,_quest.Objectives[0] do
            if _quest.Objectives[i].Type == Objective.Custom2 and _quest.Objectives[i].Data[1].SetDescriptionOverwrite then
                local Desc = _quest.Objectives[i].Data[1]:SetDescriptionOverwrite(_quest);
                Swift:ChangeCustomQuestCaptionText(Desc, _quest);
                break;
            end
        end
    end

    QuestTemplate.Interrupt_Orig_QSB_Core = QuestTemplate.Interrupt;
    QuestTemplate.Interrupt = function(_quest)
        QuestTemplate.Interrupt_Orig_QSB_Core(_quest);
        for i=1, _quest.Objectives[0] do
            if _quest.Objectives[i].Type == Objective.Custom2 and _quest.Objectives[i].Data[1].Interrupt then
                _quest.Objectives[i].Data[1]:Interrupt(_quest, i);
            end
        end
        for i=1, _quest.Triggers[0] do
            if _quest.Triggers[i].Type == Triggers.Custom2 and _quest.Triggers[i].Data[1].Interrupt then
                _quest.Triggers[i].Data[1]:Interrupt(_quest, i);
            end
        end
    end
end

function Swift:ChangeCustomQuestCaptionText(_Text, _Quest)
    if _Quest and _Quest.Visible then
        _Quest.QuestDescription = _Text;
        Logic.ExecuteInLuaLocalState([[
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/BGDeco",0)
            local identifier = "]].._Quest.Identifier..[["
            for i=1, Quests[0] do
                if Quests[i].Identifier == identifier then
                    local text = Quests[i].QuestDescription
                    XGUIEng.SetText("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/Text", "]].._Text..[[")
                    break
                end
            end
        ]]);
    end
end

function Swift:GetTextOfDesiredLanguage(_Table)
    if _Table[QSB.Language] then
        return _Table[QSB.Language];
    end
    return _Table["en"] or "ERROR_NO_TEXT";
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
    if self:IsLocalEnvironment() then
        return;
    end
    if type(_Behavior) ~= "table" or _Behavior.Name == nil then
        assert(false, "Behavior is invalid!");
        return;
    end
    if _Behavior.RequiresExtraNo and _Behavior.RequiresExtraNo > g_GameExtraNo then
        return;
    end
    if not _G["b_" .. _Behavior.Name] then
        error(string.format("Behavior %s does not exist!", _Behavior.Name));
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
    if self:IsLocalEnvironment() then
        return true;
    end
    local EntityID = Logic.CreateEntity(Entities.U_NPC_Amma_NE, 100, 100, 0, 8);
    MakeInvulnerable(EntityID);
    if Logic.GetEntityScriptingValue(EntityID, -68) == 8 then
        Logic.ExecuteInLuaLocalState("Swift.m_HistoryEdition = true");
        self.m_HistoryEdition = true;
    end
    DestroyEntity(EntityID);
end

function Swift:IsHistoryEdition()
    return self.m_HistoryEdition == true;
end

function Swift:OverrideDoQuicksave()
    -- Quicksave must not be possible while loading map
    self:AddDoQuicksaveCondition(function()
        return GUI and XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") ~= 0;
    end);

    KeyBindings_SaveGame_Orig_Module_SaveGame = KeyBindings_SaveGame;
    KeyBindings_SaveGame = function()
        if not Swift:CanDoQuicksave() then
            return;
        end
        KeyBindings_SaveGame_Orig_Module_SaveGame();
    end
end

function Swift:AddDoQuicksaveCondition(_Function)
    table.insert(self.m_NoQuicksaveConditions, _Function);
end

function Swift:CanDoQuicksave()
    for i= 1, #self.m_NoQuicksaveConditions, 1 do
        if self.m_NoQuicksaveConditions[i]() then
            return false;
        end
    end
    return true;
end

-- Logging

LOG_LEVEL_ALL     = 4;
LOG_LEVEL_INFO    = 3;
LOG_LEVEL_WARNING = 2;
LOG_LEVEL_ERROR   = 1;
LOG_LEVEL_OFF     = 0;

function Swift:Log(_Text, _Level, _Verbose)
    Framework.WriteToLog(_Text);
    if _Verbose then
        if self:IsGlobalEnvironment() then
            if Swift.m_LogLevel >= _Level then
                Logic.ExecuteInLuaLocalState(string.format(
                    [[GUI.AddStaticNote("%s")]],
                    _Text
                ));
            end
            return;
        end
        if Swift.m_LogLevel >= _Level then
            GUI.AddStaticNote(_Text);
        end
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

function debug(_Text, _Silent)
    Swift:Log("DEBUG: " .._Text, LOG_LEVEL_ALL, not _Silent);
end
function info(_Text, _Silent)
    Swift:Log("INFO: " .._Text, LOG_LEVEL_INFO, not _Silent);
end
function warn(_Text, _Silent)
    Swift:Log("WARNING: " .._Text, LOG_LEVEL_WARNING, not _Silent);
end
function error(_Text, _Silent)
    Swift:Log("ERROR: " .._Text, LOG_LEVEL_ERROR, not _Silent);
end

-- Lua base functions

function Swift:OverrideTable()
    API.OverrideTable();
end

function Swift:OverrideString()
    API.OverrideString();
end

function Swift:ConvertTableToString(_Table)
    assert(type(_Table) == "table");
    local String = "{";
    for k, v in pairs(_Table) do
        local key;
        if (tonumber(k)) then
            key = ""..k;
        else
            key = "\""..k.."\"";
        end
        if type(v) == "table" then
            String = String .. "[" .. key .. "] = " .. table.tostring(v) .. ", ";
        elseif type(v) == "number" then
            String = String .. "[" .. key .. "] = " .. v .. ", ";
        elseif type(v) == "string" then
            String = String .. "[" .. key .. "] = \"" .. v .. "\", ";
        elseif type(v) == "boolean" or type(v) == "nil" then
            String = String .. "[" .. key .. "] = " .. tostring(v) .. ", ";
        else
            String = String .. "[" .. key .. "] = \"" .. tostring(v) .. "\", ";
        end
    end
    String = String .. "}";
    return String;
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
        if self.m_ModuleRegister[i]["Global"] and self.m_ModuleRegister[i]["Global"].OnSaveGameLoaded then
            self.m_ModuleRegister[i]["Global"]:OnSaveGameLoaded();
        end
    end
end

function Swift:RestoreAfterLoad()
    debug("Loading save game", true);
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

    QSB.ScriptEvents.CustomValueChanged = Swift:CreateScriptEvent("Event_CustomValueChanged", nil);
end
function Swift:InitalizeEventsLocal()
    QSB.ScriptEvents.QuestFailure = Swift:CreateScriptEvent("Event_QuestFailure", nil);
    QSB.ScriptEvents.QuestInterrupt = Swift:CreateScriptEvent("Event_QuestInterrupt", nil);
    QSB.ScriptEvents.QuestReset = Swift:CreateScriptEvent("Event_QuestReset", nil);
    QSB.ScriptEvents.QuestSuccess = Swift:CreateScriptEvent("Event_QuestSuccess", nil);
    QSB.ScriptEvents.QuestTrigger = Swift:CreateScriptEvent("Event_QuestTrigger", nil);

    QSB.ScriptEvents.CustomValueChanged = Swift:CreateScriptEvent("Event_CustomValueChanged", nil);
end

function Swift:CreateScriptEvent(_Name, _Function)
    for i= 1, #self.m_ScriptEventRegister, 1 do
        if self.m_ScriptEventRegister[i][1] == _Name then
            return 0;
        end
    end
    local ID = #self.m_ScriptEventRegister+1;
    debug(string.format("Create script event %s", _Name), true);
    self.m_ScriptEventRegister[ID] = {_Name, _Function};
    return ID;
end

function Swift:CreateScriptEventAction(_ID, _Function)
    if self.m_ScriptEventRegister[_ID] then
        local Index;
        local EventName = self.m_ScriptEventRegister[_ID][1];
        self.m_ScriptEventActions[_ID] = self.m_ScriptEventActions[_ID] or {};
        table.insert(self.m_ScriptEventActions[_ID], {EventName, _Function, true});
        Index = #self.m_ScriptEventActions[_ID];
        debug(string.format("Bind script event action %s for event %d", EventName, _ID), true);
        return Index;
    end
    return 0;
end

function Swift:SetScriptEventActionActive(_EventID, _ActionID, _Flag)
    if self.m_ScriptEventActions[_EventID] and self.m_ScriptEventActions[_EventID][_ActionID] then
        self.m_ScriptEventActions[_EventID][_ActionID][3] = _Flag == true;
    end
end

function Swift:DispatchScriptEvent(_ID, ...)
    if not self.m_ScriptEventRegister[_ID] then
        return;
    end
    -- Dispatch module events
    for i= 1, #self.m_ModuleRegister, 1 do
        local Env = "Local";
        if self:IsGlobalEnvironment() then
            Env = "Global";
        end
        if self.m_ModuleRegister[i][Env] and self.m_ModuleRegister[i][Env].OnEvent then
            debug(string.format(
                "Dispatching %s script event %s to Module %s",
                Env:lower(),
                self.m_ScriptEventRegister[_ID][1],
                self.m_ModuleRegister[i].Properties.Name
            ), true);
            self.m_ModuleRegister[i][Env]:OnEvent(_ID, self.m_ScriptEventRegister[_ID], unpack(arg));
        end
    end
    -- Dispatch user events
    if self.m_ScriptEventActions[_ID] then
        for k, v in pairs(self.m_ScriptEventActions[_ID]) do
            if v and v[2] and v[3] then
                v[2](unpack(arg));
            end
        end
    end
end

-- Custom Variable

function Swift:GetCustomVariable(_Name)
    return QSB.CustomVariable[_Name];
end

function Swift:SetCustomVariable(_Name, _Value)
    Swift:UpdateCustomVariable(_Name, _Value);
    local Value = tostring(_Value);
    if type(_Value) ~= "number" then
        Value = [["]] ..Value.. [["]];
    end
    local Execution = string.format([[Swift:UpdateCustomVariable("%s", %s)]], _Name, Value);
    if GUI then
        GUI.SendScriptCommand(Execution);
    else
        Logic.ExecuteInLuaLocalState(Execution);
    end
end

function Swift:UpdateCustomVariable(_Name, _Value)
    if QSB.CustomVariable[_Name] then
        local Old = QSB.CustomVariable[_Name];
        QSB.CustomVariable[_Name] = _Value;
        Swift:DispatchScriptEvent(
            QSB.ScriptEvents.CustomValueChanged,
            _Name,
            Old,
            _Value
        );
    else
        QSB.CustomVariable[_Name] = _Value;
        Swift:DispatchScriptEvent(
            QSB.ScriptEvents.CustomValueChanged,
            _Name,
            nil,
            _Value
        );
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
        if self.m_ModuleRegister[i]["Global"] and self.m_ModuleRegister[i]["Global"].OnLanguageSelected then
            self.m_ModuleRegister[i]["Global"]:OnLanguageSelected(_Language);
        end
        if self.m_ModuleRegister[i]["Local"] and self.m_ModuleRegister[i]["Local"].OnLanguageSelected then
            self.m_ModuleRegister[i]["Local"]:OnLanguageSelected(_Language);
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

function Swift:CopyTable(_Table1, _Table2)
    _Table1 = _Table1 or {};
    _Table2 = _Table2 or {};
    for k, v in pairs(_Table1) do
        if "table" == type(v) then
            _Table2[k] = _Table2[k] or {};
            for kk, vv in pairs(self:CopyTable(v, _Table2[k])) do
                _Table2[k][kk] = _Table2[k][kk] or vv;
            end
        else
            _Table2[k] = v;
        end
    end
    return _Table2;
end

-- Jobs

function Swift_EventJob_WaitForLoadScreenHidden()
    if XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 0 then
        GUI.SendScriptCommand("Swift.m_LoadScreenHidden = true");
        Swift.m_LoadScreenHidden = true;
        return true;
    end
end

