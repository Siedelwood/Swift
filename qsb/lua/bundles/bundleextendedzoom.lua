-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleExtendedZoom                                           # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Manchmal ist der maximale Zoom nicht genug! Löse Dich von den Fesseln, die
-- Dich einschränken! Dieses Bundle ermöglicht es den tatsächlichen maximalen
-- Zoom zu nutzen.
--
-- <p><a href="#API.AllowExtendedZoom">Zoom entriegeln oder sperren</a></p>
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleExtendedZoom = {};

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
        API.Bridge("API.AllowExtendedZoom(".. tostring(_Flag) ..")");
        return;
    end
    BundleExtendedZoom.Global.Data.ExtendedZoomAllowed = _Flag == true;
    if _Flag == false then
        BundleExtendedZoom.Global:DeactivateExtendedZoom();
    end
end
AllowExtendedZoom = API.AllowExtendedZoom;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleExtendedZoom = {
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
function BundleExtendedZoom.Global:Install()
    self:InitExtendedZoomHotkeyFunction();
    self:InitExtendedZoomHotkeyDescription();
    API.AddSaveGameAction(BundleExtendedZoom.Global.OnSaveGameLoaded);
end

-- -------------------------------------------------------------------------- --

---
-- Schaltet zwischen dem normalen und dem erweiterten Zoom um.
--
-- @within Internal
-- @local
--
function BundleExtendedZoom.Global:ToggleExtendedZoom()
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
function BundleExtendedZoom.Global:ActivateExtendedZoom()
    self.Data.ExtendedZoomActive = true;
    API.Bridge("BundleExtendedZoom.Local:ActivateExtendedZoom()");
end

---
-- Deaktiviert den erweiterten Zoom.
--
-- @within Internal
-- @local
--
function BundleExtendedZoom.Global:DeactivateExtendedZoom()
    self.Data.ExtendedZoomActive = false;
    API.Bridge("BundleExtendedZoom.Local:DeactivateExtendedZoom()");
end

---
-- Initialisiert den erweiterten Zoom.
--
-- @within Internal
-- @local
--
function BundleExtendedZoom.Global:InitExtendedZoomHotkeyFunction()
    API.Bridge([[
        BundleExtendedZoom.Local:ActivateExtendedZoomHotkey()
    ]]);
end

---
-- Initialisiert den erweiterten Zoom.
--
-- @within Internal
-- @local
--
function BundleExtendedZoom.Global:InitExtendedZoomHotkeyDescription()
    API.Bridge([[
        BundleExtendedZoom.Local:RegisterExtendedZoomHotkey()
    ]]);
end

-- -------------------------------------------------------------------------- --

---
-- Stellt nicht-persistente Änderungen nach dem laden wieder her.
--
-- @within Internal
-- @local
--
function BundleExtendedZoom.Global.OnSaveGameLoaded()
    -- Geänderter Zoom --
    if BundleExtendedZoom.Global.Data.ExtendedZoomActive then
        BundleExtendedZoom.Global:ActivateExtendedZoom();
    end
    BundleExtendedZoom.Global:InitExtendedZoomHotkeyFunction();
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleExtendedZoom.Local:Install()
end

-- -------------------------------------------------------------------------- --

---
-- Schreibt den Hotkey für den erweiterten Zoom in das Hotkey-Register.
--
-- @within Internal
-- @local
--
function BundleExtendedZoom.Local:RegisterExtendedZoomHotkey()
    API.AddHotKey(
        {de = "Strg + Umschalt + K",       en = "Ctrl + Shift + K"},
        {de = "Alternativen Zoom ein/aus", en = "Alternative zoom on/off"}
    )
end

---
-- Aktiviert den Hotkey zum Wechsel zwischen normalen und erweiterten Zoom.
--
-- @within Internal
-- @local
--
function BundleExtendedZoom.Local:ActivateExtendedZoomHotkey()
    Input.KeyBindDown(
        Keys.ModifierControl + Keys.ModifierShift + Keys.K,
        "BundleExtendedZoom.Local:ToggleExtendedZoom()",
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
function BundleExtendedZoom.Local:ToggleExtendedZoom()
    API.Bridge("BundleExtendedZoom.Global:ToggleExtendedZoom()");
end

---
-- Erweitert die Zoomrestriktion auf das Maximum.
--
-- @within Internal
-- @local
--
function BundleExtendedZoom.Local:ActivateExtendedZoom()
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
function BundleExtendedZoom.Local:DeactivateExtendedZoom()
    Camera.RTS_SetZoomFactor(0.5000);
    Camera.RTS_SetZoomFactorMax(0.5001);
    Camera.RTS_SetZoomFactorMin(0.0999);
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleExtendedZoom");
