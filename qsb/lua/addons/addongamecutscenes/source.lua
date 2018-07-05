-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnGameCutscenes                                           # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- <p>Dieses Bundle verwaltet den Aufruf der mit dem SCA-Tool erstellten
-- Cutscenes. Ausserdem ermöglicht es das direkte Erfassen der
-- Kamerapositionen aus der Map heraus.</p>
--
-- <p><a href="#CS.StartCutscene">Cutscene starten</a></p>
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnGameCutscenes = {};

API = API or {};
CS = CS or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Startet eine Cutscene.
--
-- @param _cutscene [string] Name der Cutscene
-- @return [boolean] Cutscene gestartet
-- @within Anwenderfunktionen
--
function CS.StartCutscene(_cutscene)
    if not GUI then
        API.Bridge("CS.StartCutscene('".._cutscene.."')")
        return
    end
    if not CS.IsCutsceneActive() then
		-- make sure no Briefing starts during the cutscene
        if BriefingSystem then
            BriefingSystem.isActive = true
        end
        AddOnGameCutscenes.Local.Data.Active = true
        AddOnGameCutscenes.Local:StartCutscene(_cutscene)
        return true
    else
        if BriefingSystem then
            if BriefingSystem.IsBriefingActive() then
                return false
            end
        else
            AddOnGameCutscenes.Local:AddToWaitList(_cutscene)
        end
    end
end

---
-- Prüft, ob eine Cutscene aktiv ist.
--
-- @return [boolean] Cutscene ist aktiv
-- @within Anwenderfunktionen
--
function CS.IsCutsceneActive()
	-- local function, needs some change to be globaly used
    if not GUI then
        assert(false, "CS.IsCutsceneActive : is local function.")
        return
    end
    return AddOnGameCutscenes.Local:IsCutsceneActive()
end

---
-- Erstellen einer Cutscene, um diese mit dem SCA Tool in eine cs Datei umzuwandeln
--
-- @within Anwenderfunktionen
--
function CS.CreateCutscene_DEV_ONLY()
    if GUI then
        API.Bridge("CS.CreateCutscene_DEV_ONLY()")
        return
    end
    AddOnGameCutscenes.Global:StartCutsceneMaker()
end

---
-- Erstellen einer Echtzeit Cutscene, um diese mit dem SCA Tool in eine cs Datei umzuwandeln
--
-- @within Anwenderfunktionen
--
function CS.CreateCutsceneRealtime_DEV_ONLY()
    if GUI then
        API.Bridge("CS.CreateCutsceneRealtime_DEV_ONLY()")
        return
    end
    AddOnGameCutscenes.Global.Data.csMaker.realtime = true
    API.Bridge("AddOnGameCutscenes.Local.Data.csMakerRealtime = true")
    AddOnGameCutscenes.Global:StartCutsceneMaker()
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnGameCutscenes = {
    Global = {
        Data = {
            csMaker = {
                coord = {},
                mouse = {},
            },
        },
    },
    Local = {
        Data = {
            Language = "de",
            Active = false,
            WaitList = {},
            Positions = {},
        },
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function AddOnGameCutscenes.Global:Install()
    self.Data.csMaker.coord = {
    	xLook = 0, -- x position of the camera look at
    	yLook = 0, -- y position of the camera look at
    	zLook = 0, -- z position of the camera look at
    	xCam = 0, -- x position of the camera
    	yCam = 0, -- y position of the camera
    	zCam = 0, -- z position of the camera
    	r = 0, -- rotation of the camera
    	a = 0, -- angle of the camera
    	d = 100, -- distance of the camera
    	s = 30, -- speed of the camera
    	src = -90, --standard rotation correction
    }
    -- previous mouse position on the screen
    self.Data.csMaker.mouse = {
    	currentX = 0, -- left to right
    	currentY = 0, -- top to bottom
    	savedX = 0,
    	savedY = 0,
    	maxX = 0,
    	maxY = 0,
    }
end

---
-- Startet den CutsceneMaker
--
-- @within Internal
-- @local
--
function AddOnGameCutscenes.Global:StartCutsceneMaker()
    self.Data.csMaker.pages = {}
	self.Data.csMaker.oldDuration = 5
    self:CurrentMousePosition()
	self.Data.csMaker.mouse.savedX = self.Data.csMaker.mouse.currentX
	self.Data.csMaker.mouse.savedY = self.Data.csMaker.mouse.currentY
	self.Data.csMaker.duration = {}
    if AddOnGameCutscenes.Global.Data.csMaker.realtime then
        self.Data.csMaker.lastTime = Logic.GetTime()
    end
	self.Data.csMaker.job = StartSimpleHiResJob("AddOnGameCutscenes_Global_CutsceneMaker_MouseJob")
    API.Bridge("AddOnGameCutscenes.Local:StartCutsceneMaker()")
end

---
-- Beendet den CutsceneMaker
--
-- @within Internal
-- @local
--
function AddOnGameCutscenes.Global:EndCutsceneMaker()
    EndJob(self.Data.csMaker.job)
end

function AddOnGameCutscenes.Global:CurrentMousePosition()
    API.Bridge("AddOnGameCutscenes.Local:CurrentMousePosition()")
end

-- checks the change in the mouse position to put it on display
function AddOnGameCutscenes_Global_CutsceneMaker_MouseJob()
    AddOnGameCutscenes.Global:CurrentMousePosition()
    local savedX = AddOnGameCutscenes.Global.Data.csMaker.mouse.savedX
    local savedY = AddOnGameCutscenes.Global.Data.csMaker.mouse.savedY
    local currentX = AddOnGameCutscenes.Global.Data.csMaker.mouse.currentX
    local currentY = AddOnGameCutscenes.Global.Data.csMaker.mouse.currentY

	local deltaX = (savedX - currentX) / 2
	local deltaY = (savedY - currentY) / 2
	local updated = false

	if deltaX ~= 0 then
		updated = AddOnGameCutscenes.Global:AddDeltaRotation(deltaX)
	elseif savedX == 0 then
		updated = AddOnGameCutscenes.Global:AddDeltaRotation(2)
	elseif savedX > AddOnGameCutscenes.Global.Data.csMaker.mouse.maxX then
		updated = AddOnGameCutscenes.Global:AddDeltaRotation(-2)
	end
	if deltaY ~= 0 then
		updated = AddOnGameCutscenes.Global:AddDeltaAngle(deltaY)
	elseif savedY == 0 then
		updated = AddOnGameCutscenes.Global:AddDeltaAngle(2)
	elseif savedY > AddOnGameCutscenes.Global.Data.csMaker.mouse.maxY then
		updated = AddOnGameCutscenes.Global:AddDeltaAngle(-2)
	end

	if updated then
		AddOnGameCutscenes.Global:Refresh()
	end

	AddOnGameCutscenes.Global.Data.csMaker.mouse.savedX = currentX
	AddOnGameCutscenes.Global.Data.csMaker.mouse.savedY = currentY
end

-- transforms the mouse displacement into a rotation value
function AddOnGameCutscenes.Global:AddDeltaRotation(delta)
	self.Data.csMaker.coord.r = (self.Data.csMaker.coord.r + delta) % 360
	return true
end

-- transforms the mouse displacement into an angle value
function AddOnGameCutscenes.Global:AddDeltaAngle(delta)
	if self.Data.csMaker.coord.a == 89 and delta < 0 then
		return false
	end
	if self.Data.csMaker.coord.a == -89 and delta > 0 then
		return false
	end
	self.Data.csMaker.coord.a = self.Data.csMaker.coord.a - delta
	if self.Data.csMaker.coord.a >= 90 then
		self.Data.csMaker.coord.a = 89
	end
	if self.Data.csMaker.coord.a <= -90 then
		self.Data.csMaker.coord.a = -89
	end
	return true
end

-- sets a new position for the camera depending on an angle that represents forward/backward/left/right
function AddOnGameCutscenes.Global:SetNewCameraPosition(addedRotation)
	local addedRotation = addedRotation or 0
	local x = self.Data.csMaker.coord.xLook
	local y = self.Data.csMaker.coord.yLook
	local z = self.Data.csMaker.coord.zLook
	local rotation = self.Data.csMaker.coord.r + self.Data.csMaker.coord.src  + addedRotation
	local angle = self.Data.csMaker.coord.a
	local speed = self.Data.csMaker.coord.s
	local line = speed * math.cos(math.rad(angle))
	local x2 = x + math.cos(math.rad(rotation)) * line
	local y2 = y + math.sin(math.rad(rotation)) * line
	local z2 = speed * math.sin(math.rad(angle))

	self.Data.csMaker.coord.xLook = x2
	self.Data.csMaker.coord.yLook = y2
	if addedRotation == 0 then
		self.Data.csMaker.coord.zLook = z + z2
	elseif addedRotation == 180 then
		self.Data.csMaker.coord.zLook = z - z2
	end
end

function AddOnGameCutscenes.Global:PressedUp()
	self:SetNewCameraPosition(180)
	self:Refresh()
end

function AddOnGameCutscenes.Global:PressedDown()
	self:SetNewCameraPosition(0)
	self:Refresh()
end

function AddOnGameCutscenes.Global:PressedLeft()
	self:SetNewCameraPosition(270)
	self:Refresh()
end

function AddOnGameCutscenes.Global:PressedRight()
	self:SetNewCameraPosition(90)
	self:Refresh()
end

function AddOnGameCutscenes.Global:PressedSpace()
	self.Data.csMaker.coord.zLook = self.Data.csMaker.coord.zLook + self.Data.csMaker.coord.s
	self:Refresh()
end

function AddOnGameCutscenes.Global:PressedGoDown()
	self.Data.csMaker.coord.zLook = self.Data.csMaker.coord.zLook - self.Data.csMaker.coord.s
	self:Refresh()
end

-- sets the camera position
function AddOnGameCutscenes.Global:Refresh()
	local x = self.Data.csMaker.coord.xLook
	local y = self.Data.csMaker.coord.yLook
	local z = self.Data.csMaker.coord.zLook
	local rotation = self.Data.csMaker.coord.r + self.Data.csMaker.coord.src
	local angle = self.Data.csMaker.coord.a
	local distance = self.Data.csMaker.coord.d
	local line = distance * math.cos(math.rad(angle))
	local x2 = x + math.cos(math.rad(rotation)) * line
	local y2 = y + math.sin(math.rad(rotation)) * line
	local z2 = z + distance * math.sin(math.rad(angle))

	self.Data.csMaker.coord.xCam = x2
	self.Data.csMaker.coord.yCam = y2
	self.Data.csMaker.coord.zCam = z2

	API.Bridge('Camera.ThroneRoom_SetLookAt('..x..', '..y..', '..z..')')
	API.Bridge('Camera.ThroneRoom_SetPosition('..x2..', '..y2..', '..z2..')')
end

-- makes the movement speed bigger
function AddOnGameCutscenes.Global:PressedAdd()
	self.Data.csMaker.coord.s = self.Data.csMaker.coord.s + 10
	if self.Data.csMaker.coord.s > 100 then
		self.Data.csMaker.coord.s = 100
	end
end

-- makes the movement speed smaller
function AddOnGameCutscenes.Global:PressedSubtract()
	self.Data.csMaker.coord.s = self.Data.csMaker.coord.s - 10
	if self.Data.csMaker.coord.s < 10 then
		self.Data.csMaker.coord.s = 10
	end
end

-- add a new duration to the duration table
function AddOnGameCutscenes.Global:PressedAddDuration(_number)
	table.insert(self.Data.csMaker.duration, _number)
	local duration = self:GetDurationPassive()
	Logic.DEBUG_AddNote("Zeit der folgenden Pages : "..duration)
end

-- emtpy the values in the duration table, to be able to refill it from beginning
function AddOnGameCutscenes.Global:PressedEmptyDuration()
	self.Data.csMaker.duration = {}
	local duration = self:GetDurationPassive()
	Logic.DEBUG_AddNote("Duration Speicher geleert.")
	Logic.DEBUG_AddNote("Zeit der folgenden Pages : "..duration)
end

-- gives the current duration
function AddOnGameCutscenes.Global:GetDurationPassive()
	local length = #self.Data.csMaker.duration
	local duration
	if length == 0 then
		duration = self.Data.csMaker.oldDuration
	elseif length == 1 then
		duration = self.Data.csMaker.duration[1]
	else
		duration = self.Data.csMaker.duration[1] * 10 + self.Data.csMaker.duration[2]
	end
	return duration
end

-- gives the current duration while deleting the content of the duration table
function AddOnGameCutscenes.Global:GetDurationDestructive()
	local length = #self.Data.csMaker.duration
	local duration
	if length == 0 then
		duration = self.Data.csMaker.oldDuration
	elseif length == 1 then
		duration = self.Data.csMaker.duration[1]
	else
		duration = self.Data.csMaker.duration[1] * 10 + self.Data.csMaker.duration[2]
	end
	self.Data.csMaker.oldDuration = duration
	self.Data.csMaker.duration = {}
	return duration
end

-- This creates a new JumpTo page
function AddOnGameCutscenes.Global:PressedJump()
	local xCam = self.Data.csMaker.coord.xCam
	local yCam = self.Data.csMaker.coord.yCam
	local zCam = self.Data.csMaker.coord.zCam
	local xLook = (self.Data.csMaker.coord.xLook - self.Data.csMaker.coord.xCam) * 10 + self.Data.csMaker.coord.xCam
	local yLook = (self.Data.csMaker.coord.yLook - self.Data.csMaker.coord.yCam) * 10 + self.Data.csMaker.coord.yCam
	local zLook = (self.Data.csMaker.coord.zLook - self.Data.csMaker.coord.zCam) * 10 + self.Data.csMaker.coord.zCam
	local duration
    if AddOnGameCutscenes.Global.Data.csMaker.realtime then
        local time = Logic.GetTime()
        duration = time - self.Data.csMaker.lastTime
        self.Data.csMaker.lastTime = time
    else
        duration = self:GetDurationDestructive()
    end
	local pageData = ""..xCam..","..yCam..","..zCam..","..xLook..","..yLook..","..zLook..","..duration..",0&"
    self:SavePageToProfile(pageData)
	local newView = {
		Position    = {X = xCam, Y = yCam, Z = zCam},
		LookAt      = {X = xLook, Y = yLook, Z = zLook},
		Duration    = duration,
	}
	table.insert(self.Data.csMaker.pages, newView)
	Logic.DEBUG_AddNote("Neue JumpToPage gespeichert.")
	Logic.DEBUG_AddNote("Zeit des folgenden Pages : "..duration)
end

--This creates a new FlyTo page
function AddOnGameCutscenes.Global:PressedFly()
	local xCam = self.Data.csMaker.coord.xCam
	local yCam = self.Data.csMaker.coord.yCam
	local zCam = self.Data.csMaker.coord.zCam
	local xLook = (self.Data.csMaker.coord.xLook - self.Data.csMaker.coord.xCam) * 10 + self.Data.csMaker.coord.xCam
	local yLook = (self.Data.csMaker.coord.yLook - self.Data.csMaker.coord.yCam) * 10 + self.Data.csMaker.coord.yCam
	local zLook = (self.Data.csMaker.coord.zLook - self.Data.csMaker.coord.zCam) * 10 + self.Data.csMaker.coord.zCam
	local duration
    if AddOnGameCutscenes.Global.Data.csMaker.realtime then
        local time = Logic.GetTime()
        duration = time - self.Data.csMaker.lastTime
        self.Data.csMaker.lastTime = time
    else
        duration = self:GetDurationDestructive()
    end
	local pageData = ""..xCam..","..yCam..","..zCam..","..xLook..","..yLook..","..zLook..","..duration..",1&"
    self:SavePageToProfile(pageData)
	local newView = {
		Position    = {X = xCam, Y = yCam, Z = zCam},
		LookAt      = {X = xLook, Y = yLook, Z = zLook},
		Duration    = duration,
		FlyTime     = duration,
	}
	table.insert(self.Data.csMaker.pages, newView)
	Logic.DEBUG_AddNote("Neue FlyToPage gespeichert.")
	Logic.DEBUG_AddNote("Zeit des folgenden Pages : "..duration)
end

function AddOnGameCutscenes.Global:SavePageToProfile(_pageData)
	API.Bridge("AddOnGameCutscenes.Local:SavePageToProfile('".._pageData.."')")
end

--creates a preview of the created cutscene
function AddOnGameCutscenes.Global:PressedPreview()
	self:EndCutsceneMaker()
    API.Bridge("AddOnGameCutscenes.Local:EndCutsceneMaker()")
	local cutscene = {
        barStyle = "small",
        restoreCamera = true,
        skipAll = true,
        hideFoW = true,
        showSky = true,
        hideBorderPins = true
    };
    local AP = AddPages(cutscene)
	for i,v in ipairs(self.Data.csMaker.pages) do
		AP {
			text   = "Page "..i,
			title  = "Title",
			view   = v,
			action = function()
			end,
		}
	end
    cutscene.finished = function()
    end
    return StartCutscene(cutscene)
end


-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function AddOnGameCutscenes.Local:Install()
    self.Data.Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    local _, screenY = GUI.GetScreenSize()
    local xp, yp = XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text")
    self.Data.Positions.Text = {X = xp, Y = yp}
    local _, ys = XGUIEng.GetWidgetSize("/InGame/ThroneRoomBars_2/BarBottom")
    self.Data.Positions.TextSmall = {X = xp, Y = screenY - ys + 30}
    local xp, yp = XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight")
    self.Data.Positions.Title = {X = xp, Y = yp}
    local _, ys = XGUIEng.GetWidgetSize("/InGame/ThroneRoomBars_2/BarTop")
    self.Data.Positions.TitleSmall = {X = xp, Y = ys / 2 - 30}

    self.Data.GameCallback_Escape = GameCallback_Escape;
    GameCallback_Escape = function()
        if not self.Data.Active then
            self.Data.GameCallback_Escape();
        end
    end
end

---
-- Prüft, ob eine Cutscene oder ein Briefing activ ist.
--
-- @within Internal
-- @local
--
function AddOnGameCutscenes.Local:IsCutsceneActive()
    if BriefingSystem then
        if BriefingSystem.IsBriefingActive() then
            return true
        end
    end
    return self.Data.Active
end

---
-- Fügt eine Cutscene zur warteliste hinzu.
--
-- @param _cutscene Name der Cutscene
-- @within Internal
-- @local
--
function AddOnGameCutscenes.Local:AddToWaitList(_cutscene)
    table.insert(self.Data.WaitList, _cutscene)
end

---
-- Prüf, ob eine Cutscene in der Warteliste steht und führt diese gegebenenfalls aus.
--
-- @within Internal
-- @local
--
function AddOnGameCutscenes.Local:CheckWaitList()
    self.Data.Name = nil
    if #self.Data.WaitList > 0 then
        AddOnGameCutscenes.Local:StartCutscene(table.remove(self.Data.WaitList))
    else
        self.Data.Active = false
        AddOnGameCutscenes.Local:UndoCutsceneOptic()
        if BriefingSystem then
            BriefingSystem.isActive = false
        end
    end
end

---
-- Bereitet die Daten für die kommende Cutscene vor und startet diese dann.
--
-- @param _cutscene String, name der cutscene
-- @within Internal
-- @local
--
function AddOnGameCutscenes.Local:StartCutscene(_cutscene)
    AddOnGameCutscenes.Local:StartCutsceneOptic()
    Camera.StartCutscene(_cutscene)
end

---
-- Bereitet die UI für die Cutscene vor.
--
-- @within Internal
-- @local
--
function AddOnGameCutscenes.Local:StartCutsceneOptic()
    Display.SetRenderBorderPins(0)
    Display.SetRenderSky(1)
    Display.SetUserOptionOcclusionEffect(0)
    Display.SetRenderFogOfWar(0)
    XGUIEng.ShowWidget("/InGame/Root/Normal", 0)

    local isLoadScreenVisible = XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 1
    if isLoadScreenVisible then
        XGUIEng.PopPage()
    end

    XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoom", 1)
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", 0)
    XGUIEng.PushPage("/InGame/ThroneRoomBars", false)
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2", false)
    XGUIEng.PushPage("/InGame/ThroneRoom/Main", false)
    XGUIEng.PushPage("/InGame/ThroneRoomBars_Dodge", false)
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2_Dodge", false)
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight", 1)
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/Frame", 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/DialogBG", 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/FrameEdges", 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogBottomRight3pcs", 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/KnightInfoButton", 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Briefing", 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/BackButton", 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/TitleContainer", 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/StartButton", 0)
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text", " ")
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Title", " ")
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", " ")

    -- page.information Text
    local screen = {GUI.GetScreenSize()}
    local yAlign = 350 * (screen[2]/1080)
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo", 1)
    XGUIEng.ShowAllSubWidgets("/InGame/ThroneRoom/KnightInfo", 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/Text", 1)
    XGUIEng.PushPage("/InGame/ThroneRoom/KnightInfo", false)
    XGUIEng.SetText("/InGame/ThroneRoom/KnightInfo/Text", "")
    XGUIEng.SetTextColor("/InGame/ThroneRoom/KnightInfo/Text", 255, 255, 255, 255)
    XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/KnightInfo/Text", 100, yAlign)

    self.Data.timeFactor = Game.GameTimeGetFactor()
    Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)
    self.Data.cameraRestore = {Camera.RTS_GetLookAtPosition()}
    self.Data.selectedEntities = {GUI.GetSelectedEntities()}
    GUI.ClearSelection();
    GUI.ForbidContextSensitiveCommandsInSelectionState()
    GUI.ActivateCutSceneState()
    GUI.SetFeedbackSoundOutputState(0)
    GUI.EnableBattleSignals(false)
    Mouse.CursorHide()
    Input.CutsceneMode()

    if isLoadScreenVisible then
        XGUIEng.PushPage("/LoadScreen/LoadScreen", false);
    end
    AddOnGameCutscenes.Local:ShowText()
end

---
-- Stellt die UI für das Spiel wieder her.
--
-- @within Internal
-- @local
--
function AddOnGameCutscenes.Local:UndoCutsceneOptic()
    Display.SetRenderBorderPins(1)
    Display.SetRenderSky(0)
    if Options.GetIntValue("Display", "Occlusion", 0) > 0 then
        Display.SetUserOptionOcclusionEffect(1)
    end
    Display.SetRenderFogOfWar(1)

    XGUIEng.PopPage()
    Display.UseStandardSettings()
    Input.GameMode()
    Mouse.CursorShow()
    GUI.EnableBattleSignals(true)
    GUI.SetFeedbackSoundOutputState(1)
    GUI.ActivateSelectionState()
    GUI.PermitContextSensitiveCommandsInSelectionState()
    XGUIEng.ShowWidget("/InGame/Root/Normal", 1)

    XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", self.Data.Positions.Title.X, self.Data.Positions.Title.Y)
    XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text", self.Data.Positions.Text.X, self.Data.Positions.Text.Y)

    for _, v in ipairs(self.Data.selectedEntities) do
        if not Logic.IsEntityDestroyed(v) then
            GUI.SelectEntity(v)
        end
    end

    Camera.RTS_SetLookAtPosition(unpack(self.Data.cameraRestore))
    Game.GameTimeSetFactor(GUI.GetPlayerID(), self.Data.timeFactor)

    XGUIEng.PopPage()
    XGUIEng.PopPage()
    XGUIEng.PopPage()
    XGUIEng.PopPage()
    XGUIEng.PopPage()
    XGUIEng.ShowWidget("/InGame/ThroneRoom", 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars", 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", 0)
    XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", 1)
end

---
-- Verwaltet die Anzeige der Texte.
--
-- @param _text Text der angezeigt werden soll
-- @param _title Titel der angezeigt werden soll
-- @param _centered true wenn der Text zentriert sein soll
-- @param _show true wenn bar gezeigt werden soll
-- @param _big true wenn breiter Balken
-- @param _black true wenn Schwarz
-- @within Internal
-- @local
--
function AddOnGameCutscenes.Local:ShowText(_text, _title, _centered, _showBars, _big, _black)
    local text = _text or ""
    local title = _title or ""
    local centered = _centered or false
    local showBars = _showBars or false
    local big = _big or false
    local black = _black or false
    local alpha = not black and 100 or 255

    XGUIEng.ShowWidget("/InGame/ThroneRoomBars", (showBars and big) and 1 or 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", (showBars and big) and 1 or 0)
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarBottom", 1, alpha)
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarTop", 1, alpha)
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", (showBars and not big) and 1 or 0)
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", (showBars and not big) and 1 or 0)
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarBottom", 1, alpha)
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarTop", 1, alpha)

    if centered then
        local Height = 0;
        local Length = string.len(text)
        Height = Height + math.ceil((Length/80))
        local CarriageReturn = 0
        local s,e = string.find(text, "{cr}")
        while (e) do
            CarriageReturn = CarriageReturn + 1
            s,e = string.find(text, "{cr}", e+1)
        end
        Height = Height + math.floor((CarriageReturn/2))
        local Screen = {GUI.GetScreenSize()}
        Height = (Screen[2]/2) - (Height*10)
        XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", self.Data.Positions.Title.X, 0 + Height)
        XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text", self.Data.Positions.Text.X, 38 + Height)
    else
        local xTitle = self.Data.Positions.Title.X
        local xText = self.Data.Positions.Text.X
        if big then
            local yTitle = self.Data.Positions.Title.Y
            local yText = self.Data.Positions.Text.Y
            XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", xTitle, yTitle)
            XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text", xText, yText)
        else
            local yTitle = self.Data.Positions.TitleSmall.Y
            local yText = self.Data.Positions.TextSmall.Y
            XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", xTitle, yTitle)
            XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text", xText, yText)
        end
    end
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Text", 1)
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", 1)
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text", "{center}"..text)
    XGUIEng.SetText("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", "{center}{darkshadow}{@color:244,184,0,255}"..title)
end

---
-- Startet den Cutscene Maker
--
-- @within Internal
-- @local
--
function AddOnGameCutscenes.Local:StartCutsceneMaker()
    Profile.SetString("CutsceneAssistent", "pages", "")

    local x, y = Camera.RTS_GetLookAtPosition()
    local z = Display.GetTerrainHeight(x, y) + 1000
    API.Bridge("AddOnGameCutscenes.Global.Data.csMaker.coord.xLook = "..x)
    API.Bridge("AddOnGameCutscenes.Global.Data.csMaker.coord.yLook = "..y)
    API.Bridge("AddOnGameCutscenes.Global.Data.csMaker.coord.zLook = "..z)

    Display.SetUserOptionOcclusionEffect(0)
    Display.SetRenderSky(1)
    Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)
    Camera.SwitchCameraBehaviour(5)
    Display.SetRenderFogOfWar(0)
    GUI.MiniMap_SetRenderFogOfWar(0)
    GUI.ActivateCutSceneState()

    local width, height = GUI.GetScreenSize()
    API.Bridge("AddOnGameCutscenes.Global.Data.csMaker.mouse.maxX = "..width.." - 5")
    API.Bridge("AddOnGameCutscenes.Global.Data.csMaker.mouse.maxY = "..height.." - 5")

    Input.KeyBindDown( Keys.Up,       'API.Bridge("AddOnGameCutscenes.Global:PressedUp()")',       2, true)
    Input.KeyBindDown( Keys.Down,     'API.Bridge("AddOnGameCutscenes.Global:PressedDown()")',     2, true)
    Input.KeyBindDown( Keys.Left,     'API.Bridge("AddOnGameCutscenes.Global:PressedLeft()")',     2, true)
    Input.KeyBindDown( Keys.Right,    'API.Bridge("AddOnGameCutscenes.Global:PressedRight()")',    2, true)
    Input.KeyBindDown( Keys.W,        'API.Bridge("AddOnGameCutscenes.Global:PressedUp()")',       2, true)
    Input.KeyBindDown( Keys.S,        'API.Bridge("AddOnGameCutscenes.Global:PressedDown()")',     2, true)
    Input.KeyBindDown( Keys.A,        'API.Bridge("AddOnGameCutscenes.Global:PressedLeft()")',     2, true)
    Input.KeyBindDown( Keys.D,        'API.Bridge("AddOnGameCutscenes.Global:PressedRight()")',    2, true)
    Input.KeyBindDown( Keys.Add,      'API.Bridge("AddOnGameCutscenes.Global:PressedAdd()")',      2, true)
    Input.KeyBindDown( Keys.Subtract, 'API.Bridge("AddOnGameCutscenes.Global:PressedSubtract()")', 2, true)
    Input.KeyBindDown( Keys.Space,    'API.Bridge("AddOnGameCutscenes.Global:PressedSpace()")',    2, true)
    Input.KeyBindDown( Keys.Y,        'API.Bridge("AddOnGameCutscenes.Global:PressedGoDown()")',   2, true)
    Input.KeyBindDown( Keys.J,        'API.Bridge("AddOnGameCutscenes.Global:PressedJump()")',     2, true)
    Input.KeyBindDown( Keys.F,        'API.Bridge("AddOnGameCutscenes.Global:PressedFly()")',      2, true)
    Input.KeyBindDown( Keys.P,        'API.Bridge("AddOnGameCutscenes.Global:PressedPreview()")',  2, true)

    if not AddOnGameCutscenes.Local.Data.csMakerRealtime then
        Input.KeyBindDown( Keys.Back,    'API.Bridge("AddOnGameCutscenes.Global:PressedEmptyDuration()")', 2, true)
        Input.KeyBindDown( Keys.NumPad0, 'API.Bridge("AddOnGameCutscenes.Global:PressedAddDuration(0)")',  2, true)
        Input.KeyBindDown( Keys.NumPad1, 'API.Bridge("AddOnGameCutscenes.Global:PressedAddDuration(1)")',  2, true)
        Input.KeyBindDown( Keys.NumPad2, 'API.Bridge("AddOnGameCutscenes.Global:PressedAddDuration(2)")',  2, true)
        Input.KeyBindDown( Keys.NumPad3, 'API.Bridge("AddOnGameCutscenes.Global:PressedAddDuration(3)")',  2, true)
        Input.KeyBindDown( Keys.NumPad4, 'API.Bridge("AddOnGameCutscenes.Global:PressedAddDuration(4)")',  2, true)
        Input.KeyBindDown( Keys.NumPad5, 'API.Bridge("AddOnGameCutscenes.Global:PressedAddDuration(5)")',  2, true)
        Input.KeyBindDown( Keys.NumPad6, 'API.Bridge("AddOnGameCutscenes.Global:PressedAddDuration(6)")',  2, true)
        Input.KeyBindDown( Keys.NumPad7, 'API.Bridge("AddOnGameCutscenes.Global:PressedAddDuration(7)")',  2, true)
        Input.KeyBindDown( Keys.NumPad8, 'API.Bridge("AddOnGameCutscenes.Global:PressedAddDuration(8)")',  2, true)
        Input.KeyBindDown( Keys.NumPad9, 'API.Bridge("AddOnGameCutscenes.Global:PressedAddDuration(9)")',  2, true)
    end

    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/MapFrame/Minimap/MinimapOverlay", 0)
end

---
-- Beendet den CutsceneMaker
--
-- @within Internal
-- @local
--
function AddOnGameCutscenes.Local:EndCutsceneMaker()
    Display.SetRenderSky(0)
    Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)
    Camera.SwitchCameraBehaviour(0)
    Display.SetRenderFogOfWar(1)
    GUI.MiniMap_SetRenderFogOfWar(1)

    XGUIEng.ShowWidget("/InGame/Root/Normal", 1)

    Input.KeyBindDown( Keys.Up , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.Down , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.Left , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.Right , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.W , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.S , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.A , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.D , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.Add , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.Subtract , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.Space , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.Y , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.J , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.F , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.P , 'KeyBindings_EnableDebugMode(0)', 2)

    Input.KeyBindDown( Keys.Back , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.NumPad0 , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.NumPad1 , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.NumPad2 , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.NumPad3 , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.NumPad4 , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.NumPad5 , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.NumPad6 , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.NumPad7 , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.NumPad8 , 'KeyBindings_EnableDebugMode(0)', 2)
    Input.KeyBindDown( Keys.NumPad9 , 'KeyBindings_EnableDebugMode(0)', 2)

    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/MapFrame/Minimap/MinimapOverlay", 1)
end

function AddOnGameCutscenes.Local:CurrentMousePosition()
    local x, y = GUI.GetMousePosition()
    API.Bridge("AddOnGameCutscenes.Global.Data.csMaker.mouse.currentX = "..x)
    API.Bridge("AddOnGameCutscenes.Global.Data.csMaker.mouse.currentY = "..y)
end

function AddOnGameCutscenes.Local:SavePageToProfile(_pageData)
    local previous = Profile.GetString("CutsceneAssistent", "pages")
	Profile.SetString("CutsceneAssistent", "pages", ""..previous.."".._pageData.."")
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("AddOnGameCutscenes");
