-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnArmyController                                          # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --
---@diagnostic disable: undefined-global
---@diagnostic disable: need-check-nil
---@diagnostic disable: lowercase-global

---
-- 
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnArmyController = {};

API = API or {};
QSB = QSB or {};

QSB.MilitaryArmyList = {};
QSB.MilitaryGroupList = {};

QSB.ArmyState = {
    Idle = 0;
}

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --



-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnArmyController = {
    Global = {
        Data = {
            Armies = {},
            Paths = {},
        },
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function AddOnArmyController.Global:Install()

    -- Controller loop
    StartSimpleJobEx(function ()
        AddOnArmyController.Global:ControllerLoop();
    end);
end

function AddOnArmyController.Global:ControllerLoop()
    if Logic.GetTime() % 5 == 0 then
        for i= 1, 8, 1 do
            if self.Data.Armies[i] then
                for k, v in pairs(self.Data.Armies[i]) do
                    -- TODO: Control armies here
                end
            end
        end
    end
end

function AddOnArmyController.Global:GetUnitType(_ArmyID, _Category)
    if _Category ~= EntityCategories.Melee and _Category ~= EntityCategories.Ranged then
        _Category = EntityCategories.Melee;
    end

    local TypeName = "U_MilitarySword";
    if self.Data.Armies[_ArmyID].m_UnitType == QSB.UnitType.Bandit then
        local Climate = self:GetClimateZoneSuffix();
        TypeName = "U_MilitaryBandit_Melee_" ..Climate;
        if _Category == EntityCategories.Ranged then
            TypeName = "U_MilitaryBandit_Ranged_" ..Climate;
        end
    else
        if _Category == EntityCategories.Ranged then
            TypeName = "U_MilitaryBow";
        end
        if self.Data.Armies[_ArmyID].m_UnitType == QSB.UnitType.RedPrince then
            TypeName = TypeName.. "_RedPrince";
        end
        if self.Data.Armies[_ArmyID].m_UnitType == QSB.UnitType.Cultist then
            TypeName = TypeName.. "_Khana";
        end
    end
    return Entities[TypeName];
end

function AddOnArmyController.Global:GetClimateZoneSuffix()
    local MapName = Framework.GetCurrentMapName();
    local MapType, Campaign = Framework.GetCurrentMapTypeAndCampaignName();
    local ClimateZoneName = Framework.GetMapClimateZone(MapName, MapType, Campaign);

    local Suffix = "ME";
    if ClimateZoneName == "MiddleEurope" then
        Suffix = "ME";
    elseif ClimateZoneName == "NorthEurope" then
        Suffix = "NE";
    elseif ClimateZoneName == "SouthEurope" then
        Suffix = "SE";
    elseif ClimateZoneName == "NorthAfrica" then
        Suffix = "NA";
    elseif ClimateZoneName == "Asia" then
        Suffix = "AS";
    end
    return Suffix;
end

-- Classes ------------------------------------------------------------------ --

QSB.MilitaryArmy = {
    m_ID       = 0;
    m_PlayerID = 8;
    m_State    = QSB.ArmyState.Idle;
    m_SubState = 0;

    m_GroupID  = 0;
    m_Sword    = 0;
    m_Bow      = 0;
    m_Rams     = 0;
    m_Towers  = 0;
    m_Catapult = 0;
    m_AmmoCart = 0;

    m_Waypoint = 0;
    m_Path     = {};
}

function QSB.MilitaryArmy:New(_PlayerID, _Sword, _Bow, _Rams, _Towers, _Catapult, _AmmoCart)
    self.m_ID = _ID or (self.m_ID +1);
    local Army = API.InstanceTable(self);

    Army.m_PlayerID = _PlayerID;
    Army.m_Sword    = _Sword or 0;
    Army.m_Bow      = _Bow or 0;
    Army.m_Rams     = _Rams or 1;
    Army.m_Towers   = _Towers or 1;
    Army.m_Catapult = _Catapult or 1;
    Army.m_AmmoCart = _AmmoCart or 0;

    assert(Army.m_Sword + Army.m_Bow > 0, "Army must have at least 1 battalion!");
    assert(Army.m_Rams + Army.m_Towers + Army.m_Catapult > 0, "Army must have war machines!");

    QSB.MilitaryArmyList[Army.m_ID] = Army;
    return Army;
end

function QSB.MilitaryArmy:SetState(_State)
    self.m_State = _State;
    return self;
end

function QSB.MilitaryArmy:SetSubState(_State)
    self.m_SubState = _State;
    return self;
end

function QSB.MilitaryArmy:SetPath(_Path)
    self.m_Path = _Path;
    return self;
end

function QSB.MilitaryArmy:SetWaypoint(_Waypoint)
    self.m_Waypoint = _Waypoint;
    return self;
end

function QSB.MilitaryArmy:SetGroupID(_GroupID)
    self.m_GroupID = _GroupID;
    return self;
end

function QSB.MilitaryArmy:GetGroupOfArmy()
    return QSB.MilitaryGroup:GetInstance(self.m_GroupID);
end

-- ### --

QSB.MilitaryGroup = {
    m_ID      = 0;
    m_Members = {};
    m_Orders  = nil;

    -- Map that validates which action is possible for which type of unit.
    -- Keep in mind that only leaders and warmachines can be part of a group.
    ActionValidation = {
        -- {IsLeader, IsWarmachine, IsGuarding, IsGuarded}
        -- 0: forbid, 1: require, 2: ignore
        Attack     = {1,0,2,2};
        AttackWall = {1,0,1,0};
        Move       = {1,1,2,2};
        Idle       = {1,1,2,2};
        Mount      = {1,0,0,0};
        Unmount    = {1,0,1,0};
        Expand     = {0,1,0,1};
        Collapse   = {0,1,0,1};
    }
};

function QSB.MilitaryGroup:New(_Members, _ID)
    self.m_ID = _ID or (self.m_ID +1);
    local Group = API.InstanceTable(self);
    Group.m_Members = (_Members ~= nil and _Members) or {};
    QSB.MilitaryGroupList[Group.m_ID] = Group;
    return Group;
end

function QSB.MilitaryGroup:GetInstance(_ID)
    if QSB.MilitaryGroupList[_ID] then
        return QSB.MilitaryGroupList[_ID];
    end
    -- If nil, create group with id
    return QSB.MilitaryGroup:New(nil, _ID);
end

function QSB.MilitaryGroup:AddMember(_Unit)
    if not self:IsMember(_Unit) then
        table.insert(self.m_Members, _Unit);
    end
    return self;
end

function QSB.MilitaryGroup:SetMember(...)
    self.m_Members = arg;
    return self;
end

function QSB.MilitaryGroup:IsMember(_Unit)
    for k, v in pairs(self.m_Members) do
        if v == _Unit then
            return true;
        end
    end
    return false;
end

function QSB.MilitaryGroup:IsAlive()
    return self:GetStrength() > 0;
end

function QSB.MilitaryGroup:IsMoving()
    for k, v in pairs(self.m_Members) do
        if Logic.IsEntityMoving(v) == true then
            return true;
        end
    end
    return false;
end

function QSB.MilitaryGroup:IsFighting()
    for k, v in pairs(self.m_Members) do
        if Logic.IsFighting(v) == true then
            return true;
        end
    end
    return false;
end

function QSB.MilitaryGroup:GetStrength()
    if #self:FilterLeader() == 0 then
        return 0;
    end
    local Alive = 0;
    for k, v in pairs(self:FilterLeader()) do
        if IsExisting(v) then
            Alive = Alive +1;
        end
    end
    return Alive / (self.m_Bow + self.m_Sword);
end

function QSB.MilitaryGroup:CanMountWarMachines()
    return #self:FilterWarMachines() > 0 and #self:FilterLeader() > 0;
end

function QSB.MilitaryGroup:React(_Action, ...)
    local Action = (type(_Action) == "string" and self.ActionValidation[_Action]) or _Action;
    if not Action then
        return;
    end
    self.m_Orders = _Action;
    for k, v in pairs(self.m_Members) do
        local React = true;

        -- Is leader
        if React and Action[1] == 0 and Logic.IsEntityInCategory(v, EntityCategories.Leader) == 1 then
            React = false;
        end
        if React and Action[1] == 1 and Logic.IsEntityInCategory(v, EntityCategories.Leader) == 0 then
            React = false;
        end
        -- Is warmachine
        if React and Action[2] == 0 and Logic.IsEntityInCategory(v, EntityCategories.SiegeEngine) == 1 then
            React = false;
        end
        if React and Action[2] == 1 and Logic.IsEntityInCategory(v, EntityCategories.SiegeEngine) == 0 then
            React = false;
        end
        -- is guarding something
        if React and Action[3] == 0 and Logic.GetGuardedID(v) ~= 0 then
            React = false;
        end
        if React and Action[3] == 1 and Logic.GetGuardedID(v) == 0 then
            React = false;
        end
        -- is guarded by battalion
        if React and Action[4] == 0 and Logic.GetGuardianID(v) ~= 0 then
            React = false;
        end
        if React and Action[4] == 1 and Logic.GetGuardianID(v) == 0 then
            React = false;
        end

        if React then
            local Reaction = QSB.MilitaryReaction:New(v);
            Reaction[_Action](Reaction, unpack(arg));
        end
    end
end

function QSB.MilitaryGroup:FilterWarMachines()
    local Machines = {};
    for k, v in pairs(self.m_Members) do
        if Logic.IsEntityInCategory(v, EntityCategories.SiegeEngine) == 1 and Logic.GetEntityType(v) ~= Entities.U_AmmunitionCart then
            table.insert(Machines, v);
        end
    end
    return Machines;
end

function QSB.MilitaryGroup:FilterLeader()
    local Leaders = {};
    for k, v in pairs(self.m_Members) do
        if Logic.IsEntityInCategory(v, EntityCategories.Leader) == 1 then
            table.insert(Leaders, v);
        end
    end
    return Leaders;
end

function QSB.MilitaryGroup:FilterType(_Type)
    local Machines = {};
    for k, v in pairs(self.m_Members) do
        if Logic.GetEntityType(v) == _Type then
            table.insert(Machines, v);
        end
    end
    return Machines;
end

-- ### --

QSB.MilitaryReaction = {
    m_Entity = 0;
};

function QSB.MilitaryReaction:New(_ID)
    local Reaction = API.InstanceTable(QSB.MilitaryReaction);
    Reaction.m_Entity = _ID;
    return Reaction;
end

function QSB.MilitaryGroup:Collapse()
    -- ... Collapse v
end

function QSB.MilitaryGroup:Expand()
    -- ... Erect v
end

function QSB.MilitaryGroup:Unmount()
    if Logic.GetGuardianID(self.m_Entity) ~= 0 then
        Logic.GuardEntity(self.m_Entity, 0);
    end
end

function QSB.MilitaryGroup:Mount(_WarMachines)
    for i= 1, #_WarMachines do
        if Logic.GetGuardianID(_WarMachines[i]) == 0 and Logic.GetEntityType(_WarMachines[i]) ~= Entities.U_AmmunitionCart then
            if Logic.GetGuardedID(self.m_Entity) == 0 then
                Logic.GuardEntity(self.m_Entity, _WarMachines[i]);
            end
        end
    end
end

function QSB.MilitaryGroup:Idle()
    Logic.SetTaskList(self.m_Entity, TaskLists.TL_MILITARY_IDLE);
end

function QSB.MilitaryGroup:Move(_Position)
    Logic.MoveSettler(self.m_Entity, _Position.X, _Position.Y);
end

function QSB.MilitaryGroup:Attack(_Position)
    Logic.GroupAttackMove(self.m_Entity, _Position.X, _Position.Y);
end

function QSB.MilitaryGroup:AttackWall(_TargetID)
    local GuardedID = Logic.GetGuardedID(self.m_Entity);
    if GuardedID == 0 then
        return;
    end
    local GuardedType  = Logic.GetEntityType(GuardedID);
    local GuardianType = Logic.GetEntityType(self.m_Entity);
    local TargetName   = Logic.GetEntityTypeName(Logic.GetEntityType(_TargetID));

    -- Target is gate
    if string.find(TargetName, "Gate") then
        if GuardedType ~= Entities.U_MilitaryBatteringRam then
            return;
        end
    -- Target is Wall
    else
        -- Palisade can only be attacked by catapults
        if string.find(TargetName, "Palisade") then
            if GuardedType ~= Entities.U_MilitaryCatapult then
                return;
            end
        end
        -- Walls can not be attacked by rams
        if GuardedType == Entities.U_MilitaryBatteringRam then
            return;
        end
    end
    Logic.GroupAttack(self.m_Entity, _TargetID);
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("AddOnArmyController");

