-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundlePlayerHelperFunctions                                   # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Bundle kommen einige Funktionalitäten zur Steuerung von
-- spielerbezogenen Features.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundlePlayerHelperFunctions = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Entfernt ein Territorium für den angegebenen Spieler aus der Liste
-- der entdeckten Territorien.
--
-- <p><b>Alias:</b> UndiscoverTerritory</p>
--
-- @param[type=number] _PlayerID    Spieler-ID
-- @param[type=number] _TerritoryID Territorium-ID
-- @within Anwenderfunktionen
--
function API.UndiscoverTerritory(_PlayerID, _TerritoryID)
    if GUI then
        API.Bridge("API.UndiscoverTerritory(" .._PlayerID.. ", ".._TerritoryID.. ")")
        return;
    end
    return BundlePlayerHelperFunctions.Global:UndiscoverTerritory(_PlayerID, _TerritoryID);
end
UndiscoverTerritory = API.UndiscoverTerritory;

---
-- Entfernt alle Territorien einer Partei aus der Liste der entdeckten
-- Territorien. Als Nebeneffekt gild die Partei als unentdeckt.
--
-- <p><b>Alias:</b> UndiscoverTerritories</p>
--
-- @param[type=number] _PlayerID    Spieler-ID
-- @param[type=number] _TargetPlayerID Anderer Spieler
-- @within Anwenderfunktionen
--
function API.UndiscoverTerritories(_PlayerID, _TargetPlayerID)
    if GUI then
        API.Bridge("API.UndiscoverTerritories(" .._PlayerID.. ", ".._TargetPlayerID.. ")")
        return;
    end
    return BundlePlayerHelperFunctions.Global:UndiscoverTerritories(_PlayerID, _TargetPlayerID);
end
UndiscoverTerritories = API.UndiscoverTerritories;

---
-- Setzt die Einnahmen für alle Stadtgebäude eines Spielers. Stadtgebäude
-- können nur Einnahmen zwischen 0 und 100 Talern haben.
--
-- <p><b>Alias:</b> SetPlayerEarnings</p>
--
-- @param[type=number] _PlayerID Partei oder nil für alle
-- @param[type=number] _Earnings Einnahmen [0 | 100]
-- @within Anwenderfunktionen
--
function API.SetEarningsOfPlayerCity(_PlayerID, _Earnings)
    if GUI then
        API.Bridge("API.SetEarningsOfPlayerCity(" .._PlayerID.. ", " .._Earnings.. ")");
        return;
    end
    if _PlayerID ~= -1 and Logic.GetStoreHouse(_PlayerID) == 0 then
        API.Fatal("API.SetEarningsOfPlayerCity: Player " .._PlayerID.. " is dead! :(");
        return;
    end
    if _Earnings == nil or (_Earnings < 0 or _Earnings > 100) then
        API.Fatal("API.SetEarningsOfPlayerCity: _Earnings must be between 0 and 100!");
        return;
    end
    return BundlePlayerHelperFunctions.Global:SetEarningsOfPlayerCity(_PlayerID, _Earnings);
end
SetPlayerEarnings = API.SetEarningsOfPlayerCity;

---
-- Setzt den Befriedigungsstatus eines Bedürfnisses für alle Gebäude
-- des angegebenen Spielers. Der Befriedigungsstatus ist eine Zahl
-- zwischen 0.0 und 1.0.
--
-- <p><b>Alias:</b> SetNeedSatisfactionLevel</p>
--
-- @param[type=number] _Need Bedürfnis
-- @param[type=number] _State Erfüllung des Bedürfnisses
-- @param[type=number] _PlayerID Partei oder -1 für alle
-- @within Anwenderfunktionen
--
function API.SetNeedSatisfaction(_Need, _State, _PlayerID)
    if GUI then
        API.Bridge("API.SetNeedSatisfaction(" .._Need.. ", " .._State.. ", " .._PlayerID.. ")")
        return;
    end
    if _PlayerID ~= -1 and Logic.GetStoreHouse(_PlayerID) == 0 then
        API.Fatal("API.SetNeedSatisfaction: Player " .._PlayerID.. " is dead! :(");
        return;
    end
    if _State < 0 or _State > 1 then
        API.Fatal("API.SetNeedSatisfaction: _State must be between 0 and 1!");
        return;
    end
    return BundlePlayerHelperFunctions.Global:SetNeedSatisfactionLevel(_Need, _State, _PlayerID);
end
SetNeedSatisfactionLevel = API.SetNeedSatisfaction;

---
-- Diese Funktion ermöglicht das sichere Entsperren eines gesperrten Titels.
--
-- <p><b>Alias:</b> UnlockTitleForPlayer</p>
--
-- @param[type=number] _PlayerID Zielpartei
-- @param[type=number] _KnightTitle Titel zum Entsperren
-- @within Anwenderfunktionen
--
function API.UnlockTitleForPlayer(_PlayerID, _KnightTitle)
    if GUI then
        API.Bridge("API.UnlockTitleForPlayer(" .._PlayerID.. ", " .._KnightTitle.. ")")
        return;
    end
    return BundlePlayerHelperFunctions.Global:UnlockTitleForPlayer(_PlayerID, _KnightTitle);
end
UnlockTitleForPlayer = API.UnlockTitleForPlayer;

---
-- Startet ein Fest für den Spieler. Ist dieser Typ von Fest für
-- den Spieler verboten, wird er automatisch erlaubt.
--
-- <p><b>Alias:</b> StartNormalFestival</p>
--
-- @param[type=number] _PlayerID Spieler
-- @within Anwenderfunktionen
--
function API.StartNormalFestival(_PlayerID)
    if GUI then
        API.Bridge("API.StartNormalFestival(".. _PlayerID ..")");
        return;
    end
    BundlePlayerHelperFunctions.Global:RestrictFestivalForPlayer(_PlayerID, 0, false);
    Logic.StartFestival(_PlayerID, 0);
end
StartNormalFestival = API.StartNormalFestival;

---
-- Startet ein Beförderungsfest für den Spieler. Ist dieser Typ
-- von Fest für den Spieler verboten, wird er automatisch erlaubt.
--
-- <p><b>Alias:</b> StartCityUpgradeFestival</p>
--
-- @param[type=number] _PlayerID Spieler
-- @within Anwenderfunktionen
--
function API.StartCityUpgradeFestival(_PlayerID)
    if GUI then
        API.Bridge("API.StartCityUpgradeFestival(".. _PlayerID ..")");
        return;
    end
    BundlePlayerHelperFunctions.Global:RestrictFestivalForPlayer(_PlayerID, 1, false);
    Logic.StartFestival(_PlayerID, 1);
end
StartCityUpgradeFestival = API.StartCityUpgradeFestival;

---
-- Verbietet ein normales Fest und sperrt die Technologie.
--
-- <p><b>Alias:</b> ForbidFestival</p>
--
-- @param[type=number] _PlayerID Spieler
-- @within Anwenderfunktionen
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
    BundlePlayerHelperFunctions.Global:RestrictFestivalForPlayer(_PlayerID, 0, true);
    API.Bridge("BundlePlayerHelperFunctions.Local.Data.NormalFestivalLockedForPlayer[" .._PlayerID.. "] = true");
end
ForbidFestival = API.ForbidFestival;

---
-- Erlaubt ein normales Fest und gibt die Technologie frei.
--
-- <p><b>Alias:</b> AllowFestival</p>
--
-- @param[type=number] _PlayerID Spieler
-- @within Anwenderfunktionen
--
function API.AllowFestival(_PlayerID)
    if GUI then
        API.Bridge("API.AllowFestival(".. _PlayerID ..")");
        return;
    end

    BundlePlayerHelperFunctions.Global:RestrictFestivalForPlayer(_PlayerID, 0, false);
    local KnightTitle = Logic.GetKnightTitle(_PlayerID)
    local Technology = Technologies.R_Festival;
    local State = TechnologyStates.Unlocked;
    if KnightTitleNeededForTechnology[Technology] == nil or KnightTitle >= KnightTitleNeededForTechnology[Technology] then
        State = TechnologyStates.Researched;
    end
    Logic.TechnologySetState(_PlayerID, Technology, State);
    API.Bridge("BundlePlayerHelperFunctions.Local.Data.NormalFestivalLockedForPlayer[" .._PlayerID.. "] = false");
end
AllowFestival = API.AllowFestival;

---
-- Wechselt die Spieler ID des menschlichen Spielers. Die neue ID muss
-- einen Primärritter haben. Diese Funktion kann nicht im Multiplayer
-- Mode verwendet werden.
--
-- <p><b>Alias:</b> PlayerSetPlayerID</p>
--
-- @param[type=number]  _OldID Alte ID des menschlichen Spielers
-- @param[type=number]  _NewID Neue ID des menschlichen Spielers
-- @param[type=string]  _NewName Name in der Statistik
-- @param[type=boolean] _RetainKnight Ritter mitnehmen
-- @within Anwenderfunktionen
--
function API.SetControllingPlayer(_OldID, _NewID, _NewName, _RetainKnight)
    if GUI then
        API.Bridge("API.SetControllingPlayer(".. _OldID ..", ".. _NewID ..", '".. _NewName .."', ".. tostring(_RetainKnight) ..")");
        return;
    end
    return BundlePlayerHelperFunctions.Global:SetControllingPlayer(_OldID, _NewID, _NewName, _RetainKnight);
end
PlayerSetPlayerID = API.SetControllingPlayer;

---
-- Gibt die ID des kontrollierenden Spielers zurück. Der erste als menschlich
-- definierte Spieler wird als kontrollierender Spieler angenommen.
--
-- <p><b>Alias:</b> PlayerGetPlayerID</p>
--
-- @return[type=number] PlayerID
-- @within Anwenderfunktionen
--
function API.GetControllingPlayer()
    if not GUI then
        return BundlePlayerHelperFunctions.Global:GetControllingPlayer();
    else
        return GUI.GetPlayerID();
    end
end
PlayerGetPlayerID = API.GetControllingPlayer;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundlePlayerHelperFunctions = {
    Global = {
        Data = {
            FestivalBlacklist = {},
            DiscoveredTerritories = {};
        }
    },
    Local = {
        Data = {
            NormalFestivalLockedForPlayer = {},
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
function BundlePlayerHelperFunctions.Global:Install()
    self:InitFestival();
    API.AddSaveGameAction(BundlePlayerHelperFunctions.Global.OnSaveGameLoaded);
end

---
-- Überschreibt Logic.StartFestival, sodass das Feierverhalten der KI gesteuert
-- werden kann.
--
-- @within Internal
-- @local
--
function BundlePlayerHelperFunctions.Global:InitFestival()
    Logic.StartFestival_Orig_NothingToCelebrate = Logic.StartFestival;
    Logic.StartFestival = function(_PlayerID, _Index)
        if BundlePlayerHelperFunctions.Global.Data.FestivalBlacklist[_PlayerID] then
            if BundlePlayerHelperFunctions.Global.Data.FestivalBlacklist[_PlayerID][_Index] then
                return;
            end
        end
        Logic.StartFestival_Orig_NothingToCelebrate(_PlayerID, _Index);
    end
end

---
-- Entfernt ein Territorium für den angegebenen Spieler aus der Liste
-- der entdeckten Territorien.
--
-- @param[type=number] _PlayerID    Spieler-ID
-- @param[type=number] _TerritoryID Territorium-ID
-- @within Internal
-- @local
--
function BundlePlayerHelperFunctions.Global:UndiscoverTerritory(_PlayerID, _TerritoryID)
    if self.Data.DiscoveredTerritories[_PlayerID] == nil then
        self.Data.DiscoveredTerritories[_PlayerID] = {};
    end
    for i=1, #self.Data.DiscoveredTerritories[_PlayerID], 1 do
        if self.Data.DiscoveredTerritories[_PlayerID][i] == _TerritoryID then
            table.remove(self.Data.DiscoveredTerritories[_PlayerID], i);
            break;
        end
    end
end

---
-- Entfernt alle Territorien einer Partei aus der Liste der entdeckten
-- Territorien. Als Nebeneffekt gild die Partei als unentdeckt-
--
-- @param[type=number] _PlayerID    Spieler-ID
-- @param[type=number] _TargetPlayerID Anderer Spieler
-- @within Internal
-- @local
--
function BundlePlayerHelperFunctions.Global:UndiscoverTerritories(_PlayerID, _TargetPlayerID)
    if self.Data.DiscoveredTerritories[_PlayerID] == nil then
        self.Data.DiscoveredTerritories[_PlayerID] = {};
    end
    local Discovered = {};
    for k, v in pairs(self.Data.DiscoveredTerritories[_PlayerID]) do
        local OwnerPlayerID = Logic.GetTerritoryPlayerID(v);
        if OwnerPlayerID ~= _TargetPlayerID then
            table.insert(Discovered, v);
            break;
        end
    end
    self.Data.DiscoveredTerritories[_PlayerID][i] = Discovered;
end

---
-- Setzt die Einnahmen für alle Stadtgebäude eines Spielers. Stadtgebäude
-- können nur Einnahmen zwischen 0 und 100 Talern haben.
--
-- <b>Alias:</b> SetPlayerEarnings
--
-- @param[type=number] _PlayerID Partei oder nil für alle
-- @param[type=number] _Earnings Einnahmen [0 | 100]
-- @within Internal
-- @local
--
function BundlePlayerHelperFunctions.Global:SetEarningsOfPlayerCity(_PlayerID, _Earnings)
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
-- @param[type=number] _Need Bedürfnis
-- @param[type=number] _State Erfüllung des Bedürfnisses
-- @param[type=number] _PlayerID Partei oder -1 für alle
-- @within Internal
-- @local
--
function BundlePlayerHelperFunctions.Global:SetNeedSatisfactionLevel(_Need, _State, _PlayerID)
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
-- @param[type=number] _PlayerID Zielpartei
-- @param[type=number] _KnightTitle Titel zum Entsperren
-- @within Internal
-- @local
--
function BundlePlayerHelperFunctions.Global:UnlockTitleForPlayer(_PlayerID, _KnightTitle)
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
-- Erlaubt oder verbietet ein Fest für den angegebenen Spieler.
--
-- @param[type=number]  _PlayerID ID des Spielers
-- @param[type=number]  _Index    Index des Fest
-- @param[type=boolean] _Flag     Erlauben/verbieten
-- @within Internal
-- @local
--
function BundlePlayerHelperFunctions.Global:RestrictFestivalForPlayer(_PlayerID, _Index, _Flag)
    self.Data.FestivalBlacklist[_PlayerID] = self.Data.FestivalBlacklist[_PlayerID] or {};
    self.Data.FestivalBlacklist[_PlayerID][_Index] = _Flag == true;
end

---
-- Wechselt die Spieler ID des menschlichen Spielers. Die neue ID muss
-- einen Primärritter haben. Diese Funktion kann nicht im Multiplayer
-- Mode verwendet werden.
--
-- @param[type=number] _oldPlayerID Alte ID des menschlichen Spielers
-- @param[type=number] _newPlayerID Neue ID des menschlichen Spielers
-- @param[type=string] _newNameForStatistics Name in der Statistik
-- @param[type=boolean] _retainPrimaryKnight Ritter mitnehmen
-- @within Internal
-- @local
--
function BundlePlayerHelperFunctions.Global:SetControllingPlayer(_oldPlayerID, _newPlayerID, _newNameForStatistics, _retainPrimaryKnight)
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
-- @return[type=number] PlayerID
-- @within Internal
-- @local
--
function BundlePlayerHelperFunctions.Global:GetControllingPlayer()
    local pID = 1;
    for i=1,8 do
        if Logic.PlayerGetIsHumanFlag(i) == true then
            pID = i;
            break;
        end
    end
    return pID;
end

---
-- Stellt nicht-persistente Änderungen nach dem laden wieder her.
--
-- @within Internal
-- @local
--
function BundlePlayerHelperFunctions.Global.OnSaveGameLoaded()
    -- Feste sperren --
    Logic.StartFestival_Orig_NothingToCelebrate = nil;
    BundlePlayerHelperFunctions.Global:InitFestival();

    -- Menschlichen Spieler ändern --
    if BundlePlayerHelperFunctions.Global.Data.HumanPlayerChangedOnce then
        Logic.ExecuteInLuaLocalState([[
            GUI.SetControlledPlayer(]]..BundlePlayerHelperFunctions.Global.Data.HumanPlayerID..[[)
            for k,v in pairs(Buffs)do
                GUI_Buffs.UpdateBuffsInInterface(]]..BundlePlayerHelperFunctions.Global.Data.HumanPlayerID..[[,v)
                GUI.ResetMiniMap()
            end
            if IsExisting(Logic.GetKnightID(GUI.GetPlayerID())) then
                local portrait = GetKnightActor(]]..BundlePlayerHelperFunctions.Global.Data.HumanKnightType..[[)
                g_PlayerPortrait[]]..BundlePlayerHelperFunctions.Global.Data.HumanPlayerID..[[] = portrait
                LocalSetKnightPicture()
            end
        ]]);
    end
end

-- Local Script ------------------------------------------------------------- --

function BundlePlayerHelperFunctions.Local:Install()
    self:InitForbidFestival();
    self:OverrideQuestLogPlayerIcon();
    self:OverrideQuestPlayerIcon();
end

---
-- Überschreibt den Button zum Start eines Festes, sodass er nicht angezeigt
-- wird, wenn Feste verboten sind.
--
-- @within Internal
-- @local
--
function BundlePlayerHelperFunctions.Local:InitForbidFestival()
    NewStartFestivalUpdate = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local PlayerID = GUI.GetPlayerID();
        if BundlePlayerHelperFunctions.Local.Data.NormalFestivalLockedForPlayer[PlayerID] then
            XGUIEng.ShowWidget(WidgetID, 0);
            return true;
        end
    end
    Core:StackFunction("GUI_BuildingButtons.StartFestivalUpdate", NewStartFestivalUpdate);
end

---
-- Überschreibt das Quest Icon für Spieler, die keinem Typen zugeordnet sind.
--
-- @within Internal
-- @local
--
function BundlePlayerHelperFunctions.Local:OverrideQuestPlayerIcon()
    GUI_Interaction.SetPlayerIcon_Orig_BundlePlayerHelperFunctions = GUI_Interaction.SetPlayerIcon;
    GUI_Interaction.SetPlayerIcon = function(_PlayerIconContainer, _PlayerID)
        if _PlayerID == GUI.GetPlayerID() then
            GUI_Interaction.SetPlayerIcon_Orig_BundlePlayerHelperFunctions(_PlayerIconContainer, _PlayerID);
            return;
        end

        -- Icon
        local PlayerIcon;
        local LogoWidget = _PlayerIconContainer .. "/Logo";
        local PatternWidget = _PlayerIconContainer .. "/Pattern";
        local PlayerCategory = GetPlayerCategoryType(_PlayerID);
        local PlayerIcon = g_TexturePositions.PlayerCategories[PlayerCategory];
        if Mission_Callback_OverridePlayerIconForQuest then
            PlayerIcon = Mission_Callback_OverridePlayerIconForQuest(_PlayerID) or PlayerIcon;
        end
        if PlayerIcon == nil then
            PlayerIcon = {13, 7};
        end
        SetIcon(LogoWidget, PlayerIcon);

        -- Background
        SetIcon(PatternWidget, {14, 1});
        local R, G, B = GUI.GetPlayerColor(_PlayerID);
        if PlayerCategory == PlayerCategories.Harbour then
            R, G, B = 255, 255, 255;
        end
        XGUIEng.SetMaterialColor(PatternWidget, 0, R, G, B, 255);
    end
end

---
-- Überschreibt das Quest log Icon für Spieler, die keinem Typen zugeordnet sind.
--
-- @within Internal
-- @local
--
function BundlePlayerHelperFunctions.Local:OverrideQuestLogPlayerIcon()
    QuestLog.PushQuestGiverLogo_Orig_BundlePlayerHelperFunctions = QuestLog.PushQuestGiverLogo;
    QuestLog.PushQuestGiverLogo = function(_widgetlist, _PlayerID)
        local Frame = "Icons.png";
        local IconSize = 44;
        local PlayerCategory = GetPlayerCategoryType(_PlayerID);
        local Coordinates = g_TexturePositions.PlayerCategories[PlayerCategory];
        
        if Coordinates ~= nil or Mission_Callback_OverridePlayerIconForQuest then
            QuestLog.PushQuestGiverLogo_Orig_BundlePlayerHelperFunctions(_widgetlist, _PlayerID);
            return;
        end
        Coordinates = {13, 7};

        local u0 = (Coordinates[1] - 1) * IconSize;
        local v0 = (Coordinates[2] - 1) * IconSize;
        local u1 = Coordinates[1] * IconSize;
        local v1 = Coordinates[2] * IconSize;

        if Coordinates[3] and Coordinates[3] == 1 then
            Frame = "Icons2.png";
        end
        XGUIEng.ListBoxPushItemEx(_widgetlist, "", Frame, nil, u0, v0, u1, v1);
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundlePlayerHelperFunctions");

