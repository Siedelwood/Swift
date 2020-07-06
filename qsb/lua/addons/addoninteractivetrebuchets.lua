-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnInteractiveTrebuchets                                   # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Der Spieler kann ein Trebuchet mieten. Das Trebuchet fährt als Karren vor,
-- wird "aufgebaut" und kann anschließend benutzt werden.<br> Das Trebuchet
-- fährt ab, wenn die Munition alle ist oder der Spieler das Trebuchet abbaut.
-- <br>Sobald ein Trebuchet zerstört wird oder sein Karren wieder am Lagerhaus
-- ankommt, wird die Baustelle wieder freigegeben.
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnInteractiveTrebuchets = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erstellt eine Trebuchet-Baustelle an der Position mit den
-- angegebenen Baukosten.
--
-- Das Trebuchet kann von einem Helden aufgebaut werden. Es wird ein Karren
-- aus dem Lagerhaus zur Baustelle fahren. Erreicht der Karren die Baustelle,
-- wird er durch ein Trebuchet ersetzt.
--
-- Das Trebuchet hat dann 10 Schuss. Sind diese aufgebraucht wird das Trebuchet
-- abgebaut und fährt in das Lagerhaus zurück. Sobald der Karren angekommen
-- ist, kann die Baustelle erneut aktiviert werden.
--
-- <b>Achtung:</b>Das Auffüllen von Trebuchets wird deaktiviert, sobald eine
-- Baustelle erzeugt wird. Es wird NICHT empfohlen dem Spieler beides, normale
-- Trebuchets und Trebuchetbaustellen, zur gleichen Zeit zu geben!
--
-- <p><b>Alias</b>: CreateTrebuchetConstructionSite</p>
--
-- @param[type=string] _Name Skriptname Position
-- @param[type=number] _GoldCost Goldkosten
-- @param[type=number] _WoodCost Holzkosten
-- @within Anwenderfunktionen
--
-- @usage API.CreateTrebuchetConstructionSite("trebuchetSite1", 250, 10);
--
function API.CreateTrebuchetConstructionSite(_Name, _GoldCost, _WoodCost)
    if GUI then
        return;
    end
    AddOnInteractiveTrebuchets.Global:CreateTrebuchetConstructionSite(_Name, _GoldCost, _WoodCost);
end
CreateTrebuchetConstructionSite = API.CreateTrebuchetConstructionSite;

---
-- Zerstört eine Trebuchet-Baustelle, aber nicht die Skript Entity.
--
-- Die Baustelle wird in jedem möglichen Status zerstört. Es ist egal, ob das
-- Trebuchet aufgebaut ist, gerade ein Karren unterwegs ist, oder die Baustelle
-- noch nie berührt wurde.
--
-- <p><b>Alias</b>: DestroyTrebuchetConstructionSite</p>
--
-- @param[type=string] _Name Skriptname Position
-- @within Anwenderfunktionen
--
-- @usage API.DestroyTrebuchetConstructionSite("trebuchetSite1");
--
function API.DestroyTrebuchetConstructionSite(_Name)
    if GUI then
        return;
    end
    AddOnInteractiveTrebuchets.Global:DestroyTrebuchetConstructionSite(_Name);
end
DestroyTrebuchetConstructionSite = API.DestroyTrebuchetConstructionSite;

---
-- Gibt die EntityID aufgebaute Trebuchet der Trebuchet-Baustelle zurück.
-- Sollte kein Trebuchet aufgebaut sein, wird 0 zurückgegeben.
--
-- @param[type=string] _Name Skriptname der Trebuchet-Baustelle
-- @return[type=number] EntityID des Trebuchet
-- @within Anwenderfunktionen
--
-- @usage local ID = API.GetTrebuchetByTrebuchetConstructionSite("trebuchetSite1");
--
function API.GetTrebuchetByTrebuchetConstructionSite(_Name)
    if GUI then
        return;
    end
    if not AddOnInteractiveTrebuchets.Global.Data.Trebuchet.Sites[_Name] then
        error("API.GetTrebuchetByTrebuchetConstructionSite: Site '" ..tostring(_Name).. "' does not exist!");
        return 0;
    end
    return AddOnInteractiveTrebuchets.Global.Data.Trebuchet.Sites[_Name].ConstructedTrebuchet;
end
GetTrebuchet = API.GetTrebuchetByTrebuchetConstructionSite;

---
-- Gibt die EntityID des Anforderungswagens der Trebuchet-Baustelle zurück.
-- Sollte kein Anforderungswagen unterwegs sein, wird 0 zurückgegeben.
--
-- @param[type=string] _Name Skriptname der Trebuchet-Baustelle
-- @return[type=number] EntityID des angeforderten Wagens
-- @within Anwenderfunktionen
--
-- @usage local ID = API.GetReturningCartByTrebuchetConstructionSite("trebuchetSite1");
--
function API.GetReturningCartByTrebuchetConstructionSite(_Name)
    if GUI then
        return;
    end
    if not AddOnInteractiveTrebuchets.Global.Data.Trebuchet.Sites[_Name] then
        error("API.GetReturningCartByTrebuchetConstructionSite: Site '" ..tostring(_Name).. "' does not exist!");
        return 0;
    end
    return AddOnInteractiveTrebuchets.Global.Data.Trebuchet.Sites[_Name].ReturningCart;
end
GetReturningCart = API.GetReturningCartByTrebuchetConstructionSite;

---
-- Gibt die EntityID des Abreisewagens der Trebuchet-Baustelle zurück. Sollte
-- kein Abreisewagens unterwegs sein, wird 0 zurückgegeben.
--
-- @param[type=string] _Name Skriptname der Trebuchet-Baustelle
-- @return[type=number] EntityID des angeforderten Wagens
-- @within Anwenderfunktionen
--
-- @usage local ID = API.GetConstructionCartByTrebuchetConstructionSite("trebuchetSite1");
--
function API.GetConstructionCartByTrebuchetConstructionSite(_Name)
    if GUI then
        return;
    end
    if not AddOnInteractiveTrebuchets.Global.Data.Trebuchet.Sites[_Name] then
        error("API.GetConstructionCartByTrebuchetConstructionSite: Site '" ..tostring(_Name).. "' does not exist!");
        return 0;
    end
    return AddOnInteractiveTrebuchets.Global.Data.Trebuchet.Sites[_Name].ConstructionCart;
end
GetConstructionCart = API.GetConstructionCartByTrebuchetConstructionSite;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnInteractiveTrebuchets = {
    Global = {
        Data = {
            Trebuchet = {
                Description = {
                    Title = {
                        de = "Trebuchet anfordern",
                        en = "Order trebuchet",
                        fr = "Demande de trébuchet"
                    },
                    Text = {
                        de = "- Fordert ein Trebuchet aus der Stadt an {cr}- Trebuchet wird gebaut, wenn Wagen Baustelle erreicht {cr}- Fährt zurück, wenn Munition aufgebraucht {cr}- Trebuchet kann manuell zurückgeschickt werden",
                        en = "- Order a trebuchet from your city {cr}- The trebuchet is build after the cart has arrived {cr}- Returns after ammunition is depleted {cr}- The trebuchet can be manually send back to the city",
                        fr = "- Demander un trébuchet à votre ville {cr}- Le trébuchet est construit lorsque le chariot atteint le site de construction {cr}- Retour quand les munitions sont épuisées {cr}- Le trébuchet peut être renvoyé manuellement"
                    },
                },

                Sites = {},
                NeededKnightTitle = 0,
                IsActive = false,
            },
        }
    },
}

-- Global ----------------------------------------------------------------------

---
-- Initalisiert das AddOn.
-- @within Internal
-- @local
--
function AddOnInteractiveTrebuchets.Global:Install()
end

---
-- Initialisiert die interaktiven Trebuchet-Baustellen.
-- @within Internal
-- @local
--
function AddOnInteractiveTrebuchets.Global:TrebuchetActivate()
    if not self.Data.Trebuchet.IsActive then
        GameCallback_QSB_OnDisambleTrebuchet = AddOnInteractiveTrebuchets.Global.OnTrebuchetDisambled;
        GameCallback_QSB_OnErectTrebuchet = function() end;
        StartSimpleJobEx(self.WatchTrebuchetsAndCarts);
        self.Data.Trebuchet.IsActive = true;
    end
end

---
-- Prüft, ob der menschliche Spieler einen ausreichenden Titel
-- hat um Trebuchets zu bauen.
--
-- @return boolean: Titel hoch genug
-- @within Internal
-- @local
--
function AddOnInteractiveTrebuchets.Global.TrebuchetHasSufficentTitle()
    return Logic.GetKnightTitle(QSB.HumanPlayerID) >= AddOnInteractiveTrebuchets.Global.Data.Trebuchet.NeededKnightTitle;
end

---
-- Setzt den mindestens benötigten Titel um Trebuchets zu bauen.
--
-- @param _KnightTitle Titel
-- @within Internal
-- @local
--
function AddOnInteractiveTrebuchets.Global:TrebuchetSetNeededKnightTitle(_KnightTitle)
    self.Data.Trebuchet.NeededKnightTitle = _KnightTitle;
end

---
-- Erstellt eine Trebuchet-Baustelle an der Position mit den
-- angegebenen Baukosten.
--
-- @param _Name [string] Skriptname Position
-- @param _GoldCost Goldkosten
-- @param _WoodCost Holzkosten
-- @within Internal
-- @local
--
function AddOnInteractiveTrebuchets.Global:CreateTrebuchetConstructionSite(_Name, _GoldCost, _WoodCost)
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
        Callback                = function(_IO, _PlayerID, _Data)
            AddOnInteractiveTrebuchets.Global:SpawnTrebuchetCart(_PlayerID, _Data.Name);
        end,
    }
end

---
-- Zerstört eine Trebuchet-Baustelle.
--
-- @param _Name [string] Skriptname Position
-- @within Internal
-- @local
--
function AddOnInteractiveTrebuchets.Global:DestroyTrebuchetConstructionSite(_Name)
    local ConstructionCart = self.Data.Trebuchet.Sites[_Name].ConstructionCart;
    DestroyEntity(ConstructionCart);
    local ConstructedTrebuchet = self.Data.Trebuchet.Sites[_Name].ConstructedTrebuchet;
    DestroyEntity(ConstructedTrebuchet);
    local ReturningCart = self.Data.Trebuchet.Sites[_Name].ReturningCart;
    DestroyEntity(ReturningCart);

    self.Data.Trebuchet.Sites[_Name] = nil;
    Logic.SetVisible(GetID(_Name), false);
    RemoveInteractiveObject(_Name);
end

---
-- Erzeugt einen Trebuchetwagen für die Baustelle.
--
-- @param _PlayerID Besitzer
-- @param _Site     Baustelle
-- @within Internal
-- @local
--
function AddOnInteractiveTrebuchets.Global:SpawnTrebuchetCart(_PlayerID, _Site)
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
-- @within Internal
-- @local
--
function AddOnInteractiveTrebuchets.Global:SpawnTrebuchet(_PlayerID, _Site)
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
-- @within Internal
-- @local
--
function AddOnInteractiveTrebuchets.Global:ReturnTrebuchetToStorehouse(_PlayerID, _Trebuchet)
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
-- @within Internal
-- @local
--
function AddOnInteractiveTrebuchets.Global.OnTrebuchetDisambled(_EntityID, _PlayerID, _x, _y, _z)
    AddOnInteractiveTrebuchets.Global:ReturnTrebuchetToStorehouse(_PlayerID, _EntityID);
end

---
-- Steuert die Trebuchet-Mechanik.
-- @within Internal
-- @local
--
function AddOnInteractiveTrebuchets.Global.WatchTrebuchetsAndCarts()
    for k,v in pairs(AddOnInteractiveTrebuchets.Global.Data.Trebuchet.Sites) do
        local SiteID = GetID(k);

        -- Stufe 1: Karren kommt
        if v.ConstructionCart ~= 0 then
            -- Bauwagen wurde zerstört
            if not IsExisting(v.ConstructionCart) then
                AddOnInteractiveTrebuchets.Global.Data.Trebuchet.Sites[k].ConstructionCart = 0;
                API.InteractiveObjectActivate(k);
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
                AddOnInteractiveTrebuchets.Global:SpawnTrebuchet(PlayerID, k);
                DestroyEntity(v.ConstructionCart);
                AddOnInteractiveTrebuchets.Global.Data.Trebuchet.Sites[k].ConstructionCart = 0;
                Logic.SetVisible(SiteID, false);
                Logic.CreateEffect(EGL_Effects.E_Shockwave01, x, y, 0);
            end
        end

        -- Stufe 2: Trebuchet steht
        if v.ConstructedTrebuchet ~= 0 then
            -- Trebuchet wurde zerstört
            if not IsExisting(v.ConstructedTrebuchet) then
                AddOnInteractiveTrebuchets.Global.Data.Trebuchet.Sites[k].ConstructedTrebuchet = 0;
                Logic.SetVisible(SiteID, true);
                API.InteractiveObjectActivate(k);
            end
            -- Trebuchet hat keine Munition
            if Logic.GetAmmunitionAmount(v.ConstructedTrebuchet) == 0 and BundleEntitySelection.Local.Data.RefillTrebuchet == false then
                local PlayerID = Logic.EntityGetPlayer(v.ConstructedTrebuchet);
                AddOnInteractiveTrebuchets.Global:ReturnTrebuchetToStorehouse(PlayerID, v.ConstructedTrebuchet);
            end
        end

        -- Stufe 3: Rückweg
        if v.ReturningCart ~= 0 then
            -- Rückkehrwagen wurde zerstört
            if not IsExisting(v.ReturningCart) then
                AddOnInteractiveTrebuchets.Global.Data.Trebuchet.Sites[k].ReturningCart = 0;
                API.InteractiveObjectActivate(k);
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

-- -------------------------------------------------------------------------- --

Core:RegisterAddOn("AddOnInteractiveTrebuchets");

