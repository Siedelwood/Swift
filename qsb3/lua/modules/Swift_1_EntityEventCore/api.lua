--[[
Swift_1_DisplayCore/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht das einfache Reagieren auf Ereignisse die Entities betreffen.
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
-- @field EntityCreated Ein Entity wurde erzeugt. Wird auch durch Spieler ändern ausgelöst! (Parameter: EntityID)
-- @field EntityDestroyed Ein Entity wurde zerstört. Wird auch durch Spieler ändern ausgelöst! (Parameter: EntityID)
-- @field EntityHurt Ein Entity wurde angegriffen. (Parameter: HurtEntityID, HurtPlayerID, HurtingEntityID, HurtingPlayerID, DamageOriginal, DamageReceived)
-- @field EntityKilled Ein Entity wurde getötet. (Parameter: KilledEntityID, KilledPlayerID, KillerEntityID, KillerPlayerID)
-- @field EntityOwnerChanged Ein Entity wechselt den Besitzer. (Parameter: OldID, OldPlayer, NewID, OldPlayer)
-- @field EntityResourceChanged Resourcen im Entity verändern sich. (Parameter: EntityID, GoodType, Amount)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};



