--[[
Swift_3_JobsRealtime/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Mit diesem Modul kannst du sekundengenaue Verzögerungen in Echtzeit
-- erstellen.
--
-- Du kannst entweder in Echtzeit warten, um eine Aktion auszuführen, oder in
-- Jobs abfragen, wie viele Sekunden in Echtzeit vergangen sind. Echtzeit hat
-- den Vorteil, dass die eingestellte Spielgeschwindigkeit egal ist.
--
-- Die Wartezeiten von Questdialogen werden durch dieses Modul in Echtzeit statt
-- in Ingame Zeit gemessen. Diese Änderung geschieht vollautomatisch.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- <li><a href="Swift_2_QuestCore.api.html">(2) Quests Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Gibt die real vergangene Zeit seit dem Spielstart in Sekunden zurück.
-- @return[type=number] Vergangene reale Zeit
-- @within Anwenderfunktionen
--
-- @usage local RealTime = API.RealTimeGetSecondsPassedSinceGameStart();
--
function API.RealTimeGetSecondsPassedSinceGameStart()
    return ModuleJobsRealtime.Shared.SecondsSinceGameStart;
end

---
-- Wartet die angebene Zeit in realen Sekunden und führt anschließend das
-- Callback aus. Die Ausführung erfolgt asynchron. Das bedeutet, dass das
-- Skript weiterläuft.
--
-- @param[type=number] _Waittime Wartezeit in realen Sekunden
-- @param[type=function] _Action Callback-Funktion
-- @param ... Liste der Argumente
-- @return[type=number] ID der Verzögerung
-- @within Anwenderfunktionen
--
-- @usage API.RealTimeWait(
--     30,
--     function()
--         Logic.DEBUG_AddNote("Zeit abgelaufen!");
--     end
-- )
--
function API.RealTimeWait(_Waittime, _Action, ...)
    ModuleJobsRealtime.Shared.RealTimeWaitID = ModuleJobsRealtime.Shared.RealTimeWaitID +1;
    local ID = ModuleJobsRealtime.Shared.RealTimeWaitID;
    ModuleJobsRealtime.Shared.RealTimeWaitActiveFlag[ID] = true;

    StartSimpleJobEx( function(_StartTime, _Delay, _Callback, _Arguments)
        if not ModuleJobsRealtime.Shared.RealTimeWaitActiveFlag[ID] then
            return true;
        end
        if (ModuleJobsRealtime.Shared.SecondsSinceGameStart >= _StartTime + _Delay) then
            if #_Arguments > 0 then
                _Callback(unpack(_Arguments));
            else
                _Callback();
            end
            ModuleJobsRealtime.Shared.RealTimeWaitActiveFlag[ID] = nil;
            return true;
        end
    end, ModuleJobsRealtime.Shared.SecondsSinceGameStart, _Waittime, _Action, {...});
    return ID;
end

---
-- Stoppt den Real Time Timer mit der angegebenen ID.
--
-- @param[type=number] _ID ID der Verzögerung
-- @within Anwenderfunktionen
--
-- @usage TIMER_ID = API.RealTimeWait(...); -- (Parameter unerheblich)
-- API.RealTimeWaitStop(TIMER_ID);
--
function API.RealTimeWaitStop(_ID)
    ModuleJobsRealtime.Shared.RealTimeWaitActiveFlag[_ID] = nil;
end

