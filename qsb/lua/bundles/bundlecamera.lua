-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleCamera                                                 # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Manchmal ist der maximale Zoom nicht genug! Löse Dich von den Fesseln, die
-- Dich einschränken! Dieses Bundle ermöglicht es den tatsächlichen maximalen
-- Zoom zu nutzen.
--
-- Außerdem kannst du die Kamera auf ein bestimmtes Entity zentrieren. Du
-- kannst Rotation und Zoomfaktor bestimmen.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleCamera = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Aktiviert den Hotkey zum Wechsel zwischen normalen und erweiterten Zoom.
--
-- <p><b>Alias:</b> AllowExtendedZoom</p>
--
-- @param _Flag [boolean] Erweiterter Zoom gestattet
-- @within Anwenderfunktionen
--
function API.AllowExtendedZoom(_Flag)
    if GUI then
        GUI.SendScriptCommand("API.AllowExtendedZoom(".. tostring(_Flag == true) ..")");
        return;
    end
    BundleCamera.Global.Data.ExtendedZoomAllowed = _Flag == true;
    if _Flag == false then
        BundleCamera.Global:DeactivateExtendedZoom();
    end
end
AllowExtendedZoom = API.AllowExtendedZoom;

---
-- Fokusiert die Kamera auf dem Primärritter des Spielers.
--
-- <p><b>Alias:</b> SetCameraToPlayerKnight</p>
--
-- @param[type=number] _Player Partei
-- @param[type=number] _Rotation Kamerawinkel
-- @param[type=number] _ZoomFactor Zoomfaktor
-- @within Anwenderfunktionen
--
function API.FocusCameraOnKnight(_Player, _Rotation, _ZoomFactor)
    API.FocusCameraOnEntity(Logic.GetKnightID(_Player), _Rotation, _ZoomFactor)
end
SetCameraToPlayerKnight = API.FocusCameraOnKnight;

---
-- Fokusiert die Kamera auf dem Entity.
--
-- <p><b>Alias:</b> SetCameraToEntity</p>
--
-- @param _Entity Entity (Skriptname oder ID)
-- @param[type=number] _Rotation Kamerawinkel
-- @param[type=number] _ZoomFactor Zoomfaktor
-- @within Anwenderfunktionen
--
function API.FocusCameraOnEntity(_Entity, _Rotation, _ZoomFactor)
    if not GUI then
        local Subject = (type(_Entity) ~= "string" and _Entity) or "'" .._Entity.. "'";
        Logic.ExecuteInLuaLocalState("API.FocusCameraOnEntity(" ..Subject.. ", " ..tostring(_Rotation).. ", " ..tostring(_ZoomFactor).. ")");
        return;
    end
    if type(_Rotation) ~= "number" then
        error("API.FocusCameraOnEntity: Rotation is wrong!");
        return;
    end
    if type(_ZoomFactor) ~= "number" then
        error("API.FocusCameraOnEntity: Zoom factor is wrong!");
        return;
    end
    if not IsExisting(_Entity) then
        error("API.FocusCameraOnEntity: Entity " ..tostring(_Entity).." does not exist!");
        return;
    end
    return BundleCamera.Local:SetCameraToEntity(_Entity, _Rotation, _ZoomFactor);
end
SetCameraToEntity = API.FocusCameraOnEntity;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleCamera = {
    Global = {
        Data = {
            ExtendedZoomAllowed = true,
        }
    },
    Local = {},
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function BundleCamera.Global:Install()
    self:InitExtendedZoomHotkeyFunction();
    self:InitExtendedZoomHotkeyDescription();
    API.AddSaveGameAction(BundleCamera.Global.OnSaveGameLoaded);
end

-- -------------------------------------------------------------------------- --

---
-- Schaltet zwischen dem normalen und dem erweiterten Zoom um.
--
-- @within Internal
-- @local
--
function BundleCamera.Global:ToggleExtendedZoom()
    if self.Data.ExtendedZoomAllowed then
        if self.Data.ExtendedZoomActive then
            self:DeactivateExtendedZoom();
        else
            self:ActivateExtendedZoom();
        end
    end
end

---
-- Aktiviert den erweiterten Zoom.
--
-- @within Internal
-- @local
--
function BundleCamera.Global:ActivateExtendedZoom()
    self.Data.ExtendedZoomActive = true;
    API.Bridge("BundleCamera.Local:ActivateExtendedZoom()");
end

---
-- Deaktiviert den erweiterten Zoom.
--
-- @within Internal
-- @local
--
function BundleCamera.Global:DeactivateExtendedZoom()
    self.Data.ExtendedZoomActive = false;
    API.Bridge("BundleCamera.Local:DeactivateExtendedZoom()");
end

---
-- Initialisiert den erweiterten Zoom.
--
-- @within Internal
-- @local
--
function BundleCamera.Global:InitExtendedZoomHotkeyFunction()
    API.Bridge([[
        BundleCamera.Local:ActivateExtendedZoomHotkey()
    ]]);
end

---
-- Initialisiert den erweiterten Zoom.
--
-- @within Internal
-- @local
--
function BundleCamera.Global:InitExtendedZoomHotkeyDescription()
    API.Bridge([[
        BundleCamera.Local:RegisterExtendedZoomHotkey()
    ]]);
end

-- -------------------------------------------------------------------------- --

---
-- Stellt nicht-persistente Änderungen nach dem laden wieder her.
--
-- @within Internal
-- @local
--
function BundleCamera.Global.OnSaveGameLoaded()
    -- Geänderter Zoom --
    if BundleCamera.Global.Data.ExtendedZoomActive then
        BundleCamera.Global:ActivateExtendedZoom();
    end
    BundleCamera.Global:InitExtendedZoomHotkeyFunction();
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleCamera.Local:Install()
end

-- -------------------------------------------------------------------------- --

---
-- Fokusiert die Kamera auf dem Entity.
--
-- @param _Entity Entity (Skriptname oder ID)
-- @param[type=number] _Rotation Kamerawinkel
-- @param[type=number] _ZoomFactor Zoomfaktor
-- @within Internal
-- @local
--
function BundleCamera.Local:SetCameraToEntity(_Entity, _Rotation, _ZoomFactor)
    local pos = GetPosition(_Entity);
    local rotation = (_Rotation or -45);
    local zoomFactor = (_ZoomFactor or 0.5);
    Camera.RTS_SetLookAtPosition(pos.X, pos.Y);
    Camera.RTS_SetRotationAngle(rotation);
    Camera.RTS_SetZoomFactor(zoomFactor);
end

-- -------------------------------------------------------------------------- --

---
-- Schreibt den Hotkey für den erweiterten Zoom in das Hotkey-Register.
--
-- @within Internal
-- @local
--
function BundleCamera.Local:RegisterExtendedZoomHotkey()
    API.AddHotKey(
        {de = "Strg + Umschalt + K",
         en = "Ctrl + Shift + K"},
        {de = "Alternativen Zoom ein/aus",
         en = "Alternative zoom on/off",
         fr = "Zoom étendu on/off"}
    )
end

---
-- Aktiviert den Hotkey zum Wechsel zwischen normalen und erweiterten Zoom.
--
-- @within Internal
-- @local
--
function BundleCamera.Local:ActivateExtendedZoomHotkey()
    Input.KeyBindDown(
        Keys.ModifierControl + Keys.ModifierShift + Keys.K,
        "BundleCamera.Local:ToggleExtendedZoom()",
        2,
        false
    );
end

---
-- Wechselt zwischen erweitertem und normalen Zoom.
--
-- @within Internal
-- @local
--
function BundleCamera.Local:ToggleExtendedZoom()
    API.Bridge("BundleCamera.Global:ToggleExtendedZoom()");
end

---
-- Erweitert die Zoomrestriktion auf das Maximum.
--
-- @within Internal
-- @local
--
function BundleCamera.Local:ActivateExtendedZoom()
    Camera.RTS_SetZoomFactorMax(0.8701);
    Camera.RTS_SetZoomFactor(0.8700);
    Camera.RTS_SetZoomFactorMin(0.0999);
end

---
-- Stellt die normale Zoomrestriktion wieder her.
--
-- @within Internal
-- @local
--
function BundleCamera.Local:DeactivateExtendedZoom()
    Camera.RTS_SetZoomFactor(0.5000);
    Camera.RTS_SetZoomFactorMax(0.5001);
    Camera.RTS_SetZoomFactorMin(0.0999);
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleCamera");

