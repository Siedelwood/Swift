-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntitySelection                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle implementiert verschiedene Selektionsmodi. Es gibt keine
-- öffentlichen Funktionen. Das Bundle arbeitet autonom ohne zutun.
--
-- @module BundleEntitySelection
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --



-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleEntitySelection = {
    Global = {},
    Local = {
        Data = {
            Tooltips = {
                KnightButton = {
                    Title = {
                        de = "Ritter selektieren",
                        en = "- Selektiert den Ritter {cr}- STRG halten selektiert alle Ritter",
                    },
                    Text = {
                        de = "Select Knight",
                        en = "- Selects the knight {cr}- Press CTRL to select all knights",
                    },
                },
                BattalionButton = {
                    Title = {
                        de = "Militär selektieren",
                        en = "- Selektiert alle Militäreinheiten {cr}- SHIFT halten um auch Munitionswagen und Trebuchets auszuwählen",
                    },
                    Text = {
                        de = "Select Units",
                        en = "- Selects all military units {cr}- Press SHIFT to additionally select ammunition carts and trebuchets",
                    },
                },
            },
        },
    },
    
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Application-Space
-- @local
--
function BundleEntitySelection.Global:Install()

end

-- Local Script ----------------------------------------------------------------

---
-- Initialisiert das Bundle im lokalen Skript.
-- @within Application-Space
-- @local
--
function BundleEntitySelection.Local:Install()
    self:OverwriteSelectAllUnits();
    self:OverwriteSelectKnight();
    self:OverwriteNamesAndDescription();
end

---
-- Hängt eine Funktion an die GUI_Tooltip.SetNameAndDescription an, sodass
-- Tooltips überschrieben werden können.
--
-- @within Application-Space
-- @local
--
function BundleEntitySelection.Local:OverwriteNamesAndDescription()
    
    local Function = function(_Arguments, _Original)
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en"
        
        if XGUIEng.GetWidgetID("/InGame/Root/Normal/AlignBottomRight/MapFrame/KnightButton") == CurrentWidgetID then
            BundleEntitySelection.Local:SetTooltip(
                BundleEntitySelection.Local.Data.Tooltips.KnightButton.Title[lang], 
                BundleEntitySelection.Local.Data.Tooltips.KnightButton.Text[lang]
            )
            return;
        end
        
        if XGUIEng.GetWidgetID("/InGame/Root/Normal/AlignBottomRight/MapFrame/BattalionButton") == CurrentWidgetID then
            BundleEntitySelection.Local:SetTooltip(
                BundleEntitySelection.Local.Data.Tooltips.BattalionButton.Title[lang],
                BundleEntitySelection.Local.Data.Tooltips.BattalionButton.Text[lang]
            )
            return;
        end
        
        _Original(unpack(_Arguments));
    end
    Core:AppendFunction("GUI_Tooltip.SetNameAndDescription", Function)
end

---
-- Schreibt einen anderen Text in einen normalen Tooltip.
--
-- @param _TitleText Titel des Tooltip
-- @param _DescText  Text des Tooltip
-- @within Application-Space
-- @local
--
function BundleEntitySelection.Local:SetTooltip(_TitleText, _DescText)
    local TooltipContainerPath = "/InGame/Root/Normal/TooltipNormal"
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath)
    local TooltipNameWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Name")
    local TooltipDescriptionWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Text")
    
    XGUIEng.SetText(TooltipNameWidget, "{center}" .. _TitleText)
    XGUIEng.SetText(TooltipDescriptionWidget, _DescText)
    
    local Height = XGUIEng.GetTextHeight(TooltipDescriptionWidget, true)
    local W, H = XGUIEng.GetWidgetSize(TooltipDescriptionWidget)
    
    XGUIEng.SetWidgetSize(TooltipDescriptionWidget, W, Height)
end

---
-- Überschreibt den SelectKnight-Button. Durch drücken von CTLR können alle
-- Helden selektiert werden, die der Spieler kontrolliert.
--
-- @within Application-Space
-- @local
--
function BundleEntitySelection.Local:OverwriteSelectKnight()
    GUI_Knight.JumpToButtonClicked = function()
        local PlayerID = GUI.GetPlayerID();
        local KnightID = Logic.GetKnightID(PlayerID);
        if KnightID > 0 then
            g_MultiSelection.EntityList = {};
            g_MultiSelection.Highlighted = {};
            GUI.ClearSelection();
            
            if XGUIEng.IsModifierPressed(Keys.ModifierControl) then
                local knights = {}
                Logic.GetKnights(PlayerID, knights);
                for i=1,#knights do
                    GUI.SelectEntity(knights[i]);
                end
            else
                GUI.SelectEntity(Logic.GetKnightID(PlayerID));
            end
        else
            GUI.AddNote("Debug: You do not have a knight");
        end
    end
end

---
-- Überschreibt die Militärselektion, sodass der Spieler mit SHIFT zusätzlich
-- die Munitionswagen und Trebuchets selektieren kann.
-- @within Application-Space
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
-- @within Application-Space
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
-- @within Application-Space
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

