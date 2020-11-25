-- Realtime API ------------------------------------------------------------- --

---
-- TODO: add doc
-- @within Beschreibung
-- @set sort=true
--
ModuleRealtime = ModuleRealtime or {};

---
-- Gibt die real vergangene Zeit seit dem Spielstart in Sekunden zurück.
-- @return[type=number] Vergangene reale Zeit
-- @within Anwenderfunktionen
--
function API.RealTimeGetSecondsPassedSinceGameStart()
    return ModuleRealtime.m_SecondsSinceGameStart;
end

---
-- Wartet die angebene Zeit in realen Sekunden und führt anschließend das
-- Callback aus. Die Ausführung erfolgt asynchron. Das bedeutet, dass das
-- Skript weiterläuft.
--
-- Hinweis: Einmal gestartet, kann wait nicht beendet werden.
--
-- @param[type=number] _Waittime Wartezeit in realen Sekunden
-- @param[type=function] _Action Callback-Funktion
-- @param ... Liste der Argumente
-- @return[type=number] Vergangene reale Zeit
-- @within Anwenderfunktionen
--
function API.RealTimeWait(_Waittime, _Action, ...)
    StartSimpleJobEx( function(_StartTime, _Delay, _Callback, _Arguments)
        if (ModuleRealtime.m_SecondsSinceGameStart >= _StartTime + _Delay) then
            if #_Arguments > 0 then
                _Callback(unpack(_Arguments));
            else
                _Callback();
            end
            return true;
        end
    end, ModuleRealtime.m_SecondsSinceGameStart, _Waittime, _Action, {...});
end

