--[[
Swift_0_Core/Selfload

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

if not MapEditor and not GUI then
    local MapTypeFolder = "externalmap";
    local MapType, Campaign = Framework.GetCurrentMapTypeAndCampaignName();
    if MapType ~= 3 then
        MapTypeFolder = "development";
    end

    gvMission = gvMission or {};
    gvMission.ContentPath      = "maps/" ..MapTypeFolder.. "/" ..Framework.GetCurrentMapName() .. "/";
    gvMission.MusicRootPath    = "music/";
    gvMission.PlaylistRootPath = "config/sound/";

    Logic.ExecuteInLuaLocalState([[
        gvMission = gvMission or {};
        gvMission.GlobalVariables = Logic.CreateReferenceToTableInGlobaLuaState("gvMission");
        gvMission.ContentPath      = "maps/]] ..MapTypeFolder.. [[/" ..Framework.GetCurrentMapName() .. "/";
        gvMission.MusicRootPath    = "music/";
        gvMission.PlaylistRootPath = "config/sound/";

        Script.Load(gvMission.ContentPath.. "questsystembehavior.lua");
        API.Install();
        if ModuleKnightTitleRequirements then
            InitKnightTitleTables();
        end
        if Mission_LocalOnQsbLoaded and not Framework.IsNetworkGame() then
            Mission_LocalOnQsbLoaded();
        end
        if Mission_MP_LocalOnQSBLoaded and Framework.IsNetworkGame() then
            Mission_MP_LocalOnQSBLoaded();
        end
        StartSimpleJobEx(function()
            Swift:DispatchScriptCommand(QSB.ScriptCommands.GlobalQsbLoaded);
            return true;
        end);
    ]]);
    
    API.Install();
    if ModuleKnightTitleRequirements then
        InitKnightTitleTables();
    end
end

