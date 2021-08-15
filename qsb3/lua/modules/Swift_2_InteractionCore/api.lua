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
function API.NpcUseRepositionByDefault(_Flag)
    ModuleInteractionCore.Global.UseRepositionByDefault = _Flag == true;
end

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
-- <td><b>Beschreibung</b></td>
-- <td><b>Optional</b></td>
-- </tr>
-- <tr>
-- <td>Name</td>
-- <td>Der Skriptname des Entity, das zum interaktiven Objekt wird.</td>
-- <td>nein</td>
-- </tr>
-- <tr>
-- <td>Distance</td>
-- <td>Die minimale Entfernung zum Objekt, die ein Held benötigt um das
-- objekt zu aktivieren.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Waittime</td>
-- <td>Die Zeit, die ein Held benötigt, um das Objekt zu aktivieren.</td>
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
-- <td>State</td>
-- <td>Bestimmt, wie sich der Button des interaktiven Objektes verhält.</td>
-- <td>ja</td>
-- </tr>
-- </table>
--
-- <p><b>Alias:</b> API.CreateObject</p>
-- <p><b>Alias:</b> CreateObject</p>
--
-- @param[type=table] _Description Beschreibung
-- @within Anwenderfunktionen
-- @see API.SetObjectUnused
-- @see API.InteractiveObjectActivate
-- @see API.InteractiveObjectDeactivate
-- @see API.SetObjectHeadline
-- @see API.SetObjectDescription
-- @see API.SetObjectDisabledText
-- @see API.SetObjectIcon
-- @see API.SetObjectCondition
-- @see API.SetObjectCallback
--
-- @usage
-- CreateObject {
--     Name     = "hut",
--     Distance = 1500,
--     Reward   = {Goods.G_Gold, 1000},
-- };
--
function API.SetupObject(_Description)
    if GUI then
        return;
    end
    return ModuleInteractionCore.Global:CreateObject(_Description);
end
API.CreateObject = API.SetupObject;
CreateObject = API.SetupObject;

---
-- Setzt den Benutzt-Status eines interaktiven Objektes zurück. Das Objekt muss
-- dann wieder per Skript aktiviert werden, damit es im Spiel ausgelöst werden.
--
-- @param[type=string] _ScriptName Skriptname des Objekt 
-- @within Anwenderfunktionen
-- @see API.SetObjectUnused
-- @see API.InteractiveObjectActivate
-- @see API.InteractiveObjectDeactivate
-- @usage API.SetObjectUnused("MyObject");
--
function API.SetObjectUnused(_ScriptName)
    if GUI or not IO[_ScriptName] then
        return;
    end
    ModuleInteractionCore.Global:ResetObject(IO[_ScriptName]);
    API.InteractiveObjectDeactivate(_ScriptName);
end
ResetObject = API.SetObjectUnused;

---
-- Ändert den angezeigten Titel eines interaktiven Objecktes.
--
-- Der übergebene Text kann ein normaler Text sein, ein Stringtable-Eintrag,
-- eine lokalisierte Table oder eine Funktion, welche den Text bestimmt.
--
-- @param[type=string] _ScriptName Skriptname des Objekt 
-- @param              _Text       Angezeigter Text
-- @within Anwenderfunktionen
-- @see API.SetupObject
-- @usage -- Fester Text
-- API.SetObjectHeadline("MyObject", "Titel");
-- -- Lokalisierter Text
-- API.SetObjectHeadline("MyObject", {de = "Titel", en = "Title"});
-- -- Stringtable-Eintrag
-- API.SetObjectHeadline("MyObject", "UI_ObjectNames/B_PalisadeGate");
-- -- Eigene Funktion
-- API.SetObjectHeadline("MyObject", function(_Name, _ObjectID, _PlayerID)
--     if SomeCondition then
--         return {de = "Titel", en = "Title"};
--     end
--     return "UI_ObjectNames/InteractiveObjectAvailable";
-- end);
--
function API.SetObjectHeadline(_ScriptName, _Text)
    if GUI then
        return;
    end
    if not IsExisting(_ScriptName) then
        error("API.SetObjectHeadline: Object " ..tostring(_ScriptName).. " does not exist!");
        return;
    end
    ModuleInteractionCore.Global:SetObjectLambda(_ScriptName, "ObjectHeadline", _Text);
end

---
-- Ändert den angezeigten Text eines interaktiven Objecktes.
--
-- Der übergebene Text kann ein normaler Text sein, ein Stringtable-Eintrag,
-- eine lokalisierte Table oder eine Funktion, welche den Text bestimmt.
--
-- @param[type=string] _ScriptName Skriptname des Objekt 
-- @param              _Text       Angezeigter Text
-- @within Anwenderfunktionen
-- @see API.SetupObject
-- @usage -- Fester Text
-- API.SetObjectDescription("MyObject", "Das ist ein Text");
-- -- Lokalisierter Text
-- API.SetObjectDescription("MyObject", {de = "Das ist ein Text", en = "This is some text"});
-- -- Stringtable-Eintrag
-- API.SetObjectDescription("MyObject", "UI_ObjectDescription/B_PalisadeGate");
-- -- Eigene Funktion
-- API.SetObjectDescription("MyObject", function(_Name, _ObjectID, _PlayerID)
--     if SomeCondition then
--         return {de = "Das ist ein Text", en = "This is some text"};
--     end
--     return "UI_ObjectDescription/InteractiveObjectAvailable";
-- end);
--
function API.SetObjectDescription(_ScriptName, _Text)
    if GUI then
        return;
    end
    if not IsExisting(_ScriptName) then
        error("API.SetObjectDescription: Object " ..tostring(_ScriptName).. " does not exist!");
        return;
    end
    ModuleInteractionCore.Global:SetObjectLambda(_ScriptName, "ObjectDescription", _Text);
end

---
-- Ändert den angezeigten Grund, dass ein Objekt nicht verfügbar ist.
--
-- Der übergebene Text kann ein normaler Text sein, ein Stringtable-Eintrag,
-- eine lokalisierte Table oder eine Funktion, welche den Text bestimmt.
--
-- @param[type=string] _ScriptName Skriptname des Objekt 
-- @param              _Text       Angezeigter Text
-- @within Anwenderfunktionen
-- @see API.SetupObject
-- @usage -- Fester Text
-- API.SetObjectDisabledText("MyObject", "Das ist der Grund");
-- -- Lokalisierter Text
-- API.SetObjectDisabledText("MyObject", {de = "Das ist der Grund", en = "That's the reason"});
-- -- Stringtable-Eintrag
-- API.SetObjectDisabledText("MyObject", "UI_ButtonDisabled/InteractiveObjectAvailable");
-- -- Eigene Funktion
-- API.SetObjectDisabledText("MyObject", function(_Name, _ObjectID, _PlayerID)
--     if SomeCondition then
--         return {de = "Das ist der Grund", en = "That's the reason"};
--     end
--     return "UI_ButtonDisabled/InteractiveObjectAvailable";
-- end);
--
function API.SetObjectDisabledText(_ScriptName, _Text)
    if GUI then
        return;
    end
    if not IsExisting(_ScriptName) then
        error("API.SetObjectDisabledText: Object " ..tostring(_ScriptName).. " does not exist!");
        return;
    end
    ModuleInteractionCore.Global:SetObjectLambda(_ScriptName, "ObjectDisabledText", _Text);
end

---
-- Ändert das angezeigte Icon des Buttons.
--
-- Es kann entweder die Icon Matrix übergeben werden oder eine Funktion, die
-- eine Icon Matrix zurück gibt.
--
-- @param[type=string] _ScriptName Skriptname des Objekt
-- @param              _Icon       Verwendetes Icon
-- @within Anwenderfunktionen
-- @see API.SetupObject
-- @usage -- Festes Icon
-- API.SetObjectIcon("MyObject", {1, 1});
-- -- Eigene Funktion
-- API.SetObjectIcon("MyObject", function(_Name, _ObjectID, _PlayerID)
--     if SomeCondition then
--         return {1, 4};
--     end
--     return {1, 1};
-- end);
--
function API.SetObjectIcon(_ScriptName, _Icon)
    if GUI then
        return;
    end
    if not IsExisting(_ScriptName) then
        error("API.SetObjectIcon: Object " ..tostring(_ScriptName).. " does not exist!");
        return;
    end
    ModuleInteractionCore.Global:SetObjectLambda(_ScriptName, "ObjectIconTexture", _Icon);
end

---
-- Setzt die Aktivierungsbedingung für das interaktive Objekt.
--
-- Die Funktion muss true zurückgeben, wenn das Objekt aktiviert werden kann,
-- sonst false.
--
-- @param[type=string]   _ScriptName Skriptname des Objekt
-- @param[type=function] _Lambda     Funktion
-- @within Anwenderfunktionen
-- @see API.SetupObject
-- @usage API.SetObjectCondition("MyObject", function(_Name, _ObjectID, _PlayerID)
--     if _PlayerID == 1 then
--         return true;
--     end
--     return false;
-- end);
--
function API.SetObjectCondition(_ScriptName, _Lambda)
    if GUI then
        return;
    end
    if not IsExisting(_ScriptName) then
        error("API.SetObjectCondition: Object " ..tostring(_ScriptName).. " does not exist!");
        return;
    end
    ModuleInteractionCore.Global:SetObjectLambda(_ScriptName, "ObjectCondition", _Lambda);
end

---
-- Setzt die Aktion bei erfolgreicher Aktivierung des interaktiven Objekt.
--
-- @param[type=string]   _ScriptName Skriptname des Objekt
-- @param[type=function] _Lambda     Funktion
-- @within Anwenderfunktionen
-- @see API.SetupObject
-- @usage API.SetObjectCallback("MyObject", function(_Name, _ObjectID, _PlayerID)
--     -- Mach was hier
-- end);
--
function API.SetObjectCallback(_ScriptName, _Lambda)
    if GUI then
        return;
    end
    if not IsExisting(_ScriptName) then
        error("API.SetObjectCallback: Object " ..tostring(_ScriptName).. " does not exist!");
        return;
    end
    ModuleInteractionCore.Global:SetObjectLambda(_ScriptName, "ObjectClickAction", _Lambda);
end

---
-- Aktiviert ein Interaktives Objekt, sodass es vom Spieler
-- aktiviert werden kann.
--
-- Optional kann das Objekt nur für einen bestimmten Spieler aktiviert werden.
--
-- Der State bestimmt, ob es immer aktiviert werden kann, oder ob der Spieler
-- einen Helden benutzen muss. Wird der Parameter weggelassen, muss immer ein
-- Held das Objekt aktivieren.
--
-- <p><b>Alias</b>: InteractiveObjectActivate</p>
--
-- @param[type=string] _EntityName Skriptname des Objektes
-- @param[type=number] _State      State des Objektes
-- @param[type=number] _PlayerID   (Optional) Spieler-ID
-- @within Anwenderfunktionen
--
function API.InteractiveObjectActivate(_ScriptName, _State, _PlayerID)
    _State = _State or 0;
    if IO[_ScriptName] then
        local SlaveName = (IO[_ScriptName].m_Slave or _ScriptName);
        if IO[_ScriptName].m_Slave then
            IO_SlaveState[SlaveName] = 1;
        end
        ModuleInteractionCore.Global:SetObjectAvailability(SlaveName, _State, _PlayerID);
        IO[_ScriptName]:SetActive(true);
    else
        ModuleInteractionCore.Global:SetObjectAvailability(_ScriptName, _State, _PlayerID);
    end
end
InteractiveObjectActivate = API.InteractiveObjectActivate;

---
-- Deaktiviert ein interaktives Objekt, sodass es nicht mehr vom Spieler
-- benutzt werden kann.
--
-- Optional kann das Objekt nur für einen bestimmten Spieler deaktiviert werden.
--
-- <p><b>Alias</b>: InteractiveObjectDeactivate</p>
--
-- @param[type=string] _EntityName Scriptname des Objektes
-- @param[type=number] _PlayerID   (Optional) Spieler-ID
-- @within Anwenderfunktionen
--
function API.InteractiveObjectDeactivate(_ScriptName, _PlayerID)
    if IO[_ScriptName] then
        local SlaveName = (IO[_ScriptName].m_Slave or _ScriptName);
        if IO[_ScriptName].m_Slave then
            IO_SlaveState[SlaveName] = 0;
        end
        ModuleInteractionCore.Global:SetObjectAvailability(SlaveName, 2, _PlayerID);
        IO[_ScriptName]:SetActive(false);
    else
        ModuleInteractionCore.Global:SetObjectAvailability(_ScriptName, 2, _PlayerID);
    end
end
InteractiveObjectDeactivate = API.InteractiveObjectDeactivate;

---
-- Erzeugt eine Beschriftung für Custom Objects.
--
-- Im Questfenster werden die Namen von Custom Objects als ungesetzt angezeigt.
-- Mit dieser Funktion kann ein Name angelegt werden.
--
-- <p><b>Alias:</b> API.SetObjectCustomName</p>
-- <p><b>Alias:</b> AddCustomIOName</p>
--
-- @param[type=string] _Key  Typname des Entity
-- @param              _Text Text der Beschriftung
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetObjectCustomName("D_X_ChestClosed", {de = "Schatztruhe", en = "Treasure");
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

