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

    TEST_COMMAND = API.RegisterScriptCommand("TestFunction", TestFunction);
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
    if _EventID == QSB.ScriptEvents.EntityRegistered then
        if IsExisting(arg[1]) then
            local TypeID = Logic.GetEntityType(arg[1]);
            local TypeName = Logic.GetEntityTypeName(TypeID);
            API.Note("Create: " ..TypeName);
        end
    elseif _EventID == QSB.ScriptEvents.EntityDestroyed then
        if IsExisting(arg[1]) then
            local TypeID = Logic.GetEntityType(arg[1]);
            local TypeName = Logic.GetEntityTypeName(TypeID);
            API.Note("Destroyed: " ..TypeName);
        end
    end
end

function SearchWithPredicateTest()
    local Result = API.CommenceEntitySearch(
        {QSB.Search.OfPlayer, 1},
        {ANY,
         {QSB.Search.OfCategory, EntityCategories.CityBuilding},
         {QSB.Search.OfCategory, EntityCategories.OuterRimBuilding}},
        {QSB.Search.InTerritory, 1}
    )
    return Result;
end