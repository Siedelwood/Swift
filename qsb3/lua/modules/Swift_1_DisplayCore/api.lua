-- Display API -------------------------------------------------------------- --

---
-- Dieses Modul bietet rudimentäre Funktionen zur Veränderung des Interface und
-- einen allgemeinen Black Screen für die Darstellung verschiedener Effekte.
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
-- Blendet einen schwarzen Hintergrund über der Spielwelt aber hinter dem
-- Interface ein.
--
-- @within Anwenderfunktionen
--
function API.ActivateBlackScreen()
    if not GUI then
        Logic.ExecuteInLuaLocalState("ModuleDisplayCore.Local:InterfaceActivateBlackBackground()");
        return;
    end
    ModuleDisplayCore.Local:InterfaceActivateBlackBackground();
end

---
-- Deaktiviert den schwarzen Hintergrund, wenn er angezeigt wird.
--
-- @within Anwenderfunktionen
--
function API.DeactivateBlackScreen()
    if not GUI then
        Logic.ExecuteInLuaLocalState("ModuleDisplayCore.Local:InterfaceDeactivateBlackBackground()");
        return;
    end
    ModuleDisplayCore.Local:InterfaceDeactivateBlackBackground();
end

---
-- Zeigt das normale Interface an.
--
-- @within Anwenderfunktionen
--
function API.ActivateNormalInterface()
    if not GUI then
        Logic.ExecuteInLuaLocalState("ModuleDisplayCore.Local:InterfaceActivateNormalInterface()");
        return;
    end
    ModuleDisplayCore.Local:InterfaceActivateNormalInterface();
end

---
-- Blendet das normale Interface aus.
--
-- @within Anwenderfunktionen
--
function API.DeactivateNormalInterface()
    if not GUI then
        Logic.ExecuteInLuaLocalState("ModuleDisplayCore.Local:InterfaceDeactivateNormalInterface()");
        return;
    end
    ModuleDisplayCore.Local:InterfaceDeactivateNormalInterface();
end

---
-- Aktiviert den Cinematic State und sagt dem Framework, dass jetzt ein Effekt
-- im Kinomodus aktiv ist.
--
-- @within Anwenderfunktionen
--
function API.ActivateCinematicState()
    Logic.ExecuteInLuaLocalState("ModuleDisplayCore.Shared.CinematicState = true");
    ModuleDisplayCore.Shared.CinematicState = true;
end

---
-- Deaktiviert den Cinematic State und teilt dem Framework mit, dass der
-- Kinomodus jetzt beendet wurde.
--
-- @within Anwenderfunktionen
--
function API.DeactivateCinematicState()
    Logic.ExecuteInLuaLocalState("ModuleDisplayCore.Shared.CinematicState = false");
    ModuleDisplayCore.Shared.CinematicState = false;
end

---
-- Gibt zurück, ob gerade ein Effekt im Kinomodus läuft.
-- @return[type=boolean] Cinematic State ist Aktiv
-- @within Anwenderfunktionen
--
function API.IsCinematicState()
    return ModuleDisplayCore.Shared.CinematicState == true;
end

