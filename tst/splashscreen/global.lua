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
    local Path = "E:/Repositories/symfonia/qsb/lua";
    Script.Load(Path .. "/loader.lua");
    SymfoniaLoader:Load(Path);

    if Framework.IsNetworkGame() ~= true then
        Startup_Player()
        Startup_StartGoods()
        Startup_Diplomacy()
    end
    
    API.ActivateDebugMode(true, true, true, true)
end

--ScrollSplash = "E:/Repositories/symfonia/tst/splashscreen/scroll-splash.png";
ScrollSplash = "maps/externalmap/" ..Framework.GetCurrentMapName().. "/scroll-splash.png";

function Test()
    local cutscene = {
        barStyle = "small",
        disableGlobalInvulnerability = false,
        restoreCamera = false,
        skipAll = true,
        hideFoW = true,
        showSky = true,
        hideBorderPins = true
    };
    local AP, ASP = AddPages(cutscene)

    -- Flight 1  ---------------------------------------------------------------

    AP {
        position        = Logic.GetHeadquarters(1),
        duration        = 0,
        angle           = 25,
        rotation        = 0,
        splashscreen    = {
            image = ScrollSplash,
            uv    = {0,0,0.5,1}
        },
    };
    
    AP {
        position        = Logic.GetHeadquarters(1),
        duration        = 15,
        flyTime         = 15,
        angle           = 25,
        rotation        = 0,
        faderAlpha      = 0,
        splashscreen    = {
            image = ScrollSplash,
            uv    = {0.5,0,1,1}
        },
    };

    cutscene.finished = function()
    end
    return StartBriefing(cutscene);
end