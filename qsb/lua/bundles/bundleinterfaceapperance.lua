-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleInterfaceApperance                                     # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle bietet dem Nutzer Funktionen zur Manipulation der Oberfläche
-- des Spiels. Es gibt Funktionen zum Ausblenden einiger Buttons und Menüs und
-- die Möglichkeit eigene Texte in Tooltips und eigene Grafiken für Widgets
-- zu setzen.
--
-- <p><a href="#API.InterfaceHideBuildMenu">Interface-Steuerung</a></p>
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleInterfaceApperance = {};

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

    BundleInterfaceApperance.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/Minimap/MinimapOverlay",
        _Flag
    );
    BundleInterfaceApperance.Local:HideInterfaceButton(
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

    BundleInterfaceApperance.Local:HideInterfaceButton(
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

    BundleInterfaceApperance.Local:HideInterfaceButton(
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

    BundleInterfaceApperance.Local:HideInterfaceButton(
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

    BundleInterfaceApperance.Local:HideInterfaceButton(
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

    BundleInterfaceApperance.Local:HideInterfaceButton(
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

    BundleInterfaceApperance.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/StartAbilityProgress",
        _Flag
    );
    BundleInterfaceApperance.Local:HideInterfaceButton(
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

    BundleInterfaceApperance.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/KnightButtonProgress",
        _Flag
    );
    BundleInterfaceApperance.Local:HideInterfaceButton(
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

    BundleInterfaceApperance.Local:HideInterfaceButton(
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

    BundleInterfaceApperance.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/BuildMenu",
        _Flag
    );
end

---
-- Setzt eine Grafik als Bild für einen Icon oder einen Button.
--
-- Die Größe des Bildes ist auf 200x200 Pixel festgelegt. Es kann an jedem
-- beliebigen Ort im interen Verzeichnis oder auf der Festplatte liegen. Es
-- muss jedoch immer der korrekte Pfad angegeben werden.
--
-- <p><b>Hinweis:</b> Es kann vorkommen, dass das Bild nicht genau da ist, wo es
-- sein soll, sondern seine Position, je nach Auflösung, um ein paar Pixel
-- unterschiedlich ist.</p>
--
-- @param _widget [string|number] Widgetpfad oder ID
-- @param _file [string] Pfad zur Datei
-- @within Anwenderfunktionen
--
function API.InterfaceSetTexture(_widget, _file)
    if not GUI then
        return;
    end
    BundleInterfaceApperance.Local:SetTexture(_widget, _file)
end
UserSetTexture = API.InterfaceSetTexture;

---
-- Setzt einen Icon aus einer benutzerdefinierten Icon Matrix.
--
-- Dabei müssen die Quellen nach gui_768, gui_920 und gui_1080 in der
-- entsprechenden Größe gepackt werden. Die Ordner liegen in graphics/textures.
-- Jede Map muss einen eigenen eindeutigen Namen für jede Grafik verwenden.
--
-- <u>Größen:</u>
-- Die Gesamtgröße ergibt sich aus der Anzahl der Buttons und der Pixelbreite
-- für die jeweilige Grö0e. z.B. 64 Buttons -> Größe * 8 x Größe * 8
-- <ul>
-- <li>768: 41x41</li>
-- <li>960: 52x52</li>
-- <li>1200: 64x64</li>
-- </ul>
--
-- <u>Namenskonvention:</u>
-- Die Namenskonvention wird durch das Spiel vorgegeben. Je nach Größe sind
-- die Namen der Matrizen erweitert mit .png, big.png und verybig.png. Du
-- gibst also niemals die Dateiendung mit an!
-- <ul>
-- <li>Für normale Icons: _Name .. .png</li>
-- <li>Für große Icons: _Name .. big.png</li>
-- <li>Für riesige Icons: _Name .. verybig.png</li>
-- </ul>
--
-- @param _WidgetID [string|number] Widgetpfad oder ID
-- @param _Coordinates [table] Koordinaten
-- @param _Size [number] Größe des Icon
-- @param _Name [string] Name der Icon Matrix
-- @within Anwenderfunktionen
--
function API.InterfaceSetIcon(_WidgetID, _Coordinates, _Size, _Name)
    if not GUI then
        return;
    end
    BundleInterfaceApperance.Local:SetIcon(_WidgetID, _Coordinates, _Size, _Name)
end
UserSetIcon = API.InterfaceSetIcon;

---
-- Ändert den aktuellen Tooltip mit der Beschreibung.
--
-- <p><b>Alias:</b> UserSetTextNormal</p>
--
-- Die Funtion ermittelt das aktuelle GUI Widget und ändert den Text des
-- Tooltip. Dazu muss die Funktion innerhalb der Mouseover-Funktion eines
-- Buttons oder Widgets mit Tooltip aufgerufen werden.
--
-- Die Funktion kann auch mit deutsch/english lokalisierten Tabellen als
-- Text gefüttert werden. In diesem Fall wird der deutsche Text genommen,
-- wenn es sich um eine deutsche Spielversion handelt. Andernfalls wird
-- immer der englische Text verwendet.
--
-- @param _title [string] Titel des Tooltip
-- @param _text [string] Text des Tooltip
-- @param _disabledText [string] Textzusatz wenn inaktiv
-- @within Anwenderfunktionen
--
function API.InterfaceSetTooltipNormal(_title, _text, _disabledText)
    if not GUI then
        return;
    end
    BundleInterfaceApperance.Local:TextNormal(_title, _text, _disabledText);
end
UserSetTextNormal = API.InterfaceSetTooltipNormal;

---
-- Ändert den aktuellen Tooltip mit der Beschreibung und den Kosten.
--
-- <p><b>Alias:</b> UserSetTextBuy</p>
--
-- @see API.InterfaceSetTooltipNormal
--
-- @param _title [string] Titel des Tooltip
-- @param _text [string] Text des Tooltip
-- @param _disabledText [string] Textzusatz wenn inaktiv
-- @param _costs [table] Kostentabelle
-- @param _inSettlement [boolean] Kosten in Siedlung suchen
-- @within Anwenderfunktionen
--
function API.InterfaceSetTooltipCosts(_title,_text,_disabledText,_costs,_inSettlement)
    if not GUI then
        return;
    end
    BundleInterfaceApperance.Local:TextCosts(_title,_text,_disabledText,_costs,_inSettlement);
end
UserSetTextBuy = API.InterfaceSetTooltipCosts;

---
-- Gibt den Namen des Territoriums zurück.
--
-- <p><b>Alias:</b> GetTerritoryName</p>
--
-- @param _TerritoryID [number] ID des Territoriums
-- @return [string]  Name des Territorium
-- @within Anwenderfunktionen
--
function API.InterfaceGetTerritoryName(_TerritoryID)
    local Name = Logic.GetTerritoryName(_TerritoryID);
    local MapType = Framework.GetCurrentMapTypeAndCampaignName();
    if MapType == 1 or MapType == 3 then
        return Name;
    end

    local MapName = Framework.GetCurrentMapName();
    local StringTable = "Map_" .. MapName;
    local TerritoryName = string.gsub(Name, " ","");
    TerritoryName = XGUIEng.GetStringTableText(StringTable .. "/Territory_" .. TerritoryName);
    if TerritoryName == "" then
        TerritoryName = Name .. "(key?)";
    end
    return TerritoryName;
end
GetTerritoryName = API.InterfaceGetTerritoryName;

---
-- Gibt den Namen des Spielers zurück.
--
-- <p><b>Alias:</b> GetPlayerName</p>
--
-- @param _PlayerID [number] ID des Spielers
-- @return [string]  Name des Territorium
-- @within Anwenderfunktionen
--
function API.InterfaceGetPlayerName(_PlayerID)
    local PlayerName = Logic.GetPlayerName(_PlayerID);
    local name = QSB.PlayerNames[_PlayerID];
    if name ~= nil and name ~= "" then
        PlayerName = name;
    end

    local MapType = Framework.GetCurrentMapTypeAndCampaignName();
    local MutliplayerMode = Framework.GetMultiplayerMapMode(Framework.GetCurrentMapName(), MapType);

    if MutliplayerMode > 0 then
        return PlayerName;
    end
    if MapType == 1 or MapType == 3 then
        local PlayerNameTmp, PlayerHeadTmp, PlayerAITmp = Framework.GetPlayerInfo(_PlayerID);
        if PlayerName ~= "" then
            return PlayerName;
        end
        return PlayerNameTmp;
    end
end
GetPlayerName_OrigName = GetPlayerName;
GetPlayerName = API.InterfaceGetPlayerName;

---
-- Gibt dem Spieler einen neuen Namen.
--
-- <p><b>Alias:</b> SetPlayerName</p>
--
-- @param _playerID [number] ID des Spielers
-- @param _name [string] Name des Spielers
-- @return [string]  Name des Territorium
-- @within Anwenderfunktionen
--
function API.InterfaceSetPlayerName(_playerID,_name)
    assert(type(_playerID) == "number");
    assert(type(_name) == "string");
    if not GUI then
        Logic.ExecuteInLuaLocalState("SetPlayerName(".._playerID..",'".._name.."')");
    else
        GUI_MissionStatistic.PlayerNames[_playerID] = _name;
        GUI.SendScriptCommand("QSB.PlayerNames[".._playerID.."] = '".._name.."'");
    end
    QSB.PlayerNames[_playerID] = _name;
end
SetPlayerName = API.InterfaceSetPlayerName;

---
-- Setzt zu Spielbeginn eine andere Spielerfarbe.
--
-- @param _PlayerID [number] ID des Spielers
-- @param _Color [number] Spielerfarbe
-- @param _Logo [number] Logo (optional)
-- @param _Pattern [number] Pattern (optional)
-- @return [string]  Name des Territorium
-- @within Anwenderfunktionen
--
function API.InterfaceSetPlayerColor(_PlayerID, _Color, _Logo, _Pattern)
    if GUI then
        return;
    end
    g_ColorIndex["ExtraColor1"] = 16;
    g_ColorIndex["ExtraColor2"] = 17;

    local Type    = type(_Color);
    local Col     = (type(_Color) == "string" and g_ColorIndex[_Color]) or _Color;
    local Logo    = _Logo or -1;
    local Pattern = _Pattern or -1;

    StartSimpleJobEx( function(Col, _PlayerID, _Logo, _Pattern)
        Logic.PlayerSetPlayerColor(_PlayerID, Col, _Logo, _Pattern);
        return true;
    end, Col, _PlayerID, Logo, Pattern);
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleInterfaceApperance = {
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
function BundleInterfaceApperance.Global:Install()
    API.AddSaveGameAction(BundleInterfaceApperance.Global.RestoreAfterLoad);
end

---
-- Stellt alle versteckten Buttons nach dem Laden eines Spielstandes wieder her.
-- @within Internal
-- @local
--
function BundleInterfaceApperance.Global.RestoreAfterLoad()
    Logic.ExecuteInLuaLocalState([[
        BundleInterfaceApperance.Local:RestoreAfterLoad();
    ]]);
end

-- Local Script ----------------------------------------------------------------

---
-- Initialisiert das Bundle im lokalen Skript.
-- @within Internal
-- @local
--
function BundleInterfaceApperance.Local:Install()
    StartMissionGoodOrEntityCounter = function(_Icon, _AmountToReach)
        if type(_Icon) == "string" then
            BundleInterfaceApperance.Local:SetTexture("/InGame/Root/Normal/MissionGoodOrEntityCounter/Icon", _Icon);
        else
            if type(_Icon[3]) == "string" then
                BundleInterfaceApperance.Local:SetIcon("/InGame/Root/Normal/MissionGoodOrEntityCounter/Icon", _Icon, 64, _Icon[3]);
            else
                SetIcon("/InGame/Root/Normal/MissionGoodOrEntityCounter/Icon", _Icon);
            end
        end

        g_MissionGoodOrEntityCounterAmountToReach = _AmountToReach;
        g_MissionGoodOrEntityCounterIcon = _Icon;

        XGUIEng.ShowWidget("/InGame/Root/Normal/MissionGoodOrEntityCounter", 1);
    end

    GUI_Knight.ClaimTerritoryUpdate_Orig_QSB_InterfaceApperance = GUI_Knight.ClaimTerritoryUpdate;
    GUI_Knight.ClaimTerritoryUpdate = function()
        local Key = "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/ClaimTerritory";
        if BundleInterfaceApperance.Local.Data.HiddenWidgets[Key] == true
        then
            BundleInterfaceApperance.Local:HideInterfaceButton(Key, true);
        end
        GUI_Knight.ClaimTerritoryUpdate_Orig_QSB_InterfaceApperance();
    end
end

---
-- Versteht ein Widget oder blendet es ein.
--
-- @param _Widget [string|number] Widgetpfad oder ID
-- @param _Hide [boolean] Hidden Flag
-- @within Internal
-- @local
--
function BundleInterfaceApperance.Local:HideInterfaceButton(_Widget, _Hide)
    self.Data.HiddenWidgets[_Widget] = _Hide == true;
    XGUIEng.ShowWidget(_Widget, (_Hide == true and 0) or 1);
end

---
-- Stellt alle versteckten Buttons nach dem Laden eines Spielstandes wieder her.
-- @within Internal
-- @local
--
function BundleInterfaceApperance.Local:RestoreAfterLoad()
    for k, v in pairs(self.Data.HiddenWidgets) do
        if v then
            XGUIEng.ShowWidget(k, 0);
        end
    end
end

---
-- Setzt einen Icon aus einer benutzerdefinerten Datei.
--
-- @param _widget [string|number] Widgetpfad oder ID
-- @param _file [string] Pfad zur Datei
-- @within Internal
-- @local
--
function BundleInterfaceApperance.Local:SetTexture(_widget, _file)
    assert((type(_widget) == "string" or type(_widget) == "number"));
    local wID = (type(_widget) == "string" and XGUIEng.GetWidgetID(_widget)) or _widget;
    local screenSize = {GUI.GetScreenSize()};

    local state = 1;
    if XGUIEng.IsButton(wID) == 1 then
        state = 7;
    end

    local Scale = 330;
    if screenSize[2] >= 800 then
        Scale = 260;
    end
    if screenSize[2] >= 1000 then
        Scale = 210;
    end
    XGUIEng.SetMaterialAlpha(wID, state, 255);
    XGUIEng.SetMaterialTexture(wID, state, _file);
    XGUIEng.SetMaterialUV(wID, state, 0, 0, Scale, Scale);
end

---
-- Setzt einen Icon aus einer benutzerdefinierten Matrix.
--
-- @param _WidgetID [string|number] Widgetpfad oder ID
-- @param _Coordinates [table] Koordinaten
-- @param _Size [number] Größe des Icon
-- @param _Name [string] Name der Icon Matrix
-- @within Internal
-- @local
--
function BundleInterfaceApperance.Local:SetIcon(_WidgetID, _Coordinates, _Size, _Name)
    if _Name == nil then
        _Name = "usericons";
    end
    if _Size == nil then
        _Size = 64;
    end

    if _Size == 44 then
        _Name = _Name .. ".png"
    end
    if _Size == 64 then
        _Name = _Name .. "big.png"
    end
    if _Size == 128 then
        _Name = _Name .. "verybig.png"
    end

    local u0, u1, v0, v1;
    u0 = (_Coordinates[1] - 1) * _Size;
    v0 = (_Coordinates[2] - 1) * _Size;
    u1 = (_Coordinates[1]) * _Size;
    v1 = (_Coordinates[2]) * _Size;

    State = 1;
    if XGUIEng.IsButton(_WidgetID) == 1 then
        State = 7;
    end
    XGUIEng.SetMaterialAlpha(_WidgetID, State, 255);
    XGUIEng.SetMaterialTexture(_WidgetID, State, _Name);
    XGUIEng.SetMaterialUV(_WidgetID, State, u0, v0, u1, v1);
end

---
-- Setzt einen Beschreibungstooltip.
--
-- @param _title [string] Titel des Tooltip
-- @param _text [string] Text des Tooltip
-- @param _disabledText [string] Textzusatz wenn inaktiv
-- @within Internal
-- @local
--
function BundleInterfaceApperance.Local:TextNormal(_title, _text, _disabledText)
    local lang = Network.GetDesiredLanguage()
    if lang ~= "de" then lang = "en" end

    if type(_title) == "table" then
        _title = _title[lang];
    end
    if type(_text) == "table" then
        _text = _text[lang];
    end
    _text = _text or "";
    if type(_disabledText) == "table" then
        _disabledText = _disabledText[lang];
    end

    local TooltipContainerPath = "/InGame/Root/Normal/TooltipNormal"
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath)
    local TooltipNameWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Name")
    local TooltipDescriptionWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Text")
    local TooltipBGWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/BG")
    local TooltipFadeInContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn")
    local PositionWidget = XGUIEng.GetCurrentWidgetID()
    GUI_Tooltip.ResizeBG(TooltipBGWidget, TooltipDescriptionWidget)
    local TooltipContainerSizeWidgets = {TooltipBGWidget}
    GUI_Tooltip.SetPosition(TooltipContainer, TooltipContainerSizeWidgets, PositionWidget)
    GUI_Tooltip.FadeInTooltip(TooltipFadeInContainer)

    _disabledText = _disabledText or "";
    local disabled = "";
    if XGUIEng.IsButtonDisabled(PositionWidget) == 1 and _disabledText ~= "" and _text ~= "" then
        disabled = disabled .. "{cr}{@color:255,32,32,255}" .. _disabledText
    end

    XGUIEng.SetText(TooltipNameWidget, "{center}" .. _title)
    XGUIEng.SetText(TooltipDescriptionWidget, _text .. disabled)
    local Height = XGUIEng.GetTextHeight(TooltipDescriptionWidget, true)
    local W, H = XGUIEng.GetWidgetSize(TooltipDescriptionWidget)
    XGUIEng.SetWidgetSize(TooltipDescriptionWidget, W, Height)
end

---
-- Setzt den Kostentooltip.
--
-- @param _title [string] Titel des Tooltip
-- @param _text [string] Text des Tooltip
-- @param _disabledText [string] Textzusatz wenn inaktiv
-- @param _costs [table] Kostentabelle
-- @param _inSettlement [boolean] Kosten in Siedlung suchen
-- @within Internal
-- @local
--
function BundleInterfaceApperance.Local:TextCosts(_title,_text,_disabledText,_costs,_inSettlement)
    local lang = Network.GetDesiredLanguage()
    if lang ~= "de" then lang = "en" end
    _costs = _costs or {};

    if type(_title) == "table" then
        _title = _title[lang];
    end
    if type(_text) == "table" then
        _text = _text[lang];
    end
    _text = _text or "";
    if type(_disabledText) == "table" then
        _disabledText = _disabledText[lang];
    end

    local TooltipContainerPath = "/InGame/Root/Normal/TooltipBuy"
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath)
    local TooltipNameWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Name")
    local TooltipDescriptionWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Text")
    local TooltipBGWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/BG")
    local TooltipFadeInContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn")
    local TooltipCostsContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/Costs")
    local PositionWidget = XGUIEng.GetCurrentWidgetID()
    GUI_Tooltip.ResizeBG(TooltipBGWidget, TooltipDescriptionWidget)
    GUI_Tooltip.SetCosts(TooltipCostsContainer, _costs, _inSettlement)
    local TooltipContainerSizeWidgets = {TooltipContainer, TooltipCostsContainer, TooltipBGWidget}
    GUI_Tooltip.SetPosition(TooltipContainer, TooltipContainerSizeWidgets, PositionWidget, nil, true)
    GUI_Tooltip.OrderTooltip(TooltipContainerSizeWidgets, TooltipFadeInContainer, TooltipCostsContainer, PositionWidget, TooltipBGWidget)
    GUI_Tooltip.FadeInTooltip(TooltipFadeInContainer)

    _disabledText = _disabledText or "";
    local disabled = ""
    if XGUIEng.IsButtonDisabled(PositionWidget) == 1 and _disabledText ~= "" and _text ~= "" then
        disabled = disabled .. "{cr}{@color:255,32,32,255}" .. _disabledText
    end

    XGUIEng.SetText(TooltipNameWidget, "{center}" .. _title)
    XGUIEng.SetText(TooltipDescriptionWidget, _text .. disabled)
    local Height = XGUIEng.GetTextHeight(TooltipDescriptionWidget, true)
    local W, H = XGUIEng.GetWidgetSize(TooltipDescriptionWidget)
    XGUIEng.SetWidgetSize(TooltipDescriptionWidget, W, Height)
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleInterfaceApperance");

