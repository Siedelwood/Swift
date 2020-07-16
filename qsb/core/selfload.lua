-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia Selfload                                                     # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

if not MapEditor and not GUI then
    local MapTypeFolder = "externalmap";
    local MapType, Campaign = Framework.GetCurrentMapTypeAndCampaignName();
    if MapType ~= 3 then
        MapTypeFolder = "development";
    end

    gvMission = {
        ContentPath = "maps/" ..MapTypeFolder.. "/" ..Framework.GetCurrentMapName() .. "/"
    };

    if Mission_LoadFiles then
        local Files = Mission_LoadFiles();
        if Files then
            for i= 1, #Files, 1 do
                Script.Load(Files[i]);
            end
        end
    end
    API.Install();
    if BundleKnightTitleRequirements then
        InitKnightTitleTables();
    end

    Logic.ExecuteInLuaLocalState([[
        gvMission = {
            GlobalVariables = Logic.CreateReferenceToTableInGlobaLuaState("gvMission"),
            ContentPath = "maps/]] ..MapTypeFolder.. [[/" ..Framework.GetCurrentMapName() .. "/",
        };

        Script.Load(gvMission.ContentPath.. "questsystembehavior.lua");
        if Mission_LoadFiles then
            local Files = Mission_LoadFiles();
            if Files then
                for i= 1, #Files, 1 do
                    Script.Load(Files[i]);
                end
            end
        end
        API.Install();
        if BundleKnightTitleRequirements then
            InitKnightTitleTables();
        end
    ]]);
end

