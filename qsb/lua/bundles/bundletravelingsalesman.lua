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

QSB.TravelingSalesman = {
	Harbors = {}
};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erstellt einen fahrender Händler mit zufälligen Angeboten.
--
-- Soll immer das selbe angeboten werden, darf nur ein Angebotsblock
-- definiert werden.
-- Es kann mehr als einen fahrender Händler auf der Map geben.
--
-- <h5>Angebote</h5>
-- Es sind maximal 4 Angebote pro Angebotsblock erlaubt. Es können Waren,
-- Soldaten oder Entertainer angeboten werden. Es wird immer automatisch 1
-- Block selektiert und die Angebote gesetzt.
--
-- <h5>Routen</h5>
-- Über Waypoints wird der Weg bestimmt, den das Handelsschiff nehmen wird.
-- Die Umkehrung der Route ist standardmäßig als Rückweg festgelegt. Will
-- man einen anderen Rückweg, muss dieser als Reversed angegeben werden.
--
-- <b>Alias</b>: TravelingSalesmanActivate
--
-- @param[type=table]  _Description Definition des Händlers
-- @within Anwenderfunktionen
--
-- @usage local TraderDescription = {
--     PlayerID = 2,
--     Waypoints = {"WP1", "WP2", "WP3", "WP4"},
--     Offers = {
--         {
--             {"G_Gems", 5,},
--             {"G_Iron", 5,},
--             {"G_Beer", 2,},
--         },
--         {
--             {"G_Stone", 5,},
--             {"G_Sheep", 1,},
--             {"G_Cheese", 2,},
--             {"G_Milk", 5,},
--         },
--         {
--             {"G_Grain", 5,},
--             {"G_Broom", 2,},
--             {"G_Sheep", 1,},
--         },
--         {
--             {"U_CatapultCart", 1,},
--             {"U_MilitarySword", 3,},
--             {"U_MilitaryBow", 3,},
--         },
--     },
-- };
-- API.TravelingSalesmanCreate(TraderDescription);
--
function API.TravelingSalesmanCreate(_TraderDescription)
    if GUI then
        API.Fatal("Can not execute API.TravelingSalesmanActivate in local script!");
        return;
    end
    return QSB.TravelingSalesman:New(_TraderDescription.PlayerID)
        :SetOffers(_TraderDescription.Offers)
        :SetApproachRoute(_TraderDescription.Waypoints)
        :SetReturnRouteRoute(_TraderDescription.Reversed)
        :SetApperance(_TraderDescription.Appearance)
        :UseOfferRotation(_TraderDescription.Flag or true)
        :Activate();
end
TravelingSalesmanActivate = API.TravelingSalesmanCreate;

---
-- Entfernt den fahrenden Händler von dem Spieler. Der Spieler bleibt
-- erhalten wird aber nicht mal als fahrender Händler fungieren.
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
        API.Bridge("API.TravelingSalesmanDispose(" .._PlayerID.. ")");
        return;
    end
    QSB.TravelingSalesman:GetInstance(_PlayerID):Dispose();
end
TravelingSalesmanDeactivate = API.TravelingSalesmanDispose;

---
-- Aktiviert einen fahrenden Händler, der zuvor deaktiviert wurde.
--
-- <b>Alias</b>: TravelingSalesmanResume
--
-- @param[type=number] _PlayerID Spieler-ID des Händlers
-- @within Anwenderfunktionen
--
-- @usage API.TravelingSalesmanActivate(2);
--
function API.TravelingSalesmanActivate(_PlayerID)
    if GUI then
        API.Bridge("API.TravelingSalesmanDeactivate(" .._PlayerID.. ")");
        return;
    end
    QSB.TravelingSalesman:GetInstance(_PlayerID):Aktivate();
end
TravelingSalesmanResume = API.TravelingSalesmanActivate;

---
-- Deaktiviert einen fahrenden Händler. Der aktuelle Zyklus wird noch beendet,
-- aber danach kommt der Händler nicht mehr wieder.
--
-- <b>Alias</b>: TravelingSalesmanYield
--
-- @param[type=number] _PlayerID Spieler-ID des Händlers
-- @within Anwenderfunktionen
--
-- @usage API.TravelingSalesmanDeactivate(2);
--
function API.TravelingSalesmanDeactivate(_PlayerID)
    if GUI then
        API.Bridge("API.TravelingSalesmanDeactivate(" .._PlayerID.. ")");
        return;
    end
    QSB.TravelingSalesman:GetInstance(_PlayerID):Deaktivate();
end
TravelingSalesmanYield = API.TravelingSalesmanDeactivate;

---
-- Legt fest, ob die Angebote der Reihe nach durchgegangen werden (beginnt von
-- vorn, wenn am Ende angelangt) oder zufällig ausgesucht werden.
--
-- <b>Alias</b>: TravelingSalesmanRotationMode
--
-- @param[type=number]  _PlayerID Spieler-ID des Händlers
-- @param[type=boolean] _Flag Angebotsrotation einschalten
-- @within Anwenderfunktionen
--
-- @usage API.TravelingSalesmanRotationMode(2, true);
--
function API.TravelingSalesmanRotationMode(_PlayerID, _Flag)
    if GUI then
        API.Bridge("API.TravelingSalesmanRotationMode(" .._PlayerID.. ", " ..tostring(_Flag).. ")");
        return;
    end
    QSB.TravelingSalesman:GetInstance(_PlayerID):UseOfferRotation(_Flag);
end
TravelingSalesmanRotationMode = API.TravelingSalesmanRotationMode;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleTravelingSalesman = {
    Global = {
        Data = {},
    },
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function BundleTravelingSalesman.Global:Install()
    StartSimpleJobEx(BundleTravelingSalesman.Global.TravelingSalesmanController);
end

---
-- Ruft die Loop-Funktion aller Fahrenden Händler auf.
-- @within Internal
-- @local
--
function BundleTravelingSalesman.Global.TravelingSalesmanController()
    for i= 1, 8, 1 do
        if QSB.TravelingSalesman:GetInstance(i) then
            QSB.TravelingSalesman:GetInstance(i):Loop();
        end
    end
end

-- Klassen ------------------------------------------------------------------ --

QSB.TravelingSalesmanInstances = {};

QSB.TravelingSalesman = {}

---
-- Konstruktor
-- @param[type=number] _PlayerID Player-ID des Händlers
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:New(_PlayerID)
    local salesman = API.InstanceTable(self);
    salesman.m_PlayerID = _PlayerID;
    salesman.m_Offers = {};
    salesman.m_Appearance = {{3, 5}, {7, 9}};
    salesman.m_Waypoints = nil;
    salesman.m_Reversed = nil;
    salesman.m_OfferRotation = false;
    salesman.m_LastOffer = 0;
    salesman.m_Status = 0;
    QSB.TravelingSalesmanInstances[_PlayerID] = salesman;
    return salesman;
end

---
-- Gibt die Instanz des Fahrenden Händlers für die Player-ID zurück.
--
-- @param[type=number] _PlayerID Player-ID des Händlers
-- @return[type=table] Instanz
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:GetInstance(_PlayerID)
    if QSB.TravelingSalesmanInstances[_PlayerID] then
        return QSB.TravelingSalesmanInstances[_PlayerID];
    end
end

---
-- Startet einen initialisierten Händler.
-- @return[type=table] Instanz
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:Activate()
    self.m_Active = true;
    if type(self.m_Waypoints) ~= "table" or type(self.m_Reversed) ~= "table" then
        fatal("QSB.TravelingSalesman:Activate: trader "..self.m_PlayerID.." must have a approach and a return route!");
        return;
    end
    return self;
end

---
-- Stoppt einen aktiven Händler, sodass der nächste Zyklus nicht mehr startet.
-- @return[type=table] Instanz
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:Deactivate()
    self.m_Active = false;
    return self;
end

---
-- Gibt die ID des ersten aktiven menschlichen Spielers zurück.
-- @return[type=number] Player-ID
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:GetHumanPlayer()
    for i= 1, 8, 1 do
        if Logic.PlayerGetIsHumanFlag(1) == true then
            return i;
        end
    end
    return 0;
end

---
-- Entfernt alle Angebotsblöcke des Fahrenden Händlers.
-- @return[type=table] self
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:ClearOffers()
    return self:SetOffers({});
end

---
-- Setzt eine Liste von Angebotsblöcken für den Fahrenden Händler.
-- @param[type=table] _Offers Definierte Angebotsblöcke
-- @return[type=table] self
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:SetOffers(_Offers)
    self.m_Offers = _Offers;
    return self;
end

---
-- Fügt dem Fahrenden Händler einen Angebotsblock hinzu. Es wird zuerst der
-- Warentyp als String und danach die Anzahl angegeben.
-- @return[type=table] self
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:AddOffer(...)
    local Offer = {};
    for i= 1, #arg, 2 do
        table.insert(Offer, {arg[i], arg[i+1]});
    end
    table.insert(self.m_Offers, Offer);
    return self;
end

---
-- Löscht die Aufenthaltszeitspanne des Fahrenden Händlers.
-- @return[type=table] self
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:ClearApperance()
    return self:SetApperance({});
end

---
-- Fügt einen Zeitraum zur Aufenthalt des Fliegenden Händlers hinzu. Ein
-- Zeitraum besteht aus Startmonat und Endmonat.
-- @return[type=table] self
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:AddApperance(_Start, _End)
    table.insert(self.m_Appearance, {_Start, _End});
    return self;
end

---
-- Setzt die Aufenthaltszeitspanne des Fliegenden Händlers
-- @param[type=table] _Apperance Aufenthaltszeitspanne
-- @return[type=table] self
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:SetApperance(_Apperance)
    self.m_Appearance = _Apperance or self.m_Appearance;
    return self;
end

---
-- Setzt die Route für die Ankunft des Fahrenden Händlers.
-- @param[type=table] _List Liste der Wegpunkte
-- @return[type=table] self
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:SetApproachRoute(_List)
    self.m_Waypoints = API.InstanceTable(_List);
    self.m_SpawnPos = self.m_Waypoints[1];
    self.m_Destination = self.m_Waypoints[#_List];
    return self;
end

---
-- Setzt die Wegpunkte für die Abfahrt des Fliegenden Händlers. Ist die Liste
-- nil, werden die Wegpunkte für die Anfahrt invertiert.
-- @param[type=table] _List Liste der Wegpunkte
-- @return[type=table] self
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:SetReturnRouteRoute(_List)
    local Reversed = _List;
    if type(Reversed) ~= "table" then
        Reversed = {};
        for i= #self.m_Waypoints, 1, -1 do
            table.insert(Reversed, self.m_Waypoints[i]);
        end
    end
    self.m_Reversed = API.InstanceTable(Reversed);
    return self;
end

---
-- Aktiviert oder deaktiviert die sequentielle Abarbeitung der Angebote dieses
-- Fliegenden Händlers.
-- @param[type=boolean] _Flag Angebote sequenziell durchlaufen
-- @return[type=table] self
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:UseOfferRotation(_Flag)
    self.m_OfferRotation = _Flag == true;
    return self;
end

---
-- Invalidiert die Instanz dieses Fliegenden Händlers.
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:Dispose()
    Logic.RemoveAllOffers(Logic.GetStoreHouse(self.m_PlayerID));
    DestroyEntity("TravelingSalesmanShip_Player" ..self.m_PlayerID);
    QSB.TravelingSalesmanInstances[self.m_PlayerID] = nil;
end

---
-- Gibt einen Block Angebote für diesen Fahrenden Händler zurück.
-- @return[type=table] Angebote
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:NextOffer()
    local NextOffer;
    if self.m_OfferRotation then
        self.m_LastOffer = self.m_LastOffer +1;
        if self.m_LastOffer > #self.m_Offers then
            self.m_LastOffer = 1;
        end
        NextOffer = self.m_Offers[self.m_LastOffer];
    else
        local RandomIndex = 1;
        if #self.m_Offers > 1 then
            repeat
                RandomIndex = math.random(1,#self.m_Offers);
            until (RandomIndex ~= self.m_LastOffer);
        end
        self.m_LastOffer = RandomIndex;
        NextOffer = self.m_Offers[self.m_LastOffer];
    end
    return NextOffer;
end

---
-- Zeigt die Info-Nachricht an, wenn ein Schiff im Hafen anlegt.
-- @return[type=table] self
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:DisplayInfoMessage()
    if ((IsBriefingActive and not IsBriefingActive()) or true) then
        local InfoQuest = Quests[GetQuestID("TravelingSalesman_Info_P" ..self.m_PlayerID)];
        if InfoQuest then
            API.RestartQuest("TravelingSalesman_Info_P" ..self.m_PlayerID, true);
            InfoQuest:SetMsgKeyOverride();
            InfoQuest:SetIconOverride();
            if BundleQuestGeneration then
                BundleQuestGeneration.Global:OnQuestStateSupposedChanged(QSB.QuestStateChange.BeforeTrigger, InfoQuest);
            end
            InfoQuest:Trigger();
            if BundleQuestGeneration then
                BundleQuestGeneration.Global:OnQuestStateSupposedChanged(QSB.QuestStateChange.AfterTrigger, InfoQuest);
            end
            return self;
        end

        local Text = {
            de = "Ein Schiff hat angelegt. Es bringt Güter von weit her.",
            en = "A ship is at the pier. It delivers goods from far away.",
            fr = "Un navire a accosté. Il apporte des marchandises de loin."
        };
        QuestTemplate:New(
            "TravelingSalesman_Info_P" ..self.m_PlayerID,
            self.m_PlayerID,
            self:GetHumanPlayer(),
            {{Objective.Dummy,}},
            {{Triggers.Time, 0}},
            0,
            nil, nil, nil, nil, false, true,
            nil, nil,
            API.Localize(Text),
            nil
        );
    end
    return self;
end

---
-- Fügt dem Fahrenden Händler ein neues Angebot hinzu.
-- @return[type=table] self
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:IntroduceNewOffer()
    MerchantSystem.TradeBlackList[self.m_PlayerID] = {};
    MerchantSystem.TradeBlackList[self.m_PlayerID][0] = #MerchantSystem.TradeBlackList[3];

    local traderId = Logic.GetStoreHouse(self.m_PlayerID);
    local offer = self:NextOffer();
    Logic.RemoveAllOffers(traderId);

    if #offer > 0 then
        for i=1,#offer,1 do
            local offerType = offer[i][1];
            local isGoodType = false;
            for k,v in pairs(Goods)do
                if k == offerType then
                    isGoodType = true;
                end
            end

            if isGoodType then
                local amount = offer[i][2];
                AddOffer(traderId,amount,Goods[offerType], 9999);
            else
                if Logic.IsEntityTypeInCategory(Entities[offerType],EntityCategories.Military)== 0 then
                    AddEntertainerOffer(traderId,Entities[offerType]);
                else
                    local amount = offer[i][2];
                    AddMercenaryOffer(traderId,amount,Entities[offerType], 9999);
                end
            end
        end
    end
    SetDiplomacyState(self:GetHumanPlayer(), self.m_PlayerID, DiplomacyStates.TradeContact);
    Logic.SetTraderPlayerState(Logic.GetStoreHouse(self.m_PlayerID), self:GetHumanPlayer(), 1);
    return self;
end

---
-- Steuert den Ablauf des fliegenden Händlers.
-- @return[type=table] self
-- @within QSB.TravelingSalesman
-- @local
--
function QSB.TravelingSalesman:Loop()
    if Logic.PlayerGetIsHumanFlag(self.m_PlayerID) == false then
        if self.m_Status == 0 and self.m_Active == true then
            local month = Logic.GetCurrentMonth();
            local start = false;
            for i=1, #self.m_Appearance,1 do
                if month == self.m_Appearance[i][1] then
                    start = true;
                end
            end
            if start then
                local orientation = Logic.GetEntityOrientation(GetID(self.m_SpawnPos))
                local ID = CreateEntity(0, Entities.D_X_TradeShip, GetPosition(self.m_SpawnPos), "TravelingSalesmanShip_Player" ..self.m_PlayerID, orientation);
                Path:new(ID,self.m_Waypoints, nil, nil, nil, nil, true, nil, nil, 300);
                self.m_Status = 1;
            end

        elseif self.m_Status == 1 then
            if IsNear("TravelingSalesmanShip_Player" ..self.m_PlayerID, self.m_Destination, 400) then
                self:IntroduceNewOffer():DisplayInfoMessage();
                self.m_Status = 2;
            end
            
        elseif self.m_Status == 2 then
            local month = Logic.GetCurrentMonth();
            local stop = false;
            for i=1, #self.m_Appearance,1 do
                if month == self.m_Appearance[i][2] then
                    stop = true;
                end
            end

            if stop then
                SetDiplomacyState(self:GetHumanPlayer(), self.m_PlayerID, DiplomacyStates.EstablishedContact);
                Path:new(GetID("TravelingSalesmanShip_Player" ..self.m_PlayerID), self.m_Reversed, nil, nil, nil, nil, true, nil, nil, 300);
                Logic.RemoveAllOffers(Logic.GetStoreHouse(self.m_PlayerID));
                self.m_Status = 3;
            end

        elseif self.m_Status == 3 then
            if IsNear("TravelingSalesmanShip_Player" ..self.m_PlayerID, self.m_Reversed[#self.m_Reversed], 400) then
                DestroyEntity("TravelingSalesmanShip_Player" ..self.m_PlayerID);
                self.m_Status = 0;
            end
        end
    end
    return self;
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleTravelingSalesman");

