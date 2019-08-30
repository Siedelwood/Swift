-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleUtilities                                              # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- FIXME: Ein Sammelsorium von Funktionen, die noch nicht zugeordnet sind.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleUtilities = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Deaktiviert die Tastenkombination zum Einschalten der Cheats.
--
-- <p><b>Alias:</b> KillCheats</p>
--
-- @within Anwenderfunktionen
--
function API.ForbidCheats()
    if GUI then
        API.Bridge("API.ForbidCheats()");
        return;
    end
    return BundleUtilities.Global:KillCheats();
end
KillCheats = API.ForbidCheats;

---
-- Aktiviert die Tastenkombination zum Einschalten der Cheats.
--
-- <p><b>Alias:</b> RessurectCheats</p>
--
-- @within Anwenderfunktionen
--
function API.AllowCheats()
    if GUI then
        API.Bridge("API.AllowCheats()");
        return;
    end
    return BundleUtilities.Global:RessurectCheats();
end
RessurectCheats = API.AllowCheats;

---
-- Sperrt das Speichern von Spielständen oder gibt es wieder frei.
--
-- <p><b>Alias:</b> ForbidSaveGame</p>
--
-- @param[type=boolean] _Flag Speichern gesperrt
-- @within Anwenderfunktionen
--
function API.ForbidSaveGame(_Flag)
    if GUI then
        API.Bridge("API.ForbidSaveGame(".. tostring(_Flag) ..")");
        return;
    end
    API.Bridge([[
        BundleUtilities.Local.Data.ForbidSave = ]].. tostring(_Flag) ..[[ == true
        BundleUtilities.Local:DisplaySaveButtons(]].. tostring(_Flag) ..[[)
    ]]);
end
ForbidSaveGame = API.ForbidSaveGame;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleUtilities = {
    Global = {
        Data = {}
    },
    Local = {
        Data = {}
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function BundleUtilities.Global:Install()
    API.AddSaveGameAction(BundleUtilities.Global.OnSaveGameLoaded);
end

-- -------------------------------------------------------------------------- --

---
-- Deaktiviert die Tastenkombination zum Einschalten der Cheats.
--
-- @within Internal
-- @local
--
function BundleUtilities.Global:KillCheats()
    self.Data.CheatsForbidden = true;
    API.Bridge("BundleUtilities.Local:KillCheats()");
end

---
-- Aktiviert die Tastenkombination zum Einschalten der Cheats.
--
-- @within Internal
-- @local
--
function BundleUtilities.Global:RessurectCheats()
    self.Data.CheatsForbidden = false;
    API.Bridge("BundleUtilities.Local:RessurectCheats()");
end

-- -------------------------------------------------------------------------- --

---
-- Stellt nicht-persistente Änderungen nach dem laden wieder her.
--
-- @within Internal
-- @local
--
function BundleUtilities.Global.OnSaveGameLoaded()
    -- Cheats sperren --
    if BundleUtilities.Global.Data.CheatsForbidden == true then
        BundleUtilities.Global:KillCheats();
    end
    -- Illegale Speicherstände
    API.Bridge("BundleUtilities.Local:CloseIllegalSaveGame()");
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleUtilities.Local:Install()
    self:InitForbidSaveGame();
end

-- -------------------------------------------------------------------------- --

---
-- Deaktiviert die Tastenkombination zum Einschalten der Cheats.
--
-- @within Internal
-- @local
--
function BundleUtilities.Local:KillCheats()
    Input.KeyBindDown(
        Keys.ModifierControl + Keys.ModifierShift + Keys.Divide,
        "KeyBindings_EnableDebugMode(0)",
        2,
        false
    );
end

---
-- Aktiviert die Tastenkombination zum Einschalten der Cheats.
--
-- @within Internal
-- @local
--
function BundleUtilities.Local:RessurectCheats()
    Input.KeyBindDown(
        Keys.ModifierControl + Keys.ModifierShift + Keys.Divide,
        "KeyBindings_EnableDebugMode(2)",
        2,
        false
    );
end

-- -------------------------------------------------------------------------- --

---
-- Überschreibt die Hotkey-Funktion, die das Spiel speichert.
--
-- @within Internal
-- @local
--
function BundleUtilities.Local:InitForbidSaveGame()
    KeyBindings_SaveGame_Orig_Preferences_SaveGame = KeyBindings_SaveGame;
    KeyBindings_SaveGame = function()
        if BundleUtilities.Local.Data.ForbidSave then
            return;
        end
        KeyBindings_SaveGame_Orig_Preferences_SaveGame();
    end
end

---
-- Schließt einen Spielstand, der während des Speicherverbots erstellt wurde.
--
-- <b>Hinweis</b>: Dies ist ein Fallback wegen dem automatischen Speichern
-- der History Edition, dass nicht auf Lua-Ebene verhindert werden kann.
--
-- @within Internal
-- @local
--
function BundleUtilities.Local:CloseIllegalSaveGame()
    if BundleUtilities.Local.Data.ForbidSave then
        Framework.CloseGame();
    end
end

---
-- Zeigt oder versteckt die Speicherbuttons im Spielmenü.
--
-- @param[type=boolean] _Flag Speicherbuttons sichtbar
-- @within Internal
-- @local
--
function BundleUtilities.Local:DisplaySaveButtons(_Flag)
    XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame",  (_Flag and 0) or 1);
    XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", (_Flag and 0) or 1);
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleUtilities");

