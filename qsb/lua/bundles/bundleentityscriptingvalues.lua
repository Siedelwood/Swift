-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntityScriptingValues                                  # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Bundle können Eigenschaften von Entities abgefragt oder
-- verändert werden, die sonst unzugänglich wären. Dazu zählen beispielsweise
-- die Größe des Entity und das Bewegungsziel.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleEntityScriptingValues = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Gibt den Größenfaktor des Entity zurück.
--
-- <p>Der Faktor gibt die relative Größe des Entity zu seiner normalen Größe an.
-- </p>
--
-- <p><b>Alias</b>: GetScale</p>
--
-- @param[type=string] _Entity Entity
-- @return[type=number] Größenfaktor
-- @within Anwenderfunktionen
--
-- @usage
-- local Scale = API.GetEntityScale("alandra")
--
function API.GetEntityScale(_Entity)
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Fatal("API.GetEntityScale: Target " ..Subject.. " is invalid!");
        return -1;
    end
    return EntityScriptingValue:GetInstance(_Entity):GetEntitySize();
end
GetScale = API.GetEntityScale;

---
-- Gibt den Besitzer des Entity zurück.
--
-- <p><b>Alias</b>: GetPlayer</p>
--
-- @param[type=string] _Entity Entity
-- @return[type=number] Besitzer
-- @within Anwenderfunktionen
--
function API.GetEntityPlayer(_Entity)
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Fatal("API.GetEntityPlayer: Target " ..Subject.. " is invalid!");
        return -1;
    end
    return EntityScriptingValue:GetInstance(_Entity):GetPlayerID();
end
GetPlayer = API.GetEntityPlayer;

---
-- Gibt die Position zurück, zu der sich das Entity bewegt.
--
-- Über diese Koordinaten könnte man prüfen, ob ein Entity sich in einen
-- Bereich bewegt, in dem es nichts zu suchen hat.
--
-- <p><b>Alias</b>: GetMovingTarget</p>
--
-- @param[type=string] _Entity Entity
-- @return[type=table] Positionstabelle
-- @within Anwenderfunktionen
--
-- @usage
-- -- Hakim bleibt stehen, wenn er in ein Sperrgebiet bewegt wird.
-- local Destination = API.GetMovementTarget("hakim");
-- if GetDistance(Destination, "LockedArea") < 2000 then
--     local x,y,z = Logic.EntityGetPos(GetID("hakim"));
--     Logic.DEBUG_SetSettlerPosition(GetID("hakim"), x, y):
-- end
--
function API.GetMovementTarget(_Entity)
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Fatal("API.GetMovementTarget: Target " ..Subject.. " is invalid!");
        return nil;
    end
    return EntityScriptingValue:GetInstance(_Entity):GetMovingTargetPosition();
end
GetMovingTarget = API.GetMovementTarget;

---
-- Gibt zurück, ob das NPC-Flag bei dem Siedler gesetzt ist.
--
-- Auf diese Weise kann geprüft werden, ob ein NPC auf dem Entity aktiv ist.
--
-- <p><b>Alias</b>: IsNpc</p>
--
-- @param[type=string] _Entity Entity
-- @return[type=boolean] Ist NPC
-- @within Anwenderfunktionen
--
-- @usage
-- local Active = API.IsActiveNpc("alandra");
-- if Active then
--     API.Note("NPC is active");
-- end
--
function API.IsActiveNpc(_Entity)
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Fatal("API.IsActiveNpc: Target " ..Subject.. " is invalid!");
        return false;
    end
    return EntityScriptingValue:GetInstance(_Entity):IsOnScreenInformationActive();
end
IsNpc = API.IsActiveNpc;

---
-- Gibt zurück, ob das Entity sichtbar ist.
--
-- <p><b>Alias</b>: IsVisible</p>
--
-- @param[type=string] _Entity Entity
-- @return[type=boolean] Ist sichtbar
-- @within Anwenderfunktionen
--
function API.IsEntityVisible(_Entity)
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Fatal("API.IsEntityVisible: Target " ..Subject.. " is invalid!");
        return false;
    end
    return EntityScriptingValue:GetInstance(_Entity):IsEntityVisible();
end
IsVisible = API.IsEntityVisible;

---
-- Setzt den Größenfaktor des Entity.
--
-- Bei einem Siedler wird ebenfalls versucht die Bewegungsgeschwindigkeit an
-- die Größe anzupassen, was aber nicht bei allen Siedlern möglich ist.
--
-- <p><b>Alias</b>: SetScale</p>
--
-- @param[type=string] _Entity Entity
-- @param[type=number] _Scale Größenfaktor
-- @within Anwenderfunktionen
--
function API.SetEntityScale(_Entity, _Scale)
    if GUI or not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Fatal("API.SetEntityScale: Target " ..Subject.. " is invalid!");
        return;
    end
    if type(_Scale) ~= "number" then
        API.Fatal("API.SetEntityScale: Scale must be a number!");
        return;
    end
    EntityScriptingValue:GetInstance(_Entity):SetEntitySize(_Scale);
end
SetScale = API.SetEntityScale;

---
-- Erzwingt einen neuen Besitzer für das Entity.
--
-- Mit dieser Funktion werden die Sicherungen des Spiels umgangen! Es ist
-- möglich ein Raubtier einem richtigen Spieler zuzuweisen.
--
-- <p><b>Alias</b>: ChangePlayer</p>
--
-- @param[type=string] _Entity Entity
-- @param[type=number] _PlayerID Besitzer
-- @within Anwenderfunktionen
--
function API.SetEntityPlayer(_Entity, _PlayerID)
    if GUI or not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Fatal("API.SetEntityPlayer: Target " ..Subject.. " is invalid!");
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID <= 0 or _PlayerID > 8 then
        API.Fatal("API.SetEntityPlayer: Player-ID must between 0 and 8!");
        return;
    end
    EntityScriptingValue:GetInstance(_Entity):SetPlayerID(math.floor(_PlayerID));
end
ChangePlayer = API.SetEntityPlayer;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

-- Scripting Value Class -------------------------------------------------------

EntityScriptingValueObjects = {};

---
-- Diese Klasse definiert einen Entity-Wrapper mit dem einfach auf ESV
-- zugegriffen werden kann.
-- @within Klassen
-- @local
--
EntityScriptingValue = class {
    ---
    -- Konstruktor
    -- @param[type=string] _Entity Skriptname des Entity
    -- @within EntityScriptingValue
    -- @local
    --
    construct = function(self, _Entity)
        self.m_EntityName = _Entity;
        EntityScriptingValueObjects[_Entity] = self;
    end
};

---
-- Gibt die Scripting Value Instanz des Entity zurück.
-- @param[type=string] _Entity Skriptname des Entity
-- @return[type=table] Instanz
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:GetInstance(_Entity)
    assert(self == EntityScriptingValue, "Can not be used from instance!");
    assert(IsExisting(_Entity));

    if not EntityScriptingValueObjects[_Entity] then
        EntityScriptingValueObjects[_Entity] = new{EntityScriptingValue, _Entity};
    end
    return EntityScriptingValueObjects[_Entity];
end

---
-- Ändert die Größe des Entity.
-- @param[type=number] _Scale Größenfaktor
-- @return[type=table] self
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:SetEntitySize(_Scale)
    assert(not GUI, "Can not be used in local script");
    assert(self ~= EntityScriptingValue, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID > 0 then
        Logic.SetEntityScriptingValue(EntityID, -45, self:Float2Int(_size));
        if Logic.IsSettler(EntityID) == 1 then
            Logic.SetSpeedFactor(EntityID, _Scale);
        end
    end
    return self;
end

---
-- Ändert den Besitzer des Entity.
--
-- @param[type=number] _PlayerID Besitzer
-- @return[type=table] self
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:SetPlayerID(_PlayerID)
    assert(not GUI, "Can not be used in local script");
    assert(self ~= EntityScriptingValue, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID > 0 then
        Logic.SetEntityScriptingValue(EntityID, -71, _PlayerID);
    end
    return self;
end

---
-- Ändert die aktuelle Gesundheit des Entity.
--
-- @param[type=number] _Health Neue aktuelle Gesundheit
-- @return[type=table] self
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:SetHealth(_Health)
    assert(not GUI, "Can not be used in local script");
    assert(self ~= EntityScriptingValue, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID > 0 then
        Logic.SetEntityScriptingValue(EntityID, -41, _Health);
    end
    return self;
end

---
-- Gibt die relative Größe des Entity zurück.
--
-- @return[type=number] Größenfaktor
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:GetEntitySize()
    assert(self ~= EntityScriptingValue, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 then
        return 0;
    end
    local size = Logic.GetEntityScriptingValue(EntityID, -45);
    return self:Int2Float(size);
end

---
-- Gibt den Besitzer des Entity zurück.
--
-- @return[type=number] Besitzer
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:GetPlayerID()
    assert(self ~= EntityScriptingValue, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 then
        return 0;
    end
    return Logic.GetEntityScriptingValue(EntityID, -71);
end

---
-- Gibt zurück, ob das Entity sichtbar ist.
--
-- @return[type=boolean] Ist sichtbar
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:IsEntityVisible()
    assert(self ~= EntityScriptingValue, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 then
        return false;
    end
    return Logic.GetEntityScriptingValue(EntityID, -50) == 801280;
end

---
-- Gibt zurück, ob eine NPC-Interaktion mit dem Siedler möglich ist.
--
-- @return[type=boolean] Ist NPC
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:IsOnScreenInformationActive()
    assert(self ~= EntityScriptingValue, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 then
        return false;
    end
    if Logic.IsSettler(EntityID) == 0 then
        return false;
    end
    return Logic.GetEntityScriptingValue(EntityID, 6) == 1;
end

---
-- Gibt das Bewegungsziel des Entity zurück.
--
-- @return[type=table] Positionstabelle
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:GetMovingTargetPosition(_Entity)
    assert(self ~= EntityScriptingValue, "Can not be used in static context!");

    local pos = {};
    pos.X = self:GetValueAsFloat(19) or 0;
    pos.Y = self:GetValueAsFloat(20) or 0;
    return pos;
end

---
-- Gibt die aktuelle Gesundheit des Entity zurück.
--
-- @return[type=number] Gesundheit des Entity
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:GetAbsoluteHealth()
    assert(self ~= EntityScriptingValue, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID > 0 then
        return Logic.GetEntityScriptingValue(EntityID, -41);
    end
    return 0;
end

---
-- Gibt die Mänge an Soldaten zurück, die dem Entity unterstehen
--
-- @return[type=number] Menge an Soldaten
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:CountSoldiers()
    assert(self ~= EntityScriptingValue, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID > 0 then
        return Logic.GetEntityScriptingValue(EntityID, -57);
    end
    return 0;
end

---
-- Gibt die IDs aller Soldaten zurück, die zum Battalion gehören.
--
-- @return[type=table] Liste aller Soldaten
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:GetSoldiers()
    assert(self ~= EntityScriptingValue, "Can not be used in static context!");

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
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:GetLeaderID()
    assert(self ~= EntityScriptingValue, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID > 0 then
        return Logic.GetEntityScriptingValue(EntityID, 46);
    end
    return 0;
end

---
-- Gibt die Scripting Value des Entity als Ganzzahl zurück.
--
-- @param[type=number] _index Index im RAM
-- @return[type=number] Ganzzahl
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:GetValueAsInteger(_index)
    assert(self ~= EntityScriptingValue, "Can not be used in static context!");

    local EntityID = GetID(self.m_EntityName);
    if EntityID == 0 then
        return 0;
    end
    return math.floor(Logic.GetEntityScriptingValue(EntityID, _index) + 0.5);
end

---
-- Gibt die Scripting Value des Entity als Dezimalzahl zurück.
--
-- @param[type=number] _index Index im RAM
-- @return[type=number] Dezimalzahl
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:GetValueAsFloat(_index)
    assert(self ~= EntityScriptingValue, "Can not be used in static context!");

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
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:qmod(a, b)
    return a - math.floor(a/b)*b
end

---
-- Konvertiert eine Ganzzahl in eine Dezimalzahl.
--
-- @param[type=number] num Integer
-- @return[type=number] Integer als Float
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:Int2Float(num)
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
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:bitsInt(num)
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
-- @param[type=table] t Table
-- @return[type=table] Table mit Bits
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:bitsFrac(num, t)
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
-- @within EntityScriptingValue
-- @local
--
function EntityScriptingValue:Float2Int(fval)
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

Core:RegisterBundle("BundleEntityScriptingValues");
