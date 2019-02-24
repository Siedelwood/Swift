-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Intern Local Script                                                    # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Einfach alles so lassen, wie es ist!

function Mission_LocalVictory()
    if OnMissionVictory then
        OnMissionVictory();
    end
end

function Mission_LocalOnMapStart()
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
    Script.Load(g_ContentPath.. "knighttitlerequirements.lua");

    API.Install();
    InitKnightTitleTables();
    if InitMissionScript then
        InitMissionScript();
    end
    if FirstMapAction then
        FirstMapAction();
    end
end