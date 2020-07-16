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
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Gibt den Größenfaktor des Entity zurück.
--
-- Der Faktor gibt an, um wie viel die Größe des Entity verändert wurde, im
-- Vergleich zur normalen Größe. Faktor 1 entspricht der normalen Größe.
--
-- <b>Alias</b>: GetScale
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Größenfaktor des Entity
-- @within Anwenderfunktionen
--
function API.GetEntityScale(_Entity)
    if not IsExisting(_Entity) then
        error("API.EntityGetScale: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    return BundleEntityProperties.Shared:GetValueAsFloat(_Entity, QSB.ScriptingValues[QSB.ScriptingValues.Game].Size);
end
GetScale = API.GetEntityScale;

---
-- Setzt die Größe des Entity. Wenn es sich um einen Siedler handelt, wird
-- versucht einen neuen Speed Factor zu setzen.
--
-- <b>Alias</b>: SetScale
--
-- @param              _Entity Entity (Scriptname oder ID)
-- @param[type=number] _Scale Neuer Größenfaktor
-- @within Anwenderfunktionen
--
function API.SetEntityScale(_Entity, _Scale)
    if GUI then
        return;
    end
    if not IsExisting(_Entity) then
        error("API.SetEntityScale: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if type(_Scale) ~= "number" or _Scale <= 0 then
        error("API.SetEntityScale: _Scale (" ..tostring(_Scale).. ") must be a number above zero!");
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        Logic.SetEntityScriptingValue(EntityID, QSB.ScriptingValues[QSB.ScriptingValues.Game].Size, Core:ScriptingValueFloatToInteger(_Scale));
        if Logic.IsSettler(EntityID) == 1 then
            Logic.SetSpeedFactor(EntityID, _Scale);
        end
    end
end
SetScale = API.SetEntityScale;

---
-- Gibt den Besitzer des Entity zurück.
--
-- <b>Alias</b>: GetPlayer
--
-- @param[type=string] _Entity Scriptname des Entity
-- @return[type=number] Besitzer des Entity
-- @within Anwenderfunktionen
--
function API.GetEntityPlayer(_Entity)
    if not IsExisting(_Entity) then
        error("API.GetEntityPlayer: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    return BundleEntityProperties.Shared:GetValueAsInteger(_Entity, QSB.ScriptingValues[QSB.ScriptingValues.Game].Player);
end
GetPlayer = API.GetEntityPlayer;

---
-- Setzt den Besitzer des Entity.
--
-- <b>Alias</b>: SetPlayer
--
-- @param               _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _PlayerID ID des Besitzers
-- @within Anwenderfunktionen
--
function API.SetEntityPlayer(_Entity, _PlayerID)
    if GUI then
        return;
    end
    if not IsExisting(_Entity) then
        error("API.SetEntityPlayer: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID < 0 or _PlayerID > 8 then
        error("API.SetEntityPlayer: _PlayerID (" ..tostring(_PlayerID).. ") must be a number between 0 and 8!");
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        if API.IsEntityInAtLeastOneCategory (
            EntityID,
            EntityCategories.Leader,
            EntityCategories.CattlePasture,
            EntityCategories.SheepPasture
        ) then
            Logic.ChangeSettlerPlayerID(EntityID, _PlayerID);
        else
            Logic.SetEntityScriptingValue(EntityID, QSB.ScriptingValues[QSB.ScriptingValues.Game].Player, _PlayerID);
        end
    end
end
SetPlayer = API.SetEntityPlayer;

---
-- Gibt die Ausrichtung des Entity zurück.
--
-- <b>Alias</b>: GetOrientation
--
-- @param               _Entity  Entity (Scriptname oder ID)
-- @return[type=number] Ausrichtung in Grad
-- @within Anwenderfunktionen
--
function API.GetEntityOrientation(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return API.Round(Logic.EntityGetOrientation(EntityID));
    end
    error("API.GetEntityOrientation: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return 0;
end
GetOrientation = API.GetEntityOrientation;

---
-- Setzt die Ausrichtung des Entity.
--
-- <b>Alias</b>: SetOrientation
--
-- @param               _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _Orientation Neue Ausrichtung
-- @within Anwenderfunktionen
--
function API.SetEntityOrientation(_Entity, _Orientation)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        if type(_Orientation) ~= "number" then
            error("API.SetEntityOrientation: _Orientation is wrong!");
            return
        end
        Logic.SetOrientation(EntityID, API.Round(_Orientation));
    else
        error("API.SetEntityOrientation: _Entity (" ..tostring(_Entity).. ") does not exist!");
    end
end
SetOrientation = API.SetEntityOrientation;

---
-- Gibt die Menge an Rohstoffen des Entity zurück. Optional kann
-- eine neue Menge gesetzt werden.
--
-- <b>Alias</b>: GetResource
--
-- @param _Entity  Entity (Scriptname oder ID)
-- @return[type=number] Menge an Rohstoffen
-- @within Anwenderfunktionen
--
function API.GetResourceAmount(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return Logic.GetResourceDoodadGoodAmount(EntityID);
    end
    error("API.GetResourceAmount: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return 0;
end
GetResource = API.GetResourceAmount

---
-- Setzt die Menge an Rohstoffen des Entity.
--
-- <b>Alias</b>: SetResource
--
-- @param              _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _Amount Menge an Rohstoffen
-- @within Anwenderfunktionen
--
function API.SetResourceAmount(_Entity, _Amount)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 or Logic.GetResourceDoodadGoodType(EntityID) > 0 then
        if type(_Amount) ~= "number" or _Amount < 0 then
            error("API.SetResourceAmount: _Amount must be 0 or greater!");
            return
        end
        if Logic.GetResourceDoodadGoodAmount(EntityID) == 0 then
            EntityID = ReplaceEntity(EntityID, Logic.EntityGetType(EntityID));
        end
        Logic.SetResourceDoodadGoodAmount(EntityID, _Amount);
    else
        error("API.SetResourceAmount: _Entity (" ..tostring(_Entity).. ") does not exist or is not a resource entity!");
    end
end
SetResource = API.SetResourceAmount;

---
-- Gibt die Gesundheit des Entity zurück.
--
-- <b>Alias</b>: GetHealth
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Aktuelle Gesundheit
-- @within Anwenderfunktionen
--
function API.GetEntityHealth(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return BundleEntityProperties.Shared:GetValueAsInteger(_Entity, QSB.ScriptingValues[QSB.ScriptingValues.Game].Health);
    end
    error("API.GetEntityHealth: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return 0;
end
GetHealth = API.GetEntityHealth;

---
-- Setzt die Gesundheit des Entity. Optional kann die Gesundheit relativ zur
-- maximalen Gesundheit geändert werden.
--
-- <b>Alias</b>: SetHealth
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number]  _Health   Neue aktuelle Gesundheit
-- @param[type=boolean] _Relative (Optional) Relativ zur maximalen Gesundheit
-- @within Anwenderfunktionen
--
function API.ChangeEntityHealth(_Entity, _Health, _Relative)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        local MaxHealth = Logic.EntityGetMaxHealth(EntityID);
        if type(_Health) ~= "number" or _Health < 0 then
            error("API.ChangeEntityHealth: _Health " ..tostring(_Health).. "must be 0 or greater!");
            return
        end
        _Health = (_Health > MaxHealth and MaxHealth) or _Health;
        if Logic.IsLeader(EntityID) == 1 then
            for k, v in pairs(API.GetGroupSoldiers(EntityToHurt)) do
                API.ChangeEntityHealth(v, _Health, _Relative)
            end
        else
            local NewHealth = _Health;
            if _Relative then
                _Health = (_Health < 0 and 0) or _Health;
                _Health = (_Health > 100 and 100) or _Health;
                NewHealth = math.ceil((MaxHealth) * (_Health/100));
            end
            Logic.SetEntityScriptingValue(EntityID, QSB.ScriptingValues[QSB.ScriptingValues.Game].Health, NewHealth);
        end
        return;
    end
    error("API.ChangeEntityHealth: _Entity (" ..tostring(_Entity).. ") does not exist!");
end
SetHealth = API.ChangeEntityHealth;

---
-- Heilt das Entity um die angegebene Menge an Gesundheit.
--
-- <b>Alias</b>: HealEntity
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number]  _Amount   Geheilte Gesundheit
-- @within Anwenderfunktionen
--
function API.GroupHeal(_Entity, _Amount)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 or Logic.IsLeader(EntityID) == 1 then
        error("API.GroupHeal: _Entity (" ..tostring(_Entity).. ") must be an existing leader!");
        return;
    end
    if type(_Amount) ~= "number" or _Amount < 0 then
        error("API.GroupHeal: _Amount (" ..tostring(_Amount).. ") must greatier than 0!");
        return;
    end
    API.ChangeEntityHealth(EntityID, API.GetEntityHealth(EntityID) + _Amount);
end
HealEntity = API.GroupHeal;

---
-- Verwundet ein Entity oder ein Battallion um die angegebene
-- Menge an Schaden. Bei einem Battalion wird der Schaden solange
-- auf Soldaten aufgeteilt, bis er komplett verrechnet wurde.
--
-- <b>Alias</b>: HurtEntity
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number] _Damage   Schaden
-- @param[type=string] _Attacker Angreifer
-- @within Anwenderfunktionen
--
function API.GroupHurt(_Entity, _Damage, _Attacker)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GroupHurt: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if API.IsEntityInAtLeastOneCategory(EntityID, EntityCategories.Soldier) then
        API.GroupHurt(API.GetGroupLeader(EntityID), _Damage);
        return;
    end

    local EntityToHurt = EntityID;
    local IsLeader = Logic.IsLeader(EntityToHurt) == 1;
    if IsLeader then
        EntityToHurt = API.GetGroupSoldiers(EntityToHurt)[1];
    end
    if type(_Damage) ~= "number" or _Damage < 0 then
        error("API.GroupHurt: _Damage (" ..tostring(_Damage).. ") must be greater than 0!");
        return;
    end

    local EntityKilled = false;
    local Health = Logic.EntityGetHealth(EntityToHurt);
    if EntityToHurt then
        if Health <= _Damage then
            _Damage = _Damage - Health;
            EntityKilled = true;
            Logic.HurtEntity(EntityToHurt, Health);
            BundleEntityProperties.Global:TriggerEntityKilledCallbacks(EntityToHurt, Health, _Attacker);
            if IsLeader and _Damage > 0 then
                API.GroupHurt(EntityToHurt, _Damage);
            end
        else
            Logic.HurtEntity(EntityToHurt, _Damage);
            BundleEntityProperties.Global:TriggerEntityKilledCallbacks(EntityToHurt, _Damage, _Attacker);
        end
    end
end
HurtEntity = API.GroupHurt;

---
-- Gibt zurück, ob das Gebäude brennt.
--
-- <b>Alias</b>: IsBurning
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=boolean] Gebäude steht in Flammen
-- @within Anwenderfunktionen
--
function API.IsBuildingBurning(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.IsBuildingBurning: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    return Logic.IsBurning(EntityID);
end
IsBurning = API.IsBuildingBurning;

---
-- Steckt ein Gebäude in Brand.
--
-- <b>Alias</b>: SetBurning
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number]  _FireSize (Optional) Neue aktuelle Gesundheit
-- @within Anwenderfunktionen
--
function API.SetEntityBuildingBurning(_Entity, _FireSize)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.SetEntityBuildingBurning: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    -- TODO: Gebäude per Skript löschen!
    if _FireSize and _FireSize > 0 then
        Logic.DEBUG_SetBuildingOnFire(EntityID, _FireSize);
    end
end
SetBurning = API.SetEntityBuilding;

---
-- Gibt zurück, ob das Entity sichtbar ist.
--
-- <b>Alias</b>: IsVisible
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=boolean] Ist sichtbar
-- @within Anwenderfunktionen
--
function API.IsEntityVisible(_Entity)
    if not IsExisting(_Entity) then
        error("API.IsEntityVisible: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return false;
    end
    return BundleEntityProperties.Shared:GetValueAsInteger(_Entity, QSB.ScriptingValues[QSB.ScriptingValues.Game].Visible) == 801280;
end
IsVisible = API.IsEntityVisible;

---
-- Ändert die Sichtbarkeit des Entity.
--
-- <b>Alias</b>: SetVisible
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=boolean] _Visible (Optional) Sichtbarkeit ändern
-- @within Anwenderfunktionen
--
function API.SetEntityVisible(_Entity, _Visble)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.SetEntityVisible: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    Logic.SetVisible(EntityID, _Visble == true);
end
SetVisible = API.SetEntityVisible;

---
-- Prüft, ob das Entity krank ist.
--
-- <b>Alias</b>: IsIll
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=boolean] Entity ist krank
-- @within Anwenderfunktionen
--
function API.IsEntityIll(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.IsEntityIll: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return false;
    end
    if API.IsEntityInAtLeastOneCategory(
        EntityID,
        EntityCategories.CattlePasture,
        EntityCategories.SheepPasture
    ) then
        return Logic.IsFarmAnimalIll(EntityID);
    else
        return Logic.IsIll(EntityID);
    end
end
IsIll = API.IsEntityIll;

---
-- Macht das Entity krank.
--
-- <b>Alias</b>: MakeIll
--
-- @param _Entity Entity (Scriptname oder ID)
-- @within Anwenderfunktionen
--
function API.MakeEntityIll(_Entity)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.MakeEntityIll: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if API.IsEntityInAtLeastOneCategory(
        EntityID,
        EntityCategories.CattlePasture,
        EntityCategories.SheepPasture
    ) then
        Logic.MakeFarmAnimalIll(EntityID);
    else
        Logic.MakeSettlerIll(EntityID);
    end
end
MakeIll = API.MakeEntityIll;

---
-- Gibt zurück, ob eine NPC-Interaktion mit dem Siedler möglich ist.
--
-- <b>Alias</b>: IsNpc
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=boolean] Ist NPC
-- @within Anwenderfunktionen
--
function API.IsEntityActiveNpc(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return BundleEntityProperties.Shared:GetValueAsInteger(EntityID, 6) > 0;
    end
    error("API.IsEntityActiveNpc: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return false;
end
IsNpc = API.IsEntityActiveNpc;

---
-- Gibt das Bewegungsziel des Entity zurück.
--
-- <b>Alias</b>: GetDestination
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=table] Positionstabelle
-- @within Anwenderfunktionen
--
function API.GetEntityMovementTarget(_Entity)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        local SVX = QSB.ScriptingValues[QSB.ScriptingValues.Game].Destination.X
        local SVY = QSB.ScriptingValues[QSB.ScriptingValues.Game].Destination.Y;
        return {
            X= BundleEntityProperties.Shared:GetValueAsFloat(SVX),
            Y= BundleEntityProperties.Shared:GetValueAsFloat(SVY),
            Z= 0
        };
    end
    error("API.GetEntityMovementTarget: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return {X= 0, Y= 0, Z= 0};
end
GetDestination = API.GetEntityMovementTarget;

---
-- Setzt das Entity oder das Battalion verwundbar oder unverwundbar.
--
-- Wenn ein Skriptname angegeben wird, wird fortlaufend geprüft, ob sich die
-- ID geändert hat und das Ziel erneut unverwundbar gemacht werden muss.
--
-- <b>Alias</b>: SetVulnerable
-- 
-- @param               _Entity Entity (Scriptname oder ID)
-- @param[type=boolean] _Flag Verwundbar
-- @within Anwenderfunktionen
--
function API.SetEntityVulnerablueFlag(_Entity, _Flag)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    local VulnerabilityFlag = (_Flag and 0) or 1;
    if EntityID > 0 then
        if API.CountSoldiersOfGroup(EntityID) > 0 then
            for k, v in pairs(API.GetGroupSoldiers(EntityID)) do
                Logic.SetEntityInvulnerabilityFlag(v, VulnerabilityFlag);
            end
        end
        Logic.SetEntityInvulnerabilityFlag(EntityID, VulnerabilityFlag);
        -- Unverwundbarkeitsüberwachung
        if type(_Entity) == "string" then
            if _Flag == true then
                BundleEntityProperties.Global.Data.InvulnerableEntityNames[_Entity] = EntityID;
            else
                BundleEntityProperties.Global.Data.InvulnerableEntityNames[_Entity] = nil;
            end
        end
    end
end
SetVulnerable = API.SetEntityVulnerablueFlag;

MakeVulnerable = function(_Entity)
    API.SetEntityVulnerablueFlag(_Entity, true);
end
MakeInvulnerable = function(_Entity)
    API.SetEntityVulnerablueFlag(_Entity, false);
end

---
-- Gibt den Typen des Entity zurück.
--
-- <b>Alias</b>: GetType
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Typ des Entity
-- @within Anwenderfunktionen
--
function API.GetEntityType(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return Logic.EntityGetType(EntityID);
    end
    error("API.EntityGetType: _Entity (" ..tostring(_Entity).. ") must be a leader with soldiers!");
    return 0;
end
GetType = API.GetEntityType

---
-- Gibt den Typnamen des Entity zurück.
--
-- <b>Alias</b>: GetTypeName
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=string] Typname des Entity
-- @within Anwenderfunktionen
--
function API.GetEntityTypeName(_Entity)
    if not IsExisting(_Entity) then
        error("API.GetEntityTypeName: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    return Logic.EntityGetTypeName(API.GetEntityType(_Entity));
end
GetTypeName = API.GetEntityTypeName;

---
-- Setzt den Typen des Entity.
--
-- <b>Alias</b>: SetType
--
-- @param              _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _NewType Typ neues Entity
-- @within Anwenderfunktionen
--
function API.SetEntityType(_Entity, _NewType)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.SetEntityType: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    ReplaceEntity(EntityID, _NewType);
end
SetType = API.SetEntityType;

---
-- Gibt die aktuelle Tasklist des Entity zurück.
--
-- <b>Alias</b>: GetTask
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Tasklist
-- @within Anwenderfunktionen
--
function API.GetEntityTaskList(_Entity, _NewTask)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetEntityTaskList: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    local CurrentTask = Logic.GetCurrentTaskList(EntityID);
    return TaskLists[CurrentTask];
end
GetTask = API.GetEntityTaskList;

---
-- Setzt die aktuelle Tasklist des Entity.
--
-- <b>Alias</b>: SetTask
--
-- @param              _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _NewTask Neuer Task
-- @within Anwenderfunktionen
--
function API.SetEntityTaskList(_Entity, _NewTask)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.SetEntityTaskList: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if type(_NewTask) ~= "number" or _NewTask < 1 then
        error("API.SetEntityTaskList: _NewTask (" ..tostring(_NewTask).. ") is wrong!");
        return;
    end
    Logic.SetTaskList(EntityID, _NewTask);
end
SetTask = API.SetEntityTaskList;

---
-- Weist dem Entity ein Neues Model zu.
--
-- <b>Alias</b>: SetModel
--
-- @param              _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _NewModel Neues Model
-- @param[type=number] _AnimSet  (optional) Animation Set
-- @within Anwenderfunktionen
--
function API.SetEntityModel(_Entity, _NewModel, _AnimSet)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.SetEntityModel: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if type(_NewModel) ~= "number" or _NewModel < 1 then
        error("API.SetEntityModel: _NewModel (" ..tostring(_NewModel).. ") is wrong!");
        return;
    end
    if _AnimSet and (type(_AnimSet) ~= "number" or _AnimSet < 1) then
        error("API.SetEntityModel: _AnimSet (" ..tostring(_AnimSet).. ") is wrong!");
        return;
    end
    if not _AnimSet then
        Logic.SetModel(EntityID, _NewModel);
    else
        Logic.SetModelAndAnimSet(EntityID, _NewModel, _AnimSet);
    end
end
SetModel = API.SetEntityModel;

---
-- Gibt die Mänge an Soldaten zurück, die dem Entity unterstehen
--
-- <b>Alias</b>: CoundSoldiers
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=number] Menge an Soldaten
-- @within Anwenderfunktionen
--
function API.CountSoldiersOfGroup(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.CountSoldiersOfGroup: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    if Logic.IsLeader(EntityID) == 0 then
        return 0;
    end
    local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
    return SoldierTable[1];
end
CoundSoldiers = API.CountSoldiersOfGroup;

---
-- Gibt die IDs aller Soldaten zurück, die zum Battalion gehören.
--
-- <b>Alias</b>: GetSoldiers
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=table] Liste aller Soldaten
-- @within Anwenderfunktionen
--
function API.GetGroupSoldiers(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetGroupSoldiers: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return {};
    end
    if Logic.IsLeader(EntityID) == 0 then
        return {};
    end
    local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
    table.remove(SoldierTable, 1);
    return SoldierTable;
end
GetSoldiers = API.GetGroupSoldiers;

---
-- Gibt den Leader des Soldaten zurück.
--
-- <b>Alias</b>: GetLeader
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=number] Menge an Soldaten
-- @within Anwenderfunktionen
--
function API.GetGroupLeader(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetGroupLeader: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Soldier) == 0 then 
        return 0;
    end
    return Logic.SoldierGetLeaderEntityID(EntityID);
end
GetLeader = API.GetGroupLeader;

---
-- Gibt alle Kategorien zurück, zu denen das Entity gehört.
--
-- <b>Alias</b>: GetCategories
--
-- @param              _Entity Entity (Skriptname oder ID)
-- @return[type=table] Kategorien des Entity
-- @within Internal
-- @local
--
function API.GetEntityCategoyList(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetEntityCategoyList: _Entity (" ..tostring(_Entity).. ") does not exist!");
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
GetCategories = API.GetEntityCategoyList;

---
-- Prüft, ob das Entity mindestens eine der Kategorien hat.
--
-- <b>Alias</b>: IsInCategory
--
-- @param              _Entity Entity (Skriptname oder ID)
-- @param[type=number] ...     Liste mit Kategorien
-- @return[type=boolean] Entity hat Kategorie
-- @within Internal
-- @local
--
function API.IsEntityInAtLeastOneCategory(_Entity, ...)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        for k, v in pairs(arg) do
            if Inside(v, API.GetEntityCategoyList(_Entity)) then
                return true;
            end
        end
        return;
    end
    error("API.IsEntityInAtLeastOneCategory: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return false;
end
IsInCategory = API.IsEntityInAtLeastOneCategory;

-- -------------------------------------------------------------------------- --
-- Internal                                                                   --
-- -------------------------------------------------------------------------- --

BundleEntityProperties = {
    Global = {
        Data = {
            InvulnerableEntityNames = {},
        };
    },
    Shared = {
        Data = {};
    },
}

---
-- Installiert das Bundle.
--
function BundleEntityProperties.Global:Install()
    StartSimpleHiResJobEx(function()
        self:InvulnerabilityJob()
    end);
end

---
-- Setzt ein unverwundbares Entity wieder unverwundbar, wenn sich die ID
-- geändert hat.
-- @within Internal
-- @local
--
function BundleEntityProperties.Global:InvulnerabilityJob()
    for k, v in pairs(self.Data.InvulnerableEntityNames) do
        local ID = GetID(k);
        if v and ID ~= v then
            API.EntitySetVulnerablueFlag(k, false);
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
-- @within Internal
-- @local
--
function BundleEntityProperties.Global:TriggerEntityKilledCallbacks(_Entity, _Damage, _Attacker)
    local DefenderID = GetID(_Entity);
    local AttackerID = GetID(_Attacker or 0);
    if AttackerID == 0 or DefenderID == 0 or Logic.EntityGetHealth(DefenderID) > 0 then
        return;
    end
    local x, y, z     = Logic.EntityGetPos(DefenderID);
    local DefPlayerID = Logic.EntityGetPlayer(DefenderID);
    local DefType     = Logic.EntityGetType(DefenderID);
    local AttPlayerID = Logic.EntityGetPlayer(AttackerID);
    local AttType     = Logic.EntityGetType(AttackerID);

    GameCallback_EntityKilled(DefenderID, DefPlayerID, AttackerID, AttPlayerID, DefType, AttType);
    API.Bridge(string.format(
        "GameCallback_Feedback_EntityKilled(%d, %d, %d, %d,%d, %d, %f, %f)",
        DefenderID, DefPlayerID, AttackerID, AttPlayerID, DefType, AttType, x, y
    ));
end

---
-- Gibt die Scripting Value des Entity als Ganzzahl zurück.
--
-- @param              _Entity Entity (Skriptname oder ID)
-- @param[type=number] _Index  Index im RAM
-- @return[type=number] Ganzzahl
-- @within Internal
-- @local
--
function BundleEntityProperties.Shared:GetValueAsInteger(_Entity, _Index)
    return math.floor(Logic.EntityGetScriptingValue(GetID(_Entity), _Index) + 0.5);
end

---
-- Gibt die Scripting Value des Entity als Dezimalzahl zurück.
--
-- @param              _Entity Entity (Skriptname oder ID)
-- @param[type=number] _index  Index im RAM
-- @return[type=number] Dezimalzahl
-- @within Internal
-- @local
--
function BundleEntityProperties.Shared:GetValueAsFloat(_Entity, _Index)
    return Core:ScriptingValueIntegerToFloat(Logic.EntityGetScriptingValue(GetID(_Entity), _Index));
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleEntityProperties");

