-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntityScriptingValues                                  # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- <p>Mit diesem Bundle können Eigenschaften von Entities abgefragt oder
-- verändert werden, die sonst unzugänglich wären. Dazu zählen beispielsweise
-- die Größe des Entity und das Bewegungsziel.</p>
--
-- <p><a href="#ScriptingValue">Scripting Values</a></p>
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleEntityScriptingValues = {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --



-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleEntityScriptingValues = {
    Global = {
        Data = {},
    },
    Local = {
        Data = {},
    },
}

-- Global ------------------------------------------------------------------- --

function BundleEntityScriptingValues.Global:Install()
end

-- Local -------------------------------------------------------------------- --

function BundleEntityScriptingValues.Local:Install()
end

-- Shared Library ----------------------------------------------------------- --

---
-- Diese Klasse dient als Wrapper um ein Entity, mit dem besondere Eigenschaften
-- gelesen oder bearbeitet werden können, die sonst nicht erreichbar wären.
--
-- Initalisierung eines Entity:
-- <pre>local Hakim = new(ScriptingValue, "hakim");</pre>
--
-- @within Klassen
--
ScriptingValue = {};
function ScriptingValue:__construct(_Entity)
    self.Converter = new(ScriptingValueConverter);
    self.ScriptName = _Entity;
end
class(ScriptingValue);

---
-- Gibt die relative Größe des Entity zurück.
--
-- Wird eine Größe angegeben, wird stattdessen diese Größe gesetzt.
--
-- @param _Size [number] Neue Größe
-- @return [number] Größenfaktor
-- @within ScriptingValue
-- @local
--
function ScriptingValue:EntitySize(_Size)
    if _Size then 
        self:RawSetFloat(-45, _Size);
    end
    return self:RawGetFloat(-45);
end

---
-- Gibt den Besitzer des Entity zurück.
--
-- Wird eine PlayerID angegeben, wird stattdessen diese gesetzt.
--
-- @param _PlayerID [number] Neuer Besitzer
-- @return [number] Besitzer
-- @within ScriptingValue
-- @local
--
function ScriptingValue:Player(_PlayerID)
    if _PlayerID then 
        self:RawSetInt(-71, _PlayerID);
    end
    return self:RawGetInt(-71);
end

---
-- Gibt zurück, ob das Entity sichtbar ist.
--
-- Wird ein Visibility Flag angegeben, wird stattdessen dieses gesetzt.
--
-- @param _Visible [boolean] Sichtbar Flag
-- @return [boolean] Ist sichtbar
-- @within ScriptingValue
-- @local
--
function ScriptingValue:Visible(_Visible)
    if _Visible ~= nil then 
        self:RawSetInt(-50, (_Visible and 801280) or 0);
    end
    return self:RawGetInt(-50) == 801280;
end

---
-- Gibt zurück, ob eine NPC-Interaktion mit dem Siedler möglich ist.
--
-- Wird ein NPC Flag angegeben, wird stattdessen dieses gesetzt.
--
-- @param _Active [boolean] NPC State
-- @return [boolean] Ist NPC
-- @within ScriptingValue
-- @local
--
function ScriptingValue:Npc(_Active)
    if Logic.IsSettler(GetID(self.ScriptName)) == 0 then
        return false;
    end
    if _Active ~= nil then 
        self:RawSetInt(6, (_Active and 1) or 0);
    end
    return self:RawGetInt(6) == 1;
end

---
-- Gibt das Bewegungsziel des Entity zurück.
--
-- @return [table] Positionstabelle
-- @within ScriptingValue
-- @local
--
function ScriptingValue:MoveDestination()
    local pos = {};
    pos.X = self:RawGetFloat(19) or 0;
    pos.Y = self:RawGetFloat(20) or 0;
    return pos;
end

---
-- Prüft ob die Instanz der ScriptingValue noch funktionsfähig ist.
--
-- @return [boolean] Scripting Value valide
-- @within ScriptingValue
--
function ScriptingValue:valid()
    return IsExisting(self.ScriptName) == true;
end

---
-- Gibt einen Wert als Ganzzahl zurück.
--
-- @parem _Idx [number] Index der Scripting Value
-- @return [number] Wert als Ganzzahl
-- @within ScriptingValue
--
function ScriptingValue:RawGetInt(_Idx)
    if not self:valid() then 
        return nil;
    end
    return Logic.GetEntityScriptingValue(GetID(self.ScriptName), _Idx);
end

---
-- Setzt eine Ganzzahl als Wert einer Scripting Value im Arbeitsspeicher
--
-- @parem _Idx [number] Index der Scripting Value
-- @parem _Value [number] Neuer Wert
-- @within ScriptingValue
--
function ScriptingValue:RawSetInt(_Idx, _Value)
    assert(not GUI);
    if not self:valid() then 
        return nil;
    end
    Logic.SetEntityScriptingValue(GetID(self.ScriptName), _Idx, _Value);
    return self;
end

---
-- Gibt einen Wert als Dezimalzahl zurück.
--
-- @parem _Idx [number] Index der Scripting Value
-- @return [number] Wert als Dezimalzahl
-- @within ScriptingValue
--
function ScriptingValue:RawGetFloat(_Idx)
    if not self:valid() then 
        return nil;
    end
    return self.Converter:Int2Float(Logic.GetEntityScriptingValue(GetID(self.ScriptName), _Idx));
end

---
-- Setzt eine Dezimalzahl als Wert einer Scripting Value im Arbeitsspeicher
--
-- @parem _Idx [number] Index der Scripting Value
-- @parem _Value [number] Neuer Wert
-- @within ScriptingValue
--
function ScriptingValue:RawSetFloat(_Idx, _Value)
    if not self:valid() then 
        return nil;
    end
    Logic.SetEntityScriptingValue(GetID(self.ScriptName), _Idx, self.Converter:Float2Int(_Value));
    return self;
end

---
-- Diese Klasse konvertiert zwischen den Arbeitsspeicherformat von Zahlen und
-- dem Lua-Format von Zahlen. Diese Klasse wird benötigt, um Scriptting Values
-- im Arbeitsspeicher zu verändern.
--
-- @within Klassen
--
ScriptingValueConverter = {};
class(ScriptingValueConverter);

---
-- Bestimmt das Modul b der Zahl a.
--
-- @param a	[number] Zahl
-- @param b	[number] Modul
-- @return [number] qmod der Zahl
-- @within ScriptingValueConverter
--
-- @usage
-- local qmod = Converter:qmod(100, 2);
--
function ScriptingValueConverter:qmod(a, b)
    return a - math.floor(a/b)*b;
end

---
-- <p>Konvertiert eine Ganzzahl in eine Dezimalzahl.</p>
-- <p>Diese Funktion wird benötigt, um eine aus dem Arbeitsspeicher gelesene
-- Zahl in eine Lua-Number umzuwandeln.</p>
--
-- @param num [number] Integer
-- @return [number] Integer als Float
-- @within ScriptingValueConverter
--
-- @usage
-- local float = Converter:Int2Float(SV);
--
function ScriptingValueConverter:Int2Float(num)
    if(num == 0) then return 0; end
    local sign = 1;
    if(num < 0) then num = 2147483648 + num; sign = -1; end
    local frac = self:qmod(num, 8388608);
    local headPart = (num-frac)/8388608;
    local expNoSign = self:qmod(headPart, 256);
    local exp = expNoSign-127;
    local fraction = 1;
    local fp = 0.5;
    local check = 4194304;
    for i = 23, 0, -1 do
        if(frac - check) > 0 then fraction = fraction + fp; frac = frac - check; end
        check = check / 2; fp = fp / 2;
    end
    return fraction * math.pow(2, exp) * sign;
end

---
-- Gibt den Integer als Bits zurück
--
-- @param num [number] Bits
-- @return [table] Table mit Bits
-- @within ScriptingValueConverter
--
function ScriptingValueConverter:bitsInt(num)
    local t={};
    while num>0 do
        rest=self:qmod(num, 2); table.insert(t,1,rest); num=(num-rest)/2;
    end
    table.remove(t, 1);
    return t;
end

---
-- Stellt eine Zahl als eine Folge von Bits in einer Table dar.
--
-- @param num [integer] Integer
-- @param t	  [table] Table
-- @return [table] Table mit Bits
-- @within ScriptingValueConverter
--
function ScriptingValueConverter:bitsFrac(num, t)
    for i = 1, 48 do
        num = num * 2;
        if(num >= 1) then table.insert(t, 1); num = num - 1; else table.insert(t, 0); end
        if(num == 0) then return t; end
    end
    return t;
end

---
-- <p>Konvertiert eine Dezimalzahl in eine Ganzzahl.</p>
-- <p>Diese Funktion wird benötigt, um eine Lua-Number in einen Wert
-- umzuwandeln, der in den Arbeitsspeicher geschrieben werden kann.</p>
--
-- @param fval [number] Float
-- @return [number] Float als Integer
-- @within ScriptingValueConverter
--
-- @usage
-- local int = Converter:Float2Int(SV);
--
function ScriptingValueConverter:Float2Int(fval)
    if(fval == 0) then return 0; end
    local signed = false;
    if(fval < 0) then signed = true; fval = fval * -1; end
    local outval = 0;
    local bits;
    local exp = 0;
    if fval >= 1 then
        local intPart = math.floor(fval); local fracPart = fval - intPart;
        bits = self:bitsInt(intPart); exp = table.getn(bits); self:bitsFrac(fracPart, bits);
    else
        bits = {}; self:bitsFrac(fval, bits);
        while(bits[1] == 0) do exp = exp - 1; table.remove(bits, 1); end
        exp = exp - 1;
        table.remove(bits, 1);
    end
    local bitVal = 4194304; local start = 1;
    for bpos = start, 23 do
        local bit = bits[bpos];
        if(not bit) then break; end
        if(bit == 1) then outval = outval + bitVal; end
        bitVal = bitVal / 2;
    end
    outval = outval + (exp+127)*8388608;
    if(signed) then outval = outval - 2147483648 end
    return outval;
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleEntityScriptingValues");

