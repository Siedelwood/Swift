--[[
Swift_4_Minimap/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglocht das Anlegen von Markierungen auf der Minimap.
--
-- Mögliche Typen von Markierungen:
-- <ul>
-- <li>Signal: Eine flüchtige Markierung, die nach wenigen Sekunden wieder
-- verschwindet.</li>
-- <li>Marker: Eine statische Markierung, die dauerhaft verbleibt.</li>
-- <li>Pulse: Eine pulsierende Markierung, die dauerhaft verbleibt.</li>
-- </ul>
--
-- Die Farbe eines Markers kann auf 2 verschiedene Weisen bestimmt werden.
-- <ol>
-- <li>Durch die Spielerfarbe des "Besitzers" der Markierung.
-- <pre> API.CreateMinimapSignal(1, 1, GetPosition("pos"));</pre>
-- </li>
-- <li>Durch Übergabe einer vordefinierten Farbe oder einer Farbtabelle
-- <pre>
-- API.CreateMinimapSignal(MarkerColor.Red, GetPosition("pos"));
-- API.CreateMinimapSignal(1, {180, 180, 180, 255}, GetPosition("pos"));</pre>
-- </li>
-- </ol>
--
-- Halbtransparente Marker sind nicht vorgesehen!
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_InterfaceCore.api.html">(1) Interface Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Vordefinierte Farben für Minimap Marker.
-- @field Blue Königsblau
-- @field Red Blutrot
-- @field Yellow Sonnengelb
-- @field Green Blattgrün
--
-- @usage API.CreateMinimapSignal(1, MarkerColor.Red, GetPosition("pos"));
--
MarkerColor = {
    Blue    = { 17,   7, 216},
    Red     = {216,   7,   7},
    Yellow  = { 25, 185,   8},
    Green   = { 16, 194, 220},
}

---
-- Erstellt eine flüchtige Markierung auf der Minimap.
--
-- <b>Hinweis</b>: Die Farbe richtet sich nach der Spielerfarbe!
--
-- @param[type=number] _PlayerID             Anzeige für Spieler
-- @param              _PlayerIDOrColorTable PlayerID oder Farbtabelle (Spielernummer oder Farbtabelle)
-- @param              _Position             Position des Markers (Skriptname, ID oder Position)
-- @return[type=number] ID des Markers
-- @within Anwenderfunktionen
--
-- @usage API.CreateMinimapSignal(1, 1, GetPosition("pos"));
--
function API.CreateMinimapSignal(_PlayerID, _PlayerIDOrColorTable, _Position)
    if GUI then
        return;
    end

    local Position = _Position;
    if type(_Position) ~= "table" then
        Position = GetPosition(_Position);
    end
    if type(Position) ~= "table" or (not Position.X or not Position.X) then
        error("API.CreateMinimapSignal: Position is invalid!");
        return;
    end
    return ModuleMinimap.Global:CreateMinimapMarker(_PlayerID, _PlayerIDOrColorTable, Position.X, Position.Y, 7);
end
CreateMinimapSignal = API.CreateMinimapSignal;

---
-- Erstellt eine statische Markierung auf der Minimap.
--
-- <b>Hinweis</b>: Die Farbe richtet sich nach der Spielerfarbe!
--
-- @param[type=number] _PlayerID             Anzeige für Spieler
-- @param              _PlayerIDOrColorTable PlayerID oder Farbtabelle (Spielernummer oder Farbtabelle)
-- @param              _Position             Position des Markers (Skriptname, ID oder Position)
-- @return[type=number] ID des Markers
-- @within Anwenderfunktionen
--
-- @usage API.CreateMinimapMarker(1, 1, GetPosition("pos"));
--
function API.CreateMinimapMarker(_PlayerID, _PlayerIDOrColorTable, _Position)
    -- API.CreateMinimapMarker(1, 2, Logic.GetMarketplace(1))
    if GUI then
        return;
    end

    local Position = _Position;
    if type(_Position) ~= "table" then
        Position = GetPosition(_Position);
    end
    if type(Position) ~= "table" or (not Position.X or not Position.X) then
        error("API.CreateMinimapMarker: Position is invalid!");
        return;
    end
    return ModuleMinimap.Global:CreateMinimapMarker(_PlayerID, _PlayerIDOrColorTable, Position.X, Position.Y, 6);
end
CreateMinimapMarker = API.CreateMinimapMarker;

---
-- Erstellt eine pulsierende Markierung auf der Minimap.
--
-- <b>Hinweis</b>: Die Farbe richtet sich nach der Spielerfarbe!
--
-- @param[type=number] _PlayerID             Anzeige für Spieler
-- @param              _PlayerIDOrColorTable PlayerID oder Farbtabelle (Spielernummer oder Farbtabelle)
-- @param              _Position             Position des Markers (Skriptname, ID oder Position)
-- @return[type=number] ID des Markers
-- @within Anwenderfunktionen
--
-- @usage API.CreateMinimapPulse(1, 1, GetPosition("pos"));
--
function API.CreateMinimapPulse(_PlayerID, _PlayerIDOrColorTable, _Position)
    if GUI then
        return;
    end

    local Position = _Position;
    if type(_Position) ~= "table" then
        Position = GetPosition(_Position);
    end
    if type(Position) ~= "table" or (not Position.X or not Position.X) then
        error("API.CreateMinimapPulse: Position is invalid!");
        return;
    end
    return ModuleMinimap.Global:CreateMinimapMarker(_PlayerID, _PlayerIDOrColorTable, Position.X, Position.Y, 1);
end
CreateMinimapPulse = API.CreateMinimapPulse;

---
-- Zerstört eine Markierung auf der Minimap.
--
-- @param[type=number] _ID ID des Markers
-- @within Anwenderfunktionen
--
-- @usage API.DestroyMinimapSignal(SomeMarkerID);
--
function API.DestroyMinimapSignal(_ID)
    if GUI then
        return;
    end
    if type(_ID) ~= "number" then
        error("API.DestroyMinimapSignal: _ID must be a number!");
        return;
    end
    ModuleMinimap.Global:DestroyMinimapMarker(_ID);
end
DestroyMinimapMarker = API.DestroyMinimapSignal;

