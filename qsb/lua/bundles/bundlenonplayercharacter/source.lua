-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleNonPlayerCharacter                                     # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Implementiert ansprechbare Spielfiguren. Ein NPC wird angesprochen, indem
-- man mit einem selektierten Held über ihn zeigt. Der Mauszeiger wird zu einer
-- Hand. Klickt man dann links, wird sich der Held zum NPC bewegen. Sobald er
-- ihn errecht, wird eine Aktion ausgeführt.
--
-- Folgt ein NPC einem Helden, wird er stehen bleiben, wenn der Held zu weit
-- entfernt ist. Wenn ein Ziel angegeben ist, dann wird das Callback erst
-- ausgelöst, wenn man den NPC in der Nähe des Ziels anspricht. Ist kein
-- Ziel angegeben, wird das Callback niemals ausgelöst.
-- Optional kann eine Action angegeben werden, die anstelle des Callback
-- ausgeführt wird, wenn das Ziel nicht erreicht ist.
--
-- Führt ein NPC einen Helden, wird er stehen bleiben, wenn der Held zu weit
-- entfernt ist. Andernfalls bewegt sich der NPC zum Zielpunkt. Das Callback
-- wird nur ausgelöst, wenn sich der NPC in der Nähe des Ziels befindet. Es
-- kann eine Action angegeben werden, die anstelle des Callback ausgeführt
-- wird, wenn das Ziel nicht erreicht ist.
--
-- @module BundleNonPlayerCharacter
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

BundleNonPlayerCharacter = {
    Global = {
        NonPlayerCharacter = {
            Data = {},
        },
        NonPlayerCharacterObjects = {},
        LastNpcEntityID = 0,
        LastHeroEntityID = 0,
    },
    Local = {}
};

---
-- Erzeugt eine neue Instanz von NonPlayerCharacter für das Entity
-- mit dem angegebenen Skriptnamen.
--
-- <b>Alias:</b> NonPlayerCharacter:New
--
-- @param _ScriptName Skriptname des NPC
-- @return object
-- @within NonPlayerCharacter
--
-- @usage -- Einfachen NPC erzeugen:
-- local NPC = NonPlayerCharacter:New("npc")
--              :SetDialogPartner("hero")               -- Optional
--              :SetCallback(Briefing1)                 -- Optional
--              :Activate();
--
-- -- Folgenden NPC erzeugen:
-- local NPC = NonPlayerCharacter:New("npc")
--              :SetDialogPartner("hero")               -- Optional
--              :SetFollowTarget("hero")
--              :SetFollowDestination("destination")    -- Optional
--              :SetFollowAction(NotArrivedFunction)    -- Optional
--              :SetCallback(Briefing1)                 -- Optional
--              :Activate();
--
-- -- Führenden NPC erzeugen:
-- local NPC = NonPlayerCharacter:New("npc")
--              :SetDialogPartner("hero")               -- Optional
--              :SetGuideParams("destination", "hero")
--              :SetGuideAction(NotArrivedFunction)     -- Optional
--              :SetCallback(Briefing1)                 -- Optional
--              :Activate();
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:New(_ScriptName)
    assert( self == BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used from instance!');
    assert(IsExisting(_ScriptName), 'entity "' .._ScriptName.. '" does not exist!');
    
    local npc = CopyTableRecursive(self);
    npc.Data.NpcName = _ScriptName;
    BundleNonPlayerCharacter.Global.NonPlayerCharacterObjects[_ScriptName] = npc;
    return npc;
end

---
-- Gibt die Inztanz des NPC mit dem angegebenen Skriptnamen zurück.
-- Handelt es sich um einen Soldaten, wird versucht die Instanz
-- über den Leader zu ermitteln.
--
-- <b>Alias:</b> NonPlayerCharacter:GetInstance
--
-- @param _ScriptName Skriptname des NPC
-- @return object
-- @within NonPlayerCharacter
-- @usage -- NPC ermitteln
-- local NPC = NonPlayerCharacter:GetInstance("horst");
-- -- Etwas mit dem NPC tun
-- NPC:SetDialogPartner("hilda");
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:GetInstance(_ScriptName)
    assert( self == BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used from instance!');
    local EntityID = GetID(_ScriptName)
    local ScriptName = Logic.GetEntityName(EntityID);
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Soldier) == 1 then
        local LeaderID = Logic.SoldierGetLeaderEntityID(EntityID);
        if IsExisting(LeaderID) then
            ScriptName = Logic.GetEntityName(LeaderID);
        end
    end
    return BundleNonPlayerCharacter.Global.NonPlayerCharacterObjects[ScriptName];
end

---
-- Gibt die Entity ID des letzten angesprochenen NPC zurück.
--
-- <b>Alias:</b> NonPlayerCharacter:GetNpcId
--
-- @return number
-- @within NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:GetNpcId()
    assert( self == BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used from instance!');
    return BundleNonPlayerCharacter.Global.LastNpcEntityID;
end

---
-- Gibt die Entity ID des letzten Helden zurück, der einen NPC
-- angesprochen hat.
--
-- <b>Alias:</b> NonPlayerCharacter:GetHeroId
--
-- @return number
-- @within NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:GetHeroId()
    assert( self == BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used from instance!');
    return BundleNonPlayerCharacter.Global.LastHeroEntityID;
end

---
-- Gibt die Entity ID des NPC zurück. Ist der NPC ein Leader, wird
-- der erste Soldat zurückgegeben, wenn es einen gibt.
--
-- <b>Alias:</b> NonPlayerCharacter:GetID
--
-- @return number
-- @within NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:GetID()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    local EntityID = GetID(self.Data.NpcName);
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Leader) == 1 then
        local Soldiers = {Logic.GetSoldiersAttachedToLeader(EntityID)};
        if Soldiers[1] > 0 then
            return Soldiers[2];
        end
    end
    return EntityID
end

---
-- Löscht einen NPC.
--
-- <b>Alias:</b> NonPlayerCharacter:Dispose
--
-- @within NonPlayerCharacter
--
-- @usage -- NPC löschen
-- NPC:Dispose();
-- 
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:Dispose()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    self:Deactivate();
    BundleNonPlayerCharacter.Global.NonPlayerCharacterObjects[self.Data.NpcName] = nil;
end

---
-- Aktiviert einen inaktiven NPC, sodass er wieder angesprochen werden kann.
-- 
-- <p><b>Alias:</b> NonPlayerCharacter:Activate</p>
--
-- @return Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
-- @usage -- NPC aktivieren:
-- NPC:Activate();
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:Activate()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.Data.NpcName) then
        Logic.SetOnScreenInformation(self:GetID(), 1);
    end
    return self;
end

---
-- Deaktiviert einen aktiven NPC, sodass er nicht angesprochen werden kann.
-- 
-- <p><b>Alias:</b> NonPlayerCharacter:Deactivate</p>
--
-- @return Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
-- @usage -- NPC deaktivieren:
-- NPC:Deactivate();
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:Deactivate()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.Data.NpcName) then
        Logic.SetOnScreenInformation(self:GetID(), 0);
    end
    return self;
end

---
-- <p>Gibt true zurück, wenn der NPC aktiv ist.</p>
--
-- <p><b>Alias:</b> NonPlayerCharacter:IsActive</p>
--
-- @return boolean
-- @within NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:IsActive()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    return Logic.GetEntityScriptingValue(self:GetID(), 6) == 1;
end

---
-- Setzt den NPC zurück, sodass er erneut aktiviert werden kann.
--
-- <b>Alias:</b> NonPlayerCharacter:Reset
--
-- @return Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:Reset()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.Data.NpcName) then
        Logic.SetOnScreenInformation(self:GetID(), 0);
        self.Data.TalkedTo = nil;
    end
    return self;
end

---
-- Gibt true zurück, wenn der NPC angesprochen wurde. Ist ein
-- spezieller Ansprechpartner definiert, wird nur dann true
-- zurückgegeben, wenn dieser Held mit dem NPC spricht.
--
-- <b>Alias:</b> NonPlayerCharacter:HasTalkedTo
--
-- @return boolean
-- @within NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:HasTalkedTo()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    if self.Data.HeroName then
        return self.Data.TalkedTo == GetID(self.Data.HeroName);
    end
    return self.Data.TalkedTo ~= nil;
end

---
-- Setzt den Ansprechpartner für diesen NPC.
--
-- <b>Alias:</b> NonPlayerCharacter:SetDialogPartner
--
-- @param _HeroName     Skriptname des Helden
-- @return Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetDialogPartner(_HeroName)
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    self.Data.HeroName = _HeroName;
    return self;
end

---
-- Setzt das Callback für den Fall, dass ein falscher Held den
-- NPC anspricht.
--
-- <b>Alias:</b> NonPlayerCharacter:SetWrongPartnerCallback
--
-- @param _Callback     Callback
-- @return Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetWrongPartnerCallback(_Callback)
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    self.Data.WrongHeroCallback = _Callback;
    return self;
end

---
-- Setzt das Ziel, zu dem der NPC vom Helden geführt werden
-- muss. Wenn ein Ziel erreicht wird, kann der NPC erst dann
-- angesprochen werden, wenn das Ziel erreicht ist.
--
-- <b>Alias:</b> NonPlayerCharacter:SetFollowDestination
--
-- @param _ScriptName     Skriptname des Ziel
-- @return Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetFollowDestination(_ScriptName)
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    self.Data.FollowDestination = _ScriptName;
    return self;
end

---
-- Setzt den Helden, dem der NPC folgt. Ist Kein Ziel gesetzt,
-- folgt der NPC dem Helden unbegrenzt.
--
-- <b>Alias:</b> NonPlayerCharacter:SetFollowTarget
--
-- @param _ScriptName     Skriptname des Helden
-- @return Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetFollowTarget(_ScriptName)
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    self.Data.FollowTarget = _ScriptName;
    return self;
end

---
-- Setzt die Funktion, die während ein NPC einem Helden folgt und
-- das Ziel noch nicht erreicht ist, anstelle des Callback beim
-- Ansprechen ausgeführt wird.
--
-- <b>Alias:</b> NonPlayerCharacter:SetFollowAction
--
-- @param _Function     Action
-- @return Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetFollowAction(_Function)
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    self.Data.FollowAction = _Function;
    return self;
end
---
-- Setzt das Ziel zu dem der NPC läuft und den Helden, der dem
-- NPC folgen muss.
--
-- <b>Alias:</b> NonPlayerCharacter:SetGuideParams
--
-- @param _ScriptName     Skriptname des Ziel
-- @param _Target         Striptname des Helden
-- @return Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetGuideParams(_ScriptName, _Target)
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    self.Data.GuideDestination = _ScriptName;
    self.Data.GuideTarget = _Target;
    return self;
end

---
-- Setzt die Funktion, die während ein NPC einen Helden führt und
-- das Ziel noch nicht erreicht ist, anstelle des Callback beim
-- Ansprechen ausgeführt wird.
--
-- <b>Alias:</b> NonPlayerCharacter:SetGuideAction
--
-- @param _Function     Action
-- @return Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetGuideAction(_Function)
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    self.Data.GuideAction = _Function;
    return self;
end

---
-- Setzt das Callback des NPC, dass beim Ansprechen ausgeführt wird.
--
-- <b>Alias:</b> NonPlayerCharacter:SetCallback
--
-- @param _Callback     Callback
-- @return Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetCallback(_Callback)
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    assert(type(_Callback) == "function", 'callback must be a function!');
    self.Data.Callback = _Callback;
    return self;
end

-- -------------------------------------------------------------------------- --
-- Behavior                                                                   --
-- -------------------------------------------------------------------------- --

---
-- Der Held muss einen Nichtspielercharakter ansprechen.
--
-- @param _NpcName  Skriptname des NPC
-- @param _HeroName Skriptname des Helden (optional)
-- @return Table mit Behavior
-- @within Behavior
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

function b_Goal_NPC:GetGoalTable(__quest_)
    return {Objective.Distance, -65565, self.Hero, self.NPC, self }
end

function b_Goal_NPC:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.NPC = __parameter_
    elseif (__index_ == 1) then
        self.Hero = __parameter_
        if self.Hero == "-" then
            self.Hero = nil
        end
   end
end

function b_Goal_NPC:GetIcon()
    return {14,10}
end

Core:RegisterBehavior(b_Goal_NPC);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald der NPC angesprochen wurde.
--
-- @param _NpcName  Skriptname des NPC
-- @param _HeroName Skriptname des Helden (optional)
-- @return Table mit Behavior
-- @within Behavior
--
function Trigger_NPC(...)
    return b_Trigger_NPC:new(...);
end

b_Trigger_NPC = {
    Name = "Trigger_NPC",
    Description = {
        en = "Trigger: Starts the quest after the npc was spoken to.",
        de = "Ausloeser: Startet den Quest, sobald der NPC angesprochen wurde.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "NPC",  de = "NPC" },
        { ParameterType.ScriptName, en = "Hero", de = "Held" },
    },
}

function b_Trigger_NPC:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_NPC:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.NPC = __parameter_
    elseif (__index_ == 1) then
        self.Hero = __parameter_
        if self.Hero == "-" then
            self.Hero = nil
        end
    end
end

function b_Trigger_NPC:CustomFunction()
    if not IsExisting(self.NPC) then
        return;
    end
    if not self.NpcInstance then
        local NPC = NonPlayerCharacter:New(self.NPC);
        NPC:SetDialogPartner(self.Hero);
        self.NpcInstance = NPC;
    end
    local TalkedTo = self.NpcInstance:HasTalkedTo(self.Hero);
    if not TalkedTo then
        if not self.NpcInstance:IsActive() then
            self.NpcInstance:Activate();
        end
    end
    return TalkedTo;
end

function b_Trigger_NPC:Reset(__quest_)
    if self.NpcInstance then
        self.NpcInstance:Dispose();
    end
end

function b_Trigger_NPC:DEBUG(__quest_)
    return false;
end

Core:RegisterBehavior(b_Trigger_NPC);

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Application-Space
-- @local
--
function BundleNonPlayerCharacter.Global:Install()
    NonPlayerCharacter = BundleNonPlayerCharacter.Global.NonPlayerCharacter;
    
    ---
    -- Führt die statische Steuerungsfunktion für alle NPC aus.
    --
    StartSimpleJobEx( function()
        for k, v in pairs(BundleNonPlayerCharacter.Global.NonPlayerCharacterObjects) do
            NonPlayerCharacter:Control(k);
        end
    end);
    
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    GameCallback_OnNPCInteraction_Orig_QSB_NPC_Rewrite = GameCallback_OnNPCInteraction
    GameCallback_OnNPCInteraction = function(_EntityID, _PlayerID)
        GameCallback_OnNPCInteraction_Orig_QSB_NPC_Rewrite(_EntityID, _PlayerID)
        Quest_OnNPCInteraction(_EntityID, _PlayerID)
    end
    
    Quest_OnNPCInteraction = function(_EntityID, _PlayerID)
        local KnightIDs = {};
        Logic.GetKnights(_PlayerID, KnightIDs);
        -- Akteure ermitteln
        local ClosestKnightID = 0;
        local ClosestKnightDistance = Logic.WorldGetSize();
        for i= 1, #KnightIDs, 1 do
            local DistanceBetween = Logic.GetDistanceBetweenEntities(KnightIDs[i], _EntityID);
            if DistanceBetween < ClosestKnightDistance then
                ClosestKnightDistance = DistanceBetween;
                ClosestKnightID = KnightIDs[i];
            end
        end
        BundleNonPlayerCharacter.Global.LastHeroEntityID = ClosestKnightID;
        local NPC = NonPlayerCharacter:GetInstance(_EntityID);
        BundleNonPlayerCharacter.Global.LastNpcEntityID = NPC:GetID();
        
        if NPC then
            if NPC.Data.FollowTarget ~= nil then
                if NPC.Data.FollowDestination then
                    API.Note(Logic.GetDistanceBetweenEntities(_EntityID, GetID(NPC.Data.FollowDestination)))
                    if Logic.GetDistanceBetweenEntities(_EntityID, GetID(NPC.Data.FollowDestination)) > 2000 then
                        if NPC.Data.FollowAction then 
                            NPC.Data.FollowAction(self);
                        end
                        return
                    end
                else
                    if NPC.Data.FollowAction then
                        NPC.Data.FollowAction(self);
                    end
                    return
                end
            end

            if NPC.Data.GuideTarget ~= nil then
                local TargetID = GetID(NPC.Data.GuideDestination);
                if Logic.GetDistanceBetweenEntities(_EntityID, TargetID) > 2000 then
                    if NPC.Data.GuideAction then
                        NPC.Data.GuideAction(NPC);
                    end
                    return;
                end
                Logic.SetTaskList(_EntityID, TaskLists.TL_NPC_IDLE);
            end
            
            NPC:RotateActors();
            NPC.Data.TalkedTo = ClosestKnightID;
            if NPC:HasTalkedTo() then
                NPC:Deactivate();
                if NPC.Data.Callback then
                    NPC.Data.Callback(NPC, ClosestKnightID);
                end
            else
                if NPC.Data.WrongHeroCallback then
                    NPC.Data.WrongHeroCallback(NPC, ClosestKnightID);
                end
            end
        end
    end
    
    function QuestTemplate:RemoveQuestMarkers()
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if ((type(self.Objectives[i].Data[1]) == "number" and self.Objectives[i].Data[1] > 0) 
                or (type(self.Objectives[i].Data[1]) ~= "number")) and self.Objectives[i].Data[4] then
                    DestroyQuestMarker(self.Objectives[i].Data[2]);
                end
            end
        end
    end

    function QuestTemplate:ShowQuestMarkers()
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if ((type(self.Objectives[i].Data[1]) == "number" and self.Objectives[i].Data[1] > 0) 
                or (type(self.Objectives[i].Data[1]) ~= "number")) and self.Objectives[i].Data[4] then
                    ShowQuestMarker(self.Objectives[i].Data[2]);
                end
            end
        end
    end
    
    QuestTemplate.IsObjectiveCompleted_QSBU_NPC_Rewrite = QuestTemplate.IsObjectiveCompleted;
    QuestTemplate.IsObjectiveCompleted = function(self, objective)
        local objectiveType = objective.Type;
        local data = objective.Data;
        if objective.Completed ~= nil then
            return objective.Completed;
        end

        if objectiveType ~= Objective.Distance then
            return self:IsObjectiveCompleted_QSBU_NPC_Rewrite(objective);
        else
            if data[1] == -65565 then
                if not IsExisting(data[3]) then
                    return false;
                end
                if not data[4].NpcInstance then
                    local NPC = NonPlayerCharacter:New(data[3]);
                    NPC:SetDialogPartner(data[2]);
                    data[4].NpcInstance = NPC;
                end
                if data[4].NpcInstance:HasTalkedTo(data[2]) then
                    objective.Completed = true;
                end
                if not objective.Completed then
                    if not data[4].NpcInstance:IsActive() then
                        data[4].NpcInstance:Activate();
                    end
                end
            else
                return self:IsObjectiveCompleted_QSBU_NPC_Rewrite(objective);
            end
        end
    end
end

---
-- Rotiert alle nahen Helden zum NPC und den NPC zu dem Helden,
-- der ihn angesprochen hat.
--
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:RotateActors()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    
    local PlayerID = Logic.EntityGetPlayer(BundleNonPlayerCharacter.Global.LastHeroEntityID);
    local KnightIDs = {};
    Logic.GetKnights(PlayerID, KnightIDs);
    for i= 1, #KnightIDs, 1 do
        if Logic.GetDistanceBetweenEntities(KnightIDs[i], BundleNonPlayerCharacter.Global.LastNpcEntityID) < 3000 then
            local x,y,z = Logic.EntityGetPos(KnightIDs[i]);
            if Logic.IsEntityMoving(KnightIDs[i]) then
                Logic.MoveEntity(KnightIDs[i], x, y);
            end
            LookAt(KnightIDs[i], self.Data.NpcName);
        end
    end
    
    local Offset = 0;
    if Logic.IsEntityInCategory(self.Data.NpcName, EntityCategories.Hero) == 1 then
        LookAt(self.Data.NpcName, BundleNonPlayerCharacter.Global.LastNpcEntityID, 15);
    end
    LookAt(self.Data.NpcName, BundleNonPlayerCharacter.Global.LastHeroEntityID);
end

---
-- Steuert das Verhalten des NPC.
-- Soll ein NPC einem Helden folgen, wird er stehen bleiben, wenn
-- er dem Helden zu nahe, oder zu weit von ihm entfernt ist.
-- Soll ein NPC einen Helden führen, ...
--
-- @param _ScriptName   Skriptname des NPC
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:Control(_ScriptName)
    assert(self == BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used from instance!');
    if not IsExisting(_ScriptName) then
        return;
    end
    
    local NPC = NonPlayerCharacter:GetInstance(_ScriptName);
    if not NPC then
        return;
    end
    if not NPC:IsActive() then
        return;
    end

    if NPC.Data.FollowTarget ~= nil then
        local NpcID  = NPC:GetID();
        local HeroID = GetID(NPC.Data.FollowTarget);
        local DistanceToHero = Logic.GetDistanceBetweenEntities(NpcID, HeroID);
        
        local MinDistance = 400;
        if Logic.IsEntityInCategory(NpcID, EntityCategories.Hero) == 1 then
            MinDistance = 800;
        end
        if DistanceToHero < MinDistance or DistanceToHero > 3500 then
            Logic.SetTaskList(NpcID, TaskLists.TL_NPC_IDLE);
            return;
        end
        if DistanceToHero >= MinDistance then
            local x, y, z = Logic.EntityGetPos(HeroID);
            Logic.MoveSettler(NpcID, x, y);
            return;
        end
    end

    if NPC.Data.GuideTarget ~= nil then
        local NpcID    = NPC:GetID();
        local HeroID   = GetID(NPC.Data.GuideTarget);
        local TargetID = GetID(NPC.Data.GuideDestination);
        
        local DistanceToHero   = Logic.GetDistanceBetweenEntities(NpcID, HeroID);
        local DistanceToTarget = Logic.GetDistanceBetweenEntities(NpcID, TargetID);

        if DistanceToTarget > 2000 then
            if DistanceToHero < 1500 and not Logic.IsEntityMoving(NpcID) then
                local x, y, z = Logic.EntityGetPos(TargetID);
                Logic.MoveSettler(NpcID, x, y);
            elseif DistanceToHero > 3000 and Logic.IsEntityMoving(NpcID) then
                local x, y, z = Logic.EntityGetPos(NpcID);
                Logic.MoveSettler(NpcID, x, y);
            end
        end
    end
end

-- Local Script ----------------------------------------------------------------

---
-- Initialisiert das Bundle im lokalen Skript.
-- @within Application-Space
-- @local
--
function BundleNonPlayerCharacter.Local:Install()
    g_CurrentDisplayedQuestID = 0;

    GUI_Interaction.DisplayQuestObjective_Orig_QSBU_NPC_Rewrite = GUI_Interaction.DisplayQuestObjective
    GUI_Interaction.DisplayQuestObjective = function(_QuestIndex, _MessageKey)
        local lang = Network.GetDesiredLanguage();
        if lang ~= "de" then lang = "en" end

        local QuestIndexTemp = tonumber(_QuestIndex);
        if QuestIndexTemp then
            _QuestIndex = QuestIndexTemp;
        end

        local Quest, QuestType = GUI_Interaction.GetPotentialSubQuestAndType(_QuestIndex);
        local QuestObjectivesPath = "/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives";
        XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives", 0);
        local QuestObjectiveContainer;
        local QuestTypeCaption;

        local ParentQuest = Quests[_QuestIndex];
        local ParentQuestIdentifier;
        if ParentQuest ~= nil
        and type(ParentQuest) == "table" then
            ParentQuestIdentifier = ParentQuest.Identifier;
        end
        local HookTable = {};

        g_CurrentDisplayedQuestID = _QuestIndex;

        if QuestType == Objective.Distance then
            QuestObjectiveContainer = QuestObjectivesPath .. "/List";
            QuestTypeCaption = Wrapped_GetStringTableText(_QuestIndex, "UI_Texts/QuestInteraction");
            local ObjectList = {};

            if Quest.Objectives[1].Data[1] == -65565 then
                QuestObjectiveContainer = QuestObjectivesPath .. "/Distance";
                QuestTypeCaption = Wrapped_GetStringTableText(_QuestIndex, "UI_Texts/QuestMoveHere");
                SetIcon(QuestObjectiveContainer .. "/QuestTypeIcon",{7,10});

                local MoverEntityID = GetEntityId(Quest.Objectives[1].Data[2]);
                local MoverEntityType = Logic.GetEntityType(MoverEntityID);
                local MoverIcon = g_TexturePositions.Entities[MoverEntityType];
                if Quest.Objectives[1].Data[1] == -65567 or not MoverIcon then
                    MoverIcon = {16,12};
                end
                SetIcon(QuestObjectiveContainer .. "/IconMover", MoverIcon);

                local TargetEntityID = GetEntityId(Quest.Objectives[1].Data[3]);
                local TargetEntityType = Logic.GetEntityType(TargetEntityID);
                local TargetIcon = g_TexturePositions.Entities[TargetEntityType];
                if not TargetIcon then
                    TargetIcon = {14,10};
                end

                local IconWidget = QuestObjectiveContainer .. "/IconTarget";
                local ColorWidget = QuestObjectiveContainer .. "/TargetPlayerColor";

                SetIcon(IconWidget, TargetIcon);
                XGUIEng.SetMaterialColor(ColorWidget, 0, 255, 255, 255, 0);

                SetIcon(QuestObjectiveContainer .. "/QuestTypeIcon",{16,12});
                local caption = {de = "Gespräch beginnen", en = "Start conversation"};
                QuestTypeCaption = caption[lang];

                XGUIEng.SetText(QuestObjectiveContainer.."/Caption","{center}"..QuestTypeCaption);
                XGUIEng.ShowWidget(QuestObjectiveContainer, 1);
            else
                GUI_Interaction.DisplayQuestObjective_Orig_QSBU_NPC_Rewrite(_QuestIndex, _MessageKey);
            end
        else
            GUI_Interaction.DisplayQuestObjective_Orig_QSBU_NPC_Rewrite(_QuestIndex, _MessageKey);
        end
    end
    
    GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_QSBU_NPC_Rewrite = GUI_Interaction.GetEntitiesOrTerritoryListForQuest
    GUI_Interaction.GetEntitiesOrTerritoryListForQuest = function( _Quest, _QuestType )
        local EntityOrTerritoryList = {}
        local IsEntity = true

        if _QuestType == Objective.Distance then
            if _Quest.Objectives[1].Data[1] == -65565 then
                local Entity = GetEntityId(_Quest.Objectives[1].Data[3]);
                table.insert(EntityOrTerritoryList, Entity);
            else
                return GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_QSBU_NPC_Rewrite( _Quest, _QuestType );
            end

        else
            return GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_QSBU_NPC_Rewrite( _Quest, _QuestType );
        end
        return EntityOrTerritoryList, IsEntity
    end
end

Core:RegisterBundle("BundleNonPlayerCharacter");

