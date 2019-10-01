-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia ExternalThirdPersonCamera                                     # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle bietet einen Kameramodus an, mit dem ein Entity aus der
-- Schulterperspektive verfolgt werden kann.
--
-- @within Modulbeschreibung
-- @set sort=true
--
ExternalThirdPersonCamera = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Aktiviert die Heldenkamera und setzt den verfolgten Helden. Der
-- Held kann 0 sein, dann wird entweder der letzte Held verwendet
-- oder über den GUI-Spieler ermittelt.
--
-- <p><b>Alias:</b> HeroCameraActivate</p>
--
-- @param _Hero [string|number] Skriptname/Entity-ID des Helden
-- @param _MaxZoom [number] Maximaler Zoomfaktor
-- @within Anwenderfunktionen
--
function API.ThirdPersonActivate(_Hero, _MaxZoom)
    if GUI then
        local Target = (type(_Hero) == "string" and "'".._Hero.."'") or _Hero;
        API.Bridge("API.ThirdPersonActivate(".. Target ..", ".. _MaxZoom ..")");
        return;
    end
    return ExternalThirdPersonCamera.Global:ThirdPersonActivate(_Hero, _MaxZoom);
end
HeroCameraActivate = API.ThirdPersonActivate;

---
-- Deaktiviert die Heldenkamera.
--
-- <p><b>Alias:</b> HeroCameraDeactivate</p>
--
-- @within Anwenderfunktionen
--
function API.ThirdPersonDeactivate()
    if GUI then
        API.Bridge("API.ThirdPersonDeactivate()");
        return;
    end
    return ExternalThirdPersonCamera.Global:ThirdPersonDeactivate();
end
HeroCameraDeactivate = API.ThirdPersonDeactivate;

---
-- Prüft, ob die Heldenkamera aktiv ist.
--
-- <p><b>Alias:</b> HeroCameraIsRuning</p>
--
-- @return [boolean] Kamera aktiv
-- @within Anwenderfunktionen
--
function API.ThirdPersonIsRuning()
    if not GUI then
        return ExternalThirdPersonCamera.Global:ThirdPersonIsRuning();
    else
        return ExternalThirdPersonCamera.Local:ThirdPersonIsRuning();
    end
end
HeroCameraIsRuning = API.ThirdPersonIsRuning;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

ExternalThirdPersonCamera = {
    Global = {
        Data = {
            ThirdPersonIsActive = false,
        }
    },
    Local = {
        Data = {
            ThirdPersonIsActive = false,
            ThirdPersonLastHero = nil,
            ThirdPersonLastZoom = nil,
        }
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function ExternalThirdPersonCamera.Global:Install()
    API.AddSaveGameAction(ExternalThirdPersonCamera.Global.OnSaveGameLoaded);
end

-- -------------------------------------------------------------------------- --

---
-- Aktiviert die Heldenkamera und setzt den verfolgten Helden. Der
-- Held kann 0 sein, dann wird entweder der letzte Held verwendet
-- oder über den GUI-Spieler ermittelt.
--
-- @param _Hero [string|number] Skriptname/Entity-ID des Helden
-- @param _MaxZoom [number] Maximaler Zoomfaktor
-- @within Internal
-- @local
--
function ExternalThirdPersonCamera.Global:ThirdPersonActivate(_Hero, _MaxZoom)
    if BriefingSystem then
        ExternalThirdPersonCamera.Global:ThirdPersonOverwriteStartAndEndBriefing();
    end

    local Hero = GetID(_Hero);
    ExternalThirdPersonCamera.Global.Data.ThirdPersonIsActive = true;
    Logic.ExecuteInLuaLocalState([[
        ExternalThirdPersonCamera.Local:ThirdPersonActivate(]]..tostring(Hero)..[[, ]].. tostring(_MaxZoom) ..[[);
    ]]);
end

---
-- Deaktiviert die Heldenkamera.
-- @within Internal
-- @local
--
function ExternalThirdPersonCamera.Global:ThirdPersonDeactivate()
    ExternalThirdPersonCamera.Global.Data.ThirdPersonIsActive = false;
    Logic.ExecuteInLuaLocalState([[
        ExternalThirdPersonCamera.Local:ThirdPersonDeactivate();
    ]]);
end

---
-- Prüft, ob die Heldenkamera aktiv ist.
--
-- @return [boolean] Kamera aktiv
-- @within Internal
-- @local
--
function ExternalThirdPersonCamera.Global:ThirdPersonIsRuning()
    return self.Data.ThirdPersonIsActive;
end

---
-- Überschreibt StartBriefing und EndBriefing des Briefing System,
-- wenn es vorhanden ist.
-- @within Internal
-- @local
--
function ExternalThirdPersonCamera.Global:ThirdPersonOverwriteStartAndEndBriefing()
    if BriefingSystem then
        if not BriefingSystem.StartBriefing_Orig_HeroCamera then
            BriefingSystem.StartBriefing_Orig_HeroCamera = BriefingSystem.StartBriefing;
            BriefingSystem.StartBriefing = function(_Briefing, _CutsceneMode)
                if ExternalThirdPersonCamera.Global:ThirdPersonIsRuning() then
                    ExternalThirdPersonCamera.Global:ThirdPersonDeactivate();
                    ExternalThirdPersonCamera.Global.Data.ThirdPersonStoppedByCode = true;
                end
                BriefingSystem.StartBriefing_Orig_HeroCamera(_Briefing, _CutsceneMode);
            end
            StartBriefing = BriefingSystem.StartBriefing;
        end

        if not BriefingSystem.EndBriefing_Orig_HeroCamera then
            BriefingSystem.EndBriefing_Orig_HeroCamera = BriefingSystem.EndBriefing;
            BriefingSystem.EndBriefing = function(_Briefing, _CutsceneMode)
                BriefingSystem.EndBriefing_Orig_HeroCamera();
                if ExternalThirdPersonCamera.Global.Data.ThirdPersonStoppedByCode then
                    ExternalThirdPersonCamera.Global:ThirdPersonActivate(0);
                    ExternalThirdPersonCamera.Global.Data.ThirdPersonStoppedByCode = false;
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

---
-- Stellt nicht-persistente Änderungen nach dem laden wieder her.
--
-- @within Internal
-- @local
--
function ExternalThirdPersonCamera.Global.OnSaveGameLoaded()
    
end

-- Local Script ----------------------------------------------------------------

---
-- Aktiviert die Heldenkamera und setzt den verfolgten Helden. Der
-- Held kann 0 sein, dann wird entweder der letzte Held verwendet
-- oder über den GUI-Spieler ermittelt.
--
-- @param _Hero [string|number] Skriptname/Entity-ID des Helden
-- @param _MaxZoom [number] Maximaler Zoomfaktor
-- @within Internal
-- @local
--
function ExternalThirdPersonCamera.Local:ThirdPersonActivate(_Hero, _MaxZoom)
    _Hero = (_Hero ~= 0 and _Hero) or self.Data.ThirdPersonLastHero or Logic.GetKnightID(GUI.GetPlayerID());
    _MaxZoom = _MaxZoom or self.Data.ThirdPersonLastZoom or 0.5;
    if not _Hero then
        return;
    end

    if not GameCallback_Camera_GetBorderscrollFactor_Orig_HeroCamera then
        self:ThirdPersonOverwriteGetBorderScrollFactor();
    end

    self.Data.ThirdPersonLastHero = _Hero;
    self.Data.ThirdPersonLastZoom = _MaxZoom;
    self.Data.ThirdPersonIsActive = true;

    local Orientation = Logic.GetEntityOrientation(_Hero);
    Camera.RTS_FollowEntity(_Hero);
    Camera.RTS_SetRotationAngle(Orientation-90);
    Camera.RTS_SetZoomFactor(_MaxZoom);
    Camera.RTS_SetZoomFactorMax(_MaxZoom + 0.0001);
end

---
-- Deaktiviert die Heldenkamera.
--
-- @within Internal
-- @local
--
function ExternalThirdPersonCamera.Local:ThirdPersonDeactivate()
    self.Data.ThirdPersonIsActive = false;
    Camera.RTS_SetZoomFactorMax(0.5);
    Camera.RTS_SetZoomFactor(0.5);
    Camera.RTS_FollowEntity(0);
end

---
-- Prüft, ob die Heldenkamera aktiv ist.
--
-- @return [boolean] Kamera aktiv
-- @within Internal
-- @local
--
function ExternalThirdPersonCamera.Local:ThirdPersonIsRuning()
    return self.Data.ThirdPersonIsActive;
end

---
-- Überschreibt GameCallback_GetBorderScrollFactor und wandelt den
-- Bildlauf am Bildschirmrand in Bildrotation um. Dabei wird die
-- Kamera um links oder rechts gedreht, abhänig von der Position
-- der Mouse.
--
-- @within Internal
-- @local
--
function ExternalThirdPersonCamera.Local:ThirdPersonOverwriteGetBorderScrollFactor()
    GameCallback_Camera_GetBorderscrollFactor_Orig_HeroCamera = GameCallback_Camera_GetBorderscrollFactor
    GameCallback_Camera_GetBorderscrollFactor = function()
        if not ExternalThirdPersonCamera.Local.Data.ThirdPersonIsActive then
            return GameCallback_Camera_GetBorderscrollFactor_Orig_HeroCamera();
        end

        local CameraRotation = Camera.RTS_GetRotationAngle();
        local xS, yS = GUI.GetScreenSize();
        local xM, yM = GUI.GetMousePosition();
        local xR = xM / xS;

        if xR <= 0.02 then
            CameraRotation = CameraRotation + 0.3;
        elseif xR >= 0.98 then
            CameraRotation = CameraRotation - 0.3;
        else
            return 0;
        end
        if CameraRotation >= 360 then
            CameraRotation = 0;
        end
        Camera.RTS_SetRotationAngle(CameraRotation);
        return 0;
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("ExternalThirdPersonCamera");

