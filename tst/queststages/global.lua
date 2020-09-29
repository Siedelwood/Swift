-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_LoadFiles
-- --------------------------------
-- Läd zusätzliche Dateien aus der Map. Die Dateien
-- werden in der angegebenen Reihenfolge geladen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_LoadFiles()
    return {
        gvMission.ContentPath.. "knighttitlerequirements.lua",
    };
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_InitPlayers
-- --------------------------------
-- Diese Funktion kann benutzt werden um für die AI
-- Vereinbarungen zu treffen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_InitPlayers()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_SetStartingMonth
-- --------------------------------
-- Diese Funktion setzt einzig den Startmonat.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_InitMerchants
-- --------------------------------
-- Hier kannst du Hдndler und Handelsposten vereinbaren.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_InitMerchants()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_FirstMapAction
-- --------------------------------
-- Die FirstMapAction wird am Spielstart aufgerufen.
-- Starte von hier aus deine Funktionen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_FirstMapAction()
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/questsystembehavior.lua");

    -- Mapeditor-Einstellungen werden geladen
    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end

    API.ActivateDebugMode(true, true, true, true);

    CreateTestQuests();
end

function CreateTestQuests()
    API.CreateMainQuest {
        Name        = "TestQuestLine1",
        Stages      = {
            {
                Suggestion = "Holz produzieren",
                Success    = "geschafft!",
                Goal_Produce("G_Wood", 50),
            },
            {
                Suggestion = "Stein produzieren",
                Success    = "geschafft!",
                Goal_Produce("G_Stone", 30),
            },
            {
                Suggestion = "Baron werden",
                Success    = "geschafft!",
                Goal_KnightTitle("Baron"),
            },
            {
                Suggestion = "Bäckerei bauen",
                Success    = "geschafft!",
                Goal_Create("B_Bakery", 1, 1),
            },
        }
    }
end