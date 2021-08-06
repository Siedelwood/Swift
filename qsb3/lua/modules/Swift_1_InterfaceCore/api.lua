-- Interface API ------------------------------------------------------------ --

---
-- Dieses Modul bietet grundlegende Funktionen zur Manipulation des Interface.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_0_Core.api.html">(0) Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Setzt einen Icon aus einer benutzerdefinierten Icon Matrix.
--
-- Es wird also die Grafik eines Button oder Icon mit einer neuen Grafik
-- ausgetauscht.
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
    ModuleInterfaceCore.Local:SetIcon(_WidgetID, _Coordinates, _Size, _Name)
end

---
-- Ändert den Beschreibungstext eines Button oder eines Icon.
--
-- Wichtig ist zu beachten, dass diese Funktion in der Update-Funktion des
-- Button oder Icon ausgeführt werden muss.
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
    ModuleInterfaceCore.Local:TextNormal(_title, _text, _disabledText);
end
UserSetTextNormal = API.InterfaceSetTooltipNormal;

---
-- Ändert den Beschreibungstext und die Kosten eines Button.
--
-- Wichtig ist zu beachten, dass diese Funktion in der Update-Funktion des
-- Button oder Icon ausgeführt werden muss.
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
    ModuleInterfaceCore.Local:TextCosts(_title,_text,_disabledText,_costs,_inSettlement);
end

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
-- Setzt eine andere Spielerfarbe.
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
    g_ColorIndex["ExtraColor1"] = g_ColorIndex["ExtraColor1"] or 16;
    g_ColorIndex["ExtraColor2"] = g_ColorIndex["ExtraColor2"] or 17;

    local Type    = type(_Color);
    local Col     = (type(_Color) == "string" and g_ColorIndex[_Color]) or _Color;
    local Logo    = _Logo or -1;
    local Pattern = _Pattern or -1;

    Logic.PlayerSetPlayerColor(_PlayerID, Col, _Logo, _Pattern);
    Logic.ExecuteInLuaLocalState([[
        Display.UpdatePlayerColors()
        GUI.RebuildMinimapTerrain()
        GUI.RebuildMinimapTerritory()
    ]]);
end

---
-- Setzt das Portrait eines Spielers.
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
-- <b>Trivia</b>: Diese Funktionalität wird Umgangssprachlich als "Köpfe
-- tauschen" oder "Köpfe wechseln" bezeichnet.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=string] _Portrait Name des Models
-- @within Anwenderfunktionen
--
-- @usage -- Kopf des Primary Knight
-- API.InterfaceSetPlayerPortrait(2);
-- -- Kopf durch Entity bestimmen
-- API.InterfaceSetPlayerPortrait(2, "amma");
-- -- Kopf durch Modelname setzen
-- API.InterfaceSetPlayerPortrait(2, "H_NPC_Monk_AS");
--
function API.InterfaceSetPlayerPortrait(_PlayerID, _Portrait)
    if not _PlayerID or type(_PlayerID) ~= "number" or (_PlayerID < 1 or _PlayerID > 8) then
        error("API.InterfaceSetPlayerPortrait: Invalid player ID!");
        return;
    end
    if not GUI then
        local Portrait = (_Portrait ~= nil and "'" .._Portrait.. "'") or "nil";
        Logic.ExecuteInLuaLocalState("API.InterfaceSetPlayerPortrait(" .._PlayerID.. ", " ..Portrait.. ")")
        return;
    end
    
    if _Portrait == nil then
        ModuleInterfaceCore.Local:SetPlayerPortraitByPrimaryKnight(_PlayerID);
        return;
    end
    if _Portrait ~= nil and IsExisting(_Portrait) then
        ModuleInterfaceCore.Local:SetPlayerPortraitBySettler(_PlayerID, _Portrait);
        return;
    end
    ModuleInterfaceCore.Local:SetPlayerPortraitByModelName(_PlayerID, _Portrait);
end

