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
        if string.find(arg[i], "^-loadorder=.*$") then
            dofile(string.sub(arg[i], 12));
            SymfoniaLoader.Data.LoadOrder = LoadOrder[1];
            SymfoniaLoader.Data.AddOnLoadOrder = LoadOrder[2];
        end
    else
        -- Externe Module laden
        table.insert(Externals, arg[i]);
    end
end

SymfoniaLoader:CreateQSB(Externals);