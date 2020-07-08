-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleTimeLine                                               # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle ermöglicht es Aktionen in einer zeitlichen Abfolge zu
-- gliedern.
--
-- Die Bezeichnung "Time Line" (Zeitstrahl) wird z.B. in der Filmindustrie
-- verwendet und beschreibt einen Ablauf von aufeinander folgenden Ereignissen.
-- Diese Ereignisse sind zeitlich gegliedert.
--
-- Du kannst mit der Implementation eines solchen Zeitstrahls Lua-Funktionen
-- im Abstand einer oder mehrerer Sekunden ausführen lassen. Ein solcher
-- Zeitstrahl verfügt über eine ID, mit der er angesprochen werden kann. So
-- kann er abgebrochen, pausiert, fortgesetzt und neu gestartet werden.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleTimeLine = {};

API = API or {};
QSB = QSB or {};

QSB.TimeLine = {
    Data = {
        TimeLineUniqueJobID = 1,
        TimeLineJobs = {},
    }
};

-- -------------------------------------------------------------------------- --
-- User Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Startet einen Zeitstrahl. Ein Zeitstrahl hat Stationen,
-- an denen eine Aktion ausgeführt wird. Jede Station muss mindestens eine
-- Sekunde nach der vorherigen liegen.
--
-- Jede Aktion eines Zeitstrahls erhält die Table des aktuellen Ereignisses
-- als Argument. So können Parameter an die Funktion übergeben werden.
--
-- <p><b>Alias:</b> QSB.TimeLine:Start<br></p>
--
-- @param[type=table] _Description Beschreibung
-- @return[type=number] ID des Zeitstrahls
-- @within Anwenderfunktionen
--
-- @usage MyTimeLine = API.TimeLineStart {
--     {Time = 1, Action = MyFirstAction},
--     -- MySecondAction erhält "BOCKWURST" als Parameter
--     {Time = 3, Action = MySecondAction, "BOCKWURST"},
--     -- Inline-Funktion
--     {Time = 9, Action = function() end},
-- }
--
function API.TimeLineStart(_Description)
    if type(_Description) ~= "table" then
        error("API.TimeLineStart: _Description must be a table!");
        return;
    end
    for i= 1, #_Description, 1 do
        if type(_Description.Time) ~= "number" or _Description.Time < 0 then
            error("API.TimeLineStart: _Description[" ..i.. "].Time (".. tostring(_Description.Time).. ") must be a positive number!");
            return;
        end
        if type(_Description.Action) ~= "function" then
            error("API.TimeLineStart: _Description[" ..i.. "].Action must be a function!");
            return;
        end
    end
    return BundleTimeLine.Shared.TimeLine:Start(_Description);
end

---
-- Startet einen Zeitstrahl erneut. Ist der Zeitstrahl noch nicht
-- beendet, beginnt er dennoch von vorn.
--
-- <p><b>Alias:</b> QSB.TimeLine:Restart<br></p>
--
-- @param[type=number] _ID ID des Zeitstrahl
-- @within Anwenderfunktionen
--
-- @usage API.TimeLineRestart(MyTimeLine);
--
function API.TimeLineRestart(_ID)
    return BundleTimeLine.Shared.TimeLine:Restart(_ID)
end

---
-- Prüft, ob der Zeitstrahl noch nicht durchgelaufen ist.
--
-- <p><b>Alias:</b> QSB.TimeLine:IsRunning<br></p>
--
-- @param[type=number] _ID ID des Zeitstrahl
-- @return[type=boolean] Zeitstrahl ist aktiv
-- @within Anwenderfunktionen
--
-- @usage local IsRunning = API.TimeLineIsRunning(MyTimeLine);
--
function API.TimeLineIsRunning(_ID)
    return BundleTimeLine.Shared.TimeLine:IsRunning(_ID);
end

---
-- Hält einen Zeitstrahl an.
--
-- <p><b>Alias:</b> QSB.TimeLine:Yield<br></p>
--
-- @param[type=number] _ID ID des Zeitstrahl
-- @within Anwenderfunktionen
--
-- @usage API.TimeLineYield(MyTimeLine);
--
function API.TimeLineYield(_ID)
    return BundleTimeLine.Shared.TimeLine:Yield(_ID);
end

---
-- Stößt einen angehaltenen Zeitstrahl wieder an.
--
-- <p><b>Alias:</b> QSB.TimeLine:Resume<br></p>
--
-- @param[type=number] _ID ID des Zeitstrahl
-- @within Anwenderfunktionen
--
-- @usage API.TimeLineResume(MyTimeLine);
--
function API.TimeLineResume(_ID)
    return BundleTimeLine.Shared.TimeLine:Resume(_ID);
end

-- -------------------------------------------------------------------------- --
-- TimeLine Klasse                                                            --
-- -------------------------------------------------------------------------- --

---
-- Startet einen Zeitstrahl. Ein Zeitstrahl hat Stationen,
-- an denen eine Aktion ausgeführt wird. Jede Station muss mindestens eine
-- Sekunde nach der vorherigen liegen.
--
-- Jede Aktion eines Zeitstrahls erhält die Table des aktuellen Ereignisses
-- als Argument. So können Parameter an die Funktion übergeben werden.
--
-- @param[type=table] _Description Beschreibung
-- @return[type=number] ID des Zeitstrahls
-- @within Anwenderfunktionen
-- @local
--
-- @usage MyTimeLine = QSB.TimeLine:Start {
--     {Time = 5, Action = MyFirstAction},
--     -- MySecondAction erhält "BOCKWURST" als Parameter
--     {Time = 15, Action = MySecondAction, "BOCKWURST"},
--     -- Inline-Funktion
--     {Time = 30, Action = function() end},
-- }
--
function QSB.TimeLine:Start(_description)
    local JobID = QSB.TimeLine.Data.TimeLineUniqueJobID;
    QSB.TimeLine.Data.TimeLineUniqueJobID = JobID +1;

    _description.Running = true;
    _description.StartTime = Logic.GetTime();
    _description.Iterator = 1;

    -- Check auf sinnvolle Zeitabstände
    local Last = 0;
    for i=1, #_description, 1 do
        if _description[i].Time < Last then
            _description[i].Time = Last+1;
            Last = _description[i].Time;
        end
    end

    QSB.TimeLine.Data.TimeLineJobs[JobID] = _description;
    if not QSB.TimeLine.Data.ControlerID then
        local Controler = StartSimpleJobEx(QSB.TimeLine.TimeLineControler);
        QSB.TimeLine.Data.ControlerID = Controler;
    end
    return JobID;
end
function API.TimeLineStart(_ID)
    return QSB.TimeLine:Start(_ID);
end

---
-- Startet einen Zeitstrahl erneut. Ist der Zeitstrahl noch nicht
-- beendet, beginnt er dennoch von vorn.
--
-- @param[type=number] _ID ID des Zeitstrahl
-- @within Anwenderfunktionen
-- @local
--
-- @usage QSB.TimeLine:Restart(MyTimeLine);
--
function QSB.TimeLine:Restart(_ID)
    if not QSB.TimeLine.Data.TimeLineJobs[_ID] then
        return;
    end
    QSB.TimeLine.Data.TimeLineJobs[_ID].Running = true;
    QSB.TimeLine.Data.TimeLineJobs[_ID].StartTime = Logic.GetTime();
    QSB.TimeLine.Data.TimeLineJobs[_ID].Iterator = 1;
end
function API.TimeLineRestart(_ID)
    QSB.TimeLine:Restart(_ID);
end

---
-- Prüft, ob der Zeitstrahl noch nicht durchgelaufen ist.
--
-- @param[type=number] _ID ID des Zeitstrahl
-- @return[type=boolean] Zeitstrahl ist aktiv
-- @within Anwenderfunktionen
-- @local
--
-- @usage local IsRunning = QSB.TimeLine:IsRunning(MyTimeLine);
--
function QSB.TimeLine:IsRunning(_ID)
    if QSB.TimeLine.Data.TimeLineJobs[_ID] then
        return QSB.TimeLine.Data.TimeLineJobs[_ID].Running == true;
    end
    return false;
end
function API.TimeLineIsRunning(_ID)
    QSB.TimeLine:IsRunning(_ID);
end

---
-- Hält einen Zeitstrahl an.
--
-- @param[type=number] _ID ID des Zeitstrahl
-- @within Anwenderfunktionen
-- @local
--
-- @usage QSB.TimeLine:Yield(MyTimeLine);
--
function QSB.TimeLine:Yield(_ID)
    if not QSB.TimeLine.Data.TimeLineJobs[_ID] then
        return;
    end
    QSB.TimeLine.Data.TimeLineJobs[_ID].YieldTime = Logic.GetTime();
    QSB.TimeLine.Data.TimeLineJobs[_ID].Running = false;
end
function API.TimeLineYield(_ID)
    QSB.TimeLine:Yield(_ID);
end

---
-- Stößt einen angehaltenen Zeitstrahl wieder an.
--
-- @param[type=number] _ID ID des Zeitstrahl
-- @within Anwenderfunktionen
-- @local
--
-- @usage QSB.TimeLine:Resume(MyTimeLine);
--
function QSB.TimeLine:Resume(_ID)
    if not QSB.TimeLine.Data.TimeLineJobs[_ID] then
        return;
    end
    if QSB.TimeLine.Data.TimeLineJobs[_ID].YieldTime then
        local OldStartTime = QSB.TimeLine.Data.TimeLineJobs[_ID].StartTime;
        local TimeYielded = Logic.GetTime() - QSB.TimeLine.Data.TimeLineJobs[_ID].YieldTime;
        QSB.TimeLine.Data.TimeLineJobs[_ID].StartTime = OldStartTime + TimeYielded;
        QSB.TimeLine.Data.TimeLineJobs[_ID].YieldTime = nil;
    end
    QSB.TimeLine.Data.TimeLineJobs[_ID].Running = true;
end
function API.TimeLineResume(_ID)
    QSB.TimeLine:Resume(_ID);
end

---
-- Steuert alle Zeitstrahlen.
-- @within QSB.TimeLine
-- @local
--
function QSB.TimeLine.TimeLineControler()
    for k,v in pairs(QSB.TimeLine.Data.TimeLineJobs) do
        if v.Iterator > #v then
            QSB.TimeLine.Data.TimeLineJobs[k].Running = false;
        end

        if v.Running then
            if (v[v.Iterator].Time + v.StartTime) <= Logic.GetTime() then
                v[v.Iterator].Action(unpack(v[v.Iterator]));
                QSB.TimeLine.Data.TimeLineJobs[k].Iterator = v.Iterator +1;
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleTimeLine = {
    Global = {
        Data = {}
    },
    Local = {
        Data = {}
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function BundleTimeLine.Global:Install()
    TimeLine = QSB.TimeLine;
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleTimeLine.Local:Install()
    TimeLine = QSB.TimeLine;
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleTimeLine");

