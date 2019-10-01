-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleStockbreeding                                          # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht die Aufzucht von Nutzrieren wie Schafe und Kühe durch den Spieler.
-- 
-- Kosten für die Aufzucht oder die benötigte Menge an Tieren um mit der
-- Zucht zu beginnen, sind frei konfigurierbar.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleStockbreeding = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erlaube oder verbiete dem Spieler Schafe zu züchten.
--
-- Wenn der Spieler keine Schafe züchten soll, kann ihm dieses Recht durch
-- diese Funktion genommen werden. Natürlich kann das Recht auf diesem Weg
-- auch wieder zurückgegeben werden.
--
-- <p><b>Alias:</b> UseBreedSheeps</p>
--
-- @param[type=boolean] _flag Schafzucht aktiv/inaktiv
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

    BundleStockbreeding.Local.Data.BreedSheeps = _flag == true;
    if _flag == true then
        local Price = MerchantSystem.BasePricesOrigBundleStockbreeding[Goods.G_Sheep]
        MerchantSystem.BasePrices[Goods.G_Sheep] = Price;
        API.Bridge("MerchantSystem.BasePrices[Goods.G_Sheep] = " ..Price);
    else
        local Price = BundleStockbreeding.Local.Data.SheepMoneyCost;
        MerchantSystem.BasePrices[Goods.G_Sheep] = Price;
        API.Bridge("MerchantSystem.BasePrices[Goods.G_Sheep] = " ..Price);
    end
end
UseBreedSheeps = API.UseBreedSheeps;

---
-- Erlaube oder verbiete dem Spieler Kühe zu züchten.
--
-- Wenn der Spieler keine Kühe züchten soll, kann ihm dieses Recht durch
-- diese Funktion genommen werden. Natürlich kann das Recht auf diesem Weg
-- auch wieder zurückgegeben werden.
--
-- <p><b>Alias:</b> UseBreedCattle</p>
--
-- @param[type=boolean] _flag Kuhzucht aktiv/inaktiv
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

    BundleStockbreeding.Local.Data.BreedCattle = _flag == true;
    if _flag == true then
        local Price = MerchantSystem.BasePricesOrigBundleStockbreeding[Goods.G_Cow];
        MerchantSystem.BasePrices[Goods.G_Cow] = Price;
        API.Bridge("MerchantSystem.BasePrices[Goods.G_Cow] = " ..Price);
    else
        local Price = BundleStockbreeding.Local.Data.CattleMoneyCost;
        MerchantSystem.BasePrices[Goods.G_Cow] = Price;
        API.Bridge("MerchantSystem.BasePrices[Goods.G_Cow] = " ..Price);
    end
end
UseBreedCattle = API.UseBreedCattle;

---
-- Mit dieser Funktion werden die Getreidekosten für die Aufzucht von Schafen
-- festgelegt.
--
-- Will der Spieler nun ein Schaf züchten, muss er mindestens die angegebene
-- Menge an Getreide besitzen. Das Getreide wird dann aus dem Lager entfernt.
--
-- <p><b>Alias:</b> SetSheepGrainCost</p>
--
-- @param[type=number] _Amount Getreidekosten
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
    BundleStockbreeding.Local.Data.SheepCosts = _Amount;
end
SetSheepGrainCost = API.SetSheepGrainCost;

---
-- Mit dieser Funktion werden die Getreidekosten für die Aufzucht von Kühen
-- festgelegt.
--
-- Will der Spieler nun eine Kuh züchten, muss er mindestens die angegebene
-- Menge an Getreide besitzen. Das Getreide wird dann aus dem Lager entfernt.
--
-- <p><b>Alias:</b> SetCattleGrainCost</p>
--
-- @param[type=number] _Amount Getreidekosten
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
    BundleStockbreeding.Local.Data.CattleCosts = _Amount;
end
SetCattleGrainCost = API.SetCattleGrainCost;

---
-- Legt die Anzahlö an Schafen fest, die zur Zucht eines neuen Trieres
-- mindestens in einem Gatter vorhanden sein müssen.
--
-- <p><b>Alias:</b> SetSheepNeeded</p>
--
-- @param[type=number] _Amount Benötigte Menge
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
        API.Fatal("API.SetSheepNeeded: Needed amount is invalid!");
    end
    BundleStockbreeding.Local.Data.SheepNeeded = _Amount;
end
SetSheepNeeded = API.SetSheepNeeded;

---
-- Legt die Anzahl an Kühen fest, die zur Zucht eines neuen Trieres mindestens
-- in einem Gatter vorhanden sein müssen.
--
-- <p><b>Alias:</b> SetCattleNeeded</p>
--
-- @param[type=number] _Amount Benötigte Menge
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
        API.Fatal("API.SetCattleNeeded: Needed amount is invalid!");
    end
    BundleStockbreeding.Local.Data.CattleNeeded = _Amount;
end
SetCattleNeeded = API.SetCattleNeeded;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleStockbreeding = {
    Local = {
        Data = {
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
function BundleStockbreeding.Local:Install()
    MerchantSystem.BasePricesOrigBundleStockbreeding                = {};
    MerchantSystem.BasePricesOrigBundleStockbreeding[Goods.G_Sheep] = MerchantSystem.BasePrices[Goods.G_Sheep];
    MerchantSystem.BasePricesOrigBundleStockbreeding[Goods.G_Cow]   = MerchantSystem.BasePrices[Goods.G_Cow];

    MerchantSystem.BasePrices[Goods.G_Sheep] = BundleStockbreeding.Local.Data.SheepMoneyCost;
    MerchantSystem.BasePrices[Goods.G_Cow]   = BundleStockbreeding.Local.Data.CattleMoneyCost;

    self:OverwriteBuySiegeEngine();
end

---
-- Diese Funktion erzeugt ein Nutztier und entfernt das Getreide vom Spieler.
--
-- @within Internal
-- @local
--
function BundleStockbreeding.Local:BuyAnimal(_eID)
    Sound.FXPlay2DSound("ui\\menu_click");
    local eType = Logic.GetEntityType(_eID);

    if eType == Entities.B_CattlePasture then
        local Cost = BundleStockbreeding.Local.Data.CattleCosts * (-1);
        GUI.SendScriptCommand([[
            local PlayerID = Logic.EntityGetPlayer(]].._eID..[[)
            local x, y = Logic.GetBuildingApproachPosition(]].._eID..[[)
            Logic.CreateEntity(Entities.A_X_Cow01, x, y, 0, PlayerID)
            AddGood(Goods.G_Grain, ]] ..Cost.. [[, PlayerID)
        ]]);
    elseif eType == Entities.B_SheepPasture then
        local Cost = BundleStockbreeding.Local.Data.SheepCosts * (-1);
        GUI.SendScriptCommand([[
            local PlayerID = Logic.EntityGetPlayer(]].._eID..[[)
            local x, y = Logic.GetBuildingApproachPosition(]].._eID..[[)
            Logic.CreateEntity(Entities.A_X_Sheep01, x, y, 0, PlayerID)
            AddGood(Goods.G_Grain, ]] ..Cost.. [[, PlayerID)
        ]]);
    end
end

---
-- Diese Funktion überschreibt die Belagerungswaffenwerkstattsteuerung. Dabei
-- wird die Nutztierzucht implementiert.
--
-- @within Internal
-- @local
--
function BundleStockbreeding.Local:OverwriteBuySiegeEngine()
    GUI_BuildingButtons.BuySiegeEngineCartMouseOver = function(_EntityType,_TechnologyType)
        local lang = QSB.Language;
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
            BundleStockbreeding.Local:TextCosts(
                BundleStockbreeding.Local.Description.BuyCattle.Title[lang],
                BundleStockbreeding.Local.Description.BuyCattle.Text[lang],
                BundleStockbreeding.Local.Description.BuyCattle.Disabled[lang],
                {Goods.G_Grain, BundleStockbreeding.Local.Data.CattleCosts},
                false
            );
        elseif BuildingEntityType == Entities.B_SheepPasture then
            BundleStockbreeding.Local:TextCosts(
                BundleStockbreeding.Local.Description.BuyCattle.Title[lang],
                BundleStockbreeding.Local.Description.BuyCattle.Text[lang],
                BundleStockbreeding.Local.Description.BuyCattle.Disabled[lang],
                {Goods.G_Grain, BundleStockbreeding.Local.Data.SheepCosts},
                false
            );
        else
            GUI_Tooltip.TooltipBuy(Costs,nil,nil,_TechnologyType);
        end
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GUI_BuildingButtons.BuySiegeEngineCartClicked_Orig_Stockbreeding = GUI_BuildingButtons.BuySiegeEngineCartClicked
    GUI_BuildingButtons.BuySiegeEngineCartClicked = function(_EntityType)
        local BarrackID = GUI.GetSelectedEntity()
        local PlayerID = GUI.GetPlayerID()
        local eType = Logic.GetEntityType(BarrackID)
        if eType == Entities.B_CattlePasture or eType == Entities.B_SheepPasture then
            BundleStockbreeding.Local:BuyAnimal(BarrackID);
        else
            GUI_BuildingButtons.BuySiegeEngineCartClicked_Orig_Stockbreeding(_EntityType)
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

            if _Technology == Technologies.R_Catapult and BundleStockbreeding.Local.Data.BreedCattle then
                XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons",1);
                XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/BuyCatapultCart",1);

                if curAnimal >= maxAnimal then
                    XGUIEng.DisableButton(CurrentWidgetID, 1);
                elseif grain < BundleStockbreeding.Local.Data.CattleCosts then
                    XGUIEng.DisableButton(CurrentWidgetID, 1);
                elseif KnightTitle < BundleStockbreeding.Local.Data.CattleKnightTitle then
                    XGUIEng.DisableButton(CurrentWidgetID, 1);
                elseif cows[1] < BundleStockbreeding.Local.Data.CattleNeeded then
                    XGUIEng.DisableButton(CurrentWidgetID, 1);
                else
                    XGUIEng.DisableButton(CurrentWidgetID, 0);
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

            if _Technology == Technologies.R_Catapult and BundleStockbreeding.Local.Data.BreedSheeps then
                XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons",1);
                XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/BuyCatapultCart",1);

                if curAnimal >= maxAnimal then
                    XGUIEng.DisableButton(CurrentWidgetID, 1);
                elseif grain < BundleStockbreeding.Local.Data.SheepCosts then
                    XGUIEng.DisableButton(CurrentWidgetID, 1);
                elseif #sheeps < BundleStockbreeding.Local.Data.SheepKnightTitle then
                    XGUIEng.DisableButton(CurrentWidgetID, 1);
                elseif #sheeps < BundleStockbreeding.Local.Data.SheepNeeded then
                    XGUIEng.DisableButton(CurrentWidgetID, 1);
                else
                    XGUIEng.DisableButton(CurrentWidgetID, 0);
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
-- Setzt den Kostentooltip des aktuellen Widgets.
--
-- @param[type=string]  _Title        Titel des Tooltip
-- @param[type=string]  _Text         Text des Tooltip
-- @param[type=string]  _DisabledText (optional) Textzusatz wenn inaktiv
-- @param[type=number]  _Costs        Kostentabelle
-- @param[type=boolean] _InSettlement Kosten in Siedlung suchen
-- @within Internal
-- @local
--
function BundleStockbreeding.Local:TextCosts(_Title, _Text, _DisabledText, _Costs, _InSettlement)
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

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleStockbreeding");

