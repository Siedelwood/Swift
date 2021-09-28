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
        Dialog = {},
        DialogQueue = {},

        Text = {
            Continue = {
                de = "{cr}{cr}{azure}(Weiter mit ESC)",
                en = "{cr}{cr}{azure}(Continue with ESC)"
            }
        },
    },
    Local = {
        Dialog = {},
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {},
};

-- Global ------------------------------------------------------------------- --

function ModuleDialogSystem.Global:OnGameStart()
    for i= 1, 8 do
        ModuleDialogSystem.Global.DialogQueue[i] = {};
    end
    
    StartSimpleHiResJobEx(function()
        for i= 1, 8 do
            if ModuleDialogSystem.Global:CanStartDialog(i) then
                if #ModuleDialogSystem.Global.DialogQueue[i] > 0 then
                    ModuleDialogSystem.Global:NextDialog(i);
                end
            end
        end
    end);
end

function ModuleDialogSystem.Global:OnEvent(_ID, _Event, _PlayerID)
    if _ID == QSB.ScriptEvents.EscapePressed then
        if self.Dialog[_PlayerID] ~= nil then
            if Logic.GetTime() - self.Dialog[_PlayerID].PageStartedTime >= 6 then
                local PageID = self.Dialog[_PlayerID].CurrentPage;
                if not self.Dialog[_PlayerID][2][PageID].Options then
                    self:NextPage(_PlayerID);
                end
            end
        end
    end
end

function ModuleDialogSystem.Global:StartDialog(_Name, _PlayerID, _Data)
    self.DialogQueue[_PlayerID] = self.DialogQueue[_PlayerID] or {};
    table.insert(self.DialogQueue[_PlayerID], {_Name, _Data});
    if _Data.EnableGlobalInvulnerability then
        Logic.SetGlobalInvulnerability(1);
    end
end

function ModuleDialogSystem.Global:EndDialog(_PlayerID)
    API.FinishCinematicEvent(self.Dialog[_PlayerID].Name);
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
    return self.Dialog[_PlayerID] == nil and not API.IsCinematicEventActive(_PlayerID);
end

function ModuleDialogSystem.Global:NextDialog(_PlayerID)
    if self:CanStartDialog() then
        local Dialog = table.remove(self.DialogQueue[_PlayerID], 1);
        API.StartCinematicEvent(Dialog[1], _PlayerID);

        Dialog.Name = Dialog[1];
        Dialog.CurrentPage = 0;
        self.Dialog[_PlayerID] = Dialog;
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
    if self.DialogQueue[_PlayerID].PageQuest then
        API.StopQuest(self.DialogQueue[_PlayerID].PageQuest, true);
    end

    local PageID = self.Dialog[_PlayerID].CurrentPage;
    if PageID == -1 or PageID == 0 then
        self:EndDialog(_PlayerID);
        return;
    end
    if type(self.Dialog[_PlayerID][2][PageID]) == "table" then
        if PageID <= #self.Dialog[_PlayerID][2] then
            if self.Dialog[_PlayerID][2][PageID].Action then
                self.Dialog[_PlayerID][2][PageID]:Action();
            end
            self.DialogQueue[_PlayerID].PageQuest = self:DisplayPage(_PlayerID, PageID);
        else
            self:EndDialog(_PlayerID);
        end
    else
        local Target = self:GetPageIDByName(self.Dialog[_PlayerID][2][PageID]);
        self.Dialog[_PlayerID].CurrentPage = Target -1;
        self:NextPage(_PlayerID);
    end
end

function ModuleDialogSystem.Global:OnOptionSelected(_PlayerID, _OptionID)
    if self.Dialog[_PlayerID] == nil then
        return;
    end
    local PageID = self.Dialog[_PlayerID].CurrentPage;
    if type(self.Dialog[_PlayerID][2][PageID]) ~= "table" then
        return;
    end
    if self.Dialog[_PlayerID][2][PageID].Options then
        local Option;
        for i= 1, #self.Dialog[_PlayerID][2][PageID].Options, 1 do
            if self.Dialog[_PlayerID][2][PageID].Options[i].ID == _OptionID then
                Option = self.Dialog[_PlayerID][2][PageID].Options[i];
            end
        end
        if Option ~= nil then
            local Target = Option[2];
            if type(Option[2]) == "function" then
                Target = Option[2](Option, _PlayerID);
            end
            self.Dialog[_PlayerID][2][PageID].Options.Selected = Option.ID;
            self.Dialog[_PlayerID].CurrentPage = self:GetPageIDByName(Target) -1;
            self:NextPage(_PlayerID);
        end
    end
end

function ModuleDialogSystem.Global:DisplayPage(_PlayerID, _PageID)
    if self.Dialog[_PlayerID] == nil then
        return;
    end

    self.DialogPageCounter = self.DialogPageCounter +1;
    local Page = self.Dialog[_PlayerID][2][_PageID];
    local QuestName = "DialogSystemQuest_" .._PlayerID.. "_" ..self.DialogPageCounter;
    local QuestText = API.ConvertPlaceholders(API.Localize(Page.Text));
    local Extension = "";
    if not Page.Options and self.Dialog[_PlayerID].SkippingAllowed then
        Extension = API.ConvertPlaceholders(API.Localize(self.Text.Continue));
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

function ModuleDialogSystem.Global:GetPageIDByName(_Name)
    if type(_Name) == "string" then
        if self.Dialog[_PlayerID] ~= nil then
            for i= 1, #self.Dialog[_PlayerID][2], 1 do
                if self.Dialog[_PlayerID][2].Name == _Name then
                    return i;
                end
            end
        end
        return 0;
    end
    return _Name;
end

-- Local -------------------------------------------------------------------- --

function ModuleDialogSystem.Local:OnGameStart()
    StartSimpleHiResJobEx(function()
        for i= 1, 8 do
            if GUI.GetPlayerID() == i and ModuleDialogSystem.Local.Dialog[i] then
                if ModuleDialogSystem.Local.Dialog[i].ShowActor then
                    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message", 1);
                else
                    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message", 0);
                end
            end
        end
    end);
end

function ModuleDialogSystem.Local:StartDialog(_PlayerID, _Data)
    if GUI.GetPlayerID() == _PlayerID then
        API.DeactivateNormalInterface();
        API.DeactivateBorderScroll();
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles", 1);
        XGUIEng.ShowWidget("/InGame/Root/3dWorldView", 0);
        GUI.ClearSelection();

        -- Make camera backup
        if not self.Dialog[_PlayerID] then
            self.Dialog[_PlayerID] = {};
            self.Dialog[_PlayerID].Backup = {
                Rotation = Camera.RTS_GetRotationAngle(),
                Zoom     = Camera.RTS_GetZoomFactor(),
                Position = {Camera.RTS_GetLookAtPosition()},
                Speed    = Game.GameTimeGetFactor(_PlayerID),
            };
        end

        if _Data.HideFog then
            Display.SetRenderFogOfWar(0);
        end
        if _Data.HideBorderPins then
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
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles", 0);
        XGUIEng.ShowWidget("/InGame/Root/3dWorldView", 1);

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
            self.Dialog[_PlayerID].Backup = nil;
        end

        Display.SetRenderFogOfWar(1);
        Display.SetRenderBorderPins(1);
    end
end

function ModuleDialogSystem.Local:DisplayPage(_PlayerID, _PageData)
    if GUI.GetPlayerID() == _PlayerID then
        GUI.ClearSelection();
        self.Dialog[_PlayerID].ShowActor = _PageData.Sender ~= -1;
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
        if _PageData.Options then
            -- TODO: Display options
        end
    end
end

function ModuleDialogSystem.Local:OnOptionSelected(_PlayerID, _OptionID)
    GUI.SendScriptCommand(string.format(
        "ModuleDialogSystem.Local:OnOptionSelected(%d, %d)",
        _PlayerID,
        _OptionID
    ))
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleDialogSystem);

