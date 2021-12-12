function Cutscene1()
    local Cutscene = {
        RestoreGameSpeed = false,
        HideBorderPins   = false,
        BigBars          = false,
        BarOpacity       = 1.000000,
        FastForward      = false,
    };
    local AF = API.AddFlights(Cutscene);

    AF {
        Flight  = "c01",
        Title   = "",
        Text    = "",
        Action  = nil,
        FadeIn  = nil,
        FadeOut = nil,
    };
    AF {
        Flight  = "c02",
        Title   = "",
        Text    = "",
        Action  = nil,
        FadeIn  = nil,
        FadeOut = nil,
    };
    AF {
        Flight  = "c03",
        Title   = "",
        Text    = "",
        Action  = nil,
        FadeIn  = nil,
        FadeOut = nil,
    };


    Cutscene.Starting = nil;
    Cutscene.Finished = nil;

    return API.CutsceneStart(Cutscene);
end