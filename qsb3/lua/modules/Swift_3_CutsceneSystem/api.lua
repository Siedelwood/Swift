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
--
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
-- @param[type=table] _Briefing Briefing Definition
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
            _Page.Title = API.ConvertPlaceholders(API.Localize(_Page.Title));
            if _Page.Text then
                _Page.Text = API.ConvertPlaceholders(API.Localize(_Page.Text));
            end
            if _Page.Lines then
                _Page.Lines = API.ConvertPlaceholders(API.Localize(_Page.Lines));
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
--
-- @within Cutscene
--
function AF(_Data)
    error("AF (Cutscene System): not bound to a cutscene!");
end

