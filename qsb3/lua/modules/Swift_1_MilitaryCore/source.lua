--[[
Swift_1_MilitaryCore/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleMilitaryCore = {
    Properties = {
        Name = "ModuleMilitaryCore",
    },

    Global = {};
    Local = {
        SelectionBackup = {},
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        Event = {},
        SoldierLimits = {},
    },

    Text = {
        DestroySoldiers = {
            de = "{center}SOLDATEN ZERSTÖREN {cr}{cr}von der Partei: %s{cr}{cr}Anzahl: %d",
            en = "{center}DESTROY SOLDIERS {cr}{cr}from faction: %s{cr}{cr}Amount: %d",
        },
    }
};

-- -------------------------------------------------------------------------- --

function ModuleMilitaryCore.Global:OnGameStart()
    QSB.ScriptEvents.ProducedThief = API.RegisterScriptEvent("Event_ProducedThief");
    QSB.ScriptEvents.ProducedBattalion = API.RegisterScriptEvent("Event_ProducedBattalion");
    QSB.ScriptEvents.RefilledBattalion = API.RegisterScriptEvent("Event_RefilledBattalion");

    if API.IsHistoryEditionNetworkGame() then
        return;
    end
    ModuleMilitaryCore.Shared:InitLimits();
end

function ModuleMilitaryCore.Global:ProduceUnit(_PlayerID, _BarrackID, _UnitType, _Costs)
    local x1, y1 = Logic.GetBuildingApproachPosition(_BarrackID);
    local x2, y2 = Logic.GetRallyPoint(_BarrackID);
    local o = Logic.GetEntityOrientation(_BarrackID);
    self:SubFromPlayerGoods(_PlayerID, _BarrackID, _Costs);
    if _UnitType == Entities.U_Thief then
        local ID = Logic.CreateEntityOnUnblockedLand(_UnitType, x1, y1, o-90, _PlayerID);
        API.SendScriptEvent(QSB.ScriptEvents.ProducedThief, ID, _BarrackID, _Costs);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.ProducedThief, %d, %d, %s)]],
            ID,
            _BarrackID,
            table.tostring(_Costs)
        ))
    else
        local ID = Logic.CreateBattalionOnUnblockedLand(_UnitType, x1, y1, 0-90, _PlayerID, 6);
        Logic.MoveSettler(ID, x2, y2, -1);
        API.SendScriptEvent(QSB.ScriptEvents.ProducedBattalion, ID, _BarrackID, _Costs);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.ProducedBattalion, %d, %d, %s)]],
            ID,
            _BarrackID,
            table.tostring(_Costs)
        ))
    end
end

function ModuleMilitaryCore.Global:RefillBattalion(_PlayerID, _BarrackID, _LeaderID, _Costs)
    local x1, y1, z1 = Logic.EntityGetPos(_LeaderID);
    local x2, y2 = Logic.GetBuildingApproachPosition(_BarrackID);
    local o1 = Logic.GetEntityOrientation(_LeaderID);
    local EntityType = Logic.LeaderGetSoldiersType(_LeaderID);
    local LeaderSoldiers = Logic.GetSoldiersAttachedToLeader(_LeaderID);

    local ID = Logic.CreateBattalion(EntityType, x1, y1, o1, _PlayerID, LeaderSoldiers+1);
	Logic.SetEntityName(ID, Logic.GetEntityName(_LeaderID));
    local SoldiersOld = {Logic.GetSoldiersAttachedToLeader(_LeaderID)};
    local SoldiersNew = {Logic.GetSoldiersAttachedToLeader(ID)};
    for i= 2, SoldiersNew[1] do
        local x, y, z = Logic.EntityGetPos(SoldiersOld[i]);
        Logic.DEBUG_SetSettlerPosition(SoldiersNew[i], x, y);
        Logic.SetOrientation(SoldiersNew[i], Logic.GetEntityOrientation(SoldiersOld[i]));
        -- TODO: Fix animation
    end
    Logic.DEBUG_SetPosition(SoldiersNew[#SoldiersNew], x2, y2);
    Logic.DestroyEntity(_LeaderID);

    Logic.ExecuteInLuaLocalState(string.format(
        [[
            local ID1 = %d
            local ID2 = %d
            for i= #ModuleMilitaryCore.Local.SelectionBackup, 1, -1 do
                if ModuleMilitaryCore.Local.SelectionBackup[i] ~= ID1 then
                    GUI.SelectEntity(ModuleMilitaryCore.Local.SelectionBackup[i])
                end
            end
            ModuleMilitaryCore.Local.SelectionBackup = {}

            GUI.SelectEntity(ID2)
            GUI_MultiSelection.CreateEX()
            local Selection = {GUI.GetSelectedEntities()}
            for i= #Selection, 1, -1 do
                if Selection[i] ~= ID2 then
                    GUI.DeselectEntity(Selection[i])
                end
            end
        ]],
        _LeaderID,
        ID
    ));
    self:SubFromPlayerGoods(_PlayerID, _BarrackID, _Costs);

    API.SendScriptEvent(QSB.ScriptEvents.RefilledBattalion, ID, _BarrackID, _Costs);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.RefilledBattalion, %d, %d, %d, %d, %s)]],
        ID,
        _BarrackID,
        LeaderSoldiers,
        LeaderSoldiers+1,
        table.tostring(_Costs)
    ));
end

function ModuleMilitaryCore.Global:SubFromPlayerGoods(_PlayerID, _BarrackID, _Costs)
    for i= 1, 3, 2 do
        if _Costs[i] then
            local ResourceCategory = Logic.GetGoodCategoryForGoodType(_Costs[i]);
            if _Costs[i] == Goods.G_Gold or ResourceCategory == GoodCategories.GC_Resource then
                AddGood(_Costs[i], (-1) * _Costs[i+1], _PlayerID);
            else
                Logic.RemoveGoodFromStock(_BarrackID, _Costs[i], _Costs[i+1]);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

function ModuleMilitaryCore.Local:OnGameStart()
    QSB.ScriptEvents.ProducedThief = API.RegisterScriptEvent("Event_ProducedThief");
    QSB.ScriptEvents.ProducedBattalion = API.RegisterScriptEvent("Event_ProducedBattalion");
    QSB.ScriptEvents.RefilledBattalion = API.RegisterScriptEvent("Event_RefilledBattalion");

    if Framework.IsNetworkGame() then
        return;
    end
    ModuleMilitaryCore.Shared:InitLimits();
    self:OverrideUI();
end

function ModuleMilitaryCore.Local:OverrideUI()
    function GUI_CityOverview.LimitUpdate()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local PlayerID = GUI.GetPlayerID();
        local CastleID = Logic.GetHeadquarters(PlayerID);
        local CastleLevel = 1;
        if CastleID ~= 0 then
            CastleLevel = Logic.GetUpgradeLevel(CastleID) +1;
        end
        local Count = Logic.GetCurrentSoldierCount(PlayerID);
        local Limit = ModuleMilitaryCore.Shared:GetLimitForPlayer(PlayerID, CastleLevel);
        local Color = "{@color:none}";
        if Count >= Limit then
            Color = "{@color:255,20,30,255}";
        end
        XGUIEng.SetText(CurrentWidgetID, "{center}" .. Color .. Count .. "/" .. Limit);
    end

    function GUI_BuildingButtons.BuyBattalionClicked()
        local PlayerID  = GUI.GetPlayerID();
        local CastleID = Logic.GetHeadquarters(PlayerID);
        local CastleLevel = 1;
        if CastleID ~= 0 then
            CastleLevel = Logic.GetUpgradeLevel(CastleID) +1;
        end
        local BarrackID = GUI.GetSelectedEntity();
        local BarrackEntityType = Logic.GetEntityType(BarrackID);
        local EntityType;
        if BarrackEntityType == Entities.B_Barracks then
            EntityType = Entities.U_MilitarySword;
        elseif BarrackEntityType == Entities.B_BarracksArchers then
            EntityType = Entities.U_MilitaryBow;
        elseif Logic.IsEntityInCategory(BarrackID, EntityCategories.Headquarters) == 1 then
            EntityType = Entities.U_Thief;
        else
            return
        end
        local Costs = {Logic.GetUnitCost(BarrackID, EntityType)};
        local CanBuyBoolean, CanNotBuyString = AreCostsAffordable(Costs);
        local CurrentSoldierCount = Logic.GetCurrentSoldierCount(PlayerID);
        local CurrentSoldierLimit = ModuleMilitaryCore.Shared:GetLimitForPlayer(PlayerID, CastleLevel);
        local SoldierSize;
        if EntityType == Entities.U_Thief then
            SoldierSize = 1;
        else
            SoldierSize = Logic.GetBattalionSize(BarrackID);
        end
        if (CurrentSoldierCount + SoldierSize) > CurrentSoldierLimit then
            CanBuyBoolean = false;
            CanNotBuyString = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_SoldierLimitReached");
        end
        if CanBuyBoolean == true then
            Sound.FXPlay2DSound("ui\\menu_click");
            if EntityType == Entities.U_Thief then
                -- GUI.BuyThief(PlayerID)
                GUI.SendScriptCommand(string.format(
                    [[ModuleMilitaryCore.Global:ProduceUnit(%d, %d, %d, %s)]],
                    PlayerID,
                    BarrackID,
                    EntityType,
                    table.tostring(Costs)
                ));
            else
                -- GUI.ProduceUnits(BarrackID, EntityType)
                GUI.SendScriptCommand(string.format(
                    [[ModuleMilitaryCore.Global:ProduceUnit(%d, %d, %d, %s)]],
                    PlayerID,
                    BarrackID,
                    EntityType,
                    table.tostring(Costs)
                ));
                StartKnightVoiceForPermanentSpecialAbility(Entities.U_KnightChivalry);
            end
        else
            Message(CanNotBuyString);
        end
    end

    function GUI_Military.RefillClicked()
        local PlayerID = GUI.GetPlayerID();
        local LeaderID = GUI.GetSelectedEntity();
        local BarracksID = Logic.GetRefillerID(LeaderID);
        local LeaderMaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers(LeaderID);
        local LeaderSoldiers = Logic.GetSoldiersAttachedToLeader(LeaderID);
        local EntityType = Logic.LeaderGetSoldiersType(LeaderID);
        local Costs = {Logic.GetEntityTypeRefillCost(BarracksID, EntityType)};
        local CastleID = Logic.GetHeadquarters(PlayerID);
        local CastleLevel = 1;
        if CastleID ~= 0 then
            CastleLevel = Logic.GetUpgradeLevel(CastleID) +1;
        end
        local SoldierCount = Logic.GetCurrentSoldierCount(PlayerID);
        local SoldierMax = ModuleMilitaryCore.Shared:GetLimitForPlayer(PlayerID, CastleLevel);

        local CanBuyBoolean, CanNotBuyString;
        if LeaderSoldiers < LeaderMaxSoldiers then
            CanBuyBoolean, CanNotBuyString = AreCostsAffordable(Costs);
            if CanBuyBoolean == false then
                Message(CanNotBuyString);
                return;
            end
            local CanRefillBoolean = Logic.CanRefillBattalion(LeaderID)
            if CanRefillBoolean == false then
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotCloseToBarracksForRefilling");
                Message(MessageText);
            else
                -- local Selection = {GUI.GetSelectedEntities()};
                local Selection = table.copy(g_MultiSelection.EntityList);
                ModuleMilitaryCore.Local.SelectionBackup = Selection;
                GUI.ClearSelection();
                GUI.SendScriptCommand(string.format(
                    [[ModuleMilitaryCore.Global:RefillBattalion(%d, %d, %d, %s)]],
                    PlayerID,
                    BarracksID,
                    LeaderID,
                    table.tostring(Costs)
                ));
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

function ModuleMilitaryCore.Shared:InitLimits()
    for i= 1, 8 do
        self.SoldierLimits[i] = {25, 43, 61, 91, 91};
    end
end

function ModuleMilitaryCore.Shared:SetLimitsForPlayer(_PlayerID, _Lv1, _Lv2, _Lv3, _Lv4)
    self.SoldierLimits[_PlayerID] = {_Lv1, _Lv2, _Lv3, _Lv4, _Lv4};
end

function ModuleMilitaryCore.Shared:GetLimitForPlayer(_PlayerID, _Level)
    if API.IsHistoryEditionNetworkGame() then
        return Logic.GetCurrentSoldierLimit(_PlayerID);
    end
    return self.SoldierLimits[_PlayerID][_Level];
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleMilitaryCore);

