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
    
    AddGood(Goods.G_Gold, 99999, 1)
    AddGood(Goods.G_Wood,    60, 1)
end

function TestDestructionBan()
    API.TimeLineStart {
        {
            Time   = 5,
            Action = function()
                API.Note("Die kleine Bäckerei kann nicht abgerissen werden!");
                TestCaseProtectEntity();
            end
        },
        {
            Time   = 35,
            Action = function()
                API.Note("Keine Bäckerei kann nicht abgerissen werden!");
                TestCaseProtectEntityCleanup();
                TestCaseProtectType();
            end
        },
        {
            Time   = 65,
            Action = function()
                API.Note("Kein Stadtgebäude kann abgerissen werden!");
                TestCaseProtectTypeCleanup();
                TestCaseProtectCategory();
            end
        },
        {
            Time   = 95,
            Action = function()
                API.Note("Auf dem Territorium kann nichts abgerissen werden!");
                TestCaseProtectCategoryCleanup();
                TestCaseProtectTerritory();
            end
        },
        {
            Time   = 125,
            Action = function()
                API.Note("Test beendet!");
                TestCaseProtectTerritoryCleanup();
            end
        }
    }
end

function TestConstructionBan()
    API.TimeLineStart {
        {
            Time   = 5,
            Action = function()
                API.Note("Es können keine Bäckereien in der Stadt gebaut werden!");
                TestCaseBanTypeTerritory();
            end
        },
        {
            Time   = 35,
            Action = function()
                API.Note("Es können keine Stadtgebäude in der Stadt gebaut werden!");
                TestCaseBanTypeTerritoryCleanup();
                TestCaseBanCategoryTerritory();
            end
        },
        {
            Time   = 65,
            Action = function()
                API.Note("Es können keine Bäckereien neben der Burg gebaut werden!");
                TestCaseBanCategoryTerritoryCleanup();
                TestCaseBanTypeArea();
            end
        },
        {
            Time   = 95,
            Action = function()
                API.Note("Es können keine Stadtgebäude neben der Burg gebaut werden!");
                TestCaseBanTypeAreaCleanup();
                TestCaseBanCategoryArea();
            end
        },
        {
            Time   = 125,
            Action = function()
                API.Note("Test beendet!");
                TestCaseBanCategoryAreaCleanup();
            end
        }
    }
end

-- -------------------------------------------------------------------------- --

--
-- Testfall: Es dürfen keine Bäckereien auf dem Territorium gebaut werden.
--

function TestCaseBanTypeTerritory()
    API.BanTypeAtTerritory(Entities.B_Bakery, 1)
end

function TestCaseBanTypeTerritoryCleanup()
    API.UnbanTypeAtTerritory(Entities.B_Bakery, 1)
end

--
-- Testfall: Es dürfen keine Stadtgebäude auf dem Territorium gebaut werden.
--

function TestCaseBanCategoryTerritory()
    API.BanCategoryAtTerritory(EntityCategories.CityBuilding, 1)
end

function TestCaseBanCategoryTerritoryCleanup()
    API.UnbanCategoryAtTerritory(EntityCategories.CityBuilding, 1)
end

--
-- Testfall: Es dürfen keine Bäckereien im Bereich gebaut werden.
--

function TestCaseBanTypeArea()
    API.BanTypeInArea(Entities.B_Bakery, "pos", 5000)
end

function TestCaseBanTypeAreaCleanup()
    API.UnbanTypeInArea(Entities.B_Bakery, "pos")
end

--
-- Testfall: Es dürfen keine Stadtgebäude im Bereich gebaut werden.
--

function TestCaseBanCategoryArea()
    API.BanCategoryInArea(EntityCategories.CityBuilding, "pos", 5000)
end

function TestCaseBanCategoryAreaCleanup()
    API.UnbanCategoryInArea(EntityCategories.CityBuilding, "pos")
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
    API.ProtectTerritory(1)
end

function TestCaseProtectTerritoryCleanup()
    API.UnprotectTerritory(1)
end