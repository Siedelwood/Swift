-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleGameHelperFunctions                                    # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Bundle erhälst du hilfreiche Funktionen zur Steuerung der
-- Spielgeschwindigkeit.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleGameHelperFunctions = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Setzt die Obergrenze für die Spielgeschwindigkeit fest.
--
-- <p><b>Alias:</b> SetSpeedLimit</p>
--
-- @param[type=number] _Limit Obergrenze
-- @within Anwenderfunktionen
--
function API.SpeedLimitSet(_Limit)
    if not GUI then
        API.Bridge("API.SpeedLimitSet(" .._Limit.. ")");
        return;
    end
    return BundleGameHelperFunctions.Local:SetSpeedLimit(_Limit);
end
SetSpeedLimit = API.SpeedLimitSet

---
-- Aktiviert die Speedbremse. Die vorher eingestellte Maximalgeschwindigkeit
-- kann nicht mehr überschritten werden.
--
-- <p><b>Alias:</b> ActivateSpeedLimit</p>
--
-- @param[type=boolean] _Flag Speedbremse ist aktiv
-- @within Anwenderfunktionen
--
function API.SpeedLimitActivate(_Flag)
    if GUI then
        API.Bridge("API.SpeedLimitActivate(" ..tostring(_Flag).. ")");
        return;
    end
    return API.Bridge("BundleGameHelperFunctions.Local:ActivateSpeedLimit(" ..tostring(_Flag).. ")");
end
ActivateSpeedLimit = API.SpeedLimitActivate;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleGameHelperFunctions = {
    Local = {
        Data = {
            SpeedLimit = 32,
        }
    },
}

-- -------------------------------------------------------------------------- --

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Local:Install()
    self:InitForbidSpeedUp()
end

-- -------------------------------------------------------------------------- --

---
-- Setzt die Obergrenze für die Spielgeschwindigkeit fest.
--
-- @param[type=number] _Limit Obergrenze
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Local:SetSpeedLimit(_Limit)
    _Limit = (_Limit < 1 and 1) or math.floor(_Limit);
    self.Data.SpeedLimit = _Limit;
end

---
-- Aktiviert die Speedbremse. Die vorher eingestellte Maximalgeschwindigkeit
-- kann nicht mehr überschritten werden.
--
-- @param[type=boolean] _Flag Speedbremse ist aktiv
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Local:ActivateSpeedLimit(_Flag)
    self.Data.UseSpeedLimit = _Flag == true;
    if _Flag and Game.GameTimeGetFactor(GUI.GetPlayerID()) > self.Data.SpeedLimit then
        Game.GameTimeSetFactor(GUI.GetPlayerID(), self.Data.SpeedLimit);
    end
end

---
-- Überschreibt das Callback, das nach dem Ändern der Spielgeschwindigkeit
-- aufgerufen wird und installiert die Speedbremse.
--
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Local:InitForbidSpeedUp()
    GameCallback_GameSpeedChanged_Orig_Preferences_ForbidSpeedUp = GameCallback_GameSpeedChanged;
    GameCallback_GameSpeedChanged = function( _Speed )
        GameCallback_GameSpeedChanged_Orig_Preferences_ForbidSpeedUp( _Speed );
        if BundleGameHelperFunctions.Local.Data.UseSpeedLimit == true then
            if _Speed > BundleGameHelperFunctions.Local.Data.SpeedLimit then
                Game.GameTimeSetFactor(GUI.GetPlayerID(), BundleGameHelperFunctions.Local.Data.SpeedLimit);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleGameHelperFunctions");

