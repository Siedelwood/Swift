-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntityProperties                                       # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- In diesem Bundle werden grundlegende Funktionen zur Abfrage und Manipulation
-- von Entities bereitgestellt.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleEntityProperties = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- Backwards compability                                                      --
-- -------------------------------------------------------------------------- --

---
-- Gibt den Größenfaktor des Entity zurück.
--
-- Der Faktor gibt an, um wie viel die Größe des Entity verändert wurde, im
-- Vergleich zur normalen Größe. Faktor 1 entspricht der normalen Größe.
--
-- <b>Alias</b>: GetScale
--
-- @param[type=string] _Entity Scriptname des Entity
-- @return[type=number] Größenfaktor des Entity
--
function API.GetEntityScale(_Entity)
    return QSB.EntityProperty:GetInstance(_Entity):EntitySize();
end
GetScale = API.GetEntityScale;

---
-- Gibt den Besitzer des Entity zurück.
--
-- <b>Alias</b>: GetPlayer
--
-- @param[type=string] _Entity Scriptname des Entity
-- @return[type=number] Besitzer des Entity
--
function API.GetEntityPlayer(_Entity)
    return QSB.EntityProperty:GetInstance(_Entity):PlayerID();
end
GetPlayer = API.GetEntityPlayer;

---
-- Gibt die Position zurück, zu der sich ein Entity bewegt. Die Position wird
-- als XY-Table zurückgegeben.
--
-- <b>Alias</b>: GetMovingTarget
--
-- @param[type=string] _Entity Scriptname des Entity
-- @return[type=table] Zielposition des Entity
--
function API.GetMovementTarget(_Entity)
    return QSB.EntityProperty:GetInstance(_Entity):GetDestination();
end
GetMovingTarget = API.GetMovementTarget;

---
-- Prüft, ob das NPC-FLag für das Entity gesetzt ist.
--
-- <b>Alias</b>: IsNpc
--
-- @param[type=string] _Entity Scriptname des Entity
-- @return[type=boolean] NPC-Flag ist gesetzt
--
function API.IsActiveNpc(_Entity)
    return QSB.EntityProperty:GetInstance(_Entity):OnScreenInfo();
end
IsNpc = API.IsActiveNpc;

---
-- Prüft, ob das Entity sichtbar ist.
--
-- <b>Alias</b>: IsVisible
--
-- @param[type=string] _Entity Scriptname des Entity
-- @return[type=boolean] Entity ist sichtbar
--
function API.IsEntityVisible(_Entity)
    return QSB.EntityProperty:GetInstance(_Entity):Visible();
end
IsVisible = API.IsEntityVisible;

---
-- Gibt den Größenfaktor des Entity zurück.
--
-- Der Faktor gibt an, um wie viel die Größe des Entity verändert wurde, im
-- Vergleich zur normalen Größe. Faktor 1 entspricht der normalen Größe.
--
-- <b>Alias</b>: SetScale
--
-- @param[type=string] _Entity Scriptname des Entity
-- @param[type=number] _Scale Größenfaktor des Entity
--
function API.SetEntityScale(_Entity, _Scale)
    return QSB.EntityProperty:GetInstance(_Entity):EntitySize(_Scale);
end
SetScale = API.SetEntityScale;

---
-- Weist dem Entity einen neuen Besitzer zu.
--
-- <b>Alias</b>: ChangePlayer
--
-- @param[type=string] _Entity Scriptname des Entity
-- @param[type=number] _PlayerID Besitzer des Entity
--
function API.SetEntityPlayer(_Entity, _PlayerID)
    return QSB.EntityProperty:GetInstance(_Entity):PlayerID(_PlayerID);
end
ChangePlayer = API.SetEntityPlayer;

---
-- Gibt die relative Gesundheit des Entity zurück.
--
-- <b>Hinweis</b>: Die Gesundheit ist immer ganzzahlig zwischen 0 und 100.
--
-- <b>Alias</b>: GetHealth
--
-- @param[type=string] _Entity Scriptname des Entity
-- @return[type=number] Relative Gesundheit des Entity
--
function API.GetEntityHealth(_Entity)
    return QSB.EntityProperty:GetInstance(_Entity):Health();
end
GetHealth = API.GetEntityHealth;

---
-- Ändert die relative Gesundheit eines Entity.
--
-- <b>Hinweis</b>: Die Gesundheit ist immer ganzzahlig zwischen 0 und 100.
--
-- <b>Alias</b>: SetHealth
--
-- @param[type=string] _Entity Scriptname des Entity
-- @param[type=number] _Percentage Relative Gesundheit des Entity
--
function API.ChangeEntityHealth(_Entity, _Percentage)
    return QSB.EntityProperty:GetInstance(_Entity):Health(_Percentage, true);
end
SetHealth = API.ChangeEntityHealth;

---
-- Setzt ein Gebäude in Brand. Die Feuerstärke bestimmt, wie häftig es brennt.
--
-- <b>Hinweis</b>: Im Allgemeinen reicht eine Feuerstärke zwischen 1 und 50.
--
-- <b>Alias</b>: SetOnFire
--
-- @param[type=string] _Entity Scriptname des Entity
-- @param[type=number] _FireSize Relative Gesundheit des Entity
--
function API.SetBuildingOnFire(_Entity, _FireSize)
    QSB.EntityProperty:GetInstance(_Entity):Burning(_FireSize)
end
SetOnFire = API.SetBuildingOnFire;

---
-- Verwundet ein Entity um einen absoluten Wert Gesundheit.
--
-- <b>Hinweis</b>: Die Anzahl an Gesundheitspunkten richtet sich nach dem
-- jeweiligen Entity und ist immer ganzzahlig!
--
-- <b>Alias</b>: HurtEntityEx
--
-- @param[type=string] _Entity Scriptname des Entity
-- @param[type=number] _Damage Menge an abgezogener Gesundheit
--
function API.HurtEntity(_Entity, _Damage, _Attacker)
    QSB.EntityProperty:GetInstance(_Entity):Hurt(_Damage);
end
HurtEntityEx = API.HurtEntity;

-- -------------------------------------------------------------------------- --
-- Scripting Values Class                                                     --
-- -------------------------------------------------------------------------- --

QSB.EntityPropertyObjects = {};

QSB.EntityProperty = {};

---
-- Konstruktor
-- @param[type=string] _Entity Skriptname des Entity
-- @return[type=table] Neue Instanz
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:New(_Entity)
    assert(self == QSB.EntityProperty, "Can not be used from instance!");
    local property = API.InstanceTable(self);
    property.m_EntityName = _Entity;
    QSB.EntityPropertyObjects[_Entity] = property;
    return property;
end

---
-- Gibt die Properties Instanz des Entity zurück.
--
-- Wenn zu dem Entity keine Instanz existiert, wird eine neue
-- Instanz erzeugt.
--
-- @param[type=string] _Entity Skriptname des Entity
-- @return[type=table] Instanz
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetInstance(_Entity)
    assert(self == QSB.EntityProperty, "Can not be used from instance!");

    if not QSB.EntityPropertyObjects[_Entity] then
        QSB.EntityPropertyObjects[_Entity] = QSB.EntityProperty:New(_Entity);
    end
    return QSB.EntityPropertyObjects[_Entity];
end

---
-- Gibt die Größe des Entity zurück. Optional kann der
-- Größenfaktor geändert werden.
--
-- @param[type=number] _Scale (Optional) Neuer Größenfaktor
-- @return[type=number] Größenfaktor
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:EntitySize(_Scale)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local SV = (QSB.HistoryEdition and -42) or -45;
    if _Scale then
        local EntityID = GetID(self.m_EntityName);
        if EntityID > 0 then
            Logic.SetEntityScriptingValue(EntityID, SV, self:Float2Int(_Scale));
            if Logic.IsSettler(EntityID) == 1 then
                Logic.SetSpeedFactor(EntityID, _Scale);
            end
        end
    end
    return self:GetValueAsFloat(SV);
end

---
-- Gibt die Ausrichtung des Entity zurück. Optional kann die
-- Ausrichtung geändert werden.
--
-- @param[type=number] _Orientation (Optional) Neue Ausrichtung
-- @return[type=number] Ausrichtung in Grad
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:Orientation(_Orientation)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 then
        return 0;
    end
    if _Orientation then
        Logic.SetOrientation(EntityID, _Orientation);
    end
    return Logic.GetEntityOrientation(EntityID);
end

---
-- Gibt die Menge an Rohstoffen des Entity zurück. Optional kann
-- eine neue Menge gesetzt werden.
--
-- @param[type=number] _Amount (Optional) Menge an Rohstoffen
-- @return[type=number] Menge an Rohstoffen
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:Resource(_Amount)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 or Logic.GetResourceDoodadGoodType(EntityID) == 0 then
        return 0;
    end
    if _Amount then
        if Logic.GetResourceDoodadGoodAmount(EntityID) == 0 then
            EntityID = ReplaceEntity(EntityID, Logic.GetEntityType(EntityID));
        end
        Logic.SetResourceDoodadGoodAmount(EntityID, _Amount);
    end
    return Logic.GetResourceDoodadGoodAmount(EntityID);
end

---
-- Gibt den Besitzer des Entity zurück. Optional kann das
-- Entity einem neuen Besitzer zugeordnet werden.
--
-- @param[type=number] _PlayerID (Optional) Neuer Besitzer des Entity
-- @return[type=number] Besitzer
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:PlayerID(_PlayerID)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local SV = (QSB.HistoryEdition and -68) or -71;
    if _PlayerID then
        local EntityID = GetID(self.m_EntityName);
        if EntityID > 0 then
            if Logic.IsLeader(EntityID) == 1 then
                Logic.ChangeSettlerPlayerID(EntityID, _PlayerID);
            else
                Logic.SetEntityScriptingValue(EntityID, SV, _PlayerID);
            end
        end
    end
    return self:GetValueAsInteger(SV);
end

---
-- Gibt die Gesundheit des Entity zurück. Optional kann die
-- Gesundheit geändert werden.
--
-- @param[type=number]  _Health   (Optional) Neue aktuelle Gesundheit
-- @param[type=boolean] _Relative (Optional) Relativ zur maximalen Gesundheit
-- @return[type=number] Aktuelle Gesundheit
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:Health(_Health, _Relative)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 or Logic.IsLeader(EntityID) == 1 then
        return 0;
    end
    local SV = (QSB.HistoryEdition and -38) or -41;
    if _Health then
        local NewHealth = _Health;
        -- Relative Gesundheit berechnen
        if _Relative then
            _Health = (_Health < 0 and 0) or _Health;
            _Health = (_Health > 100 and 100) or _Health;
            local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
            NewHealth = math.ceil((MaxHealth) * (_Health/100));
        end
        Logic.SetEntityScriptingValue(EntityID, SV, NewHealth);
    end
    return self:GetValueAsInteger(SV);
end

---
-- Heilt das Entity um die angegebene Menge an Gesundheit.
--
-- @param[type=number]  _Amount   Geheilte Gesundheit
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:Heal(_Amount)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 or Logic.IsLeader(EntityID) == 1 then
        return;
    end
    self:Health(self:Health() + _Amount);
end

---
-- Verwundet ein Entity oder ein Battallion um die angegebene
-- Menge an Schaden. Bei einem Battalion wird der Schaden solange
-- auf Soldaten aufgeteilt, bis er komplett verrechnet wurde.
--
-- @param[type=number] _Damage   Schaden
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:Hurt(_Damage)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 then
        return;
    end
    if self:InGategory(EntityCategories.Soldier) then
        local Leader = GiveEntityName(self:GetLeader());
        QSB.EntityProperty:GetInstance(Leader):Hurt(_Damage);
        return;
    end

    local EntityToHurt = EntityID;
    local IsLeader = self:InGategory(EntityCategories.Leader);
    if IsLeader then
        EntityToHurt = self:GetSoldiers()[1];
    end

    local EntityKilled = false;
    local Health = Logic.GetEntityHealth(EntityToHurt);
    if EntityToHurt then
        if Health <= _Damage then
            _Damage = _Damage - Health;
            EntityKilled = true;
            Logic.HurtEntity(EntityToHurt, Health);
            if IsLeader and _Damage > 0 then
                self:Hurt(_Damage);
            end
        else
            Logic.HurtEntity(EntityToHurt, _Damage);
        end
    end
end

---
-- Gibt zurück, ob das Gebäude brennt. Optional kann die Stärke
-- des Feuers verändert werden.
--
-- @param[type=number]  _FireSize (Optional) Neue aktuelle Gesundheit
-- @return[type=boolean] Gebäude steht in Flammen
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:Burning(_FireSize)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 or Logic.IsBuilding(EntityID) == 0 then
        return false;
    end
    -- TODO: Gebäude per Skript löschen!
    if _FireSize and _FireSize > 0 then
        Logic.DEBUG_SetBuildingOnFire(EntityID, _FireSize);
    end
    return Logic.IsBurning(EntityID);
end

---
-- Gibt zurück, ob das Entity sichtbar ist. Optional
-- kann die Sichtbarkeit neu gesetzt werden.
--
-- @param[type=boolean] _Visible (Optional) Sichtbarkeit ändern
-- @return[type=boolean] Ist sichtbar
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:Visible(_Visble)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 then
        return false;
    end
    if _Visble ~= nil then
        Logic.SetVisible(EntityID, _Visble);
    end
    local SV = (QSB.HistoryEdition and -47) or -50;
    return self:GetValueAsInteger(SV) == 801280;
end

---
-- Prüft, ob das Entity krank ist. Optional kann das Entity vorher
-- krank gemacht werden.
--
-- @param[type=boolean] _SetIll (Optional) Entity krank machen
-- @return[type=boolean] Entity ist krank
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:Ill(_SetIll)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    local FarmAnimal = false;
    if self:InGategory(EntityCategories.CattlePasture) or self:InGategory(EntityCategories.SheepPasture) then
        FarmAnimal = true;
    end
    if EntityID == 0 or (Logic.IsSettler(EntityID) == 0 and FarmAnimal == false) then
        return false;
    end
    if FarmAnimal then
        if _SetIll == true then
            Logic.MakeFarmAnimalIll(EntityID);
        end
        return Logic.IsFarmAnimalIll(EntityID);
    else
        if _SetIll == true then
            Logic.MakeSettlerIll(EntityID);
        end
        return Logic.IsIll(EntityID);
    end
end

---
-- Gibt zurück, ob eine NPC-Interaktion mit dem Siedler möglich ist.
--
-- @return[type=boolean] Ist NPC
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:OnScreenInfo()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 or Logic.IsSettler(EntityID) == 0 then
        return false;
    end
    return self:GetValueAsInteger(6) > 0;
end

---
-- Gibt das Bewegungsziel des Entity zurück.
--
-- @return[type=table] Positionstabelle
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetDestination()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID > 0 then
        local SVX = (QSB.HistoryEdition and 17) or 19;
        local SVY = (QSB.HistoryEdition and 18) or 20;
        return {X= self:GetValueAsFloat(SVX), Y= self:GetValueAsFloat(SVY)};
    end
    return {X= 0, Y= 0};
end

---
-- Gibt die Mänge an Soldaten zurück, die dem Entity unterstehen
--
-- @return[type=number] Menge an Soldaten
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:CountSoldiers()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID > 0 and Logic.IsLeader(EntityID) == 1 then
        local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
        return #SoldierTable;
    end
    return 0;
end

---
-- Gibt die IDs aller Soldaten zurück, die zum Battalion gehören.
--
-- @return[type=table] Liste aller Soldaten
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetSoldiers()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID > 0 and Logic.IsLeader(EntityID) == 1 then
        local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
        table.remove(SoldierTable, 1);
        return SoldierTable;
    end
    return {};
end

---
-- Gibt den Leader des Soldaten zurück.
--
-- @return[type=number] Menge an Soldaten
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetLeader()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID > 0 and Logic.IsEntityInCategory(EntityID, EntityCategories.Soldier) == 1 then
        return Logic.SoldierGetLeaderEntityID(EntityID);
    end
    return 0;
end

---
-- Gibt den Typen des Entity zurück. Optinal kann das Entity
-- mit einem neuen Entity anderen Typs ersetzt werden.
--
-- @param[type=number] _NewType (optional) Typ neues Entity
-- @return[type=number] Typ des Entity
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:Type(_NewType)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 then
        return 0;
    end
    if _NewType then
        EntityID = ReplaceEntity(EntityID, _NewType);
    end
    return Logic.GetEntityType(EntityID);
end

---
-- Gibt den Typnamen des Entity zurück.
--
-- @return[type=string] Typname des Entity
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetTypeName()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 then
        return;
    end
    return Logic.GetEntityTypeName(self:Type());
end

---
-- Gibt alle Kategorien zurück, zu denen das Entity gehört.
--
-- @return[type=table] Kategorien des Entity
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetGategories()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 then
        return {};
    end
    local Categories = {};
    for k, v in pairs(EntityCategories) do
        if Logic.IsEntityInCategory(EntityID, v) == 1 then 
            Categories[#Categories+1] = v;
        end
    end
    return Categories;
end

---
-- Prüft, ob das Entity zur angegebenen Kategorie gehört.
--
-- @param[type=number] _Category Kategorie
-- @return[type=boolean] Entity hat Kategorie
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:InGategory(_Category)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    return Inside(_Category, self:GetGategories());
end

---
-- Gibt die Scripting Value des Entity als Ganzzahl zurück.
--
-- @param[type=number] _index  Index im RAM
-- @return[type=number] Ganzzahl
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetValueAsInteger(_index)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 then
        return 0;
    end
    return math.floor(Logic.GetEntityScriptingValue(EntityID, _index) + 0.5);
end

---
-- Gibt die Scripting Value des Entity als Dezimalzahl zurück.
--
-- @param[type=number] _index  Index im RAM
-- @return[type=number] Dezimalzahl
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetValueAsFloat(_index)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 then
        return 0.0;
    end
    return self:Int2Float(Logic.GetEntityScriptingValue(EntityID,_index));
end

-- -------------------------------------------------------------------------- --

---
-- Bestimmt das Modul b der Zahl a.
--
-- @param[type=number] a Zahl
-- @param[type=number] b Modul
-- @return[type=number] qmod der Zahl
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:qmod(a, b)
    return a - math.floor(a/b)*b
end

---
-- Konvertiert eine Ganzzahl in eine Dezimalzahl.
--
-- @param[type=number] num Integer
-- @return[type=number] Integer als Float
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:Int2Float(num)
    if(num == 0) then return 0 end
    local sign = 1
    if(num < 0) then num = 2147483648 + num; sign = -1 end
    local frac = self:qmod(num, 8388608)
    local headPart = (num-frac)/8388608
    local expNoSign = self:qmod(headPart, 256)
    local exp = expNoSign-127
    local fraction = 1
    local fp = 0.5
    local check = 4194304
    for i = 23, 0, -1 do
        if(frac - check) > 0 then fraction = fraction + fp; frac = frac - check end
        check = check / 2; fp = fp / 2
    end
    return fraction * math.pow(2, exp) * sign
end

---
-- Gibt den Integer als Bits zurück.
--
-- @param[type=number] num Bits
-- @return[type=table] Table mit Bits
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:bitsInt(num)
    local t={}
    while num>0 do
        rest=self:qmod(num, 2) table.insert(t,1,rest) num=(num-rest)/2
    end
    table.remove(t, 1)
    return t
end

---
-- Stellt eine Zahl als eine Folge von Bits in einer Table dar.
--
-- @param[type=number] num Integer
-- @param[type=table]  t   Table
-- @return[type=table] Table mit Bits
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:bitsFrac(num, t)
    for i = 1, 48 do
        num = num * 2
        if(num >= 1) then table.insert(t, 1); num = num - 1 else table.insert(t, 0) end
        if(num == 0) then return t end
    end
    return t
end

---
-- Konvertiert eine Dezimalzahl in eine Ganzzahl.
--
-- @param[type=number] fval Float
-- @return[type=number] Float als Integer
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:Float2Int(fval)
    if(fval == 0) then return 0 end
    local signed = false
    if(fval < 0) then signed = true; fval = fval * -1 end
    local outval = 0;
    local bits
    local exp = 0
    if fval >= 1 then
        local intPart = math.floor(fval); local fracPart = fval - intPart;
        bits = self:bitsInt(intPart); exp = table.getn(bits); self:bitsFrac(fracPart, bits)
    else
        bits = {}; self:bitsFrac(fval, bits)
        while(bits[1] == 0) do exp = exp - 1; table.remove(bits, 1) end
        exp = exp - 1
        table.remove(bits, 1)
    end
    local bitVal = 4194304; local start = 1
    for bpos = start, 23 do
        local bit = bits[bpos]
        if(not bit) then break; end
        if(bit == 1) then outval = outval + bitVal end
        bitVal = bitVal / 2
    end
    outval = outval + (exp+127)*8388608
    if(signed) then outval = outval - 2147483648 end
    return outval;
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleEntityProperties");

