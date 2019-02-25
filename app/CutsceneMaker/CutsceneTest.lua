function CutsceneTest()
    local cutscene = {
        barStyle = "small",
        disableGlobalInvulnerability = false,
        restoreCamera = true,
        restoreGameSpeed = false,
        disableSkipping = true,
        hideFoW = true,
        showSky = true,
        hideBorderPins = true
    };
    local AF = AddFlights(cutscene);

    AF {
        {
            Position = {X=   12793.41, Y=    3042.22, Z=    1601.68},
            LookAt   = {X=   12821.73, Y=    3137.92, Z=    1607.95},
            FOV      = 42.0,
            Title    = "Titel 1",
            Text     = "Das ist ein Text!",
            Action   = DoOneThing
        },
        {
            Position = {X=   12793.41, Y=    3042.22, Z=    1601.68},
            LookAt   = {X=   12821.73, Y=    3137.92, Z=    1607.95},
            FOV      = 42.0,
            Title    = "Titel 2",
            Text     = "Das ist ein Text!",
            Action   = DoAnotherThing
        },
        {
            Position = {X=   12793.41, Y=    3042.22, Z=    1601.68},
            LookAt   = {X=   12821.73, Y=    3137.92, Z=    1607.95},
            FOV      = 42.0,
            Title    = "",
            Text     = "",
            Action   = nil
        },
        {
            Position = {X=   12793.41, Y=    3042.22, Z=    1601.68},
            LookAt   = {X=   12821.73, Y=    3137.92, Z=    1607.95},
            FOV      = 42.0,
            Title    = "Titel 4",
            Text     = "Das ist ein Text!",
            Action   = nil
        },

        Duration   = 25.0,
        -- Add fader and other stuff here
    }
    AF {
        {
            Position = {X=   12793.41, Y=    3042.22, Z=    1601.68},
            LookAt   = {X=   12821.73, Y=    3137.92, Z=    1607.95},
            FOV      = 42.0,
            Title    = "Titel 5",
            Text     = "Das ist ein Text!",
            Action   = DoOneThing
        },
        {
            Position = {X=   12793.41, Y=    3042.22, Z=    1601.68},
            LookAt   = {X=   12821.73, Y=    3137.92, Z=    1607.95},
            FOV      = 42.0,
            Title    = "Titel 6",
            Text     = "Das ist ein Text!",
            Action   = nil
        },

        Duration   = 4.0,
        -- Add fader and other stuff here
    }
    AF {
        {
            Position = {X=   12793.41, Y=    3042.22, Z=    1601.68},
            LookAt   = {X=   12821.73, Y=    3137.92, Z=    1607.95},
            FOV      = 42.0,
            Title    = "",
            Text     = "",
            Action   = nil
        },
        {
            Position = {X=   12793.41, Y=    3042.22, Z=    1601.68},
            LookAt   = {X=   12821.73, Y=    3137.92, Z=    1607.95},
            FOV      = 42.0,
            Title    = "Titel 10",
            Text     = "Das ist ein Text!",
            Action   = nil
        },

        Duration   = 2.5,
        -- Add fader and other stuff here
    }

    cutscene.finished = function()
    end
    return StartCutscene(cutscene);
end