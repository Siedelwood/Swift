-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnCutsceneSystem                                          # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Modul können Cutscenes abgespielt werden.
-- 
-- <a href="#API.StartCutscene">Cutscene starten</a>
--
-- Cutscenes sind als CS-Datei vordefinierte Kameraflüge. Mit diesem Modul
-- können diese Kameraflüge gruppiert werden. Diese Gruppierung ist das, was
-- die Cutscene ausmacht.
--
-- Pro Flug können Titel und Text eingeblendet werden und eine Lua-Funktion
-- aufgerufen werden.
--
-- Flights können entweder im Internal-Mode des Mapeditors oder über externe
-- Tools erzeugt werden. Sie müssen jedoch immer in das Hauptverzeichnis der
-- Map kopiert werden.
-- <pre>maps/externalmap/.../myCutscene.cs</pre>
-- Gibt Deinen Flights passende Namen, um die Zuordnung zu erleichtern.
-- <pre>cs01_flight1.cs
--cs01_flight2.cs
--...</pre>
--
-- Während der Mapentwicklung können die CS-Dateien nicht in der Map liegen,
-- da sie bei jedem Speichern gelöscht werden. Wenn die Datei nicht vorhanden
-- ist, wird der Flight übersprungen. Sind also keine Flights da, gilt die
-- Cutscene trotzdem als abgespielt, sobald sie beendet ist. Das erleichtert
-- das Testen. Du siehst nur nix.
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnCutsceneSystem = {};

API = API or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Startet eine Cutscene.
--
-- Die einzelnen Flights einer Cutscene werden als CS-Dateien definiert.
--
-- Eine Cutscene besteht aus den einzelnen Flights und speziellen Feldern, mit
-- denen weitere Einstellungen gemacht werden können. Siehe dazu auch das
-- Briefing System für einen Vergleich.
--
-- Das Gerüst für eine Cutscene sieht wie folgt aus:
-- <pre>local Cutscene = {
--    CameraLookAt = {X, Y},   -- Kameraposition am Ende setzen
--    RestoreGameSpeed = true, -- Spielgeschwindigkeit wiederherstellen
--    TransperentBars = false, -- Durchsichtige Bars verwenden
--    HideBorderPins = true,   -- Grenzsteine ausblenden
--    FastForward = false,     -- Beschleunigt abspielen erlauben
--
--    ... -- Hier nacheinander die Flights auflisten
--
--    Starting = function(_Data)
--        -- Hier werden Aktionen vor dem Start ausgeführt.
--    end,
--    Finished = function(_Data)
--        -- Hier kann eine abschließende Aktion ausgeführt werden.
--    end
--};
--return API.StartCutscene(Cutscene);</pre>
--
-- Die einzelnen Flights werden nacheinander als Tables angegeben:
-- <pre>{
--    Flight = "some_file", -- .cs wird nicht mit angegeben!
--    Title  = "Angezeigter Titel",
--    Text   = "Angezeigter Text",
--    Action = function(_Data)
--        -- Aktion für den Flight ausführen
--    end,
--},</pre>
-- Ersetze ... mit den Flights, die zur Cutscene gehören sollen.
--
-- Die Funktion gibt die ID der Cutscene zurück, mit der geprüft werden kann,
-- ob die Cutscene beendet ist.
--
-- <b>Hinweis</b>: Überschreibt die gleichnamige Funktion im Briefing System
-- und gibt ihr neue Funktionalität! Fake Cutscenes müssen jetzt über den
-- folgenden Aufruf gestartet werden:
-- <pre>StartBriefing(MyCutscene, true)</pre>
-- 
-- <b>Alias</b>: StartCutscene
--
-- @param[type=table]   _Cutscene Cutscene table
-- @return[type=number] ID der Cutscene
-- @within Anwenderfunktionen
--
function API.CutsceneStart(_Cutscene)
    if GUI then
        fatal("API.CutsceneStart: Cannot start cutscene from local script!");
        return;
    end

    -- Lokalisierung Texte
    local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    for i= 1, #_Cutscene, 1 do
        if _Cutscene[i].Title and type(_Cutscene[i].Title) == "table" then
            _Cutscene[i].Title = _Cutscene[i].Title[Language];
        end
        if _Cutscene[i].Text and type(_Cutscene[i].Text) == "table" then
            _Cutscene[i].Text = _Cutscene[i].Text[Language];
        end
    end

    return AddOnCutsceneSystem.Global:StartCutscene(_Cutscene);
end
StartCutscene = API.CutsceneStart;

---
-- Prüft, ob zur Zeit eine Cutscene aktiv ist.
-- 
-- <b>Alias</b>: IsCutsceneActive
-- 
-- @return[type=boolean] Cutscene aktiv
-- @within Anwenderfunktionen
-- 
--
function API.CutsceneIsActive()
    if GUI then
        return AddOnCutsceneSystem.Local:IsCutsceneActive();
    end
    return AddOnCutsceneSystem.Global:IsCutsceneActive();
end
IsCutsceneActive = API.CutsceneIsActive;

---
-- Setzt die Geschwindigkeit für den schnellen Vorlauf für alle Cutscenes.
--
-- Beim schnellen Vorlauf wird eine Cutscene beschleunigt abgespielt.
--
-- <b>Alias</b>: SetCutsceneFastForwardSpeed
-- 
-- @param[type=number] _Speed Geschwindigkeit
-- @within Anwenderfunktionen
-- @usage API.CutsceneSetFastForwardSpeed(6);
--
function API.CutsceneSetFastForwardSpeed(_Speed)
    if not GUI then
        API.Bridge("API.CutsceneSetFastForwardSpeed(" .._Speed.. ")");
        return;
    end
    AddOnCutsceneSystem.LoadScreenVisible.Data.FastForward.Speed = _Speed;
end
SetCutsceneFastForwardSpeed = API.CutsceneSetFastForwardSpeed;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnCutsceneSystem = {
    Global = {
        Data = {
            CurrentCutscene = {},
            CutsceneQueue = {},
            CutsceneActive = false,
        },
    },
    Local = {
        Data = {
            CurrentCutscene = {},
            CurrentFlight = 1,
            CutsceneActive = false,
            CinematicActive = false,
            FastForward = {
                Active = false,
                Indent = 1,
                Speed = 15,
            },
            Fader = {
                From = 1.0,
                To = 0.0,
                TimeStamp = 0,
                Duration = 0,
                Callback = nil,
                Widget = "/InGame/Fader/Element",      
                Page = "/InGame/Fader" 
            }
        },
    },

    Text = {
        FastForwardActivate   = {de = "Beschleunigen", en = "Fast Forward"},
        FastForwardDeactivate = {de = "Zurücksetzen",  en = "Normal Speed"},
        FastFormardMessage    = {de = "SCHNELLER VORLAUF",  en = "FAST FORWARD"},
    }
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Global:Install()
end

---
-- Startet die Cutscene im globalen Skript. Es wird eine neue ID für die
-- Cutscene erzeugt und zurückgegeben. Die Cutscehe wird als CurrentCutscene
-- gespeichert und in das lokale Skript kopiert.
--
-- Damit keine Briefings starten, wird die entsprechende Variable im
-- Briefingsystem true gesetzt.
--
-- @param[type=table]   _Cutscene Cutscene table
-- @return[type=number] ID der Cutscene
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Global:StartCutscene(_Cutscene)
    if not self.Data.LoadScreenHidden or self:IsCutsceneActive() then
        table.insert(self.Data.CutsceneQueue, _Cutscene);
        if not self.Data.CutsceneQueueJobID then
            self.Data.CutsceneQueueJobID = StartSimpleHiResJobEx(AddOnCutsceneSystem.Global.CutsceneQueueController);
        end
        return;
    end
    if _Cutscene.Starting then
        _Cutscene:Starting();
    end

    BundleBriefingSystem.Global.Data.BriefingID = BundleBriefingSystem.Global.Data.BriefingID +1;
    self.Data.CurrentCutscene = _Cutscene;
    self.Data.CurrentCutscene.ID = BundleBriefingSystem.Global.Data.BriefingID;
    local Cutscene = API.ConvertTableToString(self.Data.CurrentCutscene);
    API.Bridge("AddOnCutsceneSystem.Local:StartCutscene(" ..Cutscene.. ")");
    self.Data.CutsceneActive = true;
    BundleBriefingSystem.Global.Data.BriefingActive = true;
    BundleBriefingSystem.Global.Data.DisplayIngameCutscene = true;

    return BundleBriefingSystem.Global.Data.BriefingID;
end

---
-- Stoppt die Cutscene im globalen Skript. Falls eine Finished-Funktion für
-- die Cutscene definiert ist, wird diese ausgeführt. Wenn weitere Cutscenes
-- in der Warteschlange stehen, wird die nächste Cutscene gestartet. Die
-- aktuelle Cutscene wird als beendet vermerkt.
--
-- Das Starten von Briefings wird wieder erlaubt.
--
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Global:StopCutscene()
    if self.Data.CurrentCutscene.Finished then
        self.Data.CurrentCutscene:Finished();
    end

    self.Data.CutsceneActive = false;
    BundleBriefingSystem.Global.Data.BriefingActive = false;
    BundleBriefingSystem.Global.Data.DisplayIngameCutscene = false;

    local CutsceneID = self.Data.CurrentCutscene.ID;
    BundleBriefingSystem.Global.Data.FinishedBriefings[CutsceneID] = true;
    API.Bridge("AddOnCutsceneSystem.Local:StopCutscene()");
end

---
-- Prüft, ob eine Cutscene aktiv ist.
-- @param[type=boolean] Cutscene ist aktiv
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Global:IsCutsceneActive()
    return IsBriefingActive() == true or self.Data.CutsceneActive == true;
end

---
-- Steuert die Cutscene-Warteschlange.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Global.CutsceneQueueController()
    if #AddOnCutsceneSystem.Global.Data.CutsceneQueue == 0 then
        AddOnCutsceneSystem.Global.Data.CutsceneQueueJobID = nil;
        return true;
    end
    
    if AddOnCutsceneSystem.Global.Data.LoadScreenHidden and not AddOnCutsceneSystem.Global:IsCutsceneActive() then
        local Next = table.remove(AddOnCutsceneSystem.Global.Data.CutsceneQueue, 1);
        AddOnCutsceneSystem.Global:StartCutscene(Next);
    end
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:Install()
    StartSimpleHiResJobEx(AddOnCutsceneSystem.Local.WaitForLoadScreenHidden);
    StartSimpleHiResJobEx(AddOnCutsceneSystem.Local.DisplayFastForwardMessage);

    self:OverrideUpdateFader();
end

---
-- Startet die Cutscene im lokalen Skript. Die Spielansicht wird versteckt
-- und der Cinematic Mode aktiviert.
-- @param[type=table] _Cutscene Cutscene table
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:StartCutscene(_Cutscene)
    BundleBriefingSystem.Local.Data.DisplayIngameCutscene = true;

    self.Data.CurrentFlight = 1;
    self.Data.CurrentCutscene = _Cutscene;
    self.Data.CutsceneActive = true;
    
    Display.SetRenderSky(1);
    if self.Data.CurrentCutscene.HideBorderPins then
        Display.SetRenderBorderPins(0);
    end
    if Game.GameTimeGetFactor() ~= 0 then
        if self.Data.CurrentCutscene.RestoreGameSpeed and not self.Data.GaneSpeedBackup then
            self.Data.GaneSpeedBackup = Game.GameTimeGetFactor();
        end
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
    end
    self.Data.SelectedEntities = {GUI.GetSelectedEntities()};
    
    if not self.Data.CinematicActive then
        self:ActivateCinematicMode();
    end

    self:NextFlight();
end

---
-- Stoppt die Cutscene im lokalen Skript. Hier wird der Cinematic Mode
-- deaktiviert und die Spielansicht wiederhergestellt.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:StopCutscene()
    if self.Data.CurrentCutscene.CameraLookAt then 
        Camera.RTS_SetLookAtPosition(unpack(self.Data.CurrentCutscene.CameraLookAt));
    end
    for k, v in pairs(self.Data.SelectedEntities) do
        GUI.SelectEntity(v);
    end
    Display.SetRenderBorderPins(1);
    Display.SetRenderSky(0);

    local GameSpeed = (self.Data.GaneSpeedBackup or 1);
    Game.GameTimeSetFactor(GUI.GetPlayerID(), GameSpeed);
    self.Data.GaneSpeedBackup = nil;

    BundleBriefingSystem.Local.Data.DisplayIngameCutscene = false;
    self:DeactivateCinematicMode();
    self.Data.CutsceneActive = false;
end

---
-- Prüft, ob eine Cutscene aktiv ist.
-- @param[type=boolean] Cutscene ist aktiv
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:IsCutsceneActive()
    return IsBriefingActive() == true or self.Data.CutsceneActive == true;
end

---
-- Startet den nächsten Flight.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:NextFlight()
    local FlightIndex = self.Data.CurrentFlight;
    local CurrentFlight = self.Data.CurrentCutscene[FlightIndex];
    if not CurrentFlight then
        return;
    end
    if Camera.IsValidCutscene(CurrentFlight.Flight) then
        Camera.StartCutscene(CurrentFlight.Flight);
    end
end

---
-- Script Event: Flight wurde gestartet.
-- @param[type=number] _Duration Dauer in Turns
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:FlightStarted(_Duration)
    if self:IsCutsceneActive() then
        local FlightIndex = self.Data.CurrentFlight;
        local CurrentFlight = self.Data.CurrentCutscene[FlightIndex];
        if not CurrentFlight then
            return;
        end

        local Flight  = CurrentFlight.Flight;
        local Title   = CurrentFlight.Title or "";
        local Text    = CurrentFlight.Text or "";
        local Action  = CurrentFlight.Action;

        -- Setze Title
        if string.sub(Title, 1, 1) ~= "{" then
            Title = "{@color:255,250,0,255}{center}{darkshadow}" .. Title;
        end
        XGUIEng.SetText("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", Title);
        -- Setze Text
        if string.sub(Text, 1, 1) ~= "{" then
            Text = "{@color:255,250,255,255}{center}" .. Text;
        end
        XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text", "{cr}{cr}{cr}" .. Text);
        -- Führe Action aus
        if Action then
            API.Bridge("AddOnCutsceneSystem.Global.Data.CurrentCutscene[" ..FlightIndex.. "]:Action()");
        end

        XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", (self.Data.CurrentCutscene.FastForward and 1) or 0);

        -- Handle fader
        self.Data.Fader.To = 0;
        self:SetFaderAlpha(0);
        if CurrentFlight.FadeIn then
            self:FadeIn(CurrentFlight.FadeIn);
        end
        if CurrentFlight.FadeOut then
            StartSimpleHiResJobEx(function(_Time, _FadeOut)
                if Logic.GetTimeMs() > _Time - (_FadeOut * 1000) then
                    self:FadeOut(_FadeOut);
                    return true;
                end
            end, Logic.GetTimeMs() + (_Duration*100), CurrentFlight.FadeOut);
        end
    end
end
CutsceneFlightStarted = function(_Duration)
    AddOnCutsceneSystem.Local:FlightStarted(_Duration);
end

---
-- Script Event: Flight ist beendet.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:FlightFinished()
    if self:IsCutsceneActive() then
        local FlightIndex = self.Data.CurrentFlight;
        if FlightIndex == #self.Data.CurrentCutscene then
            API.Bridge("AddOnCutsceneSystem.Global:StopCutscene()");
            return true;
        end
        self.Data.CurrentFlight = self.Data.CurrentFlight +1;
        self:SetFaderAlpha(1);
        self:NextFlight();
    end
end
CutsceneFlightFinished = function()
    AddOnCutsceneSystem.Local:FlightFinished();
end

---
-- Steuert die Wiedergabe der Cutscenes.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:ThroneRoomCameraControl()
    if self:IsCutsceneActive() then
        local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        if self.Data.FastForward.Active == false then
            XGUIEng.SetText("/InGame/ThroneRoom/Main/Skip", "{center}" ..AddOnCutsceneSystem.Text.FastForwardActivate[Language]);
        else 
            XGUIEng.SetText("/InGame/ThroneRoom/Main/Skip", "{center}" ..AddOnCutsceneSystem.Text.FastForwardDeactivate[Language]);
        end
    end
end

---
-- Steuert Reaktionen auf Klicks des Spielers.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:ThroneRoomLeftClick()
    if self:IsCutsceneActive() then
        if self.Data.CurrentCutscene.LeftClick then
            self.Data.CurrentCutscene:LeftClick();
        end
    end
end

---
-- Startet oder beendet den schnellen Vorlauf, wenn der Spieler den Skip-Button
-- klickt. Außerdem wird der Text des Skip-Button gesetzt und ein Flag gesetzt.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:NextButtonPressed()
    if self:IsCutsceneActive() then
        if Game.GameTimeGetFactor() > 1 then
            Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
            self.Data.FastForward.Active = false;
        else
            Game.GameTimeSetFactor(GUI.GetPlayerID(), self.Data.FastForward.Speed);
            self.Data.FastForward.Active = true;
        end
    end
end

---
-- Initialisiert den Fader. Bei diesem Fader handelt es sich um eine leicht
-- abgewandelte Version des normalen Fader. Dieser Fader verhält sich relativ
-- zur Spielgeschwindigkeit.
-- @return[type=boolean] Fading läuft gerade
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:InitializeFader()
    self.Data.Fader.Duration = 0;
    self.Data.Fader.To = 0;
    self:SetFaderAlpha(1.0);
    XGUIEng.PushPage(self.Data.Fader.Page, false);
end

---
-- Prüft, ob gerade ein Fading-Prozess läuft.
-- @return[type=boolean] Fading läuft gerade
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:IsFading()
	return self.Data.Fader.Duration ~= 0;
end

---
-- Blendet zur Fader-Maske aus. Callback wird am Ende ausgeführt.
-- @param[type=number] _Duration Dauer in Sekunden
-- @param[type=number] _Callback (optional) Callback-Funktion
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:FadeOut(_Duration, _Callback)
	if self:IsFading() then
        local time = Logic.GetTimeMs();
        local progress = (time - self.Data.Fader.TimeStamp) / (self.Data.Fader.Duration * 1000);
        local alpha = self:LERP(self.Data.Fader.From, self.Data.Fader.To, progress);
		self.Data.Fader.From = alpha;
		self.Data.Fader.To = 1;
		self.Data.Fader.Duration = _Duration * (self.Data.Fader.To - self.Data.Fader.From);
		
	else
        self.Data.Fader.From = 0;
        self.Data.Fader.To = 1;
        self.Data.Fader.Duration = _Duration;
	end
    self.Data.Fader.Callback = _Callback;
    self.Data.Fader.TimeStamp = Logic.GetTimeMs();
end

---
-- Blendet von der Fader-Maske ein. Callback wird am Ende ausgeführt.
-- @param[type=number] _Duration Dauer in Sekunden
-- @param[type=number] _Callback (optional) Callback-Funktion
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:FadeIn(_Duration, _Callback)
	if self:IsFading() then
		return;
	end
    self.Data.Fader.Callback = _Callback;
    self.Data.Fader.Duration = _Duration;
    self.Data.Fader.From = 1;
    self.Data.Fader.To = 0;
    self.Data.Fader.TimeStamp = Logic.GetTimeMs();
end

---
-- Setzt den Alpha-Wert der Fader-Maske auf den angegebenen Wert.
-- @param[type=number] _Alpha Alpha-Wert
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:SetFaderAlpha(_Alpha)
	if XGUIEng.IsWidgetExisting(self.Data.Fader.Widget) == 0 then
		return;
	end
	XGUIEng.SetMaterialColor(self.Data.Fader.Widget,0,0,0,0,255 * _Alpha);
	XGUIEng.SetMaterialColor(self.Data.Fader.Widget,1,0,0,0,255 * _Alpha);
end

---
-- Berechnet die lineare Interpolation des Alpha der Fader-Maske.
-- @param[type=number] _A Startwert
-- @param[type=number] _B Endwert
-- @param[type=number] _T Zeitfaktor
-- @return[number] Interpolationsfaktor
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:LERP(_A, _B, _T)
    return _A + ((_B - _A) * _T);
end

---
-- Überschreibt die Update-Funktion des normalen Fader, sodass während einer
-- Cutscene Spielzeit statt Realzeit verwendet wird.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:OverrideUpdateFader()
    UpdateFader_Orig_CutsceneSystem = UpdateFader;
    UpdateFader = function()
        if AddOnCutsceneSystem.Local.Data.CutsceneActive then
            AddOnCutsceneSystem.Local:UpdateFader();
        else
            UpdateFader_Orig_CutsceneSystem();
        end
    end
end

---
-- Aktualisiert den Alpha-Wert der Fader-Maske, wenn eine Cutscene aktiv ist.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:UpdateFader()
    if self.Data.CutsceneActive == true then
        if self.Data.Fader.Duration > 0 then
            local time = Logic.GetTimeMs();
            local progress = (time - self.Data.Fader.TimeStamp) / (self.Data.Fader.Duration * 1000);
            local alpha = self:LERP(self.Data.Fader.From, self.Data.Fader.To, progress);
            self:SetFaderAlpha(alpha);
            if time > self.Data.Fader.TimeStamp + (self.Data.Fader.Duration * 1000)  then
                self.Data.Fader.Duration = 0;
                if self.Data.Fader.Callback ~= nil then
                    self.Data.Fader:Callback();
                    return false;
                end
            end
        else
            self:SetFaderAlpha(self.Data.Fader.To);
        end
    end
end

---
-- Setzt den Bar-Style für die aktuelle Cutscene.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:SetBarStyle(_Transparend)
    local Alpha = (_Transparend and 100) or 255;

    XGUIEng.ShowWidget("/InGame/ThroneRoomBars", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", 1);

    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarBottom", 1, Alpha);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarTop", 1, Alpha);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarBottom", 1, Alpha);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarTop", 1, Alpha);
end

---
-- Aktiviert den Cinematic Mode. Alle selektierten Entities werden gespeichert
-- und anschließend deselektiert. Optional wird die Kameraposition und die
-- Spielgeschwindigkeit ebenfalls gespeichert.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:ActivateCinematicMode()
    self.Data.CinematicActive = true;
    
    local LoadScreenVisible = XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 1;
    if LoadScreenVisible then
        XGUIEng.PopPage();
    end

    XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom", 1);
    XGUIEng.PushPage("/InGame/ThroneRoomBars", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2", false);
    XGUIEng.PushPage("/InGame/ThroneRoom/Main", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_Dodge", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2_Dodge", false);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/Frame", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/DialogBG", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/FrameEdges", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogBottomRight3pcs", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/KnightInfoButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Briefing", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/BackButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/TitleContainer", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/StartButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Text", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Title", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", 1);

    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Title", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", " ");

    local x,y = XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight");
    XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", x, 65);

    XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/Objectives", 2, 0, 2000, 20);
    XGUIEng.PushPage("/InGame/ThroneRoom/KnightInfo", false);
    XGUIEng.ShowAllSubWidgets("/InGame/ThroneRoom/KnightInfo", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/Text", 1);
    XGUIEng.SetText("/InGame/ThroneRoom/KnightInfo/Text", " ");
    XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/Text", 200, 300, 1000, 10);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/LeftFrame", 1);
    XGUIEng.ShowAllSubWidgets("/InGame/ThroneRoom/KnightInfo/LeftFrame", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/KnightBG", 1);
    XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/KnightBG", 0, 6000, 400, 600);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoom/KnightInfo/KnightBG", 0, 0);

    AddOnCutsceneSystem.Local:SetBarStyle(self.Data.CurrentCutscene.TransperentBars);

    if not self.Data.SkipButtonTextBackup then
        self.Data.SkipButtonTextBackup = XGUIEng.GetText("/InGame/ThroneRoom/Main/Skip");
    end

    GUI.ClearSelection();
    GUI.ForbidContextSensitiveCommandsInSelectionState();
    GUI.ActivateCutSceneState();
    GUI.SetFeedbackSoundOutputState(0);
    GUI.EnableBattleSignals(false);
    Input.CutsceneMode();
    Display.SetRenderFogOfWar(0);
    Camera.SwitchCameraBehaviour(0);

    self:InitializeFader();
    self:SetFaderAlpha(0);

    if LoadScreenVisible then
        XGUIEng.PushPage("/LoadScreen/LoadScreen", false);
    end
end

---
-- Stoppt den Cinematic Mode. Die Selektion wird wiederhergestellt. Falls
-- aktiviert, werden auch Kameraposition und Spielgeschwindigkeit auf ihre
-- alten Werte zurückgesetzt.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:DeactivateCinematicMode()
    self.Data.CinematicActive = false;

    if not self.Data.SkipButtonTextBackup then
        XGUIEng.SetText("/InGame/ThroneRoom/Main/Skip", self.Data.SkipButtonTextBackup);
        self.Data.SkipButtonTextBackup =  nil;
    end

    self:SetFaderAlpha(0);
    XGUIEng.PopPage();
    Camera.SwitchCameraBehaviour(0);
    Display.UseStandardSettings();
    Input.GameMode();
    GUI.EnableBattleSignals(true);
    GUI.SetFeedbackSoundOutputState(1);
    GUI.ActivateSelectionState();
    GUI.PermitContextSensitiveCommandsInSelectionState();
    Display.SetRenderFogOfWar(1);

    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.ShowWidget("/InGame/ThroneRoom", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal", 1);
    XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", 1);
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", " ");
end

---
-- Steuert die Nachricht bei aktiven schnellen Vorlauf von Cutscenes.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local.DisplayFastForwardMessage()
    if AddOnCutsceneSystem.Local.Data.CutsceneActive == true then
        if AddOnCutsceneSystem.Local.Data.FastForward.Active then
            -- Realzeit ermitteln
            local RealTime = API.RealTimeGetSecondsPassedSinceGameStart();
            if not AddOnCutsceneSystem.Local.Data.FastForward.RealTime then
                AddOnCutsceneSystem.Local.Data.FastForward.RealTime = RealTime;
            end
            -- Einrückung anpassen
            if AddOnCutsceneSystem.Local.Data.FastForward.RealTime < RealTime then
                AddOnCutsceneSystem.Local.Data.FastForward.Indent = AddOnCutsceneSystem.Local.Data.FastForward.Indent +1;
                if AddOnCutsceneSystem.Local.Data.FastForward.Indent > 4 then
                    AddOnCutsceneSystem.Local.Data.FastForward.Indent = 1;
                end
                AddOnCutsceneSystem.Local.Data.FastForward.RealTime = RealTime;
            end
            -- Message anzeigen
            local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
            local Text = "{cr}{cr}" ..AddOnCutsceneSystem.Text.FastFormardMessage[Language];
            local Indent = string.rep("  ", AddOnCutsceneSystem.Local.Data.FastForward.Indent);
            XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", Text..Indent.. ". . .");
        else
            XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", " ");
        end
    end
end

---
-- Wartet bis der Ladebildschirm inaktiv ist und setzt dann ein Flag, dass
-- das Starten von Cutscenes erlaubt.
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local.WaitForLoadScreenHidden()
    if XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 0 then
        GUI.SendScriptCommand("AddOnCutsceneSystem.Global.Data.LoadScreenHidden = true;");
        return true;
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("AddOnCutsceneSystem");
 
