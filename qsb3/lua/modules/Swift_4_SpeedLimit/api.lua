--[[
Swift_4_SpeedLimit/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Dieses Modul erlaubt die maximale Beschleunigung des Spiels zu steuern.
--
-- Wenn die Geschwindigkeit festgelegt werden soll, muss zuerst bestimmt werden,
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

---
-- Diese Funktion setzt die maximale Spielgeschwindigkeit bis zu der das Spiel
-- beschleunigt werden kann.
--
-- <b>Hinweis:</b> Kann nicht im Multiplayer verwendet werden!
--
-- <b>Alias:</b> SetSpeedLimit
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
        Logic.ExecuteInLuaLocalState("API.SpeedLimitSet(" ..tostring(_Limit).. ")");
        return;
    end
    return ModuleSpeedLimitation.Local:SetSpeedLimit(_Limit);
end
SetSpeedLimit = API.SpeedLimitSet

---
-- Aktiviert die zuvor eingestellte Maximalgeschwindigkeit.
--
-- <b>Hinweis:</b> Kann nicht im Multiplayer verwendet werden!
--
-- <b>Alias:</b> ActivateSpeedLimit
--
-- @param[type=boolean] _Flag Speedbremse ist aktiv
-- @within Anwenderfunktionen
-- @see API.SpeedLimitSet
--
function API.SpeedLimitActivate(_Flag)
    if GUI then
        return;
    end
    return Logic.ExecuteInLuaLocalState("ModuleSpeedLimitation.Local:ActivateSpeedLimit(" ..tostring(_Flag).. ")");
end
ActivateSpeedLimit = API.SpeedLimitActivate;

