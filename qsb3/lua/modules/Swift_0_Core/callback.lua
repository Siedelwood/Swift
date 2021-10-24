--[[
Swift_0_Core/User

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Erzeugt Game Callbacks zur Handhabung von Script Events.
--
-- Script Events werden von den Modulen der QSB geworfen, um anderen Modulen
-- mitzuteilen, dass gerade etwas passiert wurde. Sie können aber ebenfalls
-- vom Mapper genutzt werden. Es ist auch möglich, neue Events zu erstellen
-- und zu verwenden.
--
-- Script Events werden immer sowohl im globalen als auch lokalen Skript
-- ausgeführt. Dabei i.d.R. zuerst global, dann lokal.
--
-- Die verfügbaren Events eines Moduls werden in der API gelistet.
--
-- @within Beschreibung
-- @set sort=true
--

function Swift:InitalizeCallbackGlobal()
    self:CreateUserCallbacks();
end

function Swift:InitalizeCallbackLocal()
    self:CreateUserCallbacks();
end

function Swift:CreateUserCallbacks()
    ---
    -- Wird aufgerufen, wenn ein beliebiges Event empfangen wird.
    --
    -- Wenn ein Event empfangen wird, kann es sein, dass Parameter mit übergeben
    -- werden. Um für alle Events gewappnet zu sein, muss der Listener als
    -- Varargs-Funktion, also mit ... in der Parameterliste geschrieben werden.
    --
    -- Zugegriffen wird auf die Parameter, indem die Parameterliste entsprechend
    -- indexiert wird. Für Parameter 1 wird dann arg[1] geschrieben usw.
    --
    -- @param[type=number] _EventID ID des Event
    -- @param              ...      Parameterliste des Event
    -- @within Listener
    --
    -- @usage
    -- GameCallback_QSB_OnEventReceived = function(_EventID, ...)
    --     if _EventID == QSB.ScriptEvents.EscapePressed then
    --         API.AddNote("Player " ..arg[1].. " has pressed Escape!");
    --     elseif _EventID == QSB.ScriptEvents.SaveGameLoaded then
    --         API.AddNote("A save has been loaded!");
    --     end
    -- end
    --
    GameCallback_QSB_OnEventReceived = function(_EventID, ...)
    end
end