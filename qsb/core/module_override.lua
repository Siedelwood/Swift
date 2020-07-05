-- Überschreiben ---------------------------------------------------------------

-- API Stuff --

---
-- Schickt einen Skriptbefehl an die jeweils andere Skriptumgebung.
--
-- Wird diese Funktion als dem globalen Skript aufgerufen, sendet sie den
-- Befehl an das lokale Skript. Wird diese Funktion im lokalen Skript genutzt,
-- wird der Befehl an das globale Skript geschickt.
--
-- @param[type=string]  _Command Lua-Befehl als String
-- @param[type=boolean] _Flag FIXME Optional für GUI.SendScriptCommand benötigt. 
--                      Was macht das Flag?
-- @within Anwenderfunktionen
-- @local
--
function API.Bridge(_Command, _Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState(_Command)
    else
        GUI.SendScriptCommand(_Command, _Flag)
    end
end

---
-- Wandelt underschiedliche Darstellungen einer Boolean in eine echte um.
--
-- Jeder String, der mit j, t, y oder + beginnt, wird als true interpretiert.
-- Alles andere als false.
--
-- Ist die Eingabe bereits ein Boolean wird es direkt zurückgegeben.
--
-- <p><b>Alias:</b> AcceptAlternativeBoolean</p>
--
-- @param _Value Wahrheitswert
-- @return[type=boolean] Wahrheitswert
-- @within Anwenderfunktionen
-- @local
--
-- @usage local Bool = API.ToBoolean("+")  --> Bool = true
-- local Bool = API.ToBoolean("no") --> Bool = false
--
function API.ToBoolean(_Value)
    return Core:ToBoolean(_Value);
end
AcceptAlternativeBoolean = API.ToBoolean;

---
-- Registriert eine Funktion, die nach dem laden ausgeführt wird.
--
-- <b>Alias</b>: AddOnSaveGameLoadedAction
--
-- @param[type=function] _Function Funktion, die ausgeführt werden soll
-- @within Anwenderfunktionen
-- @usage SaveGame = function()
--     API.Note("foo")
-- end
-- API.AddSaveGameAction(SaveGame)
--
function API.AddSaveGameAction(_Function)
    if GUI then
        Core:LogToFile("API.AddSaveGameAction: Can not be used from the local script!", LEVEL_ERROR);
        Core:LogToScreen("API.AddSaveGameAction: Can not be used from the local script!", LEVEL_ERROR);
        return;
    end
    return Core:AppendFunction("Mission_OnSaveGameLoaded", _Function)
end
AddOnSaveGameLoadedAction = API.AddSaveGameAction;

-- Core Stuff --

Core.Data.Overwrite = {
    StackedFunctions = {},
    AppendedFunctions = {},
    Fields = {},
};

---
-- Erweitert eine Funktion um eine andere Funktion.
--
-- Jede hinzugefügte Funktion wird vor der Originalfunktion ausgeführt. Es
-- ist möglich, eine neue Funktion an einem bestimmten Index einzufügen. Diese
-- Funktion ist nicht gedacht, um sie direkt auszuführen. Für jede Funktion
-- im Spiel sollte eine API-Funktion erstellt werden.
--
-- Wichtig: Die gestapelten Funktionen, die vor der Originalfunktion
-- ausgeführt werden, müssen etwas zurückgeben, um die Funktion an
-- gegebener Stelle zu verlassen.
--
-- @param[type=string]   _FunctionName Name der erweiterten Funktion
-- @param[type=function] _StackFunction Neuer Funktionsinhalt
-- @param[type=number]   _Index Reihenfolgeindex
-- @within Internal
-- @local
--
function Core:StackFunction(_FunctionName, _StackFunction, _Index)
    if not self.Data.Overwrite.StackedFunctions[_FunctionName] then
        self.Data.Overwrite.StackedFunctions[_FunctionName] = {
            Original = self:GetFunctionInString(_FunctionName),
            Attachments = {}
        };

        local batch = function(...)
            local ReturnValue;
            for i= 1, #self.Data.Overwrite.StackedFunctions[_FunctionName].Attachments, 1 do
                local Function = self.Data.Overwrite.StackedFunctions[_FunctionName].Attachments[i];
                ReturnValue = {Function(unpack(arg))};
                if #ReturnValue > 0 then
                    return unpack(ReturnValue);
                end
            end
            ReturnValue = {self.Data.Overwrite.StackedFunctions[_FunctionName].Original(unpack(arg))};
            return unpack(ReturnValue);
        end
        self:ReplaceFunction(_FunctionName, batch);
    end

    _Index = _Index or #self.Data.Overwrite.StackedFunctions[_FunctionName].Attachments+1;
    table.insert(self.Data.Overwrite.StackedFunctions[_FunctionName].Attachments, _Index, _StackFunction);
end

---
-- Erweitert eine Funktion um eine andere Funktion.
--
-- Jede hinzugefügte Funktion wird nach der Originalfunktion ausgeführt. Es
-- ist möglich eine neue Funktion an einem bestimmten Index einzufügen. Diese
-- Funktion ist nicht gedacht, um sie direkt auszuführen. Für jede Funktion
-- im Spiel sollte eine API-Funktion erstellt werden.
--
-- @param[type=string]   _FunctionName Name der erweiterten Funktion
-- @param[type=function] _AppendFunction Neuer Funktionsinhalt
-- @param[type=number]   _Index Reihenfolgeindex
-- @within Internal
-- @local
--
function Core:AppendFunction(_FunctionName, _AppendFunction, _Index)
    if not self.Data.Overwrite.AppendedFunctions[_FunctionName] then
        self.Data.Overwrite.AppendedFunctions[_FunctionName] = {
            Original = self:GetFunctionInString(_FunctionName),
            Attachments = {}
        };

        local batch = function(...)
            local ReturnValue = self.Data.Overwrite.AppendedFunctions[_FunctionName].Original(unpack(arg));
            for i= 1, #self.Data.Overwrite.AppendedFunctions[_FunctionName].Attachments, 1 do
                local Function = self.Data.Overwrite.AppendedFunctions[_FunctionName].Attachments[i];
                ReturnValue = {Function(unpack(arg))};
            end
            return unpack(ReturnValue);
        end
        self:ReplaceFunction(_FunctionName, batch);
    end

    _Index = _Index or #self.Data.Overwrite.AppendedFunctions[_FunctionName].Attachments+1;
    table.insert(self.Data.Overwrite.AppendedFunctions[_FunctionName].Attachments, _Index, _AppendFunction);
end

---
-- Überschreibt eine Funktion mit einer anderen.
--
-- Funktionen in einer Tabelle werden überschrieben, indem jede Ebene des
-- Tables mit einem Punkt angetrennt wird.
--
-- @param[type=string]   _FunctionName Name der erweiterten Funktion
-- @param[type=function] _AppendFunction Neuer Funktionsinhalt
-- @local
-- @within Internal
-- @usage A = {foo = function() API.Note("bar") end}
-- B = function() API.Note("muh") end
-- Core:ReplaceFunction("A.foo", B)
-- -- A.foo() == B() => "muh"
--
function Core:ReplaceFunction(_FunctionName, _Function)
    assert(type(_FunctionName) == "string");
    local ref = _G;

    local s, e = _FunctionName:find("%.");
    while (s ~= nil) do
        local SubName = _FunctionName:sub(1, e-1);
        SubName = (tonumber(SubName) ~= nil and tonumber(SubName)) or SubName;

        ref = ref[SubName];
        _FunctionName = _FunctionName:sub(e+1);
        s, e = _FunctionName:find("%.");
    end

    local SubName = (tonumber(_FunctionName) ~= nil and tonumber(_FunctionName)) or _FunctionName;
    ref[SubName] = _Function;
end

---
-- Sucht eine Funktion mit dem angegebenen Namen.
--
-- Ist die Funktionen innerhalb einer Table, so sind alle Ebenen bis zum
-- Funktionsnamen mit anzugeben, abgetrennt durch einen Punkt.
--
-- @param[type=string] _FunctionName Name der erweiterten Funktion
-- @return[type=function] Referenz auf die Funktion
-- @within Internal
-- @local
--
function Core:GetFunctionInString(_FunctionName)
    assert(type(_FunctionName) == "string");
    local ref = _G;

    local s, e = _FunctionName:find("%.");
    while (s ~= nil) do
        local SubName = _FunctionName:sub(1, e-1);
        SubName = (tonumber(SubName) ~= nil and tonumber(SubName)) or SubName;

        ref = ref[SubName];
        _FunctionName = _FunctionName:sub(e+1);
        s, e = _FunctionName:find("%.");
    end

    local SubName = (tonumber(_FunctionName) ~= nil and tonumber(_FunctionName)) or _FunctionName;
    return ref[SubName];
end

