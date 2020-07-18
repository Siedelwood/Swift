-- Placeholders ----------------------------------------------------------------

QSB.Placeholders = {
    Names = {},
    EntityTypes = {},
};

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
-- @field ocean   Ozeanblau
-- @field lucid   Transparent
--
QSB.Placeholders.Colors = {
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
    lucid   = "{@color:0,0,0,0}"
};

-- API Stuff --

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
            _Message[k] = Core:ConvertPlaceholders(v);
        end
        return _Message;
    elseif type(_Message) == "string" then
        return Core:ConvertPlaceholders(_Message);
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
        log("API.AddNamePlaceholder: Only strings, numbers, or tables are allowed!", LEVEL_ERROR);
        return;
    end
    QSB.Placeholders.Names[_Name] = _Replacement;
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
        log("API.AddEntityTypePlaceholder: EntityType does not exist!", LEVEL_ERROR);
        return;
    end
    QSB.Placeholders.EntityTypes[_Type] = _Replacement;
end

-- Core Stuff --

---
-- Ersetzt alle Platzhalter innerhalb des übergebenen Text.
-- @param[type=string] _Text Text mit Platzhaltern
-- @return[type=string] Ersetzter Text
-- @within Internal
-- @local
--
function Core:ConvertPlaceholders(_Text)
    local s1, e1, s2, e2;
    while true do
        local Before, Placeholder, After, Replacement, s1, e1, s2, e2;
        if _Text:find("{name:") then
            Before, Placeholder, After, s1, e1, s2, e2 = self:SplicePlaceholderText(_Text, "{name:");
            Replacement = QSB.Placeholders.Names[Placeholder];
            _Text = Before .. API.Localize(Replacement or "ERROR_PLACEHOLDER_NOT_FOUND") .. After;
        elseif _Text:find("{type:") then
            Before, Placeholder, After, s1, e1, s2, e2 = self:SplicePlaceholderText(_Text, "{type:");
            Replacement = QSB.Placeholders.EntityTypes[Placeholder];
            _Text = Before .. API.Localize(Replacement or "ERROR_PLACEHOLDER_NOT_FOUND") .. After;
        end
        if s1 == nil or e1 == nil or s2 == nil or e2 == nil then
            break;
        end
    end
    _Text = self:ReplaceColorPlaceholders(_Text);
    return _Text;
end

---
-- Zerlegt einen String in 3 Strings: Anfang, Platzhalter, Ende.
-- @param[type=string] _Text  Text
-- @param[type=string] _Start Anfang-Tag
-- @return[type=string] Text vor dem Platzhalter
-- @return[type=string] Platzhalter
-- @return[type=string] Text nach dem Platzhalter
-- @return[type=number] Anfang Start-Tag
-- @return[type=number] Ende Start-Tag
-- @return[type=number] Anfang Schluss-Tag
-- @return[type=number] Ende Schluss-Tag
-- @within Internal
-- @local
--
function Core:SplicePlaceholderText(_Text, _Start)
    local s1, e1 = _Text:find(_Start);
    local s2, e2 = _Text:find("}", e1);

    local Before      = _Text:sub(1, s1-1);
    local Placeholder = _Text:sub(e1+1, s2-1);
    local After       = _Text:sub(e2+1);
    return Before, Placeholder, After, s1, e1, s2, e2;
end

---
-- Ersetzt Platzhalter mit einer Farbe mit dem Wert aus der Wertetabelle.
-- @param[type=string] Text mit Platzhaltern
-- @return[type=string] Text mit ersetzten Farben
-- @see QSB.Placeholders.Colors
-- @within Internal
-- @local
--
function Core:ReplaceColorPlaceholders(_Text)
    for k, v in pairs(QSB.Placeholders.Colors) do
        _Text = _Text:gsub("{" ..k.. "}", v);
    end
    return _Text;
end

