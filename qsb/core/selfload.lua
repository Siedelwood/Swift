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

    gvMission = gvMission or {};
    gvMission.ContentPath = "maps/" ..MapTypeFolder.. "/" ..Framework.GetCurrentMapName() .. "/";
    gvMission.MusicRootPath = "music/";
    gvMission.PlaylistRootPath = "config/sound/";

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
        gvMission = gvMission or {};
        gvMission.GlobalVariables = Logic.CreateReferenceToTableInGlobaLuaState("gvMission");
        gvMission.ContentPath = "maps/]] ..MapTypeFolder.. [[/" ..Framework.GetCurrentMapName() .. "/";
        gvMission.MusicRootPath = "music/";
        gvMission.PlaylistRootPath = "config/sound/";

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
        if Mission_LocalOnQsbLoaded then
            Mission_LocalOnQsbLoaded();
        end
    ]]);
end

