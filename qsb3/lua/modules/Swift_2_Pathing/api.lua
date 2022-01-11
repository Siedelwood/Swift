--[[
Swift_2_MilitaryLimit/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- 
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_0_Core.api.html">(0) Core</a></li>
-- <li><a href="Swift_1_JobsCore.api.html">(1) JobsCore</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field PathFindingFinished Ein Pfad wurde erfolgreich gefunden (Parameter: PathIndex)
-- @field PathFindingFailed   Ein Pfad konnte nicht ermittelt werden (Parameter: PathIndex)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

