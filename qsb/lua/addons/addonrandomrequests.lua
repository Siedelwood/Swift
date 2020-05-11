-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnRandomRequests                                          # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle stellt zufällige Aufgaben durch NPC-Spieler bereit.
--
-- Es gibt verschiedene Typen von zufälligen Aufträgen. Es wird versucht, immer
-- einen einzigartigen Auftrag für den jeweiligen Auftraggeber zu erzeugen.
-- Wenn kein Auftrag erzeugt werden kann, wird der Spieler aufgefordert 2000
-- Gold zu bezahlen.
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnRandomRequests = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --


-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnRandomRequests = {
    Global = {
        Data = {
            SpecialSuggestion = nil,
            RandomQuestNameCounter = 0;
            PredatorQuests = {},
            Claim = {},
            Deliver = {},
            Reputation = {},
            KnightTitle = {},
            Object = {},
            Refill = {},
            Find = {},
            CureSettlers = {},

            Text = {
                Suggestion = {
                    {de = "Ihr müsst Euer Können unter Beweis stellen!",
                     en = "Please show us what you are capable of!",
                     fr = "Vous devez prouver vos compétences!"},
                    {de = "Bei diesem Problem benötigen wir Eure Unterstützung!",
                     en = "This problem is driving us nuts! Please help us!",
                     fr = "Nous avons besoin de votre soutien pour résoudre ce problème!"},
                    {de = "Euer Volk braucht Eure Hilfe! Werdet Ihr uns helfen?",
                     en = "Your pepole demand your attantion. Will you help them?",
                     fr = "Votre peuple a besoin de votre aide! Voulez-vous nous aider?"},

                    -- Spezielle Texte
                    Fire = {
                        de = "Dieses Feuer muss entzündet werden. Bitte helft"..
                             " dabei und sendet uns die benötigten Waren.",
                        en = "This fire needs to be ignited. Please send us"..
                             " the required goods to do so.",
                    },
                    HolyCow = {
                        de = "Zollt der heiligen Kuh ihren Tribut!",
                        en = "Pay your tribute to the holy cow!",
                    },
                    Prison = {
                        de = "Einer Eurer Siedler hat bei uns Ärger gemacht."..
                             " Ihr könnt dieses Subjekt zurück haben, doch"..
                             " Ihr müsst die Strafe zahlen.",
                        en = "One of your settlers has behaved wrongly. You"..
                             " can have this rude subject back if you want"..
                             " but you must pay the bounty.",
                    },
                    Misc = {
                        de = "Bitte untersucht diesen Ort für uns.",
                        en = "Please investigate this location.",
                    },
                    Missing = {
                        de = "Einer unserer Arbeiter ist verschwunden. Er hat"..
                             " sich bestimmt irgend wo versteckt, weil er zu"..
                             " faul zum arbeiten ist. Findet ihn!",
                        en = "One of our own settler is missing. I am sure"..
                             " they are just to lazy to work. Find them!",
                    },
                    Tiger = {
                        de = "Auf unserem Gebiet befindet sich eine Höhle."..
                              " Bisher hat sich noch keiner getraut sie zu"..
                              " untersuchen. Tut dies für uns und ihr dürft"..
                              " alles behalten, was ihr findet.",
                        en = "There is a dark cave on our land. Nobody was"..
                             " brave enough to take a look. If you this for"..
                             " us you can keep your loot as your reward.",
                    },
                    Tribute = {
                        de = "Zahlt uns einen Tribut und wir werden Euch"..
                             " vielleicht akzeptieren!",
                        en = "If you want us as your friends,, you have"..
                             " to pay us a tribute!",
                    },
                    Well = {
                        de = "Einer unserer Brungen ist versiegt. Wenn Ihr"..
                             " ihn reparieren könntet, wären wir Euch sehr"..
                             " verbunden.",
                        en = "One of our wells has run dry. If you could"..
                             " repair it for us, we would be grateful.",
                    },
                },
                Success = {
                    {de = "Wir möchten Euch von Herzen für Eure Hilfe danken!",
                     en = "Let us thank you from the bottem of out hearts!",
                     fr = "Nous tenons à vous remercier du fond du cœur pour votre aide!"},
                    {de = "Ihr habt bewiesen, dass man Euch vertrauen kann!",
                     en = "You have proven the trust we have in your, Milord!",
                     fr = "Vous nous avez prouvé qu'on pouvait vous faire confiance!"},
                    {de = "Gott segne Euch! Wir sind gerettet!",
                     en = "God be praised! You saved us all!",
                     fr = "Que Dieu vous bénisse! Nous sommes sauvés!"},
                },
                Failure = {
                    {de = "Wir haben Euch vertraut! Mich deucht Euer Wort ist nichts wert!",
                     en = "We trusted you! So that is what your words are worth! Nothing!",
                     fr = "Nous vous avons fait confiance! Votre mot ne vaut rien!"},
                    {de = "Anführer! Es sind viele an der Zahl doch taugen alle wenig!",
                     en = "Leaders! They are many but they can't even tie their shoes!",
                     fr = "Généraux! Il y en a beaucoup, mais ils sont tous inutiles!"},
                    {de = "Ein Herrscher wollt Ihr sein? Lernt das Volk zu schätzen!",
                     en = "You call yourself a ruler? Go and remember the needs of the pepole!",
                     fr = "Vous voulez être un dirigeant? Apprenez à apprécier les gens!"},
                },
            }
        },
    },
    Local = {},
}

-- Global ----------------------------------------------------------------------

---
-- Initalisiert das AddOn.
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:Install()
end

---
-- Erzeugt einen zufälligen Slave Quest anhand der Einstellungen im Quest.
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:CreateSlaveQuest(_Behavior, _Quest)
    if not _Behavior.SlaveQuest then
        local QuestGoals = self:GetPossibleBehaviors(_Behavior, _Quest);
        -- Fallback
        if #QuestGoals == 0 then
            self.Data.SpecialSuggestion = self.Data.Text.Suggestion.Tribute;
            QuestGoals[#QuestGoals+1] = {"Goal_Deliver", "G_Gold", 2000};
        end
        local SelectedGoal = QuestGoals[math.random(1, #QuestGoals)];
        local FunctionName = table.remove(SelectedGoal, 1);

        self.Data.RandomQuestNameCounter = self.Data.RandomQuestNameCounter +1;
        local QuestName = API.CreateQuest {
            Name        = "RandomRequest_Player" .._Quest.SendingPlayer.. "_" ..self.Data.RandomQuestNameCounter;
            Suggestion  = _Behavior.OptionalSuggestion or self.Data.SpecialSuggestion or self.Data.Text.Suggestion[math.random(1, 3)],
            Success     = _Behavior.OptionalSuccess or self.Data.Text.Success[math.random(1, 3)],
            Failure     = _Behavior.OptionalFailure or self.Data.Text.Failure[math.random(1, 3)],
            Receiver    = _Quest.ReceivingPlayer,
            Sender      = _Quest.SendingPlayer,
            Time        = _Behavior.TimeLimit,

            _G[FunctionName](unpack(SelectedGoal)),
            Trigger_Time(0),
        };
        _Behavior.SlaveQuest = Quests[GetQuestID(QuestName)];
        self.Data.SpecialSuggestion = nil;
    end
end

---
-- Gibt eine Liste mit Behavior zurück, die für den Random Quest verfügbar
-- sind. Es wird eines der Behavior ausgewählt.
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @return[type=table] Behavior List
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetPossibleBehaviors(_Behavior, _Quest)
    local QuestGoals = {};

    if _Behavior.TypeRefill then
        QuestGoals[#QuestGoals+1] = self:GetRefillBehavior(_Behavior, _Quest);
    end
    if _Behavior.TypeObject then
        QuestGoals[#QuestGoals+1] = self:GetObjectBehavior(_Behavior, _Quest);
    end
    if _Behavior.TypeCureSettlers then
        QuestGoals[#QuestGoals+1] = self:GetCureSettlersBehavior(_Behavior, _Quest);
    end
    if _Behavior.TypeFind then
        QuestGoals[#QuestGoals+1] = self:GetFindBehavior(_Behavior, _Quest);
    end
    if _Behavior.TypeHuntPredators then
        QuestGoals[#QuestGoals+1] = self:GetHuntPredatorBehavior(_Behavior, _Quest);
    end
    if _Behavior.TypeDeliverGoods then
        QuestGoals[#QuestGoals+1] = self:GetDeliverGoodsBehavior(_Behavior, _Quest);
    end
    if _Behavior.TypeDeliverGold then
        self.Data.SpecialSuggestion = self.Data.Text.Suggestion.Tribute;
        local Amount = math.random(150, 225) * (Logic.GetKnightTitle(_Quest.ReceivingPlayer) +1);
        QuestGoals[#QuestGoals+1] = {"Goal_Deliver", "G_Gold", Amount};
    end
    if _Behavior.TypeClaim then
        QuestGoals[#QuestGoals+1] = self:GetClaimTerritoryBehavior(_Behavior, _Quest);
    end
    if _Behavior.TypeKnightTitle then
        QuestGoals[#QuestGoals+1] = self:GetKnightTitleBehavior(_Behavior, _Quest);
    end
    if _Behavior.TypeReputation then
        self.Data.KnightTitle[_Quest.ReceivingPlayer] = self.Data.KnightTitle[_Quest.ReceivingPlayer] or {};
        local Reputation = 25 + (10 * Logic.GetKnightTitle(_Quest.ReceivingPlayer));
        if not self.Data.KnightTitle[_Quest.ReceivingPlayer][Reputation] then
            self.Data.KnightTitle[_Quest.ReceivingPlayer][Reputation] = true;
            QuestGoals[#QuestGoals+1] = {"Goal_CityReputation", Reputation};
        end
    end
    if _Behavior.TypeBuildWall then
        QuestGoals[#QuestGoals+1] = self:GetBuildWallBehavior(_Behavior, _Quest);
    end
    return QuestGoals;
end

-- Behaviors ---------------------------------------------------------------- --

---
-- Erstellt ein Goal_ActivateObject für ein Objekt auf dem Gebiet des
-- Auftraggeber. Der Spieler muss dieses Objekt dann aktivieren.
--
-- Auswählbare Objekte müssen den Namen IORR tragen und fortlauend nummeriert
-- sein. Außerdem müssen es Entities vom Typ I_X_* sein.
--
-- <b>Hinweis</b>: Jedes Objekt wird nur einmal ausgewählt. Tigerhöhlen 
-- erzeugen Raubtierspawnpunkte!
--
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @return[type=table] Behavior
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetObjectBehavior(_Behavior, _Quest)
    local KnightTitle = Logic.GetKnightTitle(_Quest.ReceivingPlayer);

    -- Objekte finden
    local Objects = {};
    local Index = 1;
    while (true) do
        local Name = "IORR" ..Index;
        if not IsExisting(Name) then
            break;
        end
        if string.find(Logic.GetEntityTypeName(Logic.GetEntityType(GetID(Name))), "I_X_") 
        and Logic.GetTerritoryPlayerID(GetTerritoryUnderEntity(GetID(Name))) == _Quest.SendingPlayer
        and not self.Data.Object[Name] then
            table.insert(Objects, Name);
        end
        Index = Index +1;
    end

    -- Behavior erzeugen
    if #Objects > 0 then
        local Name = Objects[math.random(1, #Objects)];
        self.Data.Object[Name] = true;
        local Type = Logic.GetEntityType(GetID(Name));
        local TypeName = Logic.GetEntityTypeName(Type);
        local PlayerID = _Quest.SendingPlayer;
        local Costs;
        local Reward;
        local Action;

        self.Data.SpecialSuggestion = self.Data.Text.Suggestion.Misc;
        -- Signalfeuer entzünden
        if TypeName == "I_X_BigFire_Base" then
            self.Data.SpecialSuggestion = self.Data.Text.Suggestion.Fire;
            Costs = {Goods.G_Wood, 20 + (3*KnightTitle)};
            Action = function(_Data)
                local Position = GetPosition(_Data.Name);
                Logic.CreateEntity(Entities.D_X_BigFire_Fire, Position.X, Position.Y, Orientation, 0);
                Logic.SetVisible(GetID(_Data.Name), false);
            end
        elseif TypeName == "I_X_SignalFire_Base" then
            self.Data.SpecialSuggestion = self.Data.Text.Suggestion.Fire;
            Costs = {Goods.G_Wood, 30 + (3*KnightTitle)};
            Action = function(_Data)
                local Position = GetPosition(_Data.Name);
                Logic.CreateEntity(Entities.D_X_SignalFire_Fire, Position.X, Position.Y, Orientation, 0);
                Logic.SetVisible(GetID(_Data.Name), false);
            end
        elseif TypeName == "I_X_Holy_Cow" then
            self.Data.SpecialSuggestion = self.Data.Text.Suggestion.HolyCow;
            Costs = {Goods.G_Grain, 30 + (5*KnightTitle)};
        -- Gefangenen freikaufen
        elseif TypeName:find("Prison") then
            self.Data.SpecialSuggestion = self.Data.Text.Suggestion.Prison;
            PlayerID = _Quest.ReceivingPlayer;
            Costs = {Goods.G_Gold, 250 + (50*KnightTitle)};
            Action = function(_Data)
                local Pos  = API.GetRelativePosition(_Data.Name, 200, -90);
                local Type = API.GetRandomSettlerType();
                local ID   = Logic.CreateEntityOnUnblockedLand(Type, Pos.X, Pos.Y, 0, _Data.Owner);
                Logic.SetTaskList(ID, TaskLists.TL_WAIT_THEN_WALK);
            end
        -- Faulen Harzer finden
        elseif TypeName == "I_X_NPC_Decay_Hut" then
            self.Data.SpecialSuggestion = self.Data.Text.Suggestion.Missing;
            Action = function(_Data)
                local Pos  = API.GetRelativePosition(_Data.Name, 200, -90);
                local Type = API.GetRandomSettlerType();
                local ID   = Logic.CreateEntityOnUnblockedLand(Type, Pos.X, Pos.Y, 0, _Data.Owner);
                Logic.SetTaskList(ID, TaskLists.TL_WAIT_THEN_WALK);
            end
        -- Khana-Tempel entzünden
        elseif TypeName == "I_X_KhanaTemple" then
            self.Data.SpecialSuggestion = self.Data.Text.Suggestion.Fire;
            Costs = {Goods.G_Honeycomb, 30 + (3*KnightTitle)};
            Action = function(_Data)
                local Orientation = Logic.GetOrientation(GetID(_Data.Name));
                local Position    = GetPosition(_Data.Name);
                Logic.CreateEntity(Entities.B_KhanaTemple, Position.X, Position.Y, Orientation, _Data.PlayerID);
                Logic.SetVisible(GetID(_Data.Name), false);
            end
        -- Ein Brunnen wird repariert
        elseif TypeName == "I_X_Well_Destroyed" then
            self.Data.SpecialSuggestion = self.Data.Text.Suggestion.Well;
            Costs = {Goods.G_Stone, 20 + (3*KnightTitle)};
            Action = function(_Data)
                local Position = GetPosition(_Data.Name);
                Logic.CreateEntity(Entities.D_NA_Well_Repaired, Position.X, Position.Y, Orientation, 0);
                Logic.SetVisible(GetID(_Data.Name), false);
            end
        -- Tigerhöle plündern, aber... ;)
        elseif TypeName == "I_X_TigerCave" then
            self.Data.SpecialSuggestion = self.Data.Text.Suggestion.Tiger;
            Reward = {Goods.G_Gems, 20 + (5*KnightTitle)};
            Action = function(_Data)
                local Pos  = API.GetRelativePosition(_Data.Name, 300, -90);
                local ID   = Logic.CreateEntityOnUnblockedLand(Entities.S_TigerPack_AS, Pos.X, Pos.Y, 0, 0);
            end
        -- Alle anderen Typen enthalten einfach Gold
        else
            Reward = {Goods.G_Gold, 150 + (35*KnightTitle)};
        end

        -- Objekt erzeugen
        API.CreateObject{
            Name        = Name,
            Distance    = 1500,
            Waittime    = 5,
            Reward      = Reward,
            Costs       = Costs,
            PlayerID    = PlayerID,
            Callback    = Action,
        };
        -- Behavior erzeugen
        return {"Goal_ActivateObject", Name};
    end
end

---
-- Erstellt ein Goal_SatisfyNeed für den Auftraggeber und macht alle seine
-- Siedler krank. Der Spieler muss sich dann was einfallen lassen...
--
-- <b>Hinweis</b>: Dieses Behavior kann nur auftauchen, wenn die Zielpartei
-- keine Apotheke hat und man schon Handelsrechte hat. Außerdem auch nicht,
-- wenn die Partei Medizin verkauft.
--
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @return[type=table] Behavior
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetCureSettlersBehavior(_Behavior, _Quest)
    local KnightTitle = Logic.GetKnightTitle(_Quest.ReceivingPlayer);
    self.Data.CureSettlers[_Quest.SendingPlayer] = self.Data.CureSettlers[_Quest.SendingPlayer] or {};
    if not self.Data.CureSettlers[_Quest.SendingPlayer][KnightTitle] then
        local Pharmacies = GetPlayerEntities(_Quest.SendingPlayer, Entities.B_Pharmacy);
        self.Data.Deliver[_Quest.ReceivingPlayer] = self.Data.Deliver[_Quest.ReceivingPlayer] or {};
        self.Data.Deliver[_Quest.ReceivingPlayer][_Quest.SendingPlayer] = self.Data.Deliver[_Quest.ReceivingPlayer][_Quest.SendingPlayer] or {};
        if self:CanGoodBeSetAsGoal(_Quest.SendingPlayer, _Quest.ReceivingPlayer, Goods.G_Medicine)
        or #Pharmacies == 0 or GetDiplomacyState(_Quest.SendingPlayer, _Quest.ReceivingPlayer) > 0 then
            local CityBuildings  = {Logic.GetPlayerEntitiesInCategory(_Quest.SendingPlayer, EntityCategories.CityBuilding)};
            local OuterBuildings = {Logic.GetPlayerEntitiesInCategory(_Quest.SendingPlayer, EntityCategories.OuterRimBuilding)};
            local AllBuildings = Array_Append(CityBuildings, OuterBuildings);
            if #AllBuildings > 0 then
                self.Data.CureSettlers[_Quest.SendingPlayer][KnightTitle] = true;
                for k, v in pairs(AllBuildings) do
                    Logic.MakeBuildingIll(v);
                end
                return {"Goal_SatisfyNeed", _Quest.SendingPlayer, "Medicine"};
            end
        end
    end
end

---
-- Erstellt ein Goal_CollectValuables das den Spieler 5 Gegenstände einer
-- anderen Partei finden lässt. Diese Gegenstände haben ein zufälliges
-- Model (Hammer, Sense, Messer, Sack, Kiste).
--
-- <b>Hinweis</b>: Das Behavior kann für jede Partei nur einmal pro erreichtem
-- Titel des Spielers auftreten. Es wird nicht auftreten, wenn die fordernde
-- Partei nicht mindestens 5 Gebäude hat.
--
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @return[type=table] Behavior
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetFindBehavior(_Behavior, _Quest)
    local KnightTitle = Logic.GetKnightTitle(_Quest.ReceivingPlayer);
    self.Data.Find[_Quest.SendingPlayer] = self.Data.Find[_Quest.SendingPlayer] or {};
    if not self.Data.Find[_Quest.SendingPlayer][KnightTitle] then
        local FindAmount = 5;
        local EntitiesToFind = self:GetRandomBuildingsForFindQuest(_Quest.SendingPlayer, FindAmount);
        if #EntitiesToFind >= FindAmount then
            self.Data.Find[_Quest.SendingPlayer][KnightTitle] = true;
            local Positions = {};
            for i= 1, FindAmount, 1 do
                table.insert(Positions, self:GetPositionNearBuilding(EntitiesToFind[i]));
            end
            return {"Goal_CollectValuables", Positions, "-", 0};
        end
    end
end

---
-- Erstellt ein Goal_Refill das den Spieler eine Mine auffüllen lässt. Es wird
-- eine Mine ausgewählt und per Skript geleert.
--
-- <b>Hinweis</b>: Dieses Behavior kann nur dann auftauchen, wenn der
-- Zielspieler noch nicht benutzte Minen auf seinem Territorium hat.
--
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @return[type=table] Behavior
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetRefillBehavior(_Behavior, _Quest)
    self.Data.Refill[_Quest.SendingPlayer] = self.Data.Refill[_Quest.SendingPlayer] or {};
    local AllMines = Array_Append(
        self:GetWorldEntitiesOnPlayersTerritories(Entities.R_IronMine, _Quest.SendingPlayer),
        self:GetWorldEntitiesOnPlayersTerritories(Entities.R_StoneMine, _Quest.SendingPlayer)
    );
    for i= 1, #AllMines, 1 do
        if not self.Data.Refill[_Quest.SendingPlayer][AllMines[i]] then
            self.Data.Refill[_Quest.SendingPlayer][AllMines[i]] = true;
            API.SetResourceAmount(AllMines[i], 0, 250);
            return {"Goal_Refill", AllMines[i]};
        end
    end
end

---
-- Erstellt ein Goal_DestroySpawnedEntities das den Spieler fordert Raubtiere
-- am nächst gelegenen Spawnpoint zu erledigen.
--
-- <b>Hinweis</b>: Dieses Behavior kann nur dann auftauchen, wenn es noch nicht
-- verwendete Spawnpoints gibt.
--
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @return[type=table] Behavior
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetHuntPredatorBehavior(_Behavior, _Quest)
    local SpawnPoint = self:GetClosestPredatorSpawnByQuest(_Behavior, _Quest);
    if SpawnPoint == nil or self.Data.PredatorQuests[SpawnPoint] ~= nil then
        return;
    end
    local MaxCapacity = Logic.RespawnResourceGetMaxCapacity(SpawnPoint);
    self.Data.PredatorQuests[SpawnPoint] = true;
    return {"Goal_DestroySpawnedEntities", SpawnPoint, MaxCapacity, false};
end

---
-- Erstellt Goal_KnightTitle für den Random Quest.
--
-- <b>Hinweis</b>: Dieses Behavior kann nur dann auftauchen, wenn der Spieler
-- noch einen höheren Titel erreichen kann. Außerdem wird jeder Titel nur
-- genau einmal gefordert.
--
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @return[type=table] Behavior
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetKnightTitleBehavior(_Behavior, _Quest)
    if Logic.GetKnightTitle(_Quest.ReceivingPlayer) < KnightTitles.Archduke then
        local PossibleTitles = {"Mayor", "Baron", "Earl", "Marquees", "Duke", "Archduke"};
        local NextTitle = PossibleTitles[Logic.GetKnightTitle(_Quest.ReceivingPlayer)+1];
        self.Data.KnightTitle[_Quest.ReceivingPlayer] = self.Data.KnightTitle[_Quest.ReceivingPlayer] or {};
        if not NextTitle or IsKnightTitleLockedForPlayer(_Quest.ReceivingPlayer, NextTitle) 
        or self.Data.KnightTitle[_Quest.ReceivingPlayer][NextTitle] then
            return;
        end
        self.Data.KnightTitle[_Quest.ReceivingPlayer][NextTitle] = true;
        return {"Goal_KnightTitle", NextTitle};
    end 
end

---
-- Erstellt Goal_BuildWall für den Random Quest.
--
-- <b>Hinweis</b>: Dieses Behavior kann nur dann auftauchen, wenn der Spieler
-- mindestens einen Feind hat.
--
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @return[type=table] Behavior
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetBuildWallBehavior(_Behavior, _Quest)
    local FirstEnemy;
    for i= 1, 8, 1 do
        if i ~= _Quest.SendingPlayer and i ~= _Quest.ReceivingPlayer and DiplomaticEntity.GetRelationBetween(i, _Quest.ReceivingPlayer) == DiplomacyStates.Enemy then
            FirstEnemy = i;
            break;
        end
    end
    if FirstEnemy then
        local SPStorehouse = Logic.GetStoreHouse(_Quest.SendingPlayer);
        local RPStorehouse = Logic.GetStoreHouse(_Quest.ReceivingPlayer);
        return {"Goal_BuildWall", FirstEnemy, RPStorehouse, SPStorehouse};
    end
end

---
-- Erstellt Goal_Claim für den Random Quest. Nur Territorien ohne Besitzer
-- (Spieler 0) werden berücksichtigt.
--
-- <b>Hinweis</b>: Dieses Behavior kann nur auftauchen, wenn es mindestens 1
-- neutrales Territorium gibt.
--
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @return[type=table] Behavior
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetClaimTerritoryBehavior(_Behavior, _Quest)
    local AllTerritories = self:GetTerritoriesOfPlayer(0);
    for i= #AllTerritories, 1, -1 do
        if self.Data.Claim[AllTerritories[i]] then
            table.remove(AllTerritories, i);
        end
    end
    if #AllTerritories > 0 then
        local Territory = AllTerritories[math.random(1, #AllTerritories)];
        self.Data.Claim[Territory] = true;
        return {"Goal_Claim", AllTerritories[math.random(1, #AllTerritories)]};
    end
end

---
-- Erstellt Goal_Deliver (Rohstoffe) für den Random Quest.
--
-- <b>Hinweis</b>: Es können nur Waren auftauchen, die nicht auf der Blacklist
-- der Zielpartei stehen. Vorsicht bei verbotenen Technologien!
--
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @return[type=table] Behavior
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetDeliverGoodsBehavior(_Behavior, _Quest)
    local GoodTypes = {
        "G_Wood", "G_Iron", "G_Stone", "G_Carcass", "G_Herb", "G_Wool",
        "G_Honeycomb", "G_Grain", "G_Milk", "G_RawFish"
    };

    local Receiver = _Quest.ReceivingPlayer;
    local Sender   = _Quest.SendingPlayer;
    self.Data.Deliver[Receiver] = self.Data.Deliver[Receiver] or {};
    self.Data.Deliver[Receiver][Sender] = self.Data.Deliver[Receiver][Sender] or {};

    local SelectedGood;
    repeat
        SelectedGood = GoodTypes[math.random(1, #GoodTypes)];
    until (self:CanGoodBeSetAsGoal(Sender, Receiver, Goods[SelectedGood]));
    local Amount = math.random(15, 25) * (Logic.GetKnightTitle(Receiver) +1);
    self.Data.Deliver[Receiver][Sender][Goods[SelectedGood]] = true;
    return {"Goal_Deliver", SelectedGood, Amount};
end 

-- Helper ------------------------------------------------------------------- --


---
-- Bestimmt eine zufällige Position am Gebäude.
-- @param[type=number] _BuildingID ID des Gebäudes
-- @return[type=table] Position beim Gebäude
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetPositionNearBuilding(_BuildingID)
    local Position = {X= 0, Y= 0, Z= 0};
    if IsExisting(_BuildingID) then
        local RelPos = GetPosition(_BuildingID);
        RelPos.X = RelPos.X + math.random(-200, 200);
        RelPos.Y = RelPos.Y + math.random(-200, 200);

        local ID = Logic.CreateEntityOnUnblockedLand(Entities.XD_ScriptEntity, RelPos.X, RelPos.Y, 0, 0);
        local x, y, z = Logic.EntityGetPos(ID);
        DestroyEntity(ID);

        Position.X = x;
        Position.Y = y;
        Position.Z = z;
    end
    return Position;
end

---
-- Bestimmt eine zufällige Position am Gebäude.
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Amount   Menge an Gebäuden
-- @return[type=table] Position beim Gebäude
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetRandomBuildingsForFindQuest(_PlayerID, _Amount)
    local Buildings = {};
    local AllBuildings = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.AttackableBuilding)};
    if #AllBuildings >= _Amount then
        while #Buildings < _Amount do
            local ID = table.remove(AllBuildings, math.random(1, #AllBuildings));
            if not API.TraverseTable(ID, Buildings) then
                table.insert(Buildings, ID);
            end
        end
    end
    return Buildings;
end

---
-- Ermittelt den nächsten Spawnpoint für Raubtiere zum Auftraggeber.
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @return[type=number] ID des Spawnpoint
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetClosestPredatorSpawnByQuest(_Behavior, _Quest)
    local FoundSpawnPoints = {};
    local PredatorSpawnPointTypes = {
        "S_Bear", "S_Bear_Black", "S_BearBlack", "S_LionPack_NA", 
        "S_PolarBear_NE", "S_TigerPack_AS", "S_WolfPack",
    };
    -- Select all
    for i= 1, #PredatorSpawnPointTypes, 1 do
        if Entities[PredatorSpawnPointTypes[i]] then
            local Result = {Logic.GetEntities(Entities[PredatorSpawnPointTypes[i]], 48)};
            if table.remove(Result, 1) > 0 then
                FoundSpawnPoints = Array_Append(FoundSpawnPoints, Result);
            end
        end
    end
    -- Remove already used
    for i= #FoundSpawnPoints, 1, -1 do
        if self.Data.PredatorQuests[FoundSpawnPoints[i]] then
            table.remove(FoundSpawnPoints, i);
        end
    end
    -- Find nearest
    if #FoundSpawnPoints > 0 then
        return API.GetEntitiesNearby(Logic.GetStoreHouse(_Quest.SendingPlayer), FoundSpawnPoints);
    end
end

---
-- Gibt alle Territorien des Spielers zurück. Spieler 0 ist ebenfalls möglich.
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=table] Liste der Territorien
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetTerritoriesOfPlayer(_PlayerID)
    local FoundTerritories = {};
    local AllTerritories = {Logic.GetTerritories()};
    for i= 1, #AllTerritories, 1 do
        if AllTerritories[i] ~= 0 and Logic.GetTerritoryPlayerID(AllTerritories[i]) == _PlayerID then
            table.insert(FoundTerritories, AllTerritories[i]);
        end
    end
    return FoundTerritories;
end

---
-- Prüft, ob eine Ware für ein Goal_Deliver verwendet werden kann.
-- @param[type=number] _SenderID   Sendender Spieler
-- @param[type=number] _ReceiverID Empfangender Spieler
-- @param[type=number] _Good       Warentyp
-- @return[type=boolean] Ware kann benutzt werden.
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:CanGoodBeSetAsGoal(_SenderID, _ReceiverID, _Good)
    if self.Data.Deliver[_ReceiverID][_SenderID][_Good] then
        return false;
    end
    if API.CanPlayerProduceGood(_ReceiverID, _Good) then
        return false;
    end
    if MerchantSystem.TradeBlackList[_SenderID] then
        for k, v in pairs(MerchantSystem.TradeBlackList[_SenderID]) do
            if v == _Good then
                return false;
            end
        end
    end
    return true;
end

---
-- Gibt alle Entities des Typs in allen Territorien eines Spielers zurück.
-- Spieler 0 ist ebenfalls möglich.
-- @param[type=number] _Type     Entity Type
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=table] Liste der Entities
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetWorldEntitiesOnPlayersTerritories(_Type, _PlayerID)
    local Result = {};
    local AllEntitiesOfType = {Logic.GetEntities(_Type, 48)};
    local AllTerritories = self:GetTerritoriesOfPlayer(_PlayerID);
    for i= 1, #AllEntitiesOfType, 1 do
        for j= 1, #AllTerritories, 1 do
            if  GetTerritoryUnderEntity(AllEntitiesOfType[i]) == AllTerritories[j] then
                table.insert(Result, AllEntitiesOfType[i]);
            end
        end
    end
    return Result;
end

-- -------------------------------------------------------------------------- --

---
-- Wählt einen zufälligen Auftrag für den Spieler aus. Über die Parameter kann
-- bestimmt werden, welche Typen von Aufträgen erscheinen können. Dieses
-- Behavior sollte in versteckten Quests benutzt werden.
--
-- Tribute und Warenanforderungen steigen in der Menge mit höherem Titel
-- des Auftragnehmers.
--
-- <b>Wichtig</b>:
-- <ul>
-- <li>Die Option <i>_Goods</i> kann Rohstoffe wählen, die der Spieler wegen
-- einer gesperrten Technologie nicht erlangen kann! In diesem Fall muss die
-- Ware Auf die Blacklist des Auftraggebers gesetzt werden!</li>
-- <li>Die Option _Object benötigt interaktive Objekte, die "IORR" heißen und
-- von 1 bis n fortlaufend nummeriert sind.</li>
-- <li>Die Option _Object erzeugt u.U. Raubtierspawnpoints (Tigerhöhle)!</li>
-- </ul>
--
-- <b>Hinweis</b>: Das Behavior erzeugt einen weiteren Quest mit dem zufällig
-- gewählten Ziel. Somit ist es mit den Tribut-Quests vergleichbar. Wird
-- Random Requests neu gestartet wird ein neuer Zufalls-Quest erstellt.
--
-- <b>Hinweis</b>: Es kann vorkommen, das bestimmte Auftragsarten unter gewissen
-- Voraussetzungen fälschlich sofort als erfolgreich abgeschlossen gelten. (z.B.
-- Monsun während Build Wall)
--
-- @param[type=boolean] _Goods      Ziel: Waren liefern
-- @param[type=boolean] _Gold       Ziel: Tribut bezahlen
-- @param[type=boolean] _Claim      Ziel: Territorium erobern
-- @param[type=boolean] _Title      Ziel: Nächst höherer Titel
-- @param[type=boolean] _Reputation Ziel: Ruf der Stadt
-- @param[type=boolean] _Walls      Ziel: Stadt mit einer Mauer schützen
-- @param[type=boolean] _Predator   Ziel: Raubtiere vernichten
-- @param[type=boolean] _Mine       Ziel: Verschüttete Mine auffüllen
-- @param[type=boolean] _Find       Ziel: Gegenstände suchen
-- @param[type=boolean] _Cure       Ziel: Kranke Siedler heilen
-- @param[type=boolean] _Object     Ziel: Zufällig gewähltes Objekt aktivieren
-- @param[type=number]  _Time       Zeit bis zur Niederlage (0 = aus)
-- @param[type=string]  _Suggestion (optional) Startnachricht
-- @param[type=string]  _Success    (optional) Erfolgsnachricht
-- @param[type=string]  _Failure    (optional) Fehlschlagnachricht
--
-- @within Goal
--
function Goal_RandomRequest(...)
    return b_Goal_RandomRequest:new(...);
end

b_Goal_RandomRequest = {
    Name = "Goal_RandomRequest",
    Description = {
        en = "Goal: Der Spieler erhält einen zufällig generierten Auftrag, der erfüllt werden muss. Über die Parameter wird bestimmt, welche Typen von Aufträgen möglich sind. Tipp: Für versteckten Quest nutzen!",
        de = "Ziel: The player receives an randomly generated quest that he needs to complete. Define which types of quest possibly appear by setting the parameters. Tip: Use this quest as invisible quest!",
    },
    Parameter = {
        { ParameterType.Custom,  en = "Deliver goods",           de = "Waren liefern" },
        { ParameterType.Custom,  en = "Pay tribute",             de = "Tribut entrichten" },
        { ParameterType.Custom,  en = "Claim territory",         de = "Territorium beanspruchen" },
        { ParameterType.Custom,  en = "Knight title",            de = "Titel erreichen" },
        { ParameterType.Custom,  en = "City reputation",         de = "Ruf der Stadt" },
        { ParameterType.Custom,  en = "Build rampart",           de = "Festung bauen" },
        { ParameterType.Custom,  en = "Hunt predators",          de = "Raubtiere vertreiben" },
        { ParameterType.Custom,  en = "Refill mines",            de = "Minen auffüllen" },
        { ParameterType.Custom,  en = "Find lost objects",       de = "Verlorene Gegenstände finden" },
        { ParameterType.Custom,  en = "Cure sick settlers",      de = "Kranke Siedler heilen" },
        { ParameterType.Custom,  en = "Activate object",         de = "Interaktives Object benutzen" },
        { ParameterType.Number,  en = "Time limit (0 = off)",    de = "Leitlimit (0 = aus)" },
        { ParameterType.Default, en = "(optional) Mission text", de = "(optional) Auftragsnachricht" },
        { ParameterType.Default, en = "(optional) Success text", de = "(optional) Erfolgsnachricht" },
        { ParameterType.Default, en = "(optional) Failure text", de = "(optional) Fehlschlagsnachricht" },
    },
}

function b_Goal_RandomRequest:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_RandomRequest:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.TypeDeliverGoods = API.ToBoolean(_Parameter);
    elseif (_Index == 1) then
        self.TypeDeliverGold = API.ToBoolean(_Parameter);
    elseif (_Index == 2) then
        self.TypeClaim = API.ToBoolean(_Parameter);
    elseif (_Index == 3) then
        self.TypeKnightTitle = API.ToBoolean(_Parameter);
    elseif (_Index == 4) then
        self.TypeReputation = API.ToBoolean(_Parameter);
    elseif (_Index == 5) then
        self.TypeBuildWall = API.ToBoolean(_Parameter);
    elseif (_Index == 6) then
        self.TypeHuntPredators = API.ToBoolean(_Parameter);
    elseif (_Index == 7) then
        self.TypeRefill = API.ToBoolean(_Parameter);
    elseif (_Index == 8) then
        self.TypeFind = API.ToBoolean(_Parameter);
    elseif (_Index == 9) then
        self.TypeCureSettlers = API.ToBoolean(_Parameter);
    elseif (_Index == 10) then
        self.TypeObject = API.ToBoolean(_Parameter);
    elseif (_Index == 11) then
        self.TimeLimit = _Parameter * 1;
    elseif (_Index == 12) then
        if _Parameter and _Parameter ~= "" then
            self.OptionalSuggestion = _Parameter;
        end
    elseif (_Index == 13) then
        if _Parameter and _Parameter ~= "" then
            self.OptionalSuccess = _Parameter;
        end
    elseif (_Index == 14) then
        if _Parameter and _Parameter ~= "" then
            self.OptionalFailure = _Parameter;
        end
    end
end

function b_Goal_RandomRequest:GetCustomData(_Index)
    return {"true", "false"};
end

function b_Goal_RandomRequest:CustomFunction(_Quest)
    AddOnRandomRequests.Global:CreateSlaveQuest(self, _Quest);
    if self.SlaveQuest and self.SlaveQuest.Result == QuestResult.Success then
        return true;
    end
    if self.SlaveQuest and self.SlaveQuest.Result == QuestResult.Failure then
        return false;
    end
end

function b_Goal_RandomRequest:Reset(_Quest)
    self:Interrupt(_Quest);
    self.SlaveQuest = nil;
end

function b_Goal_RandomRequest:Interrupt(_Quest)
    if self.SlaveQuest and self.SlaveQuest.State == QuestState.Active then
        API.StopQuest(self.SlaveQuest.Identifier, false);
    end
    if _Quest.PredatorMarker and Logic.IsEffectRegistered(_Quest.PredatorMarker) then
        Logic.DestroyEffect(_Quest.PredatorMarker);
        _Quest.PredatorMarker = nil;
    end
end

function b_Goal_RandomRequest:Debug(_Quest)
    if (type(self.TimeLimit) ~= "number" or self.TimeLimit < 0) then 
        API.Fatal(_Quest.Identifier.. ": " ..self.Name.. ": Time limit must be a number and at least 0!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Goal_RandomRequest);

-- -------------------------------------------------------------------------- --

Core:RegisterAddOn("AddOnRandomRequests");

