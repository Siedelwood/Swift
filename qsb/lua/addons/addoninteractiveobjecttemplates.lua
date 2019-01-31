-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnInteractiveObjectTemplates                              # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle bietet fertige Schablonen für interaktive Objekte. Mit diesen
-- Schablonen können komplexere interaktive Objekte einfach erstellt und durch
-- den Mapper genutzt werden.
--
-- <p>
-- <b>Interaktive Baustellen:</b><br>
-- Ermöglicht es den Spieler auf einem beliebigen Territorium einer Partei
-- ein Gebäude bauen zu lassen.
-- <br>Die Baustelle muss durch den Helden aktiviert
-- werden. Ein Siedler wird aus dem Lagerhaus kommen und das Gebäude bauen.
-- <br><a href="API.CreateIOBuildingSite">Eine Baustelle anlegen</a>
-- </p>
-- <p>
-- <b>Interaktive Schatztruhen:</b><br>
-- Es werden Schatztruhen mit zufälligem Inhalt erzeugt. Diese Truhen werden
-- aktiviert und der Inhalt wird in einem Karren abtransportiert.
-- <br><a href="API.CreateRandomChest">Eine Schatztruhe anlegen</a>
-- </p>
-- <p>
-- <b>Interaktive Minen:</b><br>
-- Der Spieler kann eine Stein- oder Eisenmine erzeugen, die zuerst durch
-- Begleichen der Kosten aufgebaut werden muss, bevor sie genutzt werden kann.
-- <br>Optional kann die Mine einstürzen, wenn sie erschöpft wurde.
-- <br><a href="API.CreateIOMine">Eine Mine anlegen</a>
-- </p>
-- <p>
-- <b>Trebuchet-Baustellen:</b><br>
-- Der Spieler kann Trebuchet mieten. Das Trebuchet fährt als Karren vor,
-- wird aufgebaut und kann anschließend benutzt werden.<br> Das Trebuchet fährt
-- ab, wenn die Munition alle ist oder der Spieler das Trebuchet abbaut.<br>
-- Sobald ein Trebuchet zerstört wird oder sein Karren wieder am Lagerhaus
-- ankommt, wird die Baustelle wieder freigegeben.
-- <br><a href="API.CreateTrebuchetConstructionSite">Eine Baustelle anlegen</a>
-- </p>
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnInteractiveObjectTemplates = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erstelle eine verschüttete Mine eines bestimmten Typs. Es können zudem eine
-- Bedingung und zwei verschiedene Callbacks vereinbart werden.
--
-- Minen können als "nicht auffüllbar" markiert werden. In diesem Fall werden
-- sie zusammenstützen, sobald die Rohstoffe verbraucht sind.
--
-- Verschüttete Minen können durch einen Helden in normale Minen umgewandelt
-- werden. FÜr diese Umwandlung können Kosten anfallen, müssen aber nicht. Es
-- dürfen immer maximal 2 Waren als Kosten verwendet werden.
--
-- Es können weitere Funktionen hinzugefügt werden, um die Mine anzupassen:
-- <ul>
-- <li><u>Bedingung:</u> Eine Funktion, die true oder false zurückgeben muss.
-- Mit dieser Funktion wird bestimmt, ob die Mine gebaut werden darf.</li>
-- <li><u>Callback Aktivierung:</u> Eine Funktion, die ausgeführt wird, wenn
-- die Mine erfolgreich aktiviert wurde (evtl. Kosten bezahlt und/oder
-- Bedingung erfüllt).</li>
-- <li><u>Callback Erschöpft:</u> Eine Funktion, die ausgeführt wird, sobald
-- die Rohstoffe der Mine erschöpft sind.</li>
-- </ul>
--
-- <p><b>Alias</b>: CreateIOMine</p>
--
-- @param[type=string]   _Position         Script Entity, die mit Mine ersetzt wird
-- @param[type=number]   _Type             Typ der Mine
-- @param[type=table]    _Costs            (optional) Kostentabelle
-- @param[type=boolean]  _NotRefillable    (optional) Die Mine wird weiterhin überwacht
-- @param[type=function] _Condition        (optional) Bedingungsfunktion
-- @param[type=function] _CreationCallback (optional) Funktion nach Kauf ausführen
-- @param[type=function] _CallbackDepleted (optional) Funktion nach Ausbeutung ausführen
-- @within Anwenderfunktionen
--
-- @usage
-- -- Beispiel für eine Mine
-- API.CreateIOMine("mine", Entities.B_IronMine, {Goods.G_Wood, 20}, true)
-- -- Die Mine kann für 20 Holz erschlossen werden. Sobald die Rohstoffe
-- -- erschöpft sind, stürzt die Mine zusammen.
--
function API.CreateIOMine(_Position, _Type, _Costs, _NotRefillable, _Condition, _CreationCallback, _CallbackDepleted)
    if GUI then
        API.Fatal("API.CreateIOMine: Can not be used from local script!");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateIOMine(_Position, _Type, _Costs, _NotRefillable, _Condition, _CreationCallback, _CallbackDepleted);
end
CreateIOMine = API.CreateIOMine;

---
-- Erstelle eine verschüttete Eisenmine.
--
-- <p><b>Alias</b>: CreateIOIronMine</p>
--
-- @param[type=string]  _Position      Script Entity, die mit Mine ersetzt wird
-- @param[type=number]  _Cost1Type     (optional) Kostenware 1
-- @param[type=number]  _Cost1Amount   (optional) Kostenmenge 1
-- @param[type=number]  _Cost2Type     (optional) Kostenware 2
-- @param[type=number]  _Cost2Amount   (optional) Kostenmenge 2
-- @param[type=boolean] _NotRefillable (optional) Mine wird nach Ausbeutung zerstört
-- @within Anwenderfunktionen
-- @see API.CreateIOMine
--
-- @usage
-- -- Beispiel für eine Mine
-- API.CreateIOMine("mine", Goods.G_Wood, 20)
--
function API.CreateIOIronMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable)
    if GUI then
        API.Fatal("API.CreateIOIronMine: Can not be used from local script!");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateIOIronMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable);
end
CreateIOIronMine = API.CreateIOIronMine;

---
-- Erstelle eine verschüttete Steinmine.
--
-- <p><b>Alias</b>: CreateIOStoneMine</p>
--
-- @param[type=string]  _Position      Script Entity, die mit Mine ersetzt wird
-- @param[type=number]  _Cost1Type     (optional) Kostenware 1
-- @param[type=number]  _Cost1Amount   (optional) Kostenmenge 1
-- @param[type=number]  _Cost2Type     (optional) Kostenware 2
-- @param[type=number]  _Cost2Amount   (optional) Kostenmenge 2
-- @param[type=boolean] _NotRefillable (optional) Mine wird nach Ausbeutung zerstört
-- @within Anwenderfunktionen
-- @see API.CreateIOMine
--
-- @usage
-- -- Beispiel für eine Mine
-- API.CreateIOMine("mine", Goods.G_Wood, 20)
--
function API.CreateIOStoneMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable)
    if GUI then
        API.Fatal("API.CreateIOStoneMine: Can not be used from local script!");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateIOStoneMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable);
end
CreateIOStoneMine = API.CreateIOStoneMine;

---
-- Erzeugt eine Baustelle eines beliebigen Gebäudetyps an der Position.
--
-- Diese Baustelle kann durch einen Helden aktiviert werden. Dann wird ein
-- Siedler zur Baustelle eilen und das Gebäude aufbauen. Es ist egal, ob es
-- sich um ein Territorium des Spielers oder einer KI handelt.
--
-- Es ist dabei zu beachten, dass der Spieler, dem die Baustelle zugeordnet
-- wird, das Territorium besitzt, auf dem er bauen soll. Des weiteren muss
-- er über ein Lagerhaus/Hauptzelt verfügen.
--
-- <p><b>Hinweis:</b> Es kann vorkommen, dass das Model der Baustelle nicht
-- geladen wird. Dann ist der Boden der Baustelle schwarz. Sobald wenigstens
-- ein reguläres Gebäude gebaut wurde, sollte die Textur jedoch vorhanden sein.
-- </p>
--
-- <p><b>Alias</b>: CreateIOBuildingSite</p>
--
-- @param[type=string]   _Position [string] Zielpunkt
-- @param[type=number]   _PlayerID Besitzer des Gebäudes
-- @param[type=number]   _Type Typ des Gebäudes
-- @param[type=table]    _Costs (optional) Eigene Gebäudekosten
-- @param[type=number]   _Distance (optional) Aktivierungsentfernung
-- @param[type=table]    _Icon (optional) Icon des Schalters
-- @param[type=string]   _Title (optional) Titel der Beschreibung
-- @param[type=string]   _Text(optional) Text der Beschreibung
-- @param[type=function] _Callback (optional) Funktion nach Fertigstellung
-- @within Anwenderfunktionen
--
-- @usage
-- -- Erzeugt eine Baustelle ohne besondere Einstellungen
-- API.CreateIOBuildingSite("haus", 1, Entities.B_Bakery)
-- -- Baustelle mit Kosten und Aktivierungsdistanz
-- API.CreateIOBuildingSite("haus", 1, Entities.B_Bakery, {Goods.G_Wood, 4}, 1000)
--
function API.CreateIOBuildingSite(_Position, _PlayerID, _Type, _Costs, _Distance, _Icon, _Title, _Text, _Callback)
    if GUI then
        API.Fatal("API.CreateIOBuildingSite: Can not be used from local script!");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateIOBuildingSite(_Position, _PlayerID, _Type, _Costs, _Distance, _Icon, _Title, _Text, _Callback);
end
CreateIOBuildingSite = API.CreateIOBuildingSite;

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge an Waren
-- des angegebenen Typs.
--
-- Die Menge der Ware ist dabei zufällig und liegt zwischen dem Minimalwert
-- und dem Maximalwert. Optional kann eine Funktion angegeben werden, die
-- ausgeführt wird, wenn die Truhe geöffnet wird. Diese Funktion verhält sich
-- wie das Callback eines interaktiven Objektes.
--
-- <p><b>Alias</b>: CreateRandomChest</p>
--
-- @param[type=string]   _Name Name der zu ersetzenden Script Entity
-- @param[type=number]   _Good Warentyp
-- @param[type=number]   _Min Mindestmenge
-- @param[type=number]   _Max Maximalmenge
-- @param[type=function] _Callback Callback-Funktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.CreateRandomChest("chest", Goods.G_Gems, 100, 300, OnChestOpened)
--
function API.CreateRandomChest(_Name, _Good, _Min, _Max, _Callback)
    if GUI then
        API.Fatal("API.CreateRandomChest: Can not be used from local script!");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateRandomChest(_Name, _Good, _Min, _Max, _Callback);
end
CreateRandomChest = API.CreateRandomChest;

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge Gold.
--
-- <p><b>Alias</b>: CreateRandomGoldChest</p>
--
-- @param[type=string] _Name Name der zu ersetzenden Script Entity
-- @within Anwenderfunktionen
--
function API.CreateRandomGoldChest(_Name)
    if GUI then
        API.Fatal("API.CreateRandomGoldChest('" .._Name.. "')");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateRandomChest(_Name, Goods.G_Gold, 300, 600);
end
CreateRandomGoldChest = API.CreateRandomGoldChest;

---
-- Erstellt eine Schatztruhe mit einer zufälligen Art und Menge
-- an Gütern.
--
-- Güter können seien: Eisen, Fisch, Fleisch, Getreide, Holz,
-- Honig, Kräuter, Milch, Stein, Wolle.
--
-- <p><b>Alias</b>: CreateRandomResourceChest</p>
--
-- @param[type=string] _Name Name der zu ersetzenden Script Entity
-- @within Anwenderfunktionen
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
-- Erstellt eine Schatztruhe mit einer zufälligen Art und Menge
-- an Luxusgütern.
--
-- Luxusgüter können seien: Edelsteine, Farben, Musikinstrumente
-- Salz oder Weihrauch.
--
-- <p><b>Alias</b>: CreateRandomLuxuryChest</p>
--
-- @param[type=string] _Name Name der zu ersetzenden Script Entity
-- @within Anwenderfunktionen
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
function API.CreateTrebuchetConstructionSite(_Name, _GoldCost, _WoodCost)
    if GUI then
        API.Bridge("API.CreateTrebuchetConstructionSite('" .._Name.. "', " .._GoldCost.. ", " .._WoodCost.. ")");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:CreateTrebuchetConstructionSite(_Name, _GoldCost, _WoodCost);
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
function API.DestroyTrebuchetConstructionSite(_Name)
    if GUI then
        API.Bridge("API.DestroyTrebuchetConstructionSite('" .._Name.. "')");
        return;
    end
    AddOnInteractiveObjectTemplates.Global:DestroyTrebuchetConstructionSite(_Name);
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
function API.GetTrebuchetByTrebuchetConstructionSite(_Name)
    if GUI then
        API.Fatal("API.GetTrebuchetByTrebuchetConstructionSite: Can only be used in global script!");
        return;
    end
    if not self.Data.Trebuchet.Sites[_Name] then
        API.Warn("API.GetTrebuchetByTrebuchetConstructionSite: Site '" ..tostring(_Name).. "' does not exist!");
        return 0;
    end
    return self.Data.Trebuchet.Sites[_Name].ConstructedTrebuchet;
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
function API.GetReturningCartByTrebuchetConstructionSite(_Name)
    if GUI then
        API.Fatal("API.GetReturningCartByTrebuchetConstructionSite: Can only be used in global script!");
        return;
    end
    if not self.Data.Trebuchet.Sites[_Name] then
        API.Warn("API.GetReturningCartByTrebuchetConstructionSite: Site '" ..tostring(_Name).. "' does not exist!");
        return 0;
    end
    return self.Data.Trebuchet.Sites[_Name].ReturningCart;
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
function API.GetConstructionCartByTrebuchetConstructionSite(_Name)
    if GUI then
        API.Fatal("API.GetConstructionCartByTrebuchetConstructionSite: Can only be used in global script!");
        return;
    end
    if not self.Data.Trebuchet.Sites[_Name] then
        API.Warn("API.GetConstructionCartByTrebuchetConstructionSite: Site '" ..tostring(_Name).. "' does not exist!");
        return 0;
    end
    return self.Data.Trebuchet.Sites[_Name].ConstructionCart;
end
GetConstructionCart = API.GetConstructionCartByTrebuchetConstructionSite;

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
                        de = "Beauftragt den Bau eines Gebäudes. Ein Siedler wird aus"..
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
                    Unfulfilled = {
                        de = "Die Mine kann nicht umgewandelt werden!",
                        en = "The mine can not be transformed!",
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
                    de = "Euer Ritter benötigt einen höheren Titel!",
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
-- @within Internal
-- @local
--
function AddOnInteractiveObjectTemplates.Global:Install()
end

---
-- Initialisiert die interaktiven Trebuchet-Baustellen.
-- @within Internal
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
-- @within Internal
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
-- @within Internal
-- @local
--
function AddOnInteractiveObjectTemplates.Global:TrebuchetSetNeededKnightTitle(_KnightTitle)
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
-- @param _Name [string] Skriptname Position
-- @within Internal
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
-- @within Internal
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
-- @within Internal
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
-- @within Internal
-- @local
--
function AddOnInteractiveObjectTemplates.Global.OnTrebuchetDisambled(_EntityID, _PlayerID, _x, _y, _z)
    AddOnInteractiveObjectTemplates.Global:ReturnTrebuchetToStorehouse(_PlayerID, _EntityID);
end

---
-- Steuert die Trebuchet-Mechanik.
-- @within Internal
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
                API.InteractiveObjectActivate(k);
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

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge an Waren
-- des angegebenen Typs.
-- @param _Name [string] Name der zu ersetzenden Script Entity
-- @param _Good [number] Warentyp
-- @param _Min [number] Mindestmenge
-- @param _Max [number] Maximalmenge
-- @param _Callback [function] Callback-Funktion
-- @within Internal
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
-- @param _Name [string] Name der zu ersetzenden Script Entity
-- @within Internal
-- @local
--
function AddOnInteractiveObjectTemplates.Global:CreateRandomGoldChest(_Name)
    AddOnInteractiveObjectTemplates.Global:CreateRandomChest(_Name, Goods.G_Gold, 300, 600);
end

---
-- Erstellt eine Schatztruhe mit einer zufälligen Art und Menge
-- an Gütern.
-- Güter können seien: Eisen, Fisch, Fleisch, Getreide, Holz,
-- Honig, Kräuter, Milch, Stein, Wolle.
--
-- @param _Name [string] Name der zu ersetzenden Script Entity
-- @within Internal
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
-- Erstellt eine Schatztruhe mit einer zufälligen Art und Menge
-- an Luxusgütern.
-- Luxusgüter können seien: Edelsteine, Farben, Musikinstrumente
-- Salz oder Weihrauch.
--
-- @param _Name [string] Name der zu ersetzenden Script Entity
-- @within Internal
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
-- @param _Position [string] Script Entity, die mit Mine ersetzt wird
-- @param _Type [number] Typ der Mine
-- @param _Costs [table] (optional) Kostentabelle
-- @param _NotRefillable [boolean] (optional) Die Mine wird weiterhin überwacht
-- @param _Condition [function] (optional) Bedingungsfunktion
-- @param _CreationCallback (optional) Funktion nach Kauf ausführen
-- @param _CallbackDepleted (optional) Funktion nach Ausbeutung ausführen
-- @within Internal
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
        ConditionUnfulfilled = self.Data.Mines.Description.Unfulfilled,
        CallbackCreate       = _CreationCallback,
        CallbackDepleted     = _CallbackDepleted,
        Callback             = self.ActionBuildIOMine,
    };
end

---
-- Erstelle eine verschüttete Eisenmine.
--
-- @param _Position [string] Script Entity, die mit Mine ersetzt wird
-- @param _Cost1Type [number] (optional) Kostenware 1
-- @param _Cost1Amount [number] (optional) Kostenmenge 1
-- @param _Cost2Type [number] (optional) Kostenware 2
-- @param _Cost2Amount [number] (optional) Kostenmenge 2
-- @param _NotRefillable [boolean] (optional) Mine wird nach Ausbeutung zerstört
-- @within Internal
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
-- Erstelle eine verschüttete Steinmine.
--
-- @param _Position [string] Script Entity, die mit Mine ersetzt wird
-- @param _Cost1Type [number] (optional) Kostenware 1
-- @param _Cost1Amount [number] (optional) Kostenmenge 1
-- @param _Cost2Type [number] (optional) Kostenware 2
-- @param _Cost2Amount [number] (optional) Kostenmenge 2
-- @param _NotRefillable [boolean] (optional) Mine wird nach Ausbeutung zerstört
-- @within Internal
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
-- @within Internal
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
-- @within Internal
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
-- @within Internal
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
-- @within Internal
-- @local
--
function AddOnInteractiveObjectTemplates.Global.OnConstructionComplete(_PlayerID, _EntityID)
    local IO = AddOnInteractiveObjectTemplates.Global.Data.ConstructionSite.Sites[_EntityID];
    if IO ~= nil and IO.CompletedCallback then
        IO.CompletedCallback(IO, _EntityID);
    end
end

---
-- Erzeugt eine echte Baustelle an der Position. Ein Siedler wird das Gebäude
-- aufbauen.
--
-- @param _Position [string] Zielpunkt
-- @param _PlayerID Besitzer des Gebäudes
-- @param _Type [number] Typ des Gebäudes
-- @param _Costs [table] (optional) Eigene Gebäudekosten
-- @param _Distance [number] (optional) Aktivierungsentfernung
-- @param _Icon [table] (optional) Icon des Schalters
-- @param _Title [string] (optional) Titel der Beschreibung
-- @param _Text [string] (optional) Text der Beschreibung
-- @param _Callback [function] (optional) Funktion nach fertigstellung
-- @within Internal
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
        Callback             = AddOnInteractiveObjectTemplates.Global.CallbackIOConstructionSite;
    };
end

---
-- Lässt einen Siedler die Baustelle zum Gebäude aufbauen.
-- @param _Data Daten des Objekt
-- @within Internal
-- @local
--
function AddOnInteractiveObjectTemplates.Global.CallbackIOConstructionSite(_Data)
    local pos  = GetPosition(_Data.Name);
    local eID  = GetID(_Data.Name);
    local ori  = Logic.GetEntityOrientation(eID);
    local site = Logic.CreateConstructionSite(pos.X, pos.Y, ori, _Data.Type, _Data.PlayerID);
    Logic.SetVisible(eID, false);
    if (site == nil) then
        API.Fatal('AddOnInteractiveObjectTemplates.Global:CreateIOBuildingSite: Failed to place construction site!');
        return;
    end
    AddOnInteractiveObjectTemplates.Global.Data.ConstructionSite.Sites[site] = _Data;
    StartSimpleJobEx(AddOnInteractiveObjectTemplates.Global.ControlConstructionSite, site);
end

---
-- Prüft ob das Gebäude theoretisch gebaut werden kann.
-- @param _Data Daten des Objekt
-- @return boolean: Kann aktiviert werden
-- @within Internal
-- @local
--
function AddOnInteractiveObjectTemplates.Global.ConditionConstructionSite(_Data)
    local eID = GetID(_Data.Name);
    local tID = GetTerritoryUnderEntity(eID);
    local pID = Logic.GetTerritoryPlayerID(tID);

    if Logic.GetStoreHouse(_Data.PlayerID) == 0 then
        return false;
    end
    if _Data.PlayerID ~= pID then
        return false;
    end
    return true;
end

---
-- Überwacht eine Gebäudebaustelle und reaktiviert sie falls nötig.
-- @param _eID EntityID des Gebäudes
-- @return boolean: Job beenden
-- @within Internal
-- @local
--
function AddOnInteractiveObjectTemplates.Global.ControlConstructionSite(_eID)
    if AddOnInteractiveObjectTemplates.Global.Data.ConstructionSite.Sites[_eID] == nil then
        return true;
    end
    if not IsExisting(_eID) then
        local Name = AddOnInteractiveObjectTemplates.Global.Data.ConstructionSite.Sites[_eID].Name;
        Logic.SetVisible(GetID(Name), true);
        API.InteractiveObjectActivate(Name);
        return true;
    end
end

-- Local -----------------------------------------------------------------------

---
-- Initalisiert das AddOn.
-- @within Internal
-- @local
--
function AddOnInteractiveObjectTemplates.Local:Install()
end

Core:RegisterAddOn("AddOnInteractiveObjectTemplates");

