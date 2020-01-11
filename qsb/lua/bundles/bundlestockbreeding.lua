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
-- Zusätzlich können die Tiere kleiner gespawnt werden und wachsen dann mit
-- der Zeit automatisch. Diese Funktionalität kann abgeschaltet werden.
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
-- @param[type=boolean] _Flag Schafzucht aktiv/inaktiv
-- @within Anwenderfunktionen
--
-- @usage
-- -- Schafsaufzucht ist erlaubt
-- API.UseBreedSheeps(true);
--
function API.UseBreedSheeps(_Flag)
    if not GUI then
        API.Bridge(string.format("API.UseBreedSheeps(%b)", _Flag));
        return;
    end

    BundleStockbreeding.Local.Data.BreedSheeps = _Flag == true;
    if _Flag == true then
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
-- @param[type=boolean] _Flag Kuhzucht aktiv/inaktiv
-- @within Anwenderfunktionen
--
-- @usage
-- -- Es können keine Kühe gezüchtet werden
-- API.UseBreedCattle(false);
--
function API.UseBreedCattle(_Flag)
    if not GUI then
        API.Bridge(string.format("API.UseBreedCattle(%b)", _Flag));
        return;
    end

    BundleStockbreeding.Local.Data.BreedCattle = _Flag == true;
    if _Flag == true then
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
        API.Bridge(string.format("API.SetSheepGrainCost(%d)", _Amount));
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
        API.Bridge(string.format("API.SetCattleGrainCost(%d)", _Amount));
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
        API.Bridge(string.format("API.SetSheepNeeded(%d)", _Amount));
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
        API.Bridge(string.format("API.SetCattleNeeded(%d)", _Amount));
        return;
    end
    if type(_Amount) ~= "number" or _Amount < 0 or _Amount > 5 then
        API.Fatal("API.SetCattleNeeded: Needed amount is invalid!");
    end
    BundleStockbreeding.Local.Data.CattleNeeded = _Amount;
end
SetCattleNeeded = API.SetCattleNeeded;

---
-- Setzt den Typen des verwendeten Schafes.
--
-- Der EntityTyp muss nicht angegeben werden. Folgende Werte sind möglich:
-- <ul>
-- <li>0: Zufällig bei Zucht gewählt</li>
-- <li>1: X_A_Sheep01 (weiß)</li>
-- <li>2: X_A_Sheep02 (grau)</li>
-- </ul>
--
-- <b>Alias</b>: SetSheepType
--
-- @param[type=boolean] _Flag Baby Mode aktivieren/deaktivieren
-- @within Anwenderfunktionen
--
-- @usage
-- -- Es wird jedes mal zufällig ausgewählt
-- API.SetSheepType(0);
-- -- Es werden nur graue Schafe erzeugt
-- API.SetSheepType(2);
--
function API.SetSheepType(_Type)
    if not GUI then
        API.Bridge(string.format("API.SetSheepType(%d)", _Type));
        return;
    end
    if type(_Type) ~= "number" or _Type > 2 or _Type < 0 then
        API.Fatal("API.SetCattleNeeded: Needed amount is invalid!");
    end
    BundleStockbreeding.Local.Data.SheepType = _Type * (-1);
end
SetSheepType = API.SetSheepType;

---
-- Aktiviert oder deaktiviert den "Baby Mode" für Schafe.
--
-- Ist der Modus aktiv, werden neu gekaufte Tiere mit 40% ihrer Große erzeugt
-- und wachseln allmählich heran. Dies ist nur kosmetisch und hat keinen
-- Einfluss auf ihre Funktion.
--
-- <b>Alias</b>: SetSheepBabyMode
--
-- @param[type=boolean] _Flag Baby Mode aktivieren/deaktivieren
-- @within Anwenderfunktionen
--
-- @usage
-- -- Schafe werden verkleinert erzeugt und wachsen mit der Zeit
-- API.SetSheepBabyMode(true);
--
function API.SetSheepBabyMode(_Flag)
    if not GUI then
        API.Bridge(string.format("API.SetSheepBabyMode(%b)", _Flag == true));
        return;
    end
    BundleStockbreeding.Local.Data.SheepBaby = _Flag == true;
end
SetSheepBabyMode = API.SetSheepBabyMode;

---
-- Aktiviert oder deaktiviert den "Baby Mode" für Kühe.
--
-- Ist der Modus aktiv, werden neu gekaufte Tiere mit 40% ihrer Große erzeugt
-- und wachseln allmählich heran. Dies ist nur kosmetisch und hat keinen
-- Einfluss auf ihre Funktion.
--
-- <b>Alias</b>: SetCattleBaby
--
-- @param[type=boolean] _Flag Baby Mode aktivieren/deaktivieren
-- @within Anwenderfunktionen
--
-- @usage
-- -- Kühe werden verkleinert erzeugt und wachsen mit der Zeit
-- API.SetCattleBabyMode(true);
--
function API.SetCattleBabyMode(_Flag)
    if not GUI then
        API.Bridge(string.format("API.SetCattleBabyMode(%b)", _Flag == true));
        return;
    end
    BundleStockbreeding.Local.Data.CattleBaby = _Flag == true;
end
SetCattleBaby = API.SetCattleBaby;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleStockbreeding = {
    Global = {
        Data = {
            AnimalChildren = {},
            GrothTime = 45,
            ShrinkedSize = 0.4,
        }
    },
    Local = {
        Data = {
            BreedCattle = true,
            CattleBaby = false,
            CattleCosts = 10,
            CattleNeeded = 3,
            CattleKnightTitle = 0,
            CattleMoneyCost = 300,

            BreedSheeps = true,
            SheepBaby = false,
            SheepType = -1,
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
                    fr = "acheter du bétail"
                },
                Text = {
                    de = "- Kauft ein Nutztier {cr}- Nutztiere produzieren Rohstoffe",
                    fr = "- Achète un animal de la ferme {cr} - les animaux de la ferme produisent des matières premières",
                    en = "- Buy a farm animal {cr}- Farm animals produce resources",
                },
                Disabled = {
                    de = "Kauf ist nicht möglich!",
                    fr = "L'achat n'est pas possible!",
                    en = "Buy not possible!",
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
function BundleStockbreeding.Global:Install()
    StartSimpleJobEx(self.AnimalGrouthJob);
end

---
-- Gibt die Skalierung (Größe) eines Entity zurück.
-- @param              _Entity Skriptname oder EntityID des Entity
-- @return[type=number] Skalierung des Entity
-- @within Internal
-- @local
--
function BundleStockbreeding.Global:GetScale(_Entity)
    local ID = GetID(_Entity);
    local SV = (QSB.HistoryEdition and -42) or -45;
    local IntVal = Logic.GetEntityScriptingValue(ID, SV);
    return Core:ScriptingValueIntegerToFloat(IntVal);
end

---
-- Setzt die Skalierung (Größe) eines Entity.
-- @param              _Entity Skriptname oder EntityID des Entity
-- @param[type=number] _Scale  Zu setzende Größe
-- @within Internal
-- @local
--
function BundleStockbreeding.Global:SetScale(_Entity, _Scale)
    local ID = GetID(_Entity);
    local SV = (QSB.HistoryEdition and -42) or -45;
    local IntVal = Core:ScriptingValueFloatToInteger(_Scale);
    Logic.SetEntityScriptingValue(ID, SV, IntVal);
end

---
-- Erzeugt ein Nutztier vor dem Gatter und zieht die Kosten ab.
--
-- Falls der "Baby Mode" für die Tierart aktiv ist, wird das Tier kleiner
-- gemacht und zur Wachstumskontrolle hinzugefügt.
--
-- @param[type=number]  _PastureID Gatter ID
-- @param[type=number]  _Type      Typ des Tieres
-- @param[type=number]  _GrainCost Getreidekosten
-- @param[type=boolean] _Shrink    Tier geschrumptf erzeugen
-- @within Internal
-- @local
--
function BundleStockbreeding.Global:CreateAnimal(_PastureID, _Type, _GrainCost, _Shrink)
    local PlayerID = Logic.EntityGetPlayer(_PastureID);
    local x, y = Logic.GetBuildingApproachPosition(_PastureID);
    local Type = (_Type > 0 and _Type) or (_Type == 0 and Entities["A_X_Sheep0" ..math.random(1, 2)]) or Entities["A_X_Sheep0" ..(_Type * (-1))];
    local ID = Logic.CreateEntity(Type, x, y, 0, PlayerID);
    AddGood(Goods.G_Grain, _GrainCost, PlayerID);
    if _Shrink == true then
        self:SetScale(ID, self.Data.ShrinkedSize);
        table.insert(self.Data.AnimalChildren, {ID, self.Data.GrothTime});
    end
end

---
-- Steuert das Wachstum aller registrierten Tiere.
-- @within Internal
-- @local
--
function BundleStockbreeding.Global:AnimalGrouthController()
    for k, v in pairs(self.Data.AnimalChildren) do
        if v then
            if not IsExisting(v[1]) then
                self.Data.AnimalChildren[k] = nil;
            else
                self.Data.AnimalChildren[k][2] = v[2] -1;
                if v[2] < 0 then
                    self.Data.AnimalChildren[k][2] = self.Data.GrothTime;
                    local Scale = self:GetScale(v[1]);
                    if Scale < 1 then
                        self:SetScale(v[1], Scale + 0.1);
                    else
                        self.Data.AnimalChildren[k] = nil;
                    end
                end
            end
        end
    end
end

-- Controller Job ruft nur eigentlichen Controller auf.
function BundleStockbreeding.Global.AnimalGrouthJob()
    BundleStockbreeding.Global:AnimalGrouthController();
end

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
-- Diese Funktion löst den Kauf eines Nutztieres aus. Erzeugung des Tieres und
-- Abzug der Kosten erfolg im globalen Skript.
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
            BundleStockbreeding.Global:CreateAnimal(
                ]].._eID..[[, Entities.A_X_Cow01, ]] ..Cost.. [[, ]] ..tostring(self.Data.CattleBaby == true).. [[
            )
        ]]);
    elseif eType == Entities.B_SheepPasture then
        local Cost = BundleStockbreeding.Local.Data.SheepCosts * (-1);
        GUI.SendScriptCommand([[
            BundleStockbreeding.Global:CreateAnimal(
                ]].._eID..[[, ]]..self.Data.SheepType..[[, ]] ..Cost.. [[, ]] ..tostring(self.Data.SheepBaby == true).. [[
            )
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
                API.Localize(BundleStockbreeding.Local.Description.BuyCattle.Title),
                API.Localize(BundleStockbreeding.Local.Description.BuyCattle.Text),
                API.Localize(BundleStockbreeding.Local.Description.BuyCattle.Disabled),
                {Goods.G_Grain, BundleStockbreeding.Local.Data.CattleCosts},
                false
            );
        elseif BuildingEntityType == Entities.B_SheepPasture then
            BundleStockbreeding.Local:TextCosts(
                API.Localize(BundleStockbreeding.Local.Description.BuyCattle.Title),
                API.Localize(BundleStockbreeding.Local.Description.BuyCattle.Text),
                API.Localize(BundleStockbreeding.Local.Description.BuyCattle.Disabled),
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

