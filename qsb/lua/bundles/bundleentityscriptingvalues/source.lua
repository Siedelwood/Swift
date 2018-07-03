-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntityScriptingValues                                  # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Bundle können Eigenschaften von Entities abgefragt oder
-- verändert werden, die sonst unzugänglich wären.
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
-- Der Faktor gibt die relative Größe des Entity zu seiner normalen Größe an.
--
-- <p><b>Alias</b>: GetScale</p>
--
-- @param _Entity [string|number] Entity
-- @return [number] Größenfaktor
-- @within Anwenderfunktionen
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
    return BundleEntityScriptingValues.Shared:GetEntitySize(_Entity);
end
GetScale = API.GetEntityScale;

---
-- Gibt den Besitzer des Entity zurück.
--
-- <p><b>Alias</b>: GetPlayer</p>
--
-- @param _Entity [string|number] Entity
-- @return [number] Besitzer
-- @within Anwenderfunktionen
--
function API.GetEntityPlayer(_Entity)
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.GetEntityPlayer: Target " ..Subject.. " is invalid!");
        return -1;
    end
    return BundleEntityScriptingValues.Shared:GetPlayerID(_entity);
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
-- @param _Entity [string|number] Entity
-- @return [table] Positionstabelle
-- @within Anwenderfunktionen
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
    return BundleEntityScriptingValues.Shared:GetMovingTargetPosition(_Entity);
end
GetMovingTarget = API.GetMovingTarget;

---
-- Gibt zurück, ob das NPC-Flag bei dem Siedler gesetzt ist.
--
-- Auf diese Weise kann geprüft werden, ob ein NPC auf dem Entity aktiv ist.
--
-- <p><b>Alias</b>: IsNpc</p>
--
-- @param _Entity [string|number] Entity
-- @return [boolean] Ist NPC
-- @within Anwenderfunktionen
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
    return BundleEntityScriptingValues.Shared:IsOnScreenInformationActive(_Entity);
end
IsNpc = API.IsEntityNpc;

---
-- Gibt zurück, ob das Entity sichtbar ist.
--
-- <p><b>Alias</b>: IsVisible</p>
--
-- @param _Entity [string|number] Entity
-- @return [boolean] Ist sichtbar
-- @within Anwenderfunktionen
--
function API.IsEntityVisible(_Entity)
    if not IsExisting(_Entity) then
        local Subject = (type(_Entity) == "string" and "'" .._Entity.. "'") or _Entity;
        API.Dbg("API.IsEntityVisible: Target " ..Subject.. " is invalid!");
        return false;
    end
    return BundleEntityScriptingValues.Shared:IsEntityVisible(_Entity);
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
-- @param _Entity [string|number] Entity
-- @param _Scale  [number] Größenfaktor
-- @within Anwenderfunktionen
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
-- <p><b>Alias</b>: ChangePlayer</p>
--
-- @param _Entity   [string|number] Entity
-- @param _PlayerID [number] Besitzer
-- @within Anwenderfunktionen
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
    Shared = {
        Data = {}
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function BundleEntityScriptingValues.Global:Install()

end

---
-- Ändert die Größe des Entity.
-- @param _Entity [string|number] Entity
-- @param _Scale  [number] Größenfaktor
-- @within Internal
-- @local
--
function BundleEntityScriptingValues.Global:SetEntitySize(_entity, _size)
    local EntityID = GetID(_entity);
    Logic.SetEntityScriptingValue(EntityID, -45, BundleEntityScriptingValues.Shared:Float2Int(_size));
    if Logic.IsSettler(EntityID) == 1 then
        Logic.SetSpeedFactor(EntityID, _size);
    end
end

---
-- Ändert den Besitzer des Entity.
--
-- @param _Entity   [string|number] Entity
-- @param _PlayerID [number] Besitzer
-- @within Internal
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
-- @within Internal
-- @local
--
function BundleEntityScriptingValues.Local:Install()

end

-- Shared ----------------------------------------------------------------------

---
-- Gibt die relative Größe des Entity zurück.
--
-- @param _Entity [string|number] Entity
-- @return [number] Größenfaktor
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Shared:GetEntitySize(_entity)
    local EntityID = GetID(_entity);
    local size = Logic.GetEntityScriptingValue(EntityID, -45);
    return self.Int2Float(size);
end

---
-- Gibt den Besitzer des Entity zurück.
-- @internal
--
-- @param _Entity [string|number] Entity
-- @return [number] Besitzer
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Shared:GetPlayerID(_entity)
    local EntityID = GetID(_entity);
    return Logic.GetEntityScriptingValue(EntityID, -71);
end

---
-- Gibt zurück, ob das Entity sichtbar ist.
--
-- @param _Entity [string|number] Entity
-- @return [boolean] Ist sichtbar
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Shared:IsEntityVisible(_entity)
    local EntityID = GetID(_entity);
    return Logic.GetEntityScriptingValue(EntityID, -50) == 801280;
end

---
-- Gibt zurück, ob eine NPC-Interaktion mit dem Siedler möglich ist.
--
-- @param _Entity [string|number] Entity
-- @return [boolean] Ist NPC
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Shared:IsOnScreenInformationActive(_entity)
    local EntityID = GetID(_entity);
    if Logic.IsSettler(EntityID) == 0 then
        return false;
    end
    return Logic.GetEntityScriptingValue(EntityID, 6) == 1;
end

---
-- Gibt das Bewegungsziel des Entity zurück.
--
-- @param _Entity [string|number] Entity
-- @return [table] Positionstabelle
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Shared:GetMovingTargetPosition(_entity)
    local pos = {};
    pos.X = self:GetValueAsFloat(_entity, 19) or 0;
    pos.Y = self:GetValueAsFloat(_entity, 20) or 0;
    return pos;
end

---
-- Gibt die Scripting Value des Entity als Ganzzahl zurück.
--
-- @param _entity [string|number] Zu untersuchendes Entity
-- @param _index  [number] Index im RAM
-- @return [number] Ganzzahl
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Shared:GetValueAsInteger(_entity, _index)
    local value = Logic.GetEntityScriptingValue(GetID(_entity),_index);
    return value;
end

---
-- Gibt die Scripting Value des Entity als Dezimalzahl zurück.
--
-- @param _entity [string|number] Zu untersuchendes Entity
-- @param _index  [number] Index im RAM
-- @return [number] Dezimalzahl
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Shared:GetValueAsFloat(_entity, _index)
    local value = Logic.GetEntityScriptingValue(GetID(_entity),_index);
    return BundleEntityScriptingValues.Shared:Int2Float(value);
end

---
-- Bestimmt das Modul b der Zahl a.
--
-- @param a	[number] Zahl
-- @param b	[number] Modul
-- @return [number] qmod der Zahl
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Shared:qmod(a, b)
    return a - math.floor(a/b)*b
end

---
-- Konvertiert eine Ganzzahl in eine Dezimalzahl.
--
-- @param num [number] Integer
-- @return [number] Integer als Float
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Shared:Int2Float(num)
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
-- @param num [number] Bits
-- @return [table] Table mit Bits
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Shared:bitsInt(num)
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
-- @param num [integer] Integer
-- @param t	  [table] Table
-- @return [table] Table mit Bits
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Shared:bitsFrac(num, t)
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
-- @param fval [number] Float
-- @return [number] Float als Integer
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Shared:Float2Int(fval)
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
