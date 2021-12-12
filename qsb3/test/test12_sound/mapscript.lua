-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

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
    return {};
end

function Mission_OnQsbLoaded()
    API.ActivateDebugMode(true, false, true, true);
end

-- -------------------------------------------------------------------------- --

-- > CreateTestNpcs()

function CreateTestNpcs()
    NPC1 = API.NpcCompose {
        Name     = "npc1",
        Callback = function(_Data)
            API.Note("Sound volume has been changed for playing music.");
            AlterSoundVolumeForMusik();
        end
    }

    NPC2 = API.NpcCompose {
        Name     = "npc2",
        Callback = function(_Data)
            API.Note("Sound volume has been restored.");
            RestoreSoundVolume();
        end
    }
end

-- > ResetTestNpcs()

function ResetTestNpcs()
    NPC1.Active = true;
    NPC1.TalkedTo = 0;
    API.NpcUpdate(NPC1);

    NPC2.Active = true;
    NPC2.TalkedTo = 0;
    API.NpcUpdate(NPC2);
end

function AlterSoundVolumeForMusik()
    API.SoundSetVolume(50);
    API.SoundSetMusicVolume(100);
    API.SoundSetVoiceVolume(20);
    API.SoundSetAtmoVolume(20);
    API.SoundSetUIVolume(0);
end

function RestoreSoundVolume()
    API.SoundRestore()
end