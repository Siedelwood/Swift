--[[
Swift_2_ObjectInteraction/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleObjectInteraction = {
    Properties = {
        Name = "ModuleObjectInteraction",
    },

    Global = {
        SlaveSequence = 0,
    };
    Local  = {};
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        Text = {}
    };
};

QSB.IO = {
    LastHeroEntityID = 0,
    LastObjectEntityID = 0
};

-- Global Script ------------------------------------------------------------ --

function ModuleObjectInteraction.Global:OnGameStart()
    QSB.ScriptEvents.ObjectClicked = API.RegisterScriptEvent("Event_ObjectClicked");
    QSB.ScriptEvents.ObjectInteraction = API.RegisterScriptEvent("Event_ObjectInteraction");
    QSB.ScriptEvents.ObjectReset = API.RegisterScriptEvent("Event_ObjectReset");
    QSB.ScriptEvents.ObjectDelete = API.RegisterScriptEvent("Event_ObjectDelete");

    IO = {};
    IO_UserDefindedNames = {};
    IO_SlaveToMaster = {};
    IO_SlaveState = {};

    self:OverrideObjectInteraction();
    self:StartObjectDestructionController();
    self:StartObjectConditionController();
    self:CreateDefaultObjectNames();
end

function ModuleObjectInteraction.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.ObjectInteraction then
        self:OnObjectInteraction(arg[1], arg[2], arg[3]);
    elseif _ID == QSB.ScriptEvents.ChatClosed then
        if Swift:IsProcessDebugCommands() then
            self:ProcessChatInput(arg[1]);
        end
    end
end

function ModuleObjectInteraction.Global:OnObjectInteraction(_ScriptName, _KnightID, _PlayerID)
    QSB.IO.LastObjectEntityID = GetID(_ScriptName);
    QSB.IO.LastHeroEntityID = _KnightID;

    if IO_SlaveToMaster[_ScriptName] then
        _ScriptName = IO_SlaveToMaster[_ScriptName];
    end
    if IO[_ScriptName] then
        IO[_ScriptName].IsUsed = true;
        if IO[_ScriptName].Action then
            IO[_ScriptName]:Action(_KnightID, _PlayerID);
        end
    end
    -- Avoid reference bug
    Logic.ExecuteInLuaLocalState("ModuleObjectInteraction.Local:OverrideReferenceTables()");
end

function ModuleObjectInteraction.Global:CreateObject(_Description)
    local ID = GetID(_Description.Name);
    if ID == 0 then
        return;
    end
    self:DestroyObject(_Description.Name);

    local TypeName = Logic.GetEntityTypeName(Logic.GetEntityType(ID));
    if not TypeName:find("^I_X_") then
        self:CreateSlaveObject(_Description);
    end

    _Description.IsActive = true;
    _Description.IsUsed = false;
    IO[_Description.Name] = _Description;
    self:SetupObject(_Description);
    -- Avoid reference bug
    Logic.ExecuteInLuaLocalState("ModuleObjectInteraction.Local:OverrideReferenceTables()");
    return _Description;
end

function ModuleObjectInteraction.Global:DestroyObject(_ScriptName)
    if not IO[_ScriptName] then
        return;
    end
    if IO[_ScriptName].Slave then
        IO_SlaveToMaster[IO[_ScriptName].Slave] = nil;
        IO_SlaveState[IO[_ScriptName].Slave] = nil;
        DestroyEntity(IO[_ScriptName].Slave);
    end
    self:SetObjectAvailability(_ScriptName, 2);
    API.SendScriptEvent(QSB.ScriptEvents.ObjectDelete, _ScriptName);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.ObjectDelete, "%s")]],
        _ScriptName
    ));
    IO[_ScriptName] = nil;
    -- Avoid reference bug
    Logic.ExecuteInLuaLocalState("ModuleObjectInteraction.Local:OverrideReferenceTables()");
end

function ModuleObjectInteraction.Global:CreateSlaveObject(_Object)
    local Name;
    for k, v in pairs(IO_SlaveToMaster) do
        if v == _Object.Name and IsExisting(k) then
            Name = k;
        end
    end
    if Name == nil then
        self.SlaveSequence = self.SlaveSequence +1;
        Name = "QSB_SlaveObject_" ..self.SlaveSequence;
    end

    local SlaveID = GetID(Name);
    if not IsExisting(Name) then
        local x,y,z = Logic.EntityGetPos(GetID(_Object.Name));
        SlaveID = Logic.CreateEntity(Entities.I_X_DragonBoatWreckage, x, y, 0, 0);
        Logic.SetModel(SlaveID, Models.Effects_E_Mosquitos);
        Logic.SetEntityName(SlaveID, Name);
        IO_SlaveToMaster[Name] = _Object.Name;
        _Object.Slave = Name;
    end
    IO_SlaveState[Name] = 1;
    return SlaveID;
end

function ModuleObjectInteraction.Global:SetupObject(_Object)
    local ID = GetID((_Object.Slave and _Object.Slave) or _Object.Name);
    Logic.InteractiveObjectClearCosts(ID);
    Logic.InteractiveObjectClearRewards(ID);
    Logic.InteractiveObjectSetInteractionDistance(ID,_Object.Distance);
    Logic.InteractiveObjectSetTimeToOpen(ID,_Object.Waittime);
    Logic.InteractiveObjectSetRewardResourceCartType(ID, Entities.U_ResourceMerchant);
    Logic.InteractiveObjectSetRewardGoldCartType(ID, Entities.U_GoldCart);
    Logic.InteractiveObjectSetCostResourceCartType(ID, Entities.U_ResourceMerchant);
    Logic.InteractiveObjectSetCostGoldCartType(ID, Entities.U_GoldCart);
    if _Object.Reward then
        Logic.InteractiveObjectAddRewards(ID, _Object.Reward[1], _Object.Reward[2]);
    end
    if _Object.Costs and _Object.Costs[1] then
        Logic.InteractiveObjectAddCosts(ID, _Object.Costs[1], _Object.Costs[2]);
    end
    if _Object.Costs and _Object.Costs[3] then
        Logic.InteractiveObjectAddCosts(ID, _Object.Costs[3], _Object.Costs[4]);
    end
    table.insert(HiddenTreasures, ID);
    API.InteractiveObjectActivate(Logic.GetEntityName(ID), _Object.State or 0);
end

function ModuleObjectInteraction.Global:ResetObject(_SkriptName)
    local ID = GetID((IO[_SkriptName].Slave and IO[_SkriptName].Slave) or _SkriptName);
    RemoveInteractiveObjectFromOpenedList(ID);
    table.insert(HiddenTreasures, ID);
    Logic.InteractiveObjectSetAvailability(ID, true);
    self:SetObjectAvailability(ID, IO[_SkriptName].State or 0);
    IO[_SkriptName].IsUsed = false;
    IO[_SkriptName].IsActive = true;

    API.SendScriptEvent(QSB.ScriptEvents.ObjectReset, _SkriptName);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.ObjectReset, "%s")]],
        _SkriptName
    ));
end

function ModuleObjectInteraction.Global:SetObjectAvailability(_ScriptName, _State, ...)
    arg = ((not arg or #arg == 0) and {1, 2, 3, 4, 5, 6, 7, 8}) or arg;
    for i= 1, #arg, 1 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), arg[i], _State);
    end
end

function ModuleObjectInteraction.Global:CreateDefaultObjectNames()
    IO_UserDefindedNames["D_X_ChestClosed"]             = {de = "Schatztruhe", en = "Treasure Chest", fr = "Coffre au trésor"};
    IO_UserDefindedNames["D_X_ChestOpenEmpty"]          = {de = "Leere Truhe", en = "Empty Chest", fr = "Coffre vide"};
end

function ModuleObjectInteraction.Global:OverrideObjectInteraction()
    GameCallback_OnObjectInteraction = function(_EntityID, _PlayerID)
        OnInteractiveObjectOpened(_EntityID, _PlayerID);
        OnTreasureFound(_EntityID, _PlayerID);

        local ScriptName = Logic.GetEntityName(_EntityID);
        if IO_SlaveToMaster[ScriptName] then
            ScriptName = IO_SlaveToMaster[ScriptName];
        end
        local KnightIDs = {};
        Logic.GetKnights(_PlayerID, KnightIDs);
        local KnightID = API.GetClosestToTarget(_EntityID, KnightIDs);
        API.SendScriptEvent(QSB.ScriptEvents.ObjectInteraction, ScriptName, KnightID, _PlayerID);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.ObjectInteraction, "%s", %d, %d)]],
            ScriptName,
            KnightID,
            _PlayerID
        ));
    end

    QuestTemplate.AreObjectsActivated = function(self, _ObjectList)
        for i=1, _ObjectList[0] do
            if not _ObjectList[-i] then
                _ObjectList[-i] = GetID(_ObjectList[i]);
            end
            local EntityName = Logic.GetEntityName(_ObjectList[-i]);
            if IO_SlaveToMaster[EntityName] then
                EntityName = IO_SlaveToMaster[EntityName];
            end

            if IO[EntityName] then
                if IO[EntityName].IsUsed ~= true then
                    return false;
                end
            elseif Logic.IsInteractiveObject(_ObjectList[-i]) then
                if not IsInteractiveObjectOpen(_ObjectList[-i]) then
                    return false;
                end
            end
        end
        return true;
    end
end

function ModuleObjectInteraction.Global:ProcessChatInput(_Text)
    local Commands = ModuleInputOutputCore.Shared:CommandTokenizer(_Text);
    for i= 1, #Commands, 1 do
        if Commands[1] == "enableobject" then
            local State = (Commands[3] and tonumber(Commands[3])) or nil;
            local PlayerID = (Commands[4] and tonumber(Commands[4])) or nil;
            if not IsExisting(Commands[2]) then
                error("object " ..Commands[2].. " does not exist!");
                return;
            end
            API.InteractiveObjectActivate(Commands[2], State, PlayerID);
            info("activated object " ..Commands[2].. ".");
        elseif Commands[1] == "disableobject" then
            local PlayerID = (Commands[3] and tonumber(Commands[3])) or nil;
            if not IsExisting(Commands[2]) then
                error("object " ..Commands[2].. " does not exist!");
                return;
            end
            API.InteractiveObjectDeactivate(Commands[2], PlayerID);
            info("deactivated object " ..Commands[2].. ".");
        elseif Commands[1] == "initobject" then
            if not IsExisting(Commands[2]) then
                error("object " ..Commands[2].. " does not exist!");
                return;
            end
            API.SetupObject({
                Name     = Commands[2],
                Waittime = 0,
                State    = 0
            });
            info("quick initalization of object " ..Commands[2].. ".");
        end
    end
end

function ModuleObjectInteraction.Global:StartObjectDestructionController()
    API.StartJobByEventType(Events.LOGIC_EVENT_ENTITY_DESTROYED, function()
        local DestryoedEntityID = Event.GetEntityID();
        local SlaveName  = Logic.GetEntityName(DestryoedEntityID);
        local MasterName = IO_SlaveToMaster[SlaveName];
        if SlaveName and MasterName then
            local Object = IO[MasterName];
            if not Object then
                return;
            end
            info("slave " ..SlaveName.. " of master " ..MasterName.. " has been deleted!");
            info("try to create new slave...");
            IO_SlaveToMaster[SlaveName] = nil;
            local SlaveID = ModuleObjectInteraction.Global:CreateSlaveObject(Object);
            if not IsExisting(SlaveID) then
                error("failed to create slave!");
                return;
            end
            ModuleObjectInteraction.Global:SetupObject(Object);
            if Object.IsUsed == true or (IO_SlaveState[SlaveName] and IO_SlaveState[SlaveName] == 0) then
                API.InteractiveObjectDeactivate(Object.Slave);
            end
            info("new slave created for master " ..MasterName.. ".");
        end
    end);
end

function ModuleObjectInteraction.Global:StartObjectConditionController()
    API.StartJobByEventType(Events.LOGIC_EVENT_EVERY_TURN, function()
        for k, v in pairs(IO) do
            if v and not v.IsUsed and v.IsActive then
                IO[k].IsFullfilled = true;
                if IO[k].Condition then
                    local IsFulfulled = v:Condition();
                    IO[k].IsFullfilled = IsFulfulled;
                    -- Avoid reference bug
                    Logic.ExecuteInLuaLocalState(string.format(
                        [[IO["%s"].Condition = %s]],
                        k,
                        tostring(IsFulfulled)
                    ))
                end
            end
        end
    end);
end

-- Local Script ------------------------------------------------------------- --

function ModuleObjectInteraction.Local:OnGameStart()
    QSB.ScriptEvents.ObjectClicked = API.RegisterScriptEvent("Event_ObjectClicked");
    QSB.ScriptEvents.ObjectInteraction = API.RegisterScriptEvent("Event_ObjectInteraction");
    QSB.ScriptEvents.ObjectReset = API.RegisterScriptEvent("Event_ObjectReset");
    QSB.ScriptEvents.ObjectDelete = API.RegisterScriptEvent("Event_ObjectDelete");

    self:OverrideReferenceTables();
    self:OverrideGameFunctions();
end

function ModuleObjectInteraction.Local:OnEvent(_ID, _Event, _ScriptName, _KnightID, _PlayerID)
    if _ID == QSB.ScriptEvents.ObjectInteraction then
        QSB.IO.LastObjectEntityID = GetID(_ScriptName);
        QSB.IO.LastHeroEntityID = _KnightID;
    end
end

function ModuleObjectInteraction.Local:OverrideGameFunctions()
    g_CurrentDisplayedQuestID = 0;

    GUI_Interaction.InteractiveObjectClicked_Orig_ModuleObjectInteraction = GUI_Interaction.InteractiveObjectClicked;
    GUI_Interaction.InteractiveObjectClicked = function()
        local i = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()));
        local EntityID = g_Interaction.ActiveObjectsOnScreen[i];
        local PlayerID = GUI.GetPlayerID();
        if not EntityID then
            return;
        end
        local ScriptName = Logic.GetEntityName(EntityID);
        if IO_SlaveToMaster[ScriptName] then
            ScriptName = IO_SlaveToMaster[ScriptName];
        end
        if IO[ScriptName] then
            if not IO[ScriptName].IsFullfilled then
                local Text = XGUIEng.GetStringTableText("UI_ButtonDisabled/PromoteKnight");
                if IO[ScriptName].ConditionInfo then
                    Text = API.ConvertPlaceholders(API.Localize(IO[ScriptName].ConditionInfo));
                end
                Message(Text);
                return;
            end
            if type(IO[ScriptName].Costs) == "table" and #IO[ScriptName].Costs ~= 0 then
                local CathedralID = Logic.GetCathedral(PlayerID);
                local CastleID    = Logic.GetHeadquarters(PlayerID);
                if CathedralID == nil or CathedralID == 0 or CastleID == nil or CastleID == 0 then
                    API.Note("DEBUG: Player needs special buildings when using activation costs!");
                    return;
                end
            end
        end
        GUI_Interaction.InteractiveObjectClicked_Orig_ModuleObjectInteraction();

        -- Send additional click event
        local KnightIDs = {};
        Logic.GetKnights(PlayerID, KnightIDs);
        local KnightID = API.GetClosestToTarget(EntityID, KnightIDs);
        GUI.SendScriptCommand(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.ObjectClicked, "%s", %d, %d)]],
            ScriptName,
            KnightID,
            PlayerID
        ));
        API.SendScriptEvent(QSB.ScriptEvents.ObjectClicked, ScriptName, KnightID, PlayerID);
    end

    GUI_Interaction.InteractiveObjectUpdate = function()
        if g_Interaction.ActiveObjects == nil then
            return;
        end
        
        local PlayerID = GUI.GetPlayerID();
        for i = 1, #g_Interaction.ActiveObjects do
            local ObjectID = g_Interaction.ActiveObjects[i];
            local MasterObjectID = ObjectID;
            local ScriptName = Logic.GetEntityName(ObjectID);
            if IO_SlaveToMaster[ScriptName] then
                MasterObjectID = GetID(IO_SlaveToMaster[ScriptName]);
            end
            local X, Y = GUI.GetEntityInfoScreenPosition(MasterObjectID);
            local ScreenSizeX, ScreenSizeY = GUI.GetScreenSize();
            if X ~= 0 and Y ~= 0 and X > -50 and Y > -50 and X < (ScreenSizeX + 50) and Y < (ScreenSizeY + 50) then
                if not table.contains(g_Interaction.ActiveObjectsOnScreen, ObjectID) then
                    table.insert(g_Interaction.ActiveObjectsOnScreen, ObjectID);
                end
            else
                for i = 1, #g_Interaction.ActiveObjectsOnScreen do
                    if g_Interaction.ActiveObjectsOnScreen[i] == ObjectID then
                        table.remove(g_Interaction.ActiveObjectsOnScreen, i);
                    end
                end
            end
        end

        for i = 1, #g_Interaction.ActiveObjectsOnScreen do
            local Widget = "/InGame/Root/Normal/InteractiveObjects/" ..i;
            if XGUIEng.IsWidgetExisting(Widget) == 1 then
                local ObjectID       = g_Interaction.ActiveObjectsOnScreen[i];
                local MasterObjectID = ObjectID;
                local ScriptName     = Logic.GetEntityName(ObjectID);
                if IO_SlaveToMaster[ScriptName] then
                    MasterObjectID = GetID(IO_SlaveToMaster[ScriptName]);
                end
                local EntityType = Logic.GetEntityType(ObjectID);
                local X, Y = GUI.GetEntityInfoScreenPosition(MasterObjectID);
                local WidgetSize = {XGUIEng.GetWidgetScreenSize(Widget)};
                XGUIEng.SetWidgetScreenPosition(Widget, X - (WidgetSize[1]/2), Y - (WidgetSize[2]/2));
                local BaseCosts = {Logic.InteractiveObjectGetCosts(ObjectID)};
                local EffectiveCosts = {Logic.InteractiveObjectGetEffectiveCosts(ObjectID, PlayerID)};
                local IsAvailable = Logic.InteractiveObjectGetAvailability(ObjectID);
                local HasSpace = Logic.InteractiveObjectHasPlayerEnoughSpaceForRewards(ObjectID, PlayerID);
                local Disable = false;
                if BaseCosts[1] ~= nil and EffectiveCosts[1] == nil and IsAvailable == true then
                    Disable = true;
                end
                if HasSpace == false then
                    Disable = true
                end
                if Disable == true then
                    XGUIEng.DisableButton(Widget, 1);
                else
                    XGUIEng.DisableButton(Widget, 0);
                end
                if GUI_Interaction.InteractiveObjectUpdateEx1 ~= nil then
                    GUI_Interaction.InteractiveObjectUpdateEx1(Widget, EntityType);
                end
                XGUIEng.ShowWidget(Widget, 1);
            end
        end

        for i = #g_Interaction.ActiveObjectsOnScreen + 1, 2 do
            local Widget = "/InGame/Root/Normal/InteractiveObjects/" .. i;
            XGUIEng.ShowWidget(Widget, 0);
        end

        for i = 1, #g_Interaction.ActiveObjectsOnScreen do
            local Widget     = "/InGame/Root/Normal/InteractiveObjects/" ..i;
            local ObjectID   = g_Interaction.ActiveObjectsOnScreen[i];
            local ScriptName = Logic.GetEntityName(ObjectID);
            if IO_SlaveToMaster[ScriptName] then
                ScriptName = IO_SlaveToMaster[ScriptName];
            end
            if IO[ScriptName] and IO[ScriptName].Texture then
                local a = (IO[ScriptName].Texture[1]) or 14;
                local b = (IO[ScriptName].Texture[2]) or 10;
                local c = (IO[ScriptName].Texture[3]) or 0;
                API.InterfaceSetIcon(Widget, {a, b, c}, nil, c);
            end
        end
    end

    GUI_Interaction.InteractiveObjectMouseOver_Orig_ModuleObjectInteraction = GUI_Interaction.InteractiveObjectMouseOver;
    GUI_Interaction.InteractiveObjectMouseOver = function()
        local PlayerID = GUI.GetPlayerID();
        local ButtonNumber = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()));
        local ObjectID = g_Interaction.ActiveObjectsOnScreen[ButtonNumber];
        local EntityType = Logic.GetEntityType(ObjectID);

        if g_GameExtraNo > 0 then
            local EntityTypeName = Logic.GetEntityTypeName(EntityType);
            if table.contains ({"R_StoneMine", "R_IronMine", "B_Cistern", "B_Well", "I_X_TradePostConstructionSite"}, EntityTypeName) then
                GUI_Interaction.InteractiveObjectMouseOver_Orig_ModuleObjectInteraction();
                return;
            end
        end
        local EntityTypeName = Logic.GetEntityTypeName(EntityType);
        if string.find(EntityTypeName, "^I_X_") and tonumber(Logic.GetEntityName(ObjectID)) ~= nil then
            GUI_Interaction.InteractiveObjectMouseOver_Orig_ModuleObjectInteraction();
            return;
        end
        local Costs = {Logic.InteractiveObjectGetEffectiveCosts(ObjectID, PlayerID)};
        local ScriptName = Logic.GetEntityName(ObjectID);
        if IO_SlaveToMaster[ScriptName] then
            ScriptName = IO_SlaveToMaster[ScriptName];
        end

        local CheckSettlement;
        if IO[ScriptName] and IO[ScriptName].IsUsed ~= true then
            local Key = "InteractiveObjectAvailable";
            if Logic.InteractiveObjectGetAvailability(ObjectID) == false then
                Key = "InteractiveObjectNotAvailable";
            end
            local DisabledKey;
            if Logic.InteractiveObjectHasPlayerEnoughSpaceForRewards(ObjectID, PlayerID) == false then
                DisabledKey = "InteractiveObjectAvailableReward";
            end
            local Title = IO[ScriptName].Title or ("UI_ObjectNames/" ..Key);
            Title = API.ConvertPlaceholders(API.Localize(Title));
            if Title and Title:find("^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
                Title = XGUIEng.GetStringTableText(Title);
            end
            local Text = IO[ScriptName].Text or ("UI_ObjectDescription/" ..Key);
            Text = API.ConvertPlaceholders(API.Localize(Text));
            if Text and Text:find("^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
                Text = XGUIEng.GetStringTableText(Text);
            end
            local Disabled = IO[ScriptName].DisabledText or DisabledKey;
            if Disabled then
                Disabled = API.ConvertPlaceholders(API.Localize(Disabled));
                if Disabled and Disabled:find("^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
                    Disabled = XGUIEng.GetStringTableText(Disabled);
                end
            end
            Costs = IO[ScriptName].Costs;
            if Costs and Costs[1] and Costs[1] ~= Goods.G_Gold and Logic.GetGoodCategoryForGoodType(Costs[1]) ~= GoodCategories.GC_Resource then
                CheckSettlement = true;
            end
            API.SetTooltipCosts(Title, Text, Disabled, Costs, CheckSettlement);
            return;
        end
        GUI_Interaction.InteractiveObjectMouseOver_Orig_ModuleObjectInteraction();
    end

    GUI_Interaction.DisplayQuestObjective_Orig_ModuleObjectInteraction = GUI_Interaction.DisplayQuestObjective
    GUI_Interaction.DisplayQuestObjective = function(_QuestIndex, _MessageKey)
        local QuestIndexTemp = tonumber(_QuestIndex);
        if QuestIndexTemp then
            _QuestIndex = QuestIndexTemp;
        end

        local Quest, QuestType = GUI_Interaction.GetPotentialSubQuestAndType(_QuestIndex);
        local QuestObjectivesPath = "/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives";
        XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives", 0);
        local QuestObjectiveContainer;
        local QuestTypeCaption;

        g_CurrentDisplayedQuestID = _QuestIndex;

        if QuestType == Objective.Object then
            QuestObjectiveContainer = QuestObjectivesPath .. "/List";
            QuestTypeCaption = Wrapped_GetStringTableText(_QuestIndex, "UI_Texts/QuestInteraction");
            local ObjectList = {};

            for i = 1, Quest.Objectives[1].Data[0] do
                local ObjectType;
                if Logic.IsEntityDestroyed(Quest.Objectives[1].Data[i]) then
                    ObjectType = g_Interaction.SavedQuestEntityTypes[_QuestIndex][i];
                else
                    ObjectType = Logic.GetEntityType(GetID(Quest.Objectives[1].Data[i]));
                end
                local ObjectEntityName = Logic.GetEntityName(Quest.Objectives[1].Data[i]);
                local ObjectName = "";
                if ObjectType ~= nil and ObjectType ~= 0 then
                    local ObjectTypeName = Logic.GetEntityTypeName(ObjectType)
                    ObjectName = Wrapped_GetStringTableText(_QuestIndex, "Names/" .. ObjectTypeName);
                    if ObjectName == "" then
                        ObjectName = Wrapped_GetStringTableText(_QuestIndex, "UI_ObjectNames/" .. ObjectTypeName);
                    end
                    if ObjectName == "" then
                        ObjectName = IO_UserDefindedNames[ObjectTypeName];
                    end
                    if ObjectName == nil then
                        ObjectName = IO_UserDefindedNames[ObjectEntityName];
                    end
                    if ObjectName == nil then
                        ObjectName = "Debug: ObjectName missing for " .. ObjectTypeName;
                    end
                end
                table.insert(ObjectList, ObjectName);
            end
            for i = 1, 4 do
                local String = ObjectList[i];
                if String == nil then
                    String = "";
                end
                XGUIEng.SetText(QuestObjectiveContainer .. "/Entry" .. i, "{center}" .. String);
            end

            SetIcon(QuestObjectiveContainer .. "/QuestTypeIcon",{14, 10});
            XGUIEng.SetText(QuestObjectiveContainer.."/Caption","{center}"..QuestTypeCaption);
            XGUIEng.ShowWidget(QuestObjectiveContainer, 1);
        else
            GUI_Interaction.DisplayQuestObjective_Orig_ModuleObjectInteraction(_QuestIndex, _MessageKey);
        end
    end
end

function ModuleObjectInteraction.Local:OverrideReferenceTables()
    IO = Logic.CreateReferenceToTableInGlobaLuaState("IO");
    IO_UserDefindedNames = Logic.CreateReferenceToTableInGlobaLuaState("IO_UserDefindedNames");
    IO_SlaveToMaster = Logic.CreateReferenceToTableInGlobaLuaState("IO_SlaveToMaster");
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleObjectInteraction);

