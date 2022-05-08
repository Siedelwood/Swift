--[[
Swift_2_EntitySearch/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Stellt eine bessere Suche nach Entities bereit.
--
-- Die Suche nach Entities, speziell solcher ohne eine Kategorie oder eines
-- Spielers, gestaltet sich oft schwer. Dieses Mudul wartet mit einer neuen
-- Suchmethode auf, die garantiert alle Entities findet und keine Grenzen
-- kennt.
--
-- Die Suche nach Entities wird über Prädikate gesteuert. Ein Prädikat ist ein
-- Kriterium, dass das Ergebnis der Entity-Suche anhand von Paramern enschränkt.
-- Dabei gibt es Prädikate, welche schneller als andere abgearbeitet werden.
-- Die Reihenfolge, in der sie gelistet werden, ist also wichtig.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_0_Core.api.html">(0) Core</a></li>
-- <li><a href="Swift_1_EntityEventCore.api.html">(1) Entity Event Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=false
--

---
-- Mögliche Prädikate für die Suche.
--
-- @field OfID (_ID) - Schränkt auf eine bestimmte EntityID ein.
-- @field OfName (_Name) - Schränkt auf eine bestimmten Skriptnamen ein.
-- @field OfNamePrefix (_Prefix) - Schränkt auf Entities ein, deren Name mit dem Präfix beginnt.
-- @field OfNameSuffix (_Suffix) - Schränkt auf Entities ein, deren Name mit dem Suffix endet.
-- @field OfType (_Type) - Schränkt auf Entities mit dem Typen ein.
-- @field OfCategory (_Category) - Schränkt auf Entities mit der Kategorie ein.
-- @field InArea (_X, _Y, _AreaSize) - Schränkt auf Entities im Gebiet ein.
-- @field InTerritory (_Territory) - Schränkt auf Entities im Territorium.
--
-- Predikate können verknüpft werden über Operatoren.
-- <ul>
-- <li>NOT (_Predicate) - Negiert das Ergebnis des Prädikat.</li>
-- <li>ALL (...) - Alle Prädikate müssen wahr sein.</li>
-- <li>ANY (...) - Mindestes ein Prädikat muss wahr sein</li>
-- <li>XOR (...) - Exklusiv 1 aus allen Predikaten muss wahr sein.</li>
-- </ul>
--
-- @see API.CommenceEntitySearch
--
QSB.Search = QSB.Search or {};

-- -------------------------------------------------------------------------- --

---
-- Findet <u>alle</u> Entities.
--
-- Die Suche kann optional auf einen Spieler beschränkt werden.
--
-- <b>Hinweis</b>: Im Multiplayer kann diese Funktion nur in synchron
-- ausgeführtem Code benutzt werden, da es sonst zu Desyncs komm.
--
-- @param[type=number] _PlayerID (Optional) ID des Besitzers
-- @return[type=table] Liste mit Ergebnissen
-- @within Anwenderfunktionen
-- @see API.CommenceEntitySearch
--
-- @usage
-- -- ALLE Entities
-- local Result = API.SearchEntities();
-- -- Alle Entities von Spieler 5.
-- local Result = API.SearchEntities(5);
--
function API.SearchEntities(_PlayerID)
    if _PlayerID then
        return API.CommenceEntitySearch(
            {QSB.Search.OfPlayer, _PlayerID}
        );
    end
    return API.CommenceEntitySearch();
end

---
-- Findet alle Entities in einem Gebiet.
--
-- <b>Hinweis</b>: Im Multiplayer kann diese Funktion nur in synchron
-- ausgeführtem Code benutzt werden, da es sonst zu Desyncs komm.
--
-- @param[type=number] _Area     Größe des Suchgebiet
-- @param              _Position Mittelpunkt (EntityID, Skriptname oder Table)
-- @param[type=number] _PlayerID (Optional) ID des Besitzers
-- @param[type=number] _Type     (Optional) Typ des Entity
-- @param[type=number] _Category (Optional) Category des Entity
-- @return[type=table] Liste mit Ergebnissen
-- @within Anwenderfunktionen
-- @see API.CommenceEntitySearch
--
-- @usage
-- local Result = API.SearchEntitiesInArea(5000, "Busches", 0, Entities.R_HerbBush);
--
function API.SearchEntitiesInArea(_Area, _Position, _PlayerID, _Type, _Category)
    local Position = _Position;
    if type(Position) ~= "table" then
        Position = GetPosition(Position);
    end
    local Predicates = {
        {QSB.Search.InArea, Position.X, Position.Y, _Area}
    }
    if _Type then
        table.insert(Predicates, 1, {QSB.Search.OfType, _Type});
    end
    if _Category then
        table.insert(Predicates, 1, {QSB.Search.OfCategory, _Category});
    end
    if _PlayerID then
        table.insert(Predicates, 1, {QSB.Search.OfPlayer, _PlayerID});
    end
    return API.CommenceEntitySearch(unpack(Predicates));
end

---
-- Findet alle Entities in einem Territorium.
--
-- <b>Hinweis</b>: Im Multiplayer kann diese Funktion nur in synchron
-- ausgeführtem Code benutzt werden, da es sonst zu Desyncs komm.
--
-- @param[type=number] _Territory Territorium für die Suche
-- @param[type=number] _PlayerID  (Optional) ID des Besitzers
-- @param[type=number] _Type      (Optional) Typ des Entity
-- @param[type=number] _Category  (Optional) Category des Entity
-- @return[type=table] Liste mit Ergebnissen
-- @within Anwenderfunktionen
-- @see API.CommenceEntitySearch
--
-- @usage
-- local Result = API.SearchEntitiesInTerritory(7, 0, Entities.R_HerbBush);
--
function API.SearchEntitiesInTerritory(_Territory, _PlayerID, _Type, _Category)
    local Predicates = {
        {QSB.Search.InTerritory, _Territory}
    }
    if _Type then
        table.insert(Predicates, {QSB.Search.OfType, _Type});
    end
    if _Category then
        table.insert(Predicates, {QSB.Search.OfCategory, _Category});
    end
    if _PlayerID then
        table.insert(Predicates, {QSB.Search.OfPlayer, _PlayerID});
    end
    return API.CommenceEntitySearch(unpack(Predicates));
end

---
-- Führt eine benutzerdefinierte Suche nach Entities aus.
--
-- <b>Achtung</b>: Die Reihenfolge der angewandten Predikate hat maßgeblichen
-- Einfluss auf die Dauer der Suche. Während Abfragen auf den Besitzer oder
-- den Typ schnell gehen, dauern Gebietssuchen lange! Es ist daher klug, zuerst
-- Kriterien auszuschließen, die schnell bestimmt werden!
--
-- <b>Hinweis</b>: Im Multiplayer kann diese Funktion nur in synchron
-- ausgeführtem Code benutzt werden, da es sonst zu Desyncs komm.
--
-- @param[type=table] ... Liste mit Suchprädikaten
-- @return[type=table] Liste mit Ergebnissen
-- @within Anwenderfunktionen
-- @see QSB.Search
--
-- @usage
-- -- Es werden alle Kühe und Schafe von Spieler 1 gefunden, die nicht auf den
-- -- Territorien 7 und 15 sind.
-- local Result = API.CommenceEntitySearch(
--     -- Nur Entities von Spieler 1 akzeptieren
--     {QSB.Search.OfPlayer, 1},
--     -- Nur Entities akzeptieren, die Kühe oder Schafe sind.
--     {ANY,
--      {QSB.Search.OfCategory, EntityCategories.SheepPasture},
--      {QSB.Search.OfCategory, EntityCategories.CattlePasture}},
--     -- Nur Entities akzeptieren, die nicht auf den Territorien 7 und 15 sind.
--     {ALL,
--      {NOT, {QSB.Search.InTerritory, 15}},
--      {NOT, {QSB.Search.InTerritory, 7}}}
-- );
--
function API.CommenceEntitySearch(...)
    return ModuleEntitySearch.Shared:IterateEntities(arg);
end

-- Local callbacks

-- FIX: Die höchste ID vom Trigger ermitteln und speichern lassen. Das ist
-- nötig, da die Abfrage über alle Spawner möglicher Weise noch nicht durch
-- ist, wenn der Aufruf ausgeführt wird und somit Entities verpasst werden.
function SCP.EntitySearch.TriggerEntityTrigger()
    local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, 5, 5, 0, 0);
    Logic.DestroyEntity(ID);
end

