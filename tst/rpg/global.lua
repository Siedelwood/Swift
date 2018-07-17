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
    -- Laden der Bibliothek
    local MapType, Campaign = Framework.GetCurrentMapTypeAndCampaignName();
    local MapFolder = (MapType == 1 and "Development") or "ExternalMap";
    local MapName = Framework.GetCurrentMapName();
    Script.Load("Maps/"..MapFolder.."/"..MapName.."/QuestSystemBehavior.lua");
    Script.Load("E:/Repositories/symfonia/qsb/lua/external/externalroleplayinggame/source.lua");

    -- Läd die Module
    API.Install();
    InitKnightTitleTables();

    if Framework.IsNetworkGame() ~= true then
        Startup_Player()
        Startup_StartGoods()
        Startup_Diplomacy()
    end
    
    API.ActivateDebugMode(true, true, true, true);
    
    TestArmory()
end

---
-- Der Held kann in der Waffenkammer die angelegte Waffe austauschen.
--
function TestArmory()
    CreateObject {
        Name = "armory",
        Callback = function()
            ExternalRolePlayingGame.Global:OpenArmoryDialog("meredith", "armory");
        end
    }

    -- Testwaffen --
    
    local Weapon1 = ExternalRolePlayingGame.Item:New("Weapon1");
    Weapon1:SetCaption("Weapon 1");
    Weapon1:SetDescription("This is weapon 1!");
    Weapon1:AddCategory(ExternalRolePlayingGame.ItemCategories.Equipment);
    Weapon1:AddCategory(ExternalRolePlayingGame.ItemCategories.Weapon);

    local Weapon2 = ExternalRolePlayingGame.Item:New("Weapon2");
    Weapon2:SetCaption("Weapon 2");
    Weapon2:SetDescription("This is weapon 2!");
    Weapon2:AddCategory(ExternalRolePlayingGame.ItemCategories.Equipment);
    Weapon2:AddCategory(ExternalRolePlayingGame.ItemCategories.Weapon);

    -- Hero --

    local Meredith = ExternalRolePlayingGame.Hero:New("meredith");
    local Inventory = ExternalRolePlayingGame.Inventory:New("Inventory_Meredith", Meredith);
    Meredith.Inventory = Inventory;

    Inventory:Insert("Weapon1", 4);
    Inventory:Insert("Weapon2", 2);
    Meredith:EquipWeapon("Weapon2");

    -- Ability --

    local Dummy1 = ExternalRolePlayingGame.Ability:New("Dummy1");
    Dummy1.RechargeTime = 2*60;
    Dummy1:SetCaption("Bla");
    Dummy1:SetDescription("Bla Bla Bla");
    Dummy1:SetIcon({1,1});
    Dummy1.Condition = function()
        return false;
    end
    Dummy1.Action = function()
        API.Note("Ability used!")
    end
    Meredith.Ability = Dummy1;
end

---
-- Der Held bekommt mehrere verschiedene Gegenstände ins Inventar gelegt.
-- Einige davon werden angelegt und ihre Menge im Inventar reduziert. Über
-- E kann zwischen Fähigkeit und Gürtelgegenstand gewechselt werden.
--
function TestEquipment()
    -- Testwaffen --
    
    local Weapon1 = ExternalRolePlayingGame.Item:New("Weapon1");
    Weapon1:SetCaption("Weapon 1");
    Weapon1:SetDescription("This is weapon 1!");
    Weapon1:AddCategory(ExternalRolePlayingGame.ItemCategories.Equipment);
    Weapon1:AddCategory(ExternalRolePlayingGame.ItemCategories.Weapon);

    local Weapon2 = ExternalRolePlayingGame.Item:New("Weapon2");
    Weapon2:SetCaption("Weapon 2");
    Weapon2:SetDescription("This is weapon 2!");
    Weapon2:AddCategory(ExternalRolePlayingGame.ItemCategories.Equipment);
    Weapon2:AddCategory(ExternalRolePlayingGame.ItemCategories.Weapon);

    -- Testrüstungen --

    local Armor1 = ExternalRolePlayingGame.Item:New("Armor1");
    Armor1:SetCaption("Armor 1");
    Armor1:SetDescription("This is armor 1!");
    Armor1:AddCategory(ExternalRolePlayingGame.ItemCategories.Equipment);
    Armor1:AddCategory(ExternalRolePlayingGame.ItemCategories.Armor);
    
    local Armor2 = ExternalRolePlayingGame.Item:New("Armor2");
    Armor2:SetCaption("Armor 2");
    Armor2:SetDescription("This is armor 2!");
    Armor2:AddCategory(ExternalRolePlayingGame.ItemCategories.Equipment);
    Armor2:AddCategory(ExternalRolePlayingGame.ItemCategories.Armor);

    -- Testschmuck --

    local Jewellery1 = ExternalRolePlayingGame.Item:New("Jewellery1");
    Jewellery1:SetCaption("Jewellery 1");
    Jewellery1:SetDescription("This is jewellery 1!");
    Jewellery1:AddCategory(ExternalRolePlayingGame.ItemCategories.Equipment);
    Jewellery1:AddCategory(ExternalRolePlayingGame.ItemCategories.Jewellery);
    
    local Jewellery2 = ExternalRolePlayingGame.Item:New("Jewellery2");
    Jewellery2:SetCaption("Jewellery 2");
    Jewellery2:SetDescription("This is jewellery 2!");
    Jewellery2:AddCategory(ExternalRolePlayingGame.ItemCategories.Equipment);
    Jewellery2:AddCategory(ExternalRolePlayingGame.ItemCategories.Jewellery);

    -- Testgebrauchsgegenstände --

    local Belt1 = ExternalRolePlayingGame.Item:New("Belt1");
    Belt1:SetCaption("Belt 1");
    Belt1:SetDescription("This is belt 1!");
    Belt1:AddCategory(ExternalRolePlayingGame.ItemCategories.Equipment);
    Belt1:AddCategory(ExternalRolePlayingGame.ItemCategories.Utensil);
    
    local Belt2 = ExternalRolePlayingGame.Item:New("Belt2");
    Belt2:SetCaption("Belt 2");
    Belt2:SetDescription("This is belt 2!");
    Belt2:AddCategory(ExternalRolePlayingGame.ItemCategories.Equipment);
    Belt2:AddCategory(ExternalRolePlayingGame.ItemCategories.Utensil);
    Belt2.OnConsumed = function() API.Note("foo") end
    
    -- Hero --

    local Meredith = ExternalRolePlayingGame.Hero:New("meredith");
    local Inventory = ExternalRolePlayingGame.Inventory:New("Inventory_Meredith", Meredith);
    Meredith.Inventory = Inventory;

    Inventory:Insert("Weapon1", 4);
    Inventory:Insert("Weapon2", 2);
    Inventory:Insert("Armor1", 1);
    Inventory:Insert("Armor2", 3);
    Inventory:Insert("Jewellery1", 2);
    Inventory:Insert("Jewellery2", 7);
    Inventory:Insert("Belt1", 4);
    Inventory:Insert("Belt2", 1);

    -- Equip --

    Meredith:EquipWeapon("Weapon2");
    Meredith:EquipArmor("Armor2");
    Meredith:EquipJewellery("Jewellery1");
    Meredith:EquipBelt("Belt2");

    -- Ability --

    local Dummy1 = ExternalRolePlayingGame.Ability:New("Dummy1");
    Dummy1.RechargeTime = 2*60;
    Dummy1:SetCaption("Bla");
    Dummy1:SetDescription("Bla Bla Bla");
    Dummy1:SetIcon({1,1});
    Dummy1.Condition = function()
        return false;
    end
    Dummy1.Action = function()
        API.Note("Ability used!")
    end
    Meredith.Ability = Dummy1;
end

---
-- Test Case: Spezialfähigkeit
--
-- Die Spezialfähigkeit wird ausgelöst und rediziert die Action Points auf 0.
-- Die Erholung hängt vom Magielevel ab.
--
function TestUserAbility()
    local Dummy1 = ExternalRolePlayingGame.Ability:New("Dummy1");
    Dummy1.RechargeTime = 2*60;
    Dummy1:SetCaption("Bla");
    Dummy1:SetDescription("Bla Bla Bla");
    Dummy1:SetIcon({1,1});
    Dummy1.Condition = function()
        return false;
    end
    Dummy1.Action = function()
        API.Note("Ability used!")
    end
    
    local Meredith = ExternalRolePlayingGame.Hero:New("meredith");
    Meredith:SetCaption("Meredith");
    Meredith.Ability = Dummy1;
end

---
-- Test Case: EXP und Fortbildung
--
-- Der Held erhält Erfahrung und kann diese für verbesserte Statuswerte
-- ausgeben. Die verbesserten Statuswerte beeinflussen seine Effektivität
-- im Kampf.
--
function TestLevelUp()
    local Meredith = ExternalRolePlayingGame.Hero:New("meredith");
    Meredith:SetCaption("Meredith");
    Meredith.StrengthCosts = -1;

    API.RpgConfig_UseAutoLevel(false)
    API.RpgConfig_UseLevelUpByPromotion(false)
    API.RpgHelper_AddPlayerExperience(1, 1000)
end

--
-- Test Case: Event auslösen / Tugend und Laster
--
-- Events müssen durch ihre Trigger ausgelöst werden. Dabei werden sie dann
-- für alle Helden oder eine Auswahl aller Helden ausgeführt.
--
-- Events können auch als Tugend oder Laster an einen Helden angebunden
-- werden. Dabei kann das Event dann alle Helden in der übegebenen Liste
-- betreffen oder nur den Besitzer.
--
function TestEvets()
    local Event1 = ExternalRolePlayingGame.Event:New("Dummy1");
    Event1:SetCaption("Bla");
    Event1:SetDescription("Bla Bla Bla");
    Event1.Action = function(_Event, _Hero, _Trigger, ...)
        API.Note(_Event.Identifier .. ":" .. _Trigger .. " triggered!");
        API.Note("Hero: " .. _Hero.ScriptName);
        API.Note("Arguments: " .. #arg);
    end
    Event1:AddTrigger("Trigger_BuildingUpgradeFinished");
    
    local Event2 = ExternalRolePlayingGame.Event:New("Dummy2");
    Event2:SetCaption("Bla");
    Event2:SetDescription("Bla Bla Bla");
    Event2.Action = function(_Event, _Hero, _Trigger, ...)
        API.Note(_Event.Identifier .. ":" .. _Trigger .. " triggered!");
        API.Note("Hero: " .. _Hero.ScriptName);
        API.Note("Arguments: " .. #arg);
    end
    Event1:AddTrigger("Trigger_BuildingUpgradeFinished");
    
    local Event3 = ExternalRolePlayingGame.Event:New("Dummy3");
    Event3:SetCaption("Bla");
    Event3:SetDescription("Bla Bla Bla");
    Event3.Action = function(_Event, _Hero, _Trigger, ...)
        API.Note(_Event.Identifier .. ":" .. _Trigger .. " triggered!");
        API.Note("Hero: " .. _Hero.ScriptName);
        API.Note("Arguments: " .. #arg);
    end
    Event1:AddTrigger("Trigger_BuildingUpgradeFinished");
    
    local Meredith = ExternalRolePlayingGame.Hero:New("meredith");
    Meredith:ActivateVirtue("Dummy1", true);
    Meredith:ActivateVice("Dummy2", true);
    Meredith:ActivateVice("Dummy3", true);
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
    local Dummy1 = ExternalRolePlayingGame.Item:New("Dummy1");
    Dummy1:SetCaption("Dummy 1");
    Dummy1:SetDescription("This ist Dummy 1!");
    
    local Dummy2 = ExternalRolePlayingGame.Item:New("Dummy2");
    Dummy2:SetCaption("Dummy 2");
    Dummy2:SetDescription("This ist Dummy 2!");
    
    local Dummy3 = ExternalRolePlayingGame.Item:New("Dummy3");
    Dummy3:SetCaption("Dummy 3");
    Dummy3:SetDescription("This ist Dummy 3!");
    
    local Dummy4 = ExternalRolePlayingGame.Item:New("Dummy4");
    Dummy4:SetCaption("Dummy 4");
    Dummy4:SetDescription("This ist Dummy 4!");
    Dummy4:AddCategory(ExternalRolePlayingGame.ItemCategories.Equipment);
    
    
    local Meredith = ExternalRolePlayingGame.Hero:New("meredith");
    local Inventory = ExternalRolePlayingGame.Inventory:New("Inventory_Meredith", Meredith);
    Meredith.Inventory = Inventory;
    
    Inventory:Insert("Dummy1", 10);
    Inventory:Insert("Dummy2", 3);
    Inventory:Insert("Dummy3", 7);
    Inventory:Insert("Dummy4", 1);
    
    Inventory:Equip("Dummy4");
end