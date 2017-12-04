-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Synfonia Loader                                                       # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es den Quellcode von Synfonia zu nutzen, ohne vorher eine QSB
-- generieren zu lassen.
--
-- Vorallem während des Entwicklungsprozesses ist es störend, wenn man sich
-- immer wieder eine neue QSB bauen muss. Der Loader ermöglicht es, die QSB,
-- bzw. ihre Quelldateien, während der Entwicklung direkt aus dem Projektordner
-- zu nutzen. Alles nötige dazu ist, dieses Skript in die Map zu laden und
-- die Funktion SynfoniaLoader:Load auszuführen.
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
-- @script SynfoniaLoader
-- @set sort=true
--

SynfoniaLoader = {
    Data = {
        -- Liste der zu ladenden Bundles.
        LoadOrder  = {

            -- Enthält alle Behavior aus der QSB 3.9 ohne größere Änderungen.
            --
            -- Abhänigkeiiten:
            --   keine
            --
            -- Inkompatibelitäten:
            --   keine

            {"BundleClassicBehaviors",              true},

            -- Enthält die neuen Behavior von Synfonia. Zwar ist dieses Bundle
            -- Unabhänig von den klassischen Behavior, doch ergibt es nicht
            -- viel sinn es alleine zu nutzen.
            --
            -- Abhänigkeiiten:
            --   keine
            --
            -- Inkompatibelitäten:
            --   keine

            {"BundleSynfoniaBehaviors",             true},

            --

            {"BundleQuestGeneration",               true},

            --

            {"BundleQuestDebug",                    true},
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
-- @within SynfoniaLoader
--
-- @usage SynfoniaLoader:Load()
--
function SynfoniaLoader:Load(_Path)
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
