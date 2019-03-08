-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleBriefingSystem                                         # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
--
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleBriefingSystem = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --



-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleBriefingSystem = {
    Global = {
        Data = {
            FinishedBriefings = {},
            CurrentBriefing = {},
            CurrentPage = {},
            BriefingQueue = {},
            BriefingID = 0,
            BriefingActive = false,
        }
    },
    Local = {
        Data = {
            Defaults = {

            },
            CurrentBriefing = {},
            CurrentPage = {},
            DisplayIngameCutscene = false,
        }
    },
    Text = {

    }
}

-- Global Script ------------------------------------------------------------ --

---
--
--
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:Install()
    StartSimpleHiResJobEx(BundleBriefingSystem.Global.BriefingExecutionController);
end

---
-- 
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:StartBriefing(_Briefing)
    if not self.Data.LoadScreenHidden or self:IsBriefingActive() then
        table.insert(self.Data.BriefingQueue, _Briefing);
        if not self.Data.BriefingQueueJobID then
            self.Data.BriefingQueueJobID = StartSimpleHiResJobEx(self.BriefingQueueController);
        end
        return;
    end

    self.Data.BriefingID = self.Data.BriefingID +1;
    self.Data.CurrentBriefing = _Briefing;
    self.Data.CurrentBriefing.Page = 1;
    self.Data.CurrentBriefing.ID = self.Data.BriefingID;
    if self.Data.CurrentBriefing.DisableGlobalInvulnerability ~= false then
        Logic.SetGlobalInvulnerability(1);
    end
    local Briefing = API.ConvertTableToString(self.Data.CurrentBriefing);
    API.Bridge("BundleBriefingSystem.Local:StartBriefing(" ..Briefing.. ")");
    
    self.Data.BriefingActive = true;
    if self.Data.CurrentBriefing.Started then
        self.Data.CurrentBriefing:Started();
    end
    self:PageStarted();
    return self.Data.BriefingID;
end

---
-- 
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:FinishBriefing()
    self.Data.CurrentBriefing = {};
    self.Data.CurrentPage = {};
    self.Data.BriefingActive = false;

    Logic.SetGlobalInvulnerability(0);
    API.Bridge("BundleBriefingSystem.Local:FinishBriefing()");

    if self.Data.CurrentBriefing.Finished then
        self.Data.CurrentBriefing:Finished();
    end
end

---
-- 
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:PageStarted()
    local PageID = self.Data.CurrentBriefing.Page;
    if PageID then
        if self.Data.CurrentBriefing[PageID].Action then
            self.Data.CurrentBriefing[PageID]:Action();
        end
        self.Data.CurrentPage = self.Data.CurrentBriefing[PageID];
        self.Data.CurrentPage.Started  = Logic.GetTime();
    end
    API.Bridge("BundleBriefingSystem.Local:PageStarted()");
end

---
-- 
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:PageFinished()
    self.Data.CurrentBriefing.Page = (self.Data.CurrentBriefing.Page or 0) +1;
    API.Bridge("BundleBriefingSystem.Local:PageFinished()");
end

---
-- Prüft, ob ein Briefing aktiv ist.
-- @param[type=boolean] Briefing ist aktiv
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:IsBriefingActive()
    return self.Data.BriefingActive == true;
end

---
-- 
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global.BriefingExecutionController()
    if BundleBriefingSystem.Global:IsBriefingActive() then
        if type(BundleBriefingSystem.Global.Data.CurrentPage) == "number" then
            local PageID = BundleBriefingSystem.Global.Data.CurrentPage;
            BundleBriefingSystem.Global.Data.CurrentBriefing.Page = PageID;
            API.Bridge("BundleBriefingSystem.Global.Data.CurrentBriefing.Page = " ..PageID);
            BundleBriefingSystem.Global:PageStarted();

        elseif BundleBriefingSystem.Global.Data.CurrentPage == nil then
            BundleBriefingSystem.Global:FinishBriefing();

        else
            local PageID = BundleBriefingSystem.Global.Data.CurrentBriefing.Page;
            if PageID then
                local Duration = (BundleBriefingSystem.Global.Data.CurrentBriefing[PageID].Duration or 0);
                if Duration > -1 then
                    if Logic.GetTime() > BundleBriefingSystem.Global.Data.CurrentBriefing[PageID].Started + Duration then
                        BundleBriefingSystem.Global:PageFinished();
                    end
                end
            end
        end
    end
end

---
-- 
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global.BriefingQueueController()
    if #BundleBriefingSystem.Global.Data.BriefingQueue == 0 then
        BundleBriefingSystem.Global.Data.BriefingQueueJobID = nil;
        return true;
    end
    
    if BundleBriefingSystem.Global.Data.LoadScreenHidden and not BundleBriefingSystem.Global:IsBriefingActive() then
        local Next = table.remove(BundleBriefingSystem.Global.Data.BriefingQueue, 1);
        BundleBriefingSystem.Global:StartBriefing(Next);
    end
end

-- Local Script ------------------------------------------------------------- --

---
--
--
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:Install()
    if not InitializeFader then
        Script.Load("script/mainmenu/fader.lua");
    end
    self:OverrideThroneRoomFunctions();

    StartSimpleHiResJobEx(self.WaitForLoadScreenHidden);
end

---
-- 
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:StartBriefing(_Briefing)
    self.Data.SelectedEntities = {GUI.GetSelectedEntities()};

    self.Data.CurrentBriefing.Page = 1;
    self.Data.CurrentBriefing = _Briefing;
    
    if self.Data.CurrentBriefing.HideBorderPins then
        Display.SetRenderBorderPins(0);
    end
    if self.Data.CurrentBriefing.ShowSky then
        Display.SetRenderSky(1);
    end

    if Game.GameTimeGetFactor() ~= 0 then
        if self.Data.CurrentBriefing.RestoreGameSpeed and not self.Data.GaneSpeedBackup then
            self.Data.GaneSpeedBackup = Game.GameTimeGetFactor();
        end
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
    end

    if not self.Data.CinematicActive then
        self:ActivateCinematicMode();
    end
    self.Data.BriefingActive = true;
end

---
-- 
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:FinishBriefing()
    if self.Data.CurrentBriefing.CameraLookAt then 
        Camera.RTS_SetLookAtPosition(unpack(self.Data.CurrentBriefing.CameraLookAt));
        self.Data.CurrentBriefing.CameraLookAt = nil;
    end

    for k, v in pairs(self.Data.SelectedEntities) do
        GUI.SelectEntity(v);
    end

    Display.SetRenderBorderPins(1);
    Display.SetRenderSky(0);

    local GameSpeed = (self.Data.GaneSpeedBackup or 1);
    Game.GameTimeSetFactor(GUI.GetPlayerID(), GameSpeed);
    self.Data.GaneSpeedBackup = nil;

    self:DeactivateCinematicMode();
    self.Data.BriefingActive = false;
end

---
-- 
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:PageStarted()
    local PageID = self.Data.CurrentBriefing.Page;
    if type(self.Data.CurrentBriefing[PageID]) == "table" then
        self.Data.CurrentPage = self.Data.CurrentBriefing[PageID];

        local TitleWidget = "/InGame/ThroneRoom/Main/MissionBriefing/Title";
        XGUIEng.SetText(TitleWidget, "");
        if self.Data.CurrentPage.Title then
            XGUIEng.SetText(TitleWidget, self.Data.CurrentPage.Title);
        end

        local TextWidget = "/InGame/ThroneRoom/Main/MissionBriefing/Text";
        XGUIEng.SetText(TextWidget, "");
        if self.Data.CurrentPage.Text then
            XGUIEng.SetText(TextWidget, self.Data.CurrentPage.Text);
        end
    end
end

---
-- 
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:PageFinished()
    self.Data.CurrentBriefing.Page = (self.Data.CurrentBriefing.Page or 0) +1;
end

---
-- Prüft, ob ein Briefing aktiv ist.
-- @param[type=boolean] Briefing ist aktiv
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:IsBriefingActive()
    return self.Data.BriefingActive == true;
end

---
-- Steuert die Kamera während des Throneroom Mode.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:ThroneRoomCameraControl()
    if self.Data.DisplayIngameCutscene then
        if AddOnCutsceneSystem then
            AddOnCutsceneSystem.Local:ThroneRoomCameraControl();
        end
    else
        if type(self.Data.CurrentPage) == "table" then
            local PX, PY, PZ = self:GetPagePosition(PageID);
            Camera.ThroneRoom_SetPosition(PX, PY, PZ);

            local LX, LY, LZ = self:GetPageLookAt(PageID);
            Camera.ThroneRoom_SetLookAt(LX, LY, LZ);

            local FOV = self:GetFOV(PageID);
            Camera.ThroneRoom_SetFOV(FOV);
        end
    end
end

---
-- 
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:GetPagePosition(_PageID)
    local Position = self.Data.CurrentPage.Position;
    if (type(Position) == "table") then
        return unpack(Position);
    end
    return 100.0, 100.0, 100.0;
end

---
-- 
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:GetPageLookAt(_PageID)
    local LookAt = self.Data.CurrentPage.LookAt;
    if (type(LookAt) == "table") then
        return unpack(LookAt);
    end
    return 1000.0, 1000.0, 1000.0;
end

---
-- 
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:GetPageFOV(_PageID)

    return 42.0;
end

---
-- 
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:ThroneRoomLeftClick()
    if self.Data.DisplayIngameCutscene then
        if AddOnCutsceneSystem then
            AddOnCutsceneSystem.Local:ThroneRoomLeftClick();
        end
    else

    end
end

---
-- Reagiert auf Klick auf den Skip-Button während des Throneroom Mode.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:SkipButtonPressed()
    if self.Data.DisplayIngameCutscene then
        if AddOnCutsceneSystem then
            AddOnCutsceneSystem.Local:SkipButtonPressed();
        end
    else

    end
end

---
-- Aktiviert den Cinematic Mode.
--
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:ActivateCinematicMode()
    self.Data.CinematicActive = true;
    
    local LoadScreenVisible = XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 1;
    if LoadScreenVisible then
        XGUIEng.PopPage();
    end

    XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom", 1);
    XGUIEng.PushPage("/InGame/ThroneRoomBars", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2", false);
    XGUIEng.PushPage("/InGame/ThroneRoom/Main", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_Dodge", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2_Dodge", false);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/Frame", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/DialogBG", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/FrameEdges", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogBottomRight3pcs", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/KnightInfoButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Briefing", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/BackButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/TitleContainer", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/StartButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Text", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Title", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", 1);

    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Title", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", " ");
    XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/Objectives", 2, 0, 2000, 20);
    XGUIEng.PushPage("/InGame/ThroneRoom/KnightInfo", false);
    XGUIEng.ShowAllSubWidgets("/InGame/ThroneRoom/KnightInfo", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/Text", 1);
    XGUIEng.SetText("/InGame/ThroneRoom/KnightInfo/Text", " ");
    XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/Text", 200, 300, 1000, 10);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/LeftFrame", 1);
    XGUIEng.ShowAllSubWidgets("/InGame/ThroneRoom/KnightInfo/LeftFrame", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/KnightBG", 1);
    XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/KnightBG", 0, 6000, 400, 600);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoom/KnightInfo/KnightBG", 0, 0);

    GUI.ClearSelection();
    GUI.ForbidContextSensitiveCommandsInSelectionState();
    GUI.ActivateCutSceneState();
    GUI.SetFeedbackSoundOutputState(0);
    GUI.EnableBattleSignals(false);
    Input.CutsceneMode();
    Display.SetRenderFogOfWar(0);
    Display.SetUserOptionOcclusionEffect(0);
    Camera.SwitchCameraBehaviour(0);

    InitializeFader();
    g_Fade.To = 0;
    SetFaderAlpha(0);

    if LoadScreenVisible then
        XGUIEng.PushPage("/LoadScreen/LoadScreen", false);
    end
end

---
-- Deaktiviert den Cinematic Mode.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:DeactivateCinematicMode()
    self.Data.CinematicActive = false;

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
        Display.SetUserOptionOcclusionEffect(1)
    end

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
    XGUIEng.ShowWidget("/InGame/Root/Normal", 1);
    XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", 1);
end

---
-- Überschreibt die Throneroom-Funktionen.
--
-- Überschriebene Funktionen:
-- <ul>
-- <li>ThroneRoomCameraControl - Steuerung der Throneroom-Kamera</li>
-- <li>ThroneRoomLeftClick - Es wird mit der Maus irgend wo hin geklickt</li>
-- <li>OnSkipButtonPressed - Überspringen wird geklickt</li>
-- </ul>
--
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:OverrideThroneRoomFunctions()
    ThroneRoomCameraControl = function()
        if BundleBriefingSystem then
            if BundleBriefingSystem.Local.Data.DisplayIngameCutscene then
                if AddOnCutsceneSystem then
                    AddOnCutsceneSystem.Local:ThroneRoomCameraControl();
                end
            else
                BundleBriefingSystem.Local:ThroneRoomCameraControl();
            end
        end
    end

    ThroneRoomLeftClick = function()
        if BundleBriefingSystem then
            if BundleBriefingSystem.Local.Data.DisplayIngameCutscene then
                if AddOnCutsceneSystem then
                    AddOnCutsceneSystem.Local:ThroneRoomLeftClick();
                end
            else
                BundleBriefingSystem.Local:ThroneRoomLeftClick();
            end
        end
    end

    OnSkipButtonPressed = function()
        if BundleBriefingSystem then
            if BundleBriefingSystem.Local.Data.DisplayIngameCutscene then
                if AddOnCutsceneSystem then
                    AddOnCutsceneSystem.Local:SkipButtonPressed();
                end
            else
                BundleBriefingSystem.Local:SkipButtonPressed();
            end
        end
    end
end

---
-- 
--
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local.WaitForLoadScreenHidden()
    if XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 0 then
        GUI.SendScriptCommand("BundleBriefingSystem.Global.Data.LoadScreenHidden = true");
        return true;
    end
end

-- Behavior ----------------------------------------------------------------- --



-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleBriefingSystem");