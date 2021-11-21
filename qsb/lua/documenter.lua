local htmlparser = require("htmlparser");

dofile("lua/loader.lua");

---
-- Dieses Skript erzeugt die Benutzerdokumentation. Dazu wird jede Datei
-- einzeln an LDoc übergeben und anschließend ein Index aufgebaut. Das
-- Resultat ist eine Index-Seite auf der alle Bundles als Button-Links
-- angezeigt werden und wo nach Schlagwörtern gesucht werden kann.
--
-- Die Suche nach Schlagwörtern schränkt die Auswahl an Bundles ein. Nur
-- Bundles, die das Schlagwort enthalten, werden noch angezeigt.
--
-- @set sort=true
--

QSB = QSB or {};

SymfoniaDocumenter = {
    Data = {
        BundleInfo = {
            API = {}
        },
    }
}

---
-- Erzeugt die HTML-Dateien für die Dokumentation.
--
-- @within Internal
-- @local
--
function SymfoniaDocumenter:CreateBundleHtmlDocumentation()
    -- Windows <-> Linux Fix
    local docCommand = "cd ../bin && bash.exe ./createdoc";
    local osName = self:GetOsName();
    if osName and osName:find("Linux") then
        docCommand = "cd ../bin && ./createdoc";
    end

    local ParsedBundles = {};
    
    os.execute(docCommand.. " /core");
    if (self:ReadBundleInfo("core")) then
        table.insert(ParsedBundles, "core");
    end

    for i= 1, #SymfoniaLoader.Data.LoadOrder, 1 do
        if SymfoniaLoader.Data.LoadOrder[i][2] then
        local Name = SymfoniaLoader.Data.LoadOrder[i][1]:lower();
            os.execute(docCommand.. " /bundles/ " ..Name);
            if (self:ReadBundleInfo(Name)) then
                table.insert(ParsedBundles, Name);
            end
        end
    end
    for i= 1, #SymfoniaLoader.Data.AddOnLoadOrder, 1 do
        if SymfoniaLoader.Data.AddOnLoadOrder[i][2] then
            local Name = SymfoniaLoader.Data.AddOnLoadOrder[i][1]:lower();
            os.execute(docCommand.. " /addons/ " ..Name);
            if (self:ReadBundleInfo(Name)) then
                table.insert(ParsedBundles, Name);
            end
        end
    end

    local function compareEntries(a, b)
        return a[2] < b[2];
    end
    table.sort(self.Data.BundleInfo.API, compareEntries);
end

---
-- Gibt den Namen der Linux-Distribution zurück.
-- @return[type=string] Name des Betriebssystems
-- @within Internal
-- @locals
--
function SymfoniaDocumenter:GetOsName()
    local raw_os_name;
    local popen_status, popen_result = pcall(io.popen, "")
    if popen_status then
        popen_result:close()
        raw_os_name = io.popen('uname -s','r'):read('*l')
    else
        local env_OS = os.getenv('OS')
        if env_OS and env_ARCH then
            raw_os_name = env_OS
        end
    end
    return raw_os_name;
end

---
-- Baut den Index der Dokumentation zusammen.
--
-- @within Internal
-- @local
--
function SymfoniaDocumenter:CreateDocumentationIndex()
    local FileText = self:LoadDocumentationIndexTemplate();
    local BundleList = self:CreateDocumentationIndexLink("Core", "lua/");

    local sortList = function(a, b)
        return a[1] < b[1];
    end
    
    -- Sortiere Bundles und füge hinzu
    local BundleLoadOrder = self:CopyTable(SymfoniaLoader.Data.LoadOrder);
    table.sort(BundleLoadOrder, sortList);
    for i= 1, #BundleLoadOrder, 1 do
        if BundleLoadOrder[i][2] then
            BundleList = BundleList .. self:CreateDocumentationIndexLink(BundleLoadOrder[i][1], "lua/bundles/");
        end
    end

    -- Sortiere AddOns und füge hinzu
    local AddOnLoadOrder = self:CopyTable(SymfoniaLoader.Data.AddOnLoadOrder);
    table.sort(AddOnLoadOrder, sortList);
    for i= 1, #AddOnLoadOrder, 1 do
        if AddOnLoadOrder[i][2] then
            BundleList = BundleList .. self:CreateDocumentationIndexLink(AddOnLoadOrder[i][1], "lua/addons/");
        end
    end

    FileText = FileText:gsub("###PLACEHOLDER_LUA_BUNDLES###", BundleList);
    FileText = FileText:gsub("###PLACEHOLDER_DIRECT_LINK###", self:GetDirectLinks());
    FileText = FileText:gsub("###PLACEHOLDER_BUNDLE_LINK###", self:GetBundleLinks());

    os.remove("doc/index.html");
    local fh = io.open("doc/index.html", "wt");
    assert(fh, "File not created: doc/index.html");
    fh:write(FileText);
    fh:close();
end

---
-- Kopiert den Inhalt einer Table in ein neue Table.
--
-- @param[type=table] _Table Table zum kopieren
-- @return[type=table] Kopie
-- @within Internal
-- @local
--
function SymfoniaDocumenter:CopyTable(_Table)
    local newTable = {};
    for k, v in pairs(_Table) do
        if type(v) == "table" then
            newTable[k] = self:CopyTable(v);
        else
            newTable[k] = v;
        end
    end
    return newTable;
end

---
-- Erzeugt einen Link auf der Index-Seite der Doku und gibt ihn als String
-- zurück.
--
-- @param[type=string] _Name Name des Bundle
-- @param[type=string] _Folder Relativer Pfad
-- @return[type=string] HTML des Links
-- @within Internal
-- @local
--
function SymfoniaDocumenter:CreateDocumentationIndexLink(_Name, _Folder)
    local fh = io.open("default/index.panel.template.html", "rt");
    assert(fh, "File not found: default/index.panel.template.html");
    fh:seek("set", 0);

    local HTML = fh:read("*all");
    HTML = HTML:gsub("###PLACEHOLDER_BUNDLE_NAME###", _Name);
    HTML = HTML:gsub("###PLACEHOLDER_BUNDLE_LINK###", "html/" .._Name:lower().. ".lua.html");
    return HTML
end

---
-- Läd das Template der index.html und gibt es als String zurück.
--
-- @return[type=string] Dateiinhalt
-- @within Internal
-- @local
--
function SymfoniaDocumenter:LoadDocumentationIndexTemplate()
    local fh = io.open("default/index.template.html", "rb");
    assert(fh, "File not found: default/index.template.html");
    fh:seek("set", 0);
    local Contents = fh:read("*all");
    fh:close();
    return Contents;
end

---
-- Läd eine Quelldatei und gibt einen String mit Schlagwörtern zurück.
-- Schlagworter sind Behavior- oder Funktionsnamen.
--
-- <b>Hinweis</b>: Schlagwörter werden immer mit der gesamten Zeile kopiert,
-- in der sie stehen (ist einfacher zu programmieren und ich bin faul).
--
-- @param[type=string] _File Dateiname
-- @return[type=string] Schlagworter
-- @within Internal
-- @local
--
function SymfoniaDocumenter:CreateSearchTagsFromSourceFile(_File)
    --[[
    local fh = io.open(_File, "rt");
    assert(fh, "File not found: " .._File);
    fh:seek("set", 0);

    local TagString = "";
    local LUA = fh:read();
    while (LUA ~= nil) do
        -- Einfach alles lesen... fuck of parsing
        TagString = TagString .. LUA:gsub("<", "&#x3C;"):gsub(">", "&#x3E;") .. "\n";
        -- Nächste Zeile
        LUA = fh:read();
    end
    return TagString;
    ]]
    return "";
end

---
-- Parst die zum Bundle gehörende HTML-Datei und speichert die Suchkriterien
-- im Documenter.
--
-- Gibt zudem zurück, ob das Parsen erfolgreich war.
--
-- @param[type=string] _Bundle Bundle das geparst wird
-- @return[type=boolean] Parsing war erfolgreich
-- @within Internal
-- @local
--
function SymfoniaDocumenter:ReadBundleInfo(_Bundle)
    local Path = "doc/html/" .._Bundle.. ".lua.html";

    self.Data.BundleInfo[_Bundle] = {};

    local fh = io.open(Path, "rt");
    if not fh then
        print ("Could not parse file: ", Path);
        return false;
    end

    local HTML = htmlparser.parse(fh:read("*all"), 999999);

    -- Description --

    self.Data.BundleInfo[_Bundle].Name = _Bundle;
    self.Data.BundleInfo[_Bundle].Description = "";
    local Description = HTML:select("#content > p");
    if #Description > 0 then
        self.Data.BundleInfo[_Bundle].Description = Description[1]:getcontent():gsub("\n", "");
    end
    
    -- API --

    local index = #self.Data.BundleInfo.API;
    local anchors = HTML:select("dt a");
    for i= 1, #anchors, 1 do
        local href = anchors[i]:gettext():gsub('<a name = "', ""):gsub('"></a>', "");
        self.Data.BundleInfo.API[index+i] = {_Bundle, href};
    end
    local summary = HTML:select(".summary");
    for i= 1, #summary, 1 do
        self.Data.BundleInfo.API[index+i][3] = summary[i]:getcontent():gsub("\n", "");
    end
    local info = HTML:select("dd");
    for i= 1, #info, 1 do
        local Content = info[i]:getcontent():gsub("<", "&#x3C;"):gsub(">", "&#x3E;");
        self.Data.BundleInfo.API[index+i][4] = Content;
    end

    return true;
end

---
-- Gibt das HTML aller Direktverlinkungen zurück.
--
-- @return[type=string] HTML
-- @within Internal
-- @local
--
function SymfoniaDocumenter:GetDirectLinks()
    local Template = '<div id="%s" class="result method"><a href="%s">%s</a><br>%s<span class="docInvisibleContent">%s</span></div>';
    local HTML = "";

    for i= 1, #self.Data.BundleInfo.API, 1 do
        local v = self.Data.BundleInfo.API[i];
        local Link = "html/" ..v[1].. ".lua.html#" ..v[2];
        local Name = v[2];

        HTML = HTML .. string.format(Template, v[1].. "_" ..Name, Link, Name, v[3], v[4] or "");
    end
    return HTML;
end

---
-- Gibt das HTML der Bundle-Links zurück.
--
-- @return[type=string] HTML
-- @within Internal
-- @local
--
function SymfoniaDocumenter:GetBundleLinks()
    local Template = '<div id="%s" class="result module"><a href="%s">%s</a><br>%s</div>';

    local Bundles = {};
    for k, v in pairs(self.Data.BundleInfo) do
        if k ~= "API" then
            table.insert(
                Bundles, string.format(Template, k, "html/" ..k.. ".lua.html", v.Name or "", v.Description or "")
            )
        end
    end

    local function sortTable(a, b)
        return a < b;
    end
    table.sort(Bundles, sortTable);
    return table.concat(Bundles);
end

-- -------------------------------------------------------------------------- --

SymfoniaDocumenter:CreateBundleHtmlDocumentation();
SymfoniaDocumenter:CreateDocumentationIndex();