--[[
Swift_2_MilitaryLimit/Behavior

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Fügt Behavior hinzu, die direkt mit dem Militär in Zusammenhang stehen.
--
-- @set sort=true
--

do
    GameCallback_EntityKilled_Orig_QSB_Goal_DestroySoldiers = GameCallback_EntityKilled;
    GameCallback_EntityKilled = function(_AttackedEntityID, _AttackedPlayerID, _AttackingEntityID, _AttackingPlayerID, _AttackedEntityType, _AttackingEntityType)
        if _AttackedPlayerID ~= 0 and _AttackingPlayerID ~= 0 then
            QSB.DestroyedSoldiers[_AttackingPlayerID] = QSB.DestroyedSoldiers[_AttackingPlayerID] or {}
            QSB.DestroyedSoldiers[_AttackingPlayerID][_AttackedPlayerID] = QSB.DestroyedSoldiers[_AttackingPlayerID][_AttackedPlayerID] or 0
            if Logic.IsEntityTypeInCategory( _AttackedEntityType, EntityCategories.Military ) == 1
            and Logic.IsEntityInCategory( _AttackedEntityID, EntityCategories.HeavyWeapon) == 0 then
                QSB.DestroyedSoldiers[_AttackingPlayerID][_AttackedPlayerID] = QSB.DestroyedSoldiers[_AttackingPlayerID][_AttackedPlayerID] +1
            end
        end
        GameCallback_EntityKilled_Orig_QSB_Goal_DestroySoldiers(_AttackedEntityID, _AttackedPlayerID, _AttackingEntityID, _AttackingPlayerID, _AttackedEntityType, _AttackingEntityType)
    end
end

---
-- Ein beliebiger Spieler muss Soldaten eines anderen Spielers zerstören.
--
-- Dieses Behavior kann auch in versteckten Quests bentutzt werden, wenn die
-- Menge an zerstörten Soldaten durch einen Feind des Spielers gefragt ist.
--
-- @param _PlayerA Angreifende Partei
-- @param _PlayerB Zielpartei
-- @param _Amount Menga an Soldaten
--
-- @within Goal
--
function Goal_DestroySoldiers(...)
    return B_Goal_DestroySoldiers:new(...);
end

B_Goal_DestroySoldiers = {
    Name = "Goal_DestroySoldiers",
    Description = {
        en = "Goal: Destroy a given amount of enemy soldiers",
        de = "Ziel: Zerstöre eine Anzahl gegnerischer Soldaten",
        fr = "Objectif: Détruire un certain nombre de soldats ennemis",
    },
    Parameter = {
        {ParameterType.PlayerID, en = "Attacking Player",   de = "Angreifer",   fr = "Attaquant", },
        {ParameterType.PlayerID, en = "Defending Player",   de = "Verteidiger", fr = "Défenseur", },
        {ParameterType.Number,   en = "Amount",             de = "Anzahl",      fr = "Quantité", },
    },

    Text = {
        de = "{center}SOLDATEN ZERSTÖREN {cr}{cr}von der Partei: %s{cr}{cr}Anzahl: %d",
        en = "{center}DESTROY SOLDIERS {cr}{cr}from faction: %s{cr}{cr}Amount: %d",
        fr = "{center}DESTRUIRE DES SOLDATS {cr}{cr}de la faction: %s{cr}{cr}Nombre : %d",
    }
}

function B_Goal_DestroySoldiers:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction} }
end

function B_Goal_DestroySoldiers:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.AttackingPlayer = _Parameter * 1
    elseif (_Index == 1) then
        self.AttackedPlayer = _Parameter * 1
    elseif (_Index == 2) then
        self.KillsNeeded = _Parameter * 1
    end
end

function B_Goal_DestroySoldiers:CustomFunction(_Quest)
    if not _Quest.QuestDescription or _Quest.QuestDescription == "" then
        local PlayerName = GetPlayerName(self.AttackedPlayer) or "";
        Swift:ChangeCustomQuestCaptionText(
            string.format(
                Swift:Localize(ModuleMilitaryLimit.Text),
                PlayerName, self.KillsNeeded
            ),
            _Quest
        );
    end
    if self.KillsNeeded >= ModuleMilitaryLimit.Global:GetEnemySoldierKillsOfPlayer(self.AttackingPlayer, self.AttackedPlayer) then
        return true;
    end
end

function B_Goal_DestroySoldiers:Debug(_Quest)
    if Logic.GetStoreHouse(self.AttackingPlayer) == 0 then
        error(_Quest.Identifier.. ": " ..self.Name .. ": Player " .. self.AttackinPlayer .. " is dead :-(")
        return true
    elseif Logic.GetStoreHouse(self.AttackedPlayer) == 0 then
        error(_Quest.Identifier.. ": " ..self.Name .. ": Player " .. self.AttackedPlayer .. " is dead :-(")
        return true
    elseif self.KillsNeeded < 0 then
        error(_Quest.Identifier.. ": " ..self.Name .. ": Amount negative")
        return true
    end
end

function B_Goal_DestroySoldiers:GetIcon()
    return {7,12}
end

Swift:RegisterBehavior(B_Goal_DestroySoldiers)

