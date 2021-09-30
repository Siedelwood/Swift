--[[
Swift_3_BriefingSystem/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- 
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_DisplayCore.api.html">(1) Display Core</a></li>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- <li><a href="Swift_2_QuestCore.api.html">(2) Quests Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Startet ein Briefing.
--
-- Für ein Briefing können verschiedene spezielle Einstellungen vorgenommen
-- werden. Jede dieser Einstellungen wird mit true aktiviert.
-- <table border="1">
-- <tr>
-- <td><b>Einstellung</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>HideBorderPins</td>
-- <td>Die Grenzsteine werden während des Briefing ausgeblendet</td>
-- </tr>
-- <tr>
-- <td>BarOpacity</td>
-- <td>Bestimmt die Opacity der Bars [0.0 - 1.0]</td>
-- </tr>
-- <tr>
-- <td>BigBars</td>
-- <td>Breite Bars in Briefings verwenden (Default true)</td>
-- </tr>
-- <tr>
-- <td>ShowSky</td>
-- <td>Der Himmel wird während des Briefing angezeigt</td>
-- </tr>
-- <tr>
-- <td>RestoreGameSpeed</td>
-- <td>Die Spielgeschwindigkeit wird nach Ende des Briefing zurückgesetzt</td>
-- </tr>
-- <tr>
-- <td>RestoreCamera</td>
-- <td>Die Kameraposition vor dem Briefing wird wiederhergestellt</td>
-- </tr>
-- <tr>
-- <td>SkippingAllowed</td>
-- <td>Das manuelle Springen zwischen Seiten wird erlaubt.</td>
-- </tr>
-- <tr>
-- <td>ReturnForbidden</td>
-- <td>Das Zurückspringen zur Vorherigen Seite wird deaktiviert. Wenn nicht
-- angegeben, dann standardmäßig deaktiviert.</td>
-- </tr>
-- </table>
--
-- <br><h5>Animationen entkoppeln</h5>
-- Es ist außerdem möglich, die Kameraanimation von den einzelnen Seiten des
-- Briefings zu entkoppeln. Das hat den Charme, dass Spielfiguren erzählen
-- und erzählen und die Kamera über die ganze Zeit die gleiche Animation
-- zeigt, was das Lesen angenehmer macht.
--
-- Animationen werden über die Animations-Table gesteuert. Diese wird direkt
-- an die Briefing Table angehangen. Die Animation wird die Kamera dann von
-- Position 1 zu Position 2 bewegen.
-- <p>Beispiel:</p>
-- <pre>
-- Briefing.PageAnimations = {
--    ["Page1"] = {
--        -- Position1, Rotation1, Zoom1, Angle1, Position2, Rotation2, Zoom2, Angle2, Animationsdauer
--        {"pos4", -60, 2000, 35, "pos4", -30, 2000, 25, 30}
--    },
--    ["Page3"] = {
--        PurgeOld = true,
--        {"pos2", -45, 6000, 35, "pos2", -45, 3000, 35, 30},
--    }
--};</pre>
-- Hier wird eine Animation für die Seite "Page1" definiert. Sobald die Seite
-- abgespielt wird startet die Animation. Wird Seite "Page3" erreicht, werden
-- alle laufenden Animationen abgebrochen (PurgeOld = true) und die neue
-- Animation hinzugefügt. Es können mehrere Animationen definiert werden,
-- welche nacheinander abgespielt werden.
--
-- Anstelle von Angle, Rotation und Zoom kann auch eine zweite Position
-- angegeben werden. Die Kamera befindet sich dann an der Position von
-- Position und schaut zur Position von LookAt. Es können Skriptnamen mit
-- Z-Offset oder XYZ-Koordinaten verwendet werden.
-- <p>Beispiel:</p>
--<pre>
-- Briefing.PageAnimations = {
--    ["Page1"] = {
--        -- Position1, LookAt1, Position2, Lookat2, Animationsdauer
--        {"pos1", "look1", "pos4", "look4", 30}
--    },
--};</pre>
--
-- Über Richtungsvektoren können besondere Kameraeffekte erzielt werden.
-- Wenn sich das LookAt-Entity bewegt und das Position still steht, wird
-- die LookAt-Entity von der fest stationierten Kamera verfolgt. Wenn die
-- Position z.B. ein sich bewegende Kutsche ist, und LookAt ein statisches
-- Entity, wie z.B. ein Gebäude, wird der Effekt erzielt, dass jemand aus
-- der Kutsche auf das Gebäude schaut.
--
-- Definiert man Animationen auf diese Weise, so muss man es für das <u>
-- gesamte Briefing</u> durchziehen. Angaben von Angle, Zoom und Co an
-- einzelnen Pages werden ignoriert.
--
-- <b>Alias</b>: StartBriefing
--
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=number] ID des Briefing
-- @within Anwenderfunktionen
--
function API.StartBriefing(_Briefing)
    if GUI then
        return -1;
    end
    if type(_Briefing) ~= "table" then
        error("_Briefing must be a table!");
        return -1;
    end
    if #_Briefing == 0 then
        error("API.StartBriefing: _Briefing does not contain pages!");
        return -1;
    end
    return ModuleBriefingSystem.Global:StartBriefing(_Briefing);
end
StartBriefing = API.StartBriefing;

---
-- Startet das Briefing als Mission Start Briefing.
--
-- Diese Funktion setzt das mit ihr aufgerufene Briefing als das Mission Start
-- Briefing. Mit dem entsprechenden Trigger kann auf das Ende des Briefings
-- gewartet werden.
--
-- <b>Alias</b>: StartMissionBriefing
--
-- @param[type=function] _Function Funktion mit Briefing
-- @within Anwenderfunktionen
-- @see Trigger_MissionBriefing
--
function API.StartMissionBriefing(_Function)
    if GUI then
        return;
    end
    if type(_Function) ~= "function" then
        error("API.StartMissionBriefing: _Function must be a function!");
        return;
    end
    local ID = _Function();
    if type(ID) ~= "number" then
        error("API.StartMissionBriefing: _Function did not return an ID!");
        return;
    end
    ModuleBriefingSystem.Global.Data.MissionStartBriefingID = ID;
end
StartMissionBriefing = API.StartMissionBriefing;

---
-- Prüft, ob ein Briefing einmal gestartet wurde und bis zum Ende kam.
--
-- <b>Alias</b>: IsBriefingFinished
--
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=boolean] Briefing ist beendet
-- @within Anwenderfunktionen
--
function API.IsBriefingFinished(_BriefingID)
    if GUI then
        return false;
    end
    return ModuleBriefingSystem.Global.Data.FinishedBriefings[_BriefingID] == true;
end
IsBriefingFinished = API.IsBriefingFinished;

---
-- Prüft, ob aktuell ein Briefing aktiv ist.
--
-- <b>Alias</b>: IsBriefingActive
--
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=boolean] Briefing ist beendet
-- @within Anwenderfunktionen
--
function API.IsBriefingActive(_BriefingID)
    if GUI then
        return ModuleBriefingSystem.Local.Data.BriefingActive == true;
    end
    return ModuleBriefingSystem.Global.Data.BriefingActive == true;
end
IsBriefingActive = API.IsBriefingActive;

---
-- Ändert die Sichtbarkeit einer Antwort im aktuellen Briefing.
--
-- <b>Hinweis</b>: Außerhalb von Briefings hat die Funktion keinen Effekt!
--
-- <b>Alias</b>: SetAnswerVisibility
--
-- @param[type=number] _Page ID der Page
-- @param[type=number] _Answer ID der Antwort
-- @param[type=boolean] _Visible Sichtbarkeit
-- @within Internal
-- @local
--
function API.SetAnswerAvailability(_Page, _Answer, _Visible)
    if not GUI then
        -- PageID kann nur im globalen Skript bestimmt werden
        local PageID = ModuleBriefingSystem.Global:GetPageIDByName(_Page);
        if PageID < 1 then
            error("Page '" ..tostring(_Page).. "' does not exist!");
            return;
        end
        Logic.ExecuteInLuaLocalState(string.format("API.SetAnswerAvailability(%d, %d, %s)", PageID, _Answer, tostring(not _Visible)));
        return;
    end
    ModuleBriefingSystem.Local:SetMCAnswerState(_Page, _Answer, _Visible);
 end
 SetAnswerVisibility = API.SetAnswerAvailability;

---
-- Erzeugt die Funktionen zur Erstellung von Seiten in einem Briefing und bindet
-- sie an das Briefing. Diese Funktion muss vor dem Start eines Briefing
-- aufgerufen werden um Seiten hinzuzufügen.
-- <ul>
-- <li><a href="#AP">AP</a></li>
-- </ul>
--
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=function] <a href="#AP">AP</a>
-- @within Anwenderfunktionen
--
-- @usage local AP = API.AddBriefingPages(Briefing);
--
function API.AddBriefingPages(_Briefing)
    if GUI then
        return;
    end
    _Briefing.GetPage = function(self, _NameOrID)
        local ID = ModuleBriefingSystem.Global:GetPageIDByName(_NameOrID);
        return ModuleBriefingSystem.Global.Data.CurrentBriefing[ID];
    end

    local AP = function(_Page)
        _Briefing.Length = (_Briefing.Length or 0) +1;
        if type(_Page) == "table" then
            _Page.__Legit = true;
            -- Sprache anpassen
            _Page.Title = API.ConvertPlaceholders(API.Localize(_Page.Title));
            _Page.Text = API.ConvertPlaceholders(API.Localize(_Page.Text));
            -- Lookat mappen
            if type(_Page.LookAt) == "string" or type(_Page.LookAt) == "number" then
                _Page.LookAt = {_Page.LookAt, 0}
            end
            -- Position mappen
            if type(_Page.Position) == "string" or type(_Page.Position) == "number" then
                _Page.Position = {_Page.Position, 0}
            end
            -- Dialogkamera
            if not _Page.Animations then
                if _Page.DialogCamera == true then
                    _Page.Angle = _Page.Angle or ModuleBriefingSystem.Global.Data.DLGCAMERA_ANGLEDEFAULT;
                    _Page.Zoom = _Page.Zoom or ModuleBriefingSystem.Global.Data.DLGCAMERA_ZOOMDEFAULT;
                    _Page.FOV = _Page.FOV or ModuleBriefingSystem.Global.Data.DLGCAMERA_FOVDEFAULT;
                    _Page.Rotation = _Page.Rotation or ModuleBriefingSystem.Global.Data.DLGCAMERA_ROTATIONDEFAULT;
                else
                    _Page.Angle = _Page.Angle or ModuleBriefingSystem.Global.Data.CAMERA_ANGLEDEFAULT;
                    _Page.Zoom = _Page.Zoom or ModuleBriefingSystem.Global.Data.CAMERA_ZOOMDEFAULT;
                    _Page.FOV = _Page.FOV or ModuleBriefingSystem.Global.Data.CAMERA_FOVDEFAULT;
                    _Page.Rotation = _Page.Rotation or ModuleBriefingSystem.Global.Data.CAMERA_ROTATIONDEFAULT;
                end
            end
            -- Anzeigezeit setzen
            if not _Page.Duration and not _Page.Animations then
                if _Page.FlyTo then
                    _Page.Duration = _Page.FlyTo.Duration;
                else
                    _Page.NoSkipping = false;
                    _Page.Duration = -1;
                end
            end
            -- Multiple Choice
            if _Page.MC then
                for i= 1, #_Page.MC do
                    _Page.MC[i][1] = API.Localize(_Page.MC[i][1]);
                    _Page.MC[i].ID = _Page.MC[i].ID or i;
                end
                _Page.NoSkipping = true;
                _Page.Duration = -1;
            end
            _Page.GetSelectedAnswer = function(self)
                if not self.MC or not self.MC.Selected then
                    return 0;
                end
                return self.MC.Selected;
            end
            table.insert(_Briefing, _Page);
        else
            table.insert(_Briefing, (_Page ~= nil and _Page) or -1);
        end
        return _Page;
    end

    local ASP = function(...)
        local PageName;
        if type(arg[4]) == "string" or type(arg[4]) == "table" then
            PageName = table.remove(arg, 1);
        end
        -- Position angleichen
        local Position = ModuleBriefingSystem.Global:NormalizeZPosForEntity(table.remove(arg, 1));
        -- Rotation angleichen
        local Rotation = ModuleBriefingSystem.Global:NormalizeRotationForEntity(Position[1]);
        -- Größe abgleichen
        local SizeSV = QSB.ScriptingValues[QSB.ScriptingValues.Game].Size;
        local Size = Logic.GetEntityScriptingValue(GetID(Position[1]), SizeSV);
        Position[2] = Position[2] * Core:ScriptingValueIntegerToFloat(Size);
    
        local Title  = table.remove(arg, 1);
        local Text   = table.remove(arg, 1);
        local DlgCam = table.remove(arg, 1);
        local Action;
        if type(arg[1]) == "function" then
            Action = table.remove(arg, 1);
        end
        return AP {
            Name         = PageName,
            Title        = Title,
            Text         = Text,
            Position     = Position,
            Zoom         = (DlgCam and 1000) or ModuleBriefingSystem.Global.Data.CAMERA_ZOOMDEFAULT,
            Angle        = (DlgCam and 27) or ModuleBriefingSystem.Global.Data.CAMERA_ANGLEDEFAULT,
            Rotation     = Rotation,
            Duration     = -1,
            Action       = Action
        }
    end
    
    return AP, ASP;
end

---
-- Erstellt eine Seite für ein Dialog-Briefing.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddPages">API.AddPages</a> erzeugt und an
-- das Briefing gebunden.
--
-- <h5>Dialog Page</h5>
-- Eine Dialog Page ist eine einfache Seite, zu der es keine spezielle
-- Kameraanimation gibt. Sie kann für die Darstellung von Dialogen zwischen
-- Spielfiguren benutzt werden. Folgende Optionen stehen zur Verfügung:
-- <table border="1">
-- <tr>
-- <td><b>Einstellung</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>Der Titel, der oben angezeigt wird. Es ist möglich eine Table mit
-- deutschen und englischen Texten anzugeben.</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>Der Text, der unten angezeigt wird. Es ist möglich eine Table mit
-- deutschen und englischen Texten anzugeben.</td>
-- </tr>
-- <tr>
-- <td>Position</td>
-- <td>Striptname des Entity, welches die Kamera ansieht. Es kann auch eine
-- Table angegeben werden. Dann ist der erste Wert die Position und der
-- zweite Wert das Z-Offset.</td>
-- </tr>
-- <tr>
-- <td>Duration</td>
-- <td>Bestimmt, wie lange die Page angezeigt wird. Wenn du es weglässt,
-- wird die Page solange angezeigt, bis der Spieler "Weiter" klickt.</td>
-- </tr>
-- <tr>
-- <td>DialogCamera</td>
-- <td>Eine Boolean, welche angibt, ob Nah- oder Fernsicht benutzt wird.</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>Eine optional angebbare Funktion, die jedes Mal ausgeführt wird, sobald
-- die Seite angezeigt wird.</td>
-- </tr>
-- </table>
-- <p>Beispiel:</p>
-- <pre>AP {
--    Title        = "Marcus",
--    Text         = "Das ist eine simple Dialogseite",
--    Position     = "Marcus",
--    DialogCamera = true,
--};</pre>
-- Eine solche Seite wird immer im Winkel von -45° auf die Welt schauen.
-- 
-- <br><br><h5>Erweiterte Dialog Page</h5>
-- Will man die Kameraeinstellungen selbst vornehmen kann man einige oder alle
-- der folgenden Optionen ergänzen:
-- <table border="1">
-- <tr>
-- <td><b>Einstellung</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Rotation</td>
-- <td>Die Rotation der Kamera gibt den Winkel an, indem die Kamera um das
-- Ziel gedreht wird.</td>
-- </tr>
-- <tr>
-- <td>Zoom</td>
-- <td>Zoom bestimmt die Entfernung der Kamera zum Ziel.</td>
-- </tr>
-- <tr>
-- <td>Angle</td>
-- <td>Der Angle gibt den Winkel an, in dem die Kamera gekippt wird.</td>
-- </tr>
-- <tr>
-- <td>FadeIn</td>
-- <td>Diese Option ermöglicht das Einblenden von schwarz.</td>
-- </tr>
-- <tr>
-- <td>FadeOut</td>
-- <td>Diese Option ermoglicht das Ausblenden zu schwarz.</td>
-- </tr>
-- <tr>
-- <td>FaderAlpha</td>
-- <td>Diese Option ermöglicht eine Seite komplett schwarz darzustellen. Du
-- kannst dies Einsetzen um von einem Punkt zum anderen zu springen und
-- "hinter dem Vorhang" Änderungen vorzunehmen, wie z.B. Entiries erzeugen.</td>
-- </tr>
-- </table>
--
-- <br><h5>Bedingtes Anzeigen</h5>
-- Hat man verschiedene Handlungsstränge oder sollen sich die Texte an die
-- Aktionen des Spielers anpassen, so kann es sein, dass man Pages anzeigen
-- oder überspringen will. Dafür kann man Pages einen Namen geben.
-- <pre>AP {
--    Name        = "ExamplePage1",
--    ...
--};</pre>
-- Mit diesem Namen kann eine Page direkt angesprungen werden.
-- <pre>AP("ExamplePage1")</pre>
--
-- <br><h5>Multiple Choice</h5>
-- In einem Dialog kann der Spieler auch zur Auswahl einer Option gebeten
-- werden. Dies wird als Multiple Choice bezeichnet. Schreibe die Optionen
-- in eine Subtable MC.
-- <pre>AP {
--    ...
--    MC = {
--        {"Antwort 1", "ExamplePage1"},
--        {"Antwort 2", Option2Clicked},
--    },
--};</pre>
-- Es kann der Name der Zielseite angegeben werden, oder eine Funktion, die
-- den Namen des Ziels zurück gibt. In der Funktion können vorher beliebige
-- Dinge getan werden, wie z.B. Variablen setzen.
--
-- Eine Antwort kann markiert werden, dass sie auch bei einem Rücksprung,
-- nicht mehrfach gewählt werden kann.
-- <pre>{"Antwort 3", "AnotherPage", Remove = true},</pre>
-- Eine Option kann auch bedingt ausgeblendet werden. Dazu wird eine Funktion
-- angegeben, die für alle Optionen aller MC-Seiten beim Start des Briefing
-- entscheidet, ob die Option sichtbar ist oder nicht.
-- <pre>{"Antwort 3", "AnotherPage", Disable = OptionIsDisabled},</pre>
--
-- Nachdem der Spieler eine Antwort gewählt hat, wird er auf die Seite mit
-- dem angegebenen Namen geleitet.
--
-- Um das Briefing zu beenden, nachdem ein Pfad beendet ist, wird eine leere
-- AP-Seite genutzt. Auf diese Weise weiß das Briefing, das es an dieser
-- Stelle zuende ist.
-- <pre>AP()</pre>
--
-- Soll stattdessen zu einer anderen Seite gesprungen werden, kann bei AP der
-- Name der Seite angeben werden, zu der gesprungen werden soll.
-- <pre>AP("SomePageName")</pre>
--
-- Um später zu einem beliebigen Zeitpunkt die gewählte Antwort einer Seite zu
-- erfahren, muss der Name der Seite genutzt werden.
-- <pre>Briefing.Finished(_Data)
--    local Choosen = _Data:GetPage("Choice"):GetSelectedAnswer();
--end</pre>
-- Die zurückgegebene Zahl ist der Index der Antwort, angefangen von oben.
-- Wird 0 zurückgegeben, wurde noch nicht geantwortet. Wenn Anworten nicht
-- aktiv sind, verändert sich der Index anderer Antworten nicht.
--
-- <br><h5>Zurückblättern</h5>
-- Wenn man zurückblättern erlaubt, aber nicht will, dass die Entscheidung
-- erneut getroffen werden kann, kann man dies mit NoRethink unterbinden.
-- <pre>AP {
--    ...
--    NoRethink = true,
--};</pre>
-- Auf diese Weise hat der Spieler die Möglichkeit die Texte nach der letzten
-- Entscheidung noch einmal zu lesen, ohne dass er seine Meinung ändern kann.
--
-- @param[type=table] _Page Spezifikation der Seite
-- @return[type=table] Refernez auf die angelegte Seite
-- @within Briefing
--
function AP(_Page)
    error("AP (Briefing System): not bound to a briefing!");
end

---
-- Erstellt eine Seite in vereinfachter Syntax. Es wird davon
-- Ausgegangen, dass das Entity ein Siedler ist. Die Kamera
-- schaut den Siedler an.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddPages">API.AddPages</a> erzeugt und an
-- das Briefing gebunden.
--
-- @param[type=string]   _pageName     (optional) Briefing-Seite Namen geben
-- @param[type=string]   _entity       Entity, das die Kamera zeigt
-- @param[type=string]   _title	       Titel der Seite
-- @param[type=string]   _text         Text der Seite
-- @param[type=boolean]  _dialogCamera Nahsicht an/aus
-- @param[type=function] _action       (Optional) Callback-Funktion
-- @return[type=table] Referenz auf die Seite
-- @within Briefing
-- 
-- @usage -- Beispiel ohne Page Name
-- ASP("hans", "Hänschen-Klein", "Ich gehe in die weitel Welt hinein.", true);
-- -- Beispiel mit Page Name
-- ASP("B1P1", "hans", "Hänschen-Klein", "Ich gehe in die weitel Welt hinein.", true);
--
function ASP(...)
    error("ASP (Briefing System): not bound to a briefing!");
end

