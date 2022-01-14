--[[
Swift_1_EntityEventCore/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht das einfache Reagieren auf Ereignisse die Entities betreffen.
--
-- <h5>Entity Created</h5>
-- Das Modul bringt eine eigene Implementierung des Entity Created Event mit
-- sich, da das originale Event des Spiels nicht funktioniert.
--
-- <h5>Diebstahleffekte</h5>
-- Die Effekte von Diebstählen können deaktiviert und mittels Event neu
-- geschrieben werden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_0_Core.api.html">(0) Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field EntityRegistered Ein Entity wurde erzeugt. Wird auch durch Spieler ändern ausgelöst! (Parameter: EntityID)
-- @field EntityDestroyed Ein Entity wurde zerstört. Wird auch durch Spieler ändern ausgelöst! (Parameter: EntityID)
-- @field EntityHurt Ein Entity wurde angegriffen. (Parameter: HurtEntityID, HurtPlayerID, HurtingEntityID, HurtingPlayerID, DamageOriginal, DamageReceived)
-- @field EntityKilled Ein Entity wurde getötet. (Parameter: KilledEntityID, KilledPlayerID, KillerEntityID, KillerPlayerID)
-- @field EntityOwnerChanged Ein Entity wechselt den Besitzer. (Parameter: OldID, OldPlayer, NewID, OldPlayer)
-- @field EntityResourceChanged Resourcen im Entity verändern sich. (Parameter: EntityID, GoodType, Amount)
-- @field BuildingConstructed Ein Gebäude wurde fertiggestellt. (Parameter: PlayerID, BuildingID)
-- @field BuildingUpgraded Ein Gebäude wurde aufgewertet. (Parameter: PlayerID, BuildingID, NewUpgradeLevel)
-- @field ThiefInfiltratedBuilding Ein Dieb hat ein Gebäude infiltriert. (Parameter: ThiefID, PlayerID, BuildingID, BuildingPlayerID)
-- @field ThiefDeliverEarnings Ein Dieb liefert seine Beute ab. (Parameter: ThiefID, PlayerID, BuildingID, BuildingPlayerID, GoldAmount)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Deaktiviert die Standardaktion wenn ein Dieb in ein Lagerhaus eindringt.
--
-- <b>Hinweis</b>: Wird die Standardaktion deaktiviert, stielt der Dieb
-- stattdessen Informationen.
--
-- @param[type=boolean] _Flag Standardeffekt deaktiviert
-- @within Anwenderfunktionen
--
-- @usage
-- -- Deaktivieren
-- API.ThiefDisableStorehouseEffect(true);
-- -- Aktivieren
-- API.ThiefDisableStorehouseEffect(false);
--
function API.ThiefDisableStorehouseEffect(_Flag)
    ModuleEntityEventCore.Global.DisableThiefStorehouseHeist = _Flag == true;
end

---
-- Deaktiviert die Standardaktion wenn ein Dieb in eine Kirche eindringt.
--
-- <b>Hinweis</b>: Wird die Standardaktion deaktiviert, stielt der Dieb
-- stattdessen Informationen.
--
-- @param[type=boolean] _Flag Standardeffekt deaktiviert
-- @within Anwenderfunktionen
--
-- @usage
-- -- Deaktivieren
-- API.ThiefDisableCathedralEffect(true);
-- -- Aktivieren
-- API.ThiefDisableCathedralEffect(false);
--
function API.ThiefDisableCathedralEffect(_Flag)
    ModuleEntityEventCore.Global.DisableThiefCathedralSabotage = _Flag == true;
end

---
-- Deaktiviert die Standardaktion wenn ein Dieb einen Brunnen sabotiert.
--
-- <b>Hinweis</b>: Brunnen können nur im Addon gebaut und sabotiert werden.
--
-- @param[type=boolean] _Flag Standardeffekt deaktiviert
-- @within Anwenderfunktionen
--
-- @usage
-- -- Deaktivieren
-- API.ThiefDisableCisternEffect(true);
-- -- Aktivieren
-- API.ThiefDisableCisternEffect(false);
--
function API.ThiefDisableCisternEffect(_Flag)
    ModuleEntityEventCore.Global.DisableThiefCisternSabotage = _Flag == true;
end

---
-- Bewegt ein Entity zum Zielpunkt und lässt es das Ziel anschauen.
--
-- Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
-- Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.
--
-- Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
-- wird das Event QSB.ScriptEvents.EntityArrived geworfen.
--
-- @param               _Entity         Bewegtes Entity (Skriptname oder ID)
-- @param               _Position       Ziel (Skriptname, ID oder Position)
-- @param               _Target         Angeschaute Position (Skriptname, ID oder Position)
-- @param[type=boolean] _IgnoreBlocking Direkten Weg benutzen
-- @within Anwenderfunktionen
--
function API.MoveEntityAndLookAt(_Entity, _Position, _Target, _IgnoreBlocking)
    local ID1 = GetID(_Entity);
    if not IsExisting(ID1) then
        error("API.MoveEntityAndLookAt: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end
    local ID2 = GetID(_Target);
    if not IsExisting(ID2) then
        error("API.MoveEntityAndLookAt: entity '" ..tostring(_Target).. "' does not exist!");
        return;
    end
    ModuleEntityEventCore.Global.MovingEntities[ID1] = ID2;
    API.MoveEntity(_Entity, _Position, _IgnoreBlocking);
end

---
-- Bewegt ein Entity zum Zielpunkt und führt die Funktion aus.
--
-- Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
-- Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.
--
-- Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
-- wird das Event QSB.ScriptEvents.EntityArrived geworfen.
--
-- @param                _Entity         Bewegtes Entity (Skriptname oder ID)
-- @param                _Target         Ziel (Skriptname, ID oder Position)
-- @param[type=function] _Action         Funktion wenn Entity ankommt
-- @param[type=boolean]  _IgnoreBlocking Direkten Weg benutzen
-- @within Anwenderfunktionen
--
function API.MoveEntityAndExecute(_Entity, _Target, _Action, _IgnoreBlocking)
    local ID1 = GetID(_Entity);
    if not IsExisting(ID1) then
        error("API.MoveEntityAndExecute: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end
    local ID2 = GetID(_Target);
    if not IsExisting(ID2) then
        error("API.MoveEntityAndExecute: entity '" ..tostring(_Target).. "' does not exist!");
        return;
    end
    ModuleEntityEventCore.Global.MovingEntities[ID1] = _Action;
    API.MoveEntity(_Entity, _Target, _IgnoreBlocking);
end

