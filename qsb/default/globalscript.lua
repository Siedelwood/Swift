-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Trage hier den Pfad ein, wo Deine Inhalte liegen.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";

-- Lade Inhalte aus dem Testpfad. Auf true setzen zum aktivieren.
if false then
    -- Trage hier den Pfad zu Deinem Mapverzeichnis ein. Achte darauf / statt \
    -- zu verwenden. Der Pfad muss mit einem / enden.
    g_ContentPath = "C:/Maps/MapName/";
end

-- Globaler Namespace für Deine Variablen
gvMission = {};

-- -------------------------------------------------------------------------- --
-- Basisfunktionen                                                            --
-- -------------------------------------------------------------------------- --
--      Die folgenden Funktionen setzen die wichtigsten Einstellungen für Deine
--      Map. Hier kannst du Spielerfarben, Handelsangebote und KI-Einstellungen
--      setzen, Funktionen aufrufen und Deine Skripte laden.

-- Läd die Kartenskripte der Mission.
function Mission_LoadFiles()
    -- Die Quest-Bibliothek wird geladen
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
    -- Optional: Füge der Map ein Skript mit namen knighttitlerequirements.lua
    -- hinzu, wenn die Aufstiegsbedingungen geändert werden sollen. 
    Script.Load(g_ContentPath.. "knighttitlerequirements.lua");

    -- Füge hier weitere Skriptdateien hinzu.
end

-- Setzt Voreinstellungen für KI-Spieler.
-- (Spielerfarbe, AI-Blacklist, etc)
function Mission_InitPlayers()
end

-- Setzt den Monat, mit dem das Spiel beginnt.
function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

-- Setzt Handelsangebote der Nichtspielerparteien.
function Mission_InitMerchants()
end

-- Wird aufgerufen, wenn das Spiel gestartet wird.
function Mission_FirstMapAction()
    Mission_LoadFiles();
    API.Install();
    InitKnightTitleTables();

    -- Mapeditor-Einstellungen werden geladen
    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end

    -- Startet Quests, die im Skript erzeugt werden
    StartAllChapters();

    -- Oder, alternativ, startet die Mapeditor-Quests
    -- CreateQuests();

    -- Hier kannst Du Deine Funktionen aufrufen:

end

-- -------------------------------------------------------------------------- --
-- Quests                                                                     --
-- -------------------------------------------------------------------------- --
--      Hier kannst Du Quests erzeugen
--      Reichen die vorgegebenen 3 Kapitel nicht aus, kannst Du weitere in
--      fortlaufender Nummerierung hinzufügen. Achte darauf zu jedem Aufruf
--      auch eine Funktion zu haben.
--
--      Hinweis: Du kannst die Kapitel auch in eigenen Skripten erstellen und
--      dann über Mission_LoadFiles laden lassen.

function StartAllChapters()
    CreateQuestsChapter1();
    CreateQuestsChapter2();
    CreateQuestsChapter3();

    -- Füge hier weitere Kapitel hinzu.
end

-- Kapitel 1 -------------------------------------------------------------------

function CreateQuestsChapter1()
end

-- Kapitel 2 -------------------------------------------------------------------

function CreateQuestsChapter2()
end

-- Kapitel 3 -------------------------------------------------------------------

function CreateQuestsChapter3()
end

-- -------------------------------------------------------------------------- --
-- Briefings                                                                  --
-- -------------------------------------------------------------------------- --
--      Dies ist ein Beispiel für ein Dialog-Briefing
--      Das folgende Beispiel zeigt ein einfaches Briefing mit ein paar Seiten.
--      Dies ist ein Dialog, dessen Seiten bestätigt werden müssen, damit es
--      weiter geht. Der Spieler kann auch zurück springen, wenn er etwas noch
--      einmal lesen will.
--
--      Hinweis: Du kannst die Briefings auch in eigenen Skripten erstellen und
--      dann über Mission_LoadFiles laden lassen.

function ExampleBriefing1()
    -- Definition der globalen Einstellungen.
    local Briefing = {
        HideBorderPins = true,
        ShowSky = true,
        RestoreGameSpeed = true,
        RestoreCamera = true,
        SkippingAllowed = true,
        ReturnForbidden = false,
    }
    local AP = API.AddPages(Briefing);

    -- Erzeugung der Pages
    ASP("hans", "Hans", "Hallo Anton! Wie geht es dir?", true);
    ASP("anton", "Anton", "Mir geht es schlecht. Ich brauche Medizin!", true);
    ASP("hans", "Hans", "Wirklich? Dann werden wir dir welche besorgen!", true);

    -- Funktion, die vor dem Start aufgerufen wird
    Briefing.Starting = function(_Data)
    end
    -- Funktion, die beim Abschluss aufgerufen wird
    Briefing.Finished = function(_Data)
    end
    -- Startet das Briefing und gibt die Briefing ID zurück.
    return API.StartBriefing(Briefing);
end