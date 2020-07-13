-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleTravelingSalesman                                       # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Bundle wird ein Fahrender Händler angeboten der periodisch den
-- Hafen mit einem Schiff anfährt. Dabei kann der Fahrtweg frei mit Wegpunkten
-- bestimmt werden. Es können auch mehrere Spieler zu Händlern gemacht werden.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleTravelingSalesman = {};

API = API or {};
QSB = QSB or {};

QSB.ShipWaypointDistance = 300;

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erstellt einen fahrender Händler mit zufälligen Angeboten.
--
-- Soll immer das selbe angeboten werden, darf es nur genauso viele Angebote
-- geben, wie als Maximum gesetzt wird.
--
-- Es kann mehr als einen fahrender Händler auf der Map geben.
--
-- <h5>Angebote</h5>
-- Es können Waren, Soldaten oder Entertainer angeboten werden. Aus allen
-- definierten Angeboten werden zufällig Angebote in der angegebenen Mange
-- ausgesucht und gesetzt.
--
-- <h5>Routen</h5>
-- Um die Route anzugeben, wird ein Name eingegeben. Es werden alle fortlaufend
-- nummerierte Punkte mit diesem Namen gesucht. Alternativ kann auch eine
-- Liste von Punkten angegeben werden. Es muss mindestens 2 Punkte geben.
--
-- <b>Alias</b>: TravelingSalesmanActivate
--
-- @param[type=table]  _Description Definition des Händlers
-- @within Anwenderfunktionen
--
-- @usage local TraderDescription = {
--     PlayerID   = 2,       -- Partei des Hafen
--     Path       = "SH2WP", -- Pfad (auch als Table einzelner Punkte möglich)
--     Duration   = 150,     -- Ankerzeit in Sekunden (Standard: 360)
--     Interval   = 3,       -- Monate zwischen zwei Anfarten (Standard: 2)
--     OfferCount = 4,       -- Anzahl Angebote (1 bis 4) (Standard: 4)
--     NoIce      = true,    -- Schiff kommt nicht im Winter (Standard: false)
--     Offers = {
--         -- Angebot, Menge
--         {"G_Gems", 5},
--         {"G_Iron", 5},
--         {"G_Beer", 2},
--         {"G_Stone", 5},
--         {"G_Sheep", 1},
--         {"G_Cheese", 2},
--         {"G_Milk", 5},
--         {"G_Grain", 5},
--         {"G_Broom", 2},
--         {"U_CatapultCart", 1},
--         {"U_MilitarySword", 3},
--         {"U_MilitaryBow", 3}
--     },
-- };
-- API.TravelingSalesmanCreate(TraderDescription);
--
function API.TravelingSalesmanCreate(_TraderDescription)
    if GUI then
        return;
    end
    if type(_TraderDescription) ~= "table" then
        error("API.TravelingSalesmanCreate: _TraderDescription must be a table!");
        return;
    end
    if type(_TraderDescription.PlayerID) ~= "number" or _TraderDescription.PlayerID < 1 or _TraderDescription.PlayerID > 8 then
        error("API.TravelingSalesmanCreate: _TraderDescription.PlayerID (" ..tostring(_TraderDescription.PlayerID).. ") is wrong!");
        return;
    end
    if type(_TraderDescription.Duration) ~= "number" or _TraderDescription.Duration < 60 then
        error("API.TravelingSalesmanCreate: _TraderDescription.Duration (" ..tostring(_TraderDescription.Duration).. ") must be at least 60 seconds!");
        return;
    end
    if type(_TraderDescription.Interval) ~= "number" or _TraderDescription.Interval < 1 then
        error("API.TravelingSalesmanCreate: _TraderDescription.Interval (" ..tostring(_TraderDescription.Interval).. ") must be at least 1 month!");
        return;
    end
    if type(_TraderDescription.OfferCount) ~= "number" or _TraderDescription.OfferCount < 1 or _TraderDescription.OfferCount > 4 then
        error("API.TravelingSalesmanCreate: _TraderDescription.Duration (" ..tostring(_TraderDescription.OfferCount).. ") is wrong!");
        return;
    end
    if type(_TraderDescription.Offers) ~= "table" or #_TraderDescription.Offers < _TraderDescription.OfferCount then
        error("API.TravelingSalesmanCreate: _TraderDescription.Offers must have at least " .._TraderDescription.OfferCount.." entries!");
        return;
    end
    for i= 1, #_TraderDescription.Offers, 1 do
        if Goods[_TraderDescription.Offers[i][1]] == nil and Entities[_TraderDescription.Offers[i][1]] == nil then
            error("API.TravelingSalesmanCreate: _TraderDescription.Offers[" ..i.. "][1] is invalid good type!");
            return;
        end
        if type(_TraderDescription.Offers[i][2]) ~= "number" or _TraderDescription.Offers[i][2] < 1 then
            error("API.TravelingSalesmanCreate: _TraderDescription.Offers[" ..i.. "][2] amount must be at least 1!");
            return;
        end
    end

    API.TravelingSalesmanDispose(_TraderDescription.PlayerID);
    _TraderDescription.Offers = API.ConvertOldOfferFormat(_TraderDescription.Offers);
    _TraderDescription.Duration = _TraderDescription.Duration or (6 * 60);
    _TraderDescription.Interval = _TraderDescription.Interval or 2;
    _TraderDescription.OfferCount = _TraderDescription.OfferCount or 4;

    local Harbor = QSB.TradeShipHarbor:New(_TraderDescription.PlayerID)
        :SetPath(_TraderDescription.Path or _TraderDescription.Waypoints)
        :SetDuration(_TraderDescription.Duration)
        :SetInterval(_TraderDescription.Interval)
        :SetNoIce(_TraderDescription.NoIce == true)
        :SetOfferCount(_TraderDescription.OfferCount);

    local OffersString = "";
    for i= 1, #_TraderDescription.Offers, 1 do
        Harbor:AddOffer(_TraderDescription.Offers[i][1], _TraderDescription.Offers[i][2]);       
        OffersString = OffersString .. "(" ..tostring(_TraderDescription.Offers[i][1]).. ", " .._TraderDescription.Offers[i][2].. "){cr}";
    end
    Harbor:SetActive(true);
    BundleTravelingSalesman.Global:RegisterHarbor(Harbor);

    info("API.TravelingSalesmanCreate: creating habor for player " .._TraderDescription.PlayerID.. "{cr}"..
         "Duration: " .._TraderDescription.Duration.. "{cr}"..
         "Interval: " .._TraderDescription.Interval.. "{cr}"..
         "Offers per period: " .._TraderDescription.OfferCount.. "{cr}"..
         "Offer types:{cr}" ..OffersString);
end
TravelingSalesmanCreate = API.TravelingSalesmanCreate;

---
-- Konvertiert die Angebote, falls sie im alten Format angegeben wurden.
-- @param[type=table] _Offers Angebotsliste
-- @return Umgeformte Angebote
-- @within Anwenderfunktionen
-- @local
--
function API.ConvertOldOfferFormat(_Offers)
    if type(_Offers[1][1]) ~= "table" then
        return _Offers;
    end
    local Offers = {};
    for i= 1, #_Offers, 1 do
        for j= 1, #_Offers[i], 1 do
            local Found = false;
            for k= 1, #Offers, 1 do
                if Offers[k][1] == _Offers[i][j][1] then
                    Found = true;
                    break;
                end
            end
            if (not Found) then
                table.insert(Offers, _Offers[i][j]);
            end
        end
    end
    return Offers;
end
ConvertOldOfferFormat = API.ConvertOldOfferFormat;

---
-- Entfernt den fahrenden Händler von dem Spieler. Der Spieler bleibt
-- erhalten wird aber nicht mal als fahrender Händler fungieren.
--
-- <b>Hinweis</b>: Wenn gerade ein Schiff unterwegs ist oder im Hafen liegt,
-- wird es sofort gelöscht!
--
-- <b>Alias</b>: TravelingSalesmanDeactivate
--
-- @param[type=number] _PlayerID Spieler-ID des Händlers
-- @within Anwenderfunktionen
--
-- @usage API.TravelingSalesmanDispose(2);
--
function API.TravelingSalesmanDispose(_PlayerID)
    if GUI then
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.TravelingSalesmanDispose: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    local Harbor = BundleTravelingSalesman.Global.Data.Harbors[_PlayerID];
    if Harbor then
        info("API.TravelingSalesmanDispose: Deleting habor of player " .._PlayerID);
        Harbor:Dispose();
    end
    BundleTravelingSalesman.Global.Data.Harbors[_PlayerID] = nil;
end
TravelingSalesmanDeactivate = API.TravelingSalesmanDispose;

---
-- Deaktiviert einen fahrenden Händler. Der aktuelle Zyklus wird noch beendet,
-- aber danach kommt der Händler nicht mehr wieder.
--
-- <b>Alias</b>: TravelingSalesmanYield
--
-- @param[type=number] _PlayerID Spieler-ID des Händlers
-- @within Anwenderfunktionen
--
-- @usage API.TravelingSalesmanYield(2);
--
function API.TravelingSalesmanYield(_PlayerID)
    if GUI then
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.TravelingSalesmanYield: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    local Harbor = BundleTravelingSalesman.Global.Data.Harbors[_PlayerID];
    if Harbor then
        info("API.TravelingSalesmanYield: Suspending habor of player " .._PlayerID);
        Harbor:SetActive(false);
    end
end
API.TravelingSalesmanDeactivate = API.TravelingSalesmanYield;
TravelingSalesmanYield = API.TravelingSalesmanYield;

---
-- Aktiviert einen fahrenden Händler, der zuvor deaktiviert wurde.
--
-- <b>Alias</b>: TravelingSalesmanResume
--
-- @param[type=number] _PlayerID Spieler-ID des Händlers
-- @within Anwenderfunktionen
--
-- @usage API.TravelingSalesmanResume(2);
--
function API.TravelingSalesmanResume(_PlayerID)
    if GUI then
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.TravelingSalesmanResume: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    local Harbor = BundleTravelingSalesman.Global.Data.Harbors[_PlayerID];
    if Harbor then
        info("API.TravelingSalesmanResume: Resuming habor of player " .._PlayerID);
        Harbor:SetActive(true);
    end
end
API.TravelingSalesmanActivate = API.TravelingSalesmanResume;
TravelingSalesmanResume = API.TravelingSalesmanResume;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleTravelingSalesman = {
    Global = {
        Data = {
            Harbors = {},
            QuestInfoCounter = 0,
        },
    },
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function BundleTravelingSalesman.Global:Install()
    -- End of Month Callback
    Core:AppendFunction("GameCallback_EndOfMonth", function()
        BundleTravelingSalesman.Global:TravelingSalesmanEndOfMonth();
    end);
    -- Controller
    StartSimpleJobEx(function()
        BundleTravelingSalesman.Global:TravelingSalesmanController()
    end);
end

---
-- Registiert einen Hafen. Kann benutzt werden um Häfen zu überschreiben.
-- @param[type=table] _Harbor Harbor Model
-- @Internal
-- @local
--
function BundleTravelingSalesman.Global:RegisterHarbor(_Harbor)
    if self.Data.Harbors[_Harbor.m_PlayerID] then
        info("BundleTravelingSalesman: harbor for player " .._Harbor.m_PlayerID.. " already exists and is purged.");
        self.Data.Harbors[_Harbor.m_PlayerID]:Dispose();
    end
    info("BundleTravelingSalesman: creating harbor for player " .._Harbor.m_PlayerID.. ".");
    self.Data.Harbors[_Harbor.m_PlayerID] = _Harbor;
end

---
-- Erzeugt das Schiff und lässt es zum Hafen fahren.
-- @param[type=table] _Harbor Harbor Model
-- @Internal
-- @local
--
function BundleTravelingSalesman.Global:SpawnShip(_Harbor)
    local SpawnPoint = _Harbor:GetPath():GetFirst();
    local Orientation = Logic.GetEntityOrientation(GetID(SpawnPoint));
    local x, y, z = Logic.EntityGetPos(GetID(SpawnPoint))
    local ID = Logic.CreateEntity(Entities.D_X_TradeShip, x, y, Orientation, 0);
    _Harbor:SetShipID(ID);
    _Harbor:GetPath():SetReversed(false);
    local OnArrival = function(_Data)
        BundleTravelingSalesman.Global:ShipAtDock(_Data.Entity);
    end
    info("BundleTravelingSalesman: Ship of player " .._Harbor:GetPlayerID().. " has spawns.");
    local Instance = Path:new(ID, _Harbor:GetPath():Get(), nil, nil, OnArrival, nil, true, nil, nil, QSB.ShipWaypointDistance);
    _Harbor:SetJobID(Instance.Job);
end

---
-- Lässt das Schiff aus dem Hafen abfahren.
-- @param[type=table] _Harbor Harbor Model
-- @Internal
-- @local
--
function BundleTravelingSalesman.Global:ShipLeave(_Harbor)
    Logic.RemoveAllOffers(Logic.GetStoreHouse(_Harbor:GetPlayerID()));
    self:TriggerShipIsLeavingDockMessage(_Harbor:GetPlayerID());
    _Harbor:GetPath():SetReversed(true);
    local OnArrival = function(_Data)
        BundleTravelingSalesman.Global:ShipHasLeft(_Data.Entity);
    end
    info("BundleTravelingSalesman: Ship of player " .._Harbor:GetPlayerID().. " is leaving the harbor.");
    local Instance = Path:new(_Harbor:GetShipID(), _Harbor:GetPath():Get(), nil, nil, OnArrival, nil, true, nil, nil, QSB.ShipWaypointDistance);
    _Harbor:SetJobID(Instance.Job);
    if GameCallback_TravelingSalesmanLeave then
        GameCallback_TravelingSalesmanLeave(_Harbor:GetPlayerID(), _Harbor:GetShipID());
    end
end

---
-- Entfernt die Angebote und setzt die Werte zurück, sobald das Schiff abfährt.
-- @param[type=number] _ShipID ID des Schiffes
-- @Internal
-- @local
--
function BundleTravelingSalesman.Global:ShipHasLeft(_ShipID)
    local Harbor = self:GetHarborByShipID(_ShipID);
    if (Harbor) then
        info("BundleTravelingSalesman: Ship of player " ..Harbor:GetPlayerID().. " has despawned.");
        Harbor:SetJobID(0);
        Harbor:SetShipID(0);
        Harbor:SetDuration(Harbor:GetDuration());
        Harbor:SetIntermission(Harbor:GetInterval() +1);
        DestroyEntity(_ShipID);
    end
end

---
-- Erzeugt die Angebote sobald das Schiff im Hafen anlegt.
-- @param[type=number] _ShipID ID des Schiffes
-- @Internal
-- @local
--
function BundleTravelingSalesman.Global:ShipAtDock(_ShipID)
    local Harbor = self:GetHarborByShipID(_ShipID);
    if (Harbor) then
        info("Ship of player " ..Harbor:GetPlayerID().. " is arriving at the harbor.");
        Harbor:SetJobID(0);
        local PlayerID = Harbor:GetPlayerID();
        MerchantSystem.TradeBlackList[PlayerID] = {};
        MerchantSystem.TradeBlackList[PlayerID][0] = 0;
        self:CreateOffers(Harbor:GetRandomOffers(), Logic.GetStoreHouse(PlayerID))
        self:TriggerShipAtDockMessage(PlayerID);
        if GameCallback_TravelingSalesmanArrive then
            GameCallback_TravelingSalesmanArrive(PlayerID, _ShipID);
        end
    end
end

---
-- Erzeugt die Angebote für das angegebene Lagerhaus.
-- @param[type=table] _Offers   Angebote
-- @param[type=number] _TraderID ID Lagerhaus
-- @Internal
-- @local
--
function BundleTravelingSalesman.Global:CreateOffers(_Offers, _TraderID)
    DeActivateMerchantForPlayer(_TraderID, QSB.HumanPlayerID);
    Logic.RemoveAllOffers(_TraderID);
    local LogInfo = "BundleTravelingSalesman: Creating offers for player " .._TraderID..":";
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
        if GetDiplomacyState(QSB.HumanPlayerID, Logic.EntityGetPlayer(_TraderID)) > 0 then
            ActivateMerchantPermanentlyForPlayer(_TraderID, QSB.HumanPlayerID);
            Logic.ExecuteInLuaLocalState("g_Merchant.ActiveMerchantBuilding = nil");
        end
        LogInfo = LogInfo .. OfferString;
    end
    info(LogInfo);
end

---
-- Zeigt eine Quest Message an, dass das Schiff im Hafen vor Anker liegt.
-- @param[type=number] _PlayerID Player-ID
-- @Internal
-- @local
--
function BundleTravelingSalesman.Global:TriggerShipAtDockMessage(_PlayerID)
    self:DisplayQuestMessage(_PlayerID, {
        de = "Ein Schiff hat angelegt. Es bringt Güter von weit her.",
        en = "A ship is at the pier. It delivers goods from far away.",
        fr = "Un navire a accosté. Il apporte des marchandises de loin."
    });
end

---
-- Zeigt eine Quest Message an, dass das Schiff den Hafen verlassen hat.
-- @param[type=number] _PlayerID Player-ID
-- @Internal
-- @local
--
function BundleTravelingSalesman.Global:TriggerShipIsLeavingDockMessage(_PlayerID)
    self:DisplayQuestMessage(_PlayerID, {
        de = "Das Schiff hat den Hafen wieder verlassen.",
        en = "Time has passed on and the ship has left.",
        fr = "Le temps a passé et le navire est parti."
    });
end

---
-- Zeigt eine Quest Message an.
-- @param[type=number] _PlayerID Player-ID
-- @param              _Text (Table oder String)
-- @Internal
-- @local
--
function BundleTravelingSalesman.Global:DisplayQuestMessage(_PlayerID, _Text)
    self.Data.QuestInfoCounter = self.Data.QuestInfoCounter +1;
    QuestTemplate:New(
        "TravelingSalesman_Info_P" ..self.Data.QuestInfoCounter,
        _PlayerID,
        QSB.HumanPlayerID,
        {{Objective.Dummy,}},
        {{Triggers.Time, 0}},
        0,
        nil, nil, nil, nil, false, true,
        nil, nil,
        API.Localize(_Text),
        nil
    );
end

---
-- Ermitteld den Hafen des angegeben Schiffes.
-- @param[type=number] _ShipID ID des Schiffes
-- @return[type=table] Hafen Model
-- @Internal
-- @local
--
function BundleTravelingSalesman.Global:GetHarborByShipID(_ShipID)
    local Harbor;
    for i= 1, 8, 1 do
        Harbor = self.Data.Harbors[i];
        if (Harbor and Harbor:GetShipID() == _ShipID) then
            return Harbor;
        end
    end
    return nil;
end

---
-- Steuert die Anfahrt der Schiffe für alle Häfen.
-- @Internal
-- @local
--
function BundleTravelingSalesman.Global:TravelingSalesmanEndOfMonth()
    for i= 1, 8, 1 do
        local Harbor = self.Data.Harbors[i];
        if  (Harbor and Harbor:IsActive() and Harbor:GetShipID() == 0 and not Harbor:IsIceBlockingPath()) then
            if (Harbor:SetIntermission(Harbor:GetIntermission() -1):GetIntermission() == 0) then
                Harbor:SetIntermission(-100);
                BundleTravelingSalesman.Global:SpawnShip(Harbor);
            end
        end
    end
end

---
-- Steuert die Abfahrt der Schiffe für alle Häfen.
-- @Internal
-- @local
--
function BundleTravelingSalesman.Global:TravelingSalesmanController()
    for i= 1, 8, 1 do
        local Harbor = self.Data.Harbors[i];
        if  (Harbor and not Harbor:HasElapsed() and Harbor:GetShipID() ~= 0 and not Harbor:IsIceBlockingPath()
        and IsNear(Harbor:GetShipID(), Harbor:GetPath():GetLast(), QSB.ShipWaypointDistance)) then
            if (Harbor:Elapse():HasElapsed()) then
                self:ShipLeave(Harbor);
            end
        end
    end
end

-- Klassen ------------------------------------------------------------------ --

QSB.TradeShipPath = {
    m_Waypoints = {};
    m_Reversed = false;
}

function QSB.TradeShipPath:New(...)
    local Path = API.InstanceTable(self);
    if #arg == 1 and type(arg[1]) == "string" then
        local i = 1;
        while (IsExisting(arg[1] ..i)) do
            table.insert(Path.m_Waypoints, arg[1] ..i);
            i = i +1;
        end
    elseif #arg == 1 and type(arg[1]) == "table" then
        Path.m_Waypoints = API.InstanceTable(arg[1]);
    else
        Path.m_Waypoints = API.InstanceTable(arg);
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
    return;
end

-- -------------------------------------------------------------------------- --

QSB.TradeShipHarbor = {
    m_Path = {};
    m_OfferTypes = {};
    m_Active = false;
    m_NoIce = false;
    m_PlayerID = 1;
    m_Duration = 180;
    m_TimeLeft = 180;
    m_Interval = 2;
    m_BreakMonths = 1;
    m_OfferCount = 0;
    m_ShipID = 0;
    m_JobID = 0;
};

function QSB.TradeShipHarbor:New(_PlayerID)
    local Harbor = API.InstanceTable(self);
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

Core:RegisterBundle("BundleTravelingSalesman");

