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
    Script.Load("E:/Repositories/symfonia/test/npc/qsb.lua")
    API.Install()

    if Framework.IsNetworkGame() ~= true then
        Startup_Player()
        Startup_StartGoods()
        Startup_Diplomacy()
    end
    
    API.ActivateDebugMode(true, true, true, true)
    
    AddGood(Goods.G_Gold,   500, 1)
    AddGood(Goods.G_Wood,    30, 1)
    AddGood(Goods.G_Grain,   25, 1)
    
    AICore.HideEntityFromAI(2, GetID("christian"), true)
    
    -----
    
    API.AddQuest {
        Name        = "Test01",
        Visible     = true,
        EndMessage  = true,
        Goal_DiscoverPlayer(2),
        Reward_Diplomacy(1, 2, "EstablishedContact"),
        Trigger_Time(0),
    }
    
    API.AddQuest {
        Name        = "Test02",
        Visible     = true,
        Goal_NPC("christian", "meredith"),
        Trigger_OnQuestSuccess("Test01")
    }
    
    API.AddQuest {
        Name        = "Test03",
        EndMessage  = true,
        Goal_InstantSuccess(),
        Reward_MapScriptFunction("GuideNpc"),
        Trigger_OnQuestSuccess("Test02"),
    }
    
    API.StartQuests()
end

function FollowNpc()
    NonPlayerCharacter:New("christian")
        :SetFollowDestination("posNpc2")
        :SetFollowTarget("meredith")
        :SetFollowAction(function() API.Note("Unterwegs!") end)
        :SetCallback(function() API.Note("Ziel erreicht!") end)
        :Activate()
end

function GuideNpc()
    NonPlayerCharacter:New("christian")
        :SetGuideParams("posNpc1", "meredith")
        :SetCallback(function() API.Note("Ziel erreicht!") end)
        :SetGuideAction(function() API.Note("Unterwegs!") end)
        :Activate()
end
