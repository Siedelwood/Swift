-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleMinimapMarker                                          # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

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
-- <pre> API.CreateMinimapSignal(1, GetPosition("pos"));</pre>
-- </li>
-- <li>Durch Übergabe einer vordefinierten Farbe oder einer Farbtabelle
-- <pre>
-- API.CreateMinimapSignal(MarkerColor.Red, GetPosition("pos"));
-- API.CreateMinimapSignal({180, 180, 180}, GetPosition("pos"));</pre>
-- </li>
-- </ol>
--
-- Durchsichtige Marker sind nicht vorgesehen!
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleMinimapMarker = {};

API = API or {};
QSB = QSB or {};

---
-- Vordefinierte Farben für Minimap Marker.
-- @field Blue Königsblau
-- @field Red Blutrot
-- @field Yellow Sonnengelb
-- @field Green Blattgrün
--
-- @usage API.CreateMinimapSignal(MarkerColor.Red, GetPosition("pos"));
--
MarkerColor = {
    Blue    = { 17,   7, 216},
    Red     = {216,   7,   7},
    Yellow  = { 25, 185,   8},
    Green   = { 16, 194, 220},
}

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erstellt eine flüchtige Markierung auf der Minimap.
--
-- <b>Hinweis</b>: Die Farbe richtet sich nach der Spielerfarbe!
--
-- <b>Alias</b>: CreateMinimapSignal
--
-- @param _PlayerID PlayerID oder Farbtabelle (Spielernummer oder Farbtabelle)
-- @param _Position Position des Markers (Skriptname, ID oder Position)
-- @return[type=number] ID des Markers
-- @within Anwenderfunktionen
--
-- @usage API.CreateMinimapSignal(1, GetPosition("pos"));
--
function API.CreateMinimapSignal(_PlayerID, _Position)
    if GUI then
        return;
    end

    local Position = _Position;
    if type(_Position) ~= "table" then
        Position = GetPosition(_Position);
    end

    if type(Position) ~= "table" or (not Position.X or not Position.X) then
        log("API.CreateMinimapSignal: Position is invalid!", LEVEL_ERROR);
        return;
    end
    return BundleMinimapMarker.Global:CreateMinimapMarker(_PlayerID, Position.X, Position.Y, 7);
end
CreateMinimapSignal = API.CreateMinimapSignal;

---
-- Erstellt eine statische Markierung auf der Minimap.
--
-- <b>Hinweis</b>: Die Farbe richtet sich nach der Spielerfarbe!
--
-- <b>Alias</b>: CreateMinimapMarker
--
-- @param _PlayerID PlayerID oder Farbtabelle (Spielernummer oder Farbtabelle)
-- @param _Position Position des Markers (Skriptname, ID oder Position)
-- @return[type=number] ID des Markers
-- @within Anwenderfunktionen
--
-- @usage API.CreateMinimapMarker(1, GetPosition("pos"));
--
function API.CreateMinimapMarker(_PlayerID, _Position)
    if GUI then
        return;
    end

    local Position = _Position;
    if type(_Position) ~= "table" then
        Position = GetPosition(_Position);
    end

    if type(Position) ~= "table" or (not Position.X or not Position.X) then
        log("API.CreateMinimapMarker: Position is invalid!", LEVEL_ERROR);
        return;
    end
    return BundleMinimapMarker.Global:CreateMinimapMarker(_PlayerID, Position.X, Position.Y, 6);
end
CreateMinimapMarker = API.CreateMinimapMarker;

---
-- Erstellt eine pulsierende Markierung auf der Minimap.
--
-- <b>Hinweis</b>: Die Farbe richtet sich nach der Spielerfarbe!
--
-- <b>Alias</b>: CreateMinimapPulse
--
-- @param _PlayerID PlayerID oder Farbtabelle (Spielernummer oder Farbtabelle)
-- @param _Position Position des Markers (Skriptname, ID oder Position)
-- @return[type=number] ID des Markers
-- @within Anwenderfunktionen
--
-- @usage API.CreateMinimapPulse(1, GetPosition("pos"));
--
function API.CreateMinimapPulse(_PlayerID, _Position)
    if GUI then
        return;
    end

    local Position = _Position;
    if type(_Position) ~= "table" then
        Position = GetPosition(_Position);
    end
    
    if type(Position) ~= "table" or (not Position.X or not Position.X) then
        log("API.CreateMinimapPulse: Position is invalid!", LEVEL_ERROR);
        return;
    end
    return BundleMinimapMarker.Global:CreateMinimapMarker(_PlayerID, Position.X, Position.Y, 1);
end
CreateMinimapPulse = API.CreateMinimapPulse;

---
-- Zerstört eine Markierung auf der Minimap.
--
-- <b>Alias</b>: DestroyMinimapSignal
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
        log("API.DestroyMinimapSignal: _ID must be a number!", LEVEL_ERROR);
        return;
    end
    BundleMinimapMarker.Global:DestroyMinimapMarker(_ID);
end
DestroyMinimapMarker = API.DestroyMinimapSignal;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleMinimapMarker = {
    Global = {
        Data = {
            MarkerCounter = 1000000,
            CreatedMinimapMarkers = {},
        },
    },
    Local = {
        Data = {},
    }
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function BundleMinimapMarker.Global:Install()
    API.AddSaveGameAction(self.OnSaveGameLoaded);
end

---
-- Erstellt eine neue Markierung auf der Minimap.
-- 
-- @param[type=number] _PlayerID ID des Besitzers
-- @param[type=number] _X X-Koordinate des Markers
-- @param[type=number] _Y Y-Koordinate des Makers
-- @param[type=number] _Type Typ des Markers
-- @return[type=number] ID des Markers
-- @within Internal
-- @local
--
function BundleMinimapMarker.Global:CreateMinimapMarker(_PlayerID, _X, _Y, _Type)
    self.Data.MarkerCounter = self.Data.MarkerCounter +1;
    -- Flüchtige Markierungen werden nicht gespeichert!
    self.Data.CreatedMinimapMarkers[self.Data.MarkerCounter] = {
        _PlayerID, _X, _Y, _Type
    };
    info("BundleMinimapMarker: Create minimap marker " .._ID.. " (X= " .._X.. ", Y= " .._Y.. ", " .._Type.. ")");
    self:ShowMinimapMarker(self.Data.MarkerCounter);
    return self.Data.MarkerCounter;
end

---
-- Zerstort eine Markierung auf der Minimap.
-- 
-- @param[type=number] _ID ID des Markers
-- @within Internal
-- @local
--
function BundleMinimapMarker.Global:DestroyMinimapMarker(_ID)
    self.Data.CreatedMinimapMarkers[_ID] = nil;
    info("BundleMinimapMarker: Destroy minimap marker " .._ID);
    Logic.ExecuteInLuaLocalState([[GUI.DestroyMinimapSignal(]] .._ID.. [[)]]);
end

---
-- Zeigt eine erstellte Markierung auf der Minimap an.
-- 
-- @param[type=number] _ID ID des Markers
-- @within Internal
-- @local
--
function BundleMinimapMarker.Global:ShowMinimapMarker(_ID)
    if not self.Data.CreatedMinimapMarkers[_ID] then
        return;
    end
    local Marker = self.Data.CreatedMinimapMarkers[_ID];

    local ColorOrPlayerID = Marker[1];
    if type(ColorOrPlayerID) == "table" then
        ColorOrPlayerID = API.ConvertTableToString(ColorOrPlayerID);
    end

    info("BundleMinimapMarker: Restoring minimap marker " .._ID);
    Logic.ExecuteInLuaLocalState([[
        BundleMinimapMarker.Local:ShowMinimapMarker(
            ]] .._ID.. [[,]] ..ColorOrPlayerID.. [[,]] ..Marker[2].. [[,]] ..Marker[3].. [[, ]] ..Marker[4].. [[
        )
    ]]);
end

---
-- Stellt Markierungen auf der Minimap wieder her, wenn ein Spielstand
-- geladen wird.
-- 
-- @within Internal
-- @local
--
function BundleMinimapMarker.Global.OnSaveGameLoaded()
    for k, v in pairs(BundleMinimapMarker.Global.Data.CreatedMinimapMarkers) do
        if v and v[4] ~= 7 then
            BundleMinimapMarker.Global:ShowMinimapMarker(k);
        end
    end
end

-- Local Script ------------------------------------------------------------- --

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function BundleMinimapMarker.Local:Install()
end

---
-- Initialisiert das Bundle im globalen Skript.
--
-- @param[type=number] _PlayerID ID des Besitzers
-- @param[type=number] _X X-Koordinate des Markers
-- @param[type=number] _Y Y-Koordinate des Makers
-- @param[type=number] _Type Typ des Markers
-- @return[type=number] ID des Markers
-- @within Internal
-- @local
--
function BundleMinimapMarker.Local:ShowMinimapMarker(_ID, _PlayerID, _X, _Y, _Type)
    local R, G, B;
    if type(_PlayerID) == "number" then
        R, G, B = GUI.GetPlayerColor(_PlayerID);
    else
        R = _PlayerID[1];
        G = _PlayerID[2];
        B = _PlayerID[3];
    end
    GUI.CreateMinimapSignalRGBA(_ID, _X, _Y, R, G, B, 255, _Type);
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleMinimapMarker");

