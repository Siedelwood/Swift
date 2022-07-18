-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleBuildingButtons                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --
---@diagnostic disable: undefined-global
---@diagnostic disable: need-check-nil
---@diagnostic disable: lowercase-global

---
-- Dieses Bundle erweitert das Gebäudemenü für verschiedene Gebäude um weitere
-- Funktionen. Es ist bspw. möglich ungenutzte Schalter frei zu programmieren.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleBuildingButtons = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Aktiviert oder deaktiviert die Single Stop Buttons. Single Stop ermöglicht
-- das Anhalten eines einzelnen Betriebes, anstelle des Anhaltens aller
-- Betriebe des gleichen Typs.
--
-- Im Gegensatz zur Viehzucht und zum Rückbau, welche feste eigeständige
-- Buttons sind, handelt es sich hierbei um einen Custom Button. Single
-- Stop belegt Index 1.
--
-- @param[type=boolean] _Flag Single Stop nutzen
-- @within Anwenderfunktionen
-- @see API.AddCustomBuildingButton
--
function API.UseSingleStop(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.UseSingleStop(" ..tostring(_Flag).. ")");
        return;
    end

    if _Flag then
        BundleBuildingButtons.Local:AddOptionalButton(
            2,
            BundleBuildingButtons.Local.ButtonDefaultSingleStop_Action,
            BundleBuildingButtons.Local.ButtonDefaultSingleStop_Tooltip,
            BundleBuildingButtons.Local.ButtonDefaultSingleStop_Update
        );
    else
        BundleBuildingButtons.Local:DeleteOptionalButton(2);
    end
end

---
-- Aktiviere oder deaktiviere Rückbau bei Stadt- und Rohstoffgebäuden. Die
-- Rückbaufunktion erlaubt es dem Spieler bei Stadt- und Rohstoffgebäude
-- der Stufe 2 und 3 jeweils eine Stufe zu zerstören. Der überflüssige
-- Arbeiter wird entlassen.
--
-- @param[type=boolean] _Flag Downgrade nutzen
-- @within Anwenderfunktionen
--
function API.UseDowngrade(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.UseDowngrade(" ..tostring(_Flag == true).. ")");
        return;
    end
    BundleBuildingButtons.Local.Data.Downgrade = _Flag == true;
end

---
-- Fügt einen optionalen Gebäudeschalter hinzu. Der Index bestimmt, welcher
-- der beiden möglichen Buttons verwendet wird.
--
-- Mit dieser Funktion können zwei ungenutzte Buttons im Gebäudemenu mit einer
-- Funktionalität versehen werden. Es obliegt dem Mapper für welche Gebäude
-- der Button angezeigt wird und welche Funktion er hat. Es ist nicht möglich
-- Kosten im Tooltip anzuzeigen.
--
-- Jeder Button kann immer nur mit einer Aktion versehen werden. Soll die
-- Aktion für verschiedene Gebäudetypen unterschiedlich sein, muss in der
-- Aktion eine Fallunterscheidung durchgeführt werden.
--
-- Ein optionaler Button benötigt immer drei Funktionen:
-- <ul>
-- <li>Action: Steuert, was der Button tut.</li>
-- <li>Tooltip: Steuert, welcher Beschreibungstext angezeigt wird.</li>
-- <li>Update: Steuert, wann und wie der Button angezeigt wird.</li>
-- </ul>
-- Alle drei Funktionen erhalten die ID des Buttons und die ID des Gebäudes,
-- das gerade selektiert ist.
--
-- <p><b>Alias:</b> AddBuildingButton</p>
--
-- @param[type=number]   _Index Index des Buttons
-- @param[type=function] _Action Aktion des Buttons
-- @param[type=function] _Tooltip Tooltip Control
-- @param[type=function] _Update Button Update
-- @within Anwenderfunktionen
--
-- @usage
-- -- Aktion
-- function ExampleButtonAction(_WidgetID, _BuildingID)
--     GUI.AddNote("Hier passiert etwas!");
-- end
-- -- Tooltip
-- function ExampleButtonTooltip(_WidgetID, _BuildingID)
--     UserSetTextNormal("Beschreibung", "Das ist die Beschreibung!");
-- end
-- -- Update
-- function ExampleButtonUpdate(_WidgetID, _BuildingID)
--     SetIcon(_WidgetID, {1, 1});
-- end
--
-- -- Beispiel für einen einfachen Button, der immer angezeigt wird, das Bild
-- -- eines Apfels trägt und eine Nachricht anzeigt.
-- API.AddCustomBuildingButton(1, ExampleButtonAction, ExampleButtonTooltip, ExampleButtonUpdate);
--
function API.AddCustomBuildingButton(_Index, _Action, _Tooltip, _Update)
    if not GUI then
        return;
    end
    if (type(_Index) ~= "number" or (_Index < 1 or _Index > 2)) then
        error("API.AddCustomBuildingButton: Index must be 1 or 2!");
        return;
    end
    if (type(_Action) ~= "function" or type(_Tooltip) ~= "function" or type(_Update) ~= "function") then
        error("API.AddCustomBuildingButton: Action, tooltip and update must be functions!");
        return;
    end
    return BundleBuildingButtons.Local:AddOptionalButton(
        _Index, _Action, _Tooltip, _Update
    );
end
AddBuildingButton = API.AddCustomBuildingButton;

---
-- Entfernt den optionalen Gebäudeschalter mit dem angegebenen Index.
--
-- <p><b>Alias:</b> DeleteBuildingButton</p>
--
-- @param[type=number] _Index Index des Buttons
-- @within Anwenderfunktionen
--
-- @usage
-- -- Entfernt die Konfiguration für Button 1
-- API.RemoveCustomBuildingButton(1);
--
function API.RemoveCustomBuildingButton(_Index)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.RemoveCustomBuildingButton("..tostring(_Index)..")");
        return;
    end
    if (type(_Index) ~= "number" or (_Index < 1 or _Index > 2)) then
        error("API.RemoveCustomBuildingButton: Index must be 1 or 2!");
        return;
    end
    return BundleBuildingButtons.Local:DeleteOptionalButton(_Index);
end
DeleteBuildingButton = API.RemoveCustomBuildingButton;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleBuildingButtons = {
    Local = {
        Data = {
            OptionalButton1 = {
                UseButton = false,
            },
            OptionalButton2 = {
                UseButton = false,
            },

            StoppedBuildings = {},
            Downgrade = true,
        },

        Description = {
            Downgrade = {
                Title = {
                    de = "Rückbau",
                    en = "Downgrade",
                },
                Text = {
                    de = "- Reißt eine Stufe des Gebäudes ein {cr}- Der überschüssige Arbeiter wird entlassen",
                    en = "- Destroy one level of this building {cr}- The surplus worker will be dismissed",
                },
                Disabled = {
                    de = "Kann nicht zurückgebaut werden!",
                    en = "Can not be downgraded yet!",
                },
            },

            SingleStop = {
                Title = {
                    de = "Arbeit anhalten/aufnehmen",
                    en = "Start/Stop Work",
                },
                Text = {
                    de = "- Startet oder stoppe die Arbeit in diesem Betrieb",
                    en = "- Continue or stop work for this building",
                },
            },
        },
    },
}

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local:Install()
    self:OverwriteHouseMenuButtons();
    self:OverwriteToggleTrap();
    self:OverwriteGateOpenClose();
    self:OverwriteAutoToggle();

    Core:AppendFunction("GameCallback_GUI_SelectionChanged", self.OnSelectionChanged);
end

---
-- Das aktuell selektierte Gebäude wird um eine Stufe zurückgebaut.
--
-- Ein Gebäude der Stufe 1 wird zerstört. Aktuell ist dies aber inaktiv.
--
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local:DowngradeBuilding()
    Sound.FXPlay2DSound("ui\\menu_click");
    local Selected = GUI.GetSelectedEntity();
    GUI.DeselectEntity(Selected);
    if Logic.GetUpgradeLevel(Selected) > 0 then
        local AmountToHurt = math.ceil(Logic.GetEntityMaxHealth(Selected) / 2);
        if Logic.GetEntityHealth(Selected) >= AmountToHurt then
            GUI.SendScriptCommand([[Logic.HurtEntity(]] ..Selected.. [[, ]] ..AmountToHurt.. [[)]]);
        end
    else
        local AmountToHurt = Logic.GetEntityMaxHealth(Selected);
        GUI.SendScriptCommand([[Logic.HurtEntity(]] ..Selected.. [[, ]] ..AmountToHurt.. [[)]]);
    end
end

---
-- Fügt einen Button dem Hausmenü hinzu. Es können nur 2 Buttons
-- hinzugefügt werden. Buttons brauchen immer eine Action-, eine
-- Tooltip- und eine Update-Funktion.
--
-- @param[type=number]   _idx              Indexposition des Button (1 oder 2)
-- @param[type=function] _actionFunction   Action-Funktion (String in Global)
-- @param[type=function] _tooltipFunction  Tooltip-Funktion (String in Global)
-- @param[type=function] _updateFunction   Update-Funktion (String in Global)
-- @within Internal
-- @local
-- @see API.AddCustomBuildingButton
--
function BundleBuildingButtons.Local:AddOptionalButton(_idx, _actionFunction, _tooltipFunction, _updateFunction)
    assert(_idx == 1 or _idx == 2);
    local wID = {
        XGUIEng.GetWidgetID("/InGame/Root/Normal/BuildingButtons/GateAutoToggle"),
        XGUIEng.GetWidgetID("/InGame/Root/Normal/BuildingButtons/GateOpenClose"),
    };
    BundleBuildingButtons.Local.Data["OptionalButton".._idx].WidgetID = wID[_idx];
    BundleBuildingButtons.Local.Data["OptionalButton".._idx].UseButton = true;
    BundleBuildingButtons.Local.Data["OptionalButton".._idx].ActionFunction = _actionFunction;
    BundleBuildingButtons.Local.Data["OptionalButton".._idx].TooltipFunction = _tooltipFunction;
    BundleBuildingButtons.Local.Data["OptionalButton".._idx].UpdateFunction = _updateFunction;
end

---
-- Entfernt den Zusatz-Button auf dem Index.
--
-- @param[type=number] _idx Indexposition des Button (1 oder 2)
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local:DeleteOptionalButton(_idx)
    assert(_idx == 1 or _idx == 2);
    local wID = {
        XGUIEng.GetWidgetID("/InGame/Root/Normal/BuildingButtons/GateAutoToggle"),
        XGUIEng.GetWidgetID("/InGame/Root/Normal/BuildingButtons/GateOpenClose"),
    };
    BundleBuildingButtons.Local.Data["OptionalButton".._idx].WidgetID = wID[_idx];
    BundleBuildingButtons.Local.Data["OptionalButton".._idx].UseButton = false;
    BundleBuildingButtons.Local.Data["OptionalButton".._idx].ActionFunction = nil;
    BundleBuildingButtons.Local.Data["OptionalButton".._idx].TooltipFunction = nil;
    BundleBuildingButtons.Local.Data["OptionalButton".._idx].UpdateFunction = nil;
end

---
-- Überschreibt die GUI-Funktionen des inaktiven Schalters für automatisches
-- Umschalten von Torsperren.
--
-- Diese Funktion implementiert den optionalen Schalter #1.
--
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local:OverwriteAutoToggle()
    GUI_BuildingButtons.GateAutoToggleClicked = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local EntityID = GUI.GetSelectedEntity();
        if not BundleBuildingButtons.Local.Data.OptionalButton1.ActionFunction then
            return;
        end
        BundleBuildingButtons.Local.Data.OptionalButton1.ActionFunction(CurrentWidgetID, EntityID);
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GUI_BuildingButtons.GateAutoToggleMouseOver = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local EntityID = GUI.GetSelectedEntity();
        if not BundleBuildingButtons.Local.Data.OptionalButton1.TooltipFunction then
            return;
        end
        BundleBuildingButtons.Local.Data.OptionalButton1.TooltipFunction(CurrentWidgetID, EntityID);
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GUI_BuildingButtons.GateAutoToggleUpdate = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local EntityID = GUI.GetSelectedEntity();
        local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
        local Health = Logic.GetEntityHealth(EntityID);

        SetIcon(CurrentWidgetID, {8,16});

        if EntityID == nil
        or Logic.IsBuilding(EntityID) == 0
        or not BundleBuildingButtons.Local.Data.OptionalButton1.UpdateFunction
        or not BundleBuildingButtons.Local.Data.OptionalButton1.UseButton
        or Logic.IsConstructionComplete(EntityID) == 0 then
            XGUIEng.ShowWidget(CurrentWidgetID, 0);
            return;
        end

        if Logic.BuildingDoWorkersStrike(EntityID) == true
        or Logic.IsBuildingBeingUpgraded(EntityID) == true
        or Logic.IsBuildingBeingKnockedDown(EntityID) == true
        or Logic.IsBurning(EntityID) == true
        or MaxHealth-Health > 0 then
            XGUIEng.ShowWidget(CurrentWidgetID, 0);
            return;
        end
        BundleBuildingButtons.Local.Data.OptionalButton1.UpdateFunction(CurrentWidgetID, EntityID);
    end
end

---
-- Überschreibt den inaktiven Button zum öffnen/schließen von Toren.
--
-- Diese Funktion implementiert den optionalen Schalter #2.
--
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local:OverwriteGateOpenClose()
    GUI_BuildingButtons.GateOpenCloseClicked = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local EntityID = GUI.GetSelectedEntity();
        if not BundleBuildingButtons.Local.Data.OptionalButton2.ActionFunction then
            return;
        end
        BundleBuildingButtons.Local.Data.OptionalButton2.ActionFunction(CurrentWidgetID, EntityID);
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GUI_BuildingButtons.GateOpenCloseMouseOver = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local EntityID = GUI.GetSelectedEntity();
        if not BundleBuildingButtons.Local.Data.OptionalButton2.TooltipFunction then
            return;
        end
        BundleBuildingButtons.Local.Data.OptionalButton2.TooltipFunction(CurrentWidgetID, EntityID);
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GUI_BuildingButtons.GateOpenCloseUpdate = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local EntityID = GUI.GetSelectedEntity();
        local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
        local Health = Logic.GetEntityHealth(EntityID);

        SetIcon(CurrentWidgetID, {8,16});

        if EntityID == nil
        or Logic.IsBuilding(EntityID) == 0
        or not BundleBuildingButtons.Local.Data.OptionalButton2.UpdateFunction
        or not BundleBuildingButtons.Local.Data.OptionalButton2.UseButton
        or Logic.IsConstructionComplete(EntityID) == 0
        or Logic.IsBuilding(EntityID) == 0 then
            XGUIEng.ShowWidget(CurrentWidgetID, 0);
            return;
        end

        if Logic.BuildingDoWorkersStrike(EntityID) == true
        or Logic.IsBuildingBeingUpgraded(EntityID) == true
        or Logic.IsBuildingBeingKnockedDown(EntityID) == true
        or Logic.IsBurning(EntityID) == true
        or MaxHealth-Health > 0 then
            XGUIEng.ShowWidget(CurrentWidgetID, 0);
            return;
        end
        BundleBuildingButtons.Local.Data.OptionalButton2.UpdateFunction(CurrentWidgetID, EntityID);
    end
end

---
-- Überschreibt den inaktiven Button zum umschalten der Torhausfallen.
--
-- Diese Funktion implementiert den Rückbau.
--
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local:OverwriteToggleTrap()
    GUI_BuildingButtons.TrapToggleClicked = function()
        BundleBuildingButtons.Local:DowngradeBuilding();
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GUI_BuildingButtons.TrapToggleMouseOver = function()
        BundleBuildingButtons.Local:TextNormal(
            API.ConvertPlaceholders(API.Localize(BundleBuildingButtons.Local.Description.Downgrade.Title)),
            API.ConvertPlaceholders(API.Localize(BundleBuildingButtons.Local.Description.Downgrade.Text)),
            API.ConvertPlaceholders(API.Localize(BundleBuildingButtons.Local.Description.Downgrade.Disabled))
        );
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GUI_BuildingButtons.TrapToggleUpdate = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local EntityID = GUI.GetSelectedEntity();
        local eName = Logic.GetEntityName(EntityID);
        local eType = Logic.GetEntityType(EntityID);
        local tID = GetTerritoryUnderEntity(EntityID);
        local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
        local Health = Logic.GetEntityHealth(EntityID);
        local Level = Logic.GetUpgradeLevel(EntityID);

        local x,y = XGUIEng.GetWidgetLocalPosition("/InGame/Root/Normal/BuildingButtons/Upgrade");
        SetIcon(CurrentWidgetID, {3,15});
        XGUIEng.SetWidgetLocalPosition(CurrentWidgetID, x+64, y);

        if EntityID == nil or Logic.IsBuilding(EntityID) == 0 then
            XGUIEng.ShowWidget(CurrentWidgetID, 0);
            return;
        end

        -- Protection - Submodul
        if BundleDestructionControl then
            -- Prüfe auf Namen
            if Inside(eName, BundleDestructionControl.Local.Data.Entities) then
                XGUIEng.ShowWidget(CurrentWidgetID, 0);
                return;
            end

            -- Prüfe auf Typen
            if Inside(eType, BundleDestructionControl.Local.Data.EntityTypes) then
                XGUIEng.ShowWidget(CurrentWidgetID, 0);
                return;
            end

            -- Prüfe auf Territorien
            if Inside(tID, BundleDestructionControl.Local.Data.OnTerritory) then
                XGUIEng.ShowWidget(CurrentWidgetID, 0);
                return;
            end

            -- Prüfe auf Category
            for k,v in pairs(BundleDestructionControl.Local.Data.EntityCategories) do
                if Logic.IsEntityInCategory(EntityID, v) == 1 then
                    XGUIEng.ShowWidget(CurrentWidgetID, 0);
                    return;
                end
            end
        end

        if Logic.IsConstructionComplete(EntityID) == 0
        or (Logic.IsEntityInCategory(EntityID, EntityCategories.OuterRimBuilding) == 0
        and Logic.IsEntityInCategory(EntityID, EntityCategories.CityBuilding) == 0)
        or not BundleBuildingButtons.Local.Data.Downgrade
        or Level == 0 then
            XGUIEng.ShowWidget(CurrentWidgetID, 0);
            return;
        end
        if Logic.BuildingDoWorkersStrike(EntityID) == true
        or Logic.IsBuildingBeingUpgraded(EntityID) == true
        or Logic.IsBuildingBeingKnockedDown(EntityID) == true
        or Logic.IsBurning(EntityID) == true
        or MaxHealth-Health > 0 then
            XGUIEng.DisableButton(CurrentWidgetID, 1);
        else
            XGUIEng.DisableButton(CurrentWidgetID, 0);
        end
    end
end

---
-- Diese Funktion überschreibt das House Menu, sodass Single stop fehlerfrei
-- funktioniert.
--
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local:OverwriteHouseMenuButtons()
    HouseMenuStopProductionClicked_Orig_SingleStop = HouseMenuStopProductionClicked;
    HouseMenuStopProductionClicked = function()
        HouseMenuStopProductionClicked_Orig_SingleStop();
        local WidgetName = HouseMenu.Widget.CurrentBuilding;
        local EntityType = Entities[WidgetName];
        local PlayerID = GUI.GetPlayerID();
        local Buildings = GetPlayerEntities(PlayerID, EntityType);

        for i=1, #Buildings, 1 do
            if BundleBuildingButtons.Local.Data.StoppedBuildings[Buildings[i]] ~= HouseMenu.StopProductionBool then
                BundleBuildingButtons.Local.Data.StoppedBuildings[Buildings[i]] = HouseMenu.StopProductionBool;
                GUI.SetStoppedState(Buildings[i], HouseMenu.StopProductionBool);
            end
        end
    end
end

---
-- Setzt einen für den Tooltip des aktuellen Widget einen neuen Text.
--
-- @param[type=string] _Title        Titel des Tooltip
-- @param[type=string] _Text         Text des Tooltip
-- @param[type=string] _DisabledText (optional) Textzusatz wenn inaktiv
-- @within BundleBuildingButtons
-- @local
--
function BundleBuildingButtons.Local:TextNormal(_Title, _Text, _DisabledText)
    local TooltipContainerPath = "/InGame/Root/Normal/TooltipNormal";
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath);
    local TooltipNameWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Name");
    local TooltipDescriptionWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Text");
    local TooltipBGWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/BG");
    local TooltipFadeInContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn");
    local PositionWidget = XGUIEng.GetCurrentWidgetID();
    GUI_Tooltip.ResizeBG(TooltipBGWidget, TooltipDescriptionWidget);
    local TooltipContainerSizeWidgets = {TooltipBGWidget};
    GUI_Tooltip.SetPosition(TooltipContainer, TooltipContainerSizeWidgets, PositionWidget);
    GUI_Tooltip.FadeInTooltip(TooltipFadeInContainer);

    _DisabledText = _DisabledText or "";
    local disabled = ""
    if XGUIEng.IsButtonDisabled(PositionWidget) == 1 and _DisabledText ~= "" and _Text ~= "" then
        disabled = disabled .. "{cr}{@color:255,32,32,255}" .. _DisabledText
    end

    XGUIEng.SetText(TooltipNameWidget, "{center}" .. _Title);
    XGUIEng.SetText(TooltipDescriptionWidget, _Text .. disabled);
    local Height = XGUIEng.GetTextHeight(TooltipDescriptionWidget, true);
    local W, H = XGUIEng.GetWidgetSize(TooltipDescriptionWidget);
    XGUIEng.SetWidgetSize(TooltipDescriptionWidget, W, Height);
end

---
-- Diese Funktion ist die Action von Single Stop.
--
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local.ButtonDefaultSingleStop_Action(WidgetID, EntityID)
    local StoppedState = BundleBuildingButtons.Local.Data.StoppedBuildings[EntityID] == true;
    GUI.SetStoppedState(EntityID, not StoppedState);
    BundleBuildingButtons.Local.Data.StoppedBuildings[EntityID] = not StoppedState;
end

---
-- Diese Funktion steuert den Tooltip von Single Stop.
--
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local.ButtonDefaultSingleStop_Tooltip(WidgetID, EntityID)
    BundleBuildingButtons.Local:TextNormal(
        API.ConvertPlaceholders(API.Localize(BundleBuildingButtons.Local.Description.SingleStop.Title)),
        API.ConvertPlaceholders(API.Localize(BundleBuildingButtons.Local.Description.SingleStop.Text))
    );
end

---
-- Diese Funktion ist der Update Job von Single Stop.
--
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local.ButtonDefaultSingleStop_Update(_WidgetID, _EntityID)
    local IsOuterRimBuilding = Logic.IsEntityInCategory(_EntityID, EntityCategories.OuterRimBuilding) == 1;
    local IsCityBuilding = Logic.IsEntityInCategory(_EntityID, EntityCategories.CityBuilding) == 1;
    if IsOuterRimBuilding == false and IsCityBuilding == false then
        XGUIEng.ShowWidget(_WidgetID, 0);
    end

    if BundleBuildingButtons.Local.Data.StoppedBuildings[_EntityID] == true then
        SetIcon(_WidgetID, {4, 12});
    else
        SetIcon(_WidgetID, {4, 13});
    end
end

---
-- Diese Funktion wird aufgerufen, sobald sich die Selektion ändert.
--
-- Hier werden die ausgeblendeten ungenutzten Gebäudeschalter eingeblendet.
--
-- @param[type=number] _Source Quelle der Änderung
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local.OnSelectionChanged(_Source)
    local eID = GUI.GetSelectedEntity();
    local eType = Logic.GetEntityType(eID);

    XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/GateAutoToggle",1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/GateOpenClose",1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/TrapToggle",1);
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleBuildingButtons");

