---
-- Ermöglicht die Verwaltung von zusammenhängenden versteckten Maps als eine
-- Art Kampagne.
--
-- Die einzelnen Teile der Kampagne müssen nicht von Anfang an dem Loader
-- bekannt gemacht werden. Der Spieler kann nach und nach weitere Teile
-- herunterladen und sie werden automatisch hinzugefügt.
--
-- Eine Map muss eine Konfigurationsdatei "maploader.lua" enthalten. So eine
-- Konfiguration kann wie folgt aussehen:
-- <pre>LocalMapData = {
--    MapCode = "Bockwurst",          -- Codewort, das im Profil stehen muss
--    Splashscreen = true,            -- Splashscreen anzeigen (splashscreen.png)
--    LoaderVersion = 1,              -- Benötigte Version des Loader
--    PossibleKnights = {             -- Auswählbare Helden
--        "U_KnightTrading",
--        "U_KnightHealing",
--        "U_KnightChivalry",
--        "U_KnightWisdom",
--        "U_KnightPlunder",
--        "U_KnightSong",
--        "U_KnightSabatta",
--        "U_KnightRedPrince",
--    },
--    RequiredMaps = {                -- Benötigte Maps (max. 5)
--        "twa01_swm_examplemap1",
--        "twa02_swm_examplemap2",
--    },
--};</pre>
-- Nicht benötigte Angaben können weggelassen werden.
--
-- @set sort=true
--

ExternalMapLoader = {};

API = API or {};
QSB = QSB or {};

-- Anwenderfunktionen ------------------------------------------------------- --

function API.Campaign_Initalize()
	if not GUI then
		API.Bridge("API.Campaign_Initalize()");
		return;
	end
	ExternalMapLoader.Local:Initalize();
end

function API.Campaign_StartSelection()
	if not GUI then
		API.Bridge("API.Campaign_StartSelection()");
		return;
	end
	StartSimpleHiResJobEx(function()
		if XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 0 then
			ExternalMapLoader.Local:OverrideEndscreenDialog();
			OpenCustomGameDialog();
			return true;
		end
	end);	
end

-- Applikation -------------------------------------------------------------- --

ExternalMapLoader = {
	Global = {
        Data = {
			Campaign = {
				MapNames = {},
				MapData = {},
				BaseName = {},
				Version  = 1,
			}
		},
    },
    Local = {
        Data = {
			Campaign = {
				MapNames = {},
				MapData = {},
				BaseName = {
					"as[0-9]*_swm_",    -- Annosiedler
					"bb[0-9]*_swm_",    -- barbara27h
					"dico[0-9]*_swm_",  -- DiCo
					"fi[0-9]*_swm_",    -- fidelio
					"gitti[0-9]*_swm_", -- gitti1962
					"jlmb[0-9]*_swm_",  -- jlmb
					"twa[0-9]*_swm_"    -- totalwarANGEL
				},
				Version  = 1,
			},
		},
	},

	Text = {
		StartMap = {
			de = "{center}Mission starten",
			en = "{center}Start mission"
		},
		Back = {
			de = "{center}Hauptmenü",
			en = "{center}Main menu"
		},
		MapNotFound = {
			de = "{cr}{scarlet}Es wurde keine spielbare Map ausgewählt!",
			en = "{cr}{scarlet}No playable map has been selected!",
		},
		InsufficentLoaderVersion = {
			de = "{cr}{scarlet}Die Version des Maploaders ist zu niedrig!",
			en = "{cr}{scarlet}The version of the maploader is to old!",
		},
		RequiredMaps = {
			Title = {
				de = "Benötigte Maps",
				en = "Required maps",
			},
			Text = {
				de = "Schließt zuerst folgende Karten ab: {cr}",
				en = "Finish the following maps first: {cr}",
			},
		},
	}
}

-- Global Script ------------------------------------------------------------ --

---
-- Installiert das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function ExternalMapLoader.Global:Install()
end

-- Local Script ------------------------------------------------------------- --

---
-- Installiert das Bundle im lokalen Skript
-- @within Internal
-- @local
--
function ExternalMapLoader.Local:Install()
	Script.Load("script/mainmenu/customgame.lua");
	self:OverrideCustomGameMapSelectionDialog();
	StartSimpleJobEx(self.OnEverySecond);
end

---
-- Initialisiert den Maploader.
--
-- <ul>
-- <li>Setzt die Loader-Version im Profil</li>
-- <li>Läd die Maps entsprechend des eingestellten Base Name</li>
-- </ul>
--
-- @within Internal
-- @local
--
function ExternalMapLoader.Local:Initalize()
	local MapName = Framework.GetCurrentMapName();
	Profile.SetInteger(MapName, "Version", self.Data.Campaign.Version);
	self:ScanForMaps();
end

---
-- Läd die im Loader auswählbaren Maps.
--
-- @within Internal
-- @local
--
function ExternalMapLoader.Local:ScanForMaps()
	self.Data.Campaign.MapNames = {};
	self.Data.Campaign.MapData  = {};

    local CurrentIndex = 0;
    local MapsPerIteration = 50;
    local NewMaps;
    repeat
        NewMaps = {Framework.GetMapNames(CurrentIndex, MapsPerIteration, 1, nil)};
		for i= 1, #NewMaps, 1 do
			for k, v in pairs(self.Data.Campaign.BaseName) do
				if NewMaps[i]:find("^" ..v) then
					-- Map der Liste hinzufügen
					local Index = #self.Data.Campaign.MapNames;
					table.insert(self.Data.Campaign.MapNames, NewMaps[i]);
					-- Maploader Konfiguration laden
					Script.Load("maps/development/" ..NewMaps[i].. "/maploader.lua");
					self.Data.Campaign.MapData[NewMaps[i]] = API.InstanceTable(LocalMapData or {});
					LocalMapData = nil;
				end
		    end
        end
        CurrentIndex = CurrentIndex + MapsPerIteration;
    until table.getn(NewMaps) < MapsPerIteration;
end

---
-- Setzt die selektierte Map.
--
-- Es wird die Beschreibung angepasst und optional ein Splashscreen aus der
-- gewählten Map angezeigt.
--
-- Dateiname Splashscreen: splashscreen.png
-- 
-- Es muss außerdem ein Skript in der Map vorhanden sein, welches 
-- CustomGame.Splashscreen auf true setzt. Das Skript heißt splashscreen.lua.
--
-- @param[type=number] _Selected Ausgewählte Map
-- @within Internal
-- @local
--
function ExternalMapLoader.Local:SelectMap(_Selected)
	self.Data.Campaign.SelectedMapName = self.Data.Campaign.MapNames[_Selected];
	local Name = self.Data.Campaign.SelectedMapName;
	local Path = "maps/development/" ..Name;
	
	-- Map Description
	local MotherWidget = "/LoadScreen/LoadScreen/ContainerDescription";
	local MapInfo = ExternalMapLoader.Local:GetMapInformation(Name);
	XGUIEng.SetText(MotherWidget.. "/MapName", MapInfo[1]);
	XGUIEng.SetText(MotherWidget.. "/LoadScreenReadMe", MapInfo[2]);
	
	-- Map Splashscreen
	if self.Data.Campaign.MapData[Name] and self.Data.Campaign.MapData[Name].Splashscreen then
		-- Image aus der Map
		XGUIEng.SetMaterialTexture("/EndScreen/EndScreen/BG", 0, Path.. "/splashscreen.png");
		XGUIEng.SetMaterialColor("/EndScreen/EndScreen/BG", 0, 255, 255, 255, 255);
	else
		-- Default Image
		XGUIEng.SetMaterialTexture("/EndScreen/EndScreen/BG", 0, "graphics/textures/gui_1200/mainmenu/limitedbg.png");
		XGUIEng.SetMaterialColor("/EndScreen/EndScreen/BG", 0, 255, 255, 255, 255);
	end
end

---
-- Startet die ausgewählte Map, falls möglich.
--
-- TODO: Fehlermeldung, wenn Map nicht gestartet werden kann.
--
-- @within Internal
-- @local
--
function ExternalMapLoader.Local:StartMap()
	local MapName = Framework.GetCurrentMapName();
	local Name    = self.Data.Campaign.SelectedMapName;

	-- Prüfen ob Map existiert
	if Name == nil or Framework.GetMapNameAndDescription(Name) == nil then
		API.Message(ExternalMapLoader.Text.MapNotFound);
		return;
	end

	-- Prüfen ob die Loader-Version kompatibel ist
	local RequiredVersion = self.Data.Campaign.MapData[Name].LoaderVersion or 1;
	if RequiredVersion > self.Data.Campaign.Version then
		API.Message(ExternalMapLoader.Text.InsufficentLoaderVersion);
		return;
	end

	-- Prüfen ob benötigte Maps gespielt wurden
	if ExternalMapLoader.Local:CanMapBeStarted(Name) ~= true then
		local Text = API.Localize(ExternalMapLoader.Text.RequiredMaps.Text);
		for k, v in pairs(self.Data.Campaign.MapData[Name].RequiredMaps) do
			local Info = self:GetMapInformation(v);
			Text = Text .. "- " ..Info[1].. "{cr}";
		end

		API.DialogInfoBox(
			ExternalMapLoader.Text.RequiredMaps.Title,
			Text,
			function() end
		);
		return;
	end

	-- Map starten
	local Knight = CustomGame.Knight +1;
	Profile.SetString(Name, "SelectedKnight", CustomGame.KnightTypes[Knight]);
	Profile.SetString(Name, "MapLoader", MapName);
	Profile.SetInteger(Name, "MapLoaderVersion", self.Data.Campaign.MapData[Name].LoaderVersion or 1);
	Framework.SetLoadScreenNeedButton(1);
	InitLoadScreen(false, 1, Name, 0, 0);
	Framework.ResetProgressBar();
	Framework.StartMap(Name, 1, Knight);
end

---
-- Prüft, ob die Map erfolgreich abgeschlossen wurde.
--
-- Die Map muss sich um das Setzen des Codes selbst kümmern.
--
-- @param[type=string] _Name Map
-- @within Internal
-- @local
--
function ExternalMapLoader.Local:IsMapCompleted(_Name)
	-- Map gehört nicht zur Kampagne und kann daher nicht vorausgesetzt werden
	if self.Data.Campaign.MapData[_Name] == nil then
		return true;
	end
	-- Code prüfen
	return Profile.GetString(_Name, "SuccessfullyFinished") == self.Data.Campaign.MapData[_Name].MapCode;
end

---
-- Prüft ob die Map gestartet werden kann, oder ob vorher noch andere Maps
-- gespielt werden müssen.
--
-- @param[type=string] _Name Map
-- @within Internal
-- @local
--
function ExternalMapLoader.Local:CanMapBeStarted(_Name)
	-- Map hat keine Konfiguration
	if self.Data.Campaign.MapData[_Name] == nil then
		return true;
	end
	-- Map setzt keine anderen Maps voraus
	if self.Data.Campaign.MapData[_Name].RequiredMaps == nil or #self.Data.Campaign.MapData[_Name].RequiredMaps == 0 then
		return true;
	end
	-- Prüfe Codes der vorausgesetzten Maps
	for k, v in pairs(self.Data.Campaign.MapData[_Name].RequiredMaps) do
		if self:IsMapCompleted(v) ~= true then
			return false;
		end
	end
	return true;
end

---
-- Befüllt die Combobox mit den möglichen Helden.
--
-- @param[type=boolean] _TryToKeepSelectedKnight Ausgewählten Helden halten
-- @within Internal
-- @local
--
function ExternalMapLoader.Local:FillHeroComboBox(_TryToKeepSelectedKnight)
	-- Keine Helden vorgebenen
	local Name = self.Data.Campaign.SelectedMapName;
	if self.Data.Campaign.MapData[Name] == nil or self.Data.Campaign.MapData[Name].PossibleKnights == nil then
		CustomGame_FillHeroComboBox_Orig_MapLoader(_TryToKeepSelectedKnight);
		return;
	end
	local HeroComboBoxID = XGUIEng.GetWidgetID(CustomGame.Widget.KnightsList);

	-- Letzten Helden speichern
    local OldKnightName
    if _TryToKeepSelectedKnight then
        local Index = XGUIEng.ListBoxGetSelectedIndex(HeroComboBoxID);
        OldKnightName = CustomGame.CurrentKnightList[Index +1];
    end
    XGUIEng.ListBoxPopAll(HeroComboBoxID);
	
	-- Helden aus MapData laden
    local KnightSelection = CustomGame.KnightTypes;
	if #self.Data.Campaign.MapData[Name].PossibleKnights > 0 then
		KnightSelection = self.Data.Campaign.MapData[Name].PossibleKnights;
	end
    CustomGame.CurrentKnightList = KnightSelection;
	
	-- Liste befüllen
    for i= 1, #KnightSelection, 1 do
        XGUIEng.ListBoxPushItem(HeroComboBoxID, XGUIEng.GetStringTableText("Names/" .. KnightSelection[i]));
    end
    
    local SelectIndex = 0;
    if _TryToKeepSelectedKnight then
        for i= 1, #KnightSelection, 1 do
            if KnightSelection[i] == OldKnightName then
                SelectIndex = i -1;
                break;
            end
        end
    end
    XGUIEng.ListBoxSetSelectedIndex(HeroComboBoxID, SelectIndex);
    CustomGame_OnHeroListBoxSelectionChange();
end

---
-- Läd die Informationen der angegebenen map.
--
-- Es werden Titel, beschreibung, Größe und Modus zurückgegeben.
--
-- @param[type=string] _Name Name der Map (interner Name)
-- @return[type=table] Daten der Map
-- @within Internal
-- @local
--
function ExternalMapLoader.Local:GetMapInformation(_Name)
	local MapName, MapDescription, Size, Mode = Framework.GetMapNameAndDescription(_Name, 1);
	if MapName == nil then
		return nil;
	end
	return {MapName, MapDescription, Size, Mode};
end

---
-- Kopiert die Daten der Kampagne ins globale Skript.
--
-- @within Internal
-- @local
--
function ExternalMapLoader.Local:CopyDataToGlobalScript()
	local Campaign = API.ConvertTableToString(self.Data.Campaign);
	API.Bridge(string.format([[
		local Campaign = %s
		for k, v in pairs(Campaign) do
			if type(v) == "table" then
				ExternalMapLoader.Global.Data.Campaign[k] = API.InstanceTable(v)
			else
				ExternalMapLoader.Global.Data.Campaign[k] = v
			end
		end
	]], Campaign));
end

---
-- Zeigt die Steuerelemente des Maploaders an
--
-- @within Internal
-- @local
--
function ExternalMapLoader.Local:OverrideEndscreenDialog()
	-- Endscreen Bild
	local MotherWidget = "/EndScreen/EndScreen";
	XGUIEng.ShowWidget(MotherWidget.. "/BackGround", 0);
	XGUIEng.ShowWidget(MotherWidget.. "/BG", 1);
	XGUIEng.PushPage(MotherWidget, false);
	EndScreen_ExitGame = function() end
	
	-- Kartenbeschreibung
	local MotherWidget = "/LoadScreen/LoadScreen/ContainerDescription";
	XGUIEng.ShowWidget(MotherWidget, 1);
	XGUIEng.PushPage(MotherWidget, false);

	-- Endscreen Steuerung
	local MotherWidget = "/InGame/InGame/MissionEndScreen";
	XGUIEng.ShowWidget(MotherWidget, 1);
	XGUIEng.PushPage(MotherWidget, false);
	XGUIEng.ShowAllSubWidgets(MotherWidget, 0);
	XGUIEng.ShowWidget(MotherWidget.. "/BG", 0);
	XGUIEng.ShowWidget(MotherWidget.. "/CurrentStatus", 0);
	XGUIEng.ShowWidget(MotherWidget.. "/BGDouble", 1);
	XGUIEng.ShowWidget(MotherWidget.. "/ContinuePlaying", 1);
	XGUIEng.ShowWidget(MotherWidget.. "/Next", 1);

	-- Buttons
	local Text = API.Localize(ExternalMapLoader.Text.StartMap);
	XGUIEng.SetText(MotherWidget.. "/ContinuePlaying", Text);
	XGUIEng.SetActionFunction(MotherWidget.. "/ContinuePlaying", "ExternalMapLoader.Local:StartMap()");
	local Text = API.Localize(ExternalMapLoader.Text.Back);
	XGUIEng.SetText(MotherWidget.. "/Next", Text);
	XGUIEng.SetActionFunction(MotherWidget.. "/Next", "Framework.CloseGame()");
end

---
-- Überschreibt die Kartenauswahl des Single Player Menü.
--
-- @within Internal
-- @local
--
function ExternalMapLoader.Local:OverrideCustomGameMapSelectionDialog()
	local KnightTypes = {
		"U_KnightTrading",
		"U_KnightHealing",
		"U_KnightChivalry",
		"U_KnightWisdom",
		"U_KnightPlunder",
		"U_KnightSong",
		"U_KnightSabatta",
		"U_KnightRedPrince",
	};
	if g_GameExtraNo > 0 then
		table.insert(KnightTypes, 7, "U_KnightSaraya");
	end

	g_MapAndHeroPreview.KnightTypes = API.InstanceTable(KnightTypes);
	CustomGame.KnightTypes = API.InstanceTable(KnightTypes);

	-- ---------------------------------------------------------------------- --
	
	OpenCustomGameDialog = function()
		XGUIEng.ShowWidget("/InGame/Singleplayer/RightMenu", 0)
		XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", 0)
		XGUIEng.ShowWidget("/InGame/Root/3dWorldView", 0)
		XGUIEng.ShowWidget("/InGame/Root/Normal", 0)
		XGUIEng.ShowAllSubWidgets(CustomGame.Widget.Dialog,1)
		XGUIEng.PushPage(CustomGame.Widget.Dialog, false)
		XGUIEng.PushPage("/InGame/Root/Normal/TextMessages", false)

		XGUIEng.DisableButton("/InGame/Singleplayer/ContainerBottom/StartGame", 0)
		XGUIEng.DisableButton("/InGame/Singleplayer/ContainerBottom/Cancel", 0)
		DisplayLoadBottomButtons(
			"/InGame/Singleplayer/ContainerBottom/StartGame",
			"/InGame/Singleplayer/ContainerBottom/Cancel"
		);
		g_MapAndHeroPreview.ShowMapAndHeroWindows(1)

		CustomGame.Maps = {}
	
		XGUIEng.ListBoxPopAll(CustomGame.Widget.MapList)
		XGUIEng.ListBoxPopAll(CustomGame.Widget.ClimateZoneList)
		XGUIEng.ListBoxPopAll(CustomGame.Widget.SizeList)
		XGUIEng.ListBoxPopAll(CustomGame.Widget.ModeList)

		local CampaignMaps = ExternalMapLoader.Local.Data.Campaign.MapNames;
		CustomGame_AddMaps(API.InstanceTable(CampaignMaps), 1)

		for i = 1 , #CustomGame.Maps do 
			local MapEntry = CustomGame.Maps[i]
			local LocalizedClimateZone = XGUIEng.GetStringTableText("UI_ObjectNames/ClimateZone_" .. Framework.GetMapClimateZone(MapEntry.Name, MapEntry.MapType))
			local map,description,size,mode = Framework.GetMapNameAndDescription(MapEntry.Name, MapEntry.MapType)
			XGUIEng.ListBoxPushItem(CustomGame.Widget.ModeList, mode)
			XGUIEng.ListBoxPushItem(CustomGame.Widget.SizeList, Tool_GetLocalizedSizeString(size))
			XGUIEng.ListBoxPushItem(CustomGame.Widget.ClimateZoneList, LocalizedClimateZone)
			XGUIEng.ListBoxPushItem(CustomGame.Widget.MapList,Tool_GetLocalizedMapName(MapEntry.Name, MapEntry.MapType))
		end

		if #ExternalMapLoader.Local.Data.Campaign.MapNames > 0 then
			CustomGame_SelectMap(0);
			CustomGame_FillHeroComboBox();
		else
			CustomGame_SelectMap(-1);
		end
	end

	CustomGame_SelectMap = function(map)
		if map > -1 then
			XGUIEng.ListBoxSetSelectedIndex(CustomGame.Widget.MapList,map);  
			CustomGame.SelectedMap = CustomGame.Maps[map +1].Name;
			CustomGame.SelectedMapType = CustomGame.Maps[map +1].MapType;
			g_MapAndHeroPreview.SelectMap(CustomGame.SelectedMap, CustomGame.SelectedMapType);
			ExternalMapLoader.Local:SelectMap(map +1);
			CustomGame_FillHeroComboBox(true);
		else
			XGUIEng.ShowWidget("/LoadScreen/LoadScreen/ContainerDescription/LoadScreenReadMe", 0);
			XGUIEng.SetMaterialTexture("/EndScreen/EndScreen/BG", 0, "graphics/textures/gui_1200/mainmenu/limitedbg.png");
			XGUIEng.SetMaterialColor("/EndScreen/EndScreen/BG", 0, 255, 255, 255, 255);
		end
	end

	CustomGame_SelectKnight = function(knight)
		CustomGame.Knight = knight;
		g_MapAndHeroPreview.SelectKnight(CustomGame.Knight);
	end

	CustomGame_FillHeroComboBox_Orig_MapLoader = CustomGame_FillHeroComboBox;
	CustomGame_FillHeroComboBox = function(_TryToKeepSelectedKnight)
		ExternalMapLoader.Local:FillHeroComboBox(_TryToKeepSelectedKnight);
	end
end

-- Führt Jobs aus, die jede Sekunde laufen sollen.
function ExternalMapLoader.Local.OnEverySecond()
	ExternalMapLoader.Local:CopyDataToGlobalScript();
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("ExternalMapLoader");

