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
    InitKnightTitleTables();

    if Framework.IsNetworkGame() ~= true then
        Startup_Player()
        Startup_StartGoods()
        Startup_Diplomacy()
    end
    
    API.ActivateDebugMode(true, true, true, true)
end

function TestGetSetOrientation()
    local x,y,z = Logic.EntityGetPos(GetID("start"));
    local ID = Logic.CreateEntity(Entities.U_NPC_Amma_NE, x, y, 0, 8);

    local Settler = new {QSB.EntityProperty, GiveEntityName(ID)};
    API.Note("Base Orientation: " ..Logic.GetEntityOrientation(ID));
    API.Note("Read Orientation: " ..Settler:Orientation());
    local Orientation = Settler:Orientation(180.0);
    API.Note("Base Orientation: " ..Logic.GetEntityOrientation(ID));
    API.Note("Read Orientation: " ..Settler:Orientation());
end

function TestGetSetPlayer()
    local x,y,z = Logic.EntityGetPos(GetID("start"));
    local ID = Logic.CreateEntity(Entities.U_NPC_Amma_NE, x, y, 0, 8);

    local Settler = new {QSB.EntityProperty, GiveEntityName(ID)};
    API.Note("Base Player: " ..Logic.EntityGetPlayer(ID));
    API.Note("Read Player: " ..Settler:PlayerID());
    local Orientation = Settler:PlayerID(7);
    API.Note("Base Player: " ..Logic.EntityGetPlayer(ID));
    API.Note("Read Player: " ..Settler:PlayerID());
end

function TestGetSetHealth()
    local ID = GetID("hero1");
    local Settler = new {QSB.EntityProperty, "hero1"};
    API.Note("Base Player: " ..Logic.GetEntityHealth(ID));
    API.Note("Read Player: " ..Settler:Health());
    Settler:Health(50, true);
    Settler:Heal(100);
    Settler:Hurt(100);
    API.Note("Base Player: " ..Logic.GetEntityHealth(ID));
    API.Note("Read Player: " ..Settler:Health());
end

function TestHurtEntity()
    local x,y,z = Logic.EntityGetPos(GetID("start"));
    local ID = Logic.CreateBattalion(Entities.U_MilitarySword, x, y, 0, 8);

    local Settler = new {QSB.EntityProperty, GiveEntityName(ID)};
    Settler:Hurt(300);
end

function TestGetSetResource()
    local ID = GetID("mine1");
    local Mine = new {QSB.EntityProperty, "mine1"};
    API.Note("Base Orientation: " ..Logic.GetResourceDoodadGoodAmount(ID));
    API.Note("Read Orientation: " ..Mine:Resource());
    Mine:Resource(1000);
    API.Note("Base Orientation: " ..Logic.GetResourceDoodadGoodAmount(ID));
    API.Note("Read Orientation: " ..Mine:Resource());
end

function TestGetMovingDestination()
    local x,y,z = Logic.EntityGetPos(GetID("start"));
    local ID = Logic.CreateEntity(Entities.U_NPC_Amma_NE, x, y, 0, 8);
    local x,y,z = Logic.EntityGetPos(GetID("goal"));
    Logic.MoveSettler(ID, x, y);

    local Settler = new {QSB.EntityProperty, GiveEntityName(ID)};
    local Target  = Settler:GetDestination();

    API.Note(string.format("Real Postion: (%f; %f)", x, y));
    API.Note(string.format("Read Positon: (%f; %f)", Target.X, Target.Y));
end

function TestGetSetBurning()
    local ID = Logic.GetHeadquarters(1);
    local Building = new {QSB.EntityProperty, GiveEntityName(ID)};

    API.Note("Base Burning: " ..tostring(Logic.IsBurning(ID)));
    API.Note("Read Burning: " ..tostring(Building:Burning()));
    Building:Burning(50)
    API.Note("Base Burning: " ..tostring(Logic.IsBurning(ID)));
    API.Note("Read Burning: " ..tostring(Building:Burning()));
end

function TestGetSetVisible()
    local x,y,z = Logic.EntityGetPos(GetID("start"));
    local ID = Logic.CreateEntity(Entities.U_NPC_Amma_NE, x, y, 0, 8);

    local Settler = new {QSB.EntityProperty, GiveEntityName(ID)};
    local Target  = Settler:GetDestination();

    API.Note("Visible: " ..tostring(Settler:Visible()));
    Settler:Visible(false);
    API.Note("Visible: " ..tostring(Settler:Visible()));
end

function TestGetSetIll()
    local Worker = {Logic.GetPlayerEntitiesInCategory(1, EntityCategories.Worker)};
    local Settler = new {QSB.EntityProperty, GiveEntityName(Worker[1])};
    API.Note("Ill: " ..tostring(Settler:Ill()));
    Settler:Ill(true);
    API.Note("Ill: " ..tostring(Settler:Ill()));
end

function TestCountSoldiers()
    local x,y,z = Logic.EntityGetPos(GetID("start"));
    local ID = Logic.CreateBattalion(Entities.U_MilitarySword, x, y, 0, 1);

    local Settler = new {QSB.EntityProperty, GiveEntityName(ID)};
    API.Note("Soldiers: " ..Settler:CountSoldiers(10));
end

function TestGetCategory()
    local x,y,z = Logic.EntityGetPos(GetID("start"));
    local ID = Logic.CreateBattalion(Entities.U_MilitarySword, x, y, 0, 1);

    local Settler = new {QSB.EntityProperty, GiveEntityName(ID)};
    local Categories = Settler:GetGategories();
    API.Note("Categories: " ..#Categories);
    API.Note("Leader: " ..tostring(Settler:InGategory(EntityCategories.Leader)));
end