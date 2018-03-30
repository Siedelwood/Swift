-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleCastleStore                                            # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle stellt ein Burglager zur Verfügung, das sich ähnlich wie das
-- normale Lager verhält. Das Burglager ist von der Ausbaustufe der Burg
-- abhängig. Je weiter die Burg ausgebaut wird, desto höher ist das Limit.
-- Eine Ware wird dann im Burglager eingelagert, wenn das eingestellte Limit
-- der Ware im Lagerhaus erreicht wird.
--
-- Der Spieler kann das allgemeine Verhalten des Lagers für alle Waren wählen,
-- und zusätzlich für einzelne Waren andere Verhalten bestimmen. Waren können
-- eingelagert und ausgelagert werden. Eingelagerte Waren können zusätzlich
-- gesperrt werden. Eine gesperrte Ware wird nicht wieder ausgelagert, auch
-- wenn Platz im Lager frei wird.
--
-- @usage
-- -- Ein Lager erzeugen:
-- MyStore = QSB.CastleStore:New(1);
--
-- -- Ein Lager löschen:
-- MyStore:Dispose();
--
-- -- Gesamtmenge aller Waren im Burglager:
-- local Amount = MyStore:GetTotalAmount();
-- -- Menge einer Ware ermitteln:
-- -- Sicheres ermitteln aller Waren mit und mit ohne Burglager
-- -- Achtung: Dies ist eine statische Methode!
-- local Amount = QSB.CastleStore:GetGoodAmountWithCastleStore(Goods.G_Grain, 1, false);
-- Menge einer bestimmten Ware ermitteln:
-- local Amount = MyStore:GetAmount(Goods.G_Wood);
-- -- Aktuelles Limit erhalten:
-- MyStore:GetLimit();
--
-- -- Statisch das Lager eines Spielers erhalten:
-- local MyStore = QSB.CastleStore:GetInstance(1);
-- -- Nutzung der Instanz: s.o.
--
-- @module BundleCastleStore
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

-- Es gibt keine API-Funktionen!

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleCastleStore = {
    Global = {
        Data = {
            UpdateCastleStore = false,
            CastleStoreObjects = {},
        },
        CastleStore = {
            Data = {
                CapacityBase = 75,
                Goods = {
                    -- [Ware] = {Menge, Einlager-Flag, Gesperrt-Flag, Untergrenze}
                    [Goods.G_Wood]      = {0, true, false, 35},
                    [Goods.G_Stone]     = {0, true, false, 35},
                    [Goods.G_Iron]      = {0, true, false, 35},
                    [Goods.G_Carcass]   = {0, true, false, 15},
                    [Goods.G_Grain]     = {0, true, false, 15},
                    [Goods.G_RawFish]   = {0, true, false, 15},
                    [Goods.G_Milk]      = {0, true, false, 15},
                    [Goods.G_Herb]      = {0, true, false, 15},
                    [Goods.G_Wool]      = {0, true, false, 15},
                    [Goods.G_Honeycomb] = {0, true, false, 15},
                }
            },
        },
    },
    Local = {
        Data = {},

        CastleStore = {
            Data = {}
        },

        Description = {
            ShowCastle = {
                Text = {
                    de = "Finanzansicht",
                    en = "Financial view",
                },
            },

            ShowCastleStore = {
                Text = {
                    de = "Lageransicht",
                    en = "Storeage view",
                },
            },

            GoodButtonDisabled = {
                Text = {
                    de = "Diese Ware wird nicht angenommen.",
                    en = "This good will not be stored.",
                },
            },

            CityTab = {
                Title = {
                    de = "Waren bunkern",
                    en = "Keep goods",
                },
                Text = {
                    de = "- Lagert Waren im Burglager ein {cr}- Waren verbleiben auch im Lager, wenn Platz vorhanden ist",
                    en = "- Stores goods inside the store {cr}- Goods also remain in the warehouse when space is available",
                },
            },

            StorehouseTab = {
                Title = {
                    de = "Waren zwischenlagern",
                    en = "Store goods temporarily",
                },
                Text = {
                    de = "- Lagert Waren im Burglager ein {cr}- Lagert waren wieder aus, sobald Platz frei wird",
                    en = "- Stores goods inside the store {cr}- Allows to extrac goods as soon as space becomes available",
                },
            },

            MultiTab = {
                Title = {
                    de = "Lager räumen",
                    en = "Clear store",
                },
                Text = {
                    de = "- Lagert alle Waren aus {cr}- Benötigt Platz im Lagerhaus",
                    en = "- Removes all goods {cr}- Requires space in the storehouse",
                },
            },
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
function BundleCastleStore.Global:Install()
    QSB.CastleStore = BundleCastleStore.Global.CastleStore;
    self:OverwriteGameFunctions()
    API.AddSaveGameAction(BundleCastleStore.Global.OnSaveGameLoaded);
end

---
-- Erzeugt ein neues Burglager-Objekt und gibt es zurück.
--
-- <b>Alias</b>: QSB.CastleStore:New
--
-- @param number _PlayerID     PlayerID des Spielers
-- @return QSB.CastleStore
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:New(_PlayerID)
    assert(self == BundleCastleStore.Global.CastleStore, "Can not be used from instance!");
    local Store = API.InstanceTable(self);
    Store.Data.PlayerID = _PlayerID;
    BundleCastleStore.Global.Data.CastleStoreObjects[_PlayerID] = Store;

    if not self.Data.UpdateCastleStore then
        self.Data.UpdateCastleStore = true;
        StartSimpleJobEx(BundleCastleStore.Global.CastleStore.UpdateStores);
    end
    Logic.ExecuteInLuaLocalState([[
        QSB.CastleStore:CreateStore(]] ..Store.Data.PlayerID.. [[);
    ]])
    return Store;
end

---
-- Gibt die Burglagerinstanz für den Spieler zurück.
--
-- <b>Alias</b>: QSB.CastleStore:GetInstance
--
-- @param number _PlayerID     PlayerID des Spielers
-- @return QSB.CastleStore
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:GetInstance(_PlayerID)
    assert(self == BundleCastleStore.Global.CastleStore, "Can not be used from instance!");
    return BundleCastleStore.Global.Data.CastleStoreObjects[_PlayerID];
end

---
-- Gibt die Menge an Waren des Spielers zurück, eingeschlossen
-- der Waren im Burglager. Hat der Spieler kein Burglager, wird
-- nur die Menge im Lagerhaus zurückgegeben.
--
-- <b>Alias</b>: QSB.CastleStore:GetGoodAmountWithCastleStore
--
-- @param number _Good          Warentyp
-- @param number _PlayeriD      ID des Spielers
-- @return number
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:GetGoodAmountWithCastleStore(_Good, _PlayerID, _WithoutMarketplace)
    assert(self == BundleCastleStore.Global.CastleStore, "Can not be used from instance!");
    local CastleStore = self:GetInstance(_PlayerID);
    local Amount = GetPlayerGoodsInSettlement(_Good, _PlayerID, _WithoutMarketplace);

    if CastleStore ~= nil and _Good ~= Goods.G_Gold and Logic.GetGoodCategoryForGoodType(_Good) == GoodCategories.GC_Resource then
        Amount = Amount + CastleStore:GetAmount(_Good);
    end
    return Amount;
end

---
-- Zerstört das Burglager.
--
-- <b>Alias</b>: QSB.CastleStore:Dispose
--
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:Dispose()
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    Logic.ExecuteInLuaLocalState([[
        QSB.CastleStore:DeleteStore(]] ..self.Data.PlayerID.. [[);
    ]])
    BundleCastleStore.Global.Data.CastleStoreObjects[self.Data.PlayerID] = nil;
end

---
-- Setzt die Obergrenze für eine Ware, ab der ins Burglager
-- ausgelagert wird.
--
-- <b>Alias</b>: QSB.CastleStore:SetUperLimitInStorehouseForGoodType
--
-- @param number _Good      Warentyp
-- @param number _Limit     Obergrenze
-- @return self
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:SetUperLimitInStorehouseForGoodType(_Good, _Limit)
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    self.Data.Goods[_Good][4] = _Limit;
    Logic.ExecuteInLuaLocalState([[
        BundleCastleStore.Local.Data.CastleStore[]] ..self.Data.PlayerID.. [[].Goods[]] .._Good.. [[][4] = ]] .._Limit.. [[
    ]])
    return self;
end

---
-- Setzt den Basiswert für die maximale Kapazität des Burglagers.
--
-- <b>Alias</b>: QSB.CastleStore:SetStorageLimit
--
-- @param number _Limit     Maximale Kapazität
-- @return self
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:SetStorageLimit(_Limit)
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    self.Data.CapacityBase = _Limit;
    Logic.ExecuteInLuaLocalState([[
        BundleCastleStore.Local.Data.CastleStore[]] ..self.Data.PlayerID.. [[].CapacityBase = ]] .._Limit.. [[
    ]])
    return self;
end

---
-- Gibt die Menge an Waren des Typs im Burglager zurück.
--
-- <b>Alias</b>: QSB.CastleStore:GetAmount
--
-- @param number _Good  Warentyp
-- @return number
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:GetAmount(_Good)
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    if self.Data.Goods[_Good] then
        return self.Data.Goods[_Good][1];
    end
    return 0;
end

---
-- Gibt die Gesamtmenge aller Waren im Burglager zurück.
--
-- <b>Alias</b>: QSB.CastleStore:GetTotalAmount
--
-- @return number
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:GetTotalAmount()
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    local TotalAmount = 0;
    for k, v in pairs(self.Data.Goods) do
        TotalAmount = TotalAmount + v[1];
    end
    return TotalAmount;
end

---
-- Gibt das aktuelle Lagerlimit zurück.
--
-- <b>Alias</b>: QSB.CastleStore:GetLimit
--
-- @return number
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:GetLimit()
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    local Level = 0;
    local Headquarters = Logic.GetHeadquarters(self.Data.PlayerID);
    if Headquarters ~= 0 then
        Level = Logic.GetUpgradeLevel(Headquarters);
    end

    local Capacity = self.Data.CapacityBase;
    for i= 1, (Level+1), 1 do
        Capacity = Capacity * 2;
    end
    return Capacity;
end

---
-- Gibt zurück, ob die Ware akzeptiert wird.
--
-- <b>Alias</b>: QSB.CastleStore:IsGoodAccepted
--
-- @param number _Good  Warentyp
-- @return boolean
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:IsGoodAccepted(_Good)
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    return self.Data.Goods[_Good][2] == true;
end

---
-- Setzt den Akzeptanzstatus der Ware.
--
-- <b>Alias</b>: QSB.CastleStore:SetGoodAccepted
--
-- @param number _Good      Watentyp
-- @param boolean _Flag     Akzeptanz-Flag
-- @return self
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:SetGoodAccepted(_Good, _Flag)
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    self.Data.Goods[_Good][2] = _Flag == true;
    Logic.ExecuteInLuaLocalState([[
        QSB.CastleStore:SetAccepted(
            ]] ..self.Data.PlayerID.. [[, ]] .._Good.. [[, ]] ..tostring(_Flag == true).. [[
        )
    ]])
    return self;
end

---
-- Gibt zurück, ob die Ware gesperrt ist.
--
-- <b>Alias</b>: QSB.CastleStore:IsGoodLocked
--
-- @param number _Good  Warentyp
-- @return boolean
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:IsGoodLocked(_Good)
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    return self.Data.Goods[_Good][3] == true;
end

---
-- Setzt ob die Ware gesperrt ist, also nicht ausgelagert wird.
--
-- <b>Alias</b>: QSB.CastleStore:SetGoodLocked
--
-- @param number _Good      Watentyp
-- @param boolean _Flag     Akzeptanz-Flag
-- @return self
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:SetGoodLocked(_Good, _Flag)
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    self.Data.Goods[_Good][3] = _Flag == true;
    Logic.ExecuteInLuaLocalState([[
        QSB.CastleStore:SetLocked(
            ]] ..self.Data.PlayerID.. [[, ]] .._Good.. [[, ]] ..tostring(_Flag == true).. [[
        )
    ]])
    return self;
end

---
-- Setzt den Modus "Zwischenlagerung", als ob der Tab geklickt wird.
--
-- <b>Alias</b>: QSB.CastleStore:ActivateTemporaryMode
--
-- @return self
-- @within Private
-- @local
--
function BundleCastleStore.Global.CastleStore:ActivateTemporaryMode()
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    Logic.ExecuteInLocalLuaState([[
        QSB.CastleStore.OnStorehouseTabClicked(QSB.CastleStore, ]] ..self.Data.PlayerID.. [[)
    ]])
    return self;
end

---
-- Setzt den Modus "Bunkern", als ob der Tab geklickt wird.
--
-- <b>Alias</b>: QSB.CastleStore:ActivateStockMode
--
-- @return self
-- @within Private
-- @local
--
function BundleCastleStore.Global.CastleStore:ActivateStockMode()
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    Logic.ExecuteInLocalLuaState([[
        QSB.CastleStore.OnCityTabClicked(QSB.CastleStore, ]] ..self.Data.PlayerID.. [[)
    ]])
    return self;
end

---
-- Setzt den Modus "Auslagerung", als ob der Tab geklickt wird.
--
-- <b>Alias</b>: QSB.CastleStore:ActivateOutsourceMode
--
-- @return self
-- @within Private
-- @local
--
function BundleCastleStore.Global.CastleStore:ActivateOutsourceMode()
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    Logic.ExecuteInLocalLuaState([[
        QSB.CastleStore.OnMultiTabClicked(QSB.CastleStore, ]] ..self.Data.PlayerID.. [[)
    ]])
    return self;
end

---
-- Lagert eine Menge von Waren im Burglager ein.
--
-- <b>Alias</b>: QSB.CastleStore:Store
--
-- @param number _Good      Watentyp
-- @param number _Amount    Menge
-- @return self
-- @within Private
-- @local
--
function BundleCastleStore.Global.CastleStore:Store(_Good, _Amount)
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    if self:IsGoodAccepted(_Good) then
        if self:GetLimit() >= self:GetTotalAmount() + _Amount then
            local Level = Logic.GetUpgradeLevel(Logic.GetHeadquarters(self.Data.PlayerID));
            if GetPlayerResources(_Good, self.Data.PlayerID) > (self.Data.Goods[_Good][4] * (Level+1)) then
                AddGood(_Good, _Amount * (-1), self.Data.PlayerID);
                self.Data.Goods[_Good][1] = self.Data.Goods[_Good][1] + _Amount;
                Logic.ExecuteInLuaLocalState([[
                    QSB.CastleStore:SetAmount(
                        ]] ..self.Data.PlayerID.. [[, ]] .._Good.. [[, ]] ..self.Data.Goods[_Good][1].. [[
                    )
                ]]);
            end
        end
    end
    return self;
end

---
-- Lagert eine Menge von Waren aus dem Burglager aus.
--
-- <b>Alias</b>: QSB.CastleStore:Outsource
--
-- @param number _Good      Watentyp
-- @param number _Amount    Menge
-- @return self
-- @within Private
-- @local
--
function BundleCastleStore.Global.CastleStore:Outsource(_Good, _Amount)
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    local Level = Logic.GetUpgradeLevel(Logic.GetHeadquarters(self.Data.PlayerID));
    if Logic.GetPlayerUnreservedStorehouseSpace(self.Data.PlayerID) >= _Amount then
        if self:GetAmount(_Good) >= _Amount then
            AddGood(_Good, _Amount, self.Data.PlayerID);
            self.Data.Goods[_Good][1] = self.Data.Goods[_Good][1] - _Amount;
            Logic.ExecuteInLuaLocalState([[
                QSB.CastleStore:SetAmount(
                    ]] ..self.Data.PlayerID.. [[, ]] .._Good.. [[, ]] ..self.Data.Goods[_Good][1].. [[
                )
            ]]);
        end
    end
    return self;
end

---
-- Fügt eine Menge an Waren dem Burglager hinzu, solange noch
-- Platz vorhanden ist und die Ware angenommen wird.
--
-- <b>Alias</b>: QSB.CastleStore:Add
--
-- @param number _Good      Watentyp
-- @param number _Amount    Menge
-- @return self
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:Add(_Good, _Amount)
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    if self:IsGoodAccepted(_Good) then
        for i= 1, _Amount, 1 do
            if self:GetLimit() > self:GetTotalAmount() then
                self.Data.Goods[_Good][1] = self.Data.Goods[_Good][1] + 1;
            end
        end
        Logic.ExecuteInLuaLocalState([[
            QSB.CastleStore:SetAmount(
                ]] ..self.Data.PlayerID.. [[, ]] .._Good.. [[, ]] ..self.Data.Goods[_Good][1].. [[
            )
        ]]);
    end
    return self;
end

---
-- Entfernt eine Menge an Waren aus dem Burglager ohne sie ins
-- Lagerhaus zu legen.
--
-- <b>Alias</b>: QSB.CastleStore:Remove
--
-- @param number _Good      Watentyp
-- @param number _Amount    Menge
-- @return self
-- @within QSB.CastleStore
--
function BundleCastleStore.Global.CastleStore:Remove(_Good, _Amount)
    assert(self ~= BundleCastleStore.Global.CastleStore, "Can not be used in static context!");
    if self:GetAmount(_Good) > 0 then
        local ToRemove = (_Amount <= self:GetAmount(_Good) and _Amount) or self:GetAmount(_Good);
        self.Data.Goods[_Good][1] = self.Data.Goods[_Good][1] - ToRemove;
        Logic.ExecuteInLuaLocalState([[
            QSB.CastleStore:SetAmount(
                ]] ..self.Data.PlayerID.. [[, ]] .._Good.. [[, ]] ..self.Data.Goods[_Good][1].. [[
            )
        ]]);
    end
    return self;
end

---
-- Aktualisiert die Waren im Lager und im Burglager.
--
-- <b>Alias</b>: QSB.CastleStore.UpdateStores
--
-- @within Private
-- @local
--
function BundleCastleStore.Global.CastleStore.UpdateStores()
    assert(self == nil, "This method is only procedural!");
    for k, v in pairs(BundleCastleStore.Global.Data.CastleStoreObjects) do
        if v ~= nil then
            local Level = Logic.GetUpgradeLevel(Logic.GetHeadquarters(v.Data.PlayerID));
            for kk, vv in pairs(v.Data.Goods) do
                if vv ~= nil then
                    -- Ware wird angenommen
                    if vv[2] == true then
                        local AmountInStore  = GetPlayerResources(kk, v.Data.PlayerID)
                        local AmountInCastle = v:GetAmount(kk)
                        -- Auslagern, wenn möglich
                        if AmountInStore < (v.Data.Goods[kk][4] * (Level+1)) then
                            if vv[3] == false then
                                local Amount = (v.Data.Goods[kk][4] * (Level+1)) - AmountInStore;
                                Amount = (Amount > 10 and 10) or Amount;
                                for i= 1, Amount, 1 do
                                    v:Outsource(kk, 1);
                                end
                            end
                        -- Einlagern, falls möglich
                        else
                            local Amount = (AmountInStore > 10 and 10) or AmountInStore;
                            for i= 1, Amount, 1 do
                                v:Store(kk, 1);
                            end
                        end
                    -- Ware ist gebannt
                    else
                        local Amount = (v:GetAmount(kk) >= 10 and 10) or v:GetAmount(kk);
                        for i= 1, Amount, 1 do
                            v:Outsource(kk, 1);
                        end
                    end
                end
            end
        end
    end
end

---
-- Wirt ausgeführt, nachdem ein Spielstand geladen wurde. Diese Funktion Stellt
-- alle nicht persistenten Änderungen wieder her.
--
-- @within Private
-- @local
--
function BundleCastleStore.Global.OnSaveGameLoaded()
    API.Bridge("BundleCastleStore.Local:OverwriteGetStringTableText()")
end

---
-- Überschreibt die globalen Spielfunktionen, die mit dem Burglager in
-- Konfilckt stehen.
--
-- @within Private
-- @local
--
function BundleCastleStore.Global:OverwriteGameFunctions()
    QuestTemplate.IsObjectiveCompleted_Orig_QSB_CastleStore = QuestTemplate.IsObjectiveCompleted;
    QuestTemplate.IsObjectiveCompleted = function(self, objective)
        local objectiveType = objective.Type;
        local data = objective.Data;

        if objective.Completed ~= nil then
            return objective.Completed;
        end

        if objectiveType == Objective.Produce then
            local GoodAmount = GetPlayerGoodsInSettlement(data[1], self.ReceivingPlayer, true);
            local CastleStore = QSB.CastleStore:GetInstance(self.ReceivingPlayer);
            if CastleStore and Logic.GetGoodCategoryForGoodType(data[1]) == GoodCategories.GC_Resource then
                GoodAmount = GoodAmount + CastleStore:GetAmount(data[1]);
            end
            if (not data[3] and GoodAmount >= data[2]) or (data[3] and GoodAmount < data[2]) then
                objective.Completed = true;
            end
        else
            return QuestTemplate.IsObjectiveCompleted_Orig_QSB_CastleStore(self, objective);
        end
    end

    QuestTemplate.SendGoods = function(self)
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Deliver then
                if self.Objectives[i].Data[3] == nil then
                    local goodType = self.Objectives[i].Data[1]
                    local goodQuantity = self.Objectives[i].Data[2]

                    local amount = QSB.CastleStore:GetGoodAmountWithCastleStore(goodType, self.ReceivingPlayer, true);
                    if amount >= goodQuantity then
                        local Sender = self.ReceivingPlayer
                        local Target = self.Objectives[i].Data[6] and self.Objectives[i].Data[6] or self.SendingPlayer

                        local expectedMerchant = {}
                        expectedMerchant.Good = goodType
                        expectedMerchant.Amount = goodQuantity
                        expectedMerchant.PlayerID = Target
                        expectedMerchant.ID = nil
                        self.Objectives[i].Data[5] = expectedMerchant
                        self.Objectives[i].Data[3] = 1
                        QuestMerchants[#QuestMerchants+1] = expectedMerchant

                        if goodType == Goods.G_Gold then
                            local BuildingID = Logic.GetHeadquarters(Sender)
                            if BuildingID == 0 then
                                BuildingID = Logic.GetStoreHouse(Sender)
                            end
                            self.Objectives[i].Data[3] = Logic.CreateEntityAtBuilding(Entities.U_GoldCart, BuildingID, 0, Target)
                            Logic.HireMerchant(self.Objectives[i].Data[3], Target, goodType, goodQuantity, self.ReceivingPlayer)
                            Logic.RemoveGoodFromStock(BuildingID,goodType,goodQuantity)
                            if MapCallback_DeliverCartSpawned then
                                MapCallback_DeliverCartSpawned( self, self.Objectives[i].Data[3], goodType )
                            end

                        elseif goodType == Goods.G_Water then
                            local BuildingID = Logic.GetMarketplace(Sender)

                            self.Objectives[i].Data[3] = Logic.CreateEntityAtBuilding(Entities.U_Marketer, BuildingID, 0, Target)
                            Logic.HireMerchant(self.Objectives[i].Data[3], Target, goodType, goodQuantity, self.ReceivingPlayer)
                            Logic.RemoveGoodFromStock(BuildingID,goodType,goodQuantity)
                            if MapCallback_DeliverCartSpawned then
                                MapCallback_DeliverCartSpawned( self, self.Objectives[i].Data[3], goodType )
                            end

                        else
                            if Logic.GetGoodCategoryForGoodType(goodType) == GoodCategories.GC_Resource then
                                local StorehouseID = Logic.GetStoreHouse(Target)
                                local NumberOfGoodTypes = Logic.GetNumberOfGoodTypesOnOutStock(StorehouseID)
                                if NumberOfGoodTypes ~= nil then
                                    for j = 0, NumberOfGoodTypes-1 do
                                        local StoreHouseGoodType = Logic.GetGoodTypeOnOutStockByIndex(StorehouseID,j)
                                        local Amount = Logic.GetAmountOnOutStockByIndex(StorehouseID, j)
                                        if Amount >= goodQuantity then
                                            Logic.RemoveGoodFromStock(StorehouseID, StoreHouseGoodType, goodQuantity, false)
                                        end
                                    end
                                end

                                local SenderStorehouse = Logic.GetStoreHouse(Sender);
                                local AmountInStorehouse = GetPlayerResources(goodType, Sender);
                                if AmountInStorehouse < goodQuantity then
                                    local AmountDifference = goodQuantity - AmountInStorehouse;
                                    AddGood(goodType, AmountInStorehouse * (-1), Sender);
                                    QSB.CastleStore:GetInstance(self.ReceivingPlayer)
                                                   :Remove(goodType, AmountDifference);
                                else
                                    AddGood(goodType, goodQuantity * (-1), Sender);
                                end
                                self.Objectives[i].Data[3] = Logic.CreateEntityAtBuilding(Entities.U_ResourceMerchant, SenderStorehouse, 0, Target);
                                Logic.HireMerchant(self.Objectives[i].Data[3], Target, goodType, goodQuantity, self.ReceivingPlayer);
                            else
                                Logic.StartTradeGoodGathering(Sender, Target, goodType, goodQuantity, 0)
                            end
                        end
                    end
                end
            end
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
function BundleCastleStore.Local:Install()
    QSB.CastleStore = BundleCastleStore.Local.CastleStore;
    self:OverwriteGameFunctions();
    self:OverwriteGetStringTableText();
end

---
-- Erzeugt eine neue lokale Referenz zum Burglager des Spielers.
--
-- <b>Alias</b>: QSB.CastleStore:CreateStore
--
-- @param number _PlayerID      ID des Spielers
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:CreateStore(_PlayerID)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    local Store = {
        StoreMode = 1,
        CapacityBase = 75,
        Goods = {
            [Goods.G_Wood]      = {0, true, false, 35},
            [Goods.G_Stone]     = {0, true, false, 35},
            [Goods.G_Iron]      = {0, true, false, 35},
            [Goods.G_Carcass]   = {0, true, false, 15},
            [Goods.G_Grain]     = {0, true, false, 15},
            [Goods.G_RawFish]   = {0, true, false, 15},
            [Goods.G_Milk]      = {0, true, false, 15},
            [Goods.G_Herb]      = {0, true, false, 15},
            [Goods.G_Wool]      = {0, true, false, 15},
            [Goods.G_Honeycomb] = {0, true, false, 15},
        }
    }
    self.Data[_PlayerID] = Store;
end

---
-- Entfernt eine lokale Referenz auf ein Burglager des Spielers.
--
-- <b>Alias</b>: QSB.CastleStore:DeleteStore
--
-- @param number _PlayerID      ID des Spielers
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:DeleteStore(_PlayerID)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    self.Data[_PlayerID] = nil;
end

---
-- Gibt die Menge an Waren des Typs zurück.
--
-- <b>Alias</b>: QSB.CastleStore:GetAmount
--
-- @param number _PlayerID      ID des Spielers
-- @param number _Good          Warentyp
-- @return number
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:GetAmount(_PlayerID, _Good)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not self:HasCastleStore(_PlayerID) then
        return 0;
    end
    return self.Data[_PlayerID].Goods[_Good][1];
end

---
-- Gibt die Menge an Waren des Spielers zurück, eingeschlossen
-- der Waren im Burglager. Hat der Spieler kein Burglager, wird
-- nur die Menge im Lagerhaus zurückgegeben.
--
-- <b>Alias</b>: QSB.CastleStore:GetGoodAmountWithCastleStore
--
-- @param number _Good          Warentyp
-- @param number _PlayeriD      ID des Spielers
-- @return number
-- @within QSB.CastleStore
--
function BundleCastleStore.Local.CastleStore:GetGoodAmountWithCastleStore(_Good, _PlayerID, _WithoutMarketplace)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    local Amount = GetPlayerGoodsInSettlement(_Good, _PlayerID, _WithoutMarketplace);
    if self:HasCastleStore(_PlayerID) then
        if _Good ~= Goods.G_Gold and Logic.GetGoodCategoryForGoodType(_Good) == GoodCategories.GC_Resource then
            Amount = Amount + self:GetAmount(_PlayerID, _Good);
        end
    end
    return Amount;
end

---
-- Gibt die Gesamtmenge aller Waren im Burglager zurück.
--
-- <b>Alias</b>: QSB.CastleStore:GetTotalAmount
--
-- @param number _PlayerID      ID des Spielers
-- @param number _Good          Warentyp
-- @return number
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:GetTotalAmount(_PlayerID)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not self:HasCastleStore(_PlayerID) then
        return 0;
    end
    local TotalAmount = 0;
    for k, v in pairs(self.Data[_PlayerID].Goods) do
        TotalAmount = TotalAmount + v[1];
    end
    return TotalAmount;
end

---
-- Ändert die Menge an Waren des Typs.
--
-- <b>Alias</b>: QSB.CastleStore:SetAmount
--
-- @param number _PlayerID      ID des Spielers
-- @param number _Good          Warentyp
-- @param number _Amount        Warenmenge
-- @return self
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:SetAmount(_PlayerID, _Good, _Amount)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not self:HasCastleStore(_PlayerID) then
        return;
    end
    self.Data[_PlayerID].Goods[_Good][1] = _Amount;
    return self;
end

---
-- Gibt zurück, ob die Ware des Typs akzeptiert wird.
--
-- <b>Alias</b>: QSB.CastleStore:IsAccepted
--
-- @param number _PlayerID      ID des Spielers
-- @param number _Good          Warentyp
-- @return boolean
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:IsAccepted(_PlayerID, _Good)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not self:HasCastleStore(_PlayerID) then
        return false;
    end
    if not self.Data[_PlayerID].Goods[_Good] then
        return false;
    end
    return self.Data[_PlayerID].Goods[_Good][2] == true;
end

---
-- Setzt eine Ware als akzeptiert.
--
-- <b>Alias</b>: QSB.CastleStore:SetAccepted
--
-- @param number _PlayerID      ID des Spielers
-- @param number _Good          Warentyp
-- @param boolean _Good         Akzeptanz-Flag
-- @return self
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:SetAccepted(_PlayerID, _Good, _Flag)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if self:HasCastleStore(_PlayerID) then
        if self.Data[_PlayerID].Goods[_Good] then
            self.Data[_PlayerID].Goods[_Good][2] = _Flag == true;
        end
    end
    return self;
end

---
-- Gibt zurück, ob die Ware des Typs gesperrt ist.
--
-- <b>Alias</b>: QSB.CastleStore:IsLocked
--
-- @param number _PlayerID      ID des Spielers
-- @param number _Good          Warentyp
-- @return boolean
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:IsLocked(_PlayerID, _Good)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not self:HasCastleStore(_PlayerID) then
        return false;
    end
    if not self.Data[_PlayerID].Goods[_Good] then
        return false;
    end
    return self.Data[_PlayerID].Goods[_Good][3] == true;
end

---
-- Setzt eine Ware als gesperrt.
--
-- <b>Alias</b>: QSB.CastleStore:SetLocked
--
-- @param number _PlayerID      ID des Spielers
-- @param number _Good          Warentyp
-- @param boolean _Good         Akzeptanz-Flag
-- @return self
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:SetLocked(_PlayerID, _Good, _Flag)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if self:HasCastleStore(_PlayerID) then
        if self.Data[_PlayerID].Goods[_Good] then
            self.Data[_PlayerID].Goods[_Good][3] = _Flag == true;
        end
    end
    return self;
end

---
-- Gibt zurück, ob der Spieler ein Burglager hat.
--
-- <b>Alias</b>: QSB.CastleStore:HasCastleStore
--
-- @param number _PlayerID      ID des Spielers
-- @return boolean
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:HasCastleStore(_PlayerID)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    return self.Data[_PlayerID] ~= nil;
end

---
-- Gibt die Referenz des Burglagers des Spielers zurück.
--
-- <b>Alias</b>: QSB.CastleStore:GetStore
--
-- @param number _PlayerID      ID des Spielers
-- @return table
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:GetStore(_PlayerID)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    return self.Data[_PlayerID];
end

---
-- Gibt das aktuelle Lagerlimit des Burglagers zurück.
--
-- <b>Alias</b>: QSB.CastleStore:GetLimit
--
-- @param number _PlayerID      ID des Spielers
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:GetLimit(_PlayerID)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    local Level = 0;
    local Headquarters = Logic.GetHeadquarters(_PlayerID);
    if Headquarters ~= 0 then
        Level = Logic.GetUpgradeLevel(Headquarters);
    end

    local Capacity = self.Data[_PlayerID].CapacityBase;
    for i= 1, (Level+1), 1 do
        Capacity = Capacity * 2;
    end
    return Capacity;
end

---
-- "Waren einlagern" wurde geklickt.
--
-- <b>Alias</b>: QSB.CastleStore:OnStorehouseTabClicked
--
-- @param number _PlayerID      ID des Spielers
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:OnStorehouseTabClicked(_PlayerID)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    self.Data[_PlayerID].StoreMode = 1;
    self:UpdateBehaviorTabs(_PlayerID);
    GUI.SendScriptCommand([[
        local Store = QSB.CastleStore:GetInstance(]] .._PlayerID.. [[);
        for k, v in pairs(Store.Data.Goods) do
            Store:SetGoodAccepted(k, true);
            Store:SetGoodLocked(k, false);
        end
    ]]);
end

---
-- "Waren bunkern" wurde gedrückt.
--
-- <b>Alias</b>: QSB.CastleStore:OnCityTabClicked
--
-- @param number _PlayerID      ID des Spielers
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:OnCityTabClicked(_PlayerID)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    self.Data[_PlayerID].StoreMode = 2;
    self:UpdateBehaviorTabs(_PlayerID);
    GUI.SendScriptCommand([[
        local Store = QSB.CastleStore:GetInstance(]] .._PlayerID.. [[);
        for k, v in pairs(Store.Data.Goods) do
            Store:SetGoodAccepted(k, true);
            Store:SetGoodLocked(k, true);
        end
    ]]);
end

---
-- "Lager räumen" wurde gedrückt.
--
-- <b>Alias</b>: QSB.CastleStore:OnMultiTabClicked
--
-- @param number _PlayerID      ID des Spielers
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:OnMultiTabClicked(_PlayerID)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    self.Data[_PlayerID].StoreMode = 3;
    self:UpdateBehaviorTabs(_PlayerID);
    GUI.SendScriptCommand([[
        local Store = QSB.CastleStore:GetInstance(]] .._PlayerID.. [[);
        for k, v in pairs(Store.Data.Goods) do
            Store:SetGoodAccepted(k, false);
        end
    ]]);
end

---
-- Ein GoodType-Button wurde geklickt.
--
-- <b>Alias</b>: QSB.CastleStore:GoodClicked
--
-- @param number _PlayerID      ID des Spielers
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:GoodClicked(_PlayerID, _GoodType)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if self:HasCastleStore(_PlayerID) then
        local CurrentWirgetID = XGUIEng.GetCurrentWidgetID();
        GUI.SendScriptCommand([[
            local Store = QSB.CastleStore:GetInstance(]] .._PlayerID.. [[);
            local Accepted = not Store:IsGoodAccepted(]] .._GoodType.. [[)
            Store:SetGoodAccepted(]] .._GoodType.. [[, Accepted);
        ]]);
    end
end

---
-- Der Spieler wechselt zwischen den Ansichten in der Burg.
--
-- <b>Alias</b>: QSB.CastleStore:DestroyGoodsClicked
--
-- @param number _PlayerID      ID des Spielers
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:DestroyGoodsClicked(_PlayerID)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if self:HasCastleStore(_PlayerID) then
        QSB.CastleStore.ToggleStore();
    end
end

---
-- Aktualisiert das Burgmenü, sobald sich die Selektion ändert.
--
-- <b>Alias</b>: QSB.CastleStore:SelectionChanged
--
-- @param number _PlayerID      ID des Spielers
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:SelectionChanged(_PlayerID)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if self:HasCastleStore(_PlayerID) then
        local SelectedID = GUI.GetSelectedEntity();
        if Logic.GetHeadquarters(_PlayerID) == SelectedID then
            self:ShowCastleMenu();
        else
            self:RestoreStorehouseMenu();
        end
    end
end

---
-- Aktualisiert die Burglager-Tabs.
--
-- <b>Alias</b>: QSB.CastleStore:UpdateBehaviorTabs
--
-- @param number _PlayerID      ID des Spielers
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:UpdateBehaviorTabs(_PlayerID)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not QSB.CastleStore:HasCastleStore(GUI.GetPlayerID()) then
        return;
    end
    XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons", 0);
    if self.Data[_PlayerID].StoreMode == 1 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/StorehouseTabButtonUp", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/CityTabButtonDown", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/Tab03Down", 1);
    elseif self.Data[_PlayerID].StoreMode == 2 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/StorehouseTabButtonDown", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/CityTabButtonUp", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/Tab03Down", 1);
    else
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/StorehouseTabButtonDown", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/CityTabButtonDown", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/Tab03Up", 1);
    end
end

---
-- Aktualisiert die Mengenanzeige der Waren im Burglager.
--
-- <b>Alias</b>: QSB.CastleStore:UpdateGoodsDisplay
--
-- @param number _PlayerID      ID des Spielers
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:UpdateGoodsDisplay(_PlayerID, _CurrentWidget)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not self:HasCastleStore(_PlayerID) then
        return;
    end

    local MotherContainer  = "/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/InStorehouse/Goods";
    local WarningColor = "";
    if self:GetLimit(_PlayerID) == self:GetTotalAmount(_PlayerID) then
        WarningColor = "{@color:255,32,32,255}";
    end
    for k, v in pairs(self.Data[_PlayerID].Goods) do
        local GoodTypeName = Logic.GetGoodTypeName(k);
        local AmountWidget = MotherContainer.. "/" ..GoodTypeName.. "/Amount";
        local ButtonWidget = MotherContainer.. "/" ..GoodTypeName.. "/Button";
        local BGWidget = MotherContainer.. "/" ..GoodTypeName.. "/BG";
        XGUIEng.SetText(AmountWidget, "{center}" .. WarningColor .. v[1]);
        XGUIEng.DisableButton(ButtonWidget, 0)

        if self:IsAccepted(_PlayerID, k) then
            XGUIEng.SetMaterialColor(ButtonWidget, 0, 255, 255, 255, 255);
            XGUIEng.SetMaterialColor(ButtonWidget, 1, 255, 255, 255, 255);
            XGUIEng.SetMaterialColor(ButtonWidget, 7, 255, 255, 255, 255);
            --XGUIEng.SetMaterialColor(BGWidget, 0, 255, 255, 255, 255);
        else
            XGUIEng.SetMaterialColor(ButtonWidget, 0, 190, 90, 90, 255);
            XGUIEng.SetMaterialColor(ButtonWidget, 1, 190, 90, 90, 255);
            XGUIEng.SetMaterialColor(ButtonWidget, 7, 190, 90, 90, 255);
            --XGUIEng.SetMaterialColor(BGWidget, 0, 90, 90, 90, 255);
        end
    end
end

---
-- Aktualisiert die Lagerauslastungsanzeige des Burglagers.
--
-- <b>Alias</b>: QSB.CastleStore:UpdateStorageLimit
--
-- @param number _PlayerID      ID des Spielers
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:UpdateStorageLimit(_PlayerID)
    assert(self == BundleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not self:HasCastleStore(_PlayerID) then
        return;
    end
    local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
    local PlayerID = GUI.GetPlayerID();
    local StorageUsed = QSB.CastleStore:GetTotalAmount(PlayerID);
    local StorageLimit = QSB.CastleStore:GetLimit(PlayerID);
    local StorageLimitText = XGUIEng.GetStringTableText("UI_Texts/StorageLimit_colon");
    local Text = "{center}" ..StorageLimitText.. " " ..StorageUsed.. "/" ..StorageLimit;
    XGUIEng.SetText(CurrentWidgetID, Text);
end

---
-- Wechselt zwischen der Finanzansicht und dem Burglager.
--
-- <b>Alias</b>: QSB.CastleStore:ToggleStore
--
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:ToggleStore()
    assert(self == nil, "This function is procedural!");
    if QSB.CastleStore:HasCastleStore(GUI.GetPlayerID()) then
        if Logic.GetHeadquarters(GUI.GetPlayerID()) == GUI.GetSelectedEntity() then
            if XGUIEng.IsWidgetShown("/InGame/Root/Normal/AlignBottomRight/Selection/Castle") == 1 then
                QSB.CastleStore.ShowCastleStoreMenu(QSB.CastleStore);
            else
                QSB.CastleStore.ShowCastleMenu(QSB.CastleStore);
            end
        end
    end
end

---
-- Stellt das normale Lagerhausmenü wieder her.
--
-- <b>Alias</b>: QSB.CastleStore:RestoreStorehouseMenu
--
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:RestoreStorehouseMenu()
    XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons", 1);
    XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/InCity/Goods", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/InCity", 0);
    SetIcon("/InGame/Root/Normal/AlignBottomRight/DialogButtons/PlayerButtons/DestroyGoods", {16, 8});

    local MotherPath = "/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/";
    SetIcon(MotherPath.. "StorehouseTabButtonUp/up/B_StoreHouse", {3, 13});
    SetIcon(MotherPath.. "StorehouseTabButtonDown/down/B_StoreHouse", {3, 13});
    SetIcon(MotherPath.. "CityTabButtonUp/up/CityBuildingsNumber", {8, 1});
    SetIcon(MotherPath.. "TabButtons/CityTabButtonDown/down/CityBuildingsNumber", {8, 1});
    SetIcon(MotherPath.. "TabButtons/Tab03Up/up/B_Castle_ME", {3, 14});
    SetIcon(MotherPath.. "Tab03Down/down/B_Castle_ME", {3, 14});

    for k, v in ipairs {"G_Carcass", "G_Grain", "G_Milk", "G_RawFish", "G_Iron","G_Wood", "G_Stone", "G_Honeycomb", "G_Herb", "G_Wool"} do
        local MotherPath = "/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/InStorehouse/Goods/";
        XGUIEng.SetMaterialColor(MotherPath.. v.. "/Button", 0, 255, 255, 255, 255);
        XGUIEng.SetMaterialColor(MotherPath.. v.. "/Button", 1, 255, 255, 255, 255);
        XGUIEng.SetMaterialColor(MotherPath.. v.. "/Button", 7, 255, 255, 255, 255);
    end
end

---
-- Das normale Burgmenü wird angezeigt.
--
-- <b>Alias</b>: QSB.CastleStore:ShowCastleMenu
--
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:ShowCastleMenu()
    local MotherPath = "/InGame/Root/Normal/AlignBottomRight/";
    XGUIEng.ShowWidget(MotherPath.. "Selection/BGBig", 0)
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse", 0)
    XGUIEng.ShowWidget(MotherPath.. "Selection/BGSmall", 1)
    XGUIEng.ShowWidget(MotherPath.. "Selection/Castle", 1)

    if g_HideSoldierPayment ~= nil then
        XGUIEng.ShowWidget(MotherPath.. "Selection/Castle/Treasury/Payment", 0)
        XGUIEng.ShowWidget(MotherPath.. "Selection/Castle/LimitSoldiers", 0)
    end
    GUI_BuildingInfo.PaymentLevelSliderUpdate()
    GUI_BuildingInfo.TaxationLevelSliderUpdate()
    GUI_Trade.StorehouseSelected()
    local AnchorInfoForSmallX, AnchorInfoForSmallY = XGUIEng.GetWidgetLocalPosition(MotherPath.. "Selection/AnchorInfoForSmall")
    XGUIEng.SetWidgetLocalPosition(MotherPath.. "Selection/Info", AnchorInfoForSmallX, AnchorInfoForSmallY)

    XGUIEng.ShowWidget(MotherPath.. "DialogButtons/PlayerButtons", 1)
    XGUIEng.ShowWidget(MotherPath.. "DialogButtons/PlayerButtons/DestroyGoods", 1)
    XGUIEng.DisableButton(MotherPath.. "DialogButtons/PlayerButtons/DestroyGoods", 0)
    SetIcon(MotherPath.. "DialogButtons/PlayerButtons/DestroyGoods", {10, 9})
end

---
-- Das Burglager wird angezeigt.
--
-- <b>Alias</b>: QSB.CastleStore:ShowCastleStoreMenu
--
-- @within Private
-- @local
--
function BundleCastleStore.Local.CastleStore:ShowCastleStoreMenu()
    local MotherPath = "/InGame/Root/Normal/AlignBottomRight/";
    XGUIEng.ShowWidget(MotherPath.. "Selection/Selection/BGSmall", 0);
    XGUIEng.ShowWidget(MotherPath.. "Selection/Castle", 0);
    XGUIEng.ShowWidget(MotherPath.. "Selection/BGSmall", 0);
    XGUIEng.ShowWidget(MotherPath.. "Selection/BGBig", 1);
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse", 1);
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse/AmountContainer", 0);
    XGUIEng.ShowAllSubWidgets(MotherPath.. "Selection/Storehouse/TabButtons", 1);

    GUI_Trade.StorehouseSelected()
    local AnchorInfoForBigX, AnchorInfoForBigY = XGUIEng.GetWidgetLocalPosition(MotherPath.. "Selection/AnchorInfoForBig")
    XGUIEng.SetWidgetLocalPosition(MotherPath.. "Selection/Info", AnchorInfoForBigX, AnchorInfoForBigY)

    XGUIEng.ShowWidget(MotherPath.. "DialogButtons/PlayerButtons", 1)
    XGUIEng.ShowWidget(MotherPath.. "DialogButtons/PlayerButtons/DestroyGoods", 1)
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse/InStorehouse", 1)
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse/InMulti", 0)
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse/InCity", 1)
    XGUIEng.ShowAllSubWidgets(MotherPath.. "Selection/Storehouse/InCity/Goods", 0);
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse/InCity/Goods/G_Beer", 1)
    XGUIEng.DisableButton(MotherPath.. "DialogButtons/PlayerButtons/DestroyGoods", 0)

    local MotherPathDialog = MotherPath.. "DialogButtons/PlayerButtons/";
    local MotherPathTabs = MotherPath.. "Selection/Storehouse/TabButtons/";
    SetIcon(MotherPathDialog.. "DestroyGoods", {3, 14});
    SetIcon(MotherPathTabs.. "StorehouseTabButtonUp/up/B_StoreHouse", {10, 9});
    SetIcon(MotherPathTabs.. "StorehouseTabButtonDown/down/B_StoreHouse", {10, 9});
    SetIcon(MotherPathTabs.. "CityTabButtonUp/up/CityBuildingsNumber", {15, 6});
    SetIcon(MotherPathTabs.. "CityTabButtonDown/down/CityBuildingsNumber", {15, 6});
    SetIcon(MotherPathTabs.. "Tab03Up/up/B_Castle_ME", {7, 1});
    SetIcon(MotherPathTabs.. "Tab03Down/down/B_Castle_ME", {7, 1});

    self:UpdateBehaviorTabs(GUI.GetPlayerID());
end

---
-- Überschreibt die Textausgabe mit den eigenen Texten.
--
-- @within Private
-- @local
--
function BundleCastleStore.Local:OverwriteGetStringTableText()
    GetStringTableText_Orig_QSB_CatsleStore = XGUIEng.GetStringTableText;
    XGUIEng.GetStringTableText = function(_key)
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID = GUI.GetPlayerID();
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();

        if _key == "UI_ObjectNames/DestroyGoods" then
            if XGUIEng.IsWidgetShown("/InGame/Root/Normal/AlignBottomRight/Selection/Castle") == 1 then
                return BundleCastleStore.Local.Description.ShowCastleStore.Text[lang];
            else
                return BundleCastleStore.Local.Description.ShowCastle.Text[lang];
            end
        end
        if _key == "UI_ObjectDescription/DestroyGoods" then
            return "";
        end

        if _key == "UI_ObjectNames/CityBuildingsNumber" then
            if Logic.GetHeadquarters(PlayerID) == SelectedID then
                return BundleCastleStore.Local.Description.CityTab.Title[lang];
            end
        end
        if _key == "UI_ObjectDescription/CityBuildingsNumber" then
            if Logic.GetHeadquarters(PlayerID) == SelectedID then
                return BundleCastleStore.Local.Description.CityTab.Text[lang];
            end
        end

        if _key == "UI_ObjectNames/B_StoreHouse" then
            if Logic.GetHeadquarters(PlayerID) == SelectedID then
                return BundleCastleStore.Local.Description.StorehouseTab.Title[lang];
            end
        end
        if _key == "UI_ObjectDescription/B_StoreHouse" then
            if Logic.GetHeadquarters(PlayerID) == SelectedID then
                return BundleCastleStore.Local.Description.StorehouseTab.Text[lang];
            end
        end

        if _key == "UI_ObjectNames/B_Castle_ME" then
            local WidgetMotherName = "/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/";
            local WidgetDownButton = WidgetMotherName.. "Tab03Down/down/B_Castle_ME";
            local WidgetUpButton = WidgetMotherName.. "Tab03Up/up/B_Castle_ME";
            if XGUIEng.GetWidgetPathByID(CurrentWidgetID) == WidgetDownButton or XGUIEng.GetWidgetPathByID(CurrentWidgetID) == WidgetUpButton then
                if Logic.GetHeadquarters(PlayerID) == SelectedID then
                    return BundleCastleStore.Local.Description.MultiTab.Title[lang];
                end
            end
        end
        if _key == "UI_ObjectDescription/B_Castle_ME" then
            if Logic.GetHeadquarters(PlayerID) == SelectedID then
                return BundleCastleStore.Local.Description.MultiTab.Text[lang];
            end
        end

        if _key == "UI_ButtonDisabled/NotEnoughGoods" then
            if Logic.GetHeadquarters(PlayerID) == SelectedID then
                return BundleCastleStore.Local.Description.GoodButtonDisabled.Text[lang];
            end
        end

        return GetStringTableText_Orig_QSB_CatsleStore(_key);
    end
end

---
-- Überschreibt die lokalen Spielfunktionen, die benötigt werden, damit das
-- Burglager funktioniert.
--
-- @within Private
-- @local
--
function BundleCastleStore.Local:OverwriteGameFunctions()
    GameCallback_GUI_SelectionChanged_Orig_QSB_CastleStore = GameCallback_GUI_SelectionChanged;
    GameCallback_GUI_SelectionChanged = function(_Source)
        GameCallback_GUI_SelectionChanged_Orig_QSB_CastleStore(_Source);
        QSB.CastleStore:SelectionChanged(GUI.GetPlayerID());
    end

    GUI_Trade.GoodClicked_Orig_QSB_CastleStore = GUI_Trade.GoodClicked;
    GUI_Trade.GoodClicked = function()
        local GoodType = Goods[XGUIEng.GetWidgetNameByID(XGUIEng.GetWidgetsMotherID(XGUIEng.GetCurrentWidgetID()))];
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();

        if Logic.IsEntityInCategory(SelectedID, EntityCategories.Storehouse) == 1 then
            GUI_Trade.GoodClicked_Orig_QSB_CastleStore();
            return;
        end
        QSB.CastleStore:GoodClicked(PlayerID, GoodType);
    end

    GUI_Trade.DestroyGoodsClicked_Orig_QSB_CastleStore = GUI_Trade.DestroyGoodsClicked;
    GUI_Trade.DestroyGoodsClicked = function()
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();

        if Logic.IsEntityInCategory(SelectedID, EntityCategories.Storehouse) == 1 then
            GUI_Trade.DestroyGoodsClicked_Orig_QSB_CastleStore();
            return;
        end
        QSB.CastleStore:DestroyGoodsClicked(PlayerID);
    end

    GUI_Trade.SellUpdate_Orig_QSB_CastleStore = GUI_Trade.SellUpdate;
    GUI_Trade.SellUpdate = function()
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();

        if Logic.IsEntityInCategory(SelectedID, EntityCategories.Storehouse) == 1 then
            GUI_Trade.SellUpdate_Orig_QSB_CastleStore();
            return;
        end
        QSB.CastleStore:UpdateGoodsDisplay(PlayerID);
    end

    GUI_Trade.CityTabButtonClicked_Orig_QSB_CastleStore = GUI_Trade.CityTabButtonClicked;
    GUI_Trade.CityTabButtonClicked = function()
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();

        if Logic.IsEntityInCategory(SelectedID, EntityCategories.Storehouse) == 1 then
            GUI_Trade.CityTabButtonClicked_Orig_QSB_CastleStore();
            return;
        end
        QSB.CastleStore:OnCityTabClicked(PlayerID);
    end

    GUI_Trade.StorehouseTabButtonClicked_Orig_QSB_CastleStore = GUI_Trade.StorehouseTabButtonClicked;
    GUI_Trade.StorehouseTabButtonClicked = function()
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();

        if Logic.IsEntityInCategory(SelectedID, EntityCategories.Storehouse) == 1 then
            GUI_Trade.StorehouseTabButtonClicked_Orig_QSB_CastleStore();
            return;
        end
        QSB.CastleStore:OnStorehouseTabClicked(PlayerID);
    end

    GUI_Trade.MultiTabButtonClicked_Orig_QSB_CastleStore = GUI_Trade.MultiTabButtonClicked;
    GUI_Trade.MultiTabButtonClicked = function()
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();

        if Logic.IsEntityInCategory(SelectedID, EntityCategories.Storehouse) == 1 then
            GUI_Trade.MultiTabButtonClicked_Orig_QSB_CastleStore();
            return;
        end
        QSB.CastleStore:OnMultiTabClicked(PlayerID);
    end

    GUI_BuildingInfo.StorageLimitUpdate_Orig_QSB_CastleStore = GUI_BuildingInfo.StorageLimitUpdate;
    GUI_BuildingInfo.StorageLimitUpdate = function()
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();

        if Logic.IsEntityInCategory(SelectedID, EntityCategories.Storehouse) == 1 then
            GUI_BuildingInfo.StorageLimitUpdate_Orig_QSB_CastleStore();
            return;
        end
        QSB.CastleStore:UpdateStorageLimit(PlayerID);
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GUI_Interaction.SendGoodsClicked = function()
        local Quest, QuestType = GUI_Interaction.GetPotentialSubQuestAndType(g_Interaction.CurrentMessageQuestIndex);
        if not Quest then
            return;
        end
        local QuestIndex = GUI_Interaction.GetPotentialSubQuestIndex(g_Interaction.CurrentMessageQuestIndex);
        local GoodType = Quest.Objectives[1].Data[1];
        local GoodAmount = Quest.Objectives[1].Data[2];
        local Costs = {GoodType, GoodAmount};
        local CanBuyBoolean, CanNotBuyString = AreCostsAffordable(Costs, true);

        local PlayerID = GUI.GetPlayerID();
        if Logic.GetGoodCategoryForGoodType(GoodType) == GoodCategories.GC_Resource then
            CanNotBuyString = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources");
            CanBuyBoolean = false;
            if QSB.CastleStore:IsLocked(PlayerID, GoodType) then
                CanBuyBoolean = GetPlayerResources(GoodType, PlayerID) >= GoodAmount;
            else
                CanBuyBoolean = (GetPlayerResources(GoodType, PlayerID) + QSB.CastleStore:GetAmount(PlayerID, GoodType)) >= GoodAmount;
            end
        end

        local TargetPlayerID = Quest.Objectives[1].Data[6] and Quest.Objectives[1].Data[6] or Quest.SendingPlayer;
        local PlayerSectorType = PlayerSectorTypes.Thief;
        local IsReachable = CanEntityReachTarget(TargetPlayerID, Logic.GetStoreHouse(GUI.GetPlayerID()), Logic.GetStoreHouse(TargetPlayerID), nil, PlayerSectorType);
        if IsReachable == false then
            local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_GenericUnreachable");
            Message(MessageText);
            return
        end

        if CanBuyBoolean == true then
            Sound.FXPlay2DSound( "ui\\menu_click");
            GUI.QuestTemplate_SendGoods(QuestIndex);
            GUI_FeedbackSpeech.Add("SpeechOnly_CartsSent", g_FeedbackSpeech.Categories.CartsUnderway, nil, nil);
        else
            Message(CanNotBuyString);
        end
    end

    GUI_Tooltip.SetCosts = function(_TooltipCostsContainer, _Costs, _GoodsInSettlementBoolean)
        local TooltipCostsContainerPath = XGUIEng.GetWidgetPathByID(_TooltipCostsContainer);
        local Good1ContainerPath = TooltipCostsContainerPath .. "/1Good";
        local Goods2ContainerPath = TooltipCostsContainerPath .. "/2Goods";
        local NumberOfValidAmounts = 0;
        local Good1Path;
        local Good2Path;

        for i = 2, #_Costs, 2 do
            if _Costs[i] ~= 0 then
                NumberOfValidAmounts = NumberOfValidAmounts + 1;
            end
        end
        if NumberOfValidAmounts == 0 then
            XGUIEng.ShowWidget(Good1ContainerPath, 0);
            XGUIEng.ShowWidget(Goods2ContainerPath, 0);
            return
        elseif NumberOfValidAmounts == 1 then
            XGUIEng.ShowWidget(Good1ContainerPath, 1);
            XGUIEng.ShowWidget(Goods2ContainerPath, 0);
            Good1Path = Good1ContainerPath .. "/Good1Of1";
        elseif NumberOfValidAmounts == 2 then
            XGUIEng.ShowWidget(Good1ContainerPath, 0);
            XGUIEng.ShowWidget(Goods2ContainerPath, 1);
            Good1Path = Goods2ContainerPath .. "/Good1Of2";
            Good2Path = Goods2ContainerPath .. "/Good2Of2";
        elseif NumberOfValidAmounts > 2 then
            GUI.AddNote("Debug: Invalid Costs table. Not more than 2 GoodTypes allowed.");
        end

        local ContainerIndex = 1;
        for i = 1, #_Costs, 2 do
            if _Costs[i + 1] ~= 0 then
                local CostsGoodType = _Costs[i];
                local CostsGoodAmount = _Costs[i + 1];
                local IconWidget;
                local AmountWidget;
                if ContainerIndex == 1 then
                    IconWidget = Good1Path .. "/Icon";
                    AmountWidget = Good1Path .. "/Amount";
                else
                    IconWidget = Good2Path .. "/Icon";
                    AmountWidget = Good2Path .. "/Amount";
                end
                SetIcon(IconWidget, g_TexturePositions.Goods[CostsGoodType], 44);
                local PlayerID = GUI.GetPlayerID();
                local PlayersGoodAmount;
                if _GoodsInSettlementBoolean == true then
                    PlayersGoodAmount = GetPlayerGoodsInSettlement(CostsGoodType, PlayerID, true);
                    if Logic.GetGoodCategoryForGoodType(CostsGoodType) == GoodCategories.GC_Resource then
                        if not QSB.CastleStore:IsLocked(PlayerID, CostsGoodType) then
                            PlayersGoodAmount = PlayersGoodAmount + QSB.CastleStore:GetAmount(PlayerID, CostsGoodType);
                        end
                    end
                else
                    local IsInOutStock;
                    local BuildingID;
                    if CostsGoodType == Goods.G_Gold then
                        BuildingID = Logic.GetHeadquarters(PlayerID);
                        IsInOutStock = Logic.GetIndexOnOutStockByGoodType(BuildingID, CostsGoodType);
                    else
                        BuildingID = Logic.GetStoreHouse(PlayerID);
                        IsInOutStock = Logic.GetIndexOnOutStockByGoodType(BuildingID, CostsGoodType);
                    end
                    if IsInOutStock ~= -1 then
                        PlayersGoodAmount = Logic.GetAmountOnOutStockByGoodType(BuildingID, CostsGoodType);
                    else
                        BuildingID = GUI.GetSelectedEntity();
                        if BuildingID ~= nil then
                            if Logic.GetIndexOnOutStockByGoodType(BuildingID, CostsGoodType) == nil then
                                BuildingID = Logic.GetRefillerID(GUI.GetSelectedEntity());
                            end
                            PlayersGoodAmount = Logic.GetAmountOnOutStockByGoodType(BuildingID, CostsGoodType);
                        else
                            PlayersGoodAmount = 0;
                        end
                    end
                end
                local Color = "";
                if PlayersGoodAmount < CostsGoodAmount then
                    Color = "{@script:ColorRed}";
                end
                if CostsGoodAmount > 0 then
                    XGUIEng.SetText(AmountWidget, "{center}" .. Color .. CostsGoodAmount);
                else
                    XGUIEng.SetText(AmountWidget, "");
                end
                ContainerIndex = ContainerIndex + 1;
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleCastleStore");

