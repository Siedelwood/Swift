-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Intern Global Script                                                   # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Einfach alles so lassen, wie es ist!

GlobalMissionScript = {
    UseCredits       = false,
    UseIntro         = false,
    IntroName        = "IntroCutsceneFunctionName",
    CreditsFinished  = true,
    CreditsMapName   = "A Siedelwood Map",
    CreditsMapAuthor = "Author",
    CreditsMapTester = "Tester1, Tester2, Tester3",
    CreditsLookAt    = Logic.GetHeadquarters(1),
}

function GlobalMissionScript.SetIntro(_Name)
    GlobalMissionScript.IntroName = _Name;
    GlobalMissionScript.UseIntro = true;
end

function GlobalMissionScript.SetCredits(_MapName, _Author, _Tester, _LookAt)
    _LookAt = _LookAt or Logic.GetHeadquarters(1);
    GlobalMissionScript.CreditsMapName = _MapName;
    GlobalMissionScript.CreditsMapAuthor = _Author;
    GlobalMissionScript.CreditsMapTester = _Tester;
    GlobalMissionScript.CreditsLookAt = GetID(_LookAt);
    GlobalMissionScript.UseCredits = true;
    GlobalMissionScript.CreditsFinished = false;
end

function GlobalMissionScript.AreCreditsFinished()
    return GlobalMissionScript.CreditsFinished == true;
end

function GlobalMissionScript.DisplayUI()
    API.Bridge("Mission_LocalDisplayUI(1)");
end

function GlobalMissionScript_Trigger_WaitingForCreditsFinished()
    return GlobalMissionScript.AreCreditsFinished();
end

function GlobalMissionScript_Reward_DisplayUI()
    GlobalMissionScript.DisplayUI()
end

-- -------------------------------------------------------------------------- --

function Mission_InitPlayers()
    if InitPlayers then
        InitPlayers();
    end
end

function Mission_SetStartingMonth()
    if SetStartingMonth then
        SetStartingMonth();
    else
        Logic.SetMonthOffset(1);
    end
end

function Mission_FirstMapAction()
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
    Script.Load(g_ContentPath.. "knighttitlerequirements.lua");
    API.Install();
    InitKnightTitleTables();

    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end

    Mission_QuestOnGameStart();
    if InitMissionScript then
        InitMissionScript();
    end
    if FirstMapAction then
        FirstMapAction();
    end
end

function Mission_QuestOnGameStart()
    if BundleQuestGeneration then
        
        local Behaviors = {
            Goal_InstantSuccess(),
            Trigger_Time(0)
        };
        if GlobalMissionScript.UseCredits then
            table.insert(Behaviors, Reward_MapScriptFunction("GlobalMissionScript_Reward_DisplayUI"));
            table.insert(Behaviors, Trigger_MapScriptFunction("GlobalMissionScript_Trigger_WaitingForCreditsFinished"));
        end
        if GlobalMissionScript.UseIntro then
            table.insert(Behaviors, Reward_Briefing(GlobalMissionScript.IntroName));
        end
        API.CreateQuest { Name = "MissionStartQuest_A",  unpack(Behaviors)};

        -- ------------------------------------------------------------------ --

        local Behaviors = {
            Goal_InstantSuccess(),
            Trigger_OnQuestSuccess("MissionStartQuest_A", 0),
        };
        if GlobalMissionScript.UseIntro then
            table.insert(Behaviors, Trigger_BriefingSuccess("MissionStartQuest_A"));
        end
        API.CreateQuest { Name = "MissionStartQuest",  unpack(Behaviors)};
    end
end