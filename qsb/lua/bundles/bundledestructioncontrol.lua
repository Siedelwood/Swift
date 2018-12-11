-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleDestructionControl                                     # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es einzelne Gebäude, Typen oder Kategorien von Gebäuden vor
-- dem Abriss zu schützen. Ebenso kann jeglicher Abriss von Gebäuden auf
-- einem Territrium komplett unterbunden werden.
--
-- Das wichtigste Auf einen Blick:
-- <ul>
-- <li>
-- Den Abriss für bestimmte Entities steuern.<br>
-- <a href="#API.ProtectCategory">Entities beschützen</a>,
-- <a href="#API.UnprotectCategory">Schutz aufheben</a>
-- </li>
-- </ul>
--
-- @within Modulbeschreibung
-- @set sort=false
--
BundleDestructionControl = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Fügt ein Entity hinzu, dass nicht abgerissen werden darf.
--
-- @param _entity [string] Nicht abreißbares Entity
-- @within Anwenderfunktionen
--
function API.ProtectEntity(_entity)
    if not GUI then
        API.Bridge([[
            API.ProtectEntity("]].._entity..[[")
        ]]);
    else
        if not Inside(_enitry, BundleDestructionControl.Local.Data.Entities) then
            table.insert(BundleDestructionControl.Local.Data.Entities, _entity);
        end
    end
end

---
-- Fügt einen Entitytyp hinzu, der nicht abgerissen werden darf.
--
-- @param _entity [number] Nicht abreißbarer Typ
-- @within Anwenderfunktionen
--
function API.ProtectEntityType(_entity)
    if not GUI then
        API.Bridge([[
            API.ProtectEntityType(]].._entity..[[)
        ]]);
    else
        if not Inside(_enitry, BundleDestructionControl.Local.Data.EntityTypes) then
            table.insert(BundleDestructionControl.Local.Data.EntityTypes, _entity);
        end
    end
end

---
-- Fügt eine Kategorie hinzu, die nicht abgerissen werden darf.
--
-- @param _entity [number] Nicht abreißbare Kategorie
-- @within Anwenderfunktionen
--
function API.ProtectCategory(_entity)
    if not GUI then
        API.Bridge([[
            API.ProtectCategory(]].._entity..[[)
        ]]);
    else
        if not Inside(_enitry, BundleDestructionControl.Local.Data.EntityCategories) then
            table.insert(BundleDestructionControl.Local.Data.EntityCategories, _entity);
        end
    end
end

---
-- Fügt ein Territory hinzu, auf dem nichts abgerissen werden kann.
--
-- @param _entity [number] Geschütztes Territorium
-- @within Anwenderfunktionen
--
function API.ProtectTerritory(_entity)
    if not GUI then
        API.Bridge([[
            API.ProtectTerritory(]].._entity..[[)
        ]]);
    else
        if not Inside(_entity, BundleDestructionControl.Local.Data.OnTerritory) then
            table.insert(BundleDestructionControl.Local.Data.OnTerritory, _entity);
        end
    end
end

---
-- Entfernt ein Entity, dass nicht abgerissen werden darf.
--
-- @param _entry [string] Nicht abreißbares Entity
-- @within Anwenderfunktionen
--
function API.UnprotectEntity(_entry)
    if not GUI then
        API.Bridge([[
            API.UnprotectEntity("]].._entry..[[")
        ]]);
    else
        for i=1,#BundleDestructionControl.Local.Data.Entities do
            if BundleDestructionControl.Local.Data.Entities[i] == _entry then
                table.remove(BundleDestructionControl.Local.Data.Entities, i);
                return;
            end
        end
    end
end

---
-- Entfernt einen Entitytyp, der nicht abgerissen werden darf.
--
-- @param _entry [number] Nicht abreißbarer Typ
-- @within Anwenderfunktionen
--
function API.UnprotectEntityType(_entry)
    if not GUI then
        API.Bridge([[
            API.UnprotectEntityType(]].._entry..[[)
        ]]);
    else
        for i=1,#BundleDestructionControl.Local.Data.EntityTypes do
            if BundleDestructionControl.Local.Data.EntityTypes[i] == _entry then
                table.remove(BundleDestructionControl.Local.Data.EntityTypes, i);
                return;
            end
        end
    end
end

---
-- Entfernt eine Kategorie, die nicht abgerissen werden darf.
--
-- @param _entry [number] Nicht abreißbare Kategorie
-- @within Anwenderfunktionen
--
function API.UnprotectCategory(_entry)
    if not GUI then
        API.Bridge([[
            API.UnprotectCategory(]].._entry..[[)
        ]]);
    else
        for i=1,#BundleDestructionControl.Local.Data.EntityCategories do
            if BundleDestructionControl.Local.Data.EntityCategories[i] == _entry then
                table.remove(BundleDestructionControl.Local.Data.EntityCategories, i);
                return;
            end
        end
    end
end

---
-- Entfernt ein Territory, auf dem nichts abgerissen werden kann.
--
-- @param _entry [number] Geschütztes Territorium
-- @within Anwenderfunktionen
--
function API.UnprotectTerritory(_entry)
    if not GUI then
        API.Bridge([[
            API.UnprotectTerritory(]].._entry..[[)
        ]]);
    else
        for i=1,#BundleDestructionControl.Local.Data.OnTerritory do
            if BundleDestructionControl.Local.Data.OnTerritory[i] == _entry then
                table.remove(BundleDestructionControl.Local.Data.OnTerritory, i);
                return;
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleDestructionControl = {
    Local = {
        Data = {
            Entities = {},
            EntityTypes = {},
            EntityCategories = {},
            OnTerritory = {},
        }
    },
}

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleDestructionControl.Local:Install()
    Core:AppendFunction(
        "GameCallback_GUI_DeleteEntityStateBuilding",
        BundleDestructionControl.Local.DeleteEntityStateBuilding
    );
end

---
-- Verhindert den Abriss von Entities.
--
-- @param _BuildingID EntityID des Gebäudes
-- @within Internal
-- @local
--
function BundleDestructionControl.Local.DeleteEntityStateBuilding(_BuildingID)
    local eType = Logic.GetEntityType(_BuildingID);
    local eName = Logic.GetEntityName(_BuildingID);
    local tID   = GetTerritoryUnderEntity(_BuildingID);

    if Logic.IsConstructionComplete(_BuildingID) == 1 then
        -- Prüfe auf Namen
        if Inside(eName, BundleDestructionControl.Local.Data.Entities) then
            GUI.CancelBuildingKnockDown(_BuildingID);
            return;
        end

        -- Prüfe auf Typen
        if Inside(eType, BundleDestructionControl.Local.Data.EntityTypes) then
            GUI.CancelBuildingKnockDown(_BuildingID);
            return;
        end

        -- Prüfe auf Territorien
        if Inside(tID, BundleDestructionControl.Local.Data.OnTerritory) then
            GUI.CancelBuildingKnockDown(_BuildingID);
            return;
        end

        -- Prüfe auf Category
        for k,v in pairs(BundleDestructionControl.Local.Data.EntityCategories) do
            if Logic.IsEntityInCategory(_BuildingID, v) == 1 then
                GUI.CancelBuildingKnockDown(_BuildingID);
                return;
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleDestructionControl");

