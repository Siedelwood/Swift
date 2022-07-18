-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleTerrainAndWater                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --
---@diagnostic disable: undefined-global

---
-- Dieses Bundle beinhaltet Funktionen zur Veränderung der Höhe von Land und
-- von Wasser.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleTerrainAndWater = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Ändert die Bodentextur innerhalb des Quadrates. Offset bestimmt die
-- Abstände der Eckpunkte zum Zentralpunkt.
--
-- <b>Hinweis:</b> Für weitere Informationen zu Terraintexturen siehe
-- https://siedelwood-neu.de/23879-2/
--
-- <b>Alias:</b> TerrainTypeSquare
--
-- @param              _Center Zentralpunkt (Skriptname oder ID)
-- @param[type=number] _Offset Entfernung der Ecken zum Zentrum
-- @param[type=number] _TerrainType Textur ID
-- @within Anwenderfunktionen
--
-- @usage
-- API.ChangeTerrainTypeInSquare("area", 500, 48)
--
function API.ChangeTerrainTypeInSquare(_Center, _Offset, _TerrainType)
    if GUI then
        return;
    end
    if not IsExisting(_Center) then
        log("API.ChangeTerrainTypeInSquare: Central point does not exist!", LEVEL_ERROR);
        return;
    end
    if _Offset < 100 then
        log("API.ChangeTerrainTypeInSquare: Check your offset! It seems to small!", LEVEL_WARNING);
    end
    return BundleTerrainAndWater.Global:ChangeTerrainTypeInSquare(_Center, _Offset, _TerrainType);
end
TerrainTypeSquare = API.ChangeTerrainTypeInSquare;

---
-- Ändert die Wasserhöhe in einem Quadrat. Offset bestimmt die Abstände
-- der Eckpunkte zum Zentrum.
--
-- Wird die relative Höhe verwendet, wird die Wasserhöhe nicht absolut
-- gesetzt sondern von der aktuellen Wasserhöhe ausgegangen.
--
-- <p><b>Alias:</b> WaterHeightSquare</p>
--
-- @param               _Center Zentralpunkt (Skriptname oder ID)
-- @param[type=number]  _Offset Entfernung der Ecken zum Zentrum
-- @param[type=number]  _Height Neue Höhe
-- @param[type=boolean] _Relative Relative Höhe benutzen
-- @within Anwenderfunktionen
--
-- @usage
-- API.ChangeWaterHeightInSquare("area", 500, 5555, true);
--
function API.ChangeWaterHeightInSquare(_Center, _Offset, _Height, _Relative)
    if GUI then
        return;
    end
    if not IsExisting(_Center) then
        log("API.ChangeWaterHeightInSquare: Central point does not exist!", LEVEL_ERROR);
        return;
    end
    if _Offset < 100 then
        log("API.ChangeWaterHeightInSquare: Check your offset! It seems to small!", LEVEL_WARNING);
    end
    return BundleTerrainAndWater.Global:ChangeWaterHeightInSquare(_Center, _Offset, _Height, _Relative);
end
WaterHeightSquare = API.ChangeWaterHeightInSquare;

---
-- Ändert die Landhöhe in einem Quadrat. Offset bestimmt die Abstände
-- der Eckpunkte zum Zentralpunkt.
--
-- Wird die relative Höhe verwendet, wird die Landhöhe nicht absolut
-- gesetzt sondern von der aktuellen Landhöhe ausgegangen. Das Land muss nicht
-- eben sein. Auf diese Weise können Strukturen unverändert angehoben werden.
--
-- <p><b>Alias:</b> TerrainHeightSquare</p>
--
-- @param               _Center Zentralpunkt (Skriptname oder ID)
-- @param[type=number]  _Offset Entfernung der Ecken zum Zentrum
-- @param[type=number]  _Height Neue Höhe
-- @param[type=boolean] _Relative Relative Höhe benutzen
-- @within Anwenderfunktionen
--
-- @usage
-- API.ChangeTerrainHeightInSquare("area", 500, 5555, true);
--
function API.ChangeTerrainHeightInSquare(_Center, _Offset, _Height, _Relative)
    if GUI then
        return;
    end
    if not IsExisting(_Center) then
        log("API.ChangeTerrainHeightInSquare: Central point does not exist!", LEVEL_ERROR);
        return;
    end
    if _Offset < 100 then
        log("API.ChangeTerrainHeightInSquare: Check your offset! It seems to small!", LEVEL_WARNING);
    end
    return BundleTerrainAndWater.Global:ChangeTerrainHeightInSquare(_Center, _Offset, _Height, _Relative);
end
TerrainHeightSquare = API.ChangeTerrainHeightInSquare;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleTerrainAndWater = {
    Global = {
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
function BundleTerrainAndWater.Global:Install()
end 

-- -------------------------------------------------------------------------- --

---
-- Ändert die Bodentextur innerhalb des Quadrates. Offset bestimmt die
-- Abstände der Eckpunkte zum Zentralpunkt.
-- @param              _Center Zentralpunkt (Skriptname oder ID)
-- @param[type=number] _Offset Entfernung der Ecken zum Zentrum
-- @param[type=number] _TerrainType Textur ID
-- @within Internal
-- @local
--
function BundleTerrainAndWater.Global:ChangeTerrainTypeInSquare(_Center, _Offset, _TerrainType)
    local Xmin, Ymin, Xmax, Ymax, z = self:GetSquareForWaterAndTerrain(_Center, _Offset);
    if Xmin == -1 or Xmin == -2 then
        return Xmin;
    end
    if type(_TerrainType) == "number" then
        for x10 = Xmin, Xmax do
            for y10 = Ymin, Ymax do
                Logic.SetTerrainNodeType( x10, y10, _TerrainType );
            end
        end
    end
    Logic.UpdateBlocking( Xmin, Ymin, Xmax, Ymax);
end

---
-- Ändert die Wasserhöhe in einem Quadrat. Offset bestimmt die Abstände
-- der Eckpunkte zum Zentralpunkt.
-- @param               _Center Zentralpunkt (Skriptname oder ID)
-- @param[type=number]  _Offset Entfernung der Ecken zum Zentrum
-- @param[type=number]  _Height Neue Höhe
-- @param[type=boolean] _Relative Relative Höhe benutzen
-- @within Internal
-- @local
--
function BundleTerrainAndWater.Global:ChangeWaterHeightInSquare(_Center, _Offset, _Height, _Relative)
    local Xmin, Ymin, Xmax, Ymax, z = self:GetSquareForWaterAndTerrain(_Center, _Offset);
    if Xmin == -1 or Xmin == -2 then
        return Xmin;
    end
    if not _Relative then
        if _Height < 0 then
            return -3;
        end
        Logic.WaterSetAbsoluteHeight(Xmin, Ymin, Xmax, Ymax, _Height);
    else
        if z+_Height < 0 then
            return -3;
        end
        Logic.WaterSetAbsoluteHeight(Xmin, Ymin, Xmax, Ymax, z+_Height);
    end
    Logic.UpdateBlocking(Xmin, Ymin, Xmax, Ymax);
    return 0;
end

---
-- Ändert die Landhöhe in einem Quadrat. Offset bestimmt die Abstände
-- der Eckpunkte zum Zentralpunkt.
-- @param               _Center Zentralpunkt (Skriptname oder ID)
-- @param[type=number]  _Offset Entfernung der Ecken zum Zentrum
-- @param[type=number]  _Height Neue Höhe
-- @param[type=boolean] _Relative Relative Höhe benutzen
-- @within Internal
-- @local
--
function BundleTerrainAndWater.Global:ChangeTerrainHeightInSquare(_Center, _Offset, _Height, _Relative)
    local Xmin, Ymin, Xmax, Ymax, z = self:GetSquareForWaterAndTerrain(_Center, _Offset);
    if Xmin == -1 or Xmin == -2 then
        return Xmin;
    end
    local Height;
    if not _Relative then
        if _Height < 0 then
            return -3;
        end
        Height = _Height;
    else
        if z+_Height < 0 then
            return -3;
        end
        Height = z+_Height;
    end

    for x10 = Xmin, Xmax do
        for y10 = Ymin, Ymax do
            Logic.SetTerrainNodeHeight(x10, y10, Height);
        end
    end
    Logic.UpdateBlocking(Xmin, Ymin, Xmax, Ymax);
    return 0;
end

---
-- Gibt ein Quadrat für Land- und Wassermanipulation zurück.
--
-- Wird verwendet von: WaterHeight, TerrainHeight, TerrainType
--
-- @param              _Center Zentralpunkt des Quadrat (Skriptname oder ID)
-- @param[type=number] _Offset Abstand der Ecken zum Zentrum
-- @return[type=number] X-Koordinate von Punkt 1
-- @return[type=number] Y-Koordinate von Punkt 1
-- @return[type=number] X-Koordinate von Punkt 2
-- @return[type=number] Y-Koordinate von Punkt 2
-- @return[type=number] Bodenhöhe
-- @within Internal
-- @local
--
function BundleTerrainAndWater.Global:GetSquareForWaterAndTerrain(_Center, _Offset)
    local Type = type(_Center);
    if (Type ~= "string" and Type ~= "number") or not IsExisting(_Center) then
        return -1;
    end
    local Xmin, Ymin, Xmax, Ymax;
    local eID = GetID(_Center);
    local x,y,z = Logic.EntityGetPos(eID);
    Xmin = math.floor((x - _Offset)/100);
    Ymin = math.floor((y - _Offset)/100);
    Xmax = math.floor((x + _Offset)/100);
    Ymax = math.floor((y + _Offset)/100);
    if IsValidPosition({X= Xmin, Y= Ymin}) == false or IsValidPosition({X= Xmax, Y= Ymax}) == false then
        return -2;
    end
    return Xmin, Ymin, Xmax, Ymax, z;
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleTerrainAndWater");

