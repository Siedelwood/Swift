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
    Script.Load("E:/Repositories/symfonia/test/briefing/qsb.lua")
    API.Install()

    if Framework.IsNetworkGame() ~= true then
        Startup_Player()
        Startup_StartGoods()
        Startup_Diplomacy()
    end
    
    API.ActivateDebugMode(true, true, true, true)
    
    AddGood(Goods.G_Gold,   500, 1)
    AddGood(Goods.G_Wood,    30, 1)
    AddGood(Goods.G_Grain,   25, 1)
    
    -----
    
    
end

function BriefingTest()
    local briefing = {
        barStyle = "big",
        restoreCamera = true,
        skipPerPage = true,
        hideFoW = true,
        showSky = true,
        hideBorderPins = true
    };
    local AP, ASP, ASMC = API.AddPages(briefing)
    
    --[[1]]  ASP("castle1", "Lorem ipsum (1)", "dolor sit amet, consetetur"..
        " sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore"..
        " et dolore magna aliquyam erat, sed diam voluptua. At vero eos et"..
        " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
        " gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
         false)
    --[[2]]  ASP("store1", "Lorem ipsum (2)", "dolor sit amet, consetetur"..
        " sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore"..
        " et dolore magna aliquyam erat, sed diam voluptua. At vero eos et"..
        " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
        " gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
          false)
          
    --[[3]]  local CP1 = ASMC("cathedral1", "", "Entscheidung", false,
        "Option 1", 4,
        "Option 2", 7)
          
          
    --[[4]]  ASP("castle1", "Lorem ipsum (4)", "dolor sit amet, consetetur"..
        " sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore"..
        " et dolore magna aliquyam erat, sed diam voluptua. At vero eos et"..
        " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
        " gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
        false)
    --[[5]]  ASP("store1", "Lorem ipsum (5)", "dolor sit amet, consetetur"..
        " sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore"..
        " et dolore magna aliquyam erat, sed diam voluptua. At vero eos et"..
        " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
        " gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
        false)
            
    AP()
        
    --[[7]]  ASP("castle1", "Lorem ipsum (7)", "dolor sit amet, consetetur"..
        " sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore"..
        " et dolore magna aliquyam erat, sed diam voluptua. At vero eos et"..
        " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
        " gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
         false)
     --[[8]]  ASP("store1", "Lorem ipsum (8)", "dolor sit amet, consetetur"..
         " sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore"..
         " et dolore magna aliquyam erat, sed diam voluptua. At vero eos et"..
         " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
         " gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
          false)
    
    briefing.finished = function()
    end
    return API.StartBriefing(briefing)
end