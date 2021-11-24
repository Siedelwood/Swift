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
-- @field EntityCreated Ein Entity wurde erzeugt (Parameter: EntityID, PlayerID)
-- @field EntityDestroyed Ein Entity wurde zerstört (Parameter: EntityID, PlayerID)
-- @field EntityHurt Ein Entity wurde angegriffen (Parameter: HurtEntityID, HurtPlayerID, HurtingPlayerID, HurtingEntityID, DamageOriginal, DamageReceived)
-- @field EntityKilled Ein Entity wurde getötet (Parameter: KilledEntityID, KilledPlayerID, KillerPlayerID, KillerEntityID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};



