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

    local Position;
    Position = GetPosition("PathStart");
    Logic.CreateEffect(EGL_Effects.E_Questmarker_low, Position.X, Position.Y, 0);
    Position = GetPosition("PathEnd");
    Logic.CreateEffect(EGL_Effects.E_Questmarker_low, Position.X, Position.Y, 0);
end

GameCallback_QSB_OnEventReceived = function(_EventID, ...)
    if _EventID == QSB.ScriptEvents.PathFindingFailed then
        API.Note("Path failed: " ..arg[1]);
    elseif _EventID == QSB.ScriptEvents.PathFindingFinished then
        API.Note("Path found: " ..arg[1]);
        local Path = Pathfinder:GetPath(arg[1]);
        Path = Path:Reduce(5);
        LuaDebugger.Log(Path);
        if Path then
            Path:Show();
        end
    end
end

-- > CreateSimplePath()

function CreateSimplePath()
    API.Note(Pathfinder:Insert("PathStart", "PathEnd", 400, 20));
end

-- > CreateRoadPathWithTwoAlternatives()

function CreateRoadPathWithTwoAlternatives()
    API.Note(Pathfinder:Insert(
        "PathEnd",
        "PathStart",
        300,
        1,
        function(_Node, _Siblings, _Start)
            local x,y,z = Logic.EntityGetPos(GetID(_Start));
            local e1, l1 = Logic.DoesRoadConnectionExist(_Node.X, _Node.Y, x, y, false, 10, nil);
            if e1 then
                for i= 1, #_Siblings do
                    if _Node.ID ~= _Siblings[i].ID then
                        local e2, l2 = Logic.DoesRoadConnectionExist(_Siblings[i].X, _Siblings[i].Y, x, y, false, 10, nil);
                        if e2 and l2 < l1 and l2 - l1 < 400 then
                            return false;
                        end
                    end
                end
                return true;
            end
            return false;
        end, "PathStart")
    );
end

-- > CreateRoadPathWithBlockedAlternative()

function CreateRoadPathWithBlockedAlternative()
    ReplaceEntity("PathBlock", Entities.B_Storehouse_Rubble);

    API.Note(Pathfinder:Insert(
        "PathEnd",
        "PathStart",
        300,
        1,
        function(_Node, _Siblings, _Start)
            if Logic.DEBUG_GetSectorAtPosition(_Node.X, _Node.Y) == 0 then
                return false;
            end

            local x,y,z = Logic.EntityGetPos(GetID(_Start));
            local e1, l1 = Logic.DoesRoadConnectionExist(_Node.X, _Node.Y, x, y, false, 10, nil);
            if e1 then
                for i= 1, #_Siblings do
                    if _Node.ID ~= _Siblings[i].ID then
                        local e2, l2 = Logic.DoesRoadConnectionExist(_Siblings[i].X, _Siblings[i].Y, x, y, false, 10, nil);
                        if e2 and l2 < l1 and l2 - l1 < 400 then
                            return false;
                        end
                    end
                end
                return true;
            end
            return false;
        end, "PathStart")
    );
end