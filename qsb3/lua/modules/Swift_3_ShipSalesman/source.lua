--[[
Swift_3_ShipSalesment/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleShipSalesment = {
    Properties = {
        Name = "ModuleShipSalesment",
    },

    Global = {
        Harbors = {},
        QuestInfoCounter = 0,
    },
    Local = {},
    -- This is a shared structure but the values are asynchronous!
    Shared = {},
};

-- Global ------------------------------------------------------------------- --

function ModuleShipSalesment.Global:OnGameStart()
    QSB.ScriptEvents.TradeShipArrived = API.RegisterScriptEvent("Event_TradeShipArrived");
    QSB.ScriptEvents.TradeShipLeft = API.RegisterScriptEvent("Event_TradeShipLeft");

    API.StartHiResJob(function()
        ModuleShipSalesment.Global:TravelingSalesmanController();
    end);
    self:OverrideEndOfMonth();
end

function ModuleShipSalesment.Global:OnEvent(_ID, _Event, ...)
end

function ModuleShipSalesment.Global:RegisterHarbor(_Harbor)
    if self.Harbors[_Harbor.m_PlayerID] then
        info("ModuleShipSalesment: harbor for player " .._Harbor.m_PlayerID.. " already exists and is purged.");
        self.Harbors[_Harbor.m_PlayerID]:Dispose();
    end
    info("ModuleShipSalesment: creating harbor for player " .._Harbor.m_PlayerID.. ".");
    self.Harbors[_Harbor.m_PlayerID] = _Harbor;
end

function ModuleShipSalesment.Global:SpawnShip(_Harbor)
    local SpawnPoint = _Harbor:GetPath():GetFirst();
    local Orientation = Logic.GetEntityOrientation(GetID(SpawnPoint));
    local x, y, z = Logic.EntityGetPos(GetID(SpawnPoint))
    local ID = Logic.CreateEntity(Entities.D_X_TradeShip, x, y, Orientation, 0);
    _Harbor:SetShipID(ID);
    _Harbor:GetPath():SetReversed(false);
    local OnArrival = function(_Data)
        ModuleShipSalesment.Global:ShipAtDock(_Data.Entity);
    end
    info("ModuleShipSalesment: Ship of player " .._Harbor:GetPlayerID().. " has spawns.");
    local Instance = Path:new(ID, _Harbor:GetPath():Get(), nil, nil, OnArrival, nil, true, nil, nil, QSB.ShipWaypointDistance);
    _Harbor:SetJobID(Instance.Job);
end

function ModuleShipSalesment.Global:ShipLeave(_Harbor)
    local PlayerID = _Harbor:GetPlayerID();
    local PartnerID = _Harbor:GetPartnerPlayerID();
    Logic.RemoveAllOffers(Logic.GetStoreHouse(PlayerID));
    self:TriggerShipIsLeavingDockMessage(PlayerID, PartnerID);
    _Harbor:GetPath():SetReversed(true);
    local OnArrival = function(_Data)
        ModuleShipSalesment.Global:ShipHasLeft(_Data.Entity);
    end
    info("ModuleShipSalesment: Ship of player " ..PlayerID.. " is leaving the harbor.");
    local Instance = Path:new(_Harbor:GetShipID(), _Harbor:GetPath():Get(), nil, nil, OnArrival, nil, true, nil, nil, QSB.ShipWaypointDistance);
    _Harbor:SetJobID(Instance.Job);

    API.SendScriptEvent(QSB.ScriptEvents.TradeShipLeft, PlayerID, PartnerID, _Harbor:GetShipID());
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.TradeShipLeft, %d, %d, %d)]],
        PlayerID,
        PartnerID,
        _Harbor:GetShipID()
    ));
end

function ModuleShipSalesment.Global:ShipHasLeft(_ShipID)
    local Harbor = self:GetHarborByShipID(_ShipID);
    if (Harbor) then
        info("ModuleShipSalesment: Ship of player " ..Harbor:GetPlayerID().. " has despawned.");
        Harbor:SetJobID(0);
        Harbor:SetShipID(0);
        Harbor:SetDuration(Harbor:GetDuration());
        Harbor:SetIntermission(Harbor:GetInterval() +1);
        DestroyEntity(_ShipID);
    end
end

function ModuleShipSalesment.Global:ShipAtDock(_ShipID)
    local Harbor = self:GetHarborByShipID(_ShipID);
    if (Harbor) then
        info("Ship of player " ..Harbor:GetPlayerID().. " is arriving at the harbor.");
        Harbor:SetJobID(0);
        local PlayerID = Harbor:GetPlayerID();
        local PartnerID = Harbor:GetPartnerPlayerID();
        MerchantSystem.TradeBlackList[PlayerID] = {};
        MerchantSystem.TradeBlackList[PlayerID][0] = 0;
        self:CreateOffers(Harbor:GetRandomOffers(), Logic.GetStoreHouse(PlayerID), PartnerID)
        self:TriggerShipAtDockMessage(PlayerID, PartnerID);

        API.SendScriptEvent(QSB.ScriptEvents.TradeShipLeft, PlayerID, PartnerID, _ShipID);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.TradeShipLeft, %d, %d, %d)]],
            PlayerID,
            PartnerID,
            _ShipID
        ));
    end
end

function ModuleShipSalesment.Global:CreateOffers(_Offers, _TraderID, _PartnerPlayerID)
    DeActivateMerchantForPlayer(_TraderID, _PartnerPlayerID);
    Logic.RemoveAllOffers(_TraderID);
    local LogInfo = "ModuleShipSalesment: Creating offers for player " .._TraderID..":";
    if #_Offers > 0 then
        LogInfo = LogInfo.. "{cr}Offers:";
        local OfferString = "";
        for i=1,#_Offers,1 do
            if Goods[_Offers[i][1]] then
                AddOffer(_TraderID, _Offers[i][2], Goods[_Offers[i][1]], 9999);
            else
                if Logic.IsEntityTypeInCategory(Entities[_Offers[i][1]], EntityCategories.Military)== 0 then
                    AddEntertainerOffer(_TraderID, Entities[_Offers[i][1]]);
                else
                    AddMercenaryOffer(_TraderID, _Offers[i][2], Entities[_Offers[i][1]], 9999);
                end
            end
            OfferString = OfferString .. "{cr}(" .._Offers[i][1].. ", " ..((_Offers[i][2] ~= nil and _Offers[i][2]) or 1).. ")";
        end
        if GetDiplomacyState(_PartnerPlayerID, Logic.EntityGetPlayer(_TraderID)) > 0 then
            ActivateMerchantPermanentlyForPlayer(_TraderID, _PartnerPlayerID);
            Logic.ExecuteInLuaLocalState("g_Merchant.ActiveMerchantBuilding = nil");
        end
        LogInfo = LogInfo .. OfferString;
    end
    info(LogInfo);
end

function ModuleShipSalesment.Global:TriggerShipAtDockMessage(_PlayerID, _PartnerPlayerID)
    local Text = {
        de = "Ein Schiff hat angelegt. Es bringt Güter von weit her.",
        en = "A ship is at the pier. It delivers goods from far away.",
    };
    API.CreateQuestMessage(Text, _PlayerID, _PartnerPlayerID);
end

function ModuleShipSalesment.Global:TriggerShipIsLeavingDockMessage(_PlayerID, _PartnerPlayerID)
    local Text = {
        de = "Das Schiff hat den Hafen wieder verlassen.",
        en = "Time has passed on and the ship has left.",
    };
    API.CreateQuestMessage(Text, _PlayerID, _PartnerPlayerID);
end

function ModuleShipSalesment.Global:GetHarborByShipID(_ShipID)
    local Harbor;
    for i= 1, 8, 1 do
        Harbor = self.Harbors[i];
        if (Harbor and Harbor:GetShipID() == _ShipID) then
            return Harbor;
        end
    end
    return nil;
end

function ModuleShipSalesment.Global:OverrideEndOfMonth()
    GameCallback_EndOfMonth_Orig_ShipSlalesman = GameCallback_EndOfMonth;
    GameCallback_EndOfMonth = function(_LastMonth, _CurrentMonth)
        GameCallback_EndOfMonth_Orig_ShipSlalesman(_LastMonth, _CurrentMonth);
        ModuleShipSalesment.Global:TravelingSalesmanEndOfMonth();
    end
end

function ModuleShipSalesment.Global:TravelingSalesmanEndOfMonth()
    for i= 1, 8, 1 do
        local Harbor = self.Harbors[i];
        if  (Harbor and Harbor:IsActive() and Harbor:GetShipID() == 0 and not Harbor:IsIceBlockingPath()) then
            if (Harbor:SetIntermission(Harbor:GetIntermission() -1):GetIntermission() == 0) then
                Harbor:SetIntermission(-100);
                ModuleShipSalesment.Global:SpawnShip(Harbor);
            end
        end
    end
end

function ModuleShipSalesment.Global:TravelingSalesmanController()
    for i= 1, 8, 1 do
        local Harbor = self.Harbors[i];
        if  (Harbor and not Harbor:HasElapsed() and Harbor:GetShipID() ~= 0 and not Harbor:IsIceBlockingPath()
        and IsNear(Harbor:GetShipID(), Harbor:GetPath():GetLast(), QSB.ShipWaypointDistance)) then
            if (Harbor:Elapse():HasElapsed()) then
                self:ShipLeave(Harbor);
            end
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleShipSalesment.Local:OnGameStart()
    QSB.ScriptEvents.TradeShipArrived = API.RegisterScriptEvent("Event_TradeShipArrived");
    QSB.ScriptEvents.TradeShipLeft = API.RegisterScriptEvent("Event_TradeShipLeft");
end

-- -------------------------------------------------------------------------- --

QSB.TradeShipPath = {
    m_Waypoints = {};
    m_Reversed = false;
}

function QSB.TradeShipPath:New(...)
    local Path = table.copy(self);
    if #arg == 1 and type(arg[1]) == "string" then
        local i = 1;
        while (IsExisting(arg[1] ..i)) do
            table.insert(Path.m_Waypoints, arg[1] ..i);
            i = i +1;
        end
    elseif #arg == 1 and type(arg[1]) == "table" then
        Path.m_Waypoints = table.copy(arg[1]);
    else
        Path.m_Waypoints = table.copy(arg);
    end
    return Path;
end

function QSB.TradeShipPath:GetFirst()
    return self.m_Waypoints[1];
end

function QSB.TradeShipPath:GetLast()
    return self.m_Waypoints[#self.m_Waypoints];
end

function QSB.TradeShipPath:Get()
    local Path = self.m_Waypoints;
    if (self.m_Reversed == true) then
        Path = {};
        for i= #self.m_Waypoints, 1, -1 do
            table.insert(Path, self.m_Waypoints[i]);
        end
    end
    return Path;
end

function QSB.TradeShipPath:IsReversed()
    return self.m_Reversed == true;
end

function QSB.TradeShipPath:SetReversed(_Reversed)
    self.m_Reversed = _Reversed == true;
end

-- -------------------------------------------------------------------------- --

QSB.TradeShipHarbor = {
    m_Path = {};
    m_OfferTypes = {};
    m_Active = false;
    m_NoIce = false;
    m_PlayerID = 1;
    m_PartnerPlayerID = 1,
    m_Duration = 180;
    m_TimeLeft = 180;
    m_Interval = 2;
    m_BreakMonths = 1;
    m_OfferCount = 0;
    m_ShipID = 0;
    m_JobID = 0;
};

function QSB.TradeShipHarbor:New(_PlayerID)
    local Harbor = table.copy(self);
    Harbor.m_PlayerID = _PlayerID;
    return Harbor;
end

function QSB.TradeShipHarbor:Dispose()
    if self.m_ShipID ~= 0 then
        DestroyEntity(self.m_ShipID);
    end
    if (JobIsRunning(self.m_JobID)) then
        EndJob(self.m_JobID);
    end
    Logic.RemoveAllOffers(Logic.GetStoreHouse(self.m_PlayerID));
end

function QSB.TradeShipHarbor:GetDurationInMonths()
    return math.ceil(self.m_Duration / Logic.GetMonthDurationInSeconds());
end

function QSB.TradeShipHarbor:GetPlayerID()
    return self.m_PlayerID;
end

function QSB.TradeShipHarbor:GetPartnerPlayerID()
    return self.m_PartnerPlayerID;
end

function QSB.TradeShipHarbor:SetPartnerPlayerID(_PlayerID)
    self.m_PartnerPlayerID = _PlayerID;
    return self;
end

function QSB.TradeShipHarbor:GetShipID()
    return self.m_ShipID;
end

function QSB.TradeShipHarbor:SetShipID(_ID)
    self.m_ShipID = _ID;
    return self;
end

function QSB.TradeShipHarbor:SetJobID(_ID)
    self.m_JobID = _ID;
    return self;
end

function QSB.TradeShipHarbor:GetIntermission()
    return self.m_BreakMonths;
end

function QSB.TradeShipHarbor:SetIntermission(_Break)
    self.m_BreakMonths = _Break;
    return self;
end

function QSB.TradeShipHarbor:GetDuration()
    return self.m_Duration;
end

function QSB.TradeShipHarbor:SetDuration(_Duration)
    self.m_Duration = _Duration;
    self.m_TimeLeft = _Duration;
    return self;
end

function QSB.TradeShipHarbor:Elapse()
    self.m_TimeLeft = self.m_TimeLeft -1;
    return self;
end

function QSB.TradeShipHarbor:HasElapsed()
    return self.m_TimeLeft < 1;
end

function QSB.TradeShipHarbor:GetInterval()
    return self.m_Interval;
end

function QSB.TradeShipHarbor:SetInterval(_Interval)
    self.m_Interval = _Interval;
    self.m_BreakMonths = 1;
    return self;
end

function QSB.TradeShipHarbor:SetNoIce(_NoIce)
    self.m_NoIce = _NoIce == true;
    return self;
end

function QSB.TradeShipHarbor:IsNoIce()
    return self.m_NoIce == true;
end

function QSB.TradeShipHarbor:SetActive(_Active)
    self.m_Active = _Active == true;
    return self;
end

function QSB.TradeShipHarbor:IsActive()
    return self.m_Active == true;
end

function QSB.TradeShipHarbor:SetPath(...)
    self.m_Path = QSB.TradeShipPath:New(unpack(arg));
    return self;
end

function QSB.TradeShipHarbor:GetPath()
    return self.m_Path;
end

function QSB.TradeShipHarbor:SetOfferCount(_Count)
    self.m_OfferCount = _Count;
    return self;
end

function QSB.TradeShipHarbor:AddOffer(_Good, Amount)
    for i= 1, #self.m_OfferTypes, 1 do
        if (self.m_OfferTypes[i][1]) == _Good then
            return self;
        end
    end
    table.insert(self.m_OfferTypes, {_Good, Amount});
    return self;
end

function QSB.TradeShipHarbor:IsIceBlockingPath()
    return self:IsNoIce() and Logic.GetWeatherDoesWaterFreezeByMonth(Logic.GetCurrentMonth());
end

function QSB.TradeShipHarbor:GetRandomOffers()
    local Offers = {};
    if #self.m_OfferTypes >= self.m_OfferCount then
        local OffersToChoose = self.m_OfferCount;
        while (OffersToChoose > 0) do
            local RandomOffer = math.random(1, #self.m_OfferTypes);
            local Found = false;
            for i= 1, #Offers, 1 do
                if (Offers[i][1] == self.m_OfferTypes[RandomOffer][1]) then
                    Found = true;
                    break;
                end
            end
            if not Found then
                table.insert(Offers, {self.m_OfferTypes[RandomOffer][1], self.m_OfferTypes[RandomOffer][2]});
                OffersToChoose = OffersToChoose -1;
            end
        end
    end
    return Offers;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleShipSalesment);

