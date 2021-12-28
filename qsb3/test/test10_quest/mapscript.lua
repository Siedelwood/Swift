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

end

-- > CreateFloatingRock()

function CreateFloatingRock()
    FloatingType = Entities.D_ME_Rock_Set01_B_07;
    FloatingModel = Models.Doodads_D_ME_Rock_Set01_B_07;
    local x,y,z = Logic.EntityGetPos(GetID("pos4"));
    FloatingHeight = z;
    FloatingID = Logic.CreateEntity(FloatingType, x, y, 0, 0);

    FloatingJob = API.StartHiResJob(function()
        local x,y,z = Logic.EntityGetPos(GetID("pos4"));
        DestroyEntity(FloatingID);
        Logic.SetTerrainNodeHeight(x/100,y/100,FloatingHeight + 1000);
        Logic.UpdateBlocking((x-1000)/100, (y-1000)/100, (x+1000)/100, (y+1000)/100);
        FloatingID = Logic.CreateEntity(FloatingType, x, y, 0, 0);
        Logic.SetTerrainNodeHeight(x/100,y/100,FloatingHeight);
    end)
end

function FloatingRockCreate()
    local x,y,z = Logic.EntityGetPos(GetID("pos4"));
    FloatingID = Logic.CreateEntity(Entities.XD_ScriptEntity, x, y, 0, 0);
    Logic.SetModel(FloatingID, Models.Doodads_D_ME_Rock_Set01_B_07);
    Logic.SetVisible(FloatingID, true);

    for i= x-150, x+150, 150 do
        for j= y-150, y+150, 150 do
            local ID = Logic.CreateEntity(Entities.E_NE_BlowingSnow01, i, j, 0, 0);
            API.LookAt(ID, FloatingID);
        end
    end
end

function FloatingRockIncreaseHeight()
    local x,y,z = Logic.EntityGetPos(GetID("pos4"));
    Logic.SetTerrainNodeHeight(x/100,y/100,z + 1000);
end

function FloatingRockDecreaseHeight()
    local x,y,z = Logic.EntityGetPos(GetID("pos4"));
    Logic.SetTerrainNodeHeight(x/100,y/100,z - 1000);
end

-- > CreateSegmentedQuest()

function CreateSegmentedQuest()
    API.CreateNestedQuest {
        Name        = "SegmentTest",
        Success     = "It just work's!",
        Receiver    = 1,
        Sender      = 8,
        Segments    = {
            {
                Suggestion  = "Talk to the first monk.",
                Success     = "You did great!",
                Goal_NPC("npc1"),
            },
            {
                Suggestion  = "Talk to the second monk.",
                Success     = "You did great!",
                Goal_NPC("npc2"),
                Trigger_OnQuestSuccess("SegmentTest@Segment1")
            },
            {
                Suggestion  = "Talk to the third monk.",
                Success     = "You did great!",
                Goal_NPC("npc3"),
                Trigger_OnQuestSuccess("SegmentTest@Segment2")
            },
            {
                Suggestion  = "Talk to the fourth monk.",
                Success     = "You did great!",
                Goal_NPC("npc4"),
                Trigger_OnQuestSuccess("SegmentTest@Segment3")
            }
        },

        Trigger_Time(0);
    };
end

-- > CreateJournalQuest()

function CreateJournalQuest()
    API.CreateQuest {
        Name        = "JournalQuest1",
        Suggestion  = "Test quest for showing the jornal.",
        Goal_NoChange(),
        Trigger_Time(0),
    };
end

function EnableJournalForQuest()
    API.ShowJournalForQuest("JournalQuest1", true);
end

function AddJournalEntry()
    local ID = API.CreateJournalEntry("Das ist ein Test.");
    API.AddJournalEntryToQuest(ID, "JournalQuest1");
end

function AddImportantJournalEntry()
    local ID = API.CreateJournalEntry("Das ist ein wichtiger Test.");
    API.AddJournalEntryToQuest(ID, "JournalQuest1");
    API.HighlightJournalEntry(ID, true);
end