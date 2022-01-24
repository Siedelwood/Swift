--[[
Swift_3_CutsceneSystem/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht es Cutscene zu verwenden.
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
-- @field CutsceneStarted           Eine Cutscene beginnt (Parameter: PlayerID, CutsceneTable)
-- @field CutsceneEnded             Eine Cutscene endet (Parameter: PlayerID, CutsceneTable)
-- @field CutsceneSkipButtonPressed Der Spieler beschleunigt die Wiedergabegeschwindigkeit (Parameter: PlayerID)
-- @field CutsceneFlightStarted     Ein Flight wird gestartet (Parameter: PlayerID, PageIndex, Duration)
-- @field CutsceneFlightEnded       Ein Flight ist beendet (Parameter: PlayerID, PageIndex)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Startet eine Cutscene.
--
-- <h5>Einstellungen</h5>
-- Für eine Cutscene können verschiedene spezielle Einstellungen vorgenommen
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
-- <td>(Optional) Eine Funktion, die beim Start der Cutscene ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>Finished</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die nach Beendigung der Cutscene ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>EnableGlobalImmortality</td>
-- <td>boolean</td>
-- <td>(Optional) Alle Einheiten und Gebäude werden unverwundbar solange die Cutscene aktiv ist.</td>
-- </tr>
-- <tr>
-- <td>EnableSky</td>
-- <td>boolean</td>
-- <td>(Optional) Der Himmel wird während der Cutscene angezeigt.</td>
-- </tr>
-- <tr>
-- <td>DisableFoW</td>
-- <td>boolean</td>
-- <td>(Optional) Der Nebel des Krieges wird für die Dauer der Cutscene ausgeblendet.</td>
-- </tr>
-- <tr>
-- <td>DisableBorderPins</td>
-- <td>boolean</td>
-- <td>(Optional) Die Grenzsteine werden für die Dauer der Cutscene ausgeblendet.</td>
-- </tr>
-- </table>
--
-- @param[type=table]  _Cutscene Definition der Cutscene
-- @param[type=string] _Name     Name der Cutscene
-- @param[type=number] _PlayerID Empfänger der Cutscene
-- @within Anwenderfunktionen
--
-- @usage
-- function Cutscene1(_Name, _PlayerID)
--     local Cutscene = {
--         DisableFoW = true,
--         EnableSky = true,
--         DisableBoderPins = true,
--     };
--     local AP, ASP = API.AddCutscenePages(Cutscene);
--
--     -- Aufrufe von AP oder ASP um Seiten zu erstellen
--
--     Cutscene.Starting = function(_Data)
--         -- Mach was tolles hier wenn es anfängt.
--     end
--     Cutscene.Finished = function(_Data)
--         -- Mach was tolles hier wenn es endet.
--     end
--     API.StartCutscene(Cutscene, _Name, _PlayerID);
-- end
--
function API.StartCutscene(_Cutscene, _Name, _PlayerID)
    if GUI then
        return;
    end
    local PlayerID = _PlayerID;
    if not PlayerID and not Framework.IsNetworkGame() then
        PlayerID = QSB.HumanPlayerID;
    end
    if type(_Cutscene) ~= "table" then
        local Name = "Cutscene #" ..(ModuleCutsceneSystem.Global.CutsceneCounter +1);
        error("API.StartCutscene (" ..Name.. "): _Cutscene must be a table!");
        return;
    end
    if #_Cutscene == 0 then
        local Name = "Cutscene #" ..(ModuleCutsceneSystem.Global.CutsceneCounter +1);
        error("API.StartCutscene (" ..Name.. "): _Cutscene does not contain pages!");
        return;
    end
    for i=1, #_Cutscene do
        if not _Cutscene[i].__Legit then
            local Name = "Cutscene #" ..(ModuleCutsceneSystem.Global.CutsceneCounter +1);
            error("API.StartCutscene (" ..Name.. ", Page #" ..i.. "): Page is not initialized!");
            return;
        end
    end
    ModuleCutsceneSystem.Global:StartCutscene(_Name, PlayerID, _Cutscene);
end

---
-- Erzeugt die Funktion zur Erstellung von Flights in einer Cutscene. Diese
-- Funktion muss vor dem Start einer Cutscene aufgerufen werden, damit Seiten
-- gebunden werden können.
--
-- @param[type=table] _Cutscene Cutscene Definition
-- @return[type=function] <a href="#AF">AF</a>
-- @within Anwenderfunktionen
--
-- @usage
-- local AF = API.AddCutscenePages(Cutscene);
--
function API.AddCutscenePages(_Cutscene)
    _Cutscene.GetPage = function(self, _PlayerID, _NameOrID)
        local ID = ModuleCutsceneSystem.Global:GetPageIDByName(_PlayerID, _NameOrID);
        return ModuleCutsceneSystem.Global.Cutscene[_PlayerID][ID];
    end

    local AF = function(_Page)
        if type(_Page) == "table" then
            _Page.__Legit = true;
            
            -- Language
            _Page.Title = API.Localize(_Page.Title);
            if _Page.Text then
                _Page.Text = API.Localize(_Page.Text);
            end
            -- Fixme: not implemented?
            if _Page.Lines then
                _Page.Lines = API.Localize(_Page.Lines);
            end
            if not _Page.Lines and not _Page.Text then
                local Name = "Cutscene #" ..(ModuleCutsceneSystem.Global.CutsceneCounter +1);
                error("AF (" ..Name.. ", Page #" ..(#_Cutscene+1).. "): Missing Lines or Text attribute!");
                return;
            end

            -- Bars
            if _Page.BigBars == nil then
                _Page.BigBars = false;
            end
        end
        table.insert(_Cutscene, _Page);
        return _Page;
    end
    return AF;
end

---
-- Erzeugt einen neuen Flight für die Cutscene.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddCutscenePages">API.AddCutscenePages</a> erzeugt und an
-- die Cutscene gebunden.
--
-- Folgende Parameter werden als Felder (Name = Wert) übergeben:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Flight</td>
-- <td>string</td>
-- <td>Name der CS-Datei ohne Dateiendung</td>
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
-- <td>Action</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die ausgeführt wird, sobald der Flight
-- angezeigt wird.</td>
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
-- </table>
--
-- @within Cutscene
--
function AF(_Data)
    assert(false);
end

