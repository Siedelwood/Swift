-- Messages API ------------------------------------------------------------- --

---
-- Modul für die Nutzung von Platzhaltern.
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Schreibt eine Nachricht in das Debug Window. Der Text erscheint links am
-- Bildschirm und ist nicht statisch.
--
-- <p><b>Alias:</b> GUI_Note</p>
--
-- @param[type=string] _Text Anzeigetext
-- @within Anwenderfunktionen
-- @local
--
function API.Note(_Text)
    ModuleTextTools:Note(ModuleTextTools:Localize(_Text));
end
GUI_Note = API.Note;

---
-- Schreibt eine Nachricht in das Debug Window. Der Text erscheint links am
-- Bildschirm und verbleibt dauerhaft am Bildschirm.
--
-- <p><b>Alias:</b> GUI_StaticNote</p>
--
-- @param[type=string] _Text Anzeigetext
-- @within Anwenderfunktionen
--
function API.StaticNote(_Text)
    ModuleTextTools:StaticNote(ModuleTextTools:Localize(_Text));
end
GUI_StaticNote = API.StaticNote;

---
-- Löscht alle Nachrichten im Debug Window.
--
-- @within Anwenderfunktionen
--
function API.ClearNotes()
    ModuleTextTools:ClearNotes();
end
GUI_ClearNotes = API.ClearNotes;

---
-- Ermittelt den lokalisierten Text anhand der eingestellten Sprache der QSB.
--
-- Wird ein normaler String übergeben, wird dieser sofort zurückgegeben.
--
-- @param _Text Anzeigetext (String oder Table)
-- @return[type=string] Message
-- @within Anwenderfunktionen
-- @local
--
function API.Localize(_Text)
    return ModuleTextTools:Localize(_Text);
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
-- <pre>{YOUR_COLOR}</pre>
-- Ersetze YOUR_COLOR in deinen Texten mit einer der gelisteten Farben.
--
-- <table border="1">
-- <tr><th>Platzhalter</th><th>Farbe</th><th>RGBA</th></tr>
-- <tr><td>red</td>     <td>Rot</td>          <td>255,80,80,255</td></tr>
-- <tr><td>blue</td>    <td>Blau</td>         <td>104,104,232,255</td></tr>
-- <tr><td>yellow</td>  <td>Gelp</td>         <td>255,255,80,255</td></tr>
-- <tr><td>green</td>   <td>Grün</td>         <td>80,180,0,255</td></tr>
-- <tr><td>white</td>   <td>Weiß</td>         <td>255,255,255,255</td></tr>
-- <tr><td>black</td>   <td>Schwarz</td>      <td>0,0,0,255</td></tr>
-- <tr><td>grey</td>    <td>Grau</td>         <td>140,140,140,255</td></tr>
-- <tr><td>azure</td>   <td>Azurblau</td>     <td>255,176,30,255</td></tr>
-- <tr><td>orange</td>  <td>Orange</td>       <td>255,176,30,255</td></tr>
-- <tr><td>amber</td>   <td>Bernstein</td>    <td>224,197,117,255</td></tr>
-- <tr><td>violet</td>  <td>Violett</td>      <td>180,100,190,255</td></tr>
-- <tr><td>pink</td>    <td>Rosa</td>         <td>255,170,200,255</td></tr>
-- <tr><td>scarlet</td> <td>Scharlachrot</td> <td>190,0,0,255</td></tr>
-- <tr><td>magenta</td> <td>Magenta</td>      <td>190,0,89,255</td></tr>
-- <tr><td>olive</td>   <td>Olivgrün</td>     <td>74,120,0,255</td></tr>
-- <tr><td>sky</td>     <td>Ozeanblau</td>    <td>145,170,210,255</td></tr>
-- <tr><td>tooltip</td> <td>Tooltip-Blau</td> <td>51,51,120,255</td></tr>
-- <tr><td>lucid</td>   <td>Transparent</td>  <td>0,0,0,0</td></tr>
-- </table>
--
-- @param _Message Text oder Table mit Texten
-- @return Ersetzter Text
-- @within Anwenderfunktionen
--
function API.ConvertPlaceholders(_Message)
    if type(_Message) == "table" then
        for k, v in pairs(_Message) do
            _Message[k] = ModuleTextTools:ConvertPlaceholders(v);
        end
        return _Message;
    elseif type(_Message) == "string" then
        return ModuleTextTools:ConvertPlaceholders(_Message);
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
    ModuleTextTools.m_Placeholders.Names[_Name] = _Replacement;
end

---
-- Fügt einen Platzhalter für einen Entity-Typ hinzu.
--
-- Innerhalb des Textes wird der Plathalter wie folgt geschrieben:
-- <pre>{type:ENTITY_TYP}</pre>
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
    ModuleTextTools.m_Placeholders.EntityTypes[_Type] = _Replacement;
end

