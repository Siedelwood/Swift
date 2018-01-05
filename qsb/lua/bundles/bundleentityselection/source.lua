-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntitySelection                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- 
--
-- @module BundleEntitySelection
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User Space                                                                 --
-- -------------------------------------------------------------------------- --



-- -------------------------------------------------------------------------- --
-- Application Space                                                          --
-- -------------------------------------------------------------------------- --

BundleEntitySelection = {
    Global = {},
    Local = {}
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Application Space
-- @local
--
function BundleEntitySelection.Global:Install()

end

-- Local Script ----------------------------------------------------------------

---
-- Initialisiert das Bundle im lokalen Skript.
-- @within Application Space
-- @local
--
function BundleEntitySelection.Local:Install()
    self:OverwriteSelectAllUnits();
    self:OverwriteSelectKnight();
    self:OverwriteNamesAndDescription();
end

---
-- 
-- @within Application Space
-- @local
--
function BundleEntitySelection.Local:OverwriteNamesAndDescription()
    
    local Function = function(_Arguments, _Original)
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        
        if XGUIEng.GetWidgetID("/InGame/Root/Normal/AlignBottomRight/MapFrame/KnightButton") == CurrentWidgetID then
            
            return;
        end
        
        if XGUIEng.GetWidgetID("/InGame/Root/Normal/AlignBottomRight/MapFrame/BattalionButton") == CurrentWidgetID then
            
            return;
        end
        
        _Original(unpack(_Arguments));
    end
    Core:AppendFunction("GUI_Tooltip.SetNameAndDescription", Function)
end

---
-- 
--
-- @param _Key Description Key
-- @within Application Space
-- @local
--
function BundleEntitySelection.Local:SetTooltip(_Key)
    
end

---
-- 
-- @within Application Space
-- @local
--
function BundleEntitySelection.Local:OverwriteSelectKnight()
    
end

---
-- Überschreibt die Militärselektion, sodass der Spieler mit SHIFT zusätzlich
-- die Munitionswagen und Trebuchets selektieren kann.
-- @within Application Space
-- @local
--
function BundleEntitySelection.Local:OverwriteSelectAllUnits()
    GUI_MultiSelection.SelectAllPlayerUnitsClicked = function()
        if XGUIEng.IsModifierPressed(Keys.ModifierShift) then
            BundleEntitySelection.Local:ExtendedLeaderSortOrder();
        else
            BundleEntitySelection.Local:NormalLeaderSortOrder();
        end
        
        Sound.FXPlay2DSound("ui\\menu_click");
        GUI.ClearSelection();
        
        local PlayerID = GUI.GetPlayerID()   
        for i = 1, #LeaderSortOrder do
            local EntitiesOfThisType = GetPlayerEntities(PlayerID, LeaderSortOrder[i])      
            for j = 1, #EntitiesOfThisType do
                GUI.SelectEntity(EntitiesOfThisType[j])
            end
        end
        
        local Knights = {}
        Logic.GetKnights(PlayerID, Knights)
        for k = 1, #Knights do
            GUI.SelectEntity(Knights[k])
        end
        GUI_MultiSelection.CreateMultiSelection(g_SelectionChangedSource.User);
    end
end

---
-- Erzeugt die normale Sortierung ohne Munitionswagen und Trebuchets.
-- @within Application Space
-- @local
--
function BundleEntitySelection.Local:NormalLeaderSortOrder()
    g_MultiSelection = {};
    g_MultiSelection.EntityList = {};
    g_MultiSelection.Highlighted = {};

    LeaderSortOrder     = {};
    LeaderSortOrder[1]  = Entities.U_MilitarySword;
    LeaderSortOrder[2]  = Entities.U_MilitaryBow;
    LeaderSortOrder[3]  = Entities.U_MilitarySword_RedPrince;
    LeaderSortOrder[4]  = Entities.U_MilitaryBow_RedPrince;
    LeaderSortOrder[5]  = Entities.U_MilitaryBandit_Melee_ME;
    LeaderSortOrder[6]  = Entities.U_MilitaryBandit_Melee_NA;
    LeaderSortOrder[7]  = Entities.U_MilitaryBandit_Melee_NE;
    LeaderSortOrder[8]  = Entities.U_MilitaryBandit_Melee_SE;
    LeaderSortOrder[9]  = Entities.U_MilitaryBandit_Ranged_ME;
    LeaderSortOrder[10] = Entities.U_MilitaryBandit_Ranged_NA;
    LeaderSortOrder[11] = Entities.U_MilitaryBandit_Ranged_NE;
    LeaderSortOrder[12] = Entities.U_MilitaryBandit_Ranged_SE;
    LeaderSortOrder[13] = Entities.U_MilitaryCatapult;
    LeaderSortOrder[14] = Entities.U_MilitarySiegeTower;
    LeaderSortOrder[15] = Entities.U_MilitaryBatteringRam;
    LeaderSortOrder[16] = Entities.U_CatapultCart;
    LeaderSortOrder[17] = Entities.U_SiegeTowerCart;
    LeaderSortOrder[18] = Entities.U_BatteringRamCart;
    LeaderSortOrder[19] = Entities.U_Thief;

    -- Asien wird nur in der Erweiterung gebraucht.
    if g_GameExtraNo >= 1 then
        table.insert(LeaderSortOrder,  4, Entities.U_MilitarySword_Khana);
        table.insert(LeaderSortOrder,  6, Entities.U_MilitaryBow_Khana);
        table.insert(LeaderSortOrder,  7, Entities.U_MilitaryBandit_Melee_AS);
        table.insert(LeaderSortOrder, 12, Entities.U_MilitaryBandit_Ranged_AS);
    end
end

---
-- Erzeugt die erweiterte Selektion mit Munitionswagen und Trebuchets.
-- @within Application Space
-- @local
--
function BundleEntitySelection.Local:ExtendedLeaderSortOrder()
    g_MultiSelection = {};
    g_MultiSelection.EntityList = {};
    g_MultiSelection.Highlighted = {};

    LeaderSortOrder     = {};
    LeaderSortOrder[1]  = Entities.U_MilitarySword;
    LeaderSortOrder[2]  = Entities.U_MilitaryBow;
    LeaderSortOrder[3]  = Entities.U_MilitarySword_RedPrince;
    LeaderSortOrder[4]  = Entities.U_MilitaryBow_RedPrince;
    LeaderSortOrder[5]  = Entities.U_MilitaryBandit_Melee_ME;
    LeaderSortOrder[6]  = Entities.U_MilitaryBandit_Melee_NA;
    LeaderSortOrder[7]  = Entities.U_MilitaryBandit_Melee_NE;
    LeaderSortOrder[8]  = Entities.U_MilitaryBandit_Melee_SE;
    LeaderSortOrder[9]  = Entities.U_MilitaryBandit_Ranged_ME;
    LeaderSortOrder[10] = Entities.U_MilitaryBandit_Ranged_NA;
    LeaderSortOrder[11] = Entities.U_MilitaryBandit_Ranged_NE;
    LeaderSortOrder[12] = Entities.U_MilitaryBandit_Ranged_SE;
    LeaderSortOrder[13] = Entities.U_MilitaryCatapult;
    LeaderSortOrder[14] = Entities.U_Trebuchet;
    LeaderSortOrder[15] = Entities.U_MilitarySiegeTower;
    LeaderSortOrder[16] = Entities.U_MilitaryBatteringRam;
    LeaderSortOrder[17] = Entities.U_CatapultCart;
    LeaderSortOrder[18] = Entities.U_SiegeTowerCart;
    LeaderSortOrder[19] = Entities.U_BatteringRamCart;
    LeaderSortOrder[20] = Entities.U_AmmunitionCart;
    LeaderSortOrder[21] = Entities.U_Thief;

    -- Asien wird nur in der Erweiterung gebraucht.
    if g_GameExtraNo >= 1 then
        table.insert(LeaderSortOrder,  4, Entities.U_MilitarySword_Khana);
        table.insert(LeaderSortOrder,  6, Entities.U_MilitaryBow_Khana);
        table.insert(LeaderSortOrder,  7, Entities.U_MilitaryBandit_Melee_AS);
        table.insert(LeaderSortOrder, 12, Entities.U_MilitaryBandit_Ranged_AS);
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleEntitySelection");

