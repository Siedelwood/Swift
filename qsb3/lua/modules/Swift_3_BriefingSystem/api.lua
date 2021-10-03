--[[
Swift_3_BriefingSystem/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- 
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_DisplayCore.api.html">(1) Display Core</a></li>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- <li><a href="Swift_2_QuestCore.api.html">(2) Quests Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

function API.StartBriefing(_Briefing, _Name, _PlayerID)
    if GUI then
        return -1;
    end
    local PlayerID = _PlayerID;
    if not PlayerID and not Framework.IsNetworkGame() then
        PlayerID = QSB.HumanPlayerID;
    end
    if type(_Briefing) ~= "table" then
        error("_Briefing must be a table!");
        return -1;
    end
    if #_Briefing == 0 then
        error("API.StartBriefing: _Briefing does not contain pages!");
        return -1;
    end
    -- Returning is deactivated by default.
    if _Briefing.DisableReturn == nil then
        _Briefing.DisableReturn = true;
    end
    ModuleBriefingSystem.Global:StartBriefing(_Name, PlayerID, _Briefing);
end

function API.AddBriefingPages(_Briefing)
    _Briefing.GetPage = function(self, _PlayerID, _NameOrID)
        local ID = ModuleBriefingSystem.Global:GetPageIDByName(_PlayerID, _NameOrID);
        return ModuleBriefingSystem.Global.Briefing[_PlayerID][ID];
    end

    local AP = function(_Page)
        _Briefing.Length = (_Briefing.Length or 0) +1;
        if type(_Page) == "table" then
            _Page.__Legit = true;
            _Page.GetSelected = function(self)
                if self.MC then
                    return self.MC.Selected;
                end
                return 0;
            end
            
            -- Language
            _Page.Title = API.ConvertPlaceholders(API.Localize(_Page.Title));
            _Page.Text = API.ConvertPlaceholders(API.Localize(_Page.Text));
            -- Display time
            if not _Page.Duration and not _Page.Animations then
                if _Page.FlyTo then
                    _Page.Duration = _Page.FlyTo.Duration;
                else
                    _Page.NoSkipping = false;
                    _Page.Duration = -1;
                end
            end
            -- Multiple Choice
            if _Page.MC then
                for i= 1, #_Page.MC do
                    _Page.MC[i][1] = API.Localize(_Page.MC[i][1]);
                    _Page.MC[i].ID = _Page.MC[i].ID or i;
                end
                _Page.NoSkipping = true;
                _Page.Duration = -1;
            end
        else
            _Page = (_Page == nil and -1) or _Page;
        end
        table.insert(_Briefing, _Page);
        return _Page;
    end
    return AP;
end

function AP(_Data)
    error("AP (Briefing System): not bound to a dialog!");
end

