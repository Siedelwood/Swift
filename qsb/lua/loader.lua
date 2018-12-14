-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia Loader                                                       # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es den Quellcode von Symfonia zu nutzen, ohne vorher eine QSB
-- generieren zu lassen.
--
-- <b>Hinweis</b>: Nur für Entwickler!
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
-- unentdeckten Abhängigkeiten kommen könnte, auch wenn Bundles als eigene
-- Welten existieren.
--
-- Neben den Bundles gibt es auch AddOns. AddOns sind spezielle Bundles, die
-- von einem oder mehr Bundles bzw. anderen AddOns abhängig sind. Ist eine
-- Abhängigkeit unbefriedigt, wird das AddOn nicht geladen! AddOns, die von
-- anderen AddOns abhängig sind, müssen in der Load Order hinter AddOns stehen
-- die sie benötigen. Desshalb darf hier die Load Order nicht geändert werden!
--
-- Trotz allem muss nach Abschluss der Entwicklung eine normale QSB in die
-- Map eingefügt werden. Du kannst sie dann entsprechend zusammen bauen.
--
-- <h3>Neues Release erzeugen</h3>
-- Die Erzeugung eines Releases geschieht vollautomatisch!
--
-- <h4>Benutzerdokumentation aktualisieren</h4>
-- Bevor eine neue Version ausgeliefert wird, muss die Benutzerdokumentation
-- auf den neusten Stand gebracht werden. dies geschieht wieder mit make.sh
-- und dem Parameter -d.
-- <pre>cd bin
-- ./make.sh -d</pre>
-- Das wird jedoch vom entsprechenden Skript bereits ausgeführt.
--
-- <h4>Release-Archiv generieren</h4>
-- Das Release-Archiv wird von ./publish.sh erzeugt.
-- <pre>cd bin
-- ./publish.sh</pre>
-- Das Skript erstellt ein Archiv mit dem Namen Release im Root-Ordner des
-- Projektes. Das Archiv enthält die Benutzerdokumentation, die Anleitungen,
-- das globale und lokale Skript sowie die QSB in komprimierter und in
-- unkomprimierter form.
--
-- <h3>Personalisierte QSB</h3>
-- Die QSB kann nach belieben an Deine Wünsche angepasst werden.
-- Die QSB wird mit dem Skript make.sh gebaut.
--
-- <h4>Benutzerdefinierte Load Order</h4>
-- Eine eigene Load Order wird erstellt, indem ein Lua-Skript angelegt wird,
-- in dem es eine globale Variable LoadOrder gibt. Diese Variable beinhaltet
-- 2 Tables. Der erste ist die Load Order der Bundles, die zweite die der
-- AddOns. Die Load Order wird mit -l übergeben.
-- 
-- Beispiel für eine Load Order mit der nur Grundmodule geladen werden:
-- <pre>
-- LoadOrder = {
--     {
--         {"BundleBriefingSystem",                true},
--         {"BundleClassicBehaviors",              true},
--         {"BundleQuestGeneration",               true},
--         {"BundleConstructionControl",           true},
--     },
--     {
--         {
--         "AddOnQuestDebug",                      true,
--         "BundleQuestGeneration",
--         },
--     },
-- }
-- </pre>
--
-- Aufruf des Skriptes:
-- <pre>cd bin
-- ./make.sh -l"path/to/loadorder.lua"</pre>
--
-- <h4>Eigene Bundles</h4>
-- Als letztes gibt es noch die Möglichkeit, eigene Bundles zu schreiben und
-- in einer exklusiven persönlichen QSB zu nutzen. Dazu wird wieder die make.sh
-- im bin-Verzeichnis genutzt.
-- <pre>cd bin
--./make.sh Path/to/Bundle Path/to/another/Bundle</pre>
-- Dabei wird die Dateiendung *.lua nicht mit angegeben!
--
-- @set sort=true
--

QSB = QSB or {};

SymfoniaLoader = {
    Data = {
        LoadOrder = {
            -- Basisbibliothek
            -- Ausschließlich Features, die essentiell sind.
            {"BundleBriefingSystem",                true},
            {"BundleClassicBehaviors",              true},
            {"BundleQuestGeneration",               true},

            -- Erweiterte Bibliothek
            -- Zusätzliche Funktionalität und weitere Behavior.
            {"BundleConstructionControl",           true},
            {"BundleDestructionControl",            true},
            {"BundleDialogWindows",                 true},
            {"BundleEntityCommandFunctions",        true},
            {"BundleEntityHealth",                  true},
            {"BundleEntityHelperFunctions",         true},
            {"BundleKnightTitleRequirements",       true},
            {"BundleMinimapMarker",                 true},
            {"BundleSymfoniaBehaviors",             true},
            {"BundleTimeLine",                      true},
            {"BundleTravelingSalesman",             true},

            -- Fortgeschrittene Bibliothek
            -- Neue Funktionen für fortgeschrittene Anwender.
            {"BundleBuildingButtons",               true},
            {"BundleEntityScriptingValues",         true},
            {"BundleEntitySelection",               true},
            {"BundleGameHelperFunctions",           true},
            {"BundleInteractiveObjects",            true},
            {"BundleInterfaceApperance",            true},
            {"BundlePlayerHelperFunctions",         true},
            {"BundleMusicTools",                    true},
            {"BundleNonPlayerCharacter",            true},
            {"BundleTradingAnalysis",               true},
        },

        AddOnLoadOrder = {
            -- Basisbibliothek
            -- Ausschließlich Features, die essentiell sind.
            {
            "AddOnQuestDebug",                      true,
            "BundleQuestGeneration",
            },

            -- Sonstige AddOns
            -- "Nice To have"-Features, die nicht so wichtig sind.
            {
            "AddOnCastleStore",                     true,
            "BundleInteractiveObjects",
            },

            {
            "AddOnGameCutscenes",                   true,
            "BundleBriefingSystem",
            },

            {
            "AddOnInteractiveObjectTemplates",      true,
            "BundleInteractiveObjects",
            "BundleEntitySelection",
            },
        },
    }
}

---
-- Lädt alle Bundles innerhalb der Load Order und initalisiert sie. Diese
-- Funktion ist für die Verwendung im Spiel gedacht.
-- <br/><br/>
-- Die Liste der Bundles steuert welche Behavior geladen werden. Wird ein
-- Bundle auf false gesetzt, wird es nicht geladen. Die Reihenfolge der
-- Einträge bestimmt die Ladereihenfolge.
--
-- _Path ist der absolute Pfad, wo die QSB auf dem Rechner liegt oder der
-- relative Pfad in der Map, in den die Quellen gepackt wurden.
--
-- @param _Path Root-Verzeichnis
-- @within SymfoniaLoader
-- @usage SymfoniaLoader:Load("C:/My/Path/To/Symfonia")
--
function SymfoniaLoader:Load(_Path)
    Script.Load(_Path.. "/core.lua");

    -- Lade alle Bundles
    for i= 1, #self.Data.LoadOrder, 1 do
        if self.Data.LoadOrder[i][2] then
            local Name = self.Data.LoadOrder[i][1]:lower();
            Script.Load(_Path.. "/bundles/" ..Name.. ".lua");
            API.Log("Load bundle '" .. _Path.. "/bundles/" ..Name.. ".lua'");
        end
    end

    assert(API ~= nil);

    -- Lade alle AddOns
    for i= 1, #self.Data.AddOnLoadOrder, 1 do
        if self.Data.AddOnLoadOrder[i][2] then
            -- Prüfe Abhängigkeiten
            local LoadAddon = true;
            for j= 3, #self.Data.AddOnLoadOrder[i], 1 do
                LoadAddon = LoadAddon and API.TraverseTable(self.Data.AddOnLoadOrder[i][j], Core.Data.BundleInitializerList);
            end
            -- Lade Addon
            local Name = self.Data.AddOnLoadOrder[i][1]:lower();
            if LoadAddon then
                Script.Load(_Path.. "/addons/" ..Name.. ".lua");
                API.Log("Load addon '" .. _Path.. "/addons/" ..Name.. ".lua'");
            else
                -- Only show once
                if not GUI then
                    API.Dbg("SymfoniaLoader:Load: AddOn '" ..Name.. "' has unsatisfied dependencies and was not loaded!");
                end
            end
        end
    end

    assert(API ~= nil);
    API.Install();
end

---
-- Läd den Inhalt der Datei und gibt ihn als String zurück.
-- @param _Path Pfad zur Datei
-- @return Dateiinhalt als String
-- @within SymfoniaLoader
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
-- @within SymfoniaLoader
-- @local
--
function SymfoniaLoader:ConcatSources(_External)
    local BasePath = "qsb/lua/";
    local QsbContent = {self:LoadSource(BasePath.. "core.lua")};

    local fh = io.open("qsb/userconfig.ld", "wt");
    assert(fh, "Output file can not be created!");
    fh:write("project='Symfonia'\n");
    fh:write("kind_names={script='Skripte', module='Bibliotheken'}\n");

    local ActiveBundles = "file={\n'core.lua',\n";

    for k, v in pairs(self.Data.LoadOrder) do
        local FileContent = "";
        if v[2] then
            ActiveBundles = ActiveBundles.. "'bundles/" ..v[1]:lower().. ".lua',\n";
            FileContent = self:LoadSource(BasePath.. "bundles/" ..v[1]:lower().. ".lua");
        end
        table.insert(QsbContent, FileContent);
    end

    for k, v in pairs(self.Data.AddOnLoadOrder) do
        local FileContent = "";
        if v[2] then
            local LoadAddOn = true;
            for i= 3, #v, 1 do
                if SymfoniaLoader:IsDependencyLoaded(v[i], i) == false then
                    LoadAddOn = false;
                end
            end
            if LoadAddOn == true then
                ActiveBundles = ActiveBundles.. "'addons/" ..v[1]:lower().. ".lua',\n";
                FileContent = self:LoadSource(BasePath.. "addons/" ..v[1]:lower().. ".lua");
                table.insert(QsbContent, FileContent);
            end
        end
    end

    for i= 1, #_External, 1 do
        local FileContent = "";
            ActiveBundles = ActiveBundles.. "'" .._External[i]:lower().. ".lua',\n";
            FileContent = self:LoadSource(_External[i]:lower().. ".lua");
        table.insert(QsbContent, FileContent);
    end

    ActiveBundles = ActiveBundles.. "}";
    fh:write(ActiveBundles.. "\n");
    fh:close();

    return QsbContent;
end

---
-- Checks, if the dependency is loaded.
-- @param _Name Name of dependency
-- @param _i    Current addon index
-- @return boolean: Will be loaded
-- @within SymfoniaLoader
-- @local
--
function SymfoniaLoader:IsDependencyLoaded(_Name, _i)
    for j= 1, #self.Data.LoadOrder, 1 do
        if self.Data.LoadOrder[j][1] == _Name and self.Data.LoadOrder[j][2] then
            return true;
        end
    end
    for j= 1, _i, 1 do
        if self.Data.AddOnLoadOrder[j] and self.Data.AddOnLoadOrder[j][1] == _Name and self.Data.AddOnLoadOrder[j][2] then
            return true;
        end
    end
    return false;
end

---
-- Fügt die Quelldateien von Symfonia zu einer QSB zusammen.
-- @param _Externals [table] Liste der externen Bundles
-- @within SymfoniaLoader
-- @local
--
function SymfoniaLoader:CreateQSB(_Externals)
    local QsbContent = self:ConcatSources(_Externals);
    -- Delete old file
    local fh = io.open("var/qsb.lua", "r");
    if fh ~= nil then
        os.remove("var/qsb.lua");
        fh:close();
    end
    -- Write new file
    local fh = io.open("var/qsb.lua", "wt");
    assert(fh, "Output file can not be created!");
    fh:write(unpack(QsbContent));
    fh:close();
end
