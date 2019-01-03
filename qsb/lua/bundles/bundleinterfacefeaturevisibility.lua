-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleInterfaceFeatureVisibility                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle bietet dem Nutzer Funktionen um ausgewählte Buttons und
-- Widgets auszublenden oder einzublenden. Auf diese Weise können dem Spieler
-- Funktionalitäten vorenthalten werden.
--
-- <p><a href="#API.InterfaceHideBuildMenu">Interface-Steuerung</a></p>
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleInterfaceFeatureVisibility = {};

API = API or {};
QSB = QSB or {};

QSB.PlayerNames = {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Graut die Minimap aus oder macht sie wieder verwendbar.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param _Flag [boolean] Widget versteckt
-- @within Anwenderfunktionen
--
function API.InterfaceHideMinimap(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.InterfaceHideMinimap(" ..tostring(_Flag).. ")");
        return;
    end

    BundleInterfaceFeatureVisibility.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/Minimap/MinimapOverlay",
        _Flag
    );
    BundleInterfaceFeatureVisibility.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/Minimap/MinimapTerrain",
        _Flag
    );
end

---
-- Versteckt den Umschaltknopf der Minimap oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param _Flag [boolean] Widget versteckt
-- @within Anwenderfunktionen
--
function API.InterfaceHideToggleMinimap(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.InterfaceHideToggleMinimap(" ..tostring(_Flag).. ")");
        return;
    end

    BundleInterfaceFeatureVisibility.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/MinimapButton",
        _Flag
    );
end

---
-- Versteckt den Button des Diplomatiemenü oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param _Flag [boolean] Widget versteckt
-- @within Anwenderfunktionen
--
function API.InterfaceHideDiplomacyMenu(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.InterfaceHideDiplomacyMenu(" ..tostring(_Flag).. ")");
        return;
    end

    BundleInterfaceFeatureVisibility.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/DiplomacyMenuButton",
        _Flag
    );
end

---
-- Versteckt den Button des Produktionsmenü oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param _Flag [boolean] Widget versteckt
-- @within Anwenderfunktionen
--
function API.InterfaceHideProductionMenu(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.InterfaceHideProductionMenu(" ..tostring(_Flag).. ")");
        return;
    end

    BundleInterfaceFeatureVisibility.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/ProductionMenuButton",
        _Flag
    );
end

---
-- Versteckt den Button des Wettermenüs oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param _Flag [boolean] Widget versteckt
-- @within Anwenderfunktionen
--
function API.InterfaceHideWeatherMenu(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.InterfaceHideWeatherMenu(" ..tostring(_Flag).. ")");
        return;
    end

    BundleInterfaceFeatureVisibility.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/WeatherMenuButton",
        _Flag
    );
end

---
-- Versteckt den Button zum Territorienkauf oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param _Flag [boolean] Widget versteckt
-- @within Anwenderfunktionen
--
function API.InterfaceHideBuyTerritory(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.InterfaceHideBuyTerritory(" ..tostring(_Flag).. ")");
        return;
    end

    BundleInterfaceFeatureVisibility.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/ClaimTerritory",
        _Flag
    );
end

---
-- Versteckt den Button der Heldenfähigkeit oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param _Flag [boolean] Widget versteckt
-- @within Anwenderfunktionen
--
function API.InterfaceHideKnightAbility(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.InterfaceHideKnightAbility(" ..tostring(_Flag).. ")");
        return;
    end

    BundleInterfaceFeatureVisibility.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/StartAbilityProgress",
        _Flag
    );
    BundleInterfaceFeatureVisibility.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/StartAbility",
        _Flag
    );
end

---
-- Versteckt den Button zur Heldenselektion oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param _Flag [boolean] Widget versteckt
-- @within Anwenderfunktionen
--
function API.InterfaceHideKnightButton(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.InterfaceHideKnightButton(" ..tostring(_Flag).. ")");
        return;
    end

    local KnightID = Logic.GetKnightID(GUI.GetPlayerID());
    if _Flag == true then
        GUI.SendScriptCommand("Logic.SetEntitySelectableFlag("..KnightID..", 0)");
        GUI.DeselectEntity(KnightID);
    else
        GUI.SendScriptCommand("Logic.SetEntitySelectableFlag("..KnightID..", 1)");
    end

    BundleInterfaceFeatureVisibility.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/KnightButtonProgress",
        _Flag
    );
    BundleInterfaceFeatureVisibility.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/KnightButton",
        _Flag
    );
end

---
-- Versteckt den Button zur Selektion des Militärs oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param _Flag [boolean] Widget versteckt
-- @within Anwenderfunktionen
--
function API.InterfaceHideSelectionButton(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.InterfaceHideSelectionButton(" ..tostring(_Flag).. ")");
        return;
    end
    API.InterfaceHideKnightButton(_Flag);
    GUI.ClearSelection();

    BundleInterfaceFeatureVisibility.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/BattalionButton",
        _Flag
    );
end

---
-- Versteckt das Baumenü oder blendet es ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param _Flag [boolean] Widget versteckt
-- @within Anwenderfunktionen
--
function API.InterfaceHideBuildMenu(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.InterfaceHideBuildMenu(" ..tostring(_Flag).. ")");
        return;
    end

    BundleInterfaceFeatureVisibility.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/BuildMenu",
        _Flag
    );
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleInterfaceFeatureVisibility = {
    Global = {},
    Local = {
        Data = {
            HiddenWidgets = {},
        },
    }
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function BundleInterfaceFeatureVisibility.Global:Install()
    API.AddSaveGameAction(BundleInterfaceFeatureVisibility.Global.RestoreAfterLoad);
end

---
-- Stellt alle versteckten Buttons nach dem Laden eines Spielstandes wieder her.
-- @within Internal
-- @local
--
function BundleInterfaceFeatureVisibility.Global.RestoreAfterLoad()
    Logic.ExecuteInLuaLocalState([[
        BundleInterfaceFeatureVisibility.Local:RestoreAfterLoad();
    ]]);
end

-- Local Script ----------------------------------------------------------------

---
-- Initialisiert das Bundle im lokalen Skript.
-- @within Internal
-- @local
--
function BundleInterfaceFeatureVisibility.Local:Install()
    Core:StackFunction("GUI_Knight.ClaimTerritoryUpdate", self.UpdateClaimTerritory);
end

---
-- Versteht ein Widget oder blendet es ein.
--
-- @param _Widget [string|number] Widgetpfad oder ID
-- @param _Hide [boolean] Hidden Flag
-- @within Internal
-- @local
--
function BundleInterfaceFeatureVisibility.Local:HideInterfaceButton(_Widget, _Hide)
    self.Data.HiddenWidgets[_Widget] = _Hide == true;
    XGUIEng.ShowWidget(_Widget, (_Hide == true and 0) or 1);
end

---
-- Stellt alle versteckten Buttons nach dem Laden eines Spielstandes wieder her.
-- @within Internal
-- @local
--
function BundleInterfaceFeatureVisibility.Local:RestoreAfterLoad()
    for k, v in pairs(self.Data.HiddenWidgets) do
        if v then
            XGUIEng.ShowWidget(k, 0);
        end
    end
end

---
-- Versteckt den Claim-Territory-Button.
-- @within Internal
-- @local
--
function BundleInterfaceFeatureVisibility.Local.UpdateClaimTerritory()
    local Key = "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/ClaimTerritory";
    if BundleInterfaceFeatureVisibility.Local.Data.HiddenWidgets[Key] == true then
        XGUIEng.ShowWidget(Key, 0);
        return true;
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleInterfaceFeatureVisibility");

