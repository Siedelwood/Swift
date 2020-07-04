-- Echtzeit --------------------------------------------------------------------

QSB.RealTime_SecondsSinceGameStart = 0;

-- API Stuff --

---
-- Gibt die real vergangene Zeit seit dem Spielstart in Sekunden zurück.
-- @return[type=number] Vergangene reale Zeit
-- @within Anwenderfunktionen
--
function API.RealTimeGetSecondsPassedSinceGameStart()
    return QSB.RealTime_SecondsSinceGameStart;
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
        if (QSB.RealTime_SecondsSinceGameStart >= _StartTime + _Delay) then
            if #_Arguments > 0 then
                _Callback(unpack(_Arguments));
            else
                _Callback();
            end
            return true;
        end
    end, QSB.RealTime_SecondsSinceGameStart, _Waittime, _Action, {...});
end

-- Core Stuff --

-- Dieser Job ermittelt automatisch, ob eine Sekunde reale Zeit vergangen ist
-- und zählt eine Variable hoch, die die gesamt verstrichene reale Zeit hält.

function Core.EventJob_EventOnEveryRealTimeSecond()
    if not QSB.RealTime_LastTimeStamp then
        QSB.RealTime_LastTimeStamp = math.floor(Framework.TimeGetTime());
    end
    local CurrentTimeStamp = math.floor(Framework.TimeGetTime());

    -- Eine Sekunde ist vergangen
    if QSB.RealTime_LastTimeStamp ~= CurrentTimeStamp then
        QSB.RealTime_LastTimeStamp = CurrentTimeStamp;
        QSB.RealTime_SecondsSinceGameStart = QSB.RealTime_SecondsSinceGameStart +1;
    end
end

