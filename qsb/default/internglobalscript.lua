-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Intern Global Script                                                   # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Einfach alles so lassen, wie es ist!

-- -------------------------------------------------------------------------- --

GlobalMissionScript = {
    UseCredits      = false,
    CreditsStory    = "",
    CreditsFinished = true,

    UseIntro        = false,
    IntroBriefing   = nil,
};

function GlobalMissionScript.RegisterCredits(_Story)
    GlobalMissionScript.CreditsStory    = _Story;
    GlobalMissionScript.CreditsFinished = false;
    GlobalMissionScript.UseCredits      = true;
end

function GlobalMissionScript.StartCredits()
    API.SimpleTypewriter(GlobalMissionScript.CreditsStory, GlobalMissionScript.FinishCredits);
end

function GlobalMissionScript.FinishCredits()
    GlobalMissionScript.CreditsFinished = true;
end

function GlobalMissionScript.RegisterIntroBriefing(_Briefing)
    GlobalMissionScript.IntroBriefing = _Briefing;
    GlobalMissionScript.UseIntro      = true;
end

function GlobalMissionScript_Trigger_CreditsFinished()
    if GlobalMissionScript.UseCredits and BundleDialogWindows then
        return GlobalMissionScript.CreditsFinished == true;
    else
        return true;
    end
end

function GlobalMissionScript_Trigger_IntroFinished()
    if GlobalMissionScript.UseIntro and BriefingSystem then
        return IsBriefingFinished(GlobalMissionScript.IntroBriefingID);
    else
        return true;
    end
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
        
        if GlobalMissionScript.UseCredits then
            GlobalMissionScript.StartCredits();
        end
        if GlobalMissionScript.UseIntro then
            StartSimpleHiResJobEx(function()
                if _G[GlobalMissionScript.IntroBriefing] then
                    if GlobalMissionScript.UseCredits and GlobalMissionScript.CreditsFinished then
                        GlobalMissionScript.IntroBriefingID = _G[GlobalMissionScript.IntroBriefing]();
                        return true;
                    elseif not GlobalMissionScript.UseCredits then
                        GlobalMissionScript.IntroBriefingID = _G[GlobalMissionScript.IntroBriefing]();
                        return true;
                    end
                end
            end)
        end
        
        API.CreateQuest{
            Name = "MissionStartQuest",
            Goal_InstantSuccess(),
            Trigger_MapScriptFunction("GlobalMissionScript_Trigger_CreditsFinished"),
            Trigger_MapScriptFunction("GlobalMissionScript_Trigger_IntroFinished"),
            Trigger_Time(0),
        };
    end
end