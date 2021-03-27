-- Interaction API ---------------------------------------------------------- --

---
-- Dieses Modul erweitert die Interaktionsmöglichkeiten mit Objekten und
-- Siedlern.
--
-- <u>NPC - Ansprechbare Siedler:</u><br/>
-- Die Helden eines Spielers können mit diesen NPCs sprechen.
-- Dazu muss der Held selektiert sein. Dann kann der Spieler ihm mit einem
-- Rechtsklick befehlen, den NPC anzusprechen. Dabei wird der Mauszeiger zu
-- einer Hand.
--
-- Ein NPC wird durch ein leichtes Glitzern auf der Spielwelt hervorgehoben.
--
-- <u>NPO - Benutzbare Objecte:</u><br/>
-- Interaktive Objekte sind Gegenstände auf der Karte, mit denen interagiert
-- werden kann. Diese Interaktion geschieht über einen Button.
-- Es ist möglich, beliebige Objekte zu interaktiven Objekten zu machen.
--
-- Die Einsatzmöglichkeiten sind vielfältig. Wenn ein Gegenstand oder ein
-- Objekt mit einer Funktion versehen ist, kann dies in verschiedenem Kontext
-- an die Geschichte angepasst werden: z.B. Helbel öffnen eine Geheimtür,
-- ein Gegenstand wird vom Helden aufgehoben, eine Tür wird geöffnet, ...
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- <li><a href="Swift_1_InterfaceCore.api.html">(1) Interface Core</a></li>
-- <li><a href="Swift_1_ScriptingValueCore.api.html">(1) Scripting Value Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Erstellt einen neuen NPC für den angegebenen Siedler.
--
-- Der NPC wird sofort aktiviert und kann angesprochen werden. Er wird durch
-- eine glitzernde Aura hervorgehoben.
--
-- Mögliche Einstellungen für den NPC:
-- <table border="1">
-- <tr>
-- <th><b>Eigenschaft</b></th>
-- <th><b>Beschreibung</b></th>
-- </tr>
-- <tr>
-- <td>Name</td>
-- <td>Stringname des Siedlers, der zum NPC werden soll.</td>
-- </tr>
-- <tr>
-- <td>Hero</td>
-- <td>Skriptname eines Helden, mit dem der NPC sprechen will.</td>
-- </tr>
-- <tr>
-- <td>WrongHeroMessage</td>
-- <td>Eine optionale Nachricht, wenn der falsche Held angesprochen wird.</td>
-- </tr>
-- <tr>
-- <td>Callback</td>
-- <td>Eine Funktion, die aufgerufen wird, wenn der NPC angesprochen wird.</td>
-- </tr>
-- <tr>
-- <td>Reposition</td>
-- <td>Standardmäßig aktiv. Schaltet die Neupositionierung und Neuausrichtung
-- der Charaktere an/aus.</td>
-- </tr>
-- </table>
--
-- <p><b>Alias:</b> CreateNPC</p>
--
-- @param[type=table] _Data Nichtspieler-Charakter
-- @return[type=table] NonPlayerCharacter Objekt
-- @within Anwenderfunktionen
--
-- @usage
-- API.NpcCompose {
--     Name     = "horst",
--     Callback = function(_Npc, _Hero)
--        -- Hier kann was passieren
--     end,
-- }
--
function API.NpcCompose(_Data)
    local WronHeroCallback = function(_Npc)
        if _Npc.WrongHeroMessage then
            API.Note(_Npc.WrongHeroMessage);
        end
    end

    local NPC = QSB.NonPlayerCharacter:New(_Data.Name);
    NPC:SetDialogPartner(_Data.Hero);
    NPC:SetWrongPartnerCallback(WronHeroCallback);
    NPC:SetCallback(_Data.Callback);
    NPC:SetType(_Data.Type or 1);
    if  ModuleInteractionCore.Global.UseRepositionByDefault
    and _Data.Reposition == nil then
        _Data.Reposition = true;
    end
    NPC:SetRepositionOnAction(_Data.Reposition);
    return NPC:Activate();
end
CreateNPC = API.NpcCompose;

---
-- Entfernt den NPC komplett vom Entity. Das Entity bleibt dabei erhalten.
--
-- <p><b>Alias:</b> DestroyNPC</p>
--
-- @param _Entity Nichtspieler-Charakter (Skriptname oder ID)
-- @within Anwenderfunktionen
--
-- @usage
-- API.NpcDispose("horst")
--
function API.NpcDispose(_Entity)
    local ScriptName = Logic.GetEntityName(GetID(_Entity));
    local NPC = QSB.NonPlayerCharacter:GetInstance(ScriptName);
    if not NPC then
        return;
    end
    NPC:Dispose();
end
DestroyNPC = API.NpcDispose;

---
-- Aktiviert einen inaktiven NPC. Wenn ein NPC bereits gesprochen hat, muss
-- er zuvor zurückgesetzt werden.
--
-- <p><b>Alias:</b> EnableNPC</P>
--
-- @param _Entity Nichtspieler-Charakter (Skriptname oder ID)
-- @within Anwenderfunktionen
--
-- @usage
-- API.NpcActivate("horst")
--
function API.NpcActivate(_Entity)
    local ScriptName = Logic.GetEntityName(GetID(_Entity));
    local NPC = QSB.NonPlayerCharacter:GetInstance(ScriptName);
    if not NPC then
        return;
    end
    NPC:Activate();
end
EnableNPC = API.NpcActivate;

---
-- Deaktiviert einen NPC, sodass dieser nicht angesprochen werden kann.
--
-- <p><b>Alias:</b> DisableNPC</P>
--
-- @param _Entity Nichtspieler-Charakter (Skriptname oder ID)
-- @within Anwenderfunktionen
--
-- @usage
-- API.NpcDeactivate("horst")
--
function API.NpcDeactivate(_Entity)
    local ScriptName = Logic.GetEntityName(GetID(_Entity));
    local NPC = QSB.NonPlayerCharacter:GetInstance(ScriptName);
    if not NPC then
        return;
    end
    NPC:Deactivate();
end
DisableNPC = API.NpcDeactivate;

---
-- Setzt einen NPC zurück, sodass er nicht mehr als angesprochen gilt.
--
-- <p><b>Alias:</b> ResetNPC<p>
--
-- @param _Entity Nichtspieler-Charakter (Skriptname oder ID)
-- @within Anwenderfunktionen
--
-- @usage
-- API.NpcReset("horst")
--
function API.NpcReset(_Entity)
    local ScriptName = Logic.GetEntityName(GetID(_Entity));
    local NPC = QSB.NonPlayerCharacter:GetInstance(ScriptName);
    if not NPC then
        return;
    end
    NPC:Reset();
end
ResetNPC = API.NpcReset;

---
-- Prüft, ob der NPC bereits angesprochen wurde. Wenn ein Ansprechpartner
-- vorgegeben ist, muss dieser den NPC ansprechen.
--
-- <p><b>Alias:</b> TalkedToNPC</p>
--
-- @param _Entity Nichtspieler-Charakter (Skriptname oder ID)
-- @return[type=boolean] NPC wurde angesprochen
-- @within Anwenderfunktionen
--
-- @usage
-- API.NpcHasSpoken("horst")
--
function API.NpcHasSpoken(_Entity)
    local ScriptName = Logic.GetEntityName(GetID(_Entity));
    local NPC = QSB.NonPlayerCharacter:GetInstance(ScriptName);
    if not NPC then
        return;
    end
    return NPC:HasTalkedTo();
end
TalkedToNPC = API.NpcHasSpoken;

---
-- Setzt die Repositionierung von Charakteren per Default aktiv oder inaktiv.
-- Der Default wird verwendet, wenn nicht explizit im NPC angegeben.
--
-- @param[type=boolean] _Flag Repositionierung an/aus
-- @within Anwenderfunktionen
--
function API.SetUseRepositionByDefault(_Flag)
    ModuleInteractionCore.Global.UseRepositionByDefault = _Flag == true;
end

---
-- Erzeugt ein interaktives Objekt.
--
-- Die Parameter des interaktiven Objektes werden durch seine Beschreibung
-- festgelegt. Die Beschreibung ist eine Table, die bestimmte Werte für das
-- Objekt beinhaltet. Dabei müssen nicht immer alle Werte angegeben werden.
--
-- Mögliche Angaben:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Beschreibung</b></td>
-- <td><b>Optional</b></td>
-- </tr>
-- <tr>
-- <td>Name</td>
-- <td>Der Skriptname des Entity, das zum interaktiven Objekt wird.</td>
-- <td>nein</td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>Der angezeigter Name im Beschreibungsfeld.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>Der Beschreibungstext, der im Tooltip angezeigt wird.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Texture</td>
-- <td>Bestimmt die Icongrafik, die angezeigt wird. Dabei kann es sich um
-- eine Ingame-Grafik oder eine eigene Grafik halten.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Distance</td>
-- <td>Die minimale Entfernung zum Objekt, die ein Held benötigt um das
-- objekt zu aktivieren.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Waittime</td>
-- <td>Die Zeit, die ein Held benötigt, um das Objekt zu aktivieren. Die
-- Wartezeit ist nur für I_X_ Entities verfügbar.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Costs</td>
-- <td>Eine Table mit dem Typ und der Menge der Kosten.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Reward</td>
-- <td>Der Warentyp und die Menge der gefundenen Waren im Objekt.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Callback</td>
-- <td>Eine Funktion, die ausgeführt wird, sobald das Objekt aktiviert wird.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Condition</td>
-- <td>Eine Funktion, die vor der Aktivierung eine Beringung prüft.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>State</td>
-- <td>Bestimmt, wie sich der Button des interaktiven Objektes verhält.</td>
-- <td>ja</td>
-- </tr>
-- </table>
--
-- Zusätzlich können beliebige weitere Felder an das Objekt angehangen
-- werden. Sie sind ausnahmslos im Callback und in der Condition des Objektes
-- abrufbar.
--
-- <p><b>Alias:</b> CreateObject</p>
--
-- @param[type=table] _Description Beschreibung
-- @within Anwenderfunktionen
--
-- @usage
-- -- Ein einfaches Objekt erstellen:
-- CreateObject {
--     Name     = "hut",
--     Distance = 1500,
--     Callback = function(_Data)
--         API.Note("Do something...");
--     end,
-- }
--
function API.CreateObject(_Description)
    if GUI then
        return;
    end
    return ModuleInteractionCore.Global:CreateObject(_Description);
end
CreateObject = API.CreateObject;

---
-- Aktiviert ein Interaktives Objekt, sodass es vom Spieler
-- aktiviert werden kann.
--
-- Der State bestimmt, ob es immer aktiviert werden kann, oder ob der Spieler
-- einen Helden benutzen muss. Wird der Parameter weggelassen, muss immer ein
-- Held das Objekt aktivieren.
--
-- <p><b>Alias</b>: InteractiveObjectActivate</p>
--
-- @param[type=string] _EntityName Skriptname des Objektes
-- @param[type=number] _State      State des Objektes
-- @within Anwenderfunktionen
--
function API.InteractiveObjectActivate(_ScriptName, _State)
    if not IO[_ScriptName] then
        API.ActivateIO(_ScriptName, _State);
        return;
    end
    local ScriptName = (IO[_ScriptName].m_Slave or _ScriptName);
    if IO[_ScriptName].m_Slave then
        IO_SlaveState[ScriptName] = 1;
    end
    API.ActivateIO(ScriptName, _State);
    IO[_ScriptName]:SetActive(true);
end
InteractiveObjectActivate = API.InteractiveObjectActivate;

---
-- Deaktiviert ein interaktives Objekt, sodass es nicht mehr vom Spieler
-- benutzt werden kann.
--
-- <p><b>Alias</b>: InteractiveObjectDeactivate</p>
--
-- @param[type=string] _EntityName Scriptname des Objektes
-- @within Anwenderfunktionen
--
function API.InteractiveObjectDeactivate(_ScriptName)
    if not IO[_ScriptName] then
        API.DeactivateIO(_ScriptName);
        return;
    end
    local ScriptName = (IO[_ScriptName].m_Slave or _ScriptName);
    if IO[_ScriptName].m_Slave then
        IO_SlaveState[ScriptName] = 0;
    end
    API.DeactivateIO(ScriptName);
    IO[_ScriptName]:SetActive(false);
end
InteractiveObjectDeactivate = API.InteractiveObjectDeactivate;

---
-- Erzeugt eine Beschriftung für Custom Objects.
--
-- Im Questfenster werden die Namen von Custom Objects als ungesetzt angezeigt.
-- Mit dieser Funktion kann ein Name angelegt werden.
--
-- <p><b>Alias:</b> AddCustomIOName</p>
--
-- @param[type=string] _Key  Typname des Entity
-- @param              _Text Text der Beschriftung
-- @within Anwenderfunktionen
--
-- @usage
-- API.InteractiveObjectSetName("D_X_ChestClosed", {de = "Schatztruhe", en = "Treasure");
-- API.InteractiveObjectSetName("D_X_ChestOpenEmpty", "Leere Schatztruhe");
--
function API.InteractiveObjectSetName(_Key, _Text)
    _Text = API.ConvertPlaceholders(API.Localize(_Text));
    if GUI then
        return;
    end
    IO_UserDefindedNames[_Key] = _Text;
end
AddCustomIOName = API.InteractiveObjectSetName;

