-- Display API -------------------------------------------------------------- --

---
-- Dieses Modul bietet rudimentäre Funktionen zur Veränderung des Interface und
-- einen allgemeinen Black Screen für die Darstellung verschiedener Effekte.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="core.api.html">Core</a></li>
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

