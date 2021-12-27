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
    SetDiplomacyState(1, 2, 1);
end

-- > CreateTraderWithoutRoutesTest()

function CreateTraderWithoutRoutesTest()
    API.InitHarbor(2);
end

-- > CreateTraderTest()

function CreateTraderTest()
    API.InitHarbor(
        2,
        {
            Name       = "Route1",
            Path       = {"Spawn1", "Arrived1"},
            Interval   = 60,
            Duration   = 30,
            Amount     = 2,
            Offers     = {
                {"G_Gems", 5},
                {"G_Iron", 5},
                {"G_Beer", 2},
                {"G_Stone", 5},
                {"G_Sheep", 1},
                {"G_Cheese", 2},
            }
        }
    );
end

-- > AddTradeRoute2Test()

function AddTradeRoute2Test()
    API.AddTradeRoute(
        2,
        {
            Name       = "Route2",
            Path       = {"Spawn2", "Arrived2"},
            Interval   = 60,
            Duration   = 30,
            Amount     = 3,
            Offers     = {
                {"U_CatapultCart", 1},
                {"U_MilitarySword", 3},
                {"U_MilitaryBow", 3}
            }
        }
    );
end

-- > AddTradeRoute3Test()

function AddTradeRoute3Test()
    API.AddTradeRoute(
        2,
        {
            Name       = "Route3",
            Path       = {"Spawn3", "Arrived3"},
            Interval   = 70,
            Duration   = 90,
            Amount     = 1,
            Offers     = {
                {"G_Wool", 5},
                {"G_Dye", 5},
                {"G_Beer", 2},
                {"G_Herb", 5},
                {"G_Salt", 5},
            }
        }
    );
end

-- > AddTradeRoute4Test()

function AddTradeRoute4Test()
    API.AddTradeRoute(
        2,
        {
            Name       = "Route4",
            Path       = {"Spawn4", "Arrived4"},
            Interval   = 30,
            Duration   = 45,
            Amount     = 2,
            Offers     = {
                {"G_Honeycomb", 5},
                {"G_Stone", 5},
                {"G_Bread", 2},
                {"G_Cow", 1},
                {"G_Cheese", 2},
            }
        }
    );
end

-- -------------------------------------------------------------------------- --

function CreateOldTraderTest()
    local TraderDescription = {
        PlayerID        = 2,    -- Player ID des Hafen
        PartnerPlayerID = 1,    -- Player ID des Spielers
        Path            = "WP", -- Pfad (auch als Table einzelner Punkte möglich)
        Duration        = 150,  -- Ankerzeit in Sekunden (Standard: 360)
        Interval        = 3,    -- Monate zwischen zwei Anfarten (Standard: 2)
        OfferCount      = 4,    -- Anzahl Angebote (1 bis 4) (Standard: 4)
        NoIce           = true, -- Schiff kommt nicht im Winter (Standard: false)
        Offers          = {
            {"G_Gems", 5},
            {"G_Iron", 5},
            {"G_Beer", 2},
            {"G_Stone", 5},
            {"G_Sheep", 1},
            {"G_Cheese", 2},
            {"G_Milk", 5},
            {"G_Grain", 5},
            {"G_Broom", 2},
            {"U_CatapultCart", 1},
            {"U_MilitarySword", 3},
            {"U_MilitaryBow", 3}
        },
    };
    API.TravelingSalesmanCreate(TraderDescription);
end