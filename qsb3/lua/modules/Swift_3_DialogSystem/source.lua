--[[
Swift_3_DialogSystem/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleDialogSystem = {
    Properties = {
        Name = "ModuleDialogSystem",
    },

    Global = {
        DialogPageCounter = 0,
        DialogCounter = 0,
        Dialog = {},
        DialogQueue = {},
    },
    Local = {
        Dialog = {},
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

QSB.Dialog = {
    TIMER_PER_CHAR = 0.175,
    CAMERA_ROTATIONDEFAULT = -45,
    CAMERA_ZOOMDEFAULT = 0.5,
    DLGCAMERA_ROTATIONDEFAULT = -45,
    DLGCAMERA_ZOOMDEFAULT = 0.15,
}

-- Global ------------------------------------------------------------------- --

function ModuleDialogSystem.Global:OnGameStart()
    for i= 1, 8 do
        self.DialogQueue[i] = {};
    end
    
    -- Quests can not be decided while a dialog is active. This must be done to
    -- prevent flickering when a quest ends. Dialog quests themselves must run!
    API.AddDisableDecisionCondition(function(_PlayerID, _Quest)
        if ModuleDialogSystem.Global.Dialog[_PlayerID] ~= nil then
            return _Quest.Identifier:contains("DialogSystemQuest_");
        end
        return true;
    end);
    -- Updates the dialog queue for all players
    API.StartHiResJob(function()
        for i= 1, 8 do
            ModuleDialogSystem.Global:Update(i);
        end
    end);
end

function ModuleDialogSystem.Global:OnEvent(_ID, _Event, _PlayerID)
    if _ID == QSB.ScriptEvents.EscapePressed then
        if self.Dialog[_PlayerID] ~= nil then
            if Logic.GetTime() - self.Dialog[_PlayerID].PageStartedTime >= 2 then
                local PageID = self.Dialog[_PlayerID].CurrentPage;
                local Page = self.Dialog[_PlayerID][PageID];
                if not self.Dialog[_PlayerID].DisableSkipping and not Page.DisableSkipping and not Page.MC then
                    self:NextPage(_PlayerID);
                end
            end
        end
    end
end

function ModuleDialogSystem.Global:StartDialog(_Name, _PlayerID, _Data)
    self.DialogQueue[_PlayerID] = self.DialogQueue[_PlayerID] or {};
    self.DialogCounter = (self.DialogCounter or 0) +1;
    _Data.DialogName = "Dialog #" .. self.DialogCounter;
    table.insert(self.DialogQueue[_PlayerID], {_Name, _Data});
end

function ModuleDialogSystem.Global:EndDialog(_PlayerID)
    API.FinishCinematicEvent(self.Dialog[_PlayerID].Name, _PlayerID);
    Logic.SetGlobalInvulnerability(0);
    if self.Dialog[_PlayerID].Finished then
        self.Dialog[_PlayerID]:Finished();
    end
    Logic.ExecuteInLuaLocalState(string.format(
        "ModuleDialogSystem.Local:EndDialog(%d, %s)",
        _PlayerID,
        table.tostring(self.Dialog[_PlayerID])
    ));
    self.Dialog[_PlayerID] = nil;
end

function ModuleDialogSystem.Global:CanStartDialog(_PlayerID)
    return  self.Dialog[_PlayerID] == nil and
            not API.IsCinematicEventActive(_PlayerID) and
            not API.IsLoadscreenVisible();
end

function ModuleDialogSystem.Global:NextDialog(_PlayerID)
    if self:CanStartDialog(_PlayerID) then
        local DialogData = table.remove(self.DialogQueue[_PlayerID], 1);
        API.StartCinematicEvent(DialogData[1], _PlayerID);

        local Dialog = DialogData[2];
        Dialog.Name = DialogData[1];
        Dialog.PlayerID = _PlayerID;
        Dialog.CurrentPage = 0;
        self.Dialog[_PlayerID] = Dialog;
        if Dialog.EnableGlobalImmortality then
            Logic.SetGlobalInvulnerability(1);
        end
        if self.Dialog[_PlayerID].Starting then
            self.Dialog[_PlayerID]:Starting();
        end

        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleDialogSystem.Local:StartDialog(%d, %s)",
            _PlayerID,
            table.tostring(Dialog)
        ));
        self:NextPage(_PlayerID);
    end
end

function ModuleDialogSystem.Global:NextPage(_PlayerID)
    if self.Dialog[_PlayerID] == nil then
        return;
    end

    self.Dialog[_PlayerID].CurrentPage = self.Dialog[_PlayerID].CurrentPage +1;
    self.Dialog[_PlayerID].PageStartedTime = Logic.GetTime();
    if self.Dialog[_PlayerID].PageQuest then
        API.StopQuest(self.Dialog[_PlayerID].PageQuest, true);
    end

    local PageID = self.Dialog[_PlayerID].CurrentPage;
    if PageID == -1 or PageID == 0 then
        self:EndDialog(_PlayerID);
        return;
    end
    local Page = self.Dialog[_PlayerID][PageID];
    if type(Page) == "table" then
        if Page.MC then
            for i= 1, #Page.MC, 1 do
                if type(Page.MC[i][3]) == "function" then
                    self.Dialog[_PlayerID][PageID].MC[i].Visible = not Page.MC[i][3](_PlayerID, PageID, i)
                end
            end
        end
        
        if PageID <= #self.Dialog[_PlayerID] then
            if self.Dialog[_PlayerID][PageID].Action then
                self.Dialog[_PlayerID][PageID]:Action();
            end
            self.Dialog[_PlayerID].PageQuest = self:DisplayPage(_PlayerID, PageID);
        else
            self:EndDialog(_PlayerID);
        end
    elseif type(Page) == "number" or type(Page) == "string" then
        local Target = self:GetPageIDByName(_PlayerID, self.Dialog[_PlayerID][PageID]);
        self.Dialog[_PlayerID].CurrentPage = Target -1;
        self:NextPage(_PlayerID);
    else
        self:EndDialog(_PlayerID);
    end
end

function ModuleDialogSystem.Global:OnOptionSelected(_PlayerID, _OptionID)
    if self.Dialog[_PlayerID] == nil then
        return;
    end
    local PageID = self.Dialog[_PlayerID].CurrentPage;
    if type(self.Dialog[_PlayerID][PageID]) ~= "table" then
        return;
    end
    local Page = self.Dialog[_PlayerID][PageID];
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
            self.Dialog[_PlayerID][PageID].MC.Selected = Option.ID;
            self.Dialog[_PlayerID].CurrentPage = self:GetPageIDByName(_PlayerID, Target) -1;
            self:NextPage(_PlayerID);
        end
    end
end

function ModuleDialogSystem.Global:DisplayPage(_PlayerID, _PageID)
    if self.Dialog[_PlayerID] == nil then
        return;
    end

    self.DialogPageCounter = self.DialogPageCounter +1;
    local Page = self.Dialog[_PlayerID][_PageID];
    local QuestName = "DialogSystemQuest_" .._PlayerID.. "_" ..self.DialogPageCounter;
    local QuestText = API.ConvertPlaceholders(API.Localize(Page.Text));
    local Extension = "";
    if not self.Dialog[_PlayerID].DisableSkipping and not Page.DisableSkipping and not Page.MC then
        Extension = API.ConvertPlaceholders(API.Localize(ModuleDialogSystem.Shared.Text.Continue));
    end
    local Sender = Page.Sender or _PlayerID;
    AddQuest {
        Name        = QuestName,
        Suggestion  = QuestText .. Extension,
        Sender      = (Sender == -1 and _PlayerID) or Sender,
        Receiver    = _PlayerID,

        Goal_NoChange(),
        Trigger_Time(0),
    }

    Logic.ExecuteInLuaLocalState(string.format(
        [[ModuleDialogSystem.Local:DisplayPage(%d, %s)]],
        _PlayerID,
        table.tostring(Page)
    ));
    return QuestName;
end

function ModuleDialogSystem.Global:GetCurrentDialog(_PlayerID)
    return self.Dialog[_PlayerID];
end

function ModuleDialogSystem.Global:GetCurrentDialogPage(_PlayerID)
    if self.Dialog[_PlayerID] then
        local PageID = self.Dialog[_PlayerID].CurrentPage;
        return self.Dialog[_PlayerID][PageID];
    end
end

function ModuleDialogSystem.Global:GetPageIDByName(_PlayerID, _Name)
    if type(_Name) == "string" then
        if self.Dialog[_PlayerID] ~= nil then
            for i= 1, #self.Dialog[_PlayerID], 1 do
                if type(self.Dialog[_PlayerID][i]) == "table" and self.Dialog[_PlayerID][i].Name == _Name then
                    return i;
                end
            end
        end
        return 0;
    end
    return _Name;
end

function ModuleDialogSystem.Global:Update(_PlayerID)
    if self:CanStartDialog(_PlayerID) then
        if #self.DialogQueue[_PlayerID] > 0 then
            self:NextDialog(_PlayerID);
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleDialogSystem.Local:OnGameStart()
    API.StartHiResJob(function()
        for i= 1, 8 do
            ModuleDialogSystem.Local:Update(i);
        end
    end);
end

function ModuleDialogSystem.Local:StartDialog(_PlayerID, _Data)
    if GUI.GetPlayerID() == _PlayerID then
        API.DeactivateNormalInterface();
        API.DeactivateBorderScroll();
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/Update", 0);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles", 1);
        XGUIEng.ShowWidget("/InGame/Root/3dWorldView", 0);
        Input.CutsceneMode();
        GUI.ClearSelection();

        self.Dialog[_PlayerID] = self.Dialog[_PlayerID] or {};

        -- Subtitles position backup
        self.Dialog[_PlayerID].SubtitlesPosition = {
            XGUIEng.GetWidgetScreenPosition("/InGame/Root/Normal/AlignBottomLeft/SubTitles")
        };

        -- Make camera backup
        self.Dialog[_PlayerID].Backup = {
            Rotation = Camera.RTS_GetRotationAngle(),
            Zoom     = Camera.RTS_GetZoomFactor(),
            Position = {Camera.RTS_GetLookAtPosition()},
            Speed    = Game.GameTimeGetFactor(_PlayerID),
        };

        if _Data.DisableFoW then
            Display.SetRenderFogOfWar(0);
        end
        if _Data.DisableBorderPins then
            Display.SetRenderBorderPins(0);
        end
        if not Framework.IsNetworkGame() then
            Game.GameTimeSetFactor(_PlayerID, 1);
        end
    end
end

function ModuleDialogSystem.Local:EndDialog(_PlayerID, _Data)
    if GUI.GetPlayerID() == _PlayerID then
        API.ActivateNormalInterface();
        API.ActivateBorderScroll();
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message", 0);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/Update", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles/Update", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles", 0);
        XGUIEng.ShowWidget("/InGame/Root/3dWorldView", 1);
        Input.GameMode()

        -- Load subtitles backup
        self:ResetSubtitlesPosition(_PlayerID);

        -- Load camera backup
        Camera.RTS_FollowEntity(0);
        if self.Dialog[_PlayerID].Backup then
            if _Data.RestoreCamera then
                Camera.RTS_SetRotationAngle(self.Dialog[_PlayerID].Backup.Rotation);
                Camera.RTS_SetZoomFactor(self.Dialog[_PlayerID].Backup.Zoom);
                Camera.RTS_SetLookAtPosition(
                    self.Dialog[_PlayerID].Backup.Position[1],
                    self.Dialog[_PlayerID].Backup.Position[2]
                );
            end
            if _Data.RestoreGameSpeed and not Framework.IsNetworkGame() then
                Game.GameTimeSetFactor(_PlayerID, self.Dialog[_PlayerID].Backup.Speed);
            end
        end

        self.Dialog[_PlayerID] = nil;
        Display.SetRenderFogOfWar(1);
        Display.SetRenderBorderPins(1);
    end
end

function ModuleDialogSystem.Local:DisplayPage(_PlayerID, _PageData)
    if GUI.GetPlayerID() == _PlayerID then
        GUI.ClearSelection();

        self.Dialog[_PlayerID].PageData = _PageData;
        if _PageData.Sender ~= -1 then
            -- XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message", 1);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message", 1);
            XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomLeft/Message", 1);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/QuestLog", 0);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/Update", 0);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles/Update", 1);
            self:ResetPlayerPortrait(_PageData.Sender);
            self:ResetSubtitlesPosition(_PlayerID);
            self:SetSubtitlesText(_PlayerID);
            self:SetSubtitlesPosition(_PlayerID);
        else
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message", 0);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles", 1);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles/Update", 1);
            self:ResetSubtitlesPosition(_PlayerID);
            self:SetSubtitlesText(_PlayerID);
            self:SetSubtitlesPosition(_PlayerID);
        end

        if _PageData.Target then
            Camera.RTS_FollowEntity(GetID(_PageData.Target));
        else
            Camera.RTS_FollowEntity(0);
        end
        if _PageData.Position then
            Camera.RTS_ScrollSetLookAt(_PageData.Position.X, _PageData.Position.Y);
        end
        if _PageData.Zoom then
            Camera.RTS_SetZoomFactorMin(_PageData.Zoom -0.00001);
            Camera.RTS_SetZoomFactor(_PageData.Zoom);
            Camera.RTS_SetZoomFactorMax(_PageData.Zoom +0.00001);
        end
        if _PageData.Rotation then
            Camera.RTS_SetRotationAngle(_PageData.Rotation);
        end
        if _PageData.MC then
            self:SetOptionsDialogContent(_PlayerID);
        end
    end
end

function ModuleDialogSystem.Local:SetSubtitlesText(_PlayerID)
    local PageData = self.Dialog[_PlayerID].PageData;
    local MotherWidget = "/InGame/Root/Normal/AlignBottomLeft/SubTitles";
    local QuestText = API.ConvertPlaceholders(API.Localize(PageData.Text));
    local Extension = "";
    if not self.Dialog[_PlayerID].DisableSkipping and not PageData.DisableSkipping and not PageData.MC then
        Extension = API.ConvertPlaceholders(API.Localize(ModuleDialogSystem.Shared.Text.Continue));
    end
    XGUIEng.SetText(MotherWidget.. "/VoiceText1", QuestText .. Extension);
end

function ModuleDialogSystem.Local:SetSubtitlesPosition(_PlayerID)
    local PageData = self.Dialog[_PlayerID].PageData;
    local MotherWidget = "/InGame/Root/Normal/AlignBottomLeft/SubTitles";
    local Height = XGUIEng.GetTextHeight(MotherWidget.. "/VoiceText1", true);
    local W, H = XGUIEng.GetWidgetSize(MotherWidget.. "/VoiceText1");

    local X,Y = XGUIEng.GetWidgetLocalPosition(MotherWidget);
    if PageData.Sender ~= -1 then
        XGUIEng.SetWidgetSize(MotherWidget.. "/BG", W + 10, Height + 120);
        Y = 675 - Height;
        XGUIEng.SetWidgetLocalPosition(MotherWidget, X, Y);
    else
        XGUIEng.SetWidgetSize(MotherWidget.. "/BG", W + 10, Height + 35);
        Y = 1115 - Height;
        XGUIEng.SetWidgetLocalPosition(MotherWidget, 46, Y);
    end
end

function ModuleDialogSystem.Local:ResetPlayerPortrait(_PlayerID)
    local PortraitWidget = "/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/3DPortraitFaceFX";
    local Actor = g_PlayerPortrait[_PlayerID];
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives", 0);
    SetPortraitWithCameraSettings(PortraitWidget, Actor);
    GUI.PortraitWidgetSetRegister(PortraitWidget, "Mood_Friendly", 1,2,0);
    GUI.PortraitWidgetSetRegister(PortraitWidget, "Mood_Angry", 1,2,0);
end

function ModuleDialogSystem.Local:ResetSubtitlesPosition(_PlayerID)
    local Position = self.Dialog[_PlayerID].SubtitlesPosition;
    local SubtitleWidget = "/InGame/Root/Normal/AlignBottomLeft/SubTitles";
    XGUIEng.SetWidgetScreenPosition(SubtitleWidget, Position[1], Position[2]);
end

function ModuleDialogSystem.Local:SetOptionsDialogContent(_PlayerID)
    local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
    local PageData = self.Dialog[_PlayerID].PageData;

    local Listbox = XGUIEng.GetWidgetID(Widget .. "/ListBox");
    XGUIEng.ListBoxPopAll(Listbox);
    self.Dialog[_PlayerID].MCSelectionOptionsMap = {};
    for i=1, #PageData.MC, 1 do
        if PageData.MC[i].Visible ~= false then
            XGUIEng.ListBoxPushItem(Listbox, PageData.MC[i][1]);
            table.insert(self.Dialog[_PlayerID].MCSelectionOptionsMap, PageData.MC[i].ID);
        end
    end
    XGUIEng.ListBoxSetSelectedIndex(Listbox, 0);

    self:SetOptionsDialogPosition(_PlayerID);
    self.Dialog[_PlayerID].MCSelectionIsShown = true;
end

function ModuleDialogSystem.Local:SetOptionsDialogPosition(_PlayerID)
    local Screen = {GUI.GetScreenSize()};
    local PortraitWidget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
    local PageData = self.Dialog[_PlayerID].PageData;

    self.Dialog[_PlayerID].MCSelectionBoxPosition = {
        XGUIEng.GetWidgetScreenPosition(PortraitWidget)
    };

    -- Choice
    local ChoiceSize = {XGUIEng.GetWidgetScreenSize(PortraitWidget)};
    local CX = math.ceil((Screen[1] * 0.06) + (ChoiceSize[1] /2));
    local CY = math.ceil(Screen[2] - (ChoiceSize[2] + 60 * (Screen[2]/540)));
    if PageData.Sender == -1 then
        CX = 15 * (Screen[1]/960);
        CY = math.ceil(Screen[2] - (ChoiceSize[2] + 0 * (Screen[2]/540)));
    end
    XGUIEng.SetWidgetScreenPosition(PortraitWidget, CX, CY);
    XGUIEng.PushPage(PortraitWidget, false);
    XGUIEng.ShowWidget(PortraitWidget, 1);

    -- Text
    if PageData.Sender == -1 then
        local TextWidget = "/InGame/Root/Normal/AlignBottomLeft/SubTitles";
        local DX,DY = XGUIEng.GetWidgetLocalPosition(TextWidget);
        XGUIEng.SetWidgetLocalPosition(TextWidget, DX, DY-220);
    end
end

function ModuleDialogSystem.Local:OnOptionSelected(_PlayerID)
    local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
    local Position = self.Dialog[_PlayerID].MCSelectionBoxPosition;
    XGUIEng.SetWidgetScreenPosition(Widget, Position[1], Position[2]);
    XGUIEng.ShowWidget(Widget, 0);
    XGUIEng.PopPage();

    local Selected = XGUIEng.ListBoxGetSelectedIndex(Widget .. "/ListBox")+1;
    local AnswerID = self.Dialog[_PlayerID].MCSelectionOptionsMap[Selected];
    GUI.SendScriptCommand(string.format(
        "ModuleDialogSystem.Global:OnOptionSelected(%d, %d)",
        _PlayerID,
        AnswerID
    ))
end

function ModuleDialogSystem.Local:Update(_PlayerID)
    if GUI.GetPlayerID() == _PlayerID and self.Dialog[_PlayerID] then
        -- Multiple Choice
        if self.Dialog[_PlayerID].MCSelectionIsShown then
            local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
            if XGUIEng.IsWidgetShown(Widget) == 0 then
                self.Dialog[_PlayerID].MCSelectionIsShown = false;
                self:OnOptionSelected(_PlayerID);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleDialogSystem);

