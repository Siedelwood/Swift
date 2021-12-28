--[[
Swift_2_SpeedLimit/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Dieses Modul erlaubt die maximale Beschleunigung des Spiels zu steuern.
--
-- <b>Hinweis:</b> Kann nicht im Multiplayer verwendet werden!
--
-- @within Modulbeschreibung
-- @set sort=true
--

---
-- Setzt die Spielgeschwindigkeit auf Stufe 1 fest oder gibt sie wieder frei.
--
-- @param[type=boolean] _Flag Speedbremse ist aktiv
-- @within Anwenderfunktionen
-- @see API.SpeedLimitSet
--
function API.LockGameSpeed(_Flag)
    if GUI then
        return;
    end
    return Logic.ExecuteInLuaLocalState("ModuleSpeedLimitation.Local:ActivateSpeedLimit(" ..tostring(_Flag).. ")");
end

