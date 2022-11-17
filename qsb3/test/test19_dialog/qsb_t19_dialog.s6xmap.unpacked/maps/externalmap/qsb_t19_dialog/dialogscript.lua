function StartBriefingCutsceneDialogDemo()
    CreateInitiatorQuest();
end

-- -------------------------------------------------------------------------- --

function CreateInitiatorQuest()
    AddQuest {
        Name        = "TestNpcQuest_1",
        Suggestion  = "This is another quest with a different actor.",
        Success     = "Success Message",
        Failure     = "Failure Message",
        Receiver    = 1,
        Sender      = 4,

        Goal_NoChange(),
        Trigger_Time(0),
    }

    AddQuest {
        Name        = "TestNpcQuest1",
        Suggestion  = "Speak to this npc.",
        Receiver    = 1,

        Goal_NPC("npc1", "-"),
        Reward_MapScriptFunction("CreateInitiatorCallback"),
        Trigger_Time(5),
    }

    AddQuest {
        Name        = "TestNpcQuest0",
        Suggestion  = "This is a quest that just HAD to butt in.",
        Receiver    = 1,
        Sender      = 2,

        Goal_NoChange(),
        Trigger_Time(10),
    }

    AddQuest {
        Name        = "TestNpcQuest2",
        Suggestion  = "Sometimes it just work's!",
        Receiver    = 1,
        Sender      = 2,

        Goal_NoChange(),
        Trigger_Dialog("DialogTest1", 1, 5),
    }
end

function CreateInitiatorCallback(_Behavior, _Quest)
    TypewriterTest(_Quest.ReceivingPlayer);
    CutsceneTest("CutsceneTest1", _Quest.ReceivingPlayer);
    BriefingTest("BriefingTest1", _Quest.ReceivingPlayer);
    DialogTest2("DialogTest1", _Quest.ReceivingPlayer);
end

-- -------------------------------------------------------------------------- --

function TypewriterTest(_PlayerID)
    API.StartTypewriter {
        Text      = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "..
                    "sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
                    "magna aliquyam erat, sed diam voluptua.",
        PlayerID  = _PlayerID,
        CharSpeed = 1.5,
        Callback  = function(_Data)
        end
    }
end

-- -------------------------------------------------------------------------- --

function CutsceneTest(_Name, _PlayerID)
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
    };
    AF {
        Flight  = "c03",
        Title   = "Flight 3",
        Text    = "Keep the text small and simple, stupid!",
        FadeOut = 3,
    };

    Cutscene.Finished = function()
    end
    API.StartCutscene(Cutscene, _Name, _PlayerID)
end

-- -------------------------------------------------------------------------- --

-- > BriefingTest([[foo]], 1)

function BriefingTest(_Name, _PlayerID)
    local Briefing = {
        EnableBorderPins = false,
        EnableSky = true,
        EnableFoW = false,
    }
    local AP, ASP = API.AddBriefingPages(Briefing);

    ASP("SpecialNamedPage1", "Page 1", "This is a briefing. I have to say important things.");
    ASP("SpecialNamedPage2", "Page 2", "WOW! That is very cool.");

    Briefing.PageAnimations = {
        ["SpecialNamedPage1"] = {
            {PurgeOld = true,
             30, "npc1", -60, 2000, 35, "npc1", -30, 2000, 25}
        },
        ["SpecialNamedPage2"] = {
            {PurgeOld = true,
             30, "hero", -45, 6000, 35, "hero", -45, 3000, 35}
        },
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    API.StartBriefing(Briefing, _Name, _PlayerID)
end

-- -------------------------------------------------------------------------- --

-- > BriefingTest2([[foo]], 1)

function BriefingTest2(_Name, _PlayerID)
    local Briefing = {
        EnableBorderPins = false,
        EnableSky = true,
        EnableFoW = false,
    }
    local AP, ASP = API.AddBriefingPages(Briefing);

    AP {
        Name     = "Page1",
        Title    = "Page 1",
        Text     = "This is page 1 with parallax.",
        Position = "npc1",
        BarOpacity = 0,
        Parallax = {
            {
                Image    = "C:/IMG/Paralax6.png",
                Duration = 60,
                Start    = {U0 = 0,   V0 = 0, U1 = 0.8, V1 = 1, A = 255},
                End      = {U0 = 0.2, V0 = 0, U1 = 1,   V1 = 1, A = 255}
            }
        }
    }

    AP {
        Name     = "Page2",
        Title    = "Page 2",
        Text     = "This is page 2.",
        Position = "npc1",
    }

    Briefing.PageParallax = {
        -- ["Page1"] = {
        --     {"C:/IMG/Paralax6.png", 60, 0, 0, 0.8, 1, 255, 0.2, 0, 1, 1, 255}
        -- },
        ["Page2"] = {
            PurgeOld = true
        }
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    API.StartBriefing(Briefing, _Name, _PlayerID)
end

-- -------------------------------------------------------------------------- --

function DialogTest(_Name, _PlayerID)
    local Dialog = {
        EnableFoW = false,
        EnableBorderPins = false,
        RestoreGameSpeed = true,
        RestoreCamera = true,
    };
    local AP, ASP = API.AddDialogPages(Dialog);

    ASP(8, "npc1", "NPC", "I aren't done drowning you in useless text.", true);
    ASP(1, "npc1", "Hero", "Maybe I should make your fat neck spin...", true);

    Dialog.Starting = function(_Data)
    end
    Dialog.Finished = function(_Data)
        -- Logic.ExecuteInLuaLocalState(string.format([[
        --     Camera.RTS_SetZoomFactor(0.1);
        --     Camera.RTS_FollowEntity(GetID("hero"));
        --     API.DeactivateNormalInterface();
        -- ]]));
    end
    API.StartDialog(Dialog, _Name, _PlayerID);
end

-- -------------------------------------------------------------------------- --

function DialogTest2(_Name, _PlayerID)
    local Dialog = {
        EnableFoW = false,
        EnableBorderPins = false,
        RestoreGameSpeed = true,
        RestoreCamera = true,
    };
    local AP, ASP = API.AddDialogPages(Dialog);

    AP {
        Name         = "Page0",
        Duration     = 2,
        FadeIn       = 2,
        Position     = "npc1",
        DialogCamera = true,
    };
    ASP("Page1", 8, "npc1", "NPC", "I aren't done drowning you in useless text.", true)
    AP {
        Name         = "Page2",
        Text         = "Page without an actor. How sad...",
        Position     = "hero",
        DialogCamera = true,
        MC           = {
            {"Option 1", "Page3"},
            {"Option 2",
             function()
                return "Page4";
             end,},
        }
    };
    AP {
        Name         = "Page3",
        Title        = "Hero",
        Text         = "This page has an actor and a choice.",
        Actor        = 1,
        Position     = "hero",
        DialogCamera = true,
        MC           = {
            {"Option 1", "Page2"},
            {"Option 2",
             function()
                return "Page4";
             end,},
        }
    };
    AP {
        Name         = "Page4",
        Title        = "Hero",
        Text         = "Maybe I should make your fat neck spin...",
        Actor        = 1,
        Position     = "hero",
        DialogCamera = true,
    };
    AP {
        Name         = "Page5",
        Duration     = 2,
        FadeOut      = 2,
        Position     = "hero",
        DialogCamera = true,
    };

    Dialog.Starting = function(_Data)
    end
    Dialog.Finished = function(_Data)
    end
    API.StartDialog(Dialog, _Name, _PlayerID);
end

