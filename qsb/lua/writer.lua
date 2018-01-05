---
-- Läd die Quelldateien und fügrt sie zur QSB zusammen.
--
-- Dieses Skript kann nicht aus dem Spiel ausgeführt werden! Es wird eine
-- Installation von Lua 5.1 oder höher auf dem PC benötigt. Lua kann auf
-- Sorceforge herruntergeladen werden. <br/>
-- <a href="http://luabinaries.sourceforge.net">Lua-Release</a>
--
-- Um Lua zu installieren Lege die Quellen von Lua unter Windows nach C:/Lua
-- und passe die Systemvariable PATH so an, dass Lua über die Power Shell oder
-- die Eingabeaufforderung ausgeführt werden kann.
--
-- <p>Unter Linux und Mac müssen einige Abhängigkeiten von LDoc nachinstalliert
-- werden um die Dokumentation generieren zu können. Die Installationen müssen
-- mit Root-Rechten durchgeführt werden!</p>
-- <ul>
-- <li>apt install luarocks</li>
-- <li>luarocks install luafilesystem</li>
-- <li>luarocks install penlight</li>
-- </ul>
--
-- Um die QSB zusammenfügen zu lassen, nutze die make.bat im Hauptverzeichnis
-- des Projektes oder rufe dieses Skript in der Shell auf.
--
-- @script SymfoniaWriter
--

dofile("qsb/lua/loader.lua");
local fh = io.open("Symfonia.lua", "r");
if fh then
    fh:close();
    os.remove("Symfonia.lua");
end
SymfoniaLoader:CreateQSB();