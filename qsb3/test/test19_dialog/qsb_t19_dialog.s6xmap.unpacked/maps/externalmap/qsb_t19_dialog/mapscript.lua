Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/development.lua");

function Mission_FirstMapAction()
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/questsystembehavior.lua");
    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end
    Mission_OnQsbLoaded();
end

function Mission_InitPlayers()
end

function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

function Mission_InitMerchants()
end

function Mission_LoadFiles()
    if gvMission.MapIsInDevelopmentMode then
        local Path = gvMission.ContentPath;
        Path = "E:/Repositories/swift/qsb3/test/test19_dialog/qsb_t19_dialog.s6xmap.unpacked/" ..Path;
        gvMission.ContentPath = Path;
    end
    return {
        gvMission.ContentPath.. "dialogscript.lua"
    }
end

function Mission_OnQsbLoaded()
    API.ActivateDebugMode(true, false, true, true);
    API.SetPlayerPortrait(1);
    API.SetPlayerPortrait(8, "H_NPC_Monk_ME");
    StartBriefingCutsceneDialogDemo();
end