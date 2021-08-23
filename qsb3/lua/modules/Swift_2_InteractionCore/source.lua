-- -------------------------------------------------------------------------- --
-- Module Text Tools                                                          --
-- -------------------------------------------------------------------------- --

ModuleInteractionCore = {
    Properties = {
        Name = "ModuleInteractionCore",
    },

    Global = {
        SlaveSequence = 0,
        LastNpcEntityID = 0,
        LastHeroEntityID = 0,
        DefaultNpcType = 1,
        UseRepositionByDefault = true,

        Lambda = {
            IO = {
                ObjectHeadline = {},
                ObjectDescription = {},
                ObjectDisabledText = {},
                ObjectIconTexture = {},
                ObjectClickAction = {},
                ObjectCondition = {},
            },
        }
    };
    Local  = {};
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
};

QSB.NonPlayerCharacterObjects = {};

-- Global Script ------------------------------------------------------------ --

function ModuleInteractionCore.Global:OnGameStart()
    IO = {};
    IO_UserDefindedNames = {};
    IO_SlaveToMaster = {};
    IO_SlaveState = {};

    IO_Headlines = {};
    IO_Descriptions = {};
    IO_DisabledTexts = {};
    IO_IconTextures = {};
    IO_Conditions = {};

    QSB.ScriptEvents.InteractiveObjectClicked = API.RegisterScriptEvent("Event_InteractiveObjectClicked", nil);
    QSB.ScriptEvents.InteractiveObjectActivated = API.RegisterScriptEvent("Event_InteractiveObjectActivated", nil);

    self:CreateDefaultInteractionLambdas();
    self:StartObjectConditionController();
    self:OverrideQuestFunctions();

    API.StartJobByEventType(Events.LOGIC_EVENT_ENTITY_DESTROYED, function()
        ModuleInteractionCore.Global:OnEntityDestroyed();
    end);
    API.StartJobByEventType(Events.LOGIC_EVENT_EVERY_SECOND, function()
        ModuleInteractionCore.Global:ControlMarker();
    end);
    API.StartJobByEventType(Events.LOGIC_EVENT_EVERY_TURN, function()
        if Logic.GetTime() > 1 then
            ModuleInteractionCore.Global:DialogTriggerController();
        end
    end);
end

function ModuleInteractionCore.Global:OnEvent(_ID, _Event, _PlayerID, _ScriptName, _EntityID)
    if _ID == QSB.ScriptEvents.InteractiveObjectActivated then
        local Lambda = ModuleInteractionCore.Global.Lambda.IO.ObjectClickAction.Default;
        if ModuleInteractionCore.Global.Lambda.IO.ObjectClickAction[_ScriptName] then
            Lambda = ModuleInteractionCore.Global.Lambda.IO.ObjectClickAction[_ScriptName];
        end
        IO[_ScriptName]:SetUsed(true);
        Lambda(_ScriptName, _EntityID, _PlayerID);
    end
end

function ModuleInteractionCore.Global:CreateDefaultInteractionLambdas()
    local TitleLambda = function(_Data)
        local Key, DisabledKey = self:GetObjectDefaultKeys(_Data);
        return "UI_ObjectNames/" ..Key;
    end
    self.Lambda.IO.ObjectHeadline.Default = TitleLambda;

    local TextLambda = function(_Data)
        local Key, DisabledKey = self:GetObjectDefaultKeys(_Data);
        return "UI_ObjectDescription/" ..Key;
    end
    self.Lambda.IO.ObjectDescription.Default = TextLambda;

    local DisabledLambda = function(_Data)
        local Key, DisabledKey = self:GetObjectDefaultKeys(_Data);
        return (DisabledKey and "UI_ButtonDisabled/" ..DisabledKey) or nil;
    end
    self.Lambda.IO.ObjectDisabledText.Default = DisabledLambda;

    local IconLambda = function(_Data)
        return {14, 10, 0};
    end
    self.Lambda.IO.ObjectIconTexture.Default = IconLambda;

    local ConditionLambda = function(_Data)
        return true;
    end
    self.Lambda.IO.ObjectCondition.Default = ConditionLambda;

    local ActionLambda = function(_Data)
        return;
    end
    self.Lambda.IO.ObjectClickAction.Default = ActionLambda;
end

function ModuleInteractionCore.Global:OverrideQuestFunctions()
    -- NPC stuff --

    GameCallback_OnNPCInteraction_Orig_QSB_NPC_Rewrite = GameCallback_OnNPCInteraction
    GameCallback_OnNPCInteraction = function(_EntityID, _PlayerID)
        GameCallback_OnNPCInteraction_Orig_QSB_NPC_Rewrite(_EntityID, _PlayerID)
        Quest_OnNPCInteraction(_EntityID, _PlayerID)
    end

    Quest_OnNPCInteraction = function(_EntityID, _PlayerID)
        local KnightIDs = {};
        Logic.GetKnights(_PlayerID, KnightIDs);

        local ClosestKnightID = 0;
        local ClosestKnightDistance = Logic.WorldGetSize();
        for i= 1, #KnightIDs, 1 do
            local DistanceBetween = Logic.GetDistanceBetweenEntities(KnightIDs[i], _EntityID);
            if DistanceBetween < ClosestKnightDistance then
                ClosestKnightDistance = DistanceBetween;
                ClosestKnightID = KnightIDs[i];
            end
        end
        ModuleInteractionCore.Global.LastHeroEntityID = ClosestKnightID;
        local NPC = QSB.NonPlayerCharacter:GetInstance(_EntityID);
        ModuleInteractionCore.Global.LastNpcEntityID = NPC:GetID();

        if NPC then
            NPC:RotateActors();
            NPC:RepositionHero();
            NPC.m_TalkedTo = ClosestKnightID;
            if NPC:HasTalkedTo() then
                NPC:Deactivate();
                if NPC.m_Callback then
                    NPC.m_Callback(NPC, ClosestKnightID);
                end
            else
                if NPC.m_WrongHeroCallback then
                    NPC.m_WrongHeroCallback(NPC, ClosestKnightID);
                end
            end
        end
    end

    -- Object stuff --

    GameCallback_OnObjectInteraction = function(_EntityID, _PlayerID)
        OnInteractiveObjectOpened(_EntityID, _PlayerID);
        OnTreasureFound(_EntityID, _PlayerID);

        local ScriptName = Logic.GetEntityName(_EntityID);
        if IO_SlaveToMaster[ScriptName] then
            ScriptName = IO_SlaveToMaster[ScriptName];
        end

        API.SendScriptEvent(QSB.ScriptEvents.InteractiveObjectActivated, _PlayerID, ScriptName, _EntityID);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.InteractiveObjectActivated, %d, "%s", %d)]],
            _EntityID,
            ScriptName,
            _PlayerID
        ));
    end

    -- Quest stuff --

    QuestTemplate.RemoveQuestMarkers_Orig_ModuleInteractionCore = QuestTemplate.RemoveQuestMarkers
    QuestTemplate.RemoveQuestMarkers = function(self)
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if self.Objectives[i].Data[1] ~= -65565 then
                    QuestTemplate.RemoveQuestMarkers_Orig_ModuleInteractionCore(self);
                else
                    QuestTemplate.RemoveNPCMarkers(self);
                end
            else
                QuestTemplate.RemoveQuestMarkers_Orig_ModuleInteractionCore(self);
            end
        end
    end

    QuestTemplate.ShowQuestMarkers_Orig_ModuleInteractionCore = QuestTemplate.ShowQuestMarkers
    QuestTemplate.ShowQuestMarkers = function(self)
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if self.Objectives[i].Data[1] ~= -65565 then
                    QuestTemplate.ShowQuestMarkers_Orig_ModuleInteractionCore(self);
                end
            end
        end
    end

    function QuestTemplate:RemoveNPCMarkers()
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if self.Objectives[i].Data[1] == -65565 then
                    if self.Objectives[i].Data[4] and self.Objectives[i].Data[4].NpcInstance then
                        self.Objectives[i].Data[4].NpcInstance:Dispose();
                        self.Objectives[i].Data[4].NpcInstance = nil;
                    end
                end
            end
        end
    end

    QuestTemplate.IsObjectiveCompleted_Orig_ModuleInteractionCore = QuestTemplate.IsObjectiveCompleted;
    QuestTemplate.IsObjectiveCompleted = function(self, objective)
        local objectiveType = objective.Type;
        local data = objective.Data;
        if objective.Completed ~= nil then
            return objective.Completed;
        end

        if objectiveType ~= Objective.Distance then
            return self:IsObjectiveCompleted_Orig_ModuleInteractionCore(objective);
        else
            if data[1] == -65565 then
                if not IsExisting(data[3]) then
                    error(data[3].. " is dead! :(");
                    objective.Completed = false;
                else
                    if not data[4].NpcInstance then
                        local NPC = QSB.NonPlayerCharacter:New(data[3]);
                        NPC:SetDialogPartner(data[2]);
                        data[4].NpcInstance = NPC;
                    end
                    if data[4].NpcInstance:HasTalkedTo(data[2]) then
                        objective.Completed = true;
                    end
                    if not objective.Completed then
                        if not data[4].NpcInstance:IsActive() then
                            data[4].NpcInstance:Activate();
                        end
                    end
                end
            else
                return self:IsObjectiveCompleted_Orig_ModuleInteractionCore(objective);
            end
        end
    end

    QuestTemplate.AreObjectsActivated = function(self, _ObjectList)
        for i=1, _ObjectList[0] do
            if not _ObjectList[-i] then
                _ObjectList[-i] = GetEntityId(_ObjectList[i]);
            end
            local EntityName = Logic.GetEntityName(_ObjectList[-i]);
            if IO_SlaveToMaster[EntityName] then
                EntityName = IO_SlaveToMaster[EntityName];
            end

            if IO[EntityName] then
                if IO[EntityName]:IsUsed() ~= true then
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

function ModuleInteractionCore.Global:SetObjectLambda(_ScriptName, _FieldName, _Lambda)
    local Lambda = _Lambda;
    if Lambda ~= nil and type(Lambda) ~= "function" then
        Lambda = function()
            return _Lambda;
        end;
    end
    self.Lambda.IO[_FieldName][_ScriptName] = Lambda;
end

-- -------------------------------------------------------------------------- --

function ModuleInteractionCore.Global:SetDefaultNPCType(_Type)
    self.DefaultNpcType = _Type;
end

function ModuleInteractionCore.Global:SetUseRepositionByDefault(_Flag)
    self.UseRepositionByDefault = _Flag == true;
end

function ModuleInteractionCore.Global:GetControllingPlayer()
    return QSB.HumanPlayerID;
end

function ModuleInteractionCore.Global:ControlMarker()
    for k, v in pairs(QSB.NonPlayerCharacterObjects) do
        if IsExisting(v:GetID()) then
            v:ControlMarker();
        end
    end
end
ModuleInteractionCore_ControlMarkerJob = ModuleInteractionCore.Global.ControlMarker;

function ModuleInteractionCore.Global:DialogTriggerController()
    local PlayerID = ModuleInteractionCore.Global:GetControllingPlayer();
    local PlayersKnights = {};
    Logic.GetKnights(PlayerID, PlayersKnights);
    for i= 1, #PlayersKnights, 1 do
        if Logic.GetCurrentTaskList(PlayersKnights[i]) == "TL_NPC_INTERACTION" then
            for k, v in pairs(QSB.NonPlayerCharacterObjects) do
                if v and v.m_TalkedTo == nil and v.m_Distance >= 350 then
                    local x1 = math.floor(API.GetFloat(PlayersKnights[i], QSB.ScriptingValue.Destination.X));
                    local y1 = math.floor(API.GetFloat(PlayersKnights[i], QSB.ScriptingValue.Destination.Y));
                    local x2, y2 = Logic.EntityGetPos(GetID(k));
                    if x1 == math.floor(x2) and y1 == math.floor(y2) then
                        if IsExisting(k) and IsNear(PlayersKnights[i], k, v.m_Distance) then
                            GameCallback_OnNPCInteraction(GetID(k), PlayerID);
                            return;
                        end
                    end
                end
            end
        end
    end
end
ModuleInteractionCore_DialogTriggerJob = ModuleInteractionCore.Global.DialogTriggerController;

-- -------------------------------------------------------------------------- --

function ModuleInteractionCore.Global:CreateObject(_Description)
    -- Objekt erstellen
    local ID = GetID(_Description.Name);
    if ID == 0 then
        return;
    end
    local Object = QSB.InteractiveObject:New(_Description.Name)
        :SetDistance(_Description.Distance)
        :SetWaittime(_Description.Waittime)
        :SetState(_Description.State)
        :SetData(_Description);

    -- DEPRECATED: Legacy Code Fallback
    self:SetObjectLambda(_Description.Name, "ObjectCondition", _Description.Condition);
    self:SetObjectLambda(_Description.Name, "ObjectClickAction", _Description.Callback);
    self:SetObjectLambda(_Description.Name, "ObjectIconTexture", _Description.Texture);
    self:SetObjectLambda(_Description.Name, "ObjectHeadline", _Description.Title);
    self:SetObjectLambda(_Description.Name, "ObjectDescription", _Description.Text);
    self:SetObjectLambda(_Description.Name, "ObjectDisabledText", _Description.DisabledText);
    
    -- Belohnung setzen
    if _Description.Reward then
        Object:SetReward(unpack(_Description.Reward))
    end
    -- Kosten setzen
    if _Description.Costs then
        Object:SetCosts(unpack(_Description.Costs))
    end
    
    -- Slave Objekt erstellen
    local TypeName = Logic.GetEntityTypeName(Logic.GetEntityType(ID));
    if not TypeName:find("I_X_") then
        self:CreateSlaveObject(Object);
    end
    -- Aktivieren
    IO[_Description.Name] = Object;
    self:SetupObject(IO[_Description.Name]);
    Logic.ExecuteInLuaLocalState("ModuleInteractionCore.Local:ForceFullGlobalReferenceUpdate()");
    return Object;
end

function ModuleInteractionCore.Global:CreateSlaveObject(_Object)
    -- Generate new name
    self.SlaveSequence = self.SlaveSequence +1;
    local Name = "QSB_SlaveObject_" ..self.SlaveSequence;
    -- Overwrite with existing slave
    for k, v in pairs(IO_SlaveToMaster) do
        if v == _Object.m_Name and IsExisting(k) then
            Name = k;
        end
    end
    -- Create slave object if not already existing
    local SlaveID = GetID(Name);
    if not IsExisting(Name) then
        local x,y,z = Logic.EntityGetPos(GetID(_Object.m_Name));
        SlaveID = Logic.CreateEntity(Entities.I_X_DragonBoatWreckage, x, y, 0, 0);
        Logic.SetModel(SlaveID, Models.Effects_E_Mosquitos);
        Logic.SetEntityName(SlaveID, Name);
        IO_SlaveToMaster[Name] = _Object.m_Name;
    end
    _Object:SetWaittime(0);
    _Object:SetSlave(Name);
    IO_SlaveState[Name] = 1;
    return SlaveID;
end

function ModuleInteractionCore.Global:SetupObject(_Object)
    local ID = GetID((_Object.m_Slave and _Object.m_Slave) or _Object.m_Name);
    Logic.InteractiveObjectClearCosts(ID);
    Logic.InteractiveObjectClearRewards(ID);
    Logic.InteractiveObjectSetInteractionDistance(ID,_Object.m_Distance);
    Logic.InteractiveObjectSetTimeToOpen(ID,_Object.m_Waittime);
    Logic.InteractiveObjectSetRewardResourceCartType(ID, Entities.U_ResourceMerchant);
    Logic.InteractiveObjectSetRewardGoldCartType(ID, Entities.U_GoldCart);
    Logic.InteractiveObjectSetCostResourceCartType(ID, Entities.U_ResourceMerchant);
    Logic.InteractiveObjectSetCostGoldCartType(ID, Entities.U_GoldCart);
    if _Object.m_Reward then
        Logic.InteractiveObjectAddRewards(ID, _Object.m_Reward[1], _Object.m_Reward[2]);
    end
    if _Object.m_Costs and _Object.m_Costs[1] then
        Logic.InteractiveObjectAddCosts(ID, _Object.m_Costs[1], _Object.m_Costs[2]);
    end
    if _Object.m_Costs and _Object.m_Costs[3] then
        Logic.InteractiveObjectAddCosts(ID, _Object.m_Costs[3], _Object.m_Costs[4]);
    end
    self:ResetObject(_Object);
end

function ModuleInteractionCore.Global:ResetObject(_Object)
    local ID = GetID((_Object.m_Slave and _Object.m_Slave) or _Object.m_Name);
    RemoveInteractiveObjectFromOpenedList(ID);
    table.insert(HiddenTreasures, ID);
    Logic.InteractiveObjectSetAvailability(ID, true);
    self:SetObjectAvailability(ID, _Object.m_State or 0);
    _Object:SetUsed(false);
    _Object:SetActive(true);
end

function ModuleInteractionCore.Global:SetObjectAvailability(_ScriptName, _State, ...)
    arg = ((not arg or #arg == 0) and {1, 2, 3, 4, 5, 6, 7, 8}) or arg;
    for i= 1, #arg, 1 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), arg[i], _State);
    end
end

function ModuleInteractionCore.Global:OnEntityDestroyed()
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
        local SlaveID = self:CreateSlaveObject(Object);
        if not IsExisting(SlaveID) then
            error("failed to create slave!");
            return;
        end
        ModuleInteractionCore.Global:SetupObject(Object);
        if Object:IsUsed() == true or (IO_SlaveState[SlaveName] and IO_SlaveState[SlaveName] == 0) then
            API.InteractiveObjectDeactivate(Object.m_Slave);
        end
        info("new slave created for master " ..MasterName.. ".");
    end
end

-- -------------------------------------------------------------------------- --

function ModuleInteractionCore.Global:GetObjectDefaultKeys(_Data)
    -- Get IO name
    local ScriptName = (_Data.m_Slave and _Data.m_Slave) or _Data.m_Name;
    local ObjectID = GetID(ScriptName);
    -- Get keys
    local Key = "InteractiveObjectAvailable";
    if Logic.InteractiveObjectGetAvailability(ObjectID) == false then
        Key = "InteractiveObjectNotAvailable";
    end
    local DisabledKey;
    if Logic.InteractiveObjectHasPlayerEnoughSpaceForRewards(ObjectID, QSB.HumanPlayerID) == false then
        DisabledKey = "InteractiveObjectAvailableReward";
    end
    return Key, DisabledKey;
end

function ModuleInteractionCore.Global:StartObjectConditionController()
    StartSimpleHiResJobEx(function()
        for k, v in pairs(IO) do
            if v and not v:IsUsed() and v:IsActive() then
                -- Condition
                local ConditionLambda = ModuleInteractionCore.Global.Lambda.IO.ObjectCondition.Default;
                if ModuleInteractionCore.Global.Lambda.IO.ObjectCondition[k] then
                    ConditionLambda = ModuleInteractionCore.Global.Lambda.IO.ObjectCondition[k];
                end
                IO_Conditions[k] = ConditionLambda(k, GetID((v.m_Slave and v.m_Slave) or k), QSB.HumanPlayerID);

                -- Title
                local TitleLambda = ModuleInteractionCore.Global.Lambda.IO.ObjectHeadline.Default;
                if ModuleInteractionCore.Global.Lambda.IO.ObjectHeadline[k] then
                    TitleLambda = ModuleInteractionCore.Global.Lambda.IO.ObjectHeadline[k];
                end
                local Title = TitleLambda(k, GetID((v.m_Slave and v.m_Slave) or k), QSB.HumanPlayerID);
                if type(Title) == "table" then
                    Title = API.ConvertPlaceholders(API.Localize(Title));
                end
                IO_Headlines[k] = Title;

                -- Text
                local TextLambda = ModuleInteractionCore.Global.Lambda.IO.ObjectDescription.Default;
                if ModuleInteractionCore.Global.Lambda.IO.ObjectDescription[k] then
                    TextLambda = ModuleInteractionCore.Global.Lambda.IO.ObjectDescription[k];
                end
                local Text = TextLambda(k, GetID((v.m_Slave and v.m_Slave) or k), QSB.HumanPlayerID);
                if type(Text) == "table" then
                    Text = API.ConvertPlaceholders(API.Localize(Text));
                end
                IO_Descriptions[k] = Text;

                -- Disabled
                local DisabledLambda = ModuleInteractionCore.Global.Lambda.IO.ObjectDisabledText.Default;
                if ModuleInteractionCore.Global.Lambda.IO.ObjectDisabledText[k] then
                    DisabledLambda = ModuleInteractionCore.Global.Lambda.IO.ObjectDisabledText[k];
                end
                local Disabled = DisabledLambda(k, GetID((v.m_Slave and v.m_Slave) or k), QSB.HumanPlayerID);
                if type(Disabled) == "table" then
                    Disabled = API.ConvertPlaceholders(API.Localize(Disabled));
                end
                IO_DisabledTexts[k] = Disabled;

                -- Icon
                local IconLambda = ModuleInteractionCore.Global.Lambda.IO.ObjectIconTexture.Default;
                if ModuleInteractionCore.Global.Lambda.IO.ObjectIconTexture[k] then
                    IconLambda = ModuleInteractionCore.Global.Lambda.IO.ObjectIconTexture[k];
                end
                IO_IconTextures[k] = IconLambda(k, GetID((v.m_Slave and v.m_Slave) or k), QSB.HumanPlayerID);
            end
        end

        -- Force partial reference update
        Logic.ExecuteInLuaLocalState("ModuleInteractionCore.Local:ForceObjectLambdaResultReferenceUpdate()");
    end);
end

-- Local Script ------------------------------------------------------------- --

function ModuleInteractionCore.Local:OnGameStart()
    QSB.ScriptEvents.InteractiveObjectClicked = API.RegisterScriptEvent("Event_InteractiveObjectClicked", nil);
    QSB.ScriptEvents.InteractiveObjectActivated = API.RegisterScriptEvent("Event_InteractiveObjectActivated", nil);

    self:ForceFullGlobalReferenceUpdate();
    self:OverrideGameFunctions();
end

function ModuleInteractionCore.Local:OverrideGameFunctions()
    g_CurrentDisplayedQuestID = 0;

    -- Interface --

    GUI_Interaction.InteractiveObjectClicked_Orig_ModuleInteractionCore = GUI_Interaction.InteractiveObjectClicked
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
            if not IO_Conditions[ScriptName] then
                Message(XGUIEng.GetStringTableText("UI_ButtonDisabled/PromoteKnight"));
                return;
            end
            if type(IO[ScriptName].m_Costs) == "table" and #IO[ScriptName].m_Costs ~= 0 then
                local CathedralID = Logic.GetCathedral(PlayerID);
                local CastleID    = Logic.GetHeadquarters(PlayerID);
                if CathedralID == nil or CathedralID == 0 or CastleID == nil or CastleID == 0 then
                    API.Note("DEBUG: Player needs special buildings when using activation costs!");
                    return;
                end
            end
        end
        
        GUI_Interaction.InteractiveObjectClicked_Orig_ModuleInteractionCore();
        API.SendScriptEvent(QSB.ScriptEvents.InteractiveObjectClicked, PlayerID, ScriptName, EntityID);
        GUI.SendScriptCommand(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.InteractiveObjectClicked, %d, "%s", %d)]],
            PlayerID,
            ScriptName,
            EntityID
        ));
    end
    
    GUI_Interaction.InteractiveObjectUpdate_Orig_ModuleInteractionCore = GUI_Interaction.InteractiveObjectUpdate;
    GUI_Interaction.InteractiveObjectUpdate = function()
        GUI_Interaction.InteractiveObjectUpdate_Orig_ModuleInteractionCore();
        if g_Interaction.ActiveObjects == nil then
            return;
        end
        for i = 1, #g_Interaction.ActiveObjectsOnScreen do
            local Widget = "/InGame/Root/Normal/InteractiveObjects/" ..i;
            if XGUIEng.IsWidgetExisting(Widget) == 1 then
                local ObjectID       = g_Interaction.ActiveObjectsOnScreen[i];
                local MasterObjectID = ObjectID;
                local ScriptName     = Logic.GetEntityName(ObjectID);
                if IO_SlaveToMaster[ScriptName] then
                    ScriptName = IO_SlaveToMaster[ScriptName];
                    MasterObjectID = GetID(ScriptName);
                end
                -- Position
                local X, Y = GUI.GetEntityInfoScreenPosition(MasterObjectID);
                local WidgetSize = {XGUIEng.GetWidgetScreenSize(Widget)};
                XGUIEng.SetWidgetScreenPosition(Widget, X - (WidgetSize[1]/2), Y - (WidgetSize[2]/2));
                -- Icon
                if IO_IconTextures[ScriptName] then
                    local a = (IO_IconTextures[ScriptName][1]) or 14;
                    local b = (IO_IconTextures[ScriptName][2]) or 10;
                    local c = (IO_IconTextures[ScriptName][3]) or 0;
                    API.InterfaceSetIcon(Widget, {a, b, c}, nil, c);
                end
            end
        end
    end

    GUI_Interaction.InteractiveObjectMouseOver_Orig_ModuleInteractionCore = GUI_Interaction.InteractiveObjectMouseOver;
    GUI_Interaction.InteractiveObjectMouseOver = function()
        local PlayerID = GUI.GetPlayerID();
        local ButtonNumber = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()));
        local ObjectID = g_Interaction.ActiveObjectsOnScreen[ButtonNumber];
        local EntityType = Logic.GetEntityType(ObjectID);

        -- Fix default objects
        if g_GameExtraNo > 0 then
            local EntityTypeName = Logic.GetEntityTypeName(EntityType);
            if table.contains ({"R_StoneMine", "R_IronMine", "B_Cistern", "B_Well", "I_X_TradePostConstructionSite"}, EntityTypeName) then
                GUI_Interaction.InteractiveObjectMouseOver_Orig_ModuleInteractionCore();
                return;
            end
        end
        -- Fix gold amount script names
        local EntityTypeName = Logic.GetEntityTypeName(EntityType);
        if string.find(EntityTypeName, "^I_X_") and tonumber(Logic.GetEntityName(ObjectID)) ~= nil then
            GUI_Interaction.InteractiveObjectMouseOver_Orig_ModuleInteractionCore();
            return;
        end

        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local Costs = {Logic.InteractiveObjectGetEffectiveCosts(ObjectID, PlayerID)};
        local IsAvailable = Logic.InteractiveObjectGetAvailability(ObjectID);

        local ScriptName = Logic.GetEntityName(ObjectID);
        if IO_SlaveToMaster[ScriptName] then
            ScriptName = IO_SlaveToMaster[ScriptName];
        end

        local CheckSettlement;
        if IO[ScriptName] and IO[ScriptName].m_Used ~= true then
            -- Get keys
            local Key = "InteractiveObjectAvailable";
            if Logic.InteractiveObjectGetAvailability(ObjectID) == false then
                Key = "InteractiveObjectNotAvailable";
            end
            local DisabledKey;
            if Logic.InteractiveObjectHasPlayerEnoughSpaceForRewards(ObjectID, PlayerID) == false then
                DisabledKey = "InteractiveObjectAvailableReward";
            end

            -- Title
            local Title = IO_Headlines[ScriptName] or "UI_ObjectNames/" ..Key;
            if Title and Title:find("^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
                Title = XGUIEng.GetStringTableText(Title);
            end
            -- Text
            local Text = IO_Descriptions[ScriptName] or "UI_ObjectDescription/" ..Key;
            if Text and Text:find("^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
                Text = XGUIEng.GetStringTableText(Text);
            end
            -- Disabled reason
            local Disabled = IO_DisabledTexts[ScriptName];
            if Disabled and Disabled:find("^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
                Disabled = XGUIEng.GetStringTableText(Disabled);
            end

            -- Costs
            Costs = IO[ScriptName].m_Costs;
            if Costs and Costs[1] and Costs[1] ~= Goods.G_Gold and Logic.GetGoodCategoryForGoodType(Costs[1]) ~= GoodCategories.GC_Resource then
                CheckSettlement = true;
            end

            -- Actual tooltip
            API.InterfaceSetTooltipCosts(Title, Text, Disabled, {Costs[1], Costs[2], Costs[3], Costs[4]}, CheckSettlement);
            return;
        end
    end

    -- Quest --

    GUI_Interaction.DisplayQuestObjective_Orig_ModuleInteractionCore = GUI_Interaction.DisplayQuestObjective
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

        local ParentQuest = Quests[_QuestIndex];
        local ParentQuestIdentifier;
        if ParentQuest ~= nil
        and type(ParentQuest) == "table" then
            ParentQuestIdentifier = ParentQuest.Identifier;
        end
        local HookTable = {};

        g_CurrentDisplayedQuestID = _QuestIndex;

        if QuestType == Objective.Distance then
            QuestObjectiveContainer = QuestObjectivesPath .. "/List";
            QuestTypeCaption = Wrapped_GetStringTableText(_QuestIndex, "UI_Texts/QuestInteraction");
            local ObjectList = {};

            if Quest.Objectives[1].Data[1] == -65565 then
                QuestObjectiveContainer = QuestObjectivesPath .. "/Distance";
                QuestTypeCaption = Wrapped_GetStringTableText(_QuestIndex, "UI_Texts/QuestMoveHere");
                SetIcon(QuestObjectiveContainer .. "/QuestTypeIcon",{7,10});

                local MoverEntityID = GetEntityId(Quest.Objectives[1].Data[2]);
                local MoverEntityType = Logic.GetEntityType(MoverEntityID);
                local MoverIcon = g_TexturePositions.Entities[MoverEntityType];
                if not MoverIcon then
                    MoverIcon = {7, 9};
                end
                SetIcon(QuestObjectiveContainer .. "/IconMover", MoverIcon);

                local TargetEntityID = GetEntityId(Quest.Objectives[1].Data[3]);
                local TargetEntityType = Logic.GetEntityType(TargetEntityID);
                local TargetIcon = g_TexturePositions.Entities[TargetEntityType];
                if not TargetIcon then
                    TargetIcon = {14, 10};
                end

                local IconWidget = QuestObjectiveContainer .. "/IconTarget";
                local ColorWidget = QuestObjectiveContainer .. "/TargetPlayerColor";

                SetIcon(IconWidget, TargetIcon);
                XGUIEng.SetMaterialColor(ColorWidget, 0, 255, 255, 255, 0);

                SetIcon(QuestObjectiveContainer .. "/QuestTypeIcon",{16,12});
                local caption = {
                    de = "Gespräch beginnen",
                    en = "Start conversation",
                };
                QuestTypeCaption = API.Localize(caption);

                XGUIEng.SetText(QuestObjectiveContainer.."/Caption","{center}"..QuestTypeCaption);
                XGUIEng.ShowWidget(QuestObjectiveContainer, 1);
            else
                GUI_Interaction.DisplayQuestObjective_Orig_ModuleInteractionCore(_QuestIndex, _MessageKey);
            end
        elseif QuestType == Objective.Object then
            QuestObjectiveContainer = QuestObjectivesPath .. "/List";
            QuestTypeCaption = Wrapped_GetStringTableText(_QuestIndex, "UI_Texts/QuestInteraction");
            local ObjectList = {};

            for i = 1, Quest.Objectives[1].Data[0] do
                local ObjectType;
                if Logic.IsEntityDestroyed(Quest.Objectives[1].Data[i]) then
                    ObjectType = g_Interaction.SavedQuestEntityTypes[_QuestIndex][i];
                else
                    ObjectType = Logic.GetEntityType(GetEntityId(Quest.Objectives[1].Data[i]));
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
            GUI_Interaction.DisplayQuestObjective_Orig_ModuleInteractionCore(_QuestIndex, _MessageKey);
        end
    end

    GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_ModuleInteractionCore = GUI_Interaction.GetEntitiesOrTerritoryListForQuest
    GUI_Interaction.GetEntitiesOrTerritoryListForQuest = function( _Quest, _QuestType )
        local EntityOrTerritoryList = {}
        local IsEntity = true

        if _QuestType == Objective.Distance then
            if _Quest.Objectives[1].Data[1] == -65565 then
                local Entity = GetEntityId(_Quest.Objectives[1].Data[3]);
                table.insert(EntityOrTerritoryList, Entity);
            else
                return GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_ModuleInteractionCore( _Quest, _QuestType );
            end

        else
            return GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_ModuleInteractionCore( _Quest, _QuestType );
        end
        return EntityOrTerritoryList, IsEntity
    end
end

-- -------------------------------------------------------------------------- --

function ModuleInteractionCore.Local:ForceFullGlobalReferenceUpdate()
    IO = Logic.CreateReferenceToTableInGlobaLuaState("IO");
    IO_UserDefindedNames = Logic.CreateReferenceToTableInGlobaLuaState("IO_UserDefindedNames");
    IO_SlaveToMaster = Logic.CreateReferenceToTableInGlobaLuaState("IO_SlaveToMaster");

    self:ForceObjectLambdaResultReferenceUpdate();
end

function ModuleInteractionCore.Local:ForceObjectLambdaResultReferenceUpdate()
    IO_Headlines = Logic.CreateReferenceToTableInGlobaLuaState("IO_Headlines");
    IO_Descriptions = Logic.CreateReferenceToTableInGlobaLuaState("IO_Descriptions");
    IO_DisabledTexts = Logic.CreateReferenceToTableInGlobaLuaState("IO_DisabledTexts");
    IO_IconTextures = Logic.CreateReferenceToTableInGlobaLuaState("IO_IconTextures");
    IO_Conditions = Logic.CreateReferenceToTableInGlobaLuaState("IO_Conditions");
end

-- -------------------------------------------------------------------------- --

QSB.NonPlayerCharacter = {};

---
-- Konstruktor
-- @param[type=string] _ScriptName Skriptname des NPC
-- @within QSB.NonPlayerCharacter
-- @local
-- @usage
-- -- Einen normalen NPC erzeugen:
-- QSB.NonPlayerCharacter:New("npc")
--     :SetDialogPartner("hero")                 -- Optional
--     :SetCallback(Briefing1)                   -- Optional
--     :Activate();
--
function QSB.NonPlayerCharacter:New(_ScriptName)
    assert(self == QSB.NonPlayerCharacter, 'Can not be used from instance!');
    local npc = table.copy(self);
    npc.m_NpcName  = _ScriptName;
    npc.m_NpcType  = BundleNonPlayerCharacter.Global.DefaultNpcType
    npc.m_Distance = 350;
    if Logic.IsKnight(GetID(_ScriptName)) then
        npc.m_Distance = 400;
    end
    QSB.NonPlayerCharacterObjects[_ScriptName] = npc;
    npc:CreateMarker();
    return npc;
end

---
-- Gibt das Objekt des NPC zurück, wenn denn eins für dieses Entity existiert.
--
-- Wurde noch kein NPC für diesen Skriptnamen erzeugt, wird nil zurückgegeben.
--
-- @param[type=string] _ScriptName Skriptname des NPC
-- @return[type=table] Interaktives Objekt
-- @within QSB.NonPlayerCharacter
-- @local
-- @usage -- NPC ermitteln
-- local NPC = QSB.NonPlayerCharacter:GetInstance("horst");
-- -- Etwas mit dem NPC tun
-- NPC:SetDialogPartner("hilda");
--
function QSB.NonPlayerCharacter:GetInstance(_ScriptName)
    assert(self == QSB.NonPlayerCharacter, 'Can not be used from instance!');
    local EntityID = GetID(_ScriptName)
    local ScriptName = Logic.GetEntityName(EntityID);
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Soldier) == 1 then
        local LeaderID = Logic.SoldierGetLeaderEntityID(EntityID);
        if IsExisting(LeaderID) then
            ScriptName = Logic.GetEntityName(LeaderID);
        end
    end
    return QSB.NonPlayerCharacterObjects[ScriptName];
end

---
-- Gibt die Entity ID des letzten angesprochenen NPC zurück.
--
-- @return[type=number] ID des letzten NPC
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:GetNpcId()
    assert(self == QSB.NonPlayerCharacter, 'Can not be used from instance!');
    return BundleNonPlayerCharacter.Global.LastNpcEntityID;
end

---
-- Gibt die Entity ID des letzten Helden zurück, der einen NPC
-- angesprochen hat.
--
-- @return[type=number] ID des letzten Heden
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:GetHeroId()
    assert(self == QSB.NonPlayerCharacter, 'Can not be used from instance!');
    return BundleNonPlayerCharacter.Global.LastHeroEntityID;
end

---
-- Gibt die Entity ID des NPC zurück. Ist der NPC ein Leader, wird
-- der erste Soldat zurückgegeben, wenn es einen gibt.
--
-- @return[type=number] ID des NPC
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:GetID()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    local EntityID = GetID(self.m_NpcName);
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Leader) == 1 then
        local Soldiers = {Logic.GetSoldiersAttachedToLeader(EntityID)};
        if Soldiers[1] > 0 then
            return Soldiers[2];
        end
    end
    return EntityID
end

---
-- Löscht einen NPC.
--
-- @within QSB.NonPlayerCharacter
-- @local
--
-- @usage -- NPC löschen
-- NPC:Dispose();
--
function QSB.NonPlayerCharacter:Dispose()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    self:Deactivate();
    self:DestroyMarker();
    QSB.NonPlayerCharacterObjects[self.m_NpcName] = nil;
end

---
-- Aktiviert einen inaktiven NPC, sodass er wieder angesprochen werden kann.
--
-- @param[type=number] _Type NPC-Typ [1-4]
-- @return[type=table] self
-- @within QSB.NonPlayerCharacter
-- @local
-- @usage -- NPC aktivieren:
-- NPC:Activate();
--
function QSB.NonPlayerCharacter:Activate(_Type)
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.m_NpcName) then
        Logic.SetOnScreenInformation(self:GetID(), _Type or self.m_NpcType);
        self:ShowMarker();
    end
    return self;
end

---
-- Deaktiviert einen aktiven NPC, sodass er nicht angesprochen werden kann.
--
-- @return[type=table] self
-- @within QSB.NonPlayerCharacter
-- @local
-- @usage -- NPC deaktivieren:
-- NPC:Deactivate();
--
function QSB.NonPlayerCharacter:Deactivate()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.m_NpcName) then
        Logic.SetOnScreenInformation(self:GetID(), 0);
        self:HideMarker();
    end
    return self;
end

---
-- <p>Gibt true zurück, wenn der NPC aktiv ist.</p>
--
-- @return[type=boolean] NPC ist aktiv
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:IsActive()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    return Logic.GetEntityScriptingValue(self:GetID(), 6) > 0;
end

---
-- Setzt den NPC zurück, sodass er erneut aktiviert werden kann.
--
-- @return[type=table] self
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:Reset()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.m_NpcName) then
        Logic.SetOnScreenInformation(self:GetID(), 0);
        self.m_TalkedTo = nil;
        self:HideMarker();
    end
    return self;
end

---
-- Gibt true zurück, wenn der NPC angesprochen wurde. Ist ein
-- spezieller Ansprechpartner definiert, wird nur dann true
-- zurückgegeben, wenn dieser Held mit dem NPC spricht.
--
-- @return[type=boolean] NPC wurde angesprochen
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:HasTalkedTo()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if self.m_HeroName then
        return self.m_TalkedTo == GetID(self.m_HeroName);
    end
    return self.m_TalkedTo ~= nil;
end

---
-- Gibt die Entity ID des letzten angesprochenen NPC zurück.
--
-- @param[type=number] _Type Typ des Npc
-- @return[type=number] ID des letzten NPC
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:SetType(_Type)
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    self.m_NpcType = _Type;
    if _Type > 1 then
        self:HideMarker();
    end
    return self;
end

function QSB.NonPlayerCharacter:SetRepositionOnAction(_Flag)
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    self.m_RepositionOnAction = _Flag == true;
    return self;
end

---
-- Setzt die Entfernung, die unterschritten werden muss, damit
-- ein NPC als angesprochen gilt.
--
-- @param[type=number] _Distance Aktivierungsdistanz
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:SetTalkDistance(_Distance)
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    self.m_Distance = _Distance or 350;
    return self;
end

---
-- Setzt den Ansprechpartner für diesen NPC.
--
-- @param[type=string] _HeroName Skriptname des Helden
-- @return[type=table] self
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:SetDialogPartner(_HeroName)
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    self.m_HeroName = _HeroName;
    return self;
end

---
-- Setzt das Callback für den Fall, dass ein falscher Held den
-- NPC anspricht.
--
-- @param[type=function] _Callback Callback
-- @return[type=table] self
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:SetWrongPartnerCallback(_Callback)
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    self.m_WrongHeroCallback = _Callback;
    return self;
end

---
-- Setzt das Callback des NPC, dass beim Ansprechen ausgeführt wird.
--
-- @param[type=function] _Callback Callback
-- @return[type=table] self
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:SetCallback(_Callback)
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    assert(type(_Callback) == "function", 'callback must be a function!');
    self.m_Callback = _Callback;
    return self;
end

---
-- Rotiert alle nahen Helden zum NPC und den NPC zu dem Helden,
-- der ihn angesprochen hat.
--
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:RotateActors()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if self.m_RepositionOnAction == false then
        return;
    end
    local PlayerID = Logic.EntityGetPlayer(BundleNonPlayerCharacter.Global.LastHeroEntityID);
    local PlayerKnights = {};
    Logic.GetKnights(PlayerID, PlayerKnights);
    for k, v in pairs(PlayerKnights) do
        -- Alle Helden stoppen, die sich zu NPC bewegen
        local x1 = math.floor(API.GetFloat(v, QSB.ScriptingValue.Destination.X));
        local y1 = math.floor(API.GetFloat(v, QSB.ScriptingValue.Destination.Y));
        local x2, y2 = Logic.EntityGetPos(GetID(self.m_NpcName));
        if x1 == math.floor(x2) and y1 == math.floor(y2) then
            local x, y, z = Logic.EntityGetPos(v);
            Logic.MoveEntity(v, x, y);
            LookAt(v, self.m_NpcName);
        end
    end
    API.Confront(self.m_NpcName, BundleNonPlayerCharacter.Global.LastHeroEntityID)
end

---
-- Setzt den Helden, der den NPC angesprochen hat, auf eine Position, die
-- in der richtigen Entfernung zum NPC ist.
--
-- <b>Hinweis</b>: Dies ist ein temporärer Fix für das Kollisionsproblem.
-- Sobald eine bessere Lösung zur Verfügung steht, sollte diese Methode
-- wieder entfernt werden!
--
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:RepositionHero()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if self.m_RepositionOnAction == false then
        return;
    end
    local HeroID = BundleNonPlayerCharacter.Global.LastHeroEntityID;
    local NPCID  = GetID(self.m_NpcName);
    if GetDistance(HeroID, NPCID) < self.m_Distance -50 then
        -- Position des NPC bestimmen
        local Orientation = Logic.GetEntityOrientation(NPCID);
        local x1, y1, z1 = Logic.EntityGetPos(NPCID);
        -- Relative Position bestimmen
        local x2 = x1 + (self.m_Distance * math.cos(math.rad(Orientation)));
        local y2 = y1 + (self.m_Distance * math.sin(math.rad(Orientation)));
        -- Nächste erreichbare Position bei Punkt bestimmen
        local ID = Logic.CreateEntityOnUnblockedLand(Entities.XD_ScriptEntity, x2, y2, 0, 0);
        local x3, y3, z3 = Logic.EntityGetPos(ID);
        -- Held neu positionieren
        Logic.MoveSettler(HeroID, x3, y3);
        StartSimpleHiResJobEx( function(_HeroID, _NPCID)
            if Logic.IsEntityMoving(_HeroID) == false then
                API.Confront(_HeroID, _NPCID);
                return true;
            end
        end, HeroID, NPCID);
    end
end

---
-- Erzeugt das Entity des NPC-Markers.
--
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:CreateMarker()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    local x,y,z = Logic.EntityGetPos(self:GetID());
    local MarkerID = Logic.CreateEntity(Entities.XD_ScriptEntity, x, y, 0, 0);
    DestroyEntity(self.m_MarkerID);
    self.m_MarkerID = MarkerID;
    self:HideMarker();
    return self;
end

---
-- Entfernt das Entity des NPC-Markers.
--
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:DestroyMarker()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if self.m_MarkerID then
        DestroyEntity(self.m_MarkerID);
        self.m_MarkerID = nil;
    end
    return self;
end

---
-- Zeigt den NPC-Marker des NPC an.
--
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:ShowMarker()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if self.m_NpcType == 1 and IsExisting(self.m_MarkerID) then
        local EntityScale = API.GetFloat(self:GetID(), QSB.ScriptingValue.Size);
        API.SetFloat(self.m_MarkerID, QSB.ScriptingValue.Size, EntityScale);
        Logic.SetModel(self.m_MarkerID, Models.Effects_E_Wealth);
        Logic.SetVisible(self.m_MarkerID, true);
    end
    self.m_MarkerVisibility = true;
    return self;
end

---
-- Versteckt den NPC-Marker des NPC.
--
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:HideMarker()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.m_MarkerID) then
        Logic.SetModel(self.m_MarkerID, Models.Effects_E_NullFX);
        Logic.SetVisible(self.m_MarkerID, false);
    end
    self.m_MarkerVisibility = false;
    return self;
end

---
-- Gibt true zurück, wenn der Marker des NPC sichtbar ist.
--
-- @return[type=boolen] Sichtbarkeit
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:IsMarkerVisible()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    return IsExisting(self.m_MarkerID) and self.m_MarkerVisibility == true;
end

---
-- Kontrolliert die Sichtbarkeit und die Position des NPC-Markers.
--
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:ControlMarker()
    -- Nur, wenn Standard-NPC
    if self.m_NpcType == 1 then
        if self:IsActive() and not self:HasTalkedTo() then
            -- Blinken
            if self:IsMarkerVisible() then
                self:HideMarker();
            else
                self:ShowMarker();
            end

            -- Repositionierung
            local x1,y1,z1 = Logic.EntityGetPos(self.m_MarkerID);
            local x2,y2,z2 = Logic.EntityGetPos(self:GetID());
            if math.abs(x1-x2) > 20 or math.abs(y1-y2) > 20 then
                Logic.DEBUG_SetPosition(self.m_MarkerID, x2, y2);
            end
        end
        -- Während Briefings immer verstecken
        if IsBriefingActive and IsBriefingActive() then
            self:HideMarker();
        end
    end
end

-- -------------------------------------------------------------------------- --

QSB.InteractiveObject = {
    m_Name         = nil,
    m_State        = 0,
    m_Distance     = 1000,
    m_Waittime     = 5,
    m_Used         = false,
    m_Active       = true,
    m_Slave        = nil,
    m_Costs        = {},
    m_Reward       = {},
};

function QSB.InteractiveObject:New(_Name)
    local Object = table.copy(self);
    Object.m_Name = _Name;
    return Object;
end

function QSB.InteractiveObject:SetDistance(_Distance)
    self.m_Distance = _Distance or 1000;
    return self;
end

function QSB.InteractiveObject:SetWaittime(_Time)
    self.m_Waittime = _Time or 5;
    return self;
end

function QSB.InteractiveObject:SetState(_State)
    self.m_State = _State or 0;
    return self;
end

function QSB.InteractiveObject:SetCosts(...)
    self.m_Costs = {unpack(arg)};
    return self;
end

function QSB.InteractiveObject:SetReward(...)
    self.m_Reward = {unpack(arg)};
    return self;
end

function QSB.InteractiveObject:SetIcon(_Icon)
    self.m_Icon = _Icon;
    if type(self.m_Icon) == "table" then
        self.m_Icon[3] = self.m_Icon[3] or 0;
    end
    return self;
end

function QSB.InteractiveObject:SetData(_Data)
    self.m_Data = _Data;
    return self;
end

function QSB.InteractiveObject:SetSlave(_ScriptName)
    self.m_Slave = _ScriptName;
    return self;
end

function QSB.InteractiveObject:SetActive(_Flag)
    self.m_Active = _Flag == true;
    return self;
end

function QSB.InteractiveObject:IsActive()
    return self.m_Active == true;
end

function QSB.InteractiveObject:SetUsed(_Flag)
    self.m_Used = _Flag == true;
    return self;
end

function QSB.InteractiveObject:IsUsed()
    return self.m_Used == true;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleInteractionCore);

