-- Messages API ------------------------------------------------------------- --

---
-- TODO: add doc
-- @within Beschreibung
-- @set sort=true
--
PluginTextTools = PluginTextTools or {};

---
-- Farben, die als Platzhalter genutzt werden können.
--
-- Verwendung:
-- <pre>{YOUR_COLOR}</pre>
-- Ersetze YOUR_COLOR mit einer der gelisteten Farben.
--
-- @field red     Rot
-- @field blue    Blau
-- @field yellow  Gelp
-- @field green   Grün
-- @field white   Weiß
-- @field black   Schwarz
-- @field grey    Grau
-- @field azure   Azurblau
-- @field orange  Orange
-- @field amber   Bernstein
-- @field violet  Violett
-- @field pink    Rosa
-- @field scarlet Scharlachrot
-- @field magenta Magenta
-- @field olive   Olivgrün
-- @field sky     Ozeanblau
-- @field tooltip Tooltip-Blau
-- @field lucid   Transparent
--
QSB.TextColors = {
    red     = "{@color:255,80,80,255}",
    blue    = "{@color:104,104,232,255}",
    yellow  = "{@color:255,255,80,255}",
    green   = "{@color:80,180,0,255}",
    white   = "{@color:255,255,255,255}",
    black   = "{@color:0,0,0,255}",
    grey    = "{@color:140,140,140,255}",
    azure   = "{@color:0,160,190,255}",
    orange  = "{@color:255,176,30,255}",
    amber   = "{@color:224,197,117,255}",
    violet  = "{@color:180,100,190,255}",
    pink    = "{@color:255,170,200,255}",
    scarlet = "{@color:190,0,0,255}",
    magenta = "{@color:190,0,89,255}",
    olive   = "{@color:74,120,0,255}",
    sky     = "{@color:145,170,210,255}",
    tooltip = "{@color:51,51,120,255}",
    lucid   = "{@color:0,0,0,0}"
};

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
function API.Note(_Text)
    PluginTextTools:Note(PluginTextTools:Localize(_Text));
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
function API.StaticNote(_Text)
    PluginTextTools:StaticNote(PluginTextTools:Localize(_Text));
end
GUI_StaticNote = API.StaticNote;

---
-- Löscht alle Nachrichten im Debug Window.
--
-- @within Anwenderfunktionen
--
function API.ClearNotes()
    PluginTextTools:ClearNotes();
end
GUI_ClearNotes = API.ClearNotes;

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
function API.Localize(_Text)
    return PluginTextTools:Localize(_Text);
end

---
-- Ersetzt alle Platzhalter im Text oder in der Table.
--
-- Mögliche Platzhalter:
-- <ul>
-- <li>{name:xyz} - Ersetzt einen Skriptnamen mit dem zuvor gesetzten Wert.</li>
-- <li>{type:xyz} - Ersetzt einen Typen mit dem zuvor gesetzten Wert.</li>
-- </ul>
--
-- Außerdem werden einige Standardfarben ersetzt.
-- @see QSB.Placeholders.Colors
--
-- @param _Message Text oder Table mit Texten
-- @return Ersetzter Text
-- @within Anwenderfunktionen
--
function API.ConvertPlaceholders(_Message)
    if type(_Message) == "table" then
        for k, v in pairs(_Message) do
            _Message[k] = PluginTextTools:ConvertPlaceholders(v);
        end
        return _Message;
    elseif type(_Message) == "string" then
        return PluginTextTools:ConvertPlaceholders(_Message);
    else
        return _Message;
    end
end

---
-- Fügt einen Platzhalter für den angegebenen Namen hinzu.
--
-- Innerhalb des Textes wird der Plathalter wie folgt geschrieben:
-- <pre>{name:YOUR_NAME}</pre>
-- YOUR_NAME muss mit dem Namen ersetzt werden.
--
-- @param[type=string] _Name        Name, der ersetzt werden soll
-- @param[type=string] _Replacement Wert, der ersetzt wird
-- @within Anwenderfunktionen
--
function API.AddNamePlaceholder(_Name, _Replacement)
    if type(_Replacement) == "function" or type(_Replacement) == "thread" then
        error("API.AddNamePlaceholder: Only strings, numbers, or tables are allowed!", true);
        return;
    end
    PluginTextTools.m_Placeholders.Names[_Name] = _Replacement;
end

---
-- Fügt einen Platzhalter für einen Entity-Typ hinzu.
--
-- Innerhalb des Textes wird der Plathalter wie folgt geschrieben:
-- <pre>{name:ENTITY_TYP}</pre>
-- ENTITY_TYP muss mit einem Entity-Typ ersetzt werden. Der Typ wird ohne
-- Entities. davor geschrieben.
--
-- @param[type=string] _Name        Scriptname, der ersetzt werden soll
-- @param[type=string] _Replacement Wert, der ersetzt wird
-- @within Anwenderfunktionen
--
function API.AddEntityTypePlaceholder(_Type, _Replacement)
    if Entities[_Type] == nil then
        error("API.AddEntityTypePlaceholder: EntityType does not exist!", true);
        return;
    end
    PluginTextTools.m_Placeholders.EntityTypes[_Type] = _Replacement;
end

