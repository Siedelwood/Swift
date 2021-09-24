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
-- <b>Diese Funktion ist der offizielle Nachfolger der Laufschrift!</b>
--
-- Der Effekt startet erst, nachdem die Map geladen ist. Wenn ein Briefing
-- läuft, wird gewartet, bis das Briefing beendet ist. Wärhend der Effekt
-- läuft, können wiederrum keine Briefings starten.
--
-- <b>Hinweis</b>: Steuerzeichen wie {cr} oder {@color} werden als ein Token
-- gewertet und immer sofort eingeblendet. Steht z.B. {cr}{cr} im Text, werden
-- die Zeichen atomar behandelt, als seien sie ein einzelnes Zeichen.
-- Gibt es mehr als 1 Leerzeichen hintereinander, werden alle zusammenhängenden
-- Leerzeichen auf ein Leerzeichen reduziert!
--
-- @param[type=string]   _Text            Anzuzeigender Text
-- @param[type=string]   _BlackBackground Schwarzen Hintergrund verwenden
-- @param[type=function] _Callback        Funktion nach Ende des Effekt
--
-- @usage
-- local Text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "..
--              " sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
--              " magna aliquyam erat, sed diam voluptua. At vero eos et"..
--              " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
--              " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
--              " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
--              " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
--              " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
--              " et accusam et justo duo dolores et ea rebum. Stet clita"..
--              " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
--              " dolor sit amet.";
-- local Callback = function(_Data)
--     -- Hier kann was passieren
-- end
-- API.SimpleTypewriter(Text, true, Callback);
-- @within Anwenderfunktionen
--
function API.SimpleTypewriter(_Text, _BlackBackground, _Callback)
    if GUI then
        return;
    end
    QSB.SimpleTypewriter
        :New(API.ConvertPlaceholders(API.Localize(_Text)), _Callback)
        :SetBlackBackground(_BlackBackground)
        :Start();
end

