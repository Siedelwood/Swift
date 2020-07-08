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
-- @within Modulbeschreibung
-- @set sort=true
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
-- @param[type=string] _entry Nicht abreißbares Entity
-- @within Anwenderfunktionen
--
-- @usage API.ProtectEntity("bakery");
--
function API.ProtectEntity(_entry)
    if not GUI then
        Logic.ExecuteInLuaLocalState([[
            API.ProtectEntity("]]..tostring(_entry)..[[")
        ]]);
    else
        if not Inside(_entry, BundleDestructionControl.Local.Data.Entities) then
            table.insert(BundleDestructionControl.Local.Data.Entities, _entry);
            info("API.ProtectEntity: Adding " ..tostring(_entry).. " to protected list.");
        end
    end
end

---
-- Fügt einen Entitytyp hinzu, der nicht abgerissen werden darf.
--
-- @param[type=number] _entry Nicht abreißbarer Typ
-- @within Anwenderfunktionen
--
-- @usage API.ProtectEntityType(Entities.B_Bakery);
--
function API.ProtectEntityType(_entry)
    if not GUI then
        Logic.ExecuteInLuaLocalState([[
            API.ProtectEntityType(]]..tostring(_entry)..[[)
        ]]);
    else
        if not Inside(_entry, BundleDestructionControl.Local.Data.EntityTypes) then
            table.insert(BundleDestructionControl.Local.Data.EntityTypes, _entry);
            info("API.ProtectEntityType: Adding " ..tostring(_entry).. " to protected list.");
        end
    end
end

---
-- Fügt eine Kategorie hinzu, die nicht abgerissen werden darf.
--
-- @param[type=number] _entry Nicht abreißbare Kategorie
-- @within Anwenderfunktionen
--
-- @usage API.ProtectCategory(EntityCategories.CityBuilding);
--
function API.ProtectCategory(_entry)
    if not GUI then
        Logic.ExecuteInLuaLocalState([[
            API.ProtectCategory(]]..tostring(_entry)..[[)
        ]]);
    else
        if not Inside(_entry, BundleDestructionControl.Local.Data.EntityCategories) then
            table.insert(BundleDestructionControl.Local.Data.EntityCategories, _entry);
            info("API.ProtectCategory: Adding " ..tostring(_entry).. " to protected list.");
        end
    end
end

---
-- Fügt ein Territory hinzu, auf dem nichts abgerissen werden kann.
--
-- @param[type=number] _entry Geschütztes Territorium
-- @within Anwenderfunktionen
--
-- @usage API.ProtectTerritory(1);
--
function API.ProtectTerritory(_entry)
    if not GUI then
        Logic.ExecuteInLuaLocalState([[
            API.ProtectTerritory(]]..tostring(_entry)..[[)
        ]]);
    else
        if not Inside(_entry, BundleDestructionControl.Local.Data.OnTerritory) then
            table.insert(BundleDestructionControl.Local.Data.OnTerritory, _entry);
            info("API.ProtectTerritory: Adding " ..tostring(_entry).. " to protected list.");
        end
    end
end

---
-- Entfernt ein Entity, dass nicht abgerissen werden darf.
--
-- @param[type=string] _entry Nicht abreißbares Entity
-- @within Anwenderfunktionen
--
-- @usage API.UnprotectEntity("bakery");
--
function API.UnprotectEntity(_entry)
    if not GUI then
        Logic.ExecuteInLuaLocalState([[
            API.UnprotectEntity("]]..tostring(_entry)..[[")
        ]]);
    else
        for i=1,#BundleDestructionControl.Local.Data.Entities do
            if BundleDestructionControl.Local.Data.Entities[i] == _entry then
                table.remove(BundleDestructionControl.Local.Data.Entities, i);
                info("API.UnprotectEntity: Remove " ..tostring(_entry).. " from protected list.");
                return;
            end
        end
    end
end

---
-- Entfernt einen Entitytyp, der nicht abgerissen werden darf.
--
-- @param[type=number] _entry Nicht abreißbarer Typ
-- @within Anwenderfunktionen
--
-- @usage API.UnprotectEntityType(Entities.B_Bakery);
--
function API.UnprotectEntityType(_entry)
    if not GUI then
        Logic.ExecuteInLuaLocalState([[
            API.UnprotectEntityType(]]..tostring(_entry)..[[)
        ]]);
    else
        for i=1,#BundleDestructionControl.Local.Data.EntityTypes do
            if BundleDestructionControl.Local.Data.EntityTypes[i] == _entry then
                table.remove(BundleDestructionControl.Local.Data.EntityTypes, i);
                info("API.UnprotectEntityType: Remove " ..tostring(_entry).. " from protected list.");
                return;
            end
        end
    end
end

---
-- Entfernt eine Kategorie, die nicht abgerissen werden darf.
--
-- @param[type=number] _entry Nicht abreißbare Kategorie
-- @within Anwenderfunktionen
--
-- @usage API.UnprotectCategory(EntityCategories.CityBuilding);
--
function API.UnprotectCategory(_entry)
    if not GUI then
        Logic.ExecuteInLuaLocalState([[
            API.UnprotectCategory(]]..tostring(_entry)..[[)
        ]]);
    else
        for i=1,#BundleDestructionControl.Local.Data.EntityCategories do
            if BundleDestructionControl.Local.Data.EntityCategories[i] == _entry then
                table.remove(BundleDestructionControl.Local.Data.EntityCategories, i);
                info("API.UnprotectCategory: Remove " ..tostring(_entry).. " from protected list.");
                return;
            end
        end
    end
end

---
-- Entfernt ein Territory, auf dem nichts abgerissen werden kann.
--
-- @param[type=number] _entry Geschütztes Territorium
-- @within Anwenderfunktionen
--
-- @usage API.UnprotectTerritory(1);
--
function API.UnprotectTerritory(_entry)
    if not GUI then
        Logic.ExecuteInLuaLocalState([[
            API.UnprotectTerritory(]]..tostring(_entry)..[[)
        ]]);
    else
        for i=1,#BundleDestructionControl.Local.Data.OnTerritory do
            if BundleDestructionControl.Local.Data.OnTerritory[i] == _entry then
                table.remove(BundleDestructionControl.Local.Data.OnTerritory, i);
                info("API.UnprotectTerritory: Remove " ..tostring(_entry).. " from protected list.");
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
-- @param[type=number] _BuildingID EntityID des Gebäudes
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

