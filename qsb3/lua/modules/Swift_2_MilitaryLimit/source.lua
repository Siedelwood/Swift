--[[
Swift_2_MilitaryLimit/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

SCP.MilitaryLimit = {};

ModuleMilitaryLimit = {
    Properties = {
        Name = "ModuleMilitaryLimit",
    },

    Global = {
        SoldierLimitCalculators = {},
        SoldierKillsCounter = {},
    };
    Local = {
        SelectionBackup = {},
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        DefaultSoldierLimits = {25, 43, 61, 91, 91},
        SoldierLimits = {},
    },
};

QSB.DestroyedSoldiers = {};

-- -------------------------------------------------------------------------- --

function ModuleMilitaryLimit.Global:OnGameStart()
    QSB.ScriptEvents.ProducedThief = API.RegisterScriptEvent("Event_ProducedThief");
    QSB.ScriptEvents.ProducedBattalion = API.RegisterScriptEvent("Event_ProducedBattalion");
    QSB.ScriptEvents.RefilledBattalion = API.RegisterScriptEvent("Event_RefilledBattalion");

    for i= 0, 8 do
        self.SoldierKillsCounter[i] = {};
    end

    if API.IsHistoryEditionNetworkGame() then
        return;
    end
    for i= 1, 8 do
        self:SetLimitsForPlayer(i);
    end
    self:UpdateSoldierLimits();
    API.StartJob(function()
        ModuleMilitaryLimit.Global:UpdateSoldierLimits();
    end);

    API.RegisterScriptCommand("Cmd_MilitaryLimitProduceUnits", SCP.MilitaryLimit.ProduceUnits);
    API.RegisterScriptCommand("Cmd_MilitaryLimitRefillBattalion", SCP.MilitaryLimit.RefillBattalion);
end

function ModuleMilitaryLimit.Global:OnEvent(_ID, _Name, ...)
    if _ID == QSB.ScriptEvents.EntityKilled then
        self:OnEntityKilledController(arg[1], arg[2], arg[3], arg[4]);
    end
end

-- Destroy soldiers --------------------------------------------------------- --

function ModuleMilitaryLimit.Global:OnEntityKilledController(_KilledEntityID, _KilledPlayerID, _KillerEntityID, _KillerPlayerID)
    if _KilledEntityID ~= 0 and _KillerEntityID ~= 0 then
        self.SoldierKillsCounter[_KillerPlayerID][_KilledPlayerID] = self.SoldierKillsCounter[_KillerPlayerID][_KilledPlayerID] or 0
        if Logic.IsEntityTypeInCategory( _KillerPlayerID, EntityCategories.Soldier ) == 1 then
            self.SoldierKillsCounter[_KillerPlayerID][_KilledPlayerID] = self.SoldierKillsCounter[_KillerPlayerID][_KilledPlayerID] +1
        end
    end
end

function ModuleMilitaryLimit.Global:GetEnemySoldierKillsOfPlayer(_PlayerID1, _PlayerID2)
    return self.SoldierKillsCounter[_PlayerID1][_PlayerID2] or 0;
end

-- Soldier imits ------------------------------------------------------------ --

function ModuleMilitaryLimit.Global:SetLimitsForPlayer(_PlayerID, _Function)
    local Function = _Function;
    if not Function then
        Function = function(_Player)
            local Level = 1;
            local CastleID = Logic.GetHeadquarters(_Player);
            if CastleID ~= 0 then
                Level = Logic.GetUpgradeLevel(CastleID) +1;
            end
            return ModuleMilitaryLimit.Shared.DefaultSoldierLimits[Level];
        end
    end
    self.SoldierLimitCalculators[_PlayerID] = Function;
end

function ModuleMilitaryLimit.Global:ProduceUnit(_PlayerID, _BarrackID, _UnitType, _Costs)
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

function ModuleMilitaryLimit.Global:RefillBattalion(_PlayerID, _BarrackID, _LeaderID, _Costs)
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
            for i= #ModuleMilitaryLimit.Local.SelectionBackup, 1, -1 do
                if ModuleMilitaryLimit.Local.SelectionBackup[i] ~= ID1 then
                    GUI.SelectEntity(ModuleMilitaryLimit.Local.SelectionBackup[i])
                end
            end
            ModuleMilitaryLimit.Local.SelectionBackup = {}

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

function ModuleMilitaryLimit.Global:SubFromPlayerGoods(_PlayerID, _BarrackID, _Costs)
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

function ModuleMilitaryLimit.Global:UpdateSoldierLimits()
    for i= 1, 8 do
        local Limit = self.SoldierLimitCalculators[i](i);
        ModuleMilitaryLimit.Shared.SoldierLimits[i] = Limit;
        Logic.ExecuteInLuaLocalState(string.format(
            [[ModuleMilitaryLimit.Shared.SoldierLimits[%d] = %d]],
            i,
            Limit
        ));
    end
end

-- -------------------------------------------------------------------------- --

function ModuleMilitaryLimit.Local:OnGameStart()
    QSB.ScriptEvents.ProducedThief = API.RegisterScriptEvent("Event_ProducedThief");
    QSB.ScriptEvents.ProducedBattalion = API.RegisterScriptEvent("Event_ProducedBattalion");
    QSB.ScriptEvents.RefilledBattalion = API.RegisterScriptEvent("Event_RefilledBattalion");

    if Framework.IsNetworkGame() then
        return;
    end
    self:OverrideUI();
end

function ModuleMilitaryLimit.Local:OverrideUI()
    function GUI_CityOverview.LimitUpdate()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local PlayerID = GUI.GetPlayerID();
        local Count = Logic.GetCurrentSoldierCount(PlayerID);
        local Limit = ModuleMilitaryLimit.Shared:GetLimitForPlayer(PlayerID);
        local Color = "{@color:none}";
        if Count >= Limit then
            Color = "{@color:255,20,30,255}";
        end
        XGUIEng.SetText(CurrentWidgetID, "{center}" .. Color .. Count .. "/" .. Limit);
    end

    function GUI_BuildingButtons.BuyBattalionClicked()
        local PlayerID  = GUI.GetPlayerID();
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
        local CurrentSoldierLimit = ModuleMilitaryLimit.Shared:GetLimitForPlayer(PlayerID);
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
                API.SendScriptCommand(
                    QSB.ScriptCommands.MilitaryLimitProduceUnits,
                    PlayerID,
                    BarrackID,
                    EntityType,
                    Costs
                );
            else
                API.SendScriptCommand(
                    QSB.ScriptCommands.MilitaryLimitProduceUnits,
                    PlayerID,
                    BarrackID,
                    EntityType,
                    Costs
                );
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
        local SoldierCount = Logic.GetCurrentSoldierCount(PlayerID);
        local SoldierMax = ModuleMilitaryLimit.Shared:GetLimitForPlayer(PlayerID);

        local CanBuyBoolean, CanNotBuyString;
        if LeaderSoldiers < LeaderMaxSoldiers then
            if SoldierCount < SoldierMax then
                CanBuyBoolean, CanNotBuyString = AreCostsAffordable(Costs);
                if CanBuyBoolean == false then
                    Message(CanNotBuyString);
                    return;
                end
                local CanRefillBoolean = Logic.CanRefillBattalion(LeaderID);
                if CanRefillBoolean == false then
                    local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotCloseToBarracksForRefilling");
                    Message(MessageText);
                else
                    -- local Selection = {GUI.GetSelectedEntities()};
                    local Selection = table.copy(g_MultiSelection.EntityList);
                    ModuleMilitaryLimit.Local.SelectionBackup = Selection;
                    GUI.ClearSelection();

                    API.SendScriptCommand(
                        QSB.ScriptCommands.MilitaryLimitRefillBattalion,
                        PlayerID,
                        BarracksID,
                        LeaderID,
                        table.concat(Costs, ",")
                    );
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

function ModuleMilitaryLimit.Shared:GetLimitForPlayer(_PlayerID)
    if API.IsHistoryEditionNetworkGame() then
        return Logic.GetCurrentSoldierLimit(_PlayerID);
    end
    return self.SoldierLimits[_PlayerID];
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleMilitaryLimit);

