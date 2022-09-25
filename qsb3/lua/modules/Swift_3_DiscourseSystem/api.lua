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
            _Page.Text = API.Localize(_Page.Text or "");

            -- Skip page
            if _Page.Duration and _Page.Duration > 0 then
                if _Page.AutoSkipPage == nil then
                    _Page.AutoSkipPage = false;
                end
            else
                _Page.Duration = string.len(_Page.Text or "") * QSB.Discourse.TIMER_PER_CHAR;
                if _Page.Duration < 6 then
                    _Page.Duration = 6;
                end
                _Page.AutoSkipPage = true;
            end

            -- Multiple Choice
            if _Page.MC then
                for i= 1, #_Page.MC do
                    _Page.MC[i][1] = API.Localize(_Page.MC[i][1]);
                    _Page.MC[i].ID = _Page.MC[i].ID or i;
                end
                _Page.AutoSkipPage = false;
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
-- 
--
function AP(_Data)
    assert(false);
end

---
-- 
--
function ASP(...)
    assert(false);
end

