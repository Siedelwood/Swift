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
    return {};
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_InitPlayers
-- --------------------------------
-- Diese Funktion kann benutzt werden um für die AI
-- Vereinbarungen zu treffen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_InitPlayers()
    -- Beispiel: KI-Skripte für Spieler 2 deaktivieren (nicht im Editor möglich)
    --
    -- DoNotStartAIForPlayer(2);
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
    -- Beispiel: Setzt Handelsangebote für Spieler 3
    --
    -- local SHID = Logic.GetStoreHouse(3);
    -- AddMercenaryOffer(SHID, 2, Entities.U_MilitaryBandit_Melee_NA);
    -- AddMercenaryOffer(SHID, 2, Entities.U_MilitaryBandit_Ranged_NA);
    -- AddOffer(SHID, 1, Goods.G_Beer);
    -- AddOffer(SHID, 1, Goods.G_Cow);

    -- Beispiel: Setzt Tauschangebote für den Handelsposten von Spieler 3
    --
    -- local TPID = GetID("Tradepost_Player3");
    -- Logic.TradePost_SetTradePartnerGenerateGoodsFlag(TPID, true);
    -- Logic.TradePost_SetTradePartnerPlayerID(TPID, 3);
    -- Logic.TradePost_SetTradeDefinition(TPID, 0, Goods.G_Carcass, 18, Goods.G_Milk, 18);
	-- Logic.TradePost_SetTradeDefinition(TPID, 1, Goods.G_Grain, 18, Goods.G_Honeycomb, 18);
    -- Logic.TradePost_SetTradeDefinition(TPID, 2, Goods.G_RawFish, 24, Goods.G_Salt, 12);
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

    API.ActivateDebugMode(true, false, true, true);
    API.CastleStoreCreate(1);

    SetDiplomacyState(1, 2, 2);
    local SHID = Logic.GetStoreHouse(2);
    AddOffer(SHID, 3, Goods.G_Sheep);
    AddOffer(SHID, 3, Goods.G_Cow);

    -- StartSimpleJobEx(function()
    --     if Logic.GetTime() > 5 then
    --         API.CreateQuest {
    --             Name = "Test1",
    --             Sender = 2,
    --             Receiver = 1,
    --             Suggestion = "Deliver this shit!",
                
    --             Goal_Deliver("G_Wood", 200),
    --             Trigger_Time(6)
    --         }
    --         return true;
    --     end
    -- end);

    -- API.CreateQuest {
    --     Name = "Test2",
    --     Sender = 2,
    --     Receiver = 1,
    --     Suggestion = "Destroy enemies!",

    --     Goal_DestroySoldiers(1, 3, 6),
    --     Trigger_Time(6)
    -- }

    API.SetPlayerName(3, "Hans Wurst");

    TEST_COMMAND = API.RegisterScriptCommand("TestFunction", TestFunction);
end

function SetupPalisadeRestriction()
    -- Palisades can only be constructed near outposts
    API.AddConstructionRestriction(function(_PlayerID, _Type, _x, _y)
        if Logic.IsEntityTypeInCategory(_Type, EntityCategories.PalisadeSegment) == 1 then
            local n, OPID = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.B_Outpost_ME, _x, _y, 1500, 1);
            if n == 0 then
                return false;
            end
        end
        return true;
    end)
end

function TestMoveAmma()
    -- API.MoveEntity("amma", "pos")
    -- API.MoveEntityAndLookAt("amma", "pos", "manuel");
    -- local Position = GetPosition("constructionSite");
    -- API.MoveEntityToPosition("amma", Position, 500, 180);
    -- Logic.CreateEntity(Entities.XD_CoordinateEntity, Position.X, Position.Y, 0, 0);
    -- API.MoveEntityOnCheckpoints("amma", {"pos", "constructionSite", "manuel"});
    -- API.MoveEntityAndExecute("amma", "pos", function()
    --     API.Note("Bockwurst");
    -- end);
    -- API.PlaceEntityAndLookAt("amma", "pos", "manuel")
    -- local Position = GetPosition("constructionSite");
    -- Logic.CreateEntity(Entities.XD_CoordinateEntity, Position.X, Position.Y, 0, 0);
    -- API.PlaceEntityToPosition("amma", Position, 500, 180)
end

function TestFunction(_PlayerID, _Number, _String)
    local Text = "TestFunction :: PlayerID: " .._PlayerID.. " Param1: " .._Number.. " Param2: " .._String;
    API.Note(Text);
end

function CallTestFunction()
    Logic.ExecuteInLuaLocalState("CallTestFunction()");
end

function CallTestFunction2()
    Logic.ExecuteInLuaLocalState("CallTestFunction2()");
end

GameCallback_QSB_OnEventReceived = function(_EventID, ...)
    if _EventID == QSB.ScriptEvents.EntityHurt then
    --     local TypeID1 = Logic.GetEntityType(arg[1]);
    --     local TypeName1 = Logic.GetEntityTypeName(TypeID1);
    --     local TypeID2 = Logic.GetEntityType(arg[3]);
    --     local TypeName2 = Logic.GetEntityTypeName(TypeID2);
    --     API.Note(TypeName2 .. " (Player " ..arg[4].. ") attacked " ..TypeName1.. " (Player " ..arg[2].. ")");
    elseif _EventID == QSB.ScriptEvents.BuildingUpgraded then
        local TypeID1 = Logic.GetEntityType(arg[1]);
        local TypeName1 = Logic.GetEntityTypeName(TypeID1);
        API.Note(TypeName1 .. " upgrade finished (Player " ..arg[2].. ", Level " ..arg[3].. ")");
    elseif _EventID == QSB.ScriptEvents.UpgradeStarted then
        local TypeID1 = Logic.GetEntityType(arg[1]);
        local TypeName1 = Logic.GetEntityTypeName(TypeID1);
        API.Note(TypeName1 .. " upgrade start (Player " ..arg[2].. ")");
    elseif _EventID == QSB.ScriptEvents.UpgradeCanceled then
        -- local TypeID1 = Logic.GetEntityType(arg[1]);
        -- local TypeName1 = Logic.GetEntityTypeName(TypeID1);
        -- API.Note(TypeName1 .. " upgrade canceled (Player " ..arg[2].. ")");
    -- elseif _EventID == QSB.ScriptEvents.EntityDestroyed then
    --     local TypeID1 = Logic.GetEntityType(arg[1]);
    --     local TypeName1 = Logic.GetEntityTypeName(TypeID1);
    --     API.Note(TypeName1 .. " destroyed (Player " ..arg[2].. ")");
    -- elseif _EventID == QSB.ScriptEvents.BuildingPlaced then
    --     if IsExisting(arg[1]) then
    --         local TypeID = Logic.GetEntityType(arg[1]);
    --         local TypeName = Logic.GetEntityTypeName(TypeID);
    --         API.Note("Building placed: " ..TypeName.. " (Player: " ..arg[2].. ")");
    --     end
    -- elseif _EventID == QSB.ScriptEvents.BuildingKnockdown then
    --     if IsExisting(arg[1]) then
    --         local TypeID = Logic.GetEntityType(arg[1]);
    --         local TypeName = Logic.GetEntityTypeName(TypeID);
    --         API.Note("Knockdown: " ..TypeName.. " (Player: " ..arg[2].. ")");
    --     end
    -- elseif _EventID == QSB.ScriptEvents.SettlerAttracted then
    --     if IsExisting(arg[1]) then
    --         local TypeID = Logic.GetEntityType(arg[1]);
    --         local TypeName = Logic.GetEntityTypeName(TypeID);
    --         API.Note("Settler attracted: " ..TypeName.. " (Player: " ..arg[2].. ")");
    --     end
    -- elseif _EventID == QSB.ScriptEvents.EntitySpawned then
    --     if IsExisting(arg[1]) then
    --         local TypeID = Logic.GetEntityType(arg[1]);
    --         local TypeName = Logic.GetEntityTypeName(TypeID);
    --         API.Note("Spawned: " ..TypeName);
    --     end
    -- elseif _EventID == QSB.ScriptEvents.AnimalBred then
    --     if IsExisting(arg[1]) then
    --         local TypeID = Logic.GetEntityType(arg[1]);
    --         local TypeName = Logic.GetEntityTypeName(TypeID);
    --         API.Note("Bred: " ..TypeName);
    --     end
    end
end

function SearchWithPredicateTest()
    API.BeginBenchmark("SearchBenchmark");
    local Result = API.CommenceEntitySearch(
        {QSB.Search.OfPlayer, 1},
        {ANY,
         {QSB.Search.OfCategory, EntityCategories.CityBuilding},
         {QSB.Search.OfCategory, EntityCategories.OuterRimBuilding}},
        {QSB.Search.InTerritory, 1}
    )
    API.StopBenchmark("SearchBenchmark");
    return Result;
end