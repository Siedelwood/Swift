-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntityHealth                                           # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle soll dem Mapper ermöglichen die Trigger, die auslösen, wenn
-- Entities kämpfen, besser zu nutzen. Außerdem werden einige Hilfsfunktionen
-- bereitgestellt.
--
-- @module BundleEntityHealth
-- @set sort=true
--

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Gibt die Gesundheit des Entity in prozent zurück.
--
-- Achtung: Nur Siedler (inklusive Millitär und Helden), Belagerungswaffen,
-- Gebäude und Raubtiere haben Gesundheit.
--
-- <b>Alias</b>: GetHealth
--
-- @param _Entity Entity to change
-- @return number: Health in percent
-- @within Public
--
function API.GetHealth(_Entity)
    return BundleEntityHealth:GetHealth(_Entity);
end
GetHealth = API.GetHealth;

---
-- Ändert die Gesundheit des Entity zu dem angegeben Wert in Prozent.
--
-- Achtung: Nur Siedler (inklusive Millitär und Helden), Belagerungswaffen,
-- Gebäude und Raubtiere haben Gesundheit.
--
-- <b>Alias</b>: SetHealth
--
-- @param _Entity     Entity to change
-- @param _Percentage Health amount
-- @within Public
--
function API.SetHealth(_Entity, _Percentage)
    if GUI then
        local Sublect = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Bridge("API.SetHealth(" ..Sublect.. ", " .._Percentage.. ")");
        return;
    end
    if not IsExisting(_Entity) then
        local Sublect = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.SetHealth: _Entity " ..Sublect.. " does not exist!");
        return;
    end
    if type(_Percentage) ~= "number" then
        API.Dbg("API.SetHealth: _Percentage must be a number!");
        return;
    end

    _Percentage = (_Percentage < 0 and 0) or _Percentage;
    if _Percentage > 100 then
        API.Warn("API.SetHealth: _Percentage is larger than 100%. This could cause problems!");
    end
    BundleEntityHealth.Global:SetEntityHealth(_Entity, _Percentage);
end
SetHealth = API.SetHealth;

---
-- Steckt ein Gebäude in Brand.
--
-- Achtung: Nur Gebäude können in Brand gesteckt werden.
--
-- <b>Alias</b>: SetOnFire
--
-- @param _Entity   Entity to change
-- @param _Strength Intensity of fire
-- @within Public
--
function API.SetOnFire(_Entity, _Strength)
    if GUI then
        local Sublect = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Bridge("API.SetOnFire(" ..Sublect.. ", " .._Strength.. ")");
        return;
    end
    if not IsExisting(_Entity) then
        local Sublect = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.SetOnFire: Entity " ..Sublect.. " does not exist!");
        return;
    end
    if Logic.IsBuilding(GetID(_Entity)) == 0 then
        API.Dbg("API.SetOnFire: Only buildings can be set on fire!");
        return;
    end
    if type(_Strength) ~= "number" then
        API.Dbg("API.SetOnFire: _Strength must be a number!");
        return;
    end
    _Strength = (_Strength < 0 and 0) or _Strength;
    Logic.DEBUG_SetBuildingOnFile(GetID(_Entity), _Strength);
end
SetOnFire = API.SetOnFire;


---
-- Verwundet ein Entity oder ein Battalion um den angegebenen Wert. Wird ein
-- Battalion verwundet, werden der reihe nach alle Soldaten verwunden, bis
-- der gesamte Schaden verrechnet wurde.
--
-- <b>Alias</b>: HurtEntityEx
--
-- @param _Target         Ziel des Schadens
-- @param _AmountOfDamage Menge an Schaden
-- @param _Attacker       (Optional) Angreifendes Entity
-- @within Public
--
function API.HurtEntity(_Target, _AmountOfDamage, _Attacker)
    if GUI then
        local Target = (type(_Target) == "string" and "'" .._Target.. "'") or _Target;
        local Attacker = (type(_Attacker) == "string" and "'" .._Attacker.. "'") or _Attacker;
        API.Bridge("API.HurtEntity(" ..Target.. ", " .._AmountOfDamage.. ", " ..tostring(Attacker).. ")");
        return;
    end
    if not IsExisting(_Target) then
        local Sublect = (type(_Target) == "string" and "'" .._Target.. "'") or _Target;
        API.Dbg("API.HurtEntity: Entity " .._Target.. " does not exist!");
        return;
    end
    if type(_AmountOfDamage) ~= "number" or _AmountOfDamage < 0 then
        API.Dbg("API.SetOnFire: _Strength must be a number greater or equal 0!");
        return;
    end
    local EntityID = GetID(_Target);
    local AttackerID = GetID(_Attacker);
    return BundleEntityHealth.Global:HurtEntityEx(EntityID, _AmountOfDamage, AttackerID);
end
HurtEntityEx = API.HurtEntity;

---
-- Fügt eine Funktion hinzu, die ausgeführt wird, wenn ein Entity von einem
-- anderen Entity verwundet wird.
--
-- <b>Alias</b>: AddEntityHurtAction
--
-- @param _Function Funktion, die ausgeführt wird.
-- @within Public
--
function API.AddOnEntityHurtAction(_Function)
    if GUI then
        API.Dbg("API.AddOnEntityHurtAction: Can not be used in local script!");
        return;
    end
    if type(_Function) ~= "function" then
        API.Dbg("_Function must be a function!");
        return;
    end
    BundleEntityHealth.Global.AddOnEntityHurtAction(_Function);
end
AddEntityHurtAction = API.AddOnEntityHurtAction;

---
-- Fügt eine Funktion hinzu, die ausgeführt wird, wenn ein Entity zerstört wird.
--
-- <b>Alias</b>: AddEntityKilledAction
--
-- @param _Function Funktion, die ausgeführt wird.
-- @within Public
--
function API.AddOnEntityDestroyedAction(_Function)
    if GUI then
        API.Dbg("API.AddOnEntityDestroyedAction: Can not be used in local script!");
        return;
    end
    if type(_Function) ~= "function" then
        API.Dbg("_Function must be a function!");
        return;
    end
    BundleEntityHealth.Global.AddOnEntityDestroyedAction(_Function);
end
AddEntityKilledAction = API.AddOnEntityDestroyedAction;

---
-- Fügt eine Funktion hinzu, die ausgeführt wird, wenn ein Entity erzeugt wird.
--
-- <b>Alias</b>: AddSettlerSpawnedAction
--
-- @param _Function Funktion, die ausgeführt wird.
-- @within Public
--
function API.AddOnEntityCreatedAction(_Function)
    if GUI then
        API.Dbg("API.AddOnEntityCreatedAction: Can not be used in local script!");
        return;
    end
    if type(_Function) ~= "function" then
        API.Dbg("_Function must be a function!");
        return;
    end
    BundleEntityHealth.Global.AddOnEntityCreatedAction(_Function);
end
AddSettlerSpawnedAction = API.AddOnEntityCreatedAction;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleEntityHealth = {
    Global = {
        Data = {
            OnEntityCreatedAction = {},
            OnEntityDestroyedAction = {},
            OnEntityHurtAction = {},
        },
    },
    Local = {
        Data = {}
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Private
-- @local
--
function BundleEntityHealth.Global:Install()
    BundleEntityHealth_EntityHurtEntityController = self.EntityHurtEntityController;
    Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "BundleEntityHealth_EntityHurtEntityController", 1);

    BundleEntityHealth_EntityDestroyedController = self.EntityDestroyedController;
    Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "BundleEntityHealth_EntityDestroyedController", 1);
    
    Core:AppendFunction("GameCallback_SettlerSpawned", self.EntityCreatedController);
end

---
-- Ändert die Gesundheit des Entity zu dem angegeben Wert in Prozent.
--
-- @param _Entity     Entity to change
-- @param _Percentage Health amount
-- @within Private
-- @local
--
function BundleEntityHealth.Global:SetEntityHealth(_Entity, _Percentage)
    if not IsExisting(_Entity) then
        return;
    end
    local EntityID  = GetID(_Entity);
    local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
    local Health    = Logic.GetEntityHealth(EntityID);
    local SetHealth = math.floor((MaxHealth * (_Percentage / 100)) + 0.5);

    Logic.HealEntity(EntityID, MaxHealth - Health);
    Logic.HurtEntity(EntityID, MaxHealth - SetHealth);
end

---
-- Verwundet ein Entity um den angegebenen Wert. Wird die ID des
-- Angreifers übergeben, werden die entsprechenden Callbacks für
-- Kampfhandlungen ausgelöst.
--
-- @param _EntityID       ID des Opfers
-- @param _AmountOfDamage Menge an Schaden
-- @param _AttackerID     (optional) ID des Angreifers
-- @within Private
-- @local
--
function BundleEntityHealth.Global:HurtEntityEx(_EntityID, _AmountOfDamage, _AttackerID)
    if IsExisting(_EntityID)then
        local leader = 0
        if Logic.IsEntityInCategory(_EntityID,EntityCategories.Soldier) == 1 then
            leader = Logic.SoldierGetLeaderEntityID(_EntityID)
        end
        if Logic.IsEntityInCategory(_EntityID, EntityCategories.Leader) == 1 then
            leader = _EntityID
        end

        if leader ~= nil and leader ~= 0 then
            local soldiers = {Logic.GetSoldiersAttachedToLeader(leader)}
            if soldiers[1] == nil then soldiers[1] = 0 end

            if soldiers[1] > 0 then
                local victim = 0
                local lowestHealth = 1000
                for i=1,#soldiers do
                    local currentHealth = Logic.GetEntityHealth(soldiers[i])
                    if currentHealth < lowestHealth and currentHealth > 0 then
                        lowestHealth = currentHealth
                        victim = soldiers[i]
                    end
                end

                local damageVictim = soldiers[#soldiers]
                if victim ~= nil and victim ~= 0 then
                    damageVictim = victim
                end

                local hpEntity = 0
                local overkill = _AmountOfDamage
                if IsExisting(damageVictim)then
                    hpEntity = Logic.GetEntityHealth(damageVictim)
                    overkill = _AmountOfDamage - hpEntity
                    if hpEntity <= _AmountOfDamage then
                        if _AttackerID and hpEntity > 0 then
                            GameCallback_EntityKilled(_EntityID,
                                                      Logic.EntityGetPlayer(_EntityID),
                                                      _AttackerID,
                                                      Logic.EntityGetPlayer(_AttackerID),
                                                      Logic.GetEntityType(_EntityID),
                                                      Logic.GetEntityType(_AttackerID));

                            local x,y,z = Logic.EntityGetPos(_EntityID)
                            Logic.ExecuteInLuaLocalState("GameCallback_Feedback_EntityKilled("..
                                                         "".._EntityID..","..
                                                         ""..Logic.EntityGetPlayer(_EntityID)..","..
                                                         "".._AttackerID..","..
                                                         ""..Logic.EntityGetPlayer(_AttackerID)..","..
                                                         ""..Logic.GetEntityType(_EntityID)..","..
                                                         ""..Logic.GetEntityType(_AttackerID)..","..
                                                         ""..x..","..y..")")
                        end
                        Logic.HurtEntity(damageVictim,hpEntity)
                    else
                        Logic.HurtEntity(damageVictim,_AmountOfDamage)
                    end
                end
                if overkill > 0 then
                    HurtEntityEx(leader,overkill,_AttackerID)
                end
            end
        else
            local hpEntity = Logic.GetEntityHealth(_EntityID)
            if hpEntity <= _AmountOfDamage then
                if _AttackerID and hpEntity > 0 then
                    GameCallback_EntityKilled(_EntityID,
                                              Logic.EntityGetPlayer(_EntityID),
                                              _AttackerID,
                                              Logic.EntityGetPlayer(_AttackerID),
                                              Logic.GetEntityType(_EntityID),
                                              Logic.GetEntityType(_AttackerID))

                    local x,y,z = Logic.EntityGetPos(_EntityID)
                    Logic.ExecuteInLuaLocalState("GameCallback_Feedback_EntityKilled("..
                                                 "".._EntityID..","..
                                                 ""..Logic.EntityGetPlayer(_EntityID)..","..
                                                 "".._AttackerID..","..
                                                 ""..Logic.EntityGetPlayer(_AttackerID)..","..
                                                 ""..Logic.GetEntityType(_EntityID)..","..
                                                 ""..Logic.GetEntityType(_AttackerID)..","..
                                                 ""..x..","..y..")")
                end
                Logic.HurtEntity(_EntityID,hpEntity)
            else
                Logic.HurtEntity(_EntityID,_AmountOfDamage)
            end
        end
    end
end

---
-- Fügt eine Funktion hinzu, die ausgeführt wird, wenn ein Entity ein anderes
-- verwundet. Dabei wird EntityID des Angreifers und des Verteidigers an die
-- Funktion übergeben.
--
-- @param _Function Funktion, die ausgeführt wird
-- @within Private
-- @local
--
function BundleEntityHealth.Global.AddOnEntityHurtAction(_Function)
    table.insert(BundleEntityHealth.Global.Data.OnEntityHurtAction, _Function);
end

---
-- Fügt eine Funktion hinzu, die ausgeführt wird, wenn ein Entity zerstört
-- wird. Die EntityID des zerstörten Entity wird übergeben.
--
-- @param _Function Funktion, die ausgeführt wird
-- @within Private
-- @local
--
function BundleEntityHealth.Global.AddOnEntityDestroyedAction(_Function)
    table.insert(BundleEntityHealth.Global.Data.OnEntityDestroyedAction, _Function);
end

---
-- Fügt eine Funktion hinzu, die ausgeführt wird, wenn ein Entity erzeugt
-- wird. Die EntityID des zerstörten Entity wird übergeben.
--
-- @param _Function Funktion, die ausgeführt wird
-- @within Private
-- @local
--
function BundleEntityHealth.Global.AddOnEntityCreatedAction(_Function)
    table.insert(BundleEntityHealth.Global.Data.OnEntityCreatedAction, _Function);
end

---
-- Führt alle registrierten Events aus, wenn ein Entity ein anderes angreift.
--
-- @within Private
-- @local
--
function BundleEntityHealth.Global.EntityHurtEntityController()
    local AttackerIDs = {Event.GetEntityID1()};
    local DefenderIDs = {Event.GetEntityID2()};

    for i=1, #AttackerIDs, 1 do
        for j=1, #DefenderIDs, 1 do
            local Attacker = AttackerIDs[i];
            local Defender = DefenderIDs[j];
            if IsExisting(Attacker) and IsExisting(Defender) then
                for k, v in pairs(BundleEntityHealth.Global.Data.OnEntityHurtAction) do
                    if v then
                        v(Attacker, Defender);
                    end
                end
            end
        end
    end
end

---
-- Führt alle registrierten Events aus, wenn ein Entity zerstört wird.
--
-- @within Private
-- @local
--
function BundleEntityHealth.Global.EntityDestroyedController()
    local EntityIDs = {Event.GetEntityID()};
    
    for i=1, #EntityIDs, 1 do
        local EntityID = EntityIDs[i];
        for k, v in pairs(BundleEntityHealth.Global.Data.OnEntityDestroyedAction) do
            if v then
                v(EntityIDs);
            end
        end
    end
end

---
-- Führt alle registrierten Events aus, wenn ein Entity erzeugt wird.
--
-- @within Private
-- @local
--
function BundleEntityHealth.Global.EntityCreatedController(_EntityID)
    for k, v in pairs(BundleEntityHealth.Global.Data.OnEntityDestroyedAction) do
        if v then
            v(_EntityID);
        end
    end
end

-- Local Script ----------------------------------------------------------------

---
-- Initialisiert das Bundle im lokalen Skript.
-- @within Private
-- @local
--
function BundleEntityHealth.Local:Install()

end

-- Shared Script ---------------------------------------------------------------

---
-- Gibt die Gesundheit des Entity in prozent zurück.
--
-- @param _Entity Entity to change
-- @return number: Health in percent
-- @within Private
-- @local
--
function BundleEntityHealth:GetHealth(_Entity)
    if not IsExisting(_Entity) then
        return 0;
    end
    local EntityID  = GetID(_Entity);
    local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
    local Health    = Logic.GetEntityHealth(EntityID);
    return (Health / MaxHealth) * 100;
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleEntityHealth");

---
-- Ändert die Gesundheit eines Entity.
--
-- @param _Entity     Entity
-- @param _Percentage Prozentwert
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_SetHealth(...)
    return b_Reprisal_SetHealth:new(...);
end

b_Reprisal_SetHealth = {
    Name = "Reprisal_SetHealth",
    Description = {
        en = "Reprisal: Changes the health of an entity.",
        de = "Vergeltung: Setzt die Gesundheit eines Entity.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",     de = "Entity", },
        { ParameterType.Number,     en = "Percentage", de = "Prozentsatz", },
    },
}

function b_Reprisal_SetHealth:GetRewardTable(_Quest)
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_SetHealth:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Percentage = _Parameter;
    end
end

function b_Reprisal_SetHealth:CustomFunction(_Quest)
    SetHealth(self.Entity, self.Percentage);
end

function b_Reprisal_SetHealth:DEBUG(_Quest)
    if not IsExisting(self.Entity) then
        dbg(_Quest.Identifier.. " " ..self.Name.. ": Entity is dead! :(");
        -- return true;
    end
    if self.Percentage < 0 or self.Percentage > 100 then
        dbg(_Quest.Identifier.. " " ..self.Name.. ": Percentage must be between 0 and 100!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_SetHealth);

-- -------------------------------------------------------------------------- --

---
-- Ändert die Gesundheit eines Entity.
--
-- @param _Entity     Entity
-- @param _Percentage Prozentwert
-- @return Table mit Behavior
-- @within Reward
--
function Reward_SetHealth(...)
    return b_Reward_SetHealth:new(...);
end

b_Reward_SetHealth = API.InstanceTable(b_Reprisal_SetHealth);
b_Reward_SetHealth.Name = "Reward_SetHealth";
b_Reward_SetHealth.Description.en = "Reward: Changes the health of an entity.";
b_Reward_SetHealth.Description.de = "Lohn: Setzt die Gesundheit eines Entity.";
b_Reward_SetHealth.GetReprisalTable = nil;

b_Reward_SetHealth.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } }
end

function b_Reward_SetHealth:DEBUG(_Quest)
    if not IsExisting(self.Entity) then
        dbg(_Quest.Identifier.. " " ..self.Name.. ": Entity is dead! :(");
        return true;
    end
    if self.Percentage < 0 or self.Percentage > 100 then
        dbg(_Quest.Identifier.. " " ..self.Name.. ": Percentage must be between 0 and 100!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reward_SetHealth);

-- -------------------------------------------------------------------------- --

---
-- Die Gesundheit eines Entities muss einen bestimmten Wert erreichen.
--
-- @param _Entity Entity, das überwacht wird
-- @param _Amount Menge in Prozent
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_EntityHealth(...)
    return b_Trigger_EntityHealth:new(...);
end

b_Trigger_EntityHealth = {
    Name = "Trigger_EntityHealth",
    Description = {
        en = "Trigger: The health of a unit must reach a certain point.",
        de = "Auslöser: Die Gesundheit eines Entity muss einen bestimmten Wert erreichen.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
        { ParameterType.Custom,     en = "Relation",    de = "Relation" },
        { ParameterType.Number,     en = "Percentage",  de = "Prozentwert" },
    },
}

function b_Trigger_EntityHealth:GetTriggerTable(_Quest)
    return {Triggers.Custom2, {self, self.CustomFunction}};
end

function b_Trigger_EntityHealth:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptName = _Parameter;
    elseif (_Index == 1) then
        self.BeSmalerThan = _Parameter == "<";
    elseif (_Index == 2) then
        self.Percentage = _Parameter;
    end
end

function b_Trigger_EntityHealth:GetCustomData(_Index)
    if _Index == 1 then
        return { "<", ">=" };
    end
end

function b_Trigger_EntityHealth:CustomFunction(_Quest)
    if self.BeSmalerThan then
        return GetHealth(self.ScriptName) < self.Percentage;
    else
        return GetHealth(self.ScriptName) >= self.Percentage;
    end
end

function b_Trigger_EntityHealth:DEBUG(_Quest)
    if not IsExisting(self.ScriptName) then
        dbg(_Quest.Identifier.. " " ..self.Name.. ": Entity is dead! :(");
        return true;
    end
    if self.Percentage < 0 or self.Percentage > 100 then
        dbg(_Quest.Identifier.. " " ..self.Name.. ": Percentage must be between 0 and 100!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_EntityHealth);
