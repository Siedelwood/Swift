-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Synfonia BundleClassicBehaviors                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
--
--
-- @module BundleClassicBehaviors
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

QSB.EffectNameToID = QSB.EffectNameToID or {};

-- -------------------------------------------------------------------------- --
-- User Space                                                                 --
-- -------------------------------------------------------------------------- --



-- -------------------------------------------------------------------------- --
-- Goals                                                                      --
-- -------------------------------------------------------------------------- --

---
-- Ein Interaktives Objekt muss benutzt werden.
--
-- @param _ScriptName Skriptname des interaktiven Objektes
-- @return table: Behavior
-- @within Goals
--
function Goal_ActivateObject(...)
    return b_Goal_ActivateObject:new(...);
end

b_Goal_ActivateObject = {
    Name = "Goal_ActivateObject",
    Description = {
        en = "Goal: Activate an interactive object",
        de = "Ziel: Aktiviere ein interaktives Objekt",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Object name", de = "Skriptname" },
    },
}

function b_Goal_ActivateObject:GetGoalTable(__quest_)
    return {Objective.Object, { self.ScriptName } }
end

function b_Goal_ActivateObject:AddParameter(__index_, __parameter_)
   if __index_ == 0 then
        self.ScriptName = __parameter_
   end
end

function b_Goal_ActivateObject:GetMsgKey()
    return "Quest_Object_Activate"
end

AddQuestBehavior(b_Goal_ActivateObject);

-- -------------------------------------------------------------------------- --

---
-- Einem Spieler müssen Rohstoffe oder Waren gesendet werden.
--
-- In der Regel wird zum Auftraggeber gesendet. Es ist aber möglich auch zu
-- einem anderen Zielspieler schicken zu lassen. Wird ein Wagen gefangen
-- genommen, dann muss erneut geschickt werden. Optional kann auch gesagt
-- werden, dass keine erneute Forderung erfolgt, wenn der Karren von einem
-- Feind abgefangen wird.
--
-- @param _GoodType      Typ der Ware
-- @param _GoodAmount    Menga der Ware
-- @param _OtherTarget   Anderes Ziel als Auftraggeber
-- @param _IgnoreCapture Bei Gefangennahme nicht erneut schicken
-- @return table: Behavior
-- @within Goals
--
function Goal_Deliver(...)
    return b_Goal_Deliver:new(...)
end

b_Goal_Deliver = {
    Name = "Goal_Deliver",
    Description = {
        en = "Goal: Deliver goods to quest giver or to another player.",
        de = "Ziel: Liefere Waren zum Auftraggeber oder zu einem anderen Spieler.",
    },
    Parameter = {
        { ParameterType.Custom, en = "Type of good", de = "Ressourcentyp" },
        { ParameterType.Number, en = "Amount of good", de = "Ressourcenmenge" },
        { ParameterType.Custom, en = "To different player", de = "Anderer Empfaenger" },
        { ParameterType.Custom, en = "Ignore capture", de = "Abfangen ignorieren" },
    },
}


function b_Goal_Deliver:GetGoalTable(__quest_)
    local GoodType = Logic.GetGoodTypeID(self.GoodTypeName)
    return { Objective.Deliver, GoodType, self.GoodAmount, self.OverrideTarget, self.IgnoreCapture }
end

function b_Goal_Deliver:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.GoodTypeName = __parameter_
    elseif (__index_ == 1) then
        self.GoodAmount = __parameter_ * 1
    elseif (__index_ == 2) then
        self.OverrideTarget = tonumber(__parameter_)
    elseif (__index_ == 3) then
        self.IgnoreCapture = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Goal_Deliver:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 0 then
        for k, v in pairs( Goods ) do
            if string.find( k, "^G_" ) then
                table.insert( Data, k )
            end
        end
        table.sort( Data )
    elseif __index_ == 2 then
        table.insert( Data, "-" )
        for i = 1, 8 do
            table.insert( Data, i )
        end
    elseif __index_ == 3 then
        table.insert( Data, "true" )
        table.insert( Data, "false" )
    else
        assert( false )
    end
    return Data
end

function b_Goal_Deliver:GetMsgKey()
    local GoodType = Logic.GetGoodTypeID(self.GoodTypeName)
    local GC = Logic.GetGoodCategoryForGoodType( GoodType )

    local tMapping = {
        [GoodCategories.GC_Clothes] = "Quest_Deliver_GC_Clothes",
        [GoodCategories.GC_Entertainment] = "Quest_Deliver_GC_Entertainment",
        [GoodCategories.GC_Food] = "Quest_Deliver_GC_Food",
        [GoodCategories.GC_Gold] = "Quest_Deliver_GC_Gold",
        [GoodCategories.GC_Hygiene] = "Quest_Deliver_GC_Hygiene",
        [GoodCategories.GC_Medicine] = "Quest_Deliver_GC_Medicine",
        [GoodCategories.GC_Water] = "Quest_Deliver_GC_Water",
        [GoodCategories.GC_Weapon] = "Quest_Deliver_GC_Weapon",
        [GoodCategories.GC_Resource] = "Quest_Deliver_Resources",
    }

    if GC then
        local Key = tMapping[GC]
        if Key then
            return Key
        end
    end
    return "Quest_Deliver_Goods"
end

AddQuestBehavior(b_Goal_Deliver);

-- -------------------------------------------------------------------------- --

---
-- Es muss ein bestimmter Diplomatiestatus zu einer anderen Datei erreicht
-- werden.
--
-- Dabei muss, je nach angegebener Relation entweder wenigstens oder auch
-- minbdestens erreicht werden.
--
-- Muss z.B. mindestens der Status Handelspartner erreicht werden (mit der
-- Relation >=), so ist der Quest auch dann erfüllt, wenn der Spieler
--  Verbündeter wird.
--
-- Im Gegenzug, bei der Relation <=, wäre der Quest erfüllt, sobald der
-- Spieler Handelspartner oder einen niedrigeren Status erreicht.
--
-- @param _PlayerID Partei, die Entdeckt werden muss
-- @param _State    Diplomatiestatus
-- @return table: Behavior
-- @within Goals
--
function Goal_Diplomacy(...)
    return b_Goal_Diplomacy:new(...);
end

b_Goal_Diplomacy = {
    Name = "Goal_Diplomacy",
    Description = {
        en = "Goal: Reach a diplomatic state",
        de = "Ziel: Erreiche einen bestimmten Diplomatiestatus zu einem anderen Spieler.",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Party", de = "Partei" },
        { ParameterType.DiplomacyState, en = "Relation", de = "Beziehung" },
    },
}

function b_Goal_Diplomacy:GetGoalTable(__quest_)
    return { Objective.Diplomacy, self.PlayerID, DiplomacyStates[self.DiplState] }
end

function b_Goal_Diplomacy:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    elseif (__index_ == 1) then
        self.DiplState = __parameter_
    end
end

function b_Goal_Diplomacy:GetIcon()
    return {6,3};
end

AddQuestBehavior(b_Goal_Diplomacy);

-- -------------------------------------------------------------------------- --

---
-- Das Heimatterritorium des Spielers muss entdeckt werden.
--
-- Das Heimatterritorium ist immer das, wo sich Burg oder Lagerhaus der
-- zu entdeckenden Partei befinden.
--
-- @param _PlayerID ID der zu entdeckenden Partei
-- @returns table: Behavior
-- @within Goals
--
function Goal_DiscoverPlayer(...)
    return b_Goal_DiscoverPlayerN.new(...);
end

b_Goal_DiscoverPlayer = {
    Name = "Goal_DiscoverPlayer",
    Description = {
        en = "Goal: Discover the home territory of another player.",
        de = "Ziel: Entdecke das Heimatterritorium eines Spielers.",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
    },
}

function b_Goal_DiscoverPlayer:GetGoalTable()
    return {Objective.Discover, 2, { self.PlayerID } }
end

function b_Goal_DiscoverPlayer:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    end
end

function b_Goal_DiscoverPlayer:GetMsgKey()
    local tMapping = {
        [PlayerCategories.BanditsCamp] = "Quest_Discover",
        [PlayerCategories.City] = "Quest_Discover_City",
        [PlayerCategories.Cloister] = "Quest_Discover_Cloister",
        [PlayerCategories.Harbour] = "Quest_Discover",
        [PlayerCategories.Village] = "Quest_Discover_Village",
    }
    local PlayerCategory = GetPlayerCategoryType(self.PlayerID)
    if PlayerCategory then
        local Key = tMapping[PlayerCategory]
        if Key then
            return Key
        end
    end
    return "Quest_Discover"
end

AddQuestBehavior(b_Goal_DiscoverPlayer);

-- -------------------------------------------------------------------------- --

---
-- Ein Territorium muss erstmalig vom Auftragnehmer betreten werden.
--
-- @param _Territory Name oder ID des Territorium
-- @return table: Behavior
-- @within Goals
--
function Goal_DiscoverTerritory(...)
    return b_Goal_DiscoverTerritory:new(...);
end

b_Goal_DiscoverTerritory = {
    Name = "Goal_DiscoverTerritory",
    Description = {
        en = "Goal: Discover a territory",
        de = "Ziel: Entdecke ein Territorium",
    },
    Parameter = {
        { ParameterType.TerritoryName, en = "Territory", de = "Territorium" },
    },
}

function b_Goal_DiscoverTerritory:GetGoalTable()
    return { Objective.Discover, 1, { self.TerritoryID  } }
end

function b_Goal_DiscoverTerritory:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.TerritoryID = tonumber(__parameter_)
        if not self.TerritoryID then
            self.TerritoryID = GetTerritoryIDByName(__parameter_)
        end
        assert( self.TerritoryID > 0 )
    end
end

function b_Goal_DiscoverTerritory:GetMsgKey()
    return "Quest_Discover_Territory"
end

AddQuestBehavior(b_Goal_DiscoverTerritory);

-- -------------------------------------------------------------------------- --

---
-- Eine andere Partei muss besiegt werden.
--
-- Die Partei gilt als besiegt, wenn ein Hauptgebäude (Burg, Kirche, Lager)
-- zerstört wurde. Achtung: Funktioniert nicht bei Banditen!
--
-- @param _PlayerID ID des Spielers
-- @return table: Behavior
-- @within Goals
--
function Goal_DestroyPlayer(...)
    return b_Goal_DestroyPlayer:new(...);
end

b_Goal_DestroyPlayer = {
    Name = "Goal_DestroyPlayer",
    Description = {
        en = "Goal: Destroy a player (destroy a main building)",
        de = "Ziel: Zerstoere einen Spieler (ein Hauptgebaeude muss zerstoert werden).",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
    },
}

function b_Goal_DestroyPlayer:GetGoalTable()
    assert( self.PlayerID <= 8 and self.PlayerID >= 1, "Error in " .. self.Name .. ": GetGoalTable: PlayerID is invalid")
    return { Objective.DestroyPlayers, self.PlayerID }
end

function b_Goal_DestroyPlayer:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    end
end

function b_Goal_DestroyPlayer:GetMsgKey()
    local tMapping = {
        [PlayerCategories.BanditsCamp] = "Quest_DestroyPlayers_Bandits",
        [PlayerCategories.City] = "Quest_DestroyPlayers_City",
        [PlayerCategories.Cloister] = "Quest_DestroyPlayers_Cloister",
        [PlayerCategories.Harbour] = "Quest_DestroyEntities_Building",
        [PlayerCategories.Village] = "Quest_DestroyPlayers_Village",
    }

    local PlayerCategory = GetPlayerCategoryType(self.PlayerID)
    if PlayerCategory then
        local Key = tMapping[PlayerCategory]
        if Key then
            return Key
        end
    end
    return "Quest_DestroyEntities_Building"
end

AddQuestBehavior(b_Goal_DestroyPlayer)

-- -------------------------------------------------------------------------- --

---
-- Es sollen Informationen aus der Burg gestohlen werden.
--
-- Der Spieler muss einen Dieb entsenden um Informationen aus der Burg zu
-- stehlen. Achtung: Das ist nur bei Feinden möglich!
--
-- @param _PlayerID ID der Partei
-- @return table: Behavior
-- @within Goals
--
function Goal_StealInformation(...)
    return b_Goal_StealInformation:new(...);
end

b_Goal_StealInformation = {
    Name = "Goal_StealInformation",
    Description = {
        en = "Goal: Steal information from another players castle",
        de = "Ziel: Stehle Informationen aus der Burg eines Spielers",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
    },
}

function b_Goal_StealInformation:GetGoalTable()

    local Target = Logic.GetHeadquarters(self.PlayerID)
    if not Target or Target == 0 then
        Target = Logic.GetStoreHouse(self.PlayerID)
    end
    assert( Target and Target ~= 0 )
    return {Objective.Steal, 1, { Target } }

end

function b_Goal_StealInformation:AddParameter(__index_, __parameter_)

    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    end

end

function b_Goal_StealInformation:GetMsgKey()
    return "Quest_Steal_Info"

end

AddQuestBehavior(b_Goal_StealInformation);

-- -------------------------------------------------------------------------- --

---
-- Alle Einheiten des Spielers müssen zerstört werden.
--
-- @param _PlayerID ID des Spielers
-- @return table: Behavior
-- @within Goals
--
function Goal_DestroyAllPlayerUnits(...)
    return b_Goal_DestroyAllPlayerUnits:new(...);
end

b_Goal_DestroyAllPlayerUnits = {
    Name = "Goal_DestroyAllPlayerUnits",
    Description = {
        en = "Goal: Destroy all units owned by player (be careful with script entities)",
        de = "Ziel: Zerstoere alle Einheiten eines Spielers (vorsicht mit Script-Entities)",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
    },
}

function b_Goal_DestroyAllPlayerUnits:GetGoalTable()
    return { Objective.DestroyAllPlayerUnits, self.PlayerID }
end

function b_Goal_DestroyAllPlayerUnits:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    end
end

function b_Goal_DestroyAllPlayerUnits:GetMsgKey()
    local tMapping = {
        [PlayerCategories.BanditsCamp] = "Quest_DestroyPlayers_Bandits",
        [PlayerCategories.City] = "Quest_DestroyPlayers_City",
        [PlayerCategories.Cloister] = "Quest_DestroyPlayers_Cloister",
        [PlayerCategories.Harbour] = "Quest_DestroyEntities_Building",
        [PlayerCategories.Village] = "Quest_DestroyPlayers_Village",
    }

    local PlayerCategory = GetPlayerCategoryType(self.PlayerID)
    if PlayerCategory then
        local Key = tMapping[PlayerCategory]
        if Key then
            return Key
        end
    end
    return "Quest_DestroyEntities"
end

AddQuestBehavior(b_Goal_DestroyAllPlayerUnits);

-- -------------------------------------------------------------------------- --

---
-- Ein benanntes Entity muss zerstört werden.
--
-- @param _ScriptName Skriptname des Ziels
-- @return table: Behavior
-- @within Goals
--
function Goal_DestroyScriptEntity(...)
    return b_Goal_DestroyScriptEntity:new(...);
end

b_Goal_DestroyScriptEntity = {
    Name = "Goal_DestroyScriptEntity",
    Description = {
        en = "Goal: Destroy an entity",
        de = "Ziel: Zerstoere eine Entitaet",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
    },
}

function b_Goal_DestroyScriptEntity:GetGoalTable()
    return {Objective.DestroyEntities, 1, { self.ScriptName } }
end

function b_Goal_DestroyScriptEntity:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.ScriptName = __parameter_
    end
end

function b_Goal_DestroyScriptEntity:GetMsgKey()
    if Logic.IsEntityAlive(self.ScriptName) then
        local ID = GetID(self.ScriptName)
        if ID and ID ~= 0 then
            ID = Logic.GetEntityType( ID )
            if ID and ID ~= 0 then
                if Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableBuilding ) == 1 then
                    return "Quest_DestroyEntities_Building"

                elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableAnimal ) == 1 then
                    return "Quest_DestroyEntities_Predators"

                elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.Hero ) == 1 then
                    return "Quest_Destroy_Leader"

                elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.Military ) == 1
                    or Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableSettler ) == 1
                    or Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableMerchant ) == 1  then

                    return "Quest_DestroyEntities_Unit"
                end
            end
        end
    end
    return "Quest_DestroyEntities"
end

AddQuestBehavior(b_Goal_DestroyScriptEntity);

-- -------------------------------------------------------------------------- --

---
-- Eine Menge an Entities eines Typs müssen zerstört werden.
--
-- Wenn Raubtiere zerstört werden sollen, muss Spieler 0 als Besitzer
-- angegeben werden.
--
-- @param _EntityType Typ des Entity
-- @param _Amount     Menge an Entities des Typs
-- @param _PlayerID   Besitzer des Entity
-- @return table: Behavior
-- @within Goals
--
function Goal_DestroyType(...)
    return b_Goal_DestroyType:new(...);
end

b_Goal_DestroyType = {
    Name = "Goal_DestroyType",
    Description = {
        en = "Goal: Destroy entity types",
        de = "Ziel: Zerstoere Entitaetstypen",
    },
    Parameter = {
        { ParameterType.Custom, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
        { ParameterType.Custom, en = "Player", de = "Spieler" },
    },
}

function b_Goal_DestroyType:GetGoalTable(__quest_)
    return {Objective.DestroyEntities, 2, Entities[self.EntityName], self.Amount, self.PlayerID }
end

function b_Goal_DestroyType:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.EntityName = __parameter_
    elseif (__index_ == 1) then
        self.Amount = __parameter_ * 1
        self.DestroyTypeAmount = self.Amount
    elseif (__index_ == 2) then
        self.PlayerID = __parameter_ * 1
    end
end

function b_Goal_DestroyType:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 0 then
        for k, v in pairs( Entities ) do
            if string.find( k, "^[ABU]_" ) then
                table.insert( Data, k )
            end
        end
        table.sort( Data )
    elseif __index_ == 2 then
        for i = 0, 8 do
            table.insert( Data, i )
        end
    else
        assert( false )
    end
    return Data
end

function b_Goal_DestroyType:GetMsgKey()
    local ID = self.EntityName
    if Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableBuilding ) == 1 then
        return "Quest_DestroyEntities_Building"

    elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableAnimal ) == 1 then
        return "Quest_DestroyEntities_Predators"

    elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.Hero ) == 1 then
        return "Quest_Destroy_Leader"

    elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.Military ) == 1
        or Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableSettler ) == 1
        or Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableMerchant ) == 1  then

        return "Quest_DestroyEntities_Unit"
    end
    return "Quest_DestroyEntities"
end

AddQuestBehavior(b_Goal_DestroyType);

-- -------------------------------------------------------------------------- --

do
    GameCallback_EntityKilled_Orig_QSB_Goal_DestroySoldiers = GameCallback_EntityKilled;
    GameCallback_EntityKilled = function(_AttackedEntityID, _AttackedPlayerID, _AttackingEntityID, _AttackingPlayerID, _AttackedEntityType, _AttackingEntityType)
        if _AttackedPlayerID ~= 0 and _AttackingPlayerID ~= 0 then
            QSB.Goal_DestroySoldiers[_AttackingPlayerID] = QSB.Goal_DestroySoldiers[_AttackingPlayerID] or {}
            QSB.Goal_DestroySoldiers[_AttackingPlayerID][_AttackedPlayerID] = QSB.Goal_DestroySoldiers[_AttackingPlayerID][_AttackedPlayerID] or 0
            if Logic.IsEntityTypeInCategory( _AttackedEntityType, EntityCategories.Military ) == 1
            and Logic.IsEntityInCategory( _AttackedEntityID, EntityCategories.HeavyWeapon) == 0 then
                QSB.Goal_DestroySoldiers[_AttackingPlayerID][_AttackedPlayerID] = QSB.Goal_DestroySoldiers[_AttackingPlayerID][_AttackedPlayerID] +1
            end
        end
        GameCallback_EntityKilled_Orig_QSB_Goal_DestroySoldiers(_AttackedEntityID, _AttackedPlayerID, _AttackingEntityID, _AttackingPlayerID, _AttackedEntityType, _AttackingEntityType)
    end
end

---
-- Spieler A muss Soldaten von Spieler B zerstören.
--
-- @param _PlayerA Angreifende Partei
-- @param _PlayerB Zielpartei
-- @param _Amount Menga an Soldaten
-- @return table: Behavior
-- @within Goals
--
function Goal_DestroySoldiers(...)
    return b_Goal_DestroySoldiers:new(...);
end

b_Goal_DestroySoldiers = {
    Name = "Goal_DestroySoldiers",
    Description = {
        en = "Goal: Destroy a given amount of enemy soldiers",
        de = "Ziel: Zerstoere eine Anzahl gegnerischer Soldaten",
                },
    Parameter = {
        {ParameterType.PlayerID, en = "Attacking Player", de = "Angreifer", },
        {ParameterType.PlayerID, en = "Defending Player", de = "Verteidiger", },
        {ParameterType.Number, en = "Amount", de = "Anzahl", },
    },
}

function b_Goal_DestroySoldiers:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_DestroySoldiers:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.AttackingPlayer = __parameter_ * 1
    elseif (__index_ == 1) then
        self.AttackedPlayer = __parameter_ * 1
    elseif (__index_ == 2) then
        self.KillsNeeded = __parameter_ * 1
    end
end

function b_Goal_DestroySoldiers:CustomFunction(__quest_)
    if not __quest_.QuestDescription or __quest_.QuestDescription == "" then
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en"
        local caption = (lang == "de" and "SOLDATEN ZERST�REN {cr}{cr}von der Partei: ") or
                         "DESTROY SOLDIERS {cr}{cr}from faction: "
        local amount  = (lang == "de" and "Anzahl: ") or "Amount: "
        local party = GetPlayerName(self.AttackedPlayer);
        if party == "" or party == nil then
            party = ((lang == "de" and "Spieler ") or "Player ") .. self.AttackedPlayer
        end
        local text = "{center}" .. caption .. party .. "{cr}{cr}" .. amount .. " "..self.KillsNeeded;
        Core:ChangeCustomQuestCaptionText(text, __quest_);
    end

    local currentKills = 0;
    if QSB.Goal_DestroySoldiers[self.AttackingPlayer] and QSB.Goal_DestroySoldiers[self.AttackingPlayer][self.AttackedPlayer] then
        currentKills = QSB.Goal_DestroySoldiers[self.AttackingPlayer][self.AttackedPlayer]
    end
    self.SaveAmount = self.SaveAmount or currentKills
    return self.KillsNeeded <= currentKills - self.SaveAmount or nil
end

function b_Goal_DestroySoldiers:DEBUG(__quest_)
    if Logic.GetStoreHouse(self.AttackingPlayer) == 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Player " .. self.AttackinPlayer .. " is dead :-(")
        return true
    elseif Logic.GetStoreHouse(self.AttackedPlayer) == 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Player " .. self.AttackedPlayer .. " is dead :-(")
        return true
    elseif self.KillsNeeded < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Amount negative")
        return true
    end
end

function b_Goal_DestroySoldiers:GetIcon()
    return {7,12}
end

function b_Goal_DestroySoldiers:Reset()
    self.SaveAmount = nil
end

AddQuestBehavior(b_Goal_DestroySoldiers)

---
-- Eine Entfernung zwischen zwei Entities muss erreicht werden.
--
-- Je nach angegebener Relation muss die Entfernung unter- oder überschritten
-- werden um den Quest zu gewinnen.
--
-- @param _ScriptName1  Erstes Entity
-- @param _ScriptName2  Zweites Entity
-- @param _Relation     Relation
-- @param _Distance     Entfernung
-- @return table: Behavior
-- @within Goals
--
function Goal_EntityDistance(...)
    return b_Goal_EntityDistance:new(...);
end

b_Goal_EntityDistance = {
    Name = "Goal_EntityDistance",
    Description = {
        en = "Goal: Distance between two entities",
        de = "Ziel: Zwei Entities sollen zueinander eine Entfernung ueber- oder unterschreiten.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity 1", de = "Entity 1" },
        { ParameterType.ScriptName, en = "Entity 2", de = "Entity 2" },
        { ParameterType.Custom, en = "Relation", de = "Relation" },
        { ParameterType.Number, en = "Distance", de = "Entfernung" },
    },
}

function b_Goal_EntityDistance:GetGoalTable(__quest_)
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_EntityDistance:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Entity1 = __parameter_
    elseif (__index_ == 1) then
        self.Entity2 = __parameter_
    elseif (__index_ == 2) then
        self.bRelSmallerThan = __parameter_ == "<"
    elseif (__index_ == 3) then
        self.Distance = __parameter_ * 1
    end
end

function b_Goal_EntityDistance:CustomFunction(__quest_)
    if Logic.IsEntityDestroyed( self.Entity1 ) or Logic.IsEntityDestroyed( self.Entity2 ) then
        return false
    end
    local ID1 = GetID( self.Entity1 )
    local ID2 = GetID( self.Entity2 )
    local InRange = Logic.CheckEntitiesDistance( ID1, ID2, self.Distance )
    if ( self.bRelSmallerThan and InRange ) or ( not self.bRelSmallerThan and not InRange ) then
        return true
    end
end

function b_Goal_EntityDistance:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 2 then
        table.insert( Data, ">" )
        table.insert( Data, "<" )
    else
        assert( false )
    end
    return Data
end

function b_Goal_EntityDistance:DEBUG(__quest_)
    if not IsExisting(self.Entity1) or not IsExisting(self.Entity2) then
        local text = string.format("%s Goal_EntityDistance: At least 1 of the entities for distance check don't exist!", __quest_.Identifier);
        dbg(text);
        return true;
    end
    return false;
end

AddQuestBehavior(b_Goal_EntityDistance);

-- -------------------------------------------------------------------------- --

---
-- Der Primary Knight des angegebenen Spielers muss sich dem Ziel nähern.
--
-- @param _PlayerID   PlayerID des Helden
-- @param _ScriptName Skriptname des Ziels
-- @return table: Behavior
-- @within Goals
--
function Goal_KnightDistance(...)
    return b_Goal_KnightDistance:new(...);
end

b_Goal_KnightDistance = {
    Name = "Goal_KnightDistance",
    Description = {
        en = "Goal: Bring the knight close to a given entity",
        de = "Ziel: Bringe den Ritter nah an eine bestimmte Entitaet",
    },
    Parameter = {
        { ParameterType.PlayerID,     en = "Player", de = "Spieler" },
        { ParameterType.ScriptName, en = "Target", de = "Ziel" },
    },
}

function b_Goal_KnightDistance:GetGoalTable()
    return {Objective.Distance, Logic.GetKnightID(self.PlayerID), self.Target, 2500, true}
end

function b_Goal_KnightDistance:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    elseif (__index_ == 1) then
        self.Target = __parameter_
    end
end

AddQuestBehavior(b_Goal_KnightDistance);

---
-- Eine bestimmte Anzahl an Einheiten einer Kategorie muss sich auf dem
-- Territorium befinden.
--
-- Die gegenebe Anzahl kann entweder als Mindestwert oder als Maximalwert
-- gesucht werden.
--
-- @param _Territory  TerritoryID oder TerritoryName
-- @param _PlayerID   PlayerID der Einheiten
-- @param _Category   Kategorie der Einheiten
-- @param _Relation   Mengenrelation (< oder >=)
-- @param _Amount     Menge an Einheiten
-- @return table: Behavior
-- @within Goals
--
function Goal_UnitsOnTerritory(...)
    return b_Goal_UnitsOnTerritory:new(...);
end

b_Goal_UnitsOnTerritory = {
    Name = "Goal_UnitsOnTerritory",
    Description = {
        en = "Goal: Place a certain amount of units on a territory",
        de = "Ziel: Platziere eine bestimmte Anzahl Einheiten auf einem Gebiet",
    },
    Parameter = {
        { ParameterType.TerritoryNameWithUnknown, en = "Territory", de = "Territorium" },
        { ParameterType.Custom,  en = "Player", de = "Spieler" },
        { ParameterType.Custom,  en = "Category", de = "Kategorie" },
        { ParameterType.Custom,  en = "Relation", de = "Relation" },
        { ParameterType.Number,  en = "Number of units", de = "Anzahl Einheiten" },
    },
}

function b_Goal_UnitsOnTerritory:GetGoalTable(__quest_)
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_UnitsOnTerritory:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.TerritoryID = tonumber(__parameter_)
        if self.TerritoryID == nil then
            self.TerritoryID = GetTerritoryIDByName(__parameter_)
        end
    elseif (__index_ == 1) then
        self.PlayerID = tonumber(__parameter_) * 1
    elseif (__index_ == 2) then
        self.Category = __parameter_
    elseif (__index_ == 3) then
        self.bRelSmallerThan = (tostring(__parameter_) == "true" or tostring(__parameter_) == "<")
    elseif (__index_ == 4) then
        self.NumberOfUnits = __parameter_ * 1
    end
end

function b_Goal_UnitsOnTerritory:CustomFunction(__quest_)
    local Units = GetEntitiesOfCategoryInTerritory(self.PlayerID, EntityCategories[self.Category], self.TerritoryID);
    if self.bRelSmallerThan == false and #Units >= self.NumberOfUnits then
        return true;
    elseif self.bRelSmallerThan == true and #Units < self.NumberOfUnits then
        return true;
    end
end

function b_Goal_UnitsOnTerritory:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 1 then
        table.insert( Data, -1 )
        for i = 1, 8 do
            table.insert( Data, i )
        end
    elseif __index_ == 2 then
        for k, v in pairs( EntityCategories ) do
            if not string.find( k, "^G_" ) and k ~= "SheepPasture" then
                table.insert( Data, k )
            end
        end
        table.sort( Data );
    elseif __index_ == 3 then
        table.insert( Data, ">=" )
        table.insert( Data, "<" )
    else
        assert( false )
    end
    return Data
end

function b_Goal_UnitsOnTerritory:DEBUG(__quest_)
    local territories = {Logic.GetTerritories()}
    if tonumber(self.TerritoryID) == nil or self.TerritoryID < 0 or not Inside(self.TerritoryID,territories) then
        local text = string.format("%s Goal_UnitsOnTerritory: got an invalid territoryID!", __quest_.Identifier);
        dbg(text);
        return true;
    elseif tonumber(self.PlayerID) == nil or self.PlayerID < 0 or self.PlayerID > 8 then
        local text = string.format("%s Goal_UnitsOnTerritory: got an invalid playerID!", __quest_.Identifier);
        dbg(text);
        return true;
    elseif not EntityCategories[self.Category] then
        local text = string.format("%s Goal_UnitsOnTerritory: got an invalid playerID!", __quest_.Identifier);
        dbg(text);
        return true;
    elseif tonumber(self.NumberOfUnits) == nil or self.NumberOfUnits < 0 then
        local text = string.format("%s Goal_UnitsOnTerritory: amount is negative or nil!", __quest_.Identifier);
        dbg(text);
        return true;
    end
    return false;
end

AddQuestBehavior(b_Goal_UnitsOnTerritory);

-- -------------------------------------------------------------------------- --

---
-- Der angegebene Spieler muss einen Buff aktivieren.
--
-- <u>Buffs</u>
-- <li>Buff_Spice: Salz</li>
-- <li>Buff_Colour: Farben</li>
-- <li>Buff_Entertainers: Entertainer anheuern</li>
-- <li>Buff_FoodDiversity: Vielfältige Nahrung</li>
-- <li>Buff_ClothesDiversity: Vielfältige Kleidung</li>
-- <li>Buff_HygieneDiversity: Vielfältige Hygiene</li>
-- <li>Buff_EntertainmentDiversity: Vielfältige Unterhaltung</li>
-- <li>Buff_Sermon: Predigt halten</li>
-- <li>Buff_Festival: Fest veranstalten</li>
-- <li>Buff_ExtraPayment: Bonussold auszahlen</li>
-- <li>Buff_HighTaxes: Hohe Steuern verlangen</li>
-- <li>Buff_NoPayment: Sold streichen</li>
-- <li>Buff_NoTaxes: Keine Steuern verlangen</li>
-- <br/>
-- <u>RdO Buffs</u>
-- <li>Buff_Gems: Edelsteine</li>
-- <li>Buff_MusicalInstrument: Musikinstrumente</li>
-- <li>Buff_Olibanum: Weihrauch</li>
--
-- @param _PlayerID Spieler, der den Buff aktivieren muss
-- @param _Buff     Buff, der aktiviert werden soll
-- @return table: Behavior
-- @within Goals
--
function Goal_ActivateBuff(...)
    return b_Goal_ActivateBuff:new(...);
end

b_Goal_ActivateBuff = {
    Name = "Goal_ActivateBuff",
    Description = {
        en = "Goal: Activate a buff",
        de = "Ziel: Aktiviere einen Buff",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Custom, en = "Buff", de = "Buff" },
    },
}

function b_Goal_ActivateBuff:GetGoalTable(__quest_)
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_ActivateBuff:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    elseif (__index_ == 1) then
        self.BuffName = __parameter_
        self.Buff = Buffs[__parameter_]
    end
end

function b_Goal_ActivateBuff:CustomFunction(__quest_)
   if not __quest_.QuestDescription or __quest_.QuestDescription == "" then
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en"
        local caption = (lang == "de" and "BONUS AKTIVIEREN{cr}{cr}") or "ACTIVATE BUFF{cr}{cr}"

        local tMapping = {
            ["Buff_Spice"]                        = {de = "Salz", en = "Salt"},
            ["Buff_Colour"]                        = {de = "Farben", en = "Color"},
            ["Buff_Entertainers"]                = {de = "Entertainer", en = "Entertainer"},
            ["Buff_FoodDiversity"]                = {de = "Vielf�ltige Nahrung", en = "Food diversity"},
            ["Buff_ClothesDiversity"]            = {de = "Vielf�ltige Kleidung", en = "Clothes diversity"},
            ["Buff_HygieneDiversity"]            = {de = "Vielf�ltige Reinigung", en = "Hygiene diversity"},
            ["Buff_EntertainmentDiversity"]        = {de = "Vielf�ltige Unterhaltung", en = "Entertainment diversity"},
            ["Buff_Sermon"]                        = {de = "Predigt", en = "Sermon"},
            ["Buff_Festival"]                    = {de = "Fest", en = "Festival"},
            ["Buff_ExtraPayment"]                = {de = "Sonderzahlung", en = "Extra payment"},
            ["Buff_HighTaxes"]                    = {de = "Hohe Steuern", en = "High taxes"},
            ["Buff_NoPayment"]                    = {de = "Kein Sold", en = "No payment"},
            ["Buff_NoTaxes"]                    = {de = "Keine Steuern", en = "No taxes"},
        }

        if g_GameExtraNo >= 1 then
            tMapping["Buff_Gems"]                = {de = "Edelsteine", en = "Gems"}
            tMapping["Buff_MusicalInstrument"]  = {de = "Musikinstrumente", en = "Musical instruments"}
            tMapping["Buff_Olibanum"]            = {de = "Weihrauch", en = "Olibanum"}
        end

        local text = "{center}" .. caption .. tMapping[self.BuffName][lang]
        Core:ChangeCustomQuestCaptionText(text, __quest_)
    end

    local Buff = Logic.GetBuff( self.PlayerID, self.Buff )
    if Buff and Buff ~= 0 then
        return true
    end
end

function b_Goal_ActivateBuff:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 1 then
        Data = {
            "Buff_Spice",
            "Buff_Colour",
            "Buff_Entertainers",
            "Buff_FoodDiversity",
            "Buff_ClothesDiversity",
            "Buff_HygieneDiversity",
            "Buff_EntertainmentDiversity",
            "Buff_Sermon",
            "Buff_Festival",
            "Buff_ExtraPayment",
            "Buff_HighTaxes",
            "Buff_NoPayment",
            "Buff_NoTaxes"
        }

        if g_GameExtraNo >= 1 then
            table.insert(Data, "Buff_Gems")
            table.insert(Data, "Buff_MusicalInstrument")
            table.insert(Data, "Buff_Olibanum")
        end

        table.sort( Data )
    else
        assert( false )
    end
    return Data
end

function b_Goal_ActivateBuff:GetIcon()
    local tMapping = {
        [Buffs.Buff_Spice] = "Goods.G_Salt",
        [Buffs.Buff_Colour] = "Goods.G_Dye",
        [Buffs.Buff_Entertainers] = "Entities.U_Entertainer_NA_FireEater", --{5, 12},
        [Buffs.Buff_FoodDiversity] = "Needs.Nutrition", --{1, 1},
        [Buffs.Buff_ClothesDiversity] = "Needs.Clothes", --{1, 2},
        [Buffs.Buff_HygieneDiversity] = "Needs.Hygiene", --{16, 1},
        [Buffs.Buff_EntertainmentDiversity] = "Needs.Entertainment", --{1, 4},
        [Buffs.Buff_Sermon] = "Technologies.R_Sermon", --{4, 14},
        [Buffs.Buff_Festival] = "Technologies.R_Festival", --{4, 15},
        [Buffs.Buff_ExtraPayment]    = {1,8},
        [Buffs.Buff_HighTaxes] = {1,6},
        [Buffs.Buff_NoPayment] = {1,8},
        [Buffs.Buff_NoTaxes]    = {1,6},
    }
    if g_GameExtraNo and g_GameExtraNo >= 1 then
        tMapping[Buffs.Buff_Gems] = "Goods.G_Gems"
        tMapping[Buffs.Buff_MusicalInstrument] = "Goods.G_MusicalInstrument"
        tMapping[Buffs.Buff_Olibanum] = "Goods.G_Olibanum"
    end
    return tMapping[self.Buff]
end

function b_Goal_ActivateBuff:DEBUG(__quest_)
    if not self.Buff then
        local text = string.format("%s Goal_ActivateBuff: buff '%s' does not exist!", __quest_.Identifier, tostring(self.Buff));
        dbg(text);
        return true;
    elseif not tonumber(self.PlayerID) or self.PlayerID < 1 or self.PlayerID > 8 then
        local text = string.format("%s Goal_ActivateBuff: got an invalid playerID!", __quest_.Identifier);
        dbg(text);
        return true;
    end
    return false;
end

AddQuestBehavior(b_Goal_ActivateBuff);

-- -------------------------------------------------------------------------- --

---
-- Zwei Punkte auf der Spielwelt müssen mit einer Straße verbunden werden.
--
-- @param _Position1 Erster Endpunkt der Straße
-- @param _Position2 Zweiter Endpunkt der Straße
-- @param _OnlyRoads Keine Wege akzeptieren
-- @return table: Behavior
-- @within Goals
--
function Goal_BuildRoad(...)
    return b_Goal_BuildRoad:new(...)
end

b_Goal_BuildRoad = {
    Name = "Goal_BuildRoad",
    Description = {
        en = "Goal: Connect two points with a street or a road",
        de = "Ziel: Verbinde zwei Punkte mit einer Strasse oder einem Weg.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity 1",     de = "Entity 1" },
        { ParameterType.ScriptName, en = "Entity 2",     de = "Entity 2" },
        { ParameterType.Custom,     en = "Only roads",     de = "Nur Strassen" },
    },
}

function b_Goal_BuildRoad:GetGoalTable(__quest_)
    return { Objective.BuildRoad, { GetID( self.Entity1 ),
                                     GetID( self.Entity2 ),
                                     false,
                                     0,
                                     self.bRoadsOnly } }

end

function b_Goal_BuildRoad:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Entity1 = __parameter_
    elseif (__index_ == 1) then
        self.Entity2 = __parameter_
    elseif (__index_ == 2) then
        self.bRoadsOnly = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Goal_BuildRoad:GetCustomData( __index_ )
    local Data
    if __index_ == 2 then
        Data = {"true","false"}
    end
    return Data
end

function b_Goal_BuildRoad:DEBUG(__quest_)
    if not IsExisting(self.Entity1) or not IsExisting(self.Entity2) then
        local text = string.format("%s Goal_BuildRoad: first or second entity does not exist!", __quest_.Identifier);
        dbg(text);
        return true;
    end
    return false;
end

AddQuestBehavior(b_Goal_BuildRoad);

-- -------------------------------------------------------------------------- --


---
-- Eine Mauer muss die Bewegung eines Spielers zwischen 2 Punkten einschränken.
--
-- Achtung: Bei Monsun kann dieses Ziel fälschlicher Weise als erfüllt gewertet
-- werden, wenn der Weg durch Wasser blockiert wird!
--
-- @param _PlayerID  PlayerID, die blockiert wird
-- @param _Position1 Erste Position
-- @param _Position2 Zweite Position
-- @return table: Behavior
-- @within Goals
--
function Goal_BuildWall(...)
    return b_Goal_BuildWall:new(...)
end

b_Goal_BuildWall = {
    Name = "Goal_BuildWall",
    Description = {
        en = "Goal: Build a wall between 2 positions bo stop the movement of an (hostile) player.",
        de = "Ziel: Baue eine Mauer zwischen 2 Punkten, die die Bewegung eines (feindlichen) Spielers zwischen den Punkten verhindert.",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Enemy", de = "Feind" },
        { ParameterType.ScriptName, en = "Entity 1", de = "Entity 1" },
        { ParameterType.ScriptName, en = "Entity 2", de = "Entity 2" },
    },
}

function b_Goal_BuildWall:GetGoalTable(__quest_)
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_BuildWall:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    elseif (__index_ == 1) then
        self.EntityName1 = __parameter_
    elseif (__index_ == 2) then
        self.EntityName2 = __parameter_
    end
end

function b_Goal_BuildWall:CustomFunction(__quest_)
    local eID1 = GetID(self.EntityName1)
    local eID2 = GetID(self.EntityName2)

    if not IsExisting(eID1) then
        return false
    end
    if not IsExisting(eID2) then
        return false
    end
    local x,y,z = Logic.EntityGetPos(eID1)
    if Logic.IsBuilding(eID1) == 1 then
        x,y = Logic.GetBuildingApproachPosition(eID1)
    end
    local Sector1 = Logic.GetPlayerSectorAtPosition(self.PlayerID, x, y)
    local x,y,z = Logic.EntityGetPos(eID2)
    if Logic.IsBuilding(eID2) == 1 then
        x,y = Logic.GetBuildingApproachPosition(eID2)
    end
    local Sector2 = Logic.GetPlayerSectorAtPosition(self.PlayerID, x, y)
    if Sector1 ~= Sector2 then
        return true
    end
    return nil
end

function b_Goal_BuildWall:GetMsgKey()
    return "Quest_Create_Wall"
end

function b_Goal_BuildWall:GetIcon()
    return {3,9}
end

function b_Goal_BuildWall:DEBUG(__quest_)
    if not IsExisting(self.EntityName1) or not IsExisting(self.EntityName2) then
        local text = string.format("%s %s: first or second entity does not exist!", __quest_.Identifier, self.Name);
        dbg(text);
        return true;
    elseif not tonumber(self.PlayerID) or self.PlayerID < 1 or self.PlayerID > 8 then
        local text = string.format("%s %s: got an invalid playerID!", __quest_.Identifier, self.Name);
        dbg(text);
        return true;
    end

    if GetDiplomacyState(__quest_.ReceivingPlayer, self.PlayerID) > -1 and not self.WarningPrinted then
        local text = string.format("%s %s: player %d is neighter enemy or unknown to quest receiver!", __quest_.Identifier, self.Name, self.PlayerID);
        self.WarningPrinted = true;
        warn(text);
    end
    return false;
end

AddQuestBehavior(b_Goal_BuildWall);

-- -------------------------------------------------------------------------- --

---
-- Ein bestimmtes Territorium muss vom Auftragnehmer eingenommen werden.
--
-- @param _Territory Territorium-ID oder Territoriumname
-- @return table: Behavior
-- @within Goals
--
function Goal_Claim(...)
    return b_Goal_Claim:new(...)
end

b_Goal_Claim = {
    Name = "Goal_Claim",
    Description = {
        en = "Goal: Claim a territory",
        de = "Ziel: Erobere ein Territorium",
    },
    Parameter = {
        { ParameterType.TerritoryName, en = "Territory", de = "Territorium" },
    },
}

function b_Goal_Claim:GetGoalTable(__quest_)
    return { Objective.Claim, 1, self.TerritoryID }
end

function b_Goal_Claim:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.TerritoryID = tonumber(__parameter_)
        if not self.TerritoryID then
            self.TerritoryID = GetTerritoryIDByName(__parameter_)
        end
    end
end

function b_Goal_Claim:GetMsgKey()
    return "Quest_Claim_Territory"
end

AddQuestBehavior(b_Goal_Claim);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss eine Menge an Territorien besitzen.
--
-- Das Heimatterritorium des Spielers wird mitgezählt!
--
-- @param _Amount Anzahl Territorien
-- @return table: Behavior
-- @within Goals
--
function Goal_ClaimXTerritories(...)
    return b_Goal_ClaimXTerritories:new(...)
end

b_Goal_ClaimXTerritories = {
    Name = "Goal_ClaimXTerritories",
    Description = {
        en = "Goal: Claim the given number of territories, all player territories are counted",
        de = "Ziel: Erobere die angegebene Anzahl Territorien, alle spielereigenen Territorien werden gezaehlt",
    },
    Parameter = {
        { ParameterType.Number, en = "Territories" , de = "Territorien" }
    },
}

function b_Goal_ClaimXTerritories:GetGoalTable(__quest_)
    return { Objective.Claim, 2, self.TerritoriesToClaim }
end

function b_Goal_ClaimXTerritories:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.TerritoriesToClaim = __parameter_ * 1
    end
end

function b_Goal_ClaimXTerritories:GetMsgKey()
    return "Quest_Claim_Territory"
end

AddQuestBehavior(b_Goal_ClaimXTerritories);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss auf dem Territorium einen Entitytyp erstellen.
--
-- @param _Type      Typ des Entity
-- @param _Amount    Menge an Entities
-- @param _Territory Territorium
-- @return table: Behavior
-- @within Goals
--
function Goal_Create(...)
    return b_Goal_Create:new(...);
end

b_Goal_Create = {
    Name = "Goal_Create",
    Description = {
        en = "Goal: Create Buildings/Units on a specified territory",
        de = "Ziel: Erstelle Einheiten/Gebaeude auf einem bestimmten Territorium.",
    },
    Parameter = {
        { ParameterType.Entity, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
        { ParameterType.TerritoryNameWithUnknown, en = "Territory", de = "Territorium" },
    },
}

function b_Goal_Create:GetGoalTable(__quest_)
    return { Objective.Create, assert( Entities[self.EntityName] ), self.Amount, self.TerritoryID  }
end

function b_Goal_Create:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.EntityName = __parameter_
    elseif (__index_ == 1) then
        self.Amount = __parameter_ * 1
    elseif (__index_ == 2) then
        self.TerritoryID = tonumber(__parameter_)
        if not self.TerritoryID then
            self.TerritoryID = GetTerritoryIDByName(__parameter_)
        end
    end
end

function b_Goal_Create:GetMsgKey()
    return Logic.IsEntityTypeInCategory( Entities[self.EntityName], EntityCategories.AttackableBuilding ) == 1 and "Quest_Create_Building" or "Quest_Create_Unit"
end

AddQuestBehavior(b_Goal_Create);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss eine Menge von Rohstoffen produzieren.
--
-- @param _Type   Typ des Rohstoffs
-- @param _Amount Menge an Rohstoffen
-- @return table: Behavior
-- @within Goals
--
function Goal_Produce(...)
    return b_Goal_Produce:new(...);
end

b_Goal_Produce = {
    Name = "Goal_Produce",
    Description = {
        en = "Goal: Produce an amount of goods",
        de = "Ziel: Produziere eine Anzahl einer bestimmten Ware.",
    },
    Parameter = {
        { ParameterType.RawGoods, en = "Type of good", de = "Ressourcentyp" },
        { ParameterType.Number, en = "Amount of good", de = "Anzahl der Ressource" },
    },
}

function b_Goal_Produce:GetGoalTable(__quest_)
    local GoodType = Logic.GetGoodTypeID(self.GoodTypeName)
    return { Objective.Produce, GoodType, self.GoodAmount }
end

function b_Goal_Produce:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.GoodTypeName = __parameter_
    elseif (__index_ == 1) then
        self.GoodAmount = __parameter_ * 1
    end
end

function b_Goal_Produce:GetMsgKey()
    return "Quest_Produce"
end

AddQuestBehavior(b_Goal_Produce);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss eine bestimmte Menge einer Ware erreichen.
--
-- @param _Type     Typ der Ware
-- @param _Amount   Menge an Waren
-- @param _Relation Mengenrelation
-- @return table: Behavior
-- @within Goals
--
function Goal_GoodAmount(...)
    return b_Goal_GoodAmount:new(...);
end

b_Goal_GoodAmount = {
    Name = "Goal_GoodAmount",
    Description = {
        en = "Goal: Obtain an amount of goods - either by trading or producing them",
        de = "Ziel: Beschaffe eine Anzahl Waren - entweder durch Handel oder durch eigene Produktion.",
    },
    Parameter = {
        { ParameterType.Custom, en = "Type of good", de = "Warentyp" },
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
        { ParameterType.Custom, en = "Relation", de = "Relation" },
    },
}

function b_Goal_GoodAmount:GetGoalTable(__quest_)
    local GoodType = Logic.GetGoodTypeID(self.GoodTypeName)
    return { Objective.Produce, GoodType, self.GoodAmount, self.bRelSmallerThan }
end

function b_Goal_GoodAmount:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.GoodTypeName = __parameter_
    elseif (__index_ == 1) then
        self.GoodAmount = __parameter_ * 1
    elseif  (__index_ == 2) then
        self.bRelSmallerThan = __parameter_ == "<" or tostring(__parameter_) == "true"
    end
end

function b_Goal_GoodAmount:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 0 then
        for k, v in pairs( Goods ) do
            if string.find( k, "^G_" ) then
                table.insert( Data, k )
            end
        end
        table.sort( Data )
    elseif __index_ == 2 then
        table.insert( Data, ">=" )
        table.insert( Data, "<" )
    else
        assert( false )
    end
    return Data
end

AddQuestBehavior(b_Goal_GoodAmount);

-- -------------------------------------------------------------------------- --

---
-- Die Siedler des Spielers dürfen nicht aufgrund des Bedürfnisses streiken.
--
-- <u>Bedürfnisse</u>
-- <ul>
-- <li>Clothes: Kleidung</li>
-- <li>Entertainment: Unterhaltung</li>
-- <li>Nutrition: Nahrung</li>
-- <li>Hygiene: Hygiene</li>
-- <li>Medicine: Medizin</li>
-- </ul>
--
-- @param _PlayerID ID des Spielers
-- @param _Need     Bedürfnis
-- @return table: Behavior
-- @within Goals
--
function Goal_SatisfyNeed(...)
    return b_Goal_SatisfyNeed:new(...);
end

b_Goal_SatisfyNeed = {
    Name = "Goal_SatisfyNeed",
    Description = {
        en = "Goal: Satisfy a need",
        de = "Ziel: Erfuelle ein Beduerfnis",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Need, en = "Need", de = "Beduerfnis" },
    },
}

function b_Goal_SatisfyNeed:GetGoalTable(__quest_)
    return { Objective.SatisfyNeed, self.PlayerID, assert( Needs[self.Need] ) }

end

function b_Goal_SatisfyNeed:AddParameter(__index_, __parameter_)

    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    elseif (__index_ == 1) then
        self.Need = __parameter_
    end

end

function b_Goal_SatisfyNeed:GetMsgKey()
    local tMapping = {
        [Needs.Clothes] = "Quest_SatisfyNeed_Clothes",
        [Needs.Entertainment] = "Quest_SatisfyNeed_Entertainment",
        [Needs.Nutrition] = "Quest_SatisfyNeed_Food",
        [Needs.Hygiene] = "Quest_SatisfyNeed_Hygiene",
        [Needs.Medicine] = "Quest_SatisfyNeed_Medicine",
    }

    local Key = tMapping[Needs[self.Need]]
    if Key then
        return Key
    end

    -- No default message
end

AddQuestBehavior(b_Goal_SatisfyNeed);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss eine Menge an Siedlern in der Stadt haben.
--
-- @param _Amount Menge an Siedlern
-- @return table: Behavior
-- @within Goals
--
function Goal_SettlersNumber(...)
    return b_Goal_SettlersNumber:new(...);
end

b_Goal_SettlersNumber = {
    Name = "Goal_SettlersNumber",
    Description = {
        en = "Goal: Get a given amount of settlers",
        de = "Ziel: Erreiche eine bestimmte Anzahl Siedler.",
    },
    Parameter = {
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
    },
}

function b_Goal_SettlersNumber:GetGoalTable()
    return {Objective.SettlersNumber, 1, self.SettlersAmount }
end

function b_Goal_SettlersNumber:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.SettlersAmount = __parameter_ * 1
    end
end

function b_Goal_SettlersNumber:GetMsgKey()
    return "Quest_NumberSettlers"
end

AddQuestBehavior(b_Goal_SettlersNumber);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss eine Menge von Ehefrauen in der Stadt haben.
--
-- @param _Amount Menge an Ehefrauen
-- @return table: Behavior
-- @within Goals
--
function Goal_Spouses(...)
    return b_Goal_Spouses:new(...);    
end

b_Goal_Spouses = {
    Name = "Goal_Spouses",
    Description = {
        en = "Goal: Get a given amount of spouses",
        de = "Ziel: Erreiche eine bestimmte Ehefrauenanzahl",
    },
    Parameter = {
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
    },
}

function b_Goal_Spouses:GetGoalTable()
    return {Objective.Spouses, self.SpousesAmount }
end

function b_Goal_Spouses:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.SpousesAmount = __parameter_ * 1
    end
end

function b_Goal_Spouses:GetMsgKey()
    return "Quest_NumberSpouses"
end

AddQuestBehavior(b_Goal_Spouses);

-- -------------------------------------------------------------------------- --

---
-- Ein Spieler muss eine Menge an Soldaten haben.
--
-- <u>Relationen</u>
-- <ul>
-- <li>>= - Anzahl als Mindestmenge</li>
-- <li>< - Weniger als Anzahl</li>
-- </ul>
--
-- @param _PlayerID ID des Spielers
-- @param _Relation Mengenrelation
-- @param _Amount   Menge an Soldaten
-- @return table: Behavior
-- @within Goals
--
function Goal_SoldierCount(...)
    return b_Goal_SoldierCount:new(...);
end

b_Goal_SoldierCount = {
    Name = "Goal_SoldierCount",
    Description = {
        en = "Goal: Create a specified number of soldiers",
        de = "Ziel: Erreiche eine Anzahl groesser oder kleiner der angegebenen Menge Soldaten.",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Custom, en = "Relation", de = "Relation" },
        { ParameterType.Number, en = "Number of soldiers", de = "Anzahl Soldaten" },
    },
}

function b_Goal_SoldierCount:GetGoalTable(__quest_)
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_SoldierCount:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    elseif (__index_ == 1) then
        self.bRelSmallerThan = tostring(__parameter_) == "true" or tostring(__parameter_) == "<"
    elseif (__index_ == 2) then
        self.NumberOfUnits = __parameter_ * 1
    end
end

function b_Goal_SoldierCount:CustomFunction(__quest_)
    if not __quest_.QuestDescription or __quest_.QuestDescription == "" then
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en"
        local caption = (lang == "de" and "SOLDATENANZAHL {cr}Partei: ") or
                            "SOLDIERS {cr}faction: "
        local relation = tostring(self.bRelSmallerThan);
        local relationText = {
            ["true"]  = {de = "Weniger als", en = "Less than"},
            ["false"] = {de = "Mindestens", en = "At least"},
        };
        local party = GetPlayerName(self.PlayerID);
        if party == "" or party == nil then
            party = ((lang == "de" and "Spieler ") or "Player ") .. self.PlayerID
        end
        local text = "{center}" .. caption .. party .. "{cr}{cr}" .. relationText[relation][lang] .. " "..self.NumberOfUnits;
        Core:ChangeCustomQuestCaptionText(text, __quest_);
    end

    local NumSoldiers = Logic.GetCurrentSoldierCount( self.PlayerID )
    if ( self.bRelSmallerThan and NumSoldiers < self.NumberOfUnits ) then
        return true
    elseif ( not self.bRelSmallerThan and NumSoldiers >= self.NumberOfUnits ) then
        return true
    end
    return nil
end

function b_Goal_SoldierCount:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 1 then

        table.insert( Data, ">=" )
        table.insert( Data, "<" )

    else
        assert( false )
    end
    return Data
end

function b_Goal_SoldierCount:GetIcon()
    return {7,11}
end

function b_Goal_SoldierCount:GetMsgKey()
    return "Quest_Create_Unit"
end

function b_Goal_SoldierCount:DEBUG(__quest_)
    if tonumber(self.NumberOfUnits) == nil or self.NumberOfUnits < 0 then
        local text = string.format("%s Goal_SoldierCount: amount can not be below 0!", __quest_.Identifier);
        dbg(text);
        return true;
    elseif tonumber(self.PlayerID) == nil or self.PlayerID < 1 or self.PlayerID > 8 then
        local text = string.format("%s Goal_SoldierCount: got an invalid playerID!", __quest_.Identifier);
        dbg(text);
        return true;
    end
    return false;
end

AddQuestBehavior(b_Goal_SoldierCount);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss wenigstens einen bestimmten Titel erreichen.
--
-- @param _Title Titel, der erreicht werden muss
-- @return table: Behavior
-- @within Goals
--
function Goal_KnightTitle(...)
    return b_Goal_KnightTitle:new(...);
end

b_Goal_KnightTitle = {
    Name = "Goal_KnightTitle",
    Description = {
        en = "Goal: Reach a specified knight title",
        de = "Ziel: Erreiche einen vorgegebenen Titel",
    },
    Parameter = {
        { ParameterType.Custom, en = "Knight title", de = "Titel" },
    },
}

function b_Goal_KnightTitle:GetGoalTable()
    return {Objective.KnightTitle, assert( KnightTitles[self.KnightTitle] ) }
end

function b_Goal_KnightTitle:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.KnightTitle = __parameter_
    end
end

function b_Goal_KnightTitle:GetMsgKey()
    return "Quest_KnightTitle"
end

function b_Goal_KnightTitle:GetCustomData( __index_ )
    return {"Knight", "Mayor", "Baron", "Earl", "Marquees", "Duke", "Archduke"}
end

AddQuestBehavior(b_Goal_KnightTitle);

-- -------------------------------------------------------------------------- --

---
-- Der angegebene Spieler muss mindestens die Menge an Festen feiern.
--
-- @param _PlayerID ID des Spielers
-- @param _Amount   Menge an Festen
-- @return table: Behavior
-- @within Goals
--
function Goal_Festivals(...)
    return b_Goal_Festivals:new(...);
end

b_Goal_Festivals = {
    Name = "Goal_Festivals",
    Description = {
        en = "Goal: The player has to start the given number of festivals.",
        de = "Ziel: Der Spieler muss eine gewisse Anzahl Feste gestartet haben.",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Number, en = "Number of festivals", de = "Anzahl Feste" }
    }
};

function b_Goal_Festivals:GetGoalTable()
    return { Objective.Custom2, {self, self.CustomFunction} };
end

function b_Goal_Festivals:AddParameter(__index_, __parameter_)
    if __index_ == 0 then
        self.PlayerID = tonumber(__parameter_);
    else
        assert(__index_ == 1, "Error in " .. self.Name .. ": AddParameter: Index is invalid.");
        self.NeededFestivals = tonumber(__parameter_);
    end
end

function b_Goal_Festivals:CustomFunction(__quest_)
    if not __quest_.QuestDescription or __quest_.QuestDescription == "" then
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en"
        local caption = (lang == "de" and "FESTE FEIERN {cr}{cr}Partei: ") or
                            "HOLD PARTIES {cr}{cr}faction: "
        local amount  = (lang == "de" and "Anzahl: ") or "Amount: "
        local party = GetPlayerName(self.PlayerID);
        if party == "" or party == nil then
            party = ((lang == "de" and "Spieler ") or "Player ") .. self.PlayerID
        end
        local text = "{center}" .. caption .. party .. "{cr}{cr}" .. amount .. " "..self.NeededFestivals;
        Core:ChangeCustomQuestCaptionText(text, __quest_);
    end

    if Logic.GetStoreHouse( self.PlayerID ) == 0  then
        return false
    end
    local tablesOnFestival = {Logic.GetPlayerEntities(self.PlayerID, Entities.B_TableBeer, 5,0)}
    local amount = 0
    for k=2, #tablesOnFestival do
        local tableID = tablesOnFestival[k]
        if Logic.GetIndexOnOutStockByGoodType(tableID, Goods.G_Beer) ~= -1 then
            local goodAmountOnMarketplace = Logic.GetAmountOnOutStockByGoodType(tableID, Goods.G_Beer)
            amount = amount + goodAmountOnMarketplace
        end
    end
    if not self.FestivalStarted and amount > 0 then
        self.FestivalStarted = true
        self.FestivalCounter = (self.FestivalCounter and self.FestivalCounter + 1) or 1
        if self.FestivalCounter >= self.NeededFestivals then
            self.FestivalCounter = nil
            return true
        end
    elseif amount == 0 then
        self.FestivalStarted = false
    end
end

function b_Goal_Festivals:DEBUG(__quest_)
    if Logic.GetStoreHouse( self.PlayerID ) == 0 then
        dbg(__quest_.Identifier .. ": Error in " .. self.Name .. ": Player " .. self.PlayerID .. " is dead :-(")
        return true
    elseif GetPlayerCategoryType(self.PlayerID) ~= PlayerCategories.City then
        dbg(__quest_.Identifier .. ": Error in " .. self.Name .. ":  Player "..  self.PlayerID .. " is no city")
        return true
    elseif self.NeededFestivals < 0 then
        dbg(__quest_.Identifier .. ": Error in " .. self.Name .. ": Number of Festivals is negative")
        return true
    end
    return false
end

function b_Goal_Festivals:Reset()
    self.FestivalCounter = nil
    self.FestivalStarted = nil
end

function b_Goal_Festivals:GetIcon()
    return {4,15}
end

AddQuestBehavior(b_Goal_Festivals)

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss eine Einheit gefangen nehmen.
--
-- @param _ScriptName Ziel
-- @return table: Behavior
-- @within Goals
--
function Goal_Capture(...)
    return b_Goal_Capture:new(...)
end

b_Goal_Capture = {
    Name = "Goal_Capture",
    Description = {
        en = "Goal: Capture a cart.",
        de = "Ziel: Ein Karren muss erobert werden.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
    },
}

function b_Goal_Capture:GetGoalTable(__quest_)
    return { Objective.Capture, 1, { self.ScriptName } }
end

function b_Goal_Capture:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.ScriptName = __parameter_
    end
end

function b_Goal_Capture:GetMsgKey()
   local ID = GetID(self.ScriptName)
   if Logic.IsEntityAlive(ID) then
        ID = Logic.GetEntityType( ID )
        if ID and ID ~= 0 then
            if Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableMerchant ) == 1 then
                return "Quest_Capture_Cart"

            elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.SiegeEngine ) == 1 then
                return "Quest_Capture_SiegeEngine"

            elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.Worker ) == 1
                or Logic.IsEntityTypeInCategory( ID, EntityCategories.Spouse ) == 1
                or Logic.IsEntityTypeInCategory( ID, EntityCategories.Hero ) == 1 then

                return "Quest_Capture_VIPOfPlayer"

            end
        end
    end
end

AddQuestBehavior(b_Goal_Capture);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss eine Menge von Einheiten eines Typs von einem
-- Spieler gefangen nehmen.
--
-- @param _Typ      Typ, der gefangen werden soll
-- @param _Amount   Menge an Einheiten
-- @param _PlayerID Besitzer der Einheiten
-- @return table: Behavior
-- @within Goals
--
function Goal_CaptureType(...)
    return b_Goal_CaptureType:new(...)
end

b_Goal_CaptureType = {
    Name = "Goal_CaptureType",
    Description = {
        en = "Goal: Capture specified entity types",
        de = "Ziel: Nimm bestimmte Entitaetstypen gefangen",
    },
    Parameter = {
        { ParameterType.Custom,     en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number,     en = "Amount", de = "Anzahl" },
        { ParameterType.PlayerID,     en = "Player", de = "Spieler" },
    },
}

function b_Goal_CaptureType:GetGoalTable(__quest_)
    return { Objective.Capture, 2, Entities[self.EntityName], self.Amount, self.PlayerID }
end

function b_Goal_CaptureType:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.EntityName = __parameter_
    elseif (__index_ == 1) then
        self.Amount = __parameter_ * 1
    elseif (__index_ == 2) then
        self.PlayerID = __parameter_ * 1
    end
end

function b_Goal_CaptureType:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 0 then
        for k, v in pairs( Entities ) do
            if string.find( k, "^U_.+Cart" ) or Logic.IsEntityTypeInCategory( v, EntityCategories.AttackableMerchant ) == 1 then
                table.insert( Data, k )
            end
        end
        table.sort( Data )
    elseif __index_ == 2 then
        for i = 0, 8 do
            table.insert( Data, i )
        end
    else
        assert( false )
    end
    return Data
end

function b_Goal_CaptureType:GetMsgKey()

    local ID = self.EntityName
    if Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableMerchant ) == 1 then
        return "Quest_Capture_Cart"

    elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.SiegeEngine ) == 1 then
        return "Quest_Capture_SiegeEngine"

    elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.Worker ) == 1
        or Logic.IsEntityTypeInCategory( ID, EntityCategories.Spouse ) == 1
        or Logic.IsEntityTypeInCategory( ID, EntityCategories.Hero ) == 1 then

        return "Quest_Capture_VIPOfPlayer"
    end
end

AddQuestBehavior(b_Goal_CaptureType);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss das angegebene Entity beschützen.
--
-- Gefangennahme (bzw. Besitzerwechsel) oder Zerstörung des Entity werden als
-- Fehlschlag gewertet.
--
-- @param _ScriptName
-- @return table: Behavior
-- @within Goals
--
function Goal_Protect(...)
    return b_Goal_Protect:new(...)
end

b_Goal_Protect = {
    Name = "Goal_Protect",
    Description = {
        en = "Goal: Protect an entity (entity needs a script name",
        de = "Ziel: Beschuetze eine Entitaet (Entitaet benoetigt einen Skriptnamen)",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
    },
}

function b_Goal_Protect:GetGoalTable()
    return {Objective.Protect, { self.ScriptName }}
end

function b_Goal_Protect:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.ScriptName = __parameter_
    end
end

function b_Goal_Protect:GetMsgKey()
    if Logic.IsEntityAlive(self.ScriptName) then
        local ID = GetID(self.ScriptName)
        if ID and ID ~= 0 then
            ID = Logic.GetEntityType( ID )
            if ID and ID ~= 0 then
                if Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableBuilding ) == 1 then
                    return "Quest_Protect_Building"

                elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.SpecialBuilding ) == 1 then
                    local tMapping = {
                        [PlayerCategories.City]        = "Quest_Protect_City",
                        [PlayerCategories.Cloister]    = "Quest_Protect_Cloister",
                        [PlayerCategories.Village]    = "Quest_Protect_Village",
                    }

                    local PlayerCategory = GetPlayerCategoryType( Logic.EntityGetPlayer(GetID(self.ScriptName)) )
                    if PlayerCategory then
                        local Key = tMapping[PlayerCategory]
                        if Key then
                            return Key
                        end
                    end

                    return "Quest_Protect_Building"

                elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.Hero ) == 1 then
                    return "Quest_Protect_Knight"

                elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableMerchant ) == 1 then
                    return "Quest_Protect_Cart"

                end
            end
        end
    end

    return "Quest_Protect"
end

AddQuestBehavior(b_Goal_Protect);

-- -------------------------------------------------------------------------- --

---
-- Der AUftragnehmer muss eine Mine mit einem Geologen wieder auffüllen.
--
-- Achtung: Ausschließlich im Reich des Ostens verfügbar!
--
-- @param _ScriptName Skriptname der Mine
-- @return table: Behavior
-- @within Goals
--
function Goal_Refill(...)
    return b_Goal_Refill:new(...)
end

b_Goal_Refill = {
    Name = "Goal_Refill",
    Description = {
        en = "Goal: Refill an object using a geologist",
        de = "Ziel: Eine Mine soll durch einen Geologen wieder aufgefuellt werden.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
    },
   RequiresExtraNo = 1,
}

function b_Goal_Refill:GetGoalTable()
    return { Objective.Refill, { GetID(self.ScriptName) } }
end

function b_Goal_Refill:GetIcon()
    return {8,1,1}
end

function b_Goal_Refill:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.ScriptName = __parameter_
    end
end

AddQuestBehavior(b_Goal_Refill);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss eine Menge an Rohstoffen in einer Mine erreichen.
--
-- <u>Relationen</u>
-- <ul>
-- <li>> - Mehr als Anzahl</li>
-- <li>< - Weniger als Anzahl</li>
-- </ul>
--
-- @param _ScriptName Skriptname der Mine
-- @param _Relation   Mengenrelation
-- @param _Amount     Menge an Rohstoffen
-- @return table: Behavior
-- @within Goals
--
function Goal_ResourceAmount(...)
    return b_Goal_ResourceAmount:new(...)
end

b_Goal_ResourceAmount = {
    Name = "Goal_ResourceAmount",
    Description = {
        en = "Goal: Reach a specified amount of resources in a doodad",
        de = "Ziel: In einer Mine soll weniger oder mehr als eine angegebene Anzahl an Rohstoffen sein.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
        { ParameterType.Custom, en = "Relation", de = "Relation" },
        { ParameterType.Number, en = "Amount", de = "Menge" },
    },
}

function b_Goal_ResourceAmount:GetGoalTable(__quest_)
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_ResourceAmount:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.ScriptName = __parameter_
    elseif (__index_ == 1) then
        self.bRelSmallerThan = __parameter_ == "<"
    elseif (__index_ == 2) then
        self.Amount = __parameter_ * 1
    end
end

function b_Goal_ResourceAmount:CustomFunction(__quest_)
    local ID = GetID(self.ScriptName)
    if ID and ID ~= 0 and Logic.GetResourceDoodadGoodType(ID) ~= 0 then
        local HaveAmount = Logic.GetResourceDoodadGoodAmount(ID)
        if ( self.bRelSmallerThan and HaveAmount < self.Amount ) or ( not self.bRelSmallerThan and HaveAmount > self.Amount ) then
            return true
        end
    end
    return nil
end

function b_Goal_ResourceAmount:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 1 then
        table.insert( Data, ">" )
        table.insert( Data, "<" )
    else
        assert( false )
    end
    return Data
end

function b_Goal_ResourceAmount:DEBUG(__quest_)
    if not IsExisting(self.ScriptName) then
        local text = string.format("%s Goal_ResourceAmount: entity %s does not exist!", __quest_.Identifier, self.ScriptName);
        dbg(text);
        return true;
    elseif tonumber(self.Amount) == nil or self.Amount < 0 then
        local text = string.format("%s Goal_ResourceAmount: error at amount! (nil or below 0)", __quest_.Identifier);
        dbg(text);
        return true;
    end
    return false;
end

AddQuestBehavior(b_Goal_ResourceAmount);

-- -------------------------------------------------------------------------- --

---
-- Der Quest schlägt sofort fehl.
--
-- @return table: Behavior
-- @within Goals
--
function Goal_InstantFailure()
    return b_Goal_InstantFailure:new()
end

b_Goal_InstantFailure = {
    Name = "Goal_InstantFailure",
    Description = {
        en = "Instant failure, the goal returns false.",
        de = "Direkter Misserfolg, das Goal sendet false.",
    },
}

function b_Goal_InstantFailure:GetGoalTable(__quest_)
    return {Objective.DummyFail};
end

AddQuestBehavior(b_Goal_InstantFailure);

-- -------------------------------------------------------------------------- --

---
-- Der Quest wird sofort erfüllt. 
--
-- @return table: Behavior
-- @within Goals
--
function Goal_InstantSuccess()
    return b_Goal_InstantSuccess:new()
end

b_Goal_InstantSuccess = {
    Name = "Goal_InstantSuccess",
    Description = {
        en = "Instant success, the goal returns true.",
        de = "Direkter Erfolg, das Goal sendet true.",
    },
}

function b_Goal_InstantSuccess:GetGoalTable(__quest_)
    return {Objective.Dummy};
end

AddQuestBehavior(b_Goal_InstantSuccess);

-- -------------------------------------------------------------------------- --

---
-- Der Zustand des Quests ändert sich niemals
--
-- @return table: Behavior
-- @within Goals
--
function Goal_NoChange()
    return b_Goal_NoChange:new()
end

b_Goal_NoChange = {
    Name = "Goal_NoChange",
    Description = {
        en = "The quest state doesn't change. Use reward functions of other quests to change the state of this quest.",
        de = "Der Questzustand wird nicht veraendert. Ein Reward einer anderen Quest sollte den Zustand dieser Quest veraendern.",
    },
}

function b_Goal_NoChange:GetGoalTable()
    return { Objective.NoChange }
end

AddQuestBehavior(b_Goal_NoChange);

-- -------------------------------------------------------------------------- --

---
-- Führt eine Funktion im Skript als Goal aus.
--
-- Die Funktion muss entweder true, false oder nichts zurückgeben.
-- <ul>
-- <li>true: Erfolgreich abgeschlossen</li>
-- <li>false: Fehlschlag</li>
-- <li>nichts: Zustand unbestimmt</li>
-- </ul>
--
-- @param _FunctionName Name der Funktion
-- @return table: Behavior
-- @within Goals
--
function Goal_MapScriptFunction(...)
    return b_Goal_MapScriptFunction:new(...);
end

b_Goal_MapScriptFunction = {
    Name = "Goal_MapScriptFunction",
    Description = {
        en = "Goal: Calls a function within the global map script. Return 'true' means success, 'false' means failure and 'nil' doesn't change anything.",
        de = "Ziel: Ruft eine Funktion im globalen Skript auf, die einen Wahrheitswert zurueckgibt. Rueckgabe 'true' gilt als erfuellt, 'false' als gescheitert und 'nil' aendert nichts.",
    },
    Parameter = {
        { ParameterType.Default, en = "Function name", de = "Funktionsname" },
    },
}

function b_Goal_MapScriptFunction:GetGoalTable(__quest_)
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_MapScriptFunction:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.FuncName = __parameter_
    end
end

function b_Goal_MapScriptFunction:CustomFunction(__quest_)
    return _G[self.FuncName](self, __quest_);
end

function b_Goal_MapScriptFunction:DEBUG(__quest_)
    if not self.FuncName or not _G[self.FuncName] then
        local text = string.format("%s Goal_MapScriptFunction: function '%s' does not exist!", __quest_.Identifier, tostring(self.FuncName));
        dbg(text);
        return true;
    end
    return false;
end

AddQuestBehavior(b_Goal_MapScriptFunction);

-- -------------------------------------------------------------------------- --

---
-- Eine benutzerdefinierte Variable muss einen bestimmten Wert haben.
--
-- Custom Variables können ausschließlich Zahlen enthalten.
--
-- <p>Vergleichsoperatoren</p>
-- <ul>
-- <li>== - Werte müssen gleich sein</li>
-- <li>~= - Werte müssen ungleich sein</li>
-- <li>> - Variablenwert größer Vergleichswert</li>
-- <li>>= - Variablenwert größer oder gleich Vergleichswert</li>
-- <li>< - Variablenwert kleiner Vergleichswert</li>
-- <li><= - Variablenwert kleiner oder gleich Vergleichswert</li>
-- </ul>
--
-- @param _Name     Name der Variable
-- @param _Relation Vergleichsoperator
-- @param _Value    Wert oder andere Custom Variable mit wert.
-- @return table: Behavior
-- @within Goals
--
function Goal_CustomVariables(...)
    return b_Goal_CustomVariables:new(...);
end

b_Goal_CustomVariables = {
    Name = "Goal_CustomVariables",
    Description = {
        en = "Goal: A customised variable has to assume a certain value.",
        de = "Ziel: Eine benutzerdefinierte Variable muss einen bestimmten Wert annehmen.",
    },
    Parameter = {
        { ParameterType.Default, en = "Name of Variable", de = "Variablenname" },
        { ParameterType.Custom,  en = "Relation", de = "Relation" },
        { ParameterType.Default, en = "Value or variable", de = "Wert oder Variable" }
    }
};

function b_Goal_CustomVariables:GetGoalTable()
    return { Objective.Custom2, {self, self.CustomFunction} };
end

function b_Goal_CustomVariables:AddParameter(__index_, __parameter_)
    if __index_ == 0 then
        self.VariableName = __parameter_
    elseif __index_ == 1 then
        self.Relation = __parameter_
    elseif __index_ == 2 then
        local value = tonumber(__parameter_);
        value = (value ~= nil and value) or tostring(__parameter_);
        self.Value = value
    end
end

function b_Goal_CustomVariables:CustomFunction()
    if _G["QSB_CustomVariables_"..self.VariableName] then
        local Value = (type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value];
        if self.Relation == "==" then
            if _G["QSB_CustomVariables_"..self.VariableName] == Value then
                return true;
            end
        elseif self.Relation == "~=" then
            if _G["QSB_CustomVariables_"..self.VariableName] == Value then
                return true;
            end
        elseif self.Relation == "<" then
            if _G["QSB_CustomVariables_"..self.VariableName] < Value then
                return true;
            end
        elseif self.Relation == "<=" then
            if _G["QSB_CustomVariables_"..self.VariableName] <= Value then
                return true;
            end
        elseif self.Relation == ">=" then
            if _G["QSB_CustomVariables_"..self.VariableName] >= Value then
                return true;
            end
        else
            if _G["QSB_CustomVariables_"..self.VariableName] > Value then
                return true;
            end
        end
    end
    return nil;
end

function b_Goal_CustomVariables:GetCustomData( __index_ )
    return {"==", "~=", "<=", "<", ">", ">="};
end

function b_Goal_CustomVariables:DEBUG(__quest_)
    local relations = {"==", "~=", "<=", "<", ">", ">="}
    local results    = {true, false, nil}

    if not _G["QSB_CustomVariables_"..self.VariableName] then
        dbg(__quest_.Identifier.." "..self.Name..": variable '"..self.VariableName.."' do not exist!");
        return true;
    elseif not Inside(self.Relation,relations) then
        dbg(__quest_.Identifier.." "..self.Name..": '"..self.Relation.."' is an invalid relation!");
        return true;
    end
    return false;
end

AddQuestBehavior(b_Goal_CustomVariables)

-- -------------------------------------------------------------------------- --
-- Reprisal                                                                   --
-- -------------------------------------------------------------------------- --

---
-- Deaktiviert ein interaktives Objekt
--
-- @param _ScriptName Skriptname des interaktiven Objektes
-- @return table: Behavior
-- @within Reprisals
--
function Reprisal_ObjectDeactivate(...)
    return b_Reprisal_ObjectDeactivate:new(...);
end

b_Reprisal_ObjectDeactivate = {
    Name = "Reprisal_ObjectDeactivate",
    Description = {
        en = "Reprisal: Deactivates an interactive object",
        de = "Vergeltung: Deaktiviert ein interaktives Objekt",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Interactive object", de = "Interaktives Objekt" },
    },
}

function b_Reprisal_ObjectDeactivate:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_ObjectDeactivate:AddParameter(__index_, __parameter_)

    if (__index_ == 0) then
        self.ScriptName = __parameter_
    end

end

function b_Reprisal_ObjectDeactivate:CustomFunction(__quest_)
    InteractiveObjectDeactivate(self.ScriptName);
end

function b_Reprisal_ObjectDeactivate:DEBUG(__quest_)
    if not Logic.IsInteractiveObject(GetID(self.ScriptName)) then
        local text = string.format("%s Reprisal_ObjectDeactivate: '%s' is not a interactive object!", __quest_.Identifier, self.ScriptName);
        self.WarningPrinted = true;
        warn(text);
    end
    local eID = GetID(self.ScriptName);
    if QSB.InitalizedObjekts[eID] and QSB.InitalizedObjekts[eID] == __quest_.Identifier then
        dbg(""..__quest_.Identifier.." "..self.Name..": you can not deactivate in the same quest the object is initalized!");
        return true;
    end
    return false;
end

AddQuestBehavior(b_Reprisal_ObjectDeactivate);

-- -------------------------------------------------------------------------- --

---
-- Aktiviert ein interaktives Objekt.
--
-- Der Status bestimmt, wie das objekt aktiviert wird.
-- <ul>
-- <li>0: Kann nur mit Helden aktiviert werden</li>
-- <li>1: Kann immer aktiviert werden</li>
-- </ul>
--
-- @param _ScriptName Skriptname des interaktiven Objektes
-- @param _State Status des Objektes
-- @return table: Behavior
-- @within Reprisals
--
function Reprisal_ObjectActivate(...)
    return b_Reprisal_ObjectActivate:new(...);
end

b_Reprisal_ObjectActivate = {
    Name = "Reprisal_ObjectActivate",
    Description = {
        en = "Reprisal: Activates an interactive object",
        de = "Vergeltung: Aktiviert ein interaktives Objekt",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Interactive object",  de = "Interaktives Objekt" },
        { ParameterType.Custom,     en = "Availability",         de = "Nutzbarkeit" },
    },
}

function b_Reprisal_ObjectActivate:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_ObjectActivate:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.ScriptName = __parameter_
    elseif (__index_ == 1) then
        local parameter = 0
        if __parameter_ == "Always" or 1 then
            parameter = 1
        end
        self.UsingState = parameter
    end
end

function b_Reprisal_ObjectActivate:CustomFunction(__quest_)
    InteractiveObjectActivate(self.ScriptName, self.UsingState);
end

function b_Reprisal_ObjectActivate:GetCustomData( __index_ )
    if __index_ == 1 then
        return {"Knight only", "Always"}
    end
end

function b_Reprisal_ObjectActivate:DEBUG(__quest_)
    if not Logic.IsInteractiveObject(GetID(self.ScriptName)) then
        local text = string.format("%s Goal_IO_ObjectActivate: '%s' is not a interactive object!", __quest_.Identifier, self.ScriptName);
        self.WarningPrinted = true;
        warn(text);
    end
    local eID = GetID(self.ScriptName);
    if QSB.InitalizedObjekts[eID] and QSB.InitalizedObjekts[eID] == __quest_.Identifier then
        dbg(""..__quest_.Identifier.." "..self.Name..": you can not activate in the same quest the object is initalized!");
        return true;
    end
    return false;
end

AddQuestBehavior(b_Reprisal_ObjectActivate);

-- -------------------------------------------------------------------------- --

---
-- Der diplomatische Status zwischen Sender und Empfänger verschlechtert sich
-- um eine Stufe.
--
-- @return table: Behavior
-- @within Reprisals
--
function Reprisal_DiplomacyDecrease()
    return b_Reprisal_DiplomacyDecrease:new();
end

b_Reprisal_DiplomacyDecrease = {
    Name = "Reprisal_DiplomacyDecrease",
    Description = {
        en = "Reprisal: Diplomacy decreases slightly to another player",
        de = "Vergeltung: Der Diplomatiestatus zum Auftraggeber wird um eine Stufe verringert.",
    },
}

function b_Reprisal_DiplomacyDecrease:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_DiplomacyDecrease:CustomFunction(__quest_)
    local Sender = __quest_.SendingPlayer;
    local Receiver = __quest_.ReceivingPlayer;
    local State = GetDiplomacyState(Receiver, Sender);
    if State > -2 then
        SetDiplomacyState(Receiver, Sender, State-1);
    end
end

function b_Reprisal_DiplomacyDecrease:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    end
end

AddQuestBehavior(b_Reprisal_DiplomacyDecrease);

-- -------------------------------------------------------------------------- --

---
-- Änder den Diplomatiestatus zwischen zwei Spielern.
--
-- @param _Party1   ID der ersten Partei
-- @param _Party2   ID der zweiten Partei
-- @param _State    Neuer Diplomatiestatus
-- @return table: Behavior
-- @within Reprisals
--
function Reprisal_Diplomacy(...)
    return b_Reprisal_Diplomacy:new(...);
end

b_Reprisal_Diplomacy = {
    Name = "Reprisal_Diplomacy",
    Description = {
        en = "Reprisal: Sets Diplomacy state of two Players to a stated value.",
        de = "Vergeltung: Setzt den Diplomatiestatus zweier Spieler auf den angegebenen Wert.",
    },
    Parameter = {
        { ParameterType.PlayerID,         en = "PlayerID 1", de = "Spieler 1" },
        { ParameterType.PlayerID,         en = "PlayerID 2", de = "Spieler 2" },
        { ParameterType.DiplomacyState,   en = "Relation",   de = "Beziehung" },
    },
}

function b_Reprisal_Diplomacy:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_Diplomacy:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID1 = __parameter_ * 1
    elseif (__index_ == 1) then
        self.PlayerID2 = __parameter_ * 1
    elseif (__index_ == 2) then
        self.Relation = DiplomacyStates[__parameter_]
    end
end

function b_Reprisal_Diplomacy:CustomFunction(__quest_)
    SetDiplomacyState(self.PlayerID1, self.PlayerID2, self.Relation);
end

function b_Reprisal_Diplomacy:DEBUG(__quest_)
    if not tonumber(self.PlayerID1) or self.PlayerID1 < 1 or self.PlayerID1 > 8 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": PlayerID 1 is invalid!");
        return true;
    elseif not tonumber(self.PlayerID2) or self.PlayerID2 < 1 or self.PlayerID2 > 8 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": PlayerID 2 is invalid!");
        return true;
    elseif not tonumber(self.Relation) or self.Relation < -2 or self.Relation > 2 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": '"..self.Relation.."' is a invalid diplomacy state!");
        return true;
    end
    return false;
end

AddQuestBehavior(b_Reprisal_Diplomacy);

-- -------------------------------------------------------------------------- --

---
-- Ein benanntes Entity wird zerstört.
--
-- @param _ScriptName Skriptname des Entity
-- @return table: Behavior
-- @within Reprisals
--
function Reprisal_DestroyEntity(...)
    return b_Reprisal_DestroyEntity:new(...);
end

b_Reprisal_DestroyEntity = {
    Name = "Reprisal_DestroyEntity",
    Description = {
        en = "Reprisal: Replaces an entity with an invisible script entity, which retains the entities name.",
        de = "Vergeltung: Ersetzt eine Entity mit einer unsichtbaren Script-Entity, die den Namen uebernimmt.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity", de = "Entity" },
    },
}

function b_Reprisal_DestroyEntity:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_DestroyEntity:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.ScriptName = __parameter_
    end
end

function b_Reprisal_DestroyEntity:CustomFunction(__quest_)
    ReplaceEntity(self.ScriptName, Entities.XD_ScriptEntity);
end

function b_Reprisal_DestroyEntity:DEBUG(__quest_)
    if not IsExisting(self.ScriptName) then
        local text = string.format("%s Reprisal_DestroyEntity: '%s' is already destroyed!", __quest_.Identifier, self.ScriptName);
        self.WarningPrinted = true;
        warn(text);
    end
    return false;
end

AddQuestBehavior(b_Reprisal_DestroyEntity);

-- -------------------------------------------------------------------------- --

---
-- Zerstört einen über die QSB erzeugten Effekt.
--
-- @param _EffectName Name des Effekts
-- @return table: Behavior
-- @within Reprisals
--
function Reprisal_DestroyEffect(...)
    return b_Reprisal_DestroyEffect:new(...);
end

b_Reprisal_DestroyEffect = {
    Name = "Reprisal_DestroyEffect",
    Description = {
        en = "Reprisal: Destroys an effect",
        de = "Vergeltung: Zerstoert einen Effekt",
    },
    Parameter = {
        { ParameterType.Default, en = "Effect name", de = "Effektname" },
    }
}

function b_Reprisal_DestroyEffect:AddParameter(__index_, __parameter_)
    if __index_ == 0 then
        self.EffectName = __parameter_;
    end
end

function b_Reprisal_DestroyEffect:GetReprisalTable()
    return { Reprisal.Custom, { self, self.CustomFunction } };
end

function b_Reprisal_DestroyEffect:CustomFunction(__quest_)
    if not QSB.EffectNameToID[self.EffectName] or not Logic.IsEffectRegistered(QSB.EffectNameToID[self.EffectName]) then
        return;
    end
    Logic.DestroyEffect(QSB.EffectNameToID[self.EffectName]);
end

function b_Reprisal_DestroyEffect:DEBUG(__quest_)
    if not QSB.EffectNameToID[self.EffectName] then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Effect " .. self.EffectName .. " never created")
    end
    return false;
end

AddQuestBehavior(b_Reprisal_DestroyEffect);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler verliert das Spiel.
--
-- @return table: behavior
-- @within Reprisals
--
function Reprisal_Defeat()
    return b_Reprisal_Defeat:new()
end

b_Reprisal_Defeat = {
    Name = "Reprisal_Defeat",
    Description = {
        en = "Reprisal: The player loses the game.",
        de = "Vergeltung: Der Spieler verliert das Spiel.",
    },
}

function b_Reprisal_Defeat:GetReprisalTable(__quest_)
    return {Reprisal.Defeat};
end

AddQuestBehavior(b_Reprisal_Defeat);

-- -------------------------------------------------------------------------- --

---
-- Zeigt die Niederlagedekoration am Quest an.
--
-- Es handelt sich dabei um reine Optik! Der Spieler wird nicht verlieren.
--
-- @return table: behavior
-- @within Reprisals
--
function Reprisal_FakeDefeat()
    return b_Reprisal_FakeDefeat:new();
end

b_Reprisal_FakeDefeat = {
    Name = "Reprisal_FakeDefeat",
    Description = {
        en = "Reprisal: Displays a defeat icon for a quest",
        de = "Vergeltung: Zeigt ein Niederlage Icon fuer eine Quest an",
    },
}

function b_Reprisal_FakeDefeat:GetReprisalTable()
    return { Reprisal.FakeDefeat }
end

-- -------------------------------------------------------------------------- --

---
-- Ein Entity wird durch ein neues anderen Typs ersetzt.
--
-- Das neue Entity übernimmt Skriptname und Ausrichtung des alten Entity.
--
-- @param _Entity Skriptname oder ID des Entity
-- @param _Type   Neuer Typ des Entity
-- @param _Owner  Besitzer des Entity
-- @return table: behavior
-- @within Reprisals
--
function Reprisal_ReplaceEntity(...)
    return b_Reprisal_ReplaceEntity:new(...);
end

b_Reprisal_ReplaceEntity = {
    Name = "Reprisal_ReplaceEntity",
    Description = {
        en = "Reprisal: Replaces an entity with a new one of a different type. The playerID can be changed too.",
        de = "Vergeltung: Ersetzt eine Entity durch eine neue anderen Typs. Es kann auch die Spielerzugehoerigkeit geaendert werden.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Target", de = "Ziel" },
        { ParameterType.Custom, en = "New Type", de = "Neuer Typ" },
        { ParameterType.Custom, en = "New playerID", de = "Neue Spieler ID" },
    },
}

function b_Reprisal_ReplaceEntity:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_ReplaceEntity:AddParameter(__index_, __parameter_)
   if (__index_ == 0) then
        self.ScriptName = __parameter_
    elseif (__index_ == 1) then
        self.NewType = __parameter_
    elseif (__index_ == 2) then
        self.PlayerID = tonumber(__parameter_);
    end
end

function b_Reprisal_ReplaceEntity:CustomFunction(__quest_)
    local eID = GetID(self.ScriptName);
    local pID = self.PlayerID;
    if pID == Logic.EntityGetPlayer(eID) then
        pID = nil;
    end
    ReplaceEntity(self.ScriptName, Entities[self.NewType], pID);
end

function b_Reprisal_ReplaceEntity:GetCustomData(__index_)
    local Data = {}
    if __index_ == 1 then
        for k, v in pairs( Entities ) do
            local name = {"^M_","^XS_","^X_","^XT_","^Z_", "^XB_"}
            local found = false;
            for i=1,#name do
                if k:find(name[i]) then
                    found = true;
                    break;
                end
            end
            if not found then
                table.insert( Data, k );
            end
        end
        table.sort( Data )
    elseif __index_ == 2 then
        Data = {"-","0","1","2","3","4","5","6","7","8",}
    end
    return Data
end

function b_Reprisal_ReplaceEntity:DEBUG(__quest_)
    if not Entities[self.NewType] then
        dbg(__quest_.Identifier.." "..self.Name..": got an invalid entity type!");
        return true;
    elseif self.PlayerID ~= nil and (self.PlayerID < 1 or self.PlayerID > 8) then
        dbg(__quest_.Identifier.." "..self.Name..": got an invalid playerID!");
        return true;
    end

    if not IsExisting(self.ScriptName) then
        self.WarningPrinted = true;
        warn(__quest_.Identifier.." "..self.Name..": '%s' does not exist!");
    end
    return false;
end

AddQuestBehavior(b_Reprisal_ReplaceEntity);

-- -------------------------------------------------------------------------- --

---
-- Startet einen Quest neu.
--
-- @param _QuestName Name des Quest
-- @return table: Behavior
-- @within Reprisals
--
function Reprisal_QuestRestart(...)
    return b_Reprisal_QuestRestart(...)
end

b_Reprisal_QuestRestart = {
    Name = "Reprisal_QuestRestart",
    Description = {
        en = "Reprisal: Restarts a (completed) quest so it can be triggered and completed again",
        de = "Vergeltung: Startet eine (beendete) Quest neu, damit diese neu ausgeloest und beendet werden kann",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Questname" },
    },
}

function b_Reprisal_QuestRestart:GetReprisalTable(__quest_)
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_QuestRestart:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.QuestName = __parameter_
    end
end

function b_Reprisal_QuestRestart:CustomFunction(__quest_)
    self:ResetQuest();
end

function b_Reprisal_QuestRestart:DEBUG(__quest_)
    if not Quests[GetQuestID(self.QuestName)] then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": quest "..  self.QuestName .. " does not exist!")
        return true
    end
end

function b_Reprisal_QuestRestart:ResetQuest()
    RestartQuestByName(self.QuestName);
end

AddQuestBehavior(b_Reprisal_QuestRestart);

-- -------------------------------------------------------------------------- --

---
-- Lässt einen Quest fehlschlagen.
--
-- @param _QuestName Name des Quest
-- @return table: Behavior
-- @within Reprisals
--
function Reprisal_QuestFailure(...)
    return b_Reprisal_QuestFailure(...)
end

b_Reprisal_QuestFailure = {
    Name = "Reprisal_QuestFailure",
    Description = {
        en = "Reprisal: Lets another active quest fail",
        de = "Vergeltung: Laesst eine andere aktive Quest fehlschlagen",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Questname" },
    },
}

function b_Reprisal_QuestFailure:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_QuestFailure:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.QuestName = __parameter_
    end
end

function b_Reprisal_QuestFailure:CustomFunction(__quest_)
    FailQuestByName(self.QuestName);
end

function b_Reprisal_QuestFailure:DEBUG(__quest_)
    if not Quests[GetQuestID(self.QuestName)] then
        local text = string.format("%s b_Reprisal_QuestFailure: got an invalid quest!", __quest_.Identifier);
        dbg(text);
        return true;
    end
    return false;
end

AddQuestBehavior(b_Reprisal_QuestFailure);

-- -------------------------------------------------------------------------- --

---
-- Wertet einen Quest als erfolgreich.
--
-- @param _QuestName Name des Quest
-- @return table: Behavior
-- @within Reprisals
--
function Reprisal_QuestSuccess(...)
    return b_Reprisal_QuestSuccess(...)
end

b_Reprisal_QuestSuccess = {
    Name = "Reprisal_QuestSuccess",
    Description = {
        en = "Reprisal: Completes another active quest successfully",
        de = "Vergeltung: Beendet eine andere aktive Quest erfolgreich",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Questname" },
    },
}

function b_Reprisal_QuestSuccess:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_QuestSuccess:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.QuestName = __parameter_
    end
end

function b_Reprisal_QuestSuccess:CustomFunction(__quest_)
    WinQuestByName(self.QuestName);
end

function b_Reprisal_QuestSuccess:DEBUG(__quest_)
    if not Quests[GetQuestID(self.QuestName)] then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": quest "..  self.QuestName .. " does not exist!")
        return true
    end
    return false;
end

AddQuestBehavior(b_Reprisal_QuestSuccess);

-- -------------------------------------------------------------------------- --

---
-- Triggert einen Quest.
--
-- @param _QuestName Name des Quest
-- @return table: Behavior
-- @within Reprisals
--
function Reprisal_QuestActivate(...)
    return b_Reprisal_QuestActivate(...)
end

b_Reprisal_QuestActivate = {
    Name = "Reprisal_QuestActivate",
    Description = {
        en = "Reprisal: Activates another quest that is not triggered yet.",
        de = "Vergeltung: Aktiviert eine andere Quest die noch nicht ausgeloest wurde.",
                },
    Parameter = {
        {ParameterType.QuestName, en = "Quest name", de = "Questname", },
    },
}

function b_Reprisal_QuestActivate:GetReprisalTable()
    return {Reprisal.Custom, {self, self.CustomFunction} }
end

function b_Reprisal_QuestActivate:AddParameter(_Index, _Parameter)
    if (_Index==0) then
        self.QuestName = _Parameter
    else
        assert(false, "Error in " .. self.Name .. ": AddParameter: Index is invalid")
    end
end

function b_Reprisal_QuestActivate:CustomFunction(_Quest)
    StartQuestByName(self.QuestName);
end

function b_Reprisal_QuestActivate:DEBUG(_Quest)
    if not IsValidQuest(self.QuestName) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Quest: "..  self.QuestName .. " does not exist")
        return true
    end
end

AddQuestBehavior(b_Reprisal_QuestActivate)

-- -------------------------------------------------------------------------- --

---
-- Unterbricht einen Quest.
--
-- @param _QuestName Name des Quest
-- @return table: Behavior
-- @within Reprisals
--
function Reprisal_QuestInterrupt(...)
    return b_Reprisal_QuestInterrupt(...)
end

b_Reprisal_QuestInterrupt = {
    Name = "Reprisal_QuestInterrupt",
    Description = {
        en = "Reprisal: Interrupts another active quest without success or failure",
        de = "Vergeltung: Beendet eine andere aktive Quest ohne Erfolg oder Misserfolg",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Questname" },
    },
}

function b_Reprisal_QuestInterrupt:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_QuestInterrupt:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.QuestName = __parameter_
    end
end

function b_Reprisal_QuestInterrupt:CustomFunction(__quest_)
    if (GetQuestID(self.QuestName) ~= nil) then

        local QuestID = GetQuestID(self.QuestName)
        local Quest = Quests[QuestID]
        if Quest.State == QuestState.Active then
            StopQuestByName(self.QuestName);
        end
    end
end

function b_Reprisal_QuestInterrupt:DEBUG(__quest_)
    if not Quests[GetQuestID(self.QuestName)] then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": quest "..  self.QuestName .. " does not exist!")
        return true
    end
    return false;
end

AddQuestBehavior(b_Reprisal_QuestInterrupt);

-- -------------------------------------------------------------------------- --

---
-- Unterbricht einen Quest, selbst wenn dieser noch nicht ausgelöst wurde.
--
-- @param _QuestName   Name des Quest
-- @param _EndetQuests Bereits beendete unterbrechen
-- @return table: Behavior
-- @within Reprisals
--
function Reprisal_QuestForceInterrupt(...)
    return b_Reprisal_QuestForceInterrupt(...)
end

b_Reprisal_QuestForceInterrupt = {
    Name = "Reprisal_QuestForceInterrupt",
    Description = {
        en = "Reprisal: Interrupts another quest (even when it isn't active yet) without success or failure",
        de = "Vergeltung: Beendet eine andere Quest, auch wenn diese noch nicht aktiv ist ohne Erfolg oder Misserfolg",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Questname" },
        { ParameterType.Custom, en = "Ended quests", de = "Beendete Quests" },
    },
}

function b_Reprisal_QuestForceInterrupt:GetReprisalTable()

    return { Reprisal.Custom,{self, self.CustomFunction} }

end

function b_Reprisal_QuestForceInterrupt:AddParameter(__index_, __parameter_)

    if (__index_ == 0) then
        self.QuestName = __parameter_
    elseif (__index_ == 1) then
        self.InterruptEnded = AcceptAlternativeBoolean(__parameter_)
    end

end

function b_Reprisal_QuestForceInterrupt:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 1 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    else
        assert( false )
    end
    return Data
end
function b_Reprisal_QuestForceInterrupt:CustomFunction(__quest_)
    if (GetQuestID(self.QuestName) ~= nil) then

        local QuestID = GetQuestID(self.QuestName)
        local Quest = Quests[QuestID]
        if self.InterruptEnded or Quest.State ~= QuestState.Over then
            Quest:Interrupt()
        end
    end
end

function b_Reprisal_QuestForceInterrupt:DEBUG(__quest_)
    if not Quests[GetQuestID(self.QuestName)] then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": quest "..  self.QuestName .. " does not exist!")
        return true;
    end
    return false;
end

AddQuestBehavior(b_Reprisal_QuestForceInterrupt);

-- -------------------------------------------------------------------------- --

---
-- Führt eine Funktion im Skript als Reprisal aus.
--
-- @param _FunctionName Name der Funktion
-- @return table: Behavior
-- @within Reprisals
--
function Reprisal_MapScriptFunction(...)
    return b_Reprisal_MapScriptFunction:new(...);
end

b_Reprisal_MapScriptFunction = {
    Name = "Reprisal_MapScriptFunction",
    Description = {
        en = "Reprisal: Calls a function within the global map script if the quest has failed.",
        de = "Vergeltung: Ruft eine Funktion im globalen Kartenskript auf, wenn die Quest fehlschlaegt.",
    },
    Parameter = {
        { ParameterType.Default, en = "Function name", de = "Funktionsname" },
    },
}

function b_Reprisal_MapScriptFunction:GetReprisalTable(__quest_)
    return {Reprisal.Custom, {self, self.CustomFunction}};
end

function b_Reprisal_MapScriptFunction:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.FuncName = __parameter_
    end
end

function b_Reprisal_MapScriptFunction:CustomFunction(__quest_)
    return _G[self.FuncName](self, __quest_);
end

function b_Reprisal_MapScriptFunction:DEBUG(__quest_)
    if not self.FuncName or not _G[self.FuncName] then
        local text = string.format("%s Reprisal_MapScriptFunction: function '%s' does not exist!", __quest_.Identifier, tostring(self.FuncName));
        dbg(text);
        return true;
    end
    return false;
end

AddQuestBehavior(b_Reprisal_MapScriptFunction);

-- -------------------------------------------------------------------------- --

---
-- Ändert den Wert einer benutzerdefinierten Variable.
--
-- Benutzerdefinierte Variablen können ausschließlich Zahlen sein.
--
---- <p>Operatoren</p>
-- <ul>
-- <li>= - Variablenwert wird auf den Wert gesetzt</li>
-- <li>- - Variablenwert mit Wert Subtrahieren</li>
-- <li>+ - Variablenwert mit Wert addieren</li>
-- <li>* - Variablenwert mit Wert multiplizieren</li>
-- <li>/ - Variablenwert mit Wert dividieren</li>
-- <li>^ - Variablenwert mit Wert potenzieren</li>
-- </ul>
--
-- @param _Name     Name der Variable
-- @param _Operator Rechen- oder Zuweisungsoperator
-- @param _Value    Wert oder andere Custom Variable
-- @return table: Behavior
-- @within Reprisals
--
function Reprisal_CustomVariables(...)
    return b_Reprisal_CustomVariables:new(...);
end

b_Reprisal_CustomVariables = {
    Name = "Reprisal_CustomVariables",
    Description = {
        en = "Reprisal: Executes a mathematical operation with this variable. The other operand can be a number or another custom variable.",
        de = "Vergeltung: Fuehrt eine mathematische Operation mit der Variable aus. Der andere Operand kann eine Zahl oder eine Custom-Varible sein.",
    },
    Parameter = {
        { ParameterType.Default, en = "Name of variable", de = "Variablenname" },
        { ParameterType.Custom,  en = "Operator", de = "Operator" },
        { ParameterType.Default,  en = "Value or variable", de = "Wert oder Variable" }
    }
};

function b_Reprisal_CustomVariables:GetReprisalTable()
    return { Reprisal.Custom, {self, self.CustomFunction} };
end

function b_Reprisal_CustomVariables:AddParameter(__index_, __parameter_)
    if __index_ == 0 then
        self.VariableName = __parameter_
    elseif __index_ == 1 then
        self.Operator = __parameter_
    elseif __index_ == 2 then
        local value = tonumber(__parameter_);
        value = (value ~= nil and value) or tostring(__parameter_);
        self.Value = value
    end
end

function b_Reprisal_CustomVariables:CustomFunction()
    _G["QSB_CustomVariables_"..self.VariableName] = _G["QSB_CustomVariables_"..self.VariableName] or 0;
    local oldValue = _G["QSB_CustomVariables_"..self.VariableName];

    if self.Operator == "=" then
        _G["QSB_CustomVariables_"..self.VariableName] = (type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value];
    elseif self.Operator == "+" then
        _G["QSB_CustomVariables_"..self.VariableName] = oldValue + (type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value];
    elseif self.Operator == "-" then
        _G["QSB_CustomVariables_"..self.VariableName] = oldValue - (type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value];
    elseif self.Operator == "*" then
        _G["QSB_CustomVariables_"..self.VariableName] = oldValue * (type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value];
    elseif self.Operator == "/" then
        _G["QSB_CustomVariables_"..self.VariableName] = oldValue / (type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value];
    elseif self.Operator == "^" then
        _G["QSB_CustomVariables_"..self.VariableName] = oldValue ^ (type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value];

    end
end

function b_Reprisal_CustomVariables:GetCustomData( __index_ )
    return {"=", "+", "-", "*", "/", "^"};
end

function b_Reprisal_CustomVariables:DEBUG(__quest_)
    local operators = {"=", "+", "-", "*", "/", "^"};
    if not Inside(self.Operator,operators) then
        dbg(__quest_.Identifier.." "..self.Name..": got an invalid operator!");
        return true;
    elseif self.VariableName == "" then
        dbg(__quest_.Identifier.." "..self.Name..": missing name for variable!");
        return true;
    end
    return false;
end

AddQuestBehavior(b_Reprisal_CustomVariables)

-- -------------------------------------------------------------------------- --
-- Rewards                                                                    --
-- -------------------------------------------------------------------------- --

---
-- Deaktiviert ein interaktives Objekt
--
-- @param _ScriptName Skriptname des interaktiven Objektes
-- @return table: Behavior
-- @within Rewards
--
function Reward_ObjectDeactivate(...)
    return b_Reward_ObjectDeactivate:new(...);
end

b_Reward_ObjectDeactivate = API.InstanceTable(b_Reprisal_ObjectDeactivate);
b_Reward_ObjectDeactivate.Name             = "Reward_ObjectDeactivate";
b_Reward_ObjectDeactivate.Description.de   = "Reward: Deactivates an interactive object";
b_Reward_ObjectDeactivate.Description.en   = "Lohn: Deaktiviert ein interaktives Objekt";
b_Reward_ObjectDeactivate.GetReprisalTable = nil;

b_Reward_ObjectDeactivate.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

AddQuestBehavior(b_Reward_ObjectDeactivate);

-- -------------------------------------------------------------------------- --

---
-- Aktiviert ein interaktives Objekt.
--
-- Der Status bestimmt, wie das objekt aktiviert wird.
-- <ul>
-- <li>0: Kann nur mit Helden aktiviert werden</li>
-- <li>1: Kann immer aktiviert werden</li>
-- </ul>
--
-- @param _ScriptName Skriptname des interaktiven Objektes
-- @param _State Status des Objektes
-- @return table: Behavior
-- @within Rewards
--
function Reward_ObjectActivate(...)
    return Reward_ObjectActivate:new(...);
end

b_Reward_ObjectActivate = API.InstanceTable(b_Reprisal_ObjectActivate);
b_Reward_ObjectActivate.Name             = "Reward_ObjectActivate";
b_Reward_ObjectActivate.Description.de   = "Reward: Activates an interactive object";
b_Reward_ObjectActivate.Description.en   = "Lohn: Aktiviert ein interaktives Objekt";
b_Reward_ObjectActivate.GetReprisalTable = nil;

b_Reward_ObjectActivate.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} };
end

AddQuestBehavior(b_Reward_ObjectActivate);

-- -------------------------------------------------------------------------- --

---
-- Initialisiert ein interaktives Objekt.
--
-- Interaktive Objekte können Kosten und Belohnungen enthalten, müssen sie
-- jedoch nicht. Ist eine Wartezeit angegeben, kann das Objekt erst nach
-- Ablauf eines Cooldowns benutzt werden.
--
-- @param _ScriptName Skriptname des interaktiven Objektes
-- @param _Distance   Entfernung zur Aktivierung
-- @param _Time       Wartezeit bis zur Aktivierung
-- @param _RType1     Warentyp der Belohnung
-- @param _RAmount    Menge der Belohnung
-- @param _CType1     Typ der 1. Ware
-- @param _CAmount1   Menge der 1. Ware
-- @param _CType2     Typ der 2. Ware
-- @param _CAmount2   Menge der 2. Ware
-- @param _Status     Aktivierung (0: Held, 1: immer, 2: niemals)
-- @return table: Behavior
-- @within Rewards
--
function Reward_ObjectInit(...)
    return Reward_ObjectInit:new(...);
end

b_Reward_ObjectInit = {
    Name = "Reward_ObjectInit",
    Description = {
        en = "Reward: Setup an interactive object with costs and rewards.",
        de = "Lohn: Initialisiert ein interaktives Objekt mit seinen Kosten und Schaetzen.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Interactive object",     de = "Interaktives Objekt" },
        { ParameterType.Number,     en = "Distance to use",     de = "Nutzungsentfernung" },
        { ParameterType.Number,     en = "Waittime",             de = "Wartezeit" },
        { ParameterType.Custom,     en = "Reward good",         de = "Belohnungsware" },
        { ParameterType.Number,     en = "Reward amount",         de = "Anzahl" },
        { ParameterType.Custom,     en = "Cost good 1",         de = "Kostenware 1" },
        { ParameterType.Number,     en = "Cost amount 1",         de = "Anzahl 1" },
        { ParameterType.Custom,     en = "Cost good 2",         de = "Kostenware 2" },
        { ParameterType.Number,     en = "Cost amount 2",         de = "Anzahl 2" },
        { ParameterType.Custom,     en = "Availability",         de = "Verfï¿½gbarkeit" },
    },
}

function b_Reward_ObjectInit:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_ObjectInit:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.ScriptName = __parameter_
    elseif (__index_ == 1) then
        self.Distance = __parameter_ * 1
    elseif (__index_ == 2) then
        self.Waittime = __parameter_ * 1
    elseif (__index_ == 3) then
        self.RewardType = __parameter_
    elseif (__index_ == 4) then
        self.RewardAmount = tonumber(__parameter_)
    elseif (__index_ == 5) then
        self.FirstCostType = __parameter_
    elseif (__index_ == 6) then
        self.FirstCostAmount = tonumber(__parameter_)
    elseif (__index_ == 7) then
        self.SecondCostType = __parameter_
    elseif (__index_ == 8) then
        self.SecondCostAmount = tonumber(__parameter_)
    elseif (__index_ == 9) then
        local parameter = nil
        if __parameter_ == "Always" or 1 then
            parameter = 1
        elseif __parameter_ == "Never" or 2 then
            parameter = 2
        elseif __parameter_ == "Knight only" or 0 then
            parameter = 0
        end
        self.UsingState = parameter
    end
end

function b_Reward_ObjectInit:CustomFunction(__quest_)
    local eID = GetID(self.ScriptName);
    if eID == 0 then
        return;
    end
    QSB.InitalizedObjekts[eID] = __quest_.Identifier;

    Logic.InteractiveObjectClearCosts(eID);
    Logic.InteractiveObjectClearRewards(eID);

    Logic.InteractiveObjectSetInteractionDistance(eID, self.Distance);
    Logic.InteractiveObjectSetTimeToOpen(eID, self.Waittime);

    if self.RewardType and self.RewardType ~= "disabled" then
        Logic.InteractiveObjectAddRewards(eID, Goods[self.RewardType], self.RewardAmount);
    end
    if self.FirstCostType and self.FirstCostType ~= "disabled" then
        Logic.InteractiveObjectAddCosts(eID, Goods[self.FirstCostType], self.FirstCostAmount);
    end
    if self.SecondCostType and self.SecondCostType ~= "disabled" then
        Logic.InteractiveObjectAddCosts(eID, Goods[self.SecondCostType], self.SecondCostAmount);
    end

    Logic.InteractiveObjectSetAvailability(eID,true);
    if self.UsingState then
        for i=1, 8 do
            Logic.InteractiveObjectSetPlayerState(eID,i, self.UsingState);
        end
    end

    Logic.InteractiveObjectSetRewardResourceCartType(eID,Entities.U_ResourceMerchant);
    Logic.InteractiveObjectSetRewardGoldCartType(eID,Entities.U_GoldCart);
    Logic.InteractiveObjectSetCostResourceCartType(eID,Entities.U_ResourceMerchant);
    Logic.InteractiveObjectSetCostGoldCartType(eID, Entities.U_GoldCart);
    RemoveInteractiveObjectFromOpenedList(eID);
    table.insert(HiddenTreasures,eID);
end

function b_Reward_ObjectInit:GetCustomData( __index_ )
    if __index_ == 3 or __index_ == 5 or __index_ == 7 then
        local Data = {
            "-",
            "G_Beer",
            "G_Bread",
            "G_Broom",
            "G_Carcass",
            "G_Cheese",
            "G_Clothes",
            "G_Dye",
            "G_Gold",
            "G_Grain",
            "G_Herb",
            "G_Honeycomb",
            "G_Iron",
            "G_Leather",
            "G_Medicine",
            "G_Milk",
            "G_RawFish",
            "G_Salt",
            "G_Sausage",
            "G_SmokedFish",
            "G_Soap",
            "G_Stone",
            "G_Water",
            "G_Wood",
            "G_Wool",
        }

        if g_GameExtraNo >= 1 then
            Data[#Data+1] = "G_Gems"
            Data[#Data+1] = "G_MusicalInstrument"
            Data[#Data+1] = "G_Olibanum"
        end
        return Data
    elseif __index_ == 9 then
        return {"-", "Knight only", "Always", "Never",}
    end
end

function b_Reward_ObjectInit:DEBUG(__quest_)
    if Logic.IsInteractiveObject(GetID(self.ScriptName)) == false then
        dbg("Reward_ObjectInit "..__quest_.Identifier..": '"..self.ScriptName.."' is not a interactive object!");
        return true;
    end
    if self.UsingState ~= 1 and self.Distance < 50 then
        warn(""..__quest_.Identifier.." "..self.Name..": distance is maybe too short!");
    end
    if self.Waittime < 0 then
        dbg(""..__quest_.Identifier.." "..self.Name..": waittime must be equal or greater than 0!");
        return true;
    end
    if self.RewardType and self.RewardType ~= "-" then
        if not Goods[self.RewardType] then
            dbg(""..__quest_.Identifier.." "..self.Name..": '"..self.RewardType.."' is invalid good type!");
            return true;
        elseif self.RewardAmount < 1 then
            dbg(""..__quest_.Identifier.." "..self.Name..": amount can not be 0 or negative!");
            return true;
        end
    end
    if self.FirstCostType and self.FirstCostType ~= "-" then
        if not Goods[self.FirstCostType] then
            dbg(""..__quest_.Identifier.." "..self.Name..": '"..self.FirstCostType.."' is invalid good type!");
            return true;
        elseif self.FirstCostAmount < 1 then
            dbg(""..__quest_.Identifier.." "..self.Name..": amount can not be 0 or negative!");
            return true;
        end
    end
    if self.SecondCostType and self.SecondCostType ~= "-" then
        if not Goods[self.SecondCostType] then
            dbg(""..__quest_.Identifier.." "..self.Name..": '"..self.SecondCostType.."' is invalid good type!");
            return true;
        elseif self.SecondCostAmount < 1 then
            dbg(""..__quest_.Identifier.." "..self.Name..": amount can not be 0 or negative!");
            return true;
        end
    end
    return false;
end

AddQuestBehavior(b_Reward_ObjectInit);

-- -------------------------------------------------------------------------- --

---
-- Setzt die benutzten Wagen eines interaktiven Objektes.
--
-- In der Regel ist das Setzen der Wagen unnötig, da die voreingestellten
-- Wagen ausreichen. Will man aber z.B. eine Kutsche fahren lassen, dann
-- muss der Wagentyp geändert werden.
--
-- @param _ScriptName           Skriptname des Objektes
-- @param _CostResourceType     Wagen für Rohstoffkosten
-- @param _CostGoldType         Wagen für Goldkosten
-- @param _RewResourceType      Wagen für Rohstofflieferung
-- @param _RewGoldType          Wagen für Goldlieferung
-- @return table: Behavior
-- @within Rewards
--
function Reward_ObjectSetCarts(...)
    return b_Reward_ObjectSetCarts:new(...);
end

b_Reward_ObjectSetCarts = {
    Name = "Reward_ObjectSetCarts",
    Description = {
        en = "Reward: Set the cart types of an interactive object.",
        de = "Lohn: Setzt die Wagentypen eines interaktiven Objektes.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Interactive object",         de = "Interaktives Objekt" },
        { ParameterType.Default,     en = "Cost resource type",         de = "Rohstoffwagen Kosten" },
        { ParameterType.Default,     en = "Cost gold type",             de = "Goldwagen Kosten" },
        { ParameterType.Default,     en = "Reward resource type",     de = "Rohstoffwagen Schatz" },
        { ParameterType.Default,     en = "Reward gold type",         de = "Goldwagen Schatz" },
    },
}

function b_Reward_ObjectSetCarts:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_ObjectSetCarts:AddParameter(__index_, __parameter_)
    if __index_ == 0 then
        self.ScriptName = __parameter_
    elseif __index_ == 1 then
        if not __parameter_ or __parameter_ == "default" then
            __parameter_ = "U_ResourceMerchant";
        end
        self.CostResourceCart = __parameter_
    elseif __index_ == 2 then
        if not __parameter_ or __parameter_ == "default" then
            __parameter_ = "U_GoldCart";
        end
        self.CostGoldCart = __parameter_
    elseif __index_ == 3 then
        if not __parameter_ or __parameter_ == "default" then
            __parameter_ = "U_ResourceMerchant";
        end
        self.RewardResourceCart = __parameter_
    elseif __index_ == 4 then
        if not __parameter_ or __parameter_ == "default" then
            __parameter_ = "U_GoldCart";
        end
        self.RewardGoldCart = __parameter_
    end
end

function b_Reward_ObjectSetCarts:CustomFunction(__quest_)
    local eID = GetID(self.ScriptName);
    Logic.InteractiveObjectSetRewardResourceCartType(eID, Entities[self.RewardResourceCart]);
    Logic.InteractiveObjectSetRewardGoldCartType(eID, Entities[self.RewardGoldCart]);
    Logic.InteractiveObjectSetCostGoldCartType(eID, Entities[self.CostResourceCart]);
    Logic.InteractiveObjectSetCostResourceCartType(eID, Entities[self.CostGoldCart]);
end

function b_Reward_ObjectSetCarts:GetCustomData( __index_ )
    if __index_ == 2 or __index_ == 4 then
        return {"U_GoldCart", "U_GoldCart_Mission", "U_Noblemen_Cart", "U_RegaliaCart"}
    elseif __index_ == 1 or __index_ == 3 then
        local Data = {"U_ResourceMerchant", "U_Medicus", "U_Marketer"}
        if g_GameExtraNo > 0 then
            table.insert(Data, "U_NPC_Resource_Monk_AS");
        end
        return Data;
    end
end

function b_Reward_ObjectSetCarts:DEBUG(__quest_)
    if (not Entities[self.CostResourceCart]) or (not Entities[self.CostGoldCart])
    or (not Entities[self.RewardResourceCart]) or (not Entities[self.RewardGoldCart]) then
        dbg(""..__quest_.Identifier.." "..self.Name..": invalid cart type!");
        return true;
    end

    local eID = GetID(self.ScriptName);
    if QSB.InitalizedObjekts[eID] and QSB.InitalizedObjekts[eID] == __quest_.Identifier then
        dbg(""..__quest_.Identifier.." "..self.Name..": you can not change carts in the same quest the object is initalized!");
        return true;
    end
    return false;
end

AddQuestBehavior(b_Reward_ObjectSetCarts);

-- -------------------------------------------------------------------------- --

---
-- Änder den Diplomatiestatus zwischen zwei Spielern.
--
-- @param _Party1   ID der ersten Partei
-- @param _Party2   ID der zweiten Partei
-- @param _State    Neuer Diplomatiestatus
-- @return table: Behavior
-- @within Rewards
--
function Reward_Diplomacy(...)
    return b_Reward_Diplomacy:new(...);
end

b_Reward_Diplomacy = API.InstanceTable(b_Reprisal_Diplomacy);
b_Reward_Diplomacy.Name             = "Reward_ObjectDeactivate";
b_Reward_Diplomacy.Description.de   = "Reward: Sets Diplomacy state of two Players to a stated value.";
b_Reward_Diplomacy.Description.en   = "Lohn: Setzt den Diplomatiestatus zweier Spieler auf den angegebenen Wert.";
b_Reward_Diplomacy.GetReprisalTable = nil;

b_Reward_ObjectDeactivate.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

AddQuestBehavior(b_Reward_Diplomacy);

-- -------------------------------------------------------------------------- --

---
-- Verbessert die diplomatischen Beziehungen zwischen Sender und Empfänger
-- um einen Grad.
--
-- @return table: Behavior
-- @within Rewards
--
function Reward_DiplomacyIncrease()
    return b_Reward_DiplomacyIncrease:new();
end

b_Reward_DiplomacyIncrease = {
    Name = "Reward_DiplomacyIncrease",
    Description = {
        en = "Reward: Diplomacy increases slightly to another player",
        de = "Lohn: Verbesserug des Diplomatiestatus zu einem anderen Spieler",
    },
}

function b_Reward_DiplomacyIncrease:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_DiplomacyIncrease:CustomFunction(__quest_)
    local Sender = __quest_.SendingPlayer;
    local Receiver = __quest_.ReceivingPlayer;
    local State = GetDiplomacyState(Receiver, Sender);
    if State < 2 then
        SetDiplomacyState(Receiver, Sender, State+1);
    end
end

function b_Reward_DiplomacyIncrease:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    end
end

AddQuestBehavior(b_Reward_DiplomacyIncrease);

-- -------------------------------------------------------------------------- --

---
-- Erzeugt Handelsangebote im Lagerhaus des angegebenen Spielers.
--
-- Sollen Angebote gelöscht werden, muss "-" als Ware ausgewählt werden.
--
-- ACHTUNG: Stadtlagerhäuser können keine Söldner anbieten!
--
-- @param _PlayerID Partei, die Anbietet
-- @param _Amount1  Menge des 1. Angebot
-- @param _Type1    Ware oder Typ des 1. Angebot
-- @param _Amount2  Menge des 2. Angebot
-- @param _Type2    Ware oder Typ des 2. Angebot
-- @param _Amount3  Menge des 3. Angebot
-- @param _Type3    Ware oder Typ des 3. Angebot
-- @param _Amount4  Menge des 4. Angebot
-- @param _Type4    Ware oder Typ des 4. Angebot
-- @return table: Behavior
-- @within Rewards
--
function Reward_TradeOffers(...)
    return b_Reward_TradeOffers:new(...);
end

b_Reward_TradeOffers = {
    Name = "Reward_TradeOffers",
    Description = {
        en = "Reward: Deletes all existing offers for a merchant and sets new offers, if given",
        de = "Lohn: Loescht alle Angebote eines Haendlers und setzt neue, wenn angegeben",
    },
    Parameter = {
        { ParameterType.Custom, en = "PlayerID", de = "PlayerID" },
        { ParameterType.Custom, en = "Amount 1", de = "Menge 1" },
        { ParameterType.Custom, en = "Offer 1", de = "Angebot 1" },
        { ParameterType.Custom, en = "Amount 2", de = "Menge 2" },
        { ParameterType.Custom, en = "Offer 2", de = "Angebot 2" },
        { ParameterType.Custom, en = "Amount 3", de = "Menge 3" },
        { ParameterType.Custom, en = "Offer 3", de = "Angebot 3" },
        { ParameterType.Custom, en = "Amount 4", de = "Menge 4" },
        { ParameterType.Custom, en = "Offer 4", de = "Angebot 4" },
    },
}

function b_Reward_TradeOffers:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_TradeOffers:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_
    elseif (__index_ == 1) then
        self.AmountOffer1 = tonumber(__parameter_)
    elseif (__index_ == 2) then
        self.Offer1 = __parameter_
    elseif (__index_ == 3) then
        self.AmountOffer2 = tonumber(__parameter_)
    elseif (__index_ == 4) then
        self.Offer2 = __parameter_
    elseif (__index_ == 5) then
        self.AmountOffer3 = tonumber(__parameter_)
    elseif (__index_ == 6) then
        self.Offer3 = __parameter_
    elseif (__index_ == 7) then
        self.AmountOffer4 = tonumber(__parameter_)
    elseif (__index_ == 8) then
        self.Offer4 = __parameter_
    end
end

function b_Reward_TradeOffers:CustomFunction()
    if (self.PlayerID > 1) and (self.PlayerID < 9) then
        local Storehouse = Logic.GetStoreHouse(self.PlayerID)
        Logic.RemoveAllOffers(Storehouse)
        for i =  1,4 do
            if self["Offer"..i] and self["Offer"..i] ~= "-" then
                if Goods[self["Offer"..i]] then
                    AddOffer(Storehouse, self["AmountOffer"..i], Goods[self["Offer"..i]])
                elseif Logic.IsEntityTypeInCategory(Entities[self["Offer"..i]], EntityCategories.Military) == 1 then
                    AddMercenaryOffer(Storehouse, self["AmountOffer"..i], Entities[self["Offer"..i]])
                else
                    AddEntertainerOffer (Storehouse , Entities[self["Offer"..i]])
                end
            end
        end
    end
end

function b_Reward_TradeOffers:DEBUG(__quest_)
    if Logic.GetStoreHouse(self.PlayerID ) == 0 then
        dbg(__quest_.Identifier .. ": Error in " .. self.Name .. ": Player " .. self.PlayerID .. " is dead. :-(")
        return true
    end
end

function b_Reward_TradeOffers:GetCustomData(__index_)
    local Players = { "2", "3", "4", "5", "6", "7", "8" }
    local Amount = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
    local Offers = {"-",
                    "G_Beer",
                    "G_Bow",
                    "G_Bread",
                    "G_Broom",
                    "G_Candle",
                    "G_Carcass",
                    "G_Cheese",
                    "G_Clothes",
                    "G_Cow",
                    "G_Grain",
                    "G_Herb",
                    "G_Honeycomb",
                    "G_Iron",
                    "G_Leather",
                    "G_Medicine",
                    "G_Milk",
                    "G_RawFish",
                    "G_Sausage",
                    "G_Sheep",
                    "G_SmokedFish",
                    "G_Soap",
                    "G_Stone",
                    "G_Sword",
                    "G_Wood",
                    "G_Wool",
                    "G_Salt",
                    "G_Dye",
                    "U_AmmunitionCart",
                    "U_BatteringRamCart",
                    "U_CatapultCart",
                    "U_SiegeTowerCart",
                    "U_MilitaryBandit_Melee_ME",
                    "U_MilitaryBandit_Melee_SE",
                    "U_MilitaryBandit_Melee_NA",
                    "U_MilitaryBandit_Melee_NE",
                    "U_MilitaryBandit_Ranged_ME",
                    "U_MilitaryBandit_Ranged_NA",
                    "U_MilitaryBandit_Ranged_NE",
                    "U_MilitaryBandit_Ranged_SE",
                    "U_MilitaryBow_RedPrince",
                    "U_MilitaryBow",
                    "U_MilitarySword_RedPrince",
                    "U_MilitarySword",
                    "U_Entertainer_NA_FireEater",
                    "U_Entertainer_NA_StiltWalker",
                    "U_Entertainer_NE_StrongestMan_Barrel",
                    "U_Entertainer_NE_StrongestMan_Stone",
                    }
    if g_GameExtraNo and g_GameExtraNo >= 1 then
        table.insert(Offers, "G_Gems")
        table.insert(Offers, "G_Olibanum")
        table.insert(Offers, "G_MusicalInstrument")
        table.insert(Offers, "G_MilitaryBandit_Ranged_AS")
        table.insert(Offers, "G_MilitaryBandit_Melee_AS")
        table.insert(Offers, "U_MilitarySword_Khana")
        table.insert(Offers, "U_MilitaryBow_Khana")
    end
    if (__index_ == 0) then
        return Players
    elseif (__index_ == 1) or (__index_ == 3) or (__index_ == 5) or (__index_ == 7) then
        return Amount
    elseif (__index_ == 2) or (__index_ == 4) or (__index_ == 6) or (__index_ == 8) then
        return Offers
    end
end

AddQuestBehavior(b_Reward_TradeOffers)

-- -------------------------------------------------------------------------- --

---
-- Ein benanntes Entity wird zerstört.
--
-- @param _ScriptName Skriptname des Entity
-- @return table: Behavior
-- @within Rewards
--
function Reward_DestroyEntity(...)
    return b_Reward_DestroyEntity:new(...);
end

b_Reward_DestroyEntity = API.InstanceTable(b_Reprisal_DestroyEntity);
b_Reward_DestroyEntity.Name = "Reward_DestroyEntity";
b_Reward_DestroyEntity.Description.en = "Reward: Replaces an entity with an invisible script entity, which retains the entities name.";
b_Reward_DestroyEntity.Description.de = "Lohn: Ersetzt eine Entity mit einer unsichtbaren Script-Entity, die den Namen uebernimmt.";
b_Reward_DestroyEntity.GetReprisalTable = nil;

b_Reward_DestroyEntity.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

AddQuestBehavior(b_Reward_DestroyEntity);

-- -------------------------------------------------------------------------- --

---
-- Zerstört einen über die QSB erzeugten Effekt.
--
-- @param _EffectName Name des Effekts
-- @return table: Behavior
-- @within Rewards
--
function Reward_DestroyEffect(...)
    return b_Reward_DestroyEffect:new(...);
end

b_Reward_DestroyEffect = API.InstanceTable(b_Reprisal_DestroyEffect);
b_Reward_DestroyEffect.Name = "Reward_DestroyEffect";
b_Reward_DestroyEffect.Description.en = "Reward: Destroys an effect.";
b_Reward_DestroyEffect.Description.de = "Lohn: Zerstoert einen Effekt.";
b_Reward_DestroyEffect.GetReprisalTable = nil;

b_Reward_DestroyEffect.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } };
end

AddQuestBehavior(b_Reward_DestroyEffect);

-- -------------------------------------------------------------------------- --

---
-- Ersetzt ein Entity mit einem Batallion.
--
-- Ist die Position ein Gebäude, werden die Battalione am Eingang erzeugt und
-- Das Entity wird nicht ersetzt.
--
-- @param _Position    Skriptname des Entity
-- @param _PlayerID    PlayerID des Battalion
-- @param _UnitType    Einheitentyp der Soldaten
-- @param _Orientation Ausrichtung in °
-- @param _Soldiers    Anzahl an Soldaten
-- @param _HideFromAI  Vor KI verstecken
-- @return table: Behavior
-- @within Rewards
--
function Reward_CreateBattalion(...)
    return b_Reward_CreateBattalion:new(...);
end

b_Reward_CreateBattalion = {
    Name = "Reward_CreateBattalion",
    Description = {
        en = "Reward: Replaces a script entity with a battalion, which retains the entities name",
        de = "Lohn: Ersetzt eine Script-Entity durch ein Bataillon, welches den Namen der Script-Entity uebernimmt",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script entity", de = "Script Entity" },
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Custom, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number, en = "Orientation (in degrees)", de = "Ausrichtung (in Grad)" },
        { ParameterType.Number, en = "Number of soldiers", de = "Anzahl Soldaten" },
        { ParameterType.Custom, en = "Hide from AI", de = "Vor KI verstecken" },
    },
}

function b_Reward_CreateBattalion:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_CreateBattalion:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.ScriptNameEntity = __parameter_
    elseif (__index_ == 1) then
        self.PlayerID = __parameter_ * 1
    elseif (__index_ == 2) then
        self.UnitKey = __parameter_
    elseif (__index_ == 3) then
        self.Orientation = __parameter_ * 1
    elseif (__index_ == 4) then
        self.SoldierCount = __parameter_ * 1
    elseif (__index_ == 5) then
        self.HideFromAI = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Reward_CreateBattalion:CustomFunction(__quest_)
    if not IsExisting( self.ScriptNameEntity ) then
        return false
    end
    local pos = GetPosition(self.ScriptNameEntity)
    local NewID = Logic.CreateBattalionOnUnblockedLand( Entities[self.UnitKey], pos.X, pos.Y, self.Orientation, self.PlayerID, self.SoldierCount )
    local posID = GetID(self.ScriptNameEntity)
    if Logic.IsBuilding(posID) == 0 then
        DestroyEntity(self.ScriptNameEntity)
        Logic.SetEntityName( NewID, self.ScriptNameEntity )
    end
    if self.HideFromAI then
        AICore.HideEntityFromAI( self.PlayerID, NewID, true )
    end
end

function b_Reward_CreateBattalion:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 2 then
        for k, v in pairs( Entities ) do
            if Logic.IsEntityTypeInCategory( v, EntityCategories.Soldier ) == 1 then
                table.insert( Data, k )
            end
        end
        table.sort( Data )
    elseif __index_ == 5 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    else
        assert( false )
    end
    return Data
end

function b_Reward_CreateBattalion:DEBUG(__quest_)
    if not Entities[self.UnitKey] then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": got an invalid entity type!");
        return true;
    elseif not IsExisting(self.ScriptNameEntity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": spawnpoint does not exist!");
        return true;
    elseif tonumber(self.PlayerID) == nil or self.PlayerID < 1 or self.PlayerID > 8 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": playerID is wrong!");
        return true;
    elseif tonumber(self.Orientation) == nil then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": orientation must be a number!");
        return true;
    elseif tonumber(self.SoldierCount) == nil or self.SoldierCount < 1 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": you can not create a empty batallion!");
        return true;
    end
    return false;
end

AddQuestBehavior(b_Reward_CreateBattalion);

-- -------------------------------------------------------------------------- --

---
-- Erzeugt eine Menga von Battalionen an der Position.
--
-- @param _Amount      Anzahl erzeugter Battalione
-- @param _Position    Skriptname des Entity
-- @param _PlayerID    PlayerID des Battalion
-- @param _UnitType    Einheitentyp der Soldaten
-- @param _Orientation Ausrichtung in °
-- @param _Soldiers    Anzahl an Soldaten
-- @param _HideFromAI  Vor KI verstecken
-- @return table: Behavior
-- @within Rewards
--
function Reward_CreateSeveralBattalions(...)
    return b_Reward_CreateSeveralBattalions:new(...);
end

b_Reward_CreateSeveralBattalions = {
    Name = "Reward_CreateSeveralBattalions",
    Description = {
        en = "Reward: Creates a given amount of battalions",
        de = "Lohn: Erstellt eine gegebene Anzahl Bataillone",
    },
    Parameter = {
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
        { ParameterType.ScriptName, en = "Script entity", de = "Script Entity" },
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Custom, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number, en = "Orientation (in degrees)", de = "Ausrichtung (in Grad)" },
        { ParameterType.Number, en = "Number of soldiers", de = "Anzahl Soldaten" },
        { ParameterType.Custom, en = "Hide from AI", de = "Vor KI verstecken" },
    },
}

function b_Reward_CreateSeveralBattalions:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_CreateSeveralBattalions:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Amount = __parameter_ * 1
    elseif (__index_ == 1) then
        self.ScriptNameEntity = __parameter_
    elseif (__index_ == 2) then
        self.PlayerID = __parameter_ * 1
    elseif (__index_ == 3) then
        self.UnitKey = __parameter_
    elseif (__index_ == 4) then
        self.Orientation = __parameter_ * 1
    elseif (__index_ == 5) then
        self.SoldierCount = __parameter_ * 1
    elseif (__index_ == 6) then
        self.HideFromAI = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Reward_CreateSeveralBattalions:CustomFunction(__quest_)
    if not IsExisting( self.ScriptNameEntity ) then
        return false
    end
    local tID = GetID(self.ScriptNameEntity)
    local x,y,z = Logic.EntityGetPos(tID);
    if Logic.IsBuilding(tID) == 1 then
        x,y = Logic.GetBuildingApproachPosition(tID)
    end

    for i=1, self.Amount do
        local NewID = Logic.CreateBattalionOnUnblockedLand( Entities[self.UnitKey], x, y, self.Orientation, self.PlayerID, self.SoldierCount )
        Logic.SetEntityName( NewID, self.ScriptNameEntity .. "_" .. i )
        if self.HideFromAI then
            AICore.HideEntityFromAI( self.PlayerID, NewID, true )
        end
    end
end

function b_Reward_CreateSeveralBattalions:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 3 then
        for k, v in pairs( Entities ) do
            if Logic.IsEntityTypeInCategory( v, EntityCategories.Soldier ) == 1 then
                table.insert( Data, k )
            end
        end
        table.sort( Data )
    elseif __index_ == 6 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    else
        assert( false )
    end
    return Data
end

function b_Reward_CreateSeveralBattalions:DEBUG(__quest_)
    if not Entities[self.UnitKey] then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": got an invalid entity type!");
        return true;
    elseif not IsExisting(self.ScriptNameEntity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": spawnpoint does not exist!");
        return true;
    elseif tonumber(self.PlayerID) == nil or self.PlayerID < 1 or self.PlayerID > 8 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": playerDI is wrong!");
        return true;
    elseif tonumber(self.Orientation) == nil then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": orientation must be a number!");
        return true;
    elseif tonumber(self.SoldierCount) == nil or self.SoldierCount < 1 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": you can not create a empty batallion!");
        return true;
    elseif tonumber(self.Amount) == nil or self.Amount < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": amount can not be negative!");
        return true;
    end
    return false;
end

AddQuestBehavior(b_Reward_CreateSeveralBattalions);

-- -------------------------------------------------------------------------- --

---
-- Erzeugt einen Effekt an der angegebenen Position.
--
-- @param _EffectName  Einzigartiger Effektname
-- @param _TypeName    Typ des Effekt
-- @param _PlayerID    PlayerID des Effekt
-- @param _Location    Position des Effekt
-- @param _Orientation Ausrichtung in °
-- @return table: Behavior
-- @within Rewards
--
function Reward_CreateEffect(...)
    return b_Reward_CreateEffect:new(...);
end

b_Reward_CreateEffect = {
    Name = "Reward_CreateEffect",
    Description = {
        en = "Reward: Creates an effect at a specified position",
        de = "Lohn: Erstellt einen Effekt an der angegebenen Position",
    },
    Parameter = {
        { ParameterType.Default,    en = "Effect name", de = "Effektname" },
        { ParameterType.Custom,     en = "Type name", de = "Typbezeichnung" },
        { ParameterType.PlayerID,   en = "Player", de = "Spieler" },
        { ParameterType.ScriptName, en = "Location", de = "Ort" },
        { ParameterType.Number,     en = "Orientation (in degrees)(-1: from locating entity)", de = "Ausrichtung (in Grad)(-1: von Positionseinheit)" },
    }
}

function b_Reward_CreateEffect:AddParameter(__index_, __parameter_)

    if __index_ == 0 then
        self.EffectName = __parameter_;
    elseif __index_ == 1 then
        self.Type = EGL_Effects[__parameter_];
    elseif __index_ == 2 then
        self.PlayerID = __parameter_ * 1;
    elseif __index_ == 3 then
        self.Location = __parameter_;
    elseif __index_ == 4 then
        self.Orientation = __parameter_ * 1;
    end

end

function b_Reward_CreateEffect:GetRewardTable(__quest_)
    return { Reward.Custom, { self, self.CustomFunction } };
end

function b_Reward_CreateEffect:CustomFunction(__quest_)
    if Logic.IsEntityDestroyed(self.Location) then
        return;
    end
    local entity = assert(GetID(self.Location), __quest_.Identifier .. "Error in " .. self.Name .. ": CustomFunction: Entity is invalid");
    if QSB.EffectNameToID[self.EffectName] and Logic.IsEffectRegistered(QSB.EffectNameToID[self.EffectName]) then
        return;
    end

    local posX, posY = Logic.GetEntityPosition(entity);
    local orientation = tonumber(self.Orientation);
    local effect = Logic.CreateEffectWithOrientation(self.Type, posX, posY, orientation, self.PlayerID);
    if self.EffectName ~= "" then
        QSB.EffectNameToID[self.EffectName] = effect;
    end
end

function b_Reward_CreateEffect:DEBUG(__quest_)
    if QSB.EffectNameToID[self.EffectName] and Logic.IsEffectRegistered(QSB.EffectNameToID[self.EffectName]) then
        local text = string.format("%s Reward_CreateEffect: effect already exists!",__quest_.Identifier);
        dbg(text);
        return true;
    elseif not IsExisting(self.Location) then
        local text = string.format("%s Reward_CreateEffect: location %s is missing!",__quest_.Identifier, tostring(self.Location));
        dbg(text);
        return true;
    elseif self.PlayerID and (self.PlayerID < 0 or self.PlayerID > 8) then
        local text = string.format("%s Reward_CreateEffect: invalid playerID!",__quest_.Identifier);
        dbg(text);
        return true;
    elseif tonumber(self.Orientation) == nil then
        local text = string.format("%s Reward_CreateEffect: invalid orientation!",__quest_.Identifier);
        dbg(text);
        return true;
    end
end

function b_Reward_CreateEffect:GetCustomData(__index_)
    assert(__index_ == 1, "Error in " .. self.Name .. ": GetCustomData: Index is invalid.");
    local types = {};
    for k, v in pairs(EGL_Effects) do
        table.insert(types, k);
    end
    table.sort(types);
    return types;
end

AddQuestBehavior(b_Reward_CreateEffect);

-- -------------------------------------------------------------------------- --

---
-- Ersetzt ein Entity mit dem Skriptnamen durch ein neues Entity.
--
-- Ist die Position ein Gebäude, werden die Entities am Eingang erzeugt und
-- die Position wird nicht ersetzt.
--
-- @param _ScriptName  Skriptname des Entity
-- @param _PlayerID    PlayerID des Effekt
-- @param _TypeName    Einzigartiger Effektname
-- @param _Orientation Ausrichtung in °
-- @param _HideFromAI  Vor KI verstecken
-- @return table: Behavior
-- @within Rewards
--
function Reward_CreateEntity(...)
    return b_Reward_CreateEntity:new(...);
end

b_Reward_CreateEntity = {
    Name = "Reward_CreateEntity",
    Description = {
        en = "Reward: Replaces an entity by a new one of a given type",
        de = "Lohn: Ersetzt eine Entity durch eine neue gegebenen Typs",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script entity", de = "Script Entity" },
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Custom, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number, en = "Orientation (in degrees)", de = "Ausrichtung (in Grad)" },
        { ParameterType.Custom, en = "Hide from AI", de = "Vor KI verstecken" },
    },
}

function b_Reward_CreateEntity:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_CreateEntity:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.ScriptNameEntity = __parameter_
    elseif (__index_ == 1) then
        self.PlayerID = __parameter_ * 1
    elseif (__index_ == 2) then
        self.UnitKey = __parameter_
    elseif (__index_ == 3) then
        self.Orientation = __parameter_ * 1
    elseif (__index_ == 4) then
        self.HideFromAI = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Reward_CreateEntity:CustomFunction(__quest_)
    if not IsExisting( self.ScriptNameEntity ) then
        return false
    end
    local pos = GetPosition(self.ScriptNameEntity)
    local NewID;
    if Logic.IsEntityTypeInCategory( self.UnitKey, EntityCategories.Soldier ) == 1 then
        NewID       = Logic.CreateBattalionOnUnblockedLand( Entities[self.UnitKey], pos.X, pos.Y, self.Orientation, self.PlayerID, 1 )
        local l,s = {Logic.GetSoldiersAttachedToLeader(NewID)}
        Logic.SetOrientation(s,self.Orientation)
    else
        NewID = Logic.CreateEntityOnUnblockedLand( Entities[self.UnitKey], pos.X, pos.Y, self.Orientation, self.PlayerID )
    end
    local posID = GetID(self.ScriptNameEntity)
    if Logic.IsBuilding(posID) == 0 then
        DestroyEntity(self.ScriptNameEntity)
        Logic.SetEntityName( NewID, self.ScriptNameEntity )
    end
    if self.HideFromAI then
        AICore.HideEntityFromAI( self.PlayerID, NewID, true )
    end
end

function b_Reward_CreateEntity:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 2 then
        for k, v in pairs( Entities ) do
            local name = {"^M_*","^XS_*","^X_*","^XT_*","^Z_*"}
            local found = false;
            for i=1,#name do
                if k:find(name[i]) then
                    found = true;
                    break;
                end
            end
            if not found then
                table.insert( Data, k );
            end
        end
        table.sort( Data )

    elseif __index_ == 4 or __index_ == 5 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    else
        assert( false )
    end
    return Data
end

function b_Reward_CreateEntity:DEBUG(__quest_)
    if not Entities[self.UnitKey] then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": got an invalid entity type!");
        return true;
    elseif not IsExisting(self.ScriptNameEntity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": spawnpoint does not exist!");
        return true;
    elseif tonumber(self.PlayerID) == nil or self.PlayerID < 0 or self.PlayerID > 8 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": playerID is not valid!");
        return true;
    elseif tonumber(self.Orientation) == nil then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": orientation must be a number!");
        return true;
    end
    return false;
end

AddQuestBehavior(b_Reward_CreateEntity);

-- -------------------------------------------------------------------------- --

---
-- Erzeugt mehrere Entities an der angegebenen Position
--
-- @param _Amount      Anzahl an Entities
-- @param _ScriptName  Skriptname des Entity
-- @param _PlayerID    PlayerID des Effekt
-- @param _TypeName    Einzigartiger Effektname
-- @param _Orientation Ausrichtung in °
-- @param _HideFromAI  Vor KI verstecken
-- @return table: Behavior
-- @within Rewards
--
function Reward_CreateSeveralEntities(...)
    return b_Reward_CreateSeveralEntities:new(...);
end

b_Reward_CreateSeveralEntities = {
    Name = "Reward_CreateSeveralEntities",
    Description = {
        en = "Reward: Creating serveral battalions at the position of a entity. They retains the entities name and a _[index] suffix",
        de = "Lohn: Erzeugt mehrere Entities an der Position der Entity. Sie uebernimmt den Namen der Script Entity und den Suffix _[index]",
    },
    Parameter = {
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
        { ParameterType.ScriptName, en = "Script entity", de = "Script Entity" },
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Custom, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number, en = "Orientation (in degrees)", de = "Ausrichtung (in Grad)" },
        { ParameterType.Custom, en = "Hide from AI", de = "Vor KI verstecken" },
    },
}

function b_Reward_CreateSeveralEntities:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_CreateSeveralEntities:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Amount = __parameter_ * 1
    elseif (__index_ == 1) then
        self.ScriptNameEntity = __parameter_
    elseif (__index_ == 2) then
        self.PlayerID = __parameter_ * 1
    elseif (__index_ == 3) then
        self.UnitKey = __parameter_
    elseif (__index_ == 4) then
        self.Orientation = __parameter_ * 1
    elseif (__index_ == 5) then
        self.HideFromAI = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Reward_CreateSeveralEntities:CustomFunction(__quest_)
    if not IsExisting( self.ScriptNameEntity ) then
        return false
    end
    local pos = GetPosition(self.ScriptNameEntity)
    local NewID;
    for i=1, self.Amount do
        if Logic.IsEntityTypeInCategory( self.UnitKey, EntityCategories.Soldier ) == 1 then
            NewID       = Logic.CreateBattalionOnUnblockedLand( Entities[self.UnitKey], pos.X, pos.Y, self.Orientation, self.PlayerID, 1 )
            local l,s = {Logic.GetSoldiersAttachedToLeader(NewID)}
            Logic.SetOrientation(s,self.Orientation)
        else
            NewID = Logic.CreateEntityOnUnblockedLand( Entities[self.UnitKey], pos.X, pos.Y, self.Orientation, self.PlayerID )
        end
        Logic.SetEntityName( NewID, self.ScriptNameEntity .. "_" .. i )
        if self.HideFromAI then
            AICore.HideEntityFromAI( self.PlayerID, NewID, true )
        end
    end
end

function b_Reward_CreateSeveralEntities:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 3 then
        for k, v in pairs( Entities ) do
            local name = {"^M_*","^XS_*","^X_*","^XT_*","^Z_*"}
            local found = false;
            for i=1,#name do
                if k:find(name[i]) then
                    found = true;
                    break;
                end
            end
            if not found then
                table.insert( Data, k );
            end
        end
        table.sort( Data )

    elseif __index_ == 5 or __index_ == 6 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    else
        assert( false )
    end
    return Data

end

function b_Reward_CreateSeveralEntities:DEBUG(__quest_)
    if not Entities[self.UnitKey] then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": got an invalid entity type!");
        return true;
    elseif not IsExisting(self.ScriptNameEntity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": spawnpoint does not exist!");
        return true;
    elseif tonumber(self.PlayerID) == nil or self.PlayerID < 1 or self.PlayerID > 8 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": spawnpoint does not exist!");
        return true;
    elseif tonumber(self.Orientation) == nil then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": orientation must be a number!");
        return true;
    elseif tonumber(self.Amount) == nil or self.Amount < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": amount can not be negative!");
        return true;
    end
    return false;
end

AddQuestBehavior(b_Reward_CreateSeveralEntities);

-- -------------------------------------------------------------------------- --

---
-- Bewegt einen Siedler oder ein Battalion zum angegebenen Zielort.
--
-- @param _Settler     Einheit, die bewegt wird
-- @param _Destination Bewegungsziel
-- @return table: Behavior
-- @within Rewards
--
function Reward_MoveSettler(...)
    return b_Reward_MoveSettler:new(...);
end

b_Reward_MoveSettler = {
    Name = "Reward_MoveSettler",
    Description = {
        en = "Reward: Moves a (NPC) settler to a destination. Must not be AI controlled, or it won't move",
        de = "Lohn: Bewegt einen (NPC) Siedler zu einem Zielort. Darf keinem KI Spieler gehoeren, ansonsten wird sich der Siedler nicht bewegen",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Settler", de = "Siedler" },
        { ParameterType.ScriptName, en = "Destination", de = "Ziel" },
    },
}

function b_Reward_MoveSettler:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_MoveSettler:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.ScriptNameUnit = __parameter_
    elseif (__index_ == 1) then
        self.ScriptNameDest = __parameter_
    end
end

function b_Reward_MoveSettler:CustomFunction(__quest_)
    if Logic.IsEntityDestroyed( self.ScriptNameUnit ) or Logic.IsEntityDestroyed( self.ScriptNameDest ) then
        return false
    end
    local DestID = GetID( self.ScriptNameDest )
    local DestX, DestY = Logic.GetEntityPosition( DestID )
    if Logic.IsBuilding( DestID ) == 1 then
        DestX, DestY = Logic.GetBuildingApproachPosition( DestID )
    end
    Logic.MoveSettler( GetID( self.ScriptNameUnit ), DestX, DestY )
end

function b_Reward_MoveSettler:DEBUG(__quest_)
    if not not IsExisting(self.ScriptNameUnit) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": mover entity does not exist!");
        return true;
    elseif not IsExisting(self.ScriptNameDest) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": destination does not exist!");
        return true;
    end
    return false;
end

AddQuestBehavior(b_Reward_MoveSettler);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler gewinnt das Spiel.
--
-- @return table: Behavior
-- @within Rewards
--
function Reward_Victory()
    return b_Reward_Victory:new()
end

b_Reward_Victory = {
    Name = "Reward_Victory",
    Description = {
        en = "Reward: The player wins the game.",
        de = "Lohn: Der Spieler gewinnt das Spiel.",
    },
}

function b_Reward_Victory:GetRewardTable(__quest_)
    return {Reward.Victory};
end

AddQuestBehavior(b_Reward_Victory);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler verliert das Spiel.
--
-- @return table: Behavior
-- @within Rewards
--
function Reward_Defeat()
    return b_Reward_Defeat:new()
end

b_Reward_Defeat = {
    Name = "Reward_Defeat",
    Description = {
        en = "Reward: The player loses the game.",
        de = "Lohn: Der Spieler verliert das Spiel.",
    },
}

function b_Reward_Defeat:GetRewardTable(__quest_)
    return { Reward.Custom, {self, self.CustomFunction} }
end

function b_Reward_Defeat:CustomFunction(__quest_)
    __quest_:TerminateEventsAndStuff()
    Logic.ExecuteInLuaLocalState("GUI_Window.MissionEndScreenSetVictoryReasonText(".. g_VictoryAndDefeatType.DefeatMissionFailed ..")")
    Defeated(__quest_.ReceivingPlayer)
end

AddQuestBehavior(b_Reward_Defeat);

-- -------------------------------------------------------------------------- --

---
-- Zeigt die Siegdekoration an dem Quest an.
--
-- Dies ist reine Optik! Der Spieler wird dadurch nicht das Spiel gewinnen.
--
-- @return table: Behavior
-- @within Rewards
--
function Reward_FakeVictory()
    return b_Reward_FakeVictory:new();
end

b_Reward_FakeVictory = {
    Name = "Reward_FakeVictory",
    Description = {
        en = "Reward: Display a victory icon for a quest",
        de = "Lohn: Zeigt ein Siegesicon fuer diese Quest",
    },
}

function b_Reward_FakeVictory:GetRewardTable()
    return { Reward.FakeVictory }
end

AddQuestBehavior(b_Reward_FakeVictory);

-- -------------------------------------------------------------------------- --

---
-- Erzeugt eine Armee, die das angegebene Territorium angreift.
--
-- Die Armee wird versuchen Gebäude auf dem Territrium zu zerstören.
-- <ul>
-- <li>Außenposten: Die Armee versucht den Außenposten zu zerstören</li>
-- <li>Stadt: Die Armee versucht das Lagerhaus zu zerstören</li>
-- </ul>
--
-- @param _PlayerID   PlayerID der Angreifer
-- @param _SpawnPoint Skriptname des Entstehungspunkt
-- @param _Territory  Zielterritorium
-- @param _Sword      Anzahl Schwertkämpfer (Battalion)
-- @param _Bow        Anzahl Bogenschützen (Battalion)
-- @param _Cata       Anzahl Katapulte
-- @param _Towers     Anzahl Belagerungstürme
-- @param _Rams       Anzahl Rammen
-- @param _Ammo       Anzahl Munitionswagen
-- @param _Type       Typ der Soldaten
-- @param _Reuse      Freie Truppen wiederverwenden
-- @return table: Behavior
-- @within Rewards
--
function Reward_AI_SpawnAndAttackTerritory(...)
    return b_Reward_AI_SpawnAndAttackTerritory:new(...);
end

b_Reward_AI_SpawnAndAttackTerritory = {
    Name = "Reward_AI_SpawnAndAttackTerritory",
    Description = {
        en = "Reward: Spawns AI troops and attacks a territory (Hint: Use for hidden quests as a surprise)",
        de = "Lohn: Erstellt KI Truppen und greift ein Territorium an (Tipp: Fuer eine versteckte Quest als Ueberraschung verwenden)",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "AI Player", de = "KI Spieler" },
        { ParameterType.ScriptName, en = "Spawn point", de = "Erstellungsort" },
        { ParameterType.TerritoryName, en = "Territory", de = "Territorium" },
        { ParameterType.Number, en = "Sword", de = "Schwert" },
        { ParameterType.Number, en = "Bow", de = "Bogen" },
        { ParameterType.Number, en = "Catapults", de = "Katapulte" },
        { ParameterType.Number, en = "Siege towers", de = "Belagerungstuerme" },
        { ParameterType.Number, en = "Rams", de = "Rammen" },
        { ParameterType.Number, en = "Ammo carts", de = "Munitionswagen" },
        { ParameterType.Custom, en = "Soldier type", de = "Soldatentyp" },
        { ParameterType.Custom, en = "Reuse troops", de = "Verwende bestehende Truppen" },
    },
}

function b_Reward_AI_SpawnAndAttackTerritory:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_AI_SpawnAndAttackTerritory:AddParameter(__index_, __parameter_)

    if (__index_ == 0) then
        self.AIPlayerID = __parameter_ * 1
    elseif (__index_ == 1) then
        self.Spawnpoint = __parameter_
    elseif (__index_ == 2) then
        self.TerritoryID = tonumber(__parameter_)
        if not self.TerritoryID then
            self.TerritoryID = GetTerritoryIDByName(__parameter_)
        end
    elseif (__index_ == 3) then
        self.NumSword = __parameter_ * 1
    elseif (__index_ == 4) then
        self.NumBow = __parameter_ * 1
    elseif (__index_ == 5) then
        self.NumCatapults = __parameter_ * 1
    elseif (__index_ == 6) then
        self.NumSiegeTowers = __parameter_ * 1
    elseif (__index_ == 7) then
        self.NumRams = __parameter_ * 1
    elseif (__index_ == 8) then
        self.NumAmmoCarts = __parameter_ * 1
    elseif (__index_ == 9) then
        if __parameter_ == "Normal" or __parameter_ == false then
            self.TroopType = false
        elseif __parameter_ == "RedPrince" or __parameter_ == true then
            self.TroopType = true
        elseif __parameter_ == "Bandit" or __parameter_ == 2 then
            self.TroopType = 2
        elseif __parameter_ == "Cultist" or __parameter_ == 3 then
            self.TroopType = 3
        else
            assert(false)
        end
    elseif (__index_ == 10) then
        self.ReuseTroops = AcceptAlternativeBoolean(__parameter_)
    end

end

function b_Reward_AI_SpawnAndAttackTerritory:GetCustomData( __index_ )

    local Data = {}
    if __index_ == 9 then
        table.insert( Data, "Normal" )
        table.insert( Data, "RedPrince" )
        table.insert( Data, "Bandit" )
        if g_GameExtraNo >= 1 then
            table.insert( Data, "Cultist" )
        end

    elseif __index_ == 10 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )

    else
        assert( false )
    end

    return Data

end

function b_Reward_AI_SpawnAndAttackTerritory:CustomFunction(__quest_)

    local TargetID = Logic.GetTerritoryAcquiringBuildingID( self.TerritoryID )
    if TargetID ~= 0 then
        AIScript_SpawnAndAttackCity( self.AIPlayerID, TargetID, self.Spawnpoint, self.NumSword, self.NumBow, self.NumCatapults, self.NumSiegeTowers, self.NumRams, self.NumAmmoCarts, self.TroopType, self.ReuseTroops)
    end

end

function b_Reward_AI_SpawnAndAttackTerritory:DEBUG(__quest_)
    if self.AIPlayerID < 2 then
        dbg(__quest_.Identifier .. ": Error in " .. self.Name .. ": Player " .. self.AIPlayerID .. " is wrong")
        return true
    elseif Logic.IsEntityDestroyed(self.Spawnpoint) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Entity " .. self.SpawnPoint .. " is missing")
        return true
    elseif self.TerritoryID == 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Territory unknown")
        return true
    elseif self.NumSword < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Number of Swords is negative")
        return true
    elseif self.NumBow < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Number of Bows is negative")
        return true
    elseif self.NumBow + self.NumSword < 1 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": No Soldiers?")
        return true
    elseif self.NumCatapults < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Catapults is negative")
        return true
    elseif self.NumSiegeTowers < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": SiegeTowers is negative")
        return true
    elseif self.NumRams < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Rams is negative")
        return true
    elseif self.NumAmmoCarts < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": AmmoCarts is negative")
        return true
    end
    return false;
end

AddQuestBehavior(b_Reward_AI_SpawnAndAttackTerritory);

-- -------------------------------------------------------------------------- --

---
-- Erzeugt eine Armee, die sich zum Zielpunkt bewegt und das Gebiet angreift.
--
-- Dabei werden die Soldaten alle erreichbaren Gebäude in Brand stecken. Ist
-- Das Zielgebiet eingemauert, können die Soldaten nicht angreifen und werden
-- sich zurückziehen.
--
-- @param _PlayerID   PlayerID des Angreifers
-- @param _SpawnPoint Skriptname des Entstehungspunktes
-- @param _Target     Skriptname des Ziels
-- @param _Radius     Aktionsradius um das Ziel
-- @param _Sword      Anzahl Schwertkämpfer (Battalione)
-- @param _Bow        Anzahl Bogenschützen (Battalione)
-- @param _Soldier    Typ der Soldaten
-- @param _Reuse      Freie Truppen wiederverwenden
-- @return table: Behavior
-- @within Rewards
--
function Reward_AI_SpawnAndAttackArea(...)
    return b_Reward_AI_SpawnAndAttackArea:new(...);
end

b_Reward_AI_SpawnAndAttackArea = {
    Name = "Reward_AI_SpawnAndAttackArea",
    Description = {
        en = "Reward: Spawns AI troops and attacks everything within the specified area, except the players main buildings",
        de = "Lohn: Erstellt KI Truppen und greift ein angegebenes Gebiet an, aber nicht die Hauptgebauede eines Spielers",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "AI Player", de = "KI Spieler" },
        { ParameterType.ScriptName, en = "Spawn point", de = "Erstellungsort" },
        { ParameterType.ScriptName, en = "Target", de = "Ziel" },
        { ParameterType.Number, en = "Radius", de = "Radius" },
        { ParameterType.Number, en = "Sword", de = "Schwert" },
        { ParameterType.Number, en = "Bow", de = "Bogen" },
        { ParameterType.Custom, en = "Soldier type", de = "Soldatentyp" },
        { ParameterType.Custom, en = "Reuse troops", de = "Verwende bestehende Truppen" },
    },
}

function b_Reward_AI_SpawnAndAttackArea:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_AI_SpawnAndAttackArea:AddParameter(__index_, __parameter_)

    if (__index_ == 0) then
        self.AIPlayerID = __parameter_ * 1
    elseif (__index_ == 1) then
        self.Spawnpoint = __parameter_
    elseif (__index_ == 2) then
        self.TargetName = __parameter_
    elseif (__index_ == 3) then
        self.Radius = __parameter_ * 1
    elseif (__index_ == 4) then
        self.NumSword = __parameter_ * 1
    elseif (__index_ == 5) then
        self.NumBow = __parameter_ * 1
    elseif (__index_ == 6) then
        if __parameter_ == "Normal" or __parameter_ == false then
            self.TroopType = false
        elseif __parameter_ == "RedPrince" or __parameter_ == true then
            self.TroopType = true
        elseif __parameter_ == "Bandit" or __parameter_ == 2 then
            self.TroopType = 2
        elseif __parameter_ == "Cultist" or __parameter_ == 3 then
            self.TroopType = 3
        else
            assert(false)
        end
    elseif (__index_ == 7) then
        self.ReuseTroops = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Reward_AI_SpawnAndAttackArea:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 6 then
        table.insert( Data, "Normal" )
        table.insert( Data, "RedPrince" )
        table.insert( Data, "Bandit" )
        if g_GameExtraNo >= 1 then
            table.insert( Data, "Cultist" )
        end
    elseif __index_ == 7 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    else
        assert( false )
    end
    return Data
end

function b_Reward_AI_SpawnAndAttackArea:CustomFunction(__quest_)
    if Logic.IsEntityAlive( self.TargetName ) and Logic.IsEntityAlive( self.Spawnpoint ) then
        local TargetID = GetID( self.TargetName )
        AIScript_SpawnAndRaidSettlement( self.AIPlayerID, TargetID, self.Spawnpoint, self.Radius, self.NumSword, self.NumBow, self.TroopType, self.ReuseTroops )
    end
end

function b_Reward_AI_SpawnAndAttackArea:DEBUG(__quest_)
    if self.AIPlayerID < 2 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Player " .. self.AIPlayerID .. " is wrong")
        return true
    elseif Logic.IsEntityDestroyed(self.Spawnpoint) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Entity " .. self.SpawnPoint .. " is missing")
        return true
    elseif Logic.IsEntityDestroyed(self.TargetName) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Entity " .. self.TargetName .. " is missing")
        return true
    elseif self.Radius < 1 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Radius is to small or negative")
        return true
    elseif self.NumSword < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Number of Swords is negative")
        return true
    elseif self.NumBow < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Number of Bows is negative")
        return true
    elseif self.NumBow + self.NumSword < 1 then
        dbg(__quest_.Identifier .. ": Error in " .. self.Name .. ": No Soldiers?")
        return true
    end
    return false;
end

AddQuestBehavior(b_Reward_AI_SpawnAndAttackArea);

-- -------------------------------------------------------------------------- --

---
-- Erstellt eine Armee, die das Zielgebiet verteidigt.
--
-- @param _PlayerID     PlayerID des Angreifers
-- @param _SpawnPoint   Skriptname des Entstehungspunktes
-- @param _Target       Skriptname des Ziels
-- @param _Radius       Bewachtes Gebiet
-- @param _Time         Dauer der Bewachung (-1 für unendlich)
-- @param _Sword        Anzahl Schwertkämpfer (Battalione)
-- @param _Bow          Anzahl Bogenschützen (Battalione)
-- @param _CaptureCarts Soldaten greifen Karren an
-- @param _Type         Typ der Soldaten
-- @param _Reuse        Freie Truppen wiederverwenden
-- @return table: Behavior
-- @within Rewards
--
function Reward_AI_SpawnAndProtectArea(...)
    return b_Reward_AI_SpawnAndProtectArea:new(...);
end

b_Reward_AI_SpawnAndProtectArea = {
    Name = "Reward_AI_SpawnAndProtectArea",
    Description = {
        en = "Reward: Spawns AI troops and defends a specified area",
        de = "Lohn: Erstellt KI Truppen und verteidigt ein angegebenes Gebiet",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "AI Player", de = "KI Spieler" },
        { ParameterType.ScriptName, en = "Spawn point", de = "Erstellungsort" },
        { ParameterType.ScriptName, en = "Target", de = "Ziel" },
        { ParameterType.Number, en = "Radius", de = "Radius" },
        { ParameterType.Number, en = "Time (-1 for infinite)", de = "Zeit (-1 fuer unendlich)" },
        { ParameterType.Number, en = "Sword", de = "Schwert" },
        { ParameterType.Number, en = "Bow", de = "Bogen" },
        { ParameterType.Custom, en = "Capture tradecarts", de = "Handelskarren angreifen" },
        { ParameterType.Custom, en = "Soldier type", de = "Soldatentyp" },
        { ParameterType.Custom, en = "Reuse troops", de = "Verwende bestehende Truppen" },
    },
}

function b_Reward_AI_SpawnAndProtectArea:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_AI_SpawnAndProtectArea:AddParameter(__index_, __parameter_)

    if (__index_ == 0) then
        self.AIPlayerID = __parameter_ * 1
    elseif (__index_ == 1) then
        self.Spawnpoint = __parameter_
    elseif (__index_ == 2) then
        self.TargetName = __parameter_
    elseif (__index_ == 3) then
        self.Radius = __parameter_ * 1
    elseif (__index_ == 4) then
        self.Time = __parameter_ * 1
    elseif (__index_ == 5) then
        self.NumSword = __parameter_ * 1
    elseif (__index_ == 6) then
        self.NumBow = __parameter_ * 1
    elseif (__index_ == 7) then
        self.CaptureTradeCarts = AcceptAlternativeBoolean(__parameter_)
    elseif (__index_ == 8) then
        if __parameter_ == "Normal" or __parameter_ == true then
            self.TroopType = false
        elseif __parameter_ == "RedPrince" or __parameter_ == false then
            self.TroopType = true
        elseif __parameter_ == "Bandit" or __parameter_ == 2 then
            self.TroopType = 2
        elseif __parameter_ == "Cultist" or __parameter_ == 3 then
            self.TroopType = 3
        else
            assert(false)
        end
    elseif (__index_ == 9) then
        self.ReuseTroops = AcceptAlternativeBoolean(__parameter_)
    end

end

function b_Reward_AI_SpawnAndProtectArea:GetCustomData( __index_ )

    local Data = {}
    if __index_ == 7 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    elseif __index_ == 8 then
        table.insert( Data, "Normal" )
        table.insert( Data, "RedPrince" )
        table.insert( Data, "Bandit" )
        if g_GameExtraNo >= 1 then
            table.insert( Data, "Cultist" )
        end

    elseif __index_ == 9 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )

    else
        assert( false )
    end

    return Data

end

function b_Reward_AI_SpawnAndProtectArea:CustomFunction(__quest_)

    if Logic.IsEntityAlive( self.TargetName ) and Logic.IsEntityAlive( self.Spawnpoint ) then
        local TargetID = GetID( self.TargetName )
        AIScript_SpawnAndProtectArea( self.AIPlayerID, TargetID, self.Spawnpoint, self.Radius, self.NumSword, self.NumBow, self.Time, self.TroopType, self.ReuseTroops, self.CaptureTradeCarts )
    end

end

function b_Reward_AI_SpawnAndProtectArea:DEBUG(__quest_)
    if self.AIPlayerID < 2 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Player " .. self.AIPlayerID .. " is wrong")
        return true
    elseif Logic.IsEntityDestroyed(self.Spawnpoint) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Entity " .. self.SpawnPoint .. " is missing")
        return true
    elseif Logic.IsEntityDestroyed(self.TargetName) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Entity " .. self.TargetName .. " is missing")
        return true
    elseif self.Radius < 1 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Radius is to small or negative")
        return true
    elseif self.Time < -1 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Time is smaller than -1")
        return true
    elseif self.NumSword < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Number of Swords is negative")
        return true
    elseif self.NumBow < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Number of Bows is negative")
        return true
    elseif self.NumBow + self.NumSword < 1 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": No Soldiers?")
        return true
    end
    return false;
end

AddQuestBehavior(b_Reward_AI_SpawnAndProtectArea);

-- -------------------------------------------------------------------------- --

---
-- Ändert die Konfiguration eines KI-Spielers.
--
-- Optionen:
-- <ul>
-- <li>Courage/FEAR: Angstfaktor (0 bis ?)</li>
-- <li>Reconstruction/BARB: Wiederaufbau von Gebäuden (0 oder 1)</li>
-- <li>Build Order/BPMX: Buildorder ausführen (Nummer der Build Order)</li>
-- <li>Conquer Outposts/FCOP: Außenposten einnehmen (0 oder 1)</li>
-- <li>Mount Outposts/FMOP: Eigene Außenposten bemannen (0 oder 1)</li>
-- <li>max. Bowmen/FMBM: Maximale Anzahl an Bogenschützen (min. 1)</li>
-- <li>max. Swordmen/FMSM: Maximale Anzahl an Schwerkkämpfer (min. 1) </li>
-- <li>max. Rams/FMRA: Maximale Anzahl an Rammen (min. 1)</li>
-- <li>max. Catapults/FMCA: Maximale Anzahl an Katapulten (min. 1)</li>
-- <li>max. Ammunition Carts/FMAC: Maximale Anzahl an Minitionswagen (min. 1)</li>
-- <li>max. Siege Towers/FMST: Maximale Anzahl an Belagerungstürmen (min. 1)</li>
-- <li>max. Wall Catapults/FMBA: Maximale Anzahl an Mauerkatapulten (min. 1)</li>
-- </ul>
--
-- @param _PlayerID PlayerID des KI
-- @param _Fact     Konfigurationseintrag
-- @param _Value    Neuer Wert
-- @return table: Behavior
-- @within Rewards
--
function Reward_AI_SetNumericalFact(...)
    return b_Reward_AI_SetNumericalFact:new(...);
end

b_Reward_AI_SetNumericalFact = {
    Name = "Reward_AI_SetNumericalFact",
    Description = {
        en = "Reward: Sets a numerical fact for the AI player",
        de = "Lohn: Setzt eine Verhaltensregel fuer den KI-Spieler. ",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "AI Player",      de = "KI Spieler" },
        { ParameterType.Custom,   en = "Numerical Fact", de = "Verhaltensregel" },
        { ParameterType.Number,   en = "Value",          de = "Wert" },
    },
}

function b_Reward_AI_SetNumericalFact:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_AI_SetNumericalFact:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.AIPlayerID = __parameter_ * 1
    elseif (__index_ == 1) then
        -- mapping of numerical facts
        local fact = {
            ["Courage"]               = "FEAR",
            ["Reconstruction"]        = "BARB",
            ["Build Order"]           = "BPMX",
            ["Conquer Outposts"]      = "FCOP",
            ["Mount Outposts"]        = "FMOP",
            ["max. Bowmen"]           = "FMBM",
            ["max. Swordmen"]         = "FMSM",
            ["max. Rams"]             = "FMRA",
            ["max. Catapults"]        = "FMCA",
            ["max. Ammunition Carts"] = "FMAC",
            ["max. Siege Towers"]     = "FMST",
            ["max. Wall Catapults"]   = "FMBA",
            ["FEAR"]                  = "FEAR", -- > 0
            ["BARB"]                  = "BARB", -- 1 or 0
            ["BPMX"]                  = "BPMX", -- >= 0
            ["FCOP"]                  = "FCOP", -- 1 or 0
            ["FMOP"]                  = "FMOP", -- 1 or 0
            ["FMBM"]                  = "FMBM", -- >= 0
            ["FMSM"]                  = "FMSM", -- >= 0
            ["FMRA"]                  = "FMRA", -- >= 0
            ["FMCA"]                  = "FMCA", -- >= 0
            ["FMAC"]                  = "FMAC", -- >= 0
            ["FMST"]                  = "FMST", -- >= 0
            ["FMBA"]                  = "FMBA", -- >= 0
        }
        self.NumericalFact = fact[__parameter_]
    elseif (__index_ == 2) then
        self.Value = __parameter_ * 1
    end
end

function b_Reward_AI_SetNumericalFact:CustomFunction(__quest_)
    AICore.SetNumericalFact( self.AIPlayerID, self.NumericalFact, self.Value )
end

function b_Reward_AI_SetNumericalFact:GetCustomData(__index_)
    if (__index_ == 1) then
        return {
            "Courage",
            "Reconstruction",
            "Build Order",
            "Conquer Outposts",
            "Mount Outposts",
            "max. Bowmen",
            "max. Swordmen",
            "max. Rams",
            "max. Catapults",
            "max. Ammunition Carts",
            "max. Siege Towers",
            "max. Wall Catapults",
        };
    end
end

function b_Reward_AI_SetNumericalFact:DEBUG(__quest_)
    if Logic.GetStoreHouse(self.AIPlayerID) == 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Player " .. self.AIPlayerID .. " is wrong or dead")
        return true
    elseif not self.NumericalFact then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": invalid numerical fact choosen")
        return true
    else
        if self.NumericalFact == "BARB" or self.NumericalFact == "FCOP" or self.NumericalFact == "FMOP" then
            if self.Value ~= 0 and self.Value ~= 1 then
                dbg(__quest_.Identifier .. " " .. self.Name .. ": BARB, FCOP, FMOP: value must be 1 or 0")
                return true
            end
        elseif self.NumericalFact == "FEAR" then
            if self.Value <= 0 then
                dbg(__quest_.Identifier .. " " .. self.Name .. ": FEAR: value must greater than 0")
                return true
            end
        else
            if self.Value < 0 then
                dbg(__quest_.Identifier .. " " .. self.Name .. ": BPMX, FMBM, FMSM, FMRA, FMCA, FMAC, FMST, FMBA: value must greater than or equal 0")
                return true
            end
        end
    end
    return false
end

AddQuestBehavior(b_Reward_AI_SetNumericalFact);

-- -------------------------------------------------------------------------- --

---
-- Stellt den Aggressivitätswert des KI-Spielers nachträglich ein.
--
-- @param _PlayerID         PlayerID des KI-Spielers
-- @param _Aggressiveness   Aggressivitätswert (1 bis 3)
-- @return table: Behavior
-- @within Rewards
--
function Reward_AI_Aggressiveness(...)
    return b_Reward_AI_Aggressiveness:new(...);
end

b_Reward_AI_Aggressiveness = {
    Name = "Reward_AI_Aggressiveness",
    Description = {
        en = "Reward: Sets the AI player's aggressiveness.",
        de = "Lohn: Setzt die Aggressivitaet des KI-Spielers fest.",
    },
    Parameter =
    {
        { ParameterType.PlayerID, en = "AI player", de = "KI-Spieler" },
        { ParameterType.Custom, en = "Aggressiveness (1-3)", de = "Aggressivitaet (1-3)" }
    }
};

function b_Reward_AI_Aggressiveness:GetRewardTable()
    return {Reward.Custom, {self, self.CustomFunction} };
end

function b_Reward_AI_Aggressiveness:AddParameter(__index_, __parameter_)
    if __index_ == 0 then
        self.AIPlayer = __parameter_ * 1;
    elseif __index_ == 1 then
        self.Aggressiveness = tonumber(__parameter_);
    end
end

function b_Reward_AI_Aggressiveness:CustomFunction()
    local player = (PlayerAIs[self.AIPlayer]
        or AIPlayerTable[self.AIPlayer]
        or AIPlayer:new(self.AIPlayer, AIPlayerProfile_City));
    PlayerAIs[self.AIPlayer] = player;
    if self.Aggressiveness >= 2 then
        player.m_ProfileLoop = AIProfile_Skirmish;
        player.Skirmish = player.Skirmish or {};
        player.Skirmish.Claim_MinTime = SkirmishDefault.Claim_MinTime + (self.Aggressiveness - 2) * 390;
        player.Skirmish.Claim_MaxTime = player.Skirmish.Claim_MinTime * 2;
    else
        player.m_ProfileLoop = AIPlayerProfile_City;
    end
end

function b_Reward_AI_Aggressiveness:DEBUG(__quest_)
    if self.AIPlayer < 2 or Logic.GetStoreHouse(self.AIPlayer) == 0 then
        dbg(__quest_.Identifier .. ": Error in " .. self.Name .. ": Player " .. self.PlayerID .. " is wrong")
        return true
    end
end

function b_Reward_AI_Aggressiveness:GetCustomData(__index_)
    assert(__index_ == 1, "Error in " .. self.Name .. ": GetCustomData: Index is invalid.");
    return { "1", "2", "3" };
end

AddQuestBehavior(b_Reward_AI_Aggressiveness)

-- -------------------------------------------------------------------------- --

---
-- Stellt den Feind des Skirmish-KI ein.
--
-- Der Skirmish-KI (maximale Aggressivität) kann nur einen Spieler als Feind
-- behandeln. Für gewöhnlich ist dies der menschliche Spieler.
--
-- @param _PlayerID      PlayerID des KI
-- @param _EnemyPlayerID PlayerID des Feindes
-- @return table: Behavior
-- @within Rewards
--
function Reward_AI_SetEnemy(...)
    return b_Reward_AI_SetEnemy:new(...);
end

b_Reward_AI_SetEnemy = {
    Name = "Reward_AI_SetEnemy",
    Description = {
        en = "Reward:Sets the enemy of an AI player (the AI only handles one enemy properly).",
        de = "Lohn: Legt den Feind eines KI-Spielers fest (die KI behandelt nur einen Feind korrekt).",
    },
    Parameter =
    {
        { ParameterType.PlayerID, en = "AI player", de = "KI-Spieler" },
        { ParameterType.PlayerID, en = "Enemy", de = "Feind" }
    }
};

function b_Reward_AI_SetEnemy:GetRewardTable()

    return {Reward.Custom, {self, self.CustomFunction} };

end

function b_Reward_AI_SetEnemy:AddParameter(__index_, __parameter_)

    if __index_ == 0 then
        self.AIPlayer = __parameter_ * 1;
    elseif __index_ == 1 then
        self.Enemy = __parameter_ * 1;
    end

end

function b_Reward_AI_SetEnemy:CustomFunction()

    local player = PlayerAIs[self.AIPlayer];
    if player and player.Skirmish then
        player.Skirmish.Enemy = self.Enemy;
    end

end

function b_Reward_AI_SetEnemy:DEBUG(__quest_)

    if self.AIPlayer <= 1 or self.AIPlayer >= 8 or Logic.PlayerGetIsHumanFlag(self.AIPlayer) then
        dbg(__quest_.Identifier .. ": Error in " .. self.Name .. ": Player " .. self.AIPlayer .. " is wrong")
        return true
    end

end
AddQuestBehavior(b_Reward_AI_SetEnemy)

-- -------------------------------------------------------------------------- --

---
-- Ein Entity wird durch ein neues anderen Typs ersetzt.
--
-- Das neue Entity übernimmt Skriptname und Ausrichtung des alten Entity.
--
-- @param _Entity Skriptname oder ID des Entity
-- @param _Type   Neuer Typ des Entity
-- @param _Owner  Besitzer des Entity
-- @return table: behavior
-- @within Rewards
--
function Reward_ReplaceEntity(...)
    return b_Reward_ReplaceEntity:new(...);
end

b_Reward_ReplaceEntity = API.InstanceTable(b_Reprisal_ReplaceEntity);
b_Reward_ReplaceEntity.Name = "Reward_ReplaceEntity";
b_Reward_ReplaceEntity.Description.en = "Reward: Replaces an entity with a new one of a different type. The playerID can be changed too.";
b_Reward_ReplaceEntity.Description.de = "Lohn: Ersetzt eine Entity durch eine neue anderen Typs. Es kann auch die Spielerzugehoerigkeit geaendert werden.";
b_Reward_ReplaceEntity.GetReprisalTable = nil;

b_Reward_ReplaceEntity.GetRewardTable = function(self)
    return { Reward.Custom,{self, self.CustomFunction} }
end

AddQuestBehavior(b_Reward_ReplaceEntity);

-- -------------------------------------------------------------------------- --

---
-- Setzt die Menge von Rohstoffen in einer Mine.
--
-- Achtung: Im Reich des Ostens darf die Mine nicht eingestürzt sein!
--
-- @param _ScriptName Skriptname der Mine
-- @param _Amount     Menge an Rohstoffen
-- @return table: Behavior
-- @within Rewards
--
function Reward_SetResourceAmount(...)
    return b_Reward_SetResourceAmount:new(...);
end

b_Reward_SetResourceAmount = {
    Name = "Reward_SetResourceAmount",
    Description = {
        en = "Reward: Set the current and maximum amount of a resource doodad (the amount can also set to 0)",
        de = "Lohn: Setzt die aktuellen sowie maximalen Resourcen in einem Doodad (auch 0 ist moeglich)",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Ressource", de = "Resource" },
        { ParameterType.Number, en = "Amount", de = "Menge" },
    },
}

function b_Reward_SetResourceAmount:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_SetResourceAmount:AddParameter(__index_, __parameter_)

    if (__index_ == 0) then
        self.ScriptName = __parameter_
    elseif (__index_ == 1) then
        self.Amount = __parameter_ * 1
    end

end

function b_Reward_SetResourceAmount:CustomFunction(__quest_)
    if Logic.IsEntityDestroyed( self.ScriptName ) then
        return false
    end
    local EntityID = GetID( self.ScriptName )
    if Logic.GetResourceDoodadGoodType( EntityID ) == 0 then
        return false
    end
    Logic.SetResourceDoodadGoodAmount( EntityID, self.Amount )
end

function b_Reward_SetResourceAmount:DEBUG(__quest_)
    if not IsExisting(self.ScriptName) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": resource entity does not exist!")
        return true
    elseif not type(self.Amount) == "number" or self.Amount < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": resource amount can not be negative!")
        return true
    end
    return false;
end

AddQuestBehavior(b_Reward_SetResourceAmount);

-- -------------------------------------------------------------------------- --

---
-- Fügt dem Lagerhaus des Auftragnehmers eine Menge an Rohstoffen hinzu.
--
-- @param _Type   Rohstofftyp
-- @param _Amount Menge an Rohstoffen
-- @return table: Behavior
-- @within Rewards
--
function Reward_Resources(...)
    return b_Reward_Resources:new(...);
end

b_Reward_Resources = {
    Name = "Reward_Resources",
    Description = {
        en = "Reward: The player receives a given amount of Goods in his store.",
        de = "Lohn: Legt der Partei die angegebenen Rohstoffe ins Lagerhaus.",
    },
    Parameter = {
        { ParameterType.RawGoods, en = "Type of good", de = "Resourcentyp" },
        { ParameterType.Number, en = "Amount of good", de = "Anzahl der Resource" },
    },
}

function b_Reward_Resources:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.GoodTypeName = __parameter_
    elseif (__index_ == 1) then
        self.GoodAmount = __parameter_ * 1
    end
end

function b_Reward_Resources:GetRewardTable()
    local GoodType = Logic.GetGoodTypeID(self.GoodTypeName)
    return { Reward.Resources, GoodType, self.GoodAmount }
end

AddQuestBehavior(b_Reward_Resources);

-- -------------------------------------------------------------------------- --

---
-- Entsendet einen Karren zum angegebenen Spieler.
--
-- Wenn der Spawnpoint ein Gebäude ist, wird der Wagen am Eingang erstellt.
-- Andernfalls kann der Spawnpoint gelöscht werden und der Wagen übernimmt
-- dann den Skriptnamen.
--
-- @param _ScriptName    Skriptname des Spawnpoint
-- @param _Owner         Empfänger der Lieferung
-- @param _Type          Typ des Wagens
-- @param _Good          Typ der Ware
-- @param _Amount        Menge an Waren
-- @param _OtherPlayer   Anderer Empfänger als Auftraggeber
-- @param _NoReservation Platzreservation auf dem Markt ignorieren (Sinnvoll?)
-- @param _Replace       Spawnpoint ersetzen
-- @return table: Behavior
-- @within Rewards
--
function Reward_SendCart(...)
    return b_Reward_SendCart:new(...);
end

b_Reward_SendCart = {
    Name = "Reward_SendCart",
    Description = {
        en = "Reward: Sends a cart to a player. It spawns at a building or by replacing an entity. The cart can replace the entity if it's not a building.",
        de = "Lohn: Sendet einen Karren zu einem Spieler. Der Karren wird an einem Gebaeude oder einer Entity erstellt. Er ersetzt die Entity, wenn diese kein Gebaeude ist.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script entity", de = "Script Entity" },
        { ParameterType.PlayerID, en = "Owning player", de = "Besitzer" },
        { ParameterType.Custom, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Custom, en = "Good type", de = "Warentyp" },
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
        { ParameterType.Custom, en = "Override target player", de = "Anderer Zielspieler" },
        { ParameterType.Custom, en = "Ignore reservations", de = "Ignoriere Reservierungen" },
        { ParameterType.Custom, en = "Replace entity", de = "Entity ersetzen" },
    },
}

function b_Reward_SendCart:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_SendCart:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.ScriptNameEntity = __parameter_
    elseif (__index_ == 1) then
        self.PlayerID = __parameter_ * 1
    elseif (__index_ == 2) then
        self.UnitKey = __parameter_
    elseif (__index_ == 3) then
        self.GoodType = __parameter_
    elseif (__index_ == 4) then
        self.GoodAmount = __parameter_ * 1
    elseif (__index_ == 5) then
        self.OverrideTargetPlayer = tonumber(__parameter_)
    elseif (__index_ == 6) then
        self.IgnoreReservation = AcceptAlternativeBoolean(__parameter_)
    elseif (__index_ == 7) then
        self.ReplaceEntity = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Reward_SendCart:CustomFunction(__quest_)

    if not IsExisting( self.ScriptNameEntity ) then
        return false;
    end

    local ID = SendCart(self.ScriptNameEntity,
                        self.PlayerID,
                        Goods[self.GoodType],
                        self.GoodAmount,
                        Entities[self.UnitKey],
                        self.IgnoreReservation    );

    if self.ReplaceEntity and Logic.IsBuilding(GetID(self.ScriptNameEntity)) == 0 then
        DestroyEntity(self.ScriptNameEntity);
        Logic.SetEntityName(ID, self.ScriptNameEntity);
    end
    if self.OverrideTargetPlayer then
        Logic.ResourceMerchant_OverrideTargetPlayerID(ID,self.OverrideTargetPlayer);
    end
end

function b_Reward_SendCart:GetCustomData( __index_ )
    local Data = {}
    if __index_ == 2 then
        Data = { "U_ResourceMerchant", "U_Medicus", "U_Marketer", "U_ThiefCart", "U_GoldCart", "U_Noblemen_Cart", "U_RegaliaCart" }
    elseif __index_ == 3 then
        for k, v in pairs( Goods ) do
            if string.find( k, "^G_" ) then
                table.insert( Data, k )
            end
        end
        table.sort( Data )
    elseif __index_ == 5 then
        table.insert( Data, "---" )
        for i = 1, 8 do
            table.insert( Data, i )
        end
    elseif __index_ == 6 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    elseif __index_ == 7 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    end
    return Data
end

function b_Reward_SendCart:DEBUG(__quest_)
    if not IsExisting(self.ScriptNameEntity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": spawnpoint does not exist!");
        return true;
    elseif not tonumber(self.PlayerID) or self.PlayerID < 1 or self.PlayerID > 8 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": got a invalid playerID!");
        return true;
    elseif not Entities[self.UnitKey] then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": entity type '"..self.UnitKey.."' is invalid!");
        return true;
    elseif not Goods[self.GoodType] then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": good type '"..self.GoodType.."' is invalid!");
        return true;
    elseif not tonumber(self.GoodAmount) or self.GoodAmount < 1 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": good amount can not be below 1!");
        return true;
    elseif tonumber(self.OverrideTargetPlayer) and (self.OverrideTargetPlayer < 1 or self.OverrideTargetPlayer > 8) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": overwrite target player with invalid playerID!");
        return true;
    end
    return false;
end

AddQuestBehavior(b_Reward_SendCart);

-- -------------------------------------------------------------------------- --

---
-- Gibt dem Auftragnehmer eine Menge an Einheiten.
--
-- Die Einheiten erscheinen an der Burg. Hat der Spieler keine Burg, dann
-- erscheinen sie vorm Lagerhaus.
--
-- @param _Type   Typ der Einheit
-- @param _Amount Menge an Einheiten
-- @return table: Behavior
-- @within Rewards
--
function Reward_Units(...)
    return b_Reward_Units:new(...)
end

b_Reward_Units = {
    Name = "Reward_Units",
    Description = {
        en = "Reward: Units",
        de = "Lohn: Einheiten",
    },
    Parameter = {
        { ParameterType.Entity, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
    },
}

function b_Reward_Units:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.EntityName = __parameter_
    elseif (__index_ == 1) then
        self.Amount = __parameter_ * 1
    end
end

function b_Reward_Units:GetRewardTable()
    return { Reward.Units, assert( Entities[self.EntityName] ), self.Amount }
end

AddQuestBehavior(b_Reward_Units);

-- -------------------------------------------------------------------------- --

---
-- Startet einen Quest neu.
--
-- @param _QuestName Name des Quest
-- @return table: Behavior
-- @within Rewards
--
function Reward_QuestRestart(...)
    return b_Reward_QuestRestart(...)
end

b_Reward_QuestRestart = API.InstanceTable(b_Reprisal_QuestRestart);
b_Reward_QuestRestart.Name = "Reward_ReplaceEntity";
b_Reward_QuestRestart.Description.en = "Reward: Restarts a (completed) quest so it can be triggered and completed again.";
b_Reward_QuestRestart.Description.de = "Lohn: Startet eine (beendete) Quest neu, damit diese neu ausgeloest und beendet werden kann.";
b_Reward_QuestRestart.GetReprisalTable = nil;

b_Reward_QuestRestart.GetRewardTable = function(self, __quest_)
    return { Reward.Custom,{self, self.CustomFunction} }
end

AddQuestBehavior(b_Reward_QuestRestart);

-- -------------------------------------------------------------------------- --

---
-- Lässt einen Quest fehlschlagen.
--
-- @param _QuestName Name des Quest
-- @return table: Behavior
-- @within Rewards
--
function Reward_QuestFailure(...)
    return b_Reward_QuestFailure(...)
end

b_Reward_QuestFailure = API.InstanceTable(b_Reprisal_ReplaceEntity);
b_Reward_QuestFailure.Name = "Reward_QuestFailure";
b_Reward_QuestFailure.Description.en = "Reward: Lets another active quest fail.";
b_Reward_QuestFailure.Description.de = "Lohn: Laesst eine andere aktive Quest fehlschlagen.";
b_Reward_QuestFailure.GetReprisalTable = nil;

b_Reward_QuestFailure.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

AddQuestBehavior(b_Reward_QuestFailure);

-- -------------------------------------------------------------------------- --

---
-- Wertet einen Quest als erfolgreich.
--
-- @param _QuestName Name des Quest
-- @return table: Behavior
-- @within Rewards
--
function Reward_QuestSuccess(...)
    return b_Reward_QuestSuccess(...)
end

b_Reward_QuestSuccess = API.InstanceTable(b_Reprisal_QuestSuccess);
b_Reward_QuestSuccess.Name = "Reward_QuestSuccess";
b_Reward_QuestSuccess.Description.en = "Reward: Completes another active quest successfully.";
b_Reward_QuestSuccess.Description.de = "Lohn: Beendet eine andere aktive Quest erfolgreich.";
b_Reward_QuestSuccess.GetReprisalTable = nil;

b_Reward_QuestSuccess.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

AddQuestBehavior(b_Reward_QuestSuccess);

-- -------------------------------------------------------------------------- --

---
-- Triggert einen Quest.
--
-- @param _QuestName Name des Quest
-- @return table: Behavior
-- @within Rewards
--
function Reward_QuestActivate(...)
    return b_Reward_QuestActivate(...)
end

b_Reward_QuestActivate = API.InstanceTable(b_Reprisal_QuestActivate);
b_Reward_QuestActivate.Name = "Reward_QuestActivate";
b_Reward_QuestActivate.Description.en = "Reward: Activates another quest that is not triggered yet.";
b_Reward_QuestActivate.Description.de = "Lohn: Aktiviert eine andere Quest die noch nicht ausgeloest wurde.";
b_Reward_QuestActivate.GetReprisalTable = nil;

b_Reward_QuestActivate.GetRewardTable = function(self, _Quest)
    return {Reward.Custom, {self, self.CustomFunction} }
end

AddQuestBehavior(b_Reward_QuestActivate)

-- -------------------------------------------------------------------------- --

---
-- Unterbricht einen Quest.
--
-- @param _QuestName Name des Quest
-- @return table: Behavior
-- @within Rewards
--
function Reward_QuestInterrupt(...)
    return b_Reward_QuestInterrupt(...)
end

b_Reward_QuestInterrupt = API.InstanceTable(b_Reprisal_QuestInterrupt);
b_Reward_QuestInterrupt.Name = "Reward_QuestInterrupt";
b_Reward_QuestInterrupt.Description.en = "Reward: Interrupts another active quest without success or failure.";
b_Reward_QuestInterrupt.Description.de = "Lohn: Beendet eine andere aktive Quest ohne Erfolg oder Misserfolg.";
b_Reward_QuestInterrupt.GetReprisalTable = nil;

b_Reward_QuestInterrupt.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

AddQuestBehavior(b_Reward_QuestInterrupt);

-- -------------------------------------------------------------------------- --

---
-- Unterbricht einen Quest, selbst wenn dieser noch nicht ausgelöst wurde.
--
-- @param _QuestName   Name des Quest
-- @param _EndetQuests Bereits beendete unterbrechen
-- @return table: Behavior
-- @within Rewards
--
function Reward_QuestForceInterrupt(...)
    return b_Reward_QuestForceInterrupt(...)
end

b_Reward_QuestForceInterrupt = API.InstanceTable(b_Reprisal_QuestForceInterrupt);
b_Reward_QuestForceInterrupt.Name = "Reward_QuestForceInterrupt";
b_Reward_QuestForceInterrupt.Description.en = "Reward: Interrupts another quest (even when it isn't active yet) without success or failure.";
b_Reward_QuestForceInterrupt.Description.de = "Lohn: Beendet eine andere Quest, auch wenn diese noch nicht aktiv ist ohne Erfolg oder Misserfolg.";
b_Reward_QuestForceInterrupt.GetReprisalTable = nil;

b_Reward_QuestForceInterrupt.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

AddQuestBehavior(b_Reward_QuestForceInterrupt);

-- -------------------------------------------------------------------------- --
-- Trigger                                                                    --
-- -------------------------------------------------------------------------- --

---
-- Starte den Quest, wenn ein anderer Spieler entdeckt wurde.
--
-- Ein Spieler ist dann entdeckt, wenn sein Heimatterritorium aufgedeckt wird.
--
-- @param _PlayerID Zu entdeckender Spieler
-- @return table: Behavior
-- @within Trigger
--
function Trigger_PlayerDiscovered(...)
    return b_Trigger_PlayerDiscovered:new(...);
end

b_Trigger_PlayerDiscovered = {
    Name = "Trigger_PlayerDiscovered",
    Description = {
        en = "Trigger: if a given player has been discovered",
        de = "Ausloeser: wenn ein angegebener Spieler entdeckt wurde",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
    },
}

function b_Trigger_PlayerDiscovered:GetTriggerTable(__quest_)
    return {Triggers.PlayerDiscovered, self.PlayerID}
end

function b_Trigger_PlayerDiscovered:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1;
    end
end

AddQuestBehavior(b_Trigger_PlayerDiscovered);

-- -------------------------------------------------------------------------- --

---
-- Starte den Quest, wenn zwischen dem Empfänger und der angegebenen Partei
-- der geforderte Diplomatiestatus herrscht.
--
-- @param _PlayerID ID der Partei
-- @param _State    Diplomatie-Status
-- @return table: Behavior
-- @within Trigger
--
function Trigger_OnDiplomacy(...)
    return b_Trigger_OnDiplomacy:new(...);
end

b_Trigger_OnDiplomacy = {
    Name = "Trigger_OnDiplomacy",
    Description = {
        en = "Trigger: if diplomatic relations have been established with a player",
        de = "Ausloeser: wenn ein angegebener Diplomatie-Status mit einem Spieler erreicht wurde.",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.DiplomacyState, en = "Relation", de = "Beziehung" },
    },
}

function b_Trigger_OnDiplomacy:GetTriggerTable(__quest_)
    return {Triggers.Diplomacy, self.PlayerID, assert( DiplomacyStates[self.DiplState] ) }
end

function b_Trigger_OnDiplomacy:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    elseif (__index_ == 1) then
        self.DiplState = __parameter_
    end
end

AddQuestBehavior(b_Trigger_OnDiplomacy);

-- -------------------------------------------------------------------------- --

---
-- Starte den Quest, sobald ein Bedürfnis nicht erfüllt wird.
--
-- @param _PlayerID ID des Spielers
-- @param _Need     Bedürfnis
-- @param _Amount   Menge an skreikenden Siedlern
-- @return table: Behavior
-- @within Trigger
-- 
function Trigger_OnNeedUnsatisfied(...)
    return b_Trigger_OnNeedUnsatisfied:new(...);
end

b_Trigger_OnNeedUnsatisfied = {
    Name = "Trigger_OnNeedUnsatisfied",
    Description = {
        en = "Trigger: if a specified need is unsatisfied",
        de = "Ausloeser: wenn ein bestimmtes Beduerfnis nicht befriedigt ist.",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Need, en = "Need", de = "Beduerfnis" },
        { ParameterType.Number, en = "Workers on strike", de = "Streikende Arbeiter" },
    },
}

function b_Trigger_OnNeedUnsatisfied:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnNeedUnsatisfied:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    elseif (__index_ == 1) then
        self.Need = __parameter_
    elseif (__index_ == 2) then
        self.WorkersOnStrike = __parameter_ * 1
    end
end

function b_Trigger_OnNeedUnsatisfied:CustomFunction(__quest_)
    return Logic.GetNumberOfStrikingWorkersPerNeed( self.PlayerID, Needs[self.Need] ) >= self.WorkersOnStrike
end

function b_Trigger_OnNeedUnsatisfied:DEBUG(__quest_)
    if Logic.GetStoreHouse(self.PlayerID) == 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": " .. self.PlayerID .. " does not exist.")
        return true
    elseif not Needs[self.Need] then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": " .. self.Need .. " does not exist.")
        return true
    elseif self.WorkersOnStrike < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": WorkersOnStrike value negative")
        return true
    end
    return false;
end

AddQuestBehavior(b_Trigger_OnNeedUnsatisfied);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, wenn die angegebene Mine erschöpft ist.
-- 
-- @param _ScriptName Skriptname der Mine
-- @return table: Behavior
-- @within Trigger
--
function Trigger_OnResourceDepleted(...)
    return b_Trigger_OnResourceDepleted:new(...);
end

b_Trigger_OnResourceDepleted = {
    Name = "Trigger_OnResourceDepleted",
    Description = {
        en = "Trigger: if a resource is (temporarily) depleted",
        de = "Ausloeser: wenn eine Ressource (zeitweilig) verbraucht ist",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
    },
}

function b_Trigger_OnResourceDepleted:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnResourceDepleted:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.ScriptName = __parameter_
    end
end

function b_Trigger_OnResourceDepleted:CustomFunction(__quest_)
    local ID = GetID(self.ScriptName)
    return not ID or ID == 0 or Logic.GetResourceDoodadGoodType(ID) == 0 or Logic.GetResourceDoodadGoodAmount(ID) == 0
end

AddQuestBehavior(b_Trigger_OnResourceDepleted);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald der angegebene Spieler eine Menge an Rohstoffen
-- im Lagerhaus hat.
--
-- @param  _PlayerID ID des Spielers
-- @param  _Type     Typ des Rohstoffes
-- @param _Amount    Menge an Rohstoffen
-- @return table: Behavior
-- @within Trigger
--
function Trigger_OnAmountOfGoods(...)
    return b_Trigger_OnAmountOfGoods:new(...);
end

b_Trigger_OnAmountOfGoods = {
    Name = "Trigger_OnAmountOfGoods",
    Description = {
        en = "Trigger: if the player has gathered a given amount of resources in his storehouse",
        de = "Ausloeser: wenn der Spieler eine bestimmte Menge einer Ressource in seinem Lagerhaus hat",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.RawGoods, en = "Type of good", de = "Resourcentyp" },
        { ParameterType.Number, en = "Amount of good", de = "Anzahl der Resource" },
    },
}

function b_Trigger_OnAmountOfGoods:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnAmountOfGoods:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.PlayerID = __parameter_ * 1
    elseif (__index_ == 1) then
        self.GoodTypeName = __parameter_
    elseif (__index_ == 2) then
        self.GoodAmount = __parameter_ * 1
    end
end

function b_Trigger_OnAmountOfGoods:CustomFunction(__quest_)
    local StoreHouseID = Logic.GetStoreHouse(self.PlayerID)
    if (StoreHouseID == 0) then
        return false
    end
    local GoodType = Logic.GetGoodTypeID(self.GoodTypeName)
    local GoodAmount = Logic.GetAmountOnOutStockByGoodType(StoreHouseID, GoodType)
    if (GoodAmount >= self.GoodAmount)then
        return true
    end
    return false
end

function b_Trigger_OnAmountOfGoods:DEBUG(__quest_)
    if Logic.GetStoreHouse(self.PlayerID) == 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": " .. self.PlayerID .. " does not exist.")
        return true
    elseif not Goods[self.GoodTypeName] then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Good type is wrong.")
        return true
    elseif self.GoodAmount < 0 then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": Good amount is negative.")
        return true
    end
    return false;
end

AddQuestBehavior(b_Trigger_OnAmountOfGoods);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald ein anderer aktiv ist.
--
-- @param _QuestName Name des Quest
-- @param _Time      Wartezeit
-- return table: Behavior
-- @within Trigger
--
function Trigger_OnQuestActive(...)
    return b_Trigger_OnQuestActive(...);
end

b_Trigger_OnQuestActive = {
    Name = "Trigger_OnQuestActive",
    Description = {
        en = "Trigger: if a given quest has been activated. Waiting time optional",
        de = "Ausloeser: wenn eine angegebene Quest aktiviert wurde. Optional mit Wartezeit",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Questname" },
        { ParameterType.Number,     en = "Waiting time", de = "Wartezeit"},
    },
}

function b_Trigger_OnQuestActive:GetTriggerTable(__quest_)
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnQuestActive:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.QuestName = __parameter_
    elseif (__index_ == 1) then
        self.WaitTime = (__parameter_ ~= nil and tonumber(__parameter_)) or 0
    end
end

function b_Trigger_OnQuestActive:CustomFunction(__quest_)
    local QuestID = GetQuestID(self.QuestName)
    if QuestID ~= nil then
        assert(type(QuestID) == "number");

        if (Quests[QuestID].State == QuestState.Active) then
            self.WasActivated = self.WasActivated or true;
        end
        if self.WasActivated then
            if self.WaitTime and self.WaitTime > 0 then
                self.WaitTimeTimer = self.WaitTimeTimer or Logic.GetTime();
                if Logic.GetTime() >= self.WaitTimeTimer + self.WaitTime then
                    return true;
                end
            else
                return true;
            end
        end
    end
    return false;
end

function b_Trigger_OnQuestActive:DEBUG(__quest_)
    if type(self.QuestName) ~= "string" then
        local text = string.format("%s Trigger_OnQuestActive: invalid quest name!", __quest_.Identifier);
        dbg(text);
        return true;
    elseif type(self.WaitTime) ~= "number" then
        local text = string.format("%s Trigger_OnQuestActive: waitTime must be a number!", __quest_.Identifier);
        dbg(text);
        return true;
    end
    return false;
end

function b_Trigger_OnQuestActive:Interrupt()
    -- does this realy matter after interrupt?
    -- self.WaitTimeTimer = nil;
    -- self.WasActivated = nil;
end

function b_Trigger_OnQuestActive:Reset()
    self.WaitTimeTimer = nil;
    self.WasActivated = nil;
end

AddQuestBehavior(b_Trigger_OnQuestActive);

-- -------------------------------------------------------------------------- --

---
-- Startet einen Quest, sobald ein anderer fehlschlägt.
--
-- @param _QuestName Name des Quest
-- @param _Time      Wartezeit
-- return table: Behavior
-- @within Trigger
--
function Trigger_OnQuestFailure(...)
    return b_Trigger_OnQuestFailure(...);
end

b_Trigger_OnQuestFailure = {
    Name = "Trigger_OnQuestFailure",
    Description = {
        en = "Trigger: if a given quest has failed. Waiting time optional",
        de = "Ausloeser: wenn eine angegebene Quest fehlgeschlagen ist. Optional mit Wartezeit",
    },
    Parameter = {
        { ParameterType.QuestName,     en = "Quest name", de = "Questname" },
        { ParameterType.Number,     en = "Waiting time", de = "Wartezeit"},
    },
}

function b_Trigger_OnQuestFailure:GetTriggerTable(__quest_)
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnQuestFailure:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.QuestName = __parameter_
    elseif (__index_ == 1) then
        self.WaitTime = (__parameter_ ~= nil and tonumber(__parameter_)) or 0
    end
end

function b_Trigger_OnQuestFailure:CustomFunction(__quest_)
    if (GetQuestID(self.QuestName) ~= nil) then
        local QuestID = GetQuestID(self.QuestName)
        if (Quests[QuestID].Result == QuestResult.Failure) then
            if self.WaitTime and self.WaitTime > 0 then
                self.WaitTimeTimer = self.WaitTimeTimer or Logic.GetTime();
                if Logic.GetTime() >= self.WaitTimeTimer + self.WaitTime then
                    return true;
                end
            else
                return true;
            end
        end
    end
    return false;
end

function b_Trigger_OnQuestFailure:DEBUG(__quest_)
    if type(self.QuestName) ~= "string" then
        local text = string.format("%s Trigger_OnQuestFailure: invalid quest name!", __quest_.Identifier);
        dbg(text);
        return true;
    elseif type(self.WaitTime) ~= "number" then
        local text = string.format("%s Trigger_OnQuestFailure: waitTime must be a number!", __quest_.Identifier);
        dbg(text);
        return true;
    end
    return false;
end

function b_Trigger_OnQuestFailure:Interrupt()
    self.WaitTimeTimer = nil;
end

function b_Trigger_OnQuestFailure:Reset()
    self.WaitTimeTimer = nil;
end

AddQuestBehavior(b_Trigger_OnQuestFailure);

-- -------------------------------------------------------------------------- --

---
-- Startet einen Quest, wenn ein anderer noch nicht ausgelöst wurde.
--
-- Der Trigger löst auch aus, wenn der Quest bereits beendet wurde, da er
-- dazu vorher ausgelöst wurden sein muss.
--
-- @param _QuestName Name des Quest
-- @param _Time      Wartezeit
-- return table: Behavior
-- @within Trigger
--
function Trigger_OnQuestNotTriggered(...)
    return b_Trigger_OnQuestNotTriggered(...);
end

b_Trigger_OnQuestNotTriggered = {
    Name = "Trigger_OnQuestNotTriggered",
    Description = {
        en = "Trigger: if a given quest is not yet active. Should be used in combination with other triggers.",
        de = "Ausloeser: wenn eine angegebene Quest noch inaktiv ist. Sollte mit weiteren Triggern kombiniert werden.",
    },
    Parameter = {
        { ParameterType.QuestName,     en = "Quest name", de = "Questname" },
    },
}

function b_Trigger_OnQuestNotTriggered:GetTriggerTable(__quest_)
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnQuestNotTriggered:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.QuestName = __parameter_
    end
end

function b_Trigger_OnQuestNotTriggered:CustomFunction(__quest_)
    if (GetQuestID(self.QuestName) ~= nil) then
        local QuestID = GetQuestID(self.QuestName)
        if (Quests[QuestID].State == QuestState.NotTriggered) then
            return true;
        end
    end
    return false;
end

function b_Trigger_OnQuestNotTriggered:DEBUG(__quest_)
    if type(self.QuestName) ~= "string" then
        local text = string.format("%s Trigger_OnQuestNotTriggered: invalid quest name!", __quest_.Identifier);
        dbg(text);
        return true;
    end
    return false;
end

AddQuestBehavior(b_Trigger_OnQuestNotTriggered);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald ein anderer unterbrochen wurde.
--
-- @param _QuestName Name des Quest
-- @param _Time      Wartezeit
-- return table: Behavior
-- @within Trigger
--
function Trigger_OnQuestInterrupted(...)
    return b_Trigger_OnQuestInterrupted(...);
end

b_Trigger_OnQuestInterrupted = {
    Name = "Trigger_OnQuestInterrupted",
    Description = {
        en = "Trigger: if a given quest has been interrupted. Should be used in combination with other triggers.",
        de = "Ausloeser: wenn eine angegebene Quest abgebrochen wurde. Sollte mit weiteren Triggern kombiniert werden.",
    },
    Parameter = {
        { ParameterType.QuestName,     en = "Quest name", de = "Questname" },
        { ParameterType.Number,     en = "Waiting time", de = "Wartezeit"},
    },
}

function b_Trigger_OnQuestInterrupted:GetTriggerTable(__quest_)
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnQuestInterrupted:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.QuestName = __parameter_
    elseif (__index_ == 1) then
        self.WaitTime = (__parameter_ ~= nil and tonumber(__parameter_)) or 0
    end
end

function b_Trigger_OnQuestInterrupted:CustomFunction(__quest_)
    if (GetQuestID(self.QuestName) ~= nil) then
        local QuestID = GetQuestID(self.QuestName)
        if (Quests[QuestID].State == QuestState.Over and Quests[QuestID].Result == QuestResult.Interrupted) then
            if self.WaitTime and self.WaitTime > 0 then
                self.WaitTimeTimer = self.WaitTimeTimer or Logic.GetTime();
                if Logic.GetTime() >= self.WaitTimeTimer + self.WaitTime then
                    return true;
                end
            else
                return true;
            end
        end
    end
    return false;
end

function b_Trigger_OnQuestInterrupted:DEBUG(__quest_)
    if type(self.QuestName) ~= "string" then
        local text = string.format("%s Trigger_OnQuestInterrupted: invalid quest name!", __quest_.Identifier);
        dbg(text);
        return true;
    elseif type(self.WaitTime) ~= "number" then
        local text = string.format("%s Trigger_OnQuestInterrupted: waitTime must be a number!", __quest_.Identifier);
        dbg(text);
        return true;
    end
    return false;
end

function b_Trigger_OnQuestInterrupted:Interrupt()
    self.WaitTimeTimer = nil;
end

function b_Trigger_OnQuestInterrupted:Reset()
    self.WaitTimeTimer = nil;
end

AddQuestBehavior(b_Trigger_OnQuestInterrupted);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald ein anderer bendet wurde.
--
-- Dabei ist das Resultat egal. Der Quest kann entweder erfolgreich beendet
-- wurden oder fehlgeschlagen sein.
--
-- @param _QuestName Name des Quest
-- @param _Time      Wartezeit
-- return table: Behavior
-- @within Trigger
--
function Trigger_OnQuestOver(...)
    return b_Trigger_OnQuestOver(...);
end

b_Trigger_OnQuestOver = {
    Name = "Trigger_OnQuestOver",
    Description = {
        en = "Trigger: if a given quest has been finished, regardless of its result. Waiting time optional",
        de = "Ausloeser: wenn eine angegebene Quest beendet wurde, unabhaengig von deren Ergebnis. Wartezeit optional",
    },
    Parameter = {
        { ParameterType.QuestName,     en = "Quest name", de = "Questname" },
        { ParameterType.Number,     en = "Waiting time", de = "Wartezeit"},
    },
}

function b_Trigger_OnQuestOver:GetTriggerTable(__quest_)
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnQuestOver:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.QuestName = __parameter_
    elseif (__index_ == 1) then
        self.WaitTime = (__parameter_ ~= nil and tonumber(__parameter_)) or 0
    end
end

function b_Trigger_OnQuestOver:CustomFunction(__quest_)
    if (GetQuestID(self.QuestName) ~= nil) then
        local QuestID = GetQuestID(self.QuestName)
        if (Quests[QuestID].State == QuestState.Over and Quests[QuestID].Result ~= QuestResult.Interrupted) then
            if self.WaitTime and self.WaitTime > 0 then
                self.WaitTimeTimer = self.WaitTimeTimer or Logic.GetTime();
                if Logic.GetTime() >= self.WaitTimeTimer + self.WaitTime then
                    return true;
                end
            else
                return true;
            end
        end
    end
    return false;
end

function b_Trigger_OnQuestOver:DEBUG(__quest_)
    if type(self.QuestName) ~= "string" then
        local text = string.format("%s Trigger_OnQuestOver: invalid quest name!", __quest_.Identifier);
        dbg(text);
        return true;
    elseif type(self.WaitTime) ~= "number" then
        local text = string.format("%s Trigger_OnQuestOver: waitTime must be a number!", __quest_.Identifier);
        dbg(text);
        return true;
    end
    return false;
end

function b_Trigger_OnQuestOver:Interrupt()
    self.WaitTimeTimer = nil;
end

function b_Trigger_OnQuestOver:Reset()
    self.WaitTimeTimer = nil;
end

AddQuestBehavior(b_Trigger_OnQuestOver);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald ein anderer Quest erfolgreich abgeschlossen wurde.
--
-- @param _QuestName Name des Quest
-- @param _Time      Wartezeit
-- return table: Behavior
-- @within Trigger
--
function Trigger_OnQuestSuccess(...)
    return b_Trigger_OnQuestSuccess(...);
end

b_Trigger_OnQuestSuccess = {
    Name = "Trigger_OnQuestSuccess",
    Description = {
        en = "Trigger: if a given quest has been finished successfully. Waiting time optional",
        de = "Ausloeser: wenn eine angegebene Quest erfolgreich abgeschlossen wurde. Wartezeit optional",
    },
    Parameter = {
        { ParameterType.QuestName,     en = "Quest name", de = "Questname" },
        { ParameterType.Number,     en = "Waiting time", de = "Wartezeit"},
    },
}

function b_Trigger_OnQuestSuccess:GetTriggerTable(__quest_)
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnQuestSuccess:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.QuestName = __parameter_
    elseif (__index_ == 1) then
        self.WaitTime = (__parameter_ ~= nil and tonumber(__parameter_)) or 0
    end
end

function b_Trigger_OnQuestSuccess:CustomFunction()
    if (GetQuestID(self.QuestName) ~= nil) then
        local QuestID = GetQuestID(self.QuestName)
        if (Quests[QuestID].Result == QuestResult.Success) then
            if self.WaitTime and self.WaitTime > 0 then
                self.WaitTimeTimer = self.WaitTimeTimer or Logic.GetTime();
                if Logic.GetTime() >= self.WaitTimeTimer + self.WaitTime then
                    return true;
                end
            else
                return true;
            end
        end
    end
    return false;
end

function b_Trigger_OnQuestSuccess:DEBUG(__quest_)
    if type(self.QuestName) ~= "string" then
        local text = string.format("%s Trigger_OnQuestSuccess: invalid quest name!", __quest_.Identifier);
        dbg(text);
        return true;
    elseif type(self.WaitTime) ~= "number" then
        local text = string.format("%s Trigger_OnQuestSuccess: waittime must be a number!", __quest_.Identifier);
        dbg(text);
        return true;
    end
    return false;
end

function b_Trigger_OnQuestSuccess:Interrupt()
    self.WaitTimeTimer = nil;
end

function b_Trigger_OnQuestSuccess:Reset()
    self.WaitTimeTimer = nil;
end

AddQuestBehavior(b_Trigger_OnQuestSuccess);

-- -------------------------------------------------------------------------- --
-- Application Space                                                          --
-- -------------------------------------------------------------------------- --

BundleClassicBehaviors = {
    Global = {},
    Local = {}
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @local
--
function BundleClassicBehaviors.Global:Install()

end

-- Local Script ----------------------------------------------------------------

---
-- Initialisiert das Bundle im lokalen Skript.
-- @local
--
function BundleClassicBehaviors.Local:Install()

end
