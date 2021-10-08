--[[
Swift_2_NpcInteraction/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleNpcInteraction = {
    Properties = {
        Name = "ModuleNpcInteraction",
    },

    Global = {
        NPC = {},
    };
    Local  = {};
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
};

QSB.LastNpcEntityID = 0;
QSB.LastHeroEntityID = 0;

-- Global Script ------------------------------------------------------------ --

function ModuleNpcInteraction.Global:OnGameStart()
    QSB.ScriptEvents.NpcInteraction = API.RegisterScriptEvent("Event_NpcInteraction");

    self:OverrideQuestFunctions();

    API.StartJobByEventType(Events.LOGIC_EVENT_EVERY_TURN, function()
        if Logic.GetTime() > 1 then
            ModuleNpcInteraction.Global:DialogTriggerController();
        end
    end);
end

function ModuleNpcInteraction.Global:OnEvent(_ID, _Event, _EntityID, _KnightID, _PlayerID)
    if _ID == QSB.ScriptEvents.NpcInteraction then
        QSB.LastNpcEntityID = _EntityID;
        QSB.LastHeroEntityID = _KnightID;
        self:PerformNpcInteraction(_PlayerID);
    end
end

function ModuleInteraction.Global:CreateNpc(_Data)
    self.NPC[_Data.Name] = {
        Name      = _Data.Name,
        Active    = true,
        Type      = _Data.Type or 1,
        PlayerID  = _Data.PlayerID or 1,
        Hero      = _Data.Hero,
        Distance  = _Data.Distance or 350,
        Condition = _Data.Condition,
        Action    = _Data.Action
    }
    self:UpdateNpc(_Data.Name);
    return self.NPC[_Data.Name];
end

function ModuleInteraction.Global:DestroyNpc(_ScriptName)
    self:UpdateNpc(_ScriptName, {Active = false});
    self.NPC[_ScriptName] = nil;
end

function ModuleInteraction.Global:GetNpc(_ScriptName)
    return self.NPC[_ScriptName];
end

function ModuleInteraction.Global:UpdateNpc(_ScriptName, _Data)
    if not IsExisting(_Data.Name) then
        return;
    end
    if not self.NPC[_Data.Name] then
        local EntityID = GetID(_Data.Name);
        Logic.SetOnScreenInformation(EntityID, 0);
        return;
    end
    for k, v in pairs(_Data) do
        self.NPC[_Data.Name][k] = v;
    end
    if self.NPC[_Data.Name].Active then
        local EntityID = GetID(_Data.Name);
        Logic.SetOnScreenInformation(EntityID, self.NPC[_Data.Name].Type);
    else
        local EntityID = GetID(_Data.Name);
        Logic.SetOnScreenInformation(EntityID, 0);
    end
end

function ModuleInteraction.Global:PerformNpcInteraction(_PlayerID)
    local ScriptName = Logic.GetEntityName(QSB.LastNpcEntityID);
    if self.NPC[ScriptName] then
        self:RotateActorsToEachother(_PlayerID);
        self:AdjustHeroTalkingDistance(_PlayerID, self.NPC[ScriptName].Distance);
        
        if self.NPC[ScriptName].PlayerID == nil 
        or self.NPC[ScriptName].PlayerID == _PlayerID then
            self.NPC[ScriptName].TalkedTo = QSB.LastHeroEntityID;
        end

        if self.NPC[ScriptName].TalkedTo ~= nil and self.NPC[ScriptName].TalkedTo ~= 0 then
            if self.NPC[ScriptName].Condition == nil
            or self.NPC[ScriptName]:Condition() then
                self.NPC[ScriptName].Active = true;
                if self.NPC[ScriptName].Action then
                    self.NPC[ScriptName]:Action();
                end
            else
                self.NPC[ScriptName].TalkedTo = 0;
            end
        end
        self:UpdateNpc(self.NPC[ScriptName]);
    end
end

function ModuleNpcInteraction.Global:RotateActorsToEachother(_PlayerID)
    local PlayerKnights = {};
    Logic.GetKnights(_PlayerID, PlayerKnights);
    for k, v in pairs(PlayerKnights) do
        local Target = API.GetEntityMovementTarget(v);
        local x, y = Logic.EntityGetPos(QSB.LastNpcEntityID);
        if math.floor(Target.X) == math.floor(x) and math.floor(Target.Y) == math.floor(y) then
            local x, y, z = Logic.EntityGetPos(v);
            Logic.MoveEntity(v, x, y);
            LookAt(v, QSB.LastNpcEntityID);
        end
    end
    API.Confront(QSB.LastHeroEntityID, QSB.LastNpcEntityID);
end

function ModuleNpcInteraction.Global:AdjustHeroTalkingDistance(_PlayerID, _Distance)
    if IsNear(QSB.LastHeroEntityID, QSB.LastNpcEntityID, _Distance) then
        local Orientation = Logic.GetEntityOrientation(QSB.LastHeroEntityID);
        local x1, y1, z1 = Logic.EntityGetPos(QSB.LastHeroEntityID);
        local x2 = x1 + (_Distance * math.cos(math.rad(Orientation)));
        local y2 = y1 + (_Distance * math.sin(math.rad(Orientation)));
        local ID = Logic.CreateEntityOnUnblockedLand(Entities.XD_ScriptEntity, x2, y2, 0, 0);
        local x3, y3, z3 = Logic.EntityGetPos(ID);
        Logic.MoveSettler(QSB.LastHeroEntityID, x3, y3);

        API.StartHiResJob( function(_HeroID, _NPCID)
            if Logic.IsEntityMoving(_HeroID) == false then
                API.Confront(_HeroID, _NPCID);
                return true;
            end
        end, QSB.LastHeroEntityID, QSB.LastHeroEntityID);
    end
end

function ModuleNpcInteraction.Global:OverrideQuestFunctions()
    GameCallback_OnNPCInteraction_Orig_QSB_ModuleNpcInteraction = GameCallback_OnNPCInteraction;
    GameCallback_OnNPCInteraction = function(_EntityID, _PlayerID, _KnightID)
        GameCallback_OnNPCInteraction_Orig_QSB_ModuleNpcInteraction(_EntityID, _PlayerID, _KnightID);

        local ClosestKnightID = _KnightID or ModuleNpcInteraction.Global:GetClosestKnight(_EntityID, _PlayerID);
        API.SendScriptEvent(QSB.ScriptEvents.NpcInteraction, _EntityID, ClosestKnightID, _PlayerID);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.NpcInteraction, %d, %d, %d)]],
            _EntityID,
            ClosestKnightID,
            _PlayerID
        ));
    end
end

function ModuleNpcInteraction.Global:GetClosestKnight(_EntityID, _PlayerID)
    local KnightIDs = {};
    Logic.GetKnights(_PlayerID, KnightIDs);

    local ClosestKnightID = 0;
    local ClosestKnightDistance = Logic.WorldGetSize();
    for i= 1, #KnightIDs, 1 do
        local DistanceBetween = Logic.GetDistanceBetweenEntities(KnightIDs[i], _EntityID);
        if DistanceBetween < ClosestKnightDistance then
            ClosestKnightDistance = DistanceBetween;
            ClosestKnightID = KnightIDs[i];
        end
    end
    return ClosestKnightID;
end

function ModuleNpcInteraction.Global:DialogTriggerController()
    for PlayerID = 1, 8, 1 do
        local PlayersKnights = {};
        Logic.GetKnights(PlayerID, PlayersKnights);
        for i= 1, #PlayersKnights, 1 do
            if Logic.GetCurrentTaskList(PlayersKnights[i]) == "TL_NPC_INTERACTION" then
                for k, v in pairs(self.NPC) do
                    if v.Distance >= 350 then
                        local Target = API.GetEntityMovementTarget(PlayersKnights[i]);
                        local x, y = Logic.EntityGetPos(GetID(k));
                        if math.floor(Target.X) == math.floor(x) and math.floor(Target.Y) == math.floor(y) then
                            if IsExisting(k) and IsNear(PlayersKnights[i], k, v.Distance) then
                                GameCallback_OnNPCInteraction(GetID(k), PlayerID, PlayersKnights[i]);
                                return;
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Local Script ------------------------------------------------------------- --

function ModuleNpcInteraction.Local:OnGameStart()
    QSB.ScriptEvents.NpcInteraction = API.RegisterScriptEvent("Event_NpcInteraction");
end

function ModuleNpcInteraction.Local:OnEvent(_ID, _Event, _EntityID, _KnightID, _PlayerID)
    if _ID == QSB.ScriptEvents.NpcInteraction then
        QSB.LastNpcEntityID = _EntityID;
        QSB.LastHeroEntityID = _KnightID;
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleNpcInteraction);

