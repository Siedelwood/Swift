-- Selection API ------------------------------------------------------------ --

---
-- Die Optionen für selektierte Einheiten kann individualisiert werden.
--
-- <b>Hinweis</b>: Diese Funktionalität ist im Multiplayer nicht verfügbar.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_InterfaceCore.api.html">(0) Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Deaktiviert oder aktiviert das Entlassen von Dieben.
-- @param[type=boolean] _Flag Deaktiviert (false) / Aktiviert (true)
-- @within Anwenderfunktionen
--
-- @usage
-- API.DisableReleaseThieves(false);
--
function API.DisableReleaseThieves(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.DisableReleaseThieves(" ..tostring(_Flag).. ")");
        return;
    end
    ModuleSelectionCore.Local.ThiefRelease = not _Flag;
end

---
-- Deaktiviert oder aktiviert das Entlassen von Kriegsmaschinen.
-- @param[type=boolean] _Flag Deaktiviert (false) / Aktiviert (true)
-- @within Anwenderfunktionen
--
-- @usage
-- API.DisableReleaseSiegeEngines(true);
--
function API.DisableReleaseSiegeEngines(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.DisableReleaseSiegeEngines(" ..tostring(_Flag).. ")");
        return;
    end
    ModuleSelectionCore.Local.SiegeEngineRelease = not _Flag;
end

---
-- Deaktiviert oder aktiviert das Entlassen von Soldaten.
-- @param[type=boolean] _Flag Deaktiviert (false) / Aktiviert (true)
-- @within Anwenderfunktionen
--
-- @usage
-- API.DisableReleaseSoldiers(false);
--
function API.DisableReleaseSoldiers(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.DisableReleaseSoldiers(" ..tostring(_Flag).. ")");
        return;
    end
    ModuleSelectionCore.Local.MilitaryRelease = not _Flag;
end

---
-- Prüpft ob das Entity selektiert ist.
--
-- @param _Entity Entity das selektiert sein soll (Skriptname oder ID)
-- @return[type=boolean] Entity ist selektiert
-- @within Anwenderfunktionen
--
-- @usage
-- if API.IsEntityInSelection("hakim") then
--     -- Do something
-- end
--
function API.IsEntityInSelection(_Entity)
    if IsExisting(_Entity) then
        local EntityID = GetID(_Entity);
        local SelectedEntities;
        if not GUI then
            SelectedEntities = ModuleSelectionCore.Global.SelectedEntities;
        else
            SelectedEntities = {GUI.GetSelectedEntities()};
        end
        for i= 1, #SelectedEntities, 1 do
            if SelectedEntities[i] == EntityID then
                return true;
            end
        end
    end
    return false;
end
IsEntitySelected = API.IsEntityInSelection;

---
-- Gibt die ID des selektierten Entity zurück.
--
-- Wenn mehr als ein Entity selektiert sind, wird das erste Entity
-- zurückgegeben. Sind keine Entities selektiert, wird 0 zurückgegeben.
--
-- @return[type=number] ID des selektierten Entities
-- @within Anwenderfunktionen
--
-- @usage
-- local SelectedEntity = API.GetSelectedEntity();
--
function API.GetSelectedEntity()
    local SelectedEntity;
    if not GUI then
        SelectedEntity = ModuleSelectionCore.Global.SelectedEntities[1];
    else
        SelectedEntity = GUI.GetSelectedEntity();
    end
    return SelectedEntity or 0;
end
GetSelectedEntity = API.GetSelectedEntity;

---
-- Gibt alle selektierten Entities zurück.
--
-- @return[type=table] ID des selektierten Entities
-- @within Anwenderfunktionen
--
-- @usage
-- local Selection = API.GetSelectedEntities();
--
function API.GetSelectedEntities()
    local SelectedEntities;
    if not GUI then
        SelectedEntities = ModuleSelectionCore.Global.SelectedEntities;
    else
        SelectedEntities = {GUI.GetSelectedEntities()};
    end
    return SelectedEntities;
end
GetSelectedEntities = API.GetSelectedEntities;

