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
        UpgradeStrength = {
            de = "Kraft verbessern",
            en = "Improve Strength",
        },
        UpgradeMagic = {
            de = "Magie verbessern",
            en = "Improve Magic",
        },
        UpgradeEndurance = {
            de = "Ausdauer verbessern",
            en = "Improve Endurance",
        },
        
        -- Messages --
        
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
    StartSimpleJobEx(self.ExperienceLevelUpController);
    -- Save Game 
    API.AddSaveGameAction(self.OnSaveGameLoaded);
end

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
    
    -- Lernpunkte entfernen
    API.Bridge('AddOnRolePlayingGame.HeroList["' ..ScriptName.. '"].Learnpoints = '..(HeroInstance.Learnpoints-1));
    HeroInstance.Learnpoints = HeroInstance.Learnpoints -1;

    -- Statuswert verbessern
    if _Idx == 0 then 
        API.Note("TRACE: Attack clicked (Strength)");
        HeroInstance.Strength = HeroInstance.Strength +1;
    elseif _Idx == 1 then 
        API.Note("TRACE: Bless clicked (Endurance)");
        HeroInstance.Endurance = HeroInstance.Endurance +1;
    else 
        API.Note("TRACE: Trebuchet clicked (Magic)");
        HeroInstance.Magic = HeroInstance.Magic +1;
    end
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

---
-- Wirt ausgeführt, nachdem ein Spielstand geladen wurde. Diese Funktion Stellt
-- alle nicht persistenten Änderungen wieder her.
--
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Global.OnSaveGameLoaded()
    API.Bridge("AddOnRolePlayingGame.Local:OverrideStringKeys()");
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
    self:OverrideStringKeys();
    self:OverrideKnightCommands();
end

---
-- Zeigt die Inhalte des Inventars eines Helden an.
--
-- @param _Identifier Name des Inventars
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:DisplayInventory(_Identifier)
    if AddOnRolePlayingGame.InventoryList[_Identifier] == nil then 
        return;
    end
    
    local DisplayedItems = {};
    for k, v in pairs(AddOnRolePlayingGame.InventoryList[_Identifier].Items) do
        if v then 
            local Caption = AddOnRolePlayingGame.ItemList[k].Caption;
            local Description = AddOnRolePlayingGame.ItemList[k].Description;
            table.insert(DisplayedItems, {Caption, v, Description});
        end
    end
    
    local ContentString = "";
    local Line = "%s (%d){cr}%s{cr}{cr}";
    for i= 1, #DisplayedItems, 1 do
        ContentString = ContentString .. string.format(
            Line, DisplayedItems[1], DisplayedItems[2], DisplayedItems[3]
        );
    end
    
    TextWindow:New()
        :SetCaption({de = "Rucksack", en = "Inventory"})
        :SetContent(ContentString)
        :Show();
end

---
-- Überschreibt die KnightCommands, sodass sie für das Upgrade des Status 
-- verwendet werden kann.
--
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:OverrideKnightCommands()
    Mission_SupportButtonClicked = function(_Idx)
        local EntityID = GUI.GetSelectedEntity();
        if eID == nil or eID == 0 then
            return;
        end
        API.Bridge("AddOnRolePlayingGame.Global:UpgradeHeroStatus(" .._Idx.. ", "..EntityID..")");
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
            return;
        end
        
        XGUIEng.SetWidgetPositionAndSize(AddOnRolePlayingGame.KnightCommands.Strength.Mother, 170, 20, 100, 100);
        XGUIEng.SetWidgetPositionAndSize(AddOnRolePlayingGame.KnightCommands.Magic.Mother, 245, 23, 100, 100);
        XGUIEng.SetWidgetPositionAndSize(AddOnRolePlayingGame.KnightCommands.Endurance.Mother, 320, 20, 100, 100);
        
        SetIcon(AddOnRolePlayingGame.KnightCommands.Strength.Button, {7,4});
        SetIcon(AddOnRolePlayingGame.KnightCommands.Magic.Button, {11, 2});
        SetIcon(AddOnRolePlayingGame.KnightCommands.Endurance.Button, {7,2});
        
        if x ~= 0 and y ~= 0 and x > -200 and y > -200 and x < (Screensize[1] + 50) and y < (Screensize[2] + 200) then
            local WidgetID = "/InGame/Root/Normal/AlignTopLeft/KnightCommands";
            XGUIEng.SetWidgetSize(widget,480,160);
            local WidgetSize = {XGUIEng.GetWidgetScreenSize(WidgetID)};
            XGUIEng.SetWidgetScreenPosition(WidgetID, x-(WidgetSize[1]*0.6), y-WidgetSize[2]);
            XGUIEng.DisableButton(AddOnRolePlayingGame.KnightCommands.Strength.Mother,0);
            XGUIEng.ShowWDisableButtonidget(AddOnRolePlayingGame.KnightCommands.Magic.Mother,0);
            XGUIEng.DisableButton(AddOnRolePlayingGame.KnightCommands.Endurance.Mother,0);
            
            if Hero.Learnpoints == 0 then
                XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Strength.Mother,0);
                XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Magic.Mother,0);
                XGUIEng.ShowWidget(AddOnRolePlayingGame.KnightCommands.Endurance.Mother,0);
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

        local HeroInstance = AddOnRolePlayingGame.HeroList[KnightName];
        if HeroInstance == nil or HeroInstance.Ability == nil then
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

        local HeroInstance = AddOnRolePlayingGame.HeroList[KnightName];
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

        local HeroInstance = AddOnRolePlayingGame.HeroList[KnightName];
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
-- Gibt den tatsächlich erlittenen Schaden zurück.
-- @param _Attacker Unit des Angreifers
-- @return number: Schaden
-- @within AddOnRolePlayingGame.Unit
--
function AddOnRolePlayingGame.Unit:CalculateEnduredDamage(_Attacker)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Unit);
    
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
    
    hero.Unit.BaseDamage = 25;
    
    API.Bridge([[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["] = {}
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
-- Gibt das Inventar des Helden zurück.
--
-- Die Funktion setzt implizit den Owner des Inventar auf den Helden.
--
-- @return table: Inventar des Helden
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:GetInventory()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    if self.Inventory then 
        self.Inventory.Owner = self;
        return self.Inventory;
    end
end

---
-- Gibt die aktive Fähigkeit des Helden zurück.
-- @return table: Fähigkeit des Helden
-- @within AddOnRolePlayingGame.Hero
--
function AddOnRolePlayingGame.Hero:GetAbility()
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Hero);
    return self.Ability;
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
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Learnpoints  = ]] ..AddOnRolePlayingGame.HeroList[_ScriptName].Learnpoints.. [[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Strength     = ]] ..AddOnRolePlayingGame.HeroList[_ScriptName].Unit.Strength.. [[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Magic        = ]] ..AddOnRolePlayingGame.HeroList[_ScriptName].Unit.Magic.. [[
        AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].Endurance    = ]] ..AddOnRolePlayingGame.HeroList[_ScriptName].Unit.Endurance.. [[
    ]]);

    local EntityID = GetID(_ScriptName);
    if EntityID ~= nil and EntityID ~= 0 then
        if Logic.KnightGetResurrectionProgress(EntityID) ~= 1 then
            AddOnRolePlayingGame.HeroList[_ScriptName].Health = Hero.MaxHealth;
            if Hero:GetAbility() then
                AddOnRolePlayingGame.HeroList[_ScriptName].ActionPoints = Ability.RechargeTime;
            end
        else
            -- Aktualisiere Gesundheit
            if Hero.Health < Hero.MaxHealth then
                local Health = Hero.Health + Hero:GetRegeneration();
                Health = (Health > Hero.MaxHealth and Hero.MaxHealth) or Health;
                Health = (Health < 0 and 0) or Health;
                AddOnRolePlayingGame.HeroList[_ScriptName].Health = Health;
            end
            
            MakeVulnerable(_ScriptName);
            local Health = (Hero.Health / Hero.MaxHealth) * 100;
            SetHealth(_ScriptName, Health);
            MakeInvulnerable(_ScriptName);

            -- Aktualisiere Aktionspunkte
            if Hero:GetAbility() and Hero.ActionPoints < Ability.RechargeTime then
                local ActionPoints = Hero.ActionPoints + Hero:GetAbilityRecharge();
                ActionPoints = (ActionPoints > Ability.RechargeTime and Ability.RechargeTime) or ActionPoints;
                ActionPoints = (ActionPoints < 0 and 0) or ActionPoints;
                AddOnRolePlayingGame.HeroList[_ScriptName].Health = ActionPoints;

                API.Bridge([[
                    AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].ActionPoints = ]] ..AddOnRolePlayingGame.HeroList[_ScriptName].ActionPoints.. [[
                    AddOnRolePlayingGame.HeroList["]] .._ScriptName.. [["].RechargeTime = ]] ..AddOnRolePlayingGame.HeroList[_ScriptName]:GetAbility().RechargeTime.. [[
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

-- Inventory -------------------------------------------------------------------

-- Ein Inventar ist ein Container, in dem sich die Gegenstände befinden, die 
-- ein Held sein eigen nennt. Ein Inventar hat immer einen Besitzer, eine 
-- Referenz auf den Helden.

AddOnRolePlayingGame.InventoryList = {};

AddOnRolePlayingGame.Inventory = {};

---
-- Erzeugt eine neue Instanz eines Items.
-- @param _Identifier Name des Item
-- @return table: Instanz
-- @within AddOnRolePlayingGame.Inventory
--
function AddOnRolePlayingGame.Inventory:New(_Identifier)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Inventory);

    local inventory = API.InstanceTable(self);
    inventory.Owner        = nil,
    inventory.Identifier   = _Identifier;
    inventory.Items        = {};
    inventory.Equipped     = {};

    AddOnRolePlayingGame.InventoryList[_Identifier] = inventory;
    API.Bridge([[
        AddOnRolePlayingGame.InventoryList["]] .._Identifier.. [["]          = {}
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
            ListOfItems = ListOfItems .. k .. " = " ..v.. "{cr}";
        end
    end
    API.Note(ListOfItems);
    return self;
end

---
-- Legt einen Gegenstand als Ausrüstung an.
-- @param _ItemType Typ des Item
-- @return self
-- @within AddOnRolePlayingGame.Inventory
--
function AddOnRolePlayingGame.Inventory:Equip(_ItemType)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Inventory);
    local Item = AddOnRolePlayingGame.ItemList[_ItemType];
    if Item and self.Items[_ItemType] > 0 and not self.Equipped[_ItemType] then
        API.Bridge([[
            AddOnRolePlayingGame.InventoryList["]] .._Identifier.. [["].Equipped["]] .._ItemType.. [["] = true
        ]]);
        
        self.Equipped[_ItemType] = true;
        if Item.OnEquipped then
            Item:OnEquipped(self.Owner);
        end
    end
    return self;
end

---
-- Legt einen Gegenstand ab, der als Ausrüstung angelegt ist.
-- @param _ItemType Typ des Item
-- @return self
-- @within AddOnRolePlayingGame.Inventory
--
function AddOnRolePlayingGame.Inventory:Unequip(_ItemType)
    assert(not GUI);
    assert(self ~= AddOnRolePlayingGame.Inventory);
    local Item = AddOnRolePlayingGame.ItemList[_ItemType];
    if self.Equipped[_ItemType] then
        API.Bridge([[
            AddOnRolePlayingGame.InventoryList["]] .._Identifier.. [["].Equipped["]] .._ItemType.. [["] = nil
        ]]);
        
        self.Equipped[_ItemType] = nil;
        if Item.OnUnequipped then
            Item:OnUnequipped(self.Owner);
        end
    end
    return self;
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
        if self.Items[_ItemType] <= 0 then
            self.Items[_ItemType] = nil;
        else
            local CurrentAmount = self.Items[_ItemType];
            API.Bridge([[
                AddOnRolePlayingGame.InventoryList["]] .._Identifier.. [["].Items["]] .._ItemType.. [["] = ]] ..CurrentAmount.. [[
            ]]);
        end
        
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
        else
            local CurrentAmount = self.Items[_ItemType];
            API.Bridge([[
                AddOnRolePlayingGame.InventoryList["]] .._Identifier.. [["].Items["]] .._ItemType.. [["] = ]] ..CurrentAmount.. [[
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
    item.OnEquipped   = nil;
    item.OnUnequipped = nil;

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
