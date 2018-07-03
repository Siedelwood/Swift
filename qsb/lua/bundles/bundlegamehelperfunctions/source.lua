-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleGameHelperFunctions                                    # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle gibt dem Mapper Werkzeuge in die Hand, um einige Features zu
-- gewähren oder zu entziehen.
--
--
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Entfernt ein Territorium für den angegebenen Spieler aus der Liste
-- der entdeckten Territorien.
--
-- <b>Alias:</b> UndiscoverTerritory
--
-- @param _PlayerID    Spieler-ID
-- @param _TerritoryID Territorium-ID
-- @within Public
--
function API.UndiscoverTerritory(_PlayerID, _TerritoryID)
    if GUI then
        API.Bridge("API.UndiscoverTerritory(" .._PlayerID.. ", ".._TerritoryID.. ")")
        return;
    end
    return BundleGameHelperFunctions.Global:UndiscoverTerritory(_PlayerID, _TerritoryID);
end
UndiscoverTerritory = API.UndiscoverTerritory;

---
-- Entfernt alle Territorien einer Partei aus der Liste der entdeckten
-- Territorien. Als Nebeneffekt gild die Partei als unentdeckt.
--
-- <b>Alias:</b> UndiscoverTerritories
--
-- @param _PlayerID       Spieler-ID
-- @param _TargetPlayerID Zielpartei
-- @within Public
--
function API.UndiscoverTerritories(_PlayerID, _TargetPlayerID)
    if GUI then
        API.Bridge("API.UndiscoverTerritories(" .._PlayerID.. ", ".._TargetPlayerID.. ")")
        return;
    end
    return BundleGameHelperFunctions.Global:UndiscoverTerritories(_PlayerID, _TargetPlayerID);
end
UndiscoverTerritories = API.UndiscoverTerritories;

---
-- Setzt die Einnahmen für alle Stadtgebäude eines Spielers. Stadtgebäude
-- können nur Einnahmen zwischen 0 und 100 Talern haben.
--
-- <b>Alias:</b> SetPlayerEarnings
--
-- @param _PlayerID Partei oder nil für alle
-- @param _Earnings Einnahmen [0 | 100]
-- @within Public
--
function API.SetEarningsOfPlayerCity(_PlayerID, _Earnings)
    if GUI then
        API.Bridge("API.SetEarningsOfPlayerCity(" .._PlayerID.. ", " .._Earnings.. ")");
        return;
    end
    if _PlayerID ~= -1 and Logic.GetStoreHouse(_PlayerID) == 0 then
        API.Dbg("API.SetEarningsOfPlayerCity: Player " .._PlayerID.. " is dead! :(");
        return;
    end
    if _Earnings == nil or (_Earnings < 0 or _Earnings > 100) then
        API.Dbg("API.SetEarningsOfPlayerCity: _Earnings must be between 0 and 100!");
        return;
    end
    return BundleGameHelperFunctions.Global:SetEarningsOfPlayerCity(_PlayerID, _Earnings);
end
SetPlayerEarnings = API.SetEarningsOfPlayerCity;

---
-- Setzt den Befriedigungsstatus eines Bedürfnisses für alle Gebäude
-- des angegebenen Spielers. Der Befriedigungsstatus ist eine Zahl
-- zwischen 0.0 und 1.0.
--
-- <b>Alias:</b> SetNeedSatisfactionLevel
--
-- @param _Need     Bedürfnis
-- @param _State    Erfüllung des Bedürfnisses
-- @param _PlayerID Partei oder -1 für alle
-- @within Public
--
function API.SetNeedSatisfaction(_Need, _State, _PlayerID)
    if GUI then
        API.Bridge("API.SetNeedSatisfaction(" .._Need.. ", " .._State.. ", " .._PlayerID.. ")")
        return;
    end
    if _PlayerID ~= -1 and Logic.GetStoreHouse(_PlayerID) == 0 then
        API.Dbg("API.SetNeedSatisfaction: Player " .._PlayerID.. " is dead! :(");
        return;
    end
    if _State < 0 or _State > 1 then
        API.Dbg("API.SetNeedSatisfaction: _State must be between 0 and 1!");
        return;
    end
    return BundleGameHelperFunctions.Global:SetNeedSatisfactionLevel(_Need, _State, _PlayerID);
end
SetNeedSatisfactionLevel = API.SetNeedSatisfaction;

---
-- Diese Funktion ermöglicht das sichere Entsperren eines gesperrten Titels.
--
-- <b>Alias:</b> UnlockTitleForPlayer
--
-- @param _PlayerID    Zielpartei
-- @param _KnightTitle Titel zum Entsperren
-- @within Public
--
function API.UnlockTitleForPlayer(_PlayerID, _KnightTitle)
    if GUI then
        API.Bridge("API.UnlockTitleForPlayer(" .._PlayerID.. ", " .._KnightTitle.. ")")
        return;
    end
    return BundleGameHelperFunctions.Global:UnlockTitleForPlayer(_PlayerID, _KnightTitle);
end
UnlockTitleForPlayer = API.UnlockTitleForPlayer;

---
-- Fokusiert die Kamera auf dem Primärritter des Spielers.
--
-- <b>Alias:</b> SetCameraToPlayerKnight
--
-- @param _Player     Partei
-- @param _Rotation   Kamerawinkel
-- @param _ZoomFactor Zoomfaktor
-- @within Public
--
function API.FocusCameraOnKnight(_Player, _Rotation, _ZoomFactor)
    if not GUI then
        API.Bridge("API.SetCameraToPlayerKnight(" .._Player.. ", " .._Rotation.. ", " .._ZoomFactor.. ")")
        return;
    end
    return BundleGameHelperFunctions.Local:SetCameraToPlayerKnight(_Player, _Rotation, _ZoomFactor);
end
SetCameraToPlayerKnight = API.FocusCameraOnKnight;

---
-- Fokusiert die Kamera auf dem Entity.
--
-- <b>Alias:</b> SetCameraToEntity
--
-- @param _Entity     Entity
-- @param _Rotation   Kamerawinkel
-- @param _ZoomFactor Zoomfaktor
-- @within Public
--
function API.FocusCameraOnEntity(_Entity, _Rotation, _ZoomFactor)
    if not GUI then
        local Subject = (type(_Entity) ~= "string" and _Entity) or "'" .._Entity.. "'";
        API.Bridge("API.FocusCameraOnEntity(" ..Subject.. ", " .._Rotation.. ", " .._ZoomFactor.. ")")
        return;
    end
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) ~= "string" and _Entity) or "'" .._Entity.. "'";
        API.Dbg("API.FocusCameraOnEntity: Entity " ..Subject.. " does not exist!");
        return;
    end
    return BundleGameHelperFunctions.Local:SetCameraToEntity(_Entity, _Rotation, _ZoomFactor);
end
SetCameraToEntity = API.FocusCameraOnEntity;

---
-- Setzt die Obergrenze für die Spielgeschwindigkeit fest.
--
-- <b>Alias:</b> SetSpeedLimit
--
-- @param _Limit Obergrenze
-- @within Public
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
-- <b>Alias:</b> ActivateSpeedLimit
--
-- @param _Flag Speedbremse ist aktiv
-- @within Public
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
-- <b>Alias:</b> KillCheats
--
-- @within Public
--
function API.KillCheats()
    if GUI then
        API.Bridge("API.KillCheats()");
        return;
    end
    return BundleGameHelperFunctions.Global:KillCheats();
end
KillCheats = API.KillCheats;

---
-- Aktiviert die Tastenkombination zum Einschalten der Cheats.
--
-- <b>Alias:</b> RessurectCheats
--
-- @within Public
--
function API.RessurectCheats()
    if GUI then
        API.Bridge("API.RessurectCheats()");
        return;
    end
    return BundleGameHelperFunctions.Global:RessurectCheats();
end
RessurectCheats = API.RessurectCheats;

---
-- Sperrt das Speichern von Spielständen oder gibt es wieder frei.
--
-- <b>Alias:</b> ForbidSaveGame
--
-- @param _Flag Speichern gesperrt
-- @within Public
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
-- Aktiviert den Hotkey zum Wechsel zwischen normalen und erweiterten Zoom.
--
-- <b>Alias:</b> ActivateExtendedZoom
--
-- @param _Flag Erweiterter Zoom gestattet
-- @within Public
--
function API.AllowExtendedZoom(_Flag)
    if GUI then
        API.Bridge("API.AllowExtendedZoom(".. tostring(_Flag) ..")");
        return;
    end
    BundleGameHelperFunctions.Global.Data.ExtendedZoomAllowed = _Flag == true;
    if _Flag == false then
        BundleGameHelperFunctions.Global:DeactivateExtendedZoom();
    end
end
AllowExtendedZoom = API.AllowExtendedZoom;

---
-- Startet ein Fest für den Spieler. Ist dieser Typ von Fest für
-- den Spieler verboten, wird er automatisch erlaubt.
--
-- <b>Alias:</b> StartNormalFestival
--
-- @param  _PlayerID Spieler
-- @within Public
--
function API.StartNormalFestival(_PlayerID)
    if GUI then
        API.Bridge("API.StartNormalFestival(".. _PlayerID ..")");
        return;
    end
    BundleGameHelperFunctions.Global:RestrictFestivalForPlayer(_PlayerID, 0, false);
    Logic.StartFestival(_PlayerID, 0);
end
StartNormalFestival = API.StartNormalFestival;

---
-- Startet ein Beförderungsfest für den Spieler. Ist dieser Typ
-- von Fest für den Spieler verboten, wird er automatisch erlaubt.
--
-- <b>Alias:</b> StartCityUpgradeFestival
--
-- @param _PlayerID Spieler
-- @within Public
--
function API.StartCityUpgradeFestival(_PlayerID)
    if GUI then
        API.Bridge("API.StartCityUpgradeFestival(".. _PlayerID ..")");
        return;
    end
    BundleGameHelperFunctions.Global:RestrictFestivalForPlayer(_PlayerID, 1, false);
    Logic.StartFestival(_PlayerID, 1);
end
StartCityUpgradeFestival = API.StartCityUpgradeFestival;

---
-- Verbietet ein normales Fest und sperrt die Technologie.
--
-- <b>Alias:</b> ForbidFestival
--
-- @param _PlayerID Spieler
-- @within Public
--
function API.ForbidFestival(_PlayerID)
    if GUI then
        API.Bridge("API.ForbidFestival(".. _PlayerID ..")");
        return;
    end

    local KnightTitle = Logic.GetKnightTitle(_PlayerID)
    local Technology = Technologies.R_Festival;
    local State = TechnologyStates.Locked;
    if KnightTitleNeededForTechnology[Technology] == nil or KnightTitle >= KnightTitleNeededForTechnology[Technology] then
        State = TechnologyStates.Prohibited;
    end
    Logic.TechnologySetState(_PlayerID, Technology, State);
    BundleGameHelperFunctions.Global:RestrictFestivalForPlayer(_PlayerID, 0, true);
    API.Bridge("BundleGameHelperFunctions.Local.Data.NormalFestivalLockedForPlayer[" .._PlayerID.. "] = true");
end
ForbidFestival = API.ForbidFestival;

---
-- Erlaubt ein normales Fest und gibt die Technologie frei.
--
-- <b>Alias:</b> AllowFestival
--
-- @param _PlayerID Spieler
-- @within Public
--
function API.AllowFestival(_PlayerID)
    if GUI then
        API.Bridge("API.AllowFestival(".. _PlayerID ..")");
        return;
    end

    BundleGameHelperFunctions.Global:RestrictFestivalForPlayer(_PlayerID, 0, false);
    local KnightTitle = Logic.GetKnightTitle(_PlayerID)
    local Technology = Technologies.R_Festival;
    local State = TechnologyStates.Unlocked;
    if KnightTitleNeededForTechnology[Technology] == nil or KnightTitle >= KnightTitleNeededForTechnology[Technology] then
        State = TechnologyStates.Researched;
    end
    Logic.TechnologySetState(_PlayerID, Technology, State);
    API.Bridge("BundleGameHelperFunctions.Local.Data.NormalFestivalLockedForPlayer[" .._PlayerID.. "] = false");
end
AllowFestival = API.AllowFestival;

---
-- Wechselt die Spieler ID des menschlichen Spielers. Die neue ID muss
-- einen Primärritter haben. Diese Funktion kann nicht im Multiplayer
-- Mode verwendet werden.
--
-- <b>Alias:</b> PlayerSetPlayerID
--
-- @param _OldID        Alte ID des menschlichen Spielers
-- @param _NewID        Neue ID des menschlichen Spielers
-- @param _NewName      Name in der Statistik
-- @param _RetainKnight Ritter mitnehmen
-- @within Public
--
function API.SetControllingPlayer(_OldID, _NewID, _NewName, _RetainKnight)
    if GUI then
        API.Bridge("API.SetControllingPlayer(".. _OldID ..", ".. _NewID ..", '".. _NewName .."', ".. tostring(_RetainKnight) ..")");
        return;
    end
    return BundleGameHelperFunctions.Global:SetControllingPlayer(_OldID, _NewID, _NewName, _RetainKnight);
end
PlayerSetPlayerID = API.SetControllingPlayer;

---
-- Gibt die ID des kontrollierenden Spielers zurück. Der erste als menschlich
-- definierte Spieler wird als kontrollierender Spieler angenommen.
--
-- <b>Alias:</b> PlayerGetPlayerID
--
-- @return number: PlayerID
-- @within Public
--
function API.GetControllingPlayer()
    if not GUI then
        return BundleGameHelperFunctions.Global:GetControllingPlayer();
    else
        return GUI.GetPlayerID();
    end
end
PlayerGetPlayerID = API.GetControllingPlayer;

---
-- Aktiviert die Heldenkamera und setzt den verfolgten Helden. Der
-- Held kann 0 sein, dann wird entweder der letzte Held verwendet
-- oder über den GUI-Spieler ermittelt.
--
-- <b>Alias:</b> HeroCameraActivate
--
-- @param _Hero    Skriptname/Entity-ID des Helden
-- @param _MaxZoom Maximaler Zoomfaktor
-- @within Public
--
function API.ThridPersonActivate(_Hero, _MaxZoom)
    if GUI then
        local Target = (type(_Hero) == "string" and "'".._Hero.."'") or _Hero;
        API.Bridge("API.ThridPersonActivate(".. Target ..", ".. _MaxZoom ..")");
        return;
    end
    return BundleGameHelperFunctions.Global:ThridPersonActivate(_Hero, _MaxZoom);
end
HeroCameraActivate = API.ThridPersonActivate;

---
-- Deaktiviert die Heldenkamera.
--
-- <b>Alias:</b> HeroCameraDeactivate
--
-- @within Public
--
function API.ThridPersonDeactivate()
    if GUI then
        API.Bridge("API.ThridPersonDeactivate()");
        return;
    end
    return BundleGameHelperFunctions.Global:ThridPersonDeactivate();
end
HeroCameraDeactivate = API.ThridPersonDeactivate;

---
-- Prüft, ob die Heldenkamera aktiv ist.
--
-- <b>Alias:</b> HeroCameraIsRuning
--
-- @return boolean: Kamera aktiv
-- @within Public
--
function API.ThridPersonIsRuning()
    if not GUI then
        return BundleGameHelperFunctions.Global:ThridPersonIsRuning();
    else
        return BundleGameHelperFunctions.Local:ThridPersonIsRuning();
    end
end
HeroCameraIsRuning = API.ThridPersonIsRuning;

---
-- Lässt einen Siedler einem Helden folgen. Gibt die ID des Jobs
-- zurück, der die Verfolgung steuert.
--
-- <b>Alias:</b> AddFollowKnightSave
--
-- @param _Entity   Entity das folgt
-- @param _Knight   Held
-- @param _Distance Entfernung, die uberschritten sein muss
-- @param _Angle    Ausrichtung
-- @return number: Job-ID
-- @within Public
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
-- <b>Alias:</b> StopFollowKnightSave
--
-- @param _JobID Job-ID
-- @within Public
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
-- Ändert die Bodentextur innerhalb des Quadrates. Offset bestimmt die
-- Abstände der Eckpunkte zum Zentralpunkt.
--
-- <b>Hinweis:</b> Für weitere Informationen zu Terraintexturen siehe
-- https://siedelwood-neu.de/23879-2/
--
-- <b>Alias:</b> TerrainType
--
-- @param _Center          Zentralpunkt
-- @param _Offset          Entfernung der Ecken zum Zentrum
-- @param _TerrainType     Textur ID
-- @within Public
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
        API.Dbg("API.ChangeTerrainTypeInSquare: Central point does not exist!");
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
-- <b>Alias:</b> WaterHeight
--
-- @param _Center      Zentralpunkt
-- @param _Offset      Entfernung der Ecken zum Zentrum
-- @param _Hight       Neue Höhe
-- @param _Relative    Relative Höhe benutzen
-- @within Public
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
        API.Dbg("API.ChangeWaterHeightInSquare: Central point does not exist!");
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
-- <b>Alias:</b> TerrainHeight
--
-- @param _Center      Zentralpunkt
-- @param _Offset      Entfernung der Ecken zum Zentrum
-- @param _Hight       Neue Höhe
-- @param _Relative    Relative Höhe benutzen
-- @within Public
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
        API.Dbg("API.ChangeTerrainHeightInSquare: Central point does not exist!");
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
            ExtendedZoomAllowed = true,
            FestivalBlacklist = {},
            FollowKnightSave = {},
        }
    },
    Local = {
        Data = {
            NormalFestivalLockedForPlayer = {},
            SpeedLimit = 32,
            ThirdPersonIsActive = false,
            ThirdPersonLastHero = nil,
            ThirdPersonLastZoom = nil,
        }
    },
    Shared = {
        TimeLine = {
            Data = {
                TimeLineUniqueJobID = 1,
                TimeLineJobs = {},
            }
        }
    }
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:Install()
    self:InitExtendedZoom();
    API.AddSaveGameAction(BundleGameHelperFunctions.Global.OnSaveGameLoaded);

    QSB.TimeLine = BundleGameHelperFunctions.Shared.TimeLine;
    TimeLine = QSB.TimeLine;
end

---
-- Entfernt ein Territorium für den angegebenen Spieler aus der Liste
-- der entdeckten Territorien.
--
-- @param _PlayerID    Spieler-ID
-- @param _TerritoryID Territorium-ID
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:UndiscoverTerritory(_PlayerID, _TerritoryID)
    if DiscoveredTerritories[_PlayerID] == nil then
        DiscoveredTerritories[_PlayerID] = {};
    end
    for i=1, #DiscoveredTerritories[_PlayerID], 1 do
        if DiscoveredTerritories[_PlayerID][i] == _TerritoryID then
            table.remove(DiscoveredTerritories[_PlayerID], i);
            break;
        end
    end
end

---
-- Entfernt alle Territorien einer Partei aus der Liste der entdeckten
-- Territorien. Als Nebeneffekt gild die Partei als unentdeckt-
--
-- @param _PlayerID       Spieler-ID
-- @param _TargetPlayerID Zielpartei
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:UndiscoverTerritories(_PlayerID, _TargetPlayerID)
    if DiscoveredTerritories[_PlayerID] == nil then
        DiscoveredTerritories[_PlayerID] = {};
    end
    local Discovered = {};
    for k, v in pairs(DiscoveredTerritories[_PlayerID]) do
        local OwnerPlayerID = Logic.GetTerritoryPlayerID(v);
        if OwnerPlayerID ~= _TargetPlayerID then
            table.insert(Discovered, v);
            break;
        end
    end
    DiscoveredTerritories[_PlayerID][i] = Discovered;
end

---
-- Setzt die Einnahmen für alle Stadtgebäude eines Spielers. Stadtgebäude
-- können nur Einnahmen zwischen 0 und 100 Talern haben.
--
-- <b>Alias:</b> SetPlayerEarnings
--
-- @param _PlayerID Partei oder nil für alle
-- @param _Earnings Einnahmen [0 | 100]
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:SetEarningsOfPlayerCity(_PlayerID, _Earnings)
    if _PlayerID == -1 then
        for i=1, 8, 1 do
            self:SetEarningsOfPlayerCity(i, _Earnings);
        end
    else
        local City = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.CityBuilding)};
        for i=1, #City, 1 do
            Logic.SetBuildingEarnings(City[i], _Earnings);
        end
    end
end

---
-- Setzt den Befriedigungsstatus eines Bedürfnisses für alle Gebäude
-- des angegebenen Spielers. Der Befriedigungsstatus ist eine Zahl
-- zwischen 0.0 und 1.0.
--
-- @param _Need     Bedürfnis
-- @param _State    Erfüllung des Bedürfnisses
-- @param _PlayerID Partei oder -1 für alle
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:SetNeedSatisfactionLevel(_Need, _State, _PlayerID)
    if _PlayerID == -1 then
        for i=1, 8, 1 do
            self:SetNeedSatisfactionLevel(_Need, _State, i);
        end
    else
        local City = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.CityBuilding)};
        if _Need == Needs.Nutrition or _Need == Needs.Medicine then
            local Rim = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.OuterRimBuilding)};
            City = Array_Append(City, Rim);
        end
        for j=1, #City, 1 do
            if Logic.IsNeedActive(City[j], _Need) then
                Logic.SetNeedState(City[j], _Need, _State);
            end
        end
    end
end

---
-- Entsperrt einen gesperrten Titel für den Spieler.
--
-- @param _PlayerID    Zielpartei
-- @param _KnightTitle Titel zum Entsperren
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:UnlockTitleForPlayer(_PlayerID, _KnightTitle)
    if LockedKnightTitles[_PlayerID] == _KnightTitle
    then
        LockedKnightTitles[_PlayerID] = nil;
        for KnightTitle= _KnightTitle, #NeedsAndRightsByKnightTitle
        do
            local TechnologyTable = NeedsAndRightsByKnightTitle[KnightTitle][4];
            if TechnologyTable ~= nil
            then
                for i=1, #TechnologyTable
                do
                    local TechnologyType = TechnologyTable[i];
                    Logic.TechnologySetState(_PlayerID, TechnologyType, TechnologyStates.Unlocked);
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

---
-- Wechselt die Spieler ID des menschlichen Spielers. Die neue ID muss
-- einen Primärritter haben. Diese Funktion kann nicht im Multiplayer
-- Mode verwendet werden.
--
-- @param _oldPlayerID          Alte ID des menschlichen Spielers
-- @param _newPlayerID          Neue ID des menschlichen Spielers
-- @param _newNameForStatistics Name in der Statistik
-- @param _retainPrimaryKnight  Ritter mitnehmen
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:SetControllingPlayer(_oldPlayerID, _newPlayerID, _newNameForStatistics, _retainPrimaryKnight)
    assert(type(_oldPlayerID) == "number");
    assert(type(_newPlayerID) == "number");
    _newNameForStatistics = _newNameForStatistics or "";
    _retainPrimaryKnight = (_retainPrimaryKnight and true) or false;

    local eID,eName,eType;
    if _retainPrimaryKnight then
        eID   = Logic.GetKnightID(_oldPlayerID);
        eName = Logic.GetEntityName(eID);
        eType = Logic.GetEntityType(eID);
        Logic.ChangeEntityPlayerID(eID,_newPlayerID);
        Logic.SetPrimaryKnightID(_newPlayerID,GetID(eName));
    else
        eID   = Logic.GetKnightID(_newPlayerID);
        eName = Logic.GetEntityName(eID);
        eType = Logic.GetEntityType(eID);
    end

    Logic.PlayerSetIsHumanFlag(_oldPlayerID, 0);
    Logic.PlayerSetIsHumanFlag(_newPlayerID, 1);
    Logic.PlayerSetGameStateToPlaying(_newPlayerID);

    self.Data.HumanKnightType = eType;
    self.Data.HumanPlayerID = _newPlayerID;

    GameCallback_PlayerLost = function( _PlayerID )
        if _PlayerID == self:GetControllingPlayer() then
            QuestTemplate:TerminateEventsAndStuff()
            if MissionCallback_Player1Lost then
                MissionCallback_Player1Lost()
            end
        end
    end

    Logic.ExecuteInLuaLocalState([[
        GUI.ClearSelection()
        GUI.SetControlledPlayer(]].._newPlayerID..[[)

        for k,v in pairs(Buffs)do
            GUI_Buffs.UpdateBuffsInInterface(]].._newPlayerID..[[,v)
            GUI.ResetMiniMap()
        end

        if IsExisting(Logic.GetKnightID(GUI.GetPlayerID())) then
            local portrait = GetKnightActor(]]..eType..[[)
            g_PlayerPortrait[GUI.GetPlayerID()] = portrait
            LocalSetKnightPicture()
        end

        local newName = "]].._newNameForStatistics..[["
        if newName ~= "" then
            GUI_MissionStatistic.PlayerNames[GUI.GetPlayerID()] = newName
        end
        HideOtherMenus()

        function GUI_Knight.GetTitleNameByTitleID(_KnightType, _TitleIndex)
            local KeyName = "Title_" .. GetNameOfKeyInTable(KnightTitles, _TitleIndex) .. "_" .. KnightGender[]]..eType..[[]
            local String = XGUIEng.GetStringTableText("UI_ObjectNames/" .. KeyName)
            if String == nil or String == "" then
                String = "Knight not in Gender Table? (localscript.lua)"
            end
            return String
        end
    ]]);

    self.Data.HumanPlayerChangedOnce = true;
end

---
-- Gibt die ID des kontrollierenden Spielers zurück. Der erste als menschlich
-- definierte Spieler wird als kontrollierender Spieler angenommen.
--
-- @return number: PlayerID
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:GetControllingPlayer()
    local pID = 1;
    for i=1,8 do
        if Logic.PlayerGetIsHumanFlag(i) == true then
            pID = i;
            break;
        end
    end
    return pID;
end

-- -------------------------------------------------------------------------- --

---
-- Überschreibt Logic.StartFestival, sodass das Feierverhalten der KI gesteuert
-- werden kann.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:InitFestival()
    if not Logic.StartFestival_Orig_NothingToCelebrate then
        Logic.StartFestival_Orig_NothingToCelebrate = Logic.StartFestival;
    end

    Logic.StartFestival = function(_PlayerID, _Index)
        if BundleGameHelperFunctions.Global.Data.FestivalBlacklist[_PlayerID] then
            if BundleGameHelperFunctions.Global.Data.FestivalBlacklist[_PlayerID][_Index] then
                return;
            end
        end
        Logic.StartFestival_Orig_NothingToCelebrate(_PlayerID, _Index);
    end
end

---
-- Erlaubt oder verbietet ein Fest für den angegebenen Spieler.
--
-- @param _PlayerID ID des Spielers
-- @param _Index    Index des Fest
-- @param _Flag     Erlauben/verbieten
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:RestrictFestivalForPlayer(_PlayerID, _Index, _Flag)
    self:InitFestival();

    if not self.Data.FestivalBlacklist[_PlayerID]
    then
        self.Data.FestivalBlacklist[_PlayerID] = {};
    end
    self.Data.FestivalBlacklist[_PlayerID][_Index] = _Flag == true;
end

-- -------------------------------------------------------------------------- --

---
-- Schaltet zwischen dem normalen und dem erweiterten Zoom um.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:ToggleExtendedZoom()
    if self.Data.ExtendedZoomAllowed then
        if self.Data.ExtendedZoomActive then
            self:DeactivateExtendedZoom();
        else
            self:ActivateExtendedZoom();
        end
    end
end

---
-- Aktiviert den erweiterten Zoom.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:ActivateExtendedZoom()
    self.Data.ExtendedZoomActive = true;
    API.Bridge("BundleGameHelperFunctions.Local:ActivateExtendedZoom()");
end

---
-- Deaktiviert den erweiterten Zoom.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:DeactivateExtendedZoom()
    self.Data.ExtendedZoomActive = false;
    API.Bridge("BundleGameHelperFunctions.Local:DeactivateExtendedZoom()");
end

---
-- Initialisiert den erweiterten Zoom.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:InitExtendedZoom()
    API.Bridge([[
        BundleGameHelperFunctions.Local:ActivateExtendedZoomHotkey()
        BundleGameHelperFunctions.Local:RegisterExtendedZoomHotkey()
    ]]);
end

-- -------------------------------------------------------------------------- --

---
-- Deaktiviert die Tastenkombination zum Einschalten der Cheats.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:KillCheats()
    self.Data.CheatsForbidden = true;
    API.Bridge("BundleGameHelperFunctions.Local:KillCheats()");
end

---
-- Aktiviert die Tastenkombination zum Einschalten der Cheats.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:RessurectCheats()
    self.Data.CheatsForbidden = false;
    API.Bridge("BundleGameHelperFunctions.Local:RessurectCheats()");
end

-- -------------------------------------------------------------------------- --

---
-- Aktiviert die Heldenkamera und setzt den verfolgten Helden. Der
-- Held kann 0 sein, dann wird entweder der letzte Held verwendet
-- oder über den GUI-Spieler ermittelt.
--
-- @param _Hero    Skriptname/Entity-ID des Helden
-- @param _MaxZoom Maximaler Zoomfaktor
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:ThridPersonActivate(_Hero, _MaxZoom)
    if BriefingSystem then
        BundleGameHelperFunctions.Global:ThridPersonOverwriteStartAndEndBriefing();
    end

    local Hero = GetID(_Hero);
    BundleGameHelperFunctions.Global.Data.ThridPersonIsActive = true;
    Logic.ExecuteInLuaLocalState([[
        BundleGameHelperFunctions.Local:ThridPersonActivate(]]..tostring(Hero)..[[, ]].. tostring(_MaxZoom) ..[[);
    ]]);
end

---
-- Deaktiviert die Heldenkamera.
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:ThridPersonDeactivate()
    BundleGameHelperFunctions.Global.Data.ThridPersonIsActive = false;
    Logic.ExecuteInLuaLocalState([[
        BundleGameHelperFunctions.Local:ThridPersonDeactivate();
    ]]);
end

---
-- Prüft, ob die Heldenkamera aktiv ist.
--
-- @return boolean: Kamera aktiv
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:ThridPersonIsRuning()
    return self.Data.ThridPersonIsActive;
end

---
-- Überschreibt StartBriefing und EndBriefing des Briefing System,
-- wenn es vorhanden ist.
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global:ThridPersonOverwriteStartAndEndBriefing()
    if BriefingSystem then
        if not BriefingSystem.StartBriefing_Orig_HeroCamera then
            BriefingSystem.StartBriefing_Orig_HeroCamera = BriefingSystem.StartBriefing;
            BriefingSystem.StartBriefing = function(_Briefing, _CutsceneMode)
                if BundleGameHelperFunctions.Global:ThridPersonIsRuning() then
                    BundleGameHelperFunctions.Global:ThridPersonDeactivate();
                    BundleGameHelperFunctions.Global.Data.ThirdPersonStoppedByCode = true;
                end
                BriefingSystem.StartBriefing_Orig_HeroCamera(_Briefing, _CutsceneMode);
            end
            StartBriefing = BriefingSystem.StartBriefing;
        end

        if not BriefingSystem.EndBriefing_Orig_HeroCamera then
            BriefingSystem.EndBriefing_Orig_HeroCamera = BriefingSystem.EndBriefing;
            BriefingSystem.EndBriefing = function(_Briefing, _CutsceneMode)
                BriefingSystem.EndBriefing_Orig_HeroCamera();
                if BundleGameHelperFunctions.Global.Data.ThridPersonStoppedByCode then
                    BundleGameHelperFunctions.Global:ThridPersonActivate(0);
                    BundleGameHelperFunctions.Global.Data.ThridPersonStoppedByCode = false;
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

---
-- Lässt einen Siedler einem Helden folgen. Gibt die ID des Jobs
-- zurück, der die Verfolgung steuert.
--
-- @param _Entity   Entity das folgt
-- @param _Knight   Held
-- @param _Distance Entfernung, die uberschritten sein muss
-- @param _Angle    Ausrichtung
-- @return number: Job-ID
-- @within Private
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
-- @param _JobID Job-ID
-- @within Private
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
-- @internal
--
-- @param _Entity   Entity das folgt
-- @param _Knight   Held
-- @param _Distance Entfernung, die uberschritten sein muss
-- @param _Angle    Ausrichtung
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global.ControlFollowKnightSave(_EntityID, _KnightID, _Distance, _Angle)
    -- Entity oder Held sind hinüber bzw. haben ihre ID veründert
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
-- @param _Center          Zentralpunkt
-- @param _Offset          Entfernung der Ecken zum Zentrum
-- @param _TerrainType     Textur ID
-- @within Private
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
    Logic.UpdateBlocking( x11, y11, x12, y12);
end

---
-- Ändert die Wasserhöhe in einem Quadrat. Offset bestimmt die Abstände
-- der Eckpunkte zum Zentralpunkt.
-- @param _Center      Zentralpunkt
-- @param _Offset      Entfernung der Ecken zum Zentrum
-- @param _Hight       Neue Höhe
-- @param _Relative    Relative Höhe benutzen
-- @within Private
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
-- @param _Center      Zentralpunkt
-- @param _Offset      Entfernung der Ecken zum Zentrum
-- @param _Hight       Neue Höhe
-- @param _Relative    Relative Höhe benutzen
-- @within Private
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
-- @param _Center Zentralpunkt des Quadrat
-- @param _Offset Abstand der Ecken zum Zentrum
-- @return number: X-Koordinate von Punkt 1
-- @return number: Y-Koordinate von Punkt 1
-- @return number: X-Koordinate von Punkt 2
-- @return number: Y-Koordinate von Punkt 2
-- @return number: Bodenhöhe
-- @within Private
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
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Global.OnSaveGameLoaded()
    -- Feste sperren --
    Logic.StartFestival_Orig_NothingToCelebrate = nil;
    BundleGameHelperFunctions.Global:InitFestival();

    -- Geänderter Zoom --
    if BundleGameHelperFunctions.Global.Data.ExtendedZoomActive then
        BundleGameHelperFunctions.Global:ActivateExtendedZoom();
    end

    -- Cheats sperren --
    if BundleGameHelperFunctions.Global.Data.CheatsForbidden == true then
        BundleGameHelperFunctions.Global:KillCheats();
    end

    -- Menschlichen Spieler ändern --
    if BundleGameHelperFunctions.Global.Data.HumanPlayerChangedOnce then
        Logic.ExecuteInLuaLocalState([[
            GUI.SetControlledPlayer(]]..BundleGameHelperFunctions.Global.Data.HumanPlayerID..[[)
            for k,v in pairs(Buffs)do
                GUI_Buffs.UpdateBuffsInInterface(]]..BundleGameHelperFunctions.Global.Data.HumanPlayerID..[[,v)
                GUI.ResetMiniMap()
            end
            if IsExisting(Logic.GetKnightID(GUI.GetPlayerID())) then
                local portrait = GetKnightActor(]]..BundleGameHelperFunctions.Global.Data.HumanKnightType..[[)
                g_PlayerPortrait[]]..BundleGameHelperFunctions.Global.Data.HumanPlayerID..[[] = portrait
                LocalSetKnightPicture()
            end
        ]]);
    end
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Local:Install()
    self:InitForbidSpeedUp()
    self:InitForbidSaveGame();
    self:InitForbidFestival();

    QSB.TimeLine = BundleGameHelperFunctions.Shared.TimeLine;
    TimeLine = QSB.TimeLine;
end

---
-- Fokusiert die Kamera auf dem Primärritter des Spielers.
--
-- @param _Player     Partei
-- @param _Rotation   Kamerawinkel
-- @param _ZoomFactor Zoomfaktor
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Local:SetCameraToPlayerKnight(_Player, _Rotation, _ZoomFactor)
    BundleGameHelperFunctions.Local:SetCameraToEntity(Logic.GetKnightID(_Player), _Rotation, _ZoomFactor);
end

---
-- Fokusiert die Kamera auf dem Entity.
--
-- @param _Entity     Entity
-- @param _Rotation   Kamerawinkel
-- @param _ZoomFactor Zoomfaktor
-- @within Private
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
-- @param _Limit Obergrenze
-- @within Private
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
-- @param _Flag Speedbremse ist aktiv
-- @within Private
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
-- @within Private
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
-- @within Private
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
-- @within Private
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
-- Schreibt den Hotkey für den erweiterten Zoom in das Hotkey-Register.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Local:RegisterExtendedZoomHotkey()
    API.AddHotKey(
        {de = "Strg + Umschalt + K",       en = "Ctrl + Shift + K"},
        {de = "Alternativen Zoom ein/aus", en = "Alternative zoom on/off"}
    )
end

---
-- Aktiviert den Hotkey zum Wechsel zwischen normalen und erweiterten Zoom.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Local:ActivateExtendedZoomHotkey()
    Input.KeyBindDown(
        Keys.ModifierControl + Keys.ModifierShift + Keys.K,
        "BundleGameHelperFunctions.Local:ToggleExtendedZoom()",
        2,
        false
    );
end

---
-- Wechselt zwischen erweitertem und normalen Zoom.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Local:ToggleExtendedZoom()
    API.Bridge("BundleGameHelperFunctions.Global:ToggleExtendedZoom()");
end

---
-- Erweitert die Zoomrestriktion auf das Maximum.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Local:ActivateExtendedZoom()
    Camera.RTS_SetZoomFactorMax(0.8701);
    Camera.RTS_SetZoomFactor(0.8700);
    Camera.RTS_SetZoomFactorMin(0.0999);
end

---
-- Stellt die normale Zoomrestriktion wieder her.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Local:DeactivateExtendedZoom()
    Camera.RTS_SetZoomFactor(0.5000);
    Camera.RTS_SetZoomFactorMax(0.5001);
    Camera.RTS_SetZoomFactorMin(0.0999);
end

-- -------------------------------------------------------------------------- --

---
-- Überschreibt die Hotkey-Funktion, die das Spiel speichert.
--
-- @within Private
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
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Local:DisplaySaveButtons(_Flag)
    XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame",  (_Flag and 0) or 1);
    XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", (_Flag and 0) or 1);
end

-- -------------------------------------------------------------------------- --

---
-- Aktiviert die Heldenkamera und setzt den verfolgten Helden. Der
-- Held kann 0 sein, dann wird entweder der letzte Held verwendet
-- oder über den GUI-Spieler ermittelt.
--
-- @param _Hero    Skriptname/Entity-ID des Helden
-- @param _MaxZoom Maximaler Zoomfaktor
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Local:ThridPersonActivate(_Hero, _MaxZoom)
    _Hero = (_Hero ~= 0 and _Hero) or self.Data.ThridPersonLastHero or Logic.GetKnightID(GUI.GetPlayerID());
    _MaxZoom = _MaxZoom or self.Data.ThridPersonLastZoom or 0.5;
    if not _Hero then
        return;
    end

    if not GameCallback_Camera_GetBorderscrollFactor_Orig_HeroCamera then
        self:ThridPersonOverwriteGetBorderScrollFactor();
    end

    self.Data.ThridPersonLastHero = _Hero;
    self.Data.ThridPersonLastZoom = _MaxZoom;
    self.Data.ThridPersonIsActive = true;

    local Orientation = Logic.GetEntityOrientation(_Hero);
    Camera.RTS_FollowEntity(_Hero);
    Camera.RTS_SetRotationAngle(Orientation-90);
    Camera.RTS_SetZoomFactor(_MaxZoom);
    Camera.RTS_SetZoomFactorMax(_MaxZoom + 0.0001);
end

---
-- Deaktiviert die Heldenkamera.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Local:ThridPersonDeactivate()
    self.Data.ThridPersonIsActive = false;
    Camera.RTS_SetZoomFactorMax(0.5);
    Camera.RTS_SetZoomFactor(0.5);
    Camera.RTS_FollowEntity(0);
end

---
-- Prüft, ob die Heldenkamera aktiv ist.
--
-- @return boolean: Kamera aktiv
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Local:ThridPersonIsRuning()
    return self.Data.ThridPersonIsActive;
end

---
-- Überschreibt GameCallback_GetBorderScrollFactor und wandelt den
-- Bildlauf am Bildschirmrand in Bildrotation um. Dabei wird die
-- Kamera um links oder rechts gedreht, abhänig von der Position
-- der Mouse.
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Local:ThridPersonOverwriteGetBorderScrollFactor()
    GameCallback_Camera_GetBorderscrollFactor_Orig_HeroCamera = GameCallback_Camera_GetBorderscrollFactor
    GameCallback_Camera_GetBorderscrollFactor = function()
        if not BundleGameHelperFunctions.Local.Data.ThridPersonIsActive then
            return GameCallback_Camera_GetBorderscrollFactor_Orig_HeroCamera();
        end

        local CameraRotation = Camera.RTS_GetRotationAngle();
        local xS, yS = GUI.GetScreenSize();
        local xM, yM = GUI.GetMousePosition();
        local xR = xM / xS;

        if xR <= 0.02 then
            CameraRotation = CameraRotation + 0.3;
        elseif xR >= 0.98 then
            CameraRotation = CameraRotation - 0.3;
        else
            return 0;
        end
        if CameraRotation >= 360 then
            CameraRotation = 0;
        end
        Camera.RTS_SetRotationAngle(CameraRotation);
        return 0;
    end
end

-- -------------------------------------------------------------------------- --

---
--
--
-- @within Private
-- @local
--
function BundleGameHelperFunctions.Local:InitForbidFestival()
    NewStartFestivalUpdate = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local PlayerID = GUI.GetPlayerID();
        if BundleGameHelperFunctions.Local.Data.NormalFestivalLockedForPlayer[PlayerID] then
            XGUIEng.ShowWidget(WidgetID, 0);
            return true;
        end
    end
    Core:StackFunction("GUI_BuildingButtons.StartFestivalUpdate", NewStartFestivalUpdate);
end

-- -------------------------------------------------------------------------- --

---
-- Startet einen Zeitstrahl. Ein Zeitstrahl hat bestimmte Stationen,
-- an denen eine Aktion ausgeführt wird.
--
-- <b>Alias:</b> QSB.TimeLine:Start<br>
-- <b>Alias:</b> TimeLine:Start
--
-- @param _description     Beschreibung
-- @return number
-- @within QSB.TimeLine
--
function BundleGameHelperFunctions.Shared.TimeLine:Start(_description)
    local JobID = self.Data.TimeLineUniqueJobID;
    self.Data.TimeLineUniqueJobID = JobID +1;

    _description.Running = true;
    _description.StartTime = Logic.GetTime();
    _description.Iterator = 1;

    -- Check auf sinnvolle Zeitabstände
    local Last = 0;
    for i=1, #_description, 1 do
        if _description[i].Time < Last then
            _description[i].Time = Last+1;
            Last = _description[i].Time;
        end
    end

    self.Data.TimeLineJobs[JobID] = _description;
    if not self.Data.ControlerID then
        local Controler = StartSimpleJobEx( BundleGameHelperFunctions.Shared.TimeLine.TimeLineControler );
        self.Data.ControlerID = Controler;
    end
    return JobID;
end

---
-- Startet einen Zeitstrahl erneut. Ist der Zeitstrahl noch nicht
-- beendet, beginnt er dennoch von vorn.
--
-- <b>Alias:</b> QSB.TimeLine:Restart<br>
-- <b>Alias:</b> TimeLine:Restart
--
-- @param _ID  ID des Zeitstrahl
-- @within QSB.TimeLine
--
function BundleGameHelperFunctions.Shared.TimeLine:Restart(_ID)
    if not self.Data.TimeLineJobs[_ID] then
        return;
    end
    self.Data.TimeLineJobs[_ID].Running = true;
    self.Data.TimeLineJobs[_ID].StartTime = Logic.GetTime();
    self.Data.TimeLineJobs[_ID].Iterator = 1;
end

---
-- Prüft, ob der Zeitstrahl noch nicht durchgelaufen ist.
--
-- <b>Alias:</b> QSB.TimeLine:IsRunning<br>
-- <b>Alias:</b> TimeLine:IsRunning
--
-- @param _ID  ID des Zeitstrahl
-- @return boolean
-- @within QSB.TimeLine
--
function BundleGameHelperFunctions.Shared.TimeLine:IsRunning(_ID)
    if self.Data.TimeLineJobs[_ID] then
        return self.Data.TimeLineJobs[_ID].Running == true;
    end
    return false;
end

---
-- Hält einen Zeitstrahl an.
--
-- <b>Alias:</b> QSB.TimeLine:Yield<br>
-- <b>Alias:</b> TimeLine:Yield
--
-- @param _ID  ID des Zeitstrahl
-- @within QSB.TimeLine
--
function BundleGameHelperFunctions.Shared.TimeLine:Yield(_ID)
    if not self.Data.TimeLineJobs[_ID] then
        return;
    end
    self.Data.TimeLineJobs[_ID].Running = false;
end

---
-- Stößt einen angehaltenen Zeitstrahl wieder an.
--
-- <b>Alias:</b> QSB.TimeLine:Resume<br>
-- <b>Alias:</b> TimeLine:Resume
--
-- @param _ID  ID des Zeitstrahl
-- @within QSB.TimeLine
--
function BundleGameHelperFunctions.Shared.TimeLine:Resume(_ID)
    if not self.Data.TimeLineJobs[_ID] then
        return;
    end
    self.Data.TimeLineJobs[_ID].Running = true;
end

---
-- Steuert alle Zeitstrahlen.
-- @within QSB.TimeLine
-- @local
--
function BundleGameHelperFunctions.Shared.TimeLine.TimeLineControler()
    for k,v in pairs(BundleGameHelperFunctions.Shared.TimeLine.Data.TimeLineJobs) do
        if v.Iterator > #v then
            BundleGameHelperFunctions.Shared.TimeLine.Data.TimeLineJobs[k].Running = false;
        end

        if v.Running then
            if (v[v.Iterator].Time + v.StartTime) <= Logic.GetTime() then
                v[v.Iterator].Action(v[v.Iterator]);
                BundleGameHelperFunctions.Shared.TimeLine.Data.TimeLineJobs[k].Iterator = v.Iterator +1;
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleGameHelperFunctions");
