--[[
Swift_2_InteractionCore/Behavior

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]


---
-- Stellt neue Behavior für NPO und NPC bereit.
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Der Spieler muss bis zu 4 interaktive Objekte benutzen.
--
-- @param[type=string] _Object1 Erstes Objekt
-- @param[type=string] _Object2 (optional) Zweites Objekt
-- @param[type=string] _Object3 (optional) Drittes Objekt
-- @param[type=string] _Object4 (optional) Viertes Objekt
--
-- @within Goal
--
function Goal_ActivateSeveralObjects(...)
    return b_Goal_ActivateSeveralObjects:new(...);
end

b_Goal_ActivateSeveralObjects = {
    Name = "Goal_ActivateSeveralObjects",
    Description = {
        en = "Goal: Activate an interactive object",
        de = "Ziel: Aktiviere ein interaktives Objekt",
    },
    Parameter = {
        { ParameterType.Default, en = "Object name 1", de = "Skriptname 1" },
        { ParameterType.Default, en = "Object name 2", de = "Skriptname 2" },
        { ParameterType.Default, en = "Object name 3", de = "Skriptname 3" },
        { ParameterType.Default, en = "Object name 4", de = "Skriptname 4" },
    },
    ScriptNames = {};
}

function b_Goal_ActivateSeveralObjects:GetGoalTable()
    return {Objective.Object, { unpack(self.ScriptNames) } }
end

function b_Goal_ActivateSeveralObjects:AddParameter(_Index, _Parameter)
    if _Index == 0 then
        assert(_Parameter ~= nil and _Parameter ~= "", "Goal_ActivateSeveralObjects: At least one IO needed!");
    end
    if _Parameter ~= nil and _Parameter ~= "" then
        table.insert(self.ScriptNames, _Parameter);
    end
end

function b_Goal_ActivateSeveralObjects:GetMsgKey()
    return "Quest_Object_Activate"
end

Swift:RegisterBehavior(b_Goal_ActivateSeveralObjects);

-- -------------------------------------------------------------------------- --

---
-- Der Held muss einen Nichtspielercharakter ansprechen.
--
-- Es wird automatisch ein NPC erzeugt und überwacht, sobald der Quest
-- aktiviert wurde. Ein NPC darf nicht auf geblocktem Gebiet stehen oder
-- seine Enity-ID verändern.
--
-- <b>Hinweis</b>: Jeder Siedler kann zu jedem Zeitpunkt nur <u>einen</u> NPC 
-- haben. Wird ein weiterer NPC zugewiesen, wird der alte überschrieben und
-- der verknüpfte Quest funktioniert nicht mehr!
--
-- @param[type=string] _NpcName  Skriptname des NPC
-- @param[type=string] _HeroName (optional) Skriptname des Helden
-- @within Goal
--
function Goal_NPC(...)
    return b_Goal_NPC:new(...);
end

b_Goal_NPC = {
    Name             = "Goal_NPC",
    Description     = {
        en = "Goal: The hero has to talk to a non-player character.",
        de = "Ziel: Der Held muss einen Nichtspielercharakter ansprechen.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "NPC",  de = "NPC" },
        { ParameterType.ScriptName, en = "Hero", de = "Held" },
    },
}

function b_Goal_NPC:GetGoalTable()
    return {Objective.Distance, -65565, self.Hero, self.NPC, self}
end

function b_Goal_NPC:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.NPC = _Parameter
    elseif (_Index == 1) then
        self.Hero = _Parameter
        if self.Hero == "-" then
            self.Hero = nil
        end
   end
end

function b_Goal_NPC:GetIcon()
    return {14,10}
end

Swift:RegisterBehavior(b_Goal_NPC);

-- -------------------------------------------------------------------------- --

---
-- Ändert den angezeigten Titel eines interaktiven Objektes.
--
-- @param _ScriptName Skriptname des interaktiven Objektes
-- @param _Headline   Text
--
-- @within Reprisal
--
function Reprisal_InteractiveObjectSetHeadline(...)
    return b_Reprisal_InteractiveObjectSetHeadline:new(...);
end

b_Reprisal_InteractiveObjectSetHeadline = {
    Name = "Reprisal_InteractiveObjectSetHeadline",
    Description = {
        en = "Reward: Changes the name of the interactive object in the tooltip.",
        de = "Lohn: Ändert den angezeigten Titel eines interaktiven Objektes.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Interactive object", de = "Interaktives Objekt" },
        { ParameterType.Custom,     en = "Text",   de = "Text" },
    },
}

function b_Reprisal_InteractiveObjectSetHeadline:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_InteractiveObjectSetHeadline:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptName = _Parameter
    elseif (_Index == 1) then
        self.Lambda = _Parameter
    end
end

function b_Reprisal_InteractiveObjectSetHeadline:CustomFunction(_Quest)
    API.SetObjectHeadline(self.ScriptName, _G[self.Lambda] or self.Lambda);
end

function b_Reprisal_InteractiveObjectSetHeadline:Debug(_Quest)
    if not IsExisting(self.ScriptName) == false then
        error(_Quest.Identifier.. ": " ..self.Name..": '"..self.ScriptName.."' does not exist!");
        return true;
    end
    if self.Lambda == nil or self.Lambda == "" then
        error(_Quest.Identifier.. ": " ..self.Name..": Text is empty!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(b_Reprisal_InteractiveObjectSetHeadline);

-- -------------------------------------------------------------------------- --

---
-- Ändert den angezeigten Beschreibungstext eines interaktiven Objektes.
--
-- @param _ScriptName  Skriptname des interaktiven Objektes
-- @param _Description Text
--
-- @within Reprisal
--
function Reprisal_InteractiveObjectSetDescription(...)
    return b_Reprisal_InteractiveObjectSetDescription:new(...);
end

b_Reprisal_InteractiveObjectSetDescription = {
    Name = "Reprisal_InteractiveObjectSetDescription",
    Description = {
        en = "Reward: Changes the description text of the interactive object.",
        de = "Lohn: Ändert den angezeigten Beschreibungstext eines interaktiven Objektes.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Interactive object", de = "Interaktives Objekt" },
        { ParameterType.Custom,     en = "Text",   de = "Text" },
    },
}

function b_Reprisal_InteractiveObjectSetDescription:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_InteractiveObjectSetDescription:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptName = _Parameter
    elseif (_Index == 1) then
        self.Lambda = _Parameter
    end
end

function b_Reprisal_InteractiveObjectSetDescription:CustomFunction(_Quest)
    API.SetObjectDescription(self.ScriptName, _G[self.Lambda] or self.Lambda);
end

function b_Reprisal_InteractiveObjectSetDescription:Debug(_Quest)
    if not IsExisting(self.ScriptName) == false then
        error(_Quest.Identifier.. ": " ..self.Name..": '"..self.ScriptName.."' does not exist!");
        return true;
    end
    if self.Lambda == nil or self.Lambda == "" then
        error(_Quest.Identifier.. ": " ..self.Name..": Text is empty!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(b_Reprisal_InteractiveObjectSetDescription);

-- -------------------------------------------------------------------------- --

---
-- Ändert den Informationstext wenn ein Objekt nicht verfügbar ist.
--
-- @param _ScriptName   Skriptname des interaktiven Objektes
-- @param _DisabledText Text
--
-- @within Reprisal
--
function Reprisal_InteractiveObjectSetDisabledText(...)
    return b_Reprisal_InteractiveObjectSetDisabledText:new(...);
end

b_Reprisal_InteractiveObjectSetDisabledText = {
    Name = "Reprisal_InteractiveObjectSetDisabledText",
    DisabledText = {
        en = "Reward: Changes the disabled text of an interactive object.",
        de = "Lohn: Ändert den Informationstext wenn ein Objekt nicht verfügbar ist.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Interactive object", de = "Interaktives Objekt" },
        { ParameterType.Custom,     en = "Text",   de = "Text" },
    },
}

function b_Reprisal_InteractiveObjectSetDisabledText:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_InteractiveObjectSetDisabledText:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptName = _Parameter
    elseif (_Index == 1) then
        self.Lambda = _Parameter
    end
end

function b_Reprisal_InteractiveObjectSetDisabledText:CustomFunction(_Quest)
    API.SetObjectDisabledText(self.ScriptName, _G[self.Lambda] or self.Lambda);
end

function b_Reprisal_InteractiveObjectSetDisabledText:Debug(_Quest)
    if not IsExisting(self.ScriptName) == false then
        error(_Quest.Identifier.. ": " ..self.Name..": '"..self.ScriptName.."' does not exist!");
        return true;
    end
    if self.Lambda == nil or self.Lambda == "" then
        error(_Quest.Identifier.. ": " ..self.Name..": Text is empty!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(b_Reprisal_InteractiveObjectSetDisabledText);

-- -------------------------------------------------------------------------- --

---
-- Ändert den Informationstext wenn ein Objekt nicht verfügbar ist.
--
-- @param _ScriptName   Skriptname des interaktiven Objektes
-- @param _X            X in Icon-Matrix
-- @param _Y            Y in Icon-Matrix
-- @param _Z            Spiel (0 = AeK, 1 = RdO)
--
-- @within Reprisal
--
function Reprisal_InteractiveObjectSetIconTexture(...)
    return b_Reprisal_InteractiveObjectSetIconTexture:new(...);
end

b_Reprisal_InteractiveObjectSetIconTexture = {
    Name = "Reprisal_InteractiveObjectSetIconTexture",
    DisabledText = {
        en = "Reward: Changes the disabled text of an interactive object.",
        de = "Lohn: Ändert den Informationstext wenn ein Objekt nicht verfügbar ist.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Interactive object",      de = "Interaktives Objekt" },
        { ParameterType.Number,     en = "X in icon matrix",        de = "X in Icon-Matrix" },
        { ParameterType.Number,     en = "Y in icon matrix",        de = "Y in Icon-Matrix" },
        { ParameterType.Number,     en = "Game (0 = RoaE, 1 = ER)", de = "Spiel (0 = AeK, 1 = RdO)" },
    },
}

function b_Reprisal_InteractiveObjectSetIconTexture:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_InteractiveObjectSetIconTexture:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptName = _Parameter
    elseif (_Index == 1) then
        self.X = _Parameter * 1
    elseif (_Index == 2) then
        self.Y = _Parameter * 1
    elseif (_Index == 3) then
        self.Z = _Parameter * 1
    end
end

function b_Reprisal_InteractiveObjectSetIconTexture:CustomFunction(_Quest)
    API.SetObjectIcon(self.ScriptName, {self.X, self.Y, self.Z});
end

function b_Reprisal_InteractiveObjectSetIconTexture:Debug(_Quest)
    if not IsExisting(self.ScriptName) == false then
        error(_Quest.Identifier.. ": " ..self.Name..": '"..self.ScriptName.."' does not exist!");
        return true;
    end
    if self.Z ~= 0 or self.Z ~= 1 then
        error(_Quest.Identifier.. ": " ..self.Name..": Z must be 0 or 1!");
        return true;
    end
    if self.X <= 0 or self.X > (self.Z == 0 and 16) or 8 then
        error(_Quest.Identifier.. ": " ..self.Name..": X is not in range!");
        return true;
    end
    if self.Y <= 0 or self.Y > (self.Z == 0 and 16) or 8 then
        error(_Quest.Identifier.. ": " ..self.Name..": Y is not in range!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(b_Reprisal_InteractiveObjectSetIconTexture);

-- -------------------------------------------------------------------------- --

---
-- Ändert den angezeigten Titel eines interaktiven Objektes.
--
-- @param _ScriptName Skriptname des interaktiven Objektes
-- @param _Headline   Text oder Funktion im Skript
--
-- @within Reward
--
function Reward_InteractiveObjectSetHeadline(...)
    return b_Reward_InteractiveObjectSetHeadline:new(...);
end

b_Reward_InteractiveObjectSetHeadline = Swift:CopyTable(b_Reprisal_InteractiveObjectSetHeadline);
b_Reward_InteractiveObjectSetHeadline.Name             = "Reward_InteractiveObjectSetHeadline";
b_Reward_InteractiveObjectSetHeadline.GetReprisalTable = nil;

b_Reward_InteractiveObjectSetHeadline.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Swift:RegisterBehavior(b_Reward_InteractiveObjectSetHeadline);

-- -------------------------------------------------------------------------- --

---
-- Ändert den angezeigten Beschreibungstext eines interaktiven Objektes.
--
-- @param _ScriptName  Skriptname des interaktiven Objektes
-- @param _Description Text oder Funktion im Skript
--
-- @within Reward
--
function Reward_InteractiveObjectSetDescription(...)
    return b_Reward_InteractiveObjectSetDescription:new(...);
end

b_Reward_InteractiveObjectSetDescription = Swift:CopyTable(b_Reprisal_InteractiveObjectSetDescription);
b_Reward_InteractiveObjectSetDescription.Name             = "Reward_InteractiveObjectSetDescription";
b_Reward_InteractiveObjectSetDescription.GetReprisalTable = nil;

b_Reward_InteractiveObjectSetDescription.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Swift:RegisterBehavior(b_Reward_InteractiveObjectSetDescription);

-- -------------------------------------------------------------------------- --

---
-- Ändert den Informationstext wenn ein Objekt nicht verfügbar ist.
--
-- @param _ScriptName   Skriptname des interaktiven Objektes
-- @param _DisabledText Text oder Funktion im Skript
--
-- @within Reward
--
function Reward_InteractiveObjectSetDisabledText(...)
    return b_Reward_InteractiveObjectSetDisabledText:new(...);
end

b_Reward_InteractiveObjectSetDisabledText = Swift:CopyTable(b_Reprisal_InteractiveObjectSetDisabledText);
b_Reward_InteractiveObjectSetDisabledText.Name             = "Reward_InteractiveObjectSetDisabledText";
b_Reward_InteractiveObjectSetDisabledText.GetReprisalTable = nil;

b_Reward_InteractiveObjectSetDisabledText.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Swift:RegisterBehavior(b_Reward_InteractiveObjectSetDisabledText);

-- -------------------------------------------------------------------------- --

---
-- Ändert den Informationstext wenn ein Objekt nicht verfügbar ist.
--
-- @param _ScriptName   Skriptname des interaktiven Objektes
-- @param _X            X in Icon-Matrix
-- @param _Y            Y in Icon-Matrix
-- @param _Z            Spiel (0 = AeK, 1 = RdO)
--
-- @within Reward
--
function Reward_InteractiveObjectSetIconTexture(...)
    return b_Reward_InteractiveObjectSetIconTexture:new(...);
end

b_Reward_InteractiveObjectSetIconTexture = Swift:CopyTable(b_Reprisal_InteractiveObjectSetIconTexture);
b_Reward_InteractiveObjectSetIconTexture.Name             = "Reward_InteractiveObjectSetIconTexture";
b_Reward_InteractiveObjectSetIconTexture.GetReprisalTable = nil;

b_Reward_InteractiveObjectSetIconTexture.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Swift:RegisterBehavior(b_Reward_InteractiveObjectSetIconTexture);

-- -------------------------------------------------------------------------- --

-- API.CreateObject muss zur Initialisierung verwendet werden
b_Reward_ObjectInit.CustomFunction = function(_Behavior, _Quest)
    local eID = GetID(_Behavior.ScriptName);
    if eID == 0 then
        return;
    end
    QSB.InitalizedObjekts[eID] = _Quest.Identifier;
    
    local RewardTable = nil;
    if _Behavior.RewardType and _Behavior.RewardType ~= "-" then
        RewardTable = {Goods[_Behavior.RewardType], _Behavior.RewardAmount};
    end

    local CostsTable = nil;
    if _Behavior.FirstCostType and _Behavior.FirstCostType ~= "-" then
        CostsTable = {Goods[_Behavior.FirstCostType], _Behavior.FirstCostAmount};
        if _Behavior.SecondCostType and _Behavior.SecondCostType ~= "-" then
            table.insert(CostsTable, Goods[_Behavior.SecondCostType]);
            table.insert(CostsTable, _Behavior.SecondCostAmount);
        end
    end

    API.CreateObject{
        Name        = _Behavior.ScriptName,
        State       = _Behavior.UsingState or 0,
        Distance    = _Behavior.Distance,
        Waittime    = _Behavior.Waittime,
        Reward      = RewardTable,
        Costs       = CostsTable,
    };
end

