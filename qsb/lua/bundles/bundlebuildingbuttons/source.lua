-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleBuildingButtons                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle erweitert das Gebäudemenü für verschiedene Gebäude um weitere
-- Funktionen. Es ist bspw. möglich ungenutzte Schalter frei zu programmieren.
--
-- Bekannte Funktionen sind natürlich auch wieder mit dabei.
--
-- Das wichtigste auf einen Blick:
-- <ul>
--
-- <li>Viehzucht: Hernzüchten von Kühen und Schafen in Gattern
-- <br>Kühe züchten:<br><a href="#API.UseBreedCattle">Zucht aktivieren</a>,
-- <a href="#API.SetCattleNeeded">Mindestanzahl Tiere festlegen</a>,
-- <a href="#API.SetCattleGrainCost">Getreidekosten festlegen</a>
-- <br>Schafe züchten:<br><a href="#API.UseBreedSheeps">Zucht aktivieren</a>,
-- <a href="#API.SetSheepNeeded">Mindestanzahl Tiere festlegen</a>,
-- <a href="#API.SetSheepGrainCost">Getreidekosten festlegen</a>
-- </li>
--
-- <li>Single Stop: Anhalten der Produktion von einzelnen Gebäuden
-- <br><a href="#API.ActivateSingleStop">aktivieren</a>,
-- <a href="#API.ActivateSingleStop">deaktivieren</a>
-- </li>
--
-- <li>Downgrade: Rückbau von Stadt- und Rohstoffgebäuden
-- <br><a href="#API.ActivateDowngrade">aktivieren</a>,
-- <a href="#API.DeactivateDowngrade">deaktivieren</a>
-- </li>
--
-- </ul>
--
-- @within Modulbeschreibung
-- @set sort=false
--
BundleBuildingButtons = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Aktiviert die Single Stop Buttons. Single Stop ermöglicht das Anhalten
-- eines einzelnen Betriebes, anstelle des Anhaltens aller Betriebe des
-- gleichen Typs.
--
-- Im Gegensatz zur Viehzucht und zum Rückbau, welche feste eigeständige
-- Buttons sind, handelt es sich hierbei um einen Custom Button. Single
-- Stop belegt Index 1.
--
-- <p><b>Alias:</b> ActivateSingleStop</p>
--
-- @within Anwenderfunktionen
-- @see API.AddCustomBuildingButton
--
function API.ActivateSingleStop()
    if not GUI then
        API.Bridge("API.ActivateSingleStop()");
        return;
    end

    BundleBuildingButtons.Local:AddOptionalButton(
        2,
        BundleBuildingButtons.Local.ButtonDefaultSingleStop_Action,
        BundleBuildingButtons.Local.ButtonDefaultSingleStop_Tooltip,
        BundleBuildingButtons.Local.ButtonDefaultSingleStop_Update
    );
end
ActivateSingleStop = API.ActivateSingleStop;

---
-- Deaktiviert die Single Stop Buttons.
--
-- <p><b>Alias:</b> DeactivateSingleStop</p>
--
-- @within Anwenderfunktionen
--
function API.DeactivateSingleStop()
    if not GUI then
        API.Bridge("API.DeactivateSingleStop()");
        return;
    end
    BundleBuildingButtons.Local:DeleteOptionalButton(2);
end
DeactivateSingleStop = API.DeactivateSingleStop;

---
-- Aktiviere Rückbau bei Stadt- und Rohstoffgebäuden. Die Rückbaufunktion
-- erlaubt es dem Spieler bei Stadt- und Rohstoffgebäude der Stufe 2 und 3
-- jeweils eine Stufe zu zerstören. Der überflüssige Arbeiter wird entlassen.
--
-- <p><b>Alias:</b> UseDowngrade</p>
--
-- @within Anwenderfunktionen
--
-- @usage
-- API.ActivateDowngrade();
--
function API.ActivateDowngrade()
    if not GUI then
        API.Bridge("API.ActivateDowngrade()");
        return;
    end
    BundleBuildingButtons.Local.Data.Downgrade = true;
end
ActivateDowngrade = API.ActivateDowngrade;

---
-- Deaktiviert den Rückbau von Gebäuden.
--
-- <p><b>Alias:</b> DeactivateDowngrade</p>
--
-- @within Anwenderfunktionen
--
-- @usage
-- API.DeactivateDowngrade();
--
function API.DeactivateDowngrade()
    if not GUI then
        API.Bridge("API.DeactivateDowngrade()");
        return;
    end
    BundleBuildingButtons.Local.Data.Downgrade = false;
end
DeactivateDowngrade = API.DeactivateDowngrade;

---
-- Erlaube oder verbiete dem Spieler Schafe zu züchten.
--
-- <p><b>Alias:</b> UseBreedSheeps</p>
--
-- @param _flag [boolean] Schafzucht aktiv/inaktiv
-- @within Anwenderfunktionen
--
-- @usage
-- -- Schafsaufzucht ist erlaubt
-- API.UseBreedSheeps(true);
--
function API.UseBreedSheeps(_flag)
    if not GUI then
        API.Bridge("API.UseBreedSheeps(" ..tostring(_flag).. ")");
        return;
    end

    BundleBuildingButtons.Local.Data.BreedSheeps = _flag == true;
    if _flag == true then
        local Price = MerchantSystem.BasePricesOrigBundleBuildingButtons[Goods.G_Sheep]
        MerchantSystem.BasePrices[Goods.G_Sheep] = Price;
        API.Bridge("MerchantSystem.BasePrices[Goods.G_Sheep] = " ..Price);
    else
        local Price = BundleBuildingButtons.Local.Data.SheepMoneyCost;
        MerchantSystem.BasePrices[Goods.G_Sheep] = Price;
        API.Bridge("MerchantSystem.BasePrices[Goods.G_Sheep] = " ..Price);
    end
end
UseBreedSheeps = API.UseBreedSheeps;

---
-- Erlaube oder verbiete dem Spieler Kühe zu züchten.
--
-- <p><b>Alias:</b> UseBreedCattle</p>
--
-- @param _flag [boolean] Kuhzucht aktiv/inaktiv
-- @within Anwenderfunktionen
--
-- @usage
-- -- Es können keine Kühe gezüchtet werden
-- API.UseBreedCattle(false);
--
function API.UseBreedCattle(_flag)
    if not GUI then
        API.Bridge("API.UseBreedCattle(" ..tostring(_flag).. ")");
        return;
    end

    BundleBuildingButtons.Local.Data.BreedCattle = _flag == true;
    if _flag == true then
        local Price = MerchantSystem.BasePricesOrigBundleBuildingButtons[Goods.G_Cow];
        MerchantSystem.BasePrices[Goods.G_Cow] = Price;
        API.Bridge("MerchantSystem.BasePrices[Goods.G_Cow] = " ..Price);
    else
        local Price = BundleBuildingButtons.Local.Data.CattleMoneyCost;
        MerchantSystem.BasePrices[Goods.G_Cow] = Price;
        API.Bridge("MerchantSystem.BasePrices[Goods.G_Cow] = " ..Price);
    end
end
UseBreedCattle = API.UseBreedCattle;

---
-- Setzt die Menge an Getreide, das zur Zucht eines Tieres benötigt wird.
--
-- <p><b>Alias:</b> SetSheepGrainCost</p>
--
-- @param _Amount [number] Getreidekosten
-- @within Anwenderfunktionen
--
-- @usage
-- -- Wucherpreise zum Züchten!
-- API.SetSheepGrainCost(50);
--
function API.SetSheepGrainCost(_Amount)
    if not GUI then
        API.Bridge("API.SetSheepGrainCost(" .._Amount.. ")");
        return;
    end
    BundleBuildingButtons.Local.Data.SheepCosts = _Amount;
end
SetSheepGrainCost = API.SetSheepGrainCost;

---
-- Setzt die Menge an Getreide, das zur Zucht eines Tieres benötigt wird.
--
-- <p><b>Alias:</b> SetCattleGrainCost</p>
--
-- @param _Amount [number] Getreidekosten
-- @within Anwenderfunktionen
--
-- @usage
-- -- Wucherpreise zum Züchten!
-- API.SetCattleGrainCost(50);
--
function API.SetCattleGrainCost(_Amount)
    if not GUI then
        API.Bridge("API.SetCattleGrainCost(" .._Amount.. ")");
        return;
    end
    BundleBuildingButtons.Local.Data.CattleCosts = _Amount;
end
SetCattleGrainCost = API.SetCattleGrainCost;

---
-- Setzt die zur Zucht benötigte Menge an benötigten Tieren in einem Gatter.
--
-- <p><b>Alias:</b> SetSheepNeeded</p>
--
-- @param _Amount [number] Benötigte Menge
-- @within Anwenderfunktionen
--
-- @usage
-- -- Es wird ein volles Gatter zur Zucht benötigt:
-- API.SetSheepNeeded(5);
--
function API.SetSheepNeeded(_Amount)
    if not GUI then
        API.Bridge("API.SetSheepNeeded(" .._Amount.. ")");
        return;
    end
    if type(_Amount) ~= "number" or _Amount < 0 or _Amount > 5 then
        API.Dbg("API.SetSheepNeeded: Needed amount is invalid!");
    end
    BundleBuildingButtons.Local.Data.SheepNeeded = _Amount;
end
SetSheepNeeded = API.SetSheepNeeded;

---
-- Setzt die zur Zucht benötigte Menge an benötigten Tieren in einem Gatter.
--
-- <p><b>Alias:</b> SetCattleNeeded</p>
--
-- @param _Amount [number] Benötigte Menge
-- @within Anwenderfunktionen
--
-- @usage
-- -- Es werden keine Kühe zur Zucht benötigt:
-- API.SetCattleNeeded(0);
--
function API.SetCattleNeeded(_Amount)
    if not GUI then
        API.Bridge("API.SetCattleNeeded(" .._Amount.. ")");
        return;
    end
    if type(_Amount) ~= "number" or _Amount < 0 or _Amount > 5 then
        API.Dbg("API.SetCattleNeeded: Needed amount is invalid!");
    end
    BundleBuildingButtons.Local.Data.CattleNeeded = _Amount;
end
SetCattleNeeded = API.SetCattleNeeded;

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
-- <b>Achtung:</b> Wenn die Funktion aus dem globalen Skript ausgeführt wird,
-- müssen sich die Buttonfunktionen im lokalen Skript befinden. Die Namen der
-- Funktionen sind in diesem Fall als Zeichenkette zu übergeben!
--
-- <p><b>Alias:</b> AddBuildingButton</p>
--
-- @param _Index   [number] Index des Buttons
-- @param _Action  [function] Aktion des Buttons
-- @param _Tooltip [function] Tooltip Control
-- @param _Update  [function] Button Update
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
        API.Bridge("API.AddCustomBuildingButton("..tostring(_Index)..","..tostring(_Action)..","..tostring(_Tooltip)..","..tostring(_Update)..",)");
        return;
    end
    if (type(_Index) ~= "number" or (_Index < 1 or _Index > 2)) then
        API.Dbg("API.AddCustomBuildingButton: Index must be 1 or 2!");
        return;
    end
    if (type(_Action) ~= "function" or type(_Tooltip) ~= "function" or type(_Update) ~= "function") then
        API.Dbg("API.AddCustomBuildingButton: Action, tooltip and update must be functions!");
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
-- @param _Index   [number] Index des Buttons
-- @within Anwenderfunktionen
--
-- @usage
-- -- Entfernt die Konfiguration für Button 1
-- API.RemoveCustomBuildingButton(1);
--
function API.RemoveCustomBuildingButton(_Index)
    if not GUI then
        API.Dbg("API.RemoveCustomBuildingButton("..tostring(_Index)..")");
        return;
    end
    if (type(_Index) ~= "number" or (_Index < 1 or _Index > 2)) then
        API.Dbg("API.RemoveCustomBuildingButton: Index must be 1 or 2!");
        return;
    end
    return BundleBuildingButtons.Local:DeleteOptionalButton(_Index);
end
DeleteBuildingButton = API.RemoveCustomBuildingButton;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleBuildingButtons = {
    Global = {
        Data = {}
    },
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

            BreedCattle = true,
            CattleCosts = 10,
            CattleNeeded = 3,
            CattleKnightTitle = 0,
            CattleMoneyCost = 300,

            BreedSheeps = true,
            SheepCosts = 10,
            SheepNeeded = 3,
            SheepKnightTitle = 0,
            SheepMoneyCost = 300,
        },

        Description = {
            Downgrade = {
                Title = {
                    de = "Rückbau",
                    en = "Downgrade",
                },
                Text = {
                    de = "- Reißt eine Stufe des Geb?udes ein {cr}- Der überschüssige Arbeiter wird entlassen",
                    en = "- Destroy one level of this building {cr}- The surplus worker will be dismissed",
                },
                Disabled = {
                    de = "Kann nicht zurückgebaut werden!",
                    en = "Can not be downgraded yet!",
                },
            },

            BuyCattle = {
                Title = {
                    de = "Nutztier kaufen",
                    en = "Buy Farm animal",
                },
                Text = {
                    de = "- Kauft ein Nutztier {cr}- Nutztiere produzieren Rohstoffe",
                    en = "- Buy a farm animal {cr}- Farm animals produce resources",
                },
                Disabled = {
                    de = "Kauf ist nicht möglich!",
                    en = "Buy not possible!",
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

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function BundleBuildingButtons.Global:Install()
end



-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local:Install()
    MerchantSystem.BasePricesOrigBundleBuildingButtons                = {};

    MerchantSystem.BasePricesOrigBundleBuildingButtons[Goods.G_Sheep] = MerchantSystem.BasePrices[Goods.G_Sheep];
    MerchantSystem.BasePricesOrigBundleBuildingButtons[Goods.G_Cow]   = MerchantSystem.BasePrices[Goods.G_Cow];

    MerchantSystem.BasePrices[Goods.G_Sheep] = BundleBuildingButtons.Local.Data.SheepMoneyCost;
    MerchantSystem.BasePrices[Goods.G_Cow]   = BundleBuildingButtons.Local.Data.CattleMoneyCost;

    self:OverwriteHouseMenuButtons();
    self:OverwriteBuySiegeEngine();
    self:OverwriteToggleTrap();
    self:OverwriteGateOpenClose();
    self:OverwriteAutoToggle();

    Core:AppendFunction("GameCallback_GUI_SelectionChanged", self.OnSelectionChanged);
end

---
-- Diese Funktion erzeugt ein Nutztier und entfernt das Getreide vom Spieler.
--
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local:BuyAnimal(_eID)
    Sound.FXPlay2DSound("ui\\menu_click");
    local eType = Logic.GetEntityType(_eID);

    if eType == Entities.B_CattlePasture then
        local Cost = BundleBuildingButtons.Local.Data.CattleCosts * (-1);
        GUI.SendScriptCommand([[
            local pID = Logic.EntityGetPlayer(]].._eID..[[)
            local x, y = Logic.GetBuildingApproachPosition(]].._eID..[[)
            Logic.CreateEntity(Entities.A_X_Cow01, x, y, 0, pID)
            AddGood(Goods.G_Grain, ]] ..Cost.. [[, pID)
        ]]);
    elseif eType == Entities.B_SheepPasture then
        local Cost = BundleBuildingButtons.Local.Data.SheepCosts * (-1);
        GUI.SendScriptCommand([[
            local pID = Logic.EntityGetPlayer(]].._eID..[[)
            local x, y = Logic.GetBuildingApproachPosition(]].._eID..[[)
            Logic.CreateEntity(Entities.A_X_Sheep01, x, y, 0, pID)
            AddGood(Goods.G_Grain, ]] ..Cost.. [[, pID)
        ]]);
    end
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
-- @param _idx              Indexposition des Button (1 oder 2)
-- @param _actionFunction   Action-Funktion (String in Global)
-- @param _tooltipFunction  Tooltip-Funktion (String in Global)
-- @param _updateFunction   Update-Funktion (String in Global)
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
-- @param _idx Indexposition des Button (1 oder 2)
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
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        BundleBuildingButtons.Local:TextNormal(
            BundleBuildingButtons.Local.Description.Downgrade.Title[lang],
            BundleBuildingButtons.Local.Description.Downgrade.Text[lang],
            BundleBuildingButtons.Local.Description.Downgrade.Disabled[lang]
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
        if BundleConstructionControl then
            -- Prüfe auf Namen
            if Inside(eName, BundleConstructionControl.Local.Data.Entities) then
                XGUIEng.ShowWidget(CurrentWidgetID, 0);
                return;
            end

            -- Prüfe auf Typen
            if Inside(eType, BundleConstructionControl.Local.Data.EntityTypes) then
                XGUIEng.ShowWidget(CurrentWidgetID, 0);
                return;
            end

            -- Prüfe auf Territorien
            if Inside(tID, BundleConstructionControl.Local.Data.OnTerritory) then
                XGUIEng.ShowWidget(CurrentWidgetID, 0);
                return;
            end

            -- Prüfe auf Category
            for k,v in pairs(BundleConstructionControl.Local.Data.EntityCategories) do
                if Logic.IsEntityInCategory(_BuildingID, v) == 1 then
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
-- Diese Funktion überschreibt die Belagerungswaffenwerkstattsteuerung. Dabei
-- wird die Nutztierzucht implementiert.
--
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local:OverwriteBuySiegeEngine()
    GUI_BuildingButtons.BuySiegeEngineCartMouseOver = function(_EntityType,_TechnologyType)
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local BarrackID = GUI.GetSelectedEntity();
        local BuildingEntityType = Logic.GetEntityType(BarrackID);

        if  BuildingEntityType ~= Entities.B_SiegeEngineWorkshop
        and BuildingEntityType ~= Entities.B_CattlePasture
        and BuildingEntityType ~= Entities.B_SheepPasture then
            return;
        end

        local Costs = {Logic.GetUnitCost(BarrackID, _EntityType)}
        if BuildingEntityType == Entities.B_CattlePasture then
            BundleBuildingButtons.Local:TextCosts(
                BundleBuildingButtons.Local.Description.BuyCattle.Title[lang],
                BundleBuildingButtons.Local.Description.BuyCattle.Text[lang],
                BundleBuildingButtons.Local.Description.BuyCattle.Disabled[lang],
                {Goods.G_Grain, BundleBuildingButtons.Local.Data.CattleCosts},
                false
            );
        elseif BuildingEntityType == Entities.B_SheepPasture then
            BundleBuildingButtons.Local:TextCosts(
                BundleBuildingButtons.Local.Description.BuyCattle.Title[lang],
                BundleBuildingButtons.Local.Description.BuyCattle.Text[lang],
                BundleBuildingButtons.Local.Description.BuyCattle.Disabled[lang],
                {Goods.G_Grain, BundleBuildingButtons.Local.Data.SheepCosts},
                false
            );
        else
            GUI_Tooltip.TooltipBuy(Costs,nil,nil,_TechnologyType);
        end
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GUI_BuildingButtons.BuySiegeEngineCartClicked_OrigTHEA_Buildings = GUI_BuildingButtons.BuySiegeEngineCartClicked
    GUI_BuildingButtons.BuySiegeEngineCartClicked = function(_EntityType)
        local BarrackID = GUI.GetSelectedEntity()
        local PlayerID = GUI.GetPlayerID()
        local eType = Logic.GetEntityType(BarrackID)
        if eType == Entities.B_CattlePasture or eType == Entities.B_SheepPasture then
            BundleBuildingButtons.Local:BuyAnimal(BarrackID);
        else
            GUI_BuildingButtons.BuySiegeEngineCartClicked_OrigTHEA_Buildings(_EntityType)
        end
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GUI_BuildingButtons.BuySiegeEngineCartUpdate = function(_Technology)
        local PlayerID = GUI.GetPlayerID();
        local KnightTitle = Logic.GetKnightTitle(PlayerID);
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local EntityID = GUI.GetSelectedEntity();
        local EntityType = Logic.GetEntityType(EntityID);
        local grain = GetPlayerResources(Goods.G_Grain,PlayerID);
        local pos = GetPosition(EntityID);

        if EntityType == Entities.B_SiegeEngineWorkshop then
            XGUIEng.ShowWidget(CurrentWidgetID,1);
            if _Technology == Technologies.R_BatteringRam then
                SetIcon(CurrentWidgetID, {9,5});
            elseif _Technology == Technologies.R_SiegeTower then
                SetIcon(CurrentWidgetID, {9,6});
            elseif _Technology == Technologies.R_Catapult then
                SetIcon(CurrentWidgetID, {9,4});
            end
        elseif EntityType == Entities.B_CattlePasture then
            local CattlePasture = GetPlayerEntities(PlayerID,Entities.B_CattlePasture);
            local cows          = {Logic.GetPlayerEntitiesInArea(PlayerID,Entities.A_X_Cow01,pos.X,pos.Y,800,16)};
            local curAnimal     = Logic.GetNumberOfPlayerEntitiesInCategory(PlayerID,EntityCategories.CattlePasture);
            local maxAnimal     = #CattlePasture*5;

            SetIcon(CurrentWidgetID, {3,16})

            if _Technology == Technologies.R_Catapult then
                if BundleBuildingButtons.Local.Data.BreedCattle then
                    XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons",1);
                    XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/BuyCatapultCart",1);

                    if curAnimal >= maxAnimal then
                        XGUIEng.DisableButton(CurrentWidgetID, 1);
                    elseif grain < BundleBuildingButtons.Local.Data.CattleCosts then
                        XGUIEng.DisableButton(CurrentWidgetID, 1);
                    elseif KnightTitle < BundleBuildingButtons.Local.Data.CattleKnightTitle then
                        XGUIEng.DisableButton(CurrentWidgetID, 1);
                    elseif cows[1] < BundleBuildingButtons.Local.Data.CattleNeeded then
                        XGUIEng.DisableButton(CurrentWidgetID, 1);
                    else
                        XGUIEng.DisableButton(CurrentWidgetID, 0);
                    end
                end
            else
                XGUIEng.ShowWidget(CurrentWidgetID,0);
            end
        elseif EntityType == Entities.B_SheepPasture then
            local SheepPasture     = GetPlayerEntities(PlayerID,Entities.B_SheepPasture);
            local sheeps        = {Logic.GetPlayerEntitiesInArea(PlayerID,Entities.A_X_Sheep01,pos.X,pos.Y,800,16)};
            table.remove(sheeps, 1);
            local sheeps2        = {Logic.GetPlayerEntitiesInArea(PlayerID,Entities.A_X_Sheep02,pos.X,pos.Y,800,16)};
            table.remove(sheeps2, 1);
            local curAnimal     = Logic.GetNumberOfPlayerEntitiesInCategory(PlayerID,EntityCategories.SheepPasture);
            local maxAnimal     = #SheepPasture*5;

            sheeps = Array_Append(sheeps,sheeps2)
            SetIcon(CurrentWidgetID, {4,1})

            if _Technology == Technologies.R_Catapult then
                if BundleBuildingButtons.Local.Data.BreedSheeps then
                    XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons",1);
                    XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/BuyCatapultCart",1);

                    if curAnimal >= maxAnimal then
                        XGUIEng.DisableButton(CurrentWidgetID, 1);
                    elseif grain < BundleBuildingButtons.Local.Data.SheepCosts then
                        XGUIEng.DisableButton(CurrentWidgetID, 1);
                    elseif #sheeps < BundleBuildingButtons.Local.Data.SheepKnightTitle then
                        XGUIEng.DisableButton(CurrentWidgetID, 1);
                    elseif #sheeps < BundleBuildingButtons.Local.Data.SheepNeeded then
                        XGUIEng.DisableButton(CurrentWidgetID, 1);
                    else
                        XGUIEng.DisableButton(CurrentWidgetID, 0);
                    end
                end
            else
                XGUIEng.ShowWidget(CurrentWidgetID,0);
            end
        else
            XGUIEng.ShowWidget(CurrentWidgetID,0);
            return;
        end

        if Logic.IsConstructionComplete(GUI.GetSelectedEntity()) == 0 then
            XGUIEng.ShowWidget(CurrentWidgetID,0);
            return;
        end

        if EntityType ~= Entities.B_SheepPasture and EntityType ~= Entities.B_CattlePasture then
            local TechnologyState = Logic.TechnologyGetState(PlayerID, _Technology);
            if EnableRights == nil or EnableRights == false then
                XGUIEng.DisableButton(CurrentWidgetID,0);
                return
            end
            if TechnologyState == TechnologyStates.Researched then
                XGUIEng.DisableButton(CurrentWidgetID,0);
            else
                XGUIEng.DisableButton(CurrentWidgetID,1);
            end
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
    HouseMenuStopProductionClicked_Orig_tHEA_SingleStop = HouseMenuStopProductionClicked;
    HouseMenuStopProductionClicked = function()
        HouseMenuStopProductionClicked_Orig_tHEA_SingleStop();
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
-- Ändert die Textur eines Icons im House Menu.
--
-- @param _Widget Icon Widget
-- @param _Icon   Icon Textur
-- @within BundleBuildingButtons
-- @local
--
function BundleBuildingButtons.Local:HouseMenuIcon(_Widget, _Icon)
    if type(_Icon) == "table" then
        if type(_Icon[3]) == "string" then
            local ButtonState = 1;
            if XGUIEng.IsButton(_Widget) == 1 then
                ButtonState = 7;
            end

            local u0, u1, v0, v1;
            u0 = (_Coordinates[1] - 1) * 64;
            v0 = (_Coordinates[2] - 1) * 64;
            u1 = (_Coordinates[1]) * 64;
            v1 = (_Coordinates[2]) * 64;
            XGUIEng.SetMaterialAlpha(_Widget, ButtonState, 255);
            XGUIEng.SetMaterialTexture(_Widget, ButtonState, _Icon[3].. "big.png");
            XGUIEng.SetMaterialUV(_Widget, ButtonState, u0, v0, u1, v1);
        else
            SetIcon(_Widget, _Icon);
        end
    else
        local screenSize = {GUI.GetScreenSize()};
        local Scale = 330;
        if screenSize[2] >= 800 then
            Scale = 260;
        end
        if screenSize[2] >= 1000 then
            Scale = 210;
        end
        XGUIEng.SetMaterialAlpha(_Widget, 1, 255);
        XGUIEng.SetMaterialTexture(_Widget, 1, _file);
        XGUIEng.SetMaterialUV(_Widget, 1, 0, 0, Scale, Scale);
    end
end

---
-- Setzt einen für den Tooltip des aktuellen Widget einen neuen Text.
--
-- @param _Title        Titel des Tooltip
-- @param _Text         Text des Tooltip
-- @param _DisabledText Textzusatz wenn inaktiv
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
-- Setzt den Kostentooltip des aktuellen Widgets.
--
-- @param _Title        Titel des Tooltip
-- @param _Text         Text des Tooltip
-- @param _DisabledText Textzusatz wenn inaktiv
-- @param _Costs        Kostentabelle
-- @param _InSettlement Kosten in Siedlung suchen
-- @within Internal
-- @local
--
function BundleBuildingButtons.Local:TextCosts(_Title, _Text, _DisabledText, _Costs, _InSettlement)
    local TooltipContainerPath = "/InGame/Root/Normal/TooltipBuy"
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath)
    local TooltipNameWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Name")
    local TooltipDescriptionWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Text")
    local TooltipBGWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/BG")
    local TooltipFadeInContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn")
    local TooltipCostsContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/Costs")
    local PositionWidget = XGUIEng.GetCurrentWidgetID()
    GUI_Tooltip.ResizeBG(TooltipBGWidget, TooltipDescriptionWidget)
    GUI_Tooltip.SetCosts(TooltipCostsContainer, _Costs, _InSettlement)
    local TooltipContainerSizeWidgets = {TooltipContainer, TooltipCostsContainer, TooltipBGWidget}
    GUI_Tooltip.SetPosition(TooltipContainer, TooltipContainerSizeWidgets, PositionWidget, nil, true)
    GUI_Tooltip.OrderTooltip(TooltipContainerSizeWidgets, TooltipFadeInContainer, TooltipCostsContainer, PositionWidget, TooltipBGWidget)
    GUI_Tooltip.FadeInTooltip(TooltipFadeInContainer)

    _DisabledText = _DisabledText or "";
    local disabled = ""
    if XGUIEng.IsButtonDisabled(PositionWidget) == 1 and _DisabledText ~= "" and _Text ~= "" then
        disabled = disabled .. "{cr}{@color:255,32,32,255}" .. _DisabledText
    end

    XGUIEng.SetText(TooltipNameWidget, "{center}" .. _Title)
    XGUIEng.SetText(TooltipDescriptionWidget, _Text .. disabled)
    local Height = XGUIEng.GetTextHeight(TooltipDescriptionWidget, true)
    local W, H = XGUIEng.GetWidgetSize(TooltipDescriptionWidget)
    XGUIEng.SetWidgetSize(TooltipDescriptionWidget, W, Height)
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
    local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    BundleBuildingButtons.Local:TextNormal(
        BundleBuildingButtons.Local.Description.SingleStop.Title[lang],
        BundleBuildingButtons.Local.Description.SingleStop.Text[lang]
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
-- @param _Source Quelle der Änderung
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

