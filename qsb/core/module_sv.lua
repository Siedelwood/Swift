-- Scripting Values ------------------------------------------------------------

-- API Stuff --

---
-- Rundet eine Dezimalzahl kaufmännisch ab.
--
-- <b>Hinweis</b>: Es wird manuell gerundet um den Rundungsfehler in der
-- History Edition zu umgehen.
--
-- <p><b>Alias:</b> Round</p>
--
-- @param[type=string] _Value         Zu rundender Wert
-- @param[type=string] _DecimalDigits Maximale Dezimalstellen
-- @return[type=number] Abgerundete Zahl
-- @within Anwenderfunktionen
--
function API.Round(_Value, _DecimalDigits)
    _DecimalDigits = _DecimalDigits or 2;
    _DecimalDigits = (_DecimalDigits < 0 and 0) or _DecimalDigits;
    local Value = tostring(_Value);
    if tonumber(Value) == nil then
        return 0;
    end
    local s,e = Value:find(".", 1, true);
    if e then
        local Overhead = nil;
        if Value:len() > e + _DecimalDigits then
            if _DecimalDigits > 0 then
                local TmpNum;
                if tonumber(Value:sub(e+_DecimalDigits+1, e+_DecimalDigits+1)) >= 5 then
                    TmpNum = tonumber(Value:sub(e+1, e+_DecimalDigits)) +1;
                    Overhead = (_DecimalDigits == 1 and TmpNum == 10);
                else
                    TmpNum = tonumber(Value:sub(e+1, e+_DecimalDigits));
                end
                Value = Value:sub(1, e-1);
                if (tostring(TmpNum):len() >= _DecimalDigits) then
                    Value = Value .. "." ..TmpNum;
                end
            else
                local NewValue = tonumber(Value:sub(1, e-1));
                if tonumber(Value:sub(e+_DecimalDigits+1, e+_DecimalDigits+1)) >= 5 then
                    NewValue = NewValue +1;
                end
                Value = NewValue;
            end
        else
            Value = (Overhead and (tonumber(Value) or 0) +1) or
                     Value .. string.rep("0", Value:len() - (e + _DecimalDigits))
        end
    end
    return tonumber(Value);
end
Round = API.Round;

-- Core Stuff --

QSB.HistoryEdition = false;
QSB.ScriptingValues = {
    Game = "Vanilla",
    Vanilla = {
        Destination = {X = 19, Y= 20},
        Health      = -41,
        Player      = -71,
        Size        = -45,
        Visible     = -50,
    },
    HistoryEdition = {
        Destination = {X = 17, Y= 18},
        Health      = -38,
        Player      = -68,
        Size        = -42,
        Visible     = -47,
    }
}

---
-- Überschreibt die Hotkey-Funktion, die das Spiel speichert. Durch die
-- Prüfung, ob Briefings oder Cutscenes aktiv sind, wird vermieden, dass
-- die History Edition automatisch speichert.
--
-- @within Internal
-- @local
--
function Core:SetupLocal_HistoryEditionAutoSave()
    KeyBindings_SaveGame_Orig_Core_SaveGame = KeyBindings_SaveGame;
    KeyBindings_SaveGame = function()
        -- In der History Edition wird diese Funktion aufgerufen, wenn der
        -- letzte Spielstand der Map älter als 15 Minuten ist. Wenn ein
        -- Briefing oder eine Cutscene aktiv ist, sollen keine Quicksaves
        -- erstellt werden.
        if not Core:CanGameBeSaved() then
            return;
        end
        KeyBindings_SaveGame_Orig_Core_SaveGame();
    end
end

---
-- Identifiziert anhand der um +3 Verschobenen PlayerID bei den Scripting
-- Values die infamous History Edition. Ob es sich um die History Edition
-- hält, wird in der Variable QSB.HistoryEdition gespeichert.
--
-- TODO: Es sollten mehr Kritieren als nur die PlayerID geprüft werden!
--
-- @within Internal
-- @local
--
function Core:IdentifyHistoryEdition()
    local EntityID = Logic.CreateEntity(Entities.U_NPC_Amma_NE, 100, 100, 0, 8);
    MakeInvulnerable(EntityID);
    if Logic.GetEntityScriptingValue(EntityID, -68) == 8 then
        API.Bridge("QSB.HistoryEdition = true");
        API.Bridge("QSB.ScriptingValues.Game = 'HistoryEdition'");
        QSB.HistoryEdition = true;
        QSB.ScriptingValues.Game = "HistoryEdition";
    end
    DestroyEntity(EntityID);
end

---
-- Bestimmt das Modul b der Zahl a.
--
-- @param[type=number] a Zahl
-- @param[type=number] b Modul
-- @return[type=number] qmod der Zahl
-- @within Internal
-- @local
--
function Core:qmod(a, b)
    return a - math.floor(a/b)*b
end

---
-- Gibt den Integer als Bits zurück.
--
-- @param[type=number] num Bits
-- @return[type=table] Table mit Bits
-- @within Internal
-- @local
--
function Core:ScriptingValueBitsInteger(num)
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
-- @within Internal
-- @local
--
function Core:ScriptingValueBitsFraction(num, t)
    for i = 1, 48 do
        num = num * 2
        if(num >= 1) then table.insert(t, 1); num = num - 1 else table.insert(t, 0) end
        if(num == 0) then return t end
    end
    return t
end

---
-- Konvertiert eine Ganzzahl in eine Dezimalzahl.
--
-- @param[type=number] num Integer
-- @return[type=number] Integer als Float
-- @within Internal
-- @local
--
function Core:ScriptingValueIntegerToFloat(num)
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
-- Konvertiert eine Dezimalzahl in eine Ganzzahl.
--
-- @param[type=number] fval Float
-- @return[type=number] Float als Integer
-- @within Internal
-- @local
--
function Core:ScriptingValueFloatToInteger(fval)
    if(fval == 0) then return 0 end
    local signed = false
    if(fval < 0) then signed = true; fval = fval * -1 end
    local outval = 0;
    local bits
    local exp = 0
    if fval >= 1 then
        local intPart = math.floor(fval); local fracPart = fval - intPart;
        bits = self:ScriptingValueBitsInteger(intPart); exp = table.getn(bits); self:ScriptingValueBitsFraction(fracPart, bits)
    else
        bits = {}; self:ScriptingValueBitsFraction(fval, bits)
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

