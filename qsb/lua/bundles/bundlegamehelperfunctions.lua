-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleGameHelperFunctions                                    # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle gibt dem Mapper Werkzeuge in die Hand, um einige Features zu
-- gewähren oder zu entziehen.
--
-- Das wichtigste Auf einen Blick:
-- <ul>
-- <li>
-- <a href="#API.AllowCheats">Features aktivieren</a><br>Cheats, Erweiterter
-- Zoom, Feste feiern für KIs
-- </li>
-- <li>
-- <a href="#API.ForbidCheats">Features deaktivieren</a><br>Cheats, Erweiterter
-- Zoom, Feste feiern für KIs
-- </li>
-- <li>
-- <a href="#API.SpeedLimitActivate">Spielgeschwindigkeit steuern</a><br>
-- Maximale Spielgeschwindigkeit festlegen
-- </li>
-- </ul>
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
-- Fokusiert die Kamera auf dem Primärritter des Spielers.
--
-- <p><b>Alias:</b> SetCameraToPlayerKnight</p>
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
-- <p><b>Alias:</b> SetCameraToEntity</p>
--
-- @param _Entity Entity (Skriptname oder ID)
-- @param[type=number] _Rotation Kamerawinkel
-- @param[type=number] _ZoomFactor Zoomfaktor
-- @within Anwenderfunktionen
--
function API.FocusCameraOnEntity(_Entity, _Rotation, _ZoomFactor)
    if not GUI then
        local Subject = (type(_Entity) ~= "string" and _Entity) or "'" .._Entity.. "'";
        API.Bridge("API.FocusCameraOnEntity(" ..Subject.. ", " .._Rotation.. ", " .._ZoomFactor.. ")")
        return;
    end
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) ~= "string" and _Entity) or "'" .._Entity.. "'";
        API.Warn("API.FocusCameraOnEntity: Entity " ..Subject.. " does not exist!");
        return;
    end
    return BundleGameHelperFunctions.Local:SetCameraToEntity(_Entity, _Rotation, _ZoomFactor);
end
SetCameraToEntity = API.FocusCameraOnEntity;

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
    return BundleGameHelperFunctions.Global:KillCheats();
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
    return BundleGameHelperFunctions.Global:RessurectCheats();
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
        BundleGameHelperFunctions.Local.Data.ForbidSave = ]].. tostring(_Flag) ..[[ == true
        BundleGameHelperFunctions.Local:DisplaySaveButtons(]].. tostring(_Flag) ..[[)
    ]]);
end
ForbidSaveGame = API.ForbidSaveGame;

---
-- Lässt einen Siedler einem Helden folgen. Gibt die ID des Jobs
-- zurück, der die Verfolgung steuert.
--
-- <p><b>Hinweis:</b> Wenn eines der Entities zerstört wird, oder ins
-- Koma fällt, wird der Job beendet!</p>
--
-- <p><b>Alias:</b> AddFollowKnightSave</p>
--
-- @param              _Entity Entity das folgt (skriptname oder ID)
-- @param              _Knight Held (Skriptname oder ID)
-- @param[type=number] _Distance Entfernung, die uberschritten sein muss
-- @param[type=number] _Angle Ausrichtung
-- @return[type=number] Job-ID
-- @within Anwenderfunktionen
--
function API.FollowKnightSaveStart(_Entity, _Knight, _Distance, _Angle)
    if GUI then
        local Target = (type(_Entity) == "string" and "'".._Entity.."'") or _Entity;
        local Knight = (type(_Knight) == "string" and "'".._Knight.."'") or _Knight;
        API.Bridge("API.FollowKnightSaveStart(" ..Target.. ", " ..Knight.. ", " .._Distance.. "," .._Angle.. ")");
        return;
    end
    return BundleGameHelperFunctions.Global:AddFollowKnightSave(_Entity, _Knight, _Distance, _Angle);
end
AddFollowKnightSave = API.FollowKnightSaveStart;

---
-- Beendet einen Verfolgungsjob.
--
-- <p><b>Alias:</b> StopFollowKnightSave</p>
--
-- @param[type=number] _JobID Job-ID
-- @within Anwenderfunktionen
--
function API.FollowKnightSaveStop(_JobID)
    if GUI then
        API.Bridge("API.FollowKnightSaveStop(" .._JobID.. ")");
        return;
    end
    return BundleGameHelperFunctions.Global:StopFollowKnightSave(_JobID)
end

StopFollowKnightSave = API.FollowKnightSaveStop;

---
-- <p>Ändert die Bodentextur innerhalb des Quadrates. Offset bestimmt die
-- Abstände der Eckpunkte zum Zentralpunkt.</p>
--
-- <p><b>Hinweis:</b> Für weitere Informationen zu Terraintexturen siehe
-- https://siedelwood-neu.de/23879-2/</p>
--
-- <p><b>Alias:</b> TerrainType</p>
--
-- @param              _Center Zentralpunkt (Skriptname oder ID)
-- @param[type=number] _Offset Entfernung der Ecken zum Zentrum
-- @param[type=number] _TerrainType Textur ID
-- @within Anwenderfunktionen
--
-- @usage
-- API.ChangeTerrainTypeInSquare("area", 500, 48)
--
function API.ChangeTerrainTypeInSquare(_Center, _Offset, _TerrainType)
    if GUI then
        local Target = (type(_Center) == "string" and "'".._Center.."'") or _Center;
        API.Bridge("API.ChangeTerrainTypeInSquare(" ..Target.. ", " .._Offset.. ", " .._TerrainType.. ")");
        return;
    end
    if not IsExisting(_Center) then
        API.Fatal("API.ChangeTerrainTypeInSquare: Central point does not exist!");
        return;
    end
    if _Offset < 100 then
        API.Warn("API.ChangeTerrainTypeInSquare: Check your offset! It seems to small!");
    end
    return BundleGameHelperFunctions.Global:ChangeTerrainTypeInSquare(_Center, _Offset, _TerrainType);
end
TerrainType = API.ChangeTerrainTypeInSquare;

---
-- Ändert die Wasserhöhe in einem Quadrat. Offset bestimmt die Abstände
-- der Eckpunkte zum Zentrum.
--
-- Wird die relative Höhe verwendet, wird die Wasserhöhe nicht absolut
-- gesetzt sondern von der aktuellen Wasserhöhe ausgegangen.
--
-- <p><b>Alias:</b> WaterHeight</p>
--
-- @param               _Center Zentralpunkt (Skriptname oder ID)
-- @param[type=number]  _Offset Entfernung der Ecken zum Zentrum
-- @param[type=number]  _Height Neue Höhe
-- @param[type=boolean] _Relative Relative Höhe benutzen
-- @within Anwenderfunktionen
--
-- @usage
-- API.ChangeWaterHeightInSquare("area", 500, 5555, true);
--
function API.ChangeWaterHeightInSquare(_Center, _Offset, _Height, _Relative)
    if GUI then
        local Target = (type(_Center) == "string" and "'".._Center.."'") or _Center;
        API.Bridge("API.ChangeWaterHeightInSquare(" ..Target.. ", " .._Offset.. ", " .._Height.. ", " ..tostring(_Relative).. ")");
        return;
    end
    if not IsExisting(_Center) then
        API.Fatal("API.ChangeWaterHeightInSquare: Central point does not exist!");
        return;
    end
    if _Offset < 100 then
        API.Warn("API.ChangeWaterHeightInSquare: Check your offset! It seems to small!");
    end
    return BundleGameHelperFunctions.Global:ChangeWaterHeightInSquare(_Center, _Offset, _Height, _Relative);
end
WaterHeight = API.ChangeWaterHeightInSquare;

---
-- Ändert die Landhöhe in einem Quadrat. Offset bestimmt die Abstände
-- der Eckpunkte zum Zentralpunkt.
--
-- Wird die relative Höhe verwendet, wird die Landhöhe nicht absolut
-- gesetzt sondern von der aktuellen Landhöhe ausgegangen. Das Land muss nicht
-- eben sein. Auf diese Weise können Strukturen unverändert angehoben werden.
--
-- <p><b>Alias:</b> TerrainHeight</p>
--
-- @param               _Center Zentralpunkt (Skriptname oder ID)
-- @param[type=number]  _Offset Entfernung der Ecken zum Zentrum
-- @param[type=number]  _Height Neue Höhe
-- @param[type=boolean] _Relative Relative Höhe benutzen
-- @within Anwenderfunktionen
--
-- @usage
-- API.ChangeTerrainHeightInSquare("area", 500, 5555, true);
--
function API.ChangeTerrainHeightInSquare(_Center, _Offset, _Height, _Relative)
    if GUI then
        local Target = (type(_Center) == "string" and "'".._Center.."'") or _Center;
        API.Bridge("API.ChangeTerrainHeightInSquare(" ..Target.. ", " .._Offset.. ", " .._Height.. ", " ..tostring(_Relative).. ")");
        return;
    end
    if not IsExisting(_Center) then
        API.Fatal("API.ChangeTerrainHeightInSquare: Central point does not exist!");
        return;
    end
    if _Offset < 100 then
        API.Warn("API.ChangeTerrainHeightInSquare: Check your offset! It seems to small!");
    end
    return BundleGameHelperFunctions.Global:ChangeTerrainHeightInSquare(_Center, _Offset, _Height, _Relative);
end
TerrainHeight = API.ChangeTerrainHeightInSquare;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleGameHelperFunctions = {
    Global = {
        Data = {
            HumanPlayerChangedOnce = false,
            HumanKnightType = 0,
            HumanPlayerID = 1,
            FollowKnightSave = {},
        }
    },
    Local = {
        Data = {
            SpeedLimit = 32,
        }
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Global:Install()
    API.AddSaveGameAction(BundleGameHelperFunctions.Global.OnSaveGameLoaded);
end

-- -------------------------------------------------------------------------- --

---
-- Deaktiviert die Tastenkombination zum Einschalten der Cheats.
--
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Global:KillCheats()
    self.Data.CheatsForbidden = true;
    API.Bridge("BundleGameHelperFunctions.Local:KillCheats()");
end

---
-- Aktiviert die Tastenkombination zum Einschalten der Cheats.
--
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Global:RessurectCheats()
    self.Data.CheatsForbidden = false;
    API.Bridge("BundleGameHelperFunctions.Local:RessurectCheats()");
end

-- -------------------------------------------------------------------------- --

---
-- Lässt einen Siedler einem Helden folgen. Gibt die ID des Jobs
-- zurück, der die Verfolgung steuert.
--
-- @param              _Entity Entity das folgt (skriptname oder ID)
-- @param              _Knight Held (Skriptname oder ID)
-- @param[type=number] _Distance Entfernung, die uberschritten sein muss
-- @param[type=number] _Angle Ausrichtung
-- @return[type=number] Job-ID
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Global:AddFollowKnightSave(_Entity, _Knight, _Distance, _Angle)
    local EntityID = GetID(_Entity);
    local KnightID = GetID(_Knight);
    _Angle = _Angle or 0;

    local JobID = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN,
                                         nil,
                                         "ControlFollowKnightSave",
                                         1,
                                         {},
                                         {EntityID, KnightID, _Distance, _Angle});

    table.insert(self.Data.FollowKnightSave, JobID);
    return JobID;
end

---
-- Beendet einen Verfolgungsjob.
--
-- @param[type=number] _JobID Job-ID
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Global:StopFollowKnightSave(_JobID)
    for k,v in pairs(self.Data.FollowKnightSave) do
        if _JobID == v then
            self.Data.FollowKnightSave[k] = nil;
            EndJob(_JobID);
        end
    end
end

---
-- Kontrolliert die Verfolgung eines Helden durch einen Siedler.
--
-- @param              _Entity Entity das folgt (skriptname oder ID)
-- @param              _Knight Held (Skriptname oder ID)
-- @param[type=number] _Distance Entfernung, die uberschritten sein muss
-- @param[type=number] _Angle Ausrichtung
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Global.ControlFollowKnightSave(_EntityID, _KnightID, _Distance, _Angle)
    -- Entity oder Held sind hinüber bzw. haben ihre ID verändert
    if not IsExisting(_KnightID) or not IsExisting(_EntityID) then
        return true;
    end

    -- Wenn Entity ein Held ist, dann nur, wenn Entity nicht komatös ist
    if Logic.IsKnight(_EntityID) and Logic.KnightGetResurrectionProgress(_EntityID) ~= 1 then
        return false;
    end
    -- Wenn Knight ein Held ist, dann nur, wenn Knight nicht komatös ist
    if Logic.IsKnight(_KnightID) and Logic.KnightGetResurrectionProgress(_KnightID) ~= 1 then
        return false;
    end

    if  Logic.IsEntityMoving(_EntityID) == false and Logic.IsFighting(_EntityID) == false
    and IsNear(_EntityID, _KnightID, _Distance+300) == false then
        -- Relative Position hinter Held bestimmen
        local x, y, z = Logic.EntityGetPos(_KnightID);
        local orientation = Logic.GetEntityOrientation(_KnightID)-(180+_Angle);
        local xBehind = x + _Distance * math.cos(math.rad(orientation));
        local yBehind = y + _Distance * math.sin(math.rad(orientation));

        -- Relative Position blockingsicher machen
        local NoBlocking = Logic.CreateEntityOnUnblockedLand(Entities.XD_ScriptEntity, xBehind, yBehind, 0, 0);
        local x, y, z = Logic.EntityGetPos(NoBlocking);
        DestroyEntity(NoBlocking);

        -- Zur neuen unblockierten Position bewegen
        Logic.MoveSettler(_EntityID, x, y);
    end
end
ControlFollowKnightSave = BundleGameHelperFunctions.Global.ControlFollowKnightSave;

-- -------------------------------------------------------------------------- --

---
-- Ändert die Bodentextur innerhalb des Quadrates. Offset bestimmt die
-- Abstände der Eckpunkte zum Zentralpunkt.
-- @param              _Center Zentralpunkt (Skriptname oder ID)
-- @param[type=number] _Offset Entfernung der Ecken zum Zentrum
-- @param[type=number] _TerrainType Textur ID
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Global:ChangeTerrainTypeInSquare(_Center, _Offset, _TerrainType)
    local Xmin, Ymin, Xmax, Ymax, z = self:GetSquareForWaterAndTerrain(_Center, _Offset);
    if Xmin == -1 or Xmin == -2 then
        return Xmin;
    end
    if type(_TerrainType) == "number" then
        for x10 = Xmin, Xmax do
            for y10 = Ymin, Ymax do
                Logic.SetTerrainNodeType( x10, y10, _TerrainType );
            end
        end
    end
    Logic.UpdateBlocking( Xmin, Ymin, Xmax, Ymax);
end

---
-- Ändert die Wasserhöhe in einem Quadrat. Offset bestimmt die Abstände
-- der Eckpunkte zum Zentralpunkt.
-- @param               _Center Zentralpunkt (Skriptname oder ID)
-- @param[type=number]  _Offset Entfernung der Ecken zum Zentrum
-- @param[type=number]  _Height Neue Höhe
-- @param[type=boolean] _Relative Relative Höhe benutzen
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Global:ChangeWaterHeightInSquare(_Center, _Offset, _Height, _Relative)
    local Xmin, Ymin, Xmax, Ymax, z = self:GetSquareForWaterAndTerrain(_Center, _Offset);
    if Xmin == -1 or Xmin == -2 then
        return Xmin;
    end
    if not _Relative then
        if _Height < 0 then
            return -3;
        end
        Logic.WaterSetAbsoluteHeight(Xmin, Ymin, Xmax, Ymax, _Height);
    else
        if z+_Height < 0 then
            return -3;
        end
        Logic.WaterSetAbsoluteHeight(Xmin, Ymin, Xmax, Ymax, z+_Height);
    end
    Logic.UpdateBlocking(Xmin, Ymin, Xmax, Ymax);
    return 0;
end

---
-- Ändert die Landhöhe in einem Quadrat. Offset bestimmt die Abstände
-- der Eckpunkte zum Zentralpunkt.
-- @param               _Center Zentralpunkt (Skriptname oder ID)
-- @param[type=number]  _Offset Entfernung der Ecken zum Zentrum
-- @param[type=number]  _Height Neue Höhe
-- @param[type=boolean] _Relative Relative Höhe benutzen
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Global:ChangeTerrainHeightInSquare(_Center, _Offset, _Height, _Relative)
    local Xmin, Ymin, Xmax, Ymax, z = self:GetSquareForWaterAndTerrain(_Center, _Offset);
    if Xmin == -1 or Xmin == -2 then
        return Xmin;
    end
    local Height;
    if not _Relative then
        if _Height < 0 then
            return -3;
        end
        Height = _Height;
    else
        if z+_Height < 0 then
            return -3;
        end
        Height = z+_Height;
    end

    for x10 = Xmin, Xmax do
        for y10 = Ymin, Ymax do
            Logic.SetTerrainNodeHeight(x10, y10, Height);
        end
    end
    Logic.UpdateBlocking(Xmin, Ymin, Xmax, Ymax);
    return 0;
end

---
-- Gibt ein Quadrat für Land- und Wassermanipulation zurück.
--
-- Wird verwendet von: WaterHeight, TerrainHeight, TerrainType
--
-- @param              _Center Zentralpunkt des Quadrat (Skriptname oder ID)
-- @param[type=number] _Offset Abstand der Ecken zum Zentrum
-- @return[type=number] X-Koordinate von Punkt 1
-- @return[type=number] Y-Koordinate von Punkt 1
-- @return[type=number] X-Koordinate von Punkt 2
-- @return[type=number] Y-Koordinate von Punkt 2
-- @return[type=number] Bodenhöhe
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Global:GetSquareForWaterAndTerrain(_Center, _Offset)
    local Type = type(_Center);
    if (Type ~= "string" and Type ~= "number") or not IsExisting(_Center) then
        return -1;
    end
    local Xmin, Ymin, Xmax, Ymax;
    local eID = GetID(_Center);
    local x,y,z = Logic.EntityGetPos(eID);
    Xmin = math.floor((x - _Offset)/100);
    Ymin = math.floor((y - _Offset)/100);
    Xmax = math.floor((x + _Offset)/100);
    Ymax = math.floor((y + _Offset)/100);
    if IsValidPosition({X= Xmin, Y= Ymin}) == false or IsValidPosition({X= Xmax, Y= Ymax}) == false then
        return -2;
    end
    return Xmin, Ymin, Xmax, Ymax, z;
end

-- -------------------------------------------------------------------------- --

---
-- Stellt nicht-persistente Änderungen nach dem laden wieder her.
--
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Global.OnSaveGameLoaded()
    -- Cheats sperren --
    if BundleGameHelperFunctions.Global.Data.CheatsForbidden == true then
        BundleGameHelperFunctions.Global:KillCheats();
    end
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Local:Install()
    self:InitForbidSpeedUp()
    self:InitForbidSaveGame();
end

---
-- Fokusiert die Kamera auf dem Entity.
--
-- @param _Entity Entity (Skriptname oder ID)
-- @param[type=number] _Rotation Kamerawinkel
-- @param[type=number] _ZoomFactor Zoomfaktor
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Local:SetCameraToEntity(_Entity, _Rotation, _ZoomFactor)
    local pos = GetPosition(_Entity);
    local rotation = (_Rotation or -45);
    local zoomFactor = (_ZoomFactor or 0.5);
    Camera.RTS_SetLookAtPosition(pos.X, pos.Y);
    Camera.RTS_SetRotationAngle(rotation);
    Camera.RTS_SetZoomFactor(zoomFactor);
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

---
-- Deaktiviert die Tastenkombination zum Einschalten der Cheats.
--
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Local:KillCheats()
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
function BundleGameHelperFunctions.Local:RessurectCheats()
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
function BundleGameHelperFunctions.Local:InitForbidSaveGame()
    KeyBindings_SaveGame_Orig_Preferences_SaveGame = KeyBindings_SaveGame;
    KeyBindings_SaveGame = function()
        if BundleGameHelperFunctions.Local.Data.ForbidSave then
            return;
        end
        KeyBindings_SaveGame_Orig_Preferences_SaveGame();
    end
end

---
-- Zeigt oder versteckt die Speicherbuttons im Spielmenü.
--
-- @param[type=boolean] _Flag Speicherbuttons sichtbar
-- @within Internal
-- @local
--
function BundleGameHelperFunctions.Local:DisplaySaveButtons(_Flag)
    XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame",  (_Flag and 0) or 1);
    XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", (_Flag and 0) or 1);
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleGameHelperFunctions");
