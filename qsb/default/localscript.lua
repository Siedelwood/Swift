-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Local Script -                                                         # --
-- # ©                                                                      # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- # Setup ################################################################## --

---
-- Diese Funktion wird aufgerufen, wenn die Mission
-- gewonnen ist.
--
function Mission_LocalVictory()
end

---
-- Wird zum Spielstart einmalig aufgerufen.
--
function Mission_LocalOnMapStart()
    -- Laden der Bibliothek
    local MapType, Campaign = Framework.GetCurrentMapTypeAndCampaignName();
    local MapFolder = (MapType == 1 and "Development") or "ExternalMap";
    local MapName = Framework.GetCurrentMapName();
    Script.Load("Maps/"..MapFolder.."/"..MapName.."/QuestSystemBehavior.lua");

    -- Läd die Module
    API.Install();
    InitKnightTitleTables();
    
end

-- # Main Map Script######################################################### --

