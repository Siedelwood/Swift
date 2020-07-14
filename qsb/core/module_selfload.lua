-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia Selfload                                                     # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

if not MapEditor and not GUI then
    g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";
    gvMission = {};

    if Mission_LoadFiles then
        Mission_LoadFiles();
    end
    API.Install();
    if BundleKnightTitleRequirements then
        InitKnightTitleTables();
    end

    Logic.ExecuteInLuaLocalState([[
        if not API then
            g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";
            gvMission = {
                GlobalVariables = Logic.CreateReferenceToTableInGlobaLuaState("gvMission"),
            };
            Script.Load(g_ContentPath.. "questsystembehavior.lua");

            if Mission_LoadFiles then
                Mission_LoadFiles();
            end
            API.Install();
            if BundleKnightTitleRequirements then
                InitKnightTitleTables();
            end
        end
    ]]);
end

