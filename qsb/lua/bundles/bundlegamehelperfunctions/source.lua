-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleGameHelperFunctions                                    # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
--
--
-- @module BundleGameHelperFunctions
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
-- @within User-Space
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
-- @within User-Space
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
-- Setzt den Befriedigungsstatus eines Bedürfnisses für alle Gebäude
-- des angegebenen Spielers. Der Befriedigungsstatus ist eine Zahl
-- zwischen 0.0 und 1.0.
--
-- <b>Alias:</b> SetNeedSatisfactionLevel
--
-- @param _Need     Bedürfnis
-- @param _State    Erfüllung des Bedürfnisses
-- @param _PlayerID Partei oder nil für alle
-- @within User-Space
--
function API.SetNeedSatisfaction(_Need, _State, _PlayerID)
    if GUI then
        API.Bridge("API.SetNeedSatisfaction(" .._Need.. ", " .._State.. ", " .._PlayerID.. ")")
        return;
    end
    return BundleGameHelperFunctions.Global:SetNeedSatisfactionLevel(_Need, _State, _PlayerID);
end
SetNeedSatisfactionLevel = API.SetNeedSatisfaction;

---
-- Entsperrt einen gesperrten Titel für den Spieler, sofern dieser
-- Titel gesperrt wurde.
--
-- <b>Alias:</b> UnlockTitleForPlayer
--
-- @param _PlayerID    Zielpartei
-- @param _KnightTitle Titel zum Entsperren
-- @within User-Space
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
-- @within User-Space
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
-- @within User-Space
--
function API.FocusCameraOnEntity(_Entity, _Rotation, _ZoomFactor)
    if not GUI then
        API.Bridge("API.FocusCameraOnEntity(" .._Entity.. ", " .._Rotation.. ", " .._ZoomFactor.. ")")
        return;
    end
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and _Entity) or "'" .._Entity.. "'";
        API.Dbg("API.FocusCameraOnEntity: Entity " ..Subject.. " does not exist!");
        return;
    end
    return BundleGameHelperFunctions.Local:SetCameraToEntity(_Entity, _Rotation, _ZoomFactor);
end
SetCameraToEntity = API.FocusCameraOnEntity;

---
--
--
-- @within User-Space
--
function API.SetSpeedLimit(_Limit)
    if GUI then
        API.Bridge("API.SetSpeedLimit(" .._Limit.. ")");
        return;
    end
    return API.Bridge("BundleGameHelperFunctions.Local:SetSpeedLimit(" .._Limit.. ")");
end

---
--
--
-- @within User-Space
--
function API.ActivateSpeedLimit(_Flag)
    if GUI then
        API.Bridge("API.ActivateSpeedLimit(" ..tostring(_Flag).. ")");
        return;
    end
    return API.Bridge("BundleGameHelperFunctions.Local:ActivateSpeedLimit(" ..tostring(_Flag).. ")");
end

---
--
--
-- @within User-Space
--
function API.KillCheats()
    if GUI then
        API.Bridge("API.KillCheats()");
        return;
    end
    return BundleGameHelperFunctions.Global:KillCheats();
end

---
--
--
-- @within User-Space
--
function API.RessurectCheats()
    if GUI then
        API.Bridge("API.RessurectCheats()");
        return;
    end
    return BundleGameHelperFunctions.Global:RessurectCheats();
end

---
--
--
-- @within User-Space
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

---
--
--
-- @within User-Space
--
function API.AllowExtendedZoom(_Flag)
    if GUI then
        API.Bridge("API.AllowExtendedZoom(".. tostring(_Flag) ..")");
        return;
    end
    return BundleGameHelperFunctions.Global:AllowExtendedZoom(_Flag);
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleGameHelperFunctions = {
    Global = {
        Data = {
            ExtendedZoomAllowed = true,
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
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Global:Install()

    API.AddSaveGameAction(BundleGameHelperFunctions.Global.OnSaveGameLoaded);
end

---
-- Entfernt ein Territorium für den angegebenen Spieler aus der Liste
-- der entdeckten Territorien.
--
-- @param _PlayerID    Spieler-ID
-- @param _TerritoryID Territorium-ID
-- @within Application-Space
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
-- @within Application-Space
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
-- Setzt den Befriedigungsstatus eines Bedürfnisses für alle Gebäude
-- des angegebenen Spielers. Der Befriedigungsstatus ist eine Zahl
-- zwischen 0.0 und 1.0.
--
-- @param _Need     Bedürfnis
-- @param _State    Erfüllung des Bedürfnisses
-- @param _PlayerID Partei oder nil für alle
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Global:SetNeedSatisfactionLevel(_Need, _State, _PlayerID)
    if not _PlayerID then
        for i=1, 8, 1 do
            Module_Comforts.Global.SetNeedSatisfactionLevel(_Need, _State, i);
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
-- Entsperrt einen gesperrten Titel für den Spieler, sofern dieser
-- Titel gesperrt wurde.
--
-- @param _PlayerID    Zielpartei
-- @param _KnightTitle Titel zum Entsperren
-- @within Application-Space
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

---
--
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Global:InitFestival()

end

-- -------------------------------------------------------------------------- --

---
--
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Global:AllowExtendedZoom(_Flag)
    self.Data.ExtendedZoomAllowed = _Flag == true;
    if _Flag == false then
        self:DeactivateExtendedZoom();
    end
end

---
--
--
-- @within Application-Space
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
--
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Global:ActivateExtendedZoom()
    self.Data.ExtendedZoomActive = true;
    API.Bridge("BundleGameHelperFunctions.Local:ActivateExtendedZoom()");
end

---
--
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Global:DeactivateExtendedZoom()
    self.Data.ExtendedZoomActive = false;
    API.Bridge("BundleGameHelperFunctions.Local:DeactivateExtendedZoom()");
end

---
--
--
-- @within Application-Space
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
--
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Global:KillCheats()
    self.Data.CheatsForbidden = true;
    API.Bridge("BundleGameHelperFunctions.Local:KillCheats()");
end

---
--
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Global:RessurectCheats()
    self.Data.CheatsForbidden = false;
    API.Bridge("BundleGameHelperFunctions.Local:RessurectCheats()");
end

-- -------------------------------------------------------------------------- --

---
-- Stellt nicht-persistente Änderungen nach dem laden wieder her.
--
-- @within Application-Space
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
        -- FIXME
    end
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Local:Install()
    self:InitForbidSpeedUp()
    self:InitForbidSaveGame();
end

---
-- Fokusiert die Kamera auf dem Primärritter des Spielers.
--
-- @param _Player     Partei
-- @param _Rotation   Kamerawinkel
-- @param _ZoomFactor Zoomfaktor
-- @within Application-Space
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
-- @within Application-Space
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

---
--
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Local:AddHotKey(_Keys, _Description)

end

-- -------------------------------------------------------------------------- --

---
--
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Local:SetSpeedLimit(_Limit)
    _Limit = (_Limit < 1 and 1) or math.floor(_Limit);
    self.Data.SpeedLimit = _Limit;
end

---
--
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Local:ActivateSpeedLimit(_Flag)
    self.Data.UseSpeedLimit = _Flag == true;
    if _Flag and Game.GameTimeGetFactor(GUI.GetPlayerID()) > self.Data.SpeedLimit then
        Game.GameTimeSetFactor(GUI.GetPlayerID(), self.Data.SpeedLimit);
    end
end

---
--
--
-- @within Application-Space
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
--
--
-- @within Application-Space
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
--
--
-- @within Application-Space
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
--
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Local:RegisterExtendedZoomHotkey()
    BundleGameHelperFunctions.Local:AddHotKey("STRG + SHIFT + K", "Alternativen Zoom ein/aus");
end

---
--
--
-- @within Application-Space
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
--
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Local:ToggleExtendedZoom()
    API.Bridge("BundleGameHelperFunctions.Global:ToggleExtendedZoom()");
end

---
--
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Local:ActivateExtendedZoom()
    Camera.RTS_SetZoomFactorMax(0.8701);
    Camera.RTS_SetZoomFactor(0.8700);
    Camera.RTS_SetZoomFactorMin(0.0999);
end

---
--
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Local:DeactivateExtendedZoom()
    Camera.RTS_SetZoomFactor(0.5000);
    Camera.RTS_SetZoomFactorMax(0.5001);
    Camera.RTS_SetZoomFactorMin(0.0999);
end

-- -------------------------------------------------------------------------- --

---
--
--
-- @within Application-Space
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
--
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Local:DisplaySaveButtons(_Flag)
    XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame",  (_Flag and 0) or 1);
    XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", (_Flag and 0) or 1);
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleGameHelperFunctions");
