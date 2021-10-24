-- -------------------------------------------------------------------------- --
-- Module Quests                                                              --
-- -------------------------------------------------------------------------- --

ModuleQuestJournal = {
    Properties = {
        Name = "ModuleQuestJournal",
    },

    Global = {
        Journal = {ID = 0},
        ShowInfo   = {},
        TextColor  = "{tooltip}",
    };
    Local = {
        NextButton = "/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/TutorialNextButton",
        NextButtonIcon = {16, 10},
    };
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        Text = {
            Next  = {de = "Notizen anzeigen", en = "Show Notebook"},
            Title = {de = "Notizbuch", en = "Journal"},
        },
    };
};

-- Global Script ---------------------------------------------------------------

function ModuleQuestJournal.Global:OnGameStart()
    QSB.ScriptEvents.QuestJournalDisplayed = API.RegisterScriptEvent("Event_QuestJournalDisplayed");
end

function ModuleQuestJournal.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.ChatClosed then
        self:ProcessChatInput(arg[1], arg[2]);
    elseif _ID == QSB.ScriptEvents.QuestJournalDisplayed then
        local Info = self:DisplayQuestNote(arg[1], arg[2]);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(%d, %d, "%s")]],
            _ID,
            arg[2],
            Info
        ));
    end
end

function ModuleQuestJournal.Global:AddQuestNote(_Quest, _Rank, _Text)
    ModuleQuestJournal.Global.Journal.ID = ModuleQuestJournal.Global.Journal.ID +1;
    table.insert(ModuleQuestJournal.Global.Journal, {
        ID = ModuleQuestJournal.Global.Journal.ID,
        Quest = _Quest,
        Rank = _Rank,
        _Text
    });
    return ModuleQuestJournal.Global.Journal.ID;
end

function ModuleQuestJournal.Global:DisplayQuestNote(_QuestName, _PlayerID)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest and Quest.QuestNotes and Quest.ReceivingPlayer == _PlayerID then
        local Journal = self:GetQuestNotesSorted();
        local NotesInitalized = false;
        local Info = "";
        for i= 1, #Journal, 1 do
            if not Journal[i].Quest or Journal[i].Quest == _QuestName then
                if not Journal[i].Deleted then
                    local Text = API.ConvertPlaceholders(API.Localize(Journal[i][1]));
                    if Journal[i].Rank == 1 then
                        Text = "{scarlet}" .. Text .. self.TextColor;
                    end
                    if Journal[i].Rank == -1 then
                        if not NotesInitalized then
                            NotesInitalized = true;
                            Text = Text .. "{cr}{cr}----------{cr}{cr}";
                        end
                        Text = "{amber}" .. Text .. self.TextColor;
                    end
                    Info = Info .. ((Info ~= "" and "{cr}") or "") .. Text;
                end
            end
        end
        return Info;
    end
end

function ModuleQuestJournal.Global:GetQuestNotesSorted()
    local Journal = {};
    for i= 1, #self.Journal, 1 do
        table.insert(Journal, self.Journal[i]);
    end
    table.sort(Journal, function(a, b)
        return a.Rank > b.Rank;
    end)
    return Journal;
end

function ModuleQuestJournal.Global:ProcessChatInput(_Text, _PlayerID)
    if string.find(_Text or "", "^note ") then
        local Text = _Text:sub(7);
        local QuestName = "foo";
        -- TODO Identify the quest this note is supposed to be attached.
        self:AddQuestNote(QuestName, -1, Text);
        local Info = self:DisplayQuestNote(QuestName, _PlayerID);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(%d, %d, "%s")]],
            QSB.ScriptEvents.QuestJournalDisplayed,
            _PlayerID,
            Info
        ));
    end
end

-- Local Script ----------------------------------------------------------------

function ModuleQuestJournal.Local:OnGameStart()
    QSB.ScriptEvents.QuestJournalDisplayed = API.RegisterScriptEvent("Event_QuestJournalDisplayed");

    self:OverrideUpdateVoiceMessage();
    self:OverrideTutorialNext();
    self:OverrideStringKeys();
end

function ModuleQuestJournal.Local:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.QuestJournalDisplayed then
        self:DisplayQuestJournal(arg[1], arg[2], arg[3]);
    end
end

function ModuleQuestJournal.Local:DisplayQuestJournal(_QuestName, _PlayerID, _Info)
    if _Info and GUI.GetPlayerID() == _PlayerID then
        QSB.TextWindow:New("Journal", _Info)
            :SetPause(false)
            :Show();
    end
end

function ModuleQuestJournal.Local:OverrideUpdateVoiceMessage()
    GUI_Interaction.UpdateVoiceMessage_Orig_ModuleQuestJournal = GUI_Interaction.UpdateVoiceMessage;
    GUI_Interaction.UpdateVoiceMessage = function()
        GUI_Interaction.UpdateVoiceMessage_Orig_ModuleQuestJournal();
        if not QuestLog.IsQuestLogShown() then
            if ModuleQuestJournal.Local:IsShowingQuestNoteButton(g_Interaction.CurrentMessageQuestIndex) then
                XGUIEng.ShowWidget(ModuleQuestJournal.Local.NextButton, 1);
                SetIcon(
                    ModuleQuestJournal.Local.NextButton,
                    ModuleQuestJournal.Local.NextButtonIcon
                );
            else
                XGUIEng.ShowWidget(ModuleQuestJournal.Local.NextButton, 0);
            end
        end
    end
end

function ModuleQuestJournal.Local:IsShowingQuestNoteButton(_ID)
    if not g_Interaction.CurrentMessageQuestIndex then
        return false;
    end
    local Quest = Quests[_ID];
    if  type(Quest) == "table"
    and Quest.QuestNotes 
    and #self.Journal > 0 then
        for i= #self.Journal, 1, -1 do
            if  self.Journal[i].Deleted ~= true
            and (self.Journal[i].Quest == nil or 
            self.Journal[i].Quest == Quest.Identifier) then
                return true;
            end
        end
    end
    return false;
end

function ModuleQuestJournal.Local:OverrideTutorialNext()
    GUI_Interaction.TutorialNext_Orig_ModuleQuestJournal = GUI_Interaction.TutorialNext;
    GUI_Interaction.TutorialNext = function()
        if g_Interaction.CurrentMessageQuestIndex then
            local QuestID = g_Interaction.CurrentMessageQuestIndex;
            local Quest = Quests[QuestID];
            GUI.SendScriptCommand(string.format(
                [[API.SendScriptEvent(QSB.ScriptEvents.QuestJournalDisplayed, "%s", %d)]],
                Quest.Identifier,
                Quest.ReceivingPlayer
            ));
        end
    end
end

function ModuleQuestJournal.Local:OverrideStringKeys()
    GetStringTableText_Orig_ModuleQuestJournal = XGUIEng.GetStringTableText;
    XGUIEng.GetStringTableText = function(_key)
        if _key == "UI_ObjectNames/TutorialNextButton" then
            return API.Localize(ModuleQuestJournal.Shared.Text.Next);
        end
        return GetStringTableText_Orig_ModuleQuestJournal(_key);
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleQuestJournal);

