-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnQuestNotes                                              # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Modul erlaubt das Speichern und Anzeigen von Zusatzinformationen zu
-- Quests. Die Informationen werden mit Klick auf den Informationsbutton neben
-- dem Portrait angezeigt.
-- Per Default werden die Informationen als Message angezeigt. Sollte das Bundle
-- für Dialogfenster aktiv sein, wird stattdessen ein Textfenster verwendet.
-- Die Aktion für die Anzeige kann jedoch konfiguriert werden.
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
-- API.SetDefaultQuestInfoAction(SomeActionFunction);
--
function API.SetDefaultQuestInfoAction(_Function)
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
-- API.SetQuestInfoActionForQuest("MyQuest", SomeSpecializedActionFunction);
--
function API.SetQuestInfoActionForQuest(_QuestName, _Function)
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
-- Gibt die Zusatzinformationen eines Quests zurück. Hat ein Quest keine
-- Zusatzinformationen wird nil zurückgegeben.
--
-- @return[type=table] Zusatinfos des Quest
-- @within Anwenderfunktionen
--
-- @usage
-- local Text = API.GetQuestInfo();
--
function API.GetQuestInfo()
    return AddOnQuestNotes.Global.Data.Journal;
end

---
-- Setzt einen bestimmten Text als Zusatzinformation für Quests.
--
-- @param [type=table] _Text Zusatinfos des Quest
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetQuestInfo("Wichtige Information zum Anzeigen");
--
function API.SetQuestInfo(_Text)
    if _Text then
        _Text = {ID = 1, Quest = nil, Rank = 0, _Text};
        AddOnQuestNotes.Global.Data.Journal = {ID = 1, _Text};
    else
        AddOnQuestNotes.Global.Data.Journal = {ID = 0};
    end
end

---
-- Fugt eine Zusatzinformation für den Quests hinzu.
--
-- @param [type=string] _Quest Questname
-- @param [type=string] _Text  Zusatinfos des Quest
-- @return[type=number] ID des neuen Eintrags
-- @within Anwenderfunktionen
--
-- @usage
-- local NewEntryID = API.PushQuestInfo("SomeQuest", "Wichtige Information zum Anzeigen");
--
function API.PushQuestInfo(_Quest, _Text)
    AddOnQuestNotes.Global.Data.Journal.ID = AddOnQuestNotes.Global.Data.Journal.ID +1;
    table.insert(AddOnQuestNotes.Global.Data.Journal, {
        ID = AddOnQuestNotes.Global.Data.Journal.ID,
        Quest = _Quest,
        Rank = 0,
        _Text
    });
    return AddOnQuestNotes.Global.Data.Journal.ID;
end

---
-- Fugt eine Zusatzinformation für alle Quests hinzu.
--
-- @param [type=string] _Text Zusatinfos des Quest
-- @return[type=number] ID des neuen Eintrags
-- @within Anwenderfunktionen
--
-- @usage
-- local NewEntryID = API.PushGlobalQuestInfo("Wichtige Information zum Anzeigen");
--
function API.PushGlobalQuestInfo(_Text)
    return API.PushQuestInfo(nil, _Text);
end

---
-- Fugt eine wichtige Zusatzinformation für den Quests hinzu.
--
-- <b>Hinweis</b>: Wichtige Zusatzinformationen werden zuerst und rot hinterlegt
-- dargestellt.
--
-- @param [type=string] _Quest Questname
-- @param [type=string] _Text  Zusatinfos des Quest
-- @return[type=number] ID des neuen Eintrags
-- @within Anwenderfunktionen
--
-- @usage
-- local NewEntryID = API.PushImportantQuestInfo("SomeQuest", "Wichtige Information zum Anzeigen");
--
function API.PushImportantQuestInfo(_Quest, _Text)
    AddOnQuestNotes.Global.Data.Journal.ID = AddOnQuestNotes.Global.Data.Journal.ID +1;
    table.insert(AddOnQuestNotes.Global.Data.Journal, {
        ID = AddOnQuestNotes.Global.Data.Journal.ID,
        Quest = _Quest,
        Rank = 1,
        _Text
    });
    return AddOnQuestNotes.Global.Data.Journal.ID;
end

---
-- Fugt eine wichtige Zusatzinformation für alle Quests hinzu.
--
-- <b>Hinweis</b>: Wichtige Zusatzinformationen werden zuerst und rot hinterlegt
-- dargestellt.
--
-- @param [type=string] _Text Zusatinfos des Quest
-- @return[type=number] ID des neuen Eintrags
-- @within Anwenderfunktionen
--
-- @usage
-- local NewEntryID = API.PushImportantGlobalQuestInfo("Wichtige Information zum Anzeigen");
--
function API.PushImportantGlobalQuestInfo(_Text)
    return API.PushImportantQuestInfo(nil, _Text);
end

---
-- Hebt einen Eintrag aus den Zusatzinformationen als wichtig hervor oder
-- setzt ihn zurück.
--
-- @param [type=number]  _ID        ID des Eintrag
-- @param [type=boolean] _Important Wichtig Markierung
-- @within Anwenderfunktionen
--
-- @usage
-- API.HighlightQuestInfoEntry(SomeEntryID, true);
--
function API.HighlightQuestInfoEntry(_ID, _Important)
    for i= 1, #AddOnQuestNotes.Global.Data.Journal, 1 do
        if AddOnQuestNotes.Global.Data.Journal[i].ID == _ID then
            AddOnQuestNotes.Global.Data.Journal[i].Rank = (_Important == true and 1) or 0;
            return;
        end
    end
end

---
-- Entfernt einen Eintrag aus den Zusatzinformationen.
--
-- @param [type=number]  _ID        ID des Eintrag
-- @within Anwenderfunktionen
--
-- @usage
-- API.DeleteQuestInfoEntry(SomeEntryID);
--
function API.DeleteQuestInfoEntry(_ID)
    for i= 1, #AddOnQuestNotes.Global.Data.Journal, 1 do
        if AddOnQuestNotes.Global.Data.Journal[i].ID == _ID then
            AddOnQuestNotes.Global.Data.Journal[i].Deleted = true;
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
            ShowInfo = {},
            Journal  = {ID = 0},
        },
    },
    Local =  {
        Data = {
            NextButton = "/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/TutorialNextButton",
            NextButtonIcon = {16, 10},
            ShowJournal = false,
        },
    },

    Text = {
        Next  = {de = "Notizen anzeigen", en = "Show journal"},
        Title = {de = "Tagebuch", en = "Journal"}
    },
}

-- Global ----------------------------------------------------------------------

function AddOnQuestNotes.Global:Install()
    self:CreateDefaultActionLambda();
    API.AddSaveGameAction(function()
        Logic.ExecuteInLuaLocalState("AddOnQuestNotes.Local:OverrideStringKeys()");
    end);
end

function AddOnQuestNotes.Global:CreateDefaultActionLambda()
    self.Data.ShowInfo.Default = function(_Quest, _Text)
        if not BundleDialogWindows then
            Logic.ExecuteInLuaLocalState(string.format(
                [[GUI.ClearNotes(); API.Note("%s");]],
                _Text
            ));
        else
            Logic.ExecuteInLuaLocalState(string.format([[
                if not QSB.TextWindow.Data.Shown then
                    local Text = API.ConvertPlaceholders(API.Localize("%s"));
                    QSB.TextWindow:New(API.Localize(AddOnQuestNotes.Text.Title), Text):Show();
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
                        Text = "{scarlet}" .. Text .. "{tooltip}";
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
        if not g_Interaction.CurrentMessageQuestIndex then
            return;
        end
        if not QuestLog.IsQuestLogShown() then
            local Quest = Quests[g_Interaction.CurrentMessageQuestIndex];
            if type(Quest) == "table" and AddOnQuestNotes.Local.Data.ShowJournal and Quest.QuestNotes then
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

