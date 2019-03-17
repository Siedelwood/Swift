-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Trage hier den Pfad ein, wo Deine Inhalte liegen.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";

-- Globaler Namespace für Deine Variablen
g_Mission = {};

-- -------------------------------------------------------------------------- --
-- Basisfunktionen                                                            --
-- -------------------------------------------------------------------------- --
--      Die folgenden Funktionen setzen die wichtigsten Einstellungen für Deine
--      Map. Hier kannst du Spielerfarben, Handelsangebote und KI-Einstellungen
--      setzen, Funktionen aufrufen und Deine Skripte laden.

-- Läd die Kartenskripte der Mission.
function Mission_LoadFiles()
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
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

    -- Startet die Mapeditor-Quests
    CreateQuests();

    -- Oder, alternativ, starte Quests, die im Skript erzeugt werden
    -- StartAllChapters();

    -- Hier kannst Du Deine Funktionen aufrufen:

end

-- -------------------------------------------------------------------------- --
-- Quests                                                                     --
-- -------------------------------------------------------------------------- --
--      Hier kannst Du Quests erzeugen
--      Reichen die vorgegebenen 3 Kapitel nicht aus, kannst Du weitere in
--      fortlaufender Nummerierung hinzufügen. Achte darauf zu jedem Aufruf
--      auch eine Funktion zu haben.

function StartAllChapters()
    CreateQuestsChapter1();
    CreateQuestsChapter2();
    CreateQuestsChapter3();
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
--      Hier kannst Du Briefings erzeugen
--      Das folgende Beispiel zeigt ein einfaches Briefing mit ein paar Seiten.
--      Dies ist ein Dialog, dessen Seiten bestätigt werden müssen, damit es
--      weiter geht. Der Spieler kann auch zurück springen, wenn er etwas noch
--      einmal lesen will.

function ExampleBriefing1()
    local Briefing = {
        HideBorderPins = true,
        ShowSky = true,
        RestoreGameSpeed = true,
        RestoreCamera = true,
        SkippingAllowed = true,
        ReturnForbidden = false,
    }
    local AP = API.AddPages(Briefing);

    ASP("hans", "Hans", "Hallo Anton! Wie geht es dir?", true);
    ASP("anton", "Anton", "Mir geht es schlecht. Ich brauche Medizin!", true);
    ASP("hans", "Hans", "Wirklich? Dann werden wir dir welche besorgen!", true);

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    return API.StartBriefing(Briefing);
end