dofile("lua/loader.lua");

QSB = QSB or {};

SymfoniaDocumenter = {}

---
-- Erzeugt die HTML-Dateien für die Dokumentation.
--
-- @within Internal
-- @local
--
function SymfoniaDocumenter:CreateBundleHtmlDocumentation()
    -- Windows <-> Linux Fix
    local docCommand = "cd ../bin && bash.exe ./createdoc.sh";
    local osName = self:GetOsName();
    if osName and osName:find("Linux") then
        docCommand = "cd ../bin && ./createdoc.sh";
    end
    
    os.execute(docCommand.. " / core");
    for i= 1, #SymfoniaLoader.Data.LoadOrder, 1 do
        if SymfoniaLoader.Data.LoadOrder[i][2] then
            os.execute(docCommand.. " /bundles/ " ..SymfoniaLoader.Data.LoadOrder[i][1]:lower());
        end
    end
    for i= 1, #SymfoniaLoader.Data.AddOnLoadOrder, 1 do
        if SymfoniaLoader.Data.AddOnLoadOrder[i][2] then
            os.execute(docCommand.. " /addons/ " ..SymfoniaLoader.Data.AddOnLoadOrder[i][1]:lower());
        end
    end
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
    HTML = HTML:gsub("###PLACEHOLDER_BUNDLE_CONTENTS###", self:CreateSearchTagsFromSourceFile(_Folder .. _Name:lower() .. ".lua"));
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
    local fh = io.open(_File, "rt");
    assert(fh, "File not found: " .._File);
    fh:seek("set", 0);

    local TagString = "";
    local LUA = fh:read();
    while (LUA ~= nil) do
        -- Kommentare
        local s, e = LUA:find("^-- .*$");
        if s then
            TagString = TagString .. "<p>" .. LUA:sub(s, e) .. "</p>";
        end
        -- API calls
        local s, e = LUA:find("^function API.*$");
        if s then
            TagString = TagString .. "<p>" .. LUA:sub(s, e) .. "</p>";
        end
        -- Alias
        local s, e = LUA:find("<b>Alias<\\/b>: ");
        if e then
            TagString = TagString .. "<p>" .. LUA:sub(e+1) .. "</p>";
        end
        -- Rewards
        local s, e = LUA:find("^b_Reward.*=.*$");
        if s then
            TagString = TagString .. "<p>" .. LUA:sub(s+2, e-4) .. "</p>";
        end
        -- Reprisals
        local s, e = LUA:find("^b_Reprisal.*=.*$");
        if s then
            TagString = TagString .. "<p>" .. LUA:sub(s+2, e-4) .. "</p>";
        end
        -- Trigger
        local s, e = LUA:find("^b_Trigger.*=.*$");
        if s then
            TagString = TagString .. "<p>" .. LUA:sub(s+2, e-4) .. "</p>";
        end
        -- Goals
        local s, e = LUA:find("^b_Goal.*=.*$");
        if s then
            TagString = TagString .. "<p>" .. LUA:sub(s+2, e-4) .. "</p>";
        end
        -- Nächste Zeile
        LUA = fh:read();
    end
    return TagString;
end

-- -------------------------------------------------------------------------- --

SymfoniaDocumenter:CreateBundleHtmlDocumentation();
SymfoniaDocumenter:CreateDocumentationIndex();