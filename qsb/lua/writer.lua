---
-- Läd die Quelldateien und fügt sie zur QSB zusammen.
--
-- <p>Dieses Skript kann nicht aus dem Spiel ausgeführt werden! Es wird eine
-- Installation von Lua 5.1 oder höher auf dem PC benötigt!</p>
--
-- <h2>Installation auf Windows</h2>
-- <p>Um sauber mit Lua unter Windows zu arbeiten, wird die Distribution, ein
-- ordentlicher Source Code Editor und eine Git-Bash benötigt. Die Distribution
-- enthält die Binaries von Lua. Ohne die geht gar nichts! Die Installation von
-- Git bringt einen voll konfigurierten MinGW mit - ein Linux-Subsystem. Die
-- Wahl des Editors ist frei, jedoch gibt es nur wenige gute.</p>
--
-- <h3>Installation von Lua</h3>
-- <ul>
-- <li>
-- Lua-Binaries herunterladen:<br>
-- <a href="http://luadist.org/" target="_blank">LuaDist</a>
-- </li>
-- <li>
-- Den Inhalt des Archivs in den Programmordner kopieren und das LuaDist -
-- Verzeichnis umbenennen in "Lua".<br>
-- Beispiel: <pre>C:/Program Files/Lua</pre>
-- </li>
-- <li>
-- Das Verzeichnis .../Lua/bin der Systemvariable PATH hinzufügen. Das geschieht
-- über die Systemsteuerung.<br>
-- Beispiel: <pre>C:/Program Files/Lua/bin</pre>
-- </li>
-- <li>
-- Eine Eingabeaufforderung oder eine Powershell öffnen und lua -v bzw.
-- lua --version eingeben. Lua sollte nun die Versionsinfo anzeigen. Damit ist
-- Lua installiert.
-- </li>
-- </ul>
--
-- <h3>Installation von Git</h3>
-- <ul>
-- <li>
-- Git für Windows herunterladen:<br>
-- <a href="https://git-scm.com/download/win" target="_blank">Git</a>
-- </li>
-- <li>
-- Git installieren. Danach eine Eingabeaufforderung oder Powershell aufmachen
-- und git --version eingeben. Es sollte die Versionsinfo von Git angezeigt
-- werden.
-- </li>
-- <li>
-- Im Git-Verzeichnis nach bash.exe suchen. Der komplette Pfad muss zu PATH
-- hinzugefügt werden.<br>
-- Beispiel: <pre>C:/Program Files/Git/bin/bash.exe</pre>
-- </li>
-- </ul>
-- 
-- <h3>Setup Visual Studio Code</h3>
-- Neben Atom eignet sich auch Visual Studio Code als Editor. Hier ist der
-- Vorteil die Möglichkeit ein Terminal zu integrieren. So kann man Lua
-- sehr bequem ausführen!
-- <ul>
-- <li>
-- Visual Studio Code installieren:<br>
-- <a href="https://code.visualstudio.com/download" target="_blank">VS Code</a>
-- </li>
-- <li>
-- Einstellungen öffnen und Integiertes Terminal auf bash.exe setzen.
-- <br>Beispiel:
-- <pre>"terminal.integrated.shell.windows": "C:\\Program Files\\Git\\bin\\bash.exe"</pre>
-- </li>
-- <li>
-- Visual Studio Code neu starten und danach das integrierte Terminal öffnen.
-- Es sollte nun eine Bash statt einer Eingabeaufforderung angezeigt werden.
-- (Die Bash hat mehrfarbige Texte, die Eingabeaufforderung ist nur weiß.)
-- </li>
-- </ul>
--
-- <h2>Installation auf Linux/Mac</h2>
-- <p>Unter Linux und Mac müssen einige Abhängigkeiten von LDoc nachinstalliert
-- werden um die Dokumentation generieren zu können. Die Installationen müssen
-- mit Root-Rechten durchgeführt werden!</p>
-- 
-- <h3>Beispiel für Debian / Ubuntu / Linux Mint:</h3>
-- Superuser werden:
-- <pre>su -</pre>
-- Lua installieren:
-- <pre>apt install lua</pre>
-- Lua Package Manager installieren:
-- <pre>apt install luarocks</pre>
-- LFS installieren:
-- <pre>luarocks install luafilesystem</pre>
-- Penlight installieren:
-- <pre>luarocks install penlight</pre>
-- 
-- <p>Anschließend kann man im Terminal lua -v ausführen und sollte die
-- Version angezeigt bekommen.</p>
--

QSB = QSB or {};

SymfoniaWriter = {}

---
-- Erzeugt die HTML-Dateien für die Dokumentation.
--
-- @within Internal
-- @local
--
function SymfoniaWriter:CreateBundleHtmlDocumentation()
    -- Windows <-> Linux Fix
    local docCommand = "cd bin && bash.exe ./createdoc.sh";
    if self:GetOSName():lower():find("cygwin") or self:GetOSName():lower():find("mingw") 
    or self:GetOSName():lower():find("linux") then
        docCommand = "cd bin && ./createdoc.sh";
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
function SymfoniaWriter:GetOSName()
    local osname = "Unknown";
    fh, err = io.popen("uname -o 2>/dev/null","r");
    if fh and err == 0 then
        osname = fh:read();
    end
    return osname
end

---
-- Baut den Index der Dokumentation zusammen.
--
-- @within Internal
-- @local
--
function SymfoniaWriter:CreateDocumentationIndex()
    local FileText = self:LoadDocumentationIndexTemplate();
    local BundleList = self:CreateDocumentationIndexLink("Core", "qsb/lua/");

    local sortList = function(a, b)
        return a[1] < b[1];
    end
    
    -- Sortiere Bundles und füge hinzu
    local BundleLoadOrder = self:CopyTable(SymfoniaLoader.Data.LoadOrder);
    table.sort(BundleLoadOrder, sortList);
    for i= 1, #BundleLoadOrder, 1 do
        if BundleLoadOrder[i][2] then
            BundleList = BundleList .. self:CreateDocumentationIndexLink(BundleLoadOrder[i][1], "qsb/lua/bundles/");
        end
    end

    -- Sortiere AddOns und füge hinzu
    local AddOnLoadOrder = self:CopyTable(SymfoniaLoader.Data.AddOnLoadOrder);
    table.sort(AddOnLoadOrder, sortList);
    for i= 1, #AddOnLoadOrder, 1 do
        if AddOnLoadOrder[i][2] then
            BundleList = BundleList .. self:CreateDocumentationIndexLink(AddOnLoadOrder[i][1], "qsb/lua/addons/");
        end
    end

    FileText = FileText:gsub("###PLACEHOLDER_LUA_BUNDLES###", BundleList);
    os.remove("qsb/doc/index.html");
    local fh = io.open("qsb/doc/index.html", "wt");
    assert(fh, "File not created: qsb/doc/index.html");
    fh:write(FileText);
    fh:close();
end

---
-- Kopiert den Inhalt einer Table in ein neue Table.
--
-- @param _Table [table] Table zum kopieren
-- @return [table] Kopie
-- @within Internal
-- @local
--
function SymfoniaWriter:CopyTable(_Table)
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
-- @param _Name [string] Name des Bundle
-- @param _Folder [string] Relativer Pfad
-- @return [string] HTML des Links
-- @within Internal
-- @local
--
function SymfoniaWriter:CreateDocumentationIndexLink(_Name, _Folder)
    local fh = io.open("qsb/default/index.panel.template.html", "rt");
    assert(fh, "File not found: qsb/default/index.panel.template.html");
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
-- @return [string] Dateiinhalt
-- @within Internal
-- @local
--
function SymfoniaWriter:LoadDocumentationIndexTemplate()
    local fh = io.open("qsb/default/index.template.html", "rb");
    assert(fh, "File not found: qsb/default/index.template.html");
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
-- @param _File [string] Dateiname
-- @return [string] Schlagworter
-- @within Internal
-- @local
--
function SymfoniaWriter:CreateSearchTagsFromSourceFile(_File)
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

dofile("qsb/lua/loader.lua");
local fh = io.open("var/qsb.lua", "r");
if fh then
    fh:close();
    os.remove("var/qsb.lua");
end

local Externals = {};

-- Argumente auslesen
for i= 1, #arg, 1 do
    if string.find(arg[i], "^-.*$") then
        -- Alternative Load Order laden
        if string.find(arg[i], "^-l.*$") then
            dofile(string.sub(arg[i], 3));
            SymfoniaLoader.Data.LoadOrder = LoadOrder[1];
            SymfoniaLoader.Data.AddOnLoadOrder = LoadOrder[2];
        end
        if string.find(arg[i], "^-d.*$") then
            UpdateUserDocumentation = true;
        end
    else
        -- Externe Module laden
        table.insert(Externals, arg[i]);
    end
end

-- Bundle-Doku aktualisieren
if UpdateUserDocumentation then
    SymfoniaWriter:CreateBundleHtmlDocumentation();
    SymfoniaWriter:CreateDocumentationIndex();
end

SymfoniaLoader:CreateQSB(Externals);