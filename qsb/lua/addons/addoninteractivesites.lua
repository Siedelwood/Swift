-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnInteractiveSites                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es den Spieler auf einem beliebigen Territorium einer Partei
-- ein Gebäude bauen zu lassen.
-- <br>Die Baustelle muss durch den Helden aktiviert
-- werden. Ein Siedler wird aus dem Lagerhaus kommen und das Gebäude bauen.
-- 
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnInteractiveSites = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

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
-- @param[type=string]   _Position Zielpunkt
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
    AddOnInteractiveSites.Global:CreateIOBuildingSite(_Position, _PlayerID, _Type, _Costs, _Distance, _Icon, _Title, _Text, _Callback);
end
CreateIOBuildingSite = API.CreateIOBuildingSite;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnInteractiveSites = {
    Global = {
        Data = {
            ConstructionSite = {
                Sites = {},

                Description = {
                    Title = {
                        de = "Gebäude bauen",
                        en = "Create building",
                        fr = "Construire des bâtiments",
                    },
                    Text = {
                        de = "Beauftragt den Bau eines Gebäudes. Ein Siedler wird aus"..
                             " dem Lagerhaus kommen und mit dem Bau beginnen.",
                        en = "Order a building. A worker will come out of the"..
                             " storehouse and erect it.",
                        fr = "Commandé la construction d'un bâtiment. Un colon"..
                             " va sortir de l'entrepôt et commencer à construire."
                    },
                    Unfulfilled = {
                        de = "Das Gebäude kann derzeit nicht gebaut werden.",
                        en = "The building can not be built at the moment.",
                        fr = "Le bâtiment ne peut pas être construit pour le moment."
                    },
                }
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
function AddOnInteractiveSites.Global:Install()
end

---
-- Ruft das Callback einer Baustelle auf, sofern eins definiert wurde.
-- @param _PlayerID Besitzer des Gebäudes
-- @param _EntityID Entity-ID des Gebäudes
-- @within Internal
-- @local
--
function AddOnInteractiveSites.Global.OnConstructionComplete(_PlayerID, _EntityID)
    local IO = AddOnInteractiveSites.Global.Data.ConstructionSite.Sites[_EntityID];
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
function AddOnInteractiveSites.Global:CreateIOBuildingSite(_Position, _PlayerID, _Type, _Costs, _Distance, _Icon, _Title, _Text, _Callback)
    AddOnInteractiveSites.Global:ConstructionSiteActivate();
    local Costs = _Costs or {Logic.GetEntityTypeFullCost(_Type)};
    local Title = _Title or self.Data.ConstructionSite.Description.Title;
    local Text  = _Text or self.Data.ConstructionSite.Description.Text;
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
        Condition            = AddOnInteractiveSites.Global.ConditionConstructionSite,
        ConditionUnfulfilled = AddOnInteractiveSites.Global.Data.ConstructionSite.Description.Unfulfilled,
        PlayerID             = _PlayerID,
        CompletedCallback    = _Callback,
        Callback             = AddOnInteractiveSites.Global.CallbackIOConstructionSite;
    };
end

---
-- Lässt einen Siedler die Baustelle zum Gebäude aufbauen.
-- @param _Data Daten des Objekt
-- @within Internal
-- @local
--
function AddOnInteractiveSites.Global.CallbackIOConstructionSite(_Data)
    local pos  = GetPosition(_Data.Name);
    local eID  = GetID(_Data.Name);
    local ori  = Logic.GetEntityOrientation(eID);
    local site = Logic.CreateConstructionSite(pos.X, pos.Y, ori, _Data.Type, _Data.PlayerID);
    Logic.SetVisible(eID, false);
    if (site == nil) then
        API.Fatal('AddOnInteractiveSites.Global:CreateIOBuildingSite: Failed to place construction site!');
        return;
    end
    AddOnInteractiveSites.Global.Data.ConstructionSite.Sites[site] = _Data;
    StartSimpleJobEx(AddOnInteractiveSites.Global.ControlConstructionSite, site);
end

---
-- Prüft ob das Gebäude theoretisch gebaut werden kann.
-- @param _Data Daten des Objekt
-- @return boolean: Kann aktiviert werden
-- @within Internal
-- @local
--
function AddOnInteractiveSites.Global.ConditionConstructionSite(_Data)
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
function AddOnInteractiveSites.Global.ControlConstructionSite(_eID)
    if AddOnInteractiveSites.Global.Data.ConstructionSite.Sites[_eID] == nil then
        return true;
    end
    if not IsExisting(_eID) then
        local Name = AddOnInteractiveSites.Global.Data.ConstructionSite.Sites[_eID].Name;
        Logic.SetVisible(GetID(Name), true);
        API.InteractiveObjectActivate(Name);
        return true;
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterAddOn("AddOnInteractiveSites");

