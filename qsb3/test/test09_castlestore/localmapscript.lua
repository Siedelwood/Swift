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

    MyTest = {
        Foo = {
            Bar = function()

            end
        }
    }
end

function ConstructBuildingRescritction(_PlayerID, _Type, _X, _Y)
    return true;
end

function ConstructRoadRescritction(_PlayerID, _IsTrail, _X, _Y)
    return true;
end

function KnockdownBuildingRestriction(_PlayerID, _BuildingID, _X, _Y)
    return true;
end

function BuildingButtonTypeTest()
    for i= 1, 6 do
        --API.AddBuildingButton(
        API.AddBuildingButtonByType(
            Entities.B_Butcher,
            -- Aktion
            function(_WidgetID, _BuildingID)
                GUI.AddNote("Button " .. i .. " geklickt.");
            end,
            -- Tooltip
            function(_WidgetID, _BuildingID)
                API.SetTooltipCosts("Button " .. i, "Das ist die Beschreibung!");
            end,
            -- Update
            function(_WidgetID, _BuildingID)
                if Logic.IsConstructionComplete(_BuildingID) == 0 then
                    XGUIEng.ShowWidget(_WidgetID, 0);
                    return;
                end
                if Logic.IsBuildingBeingUpgraded(_BuildingID) then
                    XGUIEng.DisableButton(_WidgetID, 1);
                end
                SetIcon(_WidgetID, {i, i});
            end
        );
    end

    -- SpecialButtonID2 = API.AddBuildingButtonByTypeAtPosition(
    --     Entities.B_HuntersHut,
    --     123,123,
    --     -- Aktion
    --     function(_WidgetID, _BuildingID)
    --         GUI.AddNote("Hier passiert etwas!");
    --     end,
    --     -- Tooltip
    --     function(_WidgetID, _BuildingID)
    --         API.SetTooltipCosts("Beschreibung", "Das ist die Beschreibung!");
    --     end,
    --     -- Update
    --     function(_WidgetID, _BuildingID)
    --         SetIcon(_WidgetID, {10, 2});
    --     end
    -- );

    -- SpecialButtonID2 = API.AddBuildingButtonByType(
    --     Entities.B_Butcher,
    --     -- Aktion
    --     function(_WidgetID, _BuildingID)
    --         GUI.AddNote("Hier passiert etwas!");
    --     end,
    --     -- Tooltip
    --     function(_WidgetID, _BuildingID)
    --         API.SetTooltipCosts("Beschreibung", "Das ist die Beschreibung!");
    --     end,
    --     -- Update
    --     function(_WidgetID, _BuildingID)
    --         SetIcon(_WidgetID, {1, 3});
    --     end
    -- );
end

function ShowTestWindow()
    ModuleInputOutputCore.Local:ShowTextWindow {
        PlayerID = 1,
        Caption  = "Wounderful",
        Content  = "It just work's!",
        Pause    = true,
        Button   = {
            Text   = "Foo",
            Action = function()
                API.Note("It realy does!");
            end
        }
    };
end

function SearchWithPredicateTest()
    API.BeginBenchmark("SearchPredicate");
    local Result = API.CommenceEntitySearch(
        {QSB.Search.OfPlayer, 1},
        {QSB.Search.InTerritory, 1},
        {ANY,
         {QSB.Search.OfCategory, EntityCategories.CityBuilding},
         {QSB.Search.OfCategory, EntityCategories.OuterRimBuilding}}
    )
    API.StopBenchmark("SearchPredicate");
    return Result;
end

function SearchVanillaTest()
    API.BeginBenchmark("SearchTraditional");
    local Result = {};
    local City = {Logic.GetPlayerEntitiesInCategory(1, EntityCategories.CityBuilding)};
    for i= 1, #City do
        if GetTerritoryUnderEntity(City[i]) == 1 then
            table.insert(Result, City[i]);
        end
    end
    local Outer = {Logic.GetPlayerEntitiesInCategory(1, EntityCategories.OuterRimBuilding)};
    for i= 1, #Outer do
        if GetTerritoryUnderEntity(Outer[i]) == 1 then
            table.insert(Result, Outer[i]);
        end
    end
    API.StopBenchmark("SearchTraditional");
    return Result;
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

