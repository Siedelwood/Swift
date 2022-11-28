-- Läd das Skript mit der Variable des Entwicklungsmodus
Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/development.lua");

-- Setzt den Pfad anhand der Variable aus development.lua
local Path = "maps/externalmap/" ..Framework.GetCurrentMapName().. "/inc/qsb.lua";
-- Wenn der Entwicklungsmodus gesetzt ist, dann nutze den Pfad auf dem PC
if gvMission.DevelopmentMode then
    Path = "E:/Repositories/swift/qsb3/demo/003_grundstruktur_testmap.s6xmap.unpacked/" .. Path;
end
-- Lade das Spript
Script.Load(Path);

