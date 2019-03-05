function CutsceneTest()
    local Cutscene = {
        RestoreGameSpeed = true,
        HideBorderPins   = true,
        TransperentBars  = false,

        {
            Flight  = "c01",
            Title   = ""Bockwurst 1"",
            Text    = ""Das ist ein Test."",
            Action  = 3.0,
            FadeIn  = nil,
            FadeOut = 3.0,
        },
        {
            Flight  = "c02",
            Title   = ""Bockwurst 2"",
            Text    = ""Das ist ein Test."",
            Action  = nil,
            FadeIn  = nil,
            FadeOut = nil,
        },
        {
            Flight  = "c03",
            Title   = "",
            Text    = "",
            Action  = nil,
            FadeIn  = nil,
            FadeOut = nil,
        },

        Finished = function(_Data)
        end
    };
    return API.StartCutscene(Cutscene);
end