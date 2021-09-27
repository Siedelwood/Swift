--[[
Swift_1_DisplayCore/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Dieses Modul bietet rudimentäre Funktionen zur Veränderung des Interface und
-- einen allgemeinen Black Screen für die Darstellung verschiedener Effekte.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_0_Core.api.html">(0) Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

QSB.CinematicEvents = {};

CinematicEventStatus = {
    NotTriggered = 0,
    Active = 1,
    Concluded = 2,
}

---
-- Blendet einen schwarzen Hintergrund über der Spielwelt aber hinter dem
-- Interface ein.
--
-- @within Anwenderfunktionen
--
function API.ActivateBlackScreen()
    if not GUI then
        Logic.ExecuteInLuaLocalState("ModuleDisplayCore.Local:InterfaceActivateBlackBackground()");
        return;
    end
    ModuleDisplayCore.Local:InterfaceActivateBlackBackground();
end

---
-- Deaktiviert den schwarzen Hintergrund, wenn er angezeigt wird.
--
-- @within Anwenderfunktionen
--
function API.DeactivateBlackScreen()
    if not GUI then
        Logic.ExecuteInLuaLocalState("ModuleDisplayCore.Local:InterfaceDeactivateBlackBackground()");
        return;
    end
    ModuleDisplayCore.Local:InterfaceDeactivateBlackBackground();
end

---
-- Zeigt das normale Interface an.
--
-- @within Anwenderfunktionen
--
function API.ActivateNormalInterface()
    if not GUI then
        Logic.ExecuteInLuaLocalState("ModuleDisplayCore.Local:InterfaceActivateNormalInterface()");
        return;
    end
    ModuleDisplayCore.Local:InterfaceActivateNormalInterface();
end

---
-- Blendet das normale Interface aus.
--
-- @within Anwenderfunktionen
--
function API.DeactivateNormalInterface()
    if not GUI then
        Logic.ExecuteInLuaLocalState("ModuleDisplayCore.Local:InterfaceDeactivateNormalInterface()");
        return;
    end
    ModuleDisplayCore.Local:InterfaceDeactivateNormalInterface();
end

---
-- Akliviert border Scroll wieder und löst die Fixierung auf ein Entity auf.
--
-- @within Anwenderfunktionen
--
function API.ActivateBorderScroll()
    if not GUI then
        Logic.ExecuteInLuaLocalState("ModuleDisplayCore.Local:InterfaceActivateBorderScroll()");
        return;
    end
    ModuleDisplayCore.Local:InterfaceActivateBorderScroll();
end

---
-- Deaktiviert Randscrollen und setzt die Kamera optional auf das Ziel
--
-- @param[type=number] _Position (Optional) Entity auf das die Kamera schaut
-- @within Anwenderfunktionen
--
function API.DeactivateBorderScroll(_Position)
    local PositionID;
    if _Position then
        PositionID = GetID(_Position);
    end
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleDisplayCore.Local:InterfaceDeactivateBorderScroll(%d)",
            (PositionID or 0)
        ));
        return;
    end
    ModuleDisplayCore.Local:InterfaceDeactivateBorderScroll(PositionID);
end

---
-- Propagiert den Beginn des cinematischen Events und bindet es an den Spieler.
--
-- @param[type=string] Bezeichner
-- @param[type=number] ID des Spielers
-- @within Anwenderfunktionen
--
function API.StartCinematicEvent(_Name, _PlayerID)
    if GUI then
        return;
    end
    local ID = ModuleDisplayCore.Global:ActivateCinematicEvent(_PlayerID);
    QSB.CinematicEvents[_Name] = ID;
end

---
-- Propagiert das Ende des cinematischen Events.
--
-- @param[type=string] Bezeichner
-- @within Anwenderfunktionen
--
function API.FinishCinematicEvent(_Name)
    if GUI then
        return;
    end
    if QSB.CinematicEvents[_Name] then
        ModuleDisplayCore.Global:ConcludeCinematicEvent(QSB.CinematicEvents[_Name]);
    end
end

---
-- Gibt den Status des cinematischen Event zurück.
--
-- @param[type=string] Bezeichner
-- @return[type=number] Event Status
-- @within Anwenderfunktionen
--
function API.GetCinematicEventStatus(_Name)
    if QSB.CinematicEvents[_Name] then
        if GUI then
            return ModuleDisplayCore.Local:GetCinematicEventStatus(QSB.CinematicEvents[_Name]);
        end
        return ModuleDisplayCore.Global:GetCinematicEventStatus(QSB.CinematicEvents[_Name]);
    end
    return CinematicEventStatus.NotTriggered;
end

---
-- Gibt den Spieler zurück, an den das cinematische Event gebunden ist.
--
-- @param[type=string] Bezeichner
-- @return[type=number] ID des Spielers
-- @within Anwenderfunktionen
--
function API.GetCinematicEventPlayerID(_Name)
    if GUI then
        return ModuleDisplayCore.Local:GetCinematicEventPlayerID(QSB.CinematicEvents[_Name]);
    end
    ModuleDisplayCore.Global:GetCinematicEventPlayerID(QSB.CinematicEvents[_Name]);
end

---
-- Prüft ob gerade ein cinematisches Event für den Spieler aktiv ist.
--
-- @param[type=number] ID des Spielers
-- @return[type=boolean] Event aktiv
-- @within Anwenderfunktionen
--
function API.IsCinematicEventActive(_PlayerID)
    for k, v in pairs(QSB.CinematicEvents) do
        if API.GetCinematicEventPlayerID(k) == _PlayerID then
            if API.GetCinematicEventStatus(k) == CinematicEventStatus.Active then
                return true;
            end
        end
    end
    return false;
end

