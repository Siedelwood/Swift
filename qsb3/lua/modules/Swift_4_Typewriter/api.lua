--[[
Swift_4_Typewriter/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht die Anzeige eines fortlaufend getippten Text auf dem Bildschirm.
--
-- Der Text kann mit oder ohne schwarzem Hintergrund angezeigt werden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_InputOutputCore.api.html">(1) Input/Output Core</a></li>
-- <li><a href="Swift_1_DisplayCore.api.html">(1) Display Core</a></li>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Blendet einen Text Zeichen für Zeichen auf schwarzem Grund ein.
--
-- Der Effekt startet erst, nachdem die Map geladen ist. Wenn ein Briefing
-- läuft, wird gewartet, bis das Briefing beendet ist. Wärhend der Effekt
-- läuft, können wiederrum keine Briefings starten.
--
-- Mögliche Werte:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string|table</td>
-- <td>Der anzuzeigene Text</td>
-- </tr>
-- <tr>
-- <td>Callback</td>
-- <td>function</td>
-- <td>(Optional) Funktion nach Abschluss der Textanzeige (Default: nil)</td>
-- </tr>
-- <tr>
-- <td>Position</td>
-- <td></td>
-- <td>(Optional) Position der Kamera (Default: nil)</td>
-- </tr>
-- <tr>
-- <td>CharSpeed</td>
-- <td>number</td>
-- <td>(Optional) Die Schreibgeschwindigkeit (Default: 1.0) </td>
-- </tr>
-- <tr>
-- <td>Waittime</td>
-- <td></td>
-- <td>(Optional) Initiale Wartezeigt bevor der Effekt startet</td>
-- </tr>
-- <tr>
-- <td>Opacity</td>
-- <td></td>
-- <td>(Optional) Durchsichtigkeit des Hintergrund (Default: 1) </td>
-- </tr>
-- <tr>
-- <td>Color</td>
-- <td>table</td>
-- <td>(Optional) Farbe des Hintergrund (Default: {R= 0, G= 0, B= 0}}</td>
-- </tr>
-- </table>
--
-- <b>Hinweis</b>: Steuerzeichen wie {cr} oder {@color} werden als ein Token
-- gewertet und immer sofort eingeblendet. Steht z.B. {cr}{cr} im Text, werden
-- die Zeichen atomar behandelt, als seien sie ein einzelnes Zeichen.
-- Gibt es mehr als 1 Leerzeichen hintereinander, werden alle zusammenhängenden
-- Leerzeichen (vom Spiel) auf ein Leerzeichen reduziert!
--
-- @param[type=table] _Data Konfiguration
--
-- @usage
-- API.SimpleTypewriter {
--     Text     = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "..
--                "sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
--                "magna aliquyam erat, sed diam voluptua. At vero eos et"..
--                " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
--                " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
--                " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
--                " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
--                " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
--                " et accusam et justo duo dolores et ea rebum. Stet clita"..
--                " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
--                " dolor sit amet.",
--     Callback = function(_Data)
--         -- Hier kann was passieren
--     end
-- };
-- @within Anwenderfunktionen
--
function API.SimpleTypewriter(_Data)
    if GUI then
        return;
    end
    local Instance = QSB.SimpleTypewriter:New(_Data);
    if _Data.Callback then
        Instance:SetCallback(_Data.Callback);
    end
    if _Data.Position then
        Instance:SetPosition(_Data.Position);
    end
    if _Data.CharSpeed and _Data.CharSpeed > 0 then
        Instance:SetSpeed(_Data.CharSpeed);
    end
    if _Data.Waittime and _Data.Waittime > 0 then
        Instance:SetWaittime(_Data.Waittime);
    end
    if _Data.Opacity and _Data.Opacity >= 0 and _Data.Opacity <= 1 then
        Instance:SetOpacity(_Data.Opacity);
    end
    if _Data.Color then
        Instance:SetColor(_Data.Color.R, _Data.Color.G, _Data.Color.B);
    end
    Instance:Start();
end

