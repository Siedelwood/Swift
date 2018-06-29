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
    
    API.ActivateDebugMode(true, true, true, true);
    
    local Meredith = AddOnRolePlayingGame.Hero:New("meredith");
    local Inventory = AddOnRolePlayingGame.Inventory:New("Inventory_Meredith", Meredith);
    Inventory.Owner = Meredith;
    Meredith.Inventory = Inventory;
end

--
-- Test Case: Event auslösen
--
-- Events müssen durch ihre Trigger ausgelöst werden. Dabei werden sie dann
-- für alle Helden oder eine Auswahl aller Helden ausgeführt.
--
function TestEvets()
    local Event1 = AddOnRolePlayingGame.Event:New("Dummy1");
    Event1.Action = function(_Event, _Hero, _Trigger, ...)
        API.Note(_Event.Identifier .. ":" .. _Trigger .. " triggered!");
        API.Note("Hero: " .. _Hero.ScriptName);
        API.Note("Arguments: " .. #arg);
    end
    Event1:AddTrigger("Trigger_BuildingUpgradeFinished");
    
    local Event2 = AddOnRolePlayingGame.Event:New("Dummy2");
    Event2.Action = function(_Event, _Hero, _Trigger, ...)
        API.Note(_Event.Identifier .. ":" .. _Trigger .. " triggered!");
        API.Note("Hero: " .. _Hero.ScriptName);
        API.Note("Arguments: " .. #arg);
    end
    Event2:AddTrigger("Trigger_SermonFinished");
    Event2:AddTrigger("Trigger_EntityHurt");
    
    local Meredith = AddOnRolePlayingGame.Hero:New("meredith");
end

--
-- Test Case: Rucksack/Ausrüstung anzeigen
--
-- Erstellt einige Testgegenstände und einen Helden um die Anzeige der
-- Gegenstände zu testen. Es soll zwischen Rucksack und Ausrüstung
-- umhergesprungen werden können.
--
-- Wenn ein Gegenstand ausgerüstet wird, wird die Menge der Gegenstände
-- dieses Typs um 1 reduziert. Ist schon ein Gegenstand ausgerüstet, wird
-- der wieder ins Inventar zurückgelegt.
--
function TestInventoryListing()
    local Dummy1 = AddOnRolePlayingGame.Item:New("Dummy1");
    Dummy1:SetCaption("Dummy 1");
    Dummy1:SetDescription("This ist Dummy 1!");
    
    local Dummy2 = AddOnRolePlayingGame.Item:New("Dummy2");
    Dummy2:SetCaption("Dummy 2");
    Dummy2:SetDescription("This ist Dummy 2!");
    
    local Dummy3 = AddOnRolePlayingGame.Item:New("Dummy3");
    Dummy3:SetCaption("Dummy 3");
    Dummy3:SetDescription("This ist Dummy 3!");
    
    local Dummy4 = AddOnRolePlayingGame.Item:New("Dummy4");
    Dummy4:SetCaption("Dummy 4");
    Dummy4:SetDescription("This ist Dummy 4!");
    Dummy4:AddCategory(AddOnRolePlayingGame.ItemCategories.Equipment);
    
    
    local Meredith = AddOnRolePlayingGame.Hero:New("meredith");
    local Inventory = AddOnRolePlayingGame.Inventory:New("Inventory_Meredith", Meredith);
    Inventory.Owner = Meredith;
    Meredith.Inventory = Inventory;
    
    Inventory:Insert("Dummy1", 10);
    Inventory:Insert("Dummy2", 3);
    Inventory:Insert("Dummy3", 7);
    Inventory:Insert("Dummy4", 1);
    
    Inventory:Equip("Dummy4");
end