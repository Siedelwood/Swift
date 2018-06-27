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

    Texts = {
        ErrorAbility = {
            de = "Die Fähigkeit kann nicht benutzt werden!",
            en = "The ability can not be used!",
        },
        EarnedExperience = {
            de = "Eure Helden haben {@color:0,255,255,255}%d{@color:255,255,255,255} Erfahrung erhalten!",
            en = "Your heroes gained {@color:0,255,255,255}%d{@color:255,255,255,255} experience points!",
        },
        HeroLevelUp = {
            de = "{@color:244,184,0,255}Eure Helden sind eine Stufe aufgestiegen!",
            en = "{@color:244,184,0,255}Your heroes reached a higher level!",
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
function API.Rpg_AddPlayerExperience(_PlayerID, _EXP)
    assert(AddOnRolePlayingGame.Global.Data.PlayerExperience[_PlayerID]);
    AddOnRolePlayingGame.Global.Data.PlayerExperience[_PlayerID] = AddOnRolePlayingGame.Global.Data.BaseExperience[_PlayerID] + _EXP;
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
function API.Rpg_GetPlayerExperience(_PlayerID)
    assert(AddOnRolePlayingGame.Global.Data.PlayerExperience[_PlayerID]);
    return AddOnRolePlayingGame.Global.Data.PlayerExperience[_PlayerID];
end

---
-- Gibt die Erfahrungspunkte zurück, die für die nächste Stufe benötigt werden.
--
-- @param _PlayerID Spieler, der Erfahrung erhält
-- @return number: Benötigte Erfahrung
--
function API.Rpg_GetPlayerNeededExperience(_PlayerID)
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
    -- Kampf Controller
    API.AddOnEntityHurtAction(self.EntityFightingController);
    -- Level-Up Controller
    Core:AppendFunction("GameCallback_KnightTitleChanged", self.LevelUpController);
    -- Experience Level-Up Controller 
    StartSimpleJobEx(self.ExperienceLevelUpController)
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
                
                -- Den Spieler informieren
                if API.GetControllingPlayer() == _PlayerID then
                    if self.Data.UseInformPlayer then
                        API.Note(AddOnRolePlayingGame.Texts.HeroLevelUp);
                        if self.Data.UseAutoLevel then
                            API.Note(AddOnRolePlayingGame.Texts.AutoLevelUp);
                        else
                            local Text = string.format(AddOnRolePlayingGame.Texts.ManualLevelUp, self.Data.LearnpointsPerLevel);
                            API.Note(Text);
                        end
                    end
                end
            end
        end
    end
end

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
                AddOnRolePlayingGame.Global.Data.PlayerExperience[i] = 0;
                AddOnRolePlayingGame.Global.Data.BaseExperience = Needed + (Needed * 0.5);
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
        
        local Damage = DefenderUnit:CalculateEnduredDamage(AttackerUnit);
        API.HurtEntity(DefenderName, Damage, AttackerName);
        if DefenderHero ~= nil then
            DefenderHero.Health = DefenderHero.Health - Damage;
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

-- local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im localen Skript.
--
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:Install()
    self:DeactivateAbilityBlabering();
    self:OverrideActiveAbility();
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

        local HeroInstance = AddOnRolePlayingGame.Hero:GetInstance(KnightName);
        if HeroInstance == nil or HeroInstance.Ability == nil then
            GUI_Knight.StartAbilityClicked_Orig_AddOnRolePlayingGame(_Ability);
            return;
        end
        if not HeroInstance.Ability:Condition(HeroInstance) then
            if HeroInstance.Ability.ImpossibleMessage then 
                API.Message(HeroInstance.Ability.ImpossibleMessage);
            end
            return;
        end
        HeroInstance.Ability:Action(HeroInstance);
    end

    GUI_Knight.StartAbilityMouseOver_Orig_AddOnRolePlayingGame = GUI_Knight.StartAbilityMouseOver;
    GUI_Knight.StartAbilityMouseOver = function()
        local KnightID   = GUI.GetSelectedEntity();
        local KnightType = Logic.GetEntityType(KnightID);
        local KnightName = Logic.GetEntityName(KnightID);

        local HeroInstance = AddOnRolePlayingGame.Hero:GetInstance(KnightName);
        if HeroInstance == nil or HeroInstance.Ability = nil then
            GUI_Knight.StartAbilityMouseOver_Orig_AddOnRolePlayingGame();
            return;
        end
        SetTextNormal(HeroInstance.Ability.Caption, HeroInstance.Ability.Description);
    end

    GUI_Knight.StartAbilityUpdate_Orig_AddOnRolePlayingGame = GUI_Knight.StartAbilityUpdate;
    GUI_Knight.StartAbilityUpdate = function()
        local WidgetID   = "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/StartAbility";
        local KnightID   = GUI.GetSelectedEntity();
        local KnightType = Logic.GetEntityType(KnightID);
        local KnightName = Logic.GetEntityName(KnightID);

        local HeroInstance = AddOnRolePlayingGame.Hero:GetInstance(KnightName);
        if HeroInstance == nil or HeroInstance.Ability == nil then
            GUI_Knight.StartAbilityUpdate_Orig_AddOnRolePlayingGame();
            return;
        end
    
        -- Icon
        if type(HeroInstance.Ability.Icon) == "table" then
            if HeroInstance.Ability.Icon[3] and type(HeroInstance.Ability.Icon[3]) == "string" then
                API.SetIcon(WidgetID, HeroInstance.Ability.Icon, nil, HeroInstance.Ability.Icon[3]);
            else
                SetIcon(WidgetID, HeroInstance.Ability.Icon);
            end
        else
            API.SetTexture(WidgetID, HeroInstance.Ability.Icon);
        end
    
        -- Enable/Disable
        if HeroInstance.ActionPoints < HeroInstance.Ability.RechargeTime or HeroInstance.AbilityDisabled then
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

        local HeroInstance = AddOnRolePlayingGame.Hero:GetInstance(KnightName);
        if HeroInstance == nil or HeroInstance.Ability == nil then
            GUI_Knight.AbilityProgressUpdate_Orig_AddOnRolePlayingGame(_Ability);
            return;
        end

        local TotalRechargeTime = HeroInstance.Ability.RechargeTime or 6 * 60;
        local ActionPoints = HeroInstance.ActionPoints;
        local TimeAlreadyCharged = ActionPoints or TotalRechargeTime;
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
-- Gibt die Kraft der Einheit zurück.
-- @return number: Kraft
-- @within AddOnRolePlayingGame.Unit
--
function AddOnRolePlayingGame.Unit:GetStrength()
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Unit);

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
    assert(self == AddOnRolePlayingGame.Unit);

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
    assert(self == AddOnRolePlayingGame.Unit);

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
    assert(self == AddOnRolePlayingGame.Unit);
    return self.BaseDamage + (self:GetStrength() * (self.BaseDamage * 0.2));
end

---
-- Gibt den tatsächlich erlittenen Schaden zurück.
-- @param _Attacker Unit des Angreifers
-- @return number: Schaden
-- @within AddOnRolePlayingGame.Unit
--
function AddOnRolePlayingGame.Unit:CalculateEnduredDamage(_Attacker)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Unit);
    
    local Damage = _Attacker:GetDamage();
    for i= 1, self:GetEndurance(), 1 do
        Damage = Damage - (0.1 * Damage);
    end
    return Damage;
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
    assert(self == AddOnRolePlayingGame.Unit);
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
    assert(self == AddOnRolePlayingGame.Unit);
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

AddOnRolePlayingGame.HeroList = {};

AddOnRolePlayingGame.Hero = {};

---
-- Erzeugt eine neue Instanz eines Helden.
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:New(_ScriptName)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Hero);

    local hero = API.InstanceTable(self, AddOnRolePlayingGame.Unit:New(_ScriptName));
    hero.Level        = 0;
    hero.Learnpoints  = 0;
    hero.Health       = 400;
    hero.MaxHealth    = 400;
    hero.ActionPoints = 4*60;
    hero.Caption      = nil;
    hero.Description  = nil;
    hero.Ability      = nil;
    hero.Items        = {};

    AddOnRolePlayingGame.HeroList[_ScriptName] = hero;
    API.Bridge([[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["] = {}
    ]]);
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
                self.Strength = self.Strength +1;
            elseif RandomStat == 2 then
                self.Magic = self.Magic +1;
            else
                self.Endurance = self.Endurance +1;
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
        return (self.GetMagic() * 0.2) +1;
    end
    return 1;
end

---
-- Gibt die Regeneration der Gesundheit pro Sekunde zurück.
-- @return number: Regenerationsrate
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:GetRegerneration()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    return (self.GetEndurance() * 0.2) +5;
end

---
-- Fügt einen Gegenstand dem Inventar des Helden hinzu.
-- @param _ItemType Typ des Item
-- @param _Amount   Menge
-- @return self
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:ItemInsert(_ItemType, _Amount)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    _Amount = _Amount or 1;

    local Item = AddOnRolePlayingGame.ItemList[_ItemType];
    if Item then
        self.Items[_ItemType] = (self.Items[_ItemType] or 0) + _Amount;
        if self.Items[_ItemType] <= 0 then
            self.Items[_ItemType] = nil;
        end
        if Item.OnInserted then
            Item:OnInserted(self, _Amount);
        end
    end
    return self;
end

---
-- Entfernt einen Gegenstand aus dem Inventar des Helden.
-- @param _ItemType Typ des Item
-- @param _Amount   Menge
-- @return self
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:ItemRemove(_ItemType, _Amount)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    _Amount = _Amount or 1;

    local Item = AddOnRolePlayingGame.ItemList[_ItemType];
    if Item then
        self.Items[_ItemType] = (self.Items[_ItemType] or 0) - _Amount;
        if self.Items[_ItemType] <= 0 then
            self.Items[_ItemType] = nil;
        end
        if Item.OnRemoved then
            Item:OnRemoved(self, _Amount);
        end
    end
    return self;
end

---
-- Gibt die Menge an Gegenständen des Typs im Inventar des Helden zurück.
-- @param _ItemType Typ des Item
-- @param _Amount   Menge
-- @return self
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:ItemGetAmount(_ItemType)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    if AddOnRolePlayingGame.ItemList[_ItemType] and self.Items[_ItemType] then
        return self.Items[_ItemType];
    end
    return 0;
end

---
-- Aktualisiert Gesundheit und Aktionspunkte des Helden. Es werden einige
-- Werte ins lokale Skript geschrieben.
-- @within AddOnRolePlayingGame.Hero
-- @local
--
function AddOnRolePlayingGame.Hero.UpdateStatus(_ScriptName)
    if AddOnRolePlayingGame.Hero[_ScriptName] == nil then
        return true;
    end

    API.Bridge([[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Learnpoints  = ]] ..AddOnRolePlayingGame.HeroList[ScriptName].Learnpoints.. [[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Strength     = ]] ..AddOnRolePlayingGame.HeroList[ScriptName].Strength.. [[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Magic        = ]] ..AddOnRolePlayingGame.HeroList[ScriptName].Magic.. [[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Endurance    = ]] ..AddOnRolePlayingGame.HeroList[ScriptName].Endurance.. [[
    ]]);

    local EntityID = GetID(_ScriptName);
    if EntityID ~= nil and EntityID ~= 0 then
        local Hero = AddOnRolePlayingGame.Hero[_ScriptName];
        if Logic.KnightGetResurrectionProgress(EntityID) ~= 1 then
            AddOnRolePlayingGame.Hero[_ScriptName].Health = Hero.MaxHealth;
            if Hero.Ability then
                AddOnRolePlayingGame.Hero[_ScriptName].ActionPoints = Ability.RechargeTime;
            end
        else
            -- Aktualisiere Gesundheit
            if Hero.Health < Hero.MaxHealth then
                local Health = Hero.Health + Hero:GetRegeneration();
                Health = (Health > Hero.MaxHealth and Hero.MaxHealth) or Health;
                Health = (Health < 0 and 0) or Health;
                AddOnRolePlayingGame.Hero[_ScriptName].Health = Health;
            end

            -- Aktualisiere Aktionspunkte
            if Hero.Ability and Hero.ActionPoints < Ability.RechargeTime then
                local ActionPoints = Hero.ActionPoints + Hero:GetAbilityRecharge();
                ActionPoints = (ActionPoints > Ability.RechargeTime and Ability.RechargeTime) or ActionPoints;
                ActionPoints = (ActionPoints < 0 and 0) or ActionPoints;
                AddOnRolePlayingGame.Hero[_ScriptName].Health = ActionPoints;

                API.Bridge([[
                    AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].ActionPoints = ]] ..AddOnRolePlayingGame.HeroList[ScriptName].ActionPoints.. [[
                    AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].RechargeTime = ]] ..AddOnRolePlayingGame.HeroList[ScriptName].Ability.RechargeTime.. [[
                ]]);
            end
        end
    end
end

-- Ability ---------------------------------------------------------------------

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
        AddOnRolePlayingGame.AbilityList["]] .._Identifier.. [["].Icon = ]] ..Icon.. [[
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

-- Item ------------------------------------------------------------------------

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
    item.Description  = nil;
    item.Caption      = nil;
    item.OnRemoved    = nil;
    item.OnInserted   = nil;

    AddOnRolePlayingGame.ItemList[_Identifier] = item;
    API.Bridge([[
        AddOnRolePlayingGame.ItemList["]] .._Identifier.. [["] = {}
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
-- Setzt den im 2D-Interface angezeigten Namen der Fähigkeit.
-- @param _Text Name des Item
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

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("AddOnRolePlayingGame");
