-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntitySelection                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Bundle kann die Selektion von Entities gesteuert werden.
--
-- <p>Das wichtigste auf einen Blick:</p>
-- <ul>
-- <li><a href="#API.DisableReleaseSoldiers">Einheiten entlassen</a></li>
-- <li><a href="#API.GetSelectedEntities">Selektierte Entities ermitteln</a></li>
-- </ul>
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleEntitySelection = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Deaktiviert oder aktiviert das Nachfüllen von Trebuchets.
-- @param _Flag [boolean] Deaktiviert (false) / Aktiviert (true)
-- @within Anwenderfunktionen
--
-- @usage
-- API.DisableRefillTrebuchet(true);
--
function API.DisableRefillTrebuchet(_Flag)
    if not GUI then
        API.Bridge("API.DisableRefillTrebuchet(" ..tostring(_Flag).. ")");
        return;
    end
    API.Bridge("BundleEntitySelection.Local.Data.RefillTrebuchet = " ..tostring(not _Flag));
    BundleEntitySelection.Local.Data.RefillTrebuchet = not _Flag;
end

---
-- Deaktiviert oder aktiviert das Entlassen von Dieben.
-- @param _Flag [boolean] Deaktiviert (false) / Aktiviert (true)
-- @within Anwenderfunktionen
--
-- @usage
-- API.DisableReleaseThieves(false);
--
function API.DisableReleaseThieves(_Flag)
    if not GUI then
        API.Bridge("API.DisableReleaseThieves(" ..tostring(_Flag).. ")");
        return;
    end
    BundleEntitySelection.Local.Data.ThiefRelease = _Flag == true;
end

---
-- Deaktiviert oder aktiviert das Entlassen von Kriegsmaschinen.
-- @param _Flag [boolean] Deaktiviert (false) / Aktiviert (true)
-- @within Anwenderfunktionen
--
-- @usage
-- API.DisableReleaseSiegeEngines(true);
--
function API.DisableReleaseSiegeEngines(_Flag)
    if not GUI then
        API.Bridge("API.DisableReleaseSiegeEngines(" ..tostring(_Flag).. ")");
        return;
    end
    BundleEntitySelection.Local.Data.SiegeEngineRelease = _Flag == true;
end

---
-- Deaktiviert oder aktiviert das Entlassen von Soldaten.
-- @param _Flag [boolean] Deaktiviert (false) / Aktiviert (true)
-- @within Anwenderfunktionen
--
-- @usage
-- API.DisableReleaseSoldiers(false);
--
function API.DisableReleaseSoldiers(_Flag)
    if not GUI then
        API.Bridge("API.DisableReleaseSoldiers(" ..tostring(_Flag).. ")");
        return;
    end
    BundleEntitySelection.Local.Data.MilitaryRelease = _Flag == true;
end

---
-- Prüpft ob das Entity selektiert ist.
--
-- @param _Entity [string|number] Entity das selektiert sein soll
-- @return [boolean] Entity ist selektiert
-- @within Anwenderfunktionen
--
-- @usage
-- if API.IsEntityInSelection("hakim") then
--     -- Do something
-- end
--
function API.IsEntityInSelection(_Entity)
    if IsExisting(_Entity) then
        local EntityID = GetID(_Entity);
        local SelectedEntities = BundleEntitySelection.Global.Data.SelectedEntities;
        if GUI then
            SelectedEntities = {GUI.GetSelectedEntities()};
        end
        for i= 1, #SelectedEntities, 1 do
            if SelectedEntities[i] == EntityID then
                return true;
            end
        end
    end
    return false;
end
IsEntitySelected = API.IsEntityInSelection;

---
-- Gibt die ID des selektierten Entity zurück.
--
-- Wenn mehr als ein Entity selektiert sind, wird das erste Entity
-- zurückgegeben. Sind keine Entities selektiert, wird 0 zurückgegeben.
--
-- @return [number] ID des selektierten Entities
-- @within Anwenderfunktionen
--
-- @usage
-- local SelectedEntity = API.GetSelectedEntity();
--
function API.GetSelectedEntity()
    local SelectedEntity = BundleEntitySelection.Global.Data.SelectedEntities[1];
    if GUI then
        SelectedEntity = GUI.GetSelectedEntity();
    end
    return SelectedEntity or 0;
end
GetSelectedEntity = API.GetSelectedEntity;

---
-- Gibt alle selektierten Entities zurück.
--
-- @return [table] ID des selektierten Entities
-- @within Anwenderfunktionen
--
-- @usage
-- local Selection = API.GetSelectedEntities();
--
function API.GetSelectedEntities()
    local SelectedEntities = BundleEntitySelection.Global.Data.SelectedEntities;
    if GUI then
        SelectedEntities = {GUI.GetSelectedEntities()};
    end
    return SelectedEntities;
end
GetSelectedEntities = API.GetSelectedEntities;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleEntitySelection = {
    Global = {
        Data = {
            RefillTrebuchet = true,
            AmmunitionUnderway = {},
            TrebuchetIDToCart = {},
            SelectedEntities = {};
        },
    },
    Local = {
        Data = {
            RefillTrebuchet = true,
            ThiefRelease = true,
            SiegeEngineRelease = true,
            MilitaryRelease = true,

            Tooltips = {
                KnightButton = {
                    Title = {
                        de = "Ritter selektieren",
                        en = "Select Knight",
                    },
                    Text = {
                        de = "- Klick selektiert den Ritter {cr}- Doppelklick springt zum Ritter{cr}- STRG halten selektiert alle Ritter",
                        en = "- Click selects the knight {cr}- Double click jumps to knight{cr}- Press CTRL to select all knights",
                    },
                },

                BattalionButton = {
                    Title = {
                        de = "Militär selektieren",
                        en = "Select Units",
                    },
                    Text = {
                        de = "- Selektiert alle Militäreinheiten {cr}- SHIFT halten um auch Munitionswagen und Trebuchets auszuwählen",
                        en = "- Selects all military units {cr}- Press SHIFT to additionally select ammunition carts and trebuchets",
                    },
                },

                ReleaseSoldiers = {
                    Title = {
                        de = "Militär entlassen",
                        en = "Release military unit",
                    },
                    Text = {
                        de = "- Eine Militäreinheit entlassen {cr}- Soldaten werden nacheinander entlassen",
                        en = "- Dismiss a military unit {cr}- Soldiers will be dismissed each after another",
                    },
                    Disabled = {
                        de = "Kann nicht entlassen werden!",
                        en = "Releasing is impossible!",
                    },
                },

                TrebuchetCart = {
                    Title = {
                        de = "Trebuchetwagen",
                        en = "Trebuchet cart",
                    },
                    Text = {
                        de = "- Kann einmalig zum Trebuchet ausgebaut werden",
                        en = "- Can uniquely be transmuted into a trebuchet",
                    },
                },

                Trebuchet = {
                    Title = {
                        de = "Trebuchet",
                        en = "Trebuchet",
                    },
                    Text = {
                        de = "- Kann über weite Strecken Gebäude angreifen {cr}- Kann Gebäude in Brand stecken {cr}- Kann nur durch Munitionsanforderung befüllt werden {cr}- Trebuchet kann manuell zurückgeschickt werden",
                        en = "- Can perform long range attacks on buildings {cr}- Can set buildings on fire {cr}- Can only be filled by ammunition request {cr}- The trebuchet can be manually send back to the city",
                    },
                },

                TrebuchetRefiller = {
                    Title = {
                        de = "Aufladen",
                        en = "Refill",
                    },
                    Text = {
                        de = "- Läd das Trebuchet mit Karren aus dem Lagerhaus nach {cr}- Benötigt die Differenz an Steinen {cr}- Kann jeweils nur einen Wagen zu selben Zeit senden",
                        en = "- Refill the Trebuchet with a cart from the storehouse {cr}- Stones for missing ammunition required {cr}- Only one cart at the time allowed",
                    },
                },
            },
        },
    },

};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function BundleEntitySelection.Global:Install()
end

---
-- Deaktiviert oder aktiviert das Nachfüllen von Trebuchets.
-- @param _Boolean Nachfüllen deaktiviert
-- @within Internal
-- @local
--
function BundleEntitySelection.Global:DeactivateRefillTrebuchet(_Boolean)
    self.Data.RefillTrebuchet = not _Boolean;
    Logic.ExecuteInLuaLocalState([[
        BundleEntitySelection.Local:DeactivateRefillTrebuchet(]]..tostring(_Boolean)..[[)
    ]]);
end

---
-- Baut ein Trebuchet zu einem Trebuchet-Wagen ab.
-- @param _EntityID EntityID of Trebuchet
-- @within Internal
-- @local
--
function BundleEntitySelection.Global:MilitaryDisambleTrebuchet(_EntityID)
    local x,y,z = Logic.EntityGetPos(_EntityID);
    local PlayerID = Logic.EntityGetPlayer(_EntityID);

    -- Externes Callback für das Kartenskript
    -- Bricht die Ausführung dieser Funktion ab!
    if GameCallback_QSB_OnDisambleTrebuchet then
        GameCallback_QSB_OnDisambleTrebuchet(_EntityID, PlayerID, x, y, z);
        return;
    end

    if self.Data.AmmunitionUnderway[_EntityID] then
        API.Message {
            de = "Eine Munitionslieferung ist auf dem Weg!",
            en = "A ammunition card is on the way!",
        };
        return;
    end

    Logic.CreateEffect(EGL_Effects.E_Shockwave01, x, y, 0);
    Logic.SetEntityInvulnerabilityFlag(_EntityID, 1);
    Logic.SetEntitySelectableFlag(_EntityID, 0);
    Logic.SetVisible(_EntityID, false);

    local TrebuchetCart = self.Data.TrebuchetIDToCart[_EntityID];
    if TrebuchetCart ~= nil then
        Logic.SetEntityInvulnerabilityFlag(TrebuchetCart, 0);
        Logic.SetEntitySelectableFlag(TrebuchetCart, 1);
        Logic.SetVisible(TrebuchetCart, true);
    else
        TrebuchetCart = Logic.CreateEntity(Entities.U_SiegeEngineCart, x, y, 0, PlayerID);
        self.Data.TrebuchetIDToCart[_EntityID] = TrebuchetCart;
    end

    Logic.DEBUG_SetSettlerPosition(TrebuchetCart, x, y);
    Logic.SetTaskList(TrebuchetCart, TaskLists.TL_NPC_IDLE);
    Logic.ExecuteInLuaLocalState([[
        GUI.SelectEntity(]]..TrebuchetCart..[[)
    ]]);
end

---
-- Baut einen Trebuchet-Wagen zu einem Trebuchet aus.
-- @param _EntityID EntityID of Trebuchet
-- @within Internal
-- @local
--
function BundleEntitySelection.Global:MilitaryErectTrebuchet(_EntityID)
    local x,y,z = Logic.EntityGetPos(_EntityID);
    local PlayerID = Logic.EntityGetPlayer(_EntityID);

    -- Externes Callback für das Kartenskript
    -- Bricht die Ausführung dieser Funktion ab!
    if GameCallback_QSB_OnErectTrebuchet then
        GameCallback_QSB_OnErectTrebuchet(_EntityID, PlayerID, x, y, z);
        return;
    end

    Logic.CreateEffect(EGL_Effects.E_Shockwave01, x, y, 0);
    Logic.SetEntityInvulnerabilityFlag(_EntityID, 1);
    Logic.SetEntitySelectableFlag(_EntityID, 0);
    Logic.SetVisible(_EntityID, false);

    local Trebuchet;
    for k, v in pairs(self.Data.TrebuchetIDToCart) do
        if v == _EntityID then
            Trebuchet = tonumber(k);
        end
    end
    if Trebuchet == nil then
        Trebuchet = Logic.CreateEntity(Entities.U_Trebuchet, x, y, 0, PlayerID);
        self.Data.TrebuchetIDToCart[Trebuchet] = _EntityID;
    end

    Logic.SetEntityInvulnerabilityFlag(Trebuchet, 0);
    Logic.SetEntitySelectableFlag(Trebuchet, 1);
    Logic.SetVisible(Trebuchet, true);
    Logic.DEBUG_SetSettlerPosition(Trebuchet, x, y);
    Logic.ExecuteInLuaLocalState([[
        GUI.SelectEntity(]]..Trebuchet..[[)
    ]]);
end

---
-- Erzeugt einen Wagen, der zu dem Trebuchet fährt und es auffüll.
-- @param _EntityID EntityID of Trebuchet
-- @within Internal
-- @local
--
function BundleEntitySelection.Global:MilitaryCallForRefiller(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local StoreID = Logic.GetStoreHouse(PlayerID);
    local HaveAmount = Logic.GetAmmunitionAmount(_EntityID);
    local Stones = GetPlayerResources(Goods.G_Stone, PlayerID)

    -- Externes Callback für das Kartenskript
    -- Bricht die Ausführung dieser Funktion ab!
    if GameCallback_tHEA_OnRefillerCartCalled then
        GameCallback_tHEA_OnRefillerCartCalled(_EntityID, PlayerID, StoreID, HaveAmount, Stones);
        return;
    end

    if self.Data.AmmunitionUnderway[_EntityID] or StoreID == 0 then
        API.Message {
            de = "Eine Munitionslieferung ist auf dem Weg!",
            en = "A ammunition card is on the way!",
        };
        return;
    end

    if HaveAmount == 10 or Stones < 10-HaveAmount then
        API.Message {
            de = "Nicht genug Steine oder das Trebuchet ist voll!",
            en = "Not enough stones or the trebuchet is full!",
        };
        return;
    end

    local x,y = Logic.GetBuildingApproachPosition(StoreID);
    local CartID = Logic.CreateEntity(Entities.U_AmmunitionCart, x, y, 0, PlayerID);
    self.Data.AmmunitionUnderway[_EntityID] = {CartID, 10-HaveAmount};
    Logic.SetEntityInvulnerabilityFlag(CartID, 1);
    Logic.SetEntitySelectableFlag(CartID, 0);
    AddGood(Goods.G_Stone, (10-HaveAmount)*(-1), PlayerID);

    StartSimpleJobEx( function(_Trebuchet)
        local CartID = self.Data.AmmunitionUnderway[_EntityID][1];
        local Amount = self.Data.AmmunitionUnderway[_EntityID][2];

        if not IsExisting(CartID) or not IsExisting(_Trebuchet) then
            self.Data.AmmunitionUnderway[_EntityID] = nil;
            return true;
        end

        if not Logic.IsEntityMoving(CartID) then
            local x,y,z = Logic.EntityGetPos(_Trebuchet);
            Logic.MoveSettler(CartID, x, y);
        end

        if IsNear(CartID, _Trebuchet, 500) then
            for i=1, Amount, 1 do
                Logic.RefillAmmunitions(_Trebuchet);
            end
            DestroyEntity(CartID);
        end
    end, _EntityID);
end

-- Local Script ----------------------------------------------------------------

---
-- Initialisiert das Bundle im lokalen Skript.
-- @within Internal
-- @local
--
function BundleEntitySelection.Local:Install()
    self:OverwriteSelectAllUnits();
    self:OverwriteSelectKnight();
    self:OverwriteNamesAndDescription();
    self:OverwriteThiefDeliver();
    self:OverwriteMilitaryDismount();
    self:OverwriteMultiselectIcon();
    self:OverwriteMilitaryDisamble();
    self:OverwriteMilitaryErect();
    self:OverwriteMilitaryCommands();
    self:OverwriteGetStringTableText();

    Core:AppendFunction(
        "GameCallback_GUI_SelectionChanged",
        self.OnSelectionCanged
    );
end

---
-- Deaktiviert oder aktiviert das Nachfüllen von Trebuchets.
-- @param _Boolean Nachfüllen deaktiviert
-- @within Internal
-- @local
--
function BundleEntitySelection.Local:DeactivateRefillTrebuchet(_Boolean)
    self.Data.RefillTrebuchet = not _Boolean;
end

---
-- Callback-Funktion, die aufgerufen wird, wenn sich die Selektion ändert.
--
-- @param _Source Selection Source
-- @within Internal
-- @local
--
function BundleEntitySelection.Local.OnSelectionCanged(_Source)
    local SelectedEntities = {GUI.GetSelectedEntities()}
    local PlayerID = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local EntityType = Logic.GetEntityType(EntityID);

    -- Schreibe die selektierten Entities ins globale Skript
    local SelectedEntitiesString = API.ConvertTableToString(SelectedEntities);
    API.Bridge("BundleEntitySelection.Global.Data.SelectedEntities = " ..SelectedEntitiesString);

    if EntityID ~= nil then
        if EntityType == Entities.U_SiegeEngineCart then
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection", 1);
            XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection", 0);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/BGMilitary", 1);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons", 1);
            XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/DialogButtons", 0);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons/SiegeEngineCart", 1);
        elseif EntityType == Entities.U_Trebuchet then
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection", 1);
            XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection", 0);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/BGMilitary", 1);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons", 1);
            XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/DialogButtons", 0);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military", 1);
            XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military", 1);
            if BundleEntitySelection.Local.Data.RefillTrebuchet then
                XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military/Attack", 1);
            else
                XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military/Attack", 0);
            end
            GUI_Military.StrengthUpdate();
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons/SiegeEngine", 1);
        end
    end
end

---
-- Überscheibt die Funktion, die die Ingame-Texte aus den Quellen ausließt,
-- sodass eigene Texte für Keys angezeigt werden.
--
-- @within Internal
-- @local
--
function BundleEntitySelection.Local:OverwriteGetStringTableText()
    GetStringTableText_Orig_BundleEntitySelection = XGUIEng.GetStringTableText;
    XGUIEng.GetStringTableText = function(_key)
        local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        if _key == "UI_ObjectDescription/Attack" then
            local EntityID = GUI.GetSelectedEntity();
            if Logic.GetEntityType(EntityID) == Entities.U_Trebuchet then
                return BundleEntitySelection.Local.Data.Tooltips.TrebuchetRefiller.Text[Language];
            end
        end
        if _key == "UI_ObjectNames/Attack" then
            local EntityID = GUI.GetSelectedEntity();
            if Logic.GetEntityType(EntityID) == Entities.U_Trebuchet then
                return BundleEntitySelection.Local.Data.Tooltips.TrebuchetRefiller.Title[Language];
            end
        end

        return GetStringTableText_Orig_BundleEntitySelection(_key);
    end
end

---
-- Überschreibt die Millitärkommandos "Stop" und "Angreifen".
--
-- @within Internal
-- @local
--
function BundleEntitySelection.Local:OverwriteMilitaryCommands()
    GUI_Military.AttackClicked = function()
        Sound.FXPlay2DSound( "ui\\menu_click");
        local SelectedEntities = {GUI.GetSelectedEntities()};
        local EntityType = Logic.GetEntityType(SelectedEntities[1]);

        if EntityType == Entities.U_Trebuchet then
            for i=1, #SelectedEntities, 1 do
                EntityType = Logic.GetEntityType(SelectedEntities[i]);
                if EntityType == Entities.U_Trebuchet then
                    GUI.SendScriptCommand([[
                        BundleEntitySelection.Global:MilitaryCallForRefiller(]]..SelectedEntities[i]..[[)
                    ]]);
                end
            end
        else
            GUI.ActivateExplicitAttackCommandState();
        end
    end

    GUI_Military.StandGroundClicked = function()
        Sound.FXPlay2DSound( "ui\\menu_click");
        local SelectedEntities = {GUI.GetSelectedEntities()};

        for i=1,#SelectedEntities do
            local LeaderID = SelectedEntities[i];
            local eType = Logic.GetEntityType(LeaderID);
            GUI.SendCommandStationaryDefend(LeaderID);
            if eType == Entities.U_Trebuchet then
                GUI.SendScriptCommand([[
                    Logic.SetTaskList(]]..LeaderID..[[, TaskLists.TL_NPC_IDLE)
                ]]);
            end
        end

    end

    GUI_Military.StandGroundUpdate = function()
        local WidgetAttack = "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military/Attack";
        local SelectedEntities = {GUI.GetSelectedEntities()};

        SetIcon(WidgetAttack, {12, 4});

        if #SelectedEntities == 1 then
            local eID = SelectedEntities[1];
            local eType = Logic.GetEntityType(eID);
            if eType == Entities.U_Trebuchet then
                if Logic.GetAmmunitionAmount(eID) > 0 then
                    XGUIEng.ShowWidget(WidgetAttack, 0);
                else
                    XGUIEng.ShowWidget(WidgetAttack, 1);
                end
                SetIcon(WidgetAttack, {1, 10});
            else
                XGUIEng.ShowWidget(WidgetAttack, 1);
            end
        end
    end
end

---
-- Überschreibt das Aufbauen von Kriegsmaschinen, sodass auch Trebuchets
-- auf- und abgebaut werden können.
--
-- @within Internal
-- @local
--
function BundleEntitySelection.Local:OverwriteMilitaryErect()
    GUI_Military.ErectClicked_Orig_BundleEntitySelection = GUI_Military.ErectClicked;
    GUI_Military.ErectClicked = function()
        GUI_Military.ErectClicked_Orig_BundleEntitySelection();

        local PlayerID = GUI.GetPlayerID();
        local SelectedEntities = {GUI.GetSelectedEntities()};
        for i=1, #SelectedEntities, 1 do
            local EntityType = Logic.GetEntityType(SelectedEntities[i]);
            if EntityType == Entities.U_SiegeEngineCart then
                GUI.SendScriptCommand([[
                    BundleEntitySelection.Global:MilitaryErectTrebuchet(]]..SelectedEntities[i]..[[)
                ]]);
            end
        end
    end

    GUI_Military.ErectUpdate_Orig_BundleEntitySelection = GUI_Military.ErectUpdate;
    GUI_Military.ErectUpdate = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local SiegeCartID = GUI.GetSelectedEntity();
        local PlayerID = GUI.GetPlayerID();
        local EntityType = Logic.GetEntityType(SiegeCartID);

        if EntityType == Entities.U_SiegeEngineCart then
            XGUIEng.DisableButton(CurrentWidgetID, 0);
            SetIcon(CurrentWidgetID, {12, 6});
        else
            GUI_Military.ErectUpdate_Orig_BundleEntitySelection();
        end
    end

    GUI_Military.ErectMouseOver_Orig_BundleEntitySelection = GUI_Military.ErectMouseOver;
    GUI_Military.ErectMouseOver = function()
        local SiegeCartID = GUI.GetSelectedEntity();
        local TooltipTextKey;
        if Logic.GetEntityType(SiegeCartID) == Entities.U_SiegeEngineCart then
            TooltipTextKey = "ErectCatapult";
        else
            GUI_Military.ErectMouseOver_Orig_BundleEntitySelection();
            return;
        end
        GUI_Tooltip.TooltipNormal(TooltipTextKey, "Erect");
    end
end

---
-- Überschreibt das Abbauen von Kriegsmaschinen, sodass auch Trebuchets
-- abgebaut werden können.
--
-- @within Internal
-- @local
--
function BundleEntitySelection.Local:OverwriteMilitaryDisamble()
    GUI_Military.DisassembleClicked_Orig_BundleEntitySelection = GUI_Military.DisassembleClicked;
    GUI_Military.DisassembleClicked = function()
        GUI_Military.DisassembleClicked_Orig_BundleEntitySelection();

        local PlayerID = GUI.GetPlayerID();
        local SelectedEntities = {GUI.GetSelectedEntities()};
        for i=1, #SelectedEntities, 1 do
            local EntityType = Logic.GetEntityType(SelectedEntities[i]);
            if EntityType == Entities.U_Trebuchet then
                GUI.SendScriptCommand([[
                    BundleEntitySelection.Global:MilitaryDisambleTrebuchet(]]..SelectedEntities[i]..[[)
                ]]);
            end
        end
    end

    GUI_Military.DisassembleUpdate_Orig_BundleEntitySelection = GUI_Military.DisassembleUpdate;
    GUI_Military.DisassembleUpdate = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local PlayerID = GUI.GetPlayerID();
        local SiegeEngineID = GUI.GetSelectedEntity();
        local EntityType = Logic.GetEntityType(SiegeEngineID);

        if EntityType == Entities.U_Trebuchet then
            XGUIEng.DisableButton(CurrentWidgetID, 0);
            SetIcon(CurrentWidgetID, {12, 9});
        else
            GUI_Military.DisassembleUpdate_Orig_BundleEntitySelection();
        end
    end
end

---
-- Überschreibt die Multiselektion, damit Trebuchets ein Icon bekommen.
--
-- @within Internal
-- @local
--
function BundleEntitySelection.Local:OverwriteMultiselectIcon()
    GUI_MultiSelection.IconUpdate_Orig_BundleEntitySelection = GUI_MultiSelection.IconUpdate;
    GUI_MultiSelection.IconUpdate = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local CurrentMotherID = XGUIEng.GetWidgetsMotherID(CurrentWidgetID);
        local CurrentMotherName = XGUIEng.GetWidgetNameByID(CurrentMotherID);
        local Index = CurrentMotherName + 0;
        local CurrentMotherPath = XGUIEng.GetWidgetPathByID(CurrentMotherID);
        local HealthWidgetPath = CurrentMotherPath .. "/Health";
        local EntityID = g_MultiSelection.EntityList[Index];
        local EntityType = Logic.GetEntityType(EntityID);
        local HealthState = Logic.GetEntityHealth(EntityID);
        local EntityMaxHealth = Logic.GetEntityMaxHealth(EntityID);

        if EntityType ~= Entities.U_SiegeEngineCart and EntityType ~= Entities.U_Trebuchet then
            GUI_MultiSelection.IconUpdate_Orig_BundleEntitySelection();
            return;
        end
        if Logic.IsEntityAlive(EntityID) == false then
            XGUIEng.ShowWidget(CurrentMotherID, 0);
            GUI_MultiSelection.CreateEX();
            return;
        end

        SetIcon(CurrentWidgetID, g_TexturePositions.Entities[EntityType]);

        HealthState = math.floor(HealthState / EntityMaxHealth * 100);
        if HealthState < 50 then
            local green = math.floor(2*255* (HealthState/100));
            XGUIEng.SetMaterialColor(HealthWidgetPath,0,255,green, 20,255);
        else
            local red = 2*255 - math.floor(2*255* (HealthState/100));
            XGUIEng.SetMaterialColor(HealthWidgetPath,0,red, 255, 20,255);
        end
        XGUIEng.SetProgressBarValues(HealthWidgetPath,HealthState, 100);
    end

    GUI_MultiSelection.IconMouseOver_Orig_BundleEntitySelection = GUI_MultiSelection.IconMouseOver;
    GUI_MultiSelection.IconMouseOver = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local CurrentMotherID = XGUIEng.GetWidgetsMotherID(CurrentWidgetID);
        local CurrentMotherName = XGUIEng.GetWidgetNameByID(CurrentMotherID);
        local Index = tonumber(CurrentMotherName);
        local EntityID = g_MultiSelection.EntityList[Index];
        local EntityType = Logic.GetEntityType(EntityID);

        if EntityType ~= Entities.U_SiegeEngineCart and EntityType ~= Entities.U_Trebuchet then
            GUI_MultiSelection.IconMouseOver_Orig_BundleEntitySelection();
            return;
        end

        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        if EntityType == Entities.U_SiegeEngineCart then
            local TooltipData = BundleEntitySelection.Local.Data.Tooltips.TrebuchetCart;
            BundleEntitySelection.Local:SetTooltip(TooltipData.Title[lang], TooltipData.Text[lang]);
        elseif EntityType == Entities.U_Trebuchet then
            local TooltipData = BundleEntitySelection.Local.Data.Tooltips.Trebuchet;
            BundleEntitySelection.Local:SetTooltip(TooltipData.Title[lang], TooltipData.Text[lang]);
        end
    end
end

---
-- Überschreibt die Funktion zur Beendigung der Eskorte, damit Einheiten auch
-- entlassen werden können.
--
-- @within Internal
-- @local
--
function BundleEntitySelection.Local:OverwriteMilitaryDismount()
    GUI_Military.DismountClicked_Orig_BundleEntitySelection = GUI_Military.DismountClicked;
    GUI_Military.DismountClicked = function()
        local Selected = GUI.GetSelectedEntity(Selected);
        local Type = Logic.GetEntityType(Selected);
        local PlayerID = GUI.GetPlayerID();
        if Logic.GetGuardianEntityID(Selected) == 0 and Logic.IsKnight(Selected) == false then
            if (Type == Entities.U_SiegeEngineCart or Type == Entities.U_MilitarySiegeTower or
                Type == Entities.U_MilitaryCatapult or Type == Entities.U_MilitaryBatteringRam or
                Type == Entities.U_SiegeTowerCart or Type == Entities.U_CatapultCart or
                Type == Entities.U_BatteringRamCart or Type == Entities.U_AmmunitionCart)
            and BundleEntitySelection.Local.Data.SiegeEngineRelease then
                Sound.FXPlay2DSound( "ui\\menu_click");
                GUI.SendScriptCommand([[DestroyEntity(]]..Selected..[[)]]);
                return;
            end
            if (Logic.IsLeader(Selected) == 1 and BundleEntitySelection.Local.Data.MilitaryRelease) then
                Sound.FXPlay2DSound( "ui\\menu_click");
                local Soldiers = {Logic.GetSoldiersAttachedToLeader(Selected)};
                GUI.SendScriptCommand([[DestroyEntity(]]..Soldiers[#Soldiers]..[[)]]);
                return;
            end
        else
            GUI_Military.DismountClicked_Orig_BundleEntitySelection();
        end
    end

    GUI_Military.DismountUpdate_Orig_BundleEntitySelection = GUI_Military.DismountUpdate;
    GUI_Military.DismountUpdate = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local Selected = GUI.GetSelectedEntity();
        local Type = Logic.GetEntityType(Selected);
        if (Logic.GetGuardianEntityID(Selected) == 0 and Logic.IsKnight(Selected) == false and Logic.IsEntityInCategory(Selected, EntityCategories.AttackableMerchant) == 0) then
            if Logic.IsLeader(Selected) == 1 and not BundleEntitySelection.Local.Data.MilitaryRelease then
                XGUIEng.DisableButton(CurrentWidgetID, 1);
            elseif  Logic.IsLeader(Selected) == 0 then
                if not BundleEntitySelection.Local.Data.SiegeEngineRelease then
                    XGUIEng.DisableButton(CurrentWidgetID, 1);
                end
                if Type == Entities.U_Trebuchet then
                    XGUIEng.DisableButton(CurrentWidgetID, 1);
                end
            else
                SetIcon(CurrentWidgetID, {12, 1});
                XGUIEng.DisableButton(CurrentWidgetID, 0);
            end
            SetIcon(CurrentWidgetID, {14, 12});
        else
            SetIcon(CurrentWidgetID, {12, 1});
            GUI_Military.DismountUpdate_Orig_BundleEntitySelection();
        end
    end
end

---
-- Überschreibt "Beute abließern", sodass Diebe entlassen werden können.
--
-- @within Internal
-- @local
--
function BundleEntitySelection.Local:OverwriteThiefDeliver()
    GUI_Thief.ThiefDeliverClicked_Orig_BundleEntitySelection = GUI_Thief.ThiefDeliverClicked;
    GUI_Thief.ThiefDeliverClicked = function()
        if not self.Data.ThiefRelease then
            GUI_Thief.ThiefDeliverClicked_Orig_BundleEntitySelection();
            return;
        end

        Sound.FXPlay2DSound( "ui\\menu_click");
        local PlayerID = GUI.GetPlayerID();
        local ThiefID = GUI.GetSelectedEntity()
        if ThiefID == nil or Logic.GetEntityType(ThiefID) ~= Entities.U_Thief then
            return;
        end
        GUI.SendScriptCommand([[DestroyEntity(]]..ThiefID..[[)]]);
    end

    GUI_Thief.ThiefDeliverMouseOver_Orig_BundleEntitySelection = GUI_Thief.ThiefDeliverMouseOver;
    GUI_Thief.ThiefDeliverMouseOver = function()
        if not BundleEntitySelection.Local.Data.ThiefRelease then
            local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
            GUI_Thief.ThiefDeliverMouseOver_Orig_BundleEntitySelection();
            return;
        end

        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        BundleEntitySelection.Local:SetTooltip(
            BundleEntitySelection.Local.Data.Tooltips.ReleaseSoldiers.Title[lang],
            BundleEntitySelection.Local.Data.Tooltips.ReleaseSoldiers.Text[lang],
            BundleEntitySelection.Local.Data.Tooltips.ReleaseSoldiers.Disabled[lang]
        );
    end

    GUI_Thief.ThiefDeliverUpdate_Orig_BundleEntitySelection = GUI_Thief.ThiefDeliverUpdate;
    GUI_Thief.ThiefDeliverUpdate = function()
        if not BundleEntitySelection.Local.Data.ThiefRelease then
            GUI_Thief.ThiefDeliverUpdate_Orig_BundleEntitySelection();
        else
            local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
            local ThiefID = GUI.GetSelectedEntity();
            if ThiefID == nil or Logic.GetEntityType(ThiefID) ~= Entities.U_Thief then
                XGUIEng.DisableButton(CurrentWidgetID, 1);
            else
                XGUIEng.DisableButton(CurrentWidgetID, 0);
            end
            SetIcon(CurrentWidgetID, {14, 12});
        end
    end
end

---
-- Hängt eine Funktion an die GUI_Tooltip.SetNameAndDescription an, sodass
-- Tooltips überschrieben werden können.
--
-- @within Internal
-- @local
--
function BundleEntitySelection.Local:OverwriteNamesAndDescription()
    GUI_Tooltip.SetNameAndDescription_Orig_QSB_EntitySelection = GUI_Tooltip.SetNameAndDescription;
    GUI_Tooltip.SetNameAndDescription = function(_TooltipNameWidget, _TooltipDescriptionWidget, _OptionalTextKeyName, _OptionalDisabledTextKeyName, _OptionalMissionTextFileBoolean)
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";

        if XGUIEng.GetWidgetID("/InGame/Root/Normal/AlignBottomRight/MapFrame/KnightButton") == CurrentWidgetID then
            BundleEntitySelection.Local:SetTooltip(
                BundleEntitySelection.Local.Data.Tooltips.KnightButton.Title[lang],
                BundleEntitySelection.Local.Data.Tooltips.KnightButton.Text[lang]
            );
            return;
        end

        if XGUIEng.GetWidgetID("/InGame/Root/Normal/AlignBottomRight/MapFrame/BattalionButton") == CurrentWidgetID then
            BundleEntitySelection.Local:SetTooltip(
                BundleEntitySelection.Local.Data.Tooltips.BattalionButton.Title[lang],
                BundleEntitySelection.Local.Data.Tooltips.BattalionButton.Text[lang]
            );
            return;
        end

        if XGUIEng.GetWidgetID("/InGame/Root/Normal/AlignBottomRight/DialogButtons/SiegeEngineCart/Dismount") == CurrentWidgetID 
        or XGUIEng.GetWidgetID("/InGame/Root/Normal/AlignBottomRight/DialogButtons/AmmunitionCart/Dismount") == CurrentWidgetID 
        or XGUIEng.GetWidgetID("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military/Dismount") == CurrentWidgetID 
        then
            local SelectedEntity = GUI.GetSelectedEntity();
            if SelectedEntity ~= 0 then
                if Logic.IsEntityInCategory(SelectedEntity, EntityCategories.Military) == 1
                and Logic.IsEntityInCategory(SelectedEntity, EntityCategories.Hero) == 0
                then
                    local GuardianEntity = Logic.GetGuardianEntityID(SelectedEntity)
                    if GuardianEntity == nil or GuardianEntity == 0 then
                        BundleEntitySelection.Local:SetTooltip(
                            BundleEntitySelection.Local.Data.Tooltips.ReleaseSoldiers.Title[lang],
                            BundleEntitySelection.Local.Data.Tooltips.ReleaseSoldiers.Text[lang],
                            BundleEntitySelection.Local.Data.Tooltips.ReleaseSoldiers.Disabled[lang]
                        );
                        return;
                    end
                end
            end
        end

        GUI_Tooltip.SetNameAndDescription_Orig_QSB_EntitySelection(_TooltipNameWidget, _TooltipDescriptionWidget, _OptionalTextKeyName, _OptionalDisabledTextKeyName, _OptionalMissionTextFileBoolean);
    end
end

---
-- Schreibt einen anderen Text in einen normalen Tooltip.
--
-- @param _TitleText Titel des Tooltip
-- @param _DescText  Text des Tooltip
-- @within Internal
-- @local
--
function BundleEntitySelection.Local:SetTooltip(_TitleText, _DescText, _DisabledText)
    local TooltipContainerPath = "/InGame/Root/Normal/TooltipNormal";
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath);
    local TooltipNameWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Name");
    local TooltipDescriptionWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Text");
    local PositionWidget = XGUIEng.GetCurrentWidgetID();

    _DisabledText = _DisabledText or "";
    local DisabledText = "";
    if XGUIEng.IsButtonDisabled(PositionWidget) == 1 and _disabledText ~= "" and _text ~= "" then
        DisabledText = DisabledText .. "{cr}{@color:255,32,32,255}" .. _DisabledText;
    end

    XGUIEng.SetText(TooltipNameWidget, "{center}" .. _TitleText);
    XGUIEng.SetText(TooltipDescriptionWidget, _DescText .. DisabledText);
    local Height = XGUIEng.GetTextHeight(TooltipDescriptionWidget, true);
    local W, H = XGUIEng.GetWidgetSize(TooltipDescriptionWidget);
    XGUIEng.SetWidgetSize(TooltipDescriptionWidget, W, Height);
end

---
-- Überschreibt den SelectKnight-Button. Durch drücken von CTLR können alle
-- Helden selektiert werden, die der Spieler kontrolliert.
--
-- @within Internal
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

                if ((Framework.GetTimeMs() - g_Selection.LastClickTime ) < g_Selection.MaxDoubleClickTime) then
                    local pos = GetPosition(KnightID);
                    Camera.RTS_SetLookAtPosition(pos.X, pos.Y);
                else
                    Sound.FXPlay2DSound("ui\\mini_knight");
                end

                g_Selection.LastClickTime = Framework.GetTimeMs();
            end
            GUI_MultiSelection.CreateMultiSelection(g_SelectionChangedSource.User);
        else
            GUI.AddNote("Debug: You do not have a knight");
        end
    end
end

---
-- Überschreibt die Militärselektion, sodass der Spieler mit SHIFT zusätzlich
-- die Munitionswagen und Trebuchets selektieren kann.
-- @within Internal
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
-- @within Internal
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
-- @within Internal
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

