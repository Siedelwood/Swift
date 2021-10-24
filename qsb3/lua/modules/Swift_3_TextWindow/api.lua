--[[
Swift_3_TextWindow/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Mit diesem Modul kann ein Textfenster zur Darstellung eines Textes erteugt
-- werden.
--
-- <b>Hinweis</b>: Diese Funktionalitit ist im Multiplayer nicht verfügbar.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_InputOutputCore.api.html">(1) Input/Output Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Öffnet ein einfaches Textfenster mit dem angegebenen Text.
--
-- Die Länge des Textes ist nicht beschränkt. Überschreitet der Text die
-- Größe des Fensters, wird automatisch eine Bildlaufleiste eingeblendet.
--
-- @param[type=string] _Caption Titel des Fenster
-- @param[type=string] _content Inhalt des Fenster
-- @within Anwenderfunktionen
--
-- @usage
-- local Text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "..
--              "sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
--              "magna aliquyam erat, sed diam voluptua. At vero eos et"..
--              " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
--              " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
--              " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
--              " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
--              " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
--              " et accusam et justo duo dolores et ea rebum. Stet clita"..
--              " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
--              " dolor sit amet.";
-- API.SimpleTextWindow("Überschrift", Text);
--
function API.SimpleTextWindow(_Caption, _Content)
    _Caption = API.ConvertPlaceholders(API.Localize(_Caption));
    _Content = API.ConvertPlaceholders(API.Localize(_Content));
    if not GUI then
        Logic.ExecuteInLuaLocalState(
            string.format([[API.SimpleTextWindow("%s", "%s")]], _Caption, _Content)
        );
        return;
    end
    QSB.TextWindow:New(_Caption, _Content):Show();
end

