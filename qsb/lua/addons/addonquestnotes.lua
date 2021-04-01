-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnQuestNotes                                              # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Modul erlaubt das Speichern und Anzeigen von Zusatzinformationen zu
-- Quests. Die Informationen werden mit Klick auf den Informationsbutton neben
-- dem Portrait angezeigt. Dadurch ist es möglich, dem Spieler erweiterte Hilfe
-- zu geben oder ihn nach und nach Informationen zusammen tragen zu lassen, die
-- für die Erfüllung der Mission benötigt werden.
--
-- Per Default werden die Informationen als Message angezeigt. Sollte das Bundle
-- für Dialogfenster aktiv sein, wird stattdessen ein Textfenster verwendet.
-- Die Aktion für die Anzeige kann jedoch frei konfiguriert werden.
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnQuestNotes = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Setzt die Standardfunktion für Zusatzinformationen. Die Funktion wird beim
-- Klick auf den Info-Button ausgeführt und sollte den Text anzeigen.
--
-- Die Funktion erhält folgende Parameter:
-- <table border="1">
-- <tr><td><b>Parameter</b></td><td><b>Typ</b></td><td><b>Beschreibung</b></td></tr>
-- <tr><td>QuestID</td><td>number</td><td>ID der Quest</td></tr>
-- <tr><td>Information</td><td>string</td><td>Zusationformationen für den Quest</td></tr>
-- </table>
--
-- @param[type=function] _Function Aktion beim Klick
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetDefaultNoteAction(SomeActionFunction);
--
function API.SetDefaultNoteAction(_Function)
    if GUI then
        return;
    end
    AddOnQuestNotes.Global.Data.ShowInfo.Default = _Function;
end

---
-- Setzt die Funktion für Zusatzinformationen speziell für den Quest. Die
-- Funktion wird beim Klick auf den Info-Button ausgeführt und sollte den Text
-- anzeigen. Eine speziell für einen Quest gesetzte Funktion ersetzt das für
-- alle Quests eingestellte Standardverhalten.
--
-- Die Funktion erhält folgende Parameter:
-- <table border="1">
-- <tr><td><b>Parameter</b></td><td><b>Typ</b></td><td><b>Beschreibung</b></td></tr>
-- <tr><td>QuestID</td><td>number</td><td>ID der Quest</td></tr>
-- <tr><td>Information</td><td>string</td><td>Zusationformationen für den Quest</td></tr>
-- </table>
--
-- @param[type=string]   _QuestName Name des Quest
-- @param[type=function] _Function  Aktion beim Klick
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetQuestNoteAction("MyQuest", SomeSpecializedActionFunction);
--
function API.SetQuestNoteAction(_QuestName, _Function)
    if GUI then
        return;
    end
    AddOnQuestNotes.Global.Data.ShowInfo[_QuestName] = _Function;
end

---
-- Aktiviert oder Deaktiviert die Verfügbarkeit der Zusatzinformationen global
-- für alle Quests.
--
-- @param[type=boolean] _Flag Zusatzinfos aktivieren
-- @within Anwenderfunktionen
--
-- @usage
-- -- Global deaktivieren
-- API.SetShowQuestInfo(false);
-- -- Global aktivieren
-- API.SetShowQuestInfo(false);
--
function API.SetShowQuestInfo(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format([[API.SetShowQuestInfo(%s)]], tostring(_Flag)))
        return;
    end
    AddOnQuestNotes.Local.Data.ShowJournal = _Flag == true;
end

---
-- Fugt eine Zusatzinformation für diesen Quests hinzu.
--
-- <b>Hinweis</b>: Die erzeugte ID ist immer eindeutig für alle Einträge,
-- ungeachtet ob sie einem Quest zugeordnet sind oder nicht.
--
-- @param[type=string] _Quest Questname
-- @param              _Text  Text der Zusatzinfo
-- @return[type=number] ID des neuen Eintrags
-- @within Anwenderfunktionen
--
-- @usage
-- local NewEntryID = API.AddQuestNote("SomeQuest", "Wichtige Information zum Anzeigen");
--
function API.AddQuestNote(_Quest, _Text)
    -- Add entry
    AddOnQuestNotes.Global.Data.Journal.ID = AddOnQuestNotes.Global.Data.Journal.ID +1;
    table.insert(AddOnQuestNotes.Global.Data.Journal, {
        ID = AddOnQuestNotes.Global.Data.Journal.ID,
        Quest = _Quest,
        Rank = 0,
        _Text
    });
    -- Local reference
    local Index = #AddOnQuestNotes.Global.Data.Journal;
    Logic.ExecuteInLuaLocalState(string.format(
        [[AddOnQuestNotes.Local.Data.Journal[%d] = %s]],
        Index,
        API.ConvertTableToString(AddOnQuestNotes.Global.Data.Journal[Index])
    ));
    return AddOnQuestNotes.Global.Data.Journal.ID;
end

---
-- Fugt eine Zusatzinformation für alle Quests hinzu.
--
-- <b>Hinweis</b>: Die erzeugte ID ist immer eindeutig für alle Einträge,
-- ungeachtet ob sie einem Quest zugeordnet sind oder nicht.
--
-- @param _Text Text der Zusatzinfo
-- @return[type=number] ID des neuen Eintrags
-- @within Anwenderfunktionen
--
-- @usage
-- local NewEntryID = API.AddCommonQuestNote("Wichtige Information zum Anzeigen");
--
function API.AddCommonQuestNote(_Text)
    return API.AddQuestNote(nil, _Text);
end

---
-- Ändert den Text einer Zusatzinformation.
--
-- <b>Hinweis</b>: Der neue Text bezieht sich auf den Eintrag mit der ID. Ist
-- der Eintrag für alle Quests sichtbar, wird er in allen Quests geändert.
-- Kopien eines Eintrags werden nicht berücksichtigt.
--
-- @param[type=number] _ID   ID des Eintrag
-- @param              _Text Neuer Text
-- @within Anwenderfunktionen
--
-- @usage
-- API.AlterInfoEntry(SomeEntryID, "Das ist der neue Text");
--
function API.AlterInfoEntry(_ID, _Text)
    for i= #AddOnQuestNotes.Global.Data.Journal, 1, -1 do
        if AddOnQuestNotes.Global.Data.Journal[i].ID == _ID then
            AddOnQuestNotes.Global.Data.Journal[i][1] = _Text;
            Logic.ExecuteInLuaLocalState(string.format(
                [[AddOnQuestNotes.Local.Data.Journal[%d] = %s]],
                i,
                API.ConvertTableToString(AddOnQuestNotes.Global.Data.Journal[i])
            ));
            return;
        end
    end
end

---
-- Hebt einen Eintrag aus den Zusatzinformationen als wichtig hervor oder
-- setzt ihn zurück.
--
-- <b>Hinweis</b>: Wichtige Einträge erscheinen immer als erstes und sind durch
-- rote Färbung hervorgehoben.
--
-- @param[type=number]  _ID        ID des Eintrag
-- @param[type=boolean] _Important Wichtig Markierung
-- @within Anwenderfunktionen
--
-- @usage
-- API.HighlightInfoEntry(SomeEntryID, true);
--
function API.HighlightInfoEntry(_ID, _Important)
    for i= #AddOnQuestNotes.Global.Data.Journal, 1, -1 do
        if AddOnQuestNotes.Global.Data.Journal[i].ID == _ID then
            AddOnQuestNotes.Global.Data.Journal[i].Rank = (_Important == true and 1) or 0;
            Logic.ExecuteInLuaLocalState(string.format(
                [[AddOnQuestNotes.Local.Data.Journal[%d].Rank = %d]],
                i,
                (_Important == true and 1) or 0
            ));
            return;
        end
    end
end

---
-- Kopiert einen Eintrag als neuen Eintrag in einen anderen Quest.
--
-- @param[type=number] _ID    ID des Eintrag
-- @param[type=string] _Quest Name des neuen Quest
-- @within Anwenderfunktionen
--
-- @usage
-- API.DeleteInfoEntry(SomeEntryID);
--
function API.CopyInfoEntry(_ID, _Quest)
    for i= #AddOnQuestNotes.Global.Data.Journal, 1, -1 do
        if AddOnQuestNotes.Global.Data.Journal[i].ID == _ID and AddOnQuestNotes.Global.Data.Journal[i].Quest ~= nil then
            if AddOnQuestNotes.Global.Data.Journal[i].Quest ~= _Quest then
                -- Create entry
                AddOnQuestNotes.Global.Data.Journal.ID = AddOnQuestNotes.Global.Data.Journal.ID +1;
                table.insert(AddOnQuestNotes.Global.Data.Journal, {
                    ID = AddOnQuestNotes.Global.Data.Journal.ID,
                    Quest = _Quest,
                    Rank = AddOnQuestNotes.Global.Data.Journal[i].Rank,
                    AddOnQuestNotes.Global.Data.Journal[i][1]
                });
                -- Local reference
                local Index = #AddOnQuestNotes.Global.Data.Journal;
                Logic.ExecuteInLuaLocalState(string.format(
                    [[AddOnQuestNotes.Local.Data.Journal[%d] = %s]],
                    Index,
                    API.ConvertTableToString(AddOnQuestNotes.Global.Data.Journal[Index])
                ));
                return AddOnQuestNotes.Global.Data.Journal.ID;
            end
        end
    end
end

---
-- Entfernt einen Eintrag aus den Zusatzinformationen.
--
-- @param[type=number] _ID ID des Eintrag
-- @within Anwenderfunktionen
--
-- @usage
-- API.DeleteInfoEntry(SomeEntryID);
--
function API.DeleteInfoEntry(_ID)
    for i= #AddOnQuestNotes.Global.Data.Journal, 1, -1 do
        if AddOnQuestNotes.Global.Data.Journal[i].ID == _ID then
            AddOnQuestNotes.Global.Data.Journal[i].Deleted = true;
            Logic.ExecuteInLuaLocalState(string.format(
                [[AddOnQuestNotes.Local.Data.Journal[%d].Deleted = true]],
                i
            ));
            return;
        end
    end
end

---
-- Stellt einen gelöschten Eintrag in den Zusatzinformationen wieder her.
--
-- @param[type=number] _ID ID des Eintrag
-- @within Anwenderfunktionen
--
-- @usage
-- API.RestoreInfoEntry(SomeEntryID);
--
function API.RestoreInfoEntry(_ID)
    for i= #AddOnQuestNotes.Global.Data.Journal, 1, -1 do
        if AddOnQuestNotes.Global.Data.Journal[i].ID == _ID then
            AddOnQuestNotes.Global.Data.Journal[i].Deleted = false;
            Logic.ExecuteInLuaLocalState(string.format(
                [[AddOnQuestNotes.Local.Data.Journal[%d].Deleted = false]],
                i
            ));
            return;
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnQuestNotes = {
    Global =  {
        Data = {
            ShowInfo   = {},
            Journal    = {ID = 0},
            TextColor  = "{white}",
            TextWindow = false,
        },
    },
    Local =  {
        Data = {
            Journal  = {},
            NextButton = "/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/TutorialNextButton",
            NextButtonIcon = {16, 10},
            ShowJournal = false,
        },
    },

    Text = {
        Next  = {de = "Notizen anzeigen", en = "Show Notebook"},
        Title = {de = "Notizbuch", en = "Notebook"}
    },
}

-- Global ----------------------------------------------------------------------

function AddOnQuestNotes.Global:Install()
    self:CreateDefaultActionLambda();
    self.Data.TextWindow = BundleDialogWindows ~= nil;
    self.Data.TextColor  = (BundleDialogWindows ~= nil and "{tooltip}") or "{white}",

    API.AddSaveGameAction(function()
        Logic.ExecuteInLuaLocalState("AddOnQuestNotes.Local:OverrideStringKeys()");
    end);
end

function AddOnQuestNotes.Global:CreateDefaultActionLambda()
    self.Data.ShowInfo.Default = function(_Quest, _Text)
        if not self.Data.TextWindow then
            Logic.ExecuteInLuaLocalState(string.format(
                [[GUI.ClearNotes(); API.Note("%s");]],
                _Text
            ));
        else
            Logic.ExecuteInLuaLocalState(string.format([[
                if not QSB.TextWindow.Data.Shown then
                    local Text = API.ConvertPlaceholders(API.Localize("%s"));
                    QSB.TextWindow:New(API.Localize(AddOnQuestNotes.Text.Title), Text):SetPause(false):Show();
                end
            ]], _Text));
        end
    end
end

function AddOnQuestNotes.Global:DisplayQuestNote(_QuestID)
    local Quest = Quests[_QuestID];
    if Quest and Quest.QuestNotes then
        local Journal = self:GetQuestNotesSorted();
        local Info = "";
        for i= 1, #Journal, 1 do
            if not Journal[i].Quest or GetQuestID(Journal[i].Quest) == _QuestID then
                if not Journal[i].Deleted then
                    local Text = API.ConvertPlaceholders(API.Localize(Journal[i][1]));
                    if Journal[i].Rank == 1 then
                        Text = "{scarlet}" .. Text .. self.Data.TextColor;
                    end
                    Info = Info .. ((Info ~= "" and "{cr}") or "") .. Text;
                end
            end
        end
        if AddOnQuestNotes.Global.Data.ShowInfo[Quest.Identifier] then
            AddOnQuestNotes.Global.Data.ShowInfo[Quest.Identifier](_QuestID, Info);
        else
            AddOnQuestNotes.Global.Data.ShowInfo.Default(_QuestID, Info);
        end
    end
end

function AddOnQuestNotes.Global:GetQuestNotesSorted()
    local Journal = {};
    for i= 1, #AddOnQuestNotes.Global.Data.Journal, 1 do
        if AddOnQuestNotes.Global.Data.Journal[i].Rank == 0 then
            table.insert(Journal, AddOnQuestNotes.Global.Data.Journal[i]);
        end
        if AddOnQuestNotes.Global.Data.Journal[i].Rank == 1 then
            local Index = 1;
            for j= 1, #Journal, 1 do
                if Journal[j].Rank == 1 then
                    Index = Index +1;
                end
            end
            table.insert(Journal, Index, AddOnQuestNotes.Global.Data.Journal[i]);
        end
    end
    return Journal;
end

-- Local -----------------------------------------------------------------------

function AddOnQuestNotes.Local:Install()
    self:OverrideUpdateVoiceMessage();
    self:OverrideTutorialNext();
    self:OverrideStringKeys();
end

function AddOnQuestNotes.Local:OverrideUpdateVoiceMessage()
    GUI_Interaction.UpdateVoiceMessage_Orig_AddOnQuestNotes = GUI_Interaction.UpdateVoiceMessage;
    GUI_Interaction.UpdateVoiceMessage = function()
        GUI_Interaction.UpdateVoiceMessage_Orig_AddOnQuestNotes();
        if not QuestLog.IsQuestLogShown() then
            if AddOnQuestNotes.Local:IsShowingQuestNoteButton(g_Interaction.CurrentMessageQuestIndex) then
                XGUIEng.ShowWidget(AddOnQuestNotes.Local.Data.NextButton, 1);
                SetIcon(
                    AddOnQuestNotes.Local.Data.NextButton,
                    AddOnQuestNotes.Local.Data.NextButtonIcon
                );
            else
                XGUIEng.ShowWidget(AddOnQuestNotes.Local.Data.NextButton, 0);
            end
        end
    end
end

function AddOnQuestNotes.Local:IsShowingQuestNoteButton(_ID)
    if not g_Interaction.CurrentMessageQuestIndex then
        return false;
    end
    local Quest = Quests[_ID];
    if  type(Quest) == "table"
    and AddOnQuestNotes.Local.Data.ShowJournal 
    and Quest.QuestNotes 
    and #AddOnQuestNotes.Local.Data.Journal > 0 then
        for i= #AddOnQuestNotes.Local.Data.Journal, 1, -1 do
            if  AddOnQuestNotes.Local.Data.Journal[i].Deleted ~= true
            and (AddOnQuestNotes.Local.Data.Journal[i].Quest == nil or 
                 AddOnQuestNotes.Local.Data.Journal[i].Quest == Quest.Identifier) then
                return true;
            end
        end
    end
    return false;
end

function AddOnQuestNotes.Local:OverrideTutorialNext()
    GUI_Interaction.TutorialNext_Orig_AddOnQuestNotes = GUI_Interaction.TutorialNext;
    GUI_Interaction.TutorialNext = function()
        if g_Interaction.CurrentMessageQuestIndex then
            GUI.SendScriptCommand(string.format(
                [[AddOnQuestNotes.Global:DisplayQuestNote(%d)]],
                g_Interaction.CurrentMessageQuestIndex
            ));
        end
    end
end

function AddOnQuestNotes.Local:OverrideStringKeys()
    GetStringTableText_Orig_AddOnQuestNotes = XGUIEng.GetStringTableText;
    XGUIEng.GetStringTableText = function(_key)
        if _key == "UI_ObjectNames/TutorialNextButton" then
            return API.Localize(AddOnQuestNotes.Text.Next);
        end
        return GetStringTableText_Orig_AddOnQuestNotes(_key);
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterAddOn("AddOnQuestNotes");

