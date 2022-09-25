Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/development.lua");

function Mission_LocalVictory()
end

function Mission_LoadFiles()
    return {};
end

function Mission_LocalOnQsbLoaded()
    -- LastFrameworkTime = 0;
    -- CurrentFramrworkTime = 0;
    -- ThroneRoomCameraControl_Orig = ThroneRoomCameraControl;
    -- ThroneRoomCameraControl = function()
    --     ThroneRoomCameraControl_Orig();
    --     CurrentFramrworkTime = Framework.GetTimeMs();
    --     GUI.ClearNotes();
    --     GUI.AddNote("Time: " ..(CurrentFramrworkTime-LastFrameworkTime));
    --     LastFrameworkTime = CurrentFramrworkTime;
    -- end
end
