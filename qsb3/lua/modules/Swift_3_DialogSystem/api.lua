--[[
Swift_3_DialogSystem/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht es Dialoge zu verwenden.
--
-- Dialoge dienen zur Darstellung von Gesprächen. Mit Multiple Choice können
-- dem Spieler mehrere Auswahlmöglichkeiten gegeben, multiple Handlungsstränge
-- gestartet werden. Mittels Sprüngen und Leerseiten kann innerhalb des
-- Dialog navigiert werden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- <li><a href="Swift_2_QuestCore.api.html">(2) Quests Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field DialogStarted        Ein Dialog beginnt (Parameter: PlayerID, DialogTable)
-- @field DialogEnded          Ein Dialog endet (Parameter: PlayerID, DialogTable)
-- @field DialogOptionSelected Eine Multiple Choice Option wurde ausgewählt (Parameter: PlayerID, OptionID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Startet einen Dialog.
--
-- Für einen Dialog können verschiedene spezielle Einstellungen vorgenommen
-- werden.<br>Mögliche Werte:
-- <table border="1">
-- <tr>
-- <td><b>Einstellung</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Starting</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die beim Start des Dialog ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>Finished</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die nach Beendigung des Dialog ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>RestoreCamera</td>
-- <td>boolean</td>
-- <td>(Optional) Stellt die Kameraposition am Ende des Dialog wieder her. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>RestoreGameSpeed</td>
-- <td>boolean</td>
-- <td>(Optional) Stellt die Geschwindigkeit von dor dem Dialog wieder her. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>EnableGlobalImmortality</td>
-- <td>boolean</td>
-- <td>(Optional) Alle Einheiten und Gebäude werden unverwundbar solange der Dialog aktiv ist. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>EnableFoW</td>
-- <td>boolean</td>
-- <td>(Optional) Der Nebel des Krieges während des Dialog anzeigen. <br>Standard: aus</td>
-- </tr>
-- <tr>
-- <td>EnableBorderPins</td>
-- <td>boolean</td>
-- <td>(Optional) Die Grenzsteine während des Dialog anzeigen. <br>Standard: aus</td>
-- </tr>
-- </table>
--
-- @param[type=table]  _Dialog   Definition des Dialog
-- @param[type=string] _Name     Name des Dialog
-- @param[type=number] _PlayerID Empfänger des Dialog
-- @within Anwenderfunktionen
--
-- @usage function Dialog1(_Name, _PlayerID)
--     local Dialog = {
--         DisableFow = true,
--         DisableBoderPins = true,
--     };
--     local AP, ASP = API.AddDialogPages(Dialog);
--
--     -- Aufrufe von AP oder ASP um Seiten zu erstellen
--
--     Dialog.Starting = function(_Data)
--         -- Mach was tolles hier wenn es anfängt.
--     end
--     Dialog.Finished = function(_Data)
--         -- Mach was tolles hier wenn es endet.
--     end
--     API.StartDialog(Dialog, _Name, _PlayerID);
-- end
--
function API.StartDialog(_Dialog, _Name, _PlayerID)
    if GUI then
        return;
    end
    local PlayerID = _PlayerID;
    if not PlayerID and not Framework.IsNetworkGame() then
        PlayerID = QSB.HumanPlayerID;
    end
    assert(_PlayerID ~= nil);
    if type(_Dialog) ~= "table" then
        local Name = "Dialog #" ..(ModuleDialogSystem.Global.DialogCounter +1);
        error("API.StartDialog (" ..Name.. "): _Dialog must be a table!");
        return;
    end
    if #_Dialog == 0 then
        local Name = "Dialog #" ..(ModuleDialogSystem.Global.DialogCounter +1);
        error("API.StartDialog (" ..Name.. "): _Dialog does not contain pages!");
        return;
    end
    for i=1, #_Dialog do
        if type(_Dialog[i]) == "table" and not _Dialog[i].__Legit then
            local Name = "Dialog #" ..(ModuleDialogSystem.Global.DialogCounter +1);
            error("API.StartDialog (" ..Name.. ", Page #" ..i.. "): Page is not initialized!");
            return;
        end
    end

    if _Dialog.EnableGlobalImmortality == nil then
        _Dialog.EnableGlobalImmortality = true;
    end
    if _Dialog.EnableFoW == nil then
        _Dialog.EnableFoW = false;
    end
    if _Dialog.EnableBorderPins == nil then
        _Dialog.EnableBorderPins = false;
    end
    if _Dialog.RestoreGameSpeed == nil then
        _Dialog.RestoreGameSpeed = true;
    end
    if _Dialog.RestoreCamera == nil then
        _Dialog.RestoreCamera = true;
    end
    ModuleDialogSystem.Global:StartDialog(_Name, PlayerID, _Dialog);
end

---
-- Prüft ob für den Spieler gerade ein Dialog aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=boolean] Dialog ist aktiv
-- @within Anwenderfunktionen
--
function API.IsDialogActive(_PlayerID)
    if Swift:IsGlobalEnvironment() then
        return ModuleDialogSystem.Global:GetCurrentDialog(_PlayerID) ~= nil;
    end
    return ModuleDialogSystem.Local:GetCurrentDialog(_PlayerID) ~= nil;
end

---
-- Erzeugt die Funktionen zur Erstellung von Seiten in einem Dialog und bindet
-- sie an selbigen. Diese Funktion muss vor dem Start eines Dialog aufgerufen
-- werden um Seiten hinzuzufügen.
--
-- @param[type=table] _Dialog Dialog Definition
-- @return[type=function] <a href="#AP">AP</a>
-- @return[type=function] <a href="#ASP">ASP</a>
-- @within Anwenderfunktionen
--
-- @usage local AP, ASP = API.AddPages(Briefing);
--
function API.AddDialogPages(_Dialog)
    _Dialog.GetPage = function(self, _PlayerID, _NameOrID)
        local ID = ModuleDialogSystem.Global:GetPageIDByName(_PlayerID, _NameOrID);
        return ModuleDialogSystem.Global.Dialog[_PlayerID][ID];
    end

    local AP = function(_Page)
        if type(_Page) == "table" then
            local Identifier = "Page" ..(#_Dialog +1);
            if _Page.Name then
                Identifier = _Page.Name;
            else
                _Page.Name = Identifier;
            end

            if _Page.Position and _Page.Target then
                local Name = "Dialog #" ..(ModuleDialogSystem.Global.DialogCounter +1);
                error("AP (" ..Name.. ", Page '" .._Page.Name.. "'): "..
                      "Position and Target can not be used both at the "..
                      "same time!");
                return;
            end

            _Page.__Legit = true;
            _Page.GetSelected = function(self)
                if self.MC then
                    return self.MC.Selected;
                end
                return 0;
            end

            _Page.Title = _Page.Title or "";
            if _Page.Rotation == nil then
                if _Page.Target ~= nil then
                    local ID = GetID(_Page.Target);
                    local Orientation = Logic.GetEntityOrientation(ID) +90;
                    _Page.Rotation = Orientation;
                else
                    _Page.Rotation = QSB.Dialog.DLGCAMERA_ROTATIONDEFAULT;
                end
            end
            if _Page.Zoom == nil then
                _Page.Zoom = QSB.Dialog.DLGCAMERA_ZOOMDEFAULT;
            end
            if _Page.MC ~= nil then
                for j= 1, #_Page.MC, 1 do
                    _Page.MC[j].ID = j;
                    _Page.MC[j].Selected = 0;
                    _Page.MC[j].Visible = true;
                end
            end
        else
            _Page = (_Page == nil and -1) or _Page;
        end
        table.insert(_Dialog, _Page);
        return _Page;
    end

    local ASP = function(...)
        if type(arg[1]) ~= "number" then
            Name = table.remove(arg, 1);
        end
        local Sender   = table.remove(arg, 1);
        local Position = table.remove(arg, 1);
        local Title    = table.remove(arg, 1);
        local Text     = table.remove(arg, 1);
        local Dialog   = table.remove(arg, 1);
        local Action;
        if type(arg[1]) == "function" then
            Action = table.remove(arg, 1);
        end
        return AP {
            Name   = Name,
            Title  = Title,
            Text   = Text,
            Sender = Sender,
            Target = Position,
            Zoom   = (Dialog and QSB.Dialog.DLGCAMERA_ZOOMDEFAULT) or QSB.Dialog.CAMERA_ZOOMDEFAULT,
            Action = Action,
        };
    end
    return AP, ASP;
end

---
-- Erstellt eine Seite für einen Dialog.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddPages">API.AddDialogPages</a> erzeugt und an
-- den Dialog gebunden.
--
-- <h5>Dialog Page</h5>
-- Eine Dialog Page stellt den gesprochenen Text mit und ohne Akteur dar.
--
-- Mögliche Felder:
-- <table border="1">
-- <tr>
-- <td><b>Einstellung</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Titel</td>
-- <td>(string) Bestimmt den Namen des Sprechers.</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>(string) Bestimmt den auf dieser Dialogseite angezeigten Text.</td>
-- </tr>
-- <tr>
-- <td>Sender</td>
-- <td>(number) Bestimmt den Spieler, dessen Portrait angezeigt wird. Bei -1 wird kein Portrait angezeigt</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>(function) Führt eine Funktion aus, wenn die aktuelle Dialogseite angezeigt wird.</td>
-- </tr>
-- <tr>
-- <td>DisableSkipping</td>
-- <td>(boolean) Verbietet das Überspringen durch drücken von Escape für diese Seite.</td>
-- </tr>
-- <tr>
-- <td>Position</td>
-- <td>(table) Bestimmt die Position der Kamera anhand des übergebenen Positions-Table.</td>
-- </tr>
-- <tr>
-- <td>Target</td>
-- <td>(string) Setzt die Kamera auf das angegebene Entity und folgt ihm für die Anzeigedauer der Dialogseite.</td>
-- </tr>
-- <tr>
-- <td>Zoom</td>
-- <td>(number) Zoomfaktor für die Kamera. Werte zwischen 0.1 und 0.5 sind möglich.</td>
-- </tr>
-- <tr>
-- <td>Rotation</td>
-- <td>(number) Rotationswinkel der Kamera. Werte zwischen 0 und 360 sind möglich.</td>
-- </tr>
-- <tr>
-- <td>MC</td>
-- <td>(table) Table mit möglichen Dialogoptionen. (Multiple Choice)</td>
-- </tr>
-- </table>
--
-- <br><h5>Multiple Choice</h5>
-- In einem Dialog kann der Spieler auch zur Auswahl einer Option gebeten
-- werden. Dies wird als Multiple Choice bezeichnet. Schreibe die Optionen
-- in eine Untertabelle MC.
-- <pre>AP {
--    ...
--    MC = {
--        {"Antwort 1", "ExamplePage1"},
--        {"Antwort 2", Option2Clicked},
--    },
--};</pre>
-- Es kann der Name der Zielseite angegeben werden, oder eine Funktion, die
-- den Namen des Ziels zurück gibt. In der Funktion können vorher beliebige
-- Dinge getan werden, wie z.B. Variablen setzen.
--
-- Eine Antwort kann markiert werden, dass sie auch bei einem Rücksprung,
-- nicht mehrfach gewählt werden kann. In diesem Fall ist sie bei erneutem
-- Aufsuchen der Seite nicht mehr gelistet.
-- <pre>{"Antwort 3", "AnotherPage", Remove = true},</pre>
-- Eine Option kann auch bedingt ausgeblendet werden. Dazu wird eine Funktion
-- angegeben, welche über die Sichtbarkeit entscheidet.
-- <pre>{"Antwort 3", "AnotherPage", Disable = OptionIsDisabled},</pre>
--
-- Nachdem der Spieler eine Antwort gewählt hat, wird er auf die Seite mit
-- dem angegebenen Namen geleitet.
--
-- Um den Dialog zu beenden, nachdem ein Pfad beendet ist, wird eine leere
-- AP-Seite genutzt. Auf diese Weise weiß der Dialog, das er an dieser
-- Stelle zuende ist.
-- <pre>AP()</pre>
--
-- Soll stattdessen zu einer anderen Seite gesprungen werden, kann bei AP der
-- Name der Seite angeben werden, zu der gesprungen werden soll.
-- <pre>AP("SomePageName")</pre>
--
-- Um später zu einem beliebigen Zeitpunkt die gewählte Antwort einer Seite zu
-- erfahren, muss der Name der Seite genutzt werden.
-- <pre>Dialog.Finished = function(_Data)
--    local Choosen = _Data:GetPage("Choice"):GetSelectedAnswer();
--end</pre>
-- Die zurückgegebene Zahl ist die ID der Antwort, angefangen von oben. Wird 0
-- zurückgegeben, wurde noch nicht geantwortet.
--
-- @param[type=table] _Page Spezifikation der Seite
-- @return[type=table] Refernez auf die angelegte Seite
-- @within Dialog
--
-- @usage
-- -- Eine einfache Seite
-- AP {
--     Name   = "StartPage",
--     Title  = "Horst",
--     Text   = "Das ist ein Test!",
--     Sender = -1,
--     Target = "npc1",
--     Zoom   = 0.1,
-- }
--
-- -- Eine Seite mit Optionen
-- -- Hier können Namen von Seiten angegeben werden oder Aktionen, welche etwas
-- -- Ausführen und danach einen Namen zurückgeben.
-- AP {
--     Name   = "StartPage",
--     Title  = "Horst",
--     Text   = "Das ist ein Test!",
--     Sender = -1,
--     Target = "npc1",
--     Zoom   = 0.1,
--     MC     = {
--         {"Machen wir weiter...", "ContinuePage"},
--         {"Schluss jetzt!", "EndPage"}
--     }
-- }
--
function AP(_Page)
    assert(false);
end

---
-- Erstellt eine Seite in vereinfachter Syntax. Es wird davon ausgegangen, dass
-- das Entity ein Siedler ist. Die Kamera schaut den Siedler an.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddPages">API.AddDialogPages</a> erzeugt und an
-- den Dialog gebunden.
--
-- @param[type=string]   _Name         (Optional) Name der Seite
-- @param[type=number]   _Sender       Spieler (-1 für kein Portrait)
-- @param[type=string]   _Position     Position der Kamera
-- @param[type=string]   _Title        Name des Sprechers
-- @param[type=string]   _Text         Text der Seite
-- @param[type=boolean]  _DialogCamera Nahsicht an/aus
-- @param[type=function] _Action       (Optional) Callback-Funktion
-- @return[type=table] Referenz auf die Seite
-- @within Dialog
--
-- @usage -- Beispiel ohne Page Name
-- ASP("Ich gehe in die weitel Welt hinein.", 1, "hans", true);
-- -- Beispiel mit Page Name
-- ASP("Page1", "Ich gehe in die weitel Welt hinein.", 1, "hans", true);
--
function ASP(...)
    assert(false);
end

