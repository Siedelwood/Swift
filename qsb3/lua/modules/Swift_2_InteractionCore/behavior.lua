-- Interaction Behavior ----------------------------------------------------- --

---
-- Stellt neue Behavior für NPO und NPC bereit.
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Der Spieler muss bis zu 4 interaktive Objekte benutzen.
--
-- @param[type=string] _ScriptName1 Erstes Objekt
-- @param[type=string] _ScriptName2 (optional) Zweites Objekt
-- @param[type=string] _ScriptName3 (optional) Drittes Objekt
-- @param[type=string] _ScriptName4 (optional) Viertes Objekt
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

-- API.CreateObject muss zur Initialisierung verwendet werden
b_Reward_ObjectInit.CustomFunction = function(self, _Quest)
    local Data = {
        Name        = self.ScriptName,
        State       = self.UsingState,
        Distance    = self.Distance,
        Waittime    = self.Waittime,
    };

    local Reward = {};
    if self.RewardType and self.RewardType ~= "-" then
        table.insert(Costs, Goods[self.RewardType]);
        table.insert(Costs, self.RewardAmount);
    end
    if #Reward > 0 then
        Data.Reward = Reward;
    end

    local Costs = {};
    if self.FirstCostType and self.FirstCostType ~= "-" then
        table.insert(Costs, Goods[self.FirstCostType]);
        table.insert(Costs, self.FirstCostAmount);
    end
    if self.SecondCostType and self.SecondCostType ~= "-" then
        table.insert(Costs, Goods[self.SecondCostType]);
        table.insert(Costs, self.SecondCostAmount);
    end
    if #Costs > 0 then
        Data.Costs = Costs;
    end

    API.CreateObject(Data);
end

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

function b_Goal_NPC:GetGoalTable(_Quest)
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

