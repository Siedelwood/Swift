-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnInteractiveObjectTemplates                              # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle bietet fertige Schablonen für interaktive Objekte. Mit diesen
-- Schablonen können interaktive Objekte einfach erstellt und gehandhabt werden.
--
-- <p>
-- <b>Interaktive Baustellen:</b><br>
-- Ermöglicht es den Spieler auf einem beliebigen Territorium einer Partei
-- ein Gebäude bauen zu lassen.
-- <br>Die Baustelle muss durch den Helden aktiviert
-- werden. Ein Siedler wird aus dem Lagerhaus kommen und das Gebäude bauen.
-- </p>
-- <p>
-- <b>Interaktive Schatztruhen:</b><br>
-- Es werden Schatztruhen mit zufälligen Inhalt erzeugt. Diese Truhen werden
-- aktiviert und der Inhalt wird in einem Karren abtranzportiert.
-- </p>
-- <p>
-- <b>Interaktive Minen:</b><br>
-- Der Spieler kann eine Steinmine oder Eisenmine erzeugen, die zuerst durch
-- Begleichen der Kosten aufgebaut werden muss, bevor sie genutzt werden kann.
-- <br>Optional kann diese Mine auch nach dem Erschöpfen einstürzen.
-- </p>
-- <p>
-- <b>Trebuchet-Baustellen:</b><br>
-- Der Spieler kann Trebuchets mieten. Das Trebuchet fährt als Karren vor,
-- wird ausgebaut und kann anschließend benutzt werden.<br> Das Trebuchet fährt
-- ab, wenn die Munition alle ist oder der Spieler das Trebuchet abbaut.<br>
-- Sobald ein Trebuchet zerstört wird oder sein Karren wieder am Lagerhaus
-- ankommt, wird die Baustelle wieder freigegeben.
-- </p>
--
-- @module AddOnInteractiveObjectTemplates
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erstelle eine Mine eines bestimmten Typs. Es können zudem eine Bedingung
-- und zwei verschiedene Callbacks vereinbart werden.
--
-- <b>Alias</b>: CreateIOMine
--
-- @param _Position         Script Entity, die mit Mine ersetzt wird
-- @param _Type             Typ der Mine
-- @param _Costs            (optional) Kostentabelle
-- @param _NotRefillable    (optional) Die Mine wird weiterhin überwacht
-- @param _Condition        (optional) Bedingungsfunktion
-- @param _CreationCallback (optional) Funktion nach Kauf ausführen
-- @param _CallbackDepleted (optional) Funktion nach Ausbeutung ausführen
-- @within Public
--
function API.CreateIOMine(_Position, _Type, _Costs, _NotRefillable, _Condition, _CreationCallback, _CallbackDepleted)
    if GUI then
        API.Dbg("API.CreateIOMine: Can not be used from local script!");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateIOMine(_Position, _Type, _Costs, _NotRefillable, _Condition, _CreationCallback, _CallbackDepleted);
end
CreateIOMine = API.CreateIOMine;

---
-- Erstelle eine Eisenmine.
--
-- <b>Alias</b>: CreateIOIronMine
--
-- @param _Position      Script Entity, die mit Mine ersetzt wird
-- @param _Cost1Type     (optional) Kostenware 1
-- @param _Cost1Amount   (optional) Kostenmenge 1
-- @param _Cost2Type     (optional) Kostenware 2
-- @param _Cost2Amount   (optional) Kostenmenge 2
-- @param _NotRefillable (optional) Mine wird nach Ausbeutung zerstört
-- @within Public
--
function API.CreateIOIronMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable)
    if GUI then
        API.Dbg("API.CreateIOIronMine: Can not be used from local script!");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateIOIronMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable);
end
CreateIOIronMine = API.CreateIOIronMine;

---
-- Erstelle eine Steinmine.
--
-- <b>Alias</b>: CreateIOStoneMine
--
-- @param _Position      Script Entity, die mit Mine ersetzt wird
-- @param _Cost1Type     (optional) Kostenware 1
-- @param _Cost1Amount   (optional) Kostenmenge 1
-- @param _Cost2Type     (optional) Kostenware 2
-- @param _Cost2Amount   (optional) Kostenmenge 2
-- @param _NotRefillable (optional) Mine wird nach Ausbeutung zerstört
-- @within Public
--
function API.CreateIOStoneMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable)
    if GUI then
        API.Dbg("API.CreateIOStoneMine: Can not be used from local script!");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateIOStoneMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable);
end
CreateIOStoneMine = API.CreateIOStoneMine;

---
-- Erzeugt eine Baustelle an der Position.
--
-- <b>Alias</b>: CreateIOBuildingSite
--
-- @param _Position Zielpunkt
-- @param _PlayerID Besitzer des Gebäudes
-- @param _Type     Typ des Gebäudes
-- @param _Costs    (optional) Eigene Gebäudekosten
-- @param _Distance (optional) Aktivierungsentfernung
-- @param _Icon     (optional) Icon des Schalters
-- @param _Title    (optional) Titel der Beschreibung
-- @param _Text     (optional) Text der Beschreibung
-- @param _Callback (optional) Funktion nach fertigstellung
-- @within Public
--
function API.CreateIOBuildingSite(_Position, _PlayerID, _Type, _Costs, _Distance, _Icon, _Title, _Text, _Callback)
    if GUI then
        API.Dbg("API.CreateIOBuildingSite: Can not be used from local script!");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateIOBuildingSite(_Position, _PlayerID, _Type, _Costs, _Distance, _Icon, _Title, _Text, _Callback);
end
CreateIOBuildingSite = API.CreateIOBuildingSite;

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge an Waren
-- des angegebenen Typs.
--
-- <b>Alias</b>: CreateRandomChest
--
-- @param _Name     Name der zu ersetzenden Script Entity
-- @param _Good     Warentyp
-- @param _Min      Mindestmenge
-- @param _Max      Maximalmenge
-- @param _Callback Callback-Funktion
-- @within Public
--
function API.CreateRandomChest(_Name, _Good, _Min, _Max, _Callback)
    if GUI then
        API.Dbg("API.CreateRandomChest: Can not be used from local script!");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateRandomChest(_Name, _Good, _Min, _Max, _Callback);
end
CreateRandomChest = API.CreateRandomChest;

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge an Gold
-- des angegebenen Typs.
--
-- <b>Alias</b>: CreateRandomGoldChest
-- 
-- @param _Name Name der zu ersetzenden Script Entity
-- @within Public
--
function API.CreateRandomGoldChest(_Name)
    if GUI then
        API.Dbg("API.CreateRandomGoldChest('" .._Name.. "')");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateRandomChest(_Name, Goods.G_Gold, 300, 600);
end
CreateRandomGoldChest = API.CreateRandomGoldChest;

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge an Gütern
-- des angegebenen Typs.
-- Güter können seien: Eisen, Stein, HOlz, Wolle, Fleisch, Kräuter,
-- Honigwaben, Milch, Fisch oder Getreide.
--
-- <b>Alias</b>: CreateRandomResourceChest
--
-- @param _Name Name der zu ersetzenden Script Entity
-- @within Public
--
function API.CreateRandomResourceChest(_Name)
    if GUI then
        API.Bridge("API.CreateRandomResourceChest('" .._Name.. "')");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateRandomResourceChest(_Name);
end
CreateRandomResourceChest = API.CreateRandomResourceChest;

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge an Luxus-
-- gütern des angegebenen Typs.
-- Güter können seien: Salz, Farben, Edelsteine, Musikinstrumente
-- oder Weihrauch.
--
-- <b>Alias</b>: CreateRandomLuxuryChest
--
-- @param _Name Name der zu ersetzenden Script Entity
-- @within Public
--
function API.CreateRandomLuxuryChest(_Name)
    if GUI then
        API.Bridge("API.CreateRandomLuxuryChest('" .._Name.. "')");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateRandomLuxuryChest(_Name);
end
CreateRandomLuxuryChest = API.CreateRandomLuxuryChest;

---
-- Erstellt eine Trebuchet-Baustelle an der Position mit den
-- angegebenen Baukosten.
--
-- <b>Alias</b>: CreateTrebuchetConstructionSite
--
-- @param _Name     Skriptname Position
-- @param _GoldCost Goldkosten
-- @param _WoodCost Holzkosten
-- @within Public
--
function API.CreateTrebuchetConstructionSite(_Name, _GoldCost, _WoodCost)
    if GUI then
        API.Bridge("API.CreateTrebuchetConstructionSite('" .._Name.. "', " .._GoldCost.. ", " .._WoodCost.. ")");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateTrebuchetConstructionSite(_Name, _GoldCost, _WoodCost);
end
CreateTrebuchetConstructionSite = API.CreateTrebuchetConstructionSite;

---
-- Zerstört eine Trebuchet-Baustelle.
--
-- <b>Alias</b>: DestroyTrebuchetConstructionSite
--
-- @param _Name Skriptname Position
-- @within Public
--
function API.DestroyTrebuchetConstructionSite(_Name)
    if GUI then
        API.Bridge("API.DestroyTrebuchetConstructionSite('" .._Name.. "')");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:DestroyTrebuchetConstructionSite(_Name);
end
DestroyTrebuchetConstructionSite = API.DestroyTrebuchetConstructionSite;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnInteractiveObjectTemplates = {
    Global = {
        Data = {
            ConstructionSite = {
                Sites = {},
                
                Description = {
                    Title = {
                        de = "Gebäude bauen",
                        en = "Create building",
                    },
                    Text = {
                        de = "Gib das Gebäude in Auftrag. Ein Siedler wird aus"..
                             " dem Lagerhaus kommen und mit dem Bau beginnen.",
                        en = "Order a building. A worker will come out of the"..
                             " storehouse and erect it.",
                    },
                    Unfulfilled = {
                        de = "Das Gebäude kann derzeit nicht gebaut werden.",
                        en = "The building can not be built at the moment.",
                    },
                }
            },
            
            Mines = {
                Description = {
                    Title = {
                        de = "Mine errichten",
                        en = "Build pit",
                    },
                    Text = {
                        de = "An diesem Ort könnt Ihr eine Mine errichten!",
                        en = "You're able to create a pit at this location!",
                    },
                },
            },
            
            Chests = {
                Description = {
                    Title = {
                        de = "Schatztruhe",
                        en = "Treasure Chest",
                    },
                    Text = {
                        de = "Diese Truhe enthält einen geheimen Schatz. Öffnet sie um den Schatz zu bergen.",
                        en = "This chest contains a secred treasure. Open it to salvage the treasure.",
                    },
                },
            },
            
            Trebuchet = {
                Error = {
                    de = "Der Ritter benötigt einen höheren Titel!",
                    en = "Your knight need a higher title to use this site!",
                },
                Description = {
                    Title = {
                        de = "Trebuchet anfordern",
                        en = "Order trebuchet",
                    },
                    Text = {
                        de = "- Fordert ein Trebuchet aus der Stadt an {cr}- Trebuchet wird gebaut, wenn Wagen Baustelle erreicht {cr}- Fährt zurück, wenn Munition aufgebraucht {cr}- Trebuchet kann manuell zurückgeschickt werden",
                        en = "- Order a trebuchet from your city {cr}- The trebuchet is build after the cart has arrived {cr}- Returns after ammunition is depleted {cr}- The trebuchet can be manually send back to the city",
                    },
                },
                
                Sites = {},
                NeededKnightTitle = 0,
                IsActive = false,
            },
        }
    },
    Local = {
        Data = {},
    },
}

-- Global ----------------------------------------------------------------------

---
-- Initalisiert das AddOn.
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:Install()
end

---
-- Initialisiert die interaktiven Baustellen.
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:TrebuchetActivate()
    if not self.Data.Trebuchet.IsActive then
        GameCallback_QSB_OnDisambleTrebuchet = AddOnInteractiveObjectTemplates.Global.OnTrebuchetDisambled;
        GameCallback_QSB_OnErectTrebuchet = function() end;
        StartSimpleJobEx(self.WatchTrebuchetsAndCarts);
        API.DisableRefillTrebuchet(true);
        self.Data.Trebuchet.IsActive = true;
    end
end

---
-- Prüft, ob der menschliche Spieler einen ausreichenden Titel
-- hat um Trebuchets zu bauen.
--
-- @return boolean: Titel hoch genug
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global.TrebuchetHasSufficentTitle()
    local pID = 1;
    for i=1,8 do
        if Logic.PlayerGetIsHumanFlag(i) == 1 then
            pID = i;
            break;
        end
    end
    return Logic.GetKnightTitle(pID) >= AddOnInteractiveObjectTemplates.Global.Data.Trebuchet.NeededKnightTitle;
end

---
-- Setzt den mindestens benötigten Titel um Trebuchets zu bauen.
--
-- @param _KnightTitle Titel
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:TrebuchetSetNeededKnightTitle(_KnightTitle)
    self.Data.Trebuchet.NeededKnightTitle = _KnightTitle;
end

---
-- Erstellt eine Trebuchet-Baustelle an der Position mit den
-- angegebenen Baukosten.
--
-- @param _Name     Skriptname Position
-- @param _GoldCost Goldkosten
-- @param _WoodCost Holzkosten
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:CreateTrebuchetConstructionSite(_Name, _GoldCost, _WoodCost)
    self:TrebuchetActivate();

    _GoldCost = _GoldCost or 4500;
    _WoodCost = _WoodCost or 35;
    local eID = GetID(_Name);
    Logic.SetModel(eID, Models.Buildings_B_BuildingPlot_8x8);
    Logic.SetVisible(eID, true);

    self.Data.Trebuchet.Sites[_Name] = {
        ConstructedTrebuchet = 0,
        ConstructionCart = 0,
        ReturningCart = 0,
    }

    CreateObject {
        Name                    = _Name,
        Title                   = self.Data.Trebuchet.Description.Title,
        Text                    = self.Data.Trebuchet.Description.Text,
        Costs                   = {Goods.G_Gold, _GoldCost, Goods.G_Wood, _WoodCost},
        Distance                = 1000,
        State                   = 0,
        Condition               = self.TrebuchetHasSufficentTitle,
        ConditionUnfulfilled    = self.Data.Trebuchet.Error,
        Callback                = function(t, PlayerID)
            AddOnInteractiveObjectTemplates.Global:SpawnTrebuchetCart(PlayerID, t.Name);
        end,
    }
end

---
-- Zerstört eine Trebuchet-Baustelle.
--
-- @param _Name Skriptname Position
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:DestroyTrebuchetConstructionSite(_Name)
    local ConstructionCart = self.Data.Trebuchet.Sites[_Name].ConstructionCart;
    DestroyEntity(ConstructionCart);
    local ConstructedTrebuchet = self.Data.Trebuchet.Sites[_Name].ConstructedTrebuchet;
    DestroyEntity(ConstructedTrebuchet);
    local ReturningCart = self.Data.Trebuchet.Sites[_Name].ReturningCart;
    DestroyEntity(ReturningCart);

    self.Data.Trebuchet.Sites[_Name] = nil;
    Logic.SetVisible(GetID(_Name), false);
    RemoveInteractiveObject(_name);
end

---
-- Erzeugt einen Trebuchetwagen für die Baustelle.
--
-- @param _PlayerID Besitzer
-- @param _Site     Baustelle
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:SpawnTrebuchetCart(_PlayerID, _Site)
    local StoreID = Logic.GetStoreHouse(_PlayerID);
    local x,y = Logic.GetBuildingApproachPosition(StoreID);
    local CartID = Logic.CreateEntity(Entities.U_SiegeEngineCart, x, y, 0, _PlayerID);
    Logic.SetEntitySelectableFlag(CartID, 0);
    self.Data.Trebuchet.Sites[_Site].ConstructionCart = CartID;
end

---
-- Erzeugt das Trebuchet an der Baustelle.
--
-- @param _PlayerID Besitzer
-- @param _Site     Baustelle
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:SpawnTrebuchet(_PlayerID, _Site)
    local pos = GetPosition(_Site);
    local TrebuchetID = Logic.CreateEntity(Entities.U_Trebuchet, pos.X, pos.Y, 0, _PlayerID);
    self.Data.Trebuchet.Sites[_Site].ConstructedTrebuchet = TrebuchetID;
end

---
-- Baut das Trebuchet zum Wagen zurück und lässt es wieder ins
-- Lagerhaus des Besitzers fahren.
--
-- @param _PlayerID  Besitzer
-- @param _Trebuchet Baustelle
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:ReturnTrebuchetToStorehouse(_PlayerID, _Trebuchet)
    local x,y,z = Logic.EntityGetPos(_Trebuchet);
    local CartID = Logic.CreateEntity(Entities.U_SiegeEngineCart, x, y, 0, _PlayerID);
    Logic.SetEntitySelectableFlag(CartID, 0);

    local SiteName;
    for k,v in pairs(self.Data.Trebuchet.Sites) do
        if v.ConstructedTrebuchet == _Trebuchet then
            SiteName = k;
        end
    end
    if SiteName then
        self.Data.Trebuchet.Sites[SiteName].ReturningCart = CartID;
        self.Data.Trebuchet.Sites[SiteName].ConstructedTrebuchet = 0;
        Logic.SetVisible(GetID(SiteName), true);
        DestroyEntity(_Trebuchet);
    else
        DestroyEntity(CartID);
    end
end

---
-- Callback: Ein Trebuchet wird manuell zurückgebaut.
--
-- @param _EntityID Entity-ID des Trebuchet
-- @param _PlayerID Besitzer
-- @param _x        X-Position
-- @param _y        Y-Position
-- @param _z        Z-Position
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global.OnTrebuchetDisambled(_EntityID, _PlayerID, _x, _y, _z)
    AddOnInteractiveObjectTemplates.Global:ReturnTrebuchetToStorehouse(_PlayerID, _EntityID);
end

---
-- Steuert die Trebuchet-Mechanik.
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global.WatchTrebuchetsAndCarts()
    for k,v in pairs(AddOnInteractiveObjectTemplates.Global.Data.Trebuchet.Sites) do
        local SiteID = GetID(k);

        -- Stufe 1: Karren kommt
        if v.ConstructionCart ~= 0 then
            -- Bauwagen wurde zerstört
            if not IsExisting(v.ConstructionCart) then
                AddOnInteractiveObjectTemplates.Global.Data.Trebuchet.Sites[k].ConstructionCart = 0;
                API.UnuseInteractiveObject(k);
            end
            -- Bauwagen bewegt sich nicht zum Ziel
            if not Logic.IsEntityMoving(v.ConstructionCart) then
                local SiteID = GetID(k);
                local x,y,z = Logic.EntityGetPos(SiteID);
                Logic.MoveSettler(v.ConstructionCart, x, y);
            end
            -- Bauwagen ist angekommen
            if IsNear(v.ConstructionCart, k, 500) then
                local x,y,z = Logic.EntityGetPos(SiteID);
                local PlayerID = Logic.EntityGetPlayer(v.ConstructionCart);
                AddOnInteractiveObjectTemplates.Global:SpawnTrebuchet(PlayerID, k);
                DestroyEntity(v.ConstructionCart);
                AddOnInteractiveObjectTemplates.Global.Data.Trebuchet.Sites[k].ConstructionCart = 0;
                Logic.SetVisible(SiteID, false);
                Logic.CreateEffect(EGL_Effects.E_Shockwave01, x, y, 0);
            end
        end

        -- Stufe 2: Trebuchet steht
        if v.ConstructedTrebuchet ~= 0 then
            -- Trebuchet wurde zerstört
            if not IsExisting(v.ConstructedTrebuchet) then
                AddOnInteractiveObjectTemplates.Global.Data.Trebuchet.Sites[k].ConstructedTrebuchet = 0;
                Logic.SetVisible(SiteID, true);
                API.UnuseInteractiveObject(k);
            end
            -- Trebuchet hat keine Munition
            if Logic.GetAmmunitionAmount(v.ConstructedTrebuchet) == 0 and BundleEntitySelection.Local.Data.RefillTrebuchet == false then
                local PlayerID = Logic.EntityGetPlayer(v.ConstructedTrebuchet);
                AddOnInteractiveObjectTemplates.Global:ReturnTrebuchetToStorehouse(PlayerID, v.ConstructedTrebuchet);
            end
        end

        -- Stufe 3: Rückweg
        if v.ReturningCart ~= 0 then
            -- Rückkehrwagen wurde zerstört
            if not IsExisting(v.ReturningCart) then
                AddOnInteractiveObjectTemplates.Global.Data.Trebuchet.Sites[k].ReturningCart = 0;
                API.UnuseInteractiveObject(k);
            end

            local PlayerID = Logic.EntityGetPlayer(v.ReturningCart);
            local StoreID = Logic.GetStoreHouse(PlayerID);

            -- Rückkehrwagen muss sich zum Ziel bewegen
            if not Logic.IsEntityMoving(v.ReturningCart) then
                local x,y = Logic.GetBuildingApproachPosition(StoreID);
                Logic.MoveSettler(v.ReturningCart, x, y);
            end
            -- Rückkehrwagen kommt an
            if IsNear(v.ReturningCart, StoreID, 1100) then
                local PlayerID = Logic.EntityGetPlayer(v.ConstructionCart);
                DestroyEntity(v.ReturningCart);
            end
        end
    end
end

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge an Waren
-- des angegebenen Typs.
-- @param _Name     Name der zu ersetzenden Script Entity
-- @param _Good     Warentyp
-- @param _Min      Mindestmenge
-- @param _Max      Maximalmenge
-- @param _Callback Callback-Funktion
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:CreateRandomChest(_Name, _Good, _Min, _Max, _Callback)
    _Min = (_Min ~= nil and _Min > 0 and _Min) or 1;
    _Max = (_Max ~= nil and _Max > 1 and _Max) or 2;
    if not _Callback then
        _Callback = function(t) end
    end
    assert(_Good ~= nil, "CreateRandomChest: Good does not exist!");
    assert(_Min < _Max, "CreateRandomChest: min amount must be smaller than max amount!");

    local eID = ReplaceEntity(_Name, Entities.XD_ScriptEntity, 0);
    Logic.SetModel(eID, Models.Doodads_D_X_ChestClose);
    Logic.SetVisible(eID, true);

    CreateObject {
        Name                    = _Name,
        Title                   = self.Data.Chests.Description.Title,
        Text                    = self.Data.Chests.Description.Text,
        Reward                  = {_Good, math.random(_Min, _Max)},
        Texture                 = {1, 6},
        Distance                = 650,
        State                   = 0,
        CallbackOpened          = _Callback,
        Callback                = function(_Data)
            ReplaceEntity(_Data.Name, Entities.D_X_ChestOpenEmpty);
            _Data.CallbackOpened(_Data);
        end,
    }
end

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge an Gold
-- des angegebenen Typs.
-- 
-- @param _Name Name der zu ersetzenden Script Entity
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:CreateRandomGoldChest(_Name)
    AddOnInteractiveObjectTemplates.Global:CreateRandomChest(_Name, Goods.G_Gold, 300, 600);
end

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge an Gütern
-- des angegebenen Typs.
-- Güter können seien: Eisen, Stein, HOlz, Wolle, Fleisch, Kräuter,
-- Honigwaben, Milch, Fisch oder Getreide.
--
-- @param _Name Name der zu ersetzenden Script Entity
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:CreateRandomResourceChest(_Name)
    local PossibleGoods = {
        Goods.G_Iron, Goods.G_Stone, Goods.G_Wood, Goods.G_Wool,
        Goods.G_Carcass, Goods.G_Herb, Goods.G_Honeycomb,
        Goods.G_Milk, Goods.G_RawFish, Goods.G_Grain
    };
    local Good = PossibleGoods[math.random(1, #PossibleGoods)];
    AddOnInteractiveObjectTemplates.Global:CreateRandomChest(_Name, Good, 30, 60);
end

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge an Luxus-
-- gütern des angegebenen Typs.
-- Güter können seien: Salz, Farben, Edelsteine, Musikinstrumente
-- oder Weihrauch
--
-- @param _Name Name der zu ersetzenden Script Entity
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:CreateRandomLuxuryChest(_Name)
    local Luxury = {Goods.G_Salt, Goods.G_Dye};
    if g_GameExtraNo >= 1 then
        table.insert(Luxury, Goods.G_Gems);
        table.insert(Luxury, Goods.G_MusicalInstrument);
        table.insert(Luxury, Goods.G_Olibanum);
    end
    local Good = Luxury[math.random(1, #Luxury)];
    AddOnInteractiveObjectTemplates.Global:CreateRandomChest(_Name, Good, 50, 100);
end

---
-- Erstelle eine Mine eines bestimmten Typs. Es können zudem eine Bedingung
-- und zwei verschiedene Callbacks vereinbart werden.
--
-- @param _Position         Script Entity, die mit Mine ersetzt wird
-- @param _Type             Typ der Mine
-- @param _Costs            (optional) Kostentabelle
-- @param _NotRefillable    (optional) Die Mine wird weiterhin überwacht
-- @param _Condition        (optional) Bedingungsfunktion
-- @param _CreationCallback (optional) Funktion nach Kauf ausführen
-- @param _CallbackDepleted (optional) Funktion nach Ausbeutung ausführen
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:CreateIOMine(_Position, _Type, _Costs, _NotRefillable, _Condition, _CreationCallback, _CallbackDepleted)
    -- Objekt austauschen und Model anpassen
    local eID = ReplaceEntity(_Position, Entities.XD_ScriptEntity);
    local Model = Models.Doodads_D_SE_ResourceIron_Wrecked;
    if _Type == Entities.R_StoneMine then
        Model = Models.R_SE_ResorceStone_10;
    end
    Logic.SetVisible(eID, true);
    Logic.SetModel(eID, Model);
    local x, y, z = Logic.EntityGetPos(eID);
    local BlockerID = Logic.CreateEntity(Entities.D_ME_Rock_Set01_B_07, x, y, 0, 0);
    Logic.SetVisible(BlockerID, false);

    CreateObject {
        Name                 = _Position,
        Title                = self.Data.Mines.Description.Title,
        Text                 = self.Data.Mines.Description.Text,
        Type                 = _Type,
        Special              = _NotRefillable,
        Costs                = _Costs,
        InvisibleBlocker     = BlockerID,
        Distance             = 1500,
        Condition            = self.ConditionBuildIOMine,
        CustomCondition      = _Condition,
        ConditionUnfulfilled = "Not implemented yet!",
        CallbackCreate       = _CreationCallback,
        CallbackDepleted     = _CallbackDepleted,
        Callback             = self.ActionBuildIOMine,
    };
end

---
-- Erstelle eine Eisenmine.
--
-- @param _Position      Script Entity, die mit Mine ersetzt wird
-- @param _Cost1Type     (optional) Kostenware 1
-- @param _Cost1Amount   (optional) Kostenmenge 1
-- @param _Cost2Type     (optional) Kostenware 2
-- @param _Cost2Amount   (optional) Kostenmenge 2
-- @param _NotRefillable (optional) Mine wird nach Ausbeutung zerstört
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:CreateIOIronMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable)
    assert(IsExisting(_Position));
    if _Cost1Type then
        assert(API.TraverseTable(_Cost1Type, Goods));
        assert(type(_Cost1Amount) == "number");
    end
    if _Cost2Type then
        assert(API.TraverseTable(_Cost2Type, Goods));
        assert(type(_Cost2Amount) == "number");
    end

    self:CreateIOMine(
        _Position, Entities.R_IronMine,
        {_Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount},
        _NotRefillable
    );
end

---
-- Erstelle eine Steinmine.
--
-- @param _Position      Script Entity, die mit Mine ersetzt wird
-- @param _Cost1Type     (optional) Kostenware 1
-- @param _Cost1Amount   (optional) Kostenmenge 1
-- @param _Cost2Type     (optional) Kostenware 2
-- @param _Cost2Amount   (optional) Kostenmenge 2
-- @param _NotRefillable (optional) Mine wird nach Ausbeutung zerstört
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:CreateIOStoneMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable)
    assert(IsExisting(_Position));
    if _Cost1Type then
        assert(API.TraverseTable(_Cost1Type, Goods));
        assert(type(_Cost1Amount) == "number");
    end
    if _Cost2Type then
        assert(API.TraverseTable(_Cost2Type, Goods));
        assert(type(_Cost2Amount) == "number");
    end

    self:CreateIOMine(
        _Position, Entities.R_StoneMine,
        {_Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount},
        _NotRefillable
    );
end

---
-- Testet die Bedingung, unter der die Mine errichtet werden kann.
-- @param _Data Daten des Objektes
-- @return boolean: Bedingung erfüllt
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global.ConditionBuildIOMine(_Data)
    if _Data.CustomCondition then
        return _Data.CustomCondition(_Data) == true;
    end
    return true;
end


function AddOnInteractiveObjectTemplates.Global.ActionBuildIOMine(_Data)
    ReplaceEntity(_Data.Name, _Data.Type);
    DestroyEntity(_Data.InvisibleBlocker);
    if type(_Data.CallbackCreate) == "function" then
        _Data.CallbackCreate(_Data);
    end
    Trigger.RequestTrigger( Events.LOGIC_EVENT_EVERY_SECOND, "", "ControlIOMine", 1, {}, { _Data.Name });
end

---
-- Prüft gebaute Minen ob diese ausgebeutet sind. Ist das der Fall
-- werden sie "zerstört" und ggf. das Callback ausgelöst.
-- @param _Mine Zu überwachende Mine
-- @return boolean: Job beendet
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global.ControlIOMine(_Mine)
    if not IO[_Mine] then
        return true;
    end
    if not IsExisting(_Mine) then
        return true;
    end
    local eID = GetID(_Mine);

    if Logic.GetResourceDoodadGoodAmount(eID) == 0 then
        if IO[_Mine].Special == true then
            local Model = Models.Doodads_D_SE_ResourceIron_Wrecked;
            if IO[_Mine].Type == Entities.R_StoneMine then
                Model = Models.R_ResorceStone_Scaffold_Destroyed;
            end
            eID = ReplaceEntity(eID, Entities.XD_ScriptEntity);
            Logic.SetVisible(eID, true);
            Logic.SetModel(eID, Model);
        end

        if type(IO[_Mine].CallbackDepleted) == "function" then
            IO[_Mine].CallbackDepleted(IO[_Mine]);
        end
        return true;
    end
end

---
-- Initialisiert die interaktiven Baustellen.
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:ConstructionSiteActivate()
    if self.Data.ConstructionSiteActivated then
        return;
    end
    self.Data.ConstructionSiteActivated = true;

    Core:AppendFunction(
        "GameCallback_OnBuildingConstructionComplete",
        self.OnConstructionComplete
    );
end

---
-- Ruft das Callback einer Baustelle auf, sofern eins definiert wurde.
-- @param _PlayerID Besitzer des Gebäudes
-- @param _EntityID Entity-ID des Gebäudes
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global.OnConstructionComplete(_PlayerID, _EntityID)
    local IO = AddOnInteractiveObjectTemplates.Global.Data.ConstructionSite.Sites[_EntityID];
    if IO ~= nil and IO.CompletedCallback then
        IO.CompletedCallback(IO, _EntityID);
    end
end

---
-- Erzeugt eine Baustelle an der Position.
--
-- @param _Position Zielpunkt
-- @param _PlayerID Besitzer des Gebäudes
-- @param _Type     Typ des Gebäudes
-- @param _Costs    (optional) Eigene Gebäudekosten
-- @param _Distance (optional) Aktivierungsentfernung
-- @param _Icon     (optional) Icon des Schalters
-- @param _Title    (optional) Titel der Beschreibung
-- @param _Text     (optional) Text der Beschreibung
-- @param _Callback (optional) Funktion nach fertigstellung
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global:CreateIOBuildingSite(_Position, _PlayerID, _Type, _Costs, _Distance, _Icon, _Title, _Text, _Callback)
    AddOnInteractiveObjectTemplates.Global:ConstructionSiteActivate();
    local Costs = _Costs or {Logic.GetEntityTypeFullCost(_Type)};
    local Title = _Title or self.Data.ConstructionSite.Description.Title;
    local Text  = Text or self.Data.ConstructionSite.Description.Text;
    local eID = GetID(_Position);
    Logic.SetModel(eID, Models.Buildings_B_BuildingPlot_10x10);
    Logic.SetVisible(eID, true);
    
    CreateObject {
        Name                 = _Position,
        Title                = Title,
        Text                 = Text,
        Texture              = _Icon or {14, 10},
        Distance             = _Distance or 1500,
        Type                 = _Type,
        Costs                = Costs,
        Condition            = AddOnInteractiveObjectTemplates.Global.ConditionConstructionSite,
        ConditionUnfulfilled = AddOnInteractiveObjectTemplates.Global.Data.ConstructionSite.Description.Unfulfilled,
        PlayerID             = _PlayerID,
        CompletedCallback    = _Callback,
        Callback             = AddOnInteractiveObjectTemplates.Global.Callback;
    };
end

---
-- Lässt einen Siedler die Baustelle zum Gebäude aufbauen.
-- @param _Data Daten des Objekt
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global.Callback(_Data)
    local pos  = GetPosition(_Data.Name);
    local eID  = GetID(_Data.Name);
    local ori  = Logic.GetEntityOrientation(eID);
    local site = Logic.CreateConstructionSite(pos.X, pos.Y, ori, _Data.Type, _Data.PlayerID);
    Logic.SetVisible(eID, false);
    if (site == nil) then
        API.Dbg('AddOnInteractiveObjectTemplates.Global:CreateIOBuildingSite: Failed to place construction site!');
        return;
    end
    AddOnInteractiveObjectTemplates.Global.Data.ConstructionSite.Sites[site] = _Data;
    StartSimpleJobEx(AddOnInteractiveObjectTemplates.Global.ControlConstructionSite, site);
end

---
-- Prüft ob das Gebäude theoretisch gebaut werden kann.
-- @param _Data Daten des Objekt
-- @return boolean: Kann aktiviert werden
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global.ConditionConstructionSite(_Data)
    local eID = GetID(_Data.Name);
    local tID = GetTerritoryUnderEntity(eID);
    local pID = Logic.GetTerritoryPlayerID(tID);

    if Logic.GetStoreHouse(_Data.PlayerID) == 0 then
        return false;
    end
    if _Data.PlayerID ~= tID then
        return false;
    end
    return true;
end

---
-- Überwacht eine Gebäudebaustelle und reaktiviert sie fall nötig.
-- @param _eID EntityID des Gebäudes
-- @return boolean: Job beenden
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Global.ControlConstructionSite(_eID)
    if AddOnInteractiveObjectTemplates.Global.Data.ConstructionSite.Sites[_eID] == nil then
        return true;
    end
    if not IsExisting(_eID) then
        local Name = AddOnInteractiveObjectTemplates.Global.Data.ConstructionSite.Sites[_eID].Name;
        Logic.SetVisible(GetID(Name), true);
        API.UnuseInteractiveObject(Name);
        return true;
    end
end

-- Local -----------------------------------------------------------------------

---
-- Initalisiert das AddOn.
-- @within Private
-- @local
--
function AddOnInteractiveObjectTemplates.Local:Install()
end

Core:RegisterAddOn("AddOnInteractiveObjectTemplates");