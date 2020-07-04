-- Logging ---------------------------------------------------------------------

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
    local MessageFunc = Logic.DEBUG_AddNote;
    if GUI then
        MessageFunc = GUI.AddNote;
    end
    MessageFunc(_Message);
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
        Logic.ExecuteInLuaLocalState('GUI.AddStaticNote("' .._Message.. '")');
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
-- Schreibt einen FATAL auf den Bildschirm und ins Log.
--
-- <p><b>Alias:</b> API.Dbg</p>
-- <p><b>Alias:</b> fatal</p>
-- <p><b>Alias:</b> dbg</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
-- @local
--
function API.Fatal(_Message)
    API.StaticNote("FATAL: " .._Message)
    Framework.WriteToLog("FATAL: " .._Message);
end
API.Dbg = API.Fatal;
fatal = API.Fatal;
dbg = API.Fatal;

---
-- Schreibt eine WARNING auf den Bildschirm und ins Log.
--
-- <p><p><b>Alias:</b> warn</p></p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
-- @local
--
function API.Warn(_Message)
    API.StaticNote("WARNING: " .._Message)
    Framework.WriteToLog("WARNING: " .._Message);
end
warn = API.Warn;

