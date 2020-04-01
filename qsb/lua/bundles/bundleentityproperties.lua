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

QSB.InvulnerableScriptNameToID = {};

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
    return QSB.EntityProperty:GetInstance(_Entity):GetEntitySize();
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
    return QSB.EntityProperty:GetInstance(_Entity):IsVisible();
end
IsVisible = API.IsEntityVisible;

---
-- Macht das Entity oder das Battalion unverwundbar.
--
-- Wenn ein Skriptname angegeben wird, wird fortlaufend geprüft, ob sich die
-- ID geändert hat und das Ziel erneut unverwundbar gemacht werden muss.
--
-- <b>Alias</b>: MakeInvulnerable
--
-- @param[type=string] _Entity Scriptname des Entity
--
function API.MakeInvulnerable(_Entity)
    if type(_Entity) == "number" and IsExisting(_Entity) then
        QSB.EntityProperty:GetInstance(_Entity):Vulnerable(false);
    elseif type(_Entity) == "string" and IsExisting(_Entity) then
        QSB.InvulnerableScriptNameToID[_Entity] = GetID(_Entity);
        QSB.EntityProperty:GetInstance(_Entity):Vulnerable(false);
    end
end
MakeInvulnerable = API.MakeInvulnerable;

---
-- Macht das Entity oder das Battalion verwundbar.
--
-- <b>Alias</b>: MakeVulnerable
--
-- @param[type=string] _Entity Scriptname des Entity
--
function API.MakeVulnerable(_Entity)
    if type(_Entity) == "number" and IsExisting(_Entity) then
        QSB.EntityProperty:GetInstance(_Entity):Vulnerable(true);
    elseif type(_Entity) == "string" and IsExisting(_Entity) then
        QSB.InvulnerableScriptNameToID[_Entity] = nil;
        QSB.EntityProperty:GetInstance(_Entity):Vulnerable(true);

    end
end
MakeVulnerable = API.MakeVulnerable;

---
-- Setzt den Größenfaktor des Entity.
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
    return QSB.EntityProperty:GetInstance(_Entity):SetEntitySize(_Scale);
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
    return QSB.EntityProperty:GetInstance(_Entity):SetPlayerID(_PlayerID);
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
    return QSB.EntityProperty:GetInstance(_Entity):GetHealth();
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
    return QSB.EntityProperty:GetInstance(_Entity):SetHealth(_Percentage, true);
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
    QSB.EntityProperty:GetInstance(_Entity):SetBurning(_FireSize)
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
-- @param[type=number] _Attacker (optional) Skriptname des Angreifers
--
function API.HurtEntity(_Entity, _Damage, _Attacker)
    if GUI then
        return;
    end
    QSB.EntityProperty:GetInstance(_Entity):Hurt(_Damage, _Attacker);
end
HurtEntityEx = API.HurtEntity;

---
-- Gibt die Orientierung des Entity zurück.
--
-- <p><b>Alias:</b> GetOrientation</p>
--
-- @param               _entity Betreffendes Entity (Skriptname oder ID)
-- @return[type=number] Orientierung in Grad
-- @within Anwenderfunktionen
--
-- @usage
-- local Orientation = API.EntityGetOrientation("marcus");
--
function API.EntityGetOrientation(_Entity)
    if not IsExisting(_Entity) then
        return 0;
    end
    return QSB.EntityProperty:GetInstance(_Entity):GetOrientation();
end
GetOrientation = API.EntityGetOrientation;

---
-- Setzt die Orientierung des Entity.
--
-- <p><b>Alias:</b> SetOrientation</p>
--
-- @param              _Entity      Betreffendes Entity (Skriptname oder ID)
-- @param[type=number] _Orientation Ausrichtung in Grad
-- @within Anwenderfunktionen
--
-- @usage
-- API.EntitySetOrientation("marcus", 52);
--
function API.EntitySetOrientation(_Entity, _Orientation)
    if GUI then
        return;
    end
    QSB.EntityProperty:GetInstance(_Entity):SetOrientation(_Orientation);
end
SetOrientation = API.EntitySetOrientation;

-- -------------------------------------------------------------------------- --
-- Internal                                                                   --
-- -------------------------------------------------------------------------- --

BundleEntityProperties = {
    Global = {
        Data = {};
    }
}

---
-- Installiert das Bundle.
--
function BundleEntityProperties.Global:Install()
    StartSimpleHiResJobEx(self.InvulnerabilityJob);
end

---
-- Setzt ein unverwundbares Entity wieder unverwundbar, wenn sich die ID
-- geändert hat.
-- @within Internal
-- @local
--
function BundleEntityProperties.Global.InvulnerabilityJob()
    for k, v in pairs(QSB.InvulnerableScriptNameToID) do
        local ID = GetID(k);
        if v and ID ~= v then
            API.MakeInvulnerable(k);
        end
    end
end

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
-- Prüft, ob das Entity existiert.
--
-- @return[type=boolean] Entity existiert
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:IsExisting()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    return IsExisting(self.m_EntityName) == true;
end

---
-- Gibt die Größe des Entity zurück.
--
-- @return[type=number] Größenfaktor
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetEntitySize()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    return self:GetValueAsFloat(QSB.ScriptingValues[QSB.ScriptingValues.Game].Size);
end

---
-- Setzt die Größe des Entity. Wenn es sich um einen Siedler handelt, wird
-- versucht einen neuen Speed Factor zu setzen.
--
-- @param[type=number] _Scale Neuer Größenfaktor
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:SetEntitySize(_Scale)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local SV = QSB.ScriptingValues[QSB.ScriptingValues.Game].Size;
    local EntityID = GetID(self.m_EntityName);
    if EntityID > 0 then
        Logic.SetEntityScriptingValue(EntityID, SV, Core:ScriptingValueFloatToInteger(_Scale));
        if Logic.IsSettler(EntityID) == 1 then
            Logic.SetSpeedFactor(EntityID, _Scale);
        end
    end
    return self;
end

---
-- Gibt die Ausrichtung des Entity zurück.
--
-- @return[type=number] Ausrichtung in Grad
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetOrientation()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    return API.Round(Logic.GetEntityOrientation(GetID(self.m_EntityName)));
end

---
-- Setzt die Ausrichtung des Entity.
--
-- @param[type=number] _Orientation Neue Ausrichtung
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:SetOrientation(_Orientation)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    Logic.SetOrientation(GetID(self.m_EntityName), API.Round(_Orientation));
    return self;
end

---
-- Gibt die Menge an Rohstoffen des Entity zurück. Optional kann
-- eine neue Menge gesetzt werden.
--
-- @return[type=number] Menge an Rohstoffen
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetResource()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    return Logic.GetResourceDoodadGoodAmount(GetID(self.m_EntityName));
end

---
-- Setzt die Menge an Rohstoffen des Entity.
--
-- @param[type=number] _Amount Menge an Rohstoffen
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:SetResource(_Amount)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID > 0 or Logic.GetResourceDoodadGoodType(EntityID) > 0 then
        if Logic.GetResourceDoodadGoodAmount(EntityID) == 0 then
            EntityID = ReplaceEntity(EntityID, Logic.GetEntityType(EntityID));
        end
        Logic.SetResourceDoodadGoodAmount(EntityID, _Amount);
    end
    return self;
end

---
-- Gibt den Besitzer des Entity zurück.
--
-- @return[type=number] Besitzer
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetPlayerID()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    return self:GetValueAsInteger(QSB.ScriptingValues[QSB.ScriptingValues.Game].Player);
end

---
-- Setzt den Besitzer des Entity.
--
-- @param[type=number] _PlayerID (Optional) Neuer Besitzer des Entity
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:SetPlayerID(_PlayerID)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local SV = QSB.ScriptingValues[QSB.ScriptingValues.Game].Player;
    local EntityID = GetID(self.m_EntityName);
    if EntityID > 0 then
        if self:InGategory(EntityCategories.Leader) or self:InGategory(EntityCategories.CattlePasture) or self:InGategory(EntityCategories.SheepPasture) then
            Logic.ChangeSettlerPlayerID(EntityID, _PlayerID);
        else
            Logic.SetEntityScriptingValue(EntityID, SV, _PlayerID);
        end
    end
    return self;
end

---
-- Gibt die Gesundheit des Entity zurück.
--
-- @return[type=number] Aktuelle Gesundheit
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetHealth()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    local SV = QSB.ScriptingValues[QSB.ScriptingValues.Game].Health;
    return self:GetValueAsInteger(GetID(self.m_EntityName), SV);
end

---
-- Setzt die Gesundheit des Entity. Optional kann die Gesundheit relativ zur
-- maximalen Gesundheit geändert werden.
--
-- @param[type=number]  _Health   (Optional) Neue aktuelle Gesundheit
-- @param[type=boolean] _Relative (Optional) Relativ zur maximalen Gesundheit
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:SetHealth(_Health, _Relative)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID > 0 or Logic.IsLeader(EntityID) == 0 then
        local NewHealth = _Health;
        if _Relative then
            _Health = (_Health < 0 and 0) or _Health;
            _Health = (_Health > 100 and 100) or _Health;
            local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
            NewHealth = math.ceil((MaxHealth) * (_Health/100));
        end
        Logic.SetEntityScriptingValue(EntityID, SV, NewHealth);
    end
    return self;
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
    self:SetHealth(self:GetHealth() + _Amount);
end

---
-- Verwundet ein Entity oder ein Battallion um die angegebene
-- Menge an Schaden. Bei einem Battalion wird der Schaden solange
-- auf Soldaten aufgeteilt, bis er komplett verrechnet wurde.
--
-- @param[type=number] _Damage   Schaden
-- @param[type=string] _Attacker Angreifer
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:Hurt(_Damage, _Attacker)
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
            self:TriggerEntityKilledCallbacks(Health, _Attacker);
            if IsLeader and _Damage > 0 then
                self:Hurt(_Damage);
            end
        else
            Logic.HurtEntity(EntityToHurt, _Damage);
            self:TriggerEntityKilledCallbacks(_Damage, _Attacker);
        end
    end
end

---
-- Löst die entsprechenden Callbacks aus, sollte das Entity durch den Schaden
-- durch :Hurt sterben. Callbacks werden nur ausgelöst, wenn der Angreifer
-- angegeben wurde.
--
-- @param[type=number] _Damage   Schaden
-- @param[type=string] _Attacker Angreifer
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:TriggerEntityKilledCallbacks(_Damage, _Attacker)
    local DefenderID = GetID(self.m_EntityName);
    local AttackerID = GetID(_Attacker or 0);
    if AttackerID == 0 or DefenderID == 0 or Logic.GetEntityHealth(DefenderID) > 0 then
        return;
    end
    local x, y, z     = Logic.EntityGetPos(DefenderID);
    local DefPlayerID = Logic.EntityGetPlayer(DefenderID);
    local DefType     = Logic.GetEntityType(DefenderID);
    local AttPlayerID = Logic.EntityGetPlayer(AttackerID);
    local AttType     = Logic.GetEntityType(AttackerID);

    GameCallback_EntityKilled(DefenderID, DefPlayerID, AttackerID, AttPlayerID, DefType, AttType);
    API.Bridge(string.format(
        "GameCallback_Feedback_EntityKilled(%d, %d, %d, %d,%d, %d, %f, %f)",
        DefenderID, DefPlayerID, AttackerID, AttPlayerID, DefType, AttType, x, y
    ));
end

---
-- Gibt zurück, ob das Gebäude brennt.
--
-- @return[type=boolean] Gebäude steht in Flammen
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:IsBurning()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    return Logic.IsBurning(GetID(self.m_EntityName));
end

---
-- Steckt ein Gebäude in Brand.
--
-- @param[type=number]  _FireSize (Optional) Neue aktuelle Gesundheit
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:SetBurning(_FireSize)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    -- TODO: Gebäude per Skript löschen!
    if _FireSize and _FireSize > 0 then
        Logic.DEBUG_SetBuildingOnFire(GetID(self.m_EntityName), _FireSize);
    end
    return self;
end

---
-- Gibt zurück, ob das Entity sichtbar ist.
--
-- @return[type=boolean] Ist sichtbar
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:IsVisible()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    return self:GetValueAsInteger(QSB.ScriptingValues[QSB.ScriptingValues.Game].Visible) == 801280;
end

---
-- Ändert die Sichtbarkeit des Entity
--
-- @param[type=boolean] _Visible (Optional) Sichtbarkeit ändern
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:SetVisible(_Visble)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    Logic.SetVisible(GetID(self.m_EntityName), _Visble);
    return self;
end

---
-- Prüft, ob das Entity krank ist.
--
-- @return[type=boolean] Entity ist krank
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:IsIll()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    local EntityID = GetID(self.m_EntityName);
    if self:InGategory(EntityCategories.CattlePasture) or self:InGategory(EntityCategories.SheepPasture) then
        return Logic.IsFarmAnimalIll(EntityID);
    else
        return Logic.IsIll(EntityID);
    end
end

---
-- Macht das Entity krank.
--
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:MakeIll()
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if self:InGategory(EntityCategories.CattlePasture) or self:InGategory(EntityCategories.SheepPasture) then
        Logic.MakeFarmAnimalIll(EntityID);
    else
        Logic.MakeSettlerIll(EntityID);
    end
    return self;
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
        local SVX = QSB.ScriptingValues[QSB.ScriptingValues.Game].Destination.X
        local SVY = QSB.ScriptingValues[QSB.ScriptingValues.Game].Destination.Y;
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
-- Setzt das Entity oder das Battalion verwundbar oder unverwundbar.
-- 
-- @param[type=boolean] _Flag Verwundbar
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:Vulnerable(_Flag)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    local EntityID = GetID(self.m_EntityName);
    local VulnerabilityFlag = (_Flag and 0) or 1;
    if self:CountSoldiers() > 0 then
        for k, v in pairs(self:GetSoldiers()) do
            Logic.SetEntityInvulnerabilityFlag(v, VulnerabilityFlag);
        end
    end
    Logic.SetEntityInvulnerabilityFlag(EntityID, VulnerabilityFlag);
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
-- Gibt den Typen des Entity zurück.
--
-- @param[type=number] _NewType (optional) Typ neues Entity
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetType(_NewType)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    return Logic.GetEntityType(GetID(self.m_EntityName));
end

---
-- Setzt den Typen des Entity.
--
-- @param[type=number] _NewType (optional) Typ neues Entity
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:SetType(_NewType)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    ReplaceEntity(self.m_EntityName, _NewType);
    return self;
end

---
-- Gibt die aktuelle Tasklist des Entity zurück.
--
-- @return[type=number] Tasklist
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:GetTask(_NewTask)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    local EntityID = GetID(self.m_EntityName);
    local CurrentTask = Logic.GetCurrentTaskList(EntityID);
    return TaskLists[CurrentTask];
end

---
-- Setzt die aktuelle Tasklist des Entity.
--
-- @param[type=number] _NewTask (optional) Neuer Task
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:SetTask(_NewTask)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    Logic.SetTaskList(GetID(self.m_EntityName), _NewTask);
    return self;
end

---
-- Weist dem Entity ein Neues Model zu.
--
-- @param[type=number] _NewModel (optional) Neues Model
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:SetModel(_NewModel)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    Logic.SetModel(GetID(self.m_EntityName), _NewModel);
    return self;
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
-- Prüft, ob das Entity mindestens eine der Kategorien hat
--
-- @param[type=number] ... Liste mit Kategorien
-- @return[type=boolean] Entity hat Kategorie
-- @within QSB.EntityProperty
-- @local
--
function QSB.EntityProperty:InGategory(...)
    assert(self ~= QSB.EntityProperty, "Can not be used in static context!");
    for k, v in pairs(arg) do
        if Inside(v, self:GetGategories()) then
            return true;
        end
    end
    return false;    
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
    return math.floor(Logic.GetEntityScriptingValue(GetID(self.m_EntityName), _index) + 0.5);
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
    return Core:ScriptingValueIntegerToFloat(Logic.GetEntityScriptingValue(GetID(self.m_EntityName), _index));
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleEntityProperties");

