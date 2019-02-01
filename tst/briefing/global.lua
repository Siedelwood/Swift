-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Pfad an das Verzeichnis anpassen, in dem die Skripte liegen.
-- g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";
g_ContentPath = "E:/Repositories/symfonia/tst/briefing/";
Script.Load(g_ContentPath.. "internmapscript.lua");

-- Triggere deine Quests auf "MissionStartQuest".
-- Rufe GlobalMissionScript_SetIntro auf um eine Intro zu setzen.
-- Rufe GlobalMissionScript_SetCredits auf um die Credits einzustellen.
-- "MissionStartQuest" wird auf Intro und/oder Credits warten.


GlobalMissionScript_SetIntro("BriefingTest");

GlobalMissionScript_SetCredits(
    "A little Testmap",
    "totalwarANGEL",
    "Bockwurst, Schweinshaxe, Hackbraten",
    "meredith"
)

-- In dieser Funktion können Spieler initialisiert werden.
function InitPlayers()
end

-- Diese Funktion setzt den Startmonat.
function SetStartingMonth()
    Logic.SetMonthOffset(3);
end

-- In dieser Funktion kannst Du zusätzliche Skripte laden.
function InitMissionScript()
end

-- Diese Funktion wird aufgerufen, sobald die Map bereit ist.
function FirstMapAction()
    API.ActivateDebugMode(true, false, true, true);

    AddGood(Goods.G_Gold,   500, 1)
    AddGood(Goods.G_Wood,    30, 1)
    AddGood(Goods.G_Grain,   25, 1)

    API.CreateQuest {
        Name = "TestQuest",
        EndMessage = true,

        Goal_InstantSuccess(),
        Trigger_OnQuestSuccess("MissionStartQuest"),
    }
end

function BriefingTest()
    local briefing = {
        barStyle = "big",
        restoreCamera = true,
        restoreGameSpeed = false,
        skipPerPage = true,
        hideFoW = true,
        showSky = true,
        hideBorderPins = true
    };
    local AP, ASP, ASMC = API.AddPages(briefing)
    
    --[[1]]  ASP("meredith", "Lorem ipsum (1)", "dolor sit amet, consetetur"..
        " sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore"..
        " et dolore magna aliquyam erat, sed diam voluptua. At vero eos et"..
        " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
        " gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
         false)
    
    briefing.finished = function()
    end
    return API.StartBriefing(briefing)
end

function BriefingSelectionTest()
    local briefing = {
        barStyle = "big",
        restoreCamera = true,
        restoreGameSpeed = false,
        skipPerPage = true,
        hideFoW = true,
        showSky = true,
        hideBorderPins = true,
    };
    local AP, ASP, ASMC = API.AddPages(briefing);
    
    AP {
        text = "Foo",
        position = "meredith",
        dialogCamera = false,
        duration = 9999,
        entityClicked = function(_Page, _EntityID)
            API.AddBriefingNote("EntityID: " .._EntityID, 50);
        end,
        -- positionClicked = function(_Page, _X, _Y)
        --     API.AddBriefingNote("X: " .._X.." | Y: " .._Y, 50);
        -- end,
        -- screenClicked = function(_Page, _X, _Y)
        --     API.AddBriefingNote("X: " .._X.." | Y: " .._Y, 10);
        -- end,
    }
    
    briefing.finished = function()
    end
    return API.StartBriefing(briefing);
end

function BriefingMCTest()
    local briefing = {
        barStyle = "big",
        restoreCamera = true,
        restoreGameSpeed = false,
        skipPerPage = true,
        hideFoW = true,
        showSky = true,
        hideBorderPins = true
    };
    local AP, ASP, ASMC = API.AddPages(briefing)
    
    --[[1]]  ASP("meredith", "Lorem ipsum (1)", "dolor sit amet, consetetur"..
        " sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore"..
        " et dolore magna aliquyam erat, sed diam voluptua. At vero eos et"..
        " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
        " gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
         false)
    --[[2]]  ASP("christian", "Lorem ipsum (2)", "dolor sit amet, consetetur"..
        " sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore"..
        " et dolore magna aliquyam erat, sed diam voluptua. At vero eos et"..
        " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
        " gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
          false)
          
    --[[3]]  local CP1 = ASMC("meredith", "Entscheidung", "Entscheidung", false,
        "Option 1", 4,
        "Option 2", 7)
          
          
    --[[4]]  ASP("meredith", "Lorem ipsum (4)", "dolor sit amet, consetetur"..
        " sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore"..
        " et dolore magna aliquyam erat, sed diam voluptua. At vero eos et"..
        " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
        " gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
        false)
    --[[5]]  ASP("meredith", "Lorem ipsum (5)", "dolor sit amet, consetetur"..
        " sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore"..
        " et dolore magna aliquyam erat, sed diam voluptua. At vero eos et"..
        " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
        " gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
        false)
            
    AP()
        
    --[[7]]  ASP("meredith", "Lorem ipsum (7)", "dolor sit amet, consetetur"..
        " sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore"..
        " et dolore magna aliquyam erat, sed diam voluptua. At vero eos et"..
        " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
        " gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
         false)
     --[[8]]  ASP("meredith", "Lorem ipsum (8)", "dolor sit amet, consetetur"..
         " sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore"..
         " et dolore magna aliquyam erat, sed diam voluptua. At vero eos et"..
         " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
         " gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
          false)
    
    briefing.finished = function()
    end
    return API.StartBriefing(briefing)
end