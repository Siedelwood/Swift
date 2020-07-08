-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnInteractiveChests                                       # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Es werden Schatztruhen mit zufälligem Inhalt erzeugt. Diese Truhen werden
-- aktiviert und der Inhalt wird in einem Karren abtransportiert.
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
        return;
    end
    if not IsExisting(_Name) then
        error("API.CreateRandomChest: _Name (" ..tostring(_Name).. ") does not exist!");
        return;
    end
    if GetNameOfKeyInTable(Goods, _Good) == nil then
        error("API.CreateRandomChest: _Good (" ..tostring(_Good).. ") is wrong!");
        return;
    end
    if type(_Min) ~= "number" or _Min < 1 then
        error("API.CreateRandomChest: _Min (" ..tostring(_Min).. ") is wrong!");
        return;
    end
    if type(_Max) ~= "number" or _Max < 1 then
        error("API.CreateRandomChest: _Max (" ..tostring(_Max).. ") is wrong!");
        return;
    end
    if _Max < _Min then
        error("API.CreateRandomChest: _Max (" ..tostring(_Max).. ") must be greather then _Min (" ..tostring(_Min).. ")!");
        return;
    end
    AddOnInteractiveChests.Global:CreateRandomChest(_Name, _Good, _Min, _Max, _Callback);
end
CreateRandomChest = API.CreateRandomChest;

---
-- Erstellt ein beliebiges IO mit einer zufälligen Menge an Waren
-- des angegebenen Typs.
--
-- Die Menge der Ware ist dabei zufällig und liegt zwischen dem Minimalwert
-- und dem Maximalwert. Optional kann eine Funktion angegeben werden, die
-- ausgeführt wird, wenn der Schatz gefunden wird. Diese Funktion verhält sich
-- wie das Callback eines interaktiven Objektes.
--
-- <p><b>Alias</b>: CreateRandomTreasure</p>
--
-- @param[type=string]   _Name Name des Script Entity
-- @param[type=number]   _Good Warentyp
-- @param[type=number]   _Min Mindestmenge
-- @param[type=number]   _Max Maximalmenge
-- @param[type=function] _Callback Callback-Funktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.CreateRandomTreasure("well1", Goods.G_Gems, 100, 300, OnTreasureDiscovered)
--
function API.CreateRandomTreasure(_Name, _Good, _Min, _Max, _Callback)
    if GUI then
        return;
    end
    if not IsExisting(_Name) then
        error("API.CreateRandomTreasure: _Name (" ..tostring(_Name).. ") does not exist!");
        return;
    end
    if GetNameOfKeyInTable(Goods, _Good) == nil then
        error("API.CreateRandomTreasure: _Good (" ..tostring(_Good).. ") is wrong!");
        return;
    end
    if type(_Min) ~= "number" or _Min < 1 then
        error("API.CreateRandomTreasure: _Min (" ..tostring(_Min).. ") is wrong!");
        return;
    end
    if type(_Max) ~= "number" or _Max < 1 then
        error("API.CreateRandomTreasure: _Max (" ..tostring(_Max).. ") is wrong!");
        return;
    end
    if _Max < _Min then
        error("API.CreateRandomTreasure: _Max (" ..tostring(_Max).. ") must be greather then _Min (" ..tostring(_Min).. ")!");
        return;
    end
    AddOnInteractiveChests.Global:CreateRandomChest(_Name, _Good, _Min, _Max, _Callback, true);
end
CreateRandomTreasure = API.CreateRandomTreasure;

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge Gold.
--
-- <p><b>Alias</b>: CreateRandomGoldChest</p>
--
-- @param[type=string] _Name Name der zu ersetzenden Script Entity
-- @within Anwenderfunktionen
--
-- @usage
-- API.CreateRandomGoldChest("chest")
--
function API.CreateRandomGoldChest(_Name)
    if GUI then
        return;
    end
    if not IsExisting(_Name) then
        error("API.CreateRandomGoldChest: _Name (" ..tostring(_Name).. ") does not exist!");
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
-- @usage
-- API.CreateRandomResourceChest("chest")
--
function API.CreateRandomResourceChest(_Name)
    if GUI then
        return;
    end
    if not IsExisting(_Name) then
        error("API.CreateRandomResourceChest: _Name (" ..tostring(_Name).. ") does not exist!");
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
-- @usage
-- API.CreateRandomLuxuryChest("chest")
--
function API.CreateRandomLuxuryChest(_Name)
    if GUI then
        return;
    end
    if not IsExisting(_Name) then
        error("API.CreateRandomLuxuryChest: _Name (" ..tostring(_Name).. ") does not exist!");
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
            Chests = {},
        }
    },

    Text = {
        Chest = {
            Title = {
                de = "Schatztruhe",
                en = "Treasure Chest",
                fr = "Trésor box",
            },
            Text = {
                de = "Diese Truhe enthält einen geheimen Schatz. Öffnet sie um den Schatz zu bergen.",
                en = "This chest contains a secred treasure. Open it to salvage the treasure.",
                fr = "Ce coffre contient un trésor secret. Ouvrez-les pour récupérer le trésor.",
            },
        },
        Treasure = {
            Title = {
                de = "Versteckter Schatz",
                en = "Hidden treasure",
                fr = "Trésor caché",
            },
            Text = {
                de = "Ihr habt einen geheimen Schatz entdeckt. Beeilt Euch und beansprucht ihn für Euch!",
                en = "You have discovered a secred treasure. Be quick to claim it, before it is to late!",
                fr = "Vous avez découvert un trésor secret. Dépêchez-vous et réclamez-le pour vous!",
            },
        }
    }
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
--
-- Optional kann die automatische Umwandlung in eine Schatztruhe abgeschaltet
-- werden. Vorsichtig mit überbaubaren Entities!
--
-- @param _Name [string] Name der zu ersetzenden Script Entity
-- @param _Good [number] Warentyp
-- @param _Min [number] Mindestmenge
-- @param _Max [number] Maximalmenge
-- @param _Callback [function] Callback-Funktion
-- @param _NoModelChange [boolean] Kein Truhenmodel setzen
-- @within Internal
-- @local
--
function AddOnInteractiveChests.Global:CreateRandomChest(_Name, _Good, _Min, _Max, _Callback, _NoModelChange)
    _Min = math.floor((_Min ~= nil and _Min > 0 and _Min) or 1);
    _Max = math.floor((_Max ~= nil and _Max > 1 and _Max) or 2);
    if not _Callback then
        _Callback = function(t) end
    end
    assert(_Good ~= nil, "CreateRandomChest: Good does not exist!");
    assert(_Min < _Max, "CreateRandomChest: min amount must be smaller than max amount!");

    debug(string.format(
        "AddOnInteractiveChests: Creating chest (%s, %s, %d, %d, %s, %s)",
        _Name,
        Logic.GetGoodTypeName(_Good),
        _Min,
        _Max,
        tostring(_Callback),
        tostring(_NoModelChange)
    ))

    local Title = AddOnInteractiveChests.Text.Treasure.Title;
    local Text  = AddOnInteractiveChests.Text.Treasure.Text;
    if not _NoModelChange then
        Title = AddOnInteractiveChests.Text.Chest.Title;
        Text  = AddOnInteractiveChests.Text.Chest.Text;

        local eID = ReplaceEntity(_Name, Entities.XD_ScriptEntity, 0);
        Logic.SetModel(eID, Models.Doodads_D_X_ChestClose);
        Logic.SetVisible(eID, true);
    end

    CreateObject {
        Name                    = _Name,
        Title                   = Title,
        Text                    = Text,
        Reward                  = {_Good, math.random(_Min, _Max)},
        Texture                 = {1, 6},
        Distance                = 650,
        Waittime                = 0,
        State                   = 0,
        DoNotChangeModel        = _NoModelChange == true,
        CallbackOpened          = _Callback,
        Callback                = function(_IO, _PlayerID, _Data)
            if not _Data.DoNotChangeModel then
                -- Nur Modell ändern!
                -- ReplaceEntity(_Data.Name, Entities.D_X_ChestOpenEmpty);
                Logic.SetModel(GetID(_Data.Name), Models.Doodads_D_X_ChestOpenEmpty);
            end
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

