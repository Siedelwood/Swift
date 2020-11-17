LoadOrder = {
    {
        -- Basisbibliothek
        -- Ausschließlich Features, die essentiell sind.
        {"BundleBriefingSystem",                true},
        {"BundleClassicBehaviors",              true},
        {"BundleQuestGeneration",               true},

        -- NEP Feature Emulation
        -- Funktionen, die das NEP nachbilden.
        {"BundleConstructionControl",           true},
        {"BundleDestructionControl",            true},
        {"BundleEntitySelection",               true},
        {"BundleKnightTitleRequirements",       true},

        -- Erweiterte Bibliothek
        -- Zusätzliche Funktionalität und weitere Behavior.
        {"BundleCamera",                        true},
        {"BundleCheats",                        true},
        {"BundleDialogWindows",                 true},
        {"BundleEntityCommandFunctions",        true},
        {"BundleEntityHelperFunctions",         true},
        {"BundleInterfaceFeatureVisibility",    true},
        {"BundleMinimapMarker",                 true},
        {"BundleStockbreeding",                 true},
        {"BundleSymfoniaBehaviors",             true},
        {"BundleTimeLine",                      true},
        {"BundleTravelingSalesman",             true},

        -- Fortgeschrittene Bibliothek
        -- Neue Funktionen für fortgeschrittene Anwender.
        {"BundleBuildingButtons",               true},
        {"BundleEntityProperties",              true},
        {"BundleFollowKnight",                  true},
        {"BundleSpeedLimit",                    true},
        {"BundleInteractiveObjects",            true},
        {"BundleInterfaceApperance",            true},
        {"BundlePlayerHelperFunctions",         true},
        {"BundleSoundOptions",                  true},
        {"BundleNonPlayerCharacter",            true},
        {"BundleSaveGameTools",                 true},
        {"BundleTerrainAndWater",               true},
        {"BundleWeatherManipulation",           true},
    },

    {
        -- Basisbibliothek
        -- Ausschließlich Features, die essentiell sind.
        {
        "AddOnQuestDebug",                      true,
        "BundleQuestGeneration",
        },

        -- Sonstige AddOns
        -- "Nice To have"-Features, die nicht so wichtig sind.
        {
        "AddOnCastleStore",                     true,
        "BundleInteractiveObjects",
        },

        {
        "AddonCutsceneSystem",                  true,
        "BundleBriefingSystem",
        },

        {
        "AddOnInteractiveChests",               true,
        "BundleInteractiveObjects",
        },

        {
        "AddOnInteractiveMines",                true,
        "BundleInteractiveObjects",
        },

        {
        "AddOnInteractiveSites",                true,
        "BundleInteractiveObjects",
        },

        {
        "AddOnInteractiveTrebuchets",           true,
        "BundleInteractiveObjects",
        "BundleEntitySelection",
        },

        {
        "AddOnRandomRequests",                  true,
        "BundleClassicBehaviors",
        "BundleEntityHelperFunctions",
        "BundleInteractiveObjects",
        "BundlePlayerHelperFunctions",
        "BundleSymfoniaBehaviors",
        },

        {
        "AddOnQuestStages",                     true,
        "AddOnQuestDebug",
        "BundleQuestGeneration",
        },

        {
        "AddOnLanguageSelection",               true,
        "BundleDialogWindows",
        },

        {
        "AddOnGraphVizIntegration",             true,
        "AddOnQuestDebug",
        },
    }
};