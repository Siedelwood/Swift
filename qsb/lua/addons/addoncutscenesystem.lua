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
--    DisableSkipping = false, -- Deaktiviere Abbrechen der Cutscene
--    RestoreGameSpeed = true, -- Spielgeschwindigkeit wiederherstellen
--    RestoreCamera = true,    -- Kameraposition wird zurückgesetzt
--
--    ... -- Hier nacheinander die Flights auflisten
--
--    Finished = function(_Data)
--         -- Hier kann eine abschließende Aktion ausgeführt werden.
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
-- <b>Alias</b>: BriefingSystem.StartCutscene
--
-- @param[type=table]   _Cutscene Cutscene table
-- @return[type=number] ID der Cutscene
-- @within Anwenderfunktionen
--
function API.StartCutscene(_Cutscene)
    if GUI then
        fatal("API.StartCutscene: Cannot start cutscene from local script!");
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
StartCutscene = API.StartCutscene;
BriefingSystem.StartCutscene = API.StartCutscene;

---
-- Prüft, ob zur Zeit eine Cutscene aktiv ist.
-- 
-- <b>Alias</b>: IsCutsceneActive
-- 
-- @return[type=boolean] Cutscene aktiv
-- @within Anwenderfunktionen
--
function API.IsCutsceneActive()
    return AddOnCutsceneSystem.Global:IsCutsceneActive();
end
IsCutsceneActive = API.IsCutsceneActive;

---
-- Prüft, ob die Cutscene mit der ID beendet ist.
-- 
-- <b>Alias</b>: IsCutsceneFinished
-- 
-- @return[type=boolean] Cutscene aktiv
-- @within Anwenderfunktionen
--
function API.IsCutsceneFinished(_ID)
    if GUI then
        API.Warn("API.IsCutsceneFinished: Can only be used in the global script!");
        return false;
    end
    return BundleBriefingSystem.Global.Data.PlayedBriefings[_ID] == true;
end
IsCutsceneFinished = API.IsCutsceneFinished;

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
            CutsceneActive = false;
            CinematicActive = false;
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
    if self:IsCutsceneActive() then
        table.insert(self.Data.CutsceneQueue, _Cutscene);
        return;
    end

    BundleBriefingSystem.Global.Data.BriefingID = BundleBriefingSystem.Global.Data.BriefingID +1;
    self.Data.CurrentCutscene = _Cutscene;
    self.Data.DisableSkipping = _NoEscapeMode == true;
    self.Data.CurrentCutscene.ID = BundleBriefingSystem.Global.Data.BriefingID;
    local Cutscene = API.ConvertTableToString(self.Data.CurrentCutscene);
    API.Bridge("AddOnCutsceneSystem.Local:StartCutscene(" ..Cutscene.. ")");
    self.Data.CutsceneActive = true;
    BriefingSystem.isActive = true;

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
    BriefingSystem.isActive = false;

    local CutsceneID = self.Data.CurrentCutscene.ID;
    local LastCutscene = #self.Data.CutsceneQueue == 0;
    if not LastCutscene then
        local Next = table.remove(self.Data.CutsceneQueue, 1);
        self:StartCutscene(Next);
    end
    BundleBriefingSystem.Global.Data.PlayedBriefings[CutsceneID] = true;
    API.Bridge("AddOnCutsceneSystem.Local:StopCutscene(" ..tostring(LastCutscene).. ")");
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

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:Install()
    if not InitializeFader then
        Script.Load("script/mainmenu/fader.lua");
    end
end

---
-- Startet die Cutscene im lokalen Skript. Die Spielansicht wird versteckt
-- und der Cinematic Mode aktiviert.
--
-- @param[type=table] _Cutscene Cutscene table
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:StartCutscene(_Cutscene)
    if not BriefingSystem.isInitialized then
        -- Nur die Referenz erstellen
        BriefingSystem.GlobalSystem = Logic.CreateReferenceToTableInGlobaLuaState("BriefingSystem");
    end
    if not self.Data.CinematicActive then
        self:ActivateCinematicMode();
    end
    self.Data.CurrentFlight = 1;
    self.Data.CurrentCutscene = _Cutscene;
    self.Data.CutsceneActive = true;
end

---
-- Stoppt die Cutscene im lokalen Skript. Hier wird der Cinematic Mode
-- deaktiviert und die Spielansicht wiederhergestellt.
--
-- @param[type=boolean] _LastCutscene Letzte Cutscene in Queue
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:StopCutscene(_LastCutscene)
    if _LastCutscene then
        self:DeactivateCinematicMode();
    end
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
-- Experimental: To be add to the cutscene as starting script event!
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
        local FadeIn  = CurrentFlight.FadeIn;
        local FadeOut = CurrentFlight.FadeOut;

        if Camera.IsValidCutscene(Flight) then
            Camera.StartCutscene(Flight);
            -- Setze Title
            if string.sub(Title, 1, 1) ~= "{" then
                Title = "{@color:255,250,0,255}{center}{darkshadow}" .. Title;
            end
            XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Title", Title);
            -- Setze Text
            if string.sub(Text, 1, 1) ~= "{" then
                Text = "{@color:255,250,255,255}{center}" .. Text;
            end
            XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text", Text);
            -- Führe Action aus
            if Action then
                API.Bridge("self.Data.CurrentCutscene[" ..FlightIndex.. "]:Action()");
            end

            -- Handle fader
            g_Fade.To = 0;
            SetFaderAlpha(0);
            if FadeIn then
                FadeIn(FadeIn);
            end
            if FadeOut then
                StartSimpleHiResJobEx(function(_Time, _FadeOut)
                    if Logic.GetTimeMs() > _Time - (_FadeOut * 1000) then
                        FadeOut(_FadeOut);
                        return true;
                    end
                end, Logic.GetTimeMs() + (_Duration*100), FadeOut);
            end
        end
    end
end
CutsceneFlightStarted = function(_Duration)
    AddOnCutsceneSystem.Local:FlightStarted(_Duration);
end

---
-- Experimental: To be add to the cs-file as finishing script event!
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:FlightFinished()
    if self:IsCutsceneActive() then
        local FlightIndex = self.Data.CurrentFlight;
        local CurrentFlight = self.Data.CurrentCutscene[FlightIndex];
        if not CurrentFlight then
            API.Bridge("AddOnCutsceneSystem.Global:StopCutscene()");
            return true;
        end
        self.Data.CurrentFlight = self.Data.CurrentFlight +1;
        SetFaderAlpha(1);
        self:FlightStarted();
    end
end
CutsceneFlightFinished = function()
    AddOnCutsceneSystem.Local:FlightFinished();
end

---
-- Steuert die Wiedergabe der Cutscenes.
--
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:ThroneRoomCameraControl()
    if self:IsCutsceneActive() then
        if self.Data.CurrentCutscene.Loop then
            self.Data.CurrentCutscene:Loop();
        end
    end
end

---
-- Steuert Reaktionen auf Klicks des Spielers.
--
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
-- Aktiviert den Cinematic Mode. Alle selektierten Entities werden gespeichert
-- und anschließend deselektiert. Optional wird die Kameraposition und die
-- Spielgeschwindigkeit ebenfalls gespeichert.
--
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:ActivateCinematicMode()
    self.Data.CinematicActive = true;

    if Game.GameTimeGetFactor() ~= 0 then
        if self.Data.CurrentCutscene.RestoreGameSpeed and not self.Data.GaneSpeedBackup then
            self.Data.GaneSpeedBackup = Game.GameTimeGetFactor();
        end
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
    end
    if self.Data.CurrentCutscene.RestoreCamera then
        self.Data.CameraPositionBackup = { Camera.RTS_GetLookAtPosition() };
    end
    self.Data.SelectedEntities = { GUI.GetSelectedEntities() };
    
    local LoadScreenVisible = XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 1;
    if LoadScreenVisible then
        XGUIEng.PopPage();
    end

    local Skipping = (self.Data.CurrentCutscene.DisableSkipping and 0) or 1;
    XGUIEng.ShowWidget("/InGame/Root/Normal", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", Skipping);
    XGUIEng.PushPage("/InGame/ThroneRoomBars", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2", false);
    XGUIEng.PushPage("/InGame/ThroneRoom/Main", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_Dodge", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2_Dodge", false);
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
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", 0);
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Title", " ");
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

    GUI.ClearSelection();
    GUI.ForbidContextSensitiveCommandsInSelectionState();
    GUI.ActivateCutSceneState();
    GUI.SetFeedbackSoundOutputState(0);
    GUI.EnableBattleSignals(false);
    Input.CutsceneMode();
    Display.SetRenderFogOfWar(0);

    InitializeFader();
    g_Fade.To = 0;
    SetFaderAlpha(0);

    if LoadScreenVisible then
        XGUIEng.PushPage("/LoadScreen/LoadScreen", false);
    end
end

---
-- Stoppt den Cinematic Mode. Die Selektion wird wiederhergestellt. Falls
-- aktiviert, werden auch Kameraposition und Spielgeschwindigkeit auf ihre
-- alten Werte zurückgesetzt.
--
-- @within Internal
-- @local
--
function AddOnCutsceneSystem.Local:DeactivateCinematicMode()
    self.Data.CinematicActive = false;

    if self.Data.FaderJobID then
        Trigger.UnrequestTrigger(self.Data.FaderJobID);
        self.Data.FaderJobID = nil;
    end

    local x, y = Camera.ThroneRoom_GetPosition();

    g_Fade.To = 0;
    SetFaderAlpha(0);
    XGUIEng.PopPage();
    Display.UseStandardSettings();
    GUI.EnableBattleSignals(true);
    GUI.SetFeedbackSoundOutputState(1);
    GUI.ActivateSelectionState();
    GUI.PermitContextSensitiveCommandsInSelectionState();
    Display.SetRenderFogOfWar(1);

    Camera.RTS_SetLookAtPosition(x, y);
    if self.Data.CurrentCutscene.RestoreCamera then
        Camera.RTS_SetLookAtPosition(unpack(self.Data.CameraPositionBackup));
        self.Data.CameraPositionBackup = nil;
    end

    local GameSpeed = (self.Data.GaneSpeedBackup or 1);
    Game.GameTimeSetFactor(GUI.GetPlayerID(), GameSpeed);
    self.Data.GaneSpeedBackup = nil;

    for k, v in pairs(self.Data.SelectedEntities) do
        GUI.SelectEntity(v);
    end

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
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("AddOnCutsceneSystem");
 
