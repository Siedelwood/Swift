-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleSymfoniaBehaviors                                      # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle enthält einige weitere nützliche Standard-Behavior.
--
-- @module BundleSymfoniaBehaviors
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User Space                                                                 --
-- -------------------------------------------------------------------------- --



-- -------------------------------------------------------------------------- --
-- Goals                                                                      --
-- -------------------------------------------------------------------------- --

---
-- Ein Entity muss sich zu einem Ziel bewegen und eine Distanz unterschreiten.
--
-- Optional kann das Ziel mit einem Marker markiert werden.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Target     Skriptname des Ziels
-- @param _Distance   Entfernung
-- @param _UseMarker  Ziel markieren
-- @return Table mit Behavior
-- @within Goal
--
function Goal_MoveToPosition(...)
    return b_Goal_MoveToPosition:new(...);
end

b_Goal_MoveToPosition = {
    Name = "Goal_MoveToPosition",
    Description = {
        en = "Goal: A entity have to moved as close as the distance to another entity. The target can be marked with a static marker.",
        de = "Ziel: Eine Entity muss sich einer anderen bis auf eine bestimmte Distanz nähern. Die Lupe wird angezeigt, das Ziel kann markiert werden.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",      de = "Entity" },
        { ParameterType.ScriptName, en = "Target",      de = "Ziel" },
        { ParameterType.Number,     en = "Distance", de = "Entfernung" },
        { ParameterType.Custom,     en = "Marker",      de = "Ziel markieren" },
    },
}

function b_Goal_MoveToPosition:GetGoalTable(__quest_)
    return {Objective.Distance, self.Entity, self.Target, self.Distance, self.Marker}
end

function b_Goal_MoveToPosition:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Entity = __parameter_
    elseif (__index_ == 1) then
        self.Target = __parameter_
    elseif (__index_ == 2) then
        self.Distance = __parameter_ * 1
    elseif (__index_ == 3) then
        self.Marker = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Goal_MoveToPosition:GetCustomData( __index_ )
    local Data = {};
    if __index_ == 3 then
        Data = {"true", "false"}
    end
    return Data
end

Core:RegisterBehavior(b_Goal_MoveToPosition);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss einen bestimmten Quest abschließen.
--
-- @param _QuestName Name des Quest
-- @return Table mit Behavior
-- @within Goal
--
function Goal_WinQuest(...)
    return b_Goal_WinQuest:new(...);
end

b_Goal_WinQuest = {
    Name = "Goal_WinQuest",
    Description = {
        en = "Goal: The player has to win a given quest",
        de = "Ziel: Der Spieler muss eine angegebene Quest erfolgreich abschliessen.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest Name",      de = "Questname" },
    },
}

function b_Goal_WinQuest:GetGoalTable(__quest_)
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_WinQuest:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Quest = __parameter_;
    end
end

function b_Goal_WinQuest:CustomFunction(__quest_)
    local quest = Quests[GetQuestID(self.Quest)];
    if quest then
        if quest.Result == QuestResult.Failure then
            return false;
        end
        if quest.Result == QuestResult.Success then
            return true;
        end
    end
    return nil;
end

function b_Goal_WinQuest:DEBUG(__quest_)
    if Quests[GetQuestID(self.Quest)] == nil then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": Quest '"..self.Quest.."' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Goal_WinQuest);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss eine bestimmte Menge Gold mit Dieben stehlen.
--
-- Dabei ist es egal von welchem Spieler. Diebe können Gold nur aus
-- Stadtgebäude stehlen.
--
-- @param _Amount       Menge an Gold
-- @param _ShowProgress Fortschritt ausgeben
-- @return Table mit Behavior
-- @within Goal
--
function Goal_StealGold(...)
    return b_Goal_StealGold:new(...)
end

b_Goal_StealGold = {
    Name = "Goal_StealGold",
    Description = {
        en = "Goal: Steal an explicit amount of gold from a players or any players city buildings.",
        de = "Ziel: Diebe sollen eine bestimmte Menge Gold aus feindlichen Stadtgebäuden stehlen.",
    },
    Parameter = {
        { ParameterType.Number, en = "Amount on Gold", de = "Zu stehlende Menge" },
        { ParameterType.Custom, en = "Print progress", de = "Fortschritt ausgeben" },
    },
}

function b_Goal_StealGold:GetGoalTable(__quest_)
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_StealGold:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Amount = __parameter_ * 1;
    elseif (__index_ == 1) then
        __parameter_ = __parameter_ or "true"
        self.Printout = AcceptAlternativeBoolean(__parameter_);
    end
    self.StohlenGold = 0;
end

function b_Goal_StealGold:GetCustomData(__index_)
    if __index_ == 1 then
        return { "true", "false" };
    end
end

function b_Goal_StealGold:SetDescriptionOverwrite(__quest_)
    local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    local amount = self.Amount-self.StohlenGold;
    amount = (amount > 0 and amount) or 0;
    local text = {
        de = "Gold stehlen {cr}{cr}Aus Stadtgebäuden zu stehlende Goldmenge: ",
        en = "Steal gold {cr}{cr}Amount on gold to steal from city buildings: ",
    };
    return "{center}" .. text[lang] .. amount
end

function b_Goal_StealGold:CustomFunction(__quest_)
    Core:ChangeCustomQuestCaptionText(__quest_.Identifier, self:SetDescriptionOverwrite(__quest_));

    if self.StohlenGold >= self.Amount then
        return true;
    end
    return nil;
end

function b_Goal_StealGold:GetIcon()
    return {5,13};
end

function b_Goal_StealGold:DEBUG(__quest_)
    if tonumber(self.Amount) == nil and self.Amount < 0 then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": amount can not be negative!");
        return true;
    end
    return false;
end

function b_Goal_StealGold:Reset()
    self.StohlenGold = 0;
end

Core:RegisterBehavior(b_Goal_StealGold)

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss ein bestimmtes Stadtgebäude bestehlen.
--
-- Eine Kirche wird immer Sabotiert. Ein Lagerhaus verhält sich ähnlich zu
-- einer Burg.
--
-- @param _ScriptName Skriptname des Gebäudes
-- @return Table mit Behavior
-- @within Goal
--
function Goal_StealBuilding(...)
    return b_Goal_StealBuilding:new(...)
end

b_Goal_StealBuilding = {
    Name = "Goal_StealBuilding",
    Description = {
        en = "Goal: The player has to steal from a building. Not a castle and not a village storehouse!",
        de = "Ziel: Der Spieler muss ein bestimmtes Gebäude bestehlen. Dies darf keine Burg und kein Dorflagerhaus sein!",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Building", de = "Gebäude" },
    },
}

function b_Goal_StealBuilding:GetGoalTable(__quest_)
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_StealBuilding:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Building = __parameter_
    end
    self.RobberList = {};
end

function b_Goal_StealBuilding:GetCustomData(__index_)
    if __index_ == 1 then
        return { "true", "false" };
    end
end

function b_Goal_StealBuilding:SetDescriptionOverwrite(__quest_)
    local isCathedral = Logic.IsEntityInCategory(GetID(self.Building), EntityCategories.Cathedrals) == 1;
    local isWarehouse = Logic.GetEntityType(GetID(self.Building)) == Entities.B_StoreHouse;
    local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    local text;

    if isCathedral then
        text = {
            de = "Sabotage {cr}{cr} Sabotiert die mit Pfeil markierte Kirche.",
            en = "Sabotage {cr}{cr} Sabotage the Church of the opponent.",
        };
    elseif isWarehouse then
        text = {
            de = "Lagerhaus bestehlen {cr}{cr} Sendet einen Dieb in das markierte Lagerhaus.",
            en = "Steal from storehouse {cr}{cr} Steal from the marked storehouse.",
        };
    else
        text = {
            de = "Geb�ude bestehlen {cr}{cr} Bestehlt das durch einen Pfeil markierte Gebäude.",
            en = "Steal from building {cr}{cr} Steal from the building marked by an arrow.",
        };
    end
    return "{center}" .. text[lang];
end

function b_Goal_StealBuilding:CustomFunction(__quest_)
    if not IsExisting(self.Building) then
        if self.Marker then
            Logic.DestroyEffect(self.Marker);
        end
        return false;
    end

    if not self.Marker then
        local pos = GetPosition(self.Building);
        self.Marker = Logic.CreateEffect(EGL_Effects.E_Questmarker, pos.X, pos.Y, 0);
    end

    if self.SuccessfullyStohlen then
        Logic.DestroyEffect(self.Marker);
        return true;
    end
    return nil;
end

function b_Goal_StealBuilding:GetIcon()
    return {5,13};
end

function b_Goal_StealBuilding:DEBUG(__quest_)
    local eTypeName = Logic.GetEntityTypeName(Logic.GetEntityType(GetID(self.Building)));
    local IsHeadquarter = Logic.IsEntityInCategory(GetID(self.Building), EntityCategories.Headquarters) == 1;
    if Logic.IsBuilding(GetID(self.Building)) == 0 then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": target is not a building");
        return true;
    elseif not IsExisting(self.Building) then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": target is destroyed :(");
        return true;
    elseif string.find(eTypeName, "B_NPC_BanditsHQ") or string.find(eTypeName, "B_NPC_Cloister") or string.find(eTypeName, "B_NPC_StoreHouse") then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": village storehouses are not allowed!");
        return true;
    elseif IsHeadquarter then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": use Goal_StealInformation for headquarters!");
        return true;
    end
    return false;
end

function b_Goal_StealBuilding:Reset()
    self.SuccessfullyStohlen = false;
    self.RobberList = {};
    self.Marker = nil;
end

function b_Goal_StealBuilding:Interrupt(__quest_)
    Logic.DestroyEffect(self.Marker);
end

Core:RegisterBehavior(b_Goal_StealBuilding)

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss einen Dieb in ein Gebäude hineinschicken.
--
-- Der Quest ist erfolgreich, sobald der Dieb in das Gebäude eindringt. Es
-- muss sich um ein Gebäude handeln, das bestohlen werden kann (Burg, Lager,
-- Kirche, Stadtgebäude mit Einnahmen)!
--
-- Optional kann der Dieb nach Abschluss gelöscht werden. Diese Option macht
-- es einfacher ihn durch z.B. einen Abfahrenden U_ThiefCart zu ersetzen.
--
-- @param _ScriptName  Skriptname des Gebäudes
-- @param _DeleteThief Dieb nach Abschluss löschen
-- @return Table mit Behavior
-- @within Goal
--
function Goal_Infiltrate(...)
    return b_Goal_Infiltrate:new(...)
end

b_Goal_Infiltrate = {
    Name = "Goal_Infiltrate",
    IconOverwrite = {5,13},
    Description = {
        en = "Goal: Infiltrate a building with a thief. A thief must be able to steal from the target building.",
        de = "Ziel: Infiltriere ein Gebäude mit einem Dieb. Nur mit Gebaueden moeglich, die bestohlen werden koennen.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Target Building", de = "Zielgebäude" },
        { ParameterType.Custom,     en = "Destroy Thief", de = "Dieb löschen" },
    },
}

function b_Goal_Infiltrate:GetGoalTable(__quest_)
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_Infiltrate:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Building = __parameter_
    elseif (__index_ == 1) then
        __parameter_ = __parameter_ or "true"
        self.Delete = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Goal_Infiltrate:GetCustomData(__index_)
    if __index_ == 1 then
        return { "true", "false" };
    end
end

function b_Goal_Infiltrate:SetDescriptionOverwrite(__quest_)
    if not __quest_.QuestDescription then
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        local text = {
            de = "Gebäude infriltrieren {cr}{cr}Spioniere das markierte Gebäude mit einem Dieb aus!",
            en = "Infiltrate building {cr}{cr}Spy on the highlighted buildings with a thief!",
        };
        return text[lang];
    else
        return __quest_.QuestDescription;
    end
end

function b_Goal_Infiltrate:CustomFunction(__quest_)
    if not IsExisting(self.Building) then
        if self.Marker then
            Logic.DestroyEffect(self.Marker);
        end
        return false;
    end

    if not self.Marker then
        local pos = GetPosition(self.Building);
        self.Marker = Logic.CreateEffect(EGL_Effects.E_Questmarker, pos.X, pos.Y, 0);
    end

    if self.Infiltrated then
        Logic.DestroyEffect(self.Marker);
        return true;
    end
    return nil;
end

function b_Goal_Infiltrate:GetIcon()
    return self.IconOverwrite;
end

function b_Goal_Infiltrate:DEBUG(__quest_)
    if Logic.IsBuilding(GetID(self.Building)) == 0 then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": target is not a building");
        return true;
    elseif not IsExisting(self.Building) then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": target is destroyed :(");
        return true;
    end
    return false;
end

function b_Goal_Infiltrate:Reset()
    self.Infiltrated = false;
    self.Marker = nil;
end

function b_Goal_Infiltrate:Interrupt(__quest_)
    Logic.DestroyEffect(self.Marker);
end

Core:RegisterBehavior(b_Goal_Infiltrate);

-- -------------------------------------------------------------------------- --

---
-- Es muss eine Menge an Munition in der Kriegsmaschine erreicht werden.
-- 
-- <u>Relationen</u>
-- <ul>
-- <li>>= - Anzahl als Mindestmenge</li>
-- <li>< - Weniger als Anzahl</li>
-- </ul>
--
-- @param _ScriptName  Name des Kriegsgerät
-- @param _Relation    Mengenrelation
-- @param _Amount      Menge an Munition
-- @return Table mit Behavior
-- @within Goal
--
function Goal_AmmunitionAmount(...)
    return b_Goal_AmmunitionAmount:new(...);
end

b_Goal_AmmunitionAmount = {
    Name = "Goal_AmmunitionAmount",
    Description = {
        en = "Goal: Reach a smaller or bigger value than the given amount of ammunition in a war machine.",
        de = "Ziel: Ueber- oder unterschreite die angegebene Anzahl Munition in einem Kriegsgerät.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
        { ParameterType.Custom, en = "Relation", de = "Relation" },
        { ParameterType.Number, en = "Amount", de = "Menge" },
    },
}

function b_Goal_AmmunitionAmount:GetGoalTable()
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_AmmunitionAmount:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Scriptname = _Parameter
    elseif (_Index == 1) then
        self.bRelSmallerThan = tostring(_Parameter) == "true" or _Parameter == "<"
    elseif (_Index == 2) then
        self.Amount = _Parameter * 1
    end
end

function b_Goal_AmmunitionAmount:CustomFunction()
    local EntityID = GetID(self.Scriptname);
    if not IsExisting(EntityID) then
        return false;
    end
    local HaveAmount = Logic.GetAmmunitionAmount(EntityID);
    if ( self.bRelSmallerThan and HaveAmount < self.Amount ) or ( not self.bRelSmallerThan and HaveAmount >= self.Amount ) then
        return true;
    end
    return nil;
end

function b_Goal_AmmunitionAmount:DEBUG(_Quest)
    if self.Amount < 0 then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": Amount is negative");
        return true
    end
end

function b_Goal_AmmunitionAmount:GetCustomData( _Index )
    if _Index == 1 then
        return {"<", ">="};
    end
end

Core:RegisterBehavior(b_Goal_AmmunitionAmount)

-- -------------------------------------------------------------------------- --
-- Reprisals                                                                  --
-- -------------------------------------------------------------------------- --

---
-- Ändert die Position eines Siedlers oder eines Gebäudes.
--
-- Optional kann das Entity in einem bestimmten Abstand zum Ziel platziert
-- werden und das Ziel anschauen. Die Entfernung darf nicht kleiner sein
-- als 50!
--
-- @param _ScriptName Skriptname des Entity
-- @param _Target     Skriptname des Ziels
-- @param _LookAt     Gegenüberstellen
-- @param _Distance   Relative Entfernung (nur mit _LookAt)
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_SetPosition(...)
    return b_Reprisal_SetPosition:new(...);
end

b_Reprisal_SetPosition = {
    Name = "Reprisal_SetPosition",
    Description = {
        en = "Reprisal: Places an entity relative to the position of another. The entity can look the target.",
        de = "Vergeltung: Setzt eine Entity relativ zur Position einer anderen. Die Entity kann zum Ziel ausgerichtet werden.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",             de = "Entity", },
        { ParameterType.ScriptName, en = "Target position", de = "Zielposition", },
        { ParameterType.Custom,     en = "Face to face",     de = "Ziel ansehen", },
        { ParameterType.Number,     en = "Distance",         de = "Zielentfernung", },
    },
}

function b_Reprisal_SetPosition:GetReprisalTable(__quest_)
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_SetPosition:AddParameter( __index_, __parameter_ )
    if (__index_ == 0) then
        self.Entity = __parameter_;
    elseif (__index_ == 1) then
        self.Target = __parameter_;
    elseif (__index_ == 2) then
        self.FaceToFace = AcceptAlternativeBoolean(__parameter_)
    elseif (__index_ == 3) then
        self.Distance = (__parameter_ ~= nil and tonumber(__parameter_)) or 100;
    end
end

function b_Reprisal_SetPosition:CustomFunction(__quest_)
    if not IsExisting(self.Entity) or not IsExisting(self.Target) then
        return;
    end

    local entity = GetID(self.Entity);
    local target = GetID(self.Target);
    local x,y,z = Logic.EntityGetPos(target);
    if Logic.IsBuilding(target) == 1 then
        x,y = Logic.GetBuildingApproachPosition(target);
    end
    local ori = Logic.GetEntityOrientation(target)+90;

    if self.FaceToFace then
        x = x + self.Distance * math.cos( math.rad(ori) );
        y = y + self.Distance * math.sin( math.rad(ori) );
        Logic.DEBUG_SetSettlerPosition(entity, x, y);
        LookAt(self.Entity, self.Target);
    else
        if Logic.IsBuilding(target) == 1 then
            x,y = Logic.GetBuildingApproachPosition(target);
        end
        Logic.DEBUG_SetSettlerPosition(entity, x, y);
    end
end

function b_Reprisal_SetPosition:GetCustomData(__index_)
    if __index_ == 3 then
        return { "true", "false" }
    end
end

function b_Reprisal_SetPosition:DEBUG(__quest_)
    if self.FaceToFace then
        if tonumber(self.Distance) == nil or self.Distance < 50 then
            dbg(__quest_.Identifier.. " " ..self.Name.. ": Distance is nil or to short!");
            return true;
        end
    end
    if not IsExisting(self.Entity) or not IsExisting(self.Target) then
        dbg(__quest_.Identifier.. " " ..self.Name.. ": Mover entity or target entity does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_SetPosition);

-- -------------------------------------------------------------------------- --

---
-- Ändert den Eigentümer des Entity oder des Battalions.
-- 
-- @param _ScriptName Skriptname des Entity
-- @param _NewOwner   PlayerID des Eigentümers
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_ChangePlayer(...)
    return b_Reprisal_ChangePlayer:new(...)
end

b_Reprisal_ChangePlayer = {
    Name = "Reprisal_ChangePlayer",
    Description = {
        en = "Reprisal: Changes the owner of the entity or a battalion.",
        de = "Vergeltung: Aendert den Besitzer einer Entity oder eines Battalions.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",     de = "Entity", },
        { ParameterType.Custom,     en = "Player",     de = "Spieler", },
    },
}

function b_Reprisal_ChangePlayer:GetReprisalTable(__quest_)
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_ChangePlayer:AddParameter( __index_, __parameter_ )
    if (__index_ == 0) then
        self.Entity = __parameter_;
    elseif (__index_ == 1) then
        self.Player = tostring(__parameter_);
    end
end

function b_Reprisal_ChangePlayer:CustomFunction(__quest_)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    if Logic.IsLeader(eID) == 1 then
        -- local SoldiersAmount = Logic.LeaderGetNumberOfSoldiers(eID);
        -- local SoldiersType = Logic.LeaderGetNumberOfSoldiers(eID);
        -- local Orientation = Logic.GetEntityOrientation(eID);
        -- local EntityName = Logic.GetEntityName(eID);
        -- local x,y,z = Logic.EntityGetPos(eID);
        -- local NewID = Logic.CreateBattalionOnUnblockedLand(SoldiersType, x, y, Orientation, self.Player, SoldiersAmount );
        -- Logic.SetEntityName(NewID, EntityName);
        -- DestroyEntity(eID);
        Logic.ChangeSettlerPlayerID(eID, self.Player);
    else
        Logic.ChangeEntityPlayerID(eID, self.Player);
    end
end

function b_Reprisal_ChangePlayer:GetCustomData(__index_)
    if __index_ == 1 then
        return {"0", "1", "2", "3", "4", "5", "6", "7", "8"}
    end
end

function b_Reprisal_ChangePlayer:DEBUG(__quest_)
    if not IsExisting(self.Entity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_ChangePlayer);

-- -------------------------------------------------------------------------- --

---
-- Ändert die Sichtbarkeit eines Entity.
-- 
-- @param _ScriptName Skriptname des Entity
-- @param _Visible    Sichtbarkeit an/aus
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_SetVisible(...)
    return b_Reprisal_SetVisible:new(...)
end

b_Reprisal_SetVisible = {
    Name = "Reprisal_SetVisible",
    Description = {
        en = "Reprisal: Changes the visibility of an entity. If the entity is a spawner the spawned entities will be affected.",
        de = "Strafe: Setzt die Sichtbarkeit einer Entity. Handelt es sich um einen Spawner werden auch die gespawnten Entities beeinflusst.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",     de = "Entity", },
        { ParameterType.Custom,     en = "Visible",     de = "Sichtbar", },
    },
}

function b_Reprisal_SetVisible:GetReprisalTable(__quest_)
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_SetVisible:AddParameter( __index_, __parameter_ )
    if (__index_ == 0) then
        self.Entity = __parameter_;
    elseif (__index_ == 1) then
        self.Visible = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Reprisal_SetVisible:CustomFunction(__quest_)
    if not IsExisting(self.Entity) then
        return;
    end

    local eID = GetID(self.Entity);
    local pID = Logic.EntityGetPlayer(eID);
    local eType = Logic.GetEntityType(eID);
    local tName = Logic.GetEntityTypeName(eType);

    if string.find(tName, "S_") or string.find(tName, "B_NPC_Bandits")
    or string.find(tName, "B_NPC_Barracks") then
        local spawned = {Logic.GetSpawnedEntities(eID)};
        for i=1, #spawned do
            if Logic.IsLeader(spawned[i]) == 1 then
                local soldiers = {Logic.GetSoldiersAttachedToLeader(spawned[i])};
                for j=2, #soldiers do
                    Logic.SetVisible(soldiers[j], self.Visible);
                end
            else
                Logic.SetVisible(spawned[i], self.Visible);
            end
        end
    else
        if Logic.IsLeader(eID) == 1 then
            local soldiers = {Logic.GetSoldiersAttachedToLeader(eID)};
            for j=2, #soldiers do
                Logic.SetVisible(soldiers[j], self.Visible);
            end
        else
            Logic.SetVisible(eID, self.Visible);
        end
    end
end

function b_Reprisal_SetVisible:GetCustomData(__index_)
    if __index_ == 1 then
        return { "true", "false" }
    end
end

function b_Reprisal_SetVisible:DEBUG(__quest_)
    if not IsExisting(self.Entity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_SetVisible);

-- -------------------------------------------------------------------------- --

---
-- Macht das Entity verwundbar oder unverwundbar.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Vulnerable Verwundbarkeit an/aus
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_SetVulnerability(...)
    return b_Reprisal_SetVulnerability:new(...);
end

b_Reprisal_SetVulnerability = {
    Name = "Reprisal_SetVulnerability",
    Description = {
        en = "Reprisal: Changes the vulnerability of the entity. If the entity is a spawner the spawned entities will be affected.",
        de = "Vergeltung: Macht eine Entity verwundbar oder unverwundbar. Handelt es sich um einen Spawner, sind die gespawnten Entities betroffen",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",              de = "Entity", },
        { ParameterType.Custom,     en = "Vulnerability",      de = "Verwundbar", },
    },
}

function b_Reprisal_SetVulnerability:GetReprisalTable(__quest_)
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_SetVulnerability:AddParameter( __index_, __parameter_ )
    if (__index_ == 0) then
        self.Entity = __parameter_;
    elseif (__index_ == 1) then
        self.Vulnerability = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Reprisal_SetVulnerability:CustomFunction(__quest_)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    local eType = Logic.GetEntityType(eID);
    local tName = Logic.GetEntityTypeName(eType);
    if self.Vulnerability then
        if string.find(tName, "S_") or string.find(tName, "B_NPC_Bandits")
        or string.find(tName, "B_NPC_Barracks") then
            local spawned = {Logic.GetSpawnedEntities(eID)};
            for i=1, #spawned do
                if Logic.IsLeader(spawned[i]) == 1 then
                    local Soldiers = {Logic.GetSoldiersAttachedToLeader(spawned[i])};
                    for j=2, #Soldiers do
                        MakeVulnerable(Soldiers[j]);
                    end
                end
                MakeVulnerable(spawned[i]);
            end
        else
            MakeVulnerable(self.Entity);
        end
    else
        if string.find(tName, "S_") or string.find(tName, "B_NPC_Bandits")
        or string.find(tName, "B_NPC_Barracks") then
            local spawned = {Logic.GetSpawnedEntities(eID)};
            for i=1, #spawned do
                if Logic.IsLeader(spawned[i]) == 1 then
                    local Soldiers = {Logic.GetSoldiersAttachedToLeader(spawned[i])};
                    for j=2, #Soldiers do
                        MakeInvulnerable(Soldiers[j]);
                    end
                end
                MakeInvulnerable(spawned[i]);
            end
        else
            MakeInvulnerable(self.Entity);
        end
    end
end

function b_Reprisal_SetVulnerability:GetCustomData(__index_)
    if __index_ == 1 then
        return { "true", "false" }
    end
end

function b_Reprisal_SetVulnerability:DEBUG(__quest_)
    if not IsExisting(self.Entity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_SetVulnerability);

-- -------------------------------------------------------------------------- --

---
-- Ändert das Model eines Entity.
--
-- In Verbindung mit Reward_SetVisible oder Reprisal_SetVisible können
-- Script Entites ein neues Model erhalten und sichtbar gemacht werden.
-- Das hat den Vorteil, das Script Entities nicht überbaut werden können.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Model      Neues Model
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_SetModel(...)
    return b_Reprisal_SetModel:new(...);
end

b_Reprisal_SetModel = {
    Name = "Reprisal_SetModel",
    Description = {
        en = "Reward: Changes the model of the entity. Be careful, some models crash the game.",
        de = "Lohn: Aendert das Model einer Entity. Achtung: Einige Modelle fuehren zum Absturz.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",     de = "Entity", },
        { ParameterType.Custom,     en = "Model",     de = "Model", },
    },
}

function b_Reprisal_SetModel:GetRewardTable(__quest_)
    return { Reward.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_SetModel:AddParameter( __index_, __parameter_ )
    if (__index_ == 0) then
        self.Entity = __parameter_;
    elseif (__index_ == 1) then
        self.Model = __parameter_;
    end
end

function b_Reprisal_SetModel:CustomFunction(__quest_)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    Logic.SetModel(eID, Models[self.Model]);
end

function b_Reprisal_SetModel:GetCustomData(__index_)
    if __index_ == 1 then
        local Data = {};
        for k,v in pairs(Models) do
            if  not string.find(k,"Animals_") and not string.find(k,"Banners_") and not string.find(k,"Goods_") and not string.find(k,"goods_")
            and not string.find(k,"Heads_") and not string.find(k,"MissionMap_") and not string.find(k,"R_Fish") and not string.find(k,"Units_")
            and not string.find(k,"XD_") and not string.find(k,"XS_") and not string.find(k,"XT_") and not string.find(k,"Z_") then
                table.insert(Data,k);
            end
        end
        return Data;
    end
end

function b_Reprisal_SetModel:DEBUG(__quest_)
    if not IsExisting(self.Entity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_SetModel);

-- -------------------------------------------------------------------------- --
-- Rewards                                                                    --
-- -------------------------------------------------------------------------- --

---
-- Ändert die Position eines Siedlers oder eines Gebäudes.
--
-- Optional kann das Entity in einem bestimmten Abstand zum Ziel platziert
-- werden und das Ziel anschauen. Die Entfernung darf nicht kleiner sein
-- als 50!
--
-- @param _ScriptName Skriptname des Entity
-- @param _Target     Skriptname des Ziels
-- @param _LookAt     Gegenüberstellen
-- @param _Distance   Relative Entfernung (nur mit _LookAt)
-- @return Table mit Behavior
-- @within Reward
--
function Reward_SetPosition(...)
    return b_Reward_SetPosition:new(...);
end

b_Reward_SetPosition = API.InstanceTable(b_Reprisal_SetPosition);
b_Reward_SetPosition.Name = "Reward_SetPosition";
b_Reward_SetPosition.Description.en = "Reward: Places an entity relative to the position of another. The entity can look the target.";
b_Reward_SetPosition.Description.de = "Lohn: Setzt eine Entity relativ zur Position einer anderen. Die Entity kann zum Ziel ausgerichtet werden.";
b_Reward_SetPosition.GetReprisalTable = nil;

b_Reward_SetPosition.GetRewardTable = function(self, __quest_)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Core:RegisterBehavior(b_Reward_SetPosition);

-- -------------------------------------------------------------------------- --

---
-- Ändert den Eigentümer des Entity oder des Battalions.
-- 
-- @param _ScriptName Skriptname des Entity
-- @param _NewOwner   PlayerID des Eigentümers
-- @return Table mit Behavior
-- @within Reward
--
function Reprisal_ChangePlayer(...)
    return b_Reprisal_ChangePlayer:new(...)
end

b_Reward_ChangePlayer = API.InstanceTable(b_Reprisal_ChangePlayer);
b_Reward_ChangePlayer.Name = "Reward_ChangePlayer";
b_Reward_ChangePlayer.Description.en = "Reward: Changes the owner of the entity or a battalion.";
b_Reward_ChangePlayer.Description.de = "Lohn: Aendert den Besitzer einer Entity oder eines Battalions.";
b_Reward_ChangePlayer.GetReprisalTable = nil;

b_Reward_ChangePlayer.GetRewardTable = function(self, __quest_)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Core:RegisterBehavior(b_Reward_ChangePlayer);

-- -------------------------------------------------------------------------- --

---
-- Bewegt einen Siedler relativ zu einem Zielpunkt.
--
-- Der Siedler wird sich zum Ziel ausrichten und in der angegeben Distanz
-- und dem angegebenen Winkel Position beziehen.
--
-- <b>Hinweis:</b> Funktioniert ähnlich wie MoveEntityToPositionToAnotherOne.
--
-- @param _ScriptName  Skriptname des Entity
-- @param _Destination Skriptname des Ziels
-- @param _Distance    Entfernung
-- @param _Angle       Winkel
-- @return Table mit Behavior
-- @within Reward
--
function Reward_MoveToPosition(...)
    return b_Reward_MoveToPosition:new(...);
end

b_Reward_MoveToPosition = {
    Name = "Reward_MoveToPosition",
    Description = {
        en = "Reward: Moves an entity relative to another entity. If angle is zero the entities will be standing directly face to face.",
        de = "Lohn: Bewegt eine Entity relativ zur Position einer anderen. Wenn Winkel 0 ist, stehen sich die Entities direkt gegen�ber.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Settler", de = "Siedler" },
        { ParameterType.ScriptName, en = "Destination", de = "Ziel" },
        { ParameterType.Number,     en = "Distance", de = "Entfernung" },
        { ParameterType.Number,     en = "Angle", de = "Winkel" },
    },
}

function b_Reward_MoveToPosition:GetRewardTable(__quest_)
    return { Reward.Custom, {self, self.CustomFunction} }
end

function b_Reward_MoveToPosition:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Entity = __parameter_;
    elseif (__index_ == 1) then
        self.Target = __parameter_;
    elseif (__index_ == 2) then
        self.Distance = __parameter_ * 1;
    elseif (__index_ == 3) then
        self.Angle = __parameter_ * 1;
    end
end

function b_Reward_MoveToPosition:CustomFunction(__quest_)
    if not IsExisting(self.Entity) or not IsExisting(self.Target) then
        return;
    end
    self.Angle = self.Angle or 0;

    local entity = GetID(self.Entity);
    local target = GetID(self.Target);
    local orientation = Logic.GetEntityOrientation(target);
    local x,y,z = Logic.EntityGetPos(target);
    if Logic.IsBuilding(target) == 1 then
        x, y = Logic.GetBuildingApproachPosition(target);
        orientation = orientation -90;
    end
    x = x + self.Distance * math.cos( math.rad(orientation+self.Angle) );
    y = y + self.Distance * math.sin( math.rad(orientation+self.Angle) );
    Logic.MoveSettler(entity, x, y);
    StartSimpleJobEx( function(_entityID, _targetID)
        if Logic.IsEntityMoving(_entityID) == false then
            LookAt(_entityID, _targetID);
            return true;
        end
    end, entity, target);
end

function b_Reward_MoveToPosition:DEBUG(__quest_)
    if tonumber(self.Distance) == nil or self.Distance < 50 then
        dbg(__quest_.Identifier.. " " ..self.Name.. ": Reward_MoveToPosition: Distance is nil or to short!");
        return true;
    elseif not IsExisting(self.Entity) or not IsExisting(self.Target) then
        dbg(__quest_.Identifier.. " " ..self.Name.. ": Reward_MoveToPosition: Mover entity or target entity does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reward_MoveToPosition);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler gewinnt das Spiel mit einem animierten Siegesfest.
--
-- Es ist nicht möglich weiterzuspielen!
--
-- @return Table mit Behavior
-- @within Reprisal
--
function Reward_VictoryWithParty()
    return b_Reward_VictoryWithParty:new();
end

b_Reward_VictoryWithParty = {
    Name = "Reward_VictoryWithParty",
    Description = {
        en = "Reward: The player wins the game with an animated festival on the market.",
        de = "Lohn: Der Spieler gewinnt das Spiel mit einer animierten Siegesfeier.",
    },
    Parameter =    {}
};

function b_Reward_VictoryWithParty:GetRewardTable()
    return {Reward.Custom, {self, self.CustomFunction}};
end

function b_Reward_VictoryWithParty:AddParameter(__index_, __parameter_)
end

function b_Reward_VictoryWithParty:CustomFunction(__quest_)
    Victory(g_VictoryAndDefeatType.VictoryMissionComplete);
    local pID = __quest_.ReceivingPlayer;

    local market = Logic.GetMarketplace(pID);
    if IsExisting(market) then
        local pos = GetPosition(market)
        Logic.CreateEffect(EGL_Effects.FXFireworks01,pos.X,pos.Y,0);
        Logic.CreateEffect(EGL_Effects.FXFireworks02,pos.X,pos.Y,0);

        local PossibleSettlerTypes = {
            Entities.U_SmokeHouseWorker,
            Entities.U_Butcher,
            Entities.U_Carpenter,
            Entities.U_Tanner,
            Entities.U_Blacksmith,
            Entities.U_CandleMaker,
            Entities.U_Baker,
            Entities.U_DairyWorker,

            Entities.U_SpouseS01,
            Entities.U_SpouseS02,
            Entities.U_SpouseS02,
            Entities.U_SpouseS03,
            Entities.U_SpouseF01,
            Entities.U_SpouseF01,
            Entities.U_SpouseF02,
            Entities.U_SpouseF03,
        };
        VictoryGenerateFestivalAtPlayer(pID, PossibleSettlerTypes);

        Logic.ExecuteInLuaLocalState([[
            if IsExisting(]]..market..[[) then
                CameraAnimation.AllowAbort = false
                CameraAnimation.QueueAnimation( CameraAnimation.SetCameraToEntity, ]]..market..[[)
                CameraAnimation.QueueAnimation( CameraAnimation.StartCameraRotation,  5 )
                CameraAnimation.QueueAnimation( CameraAnimation.Stay ,  9999 )
            end
            XGUIEng.ShowWidget("/InGame/InGame/MissionEndScreen/ContinuePlaying", 0);
        ]]);
    end
end

function b_Reward_VictoryWithParty:DEBUG(__quest_)
    return false;
end

Core:RegisterBehavior(b_Reward_VictoryWithParty)

-- -------------------------------------------------------------------------- --

---
-- Ändert die Sichtbarkeit eines Entity.
-- 
-- @param _ScriptName Skriptname des Entity
-- @param _Visible    Sichtbarkeit an/aus
-- @return Table mit Behavior
-- @within Reprisal
--
function Reward_SetVisible(...)
    return b_Reward_SetVisible:new(...)
end

b_Reward_SetVisible = API.InstanceTable(b_Reprisal_SetVisible);
b_Reward_SetVisible.Name = "Reward_ChangePlayer";
b_Reward_SetVisible.Description.en = "Reward: Changes the visibility of an entity. If the entity is a spawner the spawned entities will be affected.";
b_Reward_SetVisible.Description.de = "Lohn: Setzt die Sichtbarkeit einer Entity. Handelt es sich um einen Spawner werden auch die gespawnten Entities beeinflusst.";
b_Reward_SetVisible.GetReprisalTable = nil;

b_Reward_SetVisible.GetRewardTable = function(self, __quest_)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Core:RegisterBehavior(b_Reward_SetVisible);

-- -------------------------------------------------------------------------- --

---
-- Gibt oder entzieht einem KI-Spieler die Kontrolle über ein Entity.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Controlled Durch KI kontrollieren an/aus
-- @return Table mit Behavior
-- @within Reward
--
function Reward_AI_SetEntityControlled(...)
    return b_Reward_AI_SetEntityControlled:new(...);
end

b_Reward_AI_SetEntityControlled = {
    Name = "Reward_AI_SetEntityControlled",
    Description = {
        en = "Reward: Bind or Unbind an entity or a battalion to/from an AI player. The AI player must be activated!",
        de = "Lohn: Die KI kontrolliert die Entity oder der KI die Kontrolle entziehen. Die KI muss aktiv sein!",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",               de = "Entity", },
        { ParameterType.Custom,     en = "AI control entity", de = "KI kontrolliert Entity", },
    },
}

function b_Reward_AI_SetEntityControlled:GetRewardTable(__quest_)
    return { Reward.Custom, { self, self.CustomFunction } }
end

function b_Reward_AI_SetEntityControlled:AddParameter( __index_, __parameter_ )
    if (__index_ == 0) then
        self.Entity = __parameter_;
    elseif (__index_ == 1) then
        self.Hidden = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Reward_AI_SetEntityControlled:CustomFunction(__quest_)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    local pID = Logic.EntityGetPlayer(eID);
    local eType = Logic.GetEntityType(eID);
    local tName = Logic.GetEntityTypeName(eType);
    if string.find(tName, "S_") or string.find(tName, "B_NPC_Bandits")
    or string.find(tName, "B_NPC_Barracks") then
        local spawned = {Logic.GetSpawnedEntities(eID)};
        for i=1, #spawned do
            if Logic.IsLeader(spawned[i]) == 1 then
                AICore.HideEntityFromAI(pID, spawned[i], not self.Hidden);
            end
        end
    else
        AICore.HideEntityFromAI(pID, eID, not self.Hidden);
    end
end

function b_Reward_AI_SetEntityControlled:GetCustomData(__index_)
    if __index_ == 1 then
        return { "false", "true" }
    end
end

function b_Reward_AI_SetEntityControlled:DEBUG(__quest_)
    if not IsExisting(self.Entity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reward_AI_SetEntityControlled);

-- -------------------------------------------------------------------------- --

---
-- Macht das Entity verwundbar oder unverwundbar.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Vulnerable Verwundbarkeit an/aus
-- @return Table mit Behavior
-- @within Reward
--
function Reward_SetVulnerability(...)
    return b_Reward_SetVulnerability:new(...);
end

b_Reward_SetVulnerability = API.InstanceTable(b_Reprisal_SetVulnerability);
b_Reward_SetVulnerability.Name = "Reward_SetVulnerability";
b_Reward_SetVulnerability.Description.en = "Reward: Changes the vulnerability of the entity. If the entity is a spawner the spawned entities will be affected.";
b_Reward_SetVulnerability.Description.de = "Lohn: Macht eine Entity verwundbar oder unverwundbar. Handelt es sich um einen Spawner, sind die gespawnten Entities betroffen.";
b_Reward_SetVulnerability.GetReprisalTable = nil;

b_Reward_SetVulnerability.GetRewardTable = function(self, __quest_)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Core:RegisterBehavior(b_Reward_SetVulnerability);

-- -------------------------------------------------------------------------- --

---
-- Ändert das Model eines Entity.
--
-- In Verbindung mit Reward_SetVisible oder Reprisal_SetVisible können
-- Script Entites ein neues Model erhalten und sichtbar gemacht werden.
-- Das hat den Vorteil, das Script Entities nicht überbaut werden können.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Model      Neues Model
-- @return Table mit Behavior
-- @within Reward
--
function Reward_SetModel(...)
    return b_Reward_SetModel:new(...);
end

b_Reward_SetModel = API.InstanceTable(b_Reprisal_SetModel);
b_Reward_SetModel.Name = "Reward_SetModel";
b_Reward_SetModel.Description.en = "Reward: Changes the model of the entity. Be careful, some models crash the game.";
b_Reward_SetModel.Description.de = "Lohn: Aendert das Model einer Entity. Achtung: Einige Modelle fuehren zum Absturz.";
b_Reward_SetModel.GetReprisalTable = nil;

b_Reward_SetModel.GetRewardTable = function(self, __quest_)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Core:RegisterBehavior(b_Reward_SetModel);

-- -------------------------------------------------------------------------- --

---
-- Füllt die Munition in der Kriegsmaschine vollständig auf.
--
-- @param _ScriptName Skriptname des Entity
-- @return Table mit Behavior
-- @within Reward
--
function Reward_RefillAmmunition(...)
    return b_Reward_RefillAmmunition:new(...);
end

b_Reward_RefillAmmunition = {
    Name = "Reward_RefillAmmunition",
    Description = {
        en = "Reward: Refills completely the ammunition of the entity.",
        de = "Lohn: Fuellt die Munition der Entity vollständig auf.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
    },
}

function b_Reward_RefillAmmunition:GetRewardTable()
    return { Reward.Custom, {self, self.CustomFunction} }
end

function b_Reward_RefillAmmunition:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Scriptname = _Parameter
    end
end

function b_Reward_RefillAmmunition:CustomFunction()
    local EntityID = GetID(self.Scriptname);
    if not IsExisting(EntityID) then
        return;
    end

    local Ammunition = Logic.GetAmmunitionAmount(EntityID);
    while (Ammunition < 10)
    do
        Logic.RefillAmmunitions(EntityID);
        Ammunition = Logic.GetAmmunitionAmount(EntityID);
    end
end

function b_Reward_RefillAmmunition:DEBUG(_Quest)
    if not IsExisting(self.Scriptname) then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": '"..self.Scriptname.."' is destroyed!");
        return true
    end
    return false;
end

Core:RegisterBehavior(b_Reward_RefillAmmunition)

-- -------------------------------------------------------------------------- --
-- Trigger                                                                    --
-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald mindestens X von Y Quests fehlgeschlagen sind.
--
-- @param _MinAmount Mindestens zu verlieren (max. 5)
-- @param _QuestAmount Anzahl geprüfter Quests (max. 5 und >= _MinAmount)
-- @param _Quest1      Name des 1. Quest
-- @param _Quest2      Name des 2. Quest
-- @param _Quest3      Name des 3. Quest
-- @param _Quest4      Name des 4. Quest
-- @param _Quest5      Name des 5. Quest
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnAtLeastXOfYQuestsFailed(...)
    return b_Trigger_OnAtLeastXOfYQuestsFailed:new(...);
end

b_Trigger_OnAtLeastXOfYQuestsFailed = {
    Name = "Trigger_OnAtLeastXOfYQuestsFailed",
    Description = {
        en = "Trigger: if at least X of Y given quests has been finished successfully.",
        de = "Ausloeser: wenn X von Y angegebener Quests fehlgeschlagen sind.",
    },
    Parameter = {
        { ParameterType.Custom, en = "Least Amount", de = "Mindest Anzahl" },
        { ParameterType.Custom, en = "Quest Amount", de = "Quest Anzahl" },
        { ParameterType.QuestName, en = "Quest name 1", de = "Questname 1" },
        { ParameterType.QuestName, en = "Quest name 2", de = "Questname 2" },
        { ParameterType.QuestName, en = "Quest name 3", de = "Questname 3" },
        { ParameterType.QuestName, en = "Quest name 4", de = "Questname 4" },
        { ParameterType.QuestName, en = "Quest name 5", de = "Questname 5" },
    },
}

function b_Trigger_OnAtLeastXOfYQuestsFailed:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnAtLeastXOfYQuestsFailed:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.LeastAmount = tonumber(_Parameter)
    elseif (_Index == 1) then
        self.QuestAmount = tonumber(_Parameter)
    elseif (_Index == 2) then
        self.QuestName1 = _Parameter
    elseif (_Index == 3) then
        self.QuestName2 = _Parameter
    elseif (_Index == 4) then
        self.QuestName3 = _Parameter
    elseif (_Index == 5) then
        self.QuestName4 = _Parameter
    elseif (_Index == 6) then
        self.QuestName5 = _Parameter
    end
end

function b_Trigger_OnAtLeastXOfYQuestsFailed:CustomFunction()
    local least = 0
    for i = 1, self.QuestAmount do
		local QuestID = GetQuestID(self["QuestName"..i]);
        if IsValidQuest(QuestID) then
			if (Quests[QuestID].Result == QuestResult.Failure) then
				least = least + 1
				if least >= self.LeastAmount then
					return true
				end
			end
        end
    end
    return false
end

function b_Trigger_OnAtLeastXOfYQuestsFailed:DEBUG(_Quest)
    local leastAmount = self.LeastAmount
    local questAmount = self.QuestAmount
    if leastAmount <= 0 or leastAmount >5 then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": LeastAmount is wrong")
        return true
    elseif questAmount <= 0 or questAmount > 5 then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": QuestAmount is wrong")
        return true
    elseif leastAmount > questAmount then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": LeastAmount is greater than QuestAmount")
        return true
    end
    for i = 1, questAmount do
        if not IsValidQuest(self["QuestName"..i]) then
            dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": Quest ".. self["QuestName"..i] .. " not found")
            return true
        end
    end
    return false
end

function b_Trigger_OnAtLeastXOfYQuestsFailed:GetCustomData(_Index)
    if (_Index == 0) or (_Index == 1) then
        return {"1", "2", "3", "4", "5"}
    end
end

Core:RegisterBehavior(b_Trigger_OnAtLeastXOfYQuestsFailed)

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald die Munition in der Kriegsmaschine erschöpft ist.
--
-- @param _ScriptName Skriptname des Entity
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_AmmunitionDepleted(...)
    return b_Trigger_AmmunitionDepleted:new(...);
end

b_Trigger_AmmunitionDepleted = {
    Name = "Trigger_AmmunitionDepleted",
    Description = {
        en = "Trigger: if the ammunition of the entity is depleted.",
        de = "Ausloeser: wenn die Munition der Entity aufgebraucht ist.",
    },
    Parameter = {
        { ParameterType.Scriptname, en = "Script name", de = "Skriptname" },
    },
}

function b_Trigger_AmmunitionDepleted:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_AmmunitionDepleted:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Scriptname = _Parameter
    end
end

function b_Trigger_AmmunitionDepleted:CustomFunction()
    if not IsExisting(self.Scriptname) then
        return false;
    end

    local EntityID = GetID(self.Scriptname);
    if Logic.GetAmmunitionAmount(EntityID) > 0 then
        return false;
    end

    return true;
end

function b_Trigger_AmmunitionDepleted:DEBUG(_Quest)
    if not IsExisting(self.Scriptname) then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": '"..self.Scriptname.."' is destroyed!");
        return true
    end
    return false
end

Core:RegisterBehavior(b_Trigger_AmmunitionDepleted)

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, wenn exakt einer von beiden Quests erfolgreich ist.
--
-- @param _QuestName1 Name des ersten Quest
-- @param _QuestName2 Name des zweiten Quest
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnExactOneQuestIsWon(...)
    return b_Trigger_OnExactOneQuestIsWon:new(...);
end

b_Trigger_OnExactOneQuestIsWon = {
    Name = "Trigger_OnExactOneQuestIsWon",
    Description = {
        en = "Trigger: if one of two given quests has been finished successfully, but NOT both.",
        de = "Ausloeser: wenn eine von zwei angegebenen Quests (aber NICHT beide) erfolgreich abgeschlossen wurde.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest Name 1", de = "Questname 1" },
        { ParameterType.QuestName, en = "Quest Name 2", de = "Questname 2" },
    },
}

function b_Trigger_OnExactOneQuestIsWon:GetTriggerTable(__quest_)
    return {Triggers.Custom2, {self, self.CustomFunction}};
end

function b_Trigger_OnExactOneQuestIsWon:AddParameter(__index_, __parameter_)
    self.QuestTable = {};

    if (__index_ == 0) then
        self.Quest1 = __parameter_;
    elseif (__index_ == 1) then
        self.Quest2 = __parameter_;
    end
end

function b_Trigger_OnExactOneQuestIsWon:CustomFunction(__quest_)
    local Quest1 = Quests[GetQuestID(self.Quest1)];
    local Quest2 = Quests[GetQuestID(self.Quest2)];
    if Quest2 and Quest1 then
        local Quest1Succeed = (Quest1.State == QuestState.Over and Quest1.Result == QuestResult.Success);
        local Quest2Succeed = (Quest2.State == QuestState.Over and Quest2.Result == QuestResult.Success);
        if (Quest1Succeed and not Quest2Succeed) or (not Quest1Succeed and Quest2Succeed) then
            return true;
        end
    end
    return false;
end

function b_Trigger_OnExactOneQuestIsWon:DEBUG(__quest_)
    if self.Quest1 == self.Quest2 then
        dbg(__quest_.Identifier..": "..self.Name..": Both quests are identical!");
        return true;
    elseif not IsValidQuest(self.Quest1) then
        dbg(__quest_.Identifier..": "..self.Name..": Quest '"..self.Quest1.."' does not exist!");
        return true;
    elseif not IsValidQuest(self.Quest2) then
        dbg(__quest_.Identifier..": "..self.Name..": Quest '"..self.Quest2.."' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_OnExactOneQuestIsWon);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, wenn exakt einer von beiden Quests erfolgreich ist.
--
-- @param _QuestName1 Name des ersten Quest
-- @param _QuestName2 Name des zweiten Quest
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnExactOneQuestIsLost(...)
    return b_Trigger_OnExactOneQuestIsLost:new(...);
end

b_Trigger_OnExactOneQuestIsLost = {
    Name = "Trigger_OnExactOneQuestIsLost",
    Description = {
        en = "Trigger: If one of two given quests has been lost, but NOT both.",
        de = "Ausloeser: Wenn einer von zwei angegebenen Quests (aber NICHT beide) fehlschlägt.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest Name 1", de = "Questname 1" },
        { ParameterType.QuestName, en = "Quest Name 2", de = "Questname 2" },
    },
}

function b_Trigger_OnExactOneQuestIsLost:GetTriggerTable(__quest_)
    return {Triggers.Custom2, {self, self.CustomFunction}};
end

function b_Trigger_OnExactOneQuestIsLost:AddParameter(__index_, __parameter_)
    self.QuestTable = {};

    if (__index_ == 0) then
        self.Quest1 = __parameter_;
    elseif (__index_ == 1) then
        self.Quest2 = __parameter_;
    end
end

function b_Trigger_OnExactOneQuestIsLost:CustomFunction(__quest_)
    local Quest1 = Quests[GetQuestID(self.Quest1)];
    local Quest2 = Quests[GetQuestID(self.Quest2)];
    if Quest2 and Quest1 then
        local Quest1Succeed = (Quest1.State == QuestState.Over and Quest1.Result == QuestResult.Failure);
        local Quest2Succeed = (Quest2.State == QuestState.Over and Quest2.Result == QuestResult.Failure);
        if (Quest1Succeed and not Quest2Succeed) or (not Quest1Succeed and Quest2Succeed) then
            return true;
        end
    end
    return false;
end

function b_Trigger_OnExactOneQuestIsLost:DEBUG(__quest_)
    if self.Quest1 == self.Quest2 then
        dbg(__quest_.Identifier..": "..self.Name..": Both quests are identical!");
        return true;
    elseif not IsValidQuest(self.Quest1) then
        dbg(__quest_.Identifier..": "..self.Name..": Quest '"..self.Quest1.."' does not exist!");
        return true;
    elseif not IsValidQuest(self.Quest2) then
        dbg(__quest_.Identifier..": "..self.Name..": Quest '"..self.Quest2.."' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_OnExactOneQuestIsWon);

-- -------------------------------------------------------------------------- --
-- Application Space                                                          --
-- -------------------------------------------------------------------------- --

BundleSymfoniaBehaviors = {
    Global = {},
    Local = {}
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Application Space
-- @local
--
function BundleSymfoniaBehaviors.Global:Install()
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Theif observation
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    GameCallback_OnThiefDeliverEarnings_Orig_QSB_SymfoniaBehaviors = GameCallback_OnThiefDeliverEarnings;
    GameCallback_OnThiefDeliverEarnings = function(_ThiefPlayerID, _ThiefID, _BuildingID, _GoodAmount)
        GameCallback_OnThiefDeliverEarnings_Orig_QSB_SymfoniaBehaviors(_ThiefPlayerID, _ThiefID, _BuildingID, _GoodAmount);

        for i=1, Quests[0] do
            if Quests[i] and Quests[i].State == QuestState.Active then
                for j=1, Quests[i].Objectives[0] do
                    if Quests[i].Objectives[j].Type == Objective.Custom2 then
                        if Quests[i].Objectives[j].Data[1].Name == "Goal_StealBuilding" then
                            local found;
                            for k=1, #Quests[i].Objectives[j].Data[1].RobberList do
                                local stohlen = Quests[i].Objectives[j].Data[1].RobberList[k];
                                if stohlen[1] == GetID(Quests[i].Objectives[j].Data[1].Building) and stohlen[2] == _ThiefID then
                                    found = true;
                                    break;
                                end
                            end
                            if found then
                                Quests[i].Objectives[j].Data[1].SuccessfullyStohlen = true;
                            end

                        elseif Quests[i].Objectives[j].Data[1].Name == "Goal_StealGold" then
                            Quests[i].Objectives[j].Data[1].StohlenGold = Quests[i].Objectives[j].Data[1].StohlenGold + _GoodAmount;
                            if Quests[i].Objectives[j].Data[1].Printout then
                                local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
                                local msg  = {de = "Talern gestohlen",en = "gold stolen",};
                                local curr = Quests[i].Objectives[j].Data[1].StohlenGold;
                                local need = Quests[i].Objectives[j].Data[1].Amount;
                                API.Note(string.format("%d/%d %s", curr, need, msg[lang]));
                            end
                        end
                    end
                end
            end
        end
    end

    GameCallback_OnThiefStealBuilding_Orig_QSB_SymfoniaBehaviors = GameCallback_OnThiefStealBuilding;
    GameCallback_OnThiefStealBuilding = function(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID)
        GameCallback_OnThiefStealBuilding_Orig_QSB_SymfoniaBehaviors(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID);

        for i=1, Quests[0] do
            if Quests[i] and Quests[i].State == QuestState.Active then
                for j=1, Quests[i].Objectives[0] do
                    if Quests[i].Objectives[j].Type == Objective.Custom2 then
                        if Quests[i].Objectives[j].Data[1].Name == "Goal_Infiltrate" then
                            if  GetID(Quests[i].Objectives[j].Data[1].Building) == _BuildingID and Quests[i].ReceivingPlayer == _ThiefPlayerID then
                                Quests[i].Objectives[j].Data[1].Infiltrated = true;
                                if Quests[i].Objectives[j].Data[1].Delete then
                                    DestroyEntity(_ThiefID);
                                end
                            end

                        elseif Quests[i].Objectives[j].Data[1].Name == "Goal_StealBuilding" then
                            local found;
                            local isCathedral = Logic.IsEntityInCategory(_BuildingID, EntityCategories.Cathedrals) == 1;
                            local isWarehouse = Logic.GetEntityType(_BuildingID) == Entities.B_StoreHouse;
                            if isWarehouse or isCathedral then
                                Quests[i].Objectives[j].Data[1].SuccessfullyStohlen = true;
                            else
                                for k=1, #Quests[i].Objectives[j].Data[1].RobberList do
                                    local stohlen = Quests[i].Objectives[j].Data[1].RobberList[k];
                                    if stohlen[1] == _BuildingID and stohlen[2] == _ThiefID then
                                        found = true;
                                        break;
                                    end
                                end
                            end
                            if not found then
                                table.insert(Quests[i].Objectives[j].Data[1].RobberList, {_BuildingID, _ThiefID});
                            end
                        end
                    end
                end
            end
        end
    end

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Objectives
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    QuestTemplate.IsObjectiveCompleted_Orig_QSB_SymfoniaBehaviors = QuestTemplate.IsObjectiveCompleted;
    QuestTemplate.IsObjectiveCompleted = function(self, objective)
        local objectiveType = objective.Type;
        local data = objective.Data;

        if objective.Completed ~= nil then
            return objective.Completed;
        end

        if objectiveType == Objective.Distance then

            -- Distance with parameter
            local IDdata2 = GetID(data[1]);
            local IDdata3 = GetID(data[2]);
            data[3] = data[3] or 2500;
            if not (Logic.IsEntityDestroyed(IDdata2) or Logic.IsEntityDestroyed(IDdata3)) then
                if Logic.GetDistanceBetweenEntities(IDdata2,IDdata3) <= data[3] then
                    DestroyQuestMarker(IDdata3);
                    objective.Completed = true;
                end
            else
                DestroyQuestMarker(IDdata3);
                objective.Completed = false;
            end
        else
            return self:IsObjectiveCompleted_Orig_QSB_SymfoniaBehaviors(objective);
        end
    end

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Questmarkers
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    function QuestTemplate:RemoveQuestMarkers()
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if self.Objectives[i].Data[4] then
                    DestroyQuestMarker(self.Objectives[i].Data[2]);
                end
            end
        end
    end

    function QuestTemplate:ShowQuestMarkers()
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if self.Objectives[i].Data[4] then
                    ShowQuestMarker(self.Objectives[i].Data[2]);
                end
            end
        end
    end

    function ShowQuestMarker(_Entity)
        local eID = GetID(_Entity);
        local x,y = Logic.GetEntityPosition(eID);
        local Marker = EGL_Effects.E_Questmarker_low;
        if Logic.IsBuilding(eID) == 1 then
            Marker = EGL_Effects.E_Questmarker;
        end
        Questmarkers[eID] = Logic.CreateEffect(Marker, x,y,0);
    end

    function DestroyQuestMarker(_Entity)
        local eID = GetID(_Entity);
        if Questmarkers[eID] ~= nil then
            Logic.DestroyEffect(Questmarkers[eID]);
            Questmarkers[eID] = nil;
        end
    end
end

-- Local Script ----------------------------------------------------------------

---
-- Initialisiert das Bundle im lokalen Skript.
-- @within Application Space
-- @local
--
function BundleSymfoniaBehaviors.Local:Install()

end

Core:RegisterBundle("BundleSymfoniaBehaviors");

