-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnRolePlayingGame                                         # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
--
--
-- @module AddOnRolePlayingGame
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

AddOnRolePlayingGame = {
    Global =  {
        Data = {},
    },
    Local = {
        Data = {},
    },

    Texts = {
        ErrorAbility = {
            de = "Die Fähigkeit kann nicht benutzt werden!",
            en = "The ability can not be used!",
        },
    },
}

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --



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

end

-- local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im localen Skript.
--
-- @within Private
-- @local
--
function AddOnRolePlayingGame.Local:Install()

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
    return self.BaseDamage * self:GetStrength();
end

---
-- Fügt der Einheit einen Buff hinzu.
--
-- Buffs können nicht gestackt werden, d.h. jeder Buff kann nur einmal auf
-- einer Einheit aktiv sein. Buffs sind entweder n Sekunden aktiv oder haben
-- eine unbegrenzte Dauer. In diesem Fall wird die Duration -1 gesetzt.
--
-- Buffs haben folgendes Format:
-- <pre><code>
-- {DURATION, STRENGTH_BONUS, MAGIC_BONUS, ENDURANCE_BONUS, BUFF_NAME}
-- </pre></code>
--
-- @param _Buff Buff-Table
-- @return self
-- @within AddOnRolePlayingGame.Unit
--
function AddOnRolePlayingGame.Unit:BuffAdd(_Buff)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Unit);
    table.insert(_Buff[1], _Buff);
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
    for k, v in pairs(self.Buffs) do
        if v and v[5] == _BuffName then
            self.Buffs[k] = nil;
        end
    end
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
        if v and v[1] > -1 then
            v[1] = v[1] -1;
            if v[1] <= 0 then
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
function AddOnRolePlayingGame.Unit:GetInstance(_ScriptName)
    assert(not GUI);
    assert(self == AddOnRolePlayingGame.Hero);
    return AddOnRolePlayingGame.HeroList[_ScriptName];
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
        return (self.Magic * 0.05) +1;
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
    return (self.Endurance * 0.1) +5;
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
