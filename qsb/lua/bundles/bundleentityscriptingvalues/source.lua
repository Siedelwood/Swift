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
-- Der Faktor gibt die relative Größe des Entity zu seiner normalen Größe an.
--
-- <b>Alias</b>: GetScale
--
-- @param _Entity Entity
-- @return Größenfaktor
-- @within Public
--
-- @usage
-- local Scale = API.GetEntityScale("alandra")
--
function API.GetEntityScale(_Entity)
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.GetEntityScale: Target " ..Subject.. " is invalid!");
        return -1;
    end
    return BundleEntityScriptingValues:GetEntitySize(_Entity);
end
GetScale = API.GetEntityScale;

---
-- Gibt den Besitzer des Entity zurück.
--
-- <b>Alias</b>: GetPlayer
--
-- @param _Entity Entity
-- @return Besitzer
-- @within Public
--
function API.GetEntityPlayer(_Entity)
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.GetEntityPlayer: Target " ..Subject.. " is invalid!");
        return -1;
    end
    return BundleEntityScriptingValues:GetPlayerID(_entity);
end
GetPlayer = API.GetEntityPlayer;

---
-- Gibt die Position zurück, zu der sich das Entity bewegt.
--
-- Über diese Koordinaten könnte man prüfen, ob ein Entity sich in einen
-- Bereich bewegt, in dem es nichts zu suchen hat.
--
-- <b>Alias</b>: GetMovingTarget
--
-- @param _Entity Entity
-- @return Positionstabelle
-- @within Public
--
-- @usage
-- local Destination = API.GetMovingTarget("hakim");
-- if GetDistance(Destination, "LockedArea") < 2000 then
--     local x,y,z = Logic.EntityGetPos(GetID("hakim"));
--     Logic.DEBUG_SetSettlerPosition(GetID("hakim"), x, y):
-- end
--
function API.GetMovingTarget(_Entity)
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.GetMovingTarget: Target " ..Subject.. " is invalid!");
        return nil;
    end
    return BundleEntityScriptingValues:GetMovingTargetPosition(_Entity);
end
GetMovingTarget = API.GetMovingTarget;

---
-- Gibt zurück, ob das NPC-Flag bei dem Siedler gesetzt ist.
--
-- Auf diese Weise kann geprüft werden, ob ein NPC auf dem Entity aktiv ist.
--
-- <b>Alias</b>: IsNpc
--
-- @param _Entity Entity
-- @return Ist NPC
-- @within Public
--
-- @usage
-- local Active = API.IsEntityNpc("alandra");
-- if Active then
--     API.Note("NPC is active");
-- end
--
function API.IsEntityNpc(_Entity)
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.IsEntityNpc: Target " ..Subject.. " is invalid!");
        return false;
    end
    return BundleEntityScriptingValues:IsOnScreenInformationActive(_Entity);
end
IsNpc = API.IsEntityNpc;

---
-- Gibt zurück, ob das Entity sichtbar ist.
--
-- <b>Alias</b>: IsVisible
--
-- @param _Entity Entity
-- @return Ist sichtbar
-- @within Public
--
function API.IsEntityVisible(_Entity)
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.IsEntityVisible: Target " ..Subject.. " is invalid!");
        return false;
    end
    return BundleEntityScriptingValues:IsEntityVisible(_Entity);
end
IsVisible = API.IsEntityVisible;

---
-- Setzt den Größenfaktor des Entity.
--
-- Bei einem Siedler wird ebenfalls versucht die Bewegungsgeschwindigkeit an
-- die Größe anzupassen, was aber nicht bei allen Siedlern möglich ist.
--
-- <b>Alias</b>: SetScale
--
-- @param _Entity Entity
-- @param _Scale  Größenfaktor
-- @within Public
--
function API.SetEntityScale(_Entity, _Scale)
    if GUI or not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.SetEntityScale: Target " ..Subject.. " is invalid!");
        return;
    end
    if type(_Scale) ~= "number" then
        API.Dbg("API.SetEntityScale: Scale must be a number!");
        return;
    end
    return BundleEntityScriptingValues.Global:SetEntitySize(_Entity, _Scale);
end
SetScale = API.SetEntityScale;

---
-- Ändert den Besitzer des Entity.
--
-- Mit dieser Funktion werden die Sicherungen des Spiels umgangen! Es ist
-- möglich ein Raubtier einem Spieler zuzuweisen.
--
-- <b>Alias</b>: ChangePlayer
--
-- @param _Entity   Entity
-- @param _PlayerID Besitzer
-- @within Public
--
function API.SetEntityPlayer(_Entity, _PlayerID)
    if GUI or not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.SetEntityPlayer: Target " ..Subject.. " is invalid!");
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID <= 0 or _PlayerID > 8 then
        API.Dbg("API.SetEntityPlayer: Player-ID must between 0 and 8!");
        return;
    end
    return BundleEntityScriptingValues.Global:SetPlayerID(_Entity, math.floor(_PlayerID));
end
ChangePlayer = API.SetEntityPlayer;

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
-- @within Private
-- @local
--
function BundleEntityScriptingValues.Global:Install()

end

---
-- Ändert die Größe des Entity.
--
-- @param _entity Entity
-- @param _size   Größenfaktor
-- @within Private
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
-- @within Private
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
-- @within Private
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
-- @within BundleEntityScriptingValues
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
-- @within BundleEntityScriptingValues
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
-- @within BundleEntityScriptingValues
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
-- @within BundleEntityScriptingValues
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
-- @within BundleEntityScriptingValues
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
-- @within BundleEntityScriptingValues
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
-- @within BundleEntityScriptingValues
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
-- @within BundleEntityScriptingValues
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
-- @within BundleEntityScriptingValues
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
-- @within BundleEntityScriptingValues
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
-- @within BundleEntityScriptingValues
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
-- @within BundleEntityScriptingValues
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
