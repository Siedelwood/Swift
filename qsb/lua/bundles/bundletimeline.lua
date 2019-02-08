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
-- <a href="#API.TimeLineStart">Zeitstrahl erstellen</a><br>Eine Abfolge von
-- Aktionen definieren, die zu gewissen Zeitpunkten ausgelöst werden.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleTimeLine = {};

API = API or {};
QSB = QSB or {};

QSB.TimeLine = {};

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
--
-- @usage MyTimeLine = QSB.TimeLine:Start {
--     {Time = 15, Action = MyFirstAction},
--     -- MySecondAction erhält "BOCKWURST" als Parameter
--     {Time = 35, Action = MySecondAction, "BOCKWURST"},
--     -- Inline-Funktion
--     {Time = 49, Action = function() end},
-- }
--
function QSB.TimeLine:Start(_description)
    local JobID = self.Data.TimeLineUniqueJobID;
    self.Data.TimeLineUniqueJobID = JobID +1;

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

    self.Data.TimeLineJobs[JobID] = _description;
    if not self.Data.ControlerID then
        local Controler = StartSimpleHiResJobEx(QSB.TimeLine.TimeLineControler);
        self.Data.ControlerID = Controler;
    end
    return JobID;
end

---
-- Startet einen Zeitstrahl erneut. Ist der Zeitstrahl noch nicht
-- beendet, beginnt er dennoch von vorn.
--
-- @param[type=number] _ID ID des Zeitstrahl
-- @within Anwenderfunktionen
--
-- @usage QSB.TimeLine:Restart(MyTimeLine);
--
function QSB.TimeLine:Restart(_ID)
    if not self.Data.TimeLineJobs[_ID] then
        return;
    end
    self.Data.TimeLineJobs[_ID].Running = true;
    self.Data.TimeLineJobs[_ID].StartTime = Logic.GetTime();
    self.Data.TimeLineJobs[_ID].Iterator = 1;
end

---
-- Prüft, ob der Zeitstrahl noch nicht durchgelaufen ist.
--
-- @param[type=number] _ID ID des Zeitstrahl
-- @return[type=boolean] Zeitstrahl ist aktiv
-- @within Anwenderfunktionen
--
-- @usage local IsRunning = QSB.TimeLine:IsRunning(MyTimeLine);
--
function QSB.TimeLine:IsRunning(_ID)
    if self.Data.TimeLineJobs[_ID] then
        return self.Data.TimeLineJobs[_ID].Running == true;
    end
    return false;
end

---
-- Hält einen Zeitstrahl an.
--
-- @param[type=number] _ID ID des Zeitstrahl
-- @within Anwenderfunktionen
--
-- @usage QSB.TimeLine:Yield(MyTimeLine);
--
function QSB.TimeLine:Yield(_ID)
    if not self.Data.TimeLineJobs[_ID] then
        return;
    end
    self.Data.TimeLineJobs[_ID].YieldTime = Logic.GetTime();
    self.Data.TimeLineJobs[_ID].Running = false;
end

---
-- Stößt einen angehaltenen Zeitstrahl wieder an.
--
-- @param[type=number] _ID ID des Zeitstrahl
-- @within Anwenderfunktionen
--
-- @usage QSB.TimeLine:Resume(MyTimeLine);
--
function QSB.TimeLine:Resume(_ID)
    if not self.Data.TimeLineJobs[_ID] then
        return;
    end
    if self.Data.TimeLineJobs[_ID].YieldTime then
        local OldStartTime = self.Data.TimeLineJobs[_ID].StartTime;
        local TimeYielded = Logic.GetTime() - self.Data.TimeLineJobs[_ID].YieldTime;
        self.Data.TimeLineJobs[_ID].StartTime = OldStartTime + TimeYielded;
        self.Data.TimeLineJobs[_ID].YieldTime = nil;
    end
    self.Data.TimeLineJobs[_ID].Running = true;
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
    Shared = {
        TimeLine = {
            Data = {
                TimeLineUniqueJobID = 1,
                TimeLineJobs = {},
            }
        }
    }
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
