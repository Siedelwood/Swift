-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnInteractiveSites                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es den Spieler auf einem beliebigen Territorium einer Partei
-- ein Gebäude bauen zu lassen.
-- 
-- Die Baustelle muss durch den Helden aktiviert
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
-- Mögliche Angaben für die Konfiguration:
-- <table border="1">
-- <tr><td><b>Feldname</b></td><td><b>Beschreibung</b></td></tr>
-- <tr><td>Position</td><td>Position für die Baustelle</td></tr>
-- <tr><td>PlayerID</td><td>Besitzer des Gebäudes</td></tr>
-- <tr><td>Type</td><td>Typ des Gebäudes</td></tr>
-- <tr><td>Costs</td><td>(optional) Eigene Gebäudekosten</td></tr>
-- <tr><td>Distance</td><td>(optional) Aktivierungsentfernung</td></tr>
-- reaktivieren</td></tr>
-- <tr><td>Icon</td><td>(optional) Icon des Schalters</td></tr>
-- <tr><td>Title</td><td>(optional) Titel der Beschreibung</td></tr>
-- <tr><td>Text</td><td>(optional) Text der Beschreibung</td></tr>
-- <tr><td>Callback</td><td>(optional) Funktion nach Fertigstellung</td></tr>
-- <tr><td>PlacementFailedHandler</td><td>(optional) Fehlerbenahdlungsfunktion bei
-- nicht platzierter Baustelle. Muss Gebäude ID zurückgeben</td></tr>
-- </table>
--
-- <p><b>Alias</b>: CreateIOBuildingSite</p>
--
-- @param[type=table] _Data Konfiguration des Objektes
-- @within Anwenderfunktionen
--
-- @usage
-- -- Erzeugt eine Baustelle ohne besondere Einstellungen
-- API.CreateIOBuildingSite {
--     Position = "haus",
--     PlayerID = 1,
--     Type     = Entities.B_Bakery
-- };
--
-- -- Baustelle mit Kosten und Aktivierungsdistanz
-- API.CreateIOBuildingSite {
--     Position = "haus",
--     PlayerID = 1,
--     Type     = Entities.B_Bakery,
--     Costs    = {Goods.G_Wood, 4},
--     Distance = 1000
-- };
--
-- -- Baustelle mit Callback und Error Handler
-- API.CreateIOBuildingSite {
--     Position               = "haus",
--     PlayerID               = 1,
--     Type                   = Entities.B_Bakery,
--     Callback               = function(_IO, _PlayerID, _Data)
--         -- Rufe etwas auf, das im Anschluss passieren soll.
--         OnSuccess();
--     end,
--     PlacementFailedHandler = function(_IO, _PlayerID, _Data)
--         -- Rufe etwas auf, das passieren soll, wenn die Baustelle nicht erzeugt wurde.
--         -- Bedenke: Der Error Handler muss dafür sorgen, dass ein Gebäude oder eine Baustelle entsteht.
--         return OnFailure();
--     end,
-- };
--
function API.CreateIOBuildingSite(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Position) then
        error("API.CreateIOBuildingSite: Position (" ..tostring(_Data.Position).. ") does not exist!");
        return;
    end
    if type(_Data.PlayerID) ~= "number" or _Data.PlayerID < 1 or _Data.PlayerID > 8 then
        error("API.CreateIOBuildingSite: PlayerID is wrong!");
        return;
    end
    if GetNameOfKeyInTable(Entities, _Data.Type) == nil then
        error("API.CreateIOBuildingSite: Type (" ..tostring(_Data.Type).. ") is wrong!");
        return;
    end
    if _Data.Costs and (type(_Data.Costs) ~= "table" or #_Data.Costs %2 ~= 0) then
        error("API.CreateIOBuildingSite: Costs has the wrong format!");
        return;
    end
    if _Data.Distance and (type(_Data.Distance) ~= "number" or _Data.Distance < 100) then
        error("API.CreateIOBuildingSite: Distance (" ..tostring(_Data.Distance).. ") is wrong or too small!");
        return;
    end
    if _Data.Callback and type(_Data.Callback) ~= "function" then
        error("API.CreateIOBuildingSite: Callback must be a function!");
        return;
    end
    if _Data.PlacementFailedHandler and type(_Data.PlacementFailedHandler) ~= "function" then
        error("API.CreateIOBuildingSite: PlacementFailedHandler must be a function!");
        return;
    end
    AddOnInteractiveSites.Global:CreateIOBuildingSite(_Data);
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
                    },
                    Text = {
                        de = "Beauftragt den Bau eines Gebäudes. Ein Siedler wird aus"..
                             " dem Lagerhaus kommen und mit dem Bau beginnen.",
                        en = "Order a building. A worker will come out of the"..
                             " storehouse and erect it.",
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

function AddOnInteractiveSites.Global:Install()
    Core:AppendFunction(
        "GameCallback_OnBuildingConstructionComplete",
        self.OnConstructionComplete
    );
end

function AddOnInteractiveSites.Global.OnConstructionComplete(_PlayerID, _EntityID)
    local IO = AddOnInteractiveSites.Global.Data.ConstructionSite.Sites[_EntityID];
    if IO ~= nil and IO.CompletedCallback then
        IO.CompletedCallback(IO, _EntityID);
    end
end

function AddOnInteractiveSites.Global:CreateIOBuildingSite(_Data)
    local Costs = _Data.Costs or {Logic.GetEntityTypeFullCost(_Data.Type)};
    local Title = _Data.Title or self.Data.ConstructionSite.Description.Title;
    local Text  = _Data.Text or self.Data.ConstructionSite.Description.Text;
    local eID = GetID(_Data.Position);
    Logic.SetModel(eID, Models.Buildings_B_BuildingPlot_10x10);
    Logic.SetVisible(eID, true);

    CreateObject {
        Name                    = _Data.Position,
        Title                   = Title,
        Text                    = Text,
        Texture                 = _Data.Icon or {14, 10},
        Distance                = _Data.Distance or 1500,
        Type                    = _Data.Type,
        Costs                   = Costs,
        PlayerID                = _Data.PlayerID,
        PlacementFailedHandler  = _Data.PlacementFailedHandler,
        NoReactivate            = true, -- TODO: Reaktivierung funktioniert nicht
        Condition               = function(_IO, _PlayerID, _Data)
            return AddOnInteractiveSites.Global:ConditionConstructionSite(_IO, _PlayerID, _Data);
        end,
        Callback                = function(_IO, _PlayerID, _Data)
            return AddOnInteractiveSites.Global:CallbackIOConstructionSite(_IO, _PlayerID, _Data);
        end,
        CompletedCallback       = _Data.Callback,
    };
end

function AddOnInteractiveSites.Global:CallbackIOConstructionSite(_IO, _PlayerID, _Data)
    local pos  = GetPosition(_Data.Name);
    local eID  = GetID(_Data.Name);
    local ori  = Logic.GetEntityOrientation(eID);
    local site = Logic.CreateConstructionSite(pos.X, pos.Y, ori, _Data.Type, _Data.PlayerID);
    Logic.SetVisible(eID, false);
    if (site == nil) then
        if _Data.PlacementFailedHandler then
            log("AddOnInteractiveSites.Global:CreateIOBuildingSite: Calling handler for failed placement!", LEVEL_WARNING);
            site = _Data.PlacementFailedHandler(_IO, _PlayerID, _Data);
            if site == nil or not IsExisting(site) then
                error("AddOnInteractiveSites.Global:CreateIOBuildingSite: Error handler failed!");
                return;
            end
        else
            log("AddOnInteractiveSites.Global:CreateIOBuildingSite: Creating building instead!", LEVEL_WARNING);
            site = Logic.CreateEntity(_Data.Type, pos.X, pos.Y, ori, _Data.PlayerID);
        end
    end
    self.Data.ConstructionSite.Sites[site] = _Data;
    if not _Data.NoReactivate then
        StartSimpleJobEx(function(_ID)
            self:ControlConstructionSite(_ID)
        end, site);
    end
end

function AddOnInteractiveSites.Global:ConditionConstructionSite(_IO, _PlayerID, _Data)
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

function AddOnInteractiveSites.Global:ControlConstructionSite(_eID)
    if self.Data.ConstructionSite.Sites[_eID] == nil then
        return true;
    end
    if not IsExisting(_eID) then
        local Data = API.InstanceTable(self.Data.ConstructionSite.Sites[_eID]);
        self:CreateIOBuildingSite(Data);
        return true;
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterAddOn("AddOnInteractiveSites");

