-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Local Script - <MAPNAME>                                               # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

function Mission_LocalVictory()
end

function Mission_LoadFiles()
    return {};
end

function Mission_LocalOnQsbLoaded()
end

function BenchmarkTestSearch()
    local Before = XGUIEng.GetSystemTime();
    local Found = API.SearchEntitiesOfType(Entities.D_ME_Rock01);
    local After = XGUIEng.GetSystemTime();
    return After - Before, #Found;
end