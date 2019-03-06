function CutsceneTest()
    local Cutscene = {
        RestoreGameSpeed = true,
        HideBorderPins   = true,
        TransperentBars  = false,

        {
            Flight  = "c01",
            Title   = "Bockwurst 1",
            Text    = "Text, während ich Umlaute nutzen muss!",
            Action  = BockwurstFunktion,
            FadeIn  = 3.0,
            FadeOut = nil,
        },
        {
            Flight  = "c02",
            Title   = "",
            Text    = "Das ist ein Test.",
            Action  = nil,
            FadeIn  = nil,
            FadeOut = 3.0,
        },
        {
            Flight  = "c03",
            Title   = "",
            Text    = "",
            Action  = nil,
            FadeIn  = nil,
            FadeOut = nil,
        },

        Finished = BockwurstFinished;
    };
    return API.StartCutscene(Cutscene);
end