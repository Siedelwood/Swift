-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleInteractiveObjects                                     # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht die Manipulation der Interaktiven Objekte und das Erstellen 
-- völlig neuer eigener Objekte.
--
-- @module BundleInteractiveObjects
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

QSB.IOList = {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erzeugt ein interaktives Objekt nach alter Schreibweise.
--
-- Diese Funktion ist ein Mapping für die veraltete Schreibweise. Du kannst
-- dich hiermit ermutigt fühlen, API.CreateObject zu verwenden!
--
-- <b>Alias:</b> SetupInteractiveObject
--
-- @param _Name          Skriptname des Objekts
-- @param _Description   Beschreibung
-- @within Public
--
function API.SetupInteractiveObject(_Name, _Description)
    if GUI then
        API.Dbg("API.SetupInteractiveObject: Can not be used from local enviorment!");
        return;
    end
    if not IsExisting(_Name) then
        API.Dbg("API.SetupInteractiveObject: Entity \"" .._Name.. "\" is invalid!");
        return;
    end
    return BundleInteractiveObjects.Global:CreateObject(_Description);
end
SetupInteractiveObject = API.SetupInteractiveObject;

---
-- Erzeugt ein interaktives Objekt nach alter Schreibweise.
--
-- <b>Alias:</b> CreateObject
--
-- @param _Name          Skriptname des Objekts
-- @param _Description   Beschreibung
-- @within Public
--
function API.CreateObject(_Description)
    if GUI then
        API.Dbg("API.CreateObject: Can not be used from local enviorment!");
        return;
    end
    return BundleInteractiveObjects.Global:CreateObject(_Description);
end
CreateObject = API.CreateObject;

---
-- Löscht ein interaktives Objekt.
--
-- Das Entity wird dabei nicht gelöscht. Es wird ausschließlich die
-- Konfiguration des Objektes entfernt.
--
-- <b>Alias:</b> RemoveInteractiveObject
--
-- @param _EntityName Skriptname des IO
-- @within Public
--
function API.RemoveInteractiveObject(_EntityName)
    if GUI then
        API.Bridge("API.RemoveInteractiveObject('" .._EntityName.. "')");
        return;
    end
    if not IsExisting(_EntityName) then
        API.Warn("API.RemoveInteractiveObject: Entity \"" .._EntityName.. "\" is invalid!");
        return;
    end
    return BundleInteractiveObjects.Global:RemoveInteractiveObject(_EntityName);
end
RemoveInteractiveObject = API.RemoveInteractiveObject;

---
-- Deaktiviert ein Interaktives Objekt, sodass es nicht mehr vom Spieler
-- aktiviert werden kann.
-- 
-- <b>Alias</b>: InteractiveObjectActivate
--
-- @param _EntityName Skriptname des Objektes
-- @param _State      State des Objektes
-- @within Public
--
function API.InteractiveObjectActivate(_EntityName, _State)
    if GUI then
        API.Bridge("API.InteractiveObjectActivate('" .._EntityName.. "', " ..tostring(_State).. ")");
        return;
    end
    if not IsExisting(_EntityName) then
        API.Warn("API.InteractiveObjectActivate: Entity \"" .._EntityName.. "\" is invalid!");
        return;
    end
    
    if not Logic.IsInteractiveObject(GetID(_EntityName)) then
        if IO[_EntityName] then
            IO[_EntityName].Inactive = false;
            IO[_EntityName].Used = false;
        end
    else
        API.ActivateIO(_EntityName, _State);
    end
end
InteractiveObjectActivate = API.InteractiveObjectActivate;

---
-- Aktiviert ein interaktives Objekt, sodass es benutzt werden kann.
--
-- Der State bestimmt, ob es immer aktiviert werden kann, oder ob der Spieler
-- einen Helden benutzen muss. Wird der Parameter weggelassen, muss immer ein
-- Held das Objekt aktivieren.
-- 
-- <b>Alias</b>: InteractiveObjectDeactivate
--
-- @param _EntityName Scriptname des Objektes
-- @within Public
--
function API.InteractiveObjectDeactivate(_EntityName)
    if GUI then
        API.Bridge("API.InteractiveObjectDeactivate('" .._EntityName.. "')");
        return;
    end
    if not IsExisting(_EntityName) then
        API.Warn("API.InteractiveObjectDeactivate: Entity \"" .._EntityName.. "\" is invalid!");
        return;
    end
    
    if not Logic.IsInteractiveObject(GetID(_EntityName)) then
        if IO[_EntityName] then
            IO[_EntityName].Inactive = true;
        end
    else
        API.DeactivateIO(_EntityName);
    end
end
InteractiveObjectDeactivate = API.InteractiveObjectDeactivate;

---
-- Erzeugt eine Beschriftung für Custom Objects.
--
-- Im Questfenster werden die Namen von Cusrom Objects als ungesetzt angezeigt.
-- Mit dieser Funktion kann ein Name angelegt werden.
--
-- <b>Alias:</b> AddCustomIOName
--
-- @param _Key  Identifier der Beschriftung
-- @param _Text Text der Beschriftung
-- @within Public
--
function API.AddCustomIOName(_Key, _Text)
    if type(_Text == "table") then
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        _Text = _Text[lang];
    end
    if GUI then
        API.Bridge("API.AddCustomIOName('" .._Key.. "', '" .._Text.. "')");
        return;
    end
    return BundleInteractiveObjects.Global:AddCustomIOName(_Key, _Text);
end
AddCustomIOName = API.AddCustomIOName;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleInteractiveObjects = {
    Global = {
        Data = {}
    },
    Local = {
        Data = {
            IOCustomNames = {},
            IOCustomNamesByEntityName = {},
        },
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Private
-- @local
--
function BundleInteractiveObjects.Global:Install()
    IO = {};
end

---
-- Erzeugt ein interaktives Objekt. Dabei können sowohl interaktive
-- Objekte (alle mit I_X_), eine Auswahl von normalen Entities und
-- sogar (sichtbare) XD_ScriptEntities verwendet werden.
-- Name, Titel und Icon müssen immer angegeben werden. Die restlichen
-- Angaben hängen teilweise vom Typ der Entity, teilweise vom
-- Verwendungszweck ab.
--
-- @param _Description Beschreibung
-- @within Private
-- @local
--
function BundleInteractiveObjects.Global:CreateObject(_Description)
    local lang = Network.GetDesiredLanguage();

    self:HackOnInteractionEvent();
    self:RemoveInteractiveObject(_Description.Name);

    if type(_Description.Title) == "table" then
        _Description.Title = _Description.Title[lang];
    end
    if not _Description.Title or _Description.Title == "" then
        _Description.Title = (lang == "de" and "Interaktion") or "Interaction";
    end

    if type(_Description.Text) == "table" then
        _Description.Text = _Description.Text[lang];
    end
    if not _Description.Text then
        _Description.Text = "";
    end

    if type(_Description.WrongKnight) == "table" then
        _Description.WrongKnight = _Description.WrongKnight[lang];
    end
    _Description.WrongKnight = _Description.WrongKnight or "";

    if type(_Description.ConditionUnfulfilled) == "table" then
        _Description.ConditionUnfulfilled = _Description.ConditionUnfulfilled[lang];
    end
    _Description.ConditionUnfulfilled = _Description.ConditionUnfulfilled or "";

    _Description.Condition = _Description.Condition or function() return true end
    _Description.Callback = _Description.Callback or function() end
    _Description.Distance = _Description.Distance or 1200;
    _Description.Waittime = _Description.Waittime or 15;
    _Description.Texture = _Description.Texture or {14,10};
    _Description.Reward = _Description.Reward or {};
    _Description.Costs = _Description.Costs or {};
    _Description.State = _Description.State or 0;

    Logic.ExecuteInLuaLocalState([[
        QSB.IOList[#QSB.IOList+1] = "]].._Description.Name..[["
        if not BundleInteractiveObjects.Local.Data.InteractionHackStarted then
            BundleInteractiveObjects.Local:ActivateInteractiveObjectControl()
            BundleInteractiveObjects.Local.Data.InteractionHackStarted = true;
        end
    ]]);
    IO[_Description.Name] = API.InstanceTable(_Description);

    local eID = GetID(_Description.Name);
    if Logic.IsInteractiveObject(eID) == true then
        Logic.InteractiveObjectClearCosts(eID);
        Logic.InteractiveObjectClearRewards(eID);
        Logic.InteractiveObjectSetInteractionDistance(eID,_Description.Distance);
        Logic.InteractiveObjectSetTimeToOpen(eID,_Description.Waittime);
        Logic.InteractiveObjectAddRewards(eID,_Description.Reward[1],_Description.Reward[2]);
        Logic.InteractiveObjectAddCosts(eID,_Description.Costs[1],_Description.Costs[2]);
        Logic.InteractiveObjectAddCosts(eID,_Description.Costs[3],_Description.Costs[4]);

        Logic.InteractiveObjectSetAvailability(eID, true);
        Logic.InteractiveObjectSetPlayerState(eID, _Description.PlayerID or 1, _Description.State);
        Logic.InteractiveObjectSetRewardResourceCartType(eID, Entities.U_ResourceMerchant);
        Logic.InteractiveObjectSetRewardGoldCartType(eID, Entities.U_GoldCart);
        Logic.InteractiveObjectSetCostGoldCartType(eID, Entities.U_GoldCart);
        Logic.InteractiveObjectSetCostResourceCartType(eID, Entities.U_ResourceMerchant);
        table.insert(HiddenTreasures,eID);
    end
end

---
-- Löscht ein interaktives Objekt.
--
-- Das Entity wird dabei nicht gelöscht. Es wird ausschließlich die
-- Konfiguration des Objektes entfernt.
--
-- @param _EntityName Skriptname des IO
-- @within Private
-- @local
--
function BundleInteractiveObjects.Global:RemoveInteractiveObject(_EntityName)
    for k,v in pairs(IO) do
        if k == _EntityName then
            Logic.ExecuteInLuaLocalState([[
                IO["]].._EntityName..[["] = nil;
            ]]);
            IO[_EntityName] = nil;
        end
    end
end

---
-- Erzeugt eine Beschriftung für Custom Objects.
--
-- Im Questfenster werden die Namen von Cusrom Objects als ungesetzt angezeigt.
-- Mit dieser Funktion kann ein Name angelegt werden.
--
-- @param _Key  Identifier der Beschriftung
-- @param _Text Text der Beschriftung
-- @within Private
-- @local
--
function BundleInteractiveObjects.Global:AddCustomIOName(_Key, _Text)
    if type(_Text) == "table" then
        local GermanText  = _Text.de;
        local EnglishText = _Text.en;

        Logic.ExecuteInLuaLocalState([[
            BundleInteractiveObjects.Local.Data.IOCustomNames["]].._Key..[["] = {
                de = "]]..GermanText..[[",
                en = "]]..EnglishText..[["
            }
        ]]);
    else
        Logic.ExecuteInLuaLocalState([[
            BundleInteractiveObjects.Local.Data.IOCustomNames["]].._Key..[["] = "]].._Text..[["
        ]]);
    end
end

---
-- Überschreibt die Events, die ausgelöst werden, wenn interaktive Objekte
-- benutzt werden.
--
-- @within Private
-- @local
--
function BundleInteractiveObjects.Global:HackOnInteractionEvent()
    if not BundleInteractiveObjects.Global.Data.InteractionEventHacked then
        StartSimpleJobEx(BundleInteractiveObjects.Global.ControlInteractiveObjects);
        BundleInteractiveObjects.Global.Data.InteractionEventHacked = true;

        OnTreasureFound = function(_TreasureID, _PlayerID)
            for i=1, #HiddenTreasures do
                local HiddenTreasureID = HiddenTreasures[i]
                if HiddenTreasureID == _TreasureID then
                    Logic.InteractiveObjectSetAvailability(_TreasureID,false)
                    for PlayerID = 1, 8 do
                        Logic.InteractiveObjectSetPlayerState(_TreasureID,PlayerID, 2)
                    end
                    table.remove(HiddenTreasures,i)
                    HiddenTreasures[0] = #HiddenTreasures

                    local ActivationSound = "menu_left_prestige";
                    local eName = Logic.GetEntityName(_TreasureID);
                    if IO[eName] and IO[eName].ActivationSound then
                        ActivationSound = IO[eName].ActivationSound;
                    end
                    Logic.ExecuteInLuaLocalState("Play2DSound(" .. _PlayerID ..",'" .. ActivationSound .. "')");
                end
            end
        end

        GameCallback_OnObjectInteraction = function(__entityID_, _PlayerID)
            local eName = Logic.GetEntityName(__entityID_);
            for k,v in pairs(IO)do
                if k == eName then
                    if not v.Used then
                        IO[k].Used = true;
                        v.Callback(v, _PlayerID);
                    end
                end
            end
            OnInteractiveObjectOpened(__entityID_, _PlayerID);
            OnTreasureFound(__entityID_, _PlayerID);
        end

        GameCallback_ExecuteCustomObjectReward = function(_PlayerID, _SpawnID, _Type, _Amount)
            if not Logic.IsInteractiveObject(GetID(_SpawnID)) then
                local pos = GetPosition(_SpawnID);
                local resCat = Logic.GetGoodCategoryForGoodType(_Type);
                local ID;
                if resCat == GoodCategories.GC_Resource then
                    ID = Logic.CreateEntityOnUnblockedLand(Entities.U_ResourceMerchant, pos.X, pos.Y,0,_PlayerID);
                elseif _Type == Goods.G_Medicine then
                    ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Medicus, pos.X, pos.Y,0,_PlayerID);
                elseif _Type == Goods.G_Gold then
                    ID = Logic.CreateEntityOnUnblockedLand(Entities.U_GoldCart, pos.X, pos.Y,0,_PlayerID);
                else
                    ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Marketer, pos.X, pos.Y,0,_PlayerID);
                end
                Logic.HireMerchant(ID,_PlayerID,_Type,_Amount,_PlayerID);
            end
        end

        function QuestTemplate:AreObjectsActivated(objectList)
            for i=1, objectList[0] do
                if not objectList[-i] then
                    objectList[-i] = GetEntityId(objectList[i]);
                end
                local EntityName = Logic.GetEntityName(objectList[-i]);
                local interactive = IO[EntityName];

                if Logic.IsInteractiveObject(objectList[-i]) then
                    if not IsInteractiveObjectOpen(objectList[-i]) then
                        return false;
                    end
                else
                    if not interactive then
                        return false;
                    end
                    if interactive.Used ~= true then
                        return false;
                    end
                end
            end
            return true;
        end
    end
end

---
-- Prüft für alle unbenutzten interaktiven Objekte, ob ihre Bedingung erfüllt 
-- ist und erlaubt die Benutzung.
--
-- @within Private
-- @local
--
function BundleInteractiveObjects.Global.ControlInteractiveObjects()
    for k,v in pairs(IO) do
        if not v.Used == true then
            v.ConditionFullfilled = v.Condition(v);
        end
    end
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Private
-- @local
--
function BundleInteractiveObjects.Local:Install()
    IO = Logic.CreateReferenceToTableInGlobaLuaState("IO");
end

---
-- Prüft, ob die Kosten für ein interaktives Objekt beglichen werden können.
--
-- @param _PlayerID Spieler, der zahlt
-- @param _Good     Typ der Ware
-- @param _Amount   Menge der Ware
-- @within Private
-- @local
--
function BundleInteractiveObjects.Local:CanBeBought(_PlayerID, _Good, _Amount)
    local AmountOfGoods = GetPlayerGoodsInSettlement(_Good, _PlayerID, true);
    if AmountOfGoods < _Amount then
        return false;
    end
    return true;
end

---
-- Zieht die Kosten des Objektes aus dem Lagerhaus des Spielers ab.
--
-- @param _PlayerID Spieler, der zahlt
-- @param _Good     Typ der Ware
-- @param _Amount   Menge der Ware
-- @within Private
-- @local
--
function BundleInteractiveObjects.Local:BuyObject(_PlayerID, _Good, _Amount)
    if Logic.GetGoodCategoryForGoodType(_Good) ~= GoodCategories.GC_Resource and _Good ~= Goods.G_Gold then
        local buildings = GetPlayerEntities(_PlayerID,0);
        local goodAmount = _Amount;
        for i=1,#buildings do
            if Logic.IsBuilding(buildings[i]) == 1 and goodAmount > 0 then
                if Logic.GetBuildingProduct(buildings[i]) == _Good then
                    local goodAmountInBuilding = Logic.GetAmountOnOutStockByIndex(buildings[i],0);
                    for j=1,goodAmountInBuilding do
                        API.Bridge("Logic.RemoveGoodFromStock("..buildings[i]..",".._Good..",1)");
                        goodAmount = goodAmount -1;
                    end
                end
            end
        end
    else
        API.Bridge("AddGood(".._Good..","..(_Amount*(-1))..",".._PlayerID..")");
    end
end

---
-- Überschreibt die Spielfunktione, die interaktive Objekte steuern.
--
-- @within Private
-- @local
--
function BundleInteractiveObjects.Local:ActivateInteractiveObjectControl()
    g_Interaction.ActiveObjectsOnScreen = g_Interaction.ActiveObjectsOnScreen or {};
    g_Interaction.ActiveObjects = g_Interaction.ActiveObjects or {};

    GUI_Interaction.InteractiveObjectUpdate = function()
        local PlayerID = GUI.GetPlayerID();
        if g_Interaction.ActiveObjects == nil then
            return;
        end

        for i = 1, #g_Interaction.ActiveObjects do
            local ObjectID = g_Interaction.ActiveObjects[i];
            local X, Y = GUI.GetEntityInfoScreenPosition(ObjectID);
            local ScreenSizeX, ScreenSizeY = GUI.GetScreenSize();

            if X ~= 0 and Y ~= 0 and X > -50 and Y > -50 and X < (ScreenSizeX + 50) and Y < (ScreenSizeY + 50) then
                if Inside(ObjectID, g_Interaction.ActiveObjectsOnScreen) == false then
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
            local Widget = "/InGame/Root/Normal/InteractiveObjects/" .. i;
            if XGUIEng.IsWidgetExisting(Widget) == 1 then
                local ObjectID = g_Interaction.ActiveObjectsOnScreen[i];
                local EntityType = Logic.GetEntityType(ObjectID);
                local X, Y = GUI.GetEntityInfoScreenPosition(ObjectID);
                local WidgetSize = {XGUIEng.GetWidgetScreenSize(Widget)};
                local BaseCosts = {Logic.InteractiveObjectGetCosts(ObjectID)};
                local EffectiveCosts = {Logic.InteractiveObjectGetEffectiveCosts(ObjectID, PlayerID)};
                local IsAvailable = Logic.InteractiveObjectGetAvailability(ObjectID);
                local eType = Logic.GetEntityType(ObjectID);
                local entityName = Logic.GetEntityName(ObjectID);
                local eTypeName = Logic.GetEntityTypeName(eType);
                local Disable = false;

                XGUIEng.SetWidgetScreenPosition(Widget, X - (WidgetSize[1]/2), Y - (WidgetSize[2]/2));

                if BaseCosts[1] ~= nil and EffectiveCosts[1] == nil and IsAvailable == true then
                    Disable = true;
                end
                local HasSpace = Logic.InteractiveObjectHasPlayerEnoughSpaceForRewards(ObjectID, PlayerID);
                if HasSpace == false then
                    Disable = true;
                end
                if Disable == true then
                    XGUIEng.DisableButton(Widget, 1);
                else
                    XGUIEng.DisableButton(Widget, 0);
                end

                if GUI_Interaction.InteractiveObjectUpdateEx1 ~= nil then
                    GUI_Interaction.InteractiveObjectUpdateEx1(Widget, EntityType);
                end
                if IO[entityName] then
                    BundleInteractiveObjects.Local:SetIcon(Widget,IO[entityName].Texture);
                end
                XGUIEng.ShowWidget(Widget, 1);
            end
        end

        for k,v in pairs(QSB.IOList) do
            local pID = GUI.GetPlayerID();
            local eType = Logic.GetEntityType(GetID(v));
            local eTypeName = Logic.GetEntityTypeName(eType);
            if eTypeName and v ~= "" then
                if  not(string.find(eTypeName,"I_X_")) and not(string.find(eTypeName,"Mine"))
                and not(string.find(eTypeName,"B_Wel")) and not(string.find(eTypeName,"B_Cis")) then
                    if IO[v].State == 0 and IO[v].Distance ~= nil and IO[v].Distance > 0 then
                        local knights = {};
                        Logic.GetKnights(pID,knights);

                        local found = false;
                        for i=1,#knights do
                            if IsNear(knights[i], v, IO[v].Distance) then
                                found = true;
                                break;
                            end
                        end
                        if not IO[v].Used and not IO[v].Inactive then
                            if found then
                                ScriptCallback_ObjectInteraction(pID,GetID(v));
                            else
                                ScriptCallback_CloseObjectInteraction(pID,GetID(v));
                            end
                        else
                            ScriptCallback_CloseObjectInteraction(pID,GetID(v));
                        end
                    else
                        if not IO[v].Used and not IO[v].Inactive then
                            ScriptCallback_ObjectInteraction(pID,GetID(v));
                        else
                            ScriptCallback_CloseObjectInteraction(pID,GetID(v));
                        end
                    end
                end
            end
        end

        for i = #g_Interaction.ActiveObjectsOnScreen + 1, 2 do
            local Widget = "/InGame/Root/Normal/InteractiveObjects/" .. i;
            XGUIEng.ShowWidget(Widget, 0);
        end
    end

    GUI_Interaction.InteractiveObjectMouseOver = function()
        local PlayerID = GUI.GetPlayerID();
        local ButtonNumber = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()));
        local ObjectID = g_Interaction.ActiveObjectsOnScreen[ButtonNumber];
        local EntityType = Logic.GetEntityType(ObjectID);

        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local Costs = {Logic.InteractiveObjectGetEffectiveCosts(ObjectID, PlayerID)};
        local IsAvailable = Logic.InteractiveObjectGetAvailability(ObjectID);

        local TooltipTextKey;
        local TooltipDisabledTextKey;
        local eName = Logic.GetEntityName(ObjectID);

        if IsAvailable == true then
           TooltipTextKey = "InteractiveObjectAvailable";
        else
           TooltipTextKey = "InteractiveObjectNotAvailable";
        end
        if Logic.InteractiveObjectHasPlayerEnoughSpaceForRewards(ObjectID, PlayerID) == false then
           TooltipDisabledTextKey = "InteractiveObjectAvailableReward";
        end

        local CheckSettlement;
        if Costs and Costs[1] and Logic.GetGoodCategoryForGoodType(Costs[1]) ~= GoodCategories.GC_Resource then
           CheckSettlement = true;
        end

        if IO[eName] and IO[eName].Used ~= true then
            local title;
            local text;
            if IO[eName].Title or IO[eName].Text then
                title = IO[eName].Title or "";
                text  = IO[eName].Text or "";
            end
            if Logic.IsInteractiveObject(ObjectID) == false then
                Costs = IO[eName].Costs;
                if Costs and Costs[1] and Logic.GetGoodCategoryForGoodType(Costs[1]) ~= GoodCategories.GC_Resource then
                    CheckSettlement = true;
                end
            end
            BundleInteractiveObjects.Local:TextCosts(title, text, nil, {Costs[1], Costs[2], Costs[3], Costs[4]}, CheckSettlement);
            return;
        end
        GUI_Tooltip.TooltipBuy(Costs, TooltipTextKey, TooltipDisabledTextKey, nil, CheckSettlement);
    end

    GUI_Interaction.InteractiveObjectClicked_Orig_QSB_IO = GUI_Interaction.InteractiveObjectClicked
    GUI_Interaction.InteractiveObjectClicked = function()
        local i = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()));
        local lang = Network.GetDesiredLanguage();
        local eID = g_Interaction.ActiveObjectsOnScreen[i];
        local pID = GUI.GetPlayerID();

        for k,v in pairs(IO)do
            if eID == GetID(k)then
                local ActivationSound = "menu_left_prestige";
                if v.ActivationSound then
                    ActivationSound = v.ActivationSound;
                end

                local Reward = {};
                if IO[k].Reward and IO[k].Reward[1] ~= nil then
                    table.insert(Reward,IO[k].Reward[1]);
                    table.insert(Reward,IO[k].Reward[2]);
                end
                local space = true;
                if  Reward[2] and type(Reward[2]) == "number" and Reward[1] ~= Goods.G_Gold
                and Logic.GetGoodCategoryForGoodType(Reward[1]) == GoodCategories.GC_Resource then
                    local freeSpace = Logic.GetPlayerUnreservedStorehouseSpace(pID);
                    if freeSpace < Reward[2] then
                        space = false;
                    end
                end

                local CheckSettlement;
                if IO[k].Costs and IO[k].Costs[1] then
                    if Logic.GetGoodCategoryForGoodType(IO[k].Costs[1]) ~= GoodCategories.GC_Resource then
                        CheckSettlement = true;
                    end

                    -- space
                    if space == false then
                        local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_MerchantStorehouseSpace")
                        Message(MessageText);
                        return;
                    end

                    local Costs = IO[k].Costs;
                    local CanNotBuyString = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources");
                    local CanBuyBoolean = true;

                    -- costs 1
                    if Costs[1] then
                        CanBuyBoolean = CanBuyBoolean and BundleInteractiveObjects.Local:CanBeBought(pID, Costs[1], Costs[2]);
                    end
                    -- costs 2
                    if Costs[3] then
                        CanBuyBoolean = CanBuyBoolean and BundleInteractiveObjects.Local:CanBeBought(pID, Costs[3], Costs[4]);
                    end

                    -- check condition
                    if not IO[k].ConditionFullfilled then
                        if IO[k].ConditionUnfulfilled and IO[k].ConditionUnfulfilled ~= "" then
                            Message(IO[k].ConditionUnfulfilled);
                        end
                        return;
                    end

                    -- check opener
                    if IO[k].Opener then
                        if Logic.GetDistanceBetweenEntities(GetID(IO[k].Opener),GetID(k)) > IO[k].Distance then
                            if IO[k].WrongKnight and IO[k].WrongKnight ~= "" then
                                Message(IO[k].WrongKnight);
                            end
                            return;
                        end
                    end

                    if CanBuyBoolean == true then
                        if Costs[1] ~= nil and not Logic.IsInteractiveObject(eID) then
                            BundleInteractiveObjects.Local:BuyObject(pID, Costs[1], Costs[2]);
                        end
                        if Costs[3] ~= nil and not Logic.IsInteractiveObject(eID) then
                            BundleInteractiveObjects.Local:BuyObject(pID, Costs[3], Costs[4]);
                        end
                        -- reward
                        if #Reward > 0 then
                            GUI.SendScriptCommand("GameCallback_ExecuteCustomObjectReward("..pID..",'"..k.."',"..Reward[1]..","..Reward[2]..")");
                        end
                        if Logic.IsInteractiveObject(eID) ~= true then
                            Play2DSound(pID, ActivationSound);
                            GUI.SendScriptCommand("GameCallback_OnObjectInteraction("..eID..","..pID..")");
                        end
                    else
                        Message(CanNotBuyString)
                    end
                else
                    -- space
                    if space == false then
                        local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_MerchantStorehouseSpace")
                        Message(MessageText);
                        return;
                    end

                    -- check condition
                    if not IO[k].ConditionFullfilled then
                        if IO[k].ConditionUnfulfilled and IO[k].ConditionUnfulfilled ~= "" then
                            Message(IO[k].ConditionUnfulfilled);
                        end
                        return;
                    end

                    -- check opener
                    if IO[k].Opener then
                        if Logic.GetDistanceBetweenEntities(GetID(IO[k].Opener),GetID(k)) > IO[k].Distance then
                            if IO[k].WrongKnight and IO[k].WrongKnight ~= "" then
                                Message(IO[k].WrongKnight);
                            end
                            return;
                        end
                    end

                    -- reward
                    if #Reward > 0 then
                        GUI.SendScriptCommand("GameCallback_ExecuteCustomObjectReward("..pID..",'"..k.."',"..Reward[1]..","..Reward[2]..")");
                    end
                    if Logic.IsInteractiveObject(eID) ~= true then
                        Play2DSound(pID, ActivationSound);
                        GUI.SendScriptCommand("GameCallback_OnObjectInteraction("..eID..","..pID..")");
                    end
                end
            end
        end
        GUI_Interaction.InteractiveObjectClicked_Orig_QSB_IO();
    end

    GUI_Interaction.DisplayQuestObjective_Orig_QSB_IO = GUI_Interaction.DisplayQuestObjective
    GUI_Interaction.DisplayQuestObjective = function(_QuestIndex, _MessageKey)
        local lang = Network.GetDesiredLanguage();
        if lang ~= "de" then lang = "en" end

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
            QuestObjectiveContainer = QuestObjectivesPath .. "/List"
            QuestTypeCaption = Wrapped_GetStringTableText(_QuestIndex, "UI_Texts/QuestInteraction")
            local ObjectList = {}

            for i = 1, Quest.Objectives[1].Data[0] do
                local ObjectType
                if Logic.IsEntityDestroyed(Quest.Objectives[1].Data[i]) then
                    ObjectType = g_Interaction.SavedQuestEntityTypes[_QuestIndex][i]
                else
                    ObjectType = Logic.GetEntityType(GetEntityId(Quest.Objectives[1].Data[i]))
                end
                local ObjectEntityName = Logic.GetEntityName(Quest.Objectives[1].Data[i]);
                local ObjectName = ""
                if ObjectType ~= 0 then
                    local ObjectTypeName = Logic.GetEntityTypeName(ObjectType)
                    ObjectName = Wrapped_GetStringTableText(_QuestIndex, "Names/" .. ObjectTypeName)
                    if ObjectName == "" then
                        ObjectName = Wrapped_GetStringTableText(_QuestIndex, "UI_ObjectNames/" .. ObjectTypeName)
                    end
                    if ObjectName == "" then
                        ObjectName = BundleInteractiveObjects.Local.Data.IOCustomNames[ObjectTypeName];
                        if type(ObjectName) == "table" then
                            local lang = Network.GetDesiredLanguage();
                            lang = (lang == "de" and "de") or "en";
                            ObjectName = ObjectName[lang];
                        end
                    end
                    if ObjectName == "" then
                        ObjectName = BundleInteractiveObjects.Local.Data.IOCustomNames[ObjectEntityName];
                        if type(ObjectName) == "table" then
                            local lang = Network.GetDesiredLanguage();
                            lang = (lang == "de" and "de") or "en";
                            ObjectName = ObjectName[lang];
                        end
                    end
                    if ObjectName == "" then
                        ObjectName = "Debug: ObjectName missing for " .. ObjectTypeName
                    end
                end
                table.insert(ObjectList, ObjectName)
            end
            for i = 1, 4 do
                local String = ObjectList[i]
                if String == nil then
                    String = ""
                end
                XGUIEng.SetText(QuestObjectiveContainer .. "/Entry" .. i, "{center}" .. String)
            end

            SetIcon(QuestObjectiveContainer .. "/QuestTypeIcon",{14, 10});
            XGUIEng.SetText(QuestObjectiveContainer.."/Caption","{center}"..QuestTypeCaption);
            XGUIEng.ShowWidget(QuestObjectiveContainer, 1);
        else
            GUI_Interaction.DisplayQuestObjective_Orig_QSB_IO(_QuestIndex, _MessageKey);
        end
    end
end

---
-- Setzt den Kostentooltip des aktuellen Widgets.
--
-- @param _Title        Titel des Tooltip
-- @param _Text         Text des Tooltip
-- @param _DisabledText Textzusatz wenn inaktiv
-- @param _Costs        Kostentabelle
-- @param _InSettlement Kosten in Siedlung suchen
-- @within Private
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
--
-- @param _Widget Icon Widget
-- @param _Icon   Icon Textur
-- @within BundleBuildingButtons
-- @local
--
function BundleInteractiveObjects.Local:SetIcon(_Widget, _Icon)
    if type(_Icon) == "table" then
        if type(_Icon[3]) == "string" then
            local u0, u1, v0, v1;
            u0 = (_Icon[1] - 1) * 64;
            v0 = (_Icon[2] - 1) * 64;
            u1 = (_Icon[1]) * 64;
            v1 = (_Icon[2]) * 64;
            XGUIEng.SetMaterialAlpha(_Widget, 1, 255);
            XGUIEng.SetMaterialTexture(_Widget, 1, _Icon[3].. "big.png");
            XGUIEng.SetMaterialUV(_Widget, 1, u0, v0, u1, v1);
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
        XGUIEng.SetMaterialTexture(_Widget, 1, _file);
        XGUIEng.SetMaterialUV(_Widget, 1, 0, 0, Scale, Scale);
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleInteractiveObjects");

