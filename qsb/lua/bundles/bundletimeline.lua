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

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
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
-- @param _Description [table] Beschreibung
-- @return [number] ID des Zeitstrahls
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
    return BundleTimeLine.Shared.TimeLine:Start(_Description);
end

---
-- Startet einen Zeitstrahl erneut. Ist der Zeitstrahl noch nicht
-- beendet, beginnt er dennoch von vorn.
--
-- <p><b>Alias:</b> QSB.TimeLine:Restart<br></p>
--
-- @param _ID [table] ID des Zeitstrahl
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
-- @param _ID [table] ID des Zeitstrahl
-- @return [boolean] Zeitstrahl ist aktiv
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
-- @param _ID [table] ID des Zeitstrahl
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
-- @param _ID [table] ID des Zeitstrahl
-- @within Anwenderfunktionen
--
-- @usage API.TimeLineResume(MyTimeLine);
--
function API.TimeLineResume(_ID)
    return BundleTimeLine.Shared.TimeLine:Resume(_ID);
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
    QSB.TimeLine = BundleTimeLine.Shared.TimeLine;
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
    QSB.TimeLine = BundleTimeLine.Shared.TimeLine;
    TimeLine = QSB.TimeLine;
end

-- Shared Script ------------------------------------------------------------ --

---
-- Startet einen Zeitstrahl. Ein Zeitstrahl hat bestimmte Stationen,
-- an denen eine Aktion ausgeführt wird.
--
-- <p><b>Alias:</b> QSB.TimeLine:Start<br></p>
--
-- @param _description [table] Beschreibung
-- @return [number] ID des Zeitstrahl
-- @within QSB.TimeLine
-- @local
--
function BundleTimeLine.Shared.TimeLine:Start(_description)
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
        local Controler = StartSimpleJobEx( BundleTimeLine.Shared.TimeLine.TimeLineControler );
        self.Data.ControlerID = Controler;
    end
    return JobID;
end

---
-- Startet einen Zeitstrahl erneut. Ist der Zeitstrahl noch nicht
-- beendet, beginnt er dennoch von vorn.
--
-- <p><b>Alias:</b> QSB.TimeLine:Restart<br></p>
--
-- @param _ID [table] ID des Zeitstrahl
-- @within QSB.TimeLine
-- @local
--
function BundleTimeLine.Shared.TimeLine:Restart(_ID)
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
-- <p><b>Alias:</b> QSB.TimeLine:IsRunning<br></p>
--
-- @param _ID [table] ID des Zeitstrahl
-- @return [boolean] Zeistrahl ist aktiv
-- @within QSB.TimeLine
-- @local
--
function BundleTimeLine.Shared.TimeLine:IsRunning(_ID)
    if self.Data.TimeLineJobs[_ID] then
        return self.Data.TimeLineJobs[_ID].Running == true;
    end
    return false;
end

---
-- Hält einen Zeitstrahl an.
--
-- Der Zeitstempel wird gespeichert.
--
-- <p><b>Alias:</b> QSB.TimeLine:Yield<br></p>
--
-- @param _ID [table] ID des Zeitstrahl
-- @within QSB.TimeLine
-- @local
--
function BundleTimeLine.Shared.TimeLine:Yield(_ID)
    if not self.Data.TimeLineJobs[_ID] then
        return;
    end
    self.Data.TimeLineJobs[_ID].YieldTime = Logic.GetTime();
    self.Data.TimeLineJobs[_ID].Running = false;
end

---
-- Stößt einen angehaltenen Zeitstrahl wieder an.
--
-- Die Zeit, die seit der Pausierung vergangen ist, wird zur Startzeit
-- addiert um Trigger Fehler zu vermeiden.
--
-- <p><b>Alias:</b> QSB.TimeLine:Resume<br></p>
--
-- @param _ID [table] ID des Zeitstrahl
-- @within QSB.TimeLine
-- @local
--
function BundleTimeLine.Shared.TimeLine:Resume(_ID)
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
function BundleTimeLine.Shared.TimeLine.TimeLineControler()
    for k,v in pairs(BundleTimeLine.Shared.TimeLine.Data.TimeLineJobs) do
        if v.Iterator > #v then
            BundleTimeLine.Shared.TimeLine.Data.TimeLineJobs[k].Running = false;
        end

        if v.Running then
            if (v[v.Iterator].Time + v.StartTime) <= Logic.GetTime() then
                v[v.Iterator].Action(unpack(v[v.Iterator]));
                BundleTimeLine.Shared.TimeLine.Data.TimeLineJobs[k].Iterator = v.Iterator +1;
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleTimeLine");
