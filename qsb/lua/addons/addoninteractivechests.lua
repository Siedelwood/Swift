-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnInteractiveChests                                       # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Es werden Schatztruhen mit zufälligem Inhalt erzeugt. Diese Truhen werden
-- aktiviert und der Inhalt wird in einem Karren abtransportiert.
-- <br><a href="#API.CreateRandomChest">Eine Schatztruhe anlegen</a>
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnInteractiveChests = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

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
    AddOnInteractiveChests.Global:CreateRandomChest(_Name, _Good, _Min, _Max, _Callback);
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
    AddOnInteractiveChests.Global:CreateRandomChest(_Name, Goods.G_Gold, 300, 600);
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
    AddOnInteractiveChests.Global:CreateRandomResourceChest(_Name);
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
    AddOnInteractiveChests.Global:CreateRandomLuxuryChest(_Name);
end
CreateRandomLuxuryChest = API.CreateRandomLuxuryChest;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnInteractiveChests = {
    Global = {
        Data = {
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
        }
    },
}

-- Global ----------------------------------------------------------------------

---
-- Initalisiert das AddOn.
-- @within Internal
-- @local
--
function AddOnInteractiveChests.Global:Install()
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
function AddOnInteractiveChests.Global:CreateRandomChest(_Name, _Good, _Min, _Max, _Callback)
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
function AddOnInteractiveChests.Global:CreateRandomGoldChest(_Name)
    AddOnInteractiveChests.Global:CreateRandomChest(_Name, Goods.G_Gold, 300, 600);
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
function AddOnInteractiveChests.Global:CreateRandomResourceChest(_Name)
    local PossibleGoods = {
        Goods.G_Iron, Goods.G_Stone, Goods.G_Wood, Goods.G_Wool,
        Goods.G_Carcass, Goods.G_Herb, Goods.G_Honeycomb,
        Goods.G_Milk, Goods.G_RawFish, Goods.G_Grain
    };
    local Good = PossibleGoods[math.random(1, #PossibleGoods)];
    AddOnInteractiveChests.Global:CreateRandomChest(_Name, Good, 30, 60);
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
function AddOnInteractiveChests.Global:CreateRandomLuxuryChest(_Name)
    local Luxury = {Goods.G_Salt, Goods.G_Dye};
    if g_GameExtraNo >= 1 then
        table.insert(Luxury, Goods.G_Gems);
        table.insert(Luxury, Goods.G_MusicalInstrument);
        table.insert(Luxury, Goods.G_Olibanum);
    end
    local Good = Luxury[math.random(1, #Luxury)];
    AddOnInteractiveChests.Global:CreateRandomChest(_Name, Good, 50, 100);
end

-- -------------------------------------------------------------------------- --

Core:RegisterAddOn("AddOnInteractiveChests");

