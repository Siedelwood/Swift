-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleInteractiveObjects                                     # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Interaktive Objekte sind Gegenstände auf der Karte, mit denen interagiert
-- werden kann. Diese Interaktion geschieht über einen Button. Ziel dieses
-- Bundels ist es, die funktionalität von interaktiven Objekten zu erweitern.
-- Es ist möglich, beliebige Objekte zu interaktiven Objekten zu machen.
--
-- Die Einsatzmöglichkeiten sind vielfältig. Wenn ein Gegenstand oder ein
-- Objekt mit einer Funktion versehen ist, kann dies in verschiedenem Kontext
-- an die Geschichte angepasst werden: z.B. Helbel öffnen eine Geheimtür,
-- ein Gegenstand wird vom Helden aufgehoben, eine Tür wird geöffnet, ...
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleInteractiveObjects = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erzeugt ein interaktives Objekt.
--
-- Die Parameter des interaktiven Objektes werden durch seine Beschreibung
-- festgelegt. Die Beschreibung ist eine Table, die bestimmte Werte für das
-- Objekt beinhaltet. Dabei müssen nicht immer alle Werte angegeben werden.
--
-- Mögliche Angaben:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Beschreibung</b></td>
-- <td><b>Optional</b></td>
-- </tr>
-- <tr>
-- <td>Name</td>
-- <td>Der Skriptname des Entity, das zum interaktiven Objekt wird.</td>
-- <td>nein</td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>Der angezeigter Name im Beschreibungsfeld.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>Der Beschreibungstext, der im Tooltip angezeigt wird.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Texture</td>
-- <td>Bestimmt die Icongrafik, die angezeigt wird. Dabei kann es sich um
-- eine Ingame-Grafik oder eine eigene Grafik halten.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Distance</td>
-- <td>Die minimale Entfernung zum Objekt, die ein Held benötigt um das
-- objekt zu aktivieren.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Waittime</td>
-- <td>Die Zeit, die ein Held benötigt, um das Objekt zu aktivieren. Die
-- Wartezeit ist nur für I_X_ Entities verfügbar.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Costs</td>
-- <td>Eine Table mit dem Typ und der Menge der Kosten.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Reward</td>
-- <td>Der Warentyp und die Menge der gefundenen Waren im Objekt.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Callback</td>
-- <td>Eine Funktion, die ausgeführt wird, sobald das Objekt aktiviert wird.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Condition</td>
-- <td>Eine Funktion, die vor der Aktivierung eine Beringung prüft.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>State</td>
-- <td>Bestimmt, wie sich der Button des interaktiven Objektes verhält.</td>
-- <td>ja</td>
-- </tr>
-- </table>
--
-- Zusätzlich können beliebige weitere Felder an das Objekt angehangen
-- werden. Sie sind ausnahmslos im Callback und in der Condition des Objektes
-- abrufbar.
--
-- <p><b>Alias:</b> CreateObject</p>
--
-- @param[type=table] _Description Beschreibung
-- @within Anwenderfunktionen
--
-- @usage
-- -- Ein einfaches Objekt erstellen:
-- CreateObject {
--     Name     = "hut",
--     Distance = 1500,
--     Callback = function(_Data)
--         API.Note("Do something...");
--     end,
-- }
--
function API.CreateObject(_Description)
    if GUI then
        return;
    end
    return BundleInteractiveObjects.Global:CreateObject(_Description);
end
CreateObject = API.CreateObject;

---
-- Aktiviert ein Interaktives Objekt, sodass es vom Spieler
-- aktiviert werden kann.
--
-- Der State bestimmt, ob es immer aktiviert werden kann, oder ob der Spieler
-- einen Helden benutzen muss. Wird der Parameter weggelassen, muss immer ein
-- Held das Objekt aktivieren.
--
-- <p><b>Alias</b>: InteractiveObjectActivate</p>
--
-- @param[type=string] _EntityName Skriptname des Objektes
-- @param[type=number] _State      State des Objektes
-- @within Anwenderfunktionen
--
function API.InteractiveObjectActivate(_ScriptName, _State)
    if not IO[_ScriptName] then
        API.ActivateIO(_ScriptName, _State);
        return;
    end
    local ScriptName = (IO[_ScriptName].m_Slave or _ScriptName);
    IO[_ScriptName]:SetActive(true);
    API.ActivateIO(ScriptName, _State);
end
InteractiveObjectActivate = API.InteractiveObjectActivate;

---
-- Deaktiviert ein interaktives Objekt, sodass es nicht mehr vom Spieler
-- benutzt werden kann.
--
-- <p><b>Alias</b>: InteractiveObjectDeactivate</p>
--
-- @param[type=string] _EntityName Scriptname des Objektes
-- @within Anwenderfunktionen
--
API.InteractiveObjectDeactivate = function(_ScriptName)
    if not IO[_ScriptName] then
        API.DeactivateIO(_ScriptName);
        return;
    end
    local ScriptName = (IO[_ScriptName].m_Slave or _ScriptName);
    IO[_ScriptName]:SetActive(false);
    API.DeactivateIO(ScriptName);
end
InteractiveObjectDeactivate = API.InteractiveObjectDeactivate;

---
-- Erzeugt eine Beschriftung für Custom Objects.
--
-- Im Questfenster werden die Namen von Custom Objects als ungesetzt angezeigt.
-- Mit dieser Funktion kann ein Name angelegt werden.
--
-- <p><b>Alias:</b> AddCustomIOName</p>
--
-- @param[type=string] _Key  Typname des Entity
-- @param              _Text Text der Beschriftung
-- @within Anwenderfunktionen
--
-- @usage
-- API.InteractiveObjectSetName("D_X_ChestClosed", {de = "Schatztruhe", en = "Treasure");
-- API.InteractiveObjectSetName("D_X_ChestOpenEmpty", "Leere Schatztruhe");
--
function API.InteractiveObjectSetName(_Key, _Text)
    _Text = API.Localize(_Text);
    if GUI then
        return;
    end
    IO_UserDefindedNames[_Key] = _Text;
end
AddCustomIOName = API.InteractiveObjectSetName;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleInteractiveObjects = {
    Global = {
        Data = {
            SlaveSequence = 0,
        }
    },
    Local = {
        Data = {},
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function BundleInteractiveObjects.Global:Install()
    IO = {};
    IO_UserDefindedNames = {};
    IO_SlaveToMaster = {};

    self:OverrideVanillaBehavior();
    self:HackOnInteractionEvent();
    self:StartObjectConditionController();
end

---
-- Erzeugt ein interaktives Objekt. Dabei können sowohl interaktive
-- Objekte (alle mit I_X_), eine Auswahl von normalen Entities und
-- sogar (sichtbare) XD_ScriptEntities verwendet werden.
--
-- @param[type=table] _Description Beschreibung
-- @within Internal
-- @local
--
function BundleInteractiveObjects.Global:CreateObject(_Description)
    -- Objekt erstellen
    local ID = GetID(_Description.Name);
    if ID == 0 then
        return;
    end
    local Object = InteractiveObject:New(_Description.Name)
        :SetDistance(_Description.Distance)
        :SetWaittime(_Description.Waittime)
        :SetCaption(_Description.Title)
        :SetDescription(_Description.Text)
        :SetAction(_Description.Callback)
        :SetCondition(_Description.Condition)
        :SetState(_Description.State)
        :SetIcon(_Description.Texture);
    
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
        self.Data.SlaveSequence = self.Data.SlaveSequence +1;
        local Name    = "QSB_SlaveObject_" ..self.Data.SlaveSequence;
        local x,y, z  = Logic.EntityGetPos(ID);
        local SlaveID = Logic.CreateEntity(Entities.I_X_DragonBoatWreckage, x, y, 0, 0);
        IO_SlaveToMaster[Name] = _Description.Name;
        Logic.SetEntityName(SlaveID, Name);
        Logic.SetModel(SlaveID, Models.Effects_E_Mosquitos);
        Object:SetSlave(Name);
    end

    -- Tatsächliches Objekt erstellen
    ID = (Object.m_Slave and GetID(Object.m_Slave)) or ID;
    Logic.InteractiveObjectClearCosts(ID);
    Logic.InteractiveObjectClearRewards(ID);
    Logic.InteractiveObjectSetInteractionDistance(ID,_Description.Distance);
    Logic.InteractiveObjectSetTimeToOpen(ID,_Description.Waittime);
    Logic.InteractiveObjectSetRewardResourceCartType(ID, Entities.U_ResourceMerchant);
    Logic.InteractiveObjectSetRewardGoldCartType(ID, Entities.U_GoldCart);
    Logic.InteractiveObjectSetCostResourceCartType(ID, Entities.U_ResourceMerchant);
    Logic.InteractiveObjectSetCostGoldCartType(ID, Entities.U_GoldCart);
    if _Description.Reward then
        Logic.InteractiveObjectAddRewards(ID, _Description.Reward[1], _Description.Reward[2]);
    end
    if _Description.Costs and _Description.Costs[1] then
        Logic.InteractiveObjectAddCosts(ID, _Description.Costs[1], _Description.Costs[2]);
    end
    if _Description.Costs and _Description.Costs[3] then
        Logic.InteractiveObjectAddCosts(ID, _Description.Costs[3], _Description.Costs[4]);
    end
    Logic.InteractiveObjectSetAvailability(ID, true);
    Logic.InteractiveObjectSetPlayerState(ID, QSB.HumanPlayerID, _Description.State or 0);
    table.insert(HiddenTreasures, ID);

    -- Aktivieren
    IO[_Description.Name] = Object;
    API.InteractiveObjectActivate(Logic.GetEntityName(ID), _Description.State or 0);
    return Object;
end

---
-- Überprüft die Bedingung aller nicht benutzten interaktiven Objekte.
--
-- @within Internal
-- @local
--
function BundleInteractiveObjects.Global:StartObjectConditionController()
    StartSimpleJobEx(function()
        for k, v in pairs(IO) do
            if v and not v:IsUsed() and v:IsActive() then
                v.m_Fullfilled = true;
                if v.m_Condition then
                    v.m_Fullfilled = v.m_Condition(v);
                end
            end
        end
    end);
end

---
-- Überschreibt Reward_ObjectInit, damit IO korrekt funktionieren.
--
-- @within Internal
-- @local
--
function BundleInteractiveObjects.Global:OverrideVanillaBehavior()
    if b_Reward_ObjectInit then
        b_Reward_ObjectInit.CustomFunction = function(_Behavior, _Quest)
            local eID = GetID(_Behavior.ScriptName);
            if eID == 0 then
                return;
            end
            QSB.InitalizedObjekts[eID] = _Quest.Identifier;
            
            local RewardTable = nil;
            if _Behavior.RewardType and _Behavior.RewardType ~= "-" then
                RewardTable = {Goods[_Behavior.RewardType], _Behavior.RewardAmount};
            end

            local CostsTable = nil;
            if _Behavior.FirstCostType and _Behavior.FirstCostType ~= "-" then
                CostsTable = {Goods[_Behavior.FirstCostType], _Behavior.FirstCostAmount};
                if _Behavior.SecondCostType and _Behavior.SecondCostType ~= "-" then
                    table.insert(CostsTable, Goods[_Behavior.SecondCostType]);
                    table.insert(CostsTable, _Behavior.SecondCostAmount);
                end
            end

            API.CreateObject{
                Name        = _Behavior.ScriptName,
                State       = _Behavior.UsingState or 0,
                Distance    = _Behavior.Distance,
                Waittime    = _Behavior.Waittime,
                Reward      = RewardTable,
                Costs       = CostsTable,
            };
        end
    end
end

---
-- Überschreibt die Events, die ausgelöst werden, wenn interaktive Objekte
-- benutzt werden.
--
-- @within Internal
-- @local
--
function BundleInteractiveObjects.Global:HackOnInteractionEvent()
    GameCallback_OnObjectInteraction = function(_EntityID, _PlayerID)
        OnInteractiveObjectOpened(_EntityID, _PlayerID);
        OnTreasureFound(_EntityID, _PlayerID);
        local ScriptName = Logic.GetEntityName(_EntityID);
        
        for k,v in pairs(IO)do
            if k == ScriptName or v.m_Slave == ScriptName then
                if not v.m_Used then
                    IO[k].m_Used = true;
                    if v.m_Action then
                        v.m_Action(v, _PlayerID);
                    end
                end
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
                if IO[EntityName].m_Used ~= true then
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

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleInteractiveObjects.Local:Install()
    IO = Logic.CreateReferenceToTableInGlobaLuaState("IO");
    IO_UserDefindedNames = Logic.CreateReferenceToTableInGlobaLuaState("IO_UserDefindedNames");
    IO_SlaveToMaster = Logic.CreateReferenceToTableInGlobaLuaState("IO_SlaveToMaster");

    self:ActivateInteractiveObjectControl();
end

---
-- Überschreibt die Spielfunktione, die interaktive Objekte steuern.
--
-- @within Internal
-- @local
--
function BundleInteractiveObjects.Local:ActivateInteractiveObjectControl()
    GUI_Interaction.InteractiveObjectClicked_Orig_BundleInteractiveObjects = GUI_Interaction.InteractiveObjectClicked
    GUI_Interaction.InteractiveObjectClicked = function()
        local i = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()));
        local EntityID = g_Interaction.ActiveObjectsOnScreen[i];
        if not EntityID then
            return;
        end
        local ScriptName = Logic.GetEntityName(EntityID);
        if IO_SlaveToMaster[ScriptName] then
            ScriptName = IO_SlaveToMaster[ScriptName];
        end
        if not IO[ScriptName] then
            GUI_Interaction.InteractiveObjectClicked_Orig_BundleInteractiveObjects();
            return;
        end
        if not IO[ScriptName].m_Fullfilled then
            Message(XGUIEng.GetStringTableText("UI_ButtonDisabled/PromoteKnight"));
            return;
        end
        GUI_Interaction.InteractiveObjectClicked_Orig_BundleInteractiveObjects();
    end
    
    GUI_Interaction.InteractiveObjectUpdate_Orig_BundleInteractiveObjects = GUI_Interaction.InteractiveObjectUpdate;
    GUI_Interaction.InteractiveObjectUpdate = function()
        GUI_Interaction.InteractiveObjectUpdate_Orig_BundleInteractiveObjects();
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
                -- Tooltip
                if IO[ScriptName] then
                    BundleInteractiveObjects.Local:SetIcon(Widget, IO[ScriptName].m_Icon);
                end
            end
        end
    end

    GUI_Interaction.InteractiveObjectMouseOver_Orig_BundleInteractiveObjects = GUI_Interaction.InteractiveObjectMouseOver;
    GUI_Interaction.InteractiveObjectMouseOver = function()
        local PlayerID = GUI.GetPlayerID();
        local ButtonNumber = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()));
        local ObjectID = g_Interaction.ActiveObjectsOnScreen[ButtonNumber];
        local EntityType = Logic.GetEntityType(ObjectID);

        if g_GameExtraNo > 0 then
            local EntityTypeName = Logic.GetEntityTypeName(EntityType);
            if Inside (EntityTypeName, {"R_StoneMine", "R_IronMine", "B_Cistern", "B_Well", "I_X_TradePostConstructionSite"}) then
                GUI_Interaction.InteractiveObjectMouseOver_Orig_BundleInteractiveObjects();
                return;
            end
        end
        local EntityTypeName = Logic.GetEntityTypeName(EntityType);
        if string.find(EntityTypeName, "^I_X_") and tonumber(Logic.GetEntityName(ObjectID)) ~= nil then
            GUI_Interaction.InteractiveObjectMouseOver_Orig_BundleInteractiveObjects();
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
            local Title = IO[ScriptName].m_Caption or XGUIEng.GetStringTableText("UI_ObjectNames/InteractiveObjectAvailable");
            local Text  = IO[ScriptName].m_Description or XGUIEng.GetStringTableText("UI_ObjectDescription/InteractiveObjectAvailable");
            Costs = IO[ScriptName].m_Costs;
            if Costs and Costs[1] and Logic.GetGoodCategoryForGoodType(Costs[1]) ~= GoodCategories.GC_Resource then
                CheckSettlement = true;
            end
            BundleInteractiveObjects.Local:TextCosts(Title, Text, nil, {Costs[1], Costs[2], Costs[3], Costs[4]}, CheckSettlement);
            return;
        end
    end

    GUI_Interaction.DisplayQuestObjective_Orig_BundleInteractiveObjects = GUI_Interaction.DisplayQuestObjective;
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

        if QuestType == Objective.Object then
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
                        ObjectName = API.Localize(IO_UserDefindedNames[ObjectTypeName]);
                    end
                    if ObjectName == nil then
                        ObjectName = API.Localize(IO_UserDefindedNames[ObjectEntityName]);
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
            GUI_Interaction.DisplayQuestObjective_Orig_BundleInteractiveObjects(_QuestIndex, _MessageKey);
        end
    end
end

---
-- Setzt den Kostentooltip des aktuellen Widgets.
--
-- @param[type=string]  _Title Titel des Tooltip
-- @param[type=string]  _Text Text des Tooltip
-- @param[type=string]  _DisabledText (optional) Textzusatz wenn inaktiv
-- @param[type=table]   _Costs Kostentabelle
-- @param[type=boolean] _InSettlement Kosten in Siedlung suchen
-- @within Internal
-- @local
--
function BundleInteractiveObjects.Local:TextCosts(_Title, _Text, _DisabledText, _Costs, _InSettlement)
    local TooltipContainerPath = "/InGame/Root/Normal/TooltipBuy"
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath)
    local TooltipNameWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Name")
    local TooltipDescriptionWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Text")
    local TooltipBGWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/BG")
    local TooltipFadeInContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn")
    local TooltipCostsContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/Costs")
    local PositionWidget = XGUIEng.GetCurrentWidgetID()
    GUI_Tooltip.ResizeBG(TooltipBGWidget, TooltipDescriptionWidget)
    GUI_Tooltip.SetCosts(TooltipCostsContainer, _Costs, _InSettlement)
    local TooltipContainerSizeWidgets = {TooltipContainer, TooltipCostsContainer, TooltipBGWidget}
    GUI_Tooltip.SetPosition(TooltipContainer, TooltipContainerSizeWidgets, PositionWidget, nil, true)
    GUI_Tooltip.OrderTooltip(TooltipContainerSizeWidgets, TooltipFadeInContainer, TooltipCostsContainer, PositionWidget, TooltipBGWidget)
    GUI_Tooltip.FadeInTooltip(TooltipFadeInContainer)

    _DisabledText = _DisabledText or "";
    local disabled = ""
    if XGUIEng.IsButtonDisabled(PositionWidget) == 1 and _DisabledText ~= "" and _Text ~= "" then
        disabled = disabled .. "{cr}{@color:255,32,32,255}" .. _DisabledText
    end

    XGUIEng.SetText(TooltipNameWidget, "{center}" .. _Title)
    XGUIEng.SetText(TooltipDescriptionWidget, _Text .. disabled)
    local Height = XGUIEng.GetTextHeight(TooltipDescriptionWidget, true)
    local W, H = XGUIEng.GetWidgetSize(TooltipDescriptionWidget)
    XGUIEng.SetWidgetSize(TooltipDescriptionWidget, W, Height)
end

---
-- Ändert die Textur eines Icons des aktuellen Widget.
-- TODO: Eigene Matrizen funktionieren nicht - Grund unbekannt.
--
-- @param[type=string] _Widget Icon Widget
-- @param              _Icon Icon Textur (Dateiname oder Positionsmatrix)
-- @within Internal
-- @local
--
function BundleInteractiveObjects.Local:SetIcon(_Widget, _Icon)
    if type(_Icon) == "table" then
        if type(_Icon[3]) == "string" then
            local ButtonState = 1;
            if XGUIEng.IsButton(_Widget) == 1 then
                ButtonState = 7;
            end

            local u0, u1, v0, v1;
            u0 = (_Icon[1] - 1) * 64;
            v0 = (_Icon[2] - 1) * 64;
            u1 = (_Icon[1]) * 64;
            v1 = (_Icon[2]) * 64;
            XGUIEng.SetMaterialAlpha(_Widget, ButtonState, 255);
            XGUIEng.SetMaterialTexture(_Widget, ButtonState, _Icon[3].. "big.png");
            XGUIEng.SetMaterialUV(_Widget, ButtonState, u0, v0, u1, v1);
        else
            SetIcon(_Widget, _Icon);
        end
    else
        local screenSize = {GUI.GetScreenSize()};
        local Scale = 330;
        if screenSize[2] >= 800 then
            Scale = 260;
        end
        if screenSize[2] >= 1000 then
            Scale = 210;
        end
        XGUIEng.SetMaterialAlpha(_Widget, 1, 255);
        XGUIEng.SetMaterialTexture(_Widget, 1, _Icon);
        XGUIEng.SetMaterialUV(_Widget, 1, 0, 0, Scale, Scale);
    end
end

-- -------------------------------------------------------------------------- --

InteractiveObject = {
    m_Name        = nil,
    m_State       = 0,
    m_Distance    = 1000,
    m_Waittime    = 5,
    m_Used        = false,
    m_Fullfilled  = true,
    m_Active      = false,
    m_Slave       = nil,
    m_Caption     = nil,
    m_Description = nil,
    m_Condition   = nil,
    m_Action      = nil,
    m_Icon        = {14, 10},
    m_Costs       = {},
    m_Reward      = {},
};

function InteractiveObject:New(_Name)
    local Object = API.InstanceTable(self);
    Object.m_Name = _Name;
    return Object;
end

function InteractiveObject:SetDistance(_Distance)
    self.m_Distance = _Distance or 1000;
    return self;
end

function InteractiveObject:SetWaittime(_Time)
    self.m_Waittime = _Time or 5;
    return self;
end

function InteractiveObject:SetState(_State)
    self.m_State = _State or 0;
    return self;
end

function InteractiveObject:SetCaption(_Text)
    if _Text then
        self.m_Caption = API.Localize(_Text);
    end
    return self;
end

function InteractiveObject:SetDescription(_Text)
    if _Text then
        self.m_Description = API.Localize(_Text);
    end
    return self;
end

function InteractiveObject:SetCosts(...)
    self.m_Costs = {unpack(arg)};
    return self;
end

function InteractiveObject:SetReward(...)
    self.m_Reward = {unpack(arg)};
    return self;
end

function InteractiveObject:SetCondition(_Function)
    self.m_Condition = _Function;
    return self;
end

function InteractiveObject:SetAction(_Function)
    self.m_Action = _Function;
    return self;
end

function InteractiveObject:SetIcon(_Icon)
    self.m_Icon = _Icon;
    return self;
end

function InteractiveObject:SetSlave(_ScriptName)
    self.m_Slave = _ScriptName;
    return self;
end

function InteractiveObject:SetActive(_Flag)
    self.m_Active = _Flag == true;
    return self;
end

function InteractiveObject:IsActive()
    return self.m_Active == true;
end

function InteractiveObject:SetUsed(_Flag)
    self.m_Used = _Flag == true;
    return self;
end

function InteractiveObject:IsUsed()
    return self.m_Used == true;
end

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss bis zu 4 interaktive Objekte benutzen.
--
-- @param[type=string] _ScriptName1 Erstes Objekt
-- @param[type=string] _ScriptName2 (optional) Zweites Objekt
-- @param[type=string] _ScriptName3 (optional) Drittes Objekt
-- @param[type=string] _ScriptName4 (optional) Viertes Objekt
--
-- @within Goal
--
function Goal_ActivateSeveralObjects(...)
    return b_Goal_ActivateSeveralObjects:new(...);
end

b_Goal_ActivateSeveralObjects = {
    Name = "Goal_ActivateSeveralObjects",
    Description = {
        en = "Goal: Activate an interactive object",
        de = "Ziel: Aktiviere ein interaktives Objekt",
    },
    Parameter = {
        { ParameterType.Default, en = "Object name 1", de = "Skriptname 1" },
        { ParameterType.Default, en = "Object name 2", de = "Skriptname 2" },
        { ParameterType.Default, en = "Object name 3", de = "Skriptname 3" },
        { ParameterType.Default, en = "Object name 4", de = "Skriptname 4" },
    },
    ScriptNames = {};
}

function b_Goal_ActivateSeveralObjects:GetGoalTable()
    return {Objective.Object, { unpack(self.ScriptNames) } }
end

function b_Goal_ActivateSeveralObjects:AddParameter(_Index, _Parameter)
    if _Index == 0 then
        assert(_Parameter ~= nil and _Parameter ~= "", "Goal_ActivateSeveralObjects: At least one IO needed!");
    end
    if _Parameter ~= nil and _Parameter ~= "" then
        table.insert(self.ScriptNames, _Parameter);
    end
end

function b_Goal_ActivateSeveralObjects:GetMsgKey()
    return "Quest_Object_Activate"
end

Core:RegisterBehavior(b_Goal_ActivateSeveralObjects);

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleInteractiveObjects");

