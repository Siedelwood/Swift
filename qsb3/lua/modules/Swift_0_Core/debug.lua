--[[
Swift_0_Core/Debug

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

Swift.m_CheckAtRun           = false;
Swift.m_TraceQuests          = false;
Swift.m_DevelopingCheats     = false;
Swift.m_DevelopingShell      = false;
Swift.m_DebugInputShown      = false;
Swift.m_ProcessDebugCommands = false;

function Swift:InitalizeDebugModeGlobal()
    self:InitalizeQsbDebugEvents();
end

function Swift:InitalizeDebugModeLocal()
    self:InitalizeQsbDebugHotkeys();
    self:InitalizeQsbDebugShell();
    self:InitalizeQsbDebugEvents();
end

function Swift:GlobalRestoreDebugAfterLoad()
    self:InitalizeQuestTrace();
end

function Swift:LocalRestoreDebugAfterLoad()
    self:InitalizeQsbDebugHotkeys();
    self:InitalizeQsbDebugShell();
    self:InitalizeDebugHotkeys();
end

function Swift:InitalizeQsbDebugEvents()
    QSB.ScriptEvents.DebugChatConfirmed = Swift:CreateScriptEvent(
        "Event_DebugModeChatConfirmed",
        nil
    );
    QSB.ScriptEvents.DebugModeStatusChanged = Swift:CreateScriptEvent(
        "Event_DebugModeStatusChanged",
        nil
    );
end

function Swift:ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
    if self:IsLocalEnvironment() then
        return;
    end

    self.m_CheckAtRun       = _CheckAtRun == true;
    self.m_TraceQuests      = _TraceQuests == true;
    self.m_DevelopingCheats = _DevelopingCheats == true;
    self.m_DevelopingShell  = _DevelopingShell == true;

    Swift:DispatchScriptEvent(
        QSB.ScriptEvents.DebugModeStatusChanged,
        self.m_CheckAtRun,
        self.m_TraceQuests,
        self.m_DevelopingCheats,
        self.m_DevelopingShell
    );
    self:InitalizeQuestTrace();
    
    Logic.ExecuteInLuaLocalState(string.format(
        [[
            Swift.m_CheckAtRun       = %s;
            Swift.m_TraceQuests      = %s;
            Swift.m_DevelopingCheats = %s;
            Swift.m_DevelopingShell  = %s;

            Swift:DispatchScriptEvent(
                QSB.ScriptEvents.DebugModeStatusChanged,
                Swift.m_CheckAtRun,
                Swift.m_TraceQuests,
                Swift.m_DevelopingCheats,
                Swift.m_DevelopingShell
            );
            Swift:InitalizeDebugHotkeys();
        ]],
        tostring(self.m_CheckAtRun),
        tostring(self.m_TraceQuests),
        tostring(self.m_DevelopingCheats),
        tostring(self.m_DevelopingShell)
    ));
end

function Swift:InitalizeQuestTrace()
    DEBUG_EnableQuestDebugKeys();
    DEBUG_QuestTrace(self.m_TraceQuests == true);
end

function Swift:InitalizeDebugHotkeys()
    if Network.IsNATReady ~= nil and Framework.IsNetworkGame() then
        return;
    end
    if self.m_DevelopingCheats then
        KeyBindings_EnableDebugMode(1);
        KeyBindings_EnableDebugMode(2);
        KeyBindings_EnableDebugMode(3);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock", 1);
        self.m_GameClock = true;
    else
        KeyBindings_EnableDebugMode(0);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock", 0);
        self.m_GameClock = false;
    end
end

function Swift:InitalizeQsbDebugHotkeys()
    if Framework.IsNetworkGame() then
        return;
    end
    Input.KeyBindDown(Keys.ModifierControl + Keys.ModifierShift + Keys.ModifierAlt + Keys.R, "Swift:ExecuteQsbDebugHotkey('RestartMap')", 30, false);
end

function Swift:ExecuteQsbDebugHotkey(_Type)
    if self.m_DevelopingCheats then
        if _Type == 'RestartMap' then
            Camera.RTS_FollowEntity(0);
            Framework.RestartMap();
        end
    end
end

function Swift:InitalizeQsbDebugShell()
    if not Framework.IsNetworkGame() then
        GUI_Chat.Abort = function()
        end
    end

    GUI_Chat.Confirm = function()
        local MotherWidget = "/InGame/Root/Normal/ChatInput";
        XGUIEng.ShowWidget(MotherWidget, 0);
        local ChatMessage = XGUIEng.GetText("/InGame/Root/Normal/ChatInput/ChatInput");
        g_Chat.JustClosed = 1;
        if not Framework.IsNetworkGame() then
            Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
        end
        Input.GameMode();
        if ChatMessage:len() > 0 and Framework.IsNetworkGame() then
            if Swift.m_DevelopingShell then
                Swift.m_ChatBoxInput = ChatMessage;
            end
            GUI.SendChatMessage(ChatMessage, GUI.GetPlayerID(), g_Chat.CurrentMessageType, g_Chat.CurrentWhisperTarget);
        end
    end

    if not Framework.IsNetworkGame() then
        QSB_DEBUG_InputBoxJob = function()
            -- Not allowed
            if not Swift.m_DevelopingShell then
                return true;
            end
            if ModuleInputOutputCore then
                return true;
            end
            -- Call cheap version
            Swift.m_ProcessDebugCommands = true;
            Swift:DisplayQsbDebugShell();
        end
        Input.KeyBindDown(Keys.ModifierShift + Keys.OemPipe, "Swift:OpenQsbDebugShell()", 30, false);
    end
end

function Swift:OpenQsbDebugShell()
    -- Text input will only be evaluated in the original version of the game
    -- and in Singleplayer History Edition.
    if Network.IsNATReady ~= nil and Framework.IsNetworkGame() then
        return;
    end
    StartSimpleHiResJob('QSB_DEBUG_InputBoxJob');
end

function Swift:IsProcessDebugCommands()
    return self.m_ProcessDebugCommands;
end

function Swift:SetProcessDebugCommands(_Debug)
    self.m_ProcessDebugCommands = _Debug;
end

function Swift:DisplayQsbDebugShell()
    local MotherWidget = "/InGame/Root/Normal/ChatInput";
    if not self.m_DebugInputShown then
        Input.ChatMode();
        if not Framework.IsNetworkGame() then
            Game.GameTimeSetFactor(GUI.GetPlayerID(), 0);
        end
        XGUIEng.ShowWidget(MotherWidget, 1);
        XGUIEng.SetText(MotherWidget.. "/ChatInput", "");
        XGUIEng.SetFocus(MotherWidget.. "/ChatInput");
        self.m_DebugInputShown = true;
    elseif self.m_ChatBoxInput then
        self.m_ChatBoxInput = string.gsub(self.m_ChatBoxInput,"'","\'");
        self:ConfirmQsbDebugShell();
        GUI.SendScriptCommand([[
            Swift:DispatchScriptEvent(
                QSB.ScriptEvents.DebugChatConfirmed, 
                "]]..self.m_ChatBoxInput..[["
            );
        ]]);
        self:DispatchScriptEvent(
            QSB.ScriptEvents.DebugChatConfirmed,
            self.m_ChatBoxInput
        );
        self.m_ProcessDebugCommands = false;
        self.m_DebugInputShown = nil;
        return true;
    end
end

function Swift:ConfirmQsbDebugShell()
    if self:IsProcessDebugCommands() then
        if self.m_ChatBoxInput == "restartmap" then
            Framework.RestartMap();
        else
            if string.find(self.m_ChatBoxInput, "^> .*$") then
                GUI.SendScriptCommand(self.m_ChatBoxInput.sub(self.m_ChatBoxInput, 3), true);
            elseif string.find(self.m_ChatBoxInput, "^>> .*$") then
                GUI.SendScriptCommand(self.m_ChatBoxInput.sub(self.m_ChatBoxInput, 4), false);
            end
        end
    end
end

