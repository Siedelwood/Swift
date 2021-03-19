-- Scripting Values API ----------------------------------------------------- --

---
-- Das Modul stellt grundlegende Funktionen zur Manipulation von Scripting
-- Values bereit.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="modules.Swift_0_Core.api.html">Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

QSB.ScriptingValue = {}

---
-- Gibt den Wert auf dem übergebenen Index für das Entity zurück.
--
-- @param[type=number] _Entity Entity
-- @param[type=number] _SV     Typ der Scripting Value
-- @return[type=number] Ermittelter Wert
-- @within Anwenderfunktionen
--
-- @usage local PlayerID = API.GetFloat("HansWurst", QSB.ScriptingValue.Player);
--
function API.GetInteger(_Entity, _SV)
    local ID = GetID(_Entity);
    if not IsExisting(ID) then
        return;
    end
    return Logic.GetEntityScriptingValue(ID, _SV);
end

---
-- Gibt den Wert auf dem übergebenen Index für das Entity zurück.
--
-- @param[type=number] _Entity Entity
-- @param[type=number] _SV     Typ der Scripting Value
-- @return[type=number] Ermittelter Wert
-- @within Anwenderfunktionen
--
-- @usage local Size = API.GetFloat("HansWurst", QSB.ScriptingValue.Size);
--
function API.GetFloat(_Entity, _SV)
    local ID = GetID(_Entity);
    if not IsExisting(ID) then
        return;
    end
    local Value = Logic.GetEntityScriptingValue(ID, _SV);
    return API.ConvertIntegerToFloat(Value);
end

---
-- Setzt den Wert auf dem übergebenen Index für das Entity.
-- 
-- @param[type=number] _Entity Entity
-- @param[type=number] _SV     Typ der Scripting Value
-- @param[type=number] _Value  Zu setzender Wert
-- @within Anwenderfunktionen
--
-- @usage API.SetInteger("HansWurst", QSB.ScriptingValue.Player, 2);
--
function API.SetInteger(_Entity, _SV, _Value)
    local ID = GetID(_Entity);
    if GUI or not IsExisting(ID) then
        return;
    end
    Logic.SetEntityScriptingValue(ID, _SV, _Value);
end

---
-- Setzt den Wert auf dem übergebenen Index für das Entity.
--
-- @param[type=number] _Entity Entity
-- @param[type=number] _SV     Typ der Scripting Value
-- @param[type=number] _Value  Zu setzender Wert
-- @within Anwenderfunktionen
--
-- @usage API.SetFloat("HansWurst", QSB.ScriptingValue.Size, 1.5);
--
function API.SetFloat(_Entity, _SV, _Value)
    local ID = GetID(_Entity);
    if GUI or not IsExisting(ID) then
        return;
    end
    Logic.SetEntityScriptingValue(ID, _SV, API.ConvertFloatToInteger(_Value));
end

---
-- Konvertirert den Wert in eine Ganzzahl.
--
-- @param[type=number] _Value Gleitkommazahl
-- @return[type=number] Konvertierte Ganzzahl
-- @within Anwenderfunktionen
--
-- @usage local Converted = API.ConvertIntegerToFloat(Value)
--
function API.ConvertIntegerToFloat(_Value)
    return ModuleScriptingValue.Shared:ScriptingValueIntegerToFloat(num);
end

---
-- Konvertirert den Wert in eine Gleitkommazahl.
--
-- @param[type=number] _Value Gleitkommazahl
-- @return[type=number] Konvertierte Ganzzahl
-- @within Anwenderfunktionen
--
-- @usage local Converted = API.ConvertFloatToInteger(Value)
--
function API.ConvertFloatToInteger(_Value)
    return ModuleScriptingValue.Shared:ScriptingValueFloatToInteger(num);
end

