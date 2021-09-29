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
        if type(_Page) == "table" then
            if _Page.Position and _Page.Target then
                error(string.format(
                    "AP (Dialog System): (Page %d) Position and Target can not be used both at the same time!",
                    (#_Dialog +1)
                ));
                return;
            end
            
            _Page.GetSelected = function(self)
                if self.MC then
                    return self.MC.Selected;
                end
                return 0;
            end
            
            if _Page.Rotation == nil and _Page.Target ~= nil then
                local ID = GetID(_Page.Target);
                local Orientation = Logic.GetEntityOrientation(ID) +90;
                _Page.Rotation = Orientation;
            end
            if _Page.Zoom == nil then
                _Page.Zoom = 0.15;
            end
            if _Page.MC ~= nil then
                for j= 1, #_Page.MC, 1 do
                    _Page.MC[j].ID = j;
                    _Page.MC[j].Selected = 0;
                    _Page.MC[j].Visible = true;
                end
            end
        else
            _Page = (_Page == nil and -1) or _Page;
        end
        table.insert(_Dialog, _Page);
        return _Page;
    end

    local ASP = function(...)
        local Name;
        if type(arg[4]) ~= "boolean" then
            Name = table.remove(arg, 1);
        end
        local Sender   = table.remove(arg, 1);
        local Position = table.remove(arg, 1);
        local Text     = table.remove(arg, 1);
        local Dialog   = table.remove(arg, 1);
        local Action;
        if type(arg[1]) == "function" then
            Action = table.remove(arg, 1);
        end
        return AP {
            Name   = Name,
            Text   = Text,
            Sender = Sender,
            Target = Position,
            Zoom   = (Dialog and 0.15) or 0.5,
            Action = Action,
        };
    end
    return AP, ASP;
end

function AP(_Data)
    error("AP (Dialog System): not bound to a dialog!");
end

function ASP(_Data)
    error("ASP (Dialog System): not bound to a dialog!");
end

