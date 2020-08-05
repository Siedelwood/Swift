-- Logging ---------------------------------------------------------------------

QSB.Logging = {
    DisplayLoggingLevel = 4,
    FileLoggingLevel = 2,
    Levels = {
        Debug = 1;
        Info = 2;
        Warning = 3;
        Error = 4;
        Off = 5;
    },
}

LEVEL_DEBUG = QSB.Logging.Levels.Debug;
LEVEL_INFO = QSB.Logging.Levels.Info;
LEVEL_WARNING = QSB.Logging.Levels.Warning;
LEVEL_ERROR = QSB.Logging.Levels.Error;
LEVEL_OFF = QSB.Logging.Levels.Off;

-- API Stuff --

---
-- Kopiert eine komplette Table und gibt die Kopie zurück. Tables können
-- nicht durch Zuweisungen kopiert werden. Verwende diese Funktion. Wenn ein
-- Ziel angegeben wird, ist die zurückgegebene Table eine Vereinigung der 2
-- angegebenen Tables.
-- Die Funktion arbeitet rekursiv.
--
-- <p><b>Alias:</b> CopyTableRecursive</p>
--
-- @param[type=table] _Source Quelltabelle
-- @param[type=table] _Dest   (optional) Zieltabelle
-- @return[type=table] Kopie der Tabelle
-- @within Anwenderfunktionen
-- @usage Table = {1, 2, 3, {a = true}}
-- Copy = API.InstanceTable(Table)
--
function API.InstanceTable(_Source, _Dest)
    _Dest = _Dest or {};
    assert(type(_Source) == "table")
    assert(type(_Dest) == "table")

    for k, v in pairs(_Source) do
        if type(v) == "table" then
            _Dest[k] = _Dest[k] or {};
            for kk, vv in pairs(API.InstanceTable(v)) do
                _Dest[k][kk] = _Dest[k][kk] or vv;
            end
        else
            _Dest[k] = _Dest[k] or v;
        end
    end
    return _Dest;
end
CopyTableRecursive = API.InstanceTable;

---
-- Sucht in einer eindimensionalen Table nach einem Wert. Das erste Auftreten
-- des Suchwerts wird als Erfolg gewertet.
--
-- Es können praktisch alle Lua-Werte gesucht werden, obwohl dies nur für
-- Strings und Numbers wirklich sinnvoll ist.
--
-- <p><b>Alias:</b> Inside</p>
--
-- @param             _Data Gesuchter Eintrag (multible Datentypen)
-- @param[type=table] _Table Tabelle, die durchquert wird
-- @return[type=booelan] Wert gefunden
-- @within Anwenderfunktionen
-- @usage Table = {1, 2, 3, {a = true}}
-- local Found = API.TraverseTable(3, Table)
--
function API.TraverseTable(_Data, _Table)
    for k,v in pairs(_Table) do
        if v == _Data then
            return true;
        end
    end
    return false;
end
Inside = API.TraverseTable;

---
-- Schreibt ein genaues Abbild der Table ins Log. Funktionen, Threads und
-- Metatables werden als Adresse geschrieben.
--
-- @param[type=table]  _Table Tabelle, die gedumpt wird
-- @param[type=string] _Name Optionaler Name im Log
-- @within Anwenderfunktionen
-- @local
-- @usage Table = {1, 2, 3, {a = true}}
-- API.DumpTable(Table)
--
function API.DumpTable(_Table, _Name)
    local Start = "{";
    if _Name then
        Start = _Name.. " = \n" ..Start;
    end
    Framework.WriteToLog(Start);

    for k, v in pairs(_Table) do
        if type(v) == "table" then
            Framework.WriteToLog("[" ..k.. "] = ");
            API.DumpTable(v);
        elseif type(v) == "string" then
            Framework.WriteToLog("[" ..k.. "] = \"" ..v.. "\"");
        else
            Framework.WriteToLog("[" ..k.. "] = " ..tostring(v));
        end
    end
    Framework.WriteToLog("}");
end

---
-- Konvertiert alle Strings, Booleans und Numbers einer Tabelle in
-- einen String. Die Funktion ist rekursiv, d.h. es werden auch alle
-- Untertabellen mit konvertiert. Alles was kein Number, Boolean oder
-- String ist, wird als Adresse geschrieben.
--
-- @param[type=table] _Table Table zum konvertieren
-- @return[type=string] Converted table
-- @within Anwenderfunktionen
-- @local
--
function API.ConvertTableToString(_Table)
    assert(type(_Table) == "table");
    local TableString = "{";
    for k, v in pairs(_Table) do
        local key;
        if (tonumber(k)) then
            key = ""..k;
        else
            key = "\""..k.."\"";
        end

        if type(v) == "table" then
            TableString = TableString .. "[" .. key .. "] = " .. API.ConvertTableToString(v) .. ", ";
        elseif type(v) == "number" then
            TableString = TableString .. "[" .. key .. "] = " .. v .. ", ";
        elseif type(v) == "string" then
            TableString = TableString .. "[" .. key .. "] = \"" .. v .. "\", ";
        elseif type(v) == "boolean" or type(v) == "nil" then
            TableString = TableString .. "[" .. key .. "] = " .. tostring(v) .. ", ";
        else
            TableString = TableString .. "[" .. key .. "] = \"" .. tostring(v) .. "\", ";
        end
    end
    TableString = TableString .. "}";
    return TableString
end

---
-- Schreibt eine Nachricht in das Debug Window. Der Text erscheint links am
-- Bildschirm und ist nicht statisch.
--
-- <p><b>Alias:</b> GUI_Note</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
-- @local
--
function API.Note(_Message)
    _Message = API.ConvertPlaceholders(API.Localize(_Message));
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[GUI.AddNote("%s")]], _Message
        ));
        return;
    end
    API.AddNote(_Message);
end
GUI_Note = API.Note;

---
-- Schreibt eine Nachricht in das Debug Window. Der Text erscheint links am
-- Bildschirm und verbleibt dauerhaft am Bildschirm.
--
-- <p><b>Alias:</b> GUI_StaticNote</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
--
function API.StaticNote(_Message)
    _Message = API.ConvertPlaceholders(API.Localize(_Message));
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[GUI.AddStaticNote("%s")]], _Message
        ));
        return;
    end
    GUI.AddStaticNote(_Message);
end
GUI_StaticNote = API.StaticNote;

---
-- Löscht alle Nachrichten im Debug Window.
--
-- @within Anwenderfunktionen
--
function API.ClearNotes()
    if not GUI then
        Logic.ExecuteInLuaLocalState('GUI.ClearNotes()');
        return;
    end
    GUI.ClearNotes();
end

---
-- Schreibt eine Nachricht in das Nachrichtenfenster unten in der Mitte.
--
-- <p><b>Alias:</b> GUI_NoteDown</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
--
function API.Message(_Message)
    _Message = API.Localize(_Message);
    if not GUI then
        Logic.ExecuteInLuaLocalState('Message("' .._Message.. '")');
        return;
    end
    Message(_Message);
end
GUI_NoteDown = API.Message;

---
-- Ermittelt den lokalisierten Text anhand der eingestellten Sprache der QSB.
--
-- Wird ein normaler String übergeben, wird dieser sofort zurückgegeben.
--
-- @param _Message Anzeigetext (String oder Table)
-- @return[type=string] Message
-- @within Anwenderfunktionen
-- @local
--
function API.Localize(_Message)
    if type(_Message) == "table" then
        local MessageText = _Message[QSB.Language];
        if MessageText then
            return MessageText;
        end
        if _Message.en then
            return _Message.en;
        end
        return tostring(_Message);
    end
    return tostring(_Message);
end

---
-- Schreibt eine Nachricht mit dem angegebenen Level auf den Bildschirm
-- und ins Log.
--
-- <p><b>Alias:</b> error</p>
--
-- @param[type=string] _Message Anzeigetext
-- @param[type=string] _Level   Fehlerlevel
-- @within Logging
--
function API.Log(_Message, _Level)
    Core:LogToScreen(_Message, _Level);
    Core:LogToFile(_Message, _Level);
end
log = API.Error;

---
-- Schreibt eine Debug-Nachricht mit dem angegebenen Level auf den Bildschirm
-- und ins Log.
--
-- <p><b>Alias:</b> error</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Logging
--
function API.Debug(_Message)
    Core:LogToScreen(_Message, LEVEL_DEBUG);
    Core:LogToFile(_Message, LEVEL_DEBUG);
end
debug = API.Debug;

---
-- Schreibt eine Ifon-Nachricht mit dem angegebenen Level auf den Bildschirm
-- und ins Log.
--
-- <p><b>Alias:</b> error</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Logging
--
function API.Info(_Message)
    Core:LogToScreen(_Message, LEVEL_INFO);
    Core:LogToFile(_Message, LEVEL_INFO);
end
info = API.Info;

---
-- Schreibt eine Warnungsmeldung mit dem angegebenen Level auf den Bildschirm
-- und ins Log.
--
-- <p><b>Alias:</b> error</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Logging
--
function API.Error(_Message)
    Core:LogToScreen(_Message, LEVEL_ERROR);
    Core:LogToFile(_Message, LEVEL_ERROR);
end
error = API.Error;

---
-- Schreibt eine Fehlermeldung mit dem angegebenen Level auf den Bildschirm
-- und ins Log.
--
-- <p><p><b>Alias:</b> warn</p></p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Logging
--
function API.Warn(_Message)
    Core:LogToScreen(_Message, LEVEL_WARNING);
    Core:LogToFile(_Message, LEVEL_WARNING);
end
warn = API.Warn;

---
-- Setzt das Level fest ab dem auf den Bildschirm und ins Log geschrieben wird.
--
-- @param[type=string] _Screen Level Bildschirm
-- @param[type=string] _File   Level Datei
-- @within Logging
--
function API.SetLoggingLevel(_Screen, _File)
    if GUI then
        return;
    end
    QSB.Logging.DisplayLoggingLevel = _Screen;
    QSB.Logging.FileLoggingLevel = _File;
    Logic.ExecuteInLuaLocalState(string.format([[
        QSB.Logging.DisplayLoggingLevel = %d
        QSB.Logging.FileLoggingLevel = %d
    ]], _Screen, _File));
end

-- Core Stuff --

---
-- Gibt die Systemzeit und das Datum formatiert als String zurück.
--
-- @return[type=string] Datum und Uhrzeit
-- @within Internal
-- @local
--
function Core:GetSystemTime()
    local DateTimeString = Framework.GetSystemTimeDateString();
    local Year = DateTimeString:sub(2, 5);
    local Month = DateTimeString:sub(7, 8);
    local Day = DateTimeString:sub(10, 11);
    local Hour = DateTimeString:sub(15, 16);
    local Minute = DateTimeString:sub(18, 19);
    local Second = DateTimeString:sub(22, 23);
    return Day.. "." ..Month.. "." ..Year.. " " ..Hour.. ":" ..Minute.. ":" ..Second;
end

---
-- Formatiert die Nachricht für die Logger.
--
-- @param[type=string]  _Text    Nachricht 
-- @param[type=number]  _Level   Scheregrad
-- @param[type=boolean] _IsFile  Formatiere für Log File
-- @param[type=string]  _Env     Umgebung
-- @return[type=string] Nachricht
-- @within Internal
-- @local
--
function Core:FormatLoggingMessage(_Text, _Level, _IsFile, _Env)
    local Date = self:GetSystemTime();
    local LevelText = "DEBUG";
    if _Level > 1 then
        LevelText = "INFO";
    end
    if _Level > 2 then
        LevelText = "WARN";
    end
    if _Level > 3 then
        LevelText = "ERROR";
    end

    local Prefix = "[" .._Env.. "] ";
    if _IsFile then
        Prefix = Prefix.. "[" ..Date.. "] ";
    end
    Prefix = Prefix ..LevelText.. ": ";
    return Prefix .. _Text;
end

---
-- Schreibt eine Log Meldung in die Logdatei.
--
-- @param[type=string]  _Text    Nachricht 
-- @param[type=number]  _Level   Scheregrad
-- @param[type=string]  _Env     Umgebung
-- @within Internal
-- @local
--
function Core:LogToFile(_Text, _Level, _Env)
    _Level = (tonumber(_Level) ~= nil and tonumber(_Level)) or 1;
    _Env = _Env or "Local";

    if QSB.Logging.FileLoggingLevel == QSB.Logging.Levels.Off then
        return;
    end
    if not GUI then
        _Env = "Global";
        Logic.ExecuteInLuaLocalState(string.format([[Core:LogToFile("%s", "%d", "%s")]], _Text, _Level, _Env));
        return;
    end
    if QSB.Logging.FileLoggingLevel <= _Level then
        local Text = Core:FormatLoggingMessage(_Text, _Level, true, _Env);
        Text = Text:gsub("{cr}", "\n");
        Framework.WriteToLog(Text);
    end
end
---
-- Schreibt eine Log Meldung auf den Bildschirm.
--
-- @param[type=string]  _Text    Nachricht 
-- @param[type=number]  _Level   Scheregrad
-- @param[type=string]  _Env     Umgebung
-- @within Internal
-- @local
--
function Core:LogToScreen(_Text, _Level, _Env)
    _Level = (tonumber(_Level) ~= nil and tonumber(_Level)) or 1;
    _Env = _Env or "Local";

    if QSB.Logging.DisplayLoggingLevel == QSB.Logging.Levels.Off then
        return;
    end
    if not GUI then
        _Env = "Global";
        Logic.ExecuteInLuaLocalState(string.format([[Core:LogToScreen("%s", "%d", "%s")]], _Text, _Level, _Env));
        return;
    end
    if QSB.Logging.DisplayLoggingLevel <= _Level then
        local Text = Core:FormatLoggingMessage(_Text, _Level, false, _Env);
        if _Level == 4 then
            GUI.AddStaticNote(Text);
        else
            GUI.AddNote(Text);
        end
    end
end

