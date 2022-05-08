-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Local Script - <MAPNAME>                                               # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_LoadFiles
-- --------------------------------
-- Läd zusätzliche Dateien aus der Map.Die Dateien
-- werden in der angegebenen Reihenfolge geladen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_LoadFiles()
    return {};
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_LocalVictory
-- --------------------------------
-- Diese Funktion wird aufgerufen, wenn die Mission
-- gewonnen ist.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_LocalVictory()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_FirstMapAction
-- --------------------------------
-- Die FirstMapAction wird am Spielstart aufgerufen.
-- Starte von hier aus deine Funktionen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_LocalOnMapStart()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_LocalOnQsbLoaded
-- --------------------------------
-- Die QSB ist im lokalen Skript initialisiert.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_LocalOnQsbLoaded()
    PredicateBenchmark = {};
    VanillaBenchmark = {};
end

function CallTestFunction()
    API.SendScriptCommand(QSB.ScriptCommands.TestFunction, 123, "abc");
end

function CallTestFunction2()
    API.SendScriptCommand(QSB.ScriptCommands.TestFunction, 456, "def");
end

function SearchWithPredicateBenchmarkTest()
    local Before = XGUIEng.GetSystemTime();
    local Result = API.CommenceEntitySearch(
        {QSB.Search.OfPlayer, 1},
        {QSB.Search.OfCategory, EntityCategories.CityBuilding, EntityCategories.OuterRimBuilding},
        {QSB.Search.InTerritory, 1, 2, 3}
    )
    local Benchmark = (XGUIEng.GetSystemTime() - Before) * 1000;
    table.insert(PredicateBenchmark, Benchmark);
    local BenchmarkDelta = 0;
    for i= 1, #PredicateBenchmark do
        BenchmarkDelta = BenchmarkDelta + PredicateBenchmark[i];
    end
    LuaDebugger.Log(BenchmarkDelta/#PredicateBenchmark);
    return Result;
end

function SearchWithoutPredicateBenchmarkTest()
    local Result;
    local Benchmark = XGUIEng.GetSystemTime();
    local Result1 = API.GetEntitiesOfCategoriesInTerritories(1, {EntityCategories.OuterRimBuilding, EntityCategories.CityBuilding}, 1);
    local Result2 = API.GetEntitiesOfCategoriesInTerritories(1, {EntityCategories.OuterRimBuilding, EntityCategories.CityBuilding}, 2);
    local Result3 = API.GetEntitiesOfCategoriesInTerritories(1, {EntityCategories.OuterRimBuilding, EntityCategories.CityBuilding}, 3);
    Result = Array_Append(Result1, Result2);
    Result = Array_Append(Result, Result3);
    local Benchmark = (XGUIEng.GetSystemTime() - Benchmark) * 1000;
    table.insert(VanillaBenchmark, Benchmark);
    local BenchmarkDelta = 0;
    for i= 1, #VanillaBenchmark do
        BenchmarkDelta = BenchmarkDelta + VanillaBenchmark[i];
    end
    LuaDebugger.Log(BenchmarkDelta/#VanillaBenchmark);
    return Result;
end

