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
    Script.Load("E:/Repositories/symfonia/test/requirment/qsb.lua")
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
    
    AICore.HideEntityFromAI(2, GetID("christian"), true)
    
    -----
    
    
end

function RunTests()
    local Index = 1;
    while (_G["ApiTest" ..Index] ~= nil) do
        _G["ApiTest" ..Index]();
        Index = Index +1;
    end
end

function ApiTest1()
    -- 6 Raubtiere müssen gefunden werden. TODO
    local Result = API.GetEntitiesOfCategoriesInTerritories(0, EntityCategories.AttackableAnimal, {1, 2});
    assert(#Result ~= 6, "Fehlschlag: Anzahl Raubtiere stimmt nicht!");
    
    -- 2 Helden müssen gefunden werden.
    local Result = API.GetEntitiesOfCategoriesInTerritories({1, 2}, EntityCategories.Hero, {1, 2});
    assert(#Result ~= 2, "Fehlschlag: Anzahl Helden stimmt nicht!");
    
    API.Note("API.GetEntitiesOfCategoriesInTerritories getestet");
end

function ApiTest2()
    -- 6 benannte Entities finden TODO
    local Result = API.GetEntitiesByPrefix("NamedEntity");
    assert(#Result ~= 6, "Fehlschlag: Anzahl Entities stimmt nicht!");
    
    API.Note("API.GetEntitiesByPrefix getestet");
end

function ApiTest3()
    -- Füllmenge muss 500 sein TODO
    API.SetResourceAmount("mine", 500, 250);
    assert(Logic.GetResourceDoodadGoodAmount(GetID("mine")) ~= 500, "Fehlschlag: Rofstoffzahl falsch!");
    
    API.Note("API.GetResourceDoodadGoodAmount getestet");
end

function ApiTest4()
    -- Leader des Battalion bestimmen TODO
    local Leader          = GetID("TestBattalion");
    local Soldier         = {Logic.GetSoldiersAttachedToLeader(Leader)};
    local LeaderBySoldier = API.GetLeaderBySoldier(Soldier[2]);
    assert(Leader == LeaderBySoldier, "Fehlschlag: Leader-ID ist falsch!");
    API.Note("API.GetLeaderBySoldier getestet");
end

function ApiTest5()
    -- Ausrichtung ermitteln TODO
    local Position = GetPosition("TestPosition");
    local EntityID = Logic.CreateEntity(Entities.U_Thief, Position.X, Position.Y, 0, 1);
    
    local Orientation = API.GetOrientation(EntityID)
    assert(Orientation == 0, "Fehlschlag: Ausrichtung ist falsch!");
    API.Note("API.GetOrientation getestet");
end