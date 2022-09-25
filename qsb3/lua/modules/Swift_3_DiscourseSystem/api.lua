--[[
Swift_3_DiscourseSystem/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht es Discourse zu verwenden.
--
-- Discourses dienen zur Darstellung von Dialogen oder zur näheren Erleuterung
-- der aktuellen Spielsituation. Mit Multiple Choice können dem Spieler mehrere
-- Auswahlmöglichkeiten gegeben, multiple Handlungsstränge gestartet
-- oder Menüstrukturen abgebildet werden. Mittels Sprüngen und Leerseiten
-- kann innerhalb des Multiple Choice Discourses navigiert werden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_DisplayCore.api.html">(1) Display Core</a></li>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field DiscourseStarted           Ein Discourse beginnt (Parameter: PlayerID, DiscourseTable)
-- @field DiscourseEnded             Ein Discourse endet (Parameter: PlayerID, DiscourseTable)
-- @field DiscoursePageShown         Ein Discourse endet (Parameter: PlayerID, PageIndex)
-- @field DiscourseSkipButtonPressed Der Spieler überspringt eine Seite (Parameter: PlayerID)
-- @field DiscourseOptionSelected    Eine Multiple Choice Option wurde ausgewählt (Parameter: PlayerID, OptionID)
-- @field DiscourseLeftClick         Left Mouse wurde während des Discourses gedrückt (Parameter: PlayerID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- 
--
function API.StartDiscourse(_Discourse, _Name, _PlayerID)
    if GUI then
        return;
    end
    local PlayerID = _PlayerID;
    if not PlayerID and not Framework.IsNetworkGame() then
        PlayerID = QSB.HumanPlayerID;
    end
    assert(_Name ~= nil);
    assert(_PlayerID ~= nil);
    if type(_Discourse) ~= "table" then
        error("API.StartDiscourse (" .._Name.. "): _Discourse must be a table!");
        return;
    end
    if #_Discourse == 0 then
        error("API.StartDiscourse (" .._Name.. "): _Discourse does not contain pages!");
        return;
    end
    for i=1, #_Discourse do
        if type(_Discourse[i]) == "table" and not _Discourse[i].__Legit then
            error("API.StartDiscourse (" .._Name.. ", Page #" ..i.. "): Page is not initialized!");
            return;
        end
    end
    if _Discourse.EnableSky == nil then
        _Discourse.EnableSky = true;
    end
    if _Discourse.EnableFoW == nil then
        _Discourse.EnableFoW = false;
    end
    if _Discourse.EnableGlobalImmortality == nil then
        _Discourse.EnableGlobalImmortality = true;
    end
    if _Discourse.EnableBorderPins == nil then
        _Discourse.EnableBorderPins = false;
    end
    ModuleDiscourseSystem.Global:StartDiscourse(_Name, PlayerID, _Discourse);
end

---
-- Prüft ob für den Spieler gerade ein Dialog aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=boolean] Dialog ist aktiv
-- @within Anwenderfunktionen
--
function API.IsDiscourseActive(_PlayerID)
    if Swift:IsGlobalEnvironment() then
        return ModuleDiscourseSystem.Global:GetCurrentDiscourse(_PlayerID) ~= nil;
    end
    return ModuleDiscourseSystem.Local:GetCurrentDiscourse(_PlayerID) ~= nil;
end

---
-- 
--
function API.AddDiscoursePages(_Discourse)
    _Discourse.GetPage = function(self, _NameOrID)
        local ID = ModuleDiscourseSystem.Global:GetPageIDByName(_Discourse.PlayerID, _NameOrID);
        return ModuleDiscourseSystem.Global.Discourse[_Discourse.PlayerID][ID];
    end

    local AP = function(_Page)
        _Discourse.PageAnimations = _Discourse.PageAnimations or {};

        _Discourse.Length = (_Discourse.Length or 0) +1;
        if type(_Page) == "table" then
            local Identifier = "Page" ..(#_Discourse +1);
            if _Page.Name then
                Identifier = _Page.Name;
            else
                _Page.Name = Identifier;
            end

            _Page.__Legit = true;
            _Page.GetSelected = function(self)
                if self.MC then
                    return self.MC.Selected;
                end
                return 0;
            end

            -- Default camera position
            assert(_Page.Camera ~= nil);
            if not _Page.Camera.Angle then
                _Page.Camera.Angle = QSB.Discourse.CAMERA_ANGLEDEFAULT;
                if _Page.Camera.Dialog then
                    _Page.Camera.Angle = QSB.Discourse.DLGCAMERA_ANGLEDEFAULT;
                end
            end
            if not _Page.Camera.Rotation then
                _Page.Camera.Rotation = QSB.Discourse.CAMERA_ROTATIONDEFAULT;
                if _Page.Camera.Dialog then
                    _Page.Camera.Rotation = QSB.Discourse.DLGCAMERA_ROTATIONDEFAULT;
                end
            end
            if not _Page.Camera.Distance then
                _Page.Camera.Distance = QSB.Discourse.CAMERA_ZOOMDEFAULT;
                if _Page.Camera.Dialog then
                    _Page.Camera.Distance = QSB.Discourse.DLGCAMERA_ZOOMDEFAULT;
                end
            end

            -- Language
            _Page.Title = API.Localize(_Page.Title or "");
            _Page.Text = API.Localize(_Page.Text or "");

            -- Skip page
            if _Page.Duration then
                if _Page.DisableSkipping == nil then
                    _Page.DisableSkipping = true;
                end
                _Page.Duration = string.len(_Page.Text or "") * QSB.Discourse.TIMER_PER_CHAR;
                if _Page.Duration < 6 then
                    _Page.Duration = 6;
                end
            else
                _Page.DisableSkipping = false;
            end

            -- Bars
            if _Page.BigBars == nil then
                _Page.BigBars = true;
            end

            -- Multiple Choice
            if _Page.MC then
                for i= 1, #_Page.MC do
                    _Page.MC[i][1] = API.Localize(_Page.MC[i][1]);
                    _Page.MC[i].ID = _Page.MC[i].ID or i;
                end
                _Page.BigBars = true;
                _Page.DisableSkipping = true;
                _Page.Duration = -1;
            end
        else
            _Page = (_Page == nil and -1) or _Page;
        end
        table.insert(_Discourse, _Page);
        return _Page;
    end

    local ASP = function(...)
        -- TODO
    end
    return AP, ASP;
end

---
-- Erzeugt eine neue Seite für das Discourse.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddDiscoursePages">API.AddDiscoursePages</a> erzeugt und an
-- das Discourse gebunden.
--
-- <h5>Discourse Page</h5>
-- Eine Dialog Page ist eine einfache Seite. Sie kann für die Darstellung von
-- Dialogen zwischen Spielfiguren benutzt werden.
--
-- Folgende Parameter werden als Felder (Name = Wert) übergeben:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>string|table</td>
-- <td>Der Titel, der oben angezeigt wird. Es ist möglich eine Table mit
-- deutschen und englischen Texten anzugeben.</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string|table</td>
-- <td>Der Text, der unten angezeigt wird. Es ist möglich eine Table mit
-- deutschen und englischen Texten anzugeben.</td>
-- </tr>
-- <tr>
-- <td>Position</td>
-- <td>string</td>
-- <td>Striptname des Entity, welches die Kamera ansieht.</td>
-- </tr>
-- <tr>
-- <td>Duration</td>
-- <td>number</td>
-- <td>(Optional) Bestimmt, wie lange die Page angezeigt wird. Wird es
-- weggelassen, wird automatisch eine Anzeigezeit anhand der Textlänge bestimmt.
-- Diese ist immer mindestens 6 Sekunden.</td>
-- </tr>
-- <tr>
-- <td>DialogCamera</td>
-- <td>boolean</td>
-- <td>(Optional) Eine Boolean, welche angibt, ob Nah- oder Fernsicht benutzt
-- wird.</td>
-- </tr>
-- <tr>
-- <td>DisableSkipping</td>
-- <td>boolean</td>
-- <td>(Optional) Das Überspringen der Seite wird unterbunden.</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die jedes Mal ausgeführt wird, sobald
-- die Seite angezeigt wird.</td>
-- </tr>
-- <tr>
-- <td>Rotation</td>
-- <td>number</td>
-- <td>(Optional) Die Rotation der Kamera gibt den Winkel an, indem die Kamera
-- um das Ziel gedreht wird.</td>
-- </tr>
-- <tr>
-- <td>Zoom</td>
-- <td>number</td>
-- <td>(Optional) Zoom bestimmt die Entfernung der Kamera zum Ziel.</td>
-- </tr>
-- <tr>
-- <td>Angle</td>
-- <td>number</td>
-- <td>(Optional) Der Angle gibt den Winkel an, in dem die Kamera gekippt wird.
-- </td>
-- </tr>
-- <tr>
-- <td>FadeIn</td>
-- <td>number</td>
-- <td>(Optional) Dauer des Einblendens von Schwarz zu Beginn des Flight.</td>
-- </tr>
-- <tr>
-- <td>FadeOut</td>
-- <td>number</td>
-- <td>(Optional) Dauer des Abblendens zu Schwarz am Ende des Flight.</td>
-- </tr>
-- <tr>
-- <td>FaderAlpha</td>
-- <td>number</td>
-- <td>(Optional) Zeigt entweder die Blende an (1) oder nicht (0). Per Default
-- wird die Blende nicht angezeigt. <br><b>Zwischen einer Seite mit FadeOut und
-- der nächsten mit Fade In muss immer eine Seite mit FaderAlpha sein!</b></td>
-- </tr>
-- <tr>
-- <td>BarOpacity</td>
-- <td>number</td>
-- <td>(Optional) Setzt den Alphawert der Bars (Zwischen 0 und 1).</td>
-- </tr>
-- <tr>
-- <td>BigBars</td>
-- <td>boolean</td>
-- <td>(Optional) Schalted breite Balken ein oder aus.</td>
-- </tr>
-- <tr>
-- <td>MC</td>
-- <td>table</td>
-- <td>(Optional) Liste von Optionen zur Verzweigung des Discourses. Dies kann
-- benutzt werden, um z.B. Dialoge mit Antwortmöglichkeiten zu erstellen.</td>
-- </tr>
-- </table>
--
-- <br><h5>Multiple Choice</h5>
-- In einem Discourse kann der Spieler auch zur Auswahl einer Option gebeten
-- werden. Dies wird als Multiple Choice bezeichnet. Schreibe die Optionen
-- in eine Untertabelle MC.
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
-- nicht mehrfach gewählt werden kann. In diesem Fall ist sie bei erneutem
-- Aufsuchen der Seite nicht mehr gelistet.
-- <pre>{"Antwort 3", "AnotherPage", Remove = true},</pre>
-- Eine Option kann auch bedingt ausgeblendet werden. Dazu wird eine Funktion
-- angegeben, welche über die Sichtbarkeit entscheidet.
-- <pre>{"Antwort 3", "AnotherPage", Disable = OptionIsDisabled},</pre>
--
-- Nachdem der Spieler eine Antwort gewählt hat, wird er auf die Seite mit
-- dem angegebenen Namen geleitet.
--
-- Um das Discourse zu beenden, nachdem ein Pfad beendet ist, wird eine leere
-- AP-Seite genutzt. Auf diese Weise weiß das Discourse, das es an dieser
-- Stelle zuende ist.
-- <pre>AP()</pre>
--
-- Soll stattdessen zu einer anderen Seite gesprungen werden, kann bei AP der
-- Name der Seite angeben werden, zu der gesprungen werden soll.
-- <pre>AP("SomePageName")</pre>
--
-- Um später zu einem beliebigen Zeitpunkt die gewählte Antwort einer Seite zu
-- erfahren, muss der Name der Seite genutzt werden.
-- <pre>Discourse.Finished = function(_Data)
--    local Choosen = _Data:GetPage("Choice"):GetSelectedAnswer();
--end</pre>
-- Die zurückgegebene Zahl ist die ID der Antwort, angefangen von oben. Wird 0
-- zurückgegeben, wurde noch nicht geantwortet.
--
-- @param[type=table] _Data Daten der Seite
-- @return[type=table] Erzeugte Seite
-- @within Discourse
--
-- @usage
-- -- Eine einfache Seite
-- AP {
--    Title        = "Marcus",
--    Text         = "Das ist eine simple Seite.",
--    Position     = "Marcus",
--    Rotation     = 30,
--    DialogCamera = true,
--};
--
-- -- Eine Seite mit Optionen
-- -- Hier können Namen von Pages angegeben werden oder Aktionen, welche etwas
-- -- Ausführen und danach einen Namen zurückgeben.
-- AP {
--    Title        = "Marcus",
--    Text         = "Das ist eine simple Seite.",
--    Position     = "Marcus",
--    Rotation     = 30,
--    DialogCamera = true,
--    MC = {
--        {"Antwort 1", "Zielseite"},
--        {"Antwort 2", Option2Clicked},
--    },
--};
--
function AP(_Data)
    assert(false);
end

---
-- Erzeugt eine neue Seite für das Discourse in Kurzschreibweise.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddDiscoursePages">API.AddDiscoursePages</a> erzeugt und an
-- das Discourse gebunden.
--
-- Die Seite erhält automatisch einen Namen, entsprechend der Reihenfolge aller
-- Seitenaufrufe von AP oder ASP. Werden also vor dem Aufruf bereits 2 Seiten
-- erzeugt, so würde die Seite den Namen "Page3" erhalten.
--
-- Folgende Parameter werden in <u>genau dieser Reihenfolge</u> an die Funktion
-- übergeben:
-- <table border="1">
-- <tr>
-- <td><b>Bezeichnung</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Name</td>
-- <td>string</td>
-- <td>Der interne Name der Page.</td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>string|table</td>
-- <td>Der angezeigte Titel der Seite. Es können auch Text Keys oder
-- lokalisierte Tables übergeben werden.</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string|table</td>
-- <td>Der angezeigte Text der Seite. Es können auch Text Keys oder
-- lokalisierte Tables übergeben werden.</td>
-- </tr>
-- <tr>
-- <td>DialogCamera</td>
-- <td>boolean</td>
-- <td>(Optional) Die Kamera geht in Nahsicht und stellt Charaktere dar. Wird
-- sie weggelassen, wird die Fernsicht verwendet.</td>
-- </tr>
-- <tr>
-- <td>Position</td>
-- <td>string</td>
-- <td>(Optional) Skriptname des Entity zu das die Kamera springt.</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die jedes Mal ausgeführt wird, wenn die Seite
-- angezeigt wird.</td>
-- </tr>
-- <tr>
-- <td>EnableSkipping</td>
-- <td>boolean</td>
-- <td>(Optional) Steuert, ob die Seite übersprungen werden darf. Wenn es nicht
-- angegeben wird, ist das Überspringen immer deaktiviert.</td>
-- </tr>
-- </table>
--
-- @param ... Daten der Seite
-- @return[type=table] Erzeugte Seite
-- @within Discourse
--
-- @usage
-- -- Hinweis dazu: In Lua werden Parameter von links nach rechts aufgelöst.
-- -- Will man also Parameter weglassen, wenn danach noch welche folgen, muss
-- -- man die Leerstellen mit nil auffüllen.
--
-- -- Fernsicht
-- ASP("Title", "Some important text.", false, "HQ");
-- -- Page Name
-- ASP("Page1", "Title", "Some important text.", false, "HQ");
-- -- Nahsicht
-- ASP("Title", "Some important text.", true, "Marcus");
-- -- Aktion ausführen
-- ASP("Title", "Some important text.", true, "Marcus", MyFunction);
-- -- Überspringen erlauben/verbieten
-- ASP("Title", "Some important text.", true, "HQ", nil, true);
--
function ASP(...)
    assert(false);
end

---
-- Erzeugt eine neue Animation für eine Seite in Kurzschreibweise.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddDiscoursePages">API.AddDiscoursePages</a> erzeugt und an
-- das Discourse gebunden.
--
-- <b>Hinweis</b>: Diese Funktion erzeugt keine eigene Seite!
--
-- Animationen werden beim Aufruf der Seite in die Warteschlange geschoben und
-- ausgeführt, sobald keine anderen Animationen mehr laufen. Dadurch ist es nun
-- möglich, mehrere Seiten Text mit der gleichen Kamerabewegung anzuzeigen.
-- Laufende Animationen können auch bei Aufruf der Seite abgebrochen werden,
-- damit die neuen Animationen sofort beginnen.
--
-- Es gibt 5 Anwendungsfälle:
-- <ol>
-- <li><b>Kamerasprung (relativ)</b>:<br>Die Kamera springt zur angegebenen
-- Position. Koordinaten werden mittels Position, Rotation, Entfernung und
-- Kamerawinkel (in dieser Reihenfolge) angegeben.</li>
-- <li><b>Kameraanimation (relativ)</b>:<br>Die Kamera bewegt sich von einem
-- Punkt zum anderen. Beide Punkte werden mittels Position, Rotation, Entfernung
-- und Kamerawinkel (in dieser Reihenfolge) angegeben.<br>Danach muss die Dauer
-- der Animation in Sekunden angegeben werden.</li>
-- <li><b>Kamerasprung (Vektor)</b>:<br>Die Kamera springt zur angegebenen
-- Vektor. Dafür wird die Kameraposition und danach das Blickziels übergeben.
-- Für beide Punkte muss die Reihenfolge beachtet werden. Also X-, Y- und dann
-- Z-Koordinate.</li>
-- <li><b>Kameraanimation (Vektor)</b>:<br>Die Kamera bewegt sich von einem
-- Vektor zum anderen. Die Positionen werden genau wie bei 3. angegeben, nur
-- das es hier 4 Punkte statt nur 2 gibt.<br>Danach muss die Dauer der Animation
-- in Sekunden angegeben werden.</li>
-- <li><b>Animation abbrechen</b>:<br>Alle laufenden Animationen werden
-- abgebrochen sobald die Seite angezeigt wird. Danach werden die für die Seite
-- definierten Animationen ausgeführt.</li>
-- </ol>
--
-- @param _Identifier Name oder ID der Seite
-- @param ...         Daten der Animation
-- @within Discourse
--
-- @usage
-- -- statische Position (relativ)
-- -- AAN(_Identifier, _Position, _Rotation, _Zoom, _Angle)
-- AAN("Page1", "HQ1", -20, 7500, 38);
-- -- animierte Bewegung (relativ)
-- -- AAN(_Identifier, _Position1, _Rotation1, _Zoom1, _Angle1, _Position2, _Rotation2, _Zoom2, _Angle2, _Duration)
-- AAN("Page1", "HQ1", -20, 7500, 38, "Marcus", -40, 3500, 28, 30);
-- -- statische Position (Vektor)
-- -- AAN(_Identifier, _X1, _Y1, _Z1, _X2, _Y2, _Z2)
-- local x1, y1, z1 = Logic.EntityGetPos("CamPos1");
-- local x2, y2, z2 = Logic.EntityGetPos("HQ1");
-- AAN("Page1", x1, y1, z1, x2, y2, z2 + 3000);
-- -- animierte Bewegung (Vektor)
-- -- AAN(_Identifier, _X1, _Y1, _Z1, _X2, _Y2, _Z2, _X3, _Y3, _Z3, _X4, _Y4, _Z4, _Duration)
-- local x1, y1, z1 = Logic.EntityGetPos(GetID("CamPos1"));
-- local x2, y2, z2 = Logic.EntityGetPos(GetID("HQ1"));
-- local x3, y3, z3 = Logic.EntityGetPos(GetID("CamPos2"));
-- local x4, y4, z4 = Logic.EntityGetPos(GetID("Marcus"));
-- AAN("Page1", x1, y1, z1, x2, y2, z2 + 3000, x3, y3, z3, x4, y4, z4 + 2000, 30);
-- -- laufende Animationen abbrechen
-- AAN("Page1", true);
--
function AAN(...)
    assert(false);
end

