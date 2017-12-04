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
-- Um die QSB zusammenfügen zu lassen, nutze die make.bat im Hauptverzeichnis
-- des Projektes oder rufe dieses Skript in der Shell auf.
--
-- @script SynfoniaWriter
--

dofile("src/loader.lua");
local fh = io.open("synfonia.lua", "r");
if fh then
    fh:close();
    os.remove("synfonia.lua");
end
SynfoniaLoader:CreateQSB();