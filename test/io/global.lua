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
    Script.Load("E:/Repositories/symfonia/test/io/qsb.lua")
    API.Install()

    if Framework.IsNetworkGame() ~= true then
        Startup_Player()
        Startup_StartGoods()
        Startup_Diplomacy()
    end
    
    API.ActivateDebugMode(true, true, true, true)
    
    AddGood(Goods.G_Gold,   1000, 1)
    AddGood(Goods.G_Wood,    30, 1)
    AddGood(Goods.G_Grain,   25, 1)
    
    -----

    QSB.CastleStore:New(1);
    ObjectsWithCastleStore()
end

function SimpleObjects()
    API.CreateObject {
        Name        = "normal",
        Title       = "Normales Objekt",
        Text        = "",
        Texture     = {11, 4},
        Waittime    = 5,
        Callback    = function(_Obj)
            API.Note(_Obj.Name.. " activated!")
        end
    }
    
    API.CreateObject {
        Name        = "custom",
        Title       = "Custom Objekt",
        Text        = "",
        Texture     = {4, 4},
        Callback    = function(_Obj)
            API.Note(_Obj.Name.. " activated!")
        end
    }
end

function ObjectsWithCosts()
    API.CreateObject {
        Name        = "normal",
        Title       = "Normales Objekt",
        Text        = "",
        Texture     = {11, 4},
        Waittime    = 5,
        Costs       = {Goods.G_Gold, 10, Goods.G_Grain, 10},
        Callback    = function(_Obj)
            API.Note(_Obj.Name.. " activated!")
        end
    }
    
    API.CreateObject {
        Name        = "custom",
        Title       = "Custom Objekt",
        Text        = "",
        Texture     = {4, 4},
        Costs       = {Goods.G_Gold, 10, Goods.G_Grain, 10},
        Callback    = function(_Obj)
            API.Note(_Obj.Name.. " activated!")
        end
    }
end

function ObjectsWithCondition()
    API.CreateObject {
        Name        = "normal",
        Title       = "Normales Objekt",
        Text        = "",
        Texture     = {11, 4},
        Waittime    = 5,
        Condition   = function(_Obj)
            return Logic.GetTime() > 15;
        end,
        Callback    = function(_Obj)
            API.Note(_Obj.Name.. " activated!")
        end
    }
    
    API.CreateObject {
        Name        = "custom",
        Title       = "Custom Objekt",
        Text        = "",
        Texture     = {4, 4},
        Condition   = function(_Obj)
            return Logic.GetTime() > 15;
        end,
        Callback    = function(_Obj)
            API.Note(_Obj.Name.. " activated!")
        end
    }
end

function ObjectsWithCastleStore()
    API.CreateObject {
        Name        = "normal",
        Title       = "Normales Objekt",
        Text        = "",
        Texture     = {11, 4},
        Waittime    = 5,
        Costs       = {Goods.G_Gold, 10, Goods.G_Grain, 25},
        Callback    = function(_Obj)
            API.Note(_Obj.Name.. " activated!")
        end
    }
    
    API.CreateObject {
        Name        = "custom",
        Title       = "Custom Objekt",
        Text        = "",
        Texture     = {4, 4},
        Costs       = {Goods.G_Gold, 10, Goods.G_Grain, 25},
        Callback    = function(_Obj)
            API.Note(_Obj.Name.. " activated!")
        end
    }
end