-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleBriefingSystem                                         # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es Briefing zu verwenden.
--
-- Briefings dienen zur Darstellung von Dialogen oder zur näheren Erleuterung
-- der aktuellen Spielsituation. Mit Multiple Choice können dem Spieler mehrere
-- Auswahlmöglichkeiten gegeben, multiple Handlungsstränge gestartet
-- oder Menüstrukturen abgebildet werden. Mittels Sprüngen und Leerseiten
-- kann innerhalb des Multiple Choice Briefings navigiert werden.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleBriefingSystem = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

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
    return BundleBriefingSystem.Global:StartBriefing(_Briefing);
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
    BundleBriefingSystem.Global.Data.MissionStartBriefingID = ID;
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
    return BundleBriefingSystem.Global.Data.FinishedBriefings[_BriefingID] == true;
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
        return BundleBriefingSystem.Local.Data.BriefingActive == true;
    end
    return BundleBriefingSystem.Global.Data.BriefingActive == true;
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
        local PageID = BundleBriefingSystem.Global:GetPageIDByName(_Page);
        if PageID < 1 then
            error("Page '" ..tostring(_Page).. "' does not exist!");
            return;
        end
        Logic.ExecuteInLuaLocalState(string.format("API.SetAnswerAvailability(%d, %d, %s)", PageID, _Answer, tostring(not _Visible)));
        return;
    end
    BundleBriefingSystem.Local:SetMCAnswerState(_Page, _Answer, _Visible);
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
-- <b>Alias</b>: AddPages
--
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=function] <a href="#AP">AP</a>
-- @within Anwenderfunktionen
--
-- @usage local AP = API.AddPages(Briefing);
--
function API.AddPages(_Briefing)
    if GUI then
        return;
    end
    _Briefing.GetPage = function(self, _NameOrID)
        local ID = BundleBriefingSystem.Global:GetPageIDByName(_NameOrID);
        return BundleBriefingSystem.Global.Data.CurrentBriefing[ID];
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
                    _Page.Angle = _Page.Angle or BundleBriefingSystem.Global.Data.DLGCAMERA_ANGLEDEFAULT;
                    _Page.Zoom = _Page.Zoom or BundleBriefingSystem.Global.Data.DLGCAMERA_ZOOMDEFAULT;
                    _Page.FOV = _Page.FOV or BundleBriefingSystem.Global.Data.DLGCAMERA_FOVDEFAULT;
                    _Page.Rotation = _Page.Rotation or BundleBriefingSystem.Global.Data.DLGCAMERA_ROTATIONDEFAULT;
                else
                    _Page.Angle = _Page.Angle or BundleBriefingSystem.Global.Data.CAMERA_ANGLEDEFAULT;
                    _Page.Zoom = _Page.Zoom or BundleBriefingSystem.Global.Data.CAMERA_ZOOMDEFAULT;
                    _Page.FOV = _Page.FOV or BundleBriefingSystem.Global.Data.CAMERA_FOVDEFAULT;
                    _Page.Rotation = _Page.Rotation or BundleBriefingSystem.Global.Data.CAMERA_ROTATIONDEFAULT;
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
        local Position = BundleBriefingSystem.Global:NormalizeZPosForEntity(table.remove(arg, 1));
        -- Rotation angleichen
        local Rotation = BundleBriefingSystem.Global:NormalizeRotationForEntity(Position[1]);
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
            Zoom         = (DlgCam and 1000) or BundleBriefingSystem.Global.Data.CAMERA_ZOOMDEFAULT,
            Angle        = (DlgCam and 27) or BundleBriefingSystem.Global.Data.CAMERA_ANGLEDEFAULT,
            Rotation     = Rotation,
            Duration     = -1,
            Action       = Action
        }
    end
    
    return AP, ASP;
end
AddPages = API.AddPages;

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
    error("AP: Please use the function provides by AddPages!");
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
    error("ASP: Please use the function provided by AddPages!");
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleBriefingSystem = {
    Global = {
        Data = {
            CAMERA_ANGLEDEFAULT = 43,
            CAMERA_ROTATIONDEFAULT = -45,
            CAMERA_ZOOMDEFAULT = 6500,
            CAMERA_FOVDEFAULT = 42,
            DLGCAMERA_ANGLEDEFAULT = 27,
            DLGCAMERA_ROTATIONDEFAULT = -45,
            DLGCAMERA_ZOOMDEFAULT = 1750,
            DLGCAMERA_FOVDEFAULT = 25,

            FinishedBriefings = {},
            CurrentBriefing = {},
            CurrentPage = {},
            BriefingQueue = {},
            BriefingID = 0,
            DisplayIngameCutscene = false,
            BriefingActive = false,
            PauseQuests = true,
            MissionStartBriefingID = 0,
        }
    },
    Local = {
        Data = {
            CurrentBriefing = {},
            CurrentPage = {},
            BriefingMessages = {},
            DisplayIngameCutscene = false,
            BriefingActive = false,
            ChatOptionsWasShown = false,
            MessageLogWasShown = false,
            LastSkipButtonPressed = 0,
        },
    },

    Text = {
        NextButton = {de = "Weiter",  en = "Forward"},
        PrevButton = {de = "Zurück",  en = "Previous"},
        EndButton  = {de = "Beenden", en = "Close"},
    },
}

-- Global Script ------------------------------------------------------------ --

---
-- Startet das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:Install()
    StartSimpleHiResJobEx(self.BriefingExecutionController);
    StartSimpleJobEx(self.BriefingQuestPausedController);
end

---
-- Konvertiert eine Briefing-Table des alten Formats in das neue.
--
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=number] ID des Briefing
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:ConvertBriefingTable(_Briefing)
    _Briefing.DisableGlobalInvulnerability = _Briefing.disableGlobalInvulnerability or _Briefing.DisableGlobalInvulnerability;
    _Briefing.HideBorderPins = _Briefing.hideBorderPins or _Briefing.HideBorderPins;
    _Briefing.ShowSky = _Briefing.showSky or _Briefing.ShowSky;
    _Briefing.RestoreGameSpeed = _Briefing.restoreGameSpeed or _Briefing.RestoreGameSpeed;
    _Briefing.RestoreCamera = _Briefing.restoreCamera or _Briefing.RestoreCamera;
    _Briefing.SkippingAllowed = (_Briefing.skipPerPage or _Briefing.skipAll) or _Briefing.SkippingAllowed;
    _Briefing.ReturnForbidden = _Briefing.returnForbidden or _Briefing.ReturnForbidden;
    _Briefing.Finished = _Briefing.finished or _Briefing.Finished;
    _Briefing.Starting = _Briefing.starting or _Briefing.Starting;
    
    for k, v in pairs(_Briefing) do
        if type(v) == "table" then
            -- Normale Optionen
            _Briefing[k].Title = v.title or _Briefing[k].Title;
            _Briefing[k].Text = v.text or _Briefing[k].Text;
            _Briefing[k].Position = (v.position and {v.position, 0}) or _Briefing[k].Position;
            _Briefing[k].Angle = v.angle or _Briefing[k].Angle;
            _Briefing[k].Rotation = v.rotation or _Briefing[k].Rotation;
            _Briefing[k].Zoom = v.zoom or _Briefing[k].Zoom;
            _Briefing[k].Action = v.action or _Briefing[k].Action;
            _Briefing[k].FadeIn = v.fadeIn or _Briefing[k].FadeIn;
            _Briefing[k].FadeOut = v.fadeOut or _Briefing[k].FadeOut;
            _Briefing[k].FaderAlpha = v.faderAlpha or _Briefing[k].FaderAlpha;
            _Briefing[k].DialogCamera = v.dialogCamera or _Briefing[k].DialogCamera;
            _Briefing[k].Portrait = v.portrait or _Briefing[k].Portrait;
            _Briefing[k].NoRethink = v.noRethink or _Briefing[k].NoRethink;
            _Briefing[k].NoHistory = v.noHistory or _Briefing[k].NoHistory;
            -- Splashscreen
            if v.splashscreen then
                v.Splashscreen = v.splashscreen;
                if type(v.Splashscreen) == "table" then
                    v.Splashscreen = v.Splashscreen.image;
                end
            end
            -- Multiple Choice
            if v.mc then
                _Briefing[k].Title = v.mc.title;
                _Briefing[k].Text = v.mc.title;
                _Briefing[k].MC = v.mc.answers;
            end
        end
    end
    return _Briefing;
end

---
-- Startet ein Briefing.
--
-- @param[type=table] _Briefing Briefing Definition
-- @param[type=number] _ID      ID aus Queue
-- @return[type=number] ID des Briefing
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:StartBriefing(_Briefing, _ID)
    _Briefing = self:ConvertBriefingTable(_Briefing);
    if _Briefing.ReturnForbidden == nil then
        _Briefing.ReturnForbidden = true;
    end

    if not _ID then
        self.Data.BriefingID = self.Data.BriefingID +1;
        _ID = self.Data.BriefingID;
    end

    if API.IsLoadscreenVisible() or self:IsBriefingActive() then
        table.insert(self.Data.BriefingQueue, {_Briefing, _ID});
        if not self.Data.BriefingQueueJobID then
            self.Data.BriefingQueueJobID = StartSimpleHiResJobEx(self.BriefingQueueController);
        end
        return _ID;
    end

    if not self:AreAllPagesLegit(_Briefing) then
        error("API.StartBriefing: Discovered illegaly added pages inside the briefing!");
        return _ID;
    end

    self.Data.CurrentBriefing = API.InstanceTable(_Briefing);
    self.Data.CurrentBriefing.Page = 1;
    self.Data.CurrentBriefing.PageHistory = {};
    self.Data.CurrentBriefing.ID = _ID;
    self.Data.CurrentBriefing.BarOpacity = self.Data.CurrentBriefing.BarOpacity or 1;

    -- Animationen übertragen
    self:TransformAnimations();
    
    -- Bars Default setzen
    if self.Data.CurrentBriefing.BigBars == nil then
        self.Data.CurrentBriefing.BigBars = true;
    end
    -- Multiple Choice vorbereiten
    self:DisableMCAnswers();
    -- Globale Unverwundbarkeit
    if self.Data.CurrentBriefing.DisableGlobalInvulnerability ~= false then
        Logic.SetGlobalInvulnerability(1);
    end
    -- Kopieren ins lokale Skript
    local Briefing = API.ConvertTableToString(self.Data.CurrentBriefing);
    Logic.ExecuteInLuaLocalState("BundleBriefingSystem.Local:StartBriefing(" ..Briefing.. ")");
    
    self.Data.BriefingActive = true;
    if self.Data.CurrentBriefing.Starting then
        self.Data.CurrentBriefing:Starting();
    end
    self.Data.CurrentPage = {};
    self:PageStarted();
    return _ID;
end

---
-- Beendet ein Briefing.
--
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:FinishBriefing()
    Logic.SetGlobalInvulnerability(0);
    Logic.ExecuteInLuaLocalState("BundleBriefingSystem.Local:FinishBriefing()");

    if self.Data.CurrentBriefing.Finished then
        self.Data.CurrentBriefing:Finished();
    end

    self.Data.FinishedBriefings[self.Data.CurrentBriefing.ID] = true;
    self.Data.CurrentBriefing = {};
    self.Data.CurrentPage = {};
    self.Data.BriefingActive = false;
end

---
-- Gibt die Page-ID zum angegebenen Page-Namen zurück.
--
-- Wenn keine Seite gefunden wird, die den angegebenen Namen hat, wird 0
-- zurückgegeben. Wenn eine Page-ID angegeben wird, wird diese zurückgegeben.
--
-- @param[type=string] _PageName Name der Seite
-- @return[type=number] ID der Seite
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:GetPageIDByName(_PageName)
    if self.Data.CurrentBriefing then
        if type(_PageName) == "number" then
            return _PageName;
        end
        for i= 1, self.Data.CurrentBriefing.Length, 1 do
            local Page = self.Data.CurrentBriefing[i];
            if Page and type(Page) == "table" and Page.Name == _PageName then
                return i;
            end
        end
    end
    return 0;
end

---
-- Startet die aktuelle Briefing-Seite.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:PageStarted()
    local PageID = self.Data.CurrentBriefing.Page;
    if PageID then
        if type(self.Data.CurrentBriefing[PageID]) == "table" then
            if type(self.Data.CurrentBriefing[PageID]) == "table" then
                if self.Data.CurrentBriefing[PageID].Action then
                    self.Data.CurrentBriefing[PageID]:Action();
                end
                self.Data.CurrentPage = self.Data.CurrentBriefing[PageID];
                self.Data.CurrentPage.Started = Logic.GetTime();
                Logic.ExecuteInLuaLocalState("BundleBriefingSystem.Local:PageStarted()");
            end

        elseif type(self.Data.CurrentBriefing[PageID]) == "string" then
            PageID = self:GetPageIDByName(self.Data.CurrentBriefing[PageID]);
            if PageID > 0 then
                self.Data.CurrentBriefing.Page = PageID;
                Logic.ExecuteInLuaLocalState("BundleBriefingSystem.Local.Data.CurrentBriefing.Page = " ..PageID);
                self:PageStarted();
            else
                self:FinishBriefing();
            end

        elseif type(self.Data.CurrentBriefing[PageID]) == "number" and self.Data.CurrentBriefing[PageID] > 0 then
            self.Data.CurrentBriefing.Page = self.Data.CurrentBriefing[PageID];
            Logic.ExecuteInLuaLocalState("BundleBriefingSystem.Local.Data.CurrentBriefing.Page = " ..self.Data.CurrentBriefing.Page);
            self:PageStarted();

        else
            self:FinishBriefing();
        end
    end
end

---
-- Beendet die aktuelle Briefing-Seite
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:PageFinished()
    local PageID = self.Data.CurrentBriefing.Page;
    Logic.ExecuteInLuaLocalState("BundleBriefingSystem.Local:PageFinished()");
    self.Data.CurrentBriefing.Page = (self.Data.CurrentBriefing.Page or 0) +1;
    local PageID = self.Data.CurrentBriefing.Page;
    if not self.Data.CurrentBriefing[PageID] or PageID > #self.Data.CurrentBriefing then
        BundleBriefingSystem.Global:FinishBriefing();
    else
        BundleBriefingSystem.Global:PageStarted();
    end
end

---
-- Prüft, ob ein Briefing aktiv ist.
-- @return[type=boolean] Briefing ist aktiv
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:IsBriefingActive()
    return self.Data.BriefingActive == true;
end

function BundleBriefingSystem.Global:AreAllPagesLegit(_Briefing)
    for i= 1, #_Briefing, 1 do
        if type(_Briefing[i]) == "table" then
            if not _Briefing[i].__Legit then
                return false;
            end
        end
    end
    return true;
end

---
-- Bindet die angegebenen Animationen an die jeweiligen Pages.
--
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:TransformAnimations()
    if self.Data.CurrentBriefing.PageAnimations then
        for k, v in pairs(self.Data.CurrentBriefing.PageAnimations) do
            local PageID = self:GetPageIDByName(k);
            self.Data.CurrentBriefing[PageID].Animations = self.Data.CurrentBriefing[PageID].Animations or {};
            self.Data.CurrentBriefing[PageID].Animations.PurgeOld = v.PurgeOld == true;
            for i= 1, #v, 1 do               
                -- Relative Angabe
                if #v[i] == 9 then
                    table.insert(self.Data.CurrentBriefing[PageID].Animations, {
                        Duration = v[i][9] or 2 * 60,

                        Start = {
                            Position = (type(v[i][1]) ~= "table" and {v[i][1],0}) or v[i][1],
                            Rotation = v[i][2],
                            Zoom     = v[i][3],
                            Angle    = v[i][4],
                        },
                        End = {
                            Position = (type(v[i][5]) ~= "table" and {v[i][5],0}) or v[i][5],
                            Rotation = v[i][6],
                            Zoom     = v[i][7],
                            Angle    = v[i][8],
                        },
                    });
                -- Vektorisierte Angabe
                elseif #v[i] == 5 then
                    table.insert(self.Data.CurrentBriefing[PageID].Animations, {
                        Duration = v[i][5] or 2 * 60,

                        Start = {
                            Position = (type(v[i][1]) ~= "table" and {v[i][1],0}) or v[i][1],
                            LookAt   = (type(v[i][2]) ~= "table" and {v[i][1],0}) or v[i][2],
                        },
                        End = {
                            Position = (type(v[i][3]) ~= "table" and {v[i][5],0}) or v[i][3],
                            LookAt   = (type(v[i][4]) ~= "table" and {v[i][1],0}) or v[i][4],
                        },
                    });
                end
            end
        end
        self.Data.CurrentBriefing.PageAnimations = nil;
    end
end

---
-- Gibt für das Entity eine Tabelle mit Skriptnamen und Z-Offset zurück.
--
-- @param[type=string] _Entity Skriptname des Entity
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:NormalizeZPosForEntity(_Entity)
    local TargetID = GetID(_Entity);
    local TargetType = Logic.GetEntityType(TargetID);
    local Position = {_Entity, 0};
    if Logic.IsSettler(TargetID) == 1 then
        Position[2] = 120;
        if Logic.IsKnight(TargetID) then
            Position[2] = 160;
        end
    end
    if TargetType == Entities.XD_ScriptEntity then
        Position[2] = 160;
    end
    return Position;
end

---
-- Gibt die Rotation für das Entity zurück.
--
-- @param[type=string] _Entity Skriptname des Entity
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:NormalizeRotationForEntity(_Entity)
    local Rotation = 0;
    if IsExisting(_Entity) then
        Rotation = Logic.GetEntityOrientation(GetID(_Entity));
        if Logic.IsSettler(GetID(_Entity)) == 1 then
            Rotation = Rotation + 90;
        end
    end
    return Rotation;
end

---
-- Reagiert auf die Auswahl einer Option einer Multiple-Choice-Page.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:OnMCConfirmed(_Selected)
    if self.Data.CurrentPage.MC then
        local PageID = self.Data.CurrentBriefing.Page;
        self.Data.CurrentBriefing[PageID].MC.Selected = _Selected;
        local JumpData = self.Data.CurrentPage.MC[_Selected];
        if type(JumpData[2]) == "function" then
            self.Data.CurrentBriefing.Page = self:GetPageIDByName(JumpData[2](self.Data.CurrentPage, JumpData))-1;
        else
            self.Data.CurrentBriefing.Page = self:GetPageIDByName(JumpData[2])-1;
        end
        Logic.ExecuteInLuaLocalState("BundleBriefingSystem.Local.Data.CurrentBriefing.Page = " ..self.Data.CurrentBriefing.Page);
        self:PageFinished();
    end
end

---
-- Aktualisiert, ob eine Option sichtbar ist oder nicht. Eine Option
-- braucht eine Update-Funktion "Display". Die Update-Funktion
-- erhält Daten der Seite und Daten der Antwort.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:DisableMCAnswers()
    for i= 1, #self.Data.CurrentBriefing, 1 do
        if type(self.Data.CurrentBriefing[i]) == "table" and self.Data.CurrentBriefing[i].MC then
            for k, v in pairs(self.Data.CurrentBriefing[i].MC) do 
                if type(v) == "table" and type(v.Disable) == "function" then
                    local Invisible = v.Disable(self.Data.CurrentBriefing[i], v) == true;
                    self.Data.CurrentBriefing[i].MC[k].Invisible = Invisible;
                end
            end
        end
    end
end

---
-- Steuert das automatische weiter blättern und Sprünge zwischen Pages.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global.BriefingExecutionController()
    if not BundleBriefingSystem.Global.Data.DisplayIngameCutscene and BundleBriefingSystem.Global:IsBriefingActive() then
        if BundleBriefingSystem.Global.Data.CurrentPage == nil then
            BundleBriefingSystem.Global:FinishBriefing();

        elseif type(BundleBriefingSystem.Global.Data.CurrentPage) == "table" then
            local Duration = (BundleBriefingSystem.Global.Data.CurrentPage.Duration or 0);
            if Duration > -1 and BundleBriefingSystem.Global.Data.CurrentPage.Started then
                if Logic.GetTime() > BundleBriefingSystem.Global.Data.CurrentPage.Started + Duration then
                    local PageID = BundleBriefingSystem.Global.Data.CurrentBriefing.Page;
                    if not BundleBriefingSystem.Global.Data.CurrentPage.NoHistory then
                        Logic.ExecuteInLuaLocalState("table.insert(BundleBriefingSystem.Local.Data.CurrentBriefing.PageHistory, " ..PageID.. ")");
                    end
                    BundleBriefingSystem.Global:PageFinished();
                end
            end
        end
    end
end

---
-- Verhindert, dass während Briefings Quest-Timer weiter laufen.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global.BriefingQuestPausedController()
    if BundleBriefingSystem.Global.Data.BriefingActive and BundleBriefingSystem.Global.Data.PauseQuests then
        for i= 1, #Quests, 1 do
            if Quests[i].State == QuestState.Active then
                Quests[i].StartTime = Quests[i].StartTime +1;
            end
        end
    end
end

---
-- Steuert die Briefing-Warteschlange.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global.BriefingQueueController()
    if #BundleBriefingSystem.Global.Data.BriefingQueue == 0 then
        BundleBriefingSystem.Global.Data.BriefingQueueJobID = nil;
        return true;
    end
    
    if not API.IsLoadscreenVisible() and not BundleBriefingSystem.Global:IsBriefingActive() then
        local Next = table.remove(BundleBriefingSystem.Global.Data.BriefingQueue, 1);
        BundleBriefingSystem.Global:StartBriefing(Next[1], Next[2]);
    end
end

-- Local Script ------------------------------------------------------------- --

---
-- Startet das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:Install()
    if not InitializeFader then
        Script.Load("script/mainmenu/fader.lua");
    end
    self:OverrideThroneRoomFunctions();
end

---
-- Startet ein Briefing.
-- @param[type=table] _Briefing Briefing Definition
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:StartBriefing(_Briefing)
    self.Data.CurrentBriefing.Page = 1;
    self.Data.CurrentBriefing = _Briefing;
    self.Data.CurrentBriefing.CurrentAnimation = nil;
    self.Data.CurrentBriefing.AnimationQueue = {};
    if self.Data.CurrentBriefing.HideBorderPins then
        Display.SetRenderBorderPins(0);
    end
    if self.Data.CurrentBriefing.ShowSky then
        Display.SetRenderSky(1);
    end
    if Game.GameTimeGetFactor() ~= 0 then
        if self.Data.CurrentBriefing.RestoreGameSpeed and not self.Data.GameSpeedBackup then
            self.Data.GameSpeedBackup = Game.GameTimeGetFactor();
        end
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
    end
    if self.Data.CurrentBriefing.RestoreCamera and not self.Data.CameraBackup then
        self.Data.CameraBackup = {Camera.RTS_GetLookAtPosition()};
    end
    if not self.Data.CinematicActive then
        self:ActivateCinematicMode();
    end
    self.Data.BriefingActive = true;
end

---
-- Beendet ein Briefing.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:FinishBriefing()
    if self.Data.CurrentBriefing.CameraBackup then 
        Camera.RTS_SetLookAtPosition(unpack(self.Data.CurrentBriefing.CameraBackup));
        self.Data.CurrentBriefing.CameraBackup = nil;
    end
    Display.SetRenderBorderPins(1);
    Display.SetRenderSky(0);
    local GameSpeed = (self.Data.GameSpeedBackup or 1);
    Game.GameTimeSetFactor(GUI.GetPlayerID(), GameSpeed);
    self.Data.GameSpeedBackup = nil;
    self:DeactivateCinematicMode();
    self.Data.BriefingActive = false;
    self.Data.CurrentBriefing = {};
    self.Data.CurrentPage = {};
end

---
-- Zeigt die aktuele Seite an.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:PageStarted()
    local PageID = self.Data.CurrentBriefing.Page;
    self.Data.CurrentPage = self.Data.CurrentBriefing[PageID];
    if type(self.Data.CurrentPage) == "table" then
        self.Data.CurrentPage.Started = Logic.GetTime();

        -- Zurück und Weiter
        local BackFlag = 1;
        local SkipFlag = 1;
        if self.Data.CurrentBriefing.SkippingAllowed ~= true or self.Data.CurrentPage.NoSkipping == true then
            if self.Data.CurrentPage.MC and not self.Data.CurrentPage.NoHistory then
                table.insert(self.Data.CurrentBriefing.PageHistory, PageID);
            end
            SkipFlag = 0;
            BackFlag = 0;
        end
        local LastPageID = self.Data.CurrentBriefing.PageHistory[#self.Data.CurrentBriefing.PageHistory];
        local LastPage = self.Data.CurrentBriefing[LastPageID];
        local NoRethinkMC = (type(LastPage) == "table" and LastPage.NoRethink and 0) or 1;
        if PageID == 1 or NoRethinkMC == 0 or self.Data.CurrentBriefing.ReturnForbidden == true then
            BackFlag = 0;
        end
        if  (self.Data.CurrentPage.Duration == nil or self.Data.CurrentPage.Duration == -1)
        and not self.Data.CurrentPage.MC then
            SkipFlag = 1;
        end
        XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", SkipFlag);
        XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/StartButton", BackFlag);

        -- Animationen
        if self.Data.CurrentPage.Animations then
            if self.Data.CurrentPage.Animations.PurgeOld then
                self.Data.CurrentBriefing.CurrentAnimation = nil;
                self.Data.CurrentBriefing.AnimationQueue = {};
            end
            for i= 1, #self.Data.CurrentPage.Animations, 1 do
                local Animation = API.InstanceTable(self.Data.CurrentPage.Animations[i]);
                table.insert(self.Data.CurrentBriefing.AnimationQueue, Animation);
            end
        end

        -- Titel setzen
        local TitleWidget = "/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight";
        XGUIEng.SetText(TitleWidget, "");
        if self.Data.CurrentPage.Title then
            local Title = self.Data.CurrentPage.Title;
            if Title:sub(1, 1) ~= "{" then
                Title = "{@color:255,250,0,255}{center}" ..Title;
            end
            XGUIEng.SetText(TitleWidget, Title);
        end

        -- Text setzen
        local TextWidget = "/InGame/ThroneRoom/Main/MissionBriefing/Text";
        XGUIEng.SetText(TextWidget, "");
        if self.Data.CurrentPage.Text then
            local Text = self.Data.CurrentPage.Text;
            if Text:sub(1, 1) ~= "{" then
                Text = "{center}" ..Text;
            end
            if not self.Data.CurrentBriefing.BigBars then
                Text = "{cr}{cr}{cr}" .. Text;
            end
            XGUIEng.SetText(TextWidget, Text);
        end

        -- Fader
        self:SetFader();
        -- Portrait
        self:SetPortrait();
        -- Splashscreen
        self:SetSplashscreen();
        -- Multiple Choice
        self:SetOptionsDialog();
    end
end

---
-- Beendet die aktuelle Seite.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:PageFinished()
    -- TODO: Warum ist PageHistory hier u.U. nil?
    -- self.Data.CurrentBriefing.PageHistory = self.Data.CurrentBriefing.PageHistory or {};
    self.Data.CurrentBriefing.Page = (self.Data.CurrentBriefing.Page or 0) +1;
    EndJob(self.Data.CurrentBriefing.FaderJob);
end

---
-- Prüft, ob ein Briefing aktiv ist.
-- @param[type=boolean] Briefing ist aktiv
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:IsBriefingActive()
    return self.Data.BriefingActive == true;
end

---
-- Reagiert auf die Auswahl einer Option einer Multiple-Choice-Page.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:LocalOnMCConfirmed()
    local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
    local Position = self.Data.OriginalBoxPosition;
    XGUIEng.SetWidgetScreenPosition(Widget, Position[1], Position[2]);
    XGUIEng.ShowWidget(Widget, 0);
    XGUIEng.PopPage();

    if self.Data.CurrentPage.MC then
        local Selected = XGUIEng.ListBoxGetSelectedIndex(Widget .. "/ListBox")+1;
        local AnswerID = self.Data.CurrentPage.MC.Map[Selected];
        for i= #self.Data.CurrentPage.MC, 1, -1 do
            if self.Data.CurrentPage.MC[i].ID == AnswerID and self.Data.CurrentPage.MC[i].Remove then
                self.Data.CurrentPage.MC[i].Invisible = true;
            end
        end
        GUI.SendScriptCommand("BundleBriefingSystem.Global:OnMCConfirmed(" ..AnswerID.. ")");
    end
end

---
-- Ändert die Sichtbarkeit einer Antwort im aktuellen Briefing.
-- @param[type=number] _Page ID der Page
-- @param[type=number] _Answer ID der Antwort
-- @param[type=boolean] _Visible Sichtbarkeit
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:SetMCAnswerState(_Page, _Answer, _Visible)
   assert(type(_Page) == "number");
   assert(type(_Answer) == "number");
   if self.Data.BriefingActive then
       if  self.Data.CurrentBriefing[_Page] and self.Data.CurrentBriefing[_Page].MC then
           for k, v in pairs(self.Data.CurrentBriefing[_Page].MC) do
               if v and v.ID == _Answer then
                   self.Data.CurrentBriefing[_Page].MC[k].Invisible = _Visible == true;
               end
           end
       end
   end
end

---
-- Steuert die Kamera während des Throneroom Mode.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:ThroneRoomCameraControl()
    if self.Data.DisplayIngameCutscene then
        if AddOnCutsceneSystem then
            AddOnCutsceneSystem.Local:ThroneRoomCameraControl();
        end
    else
        if type(self.Data.CurrentPage) == "table" then
            -- Animation invalidieren
            if self.Data.CurrentBriefing.CurrentAnimation then
                local CurrentTime = Logic.GetTime();
                local Animation = self.Data.CurrentBriefing.CurrentAnimation;
                if CurrentTime > Animation.Started + Animation.Duration then
                    if #self.Data.CurrentBriefing.AnimationQueue > 0 then
                        self.Data.CurrentBriefing.CurrentAnimation = nil;
                    end
                end
            end
            -- Nächste Animation
            if self.Data.CurrentBriefing.CurrentAnimation == nil then
                if self.Data.CurrentBriefing.AnimationQueue and #self.Data.CurrentBriefing.AnimationQueue > 0 then
                    local Next = table.remove(self.Data.CurrentBriefing.AnimationQueue, 1);
                    Next.Started = Logic.GetTime();
                    self.Data.CurrentBriefing.CurrentAnimation = Next;
                end
            end

            -- Kamera
            local PX, PY, PZ = self:GetPagePosition();
            local LX, LY, LZ = self:GetPageLookAt();
            if PX and not LX then
                LX, LY, LZ, PX, PY, PZ = self:GetCameraProperties();
            end
            Camera.ThroneRoom_SetPosition(PX, PY, PZ);
            Camera.ThroneRoom_SetLookAt(LX, LY, LZ);
            Camera.ThroneRoom_SetFOV(42.0);

            -- Bar Style
            BundleBriefingSystem.Local:SetBarStyle(self.Data.CurrentBriefing.BarOpacity, self.Data.CurrentBriefing.BigBars);
            if self.Data.CurrentPage.BigBars ~= nil then
                BundleBriefingSystem.Local:SetBarStyle(self.Data.CurrentBriefing.BarOpacity, self.Data.CurrentPage.BigBars);
            end

            -- Splashscreen
            self:ScrollSplashscreen();

            -- Multiple Choice
            if self.Data.MCSelectionIsShown then
                local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
                if XGUIEng.IsWidgetShown(Widget) == 0 then
                    self.Data.MCSelectionIsShown = false;
                    self:LocalOnMCConfirmed();
                end
            end

            -- Button Texte
            XGUIEng.SetText("/InGame/ThroneRoom/Main/StartButton", "{center}" ..API.Localize(BundleBriefingSystem.Text.PrevButton));
            local SkipText = API.Localize(BundleBriefingSystem.Text.NextButton);
            local PageID = self.Data.CurrentBriefing.Page;
            if PageID == #self.Data.CurrentBriefing or self.Data.CurrentBriefing[PageID+1] == -1 then
                SkipText = API.Localize(BundleBriefingSystem.Text.EndButton);
            end
            XGUIEng.SetText("/InGame/ThroneRoom/Main/Skip", "{center}" ..SkipText);
        end
    end
end

---
-- Gibt die Blickrichtung der Kamera und die Position der Kamera für den
-- Kompatibelitätsmodus zurück.
-- @return[type=number] LookAt X
-- @return[type=number] LookAt Y
-- @return[type=number] LookAt Z
-- @return[type=number] Position X
-- @return[type=number] Position Y
-- @return[type=number] Position Z
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:GetCameraProperties()
    local CurrPage, FlyTo;
    if self.Data.CurrentBriefing.CurrentAnimation then
        CurrPage = self.Data.CurrentBriefing.CurrentAnimation.Start;
        FlyTo = self.Data.CurrentBriefing.CurrentAnimation.End;
    else
        CurrPage = self.Data.CurrentPage;
        FlyTo = self.Data.CurrentPage.FlyTo;
    end

    local startPosition = CurrPage.Position;
    local endPosition = (FlyTo and FlyTo.Position) or CurrPage.Position;
    local startRotation = CurrPage.Rotation;
    local endRotation = (FlyTo and FlyTo.Rotation) or CurrPage.Rotation;
    local startZoomAngle = CurrPage.Angle;
    local endZoomAngle = (FlyTo and FlyTo.Angle) or CurrPage.Angle;
    local startZoomDistance = CurrPage.Zoom;
    local endZoomDistance = (FlyTo and FlyTo.Zoom) or CurrPage.Zoom;
    local startFOV = (CurrPage.FOV) or 42.0;
    local endFOV = ((FlyTo and FlyTo.FOV) or CurrPage.FOV) or 42.0;

    local factor = self:GetLERP();
    
    local lPLX, lPLY, lPLZ = BundleBriefingSystem.Local:ConvertPosition(startPosition);
    local cPLX, cPLY, cPLZ = BundleBriefingSystem.Local:ConvertPosition(endPosition);
    local lookAtX = lPLX + (cPLX - lPLX) * factor;
    local lookAtY = lPLY + (cPLY - lPLY) * factor;
    local lookAtZ = lPLZ + (cPLZ - lPLZ) * factor;

    local zoomDistance = startZoomDistance + (endZoomDistance - startZoomDistance) * factor;
    local zoomAngle = startZoomAngle + (endZoomAngle - startZoomAngle) * factor;
    local rotation = startRotation + (endRotation - startRotation) * factor;
    local line = zoomDistance * math.cos(math.rad(zoomAngle));
    local positionX = lookAtX + math.cos(math.rad(rotation - 90)) * line;
    local positionY = lookAtY + math.sin(math.rad(rotation - 90)) * line;
    local positionZ = lookAtZ + (zoomDistance) * math.sin(math.rad(zoomAngle));

    return lookAtX, lookAtY, lookAtZ, positionX, positionY, positionZ;
end

---
-- Gibt die interpolierte Kameraposition zurück.
-- @return[type=number] X
-- @return[type=number] Y
-- @return[type=number] Z
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:GetPagePosition()
    local Position, FlyTo;
    if self.Data.CurrentBriefing.CurrentAnimation then
        Position = self.Data.CurrentBriefing.CurrentAnimation.Start.Position;
        FlyTo = self.Data.CurrentBriefing.CurrentAnimation.End.Position;
    else
        Position = self.Data.CurrentPage.Position;
        FlyTo = self.Data.CurrentPage.FlyTo;
    end

    local x, y, z = self:ConvertPosition(Position);
    if FlyTo then
        local lX, lY, lZ = self:ConvertPosition(FlyTo.Position);
        if lX then
            x = x + (lX - x) * self:GetLERP();
            y = y + (lY - y) * self:GetLERP();
            z = z + (lZ - z) * self:GetLERP();
        end
    end
    return x, y, z;
end

---
-- Gibt die interpolierte Blickrichtung der Kamera zurück.
-- @return[type=number] X
-- @return[type=number] Y
-- @return[type=number] Z
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:GetPageLookAt()
    local LookAt, FlyTo;
    if self.Data.CurrentBriefing.CurrentAnimation then
        LookAt = self.Data.CurrentBriefing.CurrentAnimation.Start.LookAt;
        FlyTo = self.Data.CurrentBriefing.CurrentAnimation.End.LookAt;
    else
        LookAt = self.Data.CurrentPage.LookAt;
        FlyTo = self.Data.CurrentPage.FlyTo;
    end

    local x, y, z = self:ConvertPosition(LookAt);
    if FlyTo and x then
        local lX, lY, lZ = self:ConvertPosition(FlyTo.LookAt);
        if lX then
            x = x + (lX - x) * self:GetLERP();
            y = y + (lY - y) * self:GetLERP();
            z = z + (lZ - z) * self:GetLERP();
        end
    end
    return x, y, z;
end

---
-- Konvertiert die angegebenen Koordinaten zu XYZ.
-- @return[type=number] X
-- @return[type=number] Y
-- @return[type=number] Z
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:ConvertPosition(_Table)
    local x, y, z;
    if _Table and _Table.X then
        x = _Table.X; y = _Table.Y; z = _Table.Z;
    elseif _Table and not _Table.X then
        x, y, z = Logic.EntityGetPos(GetID(_Table[1]));
        z = z + (_Table[2] or 0);
    end
    return x, y, z;
end

---
-- Gibt den linearen Interpolationsfaktor zurück.
-- @param[type=number] LERP
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:GetLERP()
    local Current = Logic.GetTime();
    local Started, FlyTime;
    if self.Data.CurrentBriefing.CurrentAnimation then
        Started = self.Data.CurrentBriefing.CurrentAnimation.Started;
        FlyTime = self.Data.CurrentBriefing.CurrentAnimation.Duration;
    else
        Started = self.Data.CurrentPage.Started;
        FlyTime = self.Data.CurrentPage.Duration;
        if self.Data.CurrentPage.FlyTo then
            FlyTime = self.Data.CurrentPage.FlyTo.Duration;
        end
    end

    local Factor = 1.0;
    if FlyTime and FlyTime > 0 then
        if Started + FlyTime > Current then
            Factor = (Current - Started) / FlyTime;
            if Factor > 1 then
                Factor = 1.0;
            end
        end
    end
    return Factor;
end

---
-- Reagiert auf einen beliebigen Linksklick im Throneroom.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:ThroneRoomLeftClick()
    if self.Data.DisplayIngameCutscene then
        if AddOnCutsceneSystem then
            AddOnCutsceneSystem.Local:ThroneRoomLeftClick();
        end
    else
        -- Klick auf Entity
        local EntityID = GUI.GetMouseOverEntity();
        GUI.SendScriptCommand([[
            local CurrentPage = BundleBriefingSystem.Global.CurrentPage;
            if CurrentPage and CurrentPage.LeftClickOnEntity then
                BundleBriefingSystem.Global.CurrentPage:LeftClickOnEntity(]] ..tostring(EntityID).. [[)
            end
        ]]);
        -- Klick in die Spielwelt
        local x,y = GUI.Debug_GetMapPositionUnderMouse();
        GUI.SendScriptCommand([[
            local CurrentPage = BundleBriefingSystem.Global.CurrentPage;
            if CurrentPage and CurrentPage.LeftClickOnPosition then
                BundleBriefingSystem.Global.CurrentPage:LeftClickOnPosition(]] ..tostring(x).. [[, ]] ..tostring(y).. [[)
            end
        ]]);
        -- Klick auf den Bildschirm
        local x,y = GUI.GetMousePosition();
        GUI.SendScriptCommand([[
            local CurrentPage = BundleBriefingSystem.Global.CurrentPage;
            if CurrentPage and CurrentPage.LeftClickOnScreen then
                BundleBriefingSystem.Global.CurrentPage:LeftClickOnScreen(]] ..tostring(x).. [[, ]] ..tostring(y).. [[)
            end
        ]]);
    end
end

---
-- Reagiert auf Klick auf den Skip-Button während des Throneroom Mode.
--
-- Wenn eine Cutscene aktiv ist, wird die überschriebene Methode aus dem
-- Addon benutzt.
--
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:NextButtonPressed()
    if self.Data.DisplayIngameCutscene then
        if AddOnCutsceneSystem then
            AddOnCutsceneSystem.Local:NextButtonPressed();
        end
    else
        if (self.Data.LastSkipButtonPressed + 500) < Logic.GetTimeMs() then
            self.Data.LastSkipButtonPressed = Logic.GetTimeMs();
            if not self.Data.CurrentPage.NoHistory then
                table.insert(self.Data.CurrentBriefing.PageHistory, self.Data.CurrentBriefing.Page);
            end
            if self.Data.CurrentPage.OnForward then
                GUI.SendScriptCommand("BundleBriefingSystem.Global.CurrentPage:OnForward()");
            end
            GUI.SendScriptCommand("BundleBriefingSystem.Global:PageFinished()");
        end
    end
end

---
-- Reagiert auch Klick auf den Back-Button während des Throneroom Mode.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:PrevButtonPressed()
    if not self.Data.DisplayIngameCutscene then
        if (self.Data.LastSkipButtonPressed + 500) < Logic.GetTimeMs() then
            self.Data.LastSkipButtonPressed = Logic.GetTimeMs();

            local LastPageID = table.remove(BundleBriefingSystem.Local.Data.CurrentBriefing.PageHistory);
            if not LastPageID then
                return;
            end
            local LastPage = BundleBriefingSystem.Local.Data.CurrentBriefing[LastPageID];
            if type(LastPage) == "number" then
                LastPageID = table.remove(BundleBriefingSystem.Local.Data.CurrentBriefing.PageHistory);
                LastPage = BundleBriefingSystem.Local.Data.CurrentBriefing[LastPageID];
            end
            if not LastPageID or LastPageID < 1 or not LastPage then
                return;
            end

            if self.Data.CurrentPage.OnReturn then
                GUI.SendScriptCommand("BundleBriefingSystem.Global.CurrentPage:OnReturn()");
            end
            BundleBriefingSystem.Local.Data.CurrentBriefing.Page = LastPageID -1;
            GUI.SendScriptCommand([[
                BundleBriefingSystem.Global.Data.CurrentBriefing.Page = ]] ..(LastPageID -1).. [[
                BundleBriefingSystem.Global:PageFinished()
            ]]);
        end
    end
end

---
-- Setzt den Stil der Briefing-Bars.
-- @param[type=number] _Opacity Opacity der Bars
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:SetBarStyle(_Opacity, _BigBars)
    local OpacityBig = (255 * _Opacity);
    local OpacitySmall = (255 * _Opacity);
    if _BigBars then
        OpacitySmall = 0;
    end
    
    local BigVisibility = (_BigBars and 1 or 0);
    local SmallVisibility = (_BigBars and 0 or 1);
    if _Opacity == 0 then
        BigVisibility = 0;
        SmallVisibility = 0;
    end

    XGUIEng.ShowWidget("/InGame/ThroneRoomBars", BigVisibility);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", SmallVisibility);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", BigVisibility);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", SmallVisibility);

    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarBottom", 1, OpacityBig);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarTop", 1, OpacityBig);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarBottom", 1, OpacitySmall);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarTop", 1, OpacitySmall);
end

---
-- Setzt die Fader-Optionen der aktuellen Seite.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:SetFader()
    -- Alpha der Fader-Maske
    g_Fade.To = self.Data.CurrentPage.FaderAlpha or 0;

    -- Fadein starten
    local PageFadeIn = self.Data.CurrentPage.FadeIn;
    if PageFadeIn then
        FadeIn(PageFadeIn);
    end

    -- Fadeout starten
    local PageFadeOut = self.Data.CurrentPage.FadeOut;
    if PageFadeOut then
        self.Data.CurrentBriefing.FaderJob = StartSimpleHiResJobEx(function(_Time, _FadeOut)
            if Logic.GetTimeMs() > _Time - (_FadeOut * 1000) then
                FadeOut(_FadeOut);
                return true;
            end
        end, Logic.GetTimeMs() + ((self.Data.CurrentPage.Duration or 0) * 1000), PageFadeOut);
    end
end

---
-- Aktiviert den Auswahldialog einer Multiple-Choice-Seite.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:SetOptionsDialog()
    if self.Data.CurrentPage.MC then
        local Screen = {GUI.GetScreenSize()};
        local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";

        self.Data.OriginalBoxPosition = {
            XGUIEng.GetWidgetScreenPosition(Widget)
        };

        local Listbox = XGUIEng.GetWidgetID(Widget .. "/ListBox");
        XGUIEng.ListBoxPopAll(Listbox);
        self.Data.CurrentPage.MC.Map = {};
        for i=1, #self.Data.CurrentPage.MC, 1 do
            if self.Data.CurrentPage.MC[i].Invisible ~= true then
                XGUIEng.ListBoxPushItem(Listbox, self.Data.CurrentPage.MC[i][1]);
                table.insert(self.Data.CurrentPage.MC.Map, self.Data.CurrentPage.MC[i].ID);
            end
        end
        XGUIEng.ListBoxSetSelectedIndex(Listbox, 0);

        local wSize = {XGUIEng.GetWidgetScreenSize(Widget)};
        local xFactor = (Screen[1]/1920);
        local xFix = math.ceil((Screen[1] /2) - (wSize[1] /2));
        local yFix = math.ceil(Screen[2] - (wSize[2] -10));
        if self.Data.CurrentPage.Text and self.Data.CurrentPage.Text ~= "" then
            yFix = math.ceil((Screen[2] /2) - (wSize[2] /2));
        end
        XGUIEng.SetWidgetScreenPosition(Widget, xFix, yFix);
        XGUIEng.PushPage(Widget, false);
        XGUIEng.ShowWidget(Widget, 1);

        self.Data.MCSelectionIsShown = true;
    end
end

---
-- Setzt das Portrait der aktuellen Seite.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:SetPortrait()
    if self.Data.CurrentPage.Portrait then
        XGUIEng.SetMaterialAlpha("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 1, 255);
        XGUIEng.SetMaterialTexture("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 1, self.Data.CurrentPage.Portrait);
        XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 0, 0, 400, 600);
        XGUIEng.SetMaterialUV("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 1, 0, 0, 1, 1);
    else
        XGUIEng.SetMaterialAlpha("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 1, 0);
    end
end

---
-- Setzt den Splashscreen der aktuellen Seite.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:SetSplashscreen()
    local SSW = "/InGame/ThroneRoom/KnightInfo/BG";
    if self.Data.CurrentPage.Splashscreen then
        local size = {GUI.GetScreenSize()};
        local u0, v0, u1, v1 = 0, 0, 1, 1;
        -- Folgende Annahmen werden gemacht:
        -- * Alle Bildverhältnisse >= 1.6 sind 16:9
        -- * Alle Bildverhältnisse < 1.6 sind 4:3
        -- * 5:4 wird behandelt wie 4:3
        -- * 16:10 wird behandelt wie 4:3
        -- Spieler mit anderen Bildverhältnissen haben Pech!
        if size[1]/size[2] < 1.6 then
            u0 = 0.125;
            u1 = u1 - (u1 * 0.125);
        end
        local Image = self.Data.CurrentPage.Splashscreen;
        if type(Image) == "table" then
            Image = self.Data.CurrentPage.Splashscreen.Image;
        end
        XGUIEng.SetMaterialAlpha(SSW, 0, 255);
        XGUIEng.SetMaterialTexture(SSW, 0, Image);
        XGUIEng.SetMaterialUV(SSW, 0, u0, v0, u1, v1);
    else
        XGUIEng.SetMaterialAlpha(SSW, 0, 0);
    end
end

---
-- Wendet die Animation auf den Splashscreen der aktuellen Seite an.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:ScrollSplashscreen()
    local SSW = "/InGame/ThroneRoom/KnightInfo/BG";
    if type(self.Data.CurrentPage.Splashscreen) == "table" then
        local SSData = self.Data.CurrentPage.Splashscreen;
        if (not SSData.Animation[1] or #SSData.Animation[1] ~= 4) or (not SSData.Animation[2] or #SSData.Animation[2] ~= 4) then
            return;
        end

        local size   = {GUI.GetScreenSize()};
        local factor = self:GetSplashscreenLERP();

        local u0 = SSData.Animation[1][1] + (SSData.Animation[2][1] - SSData.Animation[1][1]) * factor;
        local u1 = SSData.Animation[1][3] + (SSData.Animation[2][3] - SSData.Animation[1][3]) * factor;
        local v0 = SSData.Animation[1][2] + (SSData.Animation[2][2] - SSData.Animation[1][2]) * factor;
        local v1 = SSData.Animation[1][4] + (SSData.Animation[2][4] - SSData.Animation[1][4]) * factor;
        -- Folgende Annahmen werden gemacht:
        -- * Alle Bildverhältnisse >= 1.6 sind 16:9
        -- * Alle Bildverhältnisse < 1.6 sind 4:3
        -- * 5:4 wird behandelt wie 4:3
        -- * 16:10 wird behandelt wie 16:9
        -- Spieler mit anderen Bildverhältnissen haben Pech!
        if size[1]/size[2] < 1.6 then
            u0 = u0 + 0.125;
            u1 = u1 - (u1 * 0.125);
        end
        XGUIEng.SetMaterialUV(SSW, 0, u0, v0, u1, v1);
    end
end

---
-- Gibt die lineare Interpolation des Splashscreens zurück.
-- @param[type=number] LERP
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:GetSplashscreenLERP()
    local Factor = 1.0;
    if type(self.Data.CurrentPage.Splashscreen) == "table" then
        local Current = Logic.GetTime();
        local Started = self.Data.CurrentPage.Started;
        local FlyTime = self.Data.CurrentPage.Splashscreen.Animation[3];
        Factor = (Current - Started) / FlyTime;
        Factor = (Factor > 1 and 1) or Factor;
    end
    return Factor;
end

---
-- Aktiviert den Cinematic Mode.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:ActivateCinematicMode()
    self.Data.CinematicActive = true;
    
    local LoadScreenVisible = API.IsLoadscreenVisible();
    if LoadScreenVisible then
        XGUIEng.PopPage();
    end
    local ScreenX, ScreenY = GUI.GetScreenSize();

    Core:InterfaceDeactivateNormalInterface();
    Core:InterfaceDeactivateBlackBackground();

    XGUIEng.ShowWidget("/InGame/ThroneRoom", 1);
    XGUIEng.PushPage("/InGame/ThroneRoom/KnightInfo", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2", false);
    XGUIEng.PushPage("/InGame/ThroneRoom/Main", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_Dodge", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2_Dodge", false);
    XGUIEng.PushPage("/InGame/ThroneRoom/KnightInfo/LeftFrame", false);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/StartButton", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/Frame", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/DialogBG", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/FrameEdges", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogBottomRight3pcs", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/KnightInfoButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/BackButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Briefing", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/TitleContainer", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Text", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Title", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", 1);

    -- Text
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Title", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", " ");

    -- Title and back button
    local x,y = XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight");
    XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", x, 65 * (ScreenY/1080));
    local x,y = XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/Skip");
    XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/StartButton", 20, y);
    XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/Objectives", 2, 0, 2000, 20);

    -- Briefing messages
    XGUIEng.ShowAllSubWidgets("/InGame/ThroneRoom/KnightInfo", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/Text", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/BG", 1);
    XGUIEng.SetText("/InGame/ThroneRoom/KnightInfo/Text", " ");
    XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/Text", 200, 300, 1000, 10);

    -- Splashscreen
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/BG", 1);
    XGUIEng.SetMaterialColor("/InGame/ThroneRoom/KnightInfo/BG", 0, 255, 255, 255, 0);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoom/KnightInfo/BG", 0, 0);
    
    -- Portrait
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/LeftFrame", 1);
    XGUIEng.ShowAllSubWidgets("/InGame/ThroneRoom/KnightInfo/LeftFrame", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 1);
    XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 0, 0, 400, 600);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoom/KnightInfo/LeftFrame/KnightBG", 0, 0);

    GUI.ClearSelection();
    GUI.ClearNotes();
    GUI.ForbidContextSensitiveCommandsInSelectionState();
    GUI.ActivateCutSceneState();
    GUI.SetFeedbackSoundOutputState(0);
    GUI.EnableBattleSignals(false);
    Input.CutsceneMode();
    Display.SetRenderFogOfWar(0);
    Display.SetUserOptionOcclusionEffect(0);
    Camera.SwitchCameraBehaviour(5);

    InitializeFader();
    g_Fade.To = 0;
    SetFaderAlpha(0);

    if LoadScreenVisible then
        XGUIEng.PushPage("/LoadScreen/LoadScreen", false);
    end
end

---
-- Deaktiviert den Cinematic Mode.
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:DeactivateCinematicMode()
    self.Data.CinematicActive = false;

    g_Fade.To = 0;
    SetFaderAlpha(0);
    XGUIEng.PopPage();
    Camera.SwitchCameraBehaviour(0);
    Display.UseStandardSettings();
    Input.GameMode();
    GUI.EnableBattleSignals(true);
    GUI.SetFeedbackSoundOutputState(1);
    GUI.ActivateSelectionState();
    GUI.PermitContextSensitiveCommandsInSelectionState();
    Display.SetRenderFogOfWar(1);
    if Options.GetIntValue("Display", "Occlusion", 0) > 0 then
        Display.SetUserOptionOcclusionEffect(1);
    end

    XGUIEng.PopPage();
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

    Core:InterfaceActivateNormalInterface();
    Core:InterfaceDeactivateBlackBackground();
end

---
-- Überschreibt die Throneroom-Funktionen.
--
-- Überschriebene Funktionen:
-- <ul>
-- <li>ThroneRoomCameraControl - Steuerung der Throneroom-Kamera</li>
-- <li>ThroneRoomLeftClick - Es wird mit der Maus irgend wo hin geklickt</li>
-- <li>OnSkipButtonPressed - Überspringen wird geklickt</li>
-- </ul>
--
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:OverrideThroneRoomFunctions()
    ThroneRoomCameraControl = function()
        if BundleBriefingSystem then
            if BundleBriefingSystem.Local.Data.DisplayIngameCutscene then
                if AddOnCutsceneSystem then
                    AddOnCutsceneSystem.Local:ThroneRoomCameraControl();
                end
            else
                BundleBriefingSystem.Local:ThroneRoomCameraControl();
            end
        end
    end

    ThroneRoomLeftClick = function()
        if BundleBriefingSystem then
            if BundleBriefingSystem.Local.Data.DisplayIngameCutscene then
                if AddOnCutsceneSystem then
                    AddOnCutsceneSystem.Local:ThroneRoomLeftClick();
                end
            else
                BundleBriefingSystem.Local:ThroneRoomLeftClick();
            end
        end
    end

    OnSkipButtonPressed = function()
        if BundleBriefingSystem then
            if BundleBriefingSystem.Local.Data.DisplayIngameCutscene then
                if AddOnCutsceneSystem then
                    AddOnCutsceneSystem.Local:NextButtonPressed();
                end
            else
                BundleBriefingSystem.Local:NextButtonPressed();
            end
        end
    end

    OnStartButtonPressed = function()
        if BundleBriefingSystem then
            BundleBriefingSystem.Local:PrevButtonPressed();
        end
    end

    OnBackButtonPressed = function()
        if BundleBriefingSystem then
            BundleBriefingSystem.Local:PrevButtonPressed();
        end
    end

    BundleBriefingSystem.Local.GameCallback_Escape = GameCallback_Escape;
    GameCallback_Escape = function()
        if not BundleBriefingSystem.Local:IsBriefingActive() then
            BundleBriefingSystem.Local.GameCallback_Escape();
        end
    end
end

-- Shared ------------------------------------------------------------------- --

---
-- Errechnet eine Position relativ im angegebenen Winkel und Position zur
-- Basisposition. Die Basis kann ein Entity oder eine Positionstabelle sein.
--
-- @param               _target          Basisposition (Skriptname, ID oder Position)
-- @param[type=number]  _distance        Entfernung
-- @param[type=number]  _angle           Winkel
-- @param[type=boolean] _buildingRealPos Gebäudemitte statt Gebäudeeingang
-- @return[type=table] Position
-- @within Internal
-- @local
--
function BundleBriefingSystem:GetRelativePos(_target,_distance,_angle,_buildingRealPos)
    if not type(_target) == "table" and not IsExisting(_target)then
        return
    end
    if _angle == nil then
        _angle = 0;
    end

    local pos1;
    if type(_target) == "table" then
        local pos = _target;
        local ori = 0+_angle;
        pos1 = { X= pos.X+_distance * math.cos(math.rad(ori)),
                 Y= pos.Y+_distance * math.sin(math.rad(ori))};
    else
        local eID = GetID(_target);
        local pos = GetPosition(eID);
        local ori = Logic.GetEntityOrientation(eID)+_angle;
        if Logic.IsBuilding(eID) == 1 and not _buildingRealPos then
            x, y = Logic.GetBuildingApproachPosition(eID);
            pos = {X= x, Y= y};
            ori = ori -90;
        end
        pos1 = { X= pos.X+_distance * math.cos(math.rad(ori)),
                 Y= pos.Y+_distance * math.sin(math.rad(ori))};
    end
    return pos1;
end

-- Behavior ----------------------------------------------------------------- --

---
-- Ruft die Lua-Funktion mit dem angegebenen Namen auf und spielt das Briefing
-- in ihr ab. Die Funktion muss eine Briefing-ID zurückgeben.
--
-- Das Brieifng wird an den Quest gebunden und kann mit Trigger_Briefing
-- überwacht werden. Es kann pro Quest nur ein Niederlage-Briefing 
-- gebunden werden!
--
-- @param[type=string] _Briefing Funktionsname als String
-- @within Reprisal
--
function Reprisal_Briefing(...)
    return b_Reprisal_Briefing:new(...);
end

b_Reprisal_Briefing = {
    Name = "Reprisal_Briefing",
    Description = {
        en = "Reward: Calls a function that creates a briefing and saves the returned briefing ID into the quest.",
        de = "Lohn: Ruft eine Funktion auf, die ein Briefing erzeugt und die zurueckgegebene ID in der Quest speichert.",
    },
    Parameter = {
        { ParameterType.Default, en = "Briefing function", de = "Funktion mit Briefing" },
    },
}

function b_Reprisal_Briefing:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_Briefing:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Function = _Parameter;
    end
end

function b_Reprisal_Briefing:CustomFunction(_Quest)
    info(_Quest.Identifier..": "..self.Name..": Try starting briefing '" ..self.Function.. "'");
    local BriefingID = _G[self.Function](self, _Quest);
    if BriefingID < 1 then
        error(_Quest.Identifier..": "..self.Name..": Briefing '" ..self.Function.. "' was not started!");
        return;
    end
    local QuestID = GetQuestID(_Quest.Identifier);
    if QuestID == nil then
        warn("Briefing '" ..self.Function.. "' wasn't attached to a quest!");
    end
    Quests[QuestID].zl97d_ukfs5_0dpm0 = BriefingID;
    info(_Quest.Identifier..": "..self.Name..": Briefing '" ..self.Function.. "' started");
end

function b_Reprisal_Briefing:Debug(_Quest)
    if not type(_G[self.Function]) == "function" then
        error(_Quest.Identifier..": "..self.Name..": '"..self.Function.."' was not found!", LEVEL_ERROR);
        return true;
    end
    return false;
end

function b_Reprisal_Briefing:Reset(_Quest)
    local QuestID = GetQuestID(_Quest.Identifier);
    Quests[QuestID].zl97d_ukfs5_0dpm0 = nil;
end

Core:RegisterBehavior(b_Reprisal_Briefing);

-- -------------------------------------------------------------------------- --

---
-- Ruft die Lua-Funktion mit dem angegebenen Namen auf und spielt das Briefing
-- in ihr ab. Die Funktion muss eine Briefing-ID zurückgeben.
--
-- Das Brieifng wird an den Quest gebunden und kann mit Trigger_Briefing
-- überwacht werden. Es kann pro Quest nur ein Erfolgs-Briefing gebunden werden!
--
-- @param[type=string] _Briefing Funktionsname als String
-- @within Reward
--
function Reward_Briefing(...)
    return b_Reward_Briefing:new(...);
end

b_Reward_Briefing = API.InstanceTable(b_Reprisal_Briefing);
b_Reward_Briefing.Name = "Reward_Briefing";
b_Reward_Briefing.Description.en = "Reward: Calls a function that creates a briefing and saves the returned briefing ID into the quest.";
b_Reward_Briefing.Description.de = "Lohn: Ruft eine Funktion auf, die ein Briefing erzeugt und die zurueckgegebene ID in der Quest speichert.";
b_Reward_Briefing.GetReprisalTable = nil;

b_Reward_Briefing.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

b_Reward_Briefing.CustomFunction = function(self, _Quest)
    local BriefingID = _G[self.Function](self, _Quest);
    local QuestID = GetQuestID(_Quest.Identifier);
    Quests[QuestID].w5kur_xig0q_d9k7e = BriefingID;
end

b_Reward_Briefing.Reset = function(self, _Quest)
    local QuestID = GetQuestID(_Quest.Identifier);
    Quests[QuestID].w5kur_xig0q_d9k7e = nil;
end

Core:RegisterBehavior(b_Reward_Briefing);

-- -------------------------------------------------------------------------- --

---
-- Startet einen Quest, nachdem das Briefing eines Quests gestartet und
-- durchlaufen wurde.
--
-- Der Trigger wird sowohl Erfolgs- als auch Niederlage-Briefings prüfen.
-- Über den Typ-Parameter kann auf eine spezielle Art eingeschränt werden.
-- Mit diesem Trigger ist es u.a. möglich zu verzweigen, wenn man z.B. nach
-- einem Misserfolg eine Niederlage im nächsten Quest auslösen will und bei
-- Erfolg stattdessen die Mission gewonnen werden soll.
--
-- Mögliche Angaben für Briefing-Typen:
-- <ul>
-- <li><b>"All"</b>: Erfolg und Niederlage</li>
-- <li><b>"Failure"</b>: Nur Niederlage</li>
-- <li><b>"Success"</b>: Nur Erfolg</li>
-- </ul>
--
-- @param[type=string] _QuestName Name des Quest
-- @param[type=string] _Type     (Optional) Briefing-Typ
-- @param[type=number] _Waittime (optional) Wartezeit in Sekunden
-- @within Trigger
--
function Trigger_Briefing(...)
    return b_Trigger_Briefing:new(...);
end

b_Trigger_Briefing = {
    Name = "Trigger_Briefing",
    Description = {
        en = "Trigger: After a briefing of the given quest has finished, this quest will be started. Additionally you can choose the type of briefing this trigger shall react to.",
        de = "Ausloeser: Wenn ein Briefing des angegebenen Quest beendet ist, wird dieser Quest gestartet. Optional kann gewählt werden, auf welchen Typ von Briefing reagiert werden soll.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name",    de = "Questname" },
        { ParameterType.Custom,    en = "Briefing type", de = "Briefing-Typ" },
        { ParameterType.Number,    en = "Wait time",     de = "Wartezeit" },
    },
}

function b_Trigger_Briefing:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_Briefing:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Quest = _Parameter;
    elseif (_Index == 1) then
        _Paramater = _Parameter or "All";
        self.BriefingType = _Parameter;
    elseif (_Index == 2) then
        _Parameter = _Parameter or 0;
        self.WaitTime = _Parameter * 1;
    end
end

function b_Trigger_Briefing:GetCustomData( _Index )
    if _Index == 1 then
        return {"All", "Success", "Failure"};
    end
end

function b_Trigger_Briefing:IsConditionFulfilled(_QuestID)
    if self.BriefingType == nil or self.BriefingType == "All" then
        return IsBriefingFinished(Quests[_QuestID].zl97d_ukfs5_0dpm0) or IsBriefingFinished(Quests[_QuestID].w5kur_xig0q_d9k7e);
    elseif self.BriefingType == "Failure" then
        return IsBriefingFinished(Quests[_QuestID].zl97d_ukfs5_0dpm0);
    elseif self.BriefingType == "Success" then
        return IsBriefingFinished(Quests[_QuestID].w5kur_xig0q_d9k7e);
    end
    return false;
end

function b_Trigger_Briefing:CustomFunction(_Quest)
    local QuestID = GetQuestID(self.Quest);
    if self:IsConditionFulfilled(QuestID) then
        if self.WaitTime and self.WaitTime > 0 then
            self.WaitTimeTimer = self.WaitTimeTimer or Logic.GetTime();
            if Logic.GetTime() >= self.WaitTimeTimer + self.WaitTime then
                return true;
            end
        else
            return true;
        end
    end
    return false;
end

function b_Trigger_Briefing:Interrupt(_Quest)
    local QuestID = GetQuestID(self.Quest);
    Quests[QuestID].w5kur_xig0q_d9k7e = nil;
    Quests[QuestID].zl97d_ukfs5_0dpm0 = nil;
    self.WaitTimeTimer = nil
end

function b_Trigger_Briefing:Reset(_Quest)
    self:Interrupt(_Quest);
end

function b_Trigger_Briefing:Debug(_Quest)
    if self.WaitTime and self.WaitTime < 0 then
        error(_Quest.Identifier.." "..self.Name..": waittime is below 0!", LEVEL_ERROR);
        return true;
    elseif not IsValidQuest(self.Quest) then
        error(_Quest.Identifier.." "..self.Name..": '"..self.Quest.."' is not a valid quest!", LEVEL_ERROR);
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_Briefing);

-- -------------------------------------------------------------------------- --

---
-- Startet einen Quest, nachdem das Mission Briefing beendet ist
--
-- @within Trigger
-- @see StartMissionBriefing
--
function Trigger_MissionBriefing(...)
    return b_Trigger_MissionBriefing:new(...);
end

b_Trigger_MissionBriefing = {
    Name = "Trigger_MissionBriefing",
    Description = {
        en = "Trigger: After the briefing started with StartMissionBriefing finishes, this trigger will start the quest.",
        de = "Ausloeser: Wenn das Briefing, gestartet mit StartMissionBriefing, beendet ist, wird der Quest gestartet.",
    },
}

function b_Trigger_MissionBriefing:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_MissionBriefing:CustomFunction(_Quest)
    if BundleBriefingSystem.Global.Data.MissionStartBriefingID > 0 then
        if IsBriefingFinished(BundleBriefingSystem.Global.Data.MissionStartBriefingID) then
            return true;
        end
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_MissionBriefing);

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleBriefingSystem");

