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
    Script.Load("E:/Repositories/symfonia/var/qsb.lua");
    API.Install();

    if Framework.IsNetworkGame() ~= true then
        Startup_Player()
        Startup_StartGoods()
        Startup_Diplomacy()
    end
    
    API.ActivateDebugMode(true, false, true, true)
    
    AddGood(Goods.G_Gold, 50000, 1);
    
    -----
    
    SetDiplomacyState(1, 2, 2);
    SetDiplomacyState(1, 3, 2);
    SetDiplomacyState(1, 4, 2);
    SetDiplomacyState(1, 5, 2);

    API.InterfaceSetPlayerColor(2, 6);
    API.InterfaceSetPlayerColor(3, 2);
    API.InterfaceSetPlayerColor(4, 3);
    API.InterfaceSetPlayerColor(5, 4);

    API.InterfaceSetPlayerPortrait(2);
    API.InterfaceSetPlayerPortrait(3);
    API.InterfaceSetPlayerPortrait(4);
    API.InterfaceSetPlayerPortrait(5);

    CreateHabor2();
    CreateHabor3();
    CreateHabor4();
    CreateHabor5();
end

function CreateHabor2()
    local TraderDescription = {
        PlayerID   = 2,       -- Partei des Hafen
        Path       = "SH2WP", -- Pfad (auch als Table möglich)
        Duration   = 4*60,     -- Ankerzeit in Sekunden
        Interval   = 4,       -- Monate zwischen zwei Anfarten
        OfferCount = 2,       -- Anzahl Angebote (1 bis 4)
        Offers = {
            -- Angebot, Menge
            {"G_Gems", 5},
            {"G_Iron", 5},
            {"G_Beer", 2},
            {"G_Stone", 5},
            {"G_Sheep", 1},
            {"G_Cheese", 2},
            {"G_Milk", 5},
            {"G_Grain", 5},
            {"G_Broom", 2},
            {"U_CatapultCart", 1},
            {"U_MilitarySword", 3},
            {"U_MilitaryBow", 3}
        },
    };
    API.TravelingSalesmanCreate(TraderDescription);
end 

function CreateHabor3()
    local TraderDescription = {
        PlayerID   = 3,       -- Partei des Hafen
        Path       = "SH3WP", -- Pfad (auch als Table möglich)
        Duration   = 3*60,     -- Ankerzeit in Sekunden
        Interval   = 1,       -- Monate zwischen zwei Anfarten
        OfferCount = 3,       -- Anzahl Angebote (1 bis 4)
        Offers = {
            -- Angebot, Menge
            {"G_Salt", 5},
            {"G_Stone", 5},
            {"G_Beer", 2},
            {"G_Stone", 5},
            {"G_Sheep", 1},
            {"G_Bread", 2},
            {"G_Milk", 5},
            {"G_Grain", 5},
            {"G_Soap", 2},
            {"U_SiegeTowerCart", 1},
            {"U_MilitaryBandit_Melee_SE", 3},
            {"U_MilitaryBandit_Melee_NE", 3}
        },
    };
    API.TravelingSalesmanCreate(TraderDescription);
end 

function CreateHabor4()
    local TraderDescription = {
        PlayerID   = 4,       -- Partei des Hafen
        Path       = "SH4WP", -- Pfad (auch als Table möglich)
        Duration   = 5*60,     -- Ankerzeit in Sekunden
        Interval   = 2,       -- Monate zwischen zwei Anfarten
        OfferCount = 4,       -- Anzahl Angebote (1 bis 4)
        Offers = {
            -- Angebot, Menge
            {"G_Dye", 5},
            {"G_Herb", 5},
            {"G_Beer", 2},
            {"G_Stone", 5},
            {"G_Cow", 1},
            {"G_Bread", 2},
            {"G_Milk", 5},
            {"G_RawFish", 5},
            {"G_Broom", 2},
            {"U_SiegeTowerCart", 1},
            {"U_MilitaryBandit_Melee_ME", 3},
            {"U_MilitaryBandit_Melee_NA", 3}
        },
    };
    API.TravelingSalesmanCreate(TraderDescription);
end 

function CreateHabor5()
    local TraderDescription = {
        PlayerID   = 5,       -- Partei des Hafen
        Path       = "SH5WP", -- Pfad (auch als Table möglich)
        Duration   = 7*60,     -- Ankerzeit in Sekunden
        Interval   = 3,       -- Monate zwischen zwei Anfarten
        OfferCount = 1,       -- Anzahl Angebote (1 bis 4)
        Offers = {
            -- Angebot, Menge
            {"G_Salt", 5},
            {"G_Herb", 5},
            {"G_Beer", 2},
            {"G_Gems", 5},
            {"G_Cow", 1},
            {"G_Bread", 2},
            {"G_Milk", 5},
            {"G_RawFish", 5},
            {"G_Broom", 2},
            {"U_CatapultCart", 1},
            {"U_MilitaryBandit_Ranged_SE", 3},
            {"U_MilitaryBandit_Ranged_NE", 3}
        },
    };
    API.TravelingSalesmanCreate(TraderDescription);
end 
