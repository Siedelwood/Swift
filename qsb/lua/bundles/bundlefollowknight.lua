-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleFollowKnight                                           # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle bietet Funktionalität um Entities dauerhaft einem Helden
-- (bzw Ritter) folgen zu lassen.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleFollowKnight = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Lässt einen Siedler einem Helden folgen. Gibt die ID des Jobs
-- zurück, der die Verfolgung steuert.
--
-- <p><b>Hinweis:</b> Wenn eines der Entities zerstört wird, oder ins
-- Koma fällt, wird der Job beendet!</p>
--
-- <p><b>Alias:</b> AddFollowKnightSave</p>
--
-- @param              _Entity Entity das folgt (skriptname oder ID)
-- @param              _Knight Held (Skriptname oder ID)
-- @param[type=number] _Distance Entfernung, die uberschritten sein muss
-- @param[type=number] _Angle Ausrichtung
-- @return[type=number] Job-ID
-- @within Anwenderfunktionen
--
function API.FollowKnightSaveStart(_Entity, _Knight, _Distance, _Angle)
    if GUI then
        local Target = (type(_Entity) == "string" and "'".._Entity.."'") or _Entity;
        local Knight = (type(_Knight) == "string" and "'".._Knight.."'") or _Knight;
        API.Bridge("API.FollowKnightSaveStart(" ..Target.. ", " ..Knight.. ", " .._Distance.. "," .._Angle.. ")");
        return;
    end
    return BundleFollowKnight.Global:AddFollowKnightSave(_Entity, _Knight, _Distance, _Angle);
end
AddFollowKnightSave = API.FollowKnightSaveStart;

---
-- Beendet einen Verfolgungsjob.
--
-- <p><b>Alias:</b> StopFollowKnightSave</p>
--
-- @param[type=number] _JobID Job-ID
-- @within Anwenderfunktionen
--
function API.FollowKnightSaveStop(_JobID)
    if GUI then
        API.Bridge("API.FollowKnightSaveStop(" .._JobID.. ")");
        return;
    end
    return BundleFollowKnight.Global:StopFollowKnightSave(_JobID)
end

StopFollowKnightSave = API.FollowKnightSaveStop;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleFollowKnight = {
    Global = {
        Data = {
            FollowKnightSave = {},
        }
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function BundleFollowKnight.Global:Install()
end

-- -------------------------------------------------------------------------- --

---
-- Lässt einen Siedler einem Helden folgen. Gibt die ID des Jobs
-- zurück, der die Verfolgung steuert.
--
-- @param              _Entity Entity das folgt (skriptname oder ID)
-- @param              _Knight Held (Skriptname oder ID)
-- @param[type=number] _Distance Entfernung, die uberschritten sein muss
-- @param[type=number] _Angle Ausrichtung
-- @return[type=number] Job-ID
-- @within Internal
-- @local
--
function BundleFollowKnight.Global:AddFollowKnightSave(_Entity, _Knight, _Distance, _Angle)
    local EntityID = GetID(_Entity);
    local KnightID = GetID(_Knight);
    _Angle = _Angle or 0;

    local JobID = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN,
                                         nil,
                                         "ControlFollowKnightSave",
                                         1,
                                         {},
                                         {EntityID, KnightID, _Distance, _Angle});

    table.insert(self.Data.FollowKnightSave, JobID);
    return JobID;
end

---
-- Beendet einen Verfolgungsjob.
--
-- @param[type=number] _JobID Job-ID
-- @within Internal
-- @local
--
function BundleFollowKnight.Global:StopFollowKnightSave(_JobID)
    for k,v in pairs(self.Data.FollowKnightSave) do
        if _JobID == v then
            self.Data.FollowKnightSave[k] = nil;
            EndJob(_JobID);
        end
    end
end

---
-- Kontrolliert die Verfolgung eines Helden durch einen Siedler.
--
-- @param              _Entity Entity das folgt (skriptname oder ID)
-- @param              _Knight Held (Skriptname oder ID)
-- @param[type=number] _Distance Entfernung, die uberschritten sein muss
-- @param[type=number] _Angle Ausrichtung
-- @within Internal
-- @local
--
function BundleFollowKnight.Global.ControlFollowKnightSave(_EntityID, _KnightID, _Distance, _Angle)
    -- Entity oder Held sind hinüber bzw. haben ihre ID verändert
    if not IsExisting(_KnightID) or not IsExisting(_EntityID) then
        return true;
    end

    -- Wenn Entity ein Held ist, dann nur, wenn Entity nicht komatös ist
    if Logic.IsKnight(_EntityID) and Logic.KnightGetResurrectionProgress(_EntityID) ~= 1 then
        return false;
    end
    -- Wenn Knight ein Held ist, dann nur, wenn Knight nicht komatös ist
    if Logic.IsKnight(_KnightID) and Logic.KnightGetResurrectionProgress(_KnightID) ~= 1 then
        return false;
    end

    if  Logic.IsEntityMoving(_EntityID) == false and Logic.IsFighting(_EntityID) == false
    and IsNear(_EntityID, _KnightID, _Distance+300) == false then
        -- Relative Position hinter Held bestimmen
        local x, y, z = Logic.EntityGetPos(_KnightID);
        local orientation = Logic.GetEntityOrientation(_KnightID)-(180+_Angle);
        local xBehind = x + _Distance * math.cos(math.rad(orientation));
        local yBehind = y + _Distance * math.sin(math.rad(orientation));

        -- Relative Position blockingsicher machen
        local NoBlocking = Logic.CreateEntityOnUnblockedLand(Entities.XD_ScriptEntity, xBehind, yBehind, 0, 0);
        local x, y, z = Logic.EntityGetPos(NoBlocking);
        DestroyEntity(NoBlocking);

        -- Zur neuen unblockierten Position bewegen
        Logic.MoveSettler(_EntityID, x, y);
    end
end
ControlFollowKnightSave = BundleFollowKnight.Global.ControlFollowKnightSave;

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleFollowKnight");

