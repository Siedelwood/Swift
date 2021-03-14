-- -------------------------------------------------------------------------- --
-- Selfload                                                                   --
-- -------------------------------------------------------------------------- --

if not MapEditor and not GUI then
    local MapTypeFolder = "externalmap";
    local MapType, Campaign = Framework.GetCurrentMapTypeAndCampaignName();
    if MapType ~= 3 then
        MapTypeFolder = "development";
    end

    gvMission = gvMission or {};
    gvMission.ContentPath = "maps/" ..MapTypeFolder.. "/" ..Framework.GetCurrentMapName() .. "/";
    API.Install();

    Logic.ExecuteInLuaLocalState([[
        gvMission = gvMission or {};
        gvMission.GlobalVariables = Logic.CreateReferenceToTableInGlobaLuaState("gvMission");
        gvMission.ContentPath = "maps/]] ..MapTypeFolder.. [[/" ..Framework.GetCurrentMapName() .. "/";

        Script.Load(gvMission.ContentPath.. "questsystembehavior.lua");
        API.Install();
        if Mission_LocalOnQsbLoaded then
            Mission_LocalOnQsbLoaded();
        end
    ]]);
end

