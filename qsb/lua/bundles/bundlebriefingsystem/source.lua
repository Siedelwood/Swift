-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleBriefingSystem                                         # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es Briefings und Fake-Cutscenes zu verwenden.
--
-- <br><br><b>Briefing</b><br>
-- Briefings dienen zur Darstellung von Dialogen oder zur näheren Erleuterung
-- der aktuellen Spielsituation. Mit Multiple Choice können dem Spieler mehrere
-- Auswahlmöglichkeiten gegeben werden, multiple Handlungsstränge gestartet
-- oder Menüstrukturen abgebildet werden. Mittels Sprüngen und Leerseiten
-- kann innerhalb des Multiple Choice Briefings navigiert werden.
--
-- <br><br><b>Cutscene</b><br>
-- Cutscenes dürfen kein Multiple Choice enthalten und werden immer nur ganz
-- abgespielt oder abgebrochen. Das Überspringen einzelner Seiten ist nicht
-- möglich. Cutscenes verfügen über eine neue Kamerasteuerung (Blickrichtung
-- und Ursprungspunkt) und sollten ausschließlich für szenerische Untermalung
-- der Handlung eingesetzt werden.
--
-- <br><br><b>Behavior</b><br>
-- Bisher war es schwer ein Briefing in den Ablauf einzubauen. Es wurde immer
-- ein nebenher laufender Job oder eine Variable zur Steuerung benötigt. Wenn
-- man nun ein Briefing oder eine Cutscene mit speziellen Behavior an einen
-- Auftrag anbindet, handhabt das System die nachfolgenden Aufträge.
--
-- <br><br><b>Splashscreen</b><br>
-- Splashscreens stehen sowohl in Briefings als auch in Cutscenes zuer Verfügung
-- und bieten die Möglichkeit, Bildschirmfüllende Grafiken zu verwenden. Diese
-- Grafiken können auch größer als eine Bildschirmfläche sein. Für diesen
-- Fall kann über die Angabe von UV-Koordinaten zu einem bestimmten Abschnitt
-- der Grafik gesprungen oder geflogen werden.
--
-- @within Modulbeschreibung
-- @set sort=false
--
BundleBriefingSystem = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Setzt den Zustand von Quest Timern währenddessen ein Biefings oder eine
-- Fake-Cutscene aktiv ist.
--
-- Während eines Briefings vergeht generell keine Zeit. Folglich ist der
-- Niederlage Timer generell inaktiv. Werden Quests während Briefings nicht
-- pausiert, zählen Niederlage Timer unterdessen weiter!
--
-- <p><b>Alias</b>: PauseQuestsDuringBriefings</p>
--
-- @param _Flag [boolean] Quest Timer pausiert
-- @within Anwenderfunktionen
--
function API.PauseQuestsDuringBriefings(_Flag)
    if GUI then
        API.Bridge("API.PauseQuestsDuringBriefings(" ..tostring(_Flag).. ")");
        return;
    end
    return BundleBriefingSystem.Global:PauseQuestsDuringBriefings(_Flag);
end
PauseQuestsDuringBriefings = API.PauseQuestsDuringBriefings;

---
-- Prüft, ob das Briefing mit der angegebenen ID beendet ist.
--
-- <p><b>Alias</b>: IsBriefingFinished</p>
--
-- @param _briefingID [number] ID des Briefing
-- @return [boolean] Briefing ist beendet
-- @within Anwenderfunktionen
--
function API.IsBriefingFinished(_briefingID)
    if GUI then
        API.Dbg("API.IsBriefingFinished: Can only be used in the global script!");
        return;
    end
    return BundleBriefingSystem.Global:IsBriefingFinished(_briefingID);
end
IsBriefingFinished = API.IsBriefingFinished;

---
-- Gibt die gewähtle Antwort für die Multiple Choice Page zurück.
--
-- Wird eine Seite mehrmals durchlaufen, wird die jeweils letzte Antwort
-- zurückgegeben.
--
-- <p><b>Alias</b>: MCGetSelectedAnswer</p>
--
-- @param _page [table] Referenz auf die Seite
-- @return [number] Gewählte Antwort
-- @within Anwenderfunktionen
--
function API.GetSelectedAnswerFromMCPage(_page)
    if GUI then
        API.Dbg("API.GetSelectedAnswerFromMCPage: Can only be used in the global script!");
        return;
    end
    return BundleBriefingSystem.Global:MCGetSelectedAnswer(_page);
end
MCGetSelectedAnswer = API.GetSelectedAnswerFromMCPage;

---
-- Gibt die Definition der Seite im aktuellen Briefing zurück.
--
-- Das aktuelle Briefing ist immer das letzte, das gestartet wurde.
--
-- <p><b>Alias</b>: GetCurrentBriefingPage</p>
--
-- @param _pageNumber [number] Index der Seite
-- @return [table] Seite des aktuellen Briefing
-- @within Anwenderfunktionen
--
function API.GetCurrentBriefingPage(_pageNumber)
    if GUI then
        API.Dbg("API.GetCurrentBriefingPage: Can only be used in the global script!");
        return;
    end
    return BundleBriefingSystem.Global:GetCurrentBriefingPage(_pageNumber);
end
GetCurrentBriefingPage = API.GetCurrentBriefingPage;

---
-- Gibt das aktuelle Briefing zurück.
--
-- Das aktuelle Briefing ist immer das letzte, das gestartet wurde.
--
-- <p><b>Alias</b>: GetCurrentBriefing</p>
--
-- @return [table] Briefing mit allen Seiten
-- @within Anwenderfunktionen
--
function API.GetCurrentBriefing()
    if GUI then
        API.Dbg("API.GetCurrentBriefing: Can only be used in the global script!");
        return;
    end
    return BundleBriefingSystem.Global:GetCurrentBriefing();
end
GetCurrentBriefing = API.GetCurrentBriefing;

---
-- Initalisiert die Page-Funktionen für das übergebene Briefing.
--
-- Die zurückgegebenen Funktionen sind für Dialoge gedacht. Auch wenn AP alles
-- kann, sollte man sich an diese konvention halten.
--
-- <p><b>Alias</b>: AddPages</p>
--
-- @param _Briefing [table] Briefing
-- @return [function] AP - Allround-Funktion zur Erzeugung von Seiten
-- @return [function] ASP - Vereinfachte Funktion für Dialoge
-- @return [function] ASMC - Vereinfachte Funktion für Auswahl-Dialoge
-- @within Anwenderfunktionen
--
function API.AddPages(_Briefing)
    if GUI then
        API.Dbg("API.AddPages: Can only be used in the global script!");
        return;
    end
    return BundleBriefingSystem.Global:AddPages(_Briefing);
end
AddPages = API.AddPages;

---
-- Initalisiert die Flight-Funktionen für die übergebene Fake-Cutscene.
--
-- Die zurückgegebenen Funktionen sind für Kameraflüge gedacht. Vermeide die
-- Anzeige von langen Texten.
--
-- <p><b>Alias</b>: AddPages</p>
--
-- @param _Cutscene [table] Cutscene
-- @return [function] AF - Funktion für komfortable Notation von Flights
-- @return [function] ASF - Kurzschreibweise für AF
-- @within Anwenderfunktionen
--
function API.AddFlights(_Cutscene)
    if GUI then
        API.Dbg("API.AddFlights: Can only be used in the global script!");
        return;
    end
    return BundleBriefingSystem.Global:AddFlights(_Cutscene);
end
AddFlights = API.AddFlights;

---
-- Schreibt während eines Briefings eine zusätzliche Textnachricht auf den
-- Bildschirm. Die Nachricht wird, in Abhängigkeit zur Textlänge, nach ein
-- paar Sekunden verschrinden.
--
-- <p><b>Alias:</b> BriefingMessage</p>
--
-- @param _Text	    [string] Anzuzeigender Text
-- @param _Duration	[number] Anzeigedauer in Sekunden
-- @within Anwenderfunktionen
--
function API.AddBriefingNote(_Text, _Duration)
    if type(_Text) ~= "string" and type(_Text) ~= "number" then
        API.Dbg("API.AddBriefingNote: Text must be a string or a number!");
        return;
    end
    if not GUI then
        API.Bridge([[API.AddBriefingNote("]] .._Text.. [[", ]]..tostring(_Duration)..[[)]]);
        return;
    end
    return BriefingSystem.PushInformationText(_Text, (_Duration * 100));
end
BriefingMessage = API.AddBriefingNote;

-- -------------------------------------------------------------------------- --
-- Dummy-Space                                                                --
-- -------------------------------------------------------------------------- --

---
-- Erstellt eine Seite für ein Dialog-Briefing in der alten Notation.
--
-- <b>Normale Seite</b><br>
-- Die üblichen Parameter können angegeben werden. Beispiele sind zoom, text,
-- oder action. Zusätzlich hinzugekommen sind lookAt und zOffset. Mittels
-- lookAt kann die Kamera zum Angesicht eines Siedlers ausgerichtet werden.
-- zOffset ermöglicht die Nutzung der Z-Achse.
--
-- <b>Multiple Choice, Sprünge und Leerseiten</b><br>
-- Eine Multiple-Choice-Seite enthält die Unterseite mc. In mc wird der Text,
-- der Titel und die möglichen Antwortmöglichkeiten notiiert. Alle Antworten
-- stehen innerhalb von answers. Jede mögliche Antwort ist eine Table mit dem
-- Text der Auswahl, dem Sprungziel und einigen Optionen.<br>
-- Mittels eines Sprungs kann zu einer anderen Seite eines Briefings gegangen
-- werden. Dazu muss der Index der Zielseite angegeben werden. Die erste Seite
-- eines Briefings darf kein Sprung sein!.<br>
-- Eine Leerseite kann benutzt werden um hinter einem von einer Auswahl
-- aufgeschlagenen Pfad im Briefing selbiges zu beenden. Sonst würde das
-- Briefing einfach mit der nächsten Seite weiter machen. Sprungbefehle
-- können alternativ verwendet werden.
--
-- <b>Splashscreens</b><br>
-- Splashscreens können eine Grafik anzeigen. Sie bieten zudem die Möglichkeit
-- über die Grafik zu scrollen oder zu zoomen.
--
-- @param _page	[table] Spezifikation der Seite
-- @return [table] Refernez auf die angelegte Seite
-- @within Briefing
--
function AP(_Page)
    -- Diese Funktion ist ein Dummy für LDoc!
    API.Dbg("AP: Please use the function provides by AddPages!");
end

---
-- Erstellt einen Flight einer Fake-Cutscene.
--
-- Flights bestehen aus einem Startpunkt und mindestens einer weitere Position.
-- Ein Flight kann aus nahezu unbegrenzt vielen Punkten bestehen, die alle
-- innerhalb der Duration abgefahren werden.
--
-- <b>Hinweis:</b> Es ist prinzipiell Möglich mehr als 10 Punkte pro Sekunde
-- anzusteuern, aber nicht sehr sinnvoll. ;)
--
-- Aufbau einer Station eines Flights:
-- <table border="1">
-- <tr>
-- <td><b>Eigenschaft</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Position</td>
-- <td>Die Kameraposition der Station</td>
-- </tr>
-- <tr>
-- <td>LookAt</td>
-- <td>Der Kamerablickpunkt der Station</td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>Der angezeigte Sprecher</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>Der gesprochende Text</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>Aktion zu Beginn der Kamerabewegung</td>
-- </tr>
-- </table>
--
-- Allgemeine Angaben eines Flight:
-- <table border="1">
-- <tr>
-- <td><b>Eigenschaft</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Duration</td>
-- <td>Dauer des gesamten Flights. Die Zeit wird auf alle Positionen des
-- Flights der Fake-Cutscene aufgeteilt (mit Ausnahme der Startposition).</td>
-- </tr>
-- <tr>
-- <td>FadeIn</td>
-- <td>Einblendedauer am Anfang des Flight</td>
-- </tr>
-- <tr>
-- <td>FadeOut</td>
-- <td>Abblendedauer am Ende des Flight</td>
-- </tr>
-- </table>
--
-- @param _page	[table] Spezifikation des Flight
-- @within Briefing
--
-- @usage
-- AF {
--     {
--         Position = {X= 12300, Y= 23000, Z= 3400},
--         LookAt   = {X= 22000, Y= 34050, Z= 200},
--         Text     = "Das ist ein Text....",
--     },
--     {
--         Position = {X= 12300, Y= 23000, Z= 3400},
--         LookAt   = {X= 22500, Y= 31050, Z= 350},
--         Text     = "Das ist ein Text....",
--     },
--     FadeOut  = 0.5,
--     FadeIn   = 0.5,
--     Duration = 24,
-- };
--
function AF(_Flight)
    -- Diese Funktion ist ein Dummy für LDoc!
    API.Dbg("AF: Please use the function provides by AddFlights!");
end

---
-- Ermäglicht einen Flight als Einzeiler zu notieren. Allerdings sind nicht
-- alle Optionen verfügbar.
--
-- Bei der Notation der Koordinaten ist zu beachten, dass zuerst das Triple
-- der Kameraposition und danach das Triple des Blickpunktes angegeben wird.
-- Für jeden Punkt müssen also 6 Zahlen angegeben werden.
--
-- <b>Hinweis:</b> Diese Funktion eignet sich besser für einfache Flüge mit
-- wenigen Kamerastationen oder für eine generische Nutzung.
--
-- @param _Text     [string] Angezeigter Text
-- @param _Duration [number] Dauer des Flight
-- @param _Action   [function] Aktion zu Beginn des Flight
-- @param _Fading   [boolen] Einblenden und Abblenden
-- @param ...       [number] Liste der XYZ-Koordinaten
-- @within Briefing
--
-- @usage
-- ASF ("Das ist ein Text....", 10, nil, true, 12300, 23000, 3400, 22000, 34050, 200, 12300, 23000, 3400, 22500, 31050, 350);
--
function ASF(_Text, _Duration, _Action, _Fading, ...)
    -- Diese Funktion ist ein Dummy für LDoc!
    API.Dbg("ASF: Please use the function provides by AddFlights!");
end

---
-- Erstellt eine Seite in vereinfachter Syntax. Es wird davon
-- Ausgegangen, dass das Entity ein Siedler ist. Die Kamera
-- schaut den Siedler an.
--
-- @param _entity		[string] Zielentity
-- @param _title		[string] Titel der Seite
-- @param _text		    [string] Text der Seite
-- @param _dialogCamera [boolean] Nahsicht an/aus
-- @param _action       [function] Callback-Funktion
-- @return [table] Referenz auf die Seite
-- @within Briefing
--
-- @usage ASP("hans", "Hänschen-Klein", "Ich gehe in die weitel Welt hinein.", true);
--
function ASP(_entity, _title, _text, _dialogCamera, _action)
    -- Diese Funktion ist ein Dummy für LDoc!
    API.Dbg("ASP: Please use the function provides by AddPages!");
end

---
-- Erstellt eine Multiple Choise Seite in vereinfachter Syntax. Es
-- wird davon Ausgegangen, dass das Entity ein Siedler ist. Die
-- Kamera schaut den Siedler an.
--
-- @param _entity		[string] Zielentity
-- @param _title		[tring] Titel der Seite
-- @param _text		    [string] Text der Seite
-- @param _dialogCamera [boolean] Nahsicht an/aus
-- @param ...			[mixed] Liste der Antworten und Sprungziele (string,
-- number, string, number, ...)
-- @return [table] Referenz auf die Seite
-- @within Briefing
--
-- @usage
-- ASMC("hans", "", "In welche Richtung soll Hänschen-Klein gehen?", false,
--      "Nach links gehen.", 2,
--      "Lieber nach rechts.", 4)
--
function ASMC(_entity, _title, _text, _dialogCamera, ...)
    -- Diese Funktion ist ein Dummy für LDoc!
    API.Dbg("ASMC: Please use the function provides by AddPages!");
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleBriefingSystem = {
    Global = {
        Data = {
            PlayedBriefings = {},
            QuestsPausedWhileBriefingActive = true,
            BriefingID = 0,
        }
    },
    Local = {
        Data = {}
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:Install()
    self:InitalizeBriefingSystem();
end

---
-- Setzt den Zustand von Quest Timern während Biefings und Fake-Cutscenes.
--
-- Niederlage Timer sind generell inaktiv, können aber aktiviert werden.
--
-- @param _Flag Quest Timer pausiert
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:PauseQuestsDuringBriefings(_Flag)
    self.Data.QuestsPausedWhileBriefingActive = _Flag == true;
end

---
-- Prüft, ob ein Briefing abgespielt wurde (beendet ist).
--
-- @param _Flag Quest Timer pausiert
-- @return boolean: Briefing ist beendet
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:IsBriefingFinished(_briefingID)
    return self.Data.PlayedBriefings[_briefingID] == true;
end

---
-- Gibt die gewähtle Antwort für die MC Page zurück.
--
-- Wird eine Seite mehrmals durchlaufen, wird die jeweils letzte Antwort
-- zurückgegeben.
--
-- @param _page Seite
-- @return number: Gewählte Antwort
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:MCGetSelectedAnswer(_page)
    if _page.mc and _page.mc.given then
        return _page.mc.given;
    end
    return 0;
end

---
-- Gibt die Seite im aktuellen Briefing zurück.
--
-- Das aktuelle Briefing ist immer das letzte, das gestartet wurde.
--
-- @param _pageNumber Index der Page
-- @return table: Page
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:GetCurrentBriefingPage(_pageNumber)
    return BriefingSystem.currBriefing[_pageNumber];
end

---
-- Gibt das aktuelle Briefing zurück.
--
-- Das aktuelle Briefing ist immer das letzte, das gestartet wurde.
--
-- @return table: Briefing
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:GetCurrentBriefing()
    return BriefingSystem.currBriefing;
end

---
-- Initalisiert die Flight-Funktionen für die übergebene Cutscene.
--
-- @param _Cutscene Cutscene
-- @return function: AF
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:AddFlights(_Cutscene)
    local AF = function(_Flight)
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        assert(type(_Flight) == "table" and #_Flight > 0);
        local Duration  = _Flight.Duration / (#_Flight -1);
        local i = 0;

        for i= 1, #_Flight, 1 do
            local Title = _Flight[i].Title or "";
            if type(Title) == "table" then
                Title = Title[lang];
            end
            local Text = _Flight[i].Text or "";
            if type(Text) == "table" then
                Text = Text[lang];
            end

            local Flight = {
                cutscene = {
                    Position = _Flight[i].Position,
                    LookAt   = _Flight[i].LookAt,
                },
                title        = Title,
                text         = Text,
                action       = _Flight[i].Action,
                faderAlpha   = (i == 1 and _Flight.FadeIn and 1) or nil,
                fadeIn       = (i == 1 and _Flight.FadeIn) or nil,
                fadeOut      = (i == #_Flight and _Flight.FadeOut and (-_Flight.FadeOut)) or nil,
                duration     = (i == 1 and 0) or Duration,
                flyTime      = (i > 1 and Duration) or nil,
                splashscreen = _Flight.Splashscreen
            };
            table.insert(_Cutscene, Flight);
        end
    end

    local ASF = function(_Text, _Duration, _Action, _Fading, ...)
        local Flights = {};
        for i= 1, #arg, 6 do
            local Action = (i == 1 and _Action) or nil;
            table.insert(Flights, {
                Position = {X= arg[i],   Y= arg[i+1], Z= arg[i+2]},
                LookAt   = {X= arg[i+3], Y= arg[i+4], Z= arg[i+5]},
                Text     = _Text,
                Action   = Action,
            });
        end
        Flights.FadeIn   = (_Fading == true and 0.5) or 0;
        Flights.FadeOut  = (_Fading == true and 0.5) or 0;
        Flights.Duration = _Duration;
        AF(Flights);
    end
    return AF, ASF;
end

---
-- Initalisiert die Page-Funktionen für das übergebene Briefing
--
-- @param _briefing
-- @return function: AP
-- @return function: ASP
-- @return function: ASMC
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:AddPages(_briefing)
    local AP = function(_page)
        if _page and type(_page) == "table" then
            local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
            if type(_page.title) == "table" then
                _page.title = _page.title[lang];
            end
            _page.title = _page.title or "";
            if type(_page.text) == "table" then
                _page.text = _page.text[lang];
            end
            _page.text = _page.text or "";

            -- Multiple Choice Support
            if _page.mc then
                if _page.mc.answers then
                    _page.mc.amount  = #_page.mc.answers;
                    assert(_page.mc.amount >= 1);
                    _page.mc.current = 1;

                    for i=1, _page.mc.amount do
                        if _page.mc.answers[i] then
                            if type(_page.mc.answers[i][1]) == "table" then
                                _page.mc.answers[i][1] = _page.mc.answers[i][1][lang];
                            end
                        end
                    end
                end
                if type(_page.mc.title) == "table" then
                    _page.mc.title = _page.mc.title [lang];
                end
                if type(_page.mc.text) == "table" then
                    _page.mc.text = _page.mc.text[lang];
                end
            end

            _page.cutscene = _page.cutscene or _page.view;
            if _page.cutscene then
                _page.flyTime  = _page.cutscene.FlyTime or 0;
                _page.duration = _page.cutscene.Duration or 0;
            else
                if type(_page.position) == "table" then
                    if not _page.position.X then
                        _page.zOffset = _page.position[2];
                        _page.position = _page.position[1];
                    elseif _page.position.Z then
                        _page.zOffset = _page.position.Z;
                    end
                end

                if _page.lookAt ~= nil then
                    local lookAt = _page.lookAt;
                    if type(lookAt) == "table" then
                        _page.zOffset = lookAt[2];
                        lookAt = lookAt[1];
                    end

                    if type(lookAt) == "string" or type(lookAt) == "number" then
                        local eID    = GetID(lookAt);
                        local ori    = Logic.GetEntityOrientation(eID);
                        if Logic.IsBuilding(eID) == 0 then
                            ori = ori + 90;
                        end
                        local tpCh = 0.085 * string.len(_page.text);

                        _page.position = eID;
                        _page.duration = _page.duration or tpCh;
                        _page.flyTime  = _page.flyTime;
                        _page.rotation = (_page.rotation or 0) +ori;
                    end
                end
            end
            table.insert(_briefing, _page);
        else
            -- Sprünge, Rücksprünge und Abbruch
            table.insert(_briefing, (_page ~= nil and _page) or -1);
        end
        return _page;
    end

    local ASP = function(_entity, _title, _text, _dialogCamera, _action)
        local Entity = Logic.GetEntityName(GetID(_entity));
        assert(Entity ~= nil and Entity ~= "");

        local page  = {};
        page.zoom   = (_dialogCamera == true and 2400 ) or 6250;
        page.angle  = (_dialogCamera == true and 40 ) or 47;
        page.lookAt = {Entity, 100};
        page.title  = _title;
        page.text   = _text or "";
        page.action = _action;
        return AP(page);
    end

    local ASMC = function(_entity, _title, _text, _dialogCamera, ...)
        local Entity = Logic.GetEntityName(GetID(_entity));
        assert(Entity ~= nil and Entity ~= "");

        local page    = {};
        page.zoom     = (_dialogCamera == true and 2400 ) or 6250;
        page.angle    = (_dialogCamera == true and 40 ) or 47;
        page.lookAt   = {Entity, 100};
        page.barStyle = "big";

        page.mc = {
            title = _title,
            text = _text,
            answers = {}
        };
        local args = {...};
        for i=1, #args-1, 2 do
            page.mc.answers[#page.mc.answers+1] = {args[i], args[i+1]};
        end
        return AP(page);
    end
    return AP, ASP, ASMC;
end

---
-- Initalisiert das Briefing System im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleBriefingSystem.Global:InitalizeBriefingSystem()
    -- Setze Standardfarben
    DBlau   = "{@color:70,70,255,255}";
    Blau    = "{@color:153,210,234,255}";
    Weiss   = "{@color:255,255,255,255}";
    Rot     = "{@color:255,32,32,255}";
    Gelb    = "{@color:244,184,0,255}";
    Gruen   = "{@color:173,255,47,255}";
    Orange  = "{@color:255,127,0,255}";
    Mint    = "{@color:0,255,255,255}";
    Grau    = "{@color:180,180,180,255}";
    Trans   = "{@color:0,0,0,0}";

    Quest_Loop = function(_arguments)
        local self = JobQueue_GetParameter(_arguments)

        if self.LoopCallback ~= nil then
            self:LoopCallback()
        end

        if self.State == QuestState.NotTriggered then
            local triggered = true
            for i = 1, self.Triggers[0] do
                triggered = triggered and self:IsTriggerActive(self.Triggers[i])
            end
            if triggered then
                self:SetMsgKeyOverride()
                self:SetIconOverride()
                self:Trigger()
            end

        elseif self.State == QuestState.Active then
            local allTrue = true
            local anyFalse = false
            for i = 1, self.Objectives[0] do
                local completed = self:IsObjectiveCompleted(self.Objectives[i])

                -- Wenn ein Briefing läuft, vergeht keine Zeit in laufenden Quests
                if IsBriefingActive() then
                    if BundleBriefingSystem.Global.Data.QuestsPausedWhileBriefingActive == true then
                        self.StartTime = self.StartTime +1;
                    end
                end

                if self.Objectives[i].Type == Objective.Deliver and completed == nil then
                    if self.Objectives[i].Data[4] == nil then
                        self.Objectives[i].Data[4] = 0
                    end
                    if self.Objectives[i].Data[3] ~= nil then
                        self.Objectives[i].Data[4] = self.Objectives[i].Data[4] + 1
                    end

                    local st = self.StartTime
                    local sd = self.Duration
                    local dt = self.Objectives[i].Data[4]
                    local sum = self.StartTime + self.Duration - self.Objectives[i].Data[4]
                    if self.Duration > 0 and self.StartTime + self.Duration + self.Objectives[i].Data[4] < Logic.GetTime() then
                        completed = false
                    end
                else
                    if self.Duration > 0 and self.StartTime + self.Duration < Logic.GetTime() then
                        if completed == nil and
                            (self.Objectives[i].Type == Objective.Protect or self.Objectives[i].Type == Objective.Dummy or self.Objectives[i].Type == Objective.NoChange) then
                            completed = true
                        elseif completed == nil or self.Objectives[i].Type == Objective.DummyFail then
                            completed = false
                       end
                    end
                end
                allTrue = (completed == true) and allTrue
                anyFalse = completed == false or anyFalse
            end

            if allTrue then
                self:Success()
            elseif anyFalse then
                self:Fail()
            end

        else
            if self.IsEventQuest == true then
                Logic.ExecuteInLuaLocalState("StopEventMusic(nil, "..self.ReceivingPlayer..")")
            end

            if self.Result == QuestResult.Success then
                for i = 1, self.Rewards[0] do
                    self:AddReward(self.Rewards[i])
                end
            elseif self.Result == QuestResult.Failure then
                for i = 1, self.Reprisals[0] do
                    self:AddReprisal(self.Reprisals[i])
                end
            end

            if self.EndCallback ~= nil then
                self:EndCallback()
            end

            return true
        end

        BundleBriefingSystem:OverwriteGetPosition();
    end

-- Briefing System Beginn --------------------------------------------------- --

    BriefingSystem = {
        isActive = false,
        waitList = {},
        isInitialized = false,
        maxMarkerListEntry = 0,
        currBriefingIndex = 0,
        loadScreenHidden = false
    };

    BriefingSystem.BRIEFING_CAMERA_ANGLEDEFAULT = 43;
    BriefingSystem.BRIEFING_CAMERA_ROTATIONDEFAULT = -45;
    BriefingSystem.BRIEFING_CAMERA_ZOOMDEFAULT = 6250;
    BriefingSystem.BRIEFING_CAMERA_FOVDEFAULT = 42;
    BriefingSystem.BRIEFING_DLGCAMERA_ANGLEDEFAULT = 29;
    BriefingSystem.BRIEFING_DLGCAMERA_ROTATIONDEFAULT = -45;
    BriefingSystem.BRIEFING_DLGCAMERA_ZOOMDEFAULT = 3400;
    BriefingSystem.BRIEFING_DLGCAMERA_FOVDEFAULT = 25;
    BriefingSystem.STANDARDTIME_PER_PAGE = 1;
    BriefingSystem.SECONDS_PER_CHAR = 0.05;
    BriefingSystem.COLOR1 = "{@color:255,250,0,255}";
    BriefingSystem.COLOR2 = "{@color:255,255,255,255}";
    BriefingSystem.COLOR3 = "{@color:250,255,0,255}";
    BriefingSystem.BRIEFING_FLYTIME = 0;
    BriefingSystem.POINTER_HORIZONTAL = 1;
    BriefingSystem.POINTER_VERTICAL = 4;
    BriefingSystem.POINTER_VERTICAL_LOW = 5;
    BriefingSystem.POINTER_VERTICAL_HIGH = 6;
    BriefingSystem.ANIMATED_MARKER = 1;
    BriefingSystem.STATIC_MARKER = 2;
    BriefingSystem.POINTER_PERMANENT_MARKER = 6;
    BriefingSystem.ENTITY_PERMANENT_MARKER = 8;
    BriefingSystem.SIGNAL_MARKER = 0;
    BriefingSystem.ATTACK_MARKER = 3;
    BriefingSystem.CRASH_MARKER = 4;
    BriefingSystem.POINTER_MARKER = 5;
    BriefingSystem.ENTITY_MARKER = 7;
    BriefingSystem.BRIEFING_EXPLORATION_RANGE = 6000;
    BriefingSystem.SKIPMODE_ALL = 1;
    BriefingSystem.SKIPMODE_PERPAGE = 2;
    BriefingSystem.DEFAULT_EXPLORE_ENTITY = "XD_Camera";

    ---
    -- Startet ein Briefing im Cutscene Mode. Alle nicht erlauten Operationen,
    -- wie seitenweises Überspringen oder Multiple Choice, sind deaktiviert
    -- bzw. verhindern den Start der Cutscene.
    --
    -- <b>Hinweis:</b> Bei diesen Cutscenes handelt es sich nicht um echte
    -- Cutscenes sondern um eine Simulation. Die Kamerabewegung wird
    -- dementsprechend nicht so flüssig sein und es kann ruckeln!
    --
    -- <p><b>Alias</b>: BriefingSystem.StartCutscene <br/></p>
    -- <p><b>Alias</b>: StartCutscene</p>
    --
    -- @param _briefing [table] Briefing
    -- @return [number] Briefing-ID
    -- @within Anwenderfunktionen
    --
    function API.StartCutscene(_briefing)
        -- Seitenweises abbrechen ist nicht erlaubt
        _briefing.skipPerPage = false;

        for i=1, #_briefing, 1 do
            -- Multiple Choice ist nicht erlaubt
            if _briefing[i].mc then
                API.Dbg("API.StartCutscene: Unallowed multiple choice at page " ..i.. " found!");
                return;
            end
            -- Marker sind nicht erlaubt
            if _briefing[i].marker then
                API.Dbg("API.StartCutscene: Unallowed marker at page " ..i.. " found!");
                return;
            end
            -- Pointer sind nicht erlaubt
            if _briefing[i].pointer then
                API.Dbg("API.StartCutscene: Unallowed pointer at page " ..i.. " found!");
                return;
            end
            -- Exploration ist nicht erlaubt
            if _briefing[i].explore then
                API.Dbg("API.StartCutscene: Unallowed explore at page " ..i.. " found!");
                return;
            end
        end
        return BriefingSystem.StartBriefing(_briefing, true);
    end
    BriefingSystem.StartCutscene = API.StartCutscene;
    StartCutscene = API.StartCutscene;

    ---
    -- Startet ein normales Briefing oder eine Fake-Cutscene.
    --
    -- Briefings können mittels Multiple Choice Dialogen über Verzweigungen
    -- verfügen und so komplexe Dialoge oder Menüstrukturen abbilden. Briefings
    -- sollten eingesetzt werden, wenn Quests nicht mehr ausreichen um die
    -- Handlung zu erzählen oder um multiple Handlungsstränge zu starten.
    --
    -- <p><b>Alias</b>: BriefingSystem.StartBriefing <br/></p>
    -- <p><b>Alias</b>: StartBriefing</p>
    --
    -- @param _briefing     [table] Briefing
    -- @param _cutsceneMode [boolean] Cutscene-Mode nutzen
    -- @return number: Briefing-ID
    -- @within Anwenderfunktionen
    --
    function API.StartBriefing(_briefing, _cutsceneMode)
        -- view wird nur Ausgeführt, wenn es sich um eine Cutscene handelt
        -- CutsceneMode = false -> alte Berechnung und Syntax
        _cutsceneMode = _cutsceneMode or false;
        Logic.ExecuteInLuaLocalState([[
            BriefingSystem.Flight.systemEnabled = ]]..tostring(not _cutsceneMode)..[[
        ]]);

        -- Briefing ID erzeugen
        BundleBriefingSystem.Global.Data.BriefingID = BundleBriefingSystem.Global.Data.BriefingID +1;
        _briefing.UniqueBriefingID = BundleBriefingSystem.Global.Data.BriefingID;

        if #_briefing > 0 then
            _briefing[1].duration = (_briefing[1].duration or 0) + 0.1;
        end

        -- Grenzsteine ausblenden
        if _briefing.hideBorderPins then
            Logic.ExecuteInLuaLocalState([[Display.SetRenderBorderPins(0)]]);
        end

        -- Himmel anzeigen
        if _briefing.showSky then
            Logic.ExecuteInLuaLocalState([[Display.SetRenderSky(1)]]);
        end

        -- Okklusion abschalten
        Logic.ExecuteInLuaLocalState([[
            Display.SetUserOptionOcclusionEffect(0)
        ]]);

        -- callback überschreiben
        _briefing.finished_Orig_QSB_Briefing = _briefing.finished;
        _briefing.finished = function(self)
            -- Grenzsteine einschalten
            if _briefing.hideBorderPins then
                Logic.ExecuteInLuaLocalState([[Display.SetRenderBorderPins(1)]]);
            end

            --
            if _briefing.showSky then
                Logic.ExecuteInLuaLocalState([[Display.SetRenderSky(0)]]);
            end

            -- Okklusion einschalten, wenn sie aktiv war
            Logic.ExecuteInLuaLocalState([[
                if Options.GetIntValue("Display", "Occlusion", 0) > 0 then
                    Display.SetUserOptionOcclusionEffect(1)
                end
            ]]);

            _briefing.finished_Orig_QSB_Briefing(self);
            BundleBriefingSystem.Global.Data.PlayedBriefings[_briefing.UniqueBriefingID] = true;
        end

        -- Briefing starten
        if BriefingSystem.isActive then
            table.insert(BriefingSystem.waitList, _briefing);
            if not BriefingSystem.waitList.Job then
                BriefingSystem.waitList.Job = StartSimpleJob("BriefingSystem_WaitForBriefingEnd");
            end
        else
            BriefingSystem.ExecuteBriefing(_briefing);
        end
        return BundleBriefingSystem.Global.Data.BriefingID;
    end
    BriefingSystem.StartBriefing = API.StartBriefing;
    StartBriefing = API.StartBriefing;

    ---
    -- Beendet ein laufendes Briefing oder eine laufende Fake-Cutscene.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.EndBriefing()
        BriefingSystem.isActive = false;
        Logic.SetGlobalInvulnerability(0);
        local briefing = BriefingSystem.currBriefing;
        BriefingSystem.currBriefing = nil;
        BriefingSystem[BriefingSystem.currBriefingIndex] = nil;
        Logic.ExecuteInLuaLocalState("BriefingSystem.EndBriefing()");
        EndJob(BriefingSystem.job);
        if briefing.finished then
            briefing:finished();
        end
    end

    ---
    -- Wartet, bis ein Briefing beendet ist und führt dann das nächste
    -- Briefing in der Warteschlange aus.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem_WaitForBriefingEnd()
        if not BriefingSystem.isActive and BriefingSystem.loadScreenHidden then
            BriefingSystem.ExecuteBriefing(table.remove(BriefingSystem.waitList), 1);
            if #BriefingSystem.waitList == 0 then
                BriefingSystem.waitList.Job = nil;
                return true;
            end
        end
    end

    ---
    -- Führt das aktuelle Briefing aus.
    --
    -- @param _briefing Aktuelles Briefing
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.ExecuteBriefing(_briefing)
        if not BriefingSystem.isInitialized then
            Logic.ExecuteInLuaLocalState("BriefingSystem.InitializeBriefingSystem()");
            BriefingSystem.isInitialized = true;
        end
        BriefingSystem.isActive = true;
        BriefingSystem.currBriefing = _briefing;
        BriefingSystem.currBriefingIndex = BriefingSystem.currBriefingIndex + 1;
        BriefingSystem[BriefingSystem.currBriefingIndex] = _briefing;
        BriefingSystem.timer = 0;
        BriefingSystem.page = 0;
        BriefingSystem.skipPlayers = {};
        BriefingSystem.disableSkipping = BriefingSystem.currBriefing.disableSkipping;
        BriefingSystem.activate3dOnScreenDisplay = BriefingSystem.currBriefing.activate3dOnScreenDisplay;
        BriefingSystem.skipAll = BriefingSystem.currBriefing.skipAll;
        BriefingSystem.skipPerPage = not BriefingSystem.skipAll and BriefingSystem.currBriefing.skipPerPage;

        if not _briefing.disableGlobalInvulnerability then
            Logic.SetGlobalInvulnerability(1);
        end

        Logic.ExecuteInLuaLocalState("BriefingSystem.PrepareBriefing()");
        BriefingSystem.currBriefing = BriefingSystem.UpdateMCAnswers(BriefingSystem.currBriefing);
        BriefingSystem.job = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "BriefingSystem_Condition_Briefing", "BriefingSystem_Action_Briefing", 1);
        if not BriefingSystem.loadScreenHidden then
            Logic.ExecuteInLuaLocalState("BriefingSystem.Briefing(true)");
        elseif BriefingSystem_Action_Briefing() then
            EndJob(BriefingSystem.job);
        end
    end

    ---
    -- Aktualisiert die verfügbaren Optionen wärhend eines Multiple Choice
    -- Dialogs.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.UpdateMCAnswers(_briefing)
        if _briefing then
            local i = 1;
            while (_briefing[i] ~= nil and #_briefing >= i)
            do
                if type(_briefing[i]) == "table" and _briefing[i].mc and _briefing[i].mc.answers then
                    local aswID = 1;
                    local j = 1;
                    while (_briefing[i].mc.answers[j] ~= nil)
                    do
                        -- Speichert die ID der Antwort
                        if not _briefing[i].mc.answers[j].ID then
                            _briefing[i].mc.answers[j].ID = aswID;
                        end

                        -- Entferne Antwort
                        if _briefing[i].mc.answers[j].remove then
                            table.remove(BriefingSystem.currBriefing[i].mc.answers, j);
                            if #BriefingSystem.currBriefing[i].mc.answers < j then
                                BriefingSystem.currBriefing[i].mc.current = #BriefingSystem.currBriefing[i].mc.answers
                            end
                            Logic.ExecuteInLuaLocalState([[
                                table.remove(BriefingSystem.currBriefing[]]..i..[[].mc.answers, ]]..j..[[)
                                if #BriefingSystem.currBriefing[]]..i..[[].mc.answers < ]]..j..[[ then
                                    BriefingSystem.currBriefing[]]..i..[[].mc.current = #BriefingSystem.currBriefing[]]..i..[[].mc.answers
                                end
                            ]]);
                        end

                        -- ID hochzählen
                        aswID = aswID +1;
                        j = j +1;
                    end
                    if #_briefing[i].mc.answers == 0 then
                        local lang = Network.GetDesiredLanguage();
                        _briefing[i].mc.answers[1] = {(lang == "de" and "ENDE") or "END", 999999};
                    end
                end
                i = i +1;
            end
        end
        return _briefing;
    end

    ---
    -- Prüft, ob ein Briefing aktiv ist.
    --
    -- <p><b>Alias:</b> IsBriefingActive</p>
    --
    -- @return boolean: Briefing aktiv
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.IsBriefingActive()
        return BriefingSystem.isActive;
    end
    IsBriefingActive = BriefingSystem.IsBriefingActive

    ---
    -- Condition des Briefing-Job: Prüft, ob die Action ausgeführt wird.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem_Condition_Briefing()
        if not BriefingSystem.loadScreenHidden then
            return false;
        end
        BriefingSystem.timer = BriefingSystem.timer - 0.1;
        return BriefingSystem.timer <= 0;
    end

    ---
    -- Action des Briefing-Job: Führt das eigentliche Briefing aus.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem_Action_Briefing()
        BriefingSystem.page = BriefingSystem.page + 1;

        local page;
        if BriefingSystem.currBriefing then
            page = BriefingSystem.currBriefing[BriefingSystem.page];
        end

        if not BriefingSystem.skipAll and not BriefingSystem.disableSkipping then
            for i = 1, 8 do
                if BriefingSystem.skipPlayers[i] ~= BriefingSystem.SKIPMODE_ALL then
                    BriefingSystem.skipPlayers[i] = nil;
                    if type(page) == "table" and page.skipping == false then
                        Logic.ExecuteInLuaLocalState("BriefingSystem.EnableBriefingSkipButton(" .. i .. ", false)");
                    else
                        Logic.ExecuteInLuaLocalState("BriefingSystem.EnableBriefingSkipButton(" .. i .. ", true)");
                    end
                end
            end
        end

        if not page or page == -1 then
            BriefingSystem.EndBriefing();
            return true;
        elseif type(page) == "number" and page > 0 then
            BriefingSystem.timer = 0;
            BriefingSystem.page  = page-1;
            return;
        end

        if page.mc then
            Logic.ExecuteInLuaLocalState('XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", 0)');
            BriefingSystem.currBriefing[BriefingSystem.page].duration = 99999999;
        else
            local nextPage = BriefingSystem.currBriefing[BriefingSystem.page+1];
            if not BriefingSystem.disableSkipping then
                Logic.ExecuteInLuaLocalState('XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", 1)');
            end
        end
        BriefingSystem.timer = page.duration or BriefingSystem.STANDARDTIME_PER_PAGE;

        if page.explore then
            page.exploreEntities = {};
            if type(page.explore) == "table" then
                if #page.explore > 0 or page.explore.default then
                    for pId = 1, 8 do
                        local playerExplore = page.explore[player] or page.explore.default;
                        if playerExplore then
                            if type(playerExplore) == "table" then
                                BriefingSystem.CreateExploreEntity(page, playerExplore.exploration, playerExplore.type or Entities[BriefingSystem.DEFAULT_EXPLORE_ENTITY], pId, playerExplore.position);
                            else
                                BriefingSystem.CreateExploreEntity(page, playerExplore, Entities[BriefingSystem.DEFAULT_EXPLORE_ENTITY], pId);
                            end
                        end
                    end
                else
                    BriefingSystem.CreateExploreEntity(page, page.explore.exploration, page.explore.type or Entities[BriefingSystem.DEFAULT_EXPLORE_ENTITY], 1, page.explore.position);
                end
            else
                BriefingSystem.CreateExploreEntity(page, page.explore, Entities[BriefingSystem.DEFAULT_EXPLORE_ENTITY], 1);
            end
        end
        if page.pointer then
            local pointer = page.pointer;
            page.pointerList = {};
            if type(pointer) == "table" then
                if #pointer > 0 then
                    for i = 1, #pointer do
                        BriefingSystem.CreatePointer(page, pointer[i]);
                    end
                else
                    BriefingSystem.CreatePointer(page, pointer);
                end
            else
                BriefingSystem.CreatePointer(page, { type = pointer, position = page.position or page.followEntity });
            end
        end
        if page.marker then
            BriefingSystem.maxMarkerListEntry = BriefingSystem.maxMarkerListEntry + 1;
            page.markerList = BriefingSystem.maxMarkerListEntry;
        end
        Logic.ExecuteInLuaLocalState("BriefingSystem.Briefing()");
        if page.action then
            if page.actionArg and #page.actionArg > 0 then
                page:action(unpack(page.actionArg));
            else
                page:action();
            end
        end
    end

    ---
    -- Überspringt ein Briefing.
    --
    -- @param _player ID des aktiven Spielers
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.SkipBriefing(_player)
        if not BriefingSystem.disableSkipping then
            if BriefingSystem.skipPerPage then
                BriefingSystem.SkipBriefingPage(_player);
                return;
            end
            BriefingSystem.skipPlayers[_player] = BriefingSystem.SKIPMODE_ALL;
            for i = 1, 8, 1 do
                if Logic.PlayerGetIsHumanFlag(i) and BriefingSystem.skipPlayers[i] ~= BriefingSystem.SKIPMODE_ALL then
                    Logic.ExecuteInLuaLocalState("BriefingSystem.EnableBriefingSkipButton(" .. _player .. ", false)");
                    return;
                end
            end
            EndJob(BriefingSystem.job);
            BriefingSystem.EndBriefing();
        end
    end

    ---
    -- Überspringt eine Briefing-Seite.
    --
    -- @param _player ID des aktiven Spielers
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.SkipBriefingPage(_player)
        if not BriefingSystem.disableSkipping then
            if not BriefingSystem.LastSkipTimeStemp or Logic.GetTimeMs() > BriefingSystem.LastSkipTimeStemp + 500 then
                BriefingSystem.LastSkipTimeStemp = Logic.GetTimeMs();
                if not BriefingSystem.skipPlayers[_player] then
                    BriefingSystem.skipPlayers[_player] = BriefingSystem.SKIPMODE_PERPAGE;
                end
                for i = 1, 8, 1 do
                    if Logic.PlayerGetIsHumanFlag(_player) and not BriefingSystem.skipPlayers[_player] then
                        if BriefingSystem.skipPerPage then
                            Logic.ExecuteInLuaLocalState("BriefingSystem.EnableBriefingSkipButton(" .. _player .. ", false)");
                        end
                        return;
                    end
                end
                if BriefingSystem.skipAll then
                    BriefingSystem.SkipBriefing(_player);
                elseif BriefingSystem_Action_Briefing() then
                    EndJob(BriefingSystem.job);
                end
            end
        end
    end

    ---
    -- Deckt einen bestimmten Bereich auf der Spielwelt auf.
    -- FIXME: Diese Funktion deckt komplette Territorien auf!
    --
    -- @param _page        Aktuelle Seite
    -- @param _exploration Aufdeckungsradius
    -- @param _entityType  Typ des Exploration Entity
    -- @param _player      PlayerID, für die aufgedeckt wird
    -- @param _position    Mittelpunkt der Aufdeckung
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.CreateExploreEntity(_page, _exploration, _entityType, _player, _position)
        local position = _position or _page.position;
        if position then
            if type(position) == "table" and (position[_player] or position.default or position.playerPositions) then
                position = position[_player] or position.default;
            end
            if position then
                local tPosition = type(position);
                if tPosition == "string" or tPosition == "number" then
                    position = GetPosition(position);
                end
            end
        end
        if not position then
            local followEntity = _page.followEntity;
            if type(followEntity) == "table" then
                followEntity = followEntity[_player] or followEntity.default;
            end
            if followEntity then
                position = GetPosition(followEntity);
            end
        end
        assert(position);
        local entity = Logic.CreateEntity(_entityType, position.X, position.Y, 0, _player);
        assert(entity ~= 0);
        Logic.SetEntityExplorationRange(entity, _exploration / 100);
        table.insert(_page.exploreEntities, entity);
    end

    ---
    -- Erstellt einen Questmarker auf der Spielwelt.
    --
    -- @param _page    Aktuelle Seite
    -- @param _pointer Aufdeckungsradius
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.CreatePointer(_page, _pointer)
        local pointerType = _pointer.type or BriefingSystem.POINTER_VERTICAL;
        local position = _pointer.position;
        assert(position);
        if pointerType / BriefingSystem.POINTER_VERTICAL >= 1 then
            local entity = position;
            if type(position) == "table" then
                local _;
                _, entity = Logic.GetEntitiesInArea(0, position.X, position.Y, 50, 1);
            else
                position = GetPosition(position);
            end
            local effectType = EGL_Effects.E_Questmarker_low;
            if pointerType == BriefingSystem.POINTER_VERTICAL_HIGH then
                effectType = EGL_Effects.E_Questmarker;
            elseif pointerType ~= BriefingSystem.POINTER_VERTICAL_LOW then
                if entity ~= 0 then
                    if Logic.IsBuilding(entity) == 1 then
                        pointerType = EGL_Effects.E_Questmarker;
                    end
                end
            end
            table.insert(_page.pointerList, { id = Logic.CreateEffect(effectType, position.X, position.Y, _pointer.player or 0), type = pointerType });
        else
            assert(pointerType == BriefingSystem.POINTER_HORIZONTAL);
            if type(position) ~= "table" then
                position = GetPosition(position);
            end
            table.insert(_page.pointerList, { id = Logic.CreateEntityOnUnblockedLand(Entities.E_DirectionMarker, position.X, position.Y, _pointer.orientation or 0, _pointer.player or 0), type = pointerType });
        end
    end

    ---
    -- Zerstört den Marker der aktuellen Briefing-Seite.
    --
    -- @param _page  Aktuelle Seite
    -- @param _index Index des Markers
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.DestroyPageMarker(_page, _index)
        if _page.marker then
            Logic.ExecuteInLuaLocalState("BriefingSystem.DestroyPageMarker(" .. _page.markerList .. ", " .. _index .. ")");
        end
    end

    ---
    -- Aktualisiert alle Marker der Briefing-Seite oder erstellt sie neu.
    --
    -- @param _page     Aktuelle Seite
    -- @param _position Position des markers
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.RedeployPageMarkers(_page, _position)
        if _page.marker then
            if type(_position) ~= "table" then
                _position = GetPosition(_position);
            end
            Logic.ExecuteInLuaLocalState("BriefingSystem.RedeployMarkerList(" .. _page.markerList .. ", " .. _position.X .. ", " .. _position.Y .. ")");
        end
    end

    ---
    -- Aktualisiert einen Marker der Briefing-Seite oder erstellt ihn neu.
    --
    -- @param _page     Aktuelle Seite
    -- @param _index Index des Markers
    -- @param _position Position des markers
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.RedeployPageMarker(_page, _index, _position)
        if _page.marker then
            if type(_position) ~= "table" then
                _position = GetPosition(_position);
            end
            Logic.ExecuteInLuaLocalState("BriefingSystem.RedeployMarkerOfList(" .. _page.markerList .. ", " .. _index .. ", " .. _position.X .. ", " .. _position.Y .. ")");
        end
    end

    ---
    -- Erneuert alle Marker der Briefing-Seite.
    --
    -- @param _page     Aktuelle Seite
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.RefreshPageMarkers(_page)
        if _page.marker then
            Logic.ExecuteInLuaLocalState("BriefingSystem.RefreshMarkerList(" .. _page.markerList .. ")");
        end
    end

    ---
    -- Erneuert einen Marker der Briefing-Seite.
    --
    -- @param _page     Aktuelle Seite
    -- @param _index Index des Markers
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.RefreshPageMarker(_page, _index)
        if _page.marker then
            Logic.ExecuteInLuaLocalState("BriefingSystem.RefreshMarkerOfList(" .. _page.markerList .. ", " .. _index .. ")");
        end
    end

    ---
    -- Entfernt alle Effekte, die mit der Briefing-Seite verbunden sind.
    --
    -- Effekte können sein: Aufdeckungsbereiche, Marker, Pointer.
    --
    -- @param _page     Aktuelle Seite
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.ResolveBriefingPage(_page)
        if _page.explore and _page.exploreEntities then
            for i, v in ipairs(_page.exploreEntities) do
                Logic.DestroyEntity(v);
            end
            _page.exploreEntities = nil;
        end
        if _page.pointer and _page.pointerList then
            for i, v in ipairs(_page.pointerList) do
                if v.type ~= BriefingSystem.POINTER_HORIZONTAL then
                    Logic.DestroyEffect(v.id);
                else
                    Logic.DestroyEntity(v.id);
                end
            end
            _page.pointerList = nil;
        end
        if _page.marker and _page.markerList then
            Logic.ExecuteInLuaLocalState("BriefingSystem.DestroyMarkerList(" .. _page.markerList .. ")");
            _page.markerList = nil;
        end
    end
    ResolveBriefingPage = BriefingSystem.ResolveBriefingPage;

    ---
    -- Wenn eine Antwort ausgewählt wurde, wird der entsprechende
    -- Sprung durchgeführt. Wenn remove = true ist, wird die Option
    -- für den Rest des Briefings deaktiviert (für Rücksprünge).
    --
    -- @param _aswID			Index der Antwort
    -- @param _currentPage		Aktuelle Seite
    -- @param _currentAnswer	Gegebene Antwort
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.OnConfirmed(_aswID, _currentPage, _currentAnswer)
        BriefingSystem.timer = 0
        local page = BriefingSystem.currBriefing[BriefingSystem.page];
        local pageNumber = BriefingSystem.page;
        local current = _currentPage;
        local jump = page.mc.answers[current][2];
        BriefingSystem.currBriefing[pageNumber].mc.given = _aswID;
        if type(jump) == "function" then
            BriefingSystem.page = jump(page.mc.answers[_currentAnswer])-1;
        else
            BriefingSystem.page = jump-1;
        end
        BriefingSystem.currBriefing = BriefingSystem.UpdateMCAnswers(BriefingSystem.currBriefing);
    end

    ---
    -- Diese Funktion wird aufgerufen, wenn der Spieler während eines
    -- Briefings auf ein Entity klickt.
    --
    -- @param _EntityID	Selected Entity
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.LeftClickOnEntity(_EntityID)
        if _EntityID == nil then
            return;
        end
        if BriefingSystem.IsBriefingActive == false then
            return;
        end
        local Page = BriefingSystem.currBriefing[BriefingSystem.page];
        if Page.entityClicked then
            Page:entityClicked(_EntityID);
        end
    end

    ---
    -- Diese Funktion wird aufgerufen, wenn der Spieler während eines
    -- Briefings in die Spielwelt klickt.
    --
    -- @param _X X-Position
    -- @param _Y Y-Position
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.LeftClickOnPosition(_X, _Y)
        if _X == nil or _Y == nil then
            return;
        end
        if BriefingSystem.IsBriefingActive == false then
            return;
        end
        local Page = BriefingSystem.currBriefing[BriefingSystem.page];
        if Page.positionClicked then
            Page:positionClicked(_X, _Y);
        end
    end

    ---
    -- Diese Funktion wird aufgerufen, wenn der Spieler während eines
    -- Briefings auf die Anzeige klickt.
    --
    -- @param _X X-Position
    -- @param _Y Y-Position
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.LeftClickOnScreen(_X, _Y)
        if _X == nil or _Y == nil then
            return;
        end
        if BriefingSystem.IsBriefingActive == false then
            return;
        end
        local Page = BriefingSystem.currBriefing[BriefingSystem.page];
        if Page.screenClicked then
            Page:screenClicked(_X, _Y);
        end
    end
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:Install()
    self:InitalizeBriefingSystem();
end

---
-- Initalisiert das Briefing System im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleBriefingSystem.Local:InitalizeBriefingSystem()
    GameCallback_GUI_SelectionChanged_Orig_QSB_Briefing = GameCallback_GUI_SelectionChanged;
    GameCallback_GUI_SelectionChanged = function(_Source)
        GameCallback_GUI_SelectionChanged_Orig_QSB_Briefing(_Source);
        if IsBriefingActive() then
            GUI.ClearSelection();
        end
    end

    -- ---------------------------------------------------------------------- --

    DBlau     = "{@color:70,70,255,255}";
    Blau     = "{@color:153,210,234,255}";
    Weiss     = "{@color:255,255,255,255}";
    Rot         = "{@color:255,32,32,255}";
    Gelb       = "{@color:244,184,0,255}";
    Gruen     = "{@color:173,255,47,255}";
    Orange      = "{@color:255,127,0,255}";
    Mint      = "{@color:0,255,255,255}";
    Grau     = "{@color:180,180,180,255}";
    Trans     = "{@color:0,0,0,0}";

    if not InitializeFader then
        Script.Load("Script\\MainMenu\\Fader.lua");
    end

    BriefingSystem = {
        listOfMarkers = {},
        markerUniqueID = 2 ^ 10,
        Flight = {systemEnabled = true},
        InformationTextQueue = {},
    };

    ---
    -- Initalisiert den Kern des Briefing System.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.InitializeBriefingSystem()
        BriefingSystem.GlobalSystem = Logic.CreateReferenceToTableInGlobaLuaState("BriefingSystem");
        assert(BriefingSystem.GlobalSystem);
        if not BriefingSystem.GlobalSystem.loadScreenHidden then
            BriefingSystem.StartLoadScreenSupervising();
        end
        -- Escape deactivated to avoid errors with mc briefings
        BriefingSystem.GameCallback_Escape = GameCallback_Escape;
        GameCallback_Escape = function()
            if not BriefingSystem.IsBriefingActive() then
                BriefingSystem.GameCallback_Escape();
            end
        end
        BriefingSystem.Flight.Job = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "ThroneRoomCameraControl", 0);
    end

    ---
    -- Startet den Job, der darauf wartet, dass der Loadscreen verlassen wird.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.StartLoadScreenSupervising()
        if not BriefingSystem_LoadScreenSupervising() then
            Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "BriefingSystem_LoadScreenSupervising", 1);
        end
    end

    ---
    -- Setzt das LoadScreenHidden-Flag um dem globalen Skript mitzuteilen,
    -- das der Loadscreen verlassen ist.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem_LoadScreenSupervising()
        if  XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 0 then
            GUI.SendScriptCommand("BriefingSystem.loadScreenHidden = true;");
            return true;
        end
    end

    ---
    -- Bereitet das Interface auf das Briefing / die Cutsene vor.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.PrepareBriefing()
        BriefingSystem.barType = nil;
        BriefingSystem.InformationTextQueue = {};
        BriefingSystem.currBriefing = BriefingSystem.GlobalSystem[BriefingSystem.GlobalSystem.currBriefingIndex];
        Trigger.EnableTrigger(BriefingSystem.Flight.Job);

        local isLoadScreenVisible = XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 1;
        if isLoadScreenVisible then
            XGUIEng.PopPage();
        end
        if BriefingSystem.GlobalSystem.activate3dOnScreenDisplay ~= true then
            XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", 0);
        end
        XGUIEng.ShowWidget("/InGame/Root/Normal", 0);
        XGUIEng.ShowWidget("/InGame/ThroneRoom", 1);
        XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", BriefingSystem.GlobalSystem.disableSkipping and 0 or 1);
        BriefingSystem.EnableBriefingSkipButton(nil, true);
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
        XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text", " ");
        XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Title", " ");
        XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", " ");

        -- page.information Text
        local screen = {GUI.GetScreenSize()};
        local yAlign = 350 * (screen[2]/1080);
        XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo", 1);
        XGUIEng.ShowAllSubWidgets("/InGame/ThroneRoom/KnightInfo", 0);
        XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/Text", 1);
        XGUIEng.PushPage("/InGame/ThroneRoom/KnightInfo", false);
        XGUIEng.SetText("/InGame/ThroneRoom/KnightInfo/Text", "Horst Hackebeil");
        XGUIEng.SetTextColor("/InGame/ThroneRoom/KnightInfo/Text", 255, 255, 255, 255);
        XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/KnightInfo/Text", 100, yAlign);

        local page = BriefingSystem.currBriefing[1];
        BriefingSystem.SetBriefingPageOrSplashscreen(page);
        BriefingSystem.SetBriefingPageTextPosition(page);

        if not Framework.IsNetworkGame() and Game.GameTimeGetFactor() ~= 0 then
            if BriefingSystem.currBriefing.restoreGameSpeed and not BriefingSystem.currBriefing.gameSpeedBackup then
                BriefingSystem.currBriefing.gameSpeedBackup = Game.GameTimeGetFactor();
            end
            Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
        end
        if BriefingSystem.currBriefing.restoreCamera then
            BriefingSystem.cameraRestore = { Camera.RTS_GetLookAtPosition() };
        end
        BriefingSystem.selectedEntities = { GUI.GetSelectedEntities() };
        GUI.ClearSelection();
        GUI.ForbidContextSensitiveCommandsInSelectionState();
        GUI.ActivateCutSceneState();
        GUI.SetFeedbackSoundOutputState(0);
        GUI.EnableBattleSignals(false);
        Mouse.CursorHide();
        Camera.SwitchCameraBehaviour(5);
        Input.CutsceneMode();
        InitializeFader();
        g_Fade.To = 0;
        SetFaderAlpha(0);

        if isLoadScreenVisible then
            XGUIEng.PushPage("/LoadScreen/LoadScreen", false);
        end
        if BriefingSystem.currBriefing.hideFoW then
            Display.SetRenderFogOfWar(0);
            GUI.MiniMap_SetRenderFogOfWar(0);
        end
    end

    ---
    -- Baut die Änderungen im Interface nach dem Ende des Briefings ab.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.EndBriefing()
        if BriefingSystem.faderJob then
            Trigger.UnrequestTrigger(BriefingSystem.faderJob);
            BriefingSystem.faderJob = nil;
        end
        if BriefingSystem.currBriefing.hideFoW then
            Display.SetRenderFogOfWar(1);
            GUI.MiniMap_SetRenderFogOfWar(1);
        end

        g_Fade.To = 0;
        SetFaderAlpha(0);
        XGUIEng.PopPage();
        Display.UseStandardSettings();
        Input.GameMode();
        local x, y = Camera.ThroneRoom_GetPosition();
        Camera.SwitchCameraBehaviour(0);
        Camera.RTS_SetLookAtPosition(x, y);
        Mouse.CursorShow();
        GUI.EnableBattleSignals(true);
        GUI.SetFeedbackSoundOutputState(1);
        GUI.activate3dOnScreenDisplayState();
        GUI.PermitContextSensitiveCommandsInSelectionState();
        for _, v in ipairs(BriefingSystem.selectedEntities) do
            if not Logic.IsEntityDestroyed(v) then
                GUI.SelectEntity(v);
            end
        end
        if BriefingSystem.currBriefing.restoreCamera then
            Camera.RTS_SetLookAtPosition(unpack(BriefingSystem.cameraRestore));
        end
        if not Framework.IsNetworkGame() then
            local GameSpeed = (BriefingSystem.currBriefing.gameSpeedBackup or 1);
            Game.GameTimeSetFactor(GUI.GetPlayerID(), GameSpeed);
        end

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
        Trigger.DisableTrigger(BriefingSystem.Flight.Job);

        BriefingSystem.ConvertInformationToNote();
    end

    ---
    -- Führt das Briefing aus.
    --
    -- @param _prepareBriefingStart Briefing muss vorbereitet werden
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.Briefing(_prepareBriefingStart)
        if not _prepareBriefingStart then
            if BriefingSystem.faderJob then
                Trigger.UnrequestTrigger(BriefingSystem.faderJob);
                BriefingSystem.faderJob = nil;
            end
        end
        local page = BriefingSystem.currBriefing[_prepareBriefingStart and 1 or BriefingSystem.GlobalSystem.page];
        if not page then
            return;
        end
        local barStyle = page.barStyle;
        if barStyle == nil then
            barStyle = BriefingSystem.currBriefing.barStyle;
        end

        BriefingSystem.SetBriefingPageOrSplashscreen(page, barStyle);
        BriefingSystem.SetBriefingPageTextPosition(page);

        local player = GUI.GetPlayerID();

        -- Text
        if page.text then
            local doNotCalc = page.duration ~= nil;
            local smallBarShown = ((barStyle == "small" or barStyle == "transsmall") and not page.splashscreen);
            if type(page.text) == "string" then
                BriefingSystem.ShowBriefingText(page.text, doNotCalc, smallBarShown);
            elseif page.text[player] or page.text.default then
                for i = 1, player do
                    if page.text[i] and Logic.GetIsHumanFlag(i) then
                        doNotCalc = true;
                    end
                end
                BriefingSystem.ShowBriefingText(page.text[player] or page.text.default, doNotCalc, smallBarShown);
            end
        end

        -- Titel
        if page.title then
            if type(page.title) == "string" then
                BriefingSystem.ShowBriefingTitle(page.title);
            elseif page.title[player] or page.title.default then
                BriefingSystem.ShowBriefingTitle(page.title[player] or page.title.default);
            end
        end

        -- Multiple Choice
        if page.mc then
            BriefingSystem.Briefing_MultipleChoice();
        end

        -- Splashscreen UV
        local UV0, UV1;
        if type(page.splashscreen) == "table" then
            if page.splashscreen.uv then
                UV0 = {page.splashscreen.uv[1], page.splashscreen.uv[2]};
                UV1 = {page.splashscreen.uv[3], page.splashscreen.uv[4]};
            end
        end

        if not _prepareBriefingStart then
            if page.faderAlpha then
                if type(page.faderAlpha) == "table" then
                    g_Fade.To = page.faderAlpha[player] or page.faderAlpha.default or 0;
                else
                    g_Fade.To = page.faderAlpha;
                end
                g_Fade.Duration = 0;
            end
            if page.fadeIn then
                local fadeIn = page.fadeIn;
                if type(fadeIn) == "table" then
                    fadeIn = fadeIn[player] or fadeIn.default;
                end
                if type(fadeIn) ~= "number" then
                    fadeIn = page.duration;
                    if not fadeIn then
                        fadeIn = BriefingSystem.timer;
                    end
                end
                if fadeIn < 0 then
                    BriefingSystem.faderJob = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "BriefingSystem_CheckFader", 1, {}, { 1, math.abs(fadeOut) });
                else
                    FadeIn(fadeIn);
                end
            end
            if page.fadeOut then
                local fadeOut = page.fadeOut;
                if type(fadeOut) == "table" then
                    fadeOut = fadeOut[player] or fadeOut.default;
                end
                if type(fadeOut) ~= "number" then
                    fadeOut = page.duration;
                    if not fadeOut then
                        fadeOut = BriefingSystem.timer;
                    end
                end
                if fadeOut < 0 then
                    BriefingSystem.faderJob = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "BriefingSystem_CheckFader", 1, {}, { 0, math.abs(fadeOut) });
                else
                    FadeOut(fadeOut);
                end
            end
        else
            local faderValue = (page.fadeOut and 0) or (page.fadeIn and 1) or page.faderValue;
            if faderValue then
                g_Fade.To = faderValue;
                g_Fade.Duration = 0;
            end

        end
        local dialogCamera = page.dialogCamera;
        if type(dialogCamera) == "table" then
            dialogCamera = dialogCamera[player];
            if dialogCamera == nil then
                dialogCamera = page.dialogCamera.default;
            end
        end
        dialogCamera = dialogCamera and "DLG" or "";

        local rotation = page.rotation or BriefingSystem.GlobalSystem["BRIEFING_" .. dialogCamera .. "CAMERA_ROTATIONDEFAULT"];
        if type(rotation) == "table" then
            rotation = rotation[player] or rotation.default;
        end
        local angle = page.angle or BriefingSystem.GlobalSystem["BRIEFING_" .. dialogCamera .. "CAMERA_ANGLEDEFAULT"];
        if type(angle) == "table" then
            angle = angle[player] or angle.default;
        end
        local zoom = page.zoom or BriefingSystem.GlobalSystem["BRIEFING_" .. dialogCamera .. "CAMERA_ZOOMDEFAULT"];
        if type(zoom) == "table" then
            zoom = zoom[player] or zoom.default;
        end
        local FOV = page.FOV or BriefingSystem.GlobalSystem["BRIEFING_" .. dialogCamera .. "CAMERA_FOVDEFAULT"];
        BriefingSystem.CutsceneStopFlight();
        BriefingSystem.StopFlight();

        -- Initialisierung der Kameraanimation
        if page.cutscene then
            -- Flight speichern
            if BriefingSystem.GlobalSystem.page == 1 then
                BriefingSystem.CutsceneSaveFlight(page.cutscene.Position, page.cutscene.LookAt, FOV);
            end
            -- Kamera bewegen
            BriefingSystem.CutsceneFlyTo(page.cutscene.Position,
                                         page.cutscene.LookAt,
                                         FOV,
                                         page.flyTime or 0);

        elseif page.position then
            local position = page.position;
            if type(position) == "table" and (position[player] or position.default or position.playerPositions) then
                position = position[player] or position.default;
            end
            if position then
                local ttype = type(position);
                if ttype == "string" or ttype == "number" then
                    position = GetPosition(position);
                elseif ttype == "table" then
                    position = { X = position.X, Y = position.Y, Z = position.Z};
                end

                -- Z-Achsen-Fix
                local height = position.Z or Display.GetTerrainHeight(position.X,position.Y);
                if page.zOffset then
                    height = height + page.zOffset;
                end
                position.Z = height;

                Display.SetCameraLookAtEntity(0);

                if BriefingSystem.GlobalSystem.page == 1 then
                    BriefingSystem.SaveFlight(position, rotation, angle, zoom, FOV, UV0, UV1);
                end
                BriefingSystem.FlyTo(position, rotation, angle, zoom, FOV, page.flyTime or BriefingSystem.GlobalSystem.BRIEFING_FLYTIME, UV0, UV1);
            end

        elseif page.followEntity then
            local followEntity = page.followEntity;
            if type(followEntity) == "table" then
                followEntity = followEntity[player] or followEntity.default;
            end
            followEntity = GetEntityId(followEntity);
            Display.SetCameraLookAtEntity(followEntity);

            local pos = GetPosition(followEntity);
            pos.Z = pos.Z or nil;
            local height = Display.GetTerrainHeight(pos.X,pos.Y);
            if page.zOffset then
                height = height + page.zOffset;
            end
            pos.Z = height;

            if BriefingSystem.GlobalSystem.page == 1 then
                BriefingSystem.SaveFlight(pos, rotation, angle, zoom, FOV, UV0, UV1);
            end
            BriefingSystem.FollowFlight(followEntity, rotation, angle, zoom, FOV, page.flyTime or 0, height, UV0, UV1);
        end

        if not _prepareBriefingStart then
            if page.marker then
                local marker = page.marker;
                if type(marker) == "table" then
                    if #marker > 0 then
                        for _, v in ipairs(marker) do
                            if not v.player or v.player == GUI.GetPlayerID() then
                                BriefingSystem.CreateMarker(v, v.type, page.markerList, v.display, v.R, v.G, v.B, v.Alpha);
                            else
                                table.insert(BriefingSystem.listOfMarkers[page.markerList], {});
                            end
                        end
                    else
                        if not v.player or v.player == GUI.GetPlayerID() then
                            BriefingSystem.CreateMarker(marker, marker.type, page.markerList, marker.display, marker.R, marker.G, marker.B, marker.Alpha);
                        else
                            table.insert(BriefingSystem.listOfMarkers[page.markerList], {});
                        end
                    end
                else
                    BriefingSystem.CreateMarker(page, marker, page.markerList);
                end
            end
        end
    end

    ---
    -- Callback: Überspringen wurde geklickt.
    --
    -- @local
    --
    function OnSkipButtonPressed()
        local index = BriefingSystem.GlobalSystem.page;
        if BriefingSystem.currBriefing[index] and not BriefingSystem.currBriefing[index].mc then
            GUI.SendScriptCommand("BriefingSystem.SkipBriefing(" .. GUI.GetPlayerID() .. ")");
        end
    end

    ---
    -- Überspringt eine Briefing-Seite.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.SkipBriefingPage()
        local index = BriefingSystem.GlobalSystem.page;
        if BriefingSystem.currBriefing[index] and not BriefingSystem.currBriefing[index].mc then
            GUI.SendScriptCommand("BriefingSystem.SkipBriefingPage(" .. GUI.GetPlayerID() .. ")");
        end
    end

    ---
    -- Zeigt die Rahmen an. Dabei gibt es schmale Rahmen, breite Rahmen
    -- und jeweils noch transparente Versionen. Es kann auch gar kein
    -- Rahmen angezeigt werden.
    --
    -- @param _type	Typ der Bar
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.ShowBriefingBar(_type)
        _type = _type or "big";
        -- set overwrite
        if _type == nil then
            _type = BriefingSystem.currBriefing.barStyle;
        end
        assert(_type == 'big' or _type == 'small' or _type == 'nobar' or _type == 'transbig' or _type == 'transsmall');
        -- set bars
        local flag_big = (_type == "big" or _type == "transbig") and 1 or 0;
        local flag_small = (_type == "small" or _type == "transsmall") and 1 or 0;
        local alpha = (_type == "transsmall" or _type == "transbig") and 100 or 255;
        if _type == 'nobar' then
            flag_small = 0;
            flag_big = 0;
        end

        XGUIEng.ShowWidget("/InGame/ThroneRoomBars", flag_big);
        XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", flag_small);
        XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", flag_big);
        XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", flag_small);

        XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarBottom", 1, alpha);
        XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarTop", 1, alpha);
        XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarBottom", 1, alpha);
        XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarTop", 1, alpha);

        BriefingSystem.barType = _type;
    end

    ---
    -- Zeigt den Text einer Briefingseite an und berechnet ggf. die Dauer
    -- der Anzeige.
    --
    -- @param _text      Anzuzeigender Text
    -- @param _doNotCalc Anzeigedauer nicht berechnen
    -- @param _smallBar  Die schmalen bars werden benutzt
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.ShowBriefingText(_text, _doNotCalc, _smallBar)
        local text = XGUIEng.GetStringTableText(_text);
        if text == "" then
            text = _text;
        end
        if not _doNotCalc then
            GUI.SendScriptCommand("BriefingSystem.timer = " .. (BriefingSystem.GlobalSystem.STANDARDTIME_PER_PAGE + BriefingSystem.GlobalSystem.SECONDS_PER_CHAR * string.len(text)) .. ";");
        end
        if _smallBar then
            text = "{cr}{cr}{cr}" .. text;
        end
        XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Text", 1);
        XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text", "{center}"..text);
    end

    ---
    -- Zeigt den Titel aka Sprecher der Seite an.
    --
    -- @param _title Anzuzeigender Titel
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.ShowBriefingTitle(_title)
        local title = XGUIEng.GetStringTableText(_title);
        if title == "" then
            title = _title;
        end
        if BriefingSystem.GlobalSystem and string.sub(title, 1, 1) ~= "{" then
            title = BriefingSystem.GlobalSystem.COLOR1 .. "{center}{darkshadow}" .. title;
        end
        XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", 1);
        XGUIEng.SetText("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", title);
    end

    ---
    -- Zeigt den Multiple Choice Dialog mit den Verzweigungen an.
    --
    -- @param _page Briefing-Seite
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.SchowBriefingOptionDialog(_page)
        local Screen = {GUI.GetScreenSize()};
        local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
        BriefingSystem.OriginalBoxPosition = {
            XGUIEng.GetWidgetScreenPosition(Widget)
        };

        local listbox = XGUIEng.GetWidgetID(Widget .. "/ListBox");
        XGUIEng.ListBoxPopAll(listbox);
        for i=1, _page.mc.amount, 1 do
            if _page.mc.answers[i] then
                XGUIEng.ListBoxPushItem(listbox, _page.mc.answers[i][1]);
            end
        end
        XGUIEng.ListBoxSetSelectedIndex(listbox, 0);

        local wSize = {XGUIEng.GetWidgetScreenSize(Widget)};
        local xFactor = (Screen[1]/1920);
        local xFix = math.ceil((Screen[1]/2) - (wSize[1] /2));
        local yFix = math.ceil(Screen[2] - (wSize[2]-20));
        XGUIEng.SetWidgetScreenPosition(Widget, xFix, yFix);
        XGUIEng.PushPage(Widget, false);
        XGUIEng.ShowWidget(Widget, 1);

        BriefingSystem.MCSelectionIsShown = true;
    end

    --
    -- Zeigt alle Nachrichten in der Warteschlange an und schreibt
    -- sie in das KnightInfo Widget.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.ShowBriefingInfoText()
        XGUIEng.SetText("/InGame/ThroneRoom/KnightInfo/Text", "");
        local text = "";
        for i=1, #BriefingSystem.InformationTextQueue do
            text = text .. BriefingSystem.InformationTextQueue[i][1] .. "{cr}";
        end
        XGUIEng.SetText("/InGame/ThroneRoom/KnightInfo/Text", text);
    end

    ---
    -- Konvertiert die Notizen zu einer Debug Note und zeigt sie im
    -- Debug Window an. Dies passiert dann, wenn ein Briefing endet
    -- aber die Anzeigezeit einer oder mehrerer Nachrichten noch nicht
    -- abgelaufen ist.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.ConvertInformationToNote()
        for i=1, #BriefingSystem.InformationTextQueue do
            GUI.AddNote(BriefingSystem.InformationTextQueue[i][1]);
        end
    end

    ---
    -- Fügt einen text in die Warteschlange ein.
    --
    -- @param _Text	    Nachricht
    -- @param _Duration Anzeigedauer
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.PushInformationText(_Text, _Duration)
        local length = _Duration or (string.len(_Text) * 5);
        table.insert(BriefingSystem.InformationTextQueue, {_Text, length});
    end

    ---
    -- Entfernt einen Text aus der Warteschlange.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.UnqueueInformationText(_Index)
        if #BriefingSystem.InformationTextQueue >= _Index then
            table.remove(BriefingSystem.InformationTextQueue, _Index);
        end
    end

    ---
    -- Kontrolliert die Anzeige der Notizen während eines Briefings.
    -- Die Nachrichten werden solange angezeigt, wie ihre Anzeigezeit
    -- noch nicht abgelaufen ist.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.ControlInformationText()
        local LinesToDelete = {};

        -- Abgelaufene Texte markieren
        for k, v in pairs(BriefingSystem.InformationTextQueue) do
            BriefingSystem.InformationTextQueue[k][2] = v[2] -1;
            if v[2] <= 0 then
                table.insert(LinesToDelete, k);
            end
        end

        -- Abgelaufene Texte entfernen
        for k, v in pairs(LinesToDelete) do
            BriefingSystem.UnqueueInformationText(v);
        end

        BriefingSystem.ShowBriefingInfoText();
    end

    ---
    -- Setzt den Text, den Titel und die Antworten einer Multiple Choice
    -- Seite. Setzt außerdem die Dauer der Seite auf 11 1/2 Tage (in
    -- der echten Welt). Leider ist es ohne größeren Änderungen nicht
    -- möglich die Anzeigezeit einer Seite auf unendlich zu setzen.
    -- Es ist aber allgemein unwahrscheinlich, dass der Spieler 11,5
    -- Tage vor dem Briefing sitzt, ohne etwas zu tun.
    -- Das Fehlverhalten in diesem Fall ist unerforscht. Es würde dann
    -- wahrscheinlich die 1 Antwort selektiert.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.Briefing_MultipleChoice()
        local page = BriefingSystem.currBriefing[BriefingSystem.GlobalSystem.page];

        if page and page.mc then
            -- set title
            if page.mc.title then
                BriefingSystem.ShowBriefingTitle(page.mc.title);
            end
            -- set text
            if page.mc.text then
                BriefingSystem.ShowBriefingText(page.mc.text, true);
            end
            -- set answers
            if page.mc.answers then
                BriefingSystem.SchowBriefingOptionDialog(page);
            end
            -- set page length
            GUI.SendScriptCommand("BriefingSystem.currBriefing[BriefingSystem.page].dusation = 999999");
        end
    end

    ----
    -- Eine Antwort wurde ausgewählt (lokales Skript). Die Auswahl wird
    -- gepopt und ein Event an das globale Skript gesendet. Das Event
    -- erhält die Page ID, den Index der selektierten Antwort in der
    -- Listbox und die reale ID der Antwort in der Table.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.OnConfirmed()
        local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
        local Position = BriefingSystem.OriginalBoxPosition;
        XGUIEng.SetWidgetScreenPosition(Widget, Position[1], Position[2]);
        XGUIEng.ShowWidget(Widget, 0);
        XGUIEng.PopPage();

        local page = BriefingSystem.currBriefing[BriefingSystem.GlobalSystem.page];
        if page.mc then
            local index  = BriefingSystem.GlobalSystem.page;
            local listboxidx = XGUIEng.ListBoxGetSelectedIndex(Widget .. "/ListBox")+1;
            BriefingSystem.currBriefing[index].mc.current = listboxidx;
            local answer = BriefingSystem.currBriefing[index].mc.current;
            local pageID = BriefingSystem.currBriefing[index].mc.answers[answer].ID;

            GUI.SendScriptCommand([[BriefingSystem.OnConfirmed(]]..pageID..[[,]]..page.mc.current..[[,]]..answer..[[)]]);
        end
    end

    ---
    -- Erzeugt eine Markierung auf der Minikarte.
    --
    -- @param _t          Aktuelle Seite
    -- @param _marterType Typ der Markierung
    -- @param _markerList Liste der Markierungen
    -- @param _r          Magenta-Wert
    -- @param _g          Yellow-Wert
    -- @param _b          Cyan-Wert
    -- @param _alpha      Alpha-Wert
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.CreateMarker(_t, _markerType, _markerList, _r, _g, _b, _alpha)
        local position = _t.position;
        if position then
            if type(position) == "table" then
                if position[GUI.GetPlayerID()] or position.default or position.playerPositions then
                    position = position[GUI.GetPlayerID()] or position.default;
                end
            end
        end
        if not position then
            position = _t.followEntity;
            if type(position) == "table" then
                position = position[GUI.GetPlayerID()] or position.default;
            end
        end
        assert(position);
        if type(position) ~= "table" then
            position = GetPosition(position);
        end

        if _markerList and not BriefingSystem.listOfMarkers[_markerList] then
            BriefingSystem.listOfMarkers[_markerList] = {};
        end

        while GUI.IsMinimapSignalExisting(BriefingSystem.markerUniqueID) == 1 do
            BriefingSystem.markerUniqueID = BriefingSystem.markerUniqueID + 1;
        end
        assert(type(_markerType) == "number" and _markerType > 0);
        _r = _r or 32;
        _g = _g or 245;
        _b = _b or 110;
        _alpha = _alpha or 255;
        GUI.CreateMinimapSignalRGBA(BriefingSystem.markerUniqueID, position.X, position.Y, _r, _g, _b, _alpha, _markerType);
        if _markerList then
            table.insert(BriefingSystem.listOfMarkers[_markerList], { ID = BriefingSystem.markerUniqueID, X = position.X, Y = position.Y, R = _r, G = _g, B = _b, Alpha = _alpha, type = _markerType });
        end
        BriefingSystem.markerUniqueID = BriefingSystem.markerUniqueID + 1;
    end

    ---
    -- Zerstört eine Liste von Markern auf der Minimap.
    --
    -- @param _index Index der Liste
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.DestroyMarkerList(_index)
        if BriefingSystem.listOfMarkers[_index] then
            for _, v in ipairs(BriefingSystem.listOfMarkers[_index]) do
                if v.ID and GUI.IsMinimapSignalExisting(v.ID) == 1 then
                    GUI.DestroyMinimapSignal(v.ID);
                end
            end
            BriefingSystem.listOfMarkers[_index] = nil;
        end
    end

    ---
    -- Zerstört einen Marker innerhalb einer Liste.
    --
    -- @param _index  Index der Liste
    -- @param _marker ID des Marker
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.DestroyMarkerOfList(_index, _marker)
        if BriefingSystem.listOfMarkers[_index] then
            local marker = BriefingSystem.listOfMarkers[_index][_marker];
            if marker and marker.ID and GUI.IsMinimapSignalExisting(marker.ID) == 1 then
                GUI.DestroyMinimapSignal(marker.ID);
                marker.ID = nil;
            end
        end
    end

    ---
    -- Aktualisiert die Position aller marker in der Liste oder erstellt sie
    -- neu, falls er nicht existiert.
    --
    -- @param _index Index der Marker-List
    -- @param _x     X-Position
    -- @param _y     Y-Position
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.RedeployMarkerList(_index, _x, _y)
        if BriefingSystem.listOfMarkers[_index] then
            for _, v in ipairs(BriefingSystem.listOfMarkers[_index]) do
                if v.ID then
                    v.X = _x;
                    v.Y = _y;
                    if GUI.IsMinimapSignalExisting(v.ID) == 1 then
                        GUI.RedeployMinimapSignal(v.ID, _x, _y);
                    else
                        GUI.CreateMinimapSignalRGBA(v.ID, _x, _y, v.R, v.G, v.B, v.Alpha, v.type);
                    end
                end
            end
        end
    end

    ---
    -- Aktualisiert einen Marker aus einer Liste von Markern. Existiert der
    -- Marker nicht, wird er erstellt.
    --
    -- @param _index  Index der Marker-List
    -- @param _marker ID des Markers
    -- @param _x      X-Position
    -- @param _y      Y-Position
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.RedeployMarkerOfList(_index, _marker, _x, _y)
        if BriefingSystem.listOfMarkers[_index] then
            local marker = BriefingSystem.listOfMarkers[_index][_marker];
            if marker and marker.ID then
                marker.X = _x;
                marker.Y = _y;
                if GUI.IsMinimapSignalExisting(marker.ID) == 1 then
                    GUI.RedeployMinimapSignal(marker.ID, _x, _y);
                else
                    GUI.CreateMinimapSignalRGBA(marker.ID, _x, _y, marker.R, marker.G, marker.B, marker.Alpha, marker.type);
                end
            end
        end
    end

    ---
    -- Aktualisiert die Position aller marker in der Liste oder erstellt sie
    -- neu, falls er nicht existiert.
    --
    -- @param _index  Index der Marker-List
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.RefreshMarkerList(_index)
        if BriefingSystem.listOfMarkers[_index] then
            for _, v in ipairs(BriefingSystem.listOfMarkers[_index]) do
                if v.ID then
                    if GUI.IsMinimapSignalExisting(v.ID) == 1 then
                        GUI.RedeployMinimapSignal(v.ID, v.X, v.Y);
                    else
                        GUI.CreateMinimapSignalRGBA(v.ID, v.X, v.Y, v.R, v.G, v.B, v.Alpha, v.type);
                    end
                end
            end
        end
    end

    ---
    -- Aktualisiert einen Marker aus einer Liste von Markern. Existiert der
    -- Marker nicht, wird er erstellt.
    --
    -- @param _index  Index der Marker-List
    -- @param _marker ID des Markers
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.RefreshMarkerOfList(_index, _marker)
        if BriefingSystem.listOfMarkers[_index] then
            local marker = BriefingSystem.listOfMarkers[_index][_marker];
            if marker and marker.ID then
                if GUI.IsMinimapSignalExisting(marker.ID) == 1 then
                    GUI.RedeployMinimapSignal(marker.ID, marker.X, marker.Y);
                else
                    GUI.CreateMinimapSignalRGBA(marker.ID, marker.X, marker.Y, marker.R, marker.G, marker.B, marker.Alpha, marker.type);
                end
            end
        end
    end

    ---
    -- Macht den Skip-Button sichtbar oder versteckt ihn.
    --
    -- @param _player Spieler
    -- @param _flag   Sichtbarkeit
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.EnableBriefingSkipButton(_player, _flag)
        if _player == nil or _player == GUI.GetPlayerID() then
            XGUIEng.DisableButton("/InGame/ThroneRoom/Main/Skip", _flag and 0 or 1);
        end
    end

    ---
    -- Steuert die schwarze Maske, die für Übergänge genutzt wird.
    --
    -- @param _fadeIn     Einblenden verwenden
    -- @param _timerValue Dauer des Blendvorgangs
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem_CheckFader(_fadeIn, _timerValue)
        if BriefingSystem.GlobalSystem.timer < _timerValue then
            if _fadeIn == 1 then
                FadeIn(_timerValue);
            else
                FadeOut(_timerValue);
            end
            BriefingSystem.faderJob = nil;
            return true;
        end
    end

    ---
    -- Steuert die Kamera während eines Briefings. Es wird entweder das alte
    -- System von OldMacDonald oder das neue von totalwarANGEL genutzt.
    --
    -- @within Originalfunktionen
    -- @local
    --
    function ThroneRoomCameraControl()
        if Camera.GetCameraBehaviour(5) == 5 and BriefingSystem.GlobalSystem.isActive == true then
            local flight = BriefingSystem.Flight;

            -- -------------------------------------------------------------- --
            -- Briefing Notation von OldMacDonald
            -- -------------------------------------------------------------- --

            -- Dies steuert die altbekannte Notation, entwickelt von OMD.
            -- Bis auf wenige Erweiterungen von totalwarANGEL ist es wie
            -- zum ursürunglichen Release der letzten Version.

            if flight.systemEnabled then
                -- Kameraanimation
                local startTime = flight.StartTime;
                local flyTime = flight.FlyTime;
                local startPosition = flight.StartPosition or flight.EndPosition;
                local endPosition = flight.EndPosition;
                local startRotation = flight.StartRotation or flight.EndRotation;
                local endRotation = flight.EndRotation;
                local startZoomAngle = flight.StartZoomAngle or flight.EndZoomAngle;
                local endZoomAngle = flight.EndZoomAngle;
                local startZoomDistance = flight.StartZoomDistance or flight.EndZoomDistance;
                local endZoomDistance = flight.EndZoomDistance;
                local startFOV = flight.StartFOV or flight.EndFOV;
                local endFOV = flight.EndFOV;

                -- Splashscreen-Animation
                local startUV0 = flight.StartUV0 or flight.EndUV0;
                local endUV0 = flight.EndUV0;
                local startUV1 = flight.StartUV1 or flight.EndUV1;
                local endUV1 = flight.EndUV1;

                local currTime = Logic.GetTimeMs() / 1000;
                local math = math;
                if flight.Follow then
                    local currentPosition = GetPosition(flight.Follow);
                    if endPosition.X ~= currentPosition.X and endPosition.Y ~= currentPosition.Y then
                        flight.StartPosition = endPosition;
                        flight.EndPosition = currentPosition;
                    end
                    if flight.StartPosition and Logic.IsEntityMoving(GetEntityId(flight.Follow)) then

                        local orientation = math.rad(Logic.GetEntityOrientation(GetEntityId(flight.Follow)));
                        local x1, y1, x2, y2 = flight.StartPosition.X, flight.StartPosition.Y, currentPosition.X, currentPosition.Y;
                        x1 = x1 - x2;
                        y1 = y1 - y2;
                        local distance = math.sqrt( x1 * x1 + y1 * y1 ) * 10;
                        local disttoend = distance * (flyTime - currTime + startTime);
                        local disttostart = distance * (currTime + startTime);
                        endPosition = { X = currentPosition.X + math.cos(orientation) * distance, Y = currentPosition.Y + math.sin(orientation) * distance }

                        flight.FollowTemp = flight.FollowTemp or {};
                        local factor = BriefingSystem.InterpolationFactor(currTime, currTime, 1, flight.FollowTemp);
                        x1, y1, z1 = BriefingSystem.GetCameraPosition(currentPosition, endPosition, factor);
                        startPosition = { X = x1, Y = y1, Z = z1 };
                    else
                        startPosition = currentPosition;
                    end
                    endPosition = startPosition;
                end

                -- Interpolationsfaktor
                local factor = BriefingSystem.InterpolationFactor(startTime, currTime, flyTime, flight);

                -- Kamera
                local lookAtX, lookAtY, lookAtZ = BriefingSystem.GetCameraPosition(startPosition, endPosition, factor);
                local zoomDistance = startZoomDistance + (endZoomDistance - startZoomDistance) * factor;
                local zoomAngle = startZoomAngle + (endZoomAngle - startZoomAngle) * factor;
                local rotation = startRotation + (endRotation - startRotation) * factor;
                local line = zoomDistance * math.cos(math.rad(zoomAngle));

                Camera.ThroneRoom_SetLookAt(lookAtX, lookAtY, lookAtZ);
                Camera.ThroneRoom_SetPosition(
                    lookAtX + math.cos(math.rad(rotation - 90)) * line,
                    lookAtY + math.sin(math.rad(rotation - 90)) * line,
                    lookAtZ + (zoomDistance) * math.sin(math.rad(zoomAngle))
                );
                Camera.ThroneRoom_SetFOV(startFOV + (endFOV - startFOV) * factor);

                -- Splashscreen
                BriefingSystem.SetBriefingSplashscreenUV(startUV0, endUV0, startUV1, endUV1, factor);

            -- -------------------------------------------------------------- --
            -- Cutscene notation by totalwarANGEL
            -- -------------------------------------------------------------- --

            -- Die Cutscene Notation von totalwarANGEL ermöglicht es viele
            -- Kameraeffekte einfacher umzusetzen, da man die Kamera über
            -- eine Position und eine Blickrichtung steuert.
            -- Es KANN vorkommen, dass die Bewegung flüssiger wird.

            else
                local cutscene = BriefingSystem.Flight.Cutscene;

                if cutscene then
                    -- Kamera
                    local StartPosition = cutscene.StartPosition or cutscene.EndPosition;
                    local EndPosition = cutscene.EndPosition;
                    local StartLookAt = cutscene.StartLookAt or cutscene.EndLookAt;
                    local EndLookAt = cutscene.EndLookAt;
                    local StartFOV = cutscene.StartFOV or cutscene.EndFOV;
                    local EndFOV = cutscene.EndFOV;
                    local StartTime = cutscene.StartTime;
                    local FlyTime = cutscene.FlyTime;
                    local CurrTime = Logic.GetTimeMs()/1000;

                    -- Splashscreen-Animation
                    local startUV0 = cutscene.StartUV0 or cutscene.EndUV0;
                    local endUV0 = cutscene.EndUV0;
                    local startUV1 = cutscene.StartUV1 or cutscene.EndUV1;
                    local endUV1 = cutscene.EndUV1;

                    local Factor = BriefingSystem.InterpolationFactor(StartTime, CurrTime, FlyTime, cutscene);

                    -- Setzt das Blickziel der Kamera zum Animationsbeginn
                    if not StartLookAt.X then
                        local CamPos = GetPosition(StartLookAt[1], (StartLookAt[2] or 0));
                        if StartLookAt[3] then
                            CamPos.X = CamPos.X + StartLookAt[3] * math.cos( math.rad(StartLookAt[4]) );
                            CamPos.Y = CamPos.Y + StartLookAt[3] * math.sin( math.rad(StartLookAt[4]) );
                        end
                        StartLookAt = CamPos;
                    end

                    -- Setzt das Blickziel der Kamera zum Animationsende
                    if not EndLookAt.X then
                        local CamPos = GetPosition(EndLookAt[1], (EndLookAt[2] or 0));
                        if EndLookAt[3] then
                            CamPos.X = CamPos.X + EndLookAt[3] * math.cos( math.rad(EndLookAt[4]) );
                            CamPos.Y = CamPos.Y + EndLookAt[3] * math.sin( math.rad(EndLookAt[4]) );
                        end
                        EndLookAt = CamPos;
                    end
                    local lookAtX, lookAtY, lookAtZ = BriefingSystem.CutsceneGetPosition(StartLookAt, EndLookAt, Factor);
                    Camera.ThroneRoom_SetLookAt(lookAtX, lookAtY, lookAtZ);

                    -- Setzt die Startposition der Kamera
                    -- Positionstabelle {X= x, Y= y, Z= z}

                    if not StartPosition.X then
                        local CamPos = GetPosition(StartPosition[1], (StartPosition[2] or 0));
                        if StartPosition[3] then
                            CamPos.X = CamPos.X + StartPosition[3] * math.cos( math.rad(StartPosition[4]) );
                            CamPos.Y = CamPos.Y + StartPosition[3] * math.sin( math.rad(StartPosition[4]) );
                        end
                        StartPosition = CamPos;
                    end

                    -- Setzt die Endposition der Kamera
                    -- Positionstabelle {X= x, Y= y, Z= z}

                    if not EndPosition.X then
                        local CamPos = GetPosition(EndPosition[1], (EndPosition[2] or 0));
                        if EndPosition[3] then
                            CamPos.X = CamPos.X + EndPosition[3] * math.cos( math.rad(EndPosition[4]) );
                            CamPos.Y = CamPos.Y + EndPosition[3] * math.sin( math.rad(EndPosition[4]) );
                        end
                        EndPosition = CamPos;
                    end

                    local posX, posY, posZ = BriefingSystem.CutsceneGetPosition(StartPosition, EndPosition, Factor);
                    Camera.ThroneRoom_SetPosition(posX, posY, posZ);

                    -- Setzt den Bildschirmausschnitt
                    Camera.ThroneRoom_SetFOV(StartFOV + (EndFOV - StartFOV) * Factor);

                    -- Splashscreen
                    BriefingSystem.SetBriefingSplashscreenUV(startUV0, endUV0, startUV1, endUV1, factor);
                end
            end

            -- -------------------------------------------------------------- --

            -- Notizen im Briefing
            -- Blendet zusätzlichen Text während eines Briefings ein. Siehe
            -- dazu Kommentar bei der Funktion.

            BriefingSystem.ControlInformationText();

            -- Multiple Choice ist bestätigt, wenn das Auswahlfeld
            -- verschwindet. In diesem Fall hat der Spieler geklickt.

            if BriefingSystem.MCSelectionIsShown then
                local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
                if XGUIEng.IsWidgetShown(Widget) == 0 then
                    BriefingSystem.MCSelectionIsShown = false;
                    BriefingSystem.OnConfirmed();
                end
            end
        end
    end

    ---
    -- Wird immer dann aufgerufen, wenn der Spieler innerhalb des Throneroom
    -- Mode links klickt.
    --
    -- @within Originalfunktionen
    -- @local
    --
    function ThroneRoomLeftClick()
        local EntityID = GUI.GetMouseOverEntity();
        API.Bridge("BriefingSystem.LeftClickOnEntity(" ..tostring(EntityID).. ")");
        local x,y = GUI.Debug_GetMapPositionUnderMouse();
        API.Bridge("BriefingSystem.LeftClickOnPosition(" ..tostring(x).. ", " ..tostring(y).. ")");
        local x,y = GUI.GetMousePosition();
        API.Bridge("BriefingSystem.LeftClickOnScreen(" ..tostring(x).. ", " ..tostring(y).. ")");
    end

    -- ---------------------------------------------------------------------- --
    -- Cutscene Functions by totalwarANGEL
    -- ---------------------------------------------------------------------- --

    ---
    -- Berechnet die Kameraposition wärhend eines Cutscene Flights.
    --
    -- @param _Start  Startposition des Flight
    -- @param _End    Endposition des Flight
    -- @param _Factor Interpolation Factor
    -- @return number: X-Position
    -- @return number: Y-Position
    -- @return number: Z-Position
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.CutsceneGetPosition(_Start, _End, _Factor)
        local X = _Start.X + (_End.X - _Start.X) * _Factor;
        local Y = _Start.Y + (_End.Y - _Start.Y) * _Factor;
        local Z = _Start.Z + (_End.Z - _Start.Z) * _Factor;
        return X, Y, Z;
    end

    ---
    -- Speichert die Startposition der nächsten Kameraanimation.
    --
    -- @param _FOV      Field of View
    -- @param _UV0      UV0 des Splashscreen
    -- @param _UV1      UV1 des Splashscreen
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.CutsceneSaveFlight(_cameraPosition, _cameraLookAt, _FOV, _UV0, _UV1)
        BriefingSystem.Flight.Cutscene = BriefingSystem.Flight.Cutscene or {};
        BriefingSystem.Flight.Cutscene.StartPosition = _cameraPosition;
        BriefingSystem.Flight.Cutscene.StartLookAt = _cameraLookAt;
        BriefingSystem.Flight.Cutscene.StartFOV = _FOV;
        BriefingSystem.Flight.Cutscene.StartTime = Logic.GetTimeMs()/1000;
        BriefingSystem.Flight.Cutscene.FlyTime = 0;
        BriefingSystem.Flight.Cutscene.StartUV0 = _UV0;
        BriefingSystem.Flight.Cutscene.StartUV1 = _UV1;
    end

    ---
    -- Initalisiert den Flug der Kamera zu einer Position auf der Welt.
    --
    -- @param _FOV      Field of View
    -- @param _Time     Animationszeit
    -- @param _UV0      UV0 des Splashscreen
    -- @param _UV1      UV1 des Splashscreen
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.CutsceneFlyTo(_cameraPosition, _cameraLookAt, _FOV, _Time, _UV0, _UV1)
        BriefingSystem.Flight.Cutscene = BriefingSystem.Flight.Cutscene or {};
        BriefingSystem.Flight.Cutscene.StartTime = Logic.GetTimeMs()/1000;
        BriefingSystem.Flight.Cutscene.FlyTime = _Time;
        BriefingSystem.Flight.Cutscene.EndPosition = _cameraPosition;
        BriefingSystem.Flight.Cutscene.EndLookAt = _cameraLookAt;
        BriefingSystem.Flight.Cutscene.EndFOV = _FOV;
        BriefingSystem.Flight.Cutscene.EndUV0 = _UV0;
        BriefingSystem.Flight.Cutscene.EndUV1 = _UV1;
    end

    ---
    -- Unterbricht eine Kamerabewegung der laufenden Cutscene.
    --
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.CutsceneStopFlight()
        BriefingSystem.Flight.Cutscene = BriefingSystem.Flight.Cutscene or {};
        BriefingSystem.Flight.Cutscene.StartPosition = BriefingSystem.Flight.Cutscene.EndPosition;
        BriefingSystem.Flight.Cutscene.StartLookAt = BriefingSystem.Flight.Cutscene.EndLookAt;
        BriefingSystem.Flight.Cutscene.StartFOV = BriefingSystem.Flight.Cutscene.EndFOV;
    end

    -- ---------------------------------------------------------------------- --

    ---
    -- Errechnet den Interpolation Factor für den aktuellen Flight.
    --
    -- @param _start         Startzeit
    -- @param _curr          Aktuelle Zeit
    -- @param _total         Absolute Zeit
    -- @param _dataContainer Game Tame Backup
    -- @return number: Interpolation Factor
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.InterpolationFactor(_start, _curr, _total, _dataContainer)
        local factor = 1;

        if _start + _total > _curr then
            factor = (_curr - _start) / _total;
            if _dataContainer and _curr == _dataContainer.TempLastLogicTime then
                factor = factor + (Framework.GetTimeMs() - _dataContainer.TempLastFrameworkTime) / _total / 1000 * Game.GameTimeGetFactor(GUI.GetPlayerID());
            else
                _dataContainer.TempLastLogicTime = _curr;
                _dataContainer.TempLastFrameworkTime = Framework.GetTimeMs();
            end
        end
        if factor > 1 then
            factor = 1;
        end
        return factor;
    end

    ---
    -- Berechnet die aktuelle Position der Kamera für den aktuellen Flight.
    --
    -- Der Interpolation Factor wird für eine Vektormultiplikation des
    -- Richtungsvektors zwischen S(x,y,z) und E(x,y,z) verwendet.
    --
    -- @param _start  Startposition des Flight
    -- @param _end    Endposition des Flight
    -- @param _factor Interpolation Factor
    -- @return number: X-Position
    -- @return number: Y-Position
    -- @return number: Z-Position
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.GetCameraPosition(_start, _end, _factor)
        local lookAtX = _start.X + (_end.X - _start.X) * _factor;
        local lookAtY = _start.Y + (_end.Y - _start.Y) * _factor;
        local lookAtZ;
        if _start.Z or _end.Z then
            lookAtZ = (_start.Z or Display.GetTerrainHeight(_start.X, _start.Y)) + ((_end.Z or Display.GetTerrainHeight(_end.X, _end.Y)) - (_start.Z or Display.GetTerrainHeight(_start.X, _start.Y))) * _factor;
        else
            lookAtZ = Display.GetTerrainHeight(lookAtX, lookAtY) * ((_start.ZRelative or 1) + ((_end.ZRelative or 1) - (_start.ZRelative or 1)) * _factor) + ((_start.ZAdd or 0) + ((_end.ZAdd or 0) - (_start.ZAdd or 0))) * _factor;
        end
        return lookAtX, lookAtY, lookAtZ;
    end

    ---
    -- Speichert die Startposition der nächsten Kameraanimation.
    --
    -- @param _position Blickziel der Kamera
    -- @param _rotation Rotation der Kamera
    -- @param _angle    Winkel der Kamera
    -- @param _distance Entfernung der Kamera
    -- @param _FOV      Field of View
    -- @param _UV0      UV0 des Splashscreen
    -- @param _UV1      UV1 des Splashscreen
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.SaveFlight(_position, _rotation, _angle, _distance, _FOV, _UV0, _UV1)
        BriefingSystem.Flight.StartZoomAngle = _angle;
        BriefingSystem.Flight.StartZoomDistance = _distance;
        BriefingSystem.Flight.StartRotation = _rotation;
        BriefingSystem.Flight.StartPosition = _position;
        BriefingSystem.Flight.StartFOV = _FOV;
        BriefingSystem.Flight.StartUV0 = _UV0;
        BriefingSystem.Flight.StartUV1 = _UV1;
    end

    ---
    -- Initalisiert den Flug der Kamera zu einem Entity.
    --
    -- @param _position Blickziel der Kamera
    -- @param _rotation Rotation der Kamera
    -- @param _angle    Winkel der Kamera
    -- @param _distance Entfernung der Kamera
    -- @param _FOV      Field of View
    -- @param _time     Animationszeit
    -- @param _UV0      UV0 des Splashscreen
    -- @param _UV1      UV1 des Splashscreen
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.FlyTo(_position, _rotation, _angle, _distance, _FOV, _time, _UV0, _UV1)
        local flight = BriefingSystem.Flight;
        flight.StartTime = Logic.GetTimeMs()/1000;
        flight.FlyTime = _time;
        flight.EndPosition = _position;
        flight.EndRotation = _rotation;
        flight.EndZoomAngle = _angle;
        flight.EndZoomDistance = _distance;
        flight.EndFOV = _FOV;
        flight.EndUV0 = _UV0;
        flight.EndUV1 = _UV1;
    end

    ---
    -- Stoppt die aktuelle Kameraanimation des Briefings.
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.StopFlight()
        local flight = BriefingSystem.Flight;
        flight.StartZoomAngle = flight.EndZoomAngle;
        flight.StartZoomDistance = flight.EndZoomDistance;
        flight.StartRotation = flight.EndRotation;
        flight.StartPosition = flight.EndPosition;
        flight.StartFOV = flight.EndFOV;
        flight.StartUV0 = flight.EndUV0;
        flight.StartUV1 = flight.EndUV1;
        if flight.Follow then
            flight.StartPosition = GetPosition(flight.Follow);
            flight.Follow = nil;
        end
    end

    ---
    -- Initalisiert die Verfolgung eines Entities durch die Kamera.
    --
    -- @param _follow   Blickziel der Kamera
    -- @param _rotation Rotation der Kamera
    -- @param _angle    Winkel der Kamera
    -- @param _distance Entfernung der Kamera
    -- @param _FOV      Field of View
    -- @param _time     Animationszeit
    -- @param _Z        Z-Offset des Blickziels
    -- @param _UV0      UV0 des Splashscreen
    -- @param _UV1      UV1 des Splashscreen
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.FollowFlight(_follow, _rotation, _angle, _distance, _FOV, _time, _Z, _UV0, _UV1)
        local pos = GetPosition(_follow); pos.Z = _Z or 0;
        BriefingSystem.FlyTo(pos, _rotation, _angle, _distance, _FOV, _time, _UV0, _UV1);
        BriefingSystem.Flight.StartPosition = nil;
        BriefingSystem.Flight.Follow = _follow;
    end

    --
    -- Prüft, ob ein Briefing aktiv ist.
    --
    -- <b>Alias:</b> IsBriefingActive
    --
    -- @return boolean: Briefing aktiv
    -- @within BriefingSystem
    --
    function BriefingSystem.IsBriefingActive()
        return BriefingSystem.GlobalSystem ~= nil and BriefingSystem.GlobalSystem.isActive;
    end
    IsBriefingActive = BriefingSystem.IsBriefingActive;

    ---
    -- Setzt die Position des Textes und des Titels einer Briefing-Seite.
    -- @param _page Briefing-Seite
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.SetBriefingPageTextPosition(_page)
        local size = {GUI.GetScreenSize()};

        -- set title position
        local x,y = XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight");
        XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", x, 65);

        -- reset widget position with backup
        if not _page.mc then
            if BriefingSystem.BriefingTextPositionBackup then
                local pos = BriefingSystem.BriefingTextPositionBackup;
                XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text", pos[1], pos[2]);
            end

            -- text at the mittle
            if _page.splashscreen then
                if _page.centered then
                    local Height = 0;
                    if _page.text then
                        -- Textlänge
                        local Length = string.len(_page.text);
                        Height = Height + math.ceil((Length/80));

                        -- Zeilenumbrüche
                        local CarriageReturn = 0;
                        local s,e = string.find(_page.text, "{cr}");
                        while (e) do
                            CarriageReturn = CarriageReturn + 1;
                            s,e = string.find(_page.text, "{cr}", e+1);
                        end
                        Height = Height + math.floor((CarriageReturn/2));

                        -- Relativ
                        local Screen = {GUI.GetScreenSize()};
                        Height = (Screen[2]/2) - (Height*15);
                    end

                    XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", x, 0 + Height);

                    local x,y = XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text");
                    if not BriefingSystem.BriefingTextPositionBackup then
                        BriefingSystem.BriefingTextPositionBackup = {x, y};
                    end
                    XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text", x, 38 + Height);
                end
            end
            return;
        end

        -- move title to very top if mc page contains text
        local x,y = XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight");
        if _page.mc.text and _page.mc.text ~= "" then
            XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight",x,5);
        end

        -- move the text up to the top
        local x,y = XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text");
        if not BriefingSystem.BriefingTextPositionBackup then
            BriefingSystem.BriefingTextPositionBackup = {x, y};
        end
        XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text",x,42);
    end

    ---
    -- Steuert die Scrollanimation des Splashscreen.
    --
    -- @param _StartUV0 Startposition UV0
    -- @param _EndUV0   Endposition UV0
    -- @param _StartUV1 Startposition UV1
    -- @param _EndUV1   Endposition UV1
    -- @param _Factor   Interpolation Factor
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.SetBriefingSplashscreenUV(_StartUV0, _EndUV0, _StartUV1, _EndUV1, _Factor)
        if not _StartUV0 or not _EndUV0 or not _StartUV1 or not _EndUV1 then
            return;
        end

        local BG     = "/InGame/ThroneRoomBars_2/BarTop";
        local BB     = "/InGame/ThroneRoomBars_2/BarBottom";
        local size   = {GUI.GetScreenSize()};
        local is4To3 = math.floor((size[1]/size[2]) * 10) == 13;

        local u0 = _StartUV0[1] + (_EndUV0[1] - _StartUV0[1]) * _Factor;
        local v0 = _StartUV0[2] + (_EndUV0[2] - _StartUV0[2]) * _Factor;
        local u1 = _StartUV1[1] + (_EndUV1[1] - _StartUV1[1]) * _Factor;
        local v1 = _StartUV1[2] + (_EndUV1[2] - _StartUV1[2]) * _Factor;

        -- Fix für 4:3
        if is4To3 then
            u0 = u0 + (u0 * 0.125);
            u1 = u1 - (u1 * 0.125);
        end

        XGUIEng.SetMaterialUV(BG, 1, u0, v0, u1, v1);
    end

    ---
    -- Schaltet zwischen Bars und Splashscreen um.
    --
    -- @param _page  Aktuelle Briefing-Seite
    -- @param _style Bar-Style
    -- @within BriefingSystem
    -- @local
    --
    function BriefingSystem.SetBriefingPageOrSplashscreen(_page, _style)
        local BG = "/InGame/ThroneRoomBars_2/BarTop";
        local BB = "/InGame/ThroneRoomBars_2/BarBottom";
        local size = {GUI.GetScreenSize()};

        if not _page.splashscreen then
            XGUIEng.SetMaterialTexture(BG, 1, "");
            XGUIEng.SetMaterialTexture(BB, 1, "");
            XGUIEng.SetMaterialColor(BG, 1, 0, 0, 0, 255);
            XGUIEng.SetMaterialColor(BB, 1, 0, 0, 0, 255);

            if BriefingSystem.BriefingBarSizeBackup then
                local pos = BriefingSystem.BriefingBarSizeBackup;
                XGUIEng.SetWidgetSize(BG, pos[1], pos[2]);
                BriefingSystem.BriefingBarSizeBackup = nil;
            end

            BriefingSystem.ShowBriefingBar(_style);
            return;
        end

        if _page.splashscreen == true then
            XGUIEng.SetMaterialTexture(BG, 1, "");
            XGUIEng.SetMaterialColor(BG, 1, 0, 0, 0, 255);
            XGUIEng.SetMaterialUV(BG, 1, 0, 0, 1, 1);
        else
            XGUIEng.SetMaterialColor(BB, 1, 0, 0, 0, 0);
            if _page.splashscreen.color then
                XGUIEng.SetMaterialColor(BG, 1, unpack(_page.splashscreen.color));
            else
                XGUIEng.SetMaterialColor(BG, 1, 255, 255, 255, 255);
            end
            XGUIEng.SetMaterialTexture(BG, 1, _page.splashscreen.image);
        end

        if not BriefingSystem.BriefingBarSizeBackup then
            local x,y = XGUIEng.GetWidgetSize(BG);
            BriefingSystem.BriefingBarSizeBackup = {x, y};
        end

        local BarX    = BriefingSystem.BriefingBarSizeBackup[1];
        local _, BarY = XGUIEng.GetWidgetSize("/InGame/ThroneRoomBars");
        XGUIEng.SetWidgetSize(BG, BarX, BarY);

        XGUIEng.ShowWidget("/InGame/ThroneRoomBars", 0);
        XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", 1);
        XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", 0);
        XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", 0);
        XGUIEng.ShowWidget(BG, 1);
    end

    BundleBriefingSystem:OverwriteGetPosition();
end

-- -------------------------------------------------------------------------- --

---
-- Überschreibt GetPosition um auch eine Z-Koordinate zurückzugeben.
-- @within Internal
-- @local
--
function BundleBriefingSystem:OverwriteGetPosition()
    GetPosition = function(_input, _offsetZ)
        _offsetZ = _offsetZ or 0;
        if type(_input) == "table" then
            return _input;
        else
            if not IsExisting(_input) then
                return {X=0, Y=0, Z=0+_offsetZ};
            else
                local eID = GetID(_input);
                local x,y,z = Logic.EntityGetPos(eID);
                return {X=x, Y=y, Z=z+_offsetZ};
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleBriefingSystem");

---
-- Ruft die Lua-Funktion mit dem angegebenen Namen auf und spielt das Briefing
-- in ihr ab. Die Funktion muss eine Briefing-ID zurückgeben.
--
-- Das Brieifng wird an den Quest gebunden und kann mit Trigger_Briefing
-- überwacht werden. Es kann pro Quest nur ein Briefing gebunden werden!
--
-- @param _Briefing [string] Funktionsname als String
--
-- @within Reward
--
function Reward_Briefing(...)
    return b_Reward_Briefing:new(...);
end

b_Reward_Briefing = {
    Name = "Reward_Briefing",
    Description = {
        en = "Reward: Calls a function that creates a briefing and saves the returned briefing ID into the quest.",
        de = "Lohn: Ruft eine Funktion auf, die ein Briefing erzeugt und die zurueckgegebene ID in der Quest speichert.",
    },
    Parameter = {
        { ParameterType.Default, en = "Briefing function", de = "Funktion mit Briefing" },
    },
}

function b_Reward_Briefing:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_Briefing:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Function = __parameter_;
    end
end

function b_Reward_Briefing:CustomFunction(__quest_)
    local BriefingID = _G[self.Function](self, __quest_);
    local QuestID = GetQuestID(__quest_.Identifier);
    Quests[QuestID].EmbeddedBriefing = BriefingID;
    if not BriefingID and QSB.DEBUG_CheckWhileRuntime then
        local Text = __quest_.Identifier..": "..self.Name..": '"..self.Function.."' has not returned anything!"
        if IsBriefingActive() then
            GUI_Note(Text);
        end
        dbg(Text);
    end
end

function b_Reward_Briefing:DEBUG(__quest_)
    if not type(_G[self.Function]) == "function" then
        dbg(__quest_.Identifier..": "..self.Name..": '"..self.Function.."' was not found!");
        return true;
    end
    return false;
end

function b_Reward_Briefing:Reset(__quest_)
    local QuestID = GetQuestID(__quest_.Identifier);
    Quests[QuestID].EmbeddedBriefing = nil;
end

Core:RegisterBehavior(b_Reward_Briefing);

---
-- Ruft die Lua-Funktion mit dem angegebenen Namen auf und spielt das Briefing
-- in ihr ab. Die Funktion muss eine Briefing-ID zurückgeben.
--
-- Das Brieifng wird an den Quest gebunden und kann mit Trigger_Briefing
-- überwacht werden. Es kann pro Quest nur ein Briefing gebunden werden!
--
-- @param _Briefing [string] Funktionsname als String
--
-- @within Reprisal
--
function Reprisal_Briefing(...)
    return b_Reprisal_Briefing:new(...);
end

b_Reprisal_Briefing = {
    Name = "Reprisal_Briefing",
    Description = {
        en = "Reprisal: Calls a function that creates a briefing and saves the returned briefing ID into the quest.",
        de = "Vergeltung: Ruft eine Funktion auf, die ein Briefing erzeugt und die zurueckgegebene ID in der Quest speichert.",
    },
    Parameter = {
        { ParameterType.Default, en = "Briefing function", de = "Funktion mit Briefing" },
    },
}

function b_Reprisal_Briefing:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_Briefing:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Function = __parameter_;
    end
end

function b_Reprisal_Briefing:CustomFunction(__quest_)
    local BriefingID = _G[self.Function](self, __quest_);
    local QuestID = GetQuestID(__quest_.Identifier);
    Quests[QuestID].EmbeddedBriefing = BriefingID;
    if not BriefingID and QSB.DEBUG_CheckWhileRuntime then
        local Text = __quest_.Identifier..": "..self.Name..": '"..self.Function.."' has not returned anything!"
        if IsBriefingActive() then
            GUI_Note(Text);
        end
        dbg(Text);
    end
end

function b_Reprisal_Briefing:DEBUG(__quest_)
    if not type(_G[self.Function]) == "function" then
        dbg(__quest_.Identifier..": "..self.Name..": '"..self.Function.."' was not found!");
        return true;
    end
    return false;
end

function b_Reprisal_Briefing:Reset(__quest_)
    local QuestID = GetQuestID(__quest_.Identifier);
    Quests[QuestID].EmbeddedBriefing = nil;
end

Core:RegisterBehavior(b_Reprisal_Briefing);

---
-- Startet einen Quest, nachdem das Briefing, das an einen anderen Quest
-- angehangen ist, beendet ist.
--
-- @param _QuestName [string] Name des Quest
-- @param _Waittime  [number] Wartezeit in Sekunden
-- @within Trigger
--
function Trigger_Briefing(...)
    return b_Trigger_Briefing:new(...);
end

b_Trigger_Briefing = {
    Name = "Trigger_Briefing",
    Description = {
        en = "Trigger: after an embedded briefing of another quest has finished.",
        de = "Ausloeser: wenn das eingebettete Briefing der angegebenen Quest beendet ist.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Questname" },
        { ParameterType.Number,  en = "Wait time",  de = "Wartezeit" },
    },
}

function b_Trigger_Briefing:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_Briefing:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Quest = __parameter_;
    elseif (__index_ == 1) then
        self.WaitTime = tonumber(__parameter_) or 0
    end
end

function b_Trigger_Briefing:CustomFunction(__quest_)
    local QuestID = GetQuestID(self.Quest);
    if IsBriefingFinished(Quests[QuestID].EmbeddedBriefing) then
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

function b_Trigger_Briefing:Interrupt(__quest_)
    local QuestID = GetQuestID(self.Quest);
    Quests[QuestID].EmbeddedBriefing = nil;
    self.WaitTimeTimer = nil
end

function b_Trigger_Briefing:Reset(__quest_)
    local QuestID = GetQuestID(self.Quest);
    Quests[QuestID].EmbeddedBriefing = nil;
    self.WaitTimeTimer = nil
end

function b_Trigger_Briefing:DEBUG(__quest_)
    if tonumber(self.WaitTime) == nil or self.WaitTime < 0 then
        dbg(__quest_.Identifier.." "..self.Name..": waittime is nil or below 0!");
        return true;
    elseif not IsValidQuest(self.Quest) then
        dbg(__quest_.Identifier.." "..self.Name..": '"..self.Quest.."' is not a valid quest!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_Briefing);
