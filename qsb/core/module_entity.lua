-- Entities --------------------------------------------------------------------

-- Mögliche (zufällige) Siedler getrennt in männlich und weiblich.
QSB.PossibleSettlerTypes = {
    Male = {
        Entities.U_BannerMaker,
        Entities.U_Baker,
        Entities.U_Barkeeper,
        Entities.U_Blacksmith,
        Entities.U_Butcher,
        Entities.U_BowArmourer,
        Entities.U_BowMaker,
        Entities.U_CandleMaker,
        Entities.U_Carpenter,
        Entities.U_DairyWorker,
        Entities.U_Pharmacist,
        Entities.U_Tanner,
        Entities.U_SmokeHouseWorker,
        Entities.U_Soapmaker,
        Entities.U_SwordSmith,
        Entities.U_Weaver,
    },
    Female = {
        Entities.U_BathWorker,
        Entities.U_SpouseS01,
        Entities.U_SpouseS02,
        Entities.U_SpouseS03,
        Entities.U_SpouseF01,
        Entities.U_SpouseF02,
        Entities.U_SpouseF03,
    }
}

-- API Stuff --

---
-- Wählt aus einer Liste von Typen einen zufälligen Siedler-Typ aus. Es werden
-- nur Stadtsiedler zurückgegeben. Sie können männlich oder weiblich sein.
--
-- @return[type=number] Zufälliger Typ
-- @within Anwenderfunktionen
-- @local
--
function API.GetRandomSettlerType()
    local Gender = (math.random(1, 2) == 1 and "Male") or "Female";
    local Type   = math.random(1, #QSB.PossibleSettlerTypes[Gender]);
    return QSB.PossibleSettlerTypes[Gender][Type];
end

---
-- Wählt aus einer Liste von Typen einen zufälligen männlichen Siedler aus. Es
-- werden nur Stadtsiedler zurückgegeben.
--
-- @return[type=number] Zufälliger Typ
-- @within Anwenderfunktionen
-- @local
--
function API.GetRandomMaleSettlerType()
    local Type = math.random(1, #QSB.PossibleSettlerTypes.Male);
    return QSB.PossibleSettlerTypes.Male[Type];
end

---
-- Wählt aus einer Liste von Typen einen zufälligen weiblichen Siedler aus. Es
-- werden nur Stadtsiedler zurückgegeben.
--
-- @return[type=number] Zufälliger Typ
-- @within Anwenderfunktionen
-- @local
--
function API.GetRandomFemaleSettlerType()
    local Type = math.random(1, #QSB.PossibleSettlerTypes.Female);
    return QSB.PossibleSettlerTypes.Female[Type];
end

---
-- Sendet einen Handelskarren zu dem Spieler. Startet der Karren von einem
-- Gebäude, wird immer die Position des Eingangs genommen.
--
-- <p><b>Alias:</b> SendCart</p>
--
-- @param _position                        Position (Skriptname oder Positionstable)
-- @param[type=number] _player             Zielspieler
-- @param[type=number] _good               Warentyp
-- @param[type=number] _amount             Warenmenge
-- @param[type=number] _cartOverlay        (optional) Overlay für Goldkarren
-- @param[type=boolean] _ignoreReservation (optional) Marktplatzreservation ignorieren
-- @return[type=number] Entity-ID des erzeugten Wagens
-- @within Anwenderfunktionen
-- @usage -- API-Call
-- API.SendCart(Logic.GetStoreHouse(1), 2, Goods.G_Grain, 45)
-- -- Legacy-Call mit ID-Speicherung
-- local ID = SendCart("Position_1", 5, Goods.G_Wool, 5)
--
function API.SendCart(_position, _player, _good, _amount, _cartOverlay, _ignoreReservation)
    local eID = GetID(_position);
    if not IsExisting(eID) then
        return;
    end
    local ID;
    local x,y,z = Logic.EntityGetPos(eID);
    local resCat = Logic.GetGoodCategoryForGoodType(_good);
    local orientation = 0;
    if Logic.IsBuilding(eID) == 1 then
        x,y = Logic.GetBuildingApproachPosition(eID);
        orientation = Logic.GetEntityOrientation(eID)-90;
    end

    -- Macht Waren lagerbar im Lagerhaus
    if resCat == GoodCategories.GC_Resource or _good == Goods.G_None then
        local TypeName = Logic.GetGoodTypeName(_good);
        local Category = Logic.GetGoodCategoryForGoodType(_good);
        local SHID = Logic.GetStoreHouse(_player);
        local HQID = Logic.GetHeadquarters(_player);
        if SHID ~= 0 and Logic.GetIndexOnInStockByGoodType(SHID, _good) == -1 then
            local CreateSlot = true;
            if _good ~= Goods.G_Gold or (_good == Goods.G_Gold and HQID == 0) then
                info(
                    "API.SendCart: creating stock for " ..TypeName.. " in" ..
                    "storehouse of player " .._player.. "."
                );
                Logic.AddGoodToStock(SHID, _good, 0, true, true);
            end
        end
    end

    info("API.SendCart: Creating cart ("..
        tostring(_position) ..","..
        tostring(_player) ..","..
        Logic.GetGoodTypeName(_good) ..","..
        tostring(_amount) ..","..
        tostring(_cartOverlay) ..","..
        tostring(_ignoreReservation) ..
    ")");

    if resCat == GoodCategories.GC_Resource then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_ResourceMerchant, x, y,orientation,_player)
    elseif _good == Goods.G_Medicine then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Medicus, x, y,orientation,_player)
    elseif _good == Goods.G_Gold or _good == Goods.G_None or _good == Goods.G_Information then
        if _cartOverlay then
            ID = Logic.CreateEntityOnUnblockedLand(_cartOverlay, x, y,orientation,_player)
        else
            ID = Logic.CreateEntityOnUnblockedLand(Entities.U_GoldCart, x, y,orientation,_player)
        end
    else
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Marketer, x, y,orientation,_player)
    end
    info("API.SendCart: Executing hire merchant...");
    Logic.HireMerchant( ID, _player, _good, _amount, _player, _ignoreReservation)
    info("API.SendCart: Cart has been send successfully.");
    return ID
end
SendCart = API.SendCart;

---
-- Ersetzt ein Entity mit einem neuen eines anderen Typs. Skriptname,
-- Rotation, Position und Besitzer werden übernommen.
--
-- <b>Hinweis</b>: Die Entity-ID ändert sich und beim Ersetzen von
-- Spezialgebäuden kann eine Niederlage erfolgen.
--
-- <p><b>Alias:</b> ReplaceEntity</p>
--
-- @param _Entity      Entity (Skriptname oder ID)
-- @param[type=number] _Type     Neuer Typ
-- @param[type=number] _NewOwner (optional) Neuer Besitzer
-- @return[type=number] Entity-ID des Entity
-- @within Anwenderfunktionen
-- @usage API.ReplaceEntity("Stein", Entities.XD_ScriptEntity)
--
function API.ReplaceEntity(_Entity, _Type, _NewOwner)
    local eID = GetID(_Entity);
    if eID == 0 then
        return;
    end
    local pos = GetPosition(eID);
    local player = _NewOwner or Logic.EntityGetPlayer(eID);
    local orientation = Logic.GetEntityOrientation(eID);
    local name = Logic.GetEntityName(eID);
    DestroyEntity(eID);
    info("API.ReplaceEntity: Replacing entity " ..tostring(_Entity).. " to type " ..Logic.GetEntityTypeName(_Type).. ".");
    if Logic.IsEntityTypeInCategory(_Type, EntityCategories.Soldier) == 1 then
        return CreateBattalion(player, _Type, pos.X, pos.Y, 1, name, orientation);
    else
        return CreateEntity(player, _Type, pos, name, orientation);
    end
end
ReplaceEntity = API.ReplaceEntity;

---
-- Rotiert ein Entity, sodass es zum Ziel schaut.
--
-- <p><b>Alias:</b> LookAt</p>
--
-- @param _entity         Entity (Skriptname oder ID)
-- @param _entityToLookAt Ziel (Skriptname oder ID)
-- @param[type=number]    _offsetEntity Winkel Offset
-- @within Anwenderfunktionen
-- @usage API.LookAt("Hakim", "Alandra")
--
function API.LookAt(_entity, _entityToLookAt, _offsetEntity)
    local entity = GetEntityId(_entity);
    local entityTLA = GetEntityId(_entityToLookAt);
    if not IsExisting(entity) or not IsExisting(entityTLA) then
        warn("API.LookAt: One entity is invalid or dead!");
        return;
    end
    local eX, eY = Logic.GetEntityPosition(entity);
    local eTLAX, eTLAY = Logic.GetEntityPosition(entityTLA);
    local orientation = math.deg( math.atan2( (eTLAY - eY) , (eTLAX - eX) ) );
    if Logic.IsBuilding(entity) == 1 then
        orientation = orientation - 90;
    end
    _offsetEntity = _offsetEntity or 0;
    info("API.LookAt: Entity " ..entity.. " is looking at " ..entityTLA);
    Logic.SetOrientation(entity, API.Round(orientation + _offsetEntity));
end
LookAt = API.LookAt;

---
-- Lässt zwei Entities sich gegenseitig anschauen.
--
-- @param _entity         Entity (Skriptname oder ID)
-- @param _entityToLookAt Ziel (Skriptname oder ID)
-- @within Anwenderfunktionen
-- @usage API.Confront("Hakim", "Alandra")
--
function API.Confront(_entity, _entityToLookAt)
    API.LookAt(_entity, _entityToLookAt);
    API.LookAt(_entityToLookAt, _entity);
end

---
-- Bestimmt die Distanz zwischen zwei Punkten. Es können Entity-IDs,
-- Skriptnamen oder Positionstables angegeben werden.
--
-- Wenn die Distanz nicht bestimmt werden kann, wird -1 zurückgegeben.
--
-- <p><b>Alias:</b> GetDistance</p>
--
-- @param _pos1 Erste Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @param _pos2 Zweite Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @return[type=number] Entfernung zwischen den Punkten
-- @within Anwenderfunktionen
-- @usage local Distance = API.GetDistance("HQ1", Logic.GetKnightID(1))
--
function API.GetDistance( _pos1, _pos2 )
    if (type(_pos1) == "string") or (type(_pos1) == "number") then
        _pos1 = GetPosition(_pos1);
    end
    if (type(_pos2) == "string") or (type(_pos2) == "number") then
        _pos2 = GetPosition(_pos2);
    end
    if type(_pos1) ~= "table" or type(_pos2) ~= "table" then
        warn("API.GetDistance: Distance could not be calculated!");
        return -1;
    end
    local xDistance = (_pos1.X - _pos2.X);
    local yDistance = (_pos1.Y - _pos2.Y);
    return math.sqrt((xDistance^2) + (yDistance^2));
end
GetDistance = API.GetDistance;

---
-- Prüft, ob eine Positionstabelle eine gültige Position enthält.
--
-- Eine Position ist Ungültig, wenn sie sich nicht auf der Welt befindet.
-- Das ist der Fall bei negativen Werten oder Werten, welche die Größe
-- der Welt übersteigen.
--
-- <p><b>Alias:</b> IsValidPosition</p>
--
-- @param[type=table] _pos Positionstable {X= x, Y= y}
-- @return[type=boolean] Position ist valide
-- @within Anwenderfunktionen
--
function API.ValidatePosition(_pos)
    if type(_pos) == "table" then
        if (_pos.X ~= nil and type(_pos.X) == "number") and (_pos.Y ~= nil and type(_pos.Y) == "number") then
            local world = {Logic.WorldGetSize()}
            if _pos.Z and _pos.Z < 0 then
                return false;
            end
            if _pos.X <= world[1] and _pos.X >= 0 and _pos.Y <= world[2] and _pos.Y >= 0 then
                return true;
            end
        end
    end
    return false;
end
IsValidPosition = API.ValidatePosition;

---
-- Lokalisiert ein Entity auf der Map. Es können sowohl Skriptnamen als auch
-- IDs verwendet werden. Wenn das Entity nicht gefunden wird, wird eine
-- Tabelle mit XYZ = 0 zurückgegeben.
--
-- <p><b>Alias:</b> GetPosition</p>
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=table] Positionstabelle {X= x, Y= y, Z= z}
-- @within Anwenderfunktionen
-- @usage local Position = API.LocateEntity("Hans")
--
function API.LocateEntity(_Entity)
    if (type(_Entity) == "table") then
        return _Entity;
    end
    if (not IsExisting(_Entity)) then
        warn("API.LocateEntity: Entity (" ..tostring(_Entity).. ") does not exist!");
        return {X= 0, Y= 0, Z= 0};
    end
    local x, y, z = Logic.EntityGetPos(GetID(_Entity));
    return {X= API.Round(x), Y= API.Round(y), Z= API.Round(y)};
end
GetPosition = API.LocateEntity;

---
-- Aktiviert ein interaktives Objekt, sodass es benutzt werden kann.
--
-- Der State bestimmt, ob es immer aktiviert werden kann, oder ob der Spieler
-- einen Helden benutzen muss. Wird der Parameter weggelassen, muss immer ein
-- Held das Objekt aktivieren.
--
-- <p><b>Alias:</b> InteractiveObjectActivate</p>
--
-- @param[type=string] _ScriptName  Skriptname des IO
-- @param[type=number] _State       Aktivierungszustand
-- @within Anwenderfunktionen
-- @usage API.ActivateIO("Haus1", 0)
-- API.ActivateIO("Hut1")
--
function API.ActivateIO(_ScriptName, _State)
    _State = _State or 0;
    if GUI then
        GUI.SendScriptCommand('API.ActivateIO("' .._ScriptName.. '", ' .._State..')');
        return;
    end
    if not IsExisting(_ScriptName) then
        error("API.ActivateIO: Entity (" ..tostring(_ScriptName).. ") does not exist!");
        return;
    end
    Logic.InteractiveObjectSetAvailability(GetID(_ScriptName), true);
    for i = 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), i, _State);
    end
end
InteractiveObjectActivate = API.ActivateIO;

---
-- Deaktiviert ein Interaktives Objekt, sodass es nicht mehr vom Spieler
-- aktiviert werden kann.
--
-- <p><b>Alias:</b> InteractiveObjectDeactivate</p>
--
-- @param[type=string] _ScriptName Skriptname des IO
-- @within Anwenderfunktionen
-- @usage API.DeactivateIO("Hut1")
--
function API.DeactivateIO(_ScriptName)
    if GUI then
        GUI.SendScriptCommand('API.DeactivateIO("' .._ScriptName.. '")');
        return;
    end
    if not IsExisting(_ScriptName) then
        error("API.DeactivateIO: Entity (" ..tostring(_ScriptName).. ") does not exist!");
        return;
    end
    Logic.InteractiveObjectSetAvailability(GetID(_ScriptName), false);
    for i = 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), i, 2);
    end
end
InteractiveObjectDeactivate = API.DeactivateIO;

---
-- Ermittelt alle Entities in der Kategorie auf dem Territorium und gibt
-- sie als Liste zurück.
--
-- <p><b>Alias:</b> GetEntitiesOfCategoryInTerritory</p>
--
-- @param[type=number] _player    PlayerID [0-8] oder -1 für alle
-- @param[type=number] _category  Kategorie, der die Entities angehören
-- @param[type=number] _territory Zielterritorium
-- @within Anwenderfunktionen
-- @usage local Found = API.GetEntitiesOfCategoryInTerritory(1, EntityCategories.Hero, 5)
--
function API.GetEntitiesOfCategoryInTerritory(_player, _category, _territory)
    local PlayerEntities = {};
    local Units = {};
    if (_player == -1) then
        for i=0,8 do
            local NumLast = 0;
            repeat
                Units = { Logic.GetEntitiesOfCategoryInTerritory(_territory, i, _category, NumLast) };
                PlayerEntities = Array_Append(PlayerEntities, Units);
                NumLast = NumLast + #Units;
            until #Units == 0;
        end
    else
        local NumLast = 0;
        repeat
            Units = { Logic.GetEntitiesOfCategoryInTerritory(_territory, _player, _category, NumLast) };
            PlayerEntities = Array_Append(PlayerEntities, Units);
            NumLast = NumLast + #Units;
        until #Units == 0;
    end
    return PlayerEntities;
end
GetEntitiesOfCategoryInTerritory = API.GetEntitiesOfCategoryInTerritory;

---
-- Gibt dem Entity einen eindeutigen Skriptnamen und gibt ihn zurück.
-- Hat das Entity einen Namen, bleibt dieser unverändert und wird
-- zurückgegeben.
-- @param[type=number] _EntityID Entity ID
-- @return[type=string] Skriptname
-- @within Anwenderfunktionen
--
function API.EnsureScriptName(_EntityID)
    if type(_EntityID) == "string" then
        return _EntityID;
    else
        assert(type(_EntityID) == "number");
        local name = Logic.GetEntityName(_EntityID);
        if (type(name) ~= "string" or name == "" ) then
            QSB.GiveEntityNameCounter = (QSB.GiveEntityNameCounter or 0)+ 1;
            name = "EnsureScriptName_Name_"..QSB.GiveEntityNameCounter;
            Logic.SetEntityName(_EntityID, name);
        end
        return name;
    end
end
GiveEntityName = API.EnsureScriptName;

