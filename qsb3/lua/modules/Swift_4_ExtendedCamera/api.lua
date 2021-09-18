-- Extended Camera API ------------------------------------------------------ --

---
-- 
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_InputOutputCore.api.html">(1) Input/Output Core</a></li>
-- <li><a href="Swift_1_DisplayCore.api.html">(1) Display Core</a></li>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Aktiviert den Hotkey zum Wechsel zwischen normalen und erweiterten Zoom.
--
-- <p><b>Alias:</b> AllowExtendedZoom</p>
--
-- @param _Flag [boolean] Erweiterter Zoom gestattet
-- @within Anwenderfunktionen
--
function API.AllowExtendedZoom(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.AllowExtendedZoom(%s)]],
            tostring(_Flag)
        ))
        return;
    end
    ModuleExtendedCamera.Local.ExtendedZoomAllowed = _Flag == true;
    if _Flag == false then
        ModuleExtendedCamera.Local:DeactivateExtendedZoom();
    end
end
AllowExtendedZoom = API.AllowExtendedZoom;

---
-- Fokusiert die Kamera auf dem Primärritter des Spielers.
--
-- <p><b>Alias:</b> SetCameraToPlayerKnight</p>
--
-- @param[type=number] _Player Partei
-- @param[type=number] _Rotation Kamerawinkel
-- @param[type=number] _ZoomFactor Zoomfaktor
-- @within Anwenderfunktionen
--
function API.FocusCameraOnKnight(_Player, _Rotation, _ZoomFactor)
    API.FocusCameraOnEntity(Logic.GetKnightID(_Player), _Rotation, _ZoomFactor)
end
SetCameraToPlayerKnight = API.FocusCameraOnKnight;

---
-- Fokusiert die Kamera auf dem Entity.
--
-- <p><b>Alias:</b> SetCameraToEntity</p>
--
-- @param _Entity Entity (Skriptname oder ID)
-- @param[type=number] _Rotation Kamerawinkel
-- @param[type=number] _ZoomFactor Zoomfaktor
-- @within Anwenderfunktionen
--
function API.FocusCameraOnEntity(_Entity, _Rotation, _ZoomFactor)
    if not GUI then
        ---@diagnostic disable-next-line: ambiguity-1
        local Subject = (type(_Entity) ~= "string" and _Entity) or "'" .._Entity.. "'";
        Logic.ExecuteInLuaLocalState("API.FocusCameraOnEntity(" ..Subject.. ", " ..tostring(_Rotation).. ", " ..tostring(_ZoomFactor).. ")");
        return;
    end
    if type(_Rotation) ~= "number" then
        error("API.FocusCameraOnEntity: Rotation is wrong!");
        return;
    end
    if type(_ZoomFactor) ~= "number" then
        error("API.FocusCameraOnEntity: Zoom factor is wrong!");
        return;
    end
    if not IsExisting(_Entity) then
        error("API.FocusCameraOnEntity: Entity " ..tostring(_Entity).." does not exist!");
        return;
    end
    return ModuleExtendedCamera.Local:SetCameraToEntity(_Entity, _Rotation, _ZoomFactor);
end
SetCameraToEntity = API.FocusCameraOnEntity;

