--[[
Swift_3_DialogSystem/API

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
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- <li><a href="Swift_2_QuestCore.api.html">(2) Quests Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

function API.StartDialog(_Dialog, _Name, _PlayerID)
    local PlayerID = _PlayerID;
    if not PlayerID and not Framework.IsNetworkGame() then
        PlayerID = QSB.HumanPlayerID;
    end
    ModuleDialogSystem.Global:StartDialog(_Name, PlayerID, _Dialog);
end

function API.AddDialogPages(_Dialog)
    local AP = function(_Page)
        if _Page.Rotation == nil and _Page.Target ~= nil then
            local ID = GetID(_Page.Target);
            local Orientation = Logic.GetEntityOrientation(ID) +90;
            _Page.Rotation = Orientation;
        end
        if _Page.Zoom == nil then
            _Page.Zoom = 0.15;
        end
        table.insert(_Dialog, _Page);
        return _Page;
    end
    return AP;
end

function AP(_Data)
    error("AP is not bound to dialog!");
end

