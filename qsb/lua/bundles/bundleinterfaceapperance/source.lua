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
-- @module BundleInterfaceApperance
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

QSB.PlayerNames = {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Graut die Minimap aus oder macht sie wieder verwendbar.
--
-- <b>Hinweis:</b> Diese Änderung persistiert auch nach dem Laden eines 
-- Spielstandes und muss explizit mit dieser Funktion zurückgenommen werden!
--
-- @param _Flag Widget versteckt
-- @within User-Space
--
function API.HideMinimap(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideMinimap(" ..tostring(_Flag).. ")");
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
-- <b>Hinweis:</b> Diese Änderung persistiert auch nach dem Laden eines 
-- Spielstandes und muss explizit mit dieser Funktion zurückgenommen werden!
--
-- @param _Flag Widget versteckt
-- @within User-Space
--
function API.HideToggleMinimap(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideToggleMinimap(" ..tostring(_Flag).. ")");
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
-- <b>Hinweis:</b> Diese Änderung persistiert auch nach dem Laden eines 
-- Spielstandes und muss explizit mit dieser Funktion zurückgenommen werden!
--
-- @param _Flag Widget versteckt
-- @within User-Space
--
function API.HideDiplomacyMenu(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideDiplomacyMenu(" ..tostring(_Flag).. ")");
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
-- <b>Hinweis:</b> Diese Änderung persistiert auch nach dem Laden eines 
-- Spielstandes und muss explizit mit dieser Funktion zurückgenommen werden!
--
-- @param _Flag Widget versteckt
-- @within User-Space
--
function API.HideProductionMenu(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideProductionMenu(" ..tostring(_Flag).. ")");
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
-- <b>Hinweis:</b> Diese Änderung persistiert auch nach dem Laden eines 
-- Spielstandes und muss explizit mit dieser Funktion zurückgenommen werden!
--
-- @param _Flag Widget versteckt
-- @within User-Space
--
function API.HideWeatherMenu(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideWeatherMenu(" ..tostring(_Flag).. ")");
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
-- <b>Hinweis:</b> Diese Änderung persistiert auch nach dem Laden eines 
-- Spielstandes und muss explizit mit dieser Funktion zurückgenommen werden!
--
-- @param _Flag Widget versteckt
-- @within User-Space
--
function API.HideBuyTerritory(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideBuyTerritory(" ..tostring(_Flag).. ")");
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
-- <b>Hinweis:</b> Diese Änderung persistiert auch nach dem Laden eines 
-- Spielstandes und muss explizit mit dieser Funktion zurückgenommen werden!
--
-- @param _Flag Widget versteckt
-- @within User-Space
--
function API.HideKnightAbility(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideKnightAbility(" ..tostring(_Flag).. ")");
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
-- <b>Hinweis:</b> Diese Änderung persistiert auch nach dem Laden eines 
-- Spielstandes und muss explizit mit dieser Funktion zurückgenommen werden!
--
-- @param _Flag Widget versteckt
-- @within User-Space
--
function API.HideKnightButton(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideKnightButton(" ..tostring(_Flag).. ")");
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
-- <b>Hinweis:</b> Diese Änderung persistiert auch nach dem Laden eines 
-- Spielstandes und muss explizit mit dieser Funktion zurückgenommen werden!
--
-- @param _Flag Widget versteckt
-- @within User-Space
--
function API.HideSelectionButton(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideSelectionButton(" ..tostring(_Flag).. ")");
        return;
    end
    API.HideKnightButton(_Flag);
    GUI.ClearSelection();
    
    BundleInterfaceApperance.Local:HideInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/BattalionButton",
        _Flag
    );
end

---
-- Versteckt das Baumenü oder blendet es ein.
--
-- <b>Hinweis:</b> Diese Änderung persistiert auch nach dem Laden eines 
-- Spielstandes und muss explizit mit dieser Funktion zurückgenommen werden!
--
-- @param _Flag Widget versteckt
-- @within User-Space
--
function API.HideBuildMenu(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideBuildMenu(" ..tostring(_Flag).. ")");
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
-- <b>Hinweis:</b> Es kann vorkommen, dass das Bild nicht genau da ist, wo es
-- sein soll, sondern seine Position, je nach Auflösung, um ein paar Pixel 
-- unterschiedlich ist.
-- 
-- @param _widget Widgetpfad oder ID
-- @param _file   Pfad zur Datei
-- @within User-Space
--
function API.SetTexture(_widget, _file)
    if not GUI then
        return;
    end
    BundleInterfaceApperance.Local:SetTexture(_widget, _file)
end
UserSetTexture = API.SetTexture;

---
-- Setzt einen Icon aus einer benutzerdefinierten Icon Matrix.
--
-- Dabei müssen die Quellen nach gui_768, gui_920 und gui_1080 in der
-- entsprechenden Größe gepackt werden. Die Ordner liegen in graphics/textures.
-- Jede Map muss einen eigenen eindeutigen Namen für jede Grafik verwenden.
--
-- <u>Größen:</u>
-- Die gesamtgrßee ergibt sich aus der Anzahl der Buttons und der Pixelbreite
-- für die jeweilige Grö0e. z.B. 64 Buttons -> Größe * 8 x Größe * 8
-- <ul>
-- <li>768: 41x41</li>
-- <li>960: 52x52</li>
-- <li>1200: 64x64</li>
-- </ul>
--
-- <u>Namenskonvention:</u>
-- Die Namenskonvention wird durch das Spiel vorgegeben. Je nach größe sind 
-- die Namen der Matrizen erweitert mit .png, big.png und verybig.png. Du
-- gibst also niemals die Dateiendung mit an!
-- <ul>
-- <li>Für normale Icons: _Name .. .png</li>
-- <li>Für große Icons: _Name .. big.png</li>
-- <li>Für riesige Icons: _Name .. verybig.png</li>
-- </ul>
-- 
-- @param _WidgetID    Widgetpfad oder ID
-- @param _Coordinates Koordinaten
-- @param _Size        Größe des Icon
-- @param _Name        Name der Icon Matrix
-- @within User-Space
--
function API.SetIcon(_WidgetID, _Coordinates, _Size, _Name)
    if not GUI then
        return;
    end
    BundleInterfaceApperance.Local:SetIcon(_WidgetID, _Coordinates, _Size, _Name)
end
UserSetIcon = API.SetIcon;

---
-- Ändert den aktuellen Tooltip mit der Beschreibung.
--
-- <b>Alias:</b> UserSetTextNormal
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
-- @param _title        Titel des Tooltip
-- @param _text         Text des Tooltip
-- @param _disabledText Textzusatz wenn inaktiv
-- @within User-Space
--
function API.SetTooltipNormal(_title, _text, _disabledText)
    if not GUI then 
        return;
    end
    BundleInterfaceApperance.Local:TextNormal(_title, _text, _disabledText);
end
UserSetTextNormal = API.SetTooltipNormal;

---
-- Ändert den aktuellen Tooltip mit der Beschreibung und den Kosten.
--
-- <b>Alias:</b> UserSetTextBuy
--
-- @see API.SetTooltipNormal
-- 
-- @param _title        Titel des Tooltip
-- @param _text         Text des Tooltip
-- @param _disabledText Textzusatz wenn inaktiv
-- @param _costs        Kostentabelle
-- @param _inSettlement Kosten in Siedlung suchen
-- @within User-Space
--
function API.SetTooltipCosts(_title,_text,_disabledText,_costs,_inSettlement)
    if not GUI then
        return;
    end
    BundleInterfaceApperance.Local:TextCosts(_title,_text,_disabledText,_costs,_inSettlement);
end
UserSetTextBuy = API.SetTooltipCosts;

---
-- Gibt den Namen des Territoriums zurück.
--
-- <b>Alias:</b> GetTerritoryName
--
-- @return _TerritoryID ID des Territoriums
-- @return Name des Territorium
-- @within User-Space
--
function API.GetTerritoryName(_TerritoryID)
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
GetTerritoryName = API.GetTerritoryName;

---
-- Gibt den Namen des Spielers zurück.
--
-- <b>Alias:</b> GetPlayerName
--
-- @return _PlayerID ID des Spielers
-- @return Name des Territorium
-- @within User-Space
--
function API.GetPlayerName(_PlayerID)
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
GetPlayerName = API.GetPlayerName;

---
-- Gibt dem Spieler einen neuen Namen.
--
-- <b>Alias:</b> SetPlayerName
--
-- @return _playerID ID des Spielers
-- @return _name     Name des Spielers
-- @return Name des Territorium
-- @within User-Space
--
function API.SetPlayerName(_playerID,_name)
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
SetPlayerName = API.SetPlayerName;

---
-- Setzt zu Spielbeginn eine andere Spielerfarbe.
--
-- @return _PlayerID ID des Spielers
-- @return _Color    Spielerfarbe
-- @return _Logo     Logo (optional)
-- @return _Pattern  Pattern (optional)
-- @return Name des Territorium
-- @within User-Space
--
function API.SetPlayerColor(_PlayerID, _Color, _Logo, _Pattern)
    if GUI then
        return;
    end
    local Type    = type(_Color);
    local Col     = (type(_Color) == "string" and g_ColorIndex[_Color]) or _Color;
    local Logo    = _Logo or -1;
    local Pattern = _Pattern or -1;
    
    g_ColorIndex["ExtraColor1"] = 16;
    g_ColorIndex["ExtraColor2"] = 17;
    
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
-- @within Application-Space
-- @local
--
function BundleInterfaceApperance.Global:Install()
    API.AddSaveGameAction(BundleInterfaceApperance.Global.RestoreAfterLoad);
end

---
-- Stellt alle versteckten Buttons nach dem Laden eines Spielstandes wieder her.
-- @within Application-Space
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
-- @within Application-Space
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
-- @param _Widget Widgetpfad oder ID
-- @param _Hide   Hidden Flag
-- @within Application-Space
-- @local
--
function BundleInterfaceApperance.Local:HideInterfaceButton(_Widget, _Hide)
    self.Data.HiddenWidgets[_Widget] = _Hide == true;
    XGUIEng.ShowWidget(_Widget, (_Hide == true and 0) or 1);
end

---
-- Stellt alle versteckten Buttons nach dem Laden eines Spielstandes wieder her.
-- @within Application-Space
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
-- @param _widget Widgetpfad oder ID
-- @param _file   Pfad zur Datei
-- @within Application-Space
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
-- @param _WidgetID    Widgetpfad oder ID
-- @param _Coordinates Koordinaten
-- @param _Size        Größe des Icon
-- @param _Name        Name der Icon Matrix
-- @within Application-Space
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
-- @param _title        Titel des Tooltip
-- @param _text         Text des Tooltip
-- @param _disabledText Textzusatz wenn inaktiv
-- @within Application-Space
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
-- @param _title        Titel des Tooltip
-- @param _text         Text des Tooltip
-- @param _disabledText Textzusatz wenn inaktiv
-- @param _costs        Kostentabelle
-- @param _inSettlement Kosten in Siedlung suchen
-- @within Application-Space
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

