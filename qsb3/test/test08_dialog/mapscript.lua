-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

function Mission_FirstMapAction()
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/questsystembehavior.lua");
    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end
    Mission_OnQsbLoaded();
end

function Mission_InitPlayers()
end

function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

function Mission_InitMerchants()
end

function Mission_LoadFiles()
    return {};
end

function Mission_OnQsbLoaded()
    API.ActivateDebugMode(true, false, true, true);
    API.SetPlayerPortrait(1);
    API.SetPlayerPortrait(2, "H_Knight_Sabatt");
end

-- -------------------------------------------------------------------------- --

-- > BriefingTypewriterTest()

function BriefingTypewriterTest()
    API.StartTypewriter {
        Text      = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "..
                    "sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
                    "magna aliquyam erat, sed diam voluptua. At vero eos et"..
                    " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
                    " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
                    " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
                    " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
                    " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
                    " et accusam et justo duo dolores et ea rebum. Stet clita"..
                    " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
                    " dolor sit amet.",
        PlayerID  = 1,
        CharSpeed = 1.5,
        Callback  = function(_Data)
            API.Note("It just work's!");
        end
    }
end

-- > BriefingCutsceneTest([[foo]], 1)

function BriefingCutsceneTest(_Name, _PlayerID)
    local Cutscene = {};
    local AF = API.AddCutscenePages(Cutscene);

    AF {
        Flight  = "c01",
        Title   = "Flight 1",
        Text    = "What is the first rule of a cutscene?",
        FadeIn  = 3,
    };
    AF {
        Flight  = "c02",
        Title   = "Flight 2",
        Text    = "They are NOT supposed to display huge chuncks of text!",
        Action  = function()
            API.Note("It just work's!");
        end
    };
    AF {
        Flight  = "c03",
        Title   = "Flight 3",
        Text    = "Keep the text small and simple, stupid!",
        FadeOut = 3,
    };

    Cutscene.Finished = function()
        -- BriefingAnimationTest1([[foo]], 1)
    end
    API.StartCutscene(Cutscene, _Name, _PlayerID)
end

-- > BriefingAnimationTest1([[foo]], 1)

function BriefingAnimationTest1(_Name, _PlayerID)
    local Briefing = {
        HideBorderPins = true,
        EnableSky = true,
        EnableCameraSoothing = false,
    }
    local AP, ASP, AAN = API.AddBriefingPages(Briefing);

    ASP("SpecialNamedPage1", "Page 1", "This is page 1! Here we initalize the first animation.");
    AAN("SpecialNamedPage1", true);
    AAN("SpecialNamedPage1", "pos2", -60, 2000, 35, "pos2", -30, 2000, 25, 30);

    AP{
        Title    = "Page 2",
        Text     = "This is page 2! The duration is 5 but this only affects the page not the animation.",
        Duration = 5,
    }

    AP{
        Name     = "SpecialNamedPage3",
        Title    = "Page 3",
        Text     = "This is page 3! Here the animation is purged and a new is started.",
    }
    AAN("SpecialNamedPage3", true);
    AAN("SpecialNamedPage3", "pos2", -45, 6000, 35, "pos2", -45, 3000, 35, 30);

    -- Position is not needed because there is a animation.
    ASP("Page 4", "This is page 4!");
    ASP("Page 5", "This is page 5!");

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    API.StartBriefing(Briefing, _Name, _PlayerID)
end

-- > BriefingAnimationTest2([[foo]], 1)

function BriefingAnimationTest2(_Name, _PlayerID)
    local Briefing = {
        HideBorderPins = true,
        ShowSky = true,
    }
    local AP, ASP, AAN = API.AddBriefingPages(Briefing);

    -- Animations are created automatically because a position is given.
    ASP("Page 1", "This is a briefing with default animation.", true, "pos2");
    ASP("Page 2", "It works just as you are used to it.", false, "pos2");
    ASP("Page 3", "No fancy camera magic and everything in one line.", true, "pos4");
    ASP("Page 4", "Text is displayed until the player skips the page.", false, "pos4");

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
        -- BriefingAnimationTest1([[foo]], 1)
    end
    API.StartBriefing(Briefing, _Name, _PlayerID)
end

-- > CreateTestNPCDialogQuest()

function CreateTestNPCDialogQuest()
    ReplaceEntity("npc1", Entities.U_KnightSabatta);

    AddQuest {
        Name        = "TestNpcQuest3",
        Suggestion  = "Speak to this npc.",
        Receiver    = 1,

        Goal_NPC("npc1", "-"),
        Reward_Dialog("TestDialog", "CreateTestNPCDialogBriefing"),
        Trigger_Time(0),
    }
end

function CreateTestNPCDialogBriefing(_Name, _PlayerID)
    local Dialog = {
        DisableFow = true,
        DisableBoderPins = true,
        RestoreGameSpeed = true,
        RestoreCamera = true,
    };
    local AP, ASP = API.AddDialogPages(Dialog);

    TestOptionVisibility = true;

    AP {
        Name   = "StartPage",
        Text   = "This is a test!",
        Sender = 1,
        Target = "npc1",
        Zoom   = 0.1,
        MC     = {
            {"Continue testing", "ContinuePage"},
            {"Remove answer",
             function()
                TestOptionVisibility = false;
                return "ContinuePage";
             end,
             function() return not TestOptionVisibility; end},
            {"Stop testing", "EndPage"}
        }
    }

    AP {
        Name   = "ContinuePage",
        Text   = "Splendit, it seems to work as intended.",
        Sender = 1,
        Target = Logic.GetKnightID(_PlayerID),
        Zoom   = 0.1,
    }

    AP {
        Text   = "We can show large texts with portrait... {cr}{cr}Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
        Sender = 2,
        Target = "npc1",
        Zoom   = 0.1,
    }
    AP {
        Text   = "... or without portrait... {cr}{cr}Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
        Sender = -1,
        Target = "npc1",
        Zoom   = 0.1,
    }
    AP {
        Text   = "And even more text... {cr}{cr}Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
        Sender = 2,
        Target = "npc1",
        Zoom   = 0.1,
    }
    AP("StartPage");

    AP {
        Name   = "EndPage",
        Text   = "Well, then we end this mess!",
        Sender = -1,
        Target = "npc1",
        Zoom   = 0.1,
    }

    Dialog.Starting = function(_Data)
    end
    Dialog.Finished = function(_Data)
    end
    API.StartDialog(Dialog, _Name, _PlayerID);
end