--[[
Swift_3_DiscourseSystem/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleDiscourseSystem = {
    Properties = {
        Name = "ModuleDiscourseSystem",
    },

    Global = {
        Discourse = {},
        DiscourseQueue = {},
        DiscourseCounter = 0,
    },
    Local = {
        Discourse = {},
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        Text = {
            Continue = {
                de = "{cr}{cr}{azure}(Weiter mit ESC)",
                en = "{cr}{cr}{azure}(Continue with ESC)"
            }
        },
    },
};

QSB.CinematicEventTypes.Discourse = 5;

QSB.Discourse = {
    TIMER_PER_CHAR = 0.175,
    CAMERA_ANGLEDEFAULT = 43,
    CAMERA_ROTATIONDEFAULT = -45,
    CAMERA_ZOOMDEFAULT = 6500,
    CAMERA_FOVDEFAULT = 42,
    DLGCAMERA_ANGLEDEFAULT = 27,
    DLGCAMERA_ROTATIONDEFAULT = -45,
    DLGCAMERA_ZOOMDEFAULT = 1750,
    DLGCAMERA_FOVDEFAULT = 25,
}

-- Global ------------------------------------------------------------------- --

function ModuleDiscourseSystem.Global:OnGameStart()
    QSB.ScriptEvents.DiscourseStarted = API.RegisterScriptEvent("Event_DiscourseStarted");
    QSB.ScriptEvents.DiscourseEnded = API.RegisterScriptEvent("Event_DiscourseEnded");
    QSB.ScriptEvents.DiscoursePageShown = API.RegisterScriptEvent("Event_DiscoursePageShown");
    QSB.ScriptEvents.DiscourseOptionSelected = API.RegisterScriptEvent("Event_DiscourseOptionSelected");
    QSB.ScriptEvents.DiscourseLeftClick = API.RegisterScriptEvent("Event_DiscourseLeftClick");
    
    for i= 1, 8 do
        self.DiscourseQueue[i] = {};
    end
    -- Updates the dialog queue for all players
    API.StartHiResJob(function()
        ModuleDiscourseSystem.Global:UpdateQueue();
        ModuleDiscourseSystem.Global:DiscourseExecutionController();
    end);
end

function ModuleDiscourseSystem.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.EscapePressed then
        self:SkipButtonPressed(arg[1]);
    elseif _ID == QSB.ScriptEvents.DiscourseStarted then
        self:NextPage(arg[1]);
    elseif _ID == QSB.ScriptEvents.DiscourseEnded then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.DiscourseEnded, %d, %s)]],
            arg[1],
            table.tostring(arg[2])
        ));
    elseif _ID == QSB.ScriptEvents.DiscoursePageShown then
        local Page = self.Discourse[arg[1]][arg[2]];
        if type(Page) == "table" then
            Page = table.tostring(Page);
        end
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.DiscoursePageShown, %d, %d, %s)]],
            arg[1],
            arg[2],
            Page
        ));
    elseif _ID == QSB.ScriptEvents.DiscourseOptionSelected then
        self:OnOptionSelected(arg[1], arg[2]);
    end
end

function ModuleDiscourseSystem.Global:UpdateQueue()
    for i= 1, 8 do
        if self:CanStartDiscourse(i) then
            local Next = ModuleDisplayCore.Global:LookUpCinematicInFromQueue(i);
            if Next and Next[1] == QSB.CinematicEventTypes.Discourse then
                self:NextDiscourse(i);
            end
        end
    end
end

function ModuleDiscourseSystem.Global:DiscourseExecutionController()
    for i= 1, 8 do
        if self.Discourse[i] then
            local PageID = self.Discourse[i].CurrentPage;
            local Page = self.Discourse[i][PageID];
            if Page and not Page.MC and Page.Duration > 0 and Page.AutoSkipPage then
                if (Page.Started + Page.Duration) < Logic.GetTime() then
                    self:NextPage(i);
                end
            end
        end
    end
end

function ModuleDiscourseSystem.Global:StartDiscourse(_Name, _PlayerID, _Data)
    self.DiscourseQueue[_PlayerID] = self.DiscourseQueue[_PlayerID] or {};
    ModuleDisplayCore.Global:PushCinematicEventToQueue(
        _PlayerID,
        QSB.CinematicEventTypes.Discourse,
        _Name,
        _Data
    );
end

function ModuleDiscourseSystem.Global:EndDiscourse(_PlayerID)
    Logic.SetGlobalInvulnerability(0);
    Logic.ExecuteInLuaLocalState(string.format(
        [[ModuleDiscourseSystem.Local:ResetTimerButtons(%d)]],
        _PlayerID
    ));
    API.SendScriptEvent(
        QSB.ScriptEvents.DiscourseEnded,
        _PlayerID,
        self.Discourse[_PlayerID]
    );
    if self.Discourse[_PlayerID].Finished then
        self.Discourse[_PlayerID]:Finished();
    end
    API.FinishCinematicEvent(self.Discourse[_PlayerID].Name, _PlayerID);
    self.Discourse[_PlayerID] = nil;
end

function ModuleDiscourseSystem.Global:NextDiscourse(_PlayerID)
    if self:CanStartDiscourse(_PlayerID) then
        local DiscourseData = ModuleDisplayCore.Global:PopCinematicEventFromQueue(_PlayerID);
        assert(DiscourseData[1] == QSB.CinematicEventTypes.Discourse);
        API.StartCinematicEvent(DiscourseData[2], _PlayerID);

        local Discourse = DiscourseData[3];
        Discourse.Name = DiscourseData[2];
        Discourse.PlayerID = _PlayerID;
        Discourse.LastSkipButtonPressed = 0;
        Discourse.CurrentPage = 0;
        if Discourse.EnableSoothingCamera == nil then
            Discourse.EnableSoothingCamera = true;
        end
        self.Discourse[_PlayerID] = Discourse;

        if Discourse.EnableGlobalImmortality then
            Logic.SetGlobalInvulnerability(1);
        end
        if self.Discourse[_PlayerID].Starting then
            self.Discourse[_PlayerID]:Starting();
        end

        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.DiscourseStarted, %d, %s)]],
            _PlayerID,
            table.tostring(self.Discourse[_PlayerID])
        ));
        API.SendScriptEvent(
            QSB.ScriptEvents.DiscourseStarted,
            _PlayerID,
            self.Discourse[_PlayerID]
        );
    end
end

function ModuleDiscourseSystem.Global:NextPage(_PlayerID)
    if self.Discourse[_PlayerID] == nil then
        return;
    end

    self.Discourse[_PlayerID].CurrentPage = self.Discourse[_PlayerID].CurrentPage +1;
    local PageID = self.Discourse[_PlayerID].CurrentPage;
    if PageID == -1 or PageID == 0 then
        self:EndDiscourse(_PlayerID);
        return;
    end

    local Page = self.Discourse[_PlayerID][PageID];
    if type(Page) == "table" then
        if PageID <= #self.Discourse[_PlayerID] then
            self.Discourse[_PlayerID][PageID].Started = Logic.GetTime();
            self.Discourse[_PlayerID][PageID].Duration = Page.Duration or -1;
            if self.Discourse[_PlayerID][PageID].Action then
                self.Discourse[_PlayerID][PageID]:Action();
            end
            self:DisplayPage(_PlayerID, PageID);
        else
            self:EndDiscourse(_PlayerID);
        end
    elseif type(Page) == "number" or type(Page) == "string" then
        local Target = self:GetPageIDByName(_PlayerID, self.Discourse[_PlayerID][PageID]);
        self.Discourse[_PlayerID].CurrentPage = Target -1;
        self:NextPage(_PlayerID);
    else
        self:EndDiscourse(_PlayerID);
    end
end

function ModuleDiscourseSystem.Global:DisplayPage(_PlayerID, _PageID)
    if self.Discourse[_PlayerID] == nil then
        return;
    end

    local Page = self.Discourse[_PlayerID][_PageID];
    if type(Page) == "table" then
        local PageID = self.Discourse[_PlayerID].CurrentPage;
        if Page.MC then
            for i= 1, #Page.MC, 1 do
                if type(Page.MC[i][3]) == "function" then
                    self.Discourse[_PlayerID][PageID].MC[i].Visible = Page.MC[i][3](_PlayerID, PageID, i);
                end
            end
        end
    end

    API.SendScriptEvent(
        QSB.ScriptEvents.DiscoursePageShown,
        _PlayerID,
        _PageID,
        self.Discourse[_PlayerID][_PageID]
    );
end

function ModuleDiscourseSystem.Global:SkipButtonPressed(_PlayerID, _PageID)
    if not self.Discourse[_PlayerID] then
        return;
    end
    if (self.Discourse[_PlayerID].LastSkipButtonPressed + 500) > Logic.GetTimeMs() then
        return;
    end
    local PageID = self.Discourse[_PlayerID].CurrentPage;
    if self.Discourse[_PlayerID][PageID].AutoSkipPage
    or self.Discourse[_PlayerID][PageID].MC then
        return;
    end
    if self.Discourse[_PlayerID][PageID].OnForward then
        self.Discourse[_PlayerID][PageID]:OnForward();
    end
    self.Discourse[_PlayerID].LastSkipButtonPressed = Logic.GetTimeMs();
    self:NextPage(_PlayerID);
end

function ModuleDiscourseSystem.Global:OnOptionSelected(_PlayerID, _OptionID)
    if self.Discourse[_PlayerID] == nil then
        return;
    end
    local PageID = self.Discourse[_PlayerID].CurrentPage;
    if type(self.Discourse[_PlayerID][PageID]) ~= "table" then
        return;
    end
    local Page = self.Discourse[_PlayerID][PageID];
    if Page.MC then
        local Option;
        for i= 1, #Page.MC, 1 do
            if Page.MC[i].ID == _OptionID then
                Option = Page.MC[i];
            end
        end
        if Option ~= nil then
            local Target = Option[2];
            if type(Option[2]) == "function" then
                Target = Option[2](_PlayerID, PageID, _OptionID);
            end
            self.Discourse[_PlayerID][PageID].MC.Selected = Option.ID;
            self.Discourse[_PlayerID].CurrentPage = self:GetPageIDByName(_PlayerID, Target) -1;
            self:NextPage(_PlayerID);
        end
    end
end

function ModuleDiscourseSystem.Global:GetCurrentDiscourse(_PlayerID)
    return self.Discourse[_PlayerID];
end

function ModuleDiscourseSystem.Global:GetCurrentDiscoursePage(_PlayerID)
    if self.Discourse[_PlayerID] then
        local PageID = self.Discourse[_PlayerID].CurrentPage;
        return self.Discourse[_PlayerID][PageID];
    end
end

function ModuleDiscourseSystem.Global:GetPageIDByName(_PlayerID, _Name)
    if type(_Name) == "string" then
        if self.Discourse[_PlayerID] ~= nil then
            for i= 1, #self.Discourse[_PlayerID], 1 do
                if type(self.Discourse[_PlayerID][i]) == "table" and self.Discourse[_PlayerID][i].Name == _Name then
                    return i;
                end
            end
        end
        return 0;
    end
    return _Name;
end

function ModuleDiscourseSystem.Global:CanStartDiscourse(_PlayerID)
    return  self.Discourse[_PlayerID] == nil and
            not API.IsCinematicEventActive(_PlayerID) and
            not API.IsLoadscreenVisible();
end

-- Local -------------------------------------------------------------------- --

function ModuleDiscourseSystem.Local:OnGameStart()
    QSB.ScriptEvents.DiscourseStarted = API.RegisterScriptEvent("Event_DiscourseStarted");
    QSB.ScriptEvents.DiscourseEnded = API.RegisterScriptEvent("Event_DiscourseEnded");
    QSB.ScriptEvents.DiscoursePageShown = API.RegisterScriptEvent("Event_DiscoursePageShown");
    QSB.ScriptEvents.DiscourseOptionSelected = API.RegisterScriptEvent("Event_DiscourseOptionSelected");
    QSB.ScriptEvents.DiscourseLeftClick = API.RegisterScriptEvent("Event_DiscourseLeftClick");

    self:OverrideTimerButtonClicked();
    self:OverrideThroneRoomFunctions();
end

function ModuleDiscourseSystem.Local:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.EscapePressed then
        self:SkipButtonPressed(arg[1]);
    elseif _ID == QSB.ScriptEvents.DiscourseStarted then
        self:StartDiscourse(arg[1], arg[2]);
    elseif _ID == QSB.ScriptEvents.DiscourseEnded then
        self:EndDiscourse(arg[1], arg[2]);
    elseif _ID == QSB.ScriptEvents.DiscoursePageShown then
        self:DisplayPage(arg[1], arg[2], arg[3]);
    end
end

function ModuleDiscourseSystem.Local:StartDiscourse(_PlayerID, _Discourse)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.Discourse[_PlayerID] = _Discourse;
    self.Discourse[_PlayerID].SubtitlesPosition = {
        XGUIEng.GetWidgetScreenPosition("/InGame/Root/Normal/AlignBottomLeft/SubTitles")
    };
    self.Discourse[_PlayerID].CurrentPage = 0;

    API.DeactivateNormalInterface();
    API.DeactivateBorderScroll();

    if not Framework.IsNetworkGame() then
        Game.GameTimeSetFactor(_PlayerID, 1);
    end
    self:ActivateCinematicMode(_PlayerID);
end

function ModuleDiscourseSystem.Local:EndDiscourse(_PlayerID, _Discourse)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end

    if not Framework.IsNetworkGame() then
        Game.GameTimeSetFactor(_PlayerID, 1);
    end
    self:DeactivateCinematicMode(_PlayerID);
    API.ActivateNormalInterface();
    API.ActivateBorderScroll();

    self.Discourse[_PlayerID] = nil;
    Display.SetRenderFogOfWar(1);
    Display.SetRenderBorderPins(1);
    Display.SetRenderSky(0);
end

function ModuleDiscourseSystem.Local:DisplayPage(_PlayerID, _PageID, _PageData)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.Discourse[_PlayerID][_PageID] = _PageData;
    self.Discourse[_PlayerID].CurrentPage = _PageID;
    if type(self.Discourse[_PlayerID][_PageID]) == "table" then
        self.Discourse[_PlayerID][_PageID].Started = Logic.GetTime();
        self:DisplayPageFader(_PlayerID, _PageID);
        self:DisplayPageActor(_PlayerID, _PageID);
        self:DisplayPageText(_PlayerID, _PageID);
        if self.Discourse[_PlayerID][_PageID].MC then
            self:DisplayPageOptionsDialog(_PlayerID, _PageID);
        end
    end
end

function ModuleDiscourseSystem.Local:DisplayPageFader(_PlayerID, _PageID)
    local Page = self.Discourse[_PlayerID][_PageID];
    g_Fade.To = Page.FaderAlpha or 0;

    local PageFadeIn = Page.FadeIn;
    if PageFadeIn then
        FadeIn(PageFadeIn);
    end

    local PageFadeOut = Page.FadeOut;
    if PageFadeOut then
        self.Discourse[_PlayerID].FaderJob = API.StartHiResJob(function(_Time, _FadeOut)
            if Logic.GetTimeMs() > _Time - (_FadeOut * 1000) then
                FadeOut(_FadeOut);
                return true;
            end
        end, Logic.GetTimeMs() + ((Page.Duration or 0) * 1000), PageFadeOut);
    end
end

function ModuleDiscourseSystem.Local:DisplayPageActor(_PlayerID, _PageID)
    local PortraitWidget = "/InGame/Root/Normal/AlignBottomLeft/Message";
    XGUIEng.ShowWidget(PortraitWidget, 1);
    XGUIEng.ShowAllSubWidgets(PortraitWidget, 1);
    XGUIEng.ShowWidget(PortraitWidget.. "/QuestLog", 0);
    XGUIEng.ShowWidget(PortraitWidget.. "/Update", 0);
    local Page = self.Discourse[_PlayerID][_PageID];
    if not Page.Actor then
        XGUIEng.ShowWidget(PortraitWidget, 0);
        return;
    end
    local Actor = self:GetPageActor(_PlayerID, _PageID);
    self:DisplayActorPortrait(_PlayerID, Actor);
end

function ModuleDiscourseSystem.Local:GetPageActor(_PlayerID, _PageID)
    local Actor = g_PlayerPortrait[_PlayerID];
    local Page = self.Discourse[_PlayerID][_PageID];
    if type(Page.Actor) == "string" then
        Actor = Page.Actor;
    elseif type(Page.Actor) == "number" then
        Actor = g_PlayerPortrait[Page.Actor];
    end
    -- If someone doesn't read the fucking manual...
    if not Models["Heads_" .. tostring(Actor)] then
        Actor = "H_NPC_Generic_Trader";
    end
    return Actor;
end

function ModuleDiscourseSystem.Local:DisplayPageText(_PlayerID, _PageID)
    local Page = self.Discourse[_PlayerID][_PageID];
    local SubtitlesWidget = "/InGame/Root/Normal/AlignBottomLeft/SubTitles";
    if not Page or not Page.Text or Page.Text == "" then
        XGUIEng.ShowWidget(SubtitlesWidget, 0);
        return;
    end
    XGUIEng.ShowWidget(SubtitlesWidget, 1);
    XGUIEng.ShowWidget(SubtitlesWidget.. "/Update", 0);
    XGUIEng.ShowWidget(SubtitlesWidget.. "/VoiceText1", 1);
    XGUIEng.ShowWidget(SubtitlesWidget.. "/BG", 1);

    local Text = API.ConvertPlaceholders(API.Localize(Page.Text));
    local Extension = "";
    if not Page.AutoSkipPage and not Page.MC then
        Extension = API.ConvertPlaceholders(API.Localize(ModuleDiscourseSystem.Shared.Text.Continue));
    end
    XGUIEng.SetText(SubtitlesWidget.. "/VoiceText1", Text .. Extension);
    self:SetSubtitlesPosition(_PlayerID, _PageID);
end

function ModuleDiscourseSystem.Local:SetSubtitlesPosition(_PlayerID, _PageID)
    local Page = self.Discourse[_PlayerID][_PageID];
    local MotherWidget = "/InGame/Root/Normal/AlignBottomLeft/SubTitles";
    local Height = XGUIEng.GetTextHeight(MotherWidget.. "/VoiceText1", true);
    local W, H = XGUIEng.GetWidgetSize(MotherWidget.. "/VoiceText1");

    local X,Y = XGUIEng.GetWidgetLocalPosition(MotherWidget);
    if Page.Actor then
        XGUIEng.SetWidgetSize(MotherWidget.. "/BG", W + 10, Height + 120);
        Y = 675 - Height;
        XGUIEng.SetWidgetLocalPosition(MotherWidget, X, Y);
    else
        XGUIEng.SetWidgetSize(MotherWidget.. "/BG", W + 10, Height + 35);
        Y = 1115 - Height;
        XGUIEng.SetWidgetLocalPosition(MotherWidget, 46, Y);
    end
end

function ModuleDiscourseSystem.Local:ResetSubtitlesPosition(_PlayerID)
    local Position = self.Discourse[_PlayerID].SubtitlesPosition;
    local SubtitleWidget = "/InGame/Root/Normal/AlignBottomLeft/SubTitles";
    XGUIEng.SetWidgetScreenPosition(SubtitleWidget, Position[1], Position[2]);
end

function ModuleDiscourseSystem.Local:OverrideTimerButtonClicked()
    GUI_Interaction.TimerButtonClicked_Orig_ModuleDiscourseSystem = GUI_Interaction.TimerButtonClicked;
    GUI_Interaction.TimerButtonClicked = function ()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local MotherContainerName = XGUIEng.GetWidgetNameByID(XGUIEng.GetWidgetsMotherID(CurrentWidgetID));
        local TimerNumber = tonumber(MotherContainerName);
        local QuestIndex = g_Interaction.TimerQuests[TimerNumber];

        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/Update", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles/Update", 1);
        if not (g_Interaction.CurrentMessageQuestIndex == QuestIndex and not QuestLog.IsQuestLogShown()) then
            ModuleDiscourseSystem.Local:ResetTimerButtons(GUI.GetPlayerID());
        end
        GUI_Interaction.TimerButtonClicked_Orig_ModuleDiscourseSystem();
    end
end

function ModuleDiscourseSystem.Local:ResetTimerButtons(_PlayerID)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    local MainWidget = "/InGame/Root/Normal/AlignTopLeft/QuestTimers/";
    for i= 1,6 do
        local ButtonWidget = MainWidget ..i.. "/TimerButton";
        local QuestIndex = g_Interaction.TimerQuests[i];
        if QuestIndex ~= nil then
            local Quest = Quests[QuestIndex];
            if g_Interaction.CurrentMessageQuestIndex == QuestIndex and not QuestLog.IsQuestLogShown() then
                g_Interaction.CurrentMessageQuestIndex = nil;
                g_VoiceMessageIsRunning = false;
                g_VoiceMessageEndTime = nil;
                XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait", 0);
                XGUIEng.ShowWidget(QuestLog.Widget.Main, 0);
                XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles", 0);
                XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives", 0);
                XGUIEng.HighLightButton(ButtonWidget, 0);
            end
            if Quest then
                self:DisplayActorPortrait(Quest.SendingPlayer);
            end
        end
    end
end

function ModuleDiscourseSystem.Local:DisplayActorPortrait(_PlayerID, _HeadModel)
    local PortraitWidget = "/InGame/Root/Normal/AlignBottomLeft/Message";
    local Actor = g_PlayerPortrait[_PlayerID];
    if _HeadModel then
        if not Models["Heads_" .. tostring(_HeadModel)] then
            _HeadModel = "H_NPC_Generic_Trader";
        end
        Actor = _HeadModel;
    end
    XGUIEng.ShowWidget(PortraitWidget.. "/MessagePortrait", 1);
    XGUIEng.ShowWidget(PortraitWidget.. "/QuestObjectives", 0);
    SetPortraitWithCameraSettings(PortraitWidget.. "/MessagePortrait/3DPortraitFaceFX", Actor);
    GUI.PortraitWidgetSetRegister(PortraitWidget.. "/MessagePortrait/3DPortraitFaceFX", "Mood_Friendly", 1,2,0);
    GUI.PortraitWidgetSetRegister(PortraitWidget.. "/MessagePortrait/3DPortraitFaceFX", "Mood_Angry", 1,2,0);
end

function ModuleDiscourseSystem.Local:DisplayPageOptionsDialog(_PlayerID, _PageID)
    local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
    local Screen = {GUI.GetScreenSize()};
    local Page = self.Discourse[_PlayerID][_PageID];
    local Listbox = XGUIEng.GetWidgetID(Widget .. "/ListBox");

    self.Discourse[_PlayerID].MCSelectionBoxPosition = {
        XGUIEng.GetWidgetScreenPosition(Widget)
    };

    XGUIEng.ListBoxPopAll(Listbox);
    self.Discourse[_PlayerID].MCSelectionOptionsMap = {};
    for i=1, #Page.MC, 1 do
        if Page.MC[i].Visible ~= false then
            XGUIEng.ListBoxPushItem(Listbox, Page.MC[i][1]);
            table.insert(self.Discourse[_PlayerID].MCSelectionOptionsMap, Page.MC[i].ID);
        end
    end
    XGUIEng.ListBoxSetSelectedIndex(Listbox, 0);

    local wSize = {XGUIEng.GetWidgetScreenSize(Widget)};
    local xFix = math.ceil((Screen[1] /2) - (wSize[1] /2));
    local yFix = math.ceil(Screen[2] - (wSize[2] -10));
    if Page.Text and Page.Text ~= "" then
        yFix = math.ceil((Screen[2] /2) - (wSize[2] /2));
    end
    XGUIEng.SetWidgetScreenPosition(Widget, xFix, yFix);
    XGUIEng.PushPage(Widget, false);
    XGUIEng.ShowWidget(Widget, 1);
    self.Discourse[_PlayerID].MCSelectionIsShown = true;
end

function ModuleDiscourseSystem.Local:OnOptionSelected(_PlayerID)
    local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
    local Position = self.Discourse[_PlayerID].MCSelectionBoxPosition;
    XGUIEng.SetWidgetScreenPosition(Widget, Position[1], Position[2]);
    XGUIEng.ShowWidget(Widget, 0);
    XGUIEng.PopPage();

    local Selected = XGUIEng.ListBoxGetSelectedIndex(Widget .. "/ListBox")+1;
    local AnswerID = self.Discourse[_PlayerID].MCSelectionOptionsMap[Selected];

    API.SendScriptEvent(QSB.ScriptEvents.DiscourseOptionSelected, _PlayerID, AnswerID);
    API.BroadcastScriptEventToGlobal(
        QSB.ScriptEvents.DiscourseOptionSelected,
        _PlayerID,
        AnswerID
    );
end

function ModuleDiscourseSystem.Local:ThroneRoomCameraControl(_PlayerID, _Page)
    if _Page then
        -- Camera
        local Position = _Page.Camera.Position;
        if type(Position) ~= "table" then
            Position = GetPosition(_Page.Camera.Position);
        end
        Camera.RTS_SetLookAtPosition(Position.X, Position.Y);
        Camera.RTS_SetRotationAngle(_Page.Camera.Rotation);
        Camera.RTS_SetZoomAngle(_Page.Camera.Angle);
        Camera.RTS_SetZoomFactor(_Page.Camera.Distance / 18000);
        -- Multiple Choice
        if self.Discourse[_PlayerID].MCSelectionIsShown then
            local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
            if XGUIEng.IsWidgetShown(Widget) == 0 then
                self.Discourse[_PlayerID].MCSelectionIsShown = false;
                self:OnOptionSelected(_PlayerID);
            end
        end
    end
end

function ModuleDiscourseSystem.Local:ConvertPosition(_Table)
    local Position = _Table;
    if type(Position) ~= "table" then
        Position = GetPosition(_Table);
    end
    return Position.X, Position.Y, Position.Z;
end

function ModuleDiscourseSystem.Local:SkipButtonPressed(_PlayerID, _Page)
    if not self.Discourse[_PlayerID] then
        return;
    end
    -- Nothing to do?
end

function ModuleDiscourseSystem.Local:GetCurrentDiscourse(_PlayerID)
    return self.Discourse[_PlayerID];
end

function ModuleDiscourseSystem.Local:GetCurrentDiscoursePage(_PlayerID)
    if self.Discourse[_PlayerID] then
        local PageID = self.Discourse[_PlayerID].CurrentPage;
        return self.Discourse[_PlayerID][PageID];
    end
end

function ModuleDiscourseSystem.Local:GetPageIDByName(_PlayerID, _Name)
    if type(_Name) == "string" then
        if self.Discourse[_PlayerID] ~= nil then
            for i= 1, #self.Discourse[_PlayerID], 1 do
                if type(self.Discourse[_PlayerID][i]) == "table" and self.Discourse[_PlayerID][i].Name == _Name then
                    return i;
                end
            end
        end
        return 0;
    end
    return _Name;
end

function ModuleDiscourseSystem.Local:IsAnyCinematicEventActive(_PlayerID)
    for k, v in pairs(ModuleDisplayCore.Local.CinematicEventStatus[_PlayerID]) do
        if v == 1 then
            return true;
        end
    end
    return false;
end

function ModuleDiscourseSystem.Local:OverrideThroneRoomFunctions()
    GameCallback_Camera_ThroneroomCameraControl_Orig_ModuleDiscourseSystem = GameCallback_Camera_ThroneroomCameraControl;
    GameCallback_Camera_ThroneroomCameraControl = function(_PlayerID)
        GameCallback_Camera_ThroneroomCameraControl_Orig_ModuleDiscourseSystem(_PlayerID);
        if _PlayerID == GUI.GetPlayerID() then
            local Discourse = ModuleDiscourseSystem.Local:GetCurrentDiscourse(_PlayerID);
            if Discourse ~= nil then
                ModuleDiscourseSystem.Local:ThroneRoomCameraControl(
                    _PlayerID,
                    ModuleDiscourseSystem.Local:GetCurrentDiscoursePage(_PlayerID)
                );
            end
        end
    end
end

function ModuleDiscourseSystem.Local:ActivateCinematicMode(_PlayerID)
    if self.CinematicActive or GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.CinematicActive = true;

    local LoadScreenVisible = API.IsLoadscreenVisible();
    if LoadScreenVisible then
        XGUIEng.PopPage();
    end

    local PosX, PosY = Camera.RTS_GetLookAtPosition();
    local Rotation = Camera.RTS_GetRotationAngle();
    local ZoomFactor = Camera.RTS_GetZoomFactor();
    self.CameraBackup = {PosX, PosY, Rotation, ZoomFactor};

    XGUIEng.ShowWidget("/InGame/ThroneRoom", 1);
    XGUIEng.PushPage("/InGame/ThroneRoom/Main", false);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main", 1);
    XGUIEng.ShowAllSubWidgets("/InGame/ThroneRoom/Main", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/updater", 1);

    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/SpeechStartAgainOrStop", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/SpeechButtons/SpeechStartAgainOrStop", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/Update", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles/Update", 0);
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionDiscourse/Text", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionDiscourse/Title", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionDiscourse/Objectives", " ");

    GUI.ClearSelection();
    GUI.ClearNotes();
    GUI.ForbidContextSensitiveCommandsInSelectionState();
    GUI.ActivateCutSceneState();
    GUI.SetFeedbackSoundOutputState(0);
    GUI.EnableBattleSignals(false);
    Input.CutsceneMode();
    if not self.Discourse[_PlayerID].EnableFoW then
        Display.SetRenderFogOfWar(0);
    end
    if self.Discourse[_PlayerID].EnableSky then
        Display.SetRenderSky(1);
    end
    if not self.Discourse[_PlayerID].EnableBorderPins then
        Display.SetRenderBorderPins(0);
    end
    Display.SetUserOptionOcclusionEffect(0);
    Camera.SwitchCameraBehaviour(0);

    InitializeFader();
    g_Fade.To = 0;
    SetFaderAlpha(0);

    if LoadScreenVisible then
        XGUIEng.PushPage("/LoadScreen/LoadScreen", false);
    end
end

function ModuleDiscourseSystem.Local:DeactivateCinematicMode(_PlayerID)
    if not self.CinematicActive or GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.CinematicActive = false;

    g_Fade.To = 0;
    SetFaderAlpha(0);
    XGUIEng.PopPage();
    Camera.SwitchCameraBehaviour(0);
    Display.UseStandardSettings();
    Input.GameMode();
    GUI.EnableBattleSignals(true);
    GUI.SetFeedbackSoundOutputState(1);
    GUI.ActivateSelectionState();
    GUI.PermitContextSensitiveCommandsInSelectionState();
    Display.SetRenderSky(0);
    Display.SetRenderBorderPins(1);
    Display.SetRenderFogOfWar(1);
    if Options.GetIntValue("Display", "Occlusion", 0) > 0 then
        Display.SetUserOptionOcclusionEffect(1);
    end

    XGUIEng.SetText("/InGame/Root/Normal/AlignBottomLeft/SubTitlesVoiceText1", " ");
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/SpeechButtons/SpeechStartAgainOrStop", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/SpeechStartAgainOrStop", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/Update", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles/Update", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait", 0);

    XGUIEng.PopPage();
    XGUIEng.ShowWidget("/InGame/ThroneRoom", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", 0);

    Camera.RTS_SetLookAtPosition(self.CameraBackup[1], self.CameraBackup[2]);
    Camera.RTS_SetRotationAngle(self.CameraBackup[3]);
    Camera.RTS_SetZoomFactor(self.CameraBackup[4]);
    self.CameraBackup = nil;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleDiscourseSystem);

