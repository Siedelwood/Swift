-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleGameHelperFunctions                                    # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle stellt die als "Speedbremse" bekannte Funktionalität zur 
-- Verfügung. Die maximale Beschleunigung des Spiels kann gesteuert werden.
--
-- Wenn die Geschwindigkeit festgelegt werden soll, muss zuerst bestimmt werden
-- wo die Obergrenze liegt.
-- <pre>API.SpeedLimitSet(1)</pre>
-- Diese Festlegung gilt solange, bis sie irgend wann einmal geändert wird.
--
-- Danach kann die Sperre jederzeit aktiviert oder deaktiviert werden.
-- <pre>API.SpeedLimitActivate(true)</pre>
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
-- Diese Funktion setzt die maximale Spielgeschwindigkeit bis zu der das Spiel
-- beschleunigt werden kann.
--
-- <p><b>Alias:</b> SetSpeedLimit</p>
--
-- @param[type=number] _Limit Obergrenze für Spielgeschwindigkeit
-- @within Anwenderfunktionen
-- @see API.SpeedLimitActivate
--
-- @usage -- Legt die Speedbremse auf Stufe 1 fest.
-- API.SpeedLimitSet(1)
-- -- Legt die Speedbremse auf Stufe 2 fest.
-- API.SpeedLimitSet(2)
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
-- Aktiviert die zuvor eingestellte Maximalgeschwindigkeit.
--
-- <p><b>Alias:</b> ActivateSpeedLimit</p>
--
-- @param[type=boolean] _Flag Speedbremse ist aktiv
-- @within Anwenderfunktionen
-- @see API.SpeedLimitSet
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

