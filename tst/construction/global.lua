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
    
    API.ActivateDebugMode(true, false, true, true)
    
    AddGood(Goods.G_Gold,   500, 1)
    AddGood(Goods.G_Wood,    30, 1)
    AddGood(Goods.G_Grain,   25, 1)
    
    -----
    
    
end

-- -------------------------------------------------------------------------- --

--
-- Testfall: Es dürfen keine Bäckereien auf dem Territorium gebaut werden.
--

function TestCaseBanTypeTerritory()
    API.BanTypeAtTerritory(Entities.B_Bakery, 1)
end

function TestCaseBanTypeTerritoryCleanup()
    API.UnBanTypeAtTerritory(Entities.B_Bakery, 1)
end

--
-- Testfall: Es dürfen keine Stadtgebäude auf dem Territorium gebaut werden.
--

function TestCaseBanCategoryTerritory()
    API.BanCategoryAtTerritory(EntityCategories.CityBuilding, 1)
end

function TestCaseBanCategoryTerritoryCleanup()
    API.BanCategoryAtTerritory(EntityCategories.CityBuilding, 1)
end

--
-- Testfall: Es dürfen keine Bäckereien im Bereich gebaut werden.
--

function TestCaseBanTypeArea()
    API.BanTypeInArea(Entities.B_Bakery, "pos", 2000)
end

function TestCaseBanTypeAreaCleanup()
    API.UnBanTypeInArea(Entities.B_Bakery, "pos")
end

--
-- Testfall: Es dürfen keine Stadtgebäude im Bereich gebaut werden.
--

function TestCaseBanCategoryArea()
    API.BanCategoryInArea(EntityCategories.CityBuilding, "pos", 2000)
end

function TestCaseBanCategoryAreaCleanup()
    API.UnBanCategoryInArea(EntityCategories.CityBuilding, "pos")
end

-- -------------------------------------------------------------------------- --

--
-- Testfall: Das Gebäude "bakery" wird vor Abriss geschützt.
--

function TestCaseProtectEntity()
    API.ProtectEntity("bakery")
end

function TestCaseProtectEntityCleanup()
    API.UnprotectEntity("bakery")
end

--
-- Testfall: Alle Bäckereien werden vor dem Abriss geschützt.
--

function TestCaseProtectType()
    API.ProtectEntityType(Entities.B_Bakery)
end

function TestCaseProtectTypeCleanup()
    API.UnprotectEntityType(Entities.B_Bakery)
end

--
-- Testfall: Alle Stadtgebädue werden vor dem Abriss geschützt.
--

function TestCaseProtectCategory()
    API.ProtectCategory(EntityCategories.CityBuilding)
end

function TestCaseProtectCategoryCleanup()
    API.UnprotectCategory(EntityCategories.CityBuilding)
end

--
-- Testfall: Alle Gebäude auf dem Territorium 1 werden geschützt.
--

function TestCaseProtectTerritory()
    API.ProtectCategory(1)
end

function TestCaseProtectTerritoryCleanup()
    API.UnprotectCategory(1)
end