-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleBriefingSystem                                         # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es Briefing zu verwenden.
--
-- Briefings dienen zur Darstellung von Dialogen oder zur näheren Erleuterung
-- der aktuellen Spielsituation. Mit Multiple Choice können dem Spieler mehrere
-- Auswahlmöglichkeiten gegeben werden, multiple Handlungsstränge gestartet
-- oder Menüstrukturen abgebildet werden. Mittels Sprüngen und Leerseiten
-- kann innerhalb des Multiple Choice Briefings navigiert werden.
--
-- <p>Das wichtigste auf einen Blick:
-- <ul>
-- <li><a href="#API.StartBriefing">Ein Briefing starten</a></li>
-- <li>
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

---
-- Startet ein Briefing.
--
-- <b>Alias</b>: StartBriefing
--
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=number] ID des Briefing
-- @within Anwenderfunktionen
--
function API.StartBriefing(_Briefing)
    if GUI then
        warn("API.StartBriefing: Cannot start briefing from local script!");
        return -1;
    end
    return BundleBriefingSystem.Global:StartBriefing(_Briefing);
end
StartBriefing = API.StartBriefing;

---
-- Prüft, ob ein Briefing abgeschlossen wurde.
--
-- <b>Alias</b>: IsBriefingFinished
--
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=boolean] Briefing ist beendet
-- @within Anwenderfunktionen
--
function API.IsBriefingFinished(_BriefingID)
    if GUI then
        warn("API.IsBriefingFinished: Cannot check briefing state from local script!");
        return false;
    end
    return BundleBriefingSystem.Global.Data.FinishedBriefings[_BriefingID] == true;
end
IsBriefingFinished = API.IsBriefingFinished;

---
-- Prüft, ob ein Briefing abgeschlossen wurde.
--
-- <b>Alias</b>: IsBriefingActive
--
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=boolean] Briefing ist beendet
-- @within Anwenderfunktionen
--
function API.IsBriefingActive(_BriefingID)
    if GUI then
        return BundleBriefingSystem.Local.Data.BriefingActive == true;
    end
    return BundleBriefingSystem.Global.Data.BriefingActive == true;
end
IsBriefingActive = API.IsBriefingActive;

---
-- Fügt einem Briefing eine Seite hinzu. Diese Funktion muss gestartet werden,
-- bevor das Briefing gestartet wird.
--
-- <b>Alias</b>: AddPages
--
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=function] AP-Funktion zum Seiten hinzufügen
-- @within Anwenderfunktionen
--
function API.AddPages(_Briefing)
    if GUI then
        fatal("API.AddPages: Cannot be used from local script!");
        return;
    end

    local AP = function(_Page)
        if type(_Page) == "table" then
            -- Sprache anpassen
            local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
            if type(_Page.Title) == "table" then
                _Page.Title = _Page.Title[Language];
            end
            if type(_Page.Text) == "table" then
                _Page.Text = _Page.Text[Language];
            end
            -- Lookat mappen
            if type(_Page.LookAt) == "string" or type(_Page.LookAt) == "number" then
                _Page.LookAt = {_Page.LookAt, 0}
            end
            -- Position mappen
            if type(_Page.Position) == "string" or type(_Page.Position) == "number" then
                _Page.Position = {_Page.Position, 0}
            end
            -- Dialogkamera
            if _Page.DialogCamera == true then
                _Page.Angle = _Page.Angle or BundleBriefingSystem.Global.Data.DLGCAMERA_ANGLEDEFAULT;
                _Page.Zoom = _Page.Zoom or BundleBriefingSystem.Global.Data.DLGCAMERA_ZOOMDEFAULT;
                _Page.FOV = _Page.FOV or BundleBriefingSystem.Global.Data.DLGCAMERA_FOVDEFAULT;
                _Page.Rotation = _Page.Rotation or BundleBriefingSystem.Global.Data.DLGCAMERA_ROTATIONDEFAULT;
            end
            if _Page.DialogCamera == false then
                _Page.Angle = _Page.Angle or BundleBriefingSystem.Global.Data.CAMERA_ANGLEDEFAULT;
                _Page.Zoom = _Page.Zoom or BundleBriefingSystem.Global.Data.CAMERA_ZOOMDEFAULT;
                _Page.FOV = _Page.FOV or BundleBriefingSystem.Global.Data.CAMERA_FOVDEFAULT;
                _Page.Rotation = _Page.Rotation or BundleBriefingSystem.Global.Data.CAMERA_ROTATIONDEFAULT;
            end
            -- FlyTo Animation für MC entfernen
            if _Page.FlyTo and _Page.MC then
                _Page.FlyTo = nil;
            end
            -- Anzeigezeit setzen
            if not _Page.Duration then
                if _Page.FlyTo then
                    _Page.Duration = _Page.FlyTo.Duration;
                else
                    _Briefing.DisableSkipping = false;
                    _Briefing.SkipPerPage = true;
                    _Page.Duration = -1;
                end
            end

            table.insert(_Briefing, _Page);
        else
            table.insert(_briefing, (_Page ~= nil and _Page) or -1);
        end
        return _Page;
    end

    local ASP = function(_Entity, _Title, _Text, _DialogCamera, _Action)
        return AP {
            Title        = _Title,
            Text         = _Title,
            Position     = _Entity,
            DialogCamera = _DialogCamera == true,
            Action       = _Action
        }
    end
    return AP, ASP;
end
AddPages = API.AddPages;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleBriefingSystem = {
    Global = {
        Data = {
            CAMERA_ANGLEDEFAULT = 43,
            CAMERA_ROTATIONDEFAULT = -45,
            CAMERA_ZOOMDEFAULT = 6250,
            CAMERA_FOVDEFAULT = 42,
            DLGCAMERA_ANGLEDEFAULT = 29,
            DLGCAMERA_ROTATIONDEFAULT = -45,
            DLGCAMERA_ZOOMDEFAULT = 3400,
            DLGCAMERA_FOVDEFAULT = 25,

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
            CurrentBriefing = {},
            CurrentPage = {},
            DisplayIngameCutscene = false,
            BriefingActive = false,
            LastSkipButtonPressed = 0,
        }
    },
    Text = {

    }
}

-- Global Script ------------------------------------------------------------ --

---
-- Startet das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:Install()
    StartSimpleHiResJobEx(self.BriefingExecutionController);
end

---
-- Konvertiert eine Briefing-Table des alten Formats in das neue. Diese
-- Funktion ist auf Zeit im Skript und wird später wieder entfernt.
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=number] ID des Briefing
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:ConvertBriefingTable(_Briefing)
    _Briefing.DisableGlobalInvulnerability = _Briefing.disableGlobalInvulnerability or _Briefing.DisableGlobalInvulnerability;
    _Briefing.HideBorderPins = _Briefing.hideBorderPins or _Briefing.HideBorderPins;
    _Briefing.ShowSky = _Briefing.showSky or _Briefing.ShowSky;
    _Briefing.RestoreGameSpeed = _Briefing.restoreGameSpeed or _Briefing.RestoreGameSpeed;
    _Briefing.RestoreCamera = _Briefing.restoreCamera or _Briefing.RestoreCamera;
    _Briefing.Finished = _Briefing.finished or _Briefing.Finished;
    _Briefing.Starting = _Briefing.starting or _Briefing.Starting;
    
    for k, v in pairs(_Briefing) do
        if type(v) == "table" then
            -- Normale Optionen
            _Briefing[k].Title = v.title or _Briefing[k].Title;
            _Briefing[k].Text = v.text or _Briefing[k].Text;
            _Briefing[k].Position = v.position or _Briefing[k].Position;
            _Briefing[k].Angle = v.angle or _Briefing[k].Angle;
            _Briefing[k].Rotation = v.rotation or _Briefing[k].Rotation;
            _Briefing[k].Zoom = v.zoom or _Briefing[k].Zoom;
            _Briefing[k].Action = v.action or _Briefing[k].Action;
            _Briefing[k].FadeIn = v.fadeIn or _Briefing[k].FadeIn;
            _Briefing[k].FadeOut = v.fadeOut or _Briefing[k].FadeOut;
            _Briefing[k].FaderAlpha = v.faderAlpha or _Briefing[k].FaderAlpha;
            _Briefing[k].DialogCamera = v.dialogCamera or _Briefing[k].DialogCamera;
            -- Splashscreen
            if v.splashscreen then
                v.Splashscreen = v.splashscreen;
                if type(v.Splashscreen) == "table" then
                    v.Splashscreen = v.Splashscreen.image;
                end
            end
        end
    end
    return _Briefing;
end

---
-- Startet ein Briefing.
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=number] ID des Briefing
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:StartBriefing(_Briefing)
    _Briefing = self:ConvertBriefingTable(_Briefing);
    
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
    if self.Data.CurrentBriefing.Starting then
        self.Data.CurrentBriefing:Starting();
    end
    self:PageStarted();
    return self.Data.BriefingID;
end

---
-- Beendet ein Briefing.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:FinishBriefing()
    self.Data.FinishedBriefings[self.Data.CurrentBriefing.ID] = true;
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
-- Startet die aktuelle Briefing-Seite.
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
        self.Data.CurrentPage.Started = Logic.GetTime();
        API.Bridge("BundleBriefingSystem.Local:PageStarted()");
    end
end

---
-- Beendet die aktuelle Briefing-Seite
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:PageFinished()
    API.Bridge("BundleBriefingSystem.Local:PageFinished()");
    self.Data.CurrentBriefing.Page = (self.Data.CurrentBriefing.Page or 0) +1;
    if self.Data.CurrentBriefing.Page > #self.Data.CurrentBriefing then
        BundleBriefingSystem.Global:FinishBriefing();
    else
        BundleBriefingSystem.Global:PageStarted();
    end
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
-- Steuert das automatische weiter blättern und Sprünge zwischen Pages.
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
            if BundleBriefingSystem.Global.Data.CurrentPage then
                local Duration = (BundleBriefingSystem.Global.Data.CurrentPage.Duration or 0);
                if Duration > -1 then
                    if Logic.GetTime() > BundleBriefingSystem.Global.Data.CurrentPage.Started + Duration then
                        BundleBriefingSystem.Global:PageFinished();
                    end
                end
            end
        end
    end
end

---
-- Steuert die Briefing-Warteschlange.
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
-- Startet das Bundle im globalen Skript.
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
-- Startet ein Briefing.
-- @param[type=table] _Briefing Briefing Definition
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
        if self.Data.CurrentBriefing.RestoreGameSpeed and not self.Data.GameSpeedBackup then
            self.Data.GameSpeedBackup = Game.GameTimeGetFactor();
        end
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
    end
    if self.Data.CurrentBriefing.RestoreCamera and not self.Data.CameraBackup then
        self.Data.CameraBackup = {Camera.RTS_GetLookAtPosition()};
    end
    if not self.Data.CinematicActive then
        self:ActivateCinematicMode();
    end
    self.Data.BriefingActive = true;
end

---
-- Beendet ein Briefing.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:FinishBriefing()
    if self.Data.CurrentBriefing.CameraBackup then 
        Camera.RTS_SetLookAtPosition(unpack(self.Data.CurrentBriefing.CameraBackup));
        self.Data.CurrentBriefing.CameraBackup = nil;
    end
    for k, v in pairs(self.Data.SelectedEntities) do
        GUI.SelectEntity(v);
    end
    Display.SetRenderBorderPins(1);
    Display.SetRenderSky(0);
    local GameSpeed = (self.Data.GameSpeedBackup or 1);
    Game.GameTimeSetFactor(GUI.GetPlayerID(), GameSpeed);
    self.Data.GameSpeedBackup = nil;
    self:DeactivateCinematicMode();
    self.Data.BriefingActive = false;
end

---
-- Zeigt die aktuele Seite an.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:PageStarted()
    local PageID = self.Data.CurrentBriefing.Page;
    if type(self.Data.CurrentPage) == "table" then
        if PageID > 1 and self.Data.CurrentPage then
            self.Data.LastPage = self.Data.CurrentPage;
        end
        self.Data.CurrentPage = self.Data.CurrentBriefing[PageID];
        self.Data.CurrentPage.Started = Logic.GetTime();

        -- Skip-Button
        XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", 1);
        -- Rotation an Rotation des Ziels anpassen
        if self.Data.CurrentPage.DialogCamera and IsExisting(self.Data.CurrentPage.Position[1]) then
            self.Data.CurrentPage.Rotation = Logic.GetEntityOrientation(GetID(self.Data.CurrentPage.Position[1])) + 90;
        end
        -- Titel setzen
        local TitleWidget = "/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight";
        XGUIEng.SetText(TitleWidget, "");
        if self.Data.CurrentPage.Title then
            local Title = self.Data.CurrentPage.Title;
            if Title:sub(1, 1) ~= "{" then
                Title = "{@color:255,250,0,255}{center}" ..Title;
            end
            XGUIEng.SetText(TitleWidget, Title);
        end
        -- Text setzen
        local TextWidget = "/InGame/ThroneRoom/Main/MissionBriefing/Text";
        XGUIEng.SetText(TextWidget, "");
        if self.Data.CurrentPage.Text then
            XGUIEng.SetText(TextWidget, self.Data.CurrentPage.Text);
        end
        -- Fadein starten
        local PageFadeIn = self.Data.CurrentPage.FadeIn;
        if PageFadeIn then
            FadeIn(PageFadeIn);
        end
        -- Fadeout starten
        local PageFadeOut = self.Data.CurrentPage.FadeOut;
        if PageFadeOut then
            self.Data.CurrentBriefing.FaderJob = StartSimpleHiResJobEx(function(_Time, _FadeOut)
                if Logic.GetTimeMs() > _Time - (_FadeOut * 1000) then
                    FadeOut(_FadeOut);
                    return true;
                end
            end, Logic.GetTimeMs() + ((self.Data.CurrentPage.Duration or 0) * 1000), PageFadeOut);
        end
        -- Alpha der Fader-Maske
        local PageFaderAlpha = self.Data.CurrentPage.FaderAlpha;
        if PageFaderAlpha then
            SetFaderAlpha(PageFaderAlpha);
        end
        -- Portrait
        self:SetPortrait();
        -- Splashscreen
        self:SetSplashscreen();
    end
end

---
-- Beendet die aktuelle Seite.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:PageFinished()
    self.Data.CurrentBriefing.Page = (self.Data.CurrentBriefing.Page or 0) +1;
    EndJobEx(self.Data.CurrentBriefing.FaderJob);
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
            local PX, PY, PZ = self:GetPagePosition();
            local LX, LY, LZ = self:GetPageLookAt();
            local PageFOV = self.Data.CurrentPage.FOV or 42.0;
            
            if PX and not LX then
                LX, LY, LZ, PX, PY, PZ = self:GetCameraProperties();
            end
            Camera.ThroneRoom_SetPosition(PX, PY, PZ);
            Camera.ThroneRoom_SetLookAt(LX, LY, LZ);
            Camera.ThroneRoom_SetFOV(PageFOV);
        end
    end
end

---
-- Gibt die Blickrichtung der Kamera und die Position der Kamera für den
-- Kompatibelitätsmodus zurück.
-- @return[type=number] LookAt X
-- @return[type=number] LookAt Y
-- @return[type=number] LookAt Z
-- @return[type=number] Position X
-- @return[type=number] Position Y
-- @return[type=number] Position Z
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:GetCameraProperties()
    local CurrPage = self.Data.CurrentPage;
    local FlyTo = self.Data.CurrentPage.FlyTo;

    local startTime = CurrPage.Started;
    local flyTime = CurrPage.FlyTime;
    local startPosition = (FlyTo and FlyTo.Position) or CurrPage.Position;
    local endPosition = CurrPage.Position;
    local startRotation = (FlyTo and FlyTo.Rotation) or CurrPage.Rotation;
    local endRotation = CurrPage.Rotation;
    local startZoomAngle = (FlyTo and FlyTo.Angle) or CurrPage.Angle;
    local endZoomAngle = CurrPage.Angle;
    local startZoomDistance = (FlyTo and FlyTo.Zoom) or CurrPage.Zoom;
    local endZoomDistance = CurrPage.Zoom;
    local startFOV = ((FlyTo and FlyTo.FOV) or CurrPage.FOV) or 42.0;
    local endFOV = (CurrPage.FOV) or 42.0;

    local factor = self:GetLERP();
    
    local lPLX, lPLY, lPLZ = BundleBriefingSystem.Local:ConvertPosition(startPosition);
    local cPLX, cPLY, cPLZ = BundleBriefingSystem.Local:ConvertPosition(endPosition);
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

---
-- Gibt die interpolierte Kameraposition zurück.
-- @return[type=number] X
-- @return[type=number] Y
-- @return[type=number] Z
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:GetPagePosition()
    local Position = self.Data.CurrentPage.Position;
    local x, y, z = self:ConvertPosition(Position);
    local FlyTo = self.Data.CurrentPage.FlyTo;
    if FlyTo then
        local lX, lY, lZ = self:ConvertPosition(FlyTo.Position);
        if lX then
            x = x + (lX - x) * self:GetLERP();
            y = y + (lY - y) * self:GetLERP();
            z = z + (lZ - z) * self:GetLERP();
        end
    end
    return x, y, z;
end

---
-- Gibt die interpolierte Blickrichtung der Kamera zurück.
-- @return[type=number] X
-- @return[type=number] Y
-- @return[type=number] Z
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:GetPageLookAt()
    local LookAt = self.Data.CurrentPage.LookAt;
    local x, y, z = self:ConvertPosition(LookAt);
    local FlyTo = self.Data.CurrentPage.FlyTo;
    if FlyTo and x then
        local lX, lY, lZ = self:ConvertPosition(FlyTo.LookAt);
        if lX then
            x = x + (lX - x) * self:GetLERP();
            y = y + (lY - y) * self:GetLERP();
            z = z + (lZ - z) * self:GetLERP();
        end
    end
    return x, y, z;
end

---
-- Konvertiert die angegebenen Koordinaten zu XYZ.
-- @return[type=number] X
-- @return[type=number] Y
-- @return[type=number] Z
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:ConvertPosition(_Table)
    local x, y, z;
    if _Table and _Table.X then
        x = _Table.X; y = _Table.Y; z = _Table.Z;
    elseif _Table and not _Table.X then
        x, y, z = Logic.EntityGetPos(GetID(_Table[1]));
        z = z + (_Table[2] or 0);
    end
    return x, y, z;
end

---
-- Gibt den linearen Interpolationsfaktor zurück.
-- @param[type=number] LERP
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:GetLERP()
    local Current = Logic.GetTime();
    local Started = self.Data.CurrentPage.Started;
    local FlyTime;
    if self.Data.CurrentPage.FlyTo then
        FlyTime = self.Data.CurrentPage.FlyTo.Duration;
    end

    local Factor = 1.0;
    if FlyTime then
        if Started + FlyTime > Current then
            Factor = (Current - Started) / FlyTime;
            if Factor > 1 then
                Factor = 1.0;
            end
        end
    end
    return Factor;
end

---
-- Reagiert auf einen beliebigen Linksklick im Throneroom.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:ThroneRoomLeftClick()
    if self.Data.DisplayIngameCutscene then
        if AddOnCutsceneSystem then
            AddOnCutsceneSystem.Local:ThroneRoomLeftClick();
        end
    else
        -- Klick auf Entity
        local EntityID = GUI.GetMouseOverEntity();
        API.Bridge([[
            local CurrentPage = BundleBriefingSystem.Global.CurrentPage;
            if CurrentPage and CurrentPage.LeftClickOnEntity then
                BundleBriefingSystem.Global.CurrentPage:LeftClickOnEntity(]] ..tostring(EntityID).. [[)
            end
        ]]);
        -- Klick in die Spielwelt
        local x,y = GUI.Debug_GetMapPositionUnderMouse();
        API.Bridge([[
            local CurrentPage = BundleBriefingSystem.Global.CurrentPage;
            if CurrentPage and CurrentPage.LeftClickOnPosition then
                BundleBriefingSystem.Global.CurrentPage:LeftClickOnPosition(]] ..tostring(x).. [[, ]] ..tostring(y).. [[)
            end
        ]]);
        -- Klick auf den Bildschirm
        local x,y = GUI.GetMousePosition();
        API.Bridge([[
            local CurrentPage = BundleBriefingSystem.Global.CurrentPage;
            if CurrentPage and CurrentPage.LeftClickOnScreen then
                BundleBriefingSystem.Global.CurrentPage:LeftClickOnScreen(]] ..tostring(x).. [[, ]] ..tostring(y).. [[)
            end
        ]]);
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
        if (self.Data.LastSkipButtonPressed + 500) < Logic.GetTimeMs() then
            self.Data.LastSkipButtonPressed = Logic.GetTimeMs();
            API.Bridge("BundleBriefingSystem.Global:PageFinished()");
        end
    end
end

---
-- Setzt den Stil der Briefing-Bars.
-- @param[type=boolean] _Transparend Transparente Bars benutzen
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:SetBarStyle(_Transparend)
    local Alpha = (_Transparend and 100) or 255;

    XGUIEng.ShowWidget("/InGame/ThroneRoomBars", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", 1);

    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarBottom", 1, Alpha);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarTop", 1, Alpha);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarBottom", 1, Alpha);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarTop", 1, Alpha);
end

---
-- Setzt das Portrait der aktuellen Seite.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:SetPortrait()
    if self.Data.CurrentPage.Portrait then
        XGUIEng.SetMaterialAlpha("/InGame/ThroneRoom/KnightInfo/KnightBG", 1, 255);
        XGUIEng.SetMaterialTexture("/InGame/ThroneRoom/KnightInfo/KnightBG", 1, self.Data.CurrentPage.Portrait);
        XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/KnightBG", 0, 6000, 400, 600);
        XGUIEng.SetMaterialUV("/InGame/ThroneRoom/KnightInfo/KnightBG", 1, 0, 0, 1, 1);
    else
        XGUIEng.SetMaterialAlpha("/InGame/ThroneRoom/KnightInfo/KnightBG", 1, 0);
    end
end

---
-- Setzt den Splashscreen der aktuellen Seite.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:SetSplashscreen()
    local BG = "/InGame/ThroneRoomBars_2/BarTop";
    local BB = "/InGame/ThroneRoomBars_2/BarBottom";

    if self.Data.CurrentPage.Splashscreen == nil then
        XGUIEng.SetMaterialTexture(BG, 1, "");
        XGUIEng.SetMaterialTexture(BB, 1, "");
        XGUIEng.SetMaterialColor(BG, 1, 0, 0, 0, 255);
        XGUIEng.SetMaterialColor(BB, 1, 0, 0, 0, 255);
        if self.Data.CurrentBriefing.BriefingBarSizeBackup then
            local Position = self.Data.CurrentBriefing.BriefingBarSizeBackup;
            XGUIEng.SetWidgetSize(BG, Position[1], Position[2]);
            self.Data.CurrentBriefing.BriefingBarSizeBackup = nil;
        end
        self:SetBarStyle(false);
        return;
    end

    if self.Data.CurrentPage.Splashscreen then
        local size   = {GUI.GetScreenSize()};
        local is4To3 = math.floor((size[1]/size[2]) * 100) == 133;
        local is5To4 = math.floor((size[1]/size[2]) * 100) == 125;
        local u0, v0, u1, v1 = 0, 0, 1, 1;
        if is4To3 or is5To4 then
            u0 = u0 + (u0 * 0.125); u1 = u1 - (u1 * 0.125);
        end
        XGUIEng.SetMaterialColor(BG, 1, 255, 255, 255, 255);
        XGUIEng.SetMaterialTexture(BG, 1, self.Data.CurrentPage.Splashscreen);
        XGUIEng.SetMaterialUV(BG, 1, u0, v0, u1, v1);
    end
    if not self.Data.CurrentBriefing.BriefingBarSizeBackup then
        local x, y = XGUIEng.GetWidgetSize(BG);
        self.Data.CurrentBriefing.BriefingBarSizeBackup = {x, y};
    end

    local BarX    = self.Data.CurrentBriefing.BriefingBarSizeBackup[1];
    local _, BarY = XGUIEng.GetWidgetSize("/InGame/ThroneRoomBars");
    XGUIEng.SetWidgetSize(BG, BarX, BarY);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", 0);
    XGUIEng.ShowWidget(BG, 1);
end

---
-- Aktiviert den Cinematic Mode.
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

    BundleBriefingSystem.Local:SetBarStyle(false);

    GUI.ClearSelection();
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
-- Speichert, wenn der Ladebildschirm geschlossen wird.
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