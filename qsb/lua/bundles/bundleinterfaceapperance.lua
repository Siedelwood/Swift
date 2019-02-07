-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleInterfaceApperance                                     # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle bietet dem Nutzer Funktionen zur Manipulation der Oberfläche
-- des Spiels. Der Mapper hat die Möglichkeit, eigene Texte und Grafiken im
-- Interface anzuzeigen.
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
-- @param[type=string] _widget Widgetpfad oder ID
-- @param[type=string] _file Pfad zur Datei
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
-- @param[type=string] _WidgetID Widgetpfad oder ID
-- @param[type=table]  _Coordinates Koordinaten
-- @param[type=number] _Size Größe des Icon
-- @param[type=string] _Name Name der Icon Matrix
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
-- @param[type=string] _title        Titel des Tooltip
-- @param[type=string] _text         Text des Tooltip
-- @param[type=string] _disabledText Textzusatz wenn inaktiv
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
-- @param[type=string]  _title        Titel des Tooltip
-- @param[type=string]  _text         Text des Tooltip
-- @param[type=string]  _disabledText Textzusatz wenn inaktiv
-- @param[type=table]   _costs        Kostentabelle
-- @param[type=boolean] _inSettlement Kosten in Siedlung suchen
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
-- @param[type=number] _TerritoryID ID des Territoriums
-- @return[type=string]  Name des Territorium
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
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=string]  Name des Spielers
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
-- @param[type=number] _playerID ID des Spielers
-- @param[type=string] _name Name des Spielers
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
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Color Spielerfarbe
-- @param[type=number] _Logo Logo (optional)
-- @param[type=number] _Pattern Pattern (optional)
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

---
-- Setzt das Portrait des Spielers.
--
-- Dabei gibt es 3 verschiedene Varianten:
-- <ul>
-- <li>Wenn _Portrait nicht gesetzt wird, wird das Portrait des Primary
-- Knight genommen.</li>
-- <li>Wenn _Portrait ein existierendes Entity ist, wird anhand des Typs
-- das Portrait bestimmt.</li>
-- <li>Wenn _Portrait der Modellname eines Portrait ist, wird der Wert
-- als Portrait gesetzt.</li>
-- </ul>
--
-- Wenn kein Portrait bestimmt werden kann, wird H_NPC_Generic_Trader verwendet.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=string] _Portrait Name des Models
-- @within Anwenderfunktionen
--
-- @usage -- Primary Knight
-- API.InterfaceSetPlayerPortrait(2);
-- -- Durch Entity
-- API.InterfaceSetPlayerPortrait(2, "amma");
-- -- Durch Modelname
-- API.InterfaceSetPlayerPortrait(2, "H_NPC_Monk_AS");
--
function API.InterfaceSetPlayerPortrait(_PlayerID, _Portrait)
    if not _PlayerID or type(_PlayerID) ~= "number" or (_PlayerID < 1 or _PlayerID > 8) then
        API.Fatal("API.InterfaceSetPlayerPortrait: Invalid player ID!");
        return;
    end
    if not GUI then
        local Portrait = (_Portrait ~= nil and "'" .._Portrait.. "'") or "nil";
        API.Bridge("API.InterfaceSetPlayerPortrait(" .._PlayerID.. ", " ..Portrait.. ")")
        return;
    end
    
    if _Portrait == nil then
        BundleInterfaceApperance.Local:SetPlayerPortraitByPrimaryKnight(_PlayerID);
        return;
    end
    if _Portrait ~= nil and IsExisting(_Portrait) then
        BundleInterfaceApperance.Local:SetPlayerPortraitBySettler(_PlayerID, _Portrait);
        return;
    end
    BundleInterfaceApperance.Local:SetPlayerPortraitByModelName(_PlayerID, _Portrait);
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleInterfaceApperance = {
    Global = {},
    Local = {}
};

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
end

---
-- Setzt das Portrait des Spielers anhand des Primary Knight.
-- @param[type=number] _PlayerID ID des Spielers
-- @within Internal
-- @local
--
function BundleInterfaceApperance.Local:SetPlayerPortraitByPrimaryKnight(_PlayerID)
    local KnightID = Logic.GetKnightID(_PlayerID);
    if KnightID == 0 then
        return;
    end
    local KnightType = Logic.GetEntityType(KnightID);
    local KnightTypeName = Logic.GetEntityTypeName(KnightType);
    local HeadModelName = "H" .. string.sub(KnightTypeName, 2, 8) .. "_" .. string.sub(KnightTypeName, 9);

    if not Models["Heads_" .. HeadModelName] then
        HeadModelName = "H_NPC_Generic_Trader";
    end
    g_PlayerPortrait[_PlayerID] = HeadModelName;
end

---
-- Setzt das Portrait des Spielers anhand der übergebenen Script Entity.
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=string] _Portrait Skriptname des Entity
-- @within Internal
-- @local
--
function BundleInterfaceApperance.Local:SetPlayerPortraitBySettler(_PlayerID, _Portrait)
    local PortraitMap = {
        ["U_KnightChivalry"]           = "H_Knight_Chivalry",
        ["U_KnightHealing"]            = "H_Knight_Healing",
        ["U_KnightPlunder"]            = "H_Knight_Plunder",
        ["U_KnightRedPrince"]          = "H_Knight_RedPrince",
        ["U_KnightSabatta"]            = "H_Knight_Sabatt",
        ["U_KnightSong"]               = "H_Knight_Song",
        ["U_KnightTrading"]            = "H_Knight_Trading",
        ["U_KnightWisdom"]             = "H_Knight_Wisdom",
        ["U_NPC_Amma_NE"]              = "H_NPC_Amma",
        ["U_NPC_Castellan_ME"]         = "H_NPC_Castellan_ME",
        ["U_NPC_Castellan_NA"]         = "H_NPC_Castellan_NA",
        ["U_NPC_Castellan_NE"]         = "H_NPC_Castellan_NE",
        ["U_NPC_Castellan_SE"]         = "H_NPC_Castellan_SE",
        ["U_MilitaryBandit_Ranged_ME"] = "H_NPC_Mercenary_ME",
        ["U_MilitaryBandit_Melee_NA"]  = "H_NPC_Mercenary_NA",
        ["U_MilitaryBandit_Melee_NE"]  = "H_NPC_Mercenary_NE",
        ["U_MilitaryBandit_Melee_SE"]  = "H_NPC_Mercenary_SE",
        ["U_NPC_Monk_ME"]              = "H_NPC_Monk_ME",
        ["U_NPC_Monk_NA"]              = "H_NPC_Monk_NA",
        ["U_NPC_Monk_NE"]              = "H_NPC_Monk_NE",
        ["U_NPC_Monk_SE"]              = "H_NPC_Monk_SE",
        ["U_NPC_Villager01_ME"]        = "H_NPC_Villager01_ME",
        ["U_NPC_Villager01_NA"]        = "H_NPC_Villager01_NA",
        ["U_NPC_Villager01_NE"]        = "H_NPC_Villager01_NE",
        ["U_NPC_Villager01_SE"]        = "H_NPC_Villager01_SE",
    }

    if g_GameExtraNo > 0 then
        PortraitMap["U_KnightPraphat"]           = "H_Knight_Praphat";
        PortraitMap["U_KnightSaraya"]            = "H_Knight_Saraya";
        PortraitMap["U_KnightKhana"]             = "H_Knight_Khana";
        PortraitMap["U_MilitaryBandit_Melee_AS"] = "H_NPC_Mercenary_AS";
        PortraitMap["U_NPC_Castellan_AS"]        = "H_NPC_Castellan_AS";
        PortraitMap["U_NPC_Villager_AS"]         = "H_NPC_Villager_AS";
        PortraitMap["U_NPC_Monk_AS"]             = "H_NPC_Monk_AS";
        PortraitMap["U_NPC_Monk_Khana"]          = "H_NPC_Monk_Khana";
    end

    local HeadModelName = "H_NPC_Generic_Trader";
    local EntityID = GetID(_Portrait);
    if EntityID ~= 0 then
        local EntityType = Logic.GetEntityType(EntityID);
        local EntityTypeName = Logic.GetEntityTypeName(EntityType);
        HeadModelName = PortraitMap[EntityTypeName] or "H_NPC_Generic_Trader";
        if not HeadModelName then
            HeadModelName = "H_NPC_Generic_Trader";
        end
    end
    g_PlayerPortrait[_PlayerID] = HeadModelName;
end

---
-- Setzt das Portrait des Spielers anhand des angegebenen Models.
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=string] _Portrait Name des Models
-- @within Internal
-- @local
--
function BundleInterfaceApperance.Local:SetPlayerPortraitByModelName(_PlayerID, _Portrait)
    if not Models["Heads_" .. tostring(_Portrait)] then
        _Portrait = "H_NPC_Generic_Trader";
    end
    g_PlayerPortrait[_PlayerID] = _Portrait;
end

---
-- Setzt einen Icon aus einer benutzerdefinerten Datei.
--
-- @param[type=string] _widget Widgetpfad oder ID
-- @param[type=string] _file Pfad zur Datei
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
-- @param[type=string] _WidgetID Widgetpfad oder ID
-- @param[type=table]  _Coordinates Koordinaten
-- @param[type=number] _Size Größe des Icon
-- @param[type=string] _Name Name der Icon Matrix
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
-- @param[type=string] _title        Titel des Tooltip
-- @param[type=string] _text         Text des Tooltip
-- @param[type=string] _disabledText Textzusatz wenn inaktiv
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
-- @param[type=string]  _title        Titel des Tooltip
-- @param[type=string]  _text         Text des Tooltip
-- @param[type=string]  _disabledText Textzusatz wenn inaktiv
-- @param[type=table]   _costs        Kostentabelle
-- @param[type=boolean] _inSettlement Kosten in Siedlung suchen
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

