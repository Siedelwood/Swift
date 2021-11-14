--[[
Swift_2_ObjectInteraction/API

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Dieses Modul erweitert die Interaktionsmöglichkeiten mit Objekten.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- <li><a href="Swift_1_InterfaceCore.api.html">(1) Interface Core</a></li>
-- <li><a href="Swift_1_InputOutputCore.api.html">(1) Input/Output Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field ObjectClicked     Der Spieler klickt auf den Button des IO (Parameter: EntityID, KnightID, PlayerID)
-- @field ObjectInteraction Es wird mit einem interaktiven Objekt interagiert (Parameter: EntityID, KnightID, PlayerID)
-- @field ObjectDelete      Eine Interaktion wird von einem Objekt entfernt (Parameter: ScriptName)
-- @field ObjectReset       Der Zustand eines interaktiven Objekt wird zurückgesetzt (Parameter: ScriptName)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Erzeugt ein einfaches interaktives Objekt.
--
-- Dabei können alle Entities als interaktive Objekte behandelt werden, nicht
-- nur die, die eigentlich dafür vorgesehen sind.
--
-- Die Parameter des interaktiven Objektes werden durch seine Beschreibung
-- festgelegt. Die Beschreibung ist eine Table, die bestimmte Werte für das
-- Objekt beinhaltet. Dabei müssen nicht immer alle Werte angegeben werden.
--
-- Mögliche Angaben:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- <td><b>Optional</b></td>
-- </tr>
-- <tr>
-- <td>Name</td>
-- <td>string</td>
-- <td>Der Skriptname des Entity, das zum interaktiven Objekt wird.</td>
-- <td>nein</td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>string</td>
-- <td>Angezeigter Titel des Objekt</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string</td>
-- <td>Angezeigte Beschreibung des Objekt</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Distance</td>
-- <td>number</td>
-- <td>Die minimale Entfernung zum Objekt, die ein Held benötigt um das
-- objekt zu aktivieren.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Waittime</td>
-- <td>number</td>
-- <td>Die Zeit, die ein Held benötigt, um das Objekt zu aktivieren.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Costs</td>
-- <td></td>
-- <td>Eine Table mit dem Typ und der Menge der Kosten. (Format: {Typ, Menge, Typ, Menge})</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Reward</td>
-- <td>table</td>
-- <td>Der Warentyp und die Menge der gefundenen Waren im Objekt. (Format: {Typ, Menge})</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>State</td>
-- <td>number</td>
-- <td>Bestimmt, wie sich der Button des interaktiven Objektes verhält.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Condition</td>
-- <td>function</td>
-- <td>Eine zusätzliche Aktivierungsbedinung als Funktion.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>ConditionInfo</td>
-- <td>string</td>
-- <td>Nachricht, die angezeigt wird, wenn die Bedinung nicht erfüllt ist.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>function</td>
-- <td>Eine Funktion, die nach der Aktivierung aufgerufen wird.</td>
-- <td>ja</td>
-- </tr>
-- </table>
--
-- @param[type=table] _Description Beschreibung
-- @within Anwenderfunktionen
-- @see API.ResetObject
-- @see API.InteractiveObjectActivate
-- @see API.InteractiveObjectDeactivate
--
-- @usage
-- API.SetupObject {
--     Name     = "hut",
--     Distance = 1500,
--     Reward   = {Goods.G_Gold, 1000},
-- };
--
function API.SetupObject(_Description)
    if GUI then
        return;
    end
    return ModuleObjectInteraction.Global:CreateObject(_Description);
end
API.CreateObject = API.SetupObject;
CreateObject = API.SetupObject;

---
-- Zerstört die Interation mit dem Objekt.
--
-- <b>Hinweis</b>: Das Entity selbst wird nicht zerstört.
--
-- @param[type=string] _ScriptName Skriptname des Objektes
-- @see API.SetupObject
-- @see API.ResetObject
-- @usage API.ResetObject("MyObject");
--
function API.DisposeObject(_ScriptName)
    if GUI or not IO[_ScriptName] then
        return;
    end
    ModuleObjectInteraction.Global:DestroyObject(_ScriptName);
end
ResetObject = API.ResetObject;

---
-- Setzt das interaktive Objekt zurück. Dadurch verhält es sich, wie vor der
-- Aktivierung durch den Spieler.
--
-- <b>Hinweis</b>: Das Objekt muss wieder per Skript aktiviert werden, damit es
-- im Spiel ausgelöst werden.
--
-- @param[type=string] _ScriptName Skriptname des Objektes
-- @within Anwenderfunktionen
-- @see API.SetupObject
-- @see API.InteractiveObjectActivate
-- @see API.InteractiveObjectDeactivate
-- @usage API.ResetObject("MyObject");
--
function API.ResetObject(_ScriptName)
    if GUI or not IO[_ScriptName] then
        return;
    end
    ModuleObjectInteraction.Global:ResetObject(_ScriptName);
    API.InteractiveObjectDeactivate(_ScriptName);
end
ResetObject = API.ResetObject;

---
-- Aktiviert ein Interaktives Objekt, sodass es von den Spielern
-- aktiviert werden kann.
--
-- Optional kann das Objekt nur für einen bestimmten Spieler aktiviert werden.
--
-- Der State bestimmt, ob es immer aktiviert werden kann, oder ob der Spieler
-- einen Helden benutzen muss. Wird der Parameter weggelassen, muss immer ein
-- Held das Objekt aktivieren.
--
-- @param[type=string] _EntityName Skriptname des Objektes
-- @param[type=number] _State      State des Objektes
-- @param[type=number] _PlayerID   (Optional) Spieler-ID
-- @within Anwenderfunktionen
--
function API.InteractiveObjectActivate(_ScriptName, _State, _PlayerID)
    _State = _State or 0;
    if GUI then
        return;
    end
    if IO[_ScriptName] then
        local SlaveName = (IO[_ScriptName].Slave or _ScriptName);
        if IO[_ScriptName].Slave then
            IO_SlaveState[SlaveName] = 1;
        end
        ModuleObjectInteraction.Global:SetObjectAvailability(SlaveName, _State, _PlayerID);
        IO[_ScriptName].IsActive = true;
    else
        ModuleObjectInteraction.Global:SetObjectAvailability(_ScriptName, _State, _PlayerID);
    end
end
InteractiveObjectActivate = API.InteractiveObjectActivate;

---
-- Deaktiviert ein interaktives Objekt, sodass es nicht mehr von den Spielern
-- benutzt werden kann.
--
-- Optional kann das Objekt nur für einen bestimmten Spieler deaktiviert werden.
--
-- @param[type=string] _EntityName Scriptname des Objektes
-- @param[type=number] _PlayerID   (Optional) Spieler-ID
-- @within Anwenderfunktionen
--
function API.InteractiveObjectDeactivate(_ScriptName, _PlayerID)
    if GUI then
        return;
    end
    if IO[_ScriptName] then
        local SlaveName = (IO[_ScriptName].Slave or _ScriptName);
        if IO[_ScriptName].Slave then
            IO_SlaveState[SlaveName] = 0;
        end
        ModuleObjectInteraction.Global:SetObjectAvailability(SlaveName, 2, _PlayerID);
        IO[_ScriptName].IsActive = false;
    else
        ModuleObjectInteraction.Global:SetObjectAvailability(_ScriptName, 2, _PlayerID);
    end
end
InteractiveObjectDeactivate = API.InteractiveObjectDeactivate;

---
-- Erzeugt eine Beschriftung für Custom Objects.
--
-- Im Questfenster werden die Namen von Custom Objects als ungesetzt angezeigt.
-- Mit dieser Funktion kann ein Name angelegt werden.
--
-- @param[type=string] _Key  Typname des Entity
-- @param              _Text Text der Beschriftung
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetObjectCustomName("D_X_ChestClosed", {de = "Schatztruhe", en = "Treasure"});
-- API.SetObjectCustomName("D_X_ChestOpenEmpty", "Leere Schatztruhe");
--
function API.SetObjectCustomName(_Key, _Text)
    _Text = API.ConvertPlaceholders(API.Localize(_Text));
    if GUI then
        return;
    end
    IO_UserDefindedNames[_Key] = _Text;
end
API.InteractiveObjectSetName = API.SetObjectCustomName;
AddCustomIOName = API.SetObjectCustomName;

