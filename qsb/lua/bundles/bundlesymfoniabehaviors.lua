-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleSymfoniaBehaviors                                      # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle enthält einige weitere nützliche Behavior, welche es so nicht
-- in der ursprünglichen QSB gab.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleSymfoniaBehaviors = {};

API = API or {};
QSB = QSB or {};

QSB.VictoryWithPartyEntities = {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

-- Hier gibt es keine Funktionen!

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
--
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
        { ParameterType.ScriptName, en = "Entity",   de = "Entity" },
        { ParameterType.ScriptName, en = "Target",   de = "Ziel" },
        { ParameterType.Number,     en = "Distance", de = "Entfernung" },
        { ParameterType.Custom,     en = "Marker",   de = "Ziel markieren" },
    },
}

function b_Goal_MoveToPosition:GetGoalTable()
    return {Objective.Distance, self.Entity, self.Target, self.Distance, self.Marker}
end

function b_Goal_MoveToPosition:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Entity = _Parameter
    elseif (_Index == 1) then
        self.Target = _Parameter
    elseif (_Index == 2) then
        self.Distance = _Parameter * 1
    elseif (_Index == 3) then
        self.Marker = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Goal_MoveToPosition:GetCustomData( _Index )
    local Data = {};
    if _Index == 3 then
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
--
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

function b_Goal_WinQuest:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_WinQuest:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Quest = _Parameter;
    end
end

function b_Goal_WinQuest:CustomFunction(_Quest)
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

function b_Goal_WinQuest:Debug(_Quest)
    if Quests[GetQuestID(self.Quest)] == nil then
        fatal(_Quest.Identifier .. ": " .. self.Name .. ": Quest '"..self.Quest.."' does not exist!");
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
-- Stadtgebäude stehlen und nur von feindlichen Spielern.
--
-- <b>Hinweis</b>:Das Behavior cheatet allen Zielspielern Einnahmen in den
-- Gebäuden, damit der Quest stets erfüllbar bleibt. Dies gilt auch, wenn
-- der menschliche Spieler das Ziel ist!
--
-- @param _Amount       Menge an Gold
-- @param _ShowProgress Fortschritt ausgeben
--
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
        { ParameterType.Number,   en = "Amount on Gold", de = "Zu stehlende Menge" },
        { ParameterType.Custom,   en = "Target player",  de = "Spieler von dem gestohlen wird" },
        { ParameterType.Custom,   en = "Print progress", de = "Fortschritt ausgeben" },
    },
}

function b_Goal_StealGold:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_StealGold:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Amount = _Parameter * 1;
    elseif (_Index == 1) then
        local PlayerID = tonumber(_Paramater) or -1;
        self.Target = PlayerID * 1;
    elseif (_Index == 2) then
        _Parameter = _Parameter or "true"
        self.Printout = AcceptAlternativeBoolean(_Parameter);
    end
    self.StohlenGold = 0;
end

function b_Goal_StealGold:GetCustomData(_Index)
    if _Index == 1 then
        return { "-", 1, 2, 3, 4, 5, 6, 7, 8 };
    elseif _Index == 2 then
        return { "true", "false" };
    end
end

function b_Goal_StealGold:SetDescriptionOverwrite(_Quest)
    local lang = QSB.Language;
    local TargetPlayerName = (lang == "de" and " anderen Spielern ") or " different parties";
    if self.Target ~= -1 then
        TargetPlayerName = GetPlayerName(self.Target);
        if TargetPlayerName == nil or TargetPlayerName == "" then
            TargetPlayerName = " PLAYER_NAME_MISSING ";
        end
    end

    -- Cheat earnings
    local PlayerIDs = {self.Target};
    if self.Target == -1 then
        PlayerIDs = {1, 2, 3, 4, 5, 6, 7, 8};
    end
    for i= 1, #PlayerIDs, 1 do
        if i ~= _Quest.ReceivingPlayer and Logic.GetStoreHouse(i) ~= 0 then
            local CityBuildings = {Logic.GetPlayerEntitiesInCategory(i, EntityCategories.CityBuilding)};
            for j= 1, #CityBuildings, 1 do
                local CurrentEarnings = Logic.GetBuildingProductEarnings(CityBuildings[j]);
                if CurrentEarnings < 45 and Logic.GetTime() % 5 == 0 then
                    Logic.SetBuildingEarnings(CityBuildings[j], CurrentEarnings +1);
                end
            end
        end
    end

    local amount = self.Amount-self.StohlenGold;
    amount = (amount > 0 and amount) or 0;
    local text = {
        de = "Gold von %s stehlen {cr}{cr}Aus Stadtgebäuden zu stehlende Goldmenge: %d",
        en = "Steal gold from %s {cr}{cr}Amount on gold to steal from city buildings: %d",
    };
    return "{center}" ..string.format(text[lang], TargetPlayerName, amount);
end

function b_Goal_StealGold:CustomFunction(_Quest)
    Core:ChangeCustomQuestCaptionText(self:SetDescriptionOverwrite(_Quest), _Quest);

    if self.StohlenGold >= self.Amount then
        return true;
    end
    return nil;
end

function b_Goal_StealGold:GetIcon()
    return {5,13};
end

function b_Goal_StealGold:Debug(_Quest)
    if tonumber(self.Amount) == nil and self.Amount < 0 then
        fatal(_Quest.Identifier .. ": " .. self.Name .. ": amount can not be negative!");
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
-- <b>Hinweis</b>: Das Behavior cheatet in dem Zielgebäude Einnahmen, damit
-- ein Dieb entsandt werden kann.
--
-- @param _ScriptName Skriptname des Gebäudes
--
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

function b_Goal_StealBuilding:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_StealBuilding:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Building = _Parameter
    end
    self.RobberList = {};
end

function b_Goal_StealBuilding:GetCustomData(_Index)
    if _Index == 1 then
        return { "true", "false" };
    end
end

function b_Goal_StealBuilding:SetDescriptionOverwrite(_Quest)
    local isCathedral = Logic.IsEntityInCategory(GetID(self.Building), EntityCategories.Cathedrals) == 1;
    local isWarehouse = Logic.GetEntityType(GetID(self.Building)) == Entities.B_StoreHouse;
    local lang = QSB.Language;
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
            de = "Gebäude bestehlen {cr}{cr} Bestehlt das durch einen Pfeil markierte Gebäude.",
            en = "Steal from building {cr}{cr} Steal from the building marked by an arrow.",
        };
    end
    return "{center}" .. text[lang];
end

function b_Goal_StealBuilding:CustomFunction(_Quest)
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

    -- Cheat earnings
    local BuildingID = GetID(self.Building);
    if  Logic.IsEntityInCategory(BuildingID, EntityCategories.CityBuilding) == 1
    and Logic.GetBuildingEarnings(BuildingID) < 10 then
        Logic.SetBuildingEarnings(BuildingID, 10);
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

function b_Goal_StealBuilding:Debug(_Quest)
    local eTypeName = Logic.GetEntityTypeName(Logic.GetEntityType(GetID(self.Building)));
    local IsHeadquarter = Logic.IsEntityInCategory(GetID(self.Building), EntityCategories.Headquarters) == 1;
    if Logic.IsBuilding(GetID(self.Building)) == 0 then
        fatal(_Quest.Identifier .. ": " .. self.Name .. ": target is not a building");
        return true;
    elseif not IsExisting(self.Building) then
        fatal(_Quest.Identifier .. ": " .. self.Name .. ": target is destroyed :(");
        return true;
    elseif string.find(eTypeName, "B_NPC_BanditsHQ") or string.find(eTypeName, "B_NPC_Cloister") or string.find(eTypeName, "B_NPC_StoreHouse") then
        fatal(_Quest.Identifier .. ": " .. self.Name .. ": village storehouses are not allowed!");
        return true;
    elseif IsHeadquarter then
        fatal(_Quest.Identifier .. ": " .. self.Name .. ": use Goal_StealInformation for headquarters!");
        return true;
    end
    return false;
end

function b_Goal_StealBuilding:Reset()
    self.SuccessfullyStohlen = false;
    self.RobberList = {};
    self.Marker = nil;
end

function b_Goal_StealBuilding:Interrupt(_Quest)
    Logic.DestroyEffect(self.Marker);
end

Core:RegisterBehavior(b_Goal_StealBuilding)

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss ein Gebäude mit einem Dieb ausspoinieren.
--
-- Der Quest ist erfolgreich, sobald der Dieb in das Gebäude eindringt. Es
-- muss sich um ein Gebäude handeln, das bestohlen werden kann (Burg, Lager,
-- Kirche, Stadtgebäude mit Einnahmen)!
--
-- Optional kann der Dieb nach Abschluss gelöscht werden. Diese Option macht
-- es einfacher ihn durch z.B. einen Abfahrenden U_ThiefCart zu "ersetzen".
--
-- <b>Hinweis</b>:Das Behavior cheatet in dem Zielgebäude Einnahmen, damit
-- ein Dieb entsandt werden kann.
--
-- @param _ScriptName  Skriptname des Gebäudes
-- @param _DeleteThief Dieb nach Abschluss löschen
--
-- @within Goal
--
function Goal_SpyBuilding(...)
    return b_Goal_SpyBuilding:new(...)
end

b_Goal_SpyBuilding = {
    Name = "Goal_SpyBuilding",
    IconOverwrite = {5,13},
    Description = {
        en = "Goal: Infiltrate a building with a thief. A thief must be able to steal from the target building.",
        de = "Ziel: Infiltriere ein Gebäude mit einem Dieb. Nur mit Gebaueden möglich, die bestohlen werden koennen.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Target Building", de = "Zielgebäude" },
        { ParameterType.Custom,     en = "Destroy Thief", de = "Dieb löschen" },
    },
}

function b_Goal_SpyBuilding:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_SpyBuilding:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Building = _Parameter
    elseif (_Index == 1) then
        _Parameter = _Parameter or "true"
        self.Delete = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Goal_SpyBuilding:GetCustomData(_Index)
    if _Index == 1 then
        return { "true", "false" };
    end
end

function b_Goal_SpyBuilding:SetDescriptionOverwrite(_Quest)
    if not _Quest.QuestDescription then
        local lang = QSB.Language;
        local text = {
            de = "Gebäude infriltrieren {cr}{cr}Spioniere das markierte Gebäude mit einem Dieb aus!",
            en = "Infiltrate building {cr}{cr}Spy on the highlighted buildings with a thief!",
        };
        return text[lang];
    else
        return _Quest.QuestDescription;
    end
end

function b_Goal_SpyBuilding:CustomFunction(_Quest)
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

    -- Cheat earnings
    local BuildingID = GetID(self.Building);
    if  Logic.IsEntityInCategory(BuildingID, EntityCategories.CityBuilding) == 1
    and Logic.GetBuildingEarnings(BuildingID) < 10 then
        Logic.SetBuildingEarnings(BuildingID, 10);
    end

    if self.Infiltrated then
        Logic.DestroyEffect(self.Marker);
        return true;
    end
    return nil;
end

function b_Goal_SpyBuilding:GetIcon()
    return self.IconOverwrite;
end

function b_Goal_SpyBuilding:Debug(_Quest)
    if Logic.IsBuilding(GetID(self.Building)) == 0 then
        fatal(_Quest.Identifier .. ": " .. self.Name .. ": target is not a building");
        return true;
    elseif not IsExisting(self.Building) then
        fatal(_Quest.Identifier .. ": " .. self.Name .. ": target is destroyed :(");
        return true;
    end
    return false;
end

function b_Goal_SpyBuilding:Reset()
    self.Infiltrated = false;
    self.Marker = nil;
end

function b_Goal_SpyBuilding:Interrupt(_Quest)
    Logic.DestroyEffect(self.Marker);
end

Core:RegisterBehavior(b_Goal_SpyBuilding);

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
--
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

function b_Goal_AmmunitionAmount:Debug(_Quest)
    if self.Amount < 0 then
        fatal(_Quest.Identifier .. ": Error in " .. self.Name .. ": Amount is negative");
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

---
-- Eine Menge an Entities des angegebenen Spawnpoint muss zerstört werden.
--
-- Wenn die angegebene Anzahl zu Beginn des Quest nicht mit der Anzahl an
-- bereits gespawnten Entities übereinstimmt, wird dies automatisch korrigiert.
-- (Neue Entities gespawnt bzw. überschüssige gelöscht)
--
-- @param              _SpawnPoint Spawnpoint oder Liste von Spawnpoints
-- @param[type=number] _Amount     Menge zu zerstörender Entities
--
-- @within Goal
--
function Goal_DestroySpawnedEntities(...)
    return b_Goal_DestroySpawnedEntities:new(...);
end

b_Goal_DestroySpawnedEntities = {
    Name = "Goal_DestroySpawnedEntities",
    Description = {
        en = "Goal: Destroy all entities spawned at the spawnpoint.",
        de = "Ziel: Zerstöre alle Entitäten, die bei dem Spawnpoint erzeugt wurde.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Spawnpoint", de = "Spawnpoint" },
        { ParameterType.Number,     en = "Amount",     de = "Menge" },
    },
};

function b_Goal_DestroySpawnedEntities:GetGoalTable()
    return {Objective.DestroyEntities, 3, self.SpawnPoint, self.Amount};
end

function b_Goal_DestroySpawnedEntities:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        if type(_Parameter) ~= "table" then
            _Parameter = {_Parameter};
        end
        self.SpawnPoint = _Parameter;
    elseif (_Index == 1) then
        self.Amount = _Parameter * 1;
    end
end

function b_Goal_DestroySpawnedEntities:GetMsgKey()
    return "Quest_DestroyEntities";
end

function b_Goal_DestroyType:GetMsgKey()
    local ID = GetID(self.SpawnPoint);
    if ID ~= 0 then
        local TypeName = Logic.GetEntityTypeName(Logic.GetEntityType(ID));
        if Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableBuilding ) == 1 then
            return "Quest_Destroy_Leader";
        elseif TypeName:find("Bear") or TypeName:find("Lion") or TypeName:find("Tiger") or TypeName:find("Wolf") then
            return "Quest_DestroyEntities_Predators";
        elseif TypeName:find("Military") or TypeName:find("Cart") then
            return "Quest_DestroyEntities_Unit";
        end
    end
    return "Quest_DestroyEntities";
end

Core:RegisterBehavior(b_Goal_DestroySpawnedEntities);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss mindestens den angegebenen Ruf erreichen. Der Ruf muss
-- in Prozent angegeben werden (ohne %-Zeichen).
--
-- @param[type=number] _Reputation Benötigter Ruf
--
-- @within Goal
--
function Goal_CityReputation(...)
    return b_Goal_CityReputation:new(...);
end

b_Goal_CityReputation = {
    Name = "Goal_CityReputation",
    Description = {
        en = "Goal: Der Ruf der Stadt des Empfängers muss mindestens so hoch sein, wie angegeben.",
        de = "Ziel: The reputation of the quest receivers city must at least reach the desired hight.",
    },
    Parameter = {
        { ParameterType.Number, en = "City reputation", de = "Ruf der Stadt" },
    },
    Text = {
        de = "RUF DER STADT{cr}{cr}Hebe den Ruf der Stadt durch weise Herrschaft an!{cr}Benötigter Ruf: %d",
        en = "CITY REPUTATION{cr}{cr}Raise your reputation by fair rulership!{cr}Needed reputation: %d",
    }
}

function b_Goal_CityReputation:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_CityReputation:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Reputation = _Parameter * 1;
    end
end

function b_Goal_CityReputation:CustomFunction(_Quest)
    self:SetCaption(_Quest);
    local CityReputation = Logic.GetCityReputation(_Quest.ReceivingPlayer) * 100;
    if CityReputation >= self.Reputation then
        return true;
    end
end

function b_Goal_CityReputation:SetCaption(_Quest)
    if not _Quest.QuestDescription or _Quest.QuestDescription == "" then
    local Language = QSB.Language;
        local Text = string.format(self.Text[Language], self.Reputation);
        Core:ChangeCustomQuestCaptionText(Text, _Quest);
    end
end

function b_Goal_CityReputation:Debug(_Quest)
    if type(self.Reputation) ~= "number" or self.Reputation < 0 or self.Reputation > 100 then
        API.Fatal(_Quest.Identifier.. " " ..self.Name.. ": Reputation must be between 0 and 100!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Goal_CityReputation);

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
--
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

function b_Reprisal_SetPosition:GetReprisalTable()
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_SetPosition:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Target = _Parameter;
    elseif (_Index == 2) then
        self.FaceToFace = AcceptAlternativeBoolean(_Parameter)
    elseif (_Index == 3) then
        self.Distance = (_Parameter ~= nil and tonumber(_Parameter)) or 100;
    end
end

function b_Reprisal_SetPosition:CustomFunction(_Quest)
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

function b_Reprisal_SetPosition:GetCustomData(_Index)
    if _Index == 2 then
        return { "true", "false" }
    end
end

function b_Reprisal_SetPosition:Debug(_Quest)
    if self.FaceToFace then
        if tonumber(self.Distance) == nil or self.Distance < 50 then
            fatal(_Quest.Identifier.. " " ..self.Name.. ": Distance is nil or to short!");
            return true;
        end
    end
    if not IsExisting(self.Entity) or not IsExisting(self.Target) then
        fatal(_Quest.Identifier.. " " ..self.Name.. ": Mover entity or target entity does not exist!");
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
--
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

function b_Reprisal_ChangePlayer:GetReprisalTable()
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_ChangePlayer:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Player = tostring(_Parameter);
    end
end

function b_Reprisal_ChangePlayer:CustomFunction(_Quest)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    if Logic.IsLeader(eID) == 1 then
        Logic.ChangeSettlerPlayerID(eID, self.Player);
    else
        Logic.ChangeEntityPlayerID(eID, self.Player);
    end
end

function b_Reprisal_ChangePlayer:GetCustomData(_Index)
    if _Index == 1 then
        return {"0", "1", "2", "3", "4", "5", "6", "7", "8"}
    end
end

function b_Reprisal_ChangePlayer:Debug(_Quest)
    if not IsExisting(self.Entity) then
        fatal(_Quest.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
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
--
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

function b_Reprisal_SetVisible:GetReprisalTable()
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_SetVisible:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Visible = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Reprisal_SetVisible:CustomFunction(_Quest)
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

function b_Reprisal_SetVisible:GetCustomData(_Index)
    if _Index == 1 then
        return { "true", "false" }
    end
end

function b_Reprisal_SetVisible:Debug(_Quest)
    if not IsExisting(self.Entity) then
        fatal(_Quest.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_SetVisible);

-- -------------------------------------------------------------------------- --

---
-- Macht das Entity verwundbar oder unverwundbar.
--
-- Bei einem Battalion wirkt sich das Behavior auf alle Soldaten und den
-- (unsichtbaren) Leader aus. Wird das Behavior auf ein Spawner Entity 
-- angewendet, werden die gespawnten Entities genommen.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Vulnerable Verwundbarkeit an/aus
--
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

function b_Reprisal_SetVulnerability:GetReprisalTable()
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_SetVulnerability:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Vulnerability = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Reprisal_SetVulnerability:CustomFunction(_Quest)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    local eType = Logic.GetEntityType(eID);
    local tName = Logic.GetEntityTypeName(eType);
    local EntitiesToCheck = {eID};
    if string.find(tName, "S_") or string.find(tName, "B_NPC_Bandits")
    or string.find(tName, "B_NPC_Barracks") then
        EntitiesToCheck = {Logic.GetSpawnedEntities(eID)};
    end
    local MethodToUse = "MakeInvulnerable";
    if self.Vulnerability then
        MethodToUse = "MakeVulnerable";
    end
    for i= 1, #EntitiesToCheck, 1 do
        if Logic.IsLeader(EntitiesToCheck[i]) == 1 then
            local Soldiers = {Logic.GetSoldiersAttachedToLeader(EntitiesToCheck[i])};
            for j=2, #Soldiers, 1 do
                _G[MethodToUse](Soldiers[j]);
            end
        end
        _G[MethodToUse](EntitiesToCheck[i]);
    end
end

function b_Reprisal_SetVulnerability:GetCustomData(_Index)
    if _Index == 1 then
        return { "true", "false" }
    end
end

function b_Reprisal_SetVulnerability:Debug(_Quest)
    if not IsExisting(self.Entity) then
        fatal(_Quest.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
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
--
-- @within Reprisal
--
function Reprisal_SetModel(...)
    return b_Reprisal_SetModel:new(...);
end

b_Reprisal_SetModel = {
    Name = "Reprisal_SetModel",
    Description = {
        en = "Reprisal: Changes the model of the entity. Be careful, some models crash the game.",
        de = "Vergeltung: Aendert das Model einer Entity. Achtung: Einige Modelle fuehren zum Absturz.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",     de = "Entity", },
        { ParameterType.Custom,     en = "Model",     de = "Model", },
    },
}

function b_Reprisal_SetModel:GetReprisalTable()
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_SetModel:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Model = _Parameter;
    end
end

function b_Reprisal_SetModel:CustomFunction(_Quest)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    Logic.SetModel(eID, Models[self.Model]);
end

function b_Reprisal_SetModel:GetCustomData(_Index)
    if _Index == 1 then
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

function b_Reprisal_SetModel:Debug(_Quest)
    if not IsExisting(self.Entity) then
        fatal(_Quest.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
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
--
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

b_Reward_SetPosition.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } };
end

Core:RegisterBehavior(b_Reward_SetPosition);

-- -------------------------------------------------------------------------- --

---
-- Ändert den Eigentümer des Entity oder des Battalions.
--
-- @param _ScriptName Skriptname des Entity
-- @param _NewOwner   PlayerID des Eigentümers
--
-- @within Reward
--
function Reward_ChangePlayer(...)
    return b_Reward_ChangePlayer:new(...);
end

b_Reward_ChangePlayer = API.InstanceTable(b_Reprisal_ChangePlayer);
b_Reward_ChangePlayer.Name = "Reward_ChangePlayer";
b_Reward_ChangePlayer.Description.en = "Reward: Changes the owner of the entity or a battalion.";
b_Reward_ChangePlayer.Description.de = "Lohn: Aendert den Besitzer einer Entity oder eines Battalions.";
b_Reward_ChangePlayer.GetReprisalTable = nil;

b_Reward_ChangePlayer.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } };
end

Core:RegisterBehavior(b_Reward_ChangePlayer);

-- -------------------------------------------------------------------------- --

---
-- Bewegt einen Siedler relativ zu einem Zielpunkt.
--
-- Der Siedler wird sich zum Ziel ausrichten und in der angegeben Distanz
-- und dem angegebenen Winkel Position beziehen.
--
-- <p><b>Hinweis:</b> Funktioniert ähnlich wie MoveEntityToPositionToAnotherOne.
-- </p>
--
-- @param _ScriptName  Skriptname des Entity
-- @param _Destination Skriptname des Ziels
-- @param _Distance    Entfernung
-- @param _Angle       Winkel
--
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

function b_Reward_MoveToPosition:GetRewardTable()
    return { Reward.Custom, {self, self.CustomFunction} }
end

function b_Reward_MoveToPosition:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Target = _Parameter;
    elseif (_Index == 2) then
        self.Distance = _Parameter * 1;
    elseif (_Index == 3) then
        self.Angle = _Parameter * 1;
    end
end

function b_Reward_MoveToPosition:CustomFunction(_Quest)
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

function b_Reward_MoveToPosition:Debug(_Quest)
    if tonumber(self.Distance) == nil or self.Distance < 50 then
        fatal(_Quest.Identifier.. " " ..self.Name.. ": Distance is nil or to short!");
        return true;
    elseif not IsExisting(self.Entity) or not IsExisting(self.Target) then
        fatal(_Quest.Identifier.. " " ..self.Name.. ": Mover entity or target entity does not exist!");
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
-- @within Reward
--
function Reward_VictoryWithParty()
    return b_Reward_VictoryWithParty:new();
end

b_Reward_VictoryWithParty = {
    Name = "Reward_VictoryWithParty",
    Description = {
        en = "Reward: The player wins the game with an animated festival on the market. Continue playing deleates the festival.",
        de = "Lohn: Der Spieler gewinnt das Spiel mit einer animierten Siegesfeier. Bei weiterspielen wird das Fest gelöscht.",
    },
    Parameter =    {}
};

function b_Reward_VictoryWithParty:GetRewardTable()
    return {Reward.Custom, {self, self.CustomFunction}};
end

function b_Reward_VictoryWithParty:AddParameter(_Index, _Parameter)
end

function b_Reward_VictoryWithParty:CustomFunction(_Quest)
    Victory(g_VictoryAndDefeatType.VictoryMissionComplete);
    local pID = _Quest.ReceivingPlayer;

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
        local Generated = VictoryWithParty_GenerateParty(pID, PossibleSettlerTypes);
        QSB.VictoryWithPartyEntities[pID] = Generated;

        Logic.ExecuteInLuaLocalState([[
            if IsExisting(]]..market..[[) then
                CameraAnimation.AllowAbort = false
                CameraAnimation.QueueAnimation(CameraAnimation.SetCameraToEntity, ]]..market..[[)
                CameraAnimation.QueueAnimation(CameraAnimation.StartCameraRotation, 5)
                CameraAnimation.QueueAnimation(CameraAnimation.Stay ,9999)
            end

            GUI_Window.ContinuePlayingClicked_Orig_Reward_VictoryWithParty = GUI_Window.ContinuePlayingClicked
            GUI_Window.ContinuePlayingClicked = function()
                GUI_Window.ContinuePlayingClicked_Orig_Reward_VictoryWithParty()
                
                local PlayerID = GUI.GetPlayerID()
                API.Bridge("VictoryWithParty_ClearParty(" ..PlayerID.. ")")

                CameraAnimation.AllowAbort = true
                CameraAnimation.Abort()
            end
        ]]);
    end
end

-- Diese Funktion ist statisch und wird von GUI_Window.ContinuePlayingClicked
-- aufgerufen! Rufe sie niemals manuell auf!
function VictoryWithParty_ClearParty(_PlayerID)
    if QSB.VictoryWithPartyEntities[_PlayerID] then
        for k, v in pairs(QSB.VictoryWithPartyEntities[_PlayerID]) do
            DestroyEntity(v);
        end
        QSB.VictoryWithPartyEntities[_PlayerID] = nil;
    end
end

-- Dies ist eine Hilfsfunktion zur Erzeugung eines löschbaren Festes. Wird
-- im Code aufgerufen. Nicht manuell aufrufen!
function VictoryWithParty_GenerateParty(_PlayerID, _PossibleSettlersTypesList)
    local GeneratedEntities = {};
    local Marketplace = Logic.GetMarketplace(_PlayerID);
    if Marketplace ~= nil and Marketplace ~= 0 then
        local MarketX, MarketY = Logic.GetEntityPosition(Marketplace);
        local ID = Logic.CreateEntity(Entities.D_X_Garland, MarketX, MarketY, 0, _PlayerID)
        table.insert(GeneratedEntities, ID);
        for j=1, 10 do
            for k=1,10 do
                local SettlersX = MarketX -700+ (j*150);
                local SettlersY = MarketY -700+ (k*150);
                
                local rand = Logic.GetRandom(100);
                
                if rand > 70 then
                    local SettlerType = _PossibleSettlersTypesList[1 + Logic.GetRandom(#_PossibleSettlersTypesList)];
                    local Orientation = Logic.GetRandom(360);
                    local WorkerID = Logic.CreateEntityOnUnblockedLand(SettlerType, SettlersX, SettlersY, Orientation, _PlayerID);
                    Logic.SetTaskList(WorkerID, TaskLists.TL_WORKER_FESTIVAL_APPLAUD_SPEECH);
                    table.insert(GeneratedEntities, WorkerID);
                end
            end
        end
    end
    return GeneratedEntities;
end

function b_Reward_VictoryWithParty:Debug(_Quest)
    return false;
end

Core:RegisterBehavior(b_Reward_VictoryWithParty);

-- -------------------------------------------------------------------------- --

---
-- Ändert die Sichtbarkeit eines Entity.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Visible    Sichtbarkeit an/aus
--
-- @within Reprisal
--
function Reward_SetVisible(...)
    return b_Reward_SetVisible:new(...)
end

b_Reward_SetVisible = API.InstanceTable(b_Reprisal_SetVisible);
b_Reward_SetVisible.Name = "Reward_SetVisible";
b_Reward_SetVisible.Description.en = "Reward: Changes the visibility of an entity. If the entity is a spawner the spawned entities will be affected.";
b_Reward_SetVisible.Description.de = "Lohn: Setzt die Sichtbarkeit einer Entity. Handelt es sich um einen Spawner werden auch die gespawnten Entities beeinflusst.";
b_Reward_SetVisible.GetReprisalTable = nil;

b_Reward_SetVisible.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Core:RegisterBehavior(b_Reward_SetVisible);

-- -------------------------------------------------------------------------- --

---
-- Gibt oder entzieht einem KI-Spieler die Kontrolle über ein Entity.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Controlled Durch KI kontrollieren an/aus
--
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

function b_Reward_AI_SetEntityControlled:GetRewardTable()
    return { Reward.Custom, { self, self.CustomFunction } }
end

function b_Reward_AI_SetEntityControlled:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Hidden = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Reward_AI_SetEntityControlled:CustomFunction(_Quest)
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

function b_Reward_AI_SetEntityControlled:GetCustomData(_Index)
    if _Index == 1 then
        return { "false", "true" }
    end
end

function b_Reward_AI_SetEntityControlled:Debug(_Quest)
    if not IsExisting(self.Entity) then
        fatal(_Quest.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reward_AI_SetEntityControlled);

-- -------------------------------------------------------------------------- --

---
-- Macht das Entity verwundbar oder unverwundbar.
--
-- Bei einem Battalion wirkt sich das Behavior auf alle Soldaten und den
-- (unsichtbaren) Leader aus. Wird das Behavior auf ein Spawner Entity 
-- angewendet, werden die gespawnten Entities genommen.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Vulnerable Verwundbarkeit an/aus
--
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

b_Reward_SetVulnerability.GetRewardTable = function(self, _Quest)
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
--
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

b_Reward_SetModel.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Core:RegisterBehavior(b_Reward_SetModel);

-- -------------------------------------------------------------------------- --

---
-- Füllt die Munition in der Kriegsmaschine vollständig auf.
--
-- @param _ScriptName Skriptname des Entity
--
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

function b_Reward_RefillAmmunition:Debug(_Quest)
    if not IsExisting(self.Scriptname) then
        fatal(_Quest.Identifier .. ": Error in " .. self.Name .. ": '"..self.Scriptname.."' is destroyed!");
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
--
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

function b_Trigger_OnAtLeastXOfYQuestsFailed:Debug(_Quest)
    local leastAmount = self.LeastAmount
    local questAmount = self.QuestAmount
    if leastAmount <= 0 or leastAmount >5 then
        fatal(_Quest.Identifier .. ": Error in " .. self.Name .. ": LeastAmount is wrong")
        return true
    elseif questAmount <= 0 or questAmount > 5 then
        fatal(_Quest.Identifier .. ": Error in " .. self.Name .. ": QuestAmount is wrong")
        return true
    elseif leastAmount > questAmount then
        fatal(_Quest.Identifier .. ": Error in " .. self.Name .. ": LeastAmount is greater than QuestAmount")
        return true
    end
    for i = 1, questAmount do
        if not IsValidQuest(self["QuestName"..i]) then
            fatal(_Quest.Identifier .. ": Error in " .. self.Name .. ": Quest ".. self["QuestName"..i] .. " not found")
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
--
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

function b_Trigger_AmmunitionDepleted:Debug(_Quest)
    if not IsExisting(self.Scriptname) then
        fatal(_Quest.Identifier .. ": Error in " .. self.Name .. ": '"..self.Scriptname.."' is destroyed!");
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
--
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

function b_Trigger_OnExactOneQuestIsWon:GetTriggerTable()
    return {Triggers.Custom2, {self, self.CustomFunction}};
end

function b_Trigger_OnExactOneQuestIsWon:AddParameter(_Index, _Parameter)
    self.QuestTable = {};

    if (_Index == 0) then
        self.Quest1 = _Parameter;
    elseif (_Index == 1) then
        self.Quest2 = _Parameter;
    end
end

function b_Trigger_OnExactOneQuestIsWon:CustomFunction(_Quest)
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

function b_Trigger_OnExactOneQuestIsWon:Debug(_Quest)
    if self.Quest1 == self.Quest2 then
        fatal(_Quest.Identifier..": "..self.Name..": Both quests are identical!");
        return true;
    elseif not IsValidQuest(self.Quest1) then
        fatal(_Quest.Identifier..": "..self.Name..": Quest '"..self.Quest1.."' does not exist!");
        return true;
    elseif not IsValidQuest(self.Quest2) then
        fatal(_Quest.Identifier..": "..self.Name..": Quest '"..self.Quest2.."' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_OnExactOneQuestIsWon);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, wenn exakt einer von beiden Quests fehlgeschlagen ist.
--
-- @param _QuestName1 Name des ersten Quest
-- @param _QuestName2 Name des zweiten Quest
--
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

function b_Trigger_OnExactOneQuestIsLost:GetTriggerTable()
    return {Triggers.Custom2, {self, self.CustomFunction}};
end

function b_Trigger_OnExactOneQuestIsLost:AddParameter(_Index, _Parameter)
    self.QuestTable = {};

    if (_Index == 0) then
        self.Quest1 = _Parameter;
    elseif (_Index == 1) then
        self.Quest2 = _Parameter;
    end
end

function b_Trigger_OnExactOneQuestIsLost:CustomFunction(_Quest)
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

function b_Trigger_OnExactOneQuestIsLost:Debug(_Quest)
    if self.Quest1 == self.Quest2 then
        fatal(_Quest.Identifier..": "..self.Name..": Both quests are identical!");
        return true;
    elseif not IsValidQuest(self.Quest1) then
        fatal(_Quest.Identifier..": "..self.Name..": Quest '"..self.Quest1.."' does not exist!");
        return true;
    elseif not IsValidQuest(self.Quest2) then
        fatal(_Quest.Identifier..": "..self.Name..": Quest '"..self.Quest2.."' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_OnExactOneQuestIsLost);

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleSymfoniaBehaviors = {
    Global = {},
    Local = {}
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function BundleSymfoniaBehaviors.Global:Install()
    Core:StackFunction("QuestTemplate.Trigger", self.OnQuestTriggered);

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
                            local CurrentObjective = Quests[i].Objectives[j].Data[1];
                            local TargetPlayerID = Logic.EntityGetPlayer(_BuildingID);

                            if CurrentObjective.Target ~= -1 and CurrentObjective.Target ~= TargetPlayerID then
                                return;
                            end
                            Quests[i].Objectives[j].Data[1].StohlenGold = Quests[i].Objectives[j].Data[1].StohlenGold + _GoodAmount;
                            if CurrentObjective.Printout then
                                local lang = QSB.Language;
                                local msg  = {de = "Talern gestohlen",en = "gold stolen",};
                                local curr = CurrentObjective.StohlenGold;
                                local need = CurrentObjective.Amount;
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
                        if Quests[i].Objectives[j].Data[1].Name == "Goal_SpyBuilding" then
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
        if objective.Completed ~= nil then
            if objective.Data[1] == 3 then
                objective.Data[4] = nil;
            end
            return objective.Completed;
        end

        if objectiveType == Objective.Distance then
            objective.Completed = BundleSymfoniaBehaviors.Global:IsQuestPositionReached(self, objective);
        elseif objectiveType == Objective.DestroyEntities then
            if objective.Data[1] == 3 then
                objective.Completed = BundleSymfoniaBehaviors.Global:AreQuestEntitiesDestroyed(self, objective);
            else
                return self:IsObjectiveCompleted_Orig_QSB_SymfoniaBehaviors(objective);
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

---
-- Prüft, ob das Entity das Ziel erreicht hat.
-- @param[type=table] _Quest     Quest Data
-- @param[type=table] _Objective Behavior Data
-- @return[type=boolean] Ziel wurde erreicht
-- @within Internal
-- @local
--
function BundleSymfoniaBehaviors.Global:IsQuestPositionReached(_Quest, _Objective)
    local IDdata2 = GetID(_Objective.Data[1]);
    local IDdata3 = GetID(_Objective.Data[2]);
    _Objective.Data[3] = _Objective.Data[3] or 2500;
    if not (Logic.IsEntityDestroyed(IDdata2) or Logic.IsEntityDestroyed(IDdata3)) then
        if Logic.GetDistanceBetweenEntities(IDdata2,IDdata3) <= _Objective.Data[3] then
            DestroyQuestMarker(IDdata3);
            return true;
        end
    else
        DestroyQuestMarker(IDdata3);
        return false;
    end
end

---
-- Prüft, ob alle gespawnten Entities zerstört wurden.
-- @param[type=table] _Quest     Quest Data
-- @param[type=table] _Objective Behavior Data
-- @return[type=boolean] Resultat des Behavior
-- @within Internal
-- @local
--
function BundleSymfoniaBehaviors.Global:AreQuestEntitiesDestroyed(_Quest, _Objective)
    if _Objective.Data[1] == 3 then
        local AllSpawnedEntities = {};
        for i=1, _Objective.Data[2][0], 1 do
            local ID = GetID(_Objective.Data[2][i]);
            AllSpawnedEntities = Array_Append(AllSpawnedEntities, {Logic.GetSpawnedEntities(ID)});
        end
        if #AllSpawnedEntities == 0 then
            return true;
        end
    end
end

---
-- Überschreibt die :Trigger() Methode um sicherzustellen, dass immer genug
-- gespawnte Entities vorhanden sind.
-- @within Internal
-- @local
--
function BundleSymfoniaBehaviors.Global.OnQuestTriggered(self)
    if self.Objectives[1] and self.Objectives[1].Data[1] == 3 then
        if self.Objectives[1].Data[4] ~= true then
            -- Entities respawnen
            local FirstEntityID;
            local SpawnAmount = self.Objectives[1].Data[3];
            for i=1, self.Objectives[1].Data[2][0], 1 do
                local ID = GetID(self.Objectives[1].Data[2][i]);
                local SpawnedEntities = {Logic.GetSpawnedEntities(ID)};
                if #SpawnedEntities < SpawnAmount then
                    for i= 1, SpawnAmount - #SpawnedEntities, 1 do
                        Logic.RespawnResourceEntity_Spawn(ID);
                    end
                elseif #SpawnedEntities > SpawnAmount then
                    for i= 1, #SpawnedEntities - SpawnAmount, 1 do
                        DestroyEntity(SpawnedEntities[1]);
                        SpawnedEntities = {Logic.GetSpawnedEntities(ID)};
                    end
                end
                if not FirstEntityID then
                    FirstEntityID = SpawnedEntities[1];
                end
            end
            -- Icon setzen
            if not self.Objectives[1].Data[5] then
                self.Objectives[1].Data[5] = {7, 12};
                if Logic.IsEntityInCategory(FirstEntityID, EntityCategories.AttackableAnimal) == 1 then
                    self.Objectives[1].Data[5] = {13, 8};
                end
            end
            self.Objectives[1].Data[4] = true;
        end
    end
end

-- Local Script ----------------------------------------------------------------

---
-- Initialisiert das Bundle im lokalen Skript.
-- @within Internal
-- @local
--
function BundleSymfoniaBehaviors.Local:Install()
    Core:StackFunction("GUI_Interaction.GetEntitiesOrTerritoryListForQuest", self.GetEntitiesOrTerritoryList);
    Core:StackFunction("GUI_Interaction.SaveQuestEntityTypes", self.SaveQuestEntityTypes);
    Core:StackFunction("GUI_Interaction.DisplayQuestObjective", self.DisplayQuestObjective);
end

---
-- Erweitert die Funktion, welche das Auftragsziel darstellt. Das richtige
-- Icon für Spawned Entities wird angezeigt.
-- @within Internal
-- @local
--
function BundleSymfoniaBehaviors.Local.DisplayQuestObjective(_QuestIndex, _MessageKey)
    local QuestIndexTemp = tonumber(_QuestIndex);
    if QuestIndexTemp then
        _QuestIndex = QuestIndexTemp;
    end
    local Quest, QuestType = GUI_Interaction.GetPotentialSubQuestAndType(_QuestIndex);
    local QuestObjectivesPath = "/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives";
    XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives", 0);
    if QuestType == Objective.DestroyEntities and Quest.Objectives[1].Data[1] == 3 then
        local QuestObjectiveContainer = QuestObjectivesPath .. "/GroupEntityType";
        local QuestTypeCaption = Wrapped_GetStringTableText(_QuestIndex, "UI_Texts/QuestDestroy");
        local EntitiesList = GUI_Interaction.GetEntitiesOrTerritoryListForQuest( Quest, QuestType );
        local EntitiesAmount = #EntitiesList;
        if not Quest.Objectives[1].Data[4] and #EntitiesList == 0 then
            EntitiesAmount = #Quest.Objectives[1].Data[2][0] * Quest.Objectives[1].Data[3];
        end

        XGUIEng.ShowWidget(QuestObjectiveContainer .. "/AdditionalCaption", 0);
        XGUIEng.ShowWidget(QuestObjectiveContainer .. "/AdditionalCondition", 0);
        SetIcon(QuestObjectiveContainer .. "/Icon", Quest.Objectives[1].Data[5]);
        XGUIEng.SetText(QuestObjectiveContainer .. "/Number", "{center}" .. EntitiesAmount);

        XGUIEng.SetText(QuestObjectiveContainer .. "/Caption", "{center}" .. QuestTypeCaption);
        XGUIEng.ShowWidget(QuestObjectiveContainer, 1);
        GUI_Interaction.SetQuestTypeIcon(QuestObjectiveContainer .. "/QuestTypeIcon", _QuestIndex);
        if Quest.State == QuestState.Over then
            if Quest.Result == QuestResult.Success then
                XGUIEng.ShowWidget(QuestObjectivesPath .. "/QuestOverSuccess", 1);
            elseif Quest.Result == QuestResult.Failure then
                XGUIEng.ShowWidget(QuestObjectivesPath .. "/QuestOverFailure", 1);
            end
        end
        return true;
    end

    --end if dummy quest
    if QuestObjectiveContainer == nil then
        return
    end
end

---
-- Erweitert die Funktion zur Ermittlung der Sprungziele für die Lupe.
-- Alle gespawnten Entities werden durch die Lupe angezeigt.
-- @param[type=table]  _Quest     Quest Table
-- @param[type=number] _QuestType Typ des Quest
-- @within Internal
-- @local
--
function BundleSymfoniaBehaviors.Local.GetEntitiesOrTerritoryList(_Quest, _QuestType)
    local IsEntity = true;
    local EntityOrTerritoryList = {};
    if _QuestType == Objective.DestroyEntities then
        if _Quest.Objectives[1].Data and _Quest.Objectives[1].Data[1] == 3 then
            for i=1, _Quest.Objectives[1].Data[2][0], 1 do
                local ID = GetID(_Quest.Objectives[1].Data[2][i]);
                EntityOrTerritoryList = Array_Append(EntityOrTerritoryList, {Logic.GetSpawnedEntities(ID)});
            end
            return EntityOrTerritoryList, IsEntity;
        end
    end
end

---
-- Erweitert die Funktion zur Speicherung der Quest Entities. Es wird der
-- neue Typ 3 für Objective.DestroyEntities implementiert.
-- @param[type=number] _QuestIndex Index des Quest
-- @within Internal
-- @local
--
function BundleSymfoniaBehaviors.Local.SaveQuestEntityTypes(_QuestIndex)
    if g_Interaction.SavedQuestEntityTypes[_QuestIndex] ~= nil then
        return;
    end
    local Quest, QuestType = GUI_Interaction.GetPotentialSubQuestAndType(_QuestIndex);
    local EntitiesList;
    if QuestType ~= Objective.DestroyEntities or Quest.Objectives[1].Data[1] ~= 3 then
        return;
    end
    EntitiesList = GUI_Interaction.GetEntitiesOrTerritoryListForQuest(Quest, QuestType);
    EntitiesList[0] = #EntitiesList;
    if EntitiesList ~= nil then
        g_Interaction.SavedQuestEntityTypes[_QuestIndex] = {};
        for i = 1, EntitiesList[0], 1 do
            if Logic.IsEntityAlive(EntitiesList[i]) then
                local EntityType = Logic.GetEntityType(GetEntityId(EntitiesList[i]));
                table.insert(g_Interaction.SavedQuestEntityTypes[_QuestIndex], i, EntityType);
            end
        end
        return true;
    end
end

Core:RegisterBundle("BundleSymfoniaBehaviors");

