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
    -- Optional: Füge der Map ein Skript mit namen knighttitlerequirements.lua
    -- hinzu, wenn die Aufstiegsbedingungen geändert werden sollen. 
    return {
        gvMission.ContentPath.. "knighttitlerequirements.lua",
        "E:/Repositories/swift/qsb3/lua/legacy/externalevilheroes.lua",
        -- Füge hier weitere Skriptdateien hinzu.
        -- z.B.: 
        -- gvMission.ContentPath.. "chapter1.lua",
        -- gvMission.ContentPath.. "chapter2.lua",
        -- gvMission.ContentPath.. "chapter3.lua",
    };
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

    -- Testmodus aktivieren
    API.ActivateDebugMode(true, false, true, true);

    -- Erzeugt im Assistenten erstellte Quests
    -- (Falls nicht gebraucht, löschen)
    -- CreateQuests();

    -- Hier kannst Du Deine Funktionen aufrufen
    ReplaceHeroWithSabatt()
end

function ReplaceHeroWithSabatt()
    local ID = ReplaceEntity(Logic.GetKnightID(1), Entities.U_KnightSabatta);
    Logic.SetPrimaryKnightID(1, ID);
    Logic.ExecuteInLuaLocalState("LocalSetKnightPicture()");
end

function CreateEnemy()
    local x,y,z = Logic.EntityGetPos(Logic.GetKnightID(1));
    local ID = Logic.CreateBattalionOnUnblockedLand(Entities.U_MilitarySword, x, y, 0, 2, 6);
end

function CreateTestMine()
    API.CreateIOIronMine("MineTest", Goods.G_Grain, 20, Goods.G_Stone, 30, true)
    -- API.CreateIOStoneMine("MineTest", Goods.G_Carcass, 20, Goods.G_Wood, 30, true)
    -- API.CreateIOIronMine("MineTest", Goods.G_Iron, 20, Goods.G_Gems, 20, true)
    -- API.CreateIOStoneMine("MineTest", Goods.G_Dye, 20, Goods.G_Honeycomb, 30, true)
    -- API.CreateIOIronMine("MineTest", Goods.G_Carcass, 30, Goods.G_RawFish, 30, true)
    -- API.CreateIOStoneMine("MineTest", Goods.G_Milk, 30, Goods.G_Honeycomb, 30, true)
    -- API.CreateIOIronMine("MineTest", Goods.G_Olibanum, 20, Goods.G_RawFish, 30, true)
    -- API.CreateIOStoneMine("MineTest", Goods.G_Iron, 30, Goods.G_Wood, 30, true)
end

