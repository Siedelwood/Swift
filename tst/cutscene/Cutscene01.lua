function Cutscene01()
    local Cutscene = {
        RestoreGameSpeed = false,
        HideBorderPins   = true,
        TransperentBars  = false,
        FastForward      = true,

        {
            Flight  = "c01_f01",
            Title   = "Flight 1",
            Text    = "Das ist ein Test!",
            Action  = nil,
            FadeIn  = 3.0,
            FadeOut = nil,
        },
        {
            Flight  = "c01_f02",
            Title   = "Flight 2",
            Text    = "Das ist ein Test!",
            Action  = nil,
            FadeIn  = nil,
            FadeOut = nil,
        },
        {
            Flight  = "c01_f03",
            Title   = "Flight 3",
            Text    = "Das ist ein Test!",
            Action  = nil,
            FadeIn  = nil,
            FadeOut = 3.0,
        },

        Finished = nil;
    };
    return API.CutsceneStart(Cutscene);
end