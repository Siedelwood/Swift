--[[
Swift_2_NpcInteraction/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Dieses Modul erweitert die Interaktionsmöglichkeiten mit Siedlern.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- <li><a href="Swift_1_InterfaceCore.api.html">(1) Interface Core</a></li>
-- <li><a href="Swift_1_ScriptingValueCore.api.html">(1) Scripting Value Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
--
--
-- @usage
-- -- Einen NPC mit Aktion erstellen
-- MyNpc = API.NpcCompose {
--     Name    = "HansWurst",
--     Action  = function(_Data)
--         local HeroID = QSB.LastHeroEntityID;
--         local NpcID = GetID(_Data.Name);
--         -- mach was tolles
--     end
-- }
-- -- Einen NPC mit Aktion und Bedingung erstellen
-- MyNpc = API.NpcCompose {
--     Name      = "HansWurst",
--     Condition = function(_Data)
--         local NpcID = GetID(_Data.Name);
--         -- prüfe irgend was
--         return MyConditon
--     end
--     Action    = function(_Data)
--         local HeroID = QSB.LastHeroEntityID;
--         local NpcID = GetID(_Data.Name);
--         -- mach was tolles
--     end
-- }
--
function API.NpcCompose(_Data)
    if GUI or not type(_Data) == "table" or not _Data.Name then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcCompose: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    if ModuleInteraction.Global:GetNpc(_Data.Name) ~= nil then
        error("API.NpcCompose: '" .._Data.Name.. "' is already composed as NPC!");
        return;
    end
    if _Data.Type and (not type(_Data.Type) == "number" or (_Data.Type < 1 or _Data.Type > 4)) then
        error("API.NpcCompose: Type must be a value between 1 and 4!");
        return;
    end
    return ModuleInteraction.Global:CreateNpc(_Data);
end

---
--
--
-- @usage
-- API.NpcDispose(MyNpc);
--
function API.NpcDispose(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcDispose: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    if ModuleInteraction.Global:GetNpc(_Data.Name) ~= nil then
        error("API.NpcDispose: '" .._Data.Name.. "' NPC must first be composed!");
        return;
    end

    ModuleInteraction.Global:DestroyNpc(_Data);
end

---
--
--
-- @usage
-- -- Einen NPC wieder aktivieren
-- MyNpc.Active = true;
-- MyNpc.TalkedTo = 0;
-- -- Die Aktion ändern
-- MyNpc.Action = function(_Data)
--     -- mach was hier
-- end;
-- API.NpcUpdate(MyNpc);
--
function API.NpcUpdate(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcUpdate: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    if ModuleInteraction.Global:GetNpc(_Data.Name) == nil then
        error("API.NpcUpdate: '" .._Data.Name.. "' NPC must first be composed!");
        return;
    end

    ModuleInteraction.Global:UpdateNpc(_Data);
end

---
--
--
-- @usage
-- if API.NpcIsActive(MyNpc) then
--
function API.NpcIsActive(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcIsActive: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    local NPC = ModuleInteraction.Global:GetNpc(_Data.Name);
    if NPC == nil then
        error("API.NpcIsActive: '" .._Data.Name.. "' NPC must first be composed!");
        return;
    end

    return NPC.Active == true and API.IsEntityActiveNpc(_Data.Name);
end

---
--
--
-- @usage
-- -- prüfe ob mit irgend wem gesprochen wurde
-- if API.NpcTalkedTo(MyNpc) then
-- -- prüfe ob mit Spieler gesprochen wurde
-- if API.NpcTalkedTo(MyNpc, nil, 1) then
-- -- prüfe ob mit Held des Spielers gesprochen wurde
-- if API.NpcTalkedTo(MyNpc, "Marcus", 1) then
--
function API.NpcTalkedTo(_Data, _Hero, _PlayerID)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcIsActive: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    if ModuleInteraction.Global:GetNpc(_Data.Name) ~= nil then
        error("API.NpcIsActive: '" .._Data.Name.. "' NPC must first be composed!");
        return;
    end

    local NPC = ModuleInteraction.Global:GetNpc(_Data.Data);
    local TalkedTo = NPC.TalkedTo ~= nil and NPC.TalkedTo ~= 0;
    if _Hero and TalkedTo then
        TalkedTo = NPC.TalkedTo == GetID(_Hero);
    end
    if _PlayerID and TalkedTo then
        TalkedTo = Logic.EntityGetPlayer(NPC.TalkedTo) == _PlayerID;
    end
    return TalkedTo;
end

