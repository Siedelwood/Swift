--[[
Swift_1_DisplayCore/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

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
-- Events, auf die reagiert werden kann.
--
-- @field CinematicActivated Der Kinomodus wurde aktiviert (Parameter: KinoEventID, PlayerID)
-- @field CinematicConcluded Der Kinomodus wurde deaktiviert (Parameter: KinoEventID, PlayerID)
-- @field BorderScrollLocked Scrollen am Bildschirmrand wurde gesperrt (Parameter: PlayerID)
-- @field BorderScrollReset Scrollen am Bildschirmrand wurde freigegeben (Parameter: PlayerID)
-- @field GameInterfaceShown Die Spieloberfläche wird angezeigt (Parameter: PlayerID)
-- @field GameInterfaceHidden Die Spieloberfläche wird ausgeblendet (Parameter: PlayerID)
-- @field BlackScreenShown Der schwarze Hintergrund wird angezeigt (Parameter: PlayerID)
-- @field BlackScreenHidden Der schwarze Hintergrund wird ausgeblendet (Parameter: PlayerID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Blendet einen farbigen Hintergrund über der Spielwelt aber hinter dem
-- Interface ein.
--
-- @param[type=number] _Red   (Optional) Rotwert (Standard: 0)
-- @param[type=number] _Green (Optional) Grünwert (Standard: 0)
-- @param[type=number] _Blue  (Optional) Blauwert (Standard: 0)
-- @param[type=number] _Alpha (Optional) Alphawert (Standard: 255)
-- @within Anwenderfunktionen
--
function API.ActivateColoredScreen(_Red, _Green, _Blue, _Alpha)
    -- Just to be compatible with the old version.
    API.ActivateImageScreen("", _Red or 0, _Green or 0, _Blue or 0, _Alpha);
end

---
-- Deaktiviert den farbigen Hintergrund, wenn er angezeigt wird.
--
-- @within Anwenderfunktionen
--
function API.DeactivateColoredScreen()
    -- Just to be compatible with the old version.
    API.DeactivateImageScreen()
end

---
-- Blendet eine Graphic über der Spielwelt aber hinter dem Interface ein.
-- Die Grafik muss im 16:9-Format sein. Bei 4:3-Auflösungen wird
-- links und rechts abgeschnitten.
--
-- @param[type=string] _Image Pfad zur Grafik
-- @param[type=number] _Red   (Optional) Rotwert (Standard: 255)
-- @param[type=number] _Green (Optional) Grünwert (Standard: 255)
-- @param[type=number] _Blue  (Optional) Blauwert (Standard: 255)
-- @param[type=number] _Alpha (Optional) Alphawert (Standard: 255)
-- @within Anwenderfunktionen
--
function API.ActivateImageScreen(_Image, _Red, _Green, _Blue, _Alpha)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[ModuleDisplayCore.Local:InterfaceActivateImageBackground("%s", %d, %d, %d, %d)]],
            _Image,
            (_Red ~= nil and _Red) or 255,
            (_Green ~= nil and _Green) or 255,
            (_Blue ~= nil and _Blue) or 255,
            (_Alpha ~= nil and _Alpha) or 255
        ));
        return;
    end
    ModuleDisplayCore.Local:InterfaceActivateImageBackground(_Image, _Red, _Green, _Blue, _Alpha);
end

---
-- Deaktiviert ein angezeigtes Bild, wenn dieses angezeigt wird.
--
-- @within Anwenderfunktionen
--
function API.DeactivateImageScreen()
    if not GUI then
        Logic.ExecuteInLuaLocalState("ModuleDisplayCore.Local:InterfaceDeactivateImageBackground()");
        return;
    end
    ModuleDisplayCore.Local:InterfaceDeactivateImageBackground();
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
-- Propagiert den Beginn des Kinoevents und bindet es an den Spieler.
--
-- @param[type=string] _Name     Bezeichner
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
--
function API.StartCinematicEvent(_Name, _PlayerID)
    if GUI then
        return;
    end
    QSB.CinematicEvents[_PlayerID] = QSB.CinematicEvents[_PlayerID] or {};
    local ID = ModuleDisplayCore.Global:ActivateCinematicEvent(_PlayerID);
    QSB.CinematicEvents[_PlayerID][_Name] = ID;
end

---
-- Propagiert das Ende des Kinoeventss.
--
-- @param[type=string] _Name Bezeichner
-- @within Anwenderfunktionen
--
function API.FinishCinematicEvent(_Name, _PlayerID)
    if GUI then
        return;
    end
    QSB.CinematicEvents[_PlayerID] = QSB.CinematicEvents[_PlayerID] or {};
    if QSB.CinematicEvents[_PlayerID][_Name] then
        ModuleDisplayCore.Global:ConcludeCinematicEvent(QSB.CinematicEvents[_PlayerID][_Name], _PlayerID);
    end
end

---
-- Gibt den Status des Kinoevents zurück.
--
-- @param _Identifier Bezeichner oder ID
-- @return[type=number] Event Status
-- @within Anwenderfunktionen
--
function API.GetCinematicEventStatus(_Identifier, _PlayerID)
    QSB.CinematicEvents[_PlayerID] = QSB.CinematicEvents[_PlayerID] or {};
    if type(_Identifier) == "number" then
        if GUI then
            return ModuleDisplayCore.Local:GetCinematicEventStatus(_Identifier);
        end
        return ModuleDisplayCore.Global:GetCinematicEventStatus(_Identifier);
    end
    if QSB.CinematicEvents[_PlayerID][_Identifier] then
        if GUI then
            return ModuleDisplayCore.Local:GetCinematicEventStatus(QSB.CinematicEvents[_PlayerID][_Identifier]);
        end
        return ModuleDisplayCore.Global:GetCinematicEventStatus(QSB.CinematicEvents[_PlayerID][_Identifier]);
    end
    return CinematicEventStatus.NotTriggered;
end

---
-- Prüft ob gerade ein Kinoevents für den Spieler aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=boolean] Event aktiv
-- @within Anwenderfunktionen
--
function API.IsCinematicEventActive(_PlayerID)
    QSB.CinematicEvents[_PlayerID] = QSB.CinematicEvents[_PlayerID] or {};
    for k, v in pairs(QSB.CinematicEvents[_PlayerID]) do
        if API.GetCinematicEventStatus(k, _PlayerID) == CinematicEventStatus.Active then
            return true;
        end
    end
    return false;
end

