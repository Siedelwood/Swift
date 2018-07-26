-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script -                                                        # --
-- # ©                                                                      # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- # Setup ################################################################## --

---
-- Diese Funktion kann benutzt werden um für die AI
-- Vereinbarungen zu treffen.
--
function Mission_InitPlayers()
end

---
-- Diese Funktion setzt einzig den Startmonat.
--
function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

---
-- In dieser Funktion werden Händler eingestellt.
--
function Mission_InitMerchants()
end

---
-- In dieser Funktion vereinbarst du Technologien.
--
function Mission_InitTechnologies()
end

---
-- In dieser Funktion werden Spielerfarben der KI-Parteien vereinbart
--
function Mission_InitPlayerColors()
end

---
-- Die FirstMapAction wird am Spielstart aufgerufen.
-- Starte von hier aus deine Funktionen.
--
function Mission_FirstMapAction()
    -- Laden der Bibliothek
    local MapType, Campaign = Framework.GetCurrentMapTypeAndCampaignName();
    local MapFolder = (MapType == 1 and "Development") or "ExternalMap";
    local MapName = Framework.GetCurrentMapName();
    Script.Load("Maps/"..MapFolder.."/"..MapName.."/QuestSystemBehavior.lua");

    -- Läd die Module
    API.Install();
    InitKnightTitleTables();

    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end
    Mission_InitTechnologies();
    Mission_InitPlayerColors();

    -- Mapeditor-Quests erstellen.
    CreateQuests();
    
    
end

-- # Main Map Script ######################################################## --

