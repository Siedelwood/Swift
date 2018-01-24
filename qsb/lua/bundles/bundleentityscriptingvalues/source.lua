-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntityScriptingValues                                  # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle ermöglicht die Manipulation einer Entität direkt im 
-- Arbeitsspeicher.
--
-- @module BundleEntityScriptingValues
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Gibt den Größenfaktor des Entity zurück.
--
-- @param _Entity Entity
-- @return Größenfaktor
-- @within User-Space
-- @local
--
function API.GetScale(_Entity)
    if not IsExisting(_Entity) then
        return -1;
    end
    return BundleEntityScriptingValues:GetEntitySize(_Entity);
end

---
-- Gibt den Besitzer des Entity zurück.
--
-- @param _Entity Entity
-- @return Besitzer
-- @within User-Space
-- @local
--
function API.GetPlayer(_Entity)
    if not IsExisting(_Entity) then
        return -1;
    end
    return BundleEntityScriptingValues:GetPlayerID(_entity);
end

---
-- Gibt die Position zurück, zu der sich das Entity bewegt.
--
-- @param _Entity Entity
-- @return Positionstabelle
-- @within User-Space
-- @local
--
function API.GetMovingTarget(_Entity)
    if not IsExisting(_Entity) then
        return nil;
    end
    return BundleEntityScriptingValues:GetMovingTargetPosition(_Entity);
end

---
-- Gibt zurück, ob das NPC-Flag bei dem Siedler gesetzt ist.
--
-- @param _Entity Entity
-- @return Ist NPC
-- @within User-Space
-- @local
--
function API.IsNPC(_Entity)
    if not IsExisting(_Entity) then
        return false;
    end
    return BundleEntityScriptingValues:IsOnScreenInformationActive(_Entity);
end

---
-- Gibt zurück, ob das Entity sichtbar ist.
--
-- @param _Entity Entity
-- @return Ist sichtbar
-- @within User-Space
-- @local
--
function API.IsViusible(_Entity)
    if not IsExisting(_Entity) then
        return false;
    end
    return BundleEntityScriptingValues:IsEntityVisible(_Entity);
end

---
-- Setzt den Größenfaktor des Entity.
--
-- Bei einem Siedler wird ebenfalls versucht die Bewegungsgeschwindigkeit an
-- die Größe anzupassen, was aber nicht bei allen Siedlern möglich ist.
--
-- @param _Entity Entity
-- @param _Scale  Größenfaktor
-- @within User-Space
-- @local
--
function API.SetScale(_Entity, _Scale)
    if GUI or not IsExisting(_Entity) then
        return;
    end
    BundleEntityScriptingValues.Global:SetEntitySize(_Entity, _Scale)
end

---
-- Ändert den Besitzer des Entity.
--
-- Mit dieser Funktion werden die Sicherungen des Spiels umgangen! Es ist
-- möglich ein Raubtier einem Spieler zuzuweisen.
--
-- @param _Entity   Entity
-- @param _PlayerID Besitzer
-- @within User-Space
-- @local
--
function API.SetPlayer(_Entity, _PlayerID)
    if GUI or not IsExisting(_Entity) then
        return;
    end
    BundleEntityScriptingValues.Global:SetEntitySize(_Entity, _PlayerID)
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleEntityScriptingValues = {
    Global = {
        Data = {}
    },
    Local = {
        Data = {}
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues.Global:Install()

end

---
-- Ändert die Größe des Entity.
--
-- @param _entity Entity
-- @param _size   Größenfaktor
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues.Global:SetEntitySize(_entity, _size)
    local EntityID = GetID(_entity);
    Logic.SetEntityScriptingValue(EntityID, -45, BundleEntityScriptingValues:Float2Int(_size));
    if Logic.IsSettler(EntityID) == 1 then
        Logic.SetSpeedFactor(EntityID, _size);
    end
end

---
-- Ändert den Besitzer des Entity.
--
-- @param _entity   Entity
-- @param _PlayerID Neuer Besitzer
-- @within Application-Space
-- @local
-- 
function BundleEntityScriptingValues.Global:SetPlayerID(_entity, _PlayerID)
    local EntityID = GetID(_entity);
    Logic.SetEntityScriptingValue(EntityID, -71, _PlayerID);
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues.Local:Install()

end

-- Shared ----------------------------------------------------------------------

---
-- Gibt die relative Größe des Entity zurück.
--
-- @param _entity Entity
-- @return Größenfaktor
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues:GetEntitySize(_entity)
    local EntityID = GetID(_entity);
    local size = Logic.GetEntityScriptingValue(EntityID, -45);
    return self.Int2Float(size);
end

---
-- Gibt den Besitzer des Entity zurück.
-- @internal
--
-- @param _entity Entity
-- @return PlayerID
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues:GetPlayerID(_entity)
    local EntityID = GetID(_entity);
    return Logic.GetEntityScriptingValue(EntityID, -71);
end

---
-- Gibt zurück, ob das Entity sichtbar ist.
--
-- @param _entity Entity
-- @return Entity ist sichtbar
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues:IsEntityVisible(_entity)
    local EntityID = GetID(_entity);
    return Logic.GetEntityScriptingValue(EntityID, -50) == 801280;
end

---
-- Gibt zurück, ob eine NPC-Interaktion mit dem Siedler möglich ist.
--
-- @param _entity Entity
-- @return NPC ist aktiv
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues:IsOnScreenInformationActive(_entity)
    local EntityID = GetID(_entity);
    if Logic.IsSettler(EntityID) == 0 then
        return false;
    end
    return Logic.GetEntityScriptingValue(EntityID, 6) == 1;
end

---
-- Gibt das Bewegungsziel des Entity zurück.
--
-- @param _entity Entity
-- @return Position Table
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues:GetMovingTargetPosition(_entity)
    local pos = {};
    pos.X = self:GetValueAsFloat(_entity, 19);
    pos.Y = self:GetValueAsFloat(_entity, 20);
    return pos;
end

---
-- Gibt die Scripting Value des Entity als Ganzzahl zurück.
--
-- @param _entity Zu untersuchendes Entity
-- @param _index  Index im RAM
-- @return Integer
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues:GetValueAsInteger(_entity, _index)
    local value = Logic.GetEntityScriptingValue(GetID(_entity),_index);
    return value;
end

---
-- Gibt die Scripting Value des Entity als Dezimalzahl zurück.
--
-- @param _entity Zu untersuchendes Entity
-- @param _index  Index im RAM
-- @return Float
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues:GetValueAsFloat(_entity, _index)
    local value = Logic.GetEntityScriptingValue(GetID(_entity),_index);
    return SV.Int2Float(value);
end

---
-- Bestimmt das Modul b der Zahl a.
--
-- @param a	Zahl
-- @param b	Modul
-- @return qmod der Zahl
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues:qmod(a, b)
    return a - math.floor(a/b)*b
end

---
-- Konvertiert eine Ganzzahl in eine Dezimalzahl.
--
-- @param num Integer
-- @return Integer als Float
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues:Int2Float(num)
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
-- Gibt den Integer als Bits zurück
--
-- @param num Bits
-- @return Table mit Bits
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues:bitsInt(num)
    local t={}
    while num>0 do
        rest=self:qmod(num, 2) table.insert(t,1,rest) num=(num-rest)/2
    end
    table.remove(t, 1)
    return t
end

---
-- Stellt eine Zahl als eine folge von Bits in einer Table dar.
--
-- @param num Integer
-- @param t	  Table
-- @return Table mit Bits
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues:bitsFrac(num, t)
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
-- @param fval Float
-- @return Float als Integer
-- @within Application-Space
-- @local
--
function BundleEntityScriptingValues:Float2Int(fval)
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

