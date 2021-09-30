--[[
Swift_3_BriefingSystem/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleBriefingSystem = {
    Properties = {
        Name = "ModuleBriefingSystem",
    },

    Global = {
        CAMERA_ANGLEDEFAULT = 43,
        CAMERA_ROTATIONDEFAULT = -45,
        CAMERA_ZOOMDEFAULT = 6500,
        CAMERA_FOVDEFAULT = 42,
        DLGCAMERA_ANGLEDEFAULT = 27,
        DLGCAMERA_ROTATIONDEFAULT = -45,
        DLGCAMERA_ZOOMDEFAULT = 1750,
        DLGCAMERA_FOVDEFAULT = 25,

        FinishedBriefings = {},
        CurrentBriefing = {},
        CurrentPage = {},
        BriefingQueue = {},
        BriefingID = 0,
        DisplayIngameCutscene = false,
        BriefingActive = false,
        PauseQuests = true,
        MissionStartBriefingID = 0,
    },
    Local = {
        CurrentBriefing = {},
        CurrentPage = {},
        CameraBackup = {},
        BriefingMessages = {},
        DisplayIngameCutscene = false,
        BriefingActive = false,
        ChatOptionsWasShown = false,
        MessageLogWasShown = false,
        LastSkipButtonPressed = 0,
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {},

    Text = {
        NextButton = {de = "Weiter",  en = "Forward"},
        PrevButton = {de = "Zurück",  en = "Previous"},
        EndButton  = {de = "Beenden", en = "Close"},
    },
};

-- Global ------------------------------------------------------------------- --

function ModuleBriefingSystem.Global:OnGameStart()
    QSB.ScriptEvents.BriefingStarted = API.RegisterScriptEvent("Event_BriefingStarted");
    QSB.ScriptEvents.BriefingConcluded = API.RegisterScriptEvent("Event_BriefingConcluded");

    for i= 1, 8 do
        self.BriefingQueue[i] = {};
    end

    API.StartHiResJob(function()
        ModuleBriefingSystem.Global.BriefingExecutionController()
    end);
end

function ModuleBriefingSystem.Global:StartBriefing(_Name, _PlayerID, _Briefing)
    if _Briefing.ReturnForbidden == nil then
        _Briefing.ReturnForbidden = true;
    end

    if API.IsLoadscreenVisible() or self:IsBriefingActive(_PlayerID) then
        table.insert(self.BriefingQueue[_PlayerID], {_Name, _Briefing});
        if not self.BriefingQueueJobID then
            self.BriefingQueueJobID = API.StartHiResJob(function()
                ModuleBriefingSystem.Global:BriefingQueueController();
            end);
        end
    end

    if not self:AreAllPagesLegit(_Briefing) then
        error("API.StartBriefing: Discovered illegaly added pages inside the briefing!");
        return;
    end

    API.StartCinematicEvent(_Name, _PlayerID);

    self.CurrentBriefing[_PlayerID] = table.copy(_Briefing);
    self.CurrentBriefing[_PlayerID].Name = _Name;
    self.CurrentBriefing[_PlayerID].Page = 1;
    self.CurrentBriefing[_PlayerID].PageHistory = {};
    self.CurrentBriefing[_PlayerID].BarOpacity = self.CurrentBriefing.BarOpacity or 1;

    -- Animationen übertragen
    self:TransformAnimations(_PlayerID);
    
    -- Bars Default setzen
    if self.CurrentBriefing[_PlayerID].BigBars == nil then
        self.CurrentBriefing[_PlayerID].BigBars = true;
    end
    -- Multiple Choice vorbereiten
    self:DisableMCAnswers();
    -- Globale Unverwundbarkeit
    if self.CurrentBriefing[_PlayerID].DisableGlobalVulnerability ~= false then
        Logic.SetGlobalInvulnerability(1);
    end
    -- Kopieren ins lokale Skript
    local Briefing = API.ConvertTableToString(self.CurrentBriefing[_PlayerID]);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.BriefingStarted, %s, %d);",
        Briefing,
        _PlayerID
    ))
    
    if self.CurrentBriefing[_PlayerID].Starting then
        self.CurrentBriefing[_PlayerID]:Starting();
    end
    self.CurrentPage[_PlayerID] = {};
    self:PageStarted();
end

function ModuleBriefingSystem.Global:FinishBriefing(_PlayerID)
    Logic.SetGlobalInvulnerability(0);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.BriefingConcluded, %d)",
        _PlayerID
    ));

    if self.CurrentBriefing[_PlayerID].Finished then
        self.CurrentBriefing[_PlayerID]:Finished();
    end

    API.FinishCinematicEvent(self.CurrentBriefing[_PlayerID].Name);
    self.CurrentBriefing[_PlayerID] = {};
    self.CurrentPage[_PlayerID] = {};
end

function ModuleBriefingSystem.Global:GetPageIDByName(_PageName, _PlayerID)
    if self.CurrentBriefing[_PlayerID] then
        if type(_PageName) == "number" then
            return _PageName;
        end
        for i= 1, self.CurrentBriefing[_PlayerID].Length, 1 do
            local Page = self.CurrentBriefing[_PlayerID][i];
            if Page and type(Page) == "table" and Page.Name == _PageName then
                return i;
            end
        end
    end
    return 0;
end

function ModuleBriefingSystem.Global:PageStarted(_PlayerID)
    local PageID = self.CurrentBriefing[_PlayerID].Page;
    if PageID then
        if type(self.CurrentBriefing[_PlayerID][PageID]) == "table" then
            if type(self.CurrentBriefing[_PlayerID][PageID]) == "table" then
                if self.CurrentBriefing[_PlayerID][PageID].Action then
                    self.CurrentBriefing[_PlayerID][PageID]:Action();
                end
                self.CurrentPage = self.CurrentBriefing[_PlayerID][PageID];
                self.CurrentPage.Started = Logic.GetTime();
                Logic.ExecuteInLuaLocalState(string.format(
                    "ModuleBriefingSystem.Local:PageStarted(%d)",
                    _PlayerID
                ));
            end

        elseif type(self.CurrentBriefing[_PlayerID][PageID]) == "string" then
            PageID = self:GetPageIDByName(self.CurrentBriefing[_PlayerID][PageID], _PlayerID);
            if PageID > 0 then
                self.CurrentBriefing[_PlayerID].Page = PageID;
                Logic.ExecuteInLuaLocalState(string.format(
                    "ModuleBriefingSystem.Local.CurrentBriefing[%d].Page = %d",
                    _PlayerID,
                    PageID
                ));
                self:PageStarted(_PlayerID);
            else
                self:FinishBriefing(_PlayerID);
            end

        elseif type(self.CurrentBriefing[_PlayerID][PageID]) == "number" and self.CurrentBriefing[_PlayerID][PageID] > 0 then
            self.CurrentBriefing[_PlayerID].Page = self.CurrentBriefing[_PlayerID][PageID];
            Logic.ExecuteInLuaLocalState(string.format(
                "ModuleBriefingSystem.Local.CurrentBriefing[%d].Page = %d",
                _PlayerID,
                self.CurrentBriefing[_PlayerID].Page
            ));
            self:PageStarted(_PlayerID);

        else
            self:FinishBriefing(_PlayerID);
        end
    end
end

function ModuleBriefingSystem.Global:PageFinished(_PlayerID)
    local PageID = self.CurrentBriefing[_PlayerID].Page;
    Logic.ExecuteInLuaLocalState(string.format(
        "ModuleBriefingSystem.Local:PageFinished(%d)",
        _PlayerID
    ));
    self.CurrentBriefing[_PlayerID].Page = (self.CurrentBriefing[_PlayerID].Page or 0) +1;
    local PageID = self.CurrentBriefing[_PlayerID].Page;
    if not self.CurrentBriefing[_PlayerID][PageID] or PageID > #self.CurrentBriefing[_PlayerID] then
        ModuleBriefingSystem.Global:FinishBriefing(_PlayerID);
    else
        ModuleBriefingSystem.Global:PageStarted(_PlayerID);
    end
end

function ModuleBriefingSystem.Global:IsBriefingActive(_PlayerID)
    return API.IsCinematicEventActive(_PlayerID);
end

function ModuleBriefingSystem.Global:AreAllPagesLegit(_Briefing)
    for i= 1, #_Briefing, 1 do
        if type(_Briefing[i]) == "table" then
            if not _Briefing[i].__Legit then
                return false;
            end
        end
    end
    return true;
end

function ModuleBriefingSystem.Global:TransformAnimations(_PlayerID)
    if self.CurrentBriefing[_PlayerID].PageAnimations then
        for k, v in pairs(self.CurrentBriefing[_PlayerID].PageAnimations) do
            local PageID = self:GetPageIDByName(k, _PlayerID);
            self.CurrentBriefing[_PlayerID][PageID].Animations = self.CurrentBriefing[_PlayerID][PageID].Animations or {};
            self.CurrentBriefing[_PlayerID][PageID].Animations.PurgeOld = v.PurgeOld == true;
            for i= 1, #v, 1 do               
                -- Relative Angabe
                if #v[i] == 9 then
                    table.insert(self.CurrentBriefing[_PlayerID][PageID].Animations, {
                        Duration = v[i][9] or 2 * 60,

                        Start = {
                            Position = (type(v[i][1]) ~= "table" and {v[i][1],0}) or v[i][1],
                            Rotation = v[i][2],
                            Zoom     = v[i][3],
                            Angle    = v[i][4],
                        },
                        End = {
                            Position = (type(v[i][5]) ~= "table" and {v[i][5],0}) or v[i][5],
                            Rotation = v[i][6],
                            Zoom     = v[i][7],
                            Angle    = v[i][8],
                        },
                    });
                -- Vektorisierte Angabe
                elseif #v[i] == 5 then
                    table.insert(self.CurrentBriefing[_PlayerID][PageID].Animations, {
                        Duration = v[i][5] or 2 * 60,

                        Start = {
                            Position = (type(v[i][1]) ~= "table" and {v[i][1],0}) or v[i][1],
                            LookAt   = (type(v[i][2]) ~= "table" and {v[i][1],0}) or v[i][2],
                        },
                        End = {
                            Position = (type(v[i][3]) ~= "table" and {v[i][5],0}) or v[i][3],
                            LookAt   = (type(v[i][4]) ~= "table" and {v[i][1],0}) or v[i][4],
                        },
                    });
                end
            end
        end
        self.CurrentBriefing[_PlayerID].PageAnimations = nil;
    end
end

function ModuleBriefingSystem.Global:NormalizeZPosForEntity(_Entity)
    local TargetID = GetID(_Entity);
    local TargetType = Logic.GetEntityType(TargetID);
    local Position = {_Entity, 0};
    if Logic.IsSettler(TargetID) == 1 then
        Position[2] = 120;
        if Logic.IsKnight(TargetID) then
            Position[2] = 160;
        end
    end
    if TargetType == Entities.XD_ScriptEntity then
        Position[2] = 160;
    end
    return Position;
end

function ModuleBriefingSystem.Global:NormalizeRotationForEntity(_Entity)
    local Rotation = 0;
    if IsExisting(_Entity) then
        Rotation = Logic.GetEntityOrientation(GetID(_Entity));
        if Logic.IsSettler(GetID(_Entity)) == 1 then
            Rotation = Rotation + 90;
        end
    end
    return Rotation;
end

function ModuleBriefingSystem.Global:OnMCConfirmed(_Selected, _PlayerID)
    if self.CurrentPage[_PlayerID].MC then
        local PageID = self.CurrentBriefing[_PlayerID].Page;
        self.CurrentBriefing[_PlayerID][PageID].MC.Selected = _Selected;
        local JumpData = self.CurrentPage[_PlayerID].MC[_Selected];
        if type(JumpData[2]) == "function" then
            self.CurrentBriefing[_PlayerID].Page = self:GetPageIDByName(JumpData[2](self.CurrentPage[_PlayerID], JumpData))-1;
        else
            self.CurrentBriefing[_PlayerID].Page = self:GetPageIDByName(JumpData[2])-1;
        end
        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleBriefingSystem.Local.CurrentBriefing[%d].Page = %d",
            _PlayerID,
            self.CurrentBriefing[_PlayerID].Page
        ));
        self:PageFinished(_PlayerID);
    end
end

function ModuleBriefingSystem.Global:DisableMCAnswers(_PlayerID)
    for i= 1, #self.CurrentBriefing[_PlayerID], 1 do
        if type(self.CurrentBriefing[_PlayerID][i]) == "table" and self.CurrentBriefing[_PlayerID][i].MC then
            for k, v in pairs(self.CurrentBriefing[_PlayerID][i].MC) do 
                if type(v) == "table" and type(v.Disable) == "function" then
                    local Invisible = v.Disable(self.CurrentBriefing[_PlayerID][i], v) == true;
                    self.CurrentBriefing[_PlayerID][i].MC[k].Invisible = Invisible;
                end
            end
        end
    end
end

function ModuleBriefingSystem.Global:BriefingExecutionController()
    for i= 1, 8 do
        if self:IsBriefingActive(i) then
            if self.CurrentPage[i] == nil then
                self:FinishBriefing(i);

            elseif type(self.CurrentPage[i]) == "table" then
                local Duration = (self.CurrentPage[i].Duration or 0);
                if Duration > -1 and self.CurrentPage[i].Started then
                    if Logic.GetTime() > self.CurrentPage[i].Started + Duration then
                        local PageID = self.CurrentBriefing[i].Page;
                        if not self.CurrentPage[i].NoHistory then
                            Logic.ExecuteInLuaLocalState(string.fomat(
                                "table.insert(ModuleBriefingSystem.Local.CurrentBriefing[%d].PageHistory, %d)",
                                _PlayerID,
                                PageID
                            ));
                        end
                        self:PageFinished(i);
                    end
                end
            end
        end
    end
end

function ModuleBriefingSystem.Global:BriefingQueueController()
    for i= 1, 8 do
        if #self.BriefingQueue[i] == 0 then
            self.BriefingQueueJobID = nil;
            return true;
        end
        
        if not API.IsLoadscreenVisible() and not self:IsBriefingActive(i) then        
            local Next = table.remove(self.BriefingQueue[i], 1);
            self:StartBriefing(Next[1], i, Next[2]);
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleBriefingSystem.Local:OnGameStart()
    QSB.ScriptEvents.BriefingStarted = API.RegisterScriptEvent("Event_BriefingStarted");
    QSB.ScriptEvents.BriefingConcluded = API.RegisterScriptEvent("Event_BriefingConcluded");

    if not InitializeFader then
        Script.Load("script/mainmenu/fader.lua");
    end
    self:OverrideThroneRoomFunctions();
end

function ModuleBriefingSystem.Local:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.EscapePressed then
        
    elseif _ID == QSB.ScriptEvents.BriefingStarted then
        self:StartBriefing(arg[1], arg[2]);
    elseif _ID == QSB.ScriptEvents.BriefingConcluded then
        self:FinishBriefing(arg[1]);
    end
end

function ModuleBriefingSystem.Local:StartBriefing(_Briefing, _PlayerID)
    self.CurrentBriefing[_PlayerID] = _Briefing;
    self.CurrentBriefing[_PlayerID].Page = 1;
    self.CurrentBriefing[_PlayerID].CurrentAnimation = nil;
    self.CurrentBriefing[_PlayerID].AnimationQueue = {};
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    
    if self.CurrentBriefing[_PlayerID].HideBorderPins then
        Display.SetRenderBorderPins(0);
    end
    if self.CurrentBriefing[_PlayerID].ShowSky then
        Display.SetRenderSky(1);
    end
    if not Framework.IsNetworkGame() and Game.GameTimeGetFactor() ~= 0 then
        if self.CurrentBriefing[_PlayerID].RestoreGameSpeed and not self.GameSpeedBackup then
            self.GameSpeedBackup = Game.GameTimeGetFactor();
        end
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
    end
    if self.CurrentBriefing[_PlayerID].RestoreCamera and not self.CameraBackup[_PlayerID] then
        self.CameraBackup[_PlayerID] = {Camera.RTS_GetLookAtPosition()};
    end
    if not self.CinematicActive then
        self:ActivateCinematicMode();
    end
end

function ModuleBriefingSystem.Local:FinishBriefing(_PlayerID)
    if GUI.GetPlayerID() == _PlayerID then
        if self.CurrentBriefing.CameraBackup[_PlayerID] then 
            Camera.RTS_SetLookAtPosition(unpack(self.CurrentBriefing.CameraBackup[_PlayerID]));
            self.CurrentBriefing.CameraBackup[_PlayerID] = nil;
        end
        Display.SetRenderBorderPins(1);
        Display.SetRenderSky(0);
        local GameSpeed = (self.GameSpeedBackup or 1);
        Game.GameTimeSetFactor(GUI.GetPlayerID(), GameSpeed);
        self.GameSpeedBackup = nil;
    end
    self:DeactivateCinematicMode();
    self.CurrentBriefing = {};
    self.CurrentPage = {};
end

function ModuleBriefingSystem.Local:PageStarted(_PlayerID)
    local PageID = self.CurrentBriefing[_PlayerID].Page;
    self.CurrentPage = self.CurrentBriefing[_PlayerID][PageID];
    if type(self.CurrentPage[_PlayerID]) == "table" then
        self.CurrentPage[_PlayerID].Started = Logic.GetTime();

        -- Zurück und Weiter
        local BackFlag = 1;
        local SkipFlag = 1;
        if self.CurrentBriefing[_PlayerID].SkippingAllowed ~= true or self.CurrentPage[_PlayerID].NoSkipping == true then
            if self.CurrentPage[_PlayerID].MC and not self.CurrentPage[_PlayerID].NoHistory then
                table.insert(self.CurrentBriefing[_PlayerID].PageHistory, PageID);
            end
            SkipFlag = 0;
            BackFlag = 0;
        end
        local LastPageID = self.CurrentBriefing[_PlayerID].PageHistory[#self.CurrentBriefing[_PlayerID].PageHistory];
        local LastPage = self.CurrentBriefing[_PlayerID][LastPageID];
        local NoRethinkMC = (type(LastPage) == "table" and LastPage.NoRethink and 0) or 1;
        if PageID == 1 or NoRethinkMC == 0 or self.CurrentBriefing[_PlayerID].ReturnForbidden == true then
            BackFlag = 0;
        end
        if  (self.CurrentPage[_PlayerID].Duration == nil or self.CurrentPage[_PlayerID].Duration == -1)
        and not self.CurrentPage[_PlayerID].MC then
            SkipFlag = 1;
        end

        -- Animationen
        if self.CurrentPage[_PlayerID].Animations then
            if self.CurrentPage[_PlayerID].Animations.PurgeOld then
                self.CurrentBriefing[_PlayerID].CurrentAnimation = nil;
                self.CurrentBriefing[_PlayerID].AnimationQueue = {};
            end
            for i= 1, #self.CurrentPage[_PlayerID].Animations, 1 do
                local Animation = table.copy(self.CurrentPage[_PlayerID].Animations[i]);
                table.insert(self.CurrentBriefing[_PlayerID].AnimationQueue, Animation);
            end
        end

        if GUI.GetPlayerID() ~= _PlayerID then
            return;
        end

        XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", SkipFlag);
        XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/StartButton", BackFlag);

        -- Titel setzen
        local TitleWidget = "/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight";
        XGUIEng.SetText(TitleWidget, "");
        if self.CurrentPage[_PlayerID].Title then
            local Title = self.CurrentPage[_PlayerID].Title;
            if Title:sub(1, 1) ~= "{" then
                Title = "{@color:255,250,0,255}{center}" ..Title;
            end
            XGUIEng.SetText(TitleWidget, Title);
        end

        -- Text setzen
        local TextWidget = "/InGame/ThroneRoom/Main/MissionBriefing/Text";
        XGUIEng.SetText(TextWidget, "");
        if self.CurrentPage[_PlayerID].Text then
            local Text = self.CurrentPage[_PlayerID].Text;
            if Text:sub(1, 1) ~= "{" then
                Text = "{center}" ..Text;
            end
            if not self.CurrentBriefing[_PlayerID].BigBars then
                Text = "{cr}{cr}{cr}" .. Text;
            end
            XGUIEng.SetText(TextWidget, Text);
        end

        -- Fader
        self:SetFader(_PlayerID);
        -- Portrait
        self:SetPortrait(_PlayerID);
        -- Splashscreen
        self:SetSplashscreen(_PlayerID);
        -- Multiple Choice
        self:SetOptionsDialog(_PlayerID);
    end
end

function ModuleBriefingSystem.Local:PageFinished(_PlayerID)
    -- TODO: Warum ist PageHistory hier u.U. nil?
    -- self.CurrentBriefing.PageHistory = self.CurrentBriefing.PageHistory or {};
    self.CurrentBriefing[_PlayerID].Page = (self.CurrentBriefing[_PlayerID].Page or 0) +1;
    EndJob(self.CurrentBriefing[_PlayerID].FaderJob);
end

function ModuleBriefingSystem.Local:IsBriefingActive(_PlayerID)
    return self.DisplayIngameCutscene or API.IsCinematicEventActive(_PlayerID);
end

function ModuleBriefingSystem.Local:LocalOnMCConfirmed(_PlayerID)
    local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
    if GUI.GetPlayerID() == _PlayerID then
        local Position = self.OriginalBoxPosition;
        XGUIEng.SetWidgetScreenPosition(Widget, Position[1], Position[2]);
        XGUIEng.ShowWidget(Widget, 0);
        XGUIEng.PopPage();

        if self.CurrentPage[_PlayerID].MC then
            local Selected = XGUIEng.ListBoxGetSelectedIndex(Widget .. "/ListBox")+1;
            local AnswerID = self.CurrentPage[_PlayerID].MC.Map[Selected];
            for i= #self.CurrentPage[_PlayerID].MC, 1, -1 do
                if self.CurrentPage[_PlayerID].MC[i].ID == AnswerID and self.CurrentPage[_PlayerID].MC[i].Remove then
                    GUI.SendScriptCommand(string.formt(
                        "self.CurrentPage[%d].MC[%d].Invisible = true",
                        _PlayerID,
                        i
                    ), false);
                end
            end
            GUI.SendScriptCommand("ModuleBriefingSystem.Global:OnMCConfirmed(" ..AnswerID.. ", " .._PlayerID.. ")");
        end
    end
end

function ModuleBriefingSystem.Local:SetMCAnswerState(_Page, _Answer, _Visible, _PlayerID)
   assert(type(_Page) == "number");
   assert(type(_Answer) == "number");
    if  self.CurrentBriefing[_PlayerID][_Page] and self.CurrentBriefing[_PlayerID][_Page].MC then
        for k, v in pairs(self.CurrentBriefing[_PlayerID][_Page].MC) do
            if v and v.ID == _Answer then
                self.CurrentBriefing[_PlayerID][_Page].MC[k].Invisible = _Visible == true;
            end
        end
    end
end

function ModuleBriefingSystem.Local:ThroneRoomCameraControl(_PlayerID)
    if self.DisplayIngameCutscene then
        if AddOnCutsceneSystem then
            AddOnCutsceneSystem.Local:ThroneRoomCameraControl(_PlayerID);
        end
    else
        if type(self.CurrentPage[_PlayerID]) == "table" then
            -- Animation invalidieren
            if self.CurrentBriefing[_PlayerID].CurrentAnimation then
                local CurrentTime = Logic.GetTime();
                local Animation = self.CurrentBriefing[_PlayerID].CurrentAnimation;
                if CurrentTime > Animation.Started + Animation.Duration then
                    if #self.CurrentBriefing[_PlayerID].AnimationQueue > 0 then
                        self.CurrentBriefing[_PlayerID].CurrentAnimation = nil;
                    end
                end
            end
            -- Nächste Animation
            if self.CurrentBriefing[_PlayerID].CurrentAnimation == nil then
                if self.CurrentBriefing[_PlayerID].AnimationQueue and #self.CurrentBriefing[_PlayerID].AnimationQueue > 0 then
                    local Next = table.remove(self.CurrentBriefing[_PlayerID].AnimationQueue, 1);
                    Next.Started = Logic.GetTime();
                    self.CurrentBriefing[_PlayerID].CurrentAnimation = Next;
                end
            end

            -- Kamera
            if GUI.GetPlayerID() == _PlayerID then
                local PX, PY, PZ = self:GetPagePosition();
                local LX, LY, LZ = self:GetPageLookAt();
                if PX and not LX then
                    LX, LY, LZ, PX, PY, PZ = self:GetCameraProperties();
                end
                Camera.ThroneRoom_SetPosition(PX, PY, PZ);
                Camera.ThroneRoom_SetLookAt(LX, LY, LZ);
                Camera.ThroneRoom_SetFOV(42.0);
            end

            -- Bar Style
            if GUI.GetPlayerID() == _PlayerID then
                ModuleBriefingSystem.Local:SetBarStyle(self.CurrentBriefing[_PlayerID].BarOpacity, self.CurrentBriefing[_PlayerID].BigBars);
                if self.CurrentPage[_PlayerID].BigBars ~= nil then
                    ModuleBriefingSystem.Local:SetBarStyle(self.CurrentBriefing[_PlayerID].BarOpacity, self.CurrentPage[_PlayerID].BigBars);
                end
            end

            -- Splashscreen
            self:ScrollSplashscreen(_PlayerID);

            -- Multiple Choice
            if self.CurrentBriefing[_PlayerID].MCSelectionIsShown then
                local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
                if XGUIEng.IsWidgetShown(Widget) == 0 then
                    self.CurrentBriefing[_PlayerID].MCSelectionIsShown = false;
                    self:LocalOnMCConfirmed(_PlayerID);
                end
            end

            -- Button Texte
            if GUI.GetPlayerID() == _PlayerID then
                XGUIEng.SetText("/InGame/ThroneRoom/Main/StartButton", "{center}" ..API.Localize(ModuleBriefingSystem.Text.PrevButton));
                local SkipText = API.Localize(ModuleBriefingSystem.Text.NextButton);
                local PageID = self.CurrentBriefing[_PlayerID].Page;
                if PageID == #self.CurrentBriefing[_PlayerID] or self.CurrentBriefing[_PlayerID][PageID+1] == -1 then
                    SkipText = API.Localize(ModuleBriefingSystem.Text.EndButton);
                end
                XGUIEng.SetText("/InGame/ThroneRoom/Main/Skip", "{center}" ..SkipText);
            end
        end
    end
end

function ModuleBriefingSystem.Local:GetCameraProperties(_PlayerID)
    local CurrPage, FlyTo;
    if self.CurrentBriefing[_PlayerID].CurrentAnimation then
        CurrPage = self.CurrentBriefing[_PlayerID].CurrentAnimation.Start;
        FlyTo = self.CurrentBriefing[_PlayerID].CurrentAnimation.End;
    else
        CurrPage = self.CurrentPage[_PlayerID];
        FlyTo = self.CurrentPage[_PlayerID].FlyTo;
    end

    local startPosition = CurrPage.Position;
    local endPosition = (FlyTo and FlyTo.Position) or CurrPage.Position;
    local startRotation = CurrPage.Rotation;
    local endRotation = (FlyTo and FlyTo.Rotation) or CurrPage.Rotation;
    local startZoomAngle = CurrPage.Angle;
    local endZoomAngle = (FlyTo and FlyTo.Angle) or CurrPage.Angle;
    local startZoomDistance = CurrPage.Zoom;
    local endZoomDistance = (FlyTo and FlyTo.Zoom) or CurrPage.Zoom;
    local startFOV = (CurrPage.FOV) or 42.0;
    local endFOV = ((FlyTo and FlyTo.FOV) or CurrPage.FOV) or 42.0;

    local factor = self:GetLERP(_PlayerID);
    
    local lPLX, lPLY, lPLZ = self:ConvertPosition(startPosition);
    local cPLX, cPLY, cPLZ = self:ConvertPosition(endPosition);
    local lookAtX = lPLX + (cPLX - lPLX) * factor;
    local lookAtY = lPLY + (cPLY - lPLY) * factor;
    local lookAtZ = lPLZ + (cPLZ - lPLZ) * factor;

    local zoomDistance = startZoomDistance + (endZoomDistance - startZoomDistance) * factor;
    local zoomAngle = startZoomAngle + (endZoomAngle - startZoomAngle) * factor;
    local rotation = startRotation + (endRotation - startRotation) * factor;
    local line = zoomDistance * math.cos(math.rad(zoomAngle));
    local positionX = lookAtX + math.cos(math.rad(rotation - 90)) * line;
    local positionY = lookAtY + math.sin(math.rad(rotation - 90)) * line;
    local positionZ = lookAtZ + (zoomDistance) * math.sin(math.rad(zoomAngle));

    return lookAtX, lookAtY, lookAtZ, positionX, positionY, positionZ;
end

function ModuleBriefingSystem.Local:GetPagePosition(_PlayerID)
    local Position, FlyTo;
    if self.CurrentBriefing[_PlayerID].CurrentAnimation then
        Position = self.CurrentBriefing[_PlayerID].CurrentAnimation.Start.Position;
        FlyTo = self.CurrentBriefing[_PlayerID].CurrentAnimation.End.Position;
    else
        Position = self.CurrentPage[_PlayerID].Position;
        FlyTo = self.CurrentPage[_PlayerID].FlyTo;
    end

    local x, y, z = self:ConvertPosition(Position);
    if FlyTo then
        local lX, lY, lZ = self:ConvertPosition(FlyTo.Position);
        if lX then
            x = x + (lX - x) * self:GetLERP(_PlayerID);
            y = y + (lY - y) * self:GetLERP(_PlayerID);
            z = z + (lZ - z) * self:GetLERP(_PlayerID);
        end
    end
    return x, y, z;
end

function ModuleBriefingSystem.Local:GetPageLookAt()
    local LookAt, FlyTo;
    if self.CurrentBriefing[_PlayerID].CurrentAnimation then
        LookAt = self.CurrentBriefing[_PlayerID].CurrentAnimation.Start.LookAt;
        FlyTo = self.CurrentBriefing[_PlayerID].CurrentAnimation.End.LookAt;
    else
        LookAt = self.CurrentPage[_PlayerID].LookAt;
        FlyTo = self.CurrentPage[_PlayerID].FlyTo;
    end

    local x, y, z = self:ConvertPosition(LookAt);
    if FlyTo and x then
        local lX, lY, lZ = self:ConvertPosition(FlyTo.LookAt);
        if lX then
            x = x + (lX - x) * self:GetLERP(_PlayerID);
            y = y + (lY - y) * self:GetLERP(_PlayerID);
            z = z + (lZ - z) * self:GetLERP(_PlayerID);
        end
    end
    return x, y, z;
end

function ModuleBriefingSystem.Local:ConvertPosition(_Table)
    local x, y, z;
    if _Table and _Table.X then
        x = _Table.X; y = _Table.Y; z = _Table.Z;
    elseif _Table and not _Table.X then
        x, y, z = Logic.EntityGetPos(GetID(_Table[1]));
        z = z + (_Table[2] or 0);
    end
    return x, y, z;
end

function ModuleBriefingSystem.Local:GetLERP(_PlayerID)
    local Current = Logic.GetTime();
    local Started, FlyTime;
    if self.CurrentBriefing[_PlayerID].CurrentAnimation then
        Started = self.CurrentBriefing[_PlayerID].CurrentAnimation.Started;
        FlyTime = self.CurrentBriefing[_PlayerID].CurrentAnimation.Duration;
    else
        Started = self.CurrentPage[_PlayerID].Started;
        FlyTime = self.CurrentPage[_PlayerID].Duration;
        if self.CurrentPage[_PlayerID].FlyTo then
            FlyTime = self.CurrentPage[_PlayerID].FlyTo.Duration;
        end
    end

    local Factor = 1.0;
    if FlyTime and FlyTime > 0 then
        if Started + FlyTime > Current then
            Factor = (Current - Started) / FlyTime;
            if Factor > 1 then
                Factor = 1.0;
            end
        end
    end
    return Factor;
end

function ModuleBriefingSystem.Local:ThroneRoomLeftClick(_PlayerID)
    if self.DisplayIngameCutscene then
        if AddOnCutsceneSystem then
            AddOnCutsceneSystem.Local:ThroneRoomLeftClick(_PlayerID);
        end
    else
        -- Klick auf Entity
        local EntityID = GUI.GetMouseOverEntity();
        GUI.SendScriptCommand([[
            local CurrentPage = ModuleBriefingSystem.Global.CurrentPage[]] .._PlayerID.. [[];
            if CurrentPage and CurrentPage.LeftClickOnEntity then
                ModuleBriefingSystem.Global.CurrentPage[]] .._PlayerID.. [[]:LeftClickOnEntity(]] ..tostring(EntityID).. [[)
            end
        ]]);
        -- Klick in die Spielwelt
        local x,y = GUI.Debug_GetMapPositionUnderMouse();
        GUI.SendScriptCommand([[
            local CurrentPage = ModuleBriefingSystem.Global.CurrentPage[]] .._PlayerID.. [[];
            if CurrentPage and CurrentPage.LeftClickOnPosition then
                ModuleBriefingSystem.Global.CurrentPage[]] .._PlayerID.. [[]:LeftClickOnPosition(]] ..tostring(x).. [[, ]] ..tostring(y).. [[)
            end
        ]]);
        -- Klick auf den Bildschirm
        local x,y = GUI.GetMousePosition();
        GUI.SendScriptCommand([[
            local CurrentPage = ModuleBriefingSystem.Global.CurrentPage[]] .._PlayerID.. [[];
            if CurrentPage and CurrentPage.LeftClickOnScreen then
                ModuleBriefingSystem.Global.CurrentPage[]] .._PlayerID.. [[]:LeftClickOnScreen(]] ..tostring(x).. [[, ]] ..tostring(y).. [[)
            end
        ]]);
    end
end

function ModuleBriefingSystem.Local:NextButtonPressed(_PlayerID)
    if self.DisplayIngameCutscene then
        if AddOnCutsceneSystem then
            AddOnCutsceneSystem.Local:NextButtonPressed(_PlayerID);
        end
    else
        if (self.LastSkipButtonPressed + 500) < Logic.GetTimeMs() then
            self.LastSkipButtonPressed = Logic.GetTimeMs();
            if not self.CurrentPage[_PlayerID].NoHistory then
                GUI.SendScriptCommand(string.format(
                    "table.insert(ModuleBriefingSystem.Local.CurrentBriefing[%d].PageHistory, %s)",
                    _PlayerID,
                    table.copy(self.CurrentBriefing[_PlayerID].Page)
                ), false);
            end
            if self.CurrentPage[_PlayerID].OnForward then
                GUI.SendScriptCommand(string.format(
                    "ModuleBriefingSystem.Global.CurrentPage[%d]:OnForward(%d)",
                    _PlayerID,
                    _PlayerID
                ));
            end
            GUI.SendScriptCommand(string.format("ModuleBriefingSystem.Global:PageFinished(%d)", _PlayerID));
        end
    end
end

function ModuleBriefingSystem.Local:PrevButtonPressed(_PlayerID)
    if not self.DisplayIngameCutscene then
        if (self.LastSkipButtonPressed + 500) < Logic.GetTimeMs() then
            self.LastSkipButtonPressed = Logic.GetTimeMs();

            local LastPageID = table.remove(ModuleBriefingSystem.Local.CurrentBriefing[_PlayerID].PageHistory);
            GUI.SendScriptCommand([[
                if GUI.GetPlayerID() ~= ]] .._PlayerID.. [[ then
                    table.remove(ModuleBriefingSystem.Local.CurrentBriefing[]] .._PlayerID.. [[].PageHistory);
                end
            ]], false);
            if not LastPageID then
                return;
            end
            local LastPage = ModuleBriefingSystem.Local.CurrentBriefing[_PlayerID][LastPageID];
            if type(LastPage) == "number" then
                LastPageID = table.remove(ModuleBriefingSystem.Local.CurrentBriefing[_PlayerID].PageHistory);
                GUI.SendScriptCommand([[
                    if GUI.GetPlayerID() ~= ]] .._PlayerID.. [[ then
                        table.remove(ModuleBriefingSystem.Local.CurrentBriefing[]] .._PlayerID.. [[].PageHistory);
                    end
                ]], false);
                LastPage = ModuleBriefingSystem.Local.CurrentBriefing[_PlayerID][LastPageID];
            end
            if not LastPageID or LastPageID < 1 or not LastPage then
                return;
            end

            if self.CurrentPage[_PlayerID].OnReturn then
                GUI.SendScriptCommand(string.format(
                    "ModuleBriefingSystem.Global.CurrentPage[%d]:OnReturn(%d)",
                    _PlayerID,
                    _PlayerID
                ));
            end
            ModuleBriefingSystem.Local.CurrentBriefing.Page = LastPageID -1;
            GUI.SendScriptCommand([[
                ModuleBriefingSystem.Global.CurrentBriefing[]] .._PlayerID.. [[].Page = ]] ..(LastPageID -1).. [[
                ModuleBriefingSystem.Global:PageFinished(]] .._PlayerID.. [[)
            ]]);
        end
    end
end

function ModuleBriefingSystem.Local:SetBarStyle(_Opacity, _BigBars)
    local OpacityBig = (255 * _Opacity);
    local OpacitySmall = (255 * _Opacity);
    if _BigBars then
        OpacitySmall = 0;
    end
    
    local BigVisibility = (_BigBars and 1 or 0);
    local SmallVisibility = (_BigBars and 0 or 1);
    if _Opacity == 0 then
        BigVisibility = 0;
        SmallVisibility = 0;
    end

    XGUIEng.ShowWidget("/InGame/ThroneRoomBars", BigVisibility);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", SmallVisibility);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", BigVisibility);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", SmallVisibility);

    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarBottom", 1, OpacityBig);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarTop", 1, OpacityBig);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarBottom", 1, OpacitySmall);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarTop", 1, OpacitySmall);
end

function ModuleBriefingSystem.Local:SetFader(_PlayerID)
    -- Alpha der Fader-Maske
    g_Fade.To = self.CurrentPage.FaderAlpha or 0;

    -- Fadein starten
    local PageFadeIn = self.CurrentPage.FadeIn;
    if PageFadeIn then
        if GUI.GetPlayerID() == _PlayerID then
            FadeIn(PageFadeIn);
        end
    end

    -- Fadeout starten
    local PageFadeOut = self.CurrentPage[_PlayerID].FadeOut;
    if PageFadeOut then
        self.CurrentBriefing[_PlayerID].FaderJob = StartSimpleHiResJobEx(function(_Time, _FadeOut)
            if Logic.GetTimeMs() > _Time - (_FadeOut * 1000) then
                if GUI.GetPlayerID() == _PlayerID then
                    FadeOut(_FadeOut);
                end
                return true;
            end
        end, Logic.GetTimeMs() + ((self.CurrentPage[_PlayerID].Duration or 0) * 1000), PageFadeOut);
    end
end

function ModuleBriefingSystem.Local:SetOptionsDialog(_PlayerID)
    if self.CurrentPage[_PlayerID].MC then
        local Screen = {GUI.GetScreenSize()};
        local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";

        self.OriginalBoxPosition = {
            XGUIEng.GetWidgetScreenPosition(Widget)
        };

        local Listbox = XGUIEng.GetWidgetID(Widget .. "/ListBox");
        if GUI.GetPlayerID() == _PlayerID then
            XGUIEng.ListBoxPopAll(Listbox);
        end
        self.CurrentPage[_PlayerID].MC.Map = {};
        for i=1, #self.CurrentPage[_PlayerID].MC, 1 do
            if self.CurrentPage[_PlayerID].MC[i].Invisible ~= true then
                if GUI.GetPlayerID() == _PlayerID then
                    XGUIEng.ListBoxPushItem(Listbox, self.CurrentPage[_PlayerID].MC[i][1]);
                end
                table.insert(self.CurrentPage[_PlayerID].MC.Map, self.CurrentPage[_PlayerID].MC[i].ID);
            end
        end
        
        if GUI.GetPlayerID() == _PlayerID then
            XGUIEng.ListBoxSetSelectedIndex(Listbox, 0);

            local wSize = {XGUIEng.GetWidgetScreenSize(Widget)};
            local xFactor = (Screen[1]/1920);
            local xFix = math.ceil((Screen[1] /2) - (wSize[1] /2));
            local yFix = math.ceil(Screen[2] - (wSize[2] -10));
            if self.CurrentPage[_PlayerID].Text and self.CurrentPage[_PlayerID].Text ~= "" then
                yFix = math.ceil((Screen[2] /2) - (wSize[2] /2));
            end
            XGUIEng.SetWidgetScreenPosition(Widget, xFix, yFix);
            XGUIEng.PushPage(Widget, false);
            XGUIEng.ShowWidget(Widget, 1);

            self.MCSelectionIsShown = true;
        end
    end
end

function ModuleBriefingSystem.Local:SetPortrait(_PlayerID)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    if self.CurrentPage[_PlayerID].Portrait then
        XGUIEng.SetMaterialAlpha("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 1, 255);
        XGUIEng.SetMaterialTexture("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 1, self.CurrentPage[_PlayerID].Portrait);
        XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 0, 0, 400, 600);
        XGUIEng.SetMaterialUV("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 1, 0, 0, 1, 1);
    else
        XGUIEng.SetMaterialAlpha("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 1, 0);
    end
end

function ModuleBriefingSystem.Local:SetSplashscreen(_PlayerID)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    local SSW = "/InGame/ThroneRoom/KnightInfo/BG";
    if self.CurrentPage[_PlayerID].Splashscreen then
        local size = {GUI.GetScreenSize()};
        local u0, v0, u1, v1 = 0, 0, 1, 1;
        -- Folgende Annahmen werden gemacht:
        -- * Alle Bildverhältnisse >= 1.6 sind 16:9
        -- * Alle Bildverhältnisse < 1.6 sind 4:3
        -- * 5:4 wird behandelt wie 4:3
        -- * 16:10 wird behandelt wie 4:3
        -- Spieler mit anderen Bildverhältnissen haben Pech!
        if size[1]/size[2] < 1.6 then
            u0 = 0.125;
            u1 = u1 - (u1 * 0.125);
        end
        local Image = self.CurrentPage[_PlayerID].Splashscreen;
        if type(Image) == "table" then
            Image = self.CurrentPage[_PlayerID].Splashscreen.Image;
        end
        XGUIEng.SetMaterialAlpha(SSW, 0, 255);
        XGUIEng.SetMaterialTexture(SSW, 0, Image);
        XGUIEng.SetMaterialUV(SSW, 0, u0, v0, u1, v1);
    else
        XGUIEng.SetMaterialAlpha(SSW, 0, 0);
    end
end

function ModuleBriefingSystem.Local:ScrollSplashscreen(_PlayerID)
    local SSW = "/InGame/ThroneRoom/KnightInfo/BG";
    if type(self.CurrentPage[_PlayerID].Splashscreen) == "table" then
        local SSData = self.CurrentPage[_PlayerID].Splashscreen;
        if (not SSData.Animation[1] or #SSData.Animation[1] ~= 4) or (not SSData.Animation[2] or #SSData.Animation[2] ~= 4) then
            return;
        end

        local size   = {GUI.GetScreenSize()};
        local factor = self:GetSplashscreenLERP(_PlayerID);

        local u0 = SSData.Animation[1][1] + (SSData.Animation[2][1] - SSData.Animation[1][1]) * factor;
        local u1 = SSData.Animation[1][3] + (SSData.Animation[2][3] - SSData.Animation[1][3]) * factor;
        local v0 = SSData.Animation[1][2] + (SSData.Animation[2][2] - SSData.Animation[1][2]) * factor;
        local v1 = SSData.Animation[1][4] + (SSData.Animation[2][4] - SSData.Animation[1][4]) * factor;
        -- Folgende Annahmen werden gemacht:
        -- * Alle Bildverhältnisse >= 1.6 sind 16:9
        -- * Alle Bildverhältnisse < 1.6 sind 4:3
        -- * 5:4 wird behandelt wie 4:3
        -- * 16:10 wird behandelt wie 16:9
        -- Spieler mit anderen Bildverhältnissen haben Pech!
        if size[1]/size[2] < 1.6 then
            u0 = u0 + 0.125;
            u1 = u1 - (u1 * 0.125);
        end
        if GUI.GetPlayerID() == _PlayerID then
            XGUIEng.SetMaterialUV(SSW, 0, u0, v0, u1, v1);
        end
    end
end

function ModuleBriefingSystem.Local:GetSplashscreenLERP(_PlayerID)
    local Factor = 1.0;
    if type(self.CurrentPage[_PlayerID].Splashscreen) == "table" then
        local Current = Logic.GetTime();
        local Started = self.CurrentPage[_PlayerID].Started;
        local FlyTime = self.CurrentPage[_PlayerID].Splashscreen.Animation[3];
        Factor = (Current - Started) / FlyTime;
        Factor = (Factor > 1 and 1) or Factor;
    end
    return Factor;
end

function ModuleBriefingSystem.Local:ActivateCinematicMode(_PlayerID)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.CinematicActive = true;
    
    local LoadScreenVisible = API.IsLoadscreenVisible();
    if LoadScreenVisible then
        XGUIEng.PopPage();
    end
    local ScreenX, ScreenY = GUI.GetScreenSize();

    API.DeactivateNormalInterface();
    API.DeactivateBlackScreen();

    XGUIEng.ShowWidget("/InGame/ThroneRoom", 1);
    XGUIEng.PushPage("/InGame/ThroneRoom/KnightInfo", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2", false);
    XGUIEng.PushPage("/InGame/ThroneRoom/Main", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_Dodge", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2_Dodge", false);
    XGUIEng.PushPage("/InGame/ThroneRoom/KnightInfo/LeftFrame", false);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/StartButton", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/Frame", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/DialogBG", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/FrameEdges", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogBottomRight3pcs", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/KnightInfoButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/BackButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Briefing", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/TitleContainer", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Text", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Title", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", 1);

    -- Text
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Title", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", " ");

    -- Title and back button
    local x,y = XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight");
    XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", x, 65 * (ScreenY/1080));
    local x,y = XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/Skip");
    XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/StartButton", 20, y);
    XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/Objectives", 2, 0, 2000, 20);

    -- Briefing messages
    XGUIEng.ShowAllSubWidgets("/InGame/ThroneRoom/KnightInfo", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/Text", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/BG", 1);
    XGUIEng.SetText("/InGame/ThroneRoom/KnightInfo/Text", " ");
    XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/Text", 200, 300, 1000, 10);

    -- Splashscreen
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/BG", 1);
    XGUIEng.SetMaterialColor("/InGame/ThroneRoom/KnightInfo/BG", 0, 255, 255, 255, 0);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoom/KnightInfo/BG", 0, 0);
    
    -- Portrait
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/LeftFrame", 1);
    XGUIEng.ShowAllSubWidgets("/InGame/ThroneRoom/KnightInfo/LeftFrame", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 1);
    XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 0, 0, 400, 600);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 0, 0);

    GUI.ClearSelection();
    GUI.ClearNotes();
    GUI.ForbidContextSensitiveCommandsInSelectionState();
    GUI.ActivateCutSceneState();
    GUI.SetFeedbackSoundOutputState(0);
    GUI.EnableBattleSignals(false);
    Input.CutsceneMode();
    Display.SetRenderFogOfWar(0);
    Display.SetUserOptionOcclusionEffect(0);
    Camera.SwitchCameraBehaviour(5);

    InitializeFader();
    g_Fade.To = 0;
    SetFaderAlpha(0);

    if LoadScreenVisible then
        XGUIEng.PushPage("/LoadScreen/LoadScreen", false);
    end
end

function ModuleBriefingSystem.Local:DeactivateCinematicMode(_PlayerID)
    if GUI.GetPlayerID() ~= _PlayerID then
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
    Display.SetRenderFogOfWar(1);
    if Options.GetIntValue("Display", "Occlusion", 0) > 0 then
        Display.SetUserOptionOcclusionEffect(1);
    end

    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.ShowWidget("/InGame/ThroneRoom", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", 0);

    API.ActivateNormalInterface();
    API.DeactivateBlackScreen();
end

function ModuleBriefingSystem.Local:OverrideThroneRoomFunctions()
    ThroneRoomCameraControl = function()
        if ModuleBriefingSystem then
            if ModuleBriefingSystem.Local.DisplayIngameCutscene then
                if AddOnCutsceneSystem then
                    AddOnCutsceneSystem.Local:ThroneRoomCameraControl(GUI.GetPlayerID());
                end
            else
                ModuleBriefingSystem.Local:ThroneRoomCameraControl(GUI.GetPlayerID());
            end
        end
    end

    ThroneRoomLeftClick = function()
        if ModuleBriefingSystem then
            if ModuleBriefingSystem.Local.DisplayIngameCutscene then
                if AddOnCutsceneSystem then
                    AddOnCutsceneSystem.Local:ThroneRoomLeftClick(GUI.GetPlayerID());
                end
            else
                ModuleBriefingSystem.Local:ThroneRoomLeftClick(GUI.GetPlayerID());
            end
        end
    end

    OnSkipButtonPressed = function()
        if ModuleBriefingSystem then
            if ModuleBriefingSystem.Local.DisplayIngameCutscene then
                if AddOnCutsceneSystem then
                    AddOnCutsceneSystem.Local:NextButtonPressed(GUI.GetPlayerID());
                end
            else
                ModuleBriefingSystem.Local:NextButtonPressed(GUI.GetPlayerID());
            end
        end
    end

    OnStartButtonPressed = function()
        if ModuleBriefingSystem then
            ModuleBriefingSystem.Local:PrevButtonPressed(GUI.GetPlayerID());
        end
    end

    OnBackButtonPressed = function()
        if ModuleBriefingSystem then
            ModuleBriefingSystem.Local:PrevButtonPressed(GUI.GetPlayerID());
        end
    end

    ModuleBriefingSystem.Local.GameCallback_Escape = GameCallback_Escape;
    GameCallback_Escape = function()
        if not ModuleBriefingSystem.Local:IsBriefingActive(GUI.GetPlayerID()) then
            ModuleBriefingSystem.Local.GameCallback_Escape(GUI.GetPlayerID());
        end
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleBriefingSystem);

