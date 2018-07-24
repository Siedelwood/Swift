--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_LocalVictory
----------------------------------
-- Diese Funktion wird aufgerufen, wenn die Mission
-- gewonnen ist.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_LocalVictory()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_LocalOnMapStart
----------------------------------
-- Wird zum Spielstart einmalig aufgerufen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_LocalOnMapStart()
    -- Laden der Bibliothek
    local MapType, Campaign = Framework.GetCurrentMapTypeAndCampaignName();
    local MapFolder = (MapType == 1 and "Development") or "ExternalMap";
    local MapName = Framework.GetCurrentMapName();
    Script.Load("Maps/"..MapFolder.."/"..MapName.."/QuestSystemBehavior.lua");
    Script.Load("E:/Repositories/symfonia/qsb/lua/external/externalroleplayinggame.lua");

    -- Läd die Module
    API.Install();
    InitKnightTitleTables();
end


