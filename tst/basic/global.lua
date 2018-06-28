--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_InitPlayers
----------------------------------
-- Diese Funktion kann benutzt werden um für die AI
-- Vereinbarungen zu treffen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_InitPlayers()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_SetStartingMonth
----------------------------------
-- Diese Funktion setzt einzig den Startmonat.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_InitMerchants
----------------------------------
-- Hier kannst du Hдndler und Handelsposten vereinbaren.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_InitMerchants()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mission_FirstMapAction
----------------------------------
-- Die FirstMapAction wird am Spielstart aufgerufen.
-- Starte von hier aus deine Funktionen.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Mission_FirstMapAction()
    local Path = "E:/Repositories/symfonia/qsb/lua";
    Script.Load(Path .. "/loader.lua");
    SymfoniaLoader:Load(Path);

    if Framework.IsNetworkGame() ~= true then
        Startup_Player()
        Startup_StartGoods()
        Startup_Diplomacy()
    end
    
    API.ActivateDebugMode(true, true, true, true)
    
    AddGood(Goods.G_Gold,   500, 1)
    AddGood(Goods.G_Wood,    30, 1)
    AddGood(Goods.G_Grain,   25, 1)
    
    Logic.SetKnightTitle(1, 3);
    
    API.AddQuest {
        Name = "Test01",
        EndMessage = true,
        Goal_InstantSuccess(),
        Reward_QuestRestart("Test02"),
        Trigger_OnMonth(4),
    }
    
    API.AddQuest {
        Name = "Test02",
        EndMessage = true,
        Goal_InstantSuccess(),
        Reward_QuestRestart("Test01"),
        Trigger_OnMonth(10),
    }
    
    -- -----
    -- 
    -- API.AddQuest {
    --     Name        = "Test01",
    --     Visible     = true,
    --     EndMessage  = true,
    --     Goal_DiscoverPlayer(2),
    --     Trigger_Time(0),
    -- }
    -- 
    -- API.AddQuest {
    --     Name        = "Test02",
    --     Visible     = true,
    --     EndMessage  = true,
    --     Goal_MoveToPosition("meredith", "christian", 1000, true),
    --     Trigger_OnQuestSuccess("Test01")
    -- }
    -- 
    -- API.AddQuest {
    --     Name        = "Test03",
    --     Visible     = true,
    --     EndMessage  = true,
    --     Goal_KnightTitle("Mayor"),
    --     Trigger_OnQuestSuccess("Test01"),
    -- }
    -- 
    -- API.StartQuests()
    -- 
    -- -----
    -- 
    -- API.QuestDialog {
    --     {"Das ist ein Test!",        1, 1, "Test03",  10, function() API.Note("Dialog Quest 1") end},
    --     {"Das ist noch ein Test!",   1, 1, nil,      nil, function() API.Note("Dialog Quest 2") end},
    --     {"Das ist der letzte Test!", 1, 1, nil,      nil, function() API.Note("Dialog Quest 3") end},
    -- }
end
