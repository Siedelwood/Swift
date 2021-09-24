--[[
Swift_0_Core/Debug

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

Swift.m_CheckAtRun       = false;
Swift.m_TraceQuests      = false;
Swift.m_DevelopingCheats = false;
Swift.m_DevelopingShell  = false;
Swift.m_DebugInputShown  = false;

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
    Input.KeyBindDown(Keys.ModifierControl + Keys.ModifierAlt + Keys.R, "Swift:ExecuteQsbDebugHotkey('RestartMap')", 2);
end

function Swift:ExecuteQsbDebugHotkey(_Type)
    if self.m_DevelopingCheats then
        if _Type == 'RestartMap' then
            Framework.RestartMap();
        end
    end
end

function Swift:InitalizeQsbDebugShell()
    GUI_Chat.Abort = function() end

    GUI_Chat.Confirm = function()
        local MotherWidget = "/InGame/Root/Normal/ChatInput";
        Input.GameMode();
        XGUIEng.ShowWidget(MotherWidget, 0);
        Swift.m_ChatBoxInput = XGUIEng.GetText(MotherWidget.. "/ChatInput");
        g_Chat.JustClosed = 1;
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
    end

    QSB_DEBUG_InputBoxJob = function()
        -- Not allowed
        if not Swift.m_DevelopingShell then
            return true;
        end
        -- Better module installed
        if ModuleInputOutputCore then
            API.ShowTextInput();
            return true;
        end
        -- Call cheap version
        Swift:DisplayQsbDebugShell();
    end

    Input.KeyBindDown(Keys.ModifierControl + Keys.X, "Swift:OpenQsbDebugShell()", 2);
end

function Swift:OpenQsbDebugShell()
    StartSimpleHiResJob('QSB_DEBUG_InputBoxJob');
end

function Swift:DisplayQsbDebugShell()
    local MotherWidget = "/InGame/Root/Normal/ChatInput";
        if not Swift.m_DebugInputShown then
            Input.ChatMode();
            Game.GameTimeSetFactor(GUI.GetPlayerID(), 0);
            XGUIEng.ShowWidget(MotherWidget, 1);
            XGUIEng.SetText(MotherWidget.. "/ChatInput", "");
            XGUIEng.SetFocus(MotherWidget.. "/ChatInput");
            Swift.m_DebugInputShown = true;
        elseif Swift.m_ChatBoxInput then
            Swift.m_ChatBoxInput = string.gsub(Swift.m_ChatBoxInput,"'","\'");
            Swift:ConfirmQsbDebugShell();
            GUI.SendScriptCommand([[
                Swift:DispatchScriptEvent(
                    QSB.ScriptEvents.DebugChatConfirmed, 
                    "]]..Swift.m_ChatBoxInput..[["
                );
            ]]);
            Swift:DispatchScriptEvent(
                QSB.ScriptEvents.DebugChatConfirmed, 
                Swift.m_ChatBoxInput
            );
            Swift.m_DebugInputShown = nil;
            return true;
        end
end

function Swift:ConfirmQsbDebugShell()
    if Swift.m_ChatBoxInput == "restartmap" then
        Framework.RestartMap();
    end
end

