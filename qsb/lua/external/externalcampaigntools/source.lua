--------------------------------------------------------------------------------------------
-- Campaign Tool
-- Autor: totalwarANGEL
-- Version 3.4
--------------------------------------------------------------------------------------------

---
-- <p>Mit diesem Bundle können eigene Kampagnen erstellt werden.</p>
--
-- <p>Es können bis zu 16 Maps einer Kampagne hinzugefügt werden. Die Weltkarte
-- der Kampagne und die Position der Map-Buttons können frei bestimmt werden.
-- Eine Kampagne schreibt ins Profil um die bereits gespielten Karten zu
-- vermerken.</p>
--
-- <p>Die Campaign Tools arbeiten hauptsächlich im lokalen Skript!</p>
--
-- @set sort=false
--
ExternalCampaignTools = {
	Global = {
        Data = {},
    },
    Local = {
        Data = {
            Mapfile	= "",
        	Dialog	= "/InGame/Singleplayer/Campaign",
        	Name	= "c",
        	Maps	= {},
        	Current = 1,
        },
    },
}

-- Muss da sein, sonst kracht's!
CampaignData = CampaignData or {}
CampaignData["c00"] = {
    NumberOfMaps = 16,
    MapNumbersWithVideos = { 1, 4, 8, 12, 16 },
    BackgroundBaseName = "Campaign/S6_Campaign_Act",
    BackgroundChangeAtMaps = { 4, 8, 12 }
}

---
-- <p>Erzeugt eine neue Instanz einer Kampagne.</p>
-- <p>Eine Kampagne braucht einen internen Namen, der für die Datenspeicherung
-- im Profil herangezogen wird. Der Name wird zur Sektion in der INI. Die
-- Karte wird im Hintergrund angezeigt. Ein Austausch der Karte wie in der
-- Kampagne, ist nicht vorgesehen.</p>
-- @param _name    [string] Interner Name der Kampagne
-- @param _mapfile [string] Pfad zur Kampagnenkarte
-- @within ExternalCampaignTools.Local
--
function ExternalCampaignTools.Local:New(_name,_mapfile)
	local campaign = {}
	for k,v in pairs(self) do
		if type(v) == "table" then
			campaign[k] = {}
			for s,t in pairs(v) do
				campaign[k][s] = t;
			end
		else
			campaign[k] = v;
		end
	end

	local mapname = Framework.GetCurrentMapName()
    -- TODO Wird das noch gebraucht?
	campaign.Data.Path = "maps/externalmaps/"..mapname.."/"
	campaign.Data.Mapfile = _mapfile;
	campaign.Data.Name = _name;
	return campaign;
end

---
-- <p>Fügt eine Kampagnenkarte der Kampagne hinzu.</p>
-- <p>Der Mapname wird benutzt um den Gewinn-Code im Profil zu speichern. Die
-- Position des Map-Button wird über die XY-Koordinaten angegeben. Über den
-- Index des Loadscreens kann ein eigener Loadscreen genutzt werden.</p>
-- @param _mapname    [string] Interner Name der Map
-- @param _posX       [number] X-Position des Map-Button
-- @param _posY       [number] Y-Position des Map-Button
-- @param _wonstring  [string] Gewinn Code der Map
-- @param _loadscreen [number] Index des Loadscreen
-- @within ExternalCampaignTools.Local
--
function ExternalCampaignTools.Local:Add(_mapname,_posX,_posY,_wonstring,_loadscreen)
	local mapcount = #self.Data.Maps;
	self.Data.Maps[mapcount+1] = {"Map"..(mapcount+1),_mapname,_posX,_posY,_wonstring,_loadscreen};
end

---
-- Prüft, ob eine Map bereits gewonnen wurde.
-- @param _map [number] Index der Map
-- @return [boolean] Map wurde bereits gewonnen
-- @within ExternalCampaignTools.Local
--
function ExternalCampaignTools.Local:IsWon(_map)
	assert(type(map) == "number");
	local profile   = self.Data.Maps[_map][1];
	local wonstring = self.Data.Maps[_map][5];
	return Profile.GetString(self.Data.Name,profile.."_Won") == wonstring;
end

---
-- Setzt den Gewonnen-Status einer Map im Profil.
-- @param _map [number] Index der Map
-- @within ExternalCampaignTools.Local
--
function ExternalCampaignTools.Local:SetWon(_map)
    assert(type(map) == "number");
	local profile   = self.Data.Maps[_map][1];
	local wonstring = self.Data.Maps[_map][5];
	Profile.SetString(self.Data.Name,profile.."_Won", wonstring);
end

---
-- Entfernt den Gewonnen-Status einer Map aus dem Profil.
-- @param _map [number] Index der Map
-- @within ExternalCampaignTools.Local
--
function ExternalCampaignTools.Local:DeleteWon(_map)
    assert(type(_map) == "number");
	local profile   = self.Data.Maps[_map][1];
	local wonstring = self.Data.Maps[_map][5];
	Profile.SetString(self.Data.Name,profile.."_Won", "false");
end

---
-- <p>Öffnet die Kampagnenkarte.</p>
-- <p>Dabei werden die spielinternen Funktionen der Kampagne des Hauptspiels
-- überschrieben, sodass stattdessen die Inhalte der User Campagne angezeigt
-- werden.</p>
-- @within ExternalCampaignTools.Local
-- @local
--
function ExternalCampaignTools.Local:Map()
	-- Map auf der Karte wurde angeklickt
    CampaignMap_OnClicked_Orig_CampaignTools = CampaignMap_OnClicked
	CampaignMap_OnClicked = function(map)
		CampaignMap_OnClicked_Orig_CampaignTools(map);
		for i=1,16 do
			XGUIEng.ShowWidget(self.Data.Dialog.."/Maps_c00/"..i.."/BGCurr",0);
		end
		XGUIEng.ShowWidget(self.Data.Dialog.."/Maps_c00/"..(map+1).."/BGCurr",1);
		self.Data.MissionWasClickedAtLeastOnce = true;
	end

    -- Kampagnenkarte wird zum Haptmenü hin verlassen
	function CampaignDialog_BackOnLeftClick()
		Framework.CloseGame();
	end

    -- Aktualisiert die Kampagnenkarte
	function CampaignMap_Update()
		XGUIEng.ShowWidget(self.Data.Dialog.."/Maps_c00",1);
        XGUIEng.ShowWidget(self.Data.Dialog.."/Maps_c01",0);
		for i=1,16 do
			XGUIEng.ShowWidget(self.Data.Dialog.."/Maps_c00/"..i.."/BG",1);
			XGUIEng.ShowWidget(self.Data.Dialog.."/Maps_c00/"..i.."map",1);
			if i > 1 then
				if self.Data.Maps[i] ~= nil and self:IsWon(i-1) then
					XGUIEng.ShowWidget(self.Data.Dialog.."/Maps_c00/"..i,1);
				else
					XGUIEng.ShowWidget(self.Dialog.."/Maps_c00/"..i,0);
				end
			else
				XGUIEng.ShowWidget(self.Data.Dialog.."/Maps_c00/"..i,1);
			end
			if self.Data.Maps[i] ~= nil then
				XGUIEng.SetWidgetLocalPosition(self.Data.Dialog.."/Maps_c00/"..i,self.Data.Maps[i][3],self.Data.Maps[i][4]);
			end
		end
	end

    -- Startet die ausgewählte Kampagnenkarte
	function CampaignMap_StartMission(map)
		if self.Data.MissionWasClickedAtLeastOnce then
			self.Data.Current = map +1;
			InitializeFader();
			FadeOut(1,CampaignMap_FadeInCallback);
		else
			local lang = Network.GetDesiredLanguage();
			if lang ~= "de" then lang = "en" end;
			local title = (lang == "de" and "Map auswählen") or "Select Mission";
			local message = (lang == "de" and "Ihr habt noch keine Map ausgewählt.") or "You've missed to choose a mission.";

			XGUIEng.ShowWidget("/InGame/Dialog",1);
			XGUIEng.ShowAllSubWidgets("/InGame/Dialog",1);
			XGUIEng.ShowWidget("/InGame/Dialog/Yes",0);
			XGUIEng.ShowWidget("/InGame/Dialog/No",0);
			XGUIEng.SetText("/InGame/Dialog/Message","{center}"..Umessage);
			XGUIEng.SetText("/InGame/Dialog/BG/TitleBig/Info/Name","{center}"..title);
			XGUIEng.SetText("/InGame/Dialog/BG/TitleBig/Info/NameWhite","{center}"..title);
			XGUIEng.PushPage("/InGame/Dialog",false);
			XGUIEng.SetActionFunction("/InGame/Dialog/Ok","XGUIEng.ShowWidget('/InGame/Dialog',0)");
		end
	end

    -- Fadein Callback nach Mapauswahl
	function CampaignMap_FadeInCallback()
		XGUIEng.ShowAllSubWidgets("/InGame",0);
		local map = self.Data.Maps[self.Data.Current][2];
		local loadscreen = self.Data.Maps[self.Data.Current][6];
		local name, desc, size, mode = Framework.GetMapNameAndDescription(map,1);
		assert(name ~= nil and name ~= "","Invalid Mapfile!");
		Framework.SetLoadScreenNeedButton(1);
		InitLoadScreen(false,1,map,0,(loadscreen ~= nil and loadscreen) or 0);
		Framework.ResetProgressBar();
		Framework.StartMap(map,1,(loadscreen ~= nil and loadscreen) or 0);
	end

    -- Steuert den Tooltip einer Map
	function CampaignMap_OnMouseOver()
		XGUIEng.SetWidgetSize("/InGame/Singleplayer/Campaign/Tooltip", 400, 40);
		XGUIEng.SetWidgetSize("/InGame/Singleplayer/Campaign/Tooltip/BG", 400, 40);
		XGUIEng.SetWidgetSize("/InGame/Singleplayer/Campaign/Tooltip/Text", 400, 40);

		local CurrentWidget		= XGUIEng.GetCurrentWidgetID();
		local x,y 				= XGUIEng.GetWidgetScreenPosition(CurrentWidget);
		local sizex,sizey		= XGUIEng.GetWidgetScreenSize(CurrentWidget);
		local tooltipx,tooltipy = XGUIEng.GetWidgetScreenSize("/InGame/Singleplayer/Campaign/Tooltip");

		local mapcount = 1;
		for i=1,16 do
			if CurrentWidget == XGUIEng.GetWidgetID("/InGame/Singleplayer/Campaign/Maps_c00/"..i.."/map") then
				mapcount = i;
			end
		end
		local mapname = self.Data.Maps[mapcount][2];
		local name, desc, size, mode = Framework.GetMapNameAndDescription(mapname,1);
		local s,e = string.find(name, self.Data.Name.." - ");
		if e then
			name = string.sub(name,e+1);
		end

		XGUIEng.ShowWidget("/InGame/Singleplayer/Campaign/Tooltip",1);
		XGUIEng.SetWidgetScreenPosition("/InGame/Singleplayer/Campaign/Tooltip",x+sizex/2 - tooltipx/2,y- tooltipy );
		XGUIEng.SetText("/InGame/Singleplayer/Campaign/Tooltip/Text", "{center}"..tostring(name));
	end

    -- Setzt die Kampaknenkarte (im Hintergrung)
	function CampaignMap_ShowBGMap(_highestmap)
		XGUIEng.SetMaterialTexture("/InGame/Singleplayer/Campaign/BG",0,self.Data.Mapfile);
	end

	for i=1,16 do
		XGUIEng.ShowWidget(self.Data.Dialog.."/Maps_c00/"..i,0)
	end
	for i=1,16 do
		XGUIEng.HighLightButton(self.Data.Dialog.."/Maps_c00/v"..i.."/v", 0 )
	end

	XGUIEng.ShowWidget("/InGame/Root/3dWorldView",0);
	Game.GameTimeSetFactor(GUI.GetPlayerID(),0);
	Framework.SetCampaignName("c00");
	OpenCampaignMap();

	self.Data.MissionWasClickedAtLeastOnce = false;
	CampaignMap_OnClicked(0);
end