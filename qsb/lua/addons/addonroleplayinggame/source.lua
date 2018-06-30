-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnRolePlayingGame                                         # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Bietet dem Mapper ein vereinfachtes Interface für RPG-Maps. Das Bundle
-- basiert auf dem RPG-Skript von Schwarzer Schmetterling 2, allerdings
-- wurden einige Elemente ausgespart um es zu vereinfachen. Außerdem ist 
-- die Steuerung benutzerfreundlicher gestaltet.
--
-- @module AddOnRolePlayingGame
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

AddOnRolePlayingGame = {
    Global =  {
        Data = {
            PlayerExperience = {0, 0, 0, 0, 0, 0, 0, 0,},
            BaseExperience = 500,
            LearnpointsPerLevel = 3,
            UseInformPlayer = true,
            UseLevelUpByPromotion = true,
            UseAutoLevel = true,
        },
    },
    Local = {
        Data = {},
    },
    
    KnightCommands = {
        Strength = {
            Mother	= "/InGame/Root/Normal/AlignTopLeft/KnightCommands/StartAttack",
            Button	= "/InGame/Root/Normal/AlignTopLeft/KnightCommands/StartAttack/Button",
            Timer	= "/InGame/Root/Normal/AlignTopLeft/KnightCommands/StartAttack/Time",
        },
        Magic = {
            Mother	= "/InGame/Root/Normal/AlignTopLeft/KnightCommands/Trebuchet",
            Button	= "/InGame/Root/Normal/AlignTopLeft/KnightCommands/Trebuchet/Button",
            Timer	= "/InGame/Root/Normal/AlignTopLeft/KnightCommands/Trebuchet/Time",
        },
        Endurance = {
            Mother	= "/InGame/Root/Normal/AlignTopLeft/KnightCommands/Bless",
            Button	= "/InGame/Root/Normal/AlignTopLeft/KnightCommands/Bless/Button",
            Timer	= "/InGame/Root/Normal/AlignTopLeft/KnightCommands/Bless/Time",
        },
    },

    Texts = {        
        Strength = {
            Caption = {
                de = "Kraft",
                en = "Strength",
            },
            Description = {
                de = "Kaft bestimmt, wie viel Schaden ein Held im Kampf gegen"..
                     " andere Einheiten und Helden verursacht.",
                en = "Strength indicates how much damage a hero can inflict"..
                     " to enemie units and heroes.",
            },
        },
        Magic = {
            Caption = {
                de = "Magie",
                en = "Magic",
            },
            Description = {
                de = "Magie bestimmt, wie schnell die besondere Fähigkeit des"..
                     " Helden wieder einsatzbereit wird.",
                en = "The magic shortens the time needed to restore the"..
                     " special ability of the hero.",
            },
        },
        Endurance = {
            Caption = {
                de = "Widerstandskraft",
                en = "Endurance",
            },
            Description = {
                de = "Widerstandskraft bestimmt, wie gut ein Held erlittenen"..
                     " durch Feinde erlittenen Schaden aushalten kann.",
                en = "Endurance indicates how much damage a hero can endure"..
                     " while fighting against enemies.",
            },
        },
        UpgradeStrength = {
            de = "Kraft verbessern",
            en = "Improve Strength",
        },
        UpgradeMagic = {
            de = "Magie verbessern",
            en = "Improve Magic",
        },
        UpgradeEndurance = {
            de = "Widerstandskraft verbessern",
            en = "Improve Endurance",
        },
        InventoryBackpack = {
            Caption = {de = "Rucksack", en = "Inventory"},
            Button  = {de = "Ausrüstung anzeigen", en = "Show equipment"},
        },
        InventoryEquipment = {
            Caption = {de = "Ausrüstung", en = "Equipment"},
            Button  = {de = "Rucksack anzeigen", en = "Show inventory"},
        },
        CharacterStatus = {
            Caption = {de = "Status", en = "Status"},
            Button  = {de = "Effekte anzeigen", en = "Show effects"},
        },
        PositiveEffects = {
            Caption = {de = "Erworbene Tugenden", en = "Aquired Virtues"},
            Button  = {de = "Laster anzeigen", en = "Show Vices"},
        },
        NegativeEffects = {
            Caption = {de = "Erworbene Laster", en = "Aquired Vices"},
            Button  = {de = "Tugenden anzeigen", en = "Show virtues"},
        },
        
        -- Messages --
        
        ErrorAbility = {
            de = "Die Fähigkeit kann nicht benutzt werden!",
            en = "The ability can not be used!",
        },
        EarnedExperience = {
            de = "+{@color:0,255,255,255}%d{@color:255,255,255,255} Erfahrung",
            en = "+{@color:0,255,255,255}%d{@color:255,255,255,255} Experience",
        },
        HeroLevelUp = {
            de = "{@color:244,184,0,255}Level up!",
            en = "{@color:244,184,0,255}Level up!",
        },
        AutoLevelUp = {
            de = "Die {@color:0,255,255,255}Statuswerte{@color:255,255,255,255} Eure Helden haben sich verbessert!",
            en = "The {@color:0,255,255,255}properties{@color:255,255,255,255} of your heroes have improved!",
        },
        ManualLevelUp = {
            de = "Alle Helden erhalten {@color:0,255,255,255}%d{@color:255,255,255,255} Lernpunkte!",
            en = "All heroes gained {@color:0,255,255,255}%d{@color:255,255,255,255} learnpoints!",
        },
    },
}

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Aktiviert oder deaktivier den automatischen Stufenaufstieg der Helden.
--
-- @param _Flag Auto-Level Flag
--
function API.RpgConfig_UseAutoLevel(_Flag)
    AddOnRolePlayingGame.Global.Data.UseAutoLevel = _Flag == true;
end

---
-- Aktiviert oder deaktivier die Information über Ereignisse an den Spieler.
--
-- @param _Flag Inform Player Flag
--
function API.RpgConfig_UseInformPlayer(_Flag)
    AddOnRolePlayingGame.Global.Data.UseInformPlayer = _Flag == true;
end

---
-- Legt fest, ob die Helden automatisch bei Beförderung um eine Stufe steigen.
--
-- @param _Flag Promotion Level Up Flag
--
function API.RpgConfig_UseLevelUpByPromotion(_Flag)
    AddOnRolePlayingGame.Global.Data.UseLevelUpByPromotion = _Flag == true;
end

---
-- Legt fest, wie viele Lernpunkte Helden erhalten, wenn sie eine Stufe 
-- aufsteigen.
--
-- @param _LP Menge an Lernpunkten
--
function API.RpgConfig_SetLernpointsPerLevel(_LP)
    AddOnRolePlayingGame.Global.Data.LearnpointsPerLevel = _LP
end

---
-- Setzt die Menge an Erfahrung, die für einen Stufenaufstieg benötigt wird.
--
-- @param _EXP Menge an Erfahrung
--
function API.RpgConfig_SetBaseExperience(_EXP)
    AddOnRolePlayingGame.Global.Data.BaseExperience = _EXP
end

---
-- Gibt einen Spieler eine Menge an Erfahrungspunkten.
--
-- @param _PlayerID Spieler, der Erfahrung erhält
-- @param _EXP      Menge an Erfahrung
--
function API.RpgHelper_AddPlayerExperience(_PlayerID, _EXP)
    assert(AddOnRolePlayingGame.Global.Data.PlayerExperience[_PlayerID]);
    AddOnRolePlayingGame.Global.Data.PlayerExperience[_PlayerID] = AddOnRolePlayingGame.Global.Data.PlayerExperience[_PlayerID] + _EXP;
    if AddOnRolePlayingGame.Global.Data.UseInformPlayer then
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        API.Note(string.format(AddOnRolePlayingGame.Texts.EarnedExperience[lang], _EXP));
    end
end

---
-- Gibt die Erfahrungspunkte des Spielers zurück.
--
-- @param _PlayerID Spieler, der Erfahrung erhält
-- @return number: Erfahrung des Spielers
--
function API.RpgHelper_GetPlayerExperience(_PlayerID)
    assert(AddOnRolePlayingGame.Global.Data.PlayerExperience[_PlayerID]);
    return AddOnRolePlayingGame.Global.Data.PlayerExperience[_PlayerID];
end

---
-- Gibt die Erfahrungspunkte zurück, die für die nächste Stufe benötigt werden.
--
-- @param _PlayerID Spieler, der Erfahrung erhält
-- @return number: Benötigte Erfahrung
--
function API.RpgHelper_GetPlayerNeededExperience(_PlayerID)
    assert(AddOnRolePlayingGame.Global.Data.PlayerExperience[_PlayerID]);
    local Current = AddOnRolePlayingGame.Global.Data.PlayerExperience[_PlayerID];
    local Needed  = AddOnRolePlayingGame.Global.Data.BaseExperience;
    return Needed - Current;
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global:Install()
    -- Event 
    Core:AppendFunction("GameCallback_EntityKilled", self.OnEntityKilledController);
    Core:AppendFunction("GameCallback_EntityHurt", self.OnEntityHurtController);
    Core:AppendFunction("GameCallback_TaxCollectionFinished", self.OnTaxCollectionFinished);
    Core:AppendFunction("GameCallback_RegularFestivalEnded", self.OnRegularFestivalEnded);
    Core:AppendFunction("GameCallback_EndOfMonth", self.OnEndOfMonth);
    Core:AppendFunction("GameCallback_OnBuildingUpgradeFinished", self.OnBuildingUpgradeFinished);
    Core:AppendFunction("GameCallback_OnBuildingConstructionComplete", self.OnBuildingConstructionComplete);
    Core:AppendFunction("GameCallback_OnGeologistRefill", self.OnGeologistRefill);
    StartSimpleJobEx(self.OnEverySecond);
    -- Kampf Controller
    API.AddOnEntityHurtAction(self.EntityFightingController);
    -- Level-Up Controller
    Core:AppendFunction("GameCallback_KnightTitleChanged", self.LevelUpController);
    -- Experience Level-Up Controller 
    StartSimpleJobEx(self.ExperienceLevelUpController);
    -- Save Game 
    API.AddSaveGameAction(self.OnSaveGameLoaded);
end

-- Core Functunality --

---
-- Gibt alle instanzierten Helden zurück, die dem Spieler gehören.
-- 
-- @param _EntityID ID des Entity
-- @return table: Helden des Spielers
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global:GetHeroes(_PlayerID)
    local HeroesOfPlayer = {};
    for k, v in pairs(AddOnRolePlayingGame.HeroList) do
        if v and IsExisting(v.ScriptName) and Logic.EntityGetPlayer(GetID(v.ScriptName)) == _PlayerID then 
            table.insert(HeroesOfPlayer, v);
        end
    end 
    return HeroesOfPlayer;
end

---
-- Gibt alle Inventare der Helden eines Spielers zurück.
--
-- Hat ein Held kein Inventar, wird dieser Held ausgelassen.
-- 
-- @param _EntityID ID des Entity
-- @return table: Helden des Spielers
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global:GetInventories(_PlayerID)
    local InventoriesOfPlayer = {};
    for k, v in pairs(AddOnRolePlayingGame.HeroList) do
        if v and IsExisting(v.ScriptName) and Logic.EntityGetPlayer(GetID(v.ScriptName)) == _PlayerID then 
            if v.Inventory then
                table.insert(InventoriesOfPlayer, v.Inventory);
            end
        end
    end 
    return InventoriesOfPlayer;
end

-- Callbacks --

---
-- Aktualisiert die Statuswerte eines Helden.
--
-- Der Index steht für den geklickten Button.
-- Die EntityID bestimmt den Helden.
--
-- @param _Idx      Button Index
-- @param _EntityID ID des Entity
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global:UpgradeHeroStatus(_Idx, _EntityID)
    local ScriptName = Logic.GetEntityName(_EntityID);
    local HeroInstance = AddOnRolePlayingGame.Hero:GetInstance(ScriptName);
    if HeroInstance == nil then 
        return;
    end
    if HeroInstance.Learnpoints < 1 then 
        return;
    end

    -- Statuswert verbessern
    if _Idx == 0 then 
        local Costs = HeroInstance.StrengthCosts or 1;
        HeroInstance.Learnpoints = HeroInstance.Learnpoints - Costs;
        HeroInstance.Unit.Strength = HeroInstance.Unit.Strength +1;
    elseif _Idx == 1 then
        local Costs = HeroInstance.EnduranceCosts or 1;
        HeroInstance.Learnpoints = HeroInstance.Learnpoints - Costs;
        HeroInstance.Unit.Endurance = HeroInstance.Unit.Endurance +1;
    else
        local Costs = HeroInstance.MagicCosts or 1;
        HeroInstance.Learnpoints = HeroInstance.Learnpoints - Costs;
        HeroInstance.Unit.Magic = HeroInstance.Unit.Magic +1;
    end
    API.Bridge('AddOnRolePlayingGame.HeroList["' ..ScriptName.. '"].Learnpoints = '..HeroInstance.Learnpoints);
end

---
-- Hebt das Level aller Helden eines Spielers an. Dabei werden entweder 
-- Lernpunkte vergeben oder automatisch Statuswerte erhöht.
--
-- @param _PlayerID ID des Spielers
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global:LevelUpAction(_PlayerID)
    for k, v in pairs(AddOnRolePlayingGame.HeroList) do
        if v then
            local PlayerID = Logic.EntityGetPlayer(GetID(k));
            if PlayerID == _PlayerID then
                v:LevelUp(self.Data.LearnpointsPerLevel, self.Data.UseAutoLevel == true);
            end
        end
    end
    
    -- Den Spieler informieren
    if API.GetControllingPlayer() == _PlayerID then
        if self.Data.UseInformPlayer then
            API.Note(AddOnRolePlayingGame.Texts.HeroLevelUp);
            if self.Data.UseAutoLevel then
                API.Note(AddOnRolePlayingGame.Texts.AutoLevelUp);
            else
                local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
                local Text = string.format(AddOnRolePlayingGame.Texts.ManualLevelUp[Language], self.Data.LearnpointsPerLevel);
                API.Note(Text);
            end
        end
    end
end

---
-- Wechselt zwischen Rücksack und angelegten Gegenständen des Helden.
--
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global:ToggleInventory(_SelectedEntity)
    if _SelectedEntity == 0 then
        return;
    end
    local ScriptName = Logic.GetEntityName(_SelectedEntity);
    local Hero = AddOnRolePlayingGame.Hero:GetInstance(ScriptName);
    if not Hero or Hero.Inventory == nil then
        return;
    end
    API.Bridge("AddOnRolePlayingGame.Local:DisplayInventory('" ..Hero.Inventory.Identifier.. "', false)");
end

---
-- Wechselt zwischen Rücksack und angelegten Gegenständen des Helden.
--
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global:ToggleEffects(_SelectedEntity)
    if _SelectedEntity == 0 then
        return;
    end
    local ScriptName = Logic.GetEntityName(_SelectedEntity);
    local Hero = AddOnRolePlayingGame.Hero:GetInstance(ScriptName);
    if not Hero then
        return;
    end
    API.Bridge("AddOnRolePlayingGame.Local:DisplayEffects('" ..Hero.ScriptName.. "', false)");
end

---
-- Löst für die angegebenen Helden alle Events aus, die durch den Trigger 
-- aktiviert werden. Es wird die Action eines Events aufgerufen. Die Action 
-- erhält den Helden, den Auslöser, und optionale Argumente des originalen
-- Triggers (vom Spiel).
--
-- @param _HeroList Liste der Helden
-- @param _Trigger  Auslöser
-- @param ...       Optionale Argumente
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global:InvokeEvent(_HeroList, _Trigger, ...)
    _HeroList = _HeroList or {};
    for k, v in pairs(_HeroList) do
        if v then 
            for kk, vv in pairs(AddOnRolePlayingGame.EventList) do
                if vv and vv.Action and vv:HasTrigger(_Trigger) then 
                    vv:Action(v, _Trigger, ...);
                end
            end
        end
    end
end

-- Jobs --

---
-- Hebt das Level aller Helden eines Spielers an, wenn der Spieler die
-- benötigte Erfahrung erreicht. Dabei werden entweder Lernpunkte vergeben
-- oder automatisch Statuswerte erhöht.
--
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global.ExperienceLevelUpController()
    if not AddOnRolePlayingGame.Global.Data.UseLevelUpByPromotion then
        for i= 1, 8, 1 do
            local Current = AddOnRolePlayingGame.Global.Data.PlayerExperience[i];
            local Needed  = AddOnRolePlayingGame.Global.Data.BaseExperience;
            if Needed - Current <= 0 then
                AddOnRolePlayingGame.Global:LevelUpAction(i);
                AddOnRolePlayingGame.Global.Data.PlayerExperience[i] = Current - Needed;
                AddOnRolePlayingGame.Global.Data.BaseExperience = Needed + math.floor(Needed * 0.25);
            end
        end
    end
end

---
-- Kontrolliert den Kampf von Einheiten und verrechten den absoluten Schaden.
--
-- @param _Attacker Attacking Entity
-- @param _Defender Defending Entity
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global.EntityFightingController(_Attacker, _Defender)
    if IsExisting(_Attacker) and IsExisting(_Defender) and Logic.IsBuilding(_Attacker) == 0 and Logic.IsBuilding(_Defender) == 0 then
        -- Angreiferstatus
        local AttackerName = GiveEntityName(_Attacker);
        local AttackerUnit = AddOnRolePlayingGame.Unit:GetInstance(AttackerName);
        if AttackerUnit == nil then
            AttackerUnit = AddOnRolePlayingGame.Unit:New(AttackerName);
        end
        
        -- Verteidigerstatus
        local DefenderName = GiveEntityName(_Defender);
        local DefenderUnit = AddOnRolePlayingGame.Unit:GetInstance(DefenderName);
        if DefenderUnit == nil then
            DefenderUnit = AddOnRolePlayingGame.Unit:New(DefenderName);
        end
        
        -- Verwunde das Ziel
        local DefenderHero = AddOnRolePlayingGame.Hero:GetInstance(DefenderName);
        
        local Damage = DefenderUnit:CalculateEnduredDamage(AttackerUnit:GetDamage());
        API.HurtEntity(DefenderName, Damage, AttackerName);
        if DefenderHero ~= nil then
            if DefenderHero.Vulnerable then 
                DefenderHero:Hurt(Damage, AttackerName);
            end
        end
    end
end

---
-- Hebt das Level aller Helden eines Spielers an, wenn der Spieler
-- befördert wird. Dabei werden entweder Lernpunkte vergeben oder automatisch
-- Statuswerte erhöht.
--
-- @param _PlayerID ID des Spielers
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global.LevelUpController(_PlayerID)
    if AddOnRolePlayingGame.Global.Data.UseLevelUpByPromotion then
        AddOnRolePlayingGame.Global:LevelUpAction(_PlayerID);
    end
end

---
-- Wirt ausgeführt, nachdem ein Spielstand geladen wurde. Diese Funktion Stellt
-- alle nicht persistenten Änderungen wieder her.
--
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global.OnSaveGameLoaded()
    API.Bridge("AddOnRolePlayingGame.Local:CreateHotkeys()");
    API.Bridge("AddOnRolePlayingGame.Local:OverrideStringKeys()");
end

-- Events --

---
-- Trigger: Ein Entity wird durch ein anderes Entity zerstört.
-- @param _AttackedEntityID    Entity ID of defender
-- @param _AttackedPlayerID    Player ID of defender
-- @param _AttackingEntityID   Entity ID of attacker
-- @param _AttackingPlayerID   Player ID of attacker
-- @param _AttackedEntityType  Type of defender
-- @param _AttackingEntityType Type of attacker
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global.OnEntityKilledController(_AttackedEntityID, _AttackedPlayerID, _AttackingEntityID, _AttackingPlayerID, _AttackedEntityType, _AttackingEntityType)
    AddOnRolePlayingGame.Global:InvokeEvent(
        AddOnRolePlayingGame.HeroList,
        "Trigger_EntityKilled",
        _AttackedEntityID, _AttackedPlayerID, _AttackingEntityID, _AttackingPlayerID, _AttackedEntityType, _AttackingEntityType
    );
end

---
-- Trigger: Ein Entity wurd durch ein anderes verwundet.
-- @param _DefenderPlayerID  Player ID of defender
-- @param _DefenderName      Script name of defender
-- @param _AttackingPlayerID Player ID of attacker
-- @param _AttackerName      Script name of attacker
-- @param _Damage    
-- @within Private
-- @local        
--
function AddOnRolePlayingGame.Global.OnEntityHurtController(_DefenderPlayerID, _DefenderName, _AttackingPlayerID, _AttackerName, _Damage)
    AddOnRolePlayingGame.Global:InvokeEvent(
        AddOnRolePlayingGame.HeroList,
        "Trigger_EntityHurt",
        _DefenderPlayerID, _DefenderName, _AttackingPlayerID, _AttackerName, _Damage
    );
end

---
-- Trigger: Zahltag
-- @param _PlayerID                 Player ID
-- @param _TotalTaxAmountCollected  Total collected tax
-- @param _AdditionalTaxesByAbility Hero ability bonus
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global.OnTaxCollectionFinished(_PlayerID, _TotalTaxAmountCollected, _AdditionalTaxesByAbility)
    AddOnRolePlayingGame.Global:InvokeEvent(
        AddOnRolePlayingGame.Global:GetHeroes(_PlayerID),
        "Trigger_TaxCollectionFinished",
        _PlayerID, _TotalTaxAmountCollected, _AdditionalTaxesByAbility
    );
end

---
-- Trigger: Ein normales Fest ist beendet.
-- @param _PlayerID Player ID
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global.OnRegularFestivalEnded(_PlayerID)
    -- "Trigger_RegularFestivalEnded"
    AddOnRolePlayingGame.Global:InvokeEvent(
        AddOnRolePlayingGame.Global:GetHeroes(_PlayerID),
        "Trigger_RegularFestivalEnded",
        _PlayerID
    );
end

---
-- Trigger: Ein Monat ist zuende.
-- @param _LastMonth    Elapsed month
-- @param _CurrentMonth Started month
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global.OnEndOfMonth(_LastMonth, _CurrentMonth)
    AddOnRolePlayingGame.Global:InvokeEvent(
        AddOnRolePlayingGame.HeroList,
        "Trigger_EndOfMonth",
        _LastMonth, _CurrentMonth
    );
end

---
-- Trigger: Der Ausbau eines Gebäudes ist abgeschlossen.
-- @param _PlayerID        Player ID
-- @param _EntityID        Entity ID
-- @param _NewUpgradeLevel New upgrade level
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global.OnBuildingUpgradeFinished(_PlayerID, _EntityID, _NewUpgradeLevel)
    AddOnRolePlayingGame.Global:InvokeEvent(
        AddOnRolePlayingGame.Global:GetHeroes(_PlayerID),
        "Trigger_BuildingUpgradeFinished",
        _PlayerID, _EntityID, _NewUpgradeLevel
    );
end

---
-- Trigger: Der Bau eines Gebäudes ist abgeschlossen.
-- @param _PlayerID Player ID
-- @param _EntityID Entity ID
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global.OnBuildingConstructionComplete(_PlayerID, _EntityID)
    AddOnRolePlayingGame.Global:InvokeEvent(
        AddOnRolePlayingGame.Global:GetHeroes(_PlayerID),
        "Trigger_BuildingConstructionFinished",
        _PlayerID, _EntityID
    );
end

---
-- Trigger: Ein Geologe füllt eine Mine wieder auf.
-- @param _PlayerID    Player ID
-- @param _TargetID    Entity ID of mine
-- @param _GeologistID Entity ID of geologist
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global.OnGeologistRefill(_PlayerID, _TargetID, _GeologistID)
    AddOnRolePlayingGame.Global:InvokeEvent(
        AddOnRolePlayingGame.Global:GetHeroes(_PlayerID),
        "Trigger_GeologistRefill",
        _PlayerID, _TargetID, _GeologistID
    );
end

---
-- Trigger: Eine Predigt ist beendet.
-- @param _PlayerID    Player ID
-- @param _NumSettlers Number of settlers
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global.OnSermonFinished(_PlayerID, _NumSettlers)
    AddOnRolePlayingGame.Global:InvokeEvent(
        AddOnRolePlayingGame.Global:GetHeroes(_PlayerID),
        "Trigger_SermonFinished",
        _PlayerID, _NumSettlers
    );
end

---
-- Trigger: Eine Sekunde ist vergangen.
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global.OnEverySecond()
    AddOnRolePlayingGame.Global:InvokeEvent(
        AddOnRolePlayingGame.HeroList,
        "Trigger_EverySecond"
    );
end

-- local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im localen Skript.
--
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:Install()
    -- Event 
    Core:AppendFunction("GameCallback_Feedback_OnSermonFinished", self.OnSermonFinished);
    -- Interface
    self:CreateHotkeys();
    self:DeactivateAbilityBlabering();
    self:OverrideActiveAbility();
    self:OverrideStringKeys();
    self:OverrideKnightCommands();
end

---
-- Trigger: Eine Predigt ist beendet.
-- @param _PlayerID    Player ID
-- @param _NumSettlers Number of settlers
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local.OnSermonFinished(_PlayerID, _NumSettlers)
    API.Bridge("AddOnRolePlayingGame.Global.OnSermonFinished(" .._PlayerID.. ", " .._NumSettlers.. ")")
end


---
-- Zeigt die Inhalte des Inventars eines Helden an.
--
-- @param _Identifier  Name des Inventars
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:DisplayCharacter(_Identifier)
    if AddOnRolePlayingGame.HeroList[_Identifier] == nil then 
        return;
    end
    local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    local FormatString = "%s{cr}%s{cr}%s{cr}{cr}%s{cr}%s{cr}%s{cr}{cr}%s{cr}%s{cr}%s{cr}{cr}";
    
    local LabelStrength  = AddOnRolePlayingGame.Texts.Strength.Caption[Language];
    local LabelMagic     = AddOnRolePlayingGame.Texts.Magic.Caption[Language];
    local LabelEndurance = AddOnRolePlayingGame.Texts.Endurance.Caption[Language];
    
    local DescStrength  = AddOnRolePlayingGame.Texts.Strength.Description[Language];
    local DescMagic     = AddOnRolePlayingGame.Texts.Magic.Description[Language];
    local DescEndurance = AddOnRolePlayingGame.Texts.Endurance.Description[Language];
    
    local Strength = AddOnRolePlayingGame.HeroList[_Identifier].Strength;
    local StrengthStars = string.rep("*", (Strength > 49 and 50) or Strength+1);
    local Magic = AddOnRolePlayingGame.HeroList[_Identifier].Magic;
    local MagicStars = string.rep("*", (Magic > 49 and 50) or Magic+1);
    local Endurance = AddOnRolePlayingGame.HeroList[_Identifier].Endurance;
    local EnduranceStars = string.rep("*", (Endurance > 49 and 50) or Endurance+1);
    
    local ContentString = string.format(
        FormatString,
        LabelStrength,
        StrengthStars,
        DescStrength,
        LabelMagic,
        MagicStars,
        DescMagic,
        LabelEndurance,
        EnduranceStars,
        DescEndurance
    );
    
    -- Fenster anzeigen
    local Window = TextWindow:New();
    Window:SetCaption(AddOnRolePlayingGame.Texts.CharacterStatus.Caption);
    Window:SetContent(ContentString);
    Window:Show();
end

---
-- Zeigt die Inhalte des Inventars eines Helden an.
--
-- @param _Identifier     Name des Inventars
-- @param _FilterEquipped Equipment anzeigen
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:DisplayEffects(_Identifier, _FilterVices)
    if AddOnRolePlayingGame.HeroList[_Identifier] == nil then 
        return;
    end
    
    local EffectList = AddOnRolePlayingGame.HeroList[_Identifier].Virtues;
    if _FilterVices then
        EffectList = AddOnRolePlayingGame.HeroList[_Identifier].Vices;
    end
    
    local ContentString = "";
    for k, v in pairs(EffectList) do
        if v and AddOnRolePlayingGame.EventList[v] then
            local Caption = AddOnRolePlayingGame.EventList[v].Caption;
            local Description = AddOnRolePlayingGame.EventList[v].Description;
            if Caption and Description then
                ContentString = ContentString .. Caption .. "{cr}";
                ContentString = ContentString .. Description .. "{cr}{cr}";
            end
        end
    end
    
    -- Fenster anzeigen
    local function ToggleCallback(_Data)
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
        AddOnRolePlayingGame.Local:ToggleEffects(_Data.ScriptName, _Data.FilterVices);
    end
    local Key = (_FilterVices == true and "NegativeEffects") or "PositiveEffects";
    local Window = TextWindow:New();
    Window.FilterVices = not _FilterVices;
    Window.ScriptName = _Identifier;
    Window:SetCaption(AddOnRolePlayingGame.Texts[Key].Caption);
    Window:SetContent(ContentString);
    Window:SetButton(AddOnRolePlayingGame.Texts[Key].Button, ToggleCallback);
    Window:Show();
end

---
-- Zeigt die Inhalte des Inventars eines Helden an.
--
-- @param _Identifier     Name des Inventars
-- @param _FilterEquipped Equipment anzeigen
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:DisplayInventory(_Identifier, _FilterEquipped)
    if AddOnRolePlayingGame.InventoryList[_Identifier] == nil then 
        return;
    end
    
    -- Setze dargestellte Liste
    local ItemList = AddOnRolePlayingGame.InventoryList[_Identifier].Items;
    if _FilterEquipped then
        ItemList = AddOnRolePlayingGame.InventoryList[_Identifier].Equipped;
    end
    
    -- Ermittele Inhalte
    local DisplayedItems = {};
    for k, v in pairs(ItemList) do
        if v then 
            local Caption = AddOnRolePlayingGame.ItemList[k].Caption;
            local Description = AddOnRolePlayingGame.ItemList[k].Description;
            table.insert(DisplayedItems, {Caption, Description, v});
        end
    end
    
    -- Sortiere Inhalte
    local function sortFunc(_a, _b)
        return _a[1] < _b[1];
    end
    table.sort(DisplayedItems, sortFunc);
    
    -- Baue Fensterinhalt
    local ContentString = "";
    for i= 1, #DisplayedItems, 1 do
        if _FilterEquipped then
            local Line = "%s{cr}%s{cr}{cr}";
            ContentString = ContentString .. string.format(
                Line, DisplayedItems[i][1], DisplayedItems[i][2]
            );
        else
            local Line = "%s (%d){cr}%s{cr}{cr}";
            ContentString = ContentString .. string.format(
                Line, DisplayedItems[i][1], DisplayedItems[i][3], DisplayedItems[i][2]
            );
        end
    end

    -- Fenster anzeigen
    local function ToggleCallback(_Data)
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
        AddOnRolePlayingGame.Local:ToggleInventory(_Data.InventoryIdentifier, _Data.FilterEquipped);
    end
    local Key = (_FilterEquipped == true and "InventoryEquipment") or "InventoryBackpack";
    local Window = TextWindow:New();
    Window.FilterEquipped = not _FilterEquipped;
    Window.InventoryIdentifier = _Identifier;
    Window:SetCaption(AddOnRolePlayingGame.Texts[Key].Caption);
    Window:SetContent(ContentString);
    Window:SetButton(AddOnRolePlayingGame.Texts[Key].Button, ToggleCallback);
    Window:Show();
end

---
-- 
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:ToggleInventory(_Identifier, _FilterEquipped)
    _FilterEquipped = _FilterEquipped or false;
    AddOnRolePlayingGame.Local:DisplayInventory(_Identifier, _FilterEquipped);
end

---
-- 
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:ToggleEffects(_Identifier, _FilterVices)
    _FilterEquipped = _FilterEquipped or false;
    AddOnRolePlayingGame.Local:DisplayEffects(_Identifier, _FilterVices);
end

---
-- Überschreibt die KnightCommands, sodass sie für das Upgrade des Status 
-- verwendet werden kann.
--
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:OverrideKnightCommands()
    GameCallback_GUI_SelectionChanged_Orig_AddOnRolePlayingGame = GameCallback_GUI_SelectionChanged
    GameCallback_GUI_SelectionChanged = function(a, b)
        GameCallback_GUI_SelectionChanged_Orig_AddOnRolePlayingGame(a, b);
        XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignTopLeft/KnightCommands",1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/KnightCommands",1);
        local eIDs = {GUI.GetSelectedEntities()};
        
        if #eIDs == 1 then
            XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Strength.Mother, 1);
            XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Magic.Mother, 1);
            XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Endurance.Mother, 1);
        else
            XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Strength.Mother, 0);
            XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Magic.Mother, 0);
            XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Endurance.Mother, 0);
        end
    end
    
    Mission_SupportButtonClicked = function(_Idx)
        local EntityID = GUI.GetSelectedEntity();
        if EntityID == nil or EntityID == 0 then
            return;
        end
        API.Bridge("AddOnRolePlayingGame.Global:UpgradeHeroStatus(" .._Idx.. ", "..EntityID..")");
    end
    
    Mission_SupportUpdateTimer = function()
        local EntityID = GUI.GetSelectedEntity();
        if EntityID == nil or EntityID == 0 then
            return;
        end
        local ScriptName = Logic.GetEntityName(EntityID);
        if AddOnRolePlayingGame.HeroList[ScriptName] == nil then 
            return;
        end
        
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local LP = AddOnRolePlayingGame.HeroList[ScriptName].Learnpoints;
        
        local Costs = 999;
        if WidgetID == XGUIEng.GetWidgetID(AddOnRolePlayingGame.KnightCommands.Strength.Timer) then
            Costs = AddOnRolePlayingGame.HeroList[ScriptName].StrengthCosts or 1;
        elseif WidgetID == XGUIEng.GetWidgetID(AddOnRolePlayingGame.KnightCommands.Magic.Timer) then
            Costs = AddOnRolePlayingGame.HeroList[ScriptName].MagicCosts or 1;
        elseif WidgetID == XGUIEng.GetWidgetID(AddOnRolePlayingGame.KnightCommands.Endurance.Timer) then
            Costs = AddOnRolePlayingGame.HeroList[ScriptName].EndurenceCosts or 1;
        end
        
        XGUIEng.SetText(WidgetID, "{center}" ..Costs.. "/" ..LP);
    end
    
    Mission_SupportUpdateButton = function()
        local SelectedEntities = {GUI.GetSelectedEntities()};
        if #SelectedEntities ~= 1 or SelectedEntities[1] == 0 then
            return;
        end
        local x,y = GUI.GetEntityInfoScreenPosition(SelectedEntities[1]);
        local ScriptName = Logic.GetEntityName(SelectedEntities[1]);
        local Screensize = {GUI.GetScreenSize()};
        local Hero = AddOnRolePlayingGame.HeroList[ScriptName];
        if Hero == nil then 
            XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Strength.Mother,0);
            XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Magic.Mother,0);
            XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Endurance.Mother,0);
            return;
        end
        
        SetIcon(AddOnRolePlayingGame.KnightCommands.Strength.Button, {7,4});
        SetIcon(AddOnRolePlayingGame.KnightCommands.Magic.Button, {11, 2});
        SetIcon(AddOnRolePlayingGame.KnightCommands.Endurance.Button, {7,2});
        
        if x ~= 0 and y ~= 0 and x > -200 and y > -200 and x < (Screensize[1] + 50) and y < (Screensize[2] + 200) then
            local WidgetID = "/InGame/Root/Normal/AlignTopLeft/KnightCommands";
            XGUIEng.SetWidgetSize(WidgetID, 300, 200);
            local WidgetSize = {XGUIEng.GetWidgetScreenSize(WidgetID)};
            
            local relativeX = x - (WidgetSize[1] * 0.40);
            local relativeY = y - (130 * (Screensize[2]/1080));
            XGUIEng.SetWidgetScreenPosition(WidgetID, relativeX, relativeY);
            
            XGUIEng.SetWidgetPositionAndSize(AddOnRolePlayingGame.KnightCommands.Strength.Mother, 0, 20, 100, 100);
            XGUIEng.SetWidgetPositionAndSize(AddOnRolePlayingGame.KnightCommands.Magic.Mother, 80, 23, 100, 100);
            XGUIEng.SetWidgetPositionAndSize(AddOnRolePlayingGame.KnightCommands.Endurance.Mother, 160, 26, 100, 100);
            XGUIEng.DisableButton(AddOnRolePlayingGame.KnightCommands.Strength.Mother,0);
            XGUIEng.DisableButton(AddOnRolePlayingGame.KnightCommands.Magic.Mother,0);
            XGUIEng.DisableButton(AddOnRolePlayingGame.KnightCommands.Endurance.Mother,0);
            
            if Hero.Learnpoints < (AddOnRolePlayingGame.HeroList[ScriptName].StrengthCosts or 1) then
                XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Strength.Mother,0);
            else
                XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Strength.Mother,1);
            end
            
            if Hero.Learnpoints < (AddOnRolePlayingGame.HeroList[ScriptName].MagicCosts or 1) then
                XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Magic.Mother,0);
            else
                XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Magic.Mother,1);
            end
            
            if Hero.Learnpoints < (AddOnRolePlayingGame.HeroList[ScriptName].EndurenceCosts or 1) then
                XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Endurance.Mother,0);
            else
                XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Endurance.Mother,1);
            end
        else
            local WidgetID = "/InGame/Root/Normal/AlignTopLeft/KnightCommands";
            XGUIEng.SetWidgetScreenPosition(WidgetID, -1000, -1000);
        end
    end
end

---
-- Überschreibt die Textausgabe mit den eigenen Texten.
--
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:OverrideStringKeys()
    GetStringTableText_Orig_Orig_AddOnRolePlayingGame = XGUIEng.GetStringTableText;
    XGUIEng.GetStringTableText = function(_key)
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID = GUI.GetPlayerID();
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        
        local ScriptName = Logic.GetEntityName(SelectedID)
        local Hero = AddOnRolePlayingGame.HeroList[ScriptName];

        if Hero then 
            -- Strength upgrade
            if _key == "UI_ObjectNames/MissionSpecific_StartAttack" then
                return AddOnRolePlayingGame.Texts.UpgradeStrength[lang];
            end
            if _key == "UI_ObjectDescription/MissionSpecific_StartAttack" then
                return "";
            end
            
            -- Magic upgrade
            if _key == "UI_ObjectNames/MissionSpecific_Trebuchet" then
                return AddOnRolePlayingGame.Texts.UpgradeMagic[lang];
            end
            if _key == "UI_ObjectDescription/MissionSpecific_Trebuchet" then
                return "";
            end
            
            -- Endurance upgrade
            if _key == "UI_ObjectNames/MissionSpecific_Bless" then
                return AddOnRolePlayingGame.Texts.UpgradeEndurance[lang];
            end
            if _key == "UI_ObjectDescription/MissionSpecific_Bless" then
                return "";
            end
        end

        return GetStringTableText_Orig_Orig_AddOnRolePlayingGame(_key);
    end
end

---
-- Überschreibt die Sterung der aktiven Fähigkeit um eigene Fähigkeiten
-- auszulösen, falls vorhanden.
--
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:OverrideActiveAbility()
    GUI_Knight.StartAbilityClicked_Orig_AddOnRolePlayingGame = GUI_Knight.StartAbilityClicked;
    GUI_Knight.StartAbilityClicked = function(_Ability)
        local KnightID   = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();
        local KnightType = Logic.GetEntityType(KnightID);
        local KnightName = Logic.GetEntityName(KnightID);

        local HeroInstance = AddOnRolePlayingGame.HeroList[KnightName];
        if HeroInstance == nil or HeroInstance.Ability == nil then
            GUI_Knight.StartAbilityClicked_Orig_AddOnRolePlayingGame(_Ability);
            return;
        end
        
        -- Doppelklick vermeiden
        AddOnRolePlayingGame.HeroList[KnightName].ActionPoints = 0;
        
        -- Fähigkeit ausführen
        API.Bridge([[
            local AbilityInstance = AddOnRolePlayingGame.Ability:GetInstance("]] ..HeroInstance.Ability.. [[")
            if AbilityInstance then
                AbilityInstance:Callback("]] ..KnightName.. [[")
            end
        ]]);
    end

    GUI_Knight.StartAbilityMouseOver_Orig_AddOnRolePlayingGame = GUI_Knight.StartAbilityMouseOver;
    GUI_Knight.StartAbilityMouseOver = function()
        local KnightID   = GUI.GetSelectedEntity();
        local KnightType = Logic.GetEntityType(KnightID);
        local KnightName = Logic.GetEntityName(KnightID);

        local HeroInstance = AddOnRolePlayingGame.HeroList[KnightName];
        if HeroInstance == nil or HeroInstance.Ability == nil then
            GUI_Knight.StartAbilityMouseOver_Orig_AddOnRolePlayingGame();
            return;
        end
        
        local Caption     = AddOnRolePlayingGame.AbilityList[HeroInstance.Ability].Caption;
        local Description = AddOnRolePlayingGame.AbilityList[HeroInstance.Ability].Description;
        UserSetTextNormal(Caption, Description);
    end

    GUI_Knight.StartAbilityUpdate_Orig_AddOnRolePlayingGame = GUI_Knight.StartAbilityUpdate;
    GUI_Knight.StartAbilityUpdate = function()
        local WidgetID   = "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/StartAbility";
        local KnightID   = GUI.GetSelectedEntity();
        local KnightType = Logic.GetEntityType(KnightID);
        local KnightName = Logic.GetEntityName(KnightID);

        local HeroInstance = AddOnRolePlayingGame.HeroList[KnightName];
        if HeroInstance == nil or HeroInstance.Ability == nil then
            GUI_Knight.StartAbilityUpdate_Orig_AddOnRolePlayingGame();
            return;
        end
        
        local Icon = AddOnRolePlayingGame.AbilityList[HeroInstance.Ability].Icon;
        local RechargeTime = HeroInstance.RechargeTime;
        local ActionPoints = HeroInstance.ActionPoints;
    
        -- Icon
        if type(Icon) == "table" then
            if Icon[3] and type(Icon[3]) == "string" then
                API.SetIcon(WidgetID, Icon, nil, Icon[3]);
            else
                SetIcon(WidgetID, Icon);
            end
        else
            API.SetTexture(WidgetID, Icon);
        end
    
        -- Enable/Disable
        if ActionPoints < RechargeTime or HeroInstance.AbilityDisabled then
            XGUIEng.DisableButton(WidgetID, 1);
        else
            XGUIEng.DisableButton(WidgetID, 0);
        end
    end

    GUI_Knight.AbilityProgressUpdate_Orig_AddOnRolePlayingGame = GUI_Knight.AbilityProgressUpdate;
    GUI_Knight.AbilityProgressUpdate = function()
        local WidgetID   = XGUIEng.GetCurrentWidgetID();
        local PlayerID   = GUI.GetPlayerID();
        local KnightID   = GUI.GetSelectedEntity();
        local KnightName = Logic.GetEntityName(KnightID);

        local HeroInstance = AddOnRolePlayingGame.HeroList[KnightName];
        if HeroInstance == nil or HeroInstance.Ability == nil then
            GUI_Knight.AbilityProgressUpdate_Orig_AddOnRolePlayingGame(_Ability);
            return;
        end

        local TotalRechargeTime = HeroInstance.RechargeTime or 6 * 60;
        local ActionPoints = HeroInstance.ActionPoints;
        local TimeAlreadyCharged = ActionPoints or TotalRechargeTime;
        
        -- Fix for over 100% charge
        TimeAlreadyCharged = (TimeAlreadyCharged > TotalRechargeTime and TotalRechargeTime) or TimeAlreadyCharged;
        
        if TimeAlreadyCharged == TotalRechargeTime then
            XGUIEng.SetMaterialColor(WidgetID, 0, 255, 255, 255, 0);
        else
            XGUIEng.SetMaterialColor(WidgetID, 0, 255, 255, 255, 150);
            local Progress = math.floor((TimeAlreadyCharged / TotalRechargeTime) * 100);
            XGUIEng.SetProgressBarValues(WidgetID, Progress + 10, 110);
        end
    end
end

---
-- Deaktiviert die Information über aktive und passive Fähigkeit der Helden.
--
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:DeactivateAbilityBlabering()
    StartKnightVoiceForActionSpecialAbility = function(_KnightType, _NoPriority)
    end
    StartKnightVoiceForPermanentSpecialAbility = function(_KnightType)
    end
end

---
-- 
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:CreateHotkeys()
    -- Inventar anzeigen
    Input.KeyBindDown(Keys.I, "local Sel = GUI.GetSelectedEntity() or 0; API.Bridge('AddOnRolePlayingGame.Global:ToggleInventory(' ..Sel.. ')');", 2, false);
    -- Effekte anzeigen
    Input.KeyBindDown(Keys.K, "local Sel = GUI.GetSelectedEntity() or 0; API.Bridge('AddOnRolePlayingGame.Global:ToggleEffects(' ..Sel.. ')');", 2, false);
    -- Charackter anzeigen
    Input.KeyBindDown(Keys.C, "local Sel = Logic.GetEntityName(GUI.GetSelectedEntity()); AddOnRolePlayingGame.Local:DisplayCharacter(Sel);", 2, false);
end

---
-- 
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:DescribeHotkeys()
    if AddOnRolePlayingGame.Local.Data.HotkeyDescribed == true then
        return;
    end
    
    -- Inventar anzeigen
    API.AddHotKey({de = "I", en = "I"}, {de = "Inventar öffnen", en = "Open inventory"});
    -- Effecte anzeigen
    API.AddHotKey({de = "C", en = "C"}, {de = "Charakter anzeigen", en = "Display character"});
    -- Effecte anzeigen
    API.AddHotKey({de = "K", en = "K"}, {de = "Effekte anzeigen", en = "Display effects"});
end

-- -------------------------------------------------------------------------- --
-- Models                                                                     --
-- -------------------------------------------------------------------------- --

-- Diese Models werden

-- Unit ------------------------------------------------------------------------

AddOnRolePlayingGame.UnitList = {};

AddOnRolePlayingGame.Unit = {};

---
-- Erzeugt eine neue Instanz einer Einheit.
-- @within AddOnRolePlayingGame.Unit
--
function AddOnRolePlayingGame.Unit:New(_ScriptName)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Unit);

    local unit = API.InstanceTable(self);
    unit.ScriptName   = _ScriptName;
    unit.BaseDamage   = 15;
    unit.Strength     = 0;
    unit.Magic        = 0;
    unit.Endurance    = 0;
    unit.Buffs        = {};

    AddOnRolePlayingGame.UnitList[_ScriptName] = unit;

    if not GUI then
        StartSimpleJobEx(self.UpdateBuffs, _ScriptName);
    end
    return unit;
end

---
-- Gibt die Instanz der Einheit zurück, die den Skriptnamen trägt.
-- @param _ScriptName Skriptname der Einheit
-- @return table: Instanz der Einheit
-- @within AddOnRolePlayingGame.Unit
--
function AddOnRolePlayingGame.Unit:GetInstance(_ScriptName)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Unit);
    return AddOnRolePlayingGame.UnitList[_ScriptName];
end

---
-- Entfernt die Einheit aus globalen und lokalen Skript.
-- @within AddOnRolePlayingGame.Unit
-- @local
--
function AddOnRolePlayingGame.Unit:Dispose()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Unit);
    AddOnRolePlayingGame.UnitList[self.Identifier] = nil;
end

---
-- Gibt die Kraft der Einheit zurück.
-- @return number: Kraft
-- @within AddOnRolePlayingGame.Unit
--
function AddOnRolePlayingGame.Unit:GetStrength()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Unit);

    local Strength = self.Strength;
    for k, v in pairs(self.Buffs) do
        if v then
            Strength = Strength + v[2];
        end
    end
    return Strength;
end

---
-- Gibt die magische Kraft der Einheit zurück.
-- @return number: Magie
-- @within AddOnRolePlayingGame.Unit
--
function AddOnRolePlayingGame.Unit:GetMagic()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Unit);

    local Magic = self.Magic;
    for k, v in pairs(self.Buffs) do
        if v then
            Magic = Magic + v[3];
        end
    end
    return Magic;
end

---
-- Gibt die Widerstandskraft der Einheit zurück.
-- @return number: Wiederstandskraft
-- @within AddOnRolePlayingGame.Unit
--
function AddOnRolePlayingGame.Unit:GetEndurance()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Unit);

    local Endurance = self.Endurance;
    for k, v in pairs(self.Buffs) do
        if v then
            Endurance = Endurance + v[4];
        end
    end
    return Endurance;
end

---
-- Gibt den Schaden zurück, den die Einheit verursacht.
-- @return number: Schaden
-- @within AddOnRolePlayingGame.Unit
--
function AddOnRolePlayingGame.Unit:GetDamage()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Unit);
    return self.BaseDamage + (self:GetStrength() * (self.BaseDamage * 0.2));
end

---
-- Gibt den tatsächlich erlittenen physischen Schaden zurück.
--
-- Der tatsächlich erlittene physische Schaden ist die Menge an Schaden, die
-- übrig bleibt, wenn der Basischaden mit der Widerstandskraft der Unit
-- verrechnet wird.
--
-- @param _Damage Basisschaden
-- @return number: Schaden
-- @within AddOnRolePlayingGame.Unit
--
function AddOnRolePlayingGame.Unit:CalculateEnduredDamage(_Damage)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Unit);
    for i= 1, self:GetEndurance(), 1 do
        _Damage = _Damage - (0.1 * _Damage);
    end
    return _Damage;
end

---
-- Gibt den tatsächlich erlittenen magischen Schaden zurück.
--
-- Der tatsächlich erlittene Magieschaden ist die Menge an Schaden, die übrig
-- bleibt, wenn der Basischaden mit der Magie der Unit verrechnet wird.
--
-- @param _Damage Basisschaden
-- @return number: Schaden
-- @within AddOnRolePlayingGame.Unit
--
function AddOnRolePlayingGame.Unit:CalculateEnduredMagicDamage(_Damage)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Unit);
    for i= 1, self:GetMagic(), 1 do
        _Damage = _Damage - (0.1 * _Damage);
    end
    return _Damage;
end

---
-- Fügt der Einheit einen Buff hinzu.
--
-- Ist ein Buff schon aktiv, dann wird die Dauer des Effekts um die Dauer des 
-- neuen Buffs verlängert. Buffs sind entweder n Sekunden aktiv oder haben
-- eine unbegrenzte Dauer. In diesem Fall wird die Duration -1 gesetzt.
--
-- Buffs haben folgendes Format:
-- <pre><code>
-- {DURATION, STRENGTH, MAGIC, ENDURANCE}
-- </pre></code>
--
-- @param _Buff Buff-Table
-- @return self
-- @within AddOnRolePlayingGame.Unit
--
function AddOnRolePlayingGame.Unit:BuffAdd(_BuffName, _Buff)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Unit);
    if not self.Buffs[_BuffName] then
        self.Buffs[_BuffName] = _Buff;
    else 
        if self.Buffs[_BuffName][1] > 0 then 
            self.Buffs[_BuffName][1] = self.Buffs[_BuffName][1] + _Buff[1];
        end
    end
    return self;
end

---
-- Entfernt alle Buffs mit dem angegebenen Bezeichner.
--
-- @param _BuffName Name des Buffs
-- @return self
-- @within AddOnRolePlayingGame.Unit
--
function AddOnRolePlayingGame.Unit:BuffRemove(_BuffName)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Unit);
    self.Buffs[_BuffName] = nil;
    return self;
end

---
-- Aktualisiert die Buffs einer Einheit. Buffs deren Laufzeit abgelaufen ist,
-- werden von der Einheit entfernt.
-- @within AddOnRolePlayingGame.Unit
-- @local
--
function AddOnRolePlayingGame.Unit.UpdateBuffs(_ScriptName)
    if AddOnRolePlayingGame.Unit[_ScriptName] == nil then
        return true;
    end
    for k, v in pairs(AddOnRolePlayingGame.Unit[_ScriptName].Buffs) do
        if v and v[1] > 0 then
            v[1] = v[1] -1;
            if v[1] == 0 then
                AddOnRolePlayingGame.Unit[_ScriptName].Buffs[k] = nil;
            end
        end
    end
end

-- Hero ------------------------------------------------------------------------

-- Das Model für einen RPG-Helden. Im Hero Model führen alle Stricke zusammen.

AddOnRolePlayingGame.HeroList = {};

AddOnRolePlayingGame.Hero = {};

---
-- Erzeugt eine neue Instanz eines Helden.
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:New(_ScriptName)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Hero);
    
    -- Hotkeys erst mit ersten Helden eintragen.
    API.Bridge("AddOnRolePlayingGame.Local:DescribeHotkeys()");

    local hero = API.InstanceTable(self, {});
    hero.Unit         = AddOnRolePlayingGame.Unit:New(_ScriptName);
    hero.ScriptName   = _ScriptName;
    hero.Ability      = nil;
    hero.Inventory    = nil;
    hero.Level        = 0;
    hero.Learnpoints  = 0;
    hero.Health       = 1000;
    hero.MaxHealth    = 1000;
    hero.ActionPoints = 4*60;
    hero.Caption      = nil;
    hero.Description  = nil;
    hero.Vulnerable   = true;
    
    -- Equipment
    hero.Armor        = nil;
    hero.Jewellery    = nil;
    hero.Weapon       = nil;
    
    -- Events
    hero.Vices        = {};
    hero.Virtues      = {};
    
    -- Basisschaden setzen
    hero.Unit.BaseDamage = 25;
    
    API.Bridge([[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["]         = {}
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Vices   = {}
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Virtues = {}
    ]]);
    AddOnRolePlayingGame.HeroList[_ScriptName] = hero;
    if not GUI then
        StartSimpleJobEx(self.UpdateStatus, _ScriptName);
    end
    return hero;
end

---
-- Gibt die Instanz des Helden zurück, der den Skriptnamen trägt.
-- @param _ScriptName Skriptname des Helden
-- @return table: Instanz des Helden
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:GetInstance(_ScriptName)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Hero);
    return AddOnRolePlayingGame.HeroList[_ScriptName];
end

---
-- Entfernt den Helden aus globalen und lokalen Skript.
-- @within AddOnRolePlayingGame.Hero
-- @local
--
function AddOnRolePlayingGame.Hero:Dispose()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    self.Unit:Dispose();
    API.Bridge("AddOnRolePlayingGame.HeroList['" ..self.Identifier.. "'] = nil");
    AddOnRolePlayingGame.HeroList[self.Identifier] = nil;
end

---
-- Aktiviert oder deaktiviert eine Tugend.
-- @param _EventName Name des Event
-- @param _Flag      Active Flag
-- @return self
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:ActivateVirtue(_EventName, _Flag)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    if AddOnRolePlayingGame.Event:GetInstance(_EventName) then
        self.Virtues[_EventName] = _Flag == true;
    end
    
    -- Update in local script
    local VirtuesString = "";
    for k, v in pairs(self.Virtues) do
        if v then VirtuesString = VirtuesString .. "'" .. k .. "', "; end
    end
    local CommandString = "AddOnRolePlayingGame.HeroList['%s'].Virtues = {%s}";
    API.Bridge(string.format(CommandString, self.ScriptName, VirtuesString));
    return self;
end

---
-- Aktiviert oder deaktiviert ein Laster.
-- @param _EventName Name des Event
-- @param _Flag      Active Flag
-- @return self
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:ActivateVice(_EventName, _Flag)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    if AddOnRolePlayingGame.Event:GetInstance(_EventName) then
        self.Vices[_EventName] = _Flag == true;
    end
    
    -- Update in local script
    local VicesString = "";
    for k, v in pairs(self.Vices) do
        if v then VicesString = VicesString .. "'" .. k .. "', "; end
    end
    local CommandString = "AddOnRolePlayingGame.HeroList['%s'].Vices = {%s}";
    API.Bridge(string.format(CommandString, self.ScriptName, VicesString));
    return self;
end

---
-- Macht einen Helden verwundbar oder unverwundbar.
-- @param _Flag Unverwundbar-Flag
-- @return self
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:SetVulnerable(_Flag)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    self.Vulnerable = _Flag == true;
    return self
end

---
-- Verwundet den Helden um die angegebene Menge.
-- @param _Amount       Menge an Gesundheit
-- @param _AttackerName (Optional) Name des Verursachers
-- @return self
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:Hurt(_Amount, _AttackerName)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    self.Health = self.Health - _Amount;
    AddOnRolePlayingGame.Global:InvokeEvent({self}, "Trigger_DamageSustained", _Amount, _AttackerName);
    if self.Health < 0 then 
        self.Health = 0;
    end
    return self
end

---
-- Heilt den Helden um die angegebene Menge.
-- @param _Amount     Menge an Gesundheit
-- @param _HealerName Name des Heilers
-- @return self
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:Heal(_Amount, _HealerName)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    self.Health = self.Health + _Amount;
    AddOnRolePlayingGame.Global:InvokeEvent({self}, "Trigger_HealthRegenerated", _Amount, _HealerName);
    if self.Health > self.MaxHealth then 
        self.Health = self.MaxHealth;
    end
    return self
end

---
-- Legt einen Ausrüstungsgegenstand als Rüstung an.
--
-- Ist bereits eine Rüstung angelegt, wird diese zuvor abgelegt.
--
-- @param _ItemType Ausrüstungsgegenstand
-- @return boolean: Rüstung angelegt
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:EquipArmor(_ItemType)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    
    if self.Inventory ~= nil then
        if self.Armor then
            self.Inventory:Unequip(self.Armor);
        end
        
        local Item = AddOnRolePlayingGame.ItemList[_ItemType];
        if Item and Item:IsInCategory(AddOnRolePlayingGame.ItemCategories.Armor) then
            self.Armor = _ItemType;
            if self.Armor then
                return self.Inventory:Equip(self.Armor);
            end
        end
    end
    return false;
end

---
-- Legt einen Ausrüstungsgegenstand als Waffe an.
--
-- Ist bereits eine Waffe angelegt, wird diese zuvor abgelegt.
--
-- @param _ItemType Ausrüstungsgegenstand
-- @return boolean: Waffe angelegt
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:EquipWeapon(_ItemType)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    
    if self.Inventory ~= nil then
        if self.Weapon then
            self.Inventory:Unequip(self.Weapon);
        end
        local Item = AddOnRolePlayingGame.ItemList[_ItemType];
        if Item and Item:IsInCategory(AddOnRolePlayingGame.ItemCategories.Weapon) then
            self.Weapon = _ItemType;
            if self.Weapon then
                return self.Inventory:Equip(self.Weapon);
            end
        end
    end
    return false;
end

---
-- Legt einen Ausrüstungsgegenstand als Schmuck an.
--
-- Ist bereits Schmuck angelegt, wird dieser zuvor abgelegt.
--
-- @param _ItemType Ausrüstungsgegenstand
-- @return boolean: Schmuck angelegt
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:EquipJewellery(_ItemType)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    
    if self.Inventory ~= nil then
        if self.Jewellery then
            self.Inventory:Unequip(self.Jewellery);
        end
        local Item = AddOnRolePlayingGame.ItemList[_ItemType];
        if Item and Item:IsInCategory(AddOnRolePlayingGame.ItemCategories.Jewellery) then
            self.Jewellery = _ItemType;
            if self.Jewellery then
                return self.Inventory:Equip(self.Jewellery);
            end
        end
    end
    return false;
end

---
-- Erhöht das Level des Helden. Es kann entweder automatisch gelevelt werdern.
-- In diesem Fall werden die Statuswerte automatisch erhöht. Andernfalls werden
-- Lernpunkte gutgeschrieben.
-- @param _LP        Menge an Lernpunkten
-- @param _AutoLevel Lernpunkte automatisch verwenden
-- @return self
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:LevelUp(_LP, _AutoLevel)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    if _AutoLevel == true then
        for i=1, _LP, 1 do
            local RandomStat = math.random(1, 3);
            if RandomStat == 1 then
                self.Unit.Strength = self.Unit.Strength +1;
            elseif RandomStat == 2 then
                self.Unit.Magic = self.Unit.Magic +1;
            else
                self.Unit.Endurance = self.Unit.Endurance +1;
            end
        end
    else
        self.Learnpoints = self.Learnpoints + _LP;
    end
    self.Level = self.Level +1;
    return self;
end

---
-- Setzt den im 2D-Interface angezeigten Namen des Helden.
-- @param _Text Name des Helden
-- @return self
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:SetCaption(_Text)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    self.Caption = (type(_Text) == "table" and _Text[Language]) or _Text;
    API.Bridge([[
        AddOnRolePlayingGame.HeroList["]] ..self.ScriptName.. [["].Caption  = "]] ..self.Caption.. [["
    ]]);
    return self;
end

---
-- Setzt die im 2D-Interface angezeigte Beschreibung des Helden.
-- @param _Text Beschreibung des Helden
-- @return self
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:SetDescription(_Text)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    self.Description = (type(_Text) == "table" and _Text[Language]) or _Text;
    API.Bridge([[
        AddOnRolePlayingGame.HeroList["]] ..self.ScriptName.. [["].Description  = "]] ..self.Description.. [["
    ]]);
    return self;
end

---
-- Gibt die Menge an Aktionspunkten zurück, die pro Sekunde aufgeladen werden.
-- @return number: Action Points
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:GetAbilityRecharge()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    if self.Ability then
        return (self.Unit:GetMagic() * 0.2) +1;
    end
    return 1;
end

---
-- Gibt die Regeneration der Gesundheit pro Sekunde zurück.
-- @return number: Regenerationsrate
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:GetRegeneration()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    return (self.Unit:GetEndurance() * 0.2) +5;
end

---
-- Aktualisiert Gesundheit und Aktionspunkte des Helden. Es werden einige
-- Werte ins lokale Skript geschrieben.
-- @within AddOnRolePlayingGame.Hero
-- @local
--
function AddOnRolePlayingGame.Hero.UpdateStatus(_ScriptName)
    local Hero = AddOnRolePlayingGame.Hero:GetInstance(_ScriptName);
    if Hero == nil then
        return true;
    end

    API.Bridge([[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Learnpoints       = ]] ..AddOnRolePlayingGame.HeroList[_ScriptName].Learnpoints.. [[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Strength          = ]] ..AddOnRolePlayingGame.HeroList[_ScriptName].Unit.Strength.. [[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].StrengthCosts     = ]] ..(AddOnRolePlayingGame.HeroList[_ScriptName].StrengthCosts or 1).. [[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Magic             = ]] ..AddOnRolePlayingGame.HeroList[_ScriptName].Unit.Magic.. [[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].MagicCosts        = ]] ..(AddOnRolePlayingGame.HeroList[_ScriptName].MagicCosts or 1).. [[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Endurance         = ]] ..AddOnRolePlayingGame.HeroList[_ScriptName].Unit.Endurance.. [[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].EnduranceCosts    = ]] ..(AddOnRolePlayingGame.HeroList[_ScriptName].EnduranceCosts or 1).. [[
    ]]);

    local EntityID = GetID(_ScriptName);
    if EntityID ~= nil and EntityID ~= 0 then
        if Logic.KnightGetResurrectionProgress(EntityID) ~= 1 then
            AddOnRolePlayingGame.HeroList[_ScriptName].Health = Hero.MaxHealth;
            if Hero.Ability then
                AddOnRolePlayingGame.HeroList[_ScriptName].ActionPoints = Hero.Ability.RechargeTime;
            end
        else
            -- Aktualisiere Gesundheit
            if Hero.Health < Hero.MaxHealth then
                Hero:Heal(Hero:GetRegeneration(), nil);
            end
            
            MakeVulnerable(_ScriptName);
            local Health = (Hero.Health / Hero.MaxHealth) * 100;
            SetHealth(_ScriptName, Health);
            MakeInvulnerable(_ScriptName);

            -- Aktualisiere Aktionspunkte
            if Hero.Ability then
                API.Bridge([[
                    AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Ability = "]] ..Hero.Ability.Identifier.. [["
                    AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].ActionPoints = ]] ..AddOnRolePlayingGame.HeroList[_ScriptName].ActionPoints.. [[
                    AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].RechargeTime = ]] ..AddOnRolePlayingGame.HeroList[_ScriptName].Ability.RechargeTime.. [[
                ]]);
                if Hero.ActionPoints < Hero.Ability.RechargeTime then
                    local ActionPoints = Hero.ActionPoints + Hero:GetAbilityRecharge();
                    ActionPoints = (ActionPoints > Hero.Ability.RechargeTime and Hero.Ability.RechargeTime) or ActionPoints;
                    ActionPoints = (ActionPoints < 0 and 0) or ActionPoints;
                    AddOnRolePlayingGame.HeroList[_ScriptName].ActionPoints = ActionPoints;
                    
                    AddOnRolePlayingGame.Global:InvokeEvent({Hero}, "Trigger_ActionPointsRegenerated", Hero:GetAbilityRecharge());
                end
            else
                API.Bridge([[
                    AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Ability = nil
                ]]);
            end
        end
    end
end

-- Ability ---------------------------------------------------------------------

-- Model einer selbst definierten Fähigkeit für einen Helden.

AddOnRolePlayingGame.AbilityList = {};

AddOnRolePlayingGame.Ability = {};

---
-- Erzeugt eine neue Instanz einer Fähigkeit
-- @param _Identifier Name der Fähigkeit
-- @return table: Instanz
-- @within AddOnRolePlayingGame.Ability
--
function AddOnRolePlayingGame.Ability:New(_Identifier)
    assert(self == AddOnRolePlayingGame.Ability);

    local ability = API.InstanceTable(self);
    ability.Identifier   = _Identifier;
    ability.Icon         = nil;
    ability.Description  = nil;
    ability.Caption      = nil;
    ability.Condition    = nil;
    ability.Action       = nil;
    ability.RechargeTime = 4*60;

    AddOnRolePlayingGame.AbilityList[_Identifier] = ability;
    API.Bridge([[
        AddOnRolePlayingGame.AbilityList["]] .._Identifier.. [["] = {}
    ]]);
    return ability;
end

---
-- Gibt die Instanz der Fähigkeit mit dem Identifier zurück.
-- @param _Identifier Name der Fähigkeit
-- @return table: Instanz der Fähigkeit
-- @within AddOnRolePlayingGame.Ability
--
function AddOnRolePlayingGame.Ability:GetInstance(_Identifier)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Ability);
    return AddOnRolePlayingGame.AbilityList[_Identifier];
end

---
-- Entfernt die Fähigkeit aus globalen und lokalen Skript.
-- @within AddOnRolePlayingGame.Ability
-- @local
--
function AddOnRolePlayingGame.Ability:Dispose()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Ability);
    API.Bridge("AddOnRolePlayingGame.AbilityList['" ..self.Identifier.. "'] = nil");
    AddOnRolePlayingGame.AbilityList[self.Identifier] = nil;
end

---
-- Führt die Fähigkeit für den übergebenen Helden aus.
-- @param _HeroName Skriptname des Helden
-- @return self
-- @within AddOnRolePlayingGame.Ability
--
function AddOnRolePlayingGame.Ability:Callback(_HeroName)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Ability);
    local Hero = AddOnRolePlayingGame.HeroList[_HeroName];
    if Hero and self.Action and self.Condition then
        if not self:Condition(Hero) then
            API.Message(AddOnRolePlayingGame.Texts.ErrorAbility);
            return;
        end
        Hero.ActionPoints = 0;
        self:Action(Hero);
        AddOnRolePlayingGame.Global:InvokeEvent({Hero}, "Trigger_AbilityStarted", self);
    end
    return self;
end

---
-- Setzt das Icon der Fähigkeit. Das Icon kann eine interne oder externe
-- Grafik sein.
-- @param _Icon Icon
-- @return self
-- @within AddOnRolePlayingGame.Ability
--
function AddOnRolePlayingGame.Ability:SetIcon(_Icon)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Ability);
    local Icon;
    if type(_Icon) == "table" then
        _Icon[3] = _Icon[3] or 0;
        local a = (type(_Icon[3]) == "string" and "'" .._Icon[3].. "'") or _Icon[3];
        Icon = "{" .._Icon[1].. ", " .._Icon[2].. ", " ..a.. "}";
    else
        Icon = "'" .._Icon .. "'";
    end

    API.Bridge([[
        AddOnRolePlayingGame.AbilityList["]] ..self.Identifier.. [["].Icon = ]] ..Icon.. [[
    ]]);
    return self;
end

---
-- Setzt den im 2D-Interface angezeigten Namen der Fähigkeit.
-- @param _Text Name der Fähigkeit
-- @return self
-- @within AddOnRolePlayingGame.Ability
--
function AddOnRolePlayingGame.Ability:SetCaption(_Text)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Ability);
    local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    self.Caption = (type(_Text) == "table" and _Text[Language]) or _Text;
    API.Bridge([[
        AddOnRolePlayingGame.AbilityList["]] ..self.Identifier.. [["].Caption  = "]] ..self.Caption.. [["
    ]]);
    return self;
end

---
-- Setzt die im 2D-Interface angezeigte Beschreibung der Fähigkeit.
-- @param _Text Beschreibung der FäFähigkeit
-- @return self
-- @within AddOnRolePlayingGame.Ability
--
function AddOnRolePlayingGame.Ability:SetDescription(_Text)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Ability);
    local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    self.Description = (type(_Text) == "table" and _Text[Language]) or _Text;
    API.Bridge([[
        AddOnRolePlayingGame.AbilityList["]] ..self.Identifier.. [["].Description  = "]] ..self.Description.. [["
    ]]);
    return self;
end

-- Inventory -------------------------------------------------------------------

-- Ein Inventar ist ein Container, in dem sich die Gegenstände befinden, die 
-- ein Held sein eigen nennt. Ein Inventar hat immer einen Besitzer, eine 
-- Referenz auf den Helden.

AddOnRolePlayingGame.InventoryList = {};

AddOnRolePlayingGame.Inventory = {};

---
-- Erzeugt eine neue Instanz eines Items.
-- @param _Identifier Name des Item
-- @param _Owner      Referenz auf den Helden
-- @return table: Instanz
-- @within AddOnRolePlayingGame.Inventory
--
function AddOnRolePlayingGame.Inventory:New(_Identifier, _Owner)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Inventory);

    local inventory = API.InstanceTable(self);
    inventory.Owner        = _Owner;
    inventory.Identifier   = _Identifier;
    inventory.Items        = {};
    inventory.Equipped     = {};

    AddOnRolePlayingGame.InventoryList[_Identifier] = inventory;
    API.Bridge([[
        AddOnRolePlayingGame.InventoryList["]] .._Identifier.. [["]          = {}
        AddOnRolePlayingGame.InventoryList["]] .._Identifier.. [["].Items    = {}
        AddOnRolePlayingGame.InventoryList["]] .._Identifier.. [["].Equipped = {}
    ]]);
    return inventory;
end

---
-- Gibt die Instanz des Inventars mit dem Identifier zurück.
-- @param _Identifier Name des Inventory
-- @return table: Instanz des Inventory
-- @within AddOnRolePlayingGame.Inventory
--
function AddOnRolePlayingGame.Inventory:GetInstance(_Identifier)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Inventory);
    return AddOnRolePlayingGame.InventoryList[_Identifier];
end

---
-- Entfernt das Inventar aus globalen und lokalen Skript.
-- @within AddOnRolePlayingGame.Inventory
-- @local
--
function AddOnRolePlayingGame.Inventory:Dispose()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Inventory);
    API.Bridge("AddOnRolePlayingGame.InventoryList['" ..self.Identifier.. "'] = nil");
    AddOnRolePlayingGame.InventoryList[self.Identifier] = nil;
end

---
-- Gibt die Inhalte des Inventars am Bildschirm aus.
-- @return self
-- @within AddOnRolePlayingGame.Inventory
-- @local
--
function AddOnRolePlayingGame.Inventory:Dump()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Inventory);
    
    ListOfItems = "Item types of " ..self.Identifier.. ":{cr}";
    for k, v in pairs(self.Items) do
        if v and v > 0 then 
            ListOfItems = ListOfItems .. k .. " (" ..v.. "), ";
        end
    end
    API.Note(ListOfItems);
    return self;
end

---
-- Legt einen Gegenstand als Ausrüstung an.
-- @param _ItemType Typ des Item
-- @return boolean: Erfolgreich angelegt
-- @within AddOnRolePlayingGame.Inventory
--
function AddOnRolePlayingGame.Inventory:Equip(_ItemType)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Inventory);
    local Item = AddOnRolePlayingGame.ItemList[_ItemType];
    if Item and self.Items[_ItemType] > 0 and not self.Equipped[_ItemType] then
        if Item:IsInCategory(AddOnRolePlayingGame.ItemCategories.Equipment) then
            self:Remove(_ItemType, 1);
            API.Bridge([[
                AddOnRolePlayingGame.InventoryList["]] ..self.Identifier.. [["].Equipped["]] .._ItemType.. [["] = true
            ]]);
            
            self.Equipped[_ItemType] = true;
            if Item.OnEquipped then
                Item:OnEquipped(self.Owner);
            end
            return true;
        end
    end
    return false;
end

---
-- Legt einen Gegenstand ab, der als Ausrüstung angelegt ist.
-- @param _ItemType Typ des Item
-- @return boolean: Erfolgreich abgelegt
-- @within AddOnRolePlayingGame.Inventory
--
function AddOnRolePlayingGame.Inventory:Unequip(_ItemType)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Inventory);
    local Item = AddOnRolePlayingGame.ItemList[_ItemType];
    if self.Equipped[_ItemType] then
        self:Insert(_ItemType, 1);
        API.Bridge([[
            AddOnRolePlayingGame.InventoryList["]] ..self.Identifier.. [["].Equipped["]] .._ItemType.. [["] = nil
        ]]);
        
        self.Items[_ItemType] = self.Items[_ItemType] +1;
        self.Equipped[_ItemType] = nil;
        if Item.OnUnequipped then
            Item:OnUnequipped(self.Owner);
        end
        return false;
    end
    return true;
end

---
-- Fügt einen Gegenstand dem Inventar des Helden hinzu.
-- @param _ItemType Typ des Item
-- @param _Amount   Menge
-- @return self
-- @within AddOnRolePlayingGame.Inventory
--
function AddOnRolePlayingGame.Inventory:Insert(_ItemType, _Amount)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Inventory);
    _Amount = _Amount or 1;

    local Item = AddOnRolePlayingGame.ItemList[_ItemType];
    if Item then
        self.Items[_ItemType] = (self.Items[_ItemType] or 0) + _Amount;
        
        local CurrentAmount = self.Items[_ItemType];
        API.Bridge([[
            AddOnRolePlayingGame.InventoryList["]] ..self.Identifier.. [["].Items["]] .._ItemType.. [["] = ]] ..CurrentAmount.. [[
        ]]);
        if Item.OnInserted then
            Item:OnInserted(self.Owner, _Amount);
        end
    end
    return self;
end

---
-- Entfernt einen Gegenstand aus dem Inventar des Helden.
-- @param _ItemType Typ des Item
-- @param _Amount   Menge
-- @return self
-- @within AddOnRolePlayingGame.Inventory
--
function AddOnRolePlayingGame.Inventory:Remove(_ItemType, _Amount)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Inventory);
    _Amount = _Amount or 1;

    local Item = AddOnRolePlayingGame.ItemList[_ItemType];
    if Item then
        self.Items[_ItemType] = (self.Items[_ItemType] or 0) - _Amount;
        if self.Items[_ItemType] <= 0 then
            self.Items[_ItemType] = nil;
            API.Bridge([[
                AddOnRolePlayingGame.InventoryList["]] ..self.Identifier.. [["].Items["]] .._ItemType.. [["] = nil
            ]]);
        else
            local CurrentAmount = self.Items[_ItemType];
            API.Bridge([[
                AddOnRolePlayingGame.InventoryList["]] ..self.Identifier.. [["].Items["]] .._ItemType.. [["] = ]] ..CurrentAmount.. [[
            ]]);
        end
        if Item.OnRemoved then
            Item:OnRemoved(self.Owner, _Amount);
        end
    end
    return self;
end

---
-- Gibt die Menge an Gegenständen des Typs im Inventar des Helden zurück.
-- @param _ItemType Typ des Item
-- @param _Amount   Menge
-- @return self
-- @within AddOnRolePlayingGame.Inventory
--
function AddOnRolePlayingGame.Inventory:CountItem(_ItemType)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Inventory);
    if AddOnRolePlayingGame.ItemList[_ItemType] and self.Items[_ItemType] then
        return self.Items[_ItemType];
    end
    return 0;
end

-- Item ------------------------------------------------------------------------

-- Items representieren besondere Gegenstände, die ein Held entweder anlegen,
-- benutzen oder einfach nur besitzen kann. Gegenstände können einen Effekt 
-- anwenden, wenn sie ins Inventar gelegt oder aus ihm entfernt werden.

AddOnRolePlayingGame.ItemCategories = {
    Quest     = 1, -- Gegenstände wichtig für die Handlung
    Trade     = 2, -- Handelsware
    Resource  = 3, -- Rohstoff
    Equipment = 4, -- Ausrüstungsgegenstand
    Weapon    = 5, -- Waffe
    Armor     = 6, -- Rüstung
    Jewellery = 7, -- Schmuck
};

AddOnRolePlayingGame.ItemList = {};

AddOnRolePlayingGame.Item = {};

---
-- Erzeugt eine neue Instanz eines Items.
-- @param _Identifier Name des Item
-- @return table: Instanz
-- @within AddOnRolePlayingGame.Item
--
function AddOnRolePlayingGame.Item:New(_Identifier)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Item);

    local item = API.InstanceTable(self);
    item.Identifier   = _Identifier;
    item.Categories   = {};
    item.Description  = nil;
    item.Caption      = nil;
    item.OnRemoved    = nil;
    item.OnInserted   = nil;
    item.OnEquipped   = nil;
    item.OnUnequipped = nil;

    AddOnRolePlayingGame.ItemList[_Identifier] = item;
    API.Bridge([[
        AddOnRolePlayingGame.ItemList["]] .._Identifier.. [["] = {}
        AddOnRolePlayingGame.ItemList["]] .._Identifier.. [["].Categories = {}
    ]]);
    return item;
end

---
-- Gibt die Instanz des Item mit dem Identifier zurück.
-- @param _Identifier Name des Item
-- @return table: Instanz des Item
-- @within AddOnRolePlayingGame.Item
--
function AddOnRolePlayingGame.Item:GetInstance(_Identifier)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Item);
    return AddOnRolePlayingGame.ItemList[_Identifier];
end

---
-- Entfernt das Item aus globalen und lokalen Skript.
-- @within AddOnRolePlayingGame.Item
-- @local
--
function AddOnRolePlayingGame.Item:Dispose()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Item);
    API.Bridge("AddOnRolePlayingGame.ItemList['" ..self.Identifier.. "'] = nil");
    AddOnRolePlayingGame.ItemList[self.Identifier] = nil;
end

---
-- Fügt dem Item eine Kategorie hinzu.
-- @param _Category Nummer der Kategorie
-- @return self
-- @within AddOnRolePlayingGame.Item
--
function AddOnRolePlayingGame.Item:AddCategory(_Category)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Item);
    if API.TraverseTable(_Category, self.Categories) == false then 
        table.insert(self.Categories, _Category);
    end
    
    -- Update in local script
    local CategoriesString = "";
    for i= 1, #self.Categories, 1 do
        CategoriesString = CategoriesString .. self.Categories[i] .. ", ";
    end
    local CommandString = "AddOnRolePlayingGame.ItemList['%s'].Categories = {%s}";
    API.Bridge(string.format(CommandString, self.Identifier, CategoriesString));
    return self;
end

---
-- Gibt true zurück, wenn das Item die Kategorie besitzt.
-- @param _Category Nummer der Kategorie
-- @return boolean: Ist in Kategorie
-- @within AddOnRolePlayingGame.Item
--
function AddOnRolePlayingGame.Item:IsInCategory(_Category)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Item);
    return API.TraverseTable(_Category, self.Categories) == true;
end

---
-- Setzt den im 2D-Interface angezeigten Namen des Item.
-- @param _Text Text des Item
-- @return self
-- @within AddOnRolePlayingGame.Item
--
function AddOnRolePlayingGame.Item:SetCaption(_Text)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Item);
    local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    self.Caption = (type(_Text) == "table" and _Text[Language]) or _Text;
    API.Bridge([[
        AddOnRolePlayingGame.ItemList["]] ..self.Identifier.. [["].Caption  = "]] ..self.Caption.. [["
    ]]);
    return self;
end

---
-- Setzt die im 2D-Interface angezeigte Beschreibung des Item.
-- @param _Text Beschreibung des Item
-- @return self
-- @within AddOnRolePlayingGame.Item
--
function AddOnRolePlayingGame.Item:SetDescription(_Text)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Item);
    local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    self.Description = (type(_Text) == "table" and _Text[Language]) or _Text;
    API.Bridge([[
        AddOnRolePlayingGame.ItemList["]] ..self.Identifier.. [["].Description  = "]] ..self.Description.. [["
    ]]);
    return self;
end

-- Event ---------------------------------------------------------------------

-- Events sind bestimmte Aktionen, die ausgeführt werden, wenn einer ihrer 
-- Auslöser aktiviert wird.

AddOnRolePlayingGame.EventList = {};

AddOnRolePlayingGame.Event = {};

---
-- Erzeugt einen neues Event.
-- @param _Identifier Name des Event
-- @return table: Instanz
-- @within AddOnRolePlayingGame.Event
--
function AddOnRolePlayingGame.Event:New(_Identifier)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Event);

    local event = API.InstanceTable(self);
    event.Identifier  = _Identifier;
    event.Triggers    = {};
    event.Caption     = nil;
    event.Description = nil;
    event.Action      = nil;

    AddOnRolePlayingGame.EventList[_Identifier] = event;
    API.Bridge([[
        AddOnRolePlayingGame.EventList[']] .._Identifier.. [[']          = {}
        AddOnRolePlayingGame.EventList[']] .._Identifier.. [['].Triggers = {}
    ]]);
    return event;
end

---
-- Gibt die Instanz des Event mit dem Identifier zurück.
-- @param _Identifier Name des Event
-- @return table: Instanz des Event
-- @within AddOnRolePlayingGame.Event
--
function AddOnRolePlayingGame.Event:GetInstance(_Identifier)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Event);
    return AddOnRolePlayingGame.EventList[_Identifier];
end

---
-- Entfernt das Event aus globalen und lokalen Skript.
-- @within AddOnRolePlayingGame.Event
-- @local
--
function AddOnRolePlayingGame.Event:Dispose()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Event);
    AddOnRolePlayingGame.EventList[self.Identifier] = nil;
    API.Bridge("AddOnRolePlayingGame.EventList['" ..self.Identifier.. "'] = nil");
end

---
-- Setzt den im 2D-Interface angezeigten Namen des Event.
-- @param _Text Text des Event
-- @return self
-- @within AddOnRolePlayingGame.Event
--
function AddOnRolePlayingGame.Event:SetCaption(_Text)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Event);
    local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    self.Caption = (type(_Text) == "table" and _Text[Language]) or _Text;
    API.Bridge([[
        AddOnRolePlayingGame.EventList["]] ..self.Identifier.. [["].Caption  = "]] ..self.Caption.. [["
    ]]);
    return self;
end

---
-- Setzt die im 2D-Interface angezeigte Beschreibung des Event.
-- @param _Text Beschreibung des Event
-- @return self
-- @within AddOnRolePlayingGame.Event
--
function AddOnRolePlayingGame.Event:SetDescription(_Text)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Event);
    local Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    self.Description = (type(_Text) == "table" and _Text[Language]) or _Text;
    API.Bridge([[
        AddOnRolePlayingGame.EventList["]] ..self.Identifier.. [["].Description  = "]] ..self.Description.. [["
    ]]);
    return self;
end

---
-- Fügt dem Event einen Trigger hinzu.
--
-- Liste der möglichen Trigger:
-- <ul>
-- <li>Trigger_AbilityStarted</li>
-- <li>Trigger_ActionPointsRegenerated</li>
-- <li>Trigger_HealthRegenerated</li>
-- <li>Trigger_DamageSustained</li>
-- <li>Trigger_EverySecond</li>
-- <li>Trigger_SermonFinished</li>
-- <li>Trigger_GeologistRefill</li>
-- <li>Trigger_BuildingConstructionFinished</li>
-- <li>Trigger_BuildingUpgradeFinished</li>
-- <li>Trigger_EndOfMonth</li>
-- <li>Trigger_RegularFestivalEnded</li>
-- <li>Trigger_TaxCollectionFinished</li>
-- <li>Trigger_EntityHurt</li>
-- <li>Trigger_EntityKilled</li>
-- </ul>
--
-- @param _Trigger Bezeichner des Trigger
-- @return self
-- @within AddOnRolePlayingGame.Event
--
function AddOnRolePlayingGame.Event:AddTrigger(_Event)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Event);
    if API.TraverseTable(_Event, self.Triggers) == false then 
        table.insert(self.Triggers, _Event);
    end

    local EventTrigger = "";
    for k, v in pairs(self.Triggers) do 
        EventTrigger = EventTrigger .. "'" .. v .. "', ";
    end
    local CommandString = "AddOnRolePlayingGame.EventList['%s'].Triggers = {%s}";
    API.Bridge(string.format(CommandString, self.Identifier, EventTrigger));
    return self;
end

---
-- Gibt true zurück, wenn das Event den Trigger besitzt.
-- @param _Trigger Bezeichner des Trigger
-- @return boolean: Ist in Kategorie
-- @within AddOnRolePlayingGame.Event
--
function AddOnRolePlayingGame.Event:HasTrigger(_Trigger)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Event);
    return API.TraverseTable(_Trigger, self.Triggers) == true;
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("AddOnRolePlayingGame");
