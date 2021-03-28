-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnQuestNotes                                              # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Modul erlaubt das Anfügen von Zusatzinformationen an einen Quest.
-- Solche Informationen werden mit Klick auf den Informationsbutton angezeigt.
-- Per Default werden die Informationen als Message angezeigt. Die Aktion für
-- die Anzeige kann jedoch konfiguriert werden.
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
-- Gibt die Zusatzinformationen eines Quests zurück. Hat ein Quest keine
-- Zusatzinformationen wird nil zurückgegeben.
--
-- @param[type=string] _QuestName Name des Quest
-- @return Zusatinfos des Quest (String oder Table)
-- @within Anwenderfunktionen
--
-- @usage
-- local Text = API.GetQuestInfo("MyQuest");
--
function API.GetQuestInfo(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        return Quest.QuestNotes;
    end
end

---
-- Setzt die Zusatzinformationen für den Quest. Platzhalter in Texten ersetzen
-- oder Sprachlokalisation Deutsch/Englisch werden automatisch zur Anzeigezeit
-- vorgenommen.
--
-- @param[type=string]   _QuestName Name des Quest
-- @param                _Text      Anzuzeigender Text (String oder Table)
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetQuestInfo("MyQuest", "Wichtige Information zum Anzeigen");
--
function API.SetQuestInfo(_QuestName, _Text)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        Quest.QuestNotes = _Text;
    end
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnQuestNotes = {
    Global =  {
        Data = {
            ShowInfo = {};
        },
    },
    Local =  {
        Data = {
            NextButton = "/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/TutorialNextButton",
            NextButtonIcon = {16, 10},
        },
    },

    Text = {
        Next = {de = "Notizen anzeigen", en = "Show journal"}
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
        Logic.ExecuteInLuaLocalState(string.format(
            [[GUI.ClearNotes(); API.Note("%s");]],
            _Text
        ));
    end
end

function AddOnQuestNotes.Global:DisplayQuestNote(_QuestID)
    local Quest = Quests[_QuestID];
    if Quest and Quest.QuestNotes then
        local Info = API.ConvertPlaceholders(API.Localize(Quest.QuestNotes));
        if AddOnQuestNotes.Global.Data.ShowInfo[Quest.Identifier] then
            AddOnQuestNotes.Global.Data.ShowInfo[Quest.Identifier](_QuestID, Info);
        else
            AddOnQuestNotes.Global.Data.ShowInfo.Default(_QuestID, Info);
        end
    end
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
            if type(Quest) == "table" and Quest.QuestNotes then
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
        GUI.SendScriptCommand(string.format(
            [[AddOnQuestNotes.Global:DisplayQuestNote(%d)]],
            g_Interaction.CurrentMessageQuestIndex
        ));
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

