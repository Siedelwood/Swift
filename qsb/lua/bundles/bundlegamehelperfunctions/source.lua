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
-- <b>Alias:<b> UndiscoverTerritory
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
-- <b>Alias:<b> UndiscoverTerritories
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
-- <b>Alias:<b> SetNeedSatisfactionLevel
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

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleGameHelperFunctions = {
    Global = {
        Data = {}
    },
    Local = {
        Data = {}
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



-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Application-Space
-- @local
--
function BundleGameHelperFunctions.Local:Install()

end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleGameHelperFunctions");

