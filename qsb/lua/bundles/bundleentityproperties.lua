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
function API.EntityGetScale(_Entity)
    return BundleEntityProperties.Shared:GetValueAsFloat(_Entity, QSB.ScriptingValues[QSB.ScriptingValues.Game].Size);
end
API.GetEntityScale = API.EntityGetScale;
GetScale = API.EntityGetScale;

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
function API.EntitySetScale(_Entity, _Scale)
    if GUI then
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
API.SetEntityScale = API.EntitySetScale;
SetScale = API.EntitySetScale;

---
-- Gibt den Besitzer des Entity zurück.
--
-- <b>Alias</b>: GetPlayer
--
-- @param[type=string] _Entity Scriptname des Entity
-- @return[type=number] Besitzer des Entity
-- @within Anwenderfunktionen
--
function API.EntityGetPlayer(_Entity)
    return BundleEntityProperties.Shared:GetValueAsInteger(_Entity, QSB.ScriptingValues[QSB.ScriptingValues.Game].Player);
end
API.GetEntityPlayer = API.EntityGetPlayer;
GetPlayer = API.EntityGetPlayer;

---
-- Setzt den Besitzer des Entity.
--
-- <b>Alias</b>: SetPlayer
--
-- @param               _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _PlayerID ID des Besitzers
-- @within Anwenderfunktionen
--
function API.EntitySetPlayer(_Entity, _PlayerID)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        if API.EntityIsInAtLeastOneCategory (
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
API.SetEntityPlayer = API.EntitySetPlayer;
SetPlayer = API.EntitySetPlayer;

---
-- Gibt die Ausrichtung des Entity zurück.
--
-- <b>Alias</b>: GetOrientation
--
-- @param               _Entity  Entity (Scriptname oder ID)
-- @return[type=number] Ausrichtung in Grad
-- @within Anwenderfunktionen
--
function API.EntityGetOrientation(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return API.Round(Logic.GetEntityOrientation(EntityID));
    end
    return 0;
end
GetOrientation = API.EntityGetOrientation;

---
-- Setzt die Ausrichtung des Entity.
--
-- <b>Alias</b>: SetOrientation
--
-- @param               _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _Orientation Neue Ausrichtung
-- @within Anwenderfunktionen
--
function API.EntitySetOrientation(_Entity, _Orientation)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        Logic.SetOrientation(EntityID, API.Round(_Orientation));
    end
end
SetOrientation = API.EntitySetOrientation;

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
function API.ResourceGetAmount(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return Logic.GetResourceDoodadGoodAmount(EntityID);
    end
    return 0;
end
GetResource = API.ResourceGetAmount

---
-- Setzt die Menge an Rohstoffen des Entity.
--
-- <b>Alias</b>: SetResource
--
-- @param              _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _Amount Menge an Rohstoffen
-- @within Anwenderfunktionen
--
function API.ResourceSetAmount(_Entity, _Amount)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 or Logic.GetResourceDoodadGoodType(EntityID) > 0 then
        if Logic.GetResourceDoodadGoodAmount(EntityID) == 0 then
            EntityID = ReplaceEntity(EntityID, Logic.GetEntityType(EntityID));
        end
        Logic.SetResourceDoodadGoodAmount(EntityID, _Amount);
    end
end
SetResource = API.ResourceSetAmount;

---
-- Gibt die Gesundheit des Entity zurück.
--
-- <b>Alias</b>: GetHealth
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Aktuelle Gesundheit
-- @within Anwenderfunktionen
--
function API.EntityGetHealth(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return BundleEntityProperties.Shared:GetValueAsInteger(_Entity, QSB.ScriptingValues[QSB.ScriptingValues.Game].Health);
    end
    return 0;
end
GetHealth = API.EntityGetHealth;

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
function API.EntityChangeHealth(_Entity, _Health, _Relative)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        if Logic.IsLeader(EntityID) == 1 then
            for k, v in pairs(API.GroupGetSoldiers(EntityToHurt)) do
                API.EntityChangeHealth(v, _Health, _Relative)
            end
        else
            local NewHealth = _Health;
            if _Relative then
                _Health = (_Health < 0 and 0) or _Health;
                _Health = (_Health > 100 and 100) or _Health;
                local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
                NewHealth = math.ceil((MaxHealth) * (_Health/100));
            end
            Logic.SetEntityScriptingValue(EntityID, QSB.ScriptingValues[QSB.ScriptingValues.Game].Health, NewHealth);
        end
    end
end
SetHealth = API.EntityChangeHealth;

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
        return;
    end
    API.EntityChangeHealth(EntityID, API.EntityGetHealth(EntityID) + _Amount);
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
        return;
    end
    if API.EntityIsInAtLeastOneCategory(EntityID, EntityCategories.Soldier) then
        API.GroupHurt(API.GroupGetLeader(EntityID), _Damage);
        return;
    end

    local EntityToHurt = EntityID;
    local IsLeader = Logic.IsLeader(EntityToHurt) == 1;
    if IsLeader then
        EntityToHurt = API.GroupGetSoldiers(EntityToHurt)[1];
    end

    local EntityKilled = false;
    local Health = Logic.GetEntityHealth(EntityToHurt);
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
function API.EntityIsBuildingBurning(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        return 0;
    end
    return Logic.IsBurning(EntityID);
end
IsBurning = API.EntityIsBuildingBurning;

---
-- Steckt ein Gebäude in Brand.
--
-- <b>Alias</b>: SetBurning
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number]  _FireSize (Optional) Neue aktuelle Gesundheit
-- @within Anwenderfunktionen
--
function API.EntitySetBuildingBurning(_Entity, _FireSize)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        return;
    end
    -- TODO: Gebäude per Skript löschen!
    if _FireSize and _FireSize > 0 then
        Logic.DEBUG_SetBuildingOnFire(EntityID, _FireSize);
    end
end
SetBurning = API.EntitySetBuilding;

---
-- Gibt zurück, ob das Entity sichtbar ist.
--
-- <b>Alias</b>: IsVisible
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=boolean] Ist sichtbar
-- @within Anwenderfunktionen
--
function API.EntityIsVisible(_Entity)
    return BundleEntityProperties.Shared:GetValueAsInteger(_Entity, QSB.ScriptingValues[QSB.ScriptingValues.Game].Visible) == 801280;
end
IsVisible = API.EntityIsVisible;

---
-- Ändert die Sichtbarkeit des Entity.
--
-- <b>Alias</b>: SetVisible
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=boolean] _Visible (Optional) Sichtbarkeit ändern
-- @within Anwenderfunktionen
--
function API.EntitySetVisible(_Entity, _Visble)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        return;
    end
    Logic.SetVisible(EntityID, _Visble);
end
SetVisible = API.EntitySetVisible;

---
-- Prüft, ob das Entity krank ist.
--
-- <b>Alias</b>: IsIll
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=boolean] Entity ist krank
-- @within Anwenderfunktionen
--
function API.EntityIsIll(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        return false;
    end
    if API.EntityIsInAtLeastOneCategory(
        EntityID,
        EntityCategories.CattlePasture,
        EntityCategories.SheepPasture
    ) then
        return Logic.IsFarmAnimalIll(EntityID);
    else
        return Logic.IsIll(EntityID);
    end
end
IsIll = API.EntityIsIll;

---
-- Macht das Entity krank.
--
-- <b>Alias</b>: MakeIll
--
-- @param _Entity Entity (Scriptname oder ID)
-- @within Anwenderfunktionen
--
function API.EntityMakeIll(_Entity)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        return;
    end
    if API.EntityIsInAtLeastOneCategory(
        EntityID,
        EntityCategories.CattlePasture,
        EntityCategories.SheepPasture
    ) then
        Logic.MakeFarmAnimalIll(EntityID);
    else
        Logic.MakeSettlerIll(EntityID);
    end
end
MakeIll = API.EntityMakeIll;

---
-- Gibt zurück, ob eine NPC-Interaktion mit dem Siedler möglich ist.
--
-- <b>Alias</b>: IsNpc
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=boolean] Ist NPC
-- @within Anwenderfunktionen
--
function API.EntityIsActiveNpc(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return BundleEntityProperties.Shared:GetValueAsInteger(EntityID, 6) > 0;
    end
    return false;
end
IsNpc = API.EntityIsActiveNpc;

---
-- Gibt das Bewegungsziel des Entity zurück.
--
-- <b>Alias</b>: GetDestination
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=table] Positionstabelle
-- @within Anwenderfunktionen
--
function API.EntityGetMovementTarget(_Entity)
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
    return {X= 0, Y= 0, Z= 0};
end
GetDestination = API.EntityGetMovementTarget;

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
function API.EntitySetVulnerablueFlag(_Entity, _Flag)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    local VulnerabilityFlag = (_Flag and 0) or 1;
    if EntityID > 0 and API.GroupCountSoldiers(EntityID) > 0 then
        for k, v in pairs(API.GroupGetSoldiers(EntityID)) do
            Logic.SetEntityInvulnerabilityFlag(v, VulnerabilityFlag);
        end
    end
    Logic.SetEntityInvulnerabilityFlag(EntityID, VulnerabilityFlag);
    -- Unverwundbarkeitsüberwachung
    if type(_Entity) == "string" then
        if VulnerabilityFlag == 0 then
            BundleEntityProperties.Global.Data.InvulnerableEntityNames[_Entity] = true;
        else
            BundleEntityProperties.Global.Data.InvulnerableEntityNames[_Entity] = nil;
        end
    end
end
SetVulnerable = API.EntitySetVulnerablueFlag;

MakeVulnerable = function(_Entity)
    API.EntitySetVulnerablueFlag(_Entity, true);
end
MakeInvulnerable = function(_Entity)
    API.EntitySetVulnerablueFlag(_Entity, false);
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
function API.EntityGetType(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return Logic.GetEntityType(EntityID);
    end
    return 0;
end
GetType = API.EntityGetType

---
-- Gibt den Typnamen des Entity zurück.
--
-- <b>Alias</b>: GetTypeName
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=string] Typname des Entity
-- @within Anwenderfunktionen
--
function API.EntityGetTypeName(_Entity)
    return Logic.GetEntityTypeName(API.EntityGetType(_Entity));
end
GetTypeName = API.EntityGetTypeName;

---
-- Setzt den Typen des Entity.
--
-- <b>Alias</b>: SetType
--
-- @param              _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _NewType Typ neues Entity
-- @within Anwenderfunktionen
--
function API.EntitySetType(_Entity, _NewType)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        ReplaceEntity(EntityID, _NewType);
    end
end
SetType = API.EntitySetType;

---
-- Gibt die aktuelle Tasklist des Entity zurück.
--
-- <b>Alias</b>: GetTask
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Tasklist
-- @within Anwenderfunktionen
--
function API.EntityGetTaskList(_Entity, _NewTask)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        local CurrentTask = Logic.GetCurrentTaskList(EntityID);
        return TaskLists[CurrentTask];
    end
    return 0;
end
GetTask = API.EntityGetTaskList;

---
-- Setzt die aktuelle Tasklist des Entity.
--
-- <b>Alias</b>: SetTask
--
-- @param              _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _NewTask (optional) Neuer Task
-- @within Anwenderfunktionen
--
function API.EntitySetTaskList(_Entity, _NewTask)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        Logic.SetTaskList(EntityID, _NewTask);
    end
end
SetTask = API.EntitySetTaskList;

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
function API.EntitySetModel(_Entity, _NewModel, _AnimSet)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        if not _AnimSet then
            Logic.SetModel(EntityID, _NewModel);
        else
            Logic.SetModelAndAnimSet(EntityID, _NewModel, _AnimSet);
        end
    end
end
SetModel = API.EntitySetModel;

---
-- Gibt die Mänge an Soldaten zurück, die dem Entity unterstehen
--
-- <b>Alias</b>: CoundSoldiers
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=number] Menge an Soldaten
-- @within Anwenderfunktionen
--
function API.GroupCountSoldiers(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 and Logic.IsLeader(EntityID) == 1 then
        local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
        return SoldierTable[1];
    end
    return 0;
end
CoundSoldiers = API.GroupCountSoldiers;

---
-- Gibt die IDs aller Soldaten zurück, die zum Battalion gehören.
--
-- <b>Alias</b>: GetSoldiers
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=table] Liste aller Soldaten
-- @within Anwenderfunktionen
--
function API.GroupGetSoldiers(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 and Logic.IsLeader(EntityID) == 1 then
        local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
        table.remove(SoldierTable, 1);
        return SoldierTable;
    end
    return {};
end
GetSoldiers = API.GroupGetSoldiers;

---
-- Gibt den Leader des Soldaten zurück.
--
-- <b>Alias</b>: GetLeader
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=number] Menge an Soldaten
-- @within Anwenderfunktionen
--
function API.GroupGetLeader(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 and Logic.IsEntityInCategory(EntityID, EntityCategories.Soldier) == 1 then
        return Logic.SoldierGetLeaderEntityID(EntityID);
    end
    return 0;
end
GetLeader = API.GroupGetLeader;

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
function API.EntityGetCategoyList(_Entity)
    local EntityID = GetID(_Entity);
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
GetCategories = API.EntityGetCategoyList;

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
function API.EntityIsInAtLeastOneCategory(_Entity, ...)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        for k, v in pairs(arg) do
            if Inside(v, API.EntityGetCategoyList(_Entity)) then
                return true;
            end
        end
    end
    return false;
end
IsInCategory = API.EntityIsInAtLeastOneCategory;

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
            API.EntitySetVulnerablueFlag(k, not v);
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
-- Gibt die Scripting Value des Entity als Ganzzahl zurück.
--
-- @param              _Entity Entity (Skriptname oder ID)
-- @param[type=number] _Index  Index im RAM
-- @return[type=number] Ganzzahl
-- @within Internal
-- @local
--
function BundleEntityProperties.Shared:GetValueAsInteger(_Entity, _Index)
    return math.floor(Logic.GetEntityScriptingValue(GetID(_Entity), _Index) + 0.5);
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
    return Core:ScriptingValueIntegerToFloat(Logic.GetEntityScriptingValue(GetID(_Entity), _index));
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleEntityProperties");

