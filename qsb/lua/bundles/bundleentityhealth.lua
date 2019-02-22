-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntityHealth                                           # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle stellt Funktionen bereit, mit denen die Gesundheit von
-- Entities überwacht oder geändert werden kann.
--
-- Das wichtigste Auf einen Blick:
-- <ul>
-- <li>
-- <a href="#API.GetEntityHealth">Gesundheit ermitteln</a>
-- </li>
-- <li>
-- <a href="#API.SetEntityHealth">Gesundheit verändern</a>
-- </li>
-- <li>
-- <a href="#API.SetOnFire">Gebäude in Brand stecken</a>
-- </li>
-- <li>
-- <a href="#API.AddOnEntityCreatedAction">Trigger anlegen</a>
-- </li>
-- </ul>
--
-- @within Modulbeschreibung
-- @set sort=false
--
BundleEntityHealth = {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Gibt die Gesundheit des Entity in prozent zurück.
--
-- Achtung: Nur Siedler (inklusive Millitär und Helden), Belagerungswaffen,
-- Gebäude und Raubtiere haben Gesundheit.
--
-- <p><b>Alias</b>: GetHealth</p>
--
-- @param _Entity Angefragtes Entity (Striptname oder ID)
-- @return[type=number] Gesundheit in Prozent
-- @within Anwenderfunktionen
--
-- @usage
-- local Health = GetHealth("hakim");
--
function API.GetEntityHealth(_Entity)
    return BundleEntityHealth.Shared:GetHealth(_Entity);
end
GetHealth = API.GetEntityHealth;

---
-- Ändert die Gesundheit des Entity zu dem angegeben Wert in Prozent.
--
-- Achtung: Nur Siedler (inklusive Millitär und Helden), Belagerungswaffen,
-- Gebäude und Raubtiere haben Gesundheit.
--
-- <p><b>Alias</b>: SetHealth</p>
--
-- @param              _Entity     Entity dessen Gesundheit geändert wird (Striptname oder ID)
-- @param[type=number] _Percentage Gesundheit in Prozent
-- @within Anwenderfunktionen
--
-- @usage
-- SetHealth("hakim", 50);
--
function API.ChangeEntityHealth(_Entity, _Percentage)
    if GUI then
        local Sublect = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Bridge("API.ChangeEntityHealth(" ..Sublect.. ", " .._Percentage.. ")");
        return;
    end
    if not IsExisting(_Entity) then
        local Sublect = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Fatal("API.ChangeEntityHealth: _Entity " ..Sublect.. " does not exist!");
        return;
    end
    if type(_Percentage) ~= "number" then
        API.Fatal("API.ChangeEntityHealth: _Percentage must be a number!");
        return;
    end

    _Percentage = (_Percentage < 0 and 0) or _Percentage;
    if _Percentage > 100 then
        API.Warn("API.ChangeEntityHealth: _Percentage is larger than 100%. This could cause problems!");
    end
    BundleEntityHealth.Global:SetEntityHealth(_Entity, _Percentage);
end
SetHealth = API.ChangeEntityHealth;

---
-- Steckt ein Gebäude in Brand.
--
-- Achtung: Nur Gebäude können in Brand gesteckt werden.
--
-- <p><b>Alias</b>: SetOnFire</p>
--
-- @param              _Entity   Gebäude (Striptname oder ID)
-- @param[type=number] _Strength Stärke des Brandes
-- @within Anwenderfunktionen
--
-- @usage
-- SetOnFire("headquarters1", 100);
--
function API.SetBuildingOnFire(_Entity, _Strength)
    if GUI then
        local Sublect = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Bridge("API.SetBuildingOnFire(" ..Sublect.. ", " .._Strength.. ")");
        return;
    end
    if not IsExisting(_Entity) then
        local Sublect = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Fatal("API.SetBuildingOnFire: Entity " ..Sublect.. " does not exist!");
        return;
    end
    if Logic.IsBuilding(GetID(_Entity)) == 0 then
        API.Fatal("API.SetBuildingOnFire: Only buildings can be set on fire!");
        return;
    end
    if type(_Strength) ~= "number" then
        API.Fatal("API.SetBuildingOnFire: _Strength must be a number!");
        return;
    end
    _Strength = (_Strength < 0 and 0) or _Strength;
    Logic.DEBUG_SetBuildingOnFire(GetID(_Entity), _Strength);
end
SetOnFire = API.SetBuildingOnFire;


---
-- Verwundet ein Entity oder ein Battalion um den angegebenen Wert. Wird ein
-- Battalion verwundet, werden der Reihe nach alle Soldaten verwundet, bis
-- der gesamte Schaden verrechnet wurde oder alle Sodaten tot sind.
--
-- <p><b>Alias</b>: HurtEntityEx</p>
--
-- @param              _Target         Ziel des Schadens (Striptname oder ID)
-- @param[type=number] _AmountOfDamage Menge an Schaden
-- @param              _Attacker       (Optional) Angreifendes Entity (Striptname oder ID)
-- @within Anwenderfunktionen
--
-- @usage
-- HurtEntityEx("battalion", 250, "hakim");
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
        API.Warn("API.HurtEntity: Entity " .._Target.. " does not exist!");
        return;
    end
    if type(_AmountOfDamage) ~= "number" or _AmountOfDamage < 0 then
        API.Fatal("API.HurtEntity: _AmountOfDamage must be a number greater or equal 0!");
        return;
    end
    local EntityID = GetID(_Target);
    local AttackerID = GetID(_Attacker);
    return BundleEntityHealth.Global:HurtEntityEx(EntityID, _AmountOfDamage, AttackerID);
end
HurtEntityEx = API.HurtEntity;

---
-- Erstellt einen neuen Auslöser für Kampfgeschehen.
--
-- Jede Funktion wird immer dann ausgeführt, wenn ein Entity durch ein anderes
-- verwundet wird.
--
-- <p><b>Alias</b>: AddHurtAction</p>
--
-- @param[type=function] _Function Funktion, die ausgeführt wird.
-- @within Anwenderfunktionen
--
-- @usage
-- API.AddOnEntityHurtAction(SomeFunctionReference);
--
function API.AddOnEntityHurtAction(_Function)
    if GUI then
        API.Fatal("API.AddOnEntityHurtAction: Can not be used in local script!");
        return;
    end
    if type(_Function) ~= "function" then
        API.Fatal("_Function must be a function!");
        return;
    end
    BundleEntityHealth.Global.AddOnEntityHurtAction(_Function);
end
AddHurtAction = API.AddOnEntityHurtAction;

---
-- Erstellt einen neuen Auslöser für zerstörte Entities.
--
-- Jede Funktion wird immer dann ausgeführt, wenn ein Entity durch ein anderes
-- Entity oder durch das Skript zerstört wird.
--
-- <p><b>Alias</b>: AddKilledAction</p>
--
-- @param[type=function] _Function Funktion, die ausgeführt wird.
-- @within Anwenderfunktionen
--
-- @usage
-- API.AddOnEntityCreatedAction(SomeFunctionReference);
--
function API.AddOnEntityDestroyedAction(_Function)
    if GUI then
        API.Fatal("API.AddOnEntityDestroyedAction: Can not be used in local script!");
        return;
    end
    if type(_Function) ~= "function" then
        API.Fatal("_Function must be a function!");
        return;
    end
    BundleEntityHealth.Global.AddOnEntityDestroyedAction(_Function);
end
AddKilledAction = API.AddOnEntityDestroyedAction;

---
-- Fügt eine Funktion hinzu, die ausgeführt wird, wenn ein Entity erzeugt wird.
--
-- <p><b>Alias</b>: AddSpawnedAction</p>
--
-- @param[type=function] _Function Funktion, die ausgeführt wird.
-- @within Anwenderfunktionen
--
-- @usage
-- API.AddOnEntityCreatedAction(SomeFunctionReference);
--
function API.AddOnEntityCreatedAction(_Function)
    if GUI then
        API.Fatal("API.AddOnEntityCreatedAction: Can not be used in local script!");
        return;
    end
    if type(_Function) ~= "function" then
        API.Fatal("_Function must be a function!");
        return;
    end
    BundleEntityHealth.Global.AddOnEntityCreatedAction(_Function);
end
AddSpawnedAction = API.AddOnEntityCreatedAction;

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
    Shared = {
        Data = {}
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Internal
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
-- @param _Entity     Entity to change (Striptname oder ID)
-- @param[type=number] _Percentage Health amount
-- @within Internal
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
-- @param[type=number] _EntityID       ID des Opfers
-- @param[type=number] _AmountOfDamage Menge an Schaden
-- @param[type=number] _AttackerID     (optional) ID des Angreifers
-- @within Internal
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
-- @param[type=function] _Function Funktion, die ausgeführt wird
-- @within Internal
-- @local
--
function BundleEntityHealth.Global.AddOnEntityHurtAction(_Function)
    table.insert(BundleEntityHealth.Global.Data.OnEntityHurtAction, _Function);
end

---
-- Fügt eine Funktion hinzu, die ausgeführt wird, wenn ein Entity zerstört
-- wird. Die EntityID des zerstörten Entity wird übergeben.
--
-- @param[type=function] _Function Funktion, die ausgeführt wird
-- @within Internal
-- @local
--
function BundleEntityHealth.Global.AddOnEntityDestroyedAction(_Function)
    table.insert(BundleEntityHealth.Global.Data.OnEntityDestroyedAction, _Function);
end

---
-- Fügt eine Funktion hinzu, die ausgeführt wird, wenn ein Entity erzeugt
-- wird. Die EntityID des zerstörten Entity wird übergeben.
--
-- @param[type=function] _Function Funktion, die ausgeführt wird
-- @within Internal
-- @local
--
function BundleEntityHealth.Global.AddOnEntityCreatedAction(_Function)
    table.insert(BundleEntityHealth.Global.Data.OnEntityCreatedAction, _Function);
end

---
-- Führt alle registrierten Events aus, wenn ein Entity ein anderes angreift.
--
-- @within Internal
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
-- @within Internal
-- @local
--
function BundleEntityHealth.Global.EntityDestroyedController()
    local EntityIDs = {Event.GetEntityID()};

    for i=1, #EntityIDs, 1 do
        local EntityID = EntityIDs[i];
        for k, v in pairs(BundleEntityHealth.Global.Data.OnEntityDestroyedAction) do
            if v then
                v(EntityID);
            end
        end
    end
end

---
-- Führt alle registrierten Events aus, wenn ein Entity erzeugt wird.
--
-- @param[type=number] _EntityID ID des Entity
-- @within Internal
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
-- @within Internal
-- @local
--
function BundleEntityHealth.Local:Install()

end

-- Shared Script ---------------------------------------------------------------

---
-- Gibt die Gesundheit des Entity in prozent zurück.
--
-- @param _Entity Entity to change (Striptname oder ID)
-- @return[type=number] Health in percent
-- @within Internal
-- @local
--
function BundleEntityHealth.Shared:GetHealth(_Entity)
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
-- @param[type=string] _Entity     Entity
-- @param[type=number] _Percentage Prozentwert
--
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
        self.Percentage = _Parameter * 1;
    end
end

function b_Reprisal_SetHealth:CustomFunction(_Quest)
    SetHealth(self.Entity, self.Percentage);
end

function b_Reprisal_SetHealth:DEBUG(_Quest)
    if not IsExisting(self.Entity) then
        warn(_Quest.Identifier.. " " ..self.Name.. ": Entity is dead! :(");
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
-- @param[type=string] _Entity     Entity
-- @param[type=number] _Percentage Prozentwert
--
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
-- @param[type=string] _Entity Entity, das überwacht wird
-- @param[type=number] _Amount Menge in Prozent
--
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

