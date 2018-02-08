-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia Loader                                                       # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es den Quellcode von Symfonia zu nutzen, ohne vorher eine QSB
-- generieren zu lassen.
--
-- Vorallem während des Entwicklungsprozesses ist es störend, wenn man sich
-- immer wieder eine neue QSB bauen muss. Der Loader ermöglicht es, die QSB,
-- bzw. ihre Quelldateien, während der Entwicklung direkt aus dem Projektordner
-- zu nutzen. Alles nötige dazu ist, dieses Skript in die Map zu laden und
-- die Funktion SymfoniaLoader:Load auszuführen.
--
-- Über die Load Order können einzelne Bundles aktiviert und deaktiviert
-- werden. Die Reihenfolge in der Tabelle bestimmt zudem die Reihenfolge,
-- nach der die Skripte geladen wird. Es wird empfohlen diese Reihenfolge
-- beizubehalten, da es sonst möglicher Weise zu Problemen mit möglichen
-- Abhängigkeiten kommen könnte. Ebenso gibt es gegenseitige Ausschlüsse,
-- doch diese sind im Kommentar darüber vermerkt.
--
-- Trotz allem muss nach Abschluss der Entwicklung eine normale QSB in die
-- Map eingefügt werden. Du kannst sie dann entsprechend zusammen bauen.
--
-- @script SymfoniaLoader
-- @set sort=true
--

SymfoniaLoader = {
    Data = {
        LoadOrder  = {

            -- Enthält alle Behavior aus der QSB 3.9 ohne größere Änderungen.
            --
            -- Abhängigkeiten:
            --   keine
            --
            -- Inkompatibelitäten:
            --   keine

            {"BundleClassicBehaviors",              true},

            -- Enthält die neuen Behavior von Symfonia. Zwar ist dieses Bundle
            -- Unabhänig von den klassischen Behavior, doch ergibt es nicht
            -- viel sinn es alleine zu nutzen.
            --
            -- Abhängigkeiten:
            --   keine
            --
            -- Inkompatibelitäten:
            --   keine

            {"BundleSymfoniaBehaviors",             true},

            -- Mit diesem Modul können Aufträge per Skript erstellt werden.
            --
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine

            {"BundleQuestGeneration",               true},

            -- Erweitert den mitgelieferten Debug des Spiels um eine Vielzahl 
            -- nützlicher neuer Möglichkeiten.
            --
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine

            {"BundleQuestDebug",                    true},
            
            -- Ermöglicht es ansprechbare Nichtspielercharaktere zu erstellen. 
            -- Interaktion mit ihnen löst eine beliebige Funktion aus.
            -- 
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine
            
            {"BundleNonPlayerCharacter",            true},
            
            -- Ermöglicht es ansprechbare Nichtspielercharaktere zu erstellen. 
            -- Interaktion mit ihnen löst eine beliebige Funktion aus.
            -- 
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine
            
            {"BundleKnightTitleRequirements",       true},
            
            -- Dieses Bundle bietet dem Nutzer Funktionen zur Manipulation
            -- der Oberfläche des Spiels.
            -- 
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine
            
            {"BundleInterfaceApperance",            true},
            
            -- Ändert die Funktionen zur Erstellung von Angeboten und setzt
            -- neue Preise. Zudem können Angebote analysiert werden.
            -- 
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine
            
            {"BundleTradingFunctions",              true},
            
            -- Bietet die Möglichkeit einzelne MP3-Dateien oder Playlists aus
            -- MP3-Dateien abzuspielen.
            -- 
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine
            
            {"BundleMusicTools",                    true},
            
            -- Bietet direkten Zugriff auf die Daten eines Entities im RAM.
            -- 
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine
            
            {"BundleEntityScriptingValues",         true},
            
            -- Ermöglicht Bau- und Abrissverbote für Gebäude.
            -- 
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine
            
            {"BundleConstructionControl",           true},
            
            -- Steuert die Selektion von Einheiten
            -- 
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine
            
            {"BundleEntitySelection",               true},
            
            -- Spielstände in anderen Ordnern verwalten
            -- 
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine
            
            {"BundleSaveGameTools",                 true},
            
            -- Hilfsfunktionen zu Entities
            -- 
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine
            
            {"BundleEntityHelperFunctions",         true},
            
            -- Allgemeine Hilfsfunktionen
            -- 
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine
            
            {"BundleGameHelperFunctions",           true},
            
            -- Dialoge und Textfenster
            -- 
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine
            
            {"BundleDialogWindows",                 true},
            
            -- Ermöglicht Briefings und Cutscenes
            -- 
            -- Abhängigkeiten:
            --   keine
            -- 
            -- Inkompatibelitäten:
            --   keine
            
            {"BundleBriefingSystem",                true},
        }
    }
}

---
-- Lädt alle Bundles innerhalb der Load Order und initalisiert sie.
-- <br/><br/>
-- Die Liste der Bundles steuert welche Behavior geladen werden. Wird ein
-- Bundle auf false gesetzt, wird es nicht geladen. Die Reihenfolge der
-- Einträge bestimmt die Ladereihenfolge.
--
-- @param _Path Root-Verzeichnis
-- @within SymfoniaLoader
-- @usage SymfoniaLoader:Load()
--
function SymfoniaLoader:Load(_Path)
    Script.Load(_Path.. "/core.lua");
    for i= 1, #self.Data.LoadOrder, 1 do
        if self.Data.LoadOrder[i][2] then
            local Name = self.Data.LoadOrder[i][1]:lower();
            Script.Load(_Path.. "/bundles/" ..Name.. "/source.lua");
        end
    end
    assert(API ~= nil);
    API.Install();
end

---
-- Läd den Inhalt der Datei und gibt ihn als String zurück.
-- @param _Path Pfad zur Datei
-- @return Dateiinhalt als String
-- @local
--
function SymfoniaLoader:LoadSource(_Path)
    local fh = io.open(_Path, "rb");
    assert(fh, "File not found: " ..tostring(_Path));
    fh:seek("set", 0);
    local Contents = fh:read("*all");
    fh:close();
    return Contents;
end

---
-- Läd alle Inhalte der QSB und gibt sie als Table zurück. Jeder Index des
-- Tables enthält den Inhalt einer Quelldatei.
-- @return Table mit Inhalten
-- @local
--
function SymfoniaLoader:ConcatSources()
    local BasePath = "qsb/lua/";
    local QsbContent = {self:LoadSource(BasePath.. "core.lua")};
    for k, v in pairs(self.Data.LoadOrder) do
        local FileContent = "";
        if v[2] then
            FileContent = self:LoadSource(BasePath.. "bundles/" ..v[1]:lower().. "/source.lua");
        end
        table.insert(QsbContent, FileContent);
    end
    return QsbContent;
end

---
-- Fügt die Quelldateien von Symfonia zu einer QSB zusammen.
-- @local
--
function SymfoniaLoader:CreateQSB()
    local QsbContent = self:ConcatSources();
    local fh = io.open("Symfonia.lua", "a+");
    assert(fh, "Output file can not be created!");
    fh:seek("set", 0);
    fh:write(unpack(QsbContent));
    fh:close();
end