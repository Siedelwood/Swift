--[[
Swift_1_DisplayCore/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleDisplayCore = {
    Properties = {
        Name = "ModuleDisplayCore",
    },

    Global = {
        CinematicEventID = 0,
        CinematicEventStatus = {},
    },
    Local = {
        CinematicEventStatus = {},

        ChatOptionsWasShown = false,
        MessageLogWasShown = false,
        PauseScreenShown = false,
        NormalModeHidden = false,
        BorderScrollDeactivated = false,
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
}

-- Global ------------------------------------------------------------------- --

function ModuleDisplayCore.Global:OnGameStart()
    QSB.ScriptEvents.CinematicActivated = API.RegisterScriptEvent("Event_CinematicEventActivated");
    QSB.ScriptEvents.CinematicConcluded = API.RegisterScriptEvent("Event_CinematicEventConcluded");
    QSB.ScriptEvents.BorderScrollLocked = API.RegisterScriptEvent("Event_BorderScrollLocked");
    QSB.ScriptEvents.BorderScrollReset = API.RegisterScriptEvent("Event_BorderScrollReset");
    QSB.ScriptEvents.GameInterfaceShown = API.RegisterScriptEvent("Event_GameInterfaceShown");
    QSB.ScriptEvents.GameInterfaceHidden = API.RegisterScriptEvent("Event_GameInterfaceHidden");
    QSB.ScriptEvents.BlackScreenShown = API.RegisterScriptEvent("Event_BlackScreenShown");
    QSB.ScriptEvents.BlackScreenHidden = API.RegisterScriptEvent("Event_BlackScreenHidden");

    for i= 1, 8 do
        self.CinematicEventStatus[i] = {};
    end
end

function ModuleDisplayCore.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.CinematicActivated then
        self.CinematicEventStatus[arg[2]][arg[1]] = 1;
    elseif _ID == QSB.ScriptEvents.CinematicConcluded then
        for i= 1, 8 do
            if self.CinematicEventStatus[i][arg[1]] then
                self.CinematicEventStatus[i][arg[1]] = 2;
            end
        end
    end
end

function ModuleDisplayCore.Global:GetNewCinematicEventID()
    self.CinematicEventID = self.CinematicEventID +1;
    return self.CinematicEventID;
end

function ModuleDisplayCore.Global:GetCinematicEventStatus(_InfoID)
    for i= 1, 8 do
        if self.CinematicEventStatus[i][_InfoID] then
            return self.CinematicEventStatus[i][_InfoID];
        end
    end
    return 0;
end

function ModuleDisplayCore.Global:ActivateCinematicEvent(_PlayerID)
    local ID = self:GetNewCinematicEventID();
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.CinematicActivated, %d, %d);",
        ID,
        _PlayerID
    ))
    API.SendScriptEvent(QSB.ScriptEvents.CinematicActivated, ID, _PlayerID);
    return ID;
end

function ModuleDisplayCore.Global:ConcludeCinematicEvent(_ID, _PlayerID)
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.CinematicConcluded, %d, %d);",
        _ID,
        _PlayerID
    ))
    API.SendScriptEvent(QSB.ScriptEvents.CinematicConcluded, _ID, _PlayerID);
end

-- Local -------------------------------------------------------------------- --

function ModuleDisplayCore.Local:OnGameStart()
    QSB.ScriptEvents.CinematicActivated = API.RegisterScriptEvent("Event_CinematicEventActivated");
    QSB.ScriptEvents.CinematicConcluded = API.RegisterScriptEvent("Event_CinematicEventConcluded");
    QSB.ScriptEvents.BorderScrollLocked = API.RegisterScriptEvent("Event_BorderScrollLocked");
    QSB.ScriptEvents.BorderScrollReset  = API.RegisterScriptEvent("Event_BorderScrollReset");
    QSB.ScriptEvents.GameInterfaceShown = API.RegisterScriptEvent("Event_GameInterfaceShown");
    QSB.ScriptEvents.GameInterfaceHidden = API.RegisterScriptEvent("Event_GameInterfaceHidden");
    QSB.ScriptEvents.BlackScreenShown = API.RegisterScriptEvent("Event_BlackScreenShown");
    QSB.ScriptEvents.BlackScreenHidden = API.RegisterScriptEvent("Event_BlackScreenHidden");

    for i= 1, 8 do
        self.CinematicEventStatus[i] = {};
    end
    self:OverrideInterfaceUpdateForCinematicMode();
    self:OverrideInterfaceThroneroomForCinematicMode();
end

function ModuleDisplayCore.Local:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.CinematicActivated then
        self.CinematicEventStatus[arg[2]][arg[1]] = 1;
    elseif _ID == QSB.ScriptEvents.CinematicConcluded then
        for i= 1, 8 do
            if self.CinematicEventStatus[i][arg[1]] then
                self.CinematicEventStatus[i][arg[1]] = 2;
            end
        end
    end
end

function ModuleDisplayCore.Local:GetCinematicEventStatus(_InfoID)
    for i= 1, 8 do
        if self.CinematicEventStatus[i][_InfoID] then
            return self.CinematicEventStatus[i][_InfoID];
        end
    end
    return 0;
end

function ModuleDisplayCore.Local:OverrideInterfaceUpdateForCinematicMode()
    API.AddBlockQuicksaveCondition(function()
        if ModuleDisplayCore.Local.NormalModeHidden
        or ModuleDisplayCore.Local.BorderScrollDeactivated
        or ModuleDisplayCore.Local.PauseScreenShown
        or API.IsCinematicEventActive(GUI.GetPlayerID()) then
            return true;
        end
    end);

    GameCallback_GameSpeedChanged_Orig_ModuleDisplayCoreInterface = GameCallback_GameSpeedChanged;
    GameCallback_GameSpeedChanged = function(_Speed)
        if not ModuleDisplayCore.Local.PauseScreenShown then
            GameCallback_GameSpeedChanged_Orig_ModuleDisplayCoreInterface(_Speed);
        end
    end

    MissionTimerUpdate_Orig_ModuleDisplayCoreInterface = MissionTimerUpdate;
    MissionTimerUpdate = function()
        MissionTimerUpdate_Orig_ModuleDisplayCoreInterface();
        if ModuleDisplayCore.Local.NormalModeHidden
        or ModuleDisplayCore.Local.PauseScreenShown then
            XGUIEng.ShowWidget("/InGame/Root/Normal/MissionTimer", 0);
        end
    end

    MissionGoodOrEntityCounterUpdate_Orig_ModuleDisplayCoreInterface = MissionGoodOrEntityCounterUpdate;
    MissionGoodOrEntityCounterUpdate = function()
        MissionGoodOrEntityCounterUpdate_Orig_ModuleDisplayCoreInterface();
        if ModuleDisplayCore.Local.NormalModeHidden
        or ModuleDisplayCore.Local.PauseScreenShown then
            XGUIEng.ShowWidget("/InGame/Root/Normal/MissionGoodOrEntityCounter", 0);
        end
    end

    MerchantButtonsUpdater_Orig_ModuleDisplayCoreInterface = GUI_Merchant.ButtonsUpdater;
    GUI_Merchant.ButtonsUpdater = function()
        MerchantButtonsUpdater_Orig_ModuleDisplayCoreInterface();
        if ModuleDisplayCore.Local.NormalModeHidden
        or ModuleDisplayCore.Local.PauseScreenShown then
            XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Merchant", 0);
        end
    end

    if GUI_Tradepost then
        TradepostButtonsUpdater_Orig_ModuleDisplayCoreInterface = GUI_Tradepost.ButtonsUpdater;
        GUI_Tradepost.ButtonsUpdater = function()
            TradepostButtonsUpdater_Orig_ModuleDisplayCoreInterface();
            if ModuleDisplayCore.Local.NormalModeHidden
            or ModuleDisplayCore.Local.PauseScreenShown then
                XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Tradepost", 0);
            end
        end
    end
end

function ModuleDisplayCore.Local:OverrideInterfaceThroneroomForCinematicMode()
    GameCallback_Camera_StartButtonPressed = function(_PlayerID)
    end
    OnStartButtonPressed = function()
        GameCallback_Camera_StartButtonPressed(GUI.GetPlayerID());
    end

    GameCallback_Camera_BackButtonPressed = function(_PlayerID)
    end
    OnBackButtonPressed = function()
        GameCallback_Camera_BackButtonPressed(GUI.GetPlayerID());
    end

    GameCallback_Camera_SkipButtonPressed = function(_PlayerID)
    end
    OnSkipButtonPressed = function()
        GameCallback_Camera_SkipButtonPressed(GUI.GetPlayerID());
    end

    GameCallback_Camera_ThroneRoomLeftClick = function(_PlayerID)
    end
    ThroneRoomLeftClick = function()
        GameCallback_Camera_ThroneRoomLeftClick(GUI.GetPlayerID());
    end

    GameCallback_Camera_ThroneroomCameraControl = function(_PlayerID)
    end
    ThroneRoomCameraControl = function()
        GameCallback_Camera_ThroneroomCameraControl(GUI.GetPlayerID());
    end
end

function ModuleDisplayCore.Local:InterfaceActivateColoredBackground(_R, _G, _B, _A)
    if self.PauseScreenShown then
        return;
    end
    self.PauseScreenShown = true;

    XGUIEng.PushPage("/InGame/Root/Normal/PauseScreen", false)
    XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 1);
    XGUIEng.SetMaterialColor("/InGame/Root/Normal/PauseScreen", 0, _R, _G, _B, _A);

    API.SendScriptEventToGlobal( QSB.ScriptEvents.BlackScreenShown, GUI.GetPlayerID());
    API.SendScriptEvent(QSB.ScriptEvents.BlackScreenShown, GUI.GetPlayerID());
end

function ModuleDisplayCore.Local:InterfaceDeactivateColoredBackground()
    if not self.PauseScreenShown then
        return;
    end
    self.PauseScreenShown = false;

    XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 0);
    XGUIEng.SetMaterialColor("/InGame/Root/Normal/PauseScreen", 0, 40, 40, 40, 180);
    XGUIEng.PopPage();

    API.SendScriptEventToGlobal( QSB.ScriptEvents.BlackScreenHidden, GUI.GetPlayerID());
    API.SendScriptEvent(QSB.ScriptEvents.BlackScreenHidden, GUI.GetPlayerID());
end

function ModuleDisplayCore.Local:InterfaceDeactivateBorderScroll(_PositionID)
    if self.BorderScrollDeactivated then
        return;
    end
    self.BorderScrollDeactivated = true;
    GameCallback_Camera_GetBorderscrollFactor_Orig_Interface = GameCallback_Camera_GetBorderscrollFactor;
	GameCallback_Camera_GetBorderscrollFactor = function() end;
    if _PositionID then
        Camera.RTS_FollowEntity(_PositionID);
    end
    Camera.RTS_SetZoomFactor(0.5000);
    Camera.RTS_SetZoomFactorMax(0.5001);
    Camera.RTS_SetZoomFactorMin(0.4999);

    API.SendScriptEventToGlobal(
        QSB.ScriptEvents.BorderScrollLocked,
        GUI.GetPlayerID(),
        (_PositionID or 0)
    );
    API.SendScriptEvent(QSB.ScriptEvents.BorderScrollLocked, GUI.GetPlayerID(), _PositionID);
end

function ModuleDisplayCore.Local:InterfaceActivateBorderScroll()
    if not self.BorderScrollDeactivated then
        return;
    end
    self.BorderScrollDeactivated = false;
	GameCallback_Camera_GetBorderscrollFactor = GameCallback_Camera_GetBorderscrollFactor_Orig_Interface;
    GameCallback_Camera_GetBorderscrollFactor_Orig_Interface = nil;
    Camera.RTS_FollowEntity(0);
    Camera.RTS_SetZoomFactor(0.5000);
    Camera.RTS_SetZoomFactorMax(0.5001);
    Camera.RTS_SetZoomFactorMin(0.0999);

    API.SendScriptEventToGlobal(QSB.ScriptEvents.BorderScrollReset, GUI.GetPlayerID());
    API.SendScriptEvent(QSB.ScriptEvents.BorderScrollReset, GUI.GetPlayerID());
end

function ModuleDisplayCore.Local:InterfaceDeactivateNormalInterface()
    if self.NormalModeHidden then
        return;
    end
    self.NormalModeHidden = true;

    XGUIEng.PushPage("/InGame/Root/Normal/NotesWindow", false);
    XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/TextMessages", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/SpeechStartAgainOrStop", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/BuildMenu", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/MapFrame", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopRight", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/Windows/Gold", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/Windows/Resources", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/Windows/Nutrition", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/Windows/Cleanliness", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/Windows/Clothes", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/Windows/Entertainment", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/Windows/Decoration", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/Windows/Prosperity", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/Windows/Military", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/UpdateFunction", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/UpdateFunction", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/Buttons", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/QuestLogButton", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/QuestTimers", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Merchant", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/MissionGoodOrEntityCounter", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/MissionTimer", 0);
    HideOtherMenus();
    if XGUIEng.IsWidgetShownEx("/InGame/Root/Normal/ChatOptions/Background") == 1 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions", 0);
        self.ChatOptionsWasShown = true;
    end
    if XGUIEng.IsWidgetShownEx("/InGame/Root/Normal/MessageLog/Name") == 1 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog", 0);
        self.MessageLogWasShown = true;
    end
    if g_GameExtraNo > 0 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Tradepost", 0);
    end

    API.SendScriptEventToGlobal(QSB.ScriptEvents.GameInterfaceHidden, GUI.GetPlayerID());
    API.SendScriptEvent(QSB.ScriptEvents.GameInterfaceHidden, GUI.GetPlayerID());
end

function ModuleDisplayCore.Local:InterfaceActivateNormalInterface()
    if not self.NormalModeHidden then
        return;
    end
    self.NormalModeHidden = false;

    XGUIEng.ShowWidget("/InGame/Root/Normal", 1);
    XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/SpeechStartAgainOrStop", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/BuildMenu", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/MapFrame", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopRight", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/UpdateFunction", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/Buttons", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/QuestLogButton", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/QuestTimers", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Merchant", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message", 1);
    XGUIEng.PopPage();
    
    -- Debug Clock
    -- if AddOnQuestDebug and AddOnQuestDebug.Local.GameClock then
    --     XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock", 1);
    -- end
    -- Timer
    if g_MissionTimerEndTime then
        XGUIEng.ShowWidget("/InGame/Root/Normal/MissionTimer", 1);
    end
    -- Counter
    if g_MissionGoodOrEntityCounterAmountToReach then
        XGUIEng.ShowWidget("/InGame/Root/Normal/MissionGoodOrEntityCounter", 1);
    end
    -- Chat Options
    if self.ChatOptionsWasShown then
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions", 1);
        self.ChatOptionsWasShown = false;
    end
    -- Message Log
    if self.MessageLogWasShown then
        XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog", 1);
        self.MessageLogWasShown = false;
    end
    -- Handelsposten
    if g_GameExtraNo > 0 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Tradepost", 1);
    end

    API.SendScriptEventToGlobal(QSB.ScriptEvents.GameInterfaceShown, GUI.GetPlayerID());
    API.SendScriptEvent(QSB.ScriptEvents.GameInterfaceShown, GUI.GetPlayerID());
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleDisplayCore);

