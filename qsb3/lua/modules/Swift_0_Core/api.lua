--[[
Swift_0_Core/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Stellt wichtige Kernfunktionen bereit.
--
-- <b>Befehle:</b><br>
-- <i>Diese Befehle können über die Konsole (SHIFT + ^) eingegeben werden, wenn
-- der Debug Mode aktiviert ist.</i><br>
-- <table border="1">
-- <tr>
-- <td><b>Befehl</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>restartmap</td>
-- <td>Map sofort neu starten</td>
-- </tr>
-- </table>
--
-- <b>Cheats:</b><br>
-- <i>Bei aktivierten Debug Mode können diese Cheat Codes verwendet werden.</i><br>
-- <table border="1">
-- <tr>
-- <td><b>Cheat</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>SHIFT + ^</td>
-- <td>Konsole öffnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + ALT + R</td>
-- <td>Map sofort neu starten.</td>
-- </tr>
-- <td>CTRL + C</td>
-- <td>Zeitanzeige an/aus</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + A</td>
-- <td>Clutter (Gräser) anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + C</td>
-- <td>Grasobjekte anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + E</td>
-- <td>Laubbäume anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + F</td>
-- <td>FoW anzeigen (an/aus) <i>Gebiete werden dauerhaft erkundet!</i></td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + G</td>
-- <td>GUI anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + H</td>
-- <td>Steine und Tannen anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + R</td>
-- <td>Straßen anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + S</td>
-- <td>Schatten anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + T</td>
-- <td>Boden anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + U</td>
-- <td>FoW anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + W</td>
-- <td>Wasser anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + X</td>
-- <td>Render Mode des Wassers umschalten (Einfach und komplex)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + Y</td>
-- <td>Himmel anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>ALT + F10</td>
-- <td>Selektiertes Gebäude anzünden</td>
-- </tr>
-- <tr>
-- <td>ALT + F11</td>
-- <td>Selektierte Einheit verwunden</td>
-- </tr>
-- <tr>
-- <td>ALT + F12</td>
-- <td>Alle Rechte freigeben / wieder sperren</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + 1</td>
-- <td>FPS-Anzeige</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 4</td>
-- <td>Bogenschützen unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 5</td>
-- <td>Schwertkämpfer unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 6</td>
-- <td>Katapultkarren unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 7</td>
-- <td>Ramme unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 8</td>
-- <td>Belagerungsturm unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 9</td>
-- <td>Katapult unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>(Num) +</td>
-- <td>Spiel beschleunigen</td>
-- </tr>
-- <tr>
-- <td>(Num) -</td>
-- <td>Spiel verlangsamen</td>
-- </tr>
-- <tr>
-- <td>(Num) *</td>
-- <td>Geschwindigkeit zurücksetzen</td>
-- </tr>
-- <tr>
-- <td>CTRL + F1</td>
-- <td>+ 50 Gold</td>
-- </tr>
-- <tr>
-- <td>CTRL + F2</td>
-- <td>+ 10 Holz</td>
-- </tr>
-- <tr>
-- <td>CTRL + F3</td>
-- <td>+ 10 Stein</td>
-- </tr>
-- <tr>
-- <td>CTRL + F4</td>
-- <td>+ 10 Getreide</td>
-- </tr>
-- <tr>
-- <td>CTRL + F5</td>
-- <td>+ 10 Milch</td>
-- </tr>
-- <tr>
-- <td>CTRL + F6</td>
-- <td>+ 10 Kräuter</td>
-- </tr>
-- <tr>
-- <td>CTRL + F7</td>
-- <td>+ 10 Wolle</td>
-- </tr>
-- <tr>
-- <td>CTRL + F8</td>
-- <td>+ 10 auf alle Waren</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F1</td>
-- <td>+ 10 Honig</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F2</td>
-- <td>+ 10 Eisen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F3</td>
-- <td>+ 10 Fisch</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F4</td>
-- <td>+ 10 Wild</td>
-- </tr>
-- <tr>
-- <td>ALT + F5</td>
-- <td>Bedürfnis nach Nahrung in Gebäude aktivieren</td>
-- </tr>
-- <tr>
-- <td>ALT + F6</td>
-- <td>Bedürfnis nach Kleidung in Gebäude aktivieren</td>
-- </tr>
-- <tr>
-- <td>ALT + F7</td>
-- <td>Bedürfnis nach Hygiene in Gebäude aktivieren</td>
-- </tr>
-- <tr>
-- <td>ALT + F8</td>
-- <td>Bedürfnis nach Unterhaltung in Gebäude aktivieren</td>
-- </tr>
-- <tr>
-- <td>CTRL + F9</td>
-- <td>Nahrung für selektiertes Gebäude erhöhen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F9</td>
-- <td>Nahrung für selektiertes Gebäude verringern</td>
-- </tr>
-- <tr>
-- <td>CTRL + F10</td>
-- <td>Kleidung für selektiertes Gebäude erhöhen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F10</td>
-- <td>Kleidung für selektiertes Gebäude verringern</td>
-- </tr>
-- <tr>
-- <td>CTRL + F11</td>
-- <td>Hygiene für selektiertes Gebäude erhöhen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F11</td>
-- <td>Hygiene für selektiertes Gebäude verringern</td>
-- </tr>
-- <tr>
-- <td>CTRL + F12</td>
-- <td>Unterhaltung für selektiertes Gebäude erhöhen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F12</td>
-- <td>Unterhaltung für selektiertes Gebäude verringern</td>
-- </tr>
-- <tr>
-- <td>ALT + CTRL + F10</td>
-- <td>Einnahmen des selektierten Gebäudes erhöhen</td>
-- </tr>
-- <tr>
-- <td>ALT + (Num) 1</td>
-- <td>Burg selektiert → Gold verringern, Werkstatt selektiert → Ware verringern</td>
-- </tr>
-- <tr>
-- <td>ALT + (Num) 2</td>
-- <td>Burg selektiert → Gold erhöhen, Werkstatt selektiert → Ware erhöhen</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 1</td>
-- <td>Kontrolle über Spieler 1</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 2</td>
-- <td>Kontrolle über Spieler 2</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 3</td>
-- <td>Kontrolle über Spieler 3</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 4</td>
-- <td>Kontrolle über Spieler 4</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 5</td>
-- <td>Kontrolle über Spieler 5</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 6</td>
-- <td>Kontrolle über Spieler 6</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 7</td>
-- <td>Kontrolle über Spieler 7</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 8</td>
-- <td>Kontrolle über Spieler 8</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 0</td>
-- <td>Kamera durchschalten</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 1</td>
-- <td>Kamerasprünge im RTS-Mode</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + V</td>
-- <td>Territorien anzeigen</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + B</td>
-- <td>Blocking anzeigen</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + N</td>
-- <td>Gitter verstecken</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + F9</td>
-- <td>DEBUG-Ausgabe einschalten</td>
-- </tr>
-- <tr>
-- <td>ALT + F9</td>
-- <td>Zufälligen Arbeiter verheiraten</td>
-- </tr>
-- </table>
--
-- @set sort=true
-- @within Beschreibung
--

Swift = Swift or {};

QSB.Metatable = {Init = false, Weak = {}, Metas = {}, Key = 0};

QSB.DefaultNumber = -1;
QSB.DefaultString = "";
QSB.DefaultList = {};
QSB.DefaultFunction = function() end;

-- Lua base functions

function API.OverrideTable()
    ---
    -- Vergleicht zwei Tables anhand der übergebenen Vergleichsfunktion.
    -- @param[type=table]    t1 Table 1
    -- @param[type=table]    t2 Table 2
    -- @param[type=function] fx Vergleichsfunktion
    -- @within table
    --
    table.compare = function(t1, t2, fx)
        assert(type(t1) == "table");
        assert(type(t2) == "table");
        fx = fx or function(t1, t2)
            return tostring(t1) < tostring(t2);
        end
        assert(type(fx) == "function");
        return fx(t1, t2);
    end

    ---
    -- Prüft, ob ein Table identisch zu einem anderen ist. Zwei Tables sind
    -- gleich, wenn ihre Inhalte gleich sind.
    -- @param[type=table] t1 Table 1
    -- @param[type=table] t2 Table 2
    -- @within table
    --
    table.equals = function(t1, t2)
        assert(type(t1) == "table");
        assert(type(t2) == "table");
        for k, v in pairs(t1) do
            if type(v) == "table" then
                if not t2[k] or not table.equals(t2[k], v) then
                    return false;
                end
            elseif type(v) ~= "thread" and type(v) ~= "userdata" then
                if not t2[k] or t2[k] ~= v then
                    return false;
                end
            end
        end
        return true;
    end
    
    ---
    -- Prüft, ob ein Element in einer eindimensionenen Table enthalten ist.
    -- @param[type=table] t Table
    -- @param             e Element
    -- @within table
    --
    table.contains = function (t, e)
        assert(type(t) == "table");
        for k, v in ipairs(t) do
            if v == e then
                return true;
            end
        end
        return false;
    end

    ---
    -- Erzeugt eine Deep Copy der Tabelle und schreibt alle Werte optional in
    -- eine weitere Tabelle.
    -- @param[type=table] t1 Quelle
    -- @param[type=table] t2 (Optional) Ziel
    -- @return[type=table] Deep Copy
    -- @within table
    --
    table.copy = function (t1, t2)
        t2 = t2 or {};
        assert(type(t1) == "table");
        assert(type(t2) == "table");
        return Swift:CopyTable(t1, t2);
    end

    ---
    -- Kehr die Reihenfolge aller Elemente in einer Array Table um.
    -- @param[type=table] t1 Table
    -- @return[type=table] Invertierte Table
    -- @within table
    --
    table.invert = function (t1)
        assert(type(t1) == "table");
        local t2 = {};
        for i= #t1, 1, -1 do
            table.insert(t2, t1[i]);
        end
        return t2;
    end

    ---
    -- Fügt ein Element am Anfang einer Tabelle ein.
    -- @param[type=table] t Table
    -- @param             e Element
    -- @within table
    --
    table.push = function (t, e)
        assert(type(t) == "table");
        table.insert(t, 1, e);
    end

    ---
    -- Entfernt das erste Element einer Table und gibt es zurück.
    -- @param[type=table] t Table
    -- @return Element
    -- @within table
    --
    table.pop = function (t)
        assert(type(t) == "table");
        return table.remove(t, 1);
    end

    ---
    -- Serialisiert eine Table als String. Funktionen, Threads und Upvalues
    -- können nicht serialisiert werden.
    -- @param[type=table] t Table
    -- @return[type=string] Serialisierte Table
    -- @within table
    --
    table.tostring = function(t)
        return Swift:ConvertTableToString(t);
    end

    ---
    -- Setzt die Metatable für die übergebene Table.
    -- @param[type=table] t    Table
    -- @param[type=table] meta Metatable
    -- @within table
    --
    table.setMetatable = function(t, meta)
        assert(type(t) == "table");
        assert(type(meta) == "table" or meta == nil);
    
        local oldmeta = meta;
        meta = {};
        for k,v in pairs(oldmeta) do
            meta[k] = v;
        end
        oldmeta = getmetatable(t);
        setmetatable(t, meta);
        local k = 0;
        if oldmeta and oldmeta.KeySave and t == QSB.Metatable.Weak[oldmeta.KeySave] then
            k = oldmeta.KeySave;
            if meta == nil then
                QSB.Metatable.Weak[k] = nil;
                QSB.Metatablele.Metas[k] = nil;
                return;
            end
        else
            k = QSB.Metatable.Key + 1;
            QSB.Metatable.Key = k;
        end
        QSB.Metatable.Weak[k] = t;
        QSB.Metatable.Metas[k] = meta;
        meta.KeySave = k;
    end

    ---
    -- Erneuert alle Metatables und deren Referenzen.
    -- @within table
    -- @local
    --
    table.restoreMetatables = function()
        for k, tab in pairs(QSB.Metatable.Weak) do
            setmetatable(tab, QSB.Metatable.Metas[k]);
        end
        setmetatable(QSB.Metatable.Weak, {__mode = "v"});
        setmetatable(QSB.Metatable.Metas, {__mode = "v"});
    end
    table.restoreMetatables();
end

function API.OverrideString()
    -- TODO: Implement!

    ---
    -- Gibt true zurück, wenn der Teil-String enthalten ist.
    -- @param[type=string] s Pattern
    -- @return[type=boolean] Pattern vorhanden
    -- @within string
    --
    string.contains = function (self, s)
        return self:find(s) ~= nil;
    end

    ---
    -- Gibt die Position des Teil-String im String zurück.
    -- @param[type=string] s Pattern
    -- @return[type=number] Startindex
    -- @return[type=number] Endindex
    -- @within string
    --
    string.indexOf = function (self, s)
        return self:find(s);
    end
end

-- Script Events

---
-- Liste der grundlegenden Script Events.
--
-- @field SaveGameLoaded Ein Spielstand wird geladen.
-- @field EscapePressed Escape wurde gedrückt. (Parameter: PlayerID)
-- @field QuestFailure Ein Quest schlug fehl (Parameter: QuestID)
-- @field QuestInterrupt Ein Quest wurde unterbrochen (Parameter: QuestID)
-- @field QuestReset Ein Quest wurde zurückgesetzt (Parameter: QuestID)
-- @field QuestSuccess Ein Quest wurde erfolgreich abgeschlossen (Parameter: QuestID)
-- @field QuestTrigger Ein Quest wurde aktiviert (Parameter: QuestID)
-- @field CustomValueChanged Eine Custom Variable hat sich geändert (Parameter: Name, OldValue, NewValue)
-- @field LanguageSet Die Sprache wurde geändert (Parameter: OldLanguage, NewLanguage)
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

-- Script Event Callback --

---
-- Wird aufgerufen, wenn ein beliebiges Event empfangen wird.
--
-- Wenn ein Event empfangen wird, kann es sein, dass Parameter mit übergeben
-- werden. Um für alle Events gewappnet zu sein, muss der Listener als
-- Varargs-Funktion, also mit ... in der Parameterliste geschrieben werden.
--
-- Zugegriffen wird auf die Parameter, indem die Parameterliste entsprechend
-- indexiert wird. Für Parameter 1 wird dann arg[1] geschrieben usw.
--
-- @param[type=number] _EventID ID des Event
-- @param              ...      Parameterliste des Event
-- @within Event
--
-- @usage
-- GameCallback_QSB_OnEventReceived = function(_EventID, ...)
--     if _EventID == QSB.ScriptEvents.EscapePressed then
--         API.AddNote("Player " ..arg[1].. " has pressed Escape!");
--     elseif _EventID == QSB.ScriptEvents.SaveGameLoaded then
--         API.AddNote("A save has been loaded!");
--     end
-- end
--
GameCallback_QSB_OnEventReceived = function(_EventID, ...)
end

-- Base --

---
-- Installiert Swift.
--
-- @within Base
-- @local
--
function API.Install()
    Swift:LoadCore();
    Swift:LoadModules();
    collectgarbage("collect");
end

---
-- Prüft, ob das laufende Spiel in der History Edition gespielt wird.
--
-- @return[type=boolean] Spiel ist History Edition
-- @within Base
--
function API.IsHistoryEdition()
    return Swift:IsHistoryEdition();
end

---
-- Prüft, ob das laufende Spiel eine Multiplayerpartie in der History Edition
-- ist.
--
-- <b>Hinweis</b>: Es ist unmöglich, dass Original und History Edition in einer
-- Partie aufeinander treffen, da die alten Server längst abgeschaltet und die
-- Option zum LAN-Spiel in der HE nicht verfügbar ist.
--
-- @return[type=boolean] Spiel ist History Edition
-- @within Base
--
function API.IsHistoryEditionNetworkGame()
    return API.IsHistoryEdition() and Framework.IsNetworkGame();
end

-- Debug

---
-- Aktiviert oder deaktiviert Optionen des Debug Mode.
--
-- <b>Hinweis:</b> Du kannst alle Optionen unbegrenzt oft beliebig ein-
-- und ausschalten.
--
-- @param[type=boolean] _CheckAtRun       Custom Behavior prüfen an/aus
-- @param[type=boolean] _TraceQuests      Quest Trace an/aus
-- @param[type=boolean] _DevelopingCheats Cheats an/aus
-- @param[type=boolean] _DevelopingShell  Eingabeaufforderung an/aus
-- @within Debug
--
function API.ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
    Swift:ActivateDebugMode(
        _CheckAtRun == true,
        _TraceQuests == true,
        _DevelopingCheats == true,
        _DevelopingShell == true
    );
end

---
-- Prüft, ob der Debug Behavior überprüfen darf.
--
-- <b>Hinweis:</b> Module müssen die Behandlung dieser Option selbst
-- inmpelentieren. Das Core Modul übernimmt diese Aufgabe nicht!
--
-- @return[type=boolean] Option Aktiv
-- @within Debug
--
function API.IsDebugBehaviorCheckActive()
    return Swift.m_CheckAtRun == true;
end

---
-- Prüft, ob Quest Trace benutzt wird.
--
-- @return[type=boolean] Option Aktiv
-- @within Debug
--
function API.IsDebugQuestTraceActive()
    return Swift.m_TraceQuests == true;
end

---
-- Prüft, ob die Cheats aktiviert sind.
--
-- @return[type=boolean] Option Aktiv
-- @within Debug
--
function API.IsDebugCheatsActive()
    return Swift.m_DevelopingCheats == true;
end

---
-- Prüft, ob die Eingabeaufforderung aktiv ist.
--
-- <b>Hinweis:</b> Viele Kommandos müssen von Modulen implementiert werden.
-- Siehe die Doku dieser Module.
--
-- @return[type=boolean] Option Aktiv
-- @within Debug
--
function API.IsDebugShellActive()
    return Swift.m_DevelopingShell == true;
end

---
-- Legt ein neues Script Event an.
--
-- @param[type=string]   _Name     Identifier des Event
-- @return[type=number] ID des neuen Script Event
-- @within Event
--
function API.RegisterScriptEvent(_Name)
    return Swift:CreateScriptEvent(_Name, nil);
end

---
-- Sendet das Script Event mit der übergebenen ID und überträgt optional
-- Parameter.
--
-- @param[type=number] _ID ID des Event
-- @param              ... Optionale Parameter
-- @within Event
--
function API.SendScriptEvent(_ID, ...)
    Swift:DispatchScriptEvent(_ID, unpack(arg));
end

-- Base API

---
-- Speichert den Wert der Custom Variable im globalen und lokalen Skript.
--
-- Des weiteren wird in beiden Umgebungen ein Event ausgelöst, wenn der Wert
-- gesetzt wird. Das Event bekommt den Namen der Variable, den alten Wert und
-- den neuen Wert übergeben.
--
-- @param[type=boolean] _Name  Name der Custom Variable
-- @param               _Value Neuer Wert
-- @within Base
--
-- @usage local Value = API.ObtainCustomVariable("MyVariable", 0);
--
function API.SaveCustomVariable(_Name, _Value)
    Swift:SetCustomVariable(_Name, _Value);
end

---
-- Gibt den aktuellen Wert der Custom Variable zurück oder den Default-Wert.
-- @param[type=boolean] _Name    Name der Custom Variable
-- @param               _Default (Optional) Defaultwert falls leer
-- @return Wert
-- @within Base
--
-- @usage local Value = API.ObtainCustomVariable("MyVariable", 0);
--
function API.ObtainCustomVariable(_Name, _Default)
    local Value = QSB.CustomVariable[_Name];
    if not Value and _Default then
        Value = _Default;
    end
    return Value;
end

---
-- Ermittelt den lokalisierten Text anhand der eingestellten Sprache der QSB.
--
-- Wird ein normaler String übergeben, wird dieser sofort zurückgegeben. Bei
-- einem Table mit einem passenden Sprach-Key (de, en) wird die entsprechende
-- Sprache zurückgegeben. Sollte ein Nested Table übergeben werden, werden alle
-- Texte innerhalb des Tables rekursiv übersetzt als Table zurückgegeben. Alle
-- anderen Werte sind nicht in der Rückgabe enthalten.
--
-- @param _Text Anzeigetext (String oder Table)
-- @return Übersetzten Text oder Table mit Texten
-- @within Base
--
-- @usage -- Einstufige Table
-- local Text = API.Localize({de = "Deutsch", en = "English"});
-- -- Rückgabe: "Deutsch"
--
-- -- Mehrstufige Table
-- API.Localize{{de = "Deutsch", en = "English"}, {{1,2,3,4, de = "A", en = "B"}}}
-- -- Rückgabe: {"Deutsch", {"A"}}
--
function API.Localize(_Text)
    return Swift:Localize(_Text);
end

---
-- Stellt die angegebene Sprache zur Verwendung durch die QSB ein.
--
-- Alle von der QSB erzeugten Texte werden der übergebenen Sprache angepasst.
--
-- @param _Language Genutzte Sprache
-- @within Base
--
function API.ChangeDesiredLanguage(_Language)
    if GUI or type(_Language) ~= "string" or _Language:len() ~= 2 then
        return;
    end
    Swift:ChangeSystemLanguage(_Language);
end

---
-- Wandelt underschiedliche Darstellungen einer Boolean in eine echte um.
--
-- Jeder String, der mit j, t, y oder + beginnt, wird als true interpretiert.
-- Alles andere als false.
--
-- Ist die Eingabe bereits ein Boolean wird es direkt zurückgegeben.
--
-- @param _Value Wahrheitswert
-- @return[type=boolean] Wahrheitswert
-- @within Base
-- @local
--
-- @usage local Bool = API.ToBoolean("+")  --> Bool = true
-- local Bool = API.ToBoolean("no") --> Bool = false
--
function API.ToBoolean(_Value)
    return Swift:ToBoolean(_Value);
end
AcceptAlternativeBoolean = API.ToBoolean;

---
-- Rundet eine Dezimalzahl kaufmännisch ab.
--
-- <b>Hinweis</b>: Es wird manuell gerundet um den Rundungsfehler in der
-- History Edition zu umgehen.
--
-- @param[type=string] _Value         Zu rundender Wert
-- @param[type=string] _DecimalDigits Maximale Dezimalstellen
-- @return[type=number] Abgerundete Zahl
-- @within Base
--
function API.Round(_Value, _DecimalDigits)
    _DecimalDigits = _DecimalDigits or 2;
    _DecimalDigits = (_DecimalDigits < 0 and 0) or _DecimalDigits;
    local Value = tostring(_Value);
    if tonumber(Value) == nil then
        return 0;
    end
    local s,e = Value:find(".", 1, true);
    if e then
        local Overhead = nil;
        if Value:len() > e + _DecimalDigits then
            if _DecimalDigits > 0 then
                local TmpNum;
                if tonumber(Value:sub(e+_DecimalDigits+1, e+_DecimalDigits+1)) >= 5 then
                    TmpNum = tonumber(Value:sub(e+1, e+_DecimalDigits)) +1;
                    Overhead = (_DecimalDigits == 1 and TmpNum == 10);
                else
                    TmpNum = tonumber(Value:sub(e+1, e+_DecimalDigits));
                end
                Value = Value:sub(1, e-1);
                if (tostring(TmpNum):len() >= _DecimalDigits) then
                    Value = Value .. "." ..TmpNum;
                end
            else
                local NewValue = tonumber(Value:sub(1, e-1));
                if tonumber(Value:sub(e+_DecimalDigits+1, e+_DecimalDigits+1)) >= 5 then
                    NewValue = NewValue +1;
                end
                Value = NewValue;
            end
        else
            Value = (Overhead and (tonumber(Value) or 0) +1) or
                     Value .. string.rep("0", Value:len() - (e + _DecimalDigits))
        end
    end
    return tonumber(Value);
end
Round = API.Round;

---
-- Fügt eine Bedingung für Quicksaves hinzu.
--
-- Die Bedingungsfunktion erwartet keine Parameter und muss true zurückgeben,
-- kein Quicksave möglich sein soll.
--
-- <b>Hinweis:</b> Nur im lokalen Skript möglich!
--
-- @param[type=function] _Function Bedingungsprüfung
-- @within Base
--
function API.AddBlockQuicksaveCondition(_Function)
    if not GUI or type(_Function) ~= "function" then
        return;
    end
    Swift:AddBlockQuicksaveCondition(_Function);
end

function API.IsLoadscreenVisible()
    return Swift.m_LoadScreenHidden ~= true;
end

-- Entity

---
-- Ersetzt ein Entity mit einem neuen eines anderen Typs. Skriptname,
-- Rotation, Position und Besitzer werden übernommen.
--
-- <b>Hinweis</b>: Die Entity-ID ändert sich und beim Ersetzen von
-- Spezialgebäuden kann eine Niederlage erfolgen.
--
-- @param _Entity      Entity (Skriptname oder ID)
-- @param[type=number] _Type     Neuer Typ
-- @param[type=number] _NewOwner (optional) Neuer Besitzer
-- @return[type=number] Entity-ID des Entity
-- @within Entity
-- @usage API.ReplaceEntity("Stein", Entities.XD_ScriptEntity)
--
function API.ReplaceEntity(_Entity, _Type, _NewOwner)
    local eID = GetID(_Entity);
    if eID == 0 then
        return;
    end
    local pos = GetPosition(eID);
    local player = _NewOwner or Logic.EntityGetPlayer(eID);
    local orientation = Logic.GetEntityOrientation(eID);
    local name = Logic.GetEntityName(eID);
    DestroyEntity(eID);
    -- TODO: Logging
    if Logic.IsEntityTypeInCategory(_Type, EntityCategories.Soldier) == 1 then
        return CreateBattalion(player, _Type, pos.X, pos.Y, 1, name, orientation);
    else
        return CreateEntity(player, _Type, pos, name, orientation);
    end
end
ReplaceEntity = API.ReplaceEntity;

---
-- Gibt den Typen des Entity zurück.
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Typ des Entity
-- @within Entity
--
function API.GetEntityType(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return Logic.GetEntityType(EntityID);
    end
    error("API.EntityGetType: _Entity (" ..tostring(_Entity).. ") must be a leader with soldiers!");
    return 0;
end
GetType = API.GetEntityType

---
-- Gibt den Typnamen des Entity zurück.
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=string] Typname des Entity
-- @within Entity
--
function API.GetEntityTypeName(_Entity)
    if not IsExisting(_Entity) then
        error("API.GetEntityTypeName: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    return Logic.GetEntityTypeName(API.GetEntityType(_Entity));
end
GetTypeName = API.GetEntityTypeName;

---
-- Setzt das Entity oder das Battalion verwundbar oder unverwundbar.
--
-- @param               _Entity Entity (Scriptname oder ID)
-- @param[type=boolean] _Flag Verwundbar
-- @within Entity
--
function API.SetEntityVulnerableFlag(_Entity, _Flag)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    local VulnerabilityFlag = (_Flag and 1) or 0;
    if EntityID > 0 then
        if API.CountSoldiersOfGroup(EntityID) > 0 then
            for k, v in pairs(API.GetGroupSoldiers(EntityID)) do
                Logic.SetEntityInvulnerabilityFlag(v, VulnerabilityFlag);
            end
        end
        Logic.SetEntityInvulnerabilityFlag(EntityID, VulnerabilityFlag);
    end
end
SetVulnerable = API.SetEntityVulnerableFlag;

MakeVulnerable = function(_Entity)
    API.SetEntityVulnerableFlag(_Entity, false);
end
MakeInvulnerable = function(_Entity)
    API.SetEntityVulnerableFlag(_Entity, true);
end

---
-- Rotiert ein Entity, sodass es zum Ziel schaut.
--
-- @param _entity         Entity (Skriptname oder ID)
-- @param _entityToLookAt Ziel (Skriptname oder ID)
-- @param[type=number]    _offsetEntity Winkel Offset
-- @within Entity
-- @usage API.LookAt("Hakim", "Alandra")
--
function API.LookAt(_entity, _entityToLookAt, _offsetEntity)
    local entity = GetID(_entity);
    local entityTLA = GetID(_entityToLookAt);
    if not IsExisting(entity) or not IsExisting(entityTLA) then
        warn("API.LookAt: One entity is invalid or dead!");
        return;
    end
    local eX, eY = Logic.GetEntityPosition(entity);
    local eTLAX, eTLAY = Logic.GetEntityPosition(entityTLA);
    local orientation = math.deg(math.atan2((eTLAY - eY), (eTLAX - eX)));
    if Logic.IsBuilding(entity) == 1 then
        orientation = orientation - 90;
    end
    _offsetEntity = _offsetEntity or 0;
    info("API.LookAt: Entity " ..entity.. " is looking at " ..entityTLA);
    Logic.SetOrientation(entity, orientation + _offsetEntity);
end
LookAt = API.LookAt;

---
-- Lässt zwei Entities sich gegenseitig anschauen.
--
-- @param _entity         Entity (Skriptname oder ID)
-- @param _entityToLookAt Ziel (Skriptname oder ID)
-- @within Entity
-- @usage API.Confront("Hakim", "Alandra")
--
function API.Confront(_entity, _entityToLookAt)
    API.LookAt(_entity, _entityToLookAt);
    API.LookAt(_entityToLookAt, _entity);
end
ConfrontEntities = API.LookAt;

---
-- Sendet einen Handelskarren zu dem Spieler. Startet der Karren von einem
-- Gebäude, wird immer die Position des Eingangs genommen.
--
-- @param _position                        Position (Skriptname oder Positionstable)
-- @param[type=number] _player             Zielspieler
-- @param[type=number] _good               Warentyp
-- @param[type=number] _amount             Warenmenge
-- @param[type=number] _cartOverlay        (optional) Overlay für Goldkarren
-- @param[type=boolean] _ignoreReservation (optional) Marktplatzreservation ignorieren
-- @return[type=number] Entity-ID des erzeugten Wagens
-- @within Entity
-- @usage -- API-Call
-- API.SendCart(Logic.GetStoreHouse(1), 2, Goods.G_Grain, 45)
-- -- Legacy-Call mit ID-Speicherung
-- local ID = SendCart("Position_1", 5, Goods.G_Wool, 5)
--
function API.SendCart(_position, _player, _good, _amount, _cartOverlay, _ignoreReservation)
    local eID = GetID(_position);
    if not IsExisting(eID) then
        return;
    end
    local ID;
    local x,y,z = Logic.EntityGetPos(eID);
    local resCat = Logic.GetGoodCategoryForGoodType(_good);
    local orientation = Logic.GetEntityOrientation(eID);
    if Logic.IsBuilding(eID) == 1 then
        x,y = Logic.GetBuildingApproachPosition(eID);
        orientation = Logic.GetEntityOrientation(eID)-90;
    end

    -- Macht Waren lagerbar im Lagerhaus
    if resCat == GoodCategories.GC_Resource or _good == Goods.G_None then
        local TypeName = Logic.GetGoodTypeName(_good);
        local Category = Logic.GetGoodCategoryForGoodType(_good);
        local SHID = Logic.GetStoreHouse(_player);
        local HQID = Logic.GetHeadquarters(_player);
        if SHID ~= 0 and Logic.GetIndexOnInStockByGoodType(SHID, _good) == -1 then
            local CreateSlot = true;
            if _good ~= Goods.G_Gold or (_good == Goods.G_Gold and HQID == 0) then
                info(
                    "API.SendCart: creating stock for " ..TypeName.. " in" ..
                    "storehouse of player " .._player.. "."
                );
                Logic.AddGoodToStock(SHID, _good, 0, true, true);
            end
        end
    end

    info("API.SendCart: Creating cart ("..
        tostring(_position) ..","..
        tostring(_player) ..","..
        Logic.GetGoodTypeName(_good) ..","..
        tostring(_amount) ..","..
        tostring(_cartOverlay) ..","..
        tostring(_ignoreReservation) ..
    ")");

    if resCat == GoodCategories.GC_Resource then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_ResourceMerchant, x, y,orientation,_player)
    elseif _good == Goods.G_Medicine then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Medicus, x, y,orientation,_player)
    elseif _good == Goods.G_Gold or _good == Goods.G_None or _good == Goods.G_Information then
        if _cartOverlay then
            ID = Logic.CreateEntityOnUnblockedLand(_cartOverlay, x, y,orientation,_player)
        else
            ID = Logic.CreateEntityOnUnblockedLand(Entities.U_GoldCart, x, y,orientation,_player)
        end
    else
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Marketer, x, y,orientation,_player)
    end
    info("API.SendCart: Executing hire merchant...");
    Logic.HireMerchant( ID, _player, _good, _amount, _player, _ignoreReservation)
    info("API.SendCart: Cart has been send successfully.");
    return ID
end
SendCart = API.SendCart;

---
-- Setzt die Gesundheit des Entity. Optional kann die Gesundheit relativ zur
-- maximalen Gesundheit geändert werden.
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number]  _Health   Neue aktuelle Gesundheit
-- @param[type=boolean] _Relative (Optional) Relativ zur maximalen Gesundheit
-- @within Entity
--
function API.ChangeEntityHealth(_Entity, _Health, _Relative)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
        if type(_Health) ~= "number" or _Health < 0 then
            error("API.ChangeEntityHealth: _Health " ..tostring(_Health).. "must be 0 or greater!");
            return
        end
        _Health = (_Health > MaxHealth and MaxHealth) or _Health;
        if Logic.IsLeader(EntityID) == 1 then
            for k, v in pairs(API.GetGroupSoldiers(EntityID)) do
                API.ChangeEntityHealth(v, _Health, _Relative);
            end
        else
            local OldHealth = Logic.GetEntityHealth(EntityID);
            local NewHealth = _Health;
            if _Relative then
                _Health = (_Health < 0 and 0) or _Health;
                _Health = (_Health > 100 and 100) or _Health;
                NewHealth = math.ceil((MaxHealth) * (_Health/100));
            end
            if NewHealth > OldHealth then
                Logic.HealEntity(EntityID, NewHealth - OldHealth);
            elseif NewHealth < OldHealth then
                Logic.HurtEntity(EntityID, OldHealth - NewHealth);
            end
        end
        return;
    end
    error("API.ChangeEntityHealth: _Entity (" ..tostring(_Entity).. ") does not exist!");
end
SetHealth = API.ChangeEntityHealth;

---
-- Gibt alle Kategorien zurück, zu denen das Entity gehört.
--
-- @param              _Entity Entity (Skriptname oder ID)
-- @return[type=table] Kategorien des Entity
-- @within Entity
--
function API.GetEntityCategoyList(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetEntityCategoyList: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return {};
    end
    local Categories = {};
    for k, v in pairs(EntityCategories) do
        if Logic.IsEntityInCategory(EntityID, v) == 1 then 
            Categories[#Categories+1] = v;
        end
    end
    return Categories;
end
GetCategories = API.GetEntityCategoyList;

---
-- Prüft, ob das Entity mindestens eine der Kategorien hat.
--
-- @param              _Entity Entity (Skriptname oder ID)
-- @param[type=number] ...     Liste mit Kategorien
-- @return[type=boolean] Entity hat Kategorie
-- @within Entity
--
function API.IsEntityInAtLeastOneCategory(_Entity, ...)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        for k, v in pairs(arg) do
            if table.contains(API.GetEntityCategoyList(_Entity), v) then
                return true;
            end
        end
        return;
    end
    error("API.IsEntityInAtLeastOneCategory: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return false;
end
IsInCategory = API.IsEntityInAtLeastOneCategory;

---
-- Gibt die aktuelle Tasklist des Entity zurück.
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Tasklist
-- @within Entity
--
function API.GetEntityTaskList(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetEntityTaskList: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    local CurrentTask = Logic.GetCurrentTaskList(EntityID) or "";
    return TaskLists[CurrentTask];
end
GetTask = API.GetEntityTaskList;

---
-- Weist dem Entity ein Neues Model zu.
--
-- @param              _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _NewModel Neues Model
-- @param[type=number] _AnimSet  (optional) Animation Set
-- @within Entity
--
function API.SetEntityModel(_Entity, _NewModel, _AnimSet)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.SetEntityModel: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if type(_NewModel) ~= "number" or _NewModel < 1 then
        error("API.SetEntityModel: _NewModel (" ..tostring(_NewModel).. ") is wrong!");
        return;
    end
    if _AnimSet and (type(_AnimSet) ~= "number" or _AnimSet < 1) then
        error("API.SetEntityModel: _AnimSet (" ..tostring(_AnimSet).. ") is wrong!");
        return;
    end
    if not _AnimSet then
        Logic.SetModel(EntityID, _NewModel);
    else
        Logic.SetModelAndAnimSet(EntityID, _NewModel, _AnimSet);
    end
end
SetModel = API.SetEntityModel;

---
-- Setzt die aktuelle Tasklist des Entity.
--
-- @param              _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _NewTask Neuer Task
-- @within Entity
--
function API.SetEntityTaskList(_Entity, _NewTask)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.SetEntityTaskList: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if type(_NewTask) ~= "number" or _NewTask < 1 then
        error("API.SetEntityTaskList: _NewTask (" ..tostring(_NewTask).. ") is wrong!");
        return;
    end
    Logic.SetTaskList(EntityID, _NewTask);
end
SetTask = API.SetEntityTaskList;

---
-- Gibt die Ausrichtung des Entity zurück.
--
-- @param               _Entity  Entity (Scriptname oder ID)
-- @return[type=number] Ausrichtung in Grad
-- @within Entity
--
function API.GetEntityOrientation(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return API.Round(Logic.GetEntityOrientation(EntityID));
    end
    error("API.GetEntityOrientation: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return 0;
end
GetOrientation = API.GetEntityOrientation;

---
-- Setzt die Ausrichtung des Entity.
--
-- @param               _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _Orientation Neue Ausrichtung
-- @within Entity
--
function API.SetEntityOrientation(_Entity, _Orientation)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        if type(_Orientation) ~= "number" then
            error("API.SetEntityOrientation: _Orientation is wrong!");
            return
        end
        Logic.SetOrientation(EntityID, API.Round(_Orientation));
    else
        error("API.SetEntityOrientation: _Entity (" ..tostring(_Entity).. ") does not exist!");
    end
end
SetOrientation = API.SetEntityOrientation;

---
-- Gibt die Menge an Rohstoffen des Entity zurück. Optional kann
-- eine neue Menge gesetzt werden.
--
-- @param _Entity  Entity (Scriptname oder ID)
-- @return[type=number] Menge an Rohstoffen
-- @within Entity
--
function API.GetResourceAmount(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return Logic.GetResourceDoodadGoodAmount(EntityID);
    end
    error("API.GetResourceAmount: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return 0;
end
GetResource = API.GetResourceAmount

---
-- Setzt die Menge an Rohstoffen und die durchschnittliche Auffüllmenge
-- in einer Mine.
--
-- @param              _Entity       Rohstoffvorkommen (Skriptname oder ID)
-- @param[type=number] _StartAmount  Menge an Rohstoffen
-- @param[type=number] _RefillAmount Minimale Nachfüllmenge (> 0)
-- @within Entity
--
-- @usage
-- API.SetResourceAmount("mine1", 250, 150);
--
function API.SetResourceAmount(_Entity, _StartAmount, _RefillAmount)
    if GUI or not IsExisting(_Entity) then
        return;
    end
    assert(type(_StartAmount) == "number");
    assert(type(_RefillAmount) == "number");

    local EntityID = GetID(_Entity);
    if not IsExisting(EntityID) or Logic.GetResourceDoodadGoodType(EntityID) == 0 then
        return;
    end
    if Logic.GetResourceDoodadGoodAmount(EntityID) == 0 then
        EntityID = ReplaceEntity(EntityID, Logic.GetEntityType(EntityID));
    end
    Logic.SetResourceDoodadGoodAmount(EntityID, _StartAmount);
    if _RefillAmount then
        QSB.RefillAmounts[EntityID] = _RefillAmount;
    end
end
SetResourceAmount = API.SetResourceAmount;

---
-- Ermittelt alle Entities in der Kategorie auf dem Territorium und gibt
-- sie als Liste zurück.
--
-- @param[type=number] _PlayerID  PlayerID [0-8] oder -1 für alle
-- @param[type=number] _Category  Kategorie, der die Entities angehören
-- @param[type=number] _Territory Zielterritorium
-- @within Entity
-- @local
-- @usage local Found = API.GetEntitiesOfCategoryInTerritory(1, EntityCategories.Hero, 5)
--
function API.GetEntitiesOfCategoryInTerritory(_PlayerID, _Category, _Territory)
    local PlayerEntities = {};
    local Units = {};
    if (_PlayerID == -1) then
        for i=0,8 do
            local NumLast = 0;
            repeat
                Units = { Logic.GetEntitiesOfCategoryInTerritory(_Territory, i, _Category, NumLast) };
                PlayerEntities = Array_Append(PlayerEntities, Units);
                NumLast = NumLast + #Units;
            until #Units == 0;
        end
    else
        local NumLast = 0;
        repeat
            Units = { Logic.GetEntitiesOfCategoryInTerritory(_Territory, _PlayerID, _Category, NumLast) };
            PlayerEntities = Array_Append(PlayerEntities, Units);
            NumLast = NumLast + #Units;
        until #Units == 0;
    end
    return PlayerEntities;
end
GetEntitiesOfCategoryInTerritory = API.GetEntitiesOfCategoryInTerritory;

---
-- Sucht auf den angegebenen Territorium nach Entities mit bestimmten
-- Kategorien. Dabei kann für eine Partei oder für mehrere Parteien gesucht
-- werden.
--
-- @param _PlayerID    PlayerID [0-8] oder Table mit PlayerIDs (Einzelne Spielernummer oder Table)
-- @param _Category    Kategorien oder Table mit Kategorien (Einzelne Kategorie oder Table)
-- @param _Territory   Zielterritorium oder Table mit Territorien (Einzelnes Territorium oder Table)
-- @return[type=table] Liste mit Resultaten
-- @within Entity
--
-- @usage
-- local Result = API.GetEntitiesOfCategoriesInTerritories({1, 2, 3}, EntityCategories.Hero, {5, 12, 23, 24});
--
function API.GetEntitiesOfCategoriesInTerritories(_PlayerID, _Category, _Territory)
    -- Tables erzwingen
    local p = (type(_PlayerID) == "table" and _PlayerID) or {_PlayerID};
    local c = (type(_Category) == "table" and _Category) or {_Category};
    local t = (type(_Territory) == "table" and _Territory) or {_Territory};

    local PlayerEntities = {};
    for i=1, #p, 1 do
        for j=1, #c, 1 do
            for k=1, #t, 1 do  
                local Units = API.GetEntitiesOfCategoryInTerritory(p[i], c[j], t[k]);
                PlayerEntities = Array_Append(PlayerEntities, Units);
            end
        end
    end
    return PlayerEntities;
end
GetEntitiesOfCategoriesInTerritories = API.GetEntitiesOfCategoriesInTerritories;
EntitiesInCategories = API.GetEntitiesOfCategoriesInTerritories;

---
-- Gibt dem Entity einen eindeutigen Skriptnamen und gibt ihn zurück.
-- Hat das Entity einen Namen, bleibt dieser unverändert und wird
-- zurückgegeben.
-- @param[type=number] _EntityID Entity ID
-- @return[type=string] Skriptname
-- @within Entity
--
function API.CreateEntityName(_EntityID)
    if type(_EntityID) == "string" then
        return _EntityID;
    else
        assert(type(_EntityID) == "number");
        local name = Logic.GetEntityName(_EntityID);
        if (type(name) ~= "string" or name == "" ) then
            QSB.GiveEntityNameCounter = (QSB.GiveEntityNameCounter or 0)+ 1;
            name = "AutomaticScriptName_"..QSB.GiveEntityNameCounter;
            Logic.SetEntityName(_EntityID, name);
        end
        return name;
    end
end
GiveEntityName = API.CreateEntityName;

-- Group

---
-- Gibt die Mänge an Soldaten zurück, die dem Entity unterstehen
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=number] Menge an Soldaten
-- @within Gruppe
--
function API.CountSoldiersOfGroup(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.CountSoldiersOfGroup: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    if Logic.IsLeader(EntityID) == 0 then
        return 0;
    end
    local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
    return SoldierTable[1];
end
CoundSoldiers = API.CountSoldiersOfGroup;

---
-- Gibt die IDs aller Soldaten zurück, die zum Battalion gehören.
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=table] Liste aller Soldaten
-- @within Gruppe
--
function API.GetGroupSoldiers(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetGroupSoldiers: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return {};
    end
    if Logic.IsLeader(EntityID) == 0 then
        return {};
    end
    local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
    table.remove(SoldierTable, 1);
    return SoldierTable;
end
GetSoldiers = API.GetGroupSoldiers;

---
-- Gibt den Leader des Soldaten zurück.
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=number] Menge an Soldaten
-- @within Gruppe
--
function API.GetGroupLeader(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetGroupLeader: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Soldier) == 0 then 
        return 0;
    end
    return Logic.SoldierGetLeaderEntityID(EntityID);
end
GetLeader = API.GetGroupLeader;

---
-- Heilt das Entity um die angegebene Menge an Gesundheit.
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number]  _Amount   Geheilte Gesundheit
-- @within Gruppe
--
function API.GroupHeal(_Entity, _Amount)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 or Logic.IsLeader(EntityID) == 1 then
        error("API.GroupHeal: _Entity (" ..tostring(_Entity).. ") must be an existing leader!");
        return;
    end
    if type(_Amount) ~= "number" or _Amount < 0 then
        error("API.GroupHeal: _Amount (" ..tostring(_Amount).. ") must greatier than 0!");
        return;
    end
    API.ChangeEntityHealth(EntityID, Logic.GetEntityHealth(EntityID) + _Amount);
end
HealEntity = API.GroupHeal;

---
-- Verwundet ein Entity oder ein Battallion um die angegebene
-- Menge an Schaden. Bei einem Battalion wird der Schaden solange
-- auf Soldaten aufgeteilt, bis er komplett verrechnet wurde.
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number] _Damage   Schaden
-- @param[type=string] _Attacker Angreifer
-- @within Gruppe
--
function API.GroupHurt(_Entity, _Damage, _Attacker)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GroupHurt: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if API.IsEntityInAtLeastOneCategory(EntityID, EntityCategories.Soldier) then
        API.GroupHurt(API.GetGroupLeader(EntityID), _Damage);
        return;
    end

    local EntityToHurt = EntityID;
    local IsLeader = Logic.IsLeader(EntityToHurt) == 1;
    if IsLeader then
        EntityToHurt = API.GetGroupSoldiers(EntityToHurt)[1];
    end
    if type(_Damage) ~= "number" or _Damage < 0 then
        error("API.GroupHurt: _Damage (" ..tostring(_Damage).. ") must be greater than 0!");
        return;
    end

    if EntityToHurt then
        local Health = Logic.GetEntityHealth(EntityToHurt);
        if Health <= _Damage then
            _Damage = _Damage - Health;
            Logic.HurtEntity(EntityToHurt, Health);
            Swift:TriggerEntityKilledCallbacks(EntityToHurt, _Attacker);
            if IsLeader and _Damage > 0 then
                API.GroupHurt(EntityToHurt, _Damage);
            end
        else
            Logic.HurtEntity(EntityToHurt, _Damage);
            Swift:TriggerEntityKilledCallbacks(EntityToHurt, _Attacker);
        end
    end
end
HurtEntity = API.GroupHurt;

---
-- Aktiviert ein Interaktives Objekt.
--
-- <b>Hinweis</b>: Diese Funktion wird von einem anderen Modul überschrieben!<br>
-- <a href="Swift_2_ObjectInteraction.api.html#API.InteractiveObjectActivate">(2) Object Interaction</a>
--
-- @param[type=string] _EntityName Skriptname des Objektes
-- @param[type=number] _State      State des Objektes
-- @within Entity
--
function API.InteractiveObjectActivate(_ScriptName, _State)
    _State = _State or 0;
    if GUI or not IsExisting(_ScriptName) then
        return;
    end
    for i= 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), i, _State);
    end
end
InteractiveObjectActivate = API.InteractiveObjectActivate;

---
-- Deaktiviert ein interaktives Objekt.
--
-- <b>Hinweis</b>: Diese Funktion wird von einem anderen Modul überschrieben!<br>
-- <a href="Swift_2_ObjectInteraction.api.html#API.InteractiveObjectDeactivate">(2) Object Interaction</a>
--
-- @param[type=string] _EntityName Scriptname des Objektes
-- @within Entity
--
function API.InteractiveObjectDeactivate(_ScriptName)
    if GUI or not IsExisting(_ScriptName) then
        return;
    end
    for i= 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), i, 2);
    end
end
InteractiveObjectDeactivate = API.InteractiveObjectDeactivate;

-- Position

---
-- Bestimmt die Distanz zwischen zwei Punkten. Es können Entity-IDs,
-- Skriptnamen oder Positionstables angegeben werden.
--
-- Wenn die Distanz nicht bestimmt werden kann, wird -1 zurückgegeben.
--
-- @param _pos1 Erste Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @param _pos2 Zweite Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @return[type=number] Entfernung zwischen den Punkten
-- @within Position
-- @usage local Distance = API.GetDistance("HQ1", Logic.GetKnightID(1))
--
function API.GetDistance( _pos1, _pos2 )
    if (type(_pos1) == "string") or (type(_pos1) == "number") then
        _pos1 = GetPosition(_pos1);
    end
    if (type(_pos2) == "string") or (type(_pos2) == "number") then
        _pos2 = GetPosition(_pos2);
    end
    if type(_pos1) ~= "table" or type(_pos2) ~= "table" then
        warn("API.GetDistance: Distance could not be calculated!");
        return -1;
    end
    local xDistance = (_pos1.X - _pos2.X);
    local yDistance = (_pos1.Y - _pos2.Y);
    return math.sqrt((xDistance^2) + (yDistance^2));
end
GetDistance = API.GetDistance;

---
-- Gibt das Entity aus der Liste zurück, welches dem Ziel am nähsten ist.
--
-- @param             _Target Entity oder Position
-- @param[type=table] _List   Liste von Entities oder Positionen
-- @return Nähste Entity oder Position
-- @within Position
-- @usage local Clostest = API.GetClosestToTarget("HQ1", {"Marcus", "Alandra", "Hakim"});
--
function API.GetClosestToTarget(_Target, _List)
    local ClosestToTarget = 0;
    local ClosestToTargetDistance = Logic.WorldGetSize();
    for i= 1, #_List, 1 do
        local DistanceBetween = API.GetDistance(_List[i], _Target);
        if DistanceBetween < ClosestToTargetDistance then
            ClosestToTargetDistance = DistanceBetween;
            ClosestToTarget = _List[i];
        end
    end
    return ClosestToTarget;
end

---
-- Lokalisiert ein Entity auf der Map. Es können sowohl Skriptnamen als auch
-- IDs verwendet werden. Wenn das Entity nicht gefunden wird, wird eine
-- Tabelle mit XYZ = 0 zurückgegeben.
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=table] Positionstabelle {X= x, Y= y, Z= z}
-- @within Position
-- @usage local Position = API.LocateEntity("Hans")
--
function API.LocateEntity(_Entity)
    if _Entity == nil then
        return {X= 1, Y= 1, Z= 1};
    end
    if (type(_Entity) == "table") then
        return _Entity;
    end
    if (not IsExisting(_Entity)) then
        warn("API.LocateEntity: Entity (" ..tostring(_Entity).. ") does not exist!");
        return {X= 0, Y= 0, Z= 0};
    end
    local x, y, z = Logic.EntityGetPos(GetID(_Entity));
    return {X= API.Round(x), Y= API.Round(y), Z= API.Round(y)};
end
GetPosition = API.LocateEntity;

---
-- Bestimmt die Durchschnittsposition mehrerer Entities.
--
-- @param ... Positionen mit Komma getrennt
-- @return[type=table] Durchschnittsposition aller Positionen
-- @within Position
-- @usage local Center = API.GetGeometricFocus("Hakim", "Marcus", "Alandra");
--
function API.GetGeometricFocus(...)
    local SumX = 0;
    local SumY = 0;
    local SumZ = 0;
    for i= 1, #arg, 1 do
        local Position = API.GetPosition(arg[i]);
        if API.IsValidPosition(Position) then
            SumX = SumX + Position.X;
            SumY = SumY + Position.Y;
            if Position.Z then
                SumZ = SumZ + Position.Z;
            end
        end
    end
    return {
        X= 1/#arg * SumX,
        Y= 1/#arg * SumY,
        Z= 1/#arg * SumZ
    };
end
GetAveragePosition = API.GetGeometricFocus;

---
-- Gib eine Position auf einer Linie im relativen Abstand zur ersten Position
-- zurück.
--
-- @param               _Pos1       Erste Position
-- @param               _Pos2       Zweite Position
-- @param[type=number]  _Percentage Entfernung zu Erster Position
-- @return[type=table] Position auf Linie
-- @within Position
-- @usage local Position = API.GetLinePosition("HQ1", "HQ2", 0.75);
--
function API.GetLinePosition(_Pos1, _Pos2, _Percentage)
    if _Percentage > 1 then
        _Percentage = _Percentage / 100;
    end

    if not API.ValidatePosition(_Pos1) and not IsExisting(_Pos1) then
        error("API.GetLinePosition: _Pos1 does not exist or is invalid position!");
        return;
    end
    local Pos1 = _Pos1;
    if type(Pos1) ~= "table" then
        Pos1 = GetPosition(Pos1);
    end

    if not API.ValidatePosition(_Pos2) and not IsExisting(_Pos2) then
        error("API.GetLinePosition: _Pos1 does not exist or is invalid position!");
        return;
    end
    local Pos2 = _Pos2;
    if type(Pos2) ~= "table" then
        Pos2 = GetPosition(Pos2);
    end

	local dx = Pos2.X - Pos1.X;
	local dy = Pos2.Y - Pos1.Y;
    return {X= Pos1.X+(dx*_Percentage), Y= Pos1.Y+(dy*_Percentage)};
end

---
-- Gib Positionen im gleichen Abstand auf der Linie zurück.
--
-- @param               _Pos1    Erste Position
-- @param               _Pos2    Zweite Position
-- @param[type=number]  _Periode Anzahl an Positionen
-- @return[type=table] Positionen auf Linie
-- @within Position
-- @usage local PositionList = API.GetLinePosition("HQ1", "HQ2", 6);
--
function API.GetLinePositions(_Pos1, _Pos2, _Periode)
    local PositionList = {};
    for i= 0, 100, (1/_Periode)*100 do
        local Section = API.GetLinePosition(_Pos1, _Pos2, i);
        table.insert(PositionList, Section);
    end
    return PositionList;
end

---
-- Gibt eine Position auf einer Kreisbahn um einen Punkt zurück.
--
-- @param               _Target          Entity oder Position
-- @param[type=number]  _Distance        Entfernung um das Zentrum
-- @param[type=number]  _Angle           Winkel auf dem Kreis
-- @return[type=table] Position auf Kreisbahn
-- @within Position
-- @usage local Position = API.GetCirclePosition("HQ1", 3000, -45);
--
function API.GetCirclePosition(_Target, _Distance, _Angle)
    if not API.ValidatePosition(_Target) and not IsExisting(_Target) then
        error("API.GetCirclePosition: _Target does not exist or is invalid position!");
        return;
    end

    local Position = _Target;
    local Orientation = 0+ (_Angle or 0);
    if type(_Target) ~= "table" then
        local EntityID = GetID(_Target);
        Orientation = Logic.GetEntityOrientation(EntityID)+(_Angle or 0);
        Position = GetPosition(EntityID);
    end

    local Result = {
        X= Position.X+_Distance * math.cos(math.rad(Orientation)),
        Y= Position.Y+_Distance * math.sin(math.rad(Orientation)),
        Z= Position.Z
    };
    return Result;
end
API.GetRelatiePos = API.GetCirclePosition;

---
-- Gibt Positionen im gleichen Abstand auf der Kreisbahn zurück.
--
-- @param               _Target          Entity oder Position
-- @param[type=number]  _Distance        Entfernung um das Zentrum
-- @param[type=number]  _Periode         Anzahl an Positionen
-- @param[type=number]  _Offset          Start Offset
-- @return[type=table] Positionend auf Kreisbahn
-- @within Position
-- @usage local PositionList = API.GetCirclePosition("Position", 3000, 6, 45);
--
function API.GetCirclePositions(_Target, _Distance, _Periode, _Offset)
    local Periode = Round(360 / _Periode, 0);
    local PositionList = {};
    for i= (Periode + _Offset), (360 + _Offset) do
        local Section = API.GetCirclePosition(_Target, _Distance, i);
        table.insert(PositionList, Section);
    end
    return PositionList;
end

---
-- Prüft, ob eine Positionstabelle eine gültige Position enthält.
--
-- Eine Position ist Ungültig, wenn sie sich nicht auf der Welt befindet.
-- Das ist der Fall bei negativen Werten oder Werten, welche die Größe
-- der Welt übersteigen.
--
-- @param[type=table] _pos Positionstable {X= x, Y= y}
-- @return[type=boolean] Position ist valide
-- @within Position
--
function API.IsValidPosition(_pos)
    if type(_pos) == "table" then
        if (_pos.X ~= nil and type(_pos.X) == "number") and (_pos.Y ~= nil and type(_pos.Y) == "number") then
            local world = {Logic.WorldGetSize()};
            if _pos.Z and _pos.Z < 0 then
                return false;
            end
            if _pos.X < world[1] and _pos.X > 0 and _pos.Y < world[2] and _pos.Y > 0 then
                return true;
            end
        end
    end
    return false;
end
IsValidPosition = API.IsValidPosition;

---
-- Berechnet den Faktor der linearen Interpolation.
--
-- @param[type=number] _Start   Startwert
-- @param[type=number] _Current Aktueller Wert
-- @param[type=number] _End     Endwert
-- @return[type=number] Interpolationsfaktor
-- @within Mathematik
--
function API.LERP(_Start, _Current, _End)
    local Factor = (_Current - _Start) / _End;
    if Factor > 1 then
        Factor = 1;
    end
    return Factor;
end

---
-- Gibt die ID des Quests mit dem angegebenen Namen zurück. Existiert der
-- Quest nicht, wird nil zurückgegeben.
--
-- @param[type=string] _Name Name des Quest
-- @return[type=number] ID des Quest
-- @within Quest
--
function API.GetQuestID(_Name)
    if type(_Name) == "number" then
        return _Name;
    end
    for k, v in pairs(Quests) do
        if v and k > 0 then
            if v.Identifier == _Name then
                return k;
            end
        end
    end
end
GetQuestID = API.GetQuestID;

---
-- Prüft, ob zu der angegebenen ID ein Quest existiert. Wird ein Questname
-- angegeben wird dessen Quest-ID ermittelt und geprüft.
--
-- @param[type=number] _QuestID ID oder Name des Quest
-- @return[type=boolean] Quest existiert
-- @within Quest
--
function API.IsValidQuest(_QuestID)
    return Quests[_QuestID] ~= nil or Quests[API.GetQuestID(_QuestID)] ~= nil;
end
IsValidQuest = API.IsValidQuest;

---
-- Prüft den angegebenen Questnamen auf verbotene Zeichen.
--
-- @param[type=number] _Name Name des Quest
-- @return[type=boolean] Name ist gültig
-- @within Quest
--
function API.IsValidQuestName(_Name)
    return string.find(_Name, "^[A-Za-z0-9_ @ÄÖÜäöüß]+$") ~= nil;
end
IsValidQuestName = API.IsValidQuestName;

---
-- Lässt den Quest fehlschlagen.
--
-- Der Status wird auf Over und das Resultat auf Failure gesetzt.
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Quest
--
function API.FailQuest(_QuestName, _NoMessage)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            Logic.DEBUG_AddNote("fail quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Fail();
        -- Note: Event is send in QuestTemplate:Fail()!
    end
end
FailQuestByName = API.FailQuest;

---
-- Startet den Quest neu.
--
-- Der Quest muss beendet sein um ihn wieder neu zu starten. Wird ein Quest
-- neu gestartet, müssen auch alle Trigger wieder neu ausgelöst werden, außer
-- der Quest wird manuell getriggert.
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Quest
--
function API.RestartQuest(_QuestName, _NoMessage)
    -- Alle Änderungen an Standardbehavior müssen hier berücksichtigt werden.
    -- Wird ein Standardbehavior in einem Modul verändert, muss auch diese
    -- Funktion angepasst oder überschrieben werden.
    
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            Logic.DEBUG_AddNote("restart quest " .._QuestName);
        end

        if Quest.Objectives then
            local questObjectives = Quest.Objectives;
            for i = 1, questObjectives[0] do
                local objective = questObjectives[i];
                objective.Completed = nil
                local objectiveType = objective.Type;

                if objectiveType == Objective.Deliver then
                    local data = objective.Data;
                    data[3] = nil;
                    data[4] = nil;
                    data[5] = nil;
                    data[9] = nil;

                elseif g_GameExtraNo and g_GameExtraNo >= 1 and objectiveType == Objective.Refill then
                    objective.Data[2] = nil;

                elseif objectiveType == Objective.Protect or objectiveType == Objective.Object then
                    local data = objective.Data;
                    for j=1, data[0], 1 do
                        data[-j] = nil;
                    end

                elseif objectiveType == Objective.DestroyEntities and objective.Data[1] == 2 and objective.DestroyTypeAmount then
                    objective.Data[3] = objective.DestroyTypeAmount;
                elseif objectiveType == Objective.DestroyEntities and objective.Data[1] == 3 then
                    objective.Data[4] = nil;
                    objective.Data[5] = nil;

                elseif objectiveType == Objective.Distance then
                    if objective.Data[1] == -65565 then
                        objective.Data[4].NpcInstance = nil;
                    end

                elseif objectiveType == Objective.Custom2 and objective.Data[1].Reset then
                    objective.Data[1]:Reset(Quest, i);
                end
            end
        end

        local function resetCustom(_type, _customType)
            local Quest = Quest;
            local behaviors = Quest[_type];
            if behaviors then
                for i = 1, behaviors[0] do
                    local behavior = behaviors[i];
                    if behavior.Type == _customType then
                        local behaviorDef = behavior.Data[1];
                        if behaviorDef and behaviorDef.Reset then
                            behaviorDef:Reset(Quest, i);
                        end
                    end
                end
            end
        end

        resetCustom("Triggers", Triggers.Custom2);
        resetCustom("Rewards", Reward.Custom);
        resetCustom("Reprisals", Reprisal.Custom);

        -- Quest Output zurücksetzen
        if Quest.Visible_OrigDebug then
            Quest.Visible = Quest.Visible_OrigDebug;
            Quest.Visible_OrigDebug = nil;
        end
        if Quest.ShowEndMessage then
            Quest.ShowEndMessage = Quest.ShowEndMessage_OrigDebug;
            Quest.ShowEndMessage_OrigDebug = nil;
        end
        if Quest.QuestStartMsg_OrigDebug then
            Quest.QuestStartMsg = Quest.QuestStartMsg_OrigDebug;
            Quest.QuestStartMsg_OrigDebug = nil;
        end
        if Quest.QuestSuccessMsg_OrigDebug then
            Quest.QuestSuccessMsg = Quest.QuestSuccessMsg_OrigDebug;
            Quest.QuestSuccessMsg_OrigDebug = nil;
        end
        if Quest.QuestFailureMsg_OrigDebug then
            Quest.QuestFailureMsg = Quest.QuestFailureMsg_OrigDebug;
            Quest.QuestFailureMsg_OrigDebug = nil;
        end

        Quest.Result = nil;
        local OldQuestState = Quest.State;
        Quest.State = QuestState.NotTriggered;
        Logic.ExecuteInLuaLocalState("LocalScriptCallback_OnQuestStatusChanged("..Quest.Index..")");
        if OldQuestState == QuestState.Over then
            StartSimpleJobEx(_G[QuestTemplate.Loop], Quest.QueueID);
        end
        -- Note: This is a special operation outside of the quest system!
        Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestReset, QuestID);
        Logic.ExecuteInLuaLocalState(string.format(
            "Swift:DispatchScriptEvent(QSB.ScriptEvents.QuestReset, %d)",
            QuestID
        ));
        return QuestID, Quest;
    end
end
RestartQuestByName = API.RestartQuest;

---
-- Startet den Quest sofort, sofern er existiert.
--
-- Dabei ist es unerheblich, ob die Bedingungen zum Start erfüllt sind.
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Quest
--
function API.StartQuest(_QuestName, _NoMessage)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            Logic.DEBUG_AddNote("start quest " .._QuestName);
        end
        Quest:SetMsgKeyOverride();
        Quest:SetIconOverride();
        Quest:Trigger();
        -- Note: Event is send in QuestTemplate:Trigger()!
    end
end
StartQuestByName = API.StartQuest;

---
-- Unterbricht den Quest.
--
-- Der Status wird auf Over und das Resultat auf Interrupt gesetzt. Sind Marker
-- gesetzt, werden diese entfernt.
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Quest
--
function API.StopQuest(_QuestName, _NoMessage)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            Logic.DEBUG_AddNote("interrupt quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Interrupt(-1);
        -- Note: Event is send in QuestTemplate:Interrupt()!
    end
end
StopQuestByName = API.StopQuest;

---
-- Gewinnt den Quest.
--
-- Der Status wird auf Over und das Resultat auf Success gesetzt.
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Quest
--
function API.WinQuest(_QuestName, _NoMessage)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            Logic.DEBUG_AddNote("win quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Success();
        -- Note: Event is send in QuestTemplate:Success()!
    end
end
WinQuestByName = API.WinQuest;

