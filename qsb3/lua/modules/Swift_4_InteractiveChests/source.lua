--[[
Swift_2_InteractionCore/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleteractiveChests = {
    Properties = {
        Name = "ModuleteractiveChests",
    },

    Global = {
        Chests = {},
    };
    Local  = {};
    -- This is a shared structure but the values are asynchronous!
    Shared = {};

    Text = {
        Chest = {
            Title = {
                de = "Schatztruhe",
                en = "Treasure Chest",
            },
            Text = {
                de = "Diese Truhe enthält einen geheimen Schatz. Öffnet sie um den Schatz zu bergen.",
                en = "This chest contains a secred treasure. Open it to salvage the treasure.",
            },
        },
        Treasure = {
            Title = {
                de = "Versteckter Schatz",
                en = "Hidden treasure",
            },
            Text = {
                de = "Ihr habt einen geheimen Schatz entdeckt. Beeilt Euch und beansprucht ihn für Euch!",
                en = "You have discovered a secred treasure. Be quick to claim it, before it is to late!",
            },
        }
    }
};

QSB.NonPlayerCharacterObjects = {};

-- Global Script ------------------------------------------------------------ --

function ModuleteractiveChests.Global:CreateRandomChest(_Name, _Good, _Min, _Max, _Callback, _DirectPay, _NoModelChange)
    _Min = math.floor((_Min ~= nil and _Min > 0 and _Min) or 1);
    _Max = math.floor((_Max ~= nil and _Max > 1 and _Max) or 2);
    if not _Callback then
        _Callback = function(t) end
    end
    assert(_Good ~= nil, "CreateRandomChest: Good does not exist!");
    assert(_Min <= _Max, "CreateRandomChest: min amount must be smaller or equal than max amount!");

    -- Debug Informationen schreiben
    debug(string.format(
        "ModuleteractiveChests: Creating chest (%s, %s, %d, %d, %s, %s)",
        _Name,
        Logic.GetGoodTypeName(_Good),
        _Min,
        _Max,
        tostring(_Callback),
        tostring(_NoModelChange)
    ))

    -- Texte und Model setzen
    local Title = ModuleteractiveChests.Text.Treasure.Title;
    local Text  = ModuleteractiveChests.Text.Treasure.Text;
    if not _NoModelChange then
        Title = ModuleteractiveChests.Text.Chest.Title;
        Text  = ModuleteractiveChests.Text.Chest.Text;

        local eID = ReplaceEntity(_Name, Entities.XD_ScriptEntity, 0);
        Logic.SetModel(eID, Models.Doodads_D_X_ChestClose);
        Logic.SetVisible(eID, true);
    end

    -- Menge an Gütern ermitteln
    local GoodAmount = _Min;
    if _Min < _Max then
        GoodAmount = math.random(_Min, _Max);
    end

    -- Rewards
    local ScriptReward;
    local IOReward;
    if not _DirectPay then
        IOReward = {_Good, GoodAmount};
    else
        ScriptReward = {_Good, GoodAmount};
    end

    CreateObject {
        Name                    = _Name,
        Title                   = Title,
        Text                    = Text,
        Reward                  = IOReward,
        ScriptReward            = ScriptReward,
        Texture                 = {1, 6},
        Distance                = (_NoModelChange and 1200) or 650,
        Waittime                = 0,
        State                   = 0,
        DoNotChangeModel        = _NoModelChange == true,
        CallbackOpened          = _Callback,
        Callback                = function(_ScriptName, _EntityID, _PlayerID)
            local IO = IO[_ScriptName];
            if not IO.m_Data.DoNotChangeModel then
                Logic.SetModel(GetID(IO.m_Data.Name), Models.Doodads_D_X_ChestOpenEmpty);
            end
            if IO.m_Data.ScriptReward then
                AddGood(IO.m_Data.ScriptReward[1], IO.m_Data.ScriptReward[2], _PlayerID);
            end
            IO.m_Data.CallbackOpened(IO.m_Data);
        end,
    };
end

function ModuleteractiveChests.Global:CreateRandomGoldChest(_Name)
    self:CreateRandomChest(_Name, Goods.G_Gold, 300, 600, false);
end

function ModuleteractiveChests.Global:CreateRandomResourceChest(_Name)
    local PossibleGoods = {
        Goods.G_Iron, Goods.G_Stone, Goods.G_Wood, Goods.G_Wool,
        Goods.G_Carcass, Goods.G_Herb, Goods.G_Honeycomb,
        Goods.G_Milk, Goods.G_RawFish, Goods.G_Grain
    };
    local Good = PossibleGoods[math.random(1, #PossibleGoods)];
    self:CreateRandomChest(_Name, Good, 30, 60, false);
end

function ModuleteractiveChests.Global:CreateRandomLuxuryChest(_Name)
    local Luxury = {Goods.G_Salt, Goods.G_Dye};
    if g_GameExtraNo >= 1 then
        table.insert(Luxury, Goods.G_Gems);
        table.insert(Luxury, Goods.G_MusicalInstrument);
        table.insert(Luxury, Goods.G_Olibanum);
    end
    local Good = Luxury[math.random(1, #Luxury)];
    self:CreateRandomChest(_Name, Good, 50, 100, false);
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleteractiveChests);

