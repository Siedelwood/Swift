--[[
Swift_3_BriefingSystem/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht es Briefing zu verwenden.
--
-- Briefings dienen zur Darstellung von Dialogen oder zur näheren Erleuterung
-- der aktuellen Spielsituation. Mit Multiple Choice können dem Spieler mehrere
-- Auswahlmöglichkeiten gegeben, multiple Handlungsstränge gestartet
-- oder Menüstrukturen abgebildet werden. Mittels Sprüngen und Leerseiten
-- kann innerhalb des Multiple Choice Briefings navigiert werden.
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
-- @field BriefingStarted           Ein Briefing beginnt (Parameter: PlayerID, BriefingTable)
-- @field BriefingEnded             Ein Briefing endet (Parameter: PlayerID, BriefingTable)
-- @field BriefingPageShown         Ein Briefing endet (Parameter: PlayerID, PageIndex)
-- @field BriefingSkipButtonPressed Der Spieler überspringt eine Seite (Parameter: PlayerID)
-- @field BriefingOptionSelected    Eine Multiple Choice Option wurde ausgewählt (Parameter: PlayerID, OptionID)
-- @field BriefingLeftClick         Left Mouse wurde während des Briefings gedrückt (Parameter: PlayerID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Startet ein Briefing.
--
-- <h5>Einstellungen</h5>
-- Für ein Briefing können verschiedene spezielle Einstellungen vorgenommen
-- werden.
--
-- Mögliche Werte:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Starting</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die beim Start des Briefing ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>Finished</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die nach Beendigung des Briefing ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>EnableGlobalImmortality</td>
-- <td>boolean</td>
-- <td>(Optional) Alle Einheiten und Gebäude werden unverwundbar solange das Briefing aktiv ist.</td>
-- </tr>
-- <tr>
-- <td>BarOpacity</td>
-- <td>number</td>
-- <td>(Optional) Setzt den Alphawert der Bars (Zwischen 0 und 1).</td>
-- </tr>
-- <tr>
-- <td>EnableSky</td>
-- <td>boolean</td>
-- <td>(Optional) Der Himmel wird während des Briefing angezeigt.</td>
-- </tr>
-- <tr>
-- <td>DisableFoW</td>
-- <td>boolean</td>
-- <td>(Optional) Der Nebel des Krieges wird für die Dauer des Briefing ausgeblendet.</td>
-- </tr>
-- <tr>
-- <td>DisableBorderPins</td>
-- <td>boolean</td>
-- <td>(Optional) Die Grenzsteine werden für die Dauer des Briefing ausgeblendet.</td>
-- </tr>
-- </table>
--
-- <h5>Animationen</h5>
-- Animationen für Seiten eines Briefings werden vom Text entkoppelt. Das hat
-- den Charme, dass Spielfiguren erzählen und erzählen und die Kamera über die
-- ganze Zeit die gleiche Animation zeigt, was das Lesen angenehmer macht.
--
-- Animationen können auch über eine Table angegeben werden. Diese wird direkt
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
-- Es wird aber empfohlen, die Funktion <a href="#AAN">AAN</a> zu verwenden.
--
-- @param[type=table]  _Briefing Definition des Briefing
-- @param[type=string] _Name     Name des Briefing
-- @param[type=number] _PlayerID Empfänger des Briefing
-- @within Anwenderfunktionen
--
-- @usage
-- function Briefing1(_Name, _PlayerID)
--     local Briefing = {
--         DisableFoW = true,
--         EnableSky = true,
--         DisableBoderPins = true,
--     };
--     local AP, ASP, AAN = API.AddBriefingPages(Briefing);
--
--     -- Aufrufe von AP oder ASP um Seiten zu erstellen
--
--     Briefing.Starting = function(_Data)
--         -- Mach was tolles hier wenn es anfängt.
--     end
--     Briefing.Finished = function(_Data)
--         -- Mach was tolles hier wenn es endet.
--     end
--     API.StartBriefing(Briefing, _Name, _PlayerID);
-- end
--
function API.StartBriefing(_Briefing, _Name, _PlayerID)
    if GUI then
        return;
    end
    local PlayerID = _PlayerID;
    if not PlayerID and not Framework.IsNetworkGame() then
        PlayerID = QSB.HumanPlayerID;
    end
    assert(_PlayerID ~= nil);
    if type(_Briefing) ~= "table" then
        local Name = "Briefing #" ..(ModuleBriefingSystem.Global.BriefingCounter +1);
        error("API.StartBriefing (" ..Name.. "): _Briefing must be a table!");
        return;
    end
    if #_Briefing == 0 then
        local Name = "Briefing #" ..(ModuleBriefingSystem.Global.BriefingCounter +1);
        error("API.StartBriefing (" ..Name.. "): _Briefing does not contain pages!");
        return;
    end
    for i=1, #_Briefing do
        if type(_Briefing[i]) == "table" and not _Briefing[i].__Legit then
            local Name = "Briefing #" ..(ModuleBriefingSystem.Global.BriefingCounter +1);
            error("API.StartBriefing (" ..Name.. ", Page #" ..i.. "): Page is not initialized!");
            return;
        end
    end
    ModuleBriefingSystem.Global:StartBriefing(_Name, PlayerID, _Briefing);
end

---
-- Prüft ob für den Spieler gerade ein Briefing aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=boolean] Briefing ist aktiv
-- @within Anwenderfunktionen
--
function API.IsBriefingActive(_PlayerID)
    if Swift:IsGlobalEnvironment() then
        return ModuleBriefingSystem.Global:GetCurrentBriefing(_PlayerID) ~= nil;
    end
    return ModuleBriefingSystem.Local:GetCurrentBriefing(_PlayerID) ~= nil;
end

---
-- Erzeugt die Funktionen zur Erstellung von Seiten und Animationen in einem
-- Briefing. Diese Funktion muss vor dem Start eines Briefing aufgerufen werden,
-- damit Seiten gebunden werden können. Je nach Bedarf können Rückgaben von
-- rechts nach links weggelassen werden.
--
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=function] <a href="#AP">AP</a>
-- @return[type=function] <a href="#ASP">ASP</a>
-- @return[type=function] <a href="#AA">AA</a>
-- @within Anwenderfunktionen
--
-- @usage
-- -- Wenn nur AP benötigt wird.
-- local AP = API.AddBriefingPages(Briefing);
-- -- Wenn zusätzlich ASP benötigt wird.
-- local AP, ASP = API.AddBriefingPages(Briefing);
-- -- Wenn auch die Kurzschreibweise für Animationen gebraucht wird.
-- local AP, ASP, AA = API.AddBriefingPages(Briefing);
--
function API.AddBriefingPages(_Briefing)
    _Briefing.GetPage = function(self, _NameOrID)
        local ID = ModuleBriefingSystem.Global:GetPageIDByName(_Briefing.PlayerID, _NameOrID);
        return ModuleBriefingSystem.Global.Briefing[_Briefing.PlayerID][ID];
    end

    local AP = function(_Page)
        _Briefing.PageAnimations = _Briefing.PageAnimations or {};

        _Briefing.Length = (_Briefing.Length or 0) +1;
        if type(_Page) == "table" then
            local Identifier = "Page" ..(#_Briefing +1);
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

            -- Simple camera position
            if _Page.Position then
                local Angle = _Page.Angle;
                if not Angle then
                    Angle = QSB.Briefing.CAMERA_ANGLEDEFAULT;
                    if _Page.DialogCamera then
                        Angle = QSB.Briefing.DLGCAMERA_ANGLEDEFAULT;
                    end
                end

                local Rotation = _Page.Rotation;
                if not Rotation then
                    Rotation = QSB.Briefing.CAMERA_ROTATIONDEFAULT;
                    if _Page.DialogCamera then
                        Rotation = QSB.Briefing.DLGCAMERA_ROTATIONDEFAULT;
                    end
                end

                local Zoom = _Page.Zoom;
                if not Zoom then
                    Zoom = QSB.Briefing.CAMERA_ZOOMDEFAULT;
                    if _Page.DialogCamera then
                        Zoom = QSB.Briefing.DLGCAMERA_ZOOMDEFAULT;
                    end
                end

                _Briefing.PageAnimations[Identifier] = {
                    {PurgeOld = true,
                     _Page.Position, Rotation, Zoom, Angle,
                     _Page.Position, Rotation, Zoom, Angle,
                     _Page.Duration or 1
                    }
                };
            end

            -- Language
            _Page.Title = API.Localize(_Page.Title);
            _Page.Text = API.Localize(_Page.Text);

            -- Display time
            if not _Page.Duration then
                if not _Page.Position then
                    _Page.DisableSkipping = false;
                    _Page.Duration = -1;
                else
                    if _Page.DisableSkipping == nil then
                        _Page.DisableSkipping = false;
                    end
                    _Page.Duration = string.len(_Page.Text or "") * QSB.Briefing.TIMER_PER_CHAR;
                    if _Page.Duration < 6 then
                        _Page.Duration = 6;
                    end
                end
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
        table.insert(_Briefing, _Page);
        return _Page;
    end

    local AAN = function(_Identifier, ...)
        _Briefing.PageAnimations = _Briefing.PageAnimations or {};

        local PageID = _Identifier;
        if type(_Identifier) == "string" then
            PageID = nil;
            for i= 1, #_Briefing do
                if type(_Briefing[i]) == "table" and _Briefing[i].Name == _Identifier then
                    PageID = i;
                end
            end
        end
        if not PageID then
            error("AAN (Briefing System): Can not find name or ID '".. tostring(_Identifier).. "'!");
            return;
        end
        if not _Briefing.PageAnimations[_Identifier] then
            _Briefing.PageAnimations[_Identifier] = {};
        end
        if #arg == 1 then
            _Briefing.PageAnimations[_Identifier].PurgeOld = arg[1] == true;
        else
            -- Static position (relative)
            if #arg == 4 then
                table.insert(_Briefing.PageAnimations[_Identifier], {
                    arg[1], arg[2], arg[3], arg[4],
                    arg[1], arg[2], arg[3], arg[4],
                    1
                });
            -- Camera movement (relative)
            elseif #arg == 9 then
                table.insert(_Briefing.PageAnimations[_Identifier], {
                    arg[1], arg[2], arg[3], arg[4],
                    arg[5], arg[6], arg[7], arg[8],
                    arg[9]
                });
            -- Static position (vector)
            elseif #arg == 6 then
                table.insert(_Briefing.PageAnimations[_Identifier], {
                    {arg[1], arg[2], arg[3]}, {arg[4], arg[5], arg[6]},
                    {arg[1], arg[2], arg[3]}, {arg[4], arg[5], arg[6]},
                    1
                });
            -- Camera movement (vector)
            elseif #arg == 13 then
                table.insert(_Briefing.PageAnimations[_Identifier], {
                    {arg[1], arg[2], arg[3]}, {arg[4], arg[5], arg[6]},
                    {arg[7], arg[8], arg[9]}, {arg[10], arg[11], arg[12]},
                    arg[13]
                });
            end
        end
    end

    local ASP = function(...)
        _Briefing.PageAnimations = _Briefing.PageAnimations or {};

        local Name, Title,Text, Position;
        local DialogCam = false;
        local Action = function() end;
        local NoSkipping = false;

        -- Set page parameters
        if (#arg == 3 and type(arg[1]) == "string")
        or (#arg >= 4 and type(arg[4]) == "boolean") then
            Name = table.remove(arg, 1);
        end
        Title = table.remove(arg, 1);
        Text = table.remove(arg, 1);
        if #arg > 0 then
            DialogCam = table.remove(arg, 1) == true;
        end
        if #arg > 0 then
            Position = table.remove(arg, 1);
        end
        if #arg > 0 then
            Action = table.remove(arg, 1);
        end
        if #arg > 0 then
            NoSkipping = not table.remove(arg, 1);
        end

        -- Calculate camera rotation
        local Rotation;
        if Position then
            Rotation = QSB.Briefing.CAMERA_ROTATIONDEFAULT;
            if Position and Logic.IsSettler(GetID(Position)) == 1 then
                Rotation = Logic.GetEntityOrientation(GetID(Position)) + 90;
            end
        end

        return AP {
            Name            = Name,
            Title           = Title,
            Text            = Text,
            Action          = Action,
            Position        = Position,
            DisableSkipping = NoSkipping,
            DialogCamera    = DialogCam,
            Rotation        = Rotation,
        };
    end
    return AP, ASP, AAN;
end

---
-- Erzeugt eine neue Seite für das Briefing.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddBriefingPages">API.AddBriefingPages</a> erzeugt und an
-- das Briefing gebunden.
--
-- <h5>Briefing Page</h5>
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
-- <td>BigBars</td>
-- <td>boolean</td>
-- <td>(Optional) Schalted breite Balken ein oder aus.</b></td>
-- </tr>
-- <tr>
-- <td>MC</td>
-- <td>table</td>
-- <td>(Optional) Liste von Optionen zur Verzweigung des Briefings. Dies kann
-- benutzt werden, um z.B. Dialoge mit Antwortmöglichkeiten zu erstellen.</td>
-- </tr>
-- </table>
--
-- <br><h5>Multiple Choice</h5>
-- In einem Briefing kann der Spieler auch zur Auswahl einer Option gebeten
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
-- <pre>Briefing.Finished = function(_Data)
--    local Choosen = _Data:GetPage("Choice"):GetSelectedAnswer();
--end</pre>
-- Die zurückgegebene Zahl ist die ID der Antwort, angefangen von oben. Wird 0
-- zurückgegeben, wurde noch nicht geantwortet.
--
-- @param[type=table] _Data Daten der Seite
-- @return[type=table] Erzeugte Seite
-- @within Briefing
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
-- Erzeugt eine neue Seite für das Briefing in Kurzschreibweise.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddBriefingPages">API.AddBriefingPages</a> erzeugt und an
-- das Briefing gebunden.
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
-- @within Briefing
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
-- <a href="#API.AddBriefingPages">API.AddBriefingPages</a> erzeugt und an
-- das Briefing gebunden.
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
-- @within Briefing
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

