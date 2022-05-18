

MuiltiplayerConfig = {
    -- Absolute limit for building type
    Buildings = {
        ["B_Barracks"] = {
            Limit = 3,
        },
        ["B_BarracksArchers"] = {
            Limit = 3,
        },
        ["B_SiegeEngineWorkshop"] = {
            Limit = 3,
        },
    },

    -- Limit of crops per farm building
    Crops = {
        Beehive = {
            Limit = 8,
            Area  = 2000,
        },
        Grainfield = {
            Limit = 4,
            Area  = 2000,
        }
    },

    -- Unit Data (human players)
    Units = {
        Ballista = {
            Costs = {Goods.G_Gold, 150, Goods.G_SiegeEnginePart, 5},
            Limit = 5,
        },
        Thief = {
            Limit = { 3,  6,  9, 12},
        },

        Damage = {
            ["U_MilitarySword"]            = 1.00,
            ["U_MilitaryBow"]              = 0.80,
            -- make mercenaries great again
            ["U_MilitaryBandit_Melee_AS"]  = 1.20,
            ["U_MilitaryBandit_Melee_ME"]  = 1.20,
            ["U_MilitaryBandit_Melee_NA"]  = 1.20,
            ["U_MilitaryBandit_Melee_NE"]  = 1.20,
            ["U_MilitaryBandit_Melee_SE"]  = 1.20,
            ["U_MilitaryBandit_Ranged_AS"] = 1.00,
            ["U_MilitaryBandit_Ranged_ME"] = 1.00,
            ["U_MilitaryBandit_Ranged_NA"] = 1.00,
            ["U_MilitaryBandit_Ranged_NE"] = 1.00,
            ["U_MilitaryBandit_Ranged_SE"] = 1.00,
        },
    },
}

