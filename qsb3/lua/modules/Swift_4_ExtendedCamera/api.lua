--[[
Swift_4_ExtendedCamera/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht die Verwendung des absoluten Zoom Limit.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_InputOutputCore.api.html">(1) Input/Output Core</a></li>
-- <li><a href="Swift_1_DisplayCore.api.html">(1) Display Core</a></li>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Aktiviert den Hotkey zum Wechsel zwischen normalen und erweiterten Zoom.
--
-- @param _Flag [boolean] Erweiterter Zoom gestattet
-- @within Anwenderfunktionen
--
function API.AllowExtendedZoom(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.AllowExtendedZoom(%s)]],
            tostring(_Flag)
        ))
        return;
    end
    ModuleExtendedCamera.Local.ExtendedZoomAllowed = _Flag == true;
    if _Flag == false then
        ModuleExtendedCamera.Local:DeactivateExtendedZoom();
    end
end
AllowExtendedZoom = API.AllowExtendedZoom;

---
-- Fokusiert die Kamera auf dem Primärritter des Spielers.
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
-- @param _Entity Entity (Skriptname oder ID)
-- @param[type=number] _Rotation Kamerawinkel
-- @param[type=number] _ZoomFactor Zoomfaktor
-- @within Anwenderfunktionen
--
function API.FocusCameraOnEntity(_Entity, _Rotation, _ZoomFactor)
    if not GUI then
        local Subject = (type(_Entity) ~= "string" and _Entity) or ("'" .._Entity.. "'");
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
    return ModuleExtendedCamera.Local:SetCameraToEntity(_Entity, _Rotation, _ZoomFactor);
end
SetCameraToEntity = API.FocusCameraOnEntity;

