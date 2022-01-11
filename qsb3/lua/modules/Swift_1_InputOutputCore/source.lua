--[[
Swift_2_InputOutputCore/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleInputOutputCore = {
    Properties = {
        Name = "ModuleInputOutputCore",
    },

    Global = {};
    Local  = {
        InputBoxShown = false,
        ProccessDebugCommands = false,
        CheatsDisabled = false,
        Requester = {
            ActionFunction = nil,
            ActionRequester = nil,
            Next = nil,
            Queue = {},
        },
    };
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        Colors = {
            red     = "{@color:255,80,80,255}",
            blue    = "{@color:104,104,232,255}",
            yellow  = "{@color:255,255,80,255}",
            green   = "{@color:80,180,0,255}",
            white   = "{@color:255,255,255,255}",
            black   = "{@color:0,0,0,255}",
            grey    = "{@color:140,140,140,255}",
            azure   = "{@color:0,160,190,255}",
            orange  = "{@color:255,176,30,255}",
            amber   = "{@color:224,197,117,255}",
            violet  = "{@color:180,100,190,255}",
            pink    = "{@color:255,170,200,255}",
            scarlet = "{@color:190,0,0,255}",
            magenta = "{@color:190,0,89,255}",
            olive   = "{@color:74,120,0,255}",
            sky     = "{@color:145,170,210,255}",
            tooltip = "{@color:51,51,120,255}",
            lucid   = "{@color:0,0,0,0}"
        },

        Placeholders = {
            Names = {},
            EntityTypes = {},
        };
    };
};

-- Global ------------------------------------------------------------------- --

function ModuleInputOutputCore.Global:OnGameStart()
    QSB.ScriptEvents.ChatOpened = API.RegisterScriptEvent("Event_ChatOpened");
    QSB.ScriptEvents.ChatClosed = API.RegisterScriptEvent("Event_ChatClosed");

    if Framework.IsNetworkGame() then
        return;
    end
end

function ModuleInputOutputCore.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.ChatClosed then
        for i= 1, Quests[0], 1 do
            if Quests[i].State == QuestState.Active and QSB.GoalInputDialogQuest == Quests[i].Identifier then
                for j= 1, #Quests[i].Objectives, 1 do
                    if Quests[i].Objectives[j].Type == Objective.Custom2 then
                        if Quests[i].Objectives[j].Data[1].Name == "Goal_InputDialog" then
                            Quests[i].Objectives[j].Data[1].InputDialogResult = arg[1];
                        end
                    end
                end
            end
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleInputOutputCore.Local:OnGameStart()
    QSB.ScriptEvents.ChatOpened = API.RegisterScriptEvent("Event_ChatOpened");
    QSB.ScriptEvents.ChatClosed = API.RegisterScriptEvent("Event_ChatClosed");

    if Framework.IsNetworkGame() then
        return;
    end
    self:OverrideQuicksave();
    self:OverrideCheats();
    self:DialogOverwriteOriginal();
    self:DialogAltF4Hotkey();
    -- Some kind of wierd timing problem...
    API.StartJob(function()
        self:OverrideDebugInput();
        return true;
    end);
end

function ModuleInputOutputCore.Local:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:OverrideDebugInput();
        self:OverrideCheats();
        self:DialogAltF4Hotkey();
    elseif _ID == QSB.ScriptEvents.ChatClosed then
        if Swift:IsProcessDebugCommands() then
            if arg[1] == "restartmap" then
                Framework.RestartMap();
            elseif arg[1]:find("^>") then
                GUI.SendScriptCommand(arg[1]:sub(3), true);
            elseif arg[1]:find("^>>") then
                GUI.SendScriptCommand(arg[1]:sub(4), false);
            elseif arg[1]:find("^<") then
                GUI.SendScriptCommand(string.format(
                    [[Script.Load("%s")]],
                    arg[1]:sub(3)
                ));
            elseif arg[1]:find("^<<") then
                Script.Load(arg[1]:sub(4));
            elseif arg[1]:find("^clear$") then
                GUI.ClearNotes();
            elseif arg[1]:find("^version$") then
                GUI.AddStaticNote(QSB.Version);
            end
        end
    end
end

function ModuleInputOutputCore.Local:OverrideQuicksave()
    API.AddBlockQuicksaveCondition(function()
        return ModuleInputOutputCore.Local.DialogWindowShown;
    end);
    
    KeyBindings_SaveGame = function()
        if not Swift:CanDoQuicksave() then
            return;
        end
        if g_Throneroom ~= nil
        or Framework and Framework.IsNetworkGame()
        or XGUIEng.IsWidgetShownEx("/InGame/MissionStatistic") == 1
        or GUI_Window.IsOpen("MissionEndScreen")
        or XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 1
        or XGUIEng.IsWidgetShownEx("/InGame/Dialog") == 1 then
            return;
        end
        OpenDialog(
            XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center") .. "{cr}{cr}{cr}{cr}{cr}" .. "QuickSave",
            XGUIEng.GetStringTableText("UI_Texts/Saving_center") .. "{cr}{cr}{cr}"
        );
        XGUIEng.ShowWidget("/InGame/Dialog/Ok", 0);
        Dialog_SetUpdateCallback(KeyBindings_SaveGame_Delayed);
    end

    SaveDialog_HoldGameState = function(name)
        SaveDialog.Name = name;
        if SaveDialog_SearchFilename(name) == true then
            OpenRequesterDialog(
                "{cr}" .. name .. " : " .. XGUIEng.GetStringTableText("UI_Texts/ConfirmOverwriteFile"),
                XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center"),
                "SaveDialog_SaveFile()"
            );
        else
            SaveDialog_SaveFile();
        end
    end

    SaveDialog_SaveFile = function()
        CloseSaveDialog();
        GUI_Window.Toggle("MainMenu");
        local SaveMsgText;
        if string.len(SaveDialog.Name) > 15 then
            SaveMsgText = XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center") .. "{cr}{cr}{cr}{cr}{cr}" .. SaveDialog.Name;
        else
            SaveMsgText = XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center") .. "{cr}{cr}{cr}{cr}{cr}" .. SaveDialog.Name;
        end
        OpenDialog(SaveMsgText, XGUIEng.GetStringTableText("UI_Texts/Saving_center") .. "{cr}{cr}{cr}");
        XGUIEng.ShowWidget("/InGame/Dialog/Ok", 0);
        Framework.SaveGame(SaveDialog.Name,"--");
    end

    GUI_Window.MainMenuSaveClicked = function()
        GUI_Window.CloseInGameMenu();
        OpenDialog(
            XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center") .. "{cr}{cr}{cr}{cr}{cr}" .. "QuickSave",
            XGUIEng.GetStringTableText("UI_Texts/Saving_center") .. "{cr}{cr}{cr}"
        );
        XGUIEng.ShowWidget("/InGame/Dialog/Ok", 0);
        Framework.SaveGame("QuickSave", "Quicksave");
    end
end

function ModuleInputOutputCore.Local:OverrideCheats()
    if self.CheatsDisabled then
        Input.KeyBindDown(
            Keys.ModifierControl + Keys.ModifierShift + Keys.Divide,
            "KeyBindings_EnableDebugMode(0)",
            2,
            false
        );
    else
        Input.KeyBindDown(
            Keys.ModifierControl + Keys.ModifierShift + Keys.Divide,
            "KeyBindings_EnableDebugMode(2)",
            2,
            false
        );
    end
end

-- Override the original usage of the chat box to make it compatible to this
-- module. Otherwise there would be no reaction whatsoever to console commands.
function ModuleInputOutputCore.Local:OverrideDebugInput()
    Swift.InitalizeQsbDebugShell = function(self)
        if not self.m_DevelopingShell then
            return;
        end
        Input.KeyBindDown(Keys.ModifierShift + Keys.OemPipe, "API.ShowTextInput(true)", 2, false);
    end
    Swift:InitalizeQsbDebugShell();
end

function ModuleInputOutputCore.Local:DialogAltF4Hotkey()
    StartSimpleJobEx(function ()
        if not API.IsLoadscreenVisible() then
            Input.KeyBindDown(Keys.ModifierAlt + Keys.F4, "ModuleInputOutputCore.Local:DialogAltF4Action()", 2, false);
            return true;
        end
    end);
end

function ModuleInputOutputCore.Local:DialogAltF4Action()
    Input.KeyBindDown(Keys.ModifierAlt + Keys.F4, "", 30, false);
    self:OpenRequesterDialog(
        XGUIEng.GetStringTableText("UI_Texts/MainMenuExitGame_center"),
        XGUIEng.GetStringTableText("UI_Texts/ConfirmQuitCurrentGame"),
        function (_Yes) 
            if _Yes then 
                Framework.ExitGame();
            end
            Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
            if not ModuleDisplayCore or not ModuleDisplayCore.Local.PauseScreenShown then
                XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 0);
            end
            ModuleInputOutputCore.Local:DialogAltF4Hotkey();
        end
    );
    Game.GameTimeSetFactor(GUI.GetPlayerID(), 0.0000001);
    XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 1);
end

function ModuleInputOutputCore.Local:Callback()
    if self.Requester.ActionFunction then
        self.Requester.ActionFunction(CustomGame.Knight + 1);
    end
    self:OnDialogClosed();
end

function ModuleInputOutputCore.Local:CallbackRequester(_yes)
    if self.Requester.ActionRequester then
        self.Requester.ActionRequester(_yes);
    end
    self:OnDialogClosed();
end

function ModuleInputOutputCore.Local:OnDialogClosed()
    self:DialogQueueStartNext();
    self:RestoreSaveGame();
end

function ModuleInputOutputCore.Local:DialogQueueStartNext()
    self.Requester.Next = table.remove(self.Requester.Queue, 1);

    DialogQueueStartNext_HiResControl = function()
        local Entry = ModuleInputOutputCore.Local.Requester.Next;
        if Entry and Entry[1] and Entry[2] then
            local Methode = Entry[1];
            ModuleInputOutputCore.Local[Methode]( ModuleInputOutputCore.Local, unpack(Entry[2]) );
            ModuleInputOutputCore.Local.Requester.Next = nil;
        end
        return true;
    end
    StartSimpleHiResJob("DialogQueueStartNext_HiResControl");
end

function ModuleInputOutputCore.Local:DialogQueuePush(_Methode, _Args)
    local Entry = {_Methode, _Args};
    table.insert(self.Requester.Queue, Entry);
end

function ModuleInputOutputCore.Local:OpenDialog(_Title, _Text, _Action)
    if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
        assert(type(_Title) == "string");
        assert(type(_Text) == "string");

        _Title = "{center}" .. _Title;
        if string.len(_Text) < 35 then
            _Text = _Text .. "{cr}";
        end

        g_MapAndHeroPreview.SelectKnight = function(_Knight)
        end

        XGUIEng.ShowAllSubWidgets("/InGame/Dialog/BG",1);
        XGUIEng.ShowWidget("/InGame/Dialog/Backdrop",0);
        XGUIEng.ShowWidget(RequesterDialog,1);
        XGUIEng.ShowWidget(RequesterDialog_Yes,0);
        XGUIEng.ShowWidget(RequesterDialog_No,0);
        XGUIEng.ShowWidget(RequesterDialog_Ok,1);

        if type(_Action) == "function" then
            self.Requester.ActionFunction = _Action;
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)";
            Action = Action .. "; XGUIEng.PopPage()";
            Action = Action .. "; ModuleInputOutputCore.Local.Callback(ModuleInputOutputCore.Local)";
            XGUIEng.SetActionFunction(RequesterDialog_Ok, Action);
        else
            self.Requester.ActionFunction = nil;
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)";
            Action = Action .. "; XGUIEng.PopPage()";
            Action = Action .. "; ModuleInputOutputCore.Local.Callback(ModuleInputOutputCore.Local)";
            XGUIEng.SetActionFunction(RequesterDialog_Ok, Action);
        end

        XGUIEng.SetText(RequesterDialog_Message, "{center}" .. _Text);
        XGUIEng.SetText(RequesterDialog_Title, _Title);
        XGUIEng.SetText(RequesterDialog_Title.."White", _Title);
        XGUIEng.PushPage(RequesterDialog,false);

        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", 0);
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame", 0);
        self.DialogWindowShown = true;
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 0.0000001);
        XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 1);
    else
        self:DialogQueuePush("OpenDialog", {_Title, _Text, _Action});
    end
end

function ModuleInputOutputCore.Local:OpenRequesterDialog(_Title, _Text, _Action, _OkCancel)
    if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
        assert(type(_Title) == "string");
        assert(type(_Text) == "string");
        _Title = "{center}" .. _Title;

        self:OpenDialog(_Title, _Text, _Action);
        XGUIEng.ShowWidget(RequesterDialog_Yes,1);
        XGUIEng.ShowWidget(RequesterDialog_No,1);
        XGUIEng.ShowWidget(RequesterDialog_Ok,0);

        if _OkCancel then
            XGUIEng.SetText(RequesterDialog_Yes, XGUIEng.GetStringTableText("UI_Texts/Ok_center"));
            XGUIEng.SetText(RequesterDialog_No, XGUIEng.GetStringTableText("UI_Texts/Cancel_center"));
        else
            XGUIEng.SetText(RequesterDialog_Yes, XGUIEng.GetStringTableText("UI_Texts/Yes_center"));
            XGUIEng.SetText(RequesterDialog_No, XGUIEng.GetStringTableText("UI_Texts/No_center"));
        end

        self.Requester.ActionRequester = nil;
        if _Action then
            assert(type(_Action) == "function");
            self.Requester.ActionRequester = _Action;
        end
        local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
        Action = Action .. "; Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; ModuleInputOutputCore.Local.CallbackRequester(ModuleInputOutputCore.Local, true)"
        XGUIEng.SetActionFunction(RequesterDialog_Yes, Action);
        local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)"
        Action = Action .. "; Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; ModuleInputOutputCore.Local.CallbackRequester(ModuleInputOutputCore.Local, false)"
        XGUIEng.SetActionFunction(RequesterDialog_No, Action);
    else
        self:DialogQueuePush("OpenRequesterDialog", {_Title, _Text, _Action, _OkCancel});
    end
end

function ModuleInputOutputCore.Local:OpenSelectionDialog(_Title, _Text, _Action, _List)
    if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
        self:OpenDialog(_Title, _Text, _Action);

        local HeroComboBoxID = XGUIEng.GetWidgetID(CustomGame.Widget.KnightsList);
        XGUIEng.ListBoxPopAll(HeroComboBoxID);
        for i=1,#_List do
            XGUIEng.ListBoxPushItem(HeroComboBoxID, _List[i] );
        end
        XGUIEng.ListBoxSetSelectedIndex(HeroComboBoxID, 0);
        CustomGame.Knight = 0;

        local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)"
        Action = Action .. "; Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; ModuleInputOutputCore.Local.Callback(ModuleInputOutputCore.Local)";
        XGUIEng.SetActionFunction(RequesterDialog_Ok, Action);

        local Container = "/InGame/Singleplayer/CustomGame/ContainerSelection/";
        XGUIEng.SetText(Container .. "HeroComboBoxMain/HeroComboBox", "");
        if _List[1] then
            XGUIEng.SetText(Container .. "HeroComboBoxMain/HeroComboBox", _List[1]);
        end
        XGUIEng.PushPage(Container .. "HeroComboBoxContainer", false);
        XGUIEng.PushPage(Container .. "HeroComboBoxMain",false);
        XGUIEng.ShowWidget(Container .. "HeroComboBoxContainer", 0);
        local screen = {GUI.GetScreenSize()};
        local x1, y1 = XGUIEng.GetWidgetScreenPosition(RequesterDialog_Ok);
        XGUIEng.SetWidgetScreenPosition(Container .. "HeroComboBoxMain", x1-25, y1-(90*(screen[2]/1080)));
        XGUIEng.SetWidgetScreenPosition(Container .. "HeroComboBoxContainer", x1-25, y1-(20*(screen[2]/1080)));
    else
        self:DialogQueuePush("OpenSelectionDialog", {_Title, _Text, _Action, _List});
    end
end

function ModuleInputOutputCore.Local:RestoreSaveGame()
    if not ModuleInterfaceCore or not ModuleInterfaceCore.Local.ForbidRegularSave then
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", 1);
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame", 1);
    end
    self.DialogWindowShown = false;
end

function ModuleInputOutputCore.Local:DialogOverwriteOriginal()
    OpenDialog_Orig_Windows = OpenDialog;
    OpenDialog = function(_Message, _Title, _IsMPError)
        if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; XGUIEng.PopPage()";
            OpenDialog_Orig_Windows(_Title, _Message);
        end
    end

    OpenRequesterDialog_Orig_Windows = OpenRequesterDialog;
    OpenRequesterDialog = function(_Message, _Title, action, _OkCancel, no_action)
        if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; XGUIEng.PopPage()";
            XGUIEng.SetActionFunction(RequesterDialog_Yes, Action);
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; XGUIEng.PopPage()";
            XGUIEng.SetActionFunction(RequesterDialog_No, Action);
            OpenRequesterDialog_Orig_Windows(_Message, _Title, action, _OkCancel, no_action);
        end
    end
end

function ModuleInputOutputCore.Local:ShowInputBox(_Debug)
    Swift:SetProcessDebugCommands(_Debug);
    StartSimpleHiResJob("ModuleInputOutputCore_Local_InputBoxJob");
end

function ModuleInputOutputCore_Local_InputBoxJob()
    Input.ChatMode();
    Game.GameTimeSetFactor(GUI.GetPlayerID(), 0.0000001);
    XGUIEng.SetText("/InGame/Root/Normal/ChatInput/ChatInput", "");
    XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput", 1);
    XGUIEng.SetFocus("/InGame/Root/Normal/ChatInput/ChatInput");
    return true;
end

function ModuleInputOutputCore.Local:PrepareInputVariable()
    GUI.SendScriptCommand(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.ChatOpened, %d)",
        GUI.GetPlayerID()
    ));
    API.SendScriptEvent(QSB.ScriptEvents.ChatOpened, GUI.GetPlayerID());

    GUI_Chat.Abort_Orig_ModuleInputOutputCore = GUI_Chat.Abort_Orig_ModuleInputOutputCore or GUI_Chat.Abort;
    GUI_Chat.Confirm_Orig_ModuleInputOutputCore = GUI_Chat.Confirm_Orig_ModuleInputOutputCore or GUI_Chat.Confirm;

    GUI_Chat.Confirm = function()
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput", 0);
        if not ModuleDisplayCore or not ModuleDisplayCore.Local.PauseScreenShown then
            XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 0);
        end
        local ChatMessage = XGUIEng.GetText("/InGame/Root/Normal/ChatInput/ChatInput");
        g_Chat.JustClosed = 1;
        ModuleInputOutputCore.Local:LocalToGlobal(ChatMessage);
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
        Input.GameMode();
    end

    GUI_Chat.Abort = function()
    end
end

function ModuleInputOutputCore.Local:LocalToGlobal(_Text)
    _Text = (_Text == nil and "") or _Text;
    API.SendScriptEvent(QSB.ScriptEvents.ChatClosed, _Text);
    GUI.SendScriptCommand(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.ChatClosed, "%s", %d)]],
        _Text,
        GUI.GetPlayerID()
    ));
    Swift:SetProcessDebugCommands(false);
end

-- Shared ------------------------------------------------------------------- --

function ModuleInputOutputCore.Shared:Note(_Text)
    _Text = self:ConvertPlaceholders(Swift:Localize(_Text));
    if Swift:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState(string.format(
            [[GUI.AddNote("%s")]],
            _Text
        ));
    else
        GUI.AddNote(_Text);
    end
end

function ModuleInputOutputCore.Shared:StaticNote(_Text)
    _Text = self:ConvertPlaceholders(Swift:Localize(_Text));
    if Swift:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState(string.format(
            [[GUI.AddStaticNote("%s")]],
            _Text
        ));
        return;
    end
    GUI.AddStaticNote(_Text);
end

function ModuleInputOutputCore.Shared:Message(_Text)
    _Text = self:ConvertPlaceholders(Swift:Localize(_Text));
    if Swift:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState(string.format(
            [[Message("%s")]],
            _Text
        ));
        return;
    end
    Message(_Text);
end

function ModuleInputOutputCore.Shared:ClearNotes()
    if Swift:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState([[GUI.ClearNotes()]]);
        return;
    end
    GUI.ClearNotes();
end

function ModuleInputOutputCore.Shared:ConvertPlaceholders(_Text)
    local s1, e1, s2, e2;
    while true do
        local Before, Placeholder, After, Replacement, s1, e1, s2, e2;
        if _Text:find("{name:") then
            Before, Placeholder, After, s1, e1, s2, e2 = self:SplicePlaceholderText(_Text, "{name:");
            Replacement = self.Placeholders.Names[Placeholder];
            _Text = Before .. Swift:Localize(Replacement or "ERROR_PLACEHOLDER_NOT_FOUND") .. After;
        elseif _Text:find("{type:") then
            Before, Placeholder, After, s1, e1, s2, e2 = self:SplicePlaceholderText(_Text, "{type:");
            Replacement = self.Placeholders.EntityTypes[Placeholder];
            _Text = Before .. Swift:Localize(Replacement or "ERROR_PLACEHOLDER_NOT_FOUND") .. After;
        end
        if s1 == nil or e1 == nil or s2 == nil or e2 == nil then
            break;
        end
    end
    _Text = self:ReplaceColorPlaceholders(_Text);
    return _Text;
end

function ModuleInputOutputCore.Shared:SplicePlaceholderText(_Text, _Start)
    local s1, e1 = _Text:find(_Start);
    local s2, e2 = _Text:find("}", e1);

    local Before      = _Text:sub(1, s1-1);
    local Placeholder = _Text:sub(e1+1, s2-1);
    local After       = _Text:sub(e2+1);
    return Before, Placeholder, After, s1, e1, s2, e2;
end

function ModuleInputOutputCore.Shared:ReplaceColorPlaceholders(_Text)
    for k, v in pairs(self.Colors) do
        _Text = _Text:gsub("{" ..k.. "}", v);
    end
    return _Text;
end

function ModuleInputOutputCore.Shared:CommandTokenizer(_Input)
    local Commands = {};
    if _Input == nil then
        return Commands;
    end
    local DAmberCommands = {_Input};
    local AmberCommands = {};

    -- parse & delimiter
    local s, e = string.find(_Input, "%s+&&%s+");
    if s then
        DAmberCommands = {};
        while (s) do
            local tmp = string.sub(_Input, 1, s-1);
            table.insert(DAmberCommands, tmp);
            _Input = string.sub(_Input, e+1);
            s, e = string.find(_Input, "%s+&&%s+");
        end
        if string.len(_Input) > 0 then 
            table.insert(DAmberCommands, _Input);
        end
    end

    -- parse & delimiter
    for i= 1, #DAmberCommands, 1 do
        local s, e = string.find(DAmberCommands[i], "%s+&%s+");
        if s then
            local LastCommand = "";
            while (s) do
                local tmp = string.sub(DAmberCommands[i], 1, s-1);
                table.insert(AmberCommands, LastCommand .. tmp);
                if string.find(tmp, " ") then
                    LastCommand = string.sub(tmp, 1, string.find(tmp, " ")-1) .. " ";
                end
                DAmberCommands[i] = string.sub(DAmberCommands[i], e+1);
                s, e = string.find(DAmberCommands[i], "%s+&%s+");
            end
            if string.len(DAmberCommands[i]) > 0 then 
                table.insert(AmberCommands, LastCommand .. DAmberCommands[i]);
            end
        else
            table.insert(AmberCommands, DAmberCommands[i]);
        end
    end

    -- parse spaces
    for i= 1, #AmberCommands, 1 do
        local CommandLine = {};
        local s, e = string.find(AmberCommands[i], "%s+");
        if s then
            while (s) do
                local tmp = string.sub(AmberCommands[i], 1, s-1);
                table.insert(CommandLine, tmp);
                AmberCommands[i] = string.sub(AmberCommands[i], e+1);
                s, e = string.find(AmberCommands[i], "%s+");
            end
            table.insert(CommandLine, AmberCommands[i]);
        else
            table.insert(CommandLine, AmberCommands[i]);
        end
        table.insert(Commands, CommandLine);
    end

    return Commands;
end

-- TextWindow class ------------------------------------------------------------

QSB.TextWindow = {
    Shown       = false,
    Caption     = "",
    Text        = "",
    ButtonText  = "",
    Picture     = nil,
    Action      = nil,
    Pause       = true,
    Callback    = function() end,
};

---
-- Erzeugt ein Textfenster, dass einen beliebig großen Text anzeigen kann.
-- Optional kann ein Button genutzt werden, der eine Aktion ausführt, wenn
-- er gedrückt wird.
--
-- Parameterliste:
-- <table>
-- <tr>
-- <th>Index</th>
-- <th>Beschreibung</th>
-- </tr>
-- <tr>
-- <td>1</td>
-- <td>Titel des Fensters</td>
-- </tr>
-- <tr>
-- <td>2</td>
-- <td>Text des Fensters</td>
-- </tr>
-- <tr>
-- <td>3</td>
-- <td>Aktion nach dem Schließen</td>
-- </tr>
-- <tr>
-- <td>4</td>
-- <td>Beschriftung des Buttons</td>
-- </tr>
-- <tr>
-- <td>5</td>
-- <td>Callback des Buttons</td>
-- </tr>
-- </table>
--
-- @param ... Parameterliste
-- @return[type=table] Instanz des konfigurierten Fensters
-- @within QSB.TextWindow
-- @local
--
-- @usage
-- local MyWindow = TextWindow:New("Fenster", "Das ist ein Text");
--
function QSB.TextWindow:New(...)
    assert(self == QSB.TextWindow, "Can not be used from instance!")
    local window      = table.copy(self);
    window.Caption    = arg[1] or window.Caption;
    window.Text       = arg[2] or window.Text;
    window.Action     = arg[3];
    window.ButtonText = arg[4] or window.ButtonText;
    window.Callback   = arg[5] or window.Callback;
    return window;
end

---
-- Fügt einen beliebigen Parameter hinzu. Parameter müssen immer als
-- Schlüssel-Wert-Paare angegeben werden und dürfen vorhandene Pare nicht
-- überschreiben.
--
-- @param[type=string] _Key   Schlüssel
-- @param              _Value Wert
-- @return self
-- @within QSB.TextWindow
-- @local
--
-- @usage
-- MyWindow:AddParameter("Name", "Horst");
--
function QSB.TextWindow:AddParamater(_Key, _Value)
    assert(self ~= QSB.TextWindow, "Can not be used in static context!");
    assert(self[_Key] ~= nil, "Key '" .._Key.. "' already exists!");
    self[_Key] = _Value;
    return self;
end

---
-- Setzt die Überschrift des TextWindow.
--
-- @param[type=string] _Flag Spiel pausieren
-- @return self
-- @within QSB.TextWindow
-- @local
--
-- @usage
-- MyWindow:SetPause(false);
--
function QSB.TextWindow:SetPause(_Flag)
    assert(self ~= QSB.TextWindow, "Can not be used in static context!");
    self.Pause = _Flag == true;
    return self;
end

---
-- Setzt die Überschrift des TextWindow.
--
-- @param[type=string] _Text Titel des Textfenster
-- @return self
-- @within QSB.TextWindow
-- @local
--
-- @usage
-- MyWindow:SetCaption("Das ist der Titel");
--
function QSB.TextWindow:SetCaption(_Text)
    assert(self ~= QSB.TextWindow, "Can not be used in static context!");
    assert(type(_Text) == "string");
    self.Caption = API.Localize(_Text);
    return self;
end

---
-- Setzt den Inhalt des TextWindow.
--
-- @param[type=string] _Text Inhalt des Textfenster
-- @return self
-- @within QSB.TextWindow
-- @local
--
-- @usage
-- MyWindow:SetCaption("Das ist der Text. Er ist sehr informativ!");
--
function QSB.TextWindow:SetContent(_Text)
    assert(self ~= QSB.TextWindow, "Can not be used in static context!");
    assert(type(_Text) == "string");
    self.Text = API.Localize(_Text);
    return self;
end

---
-- Setzt die Close Action des TextWindow. Die Funktion wird beim schließen
-- des Fensters ausgeführt.
--
-- @param[type=function] _Function Close Callback
-- @return self
-- @within QSB.TextWindow
-- @local
--
-- @usage
-- local MyAction = function(_Window)
--     -- Something is done here!
-- end
-- MyWindow:SetAction(MyAction);
--
function QSB.TextWindow:SetAction(_Function)
    assert(self ~= QSB.TextWindow, "Can not be used in static context!");
    assert(nil or type(_Function) == "function");
    self.Callback = _Function;
    return self;
end

---
-- Setzt einen Aktionsbutton im TextWindow.
--
-- Der Button muss mit einer Funktion versehen werden. Sobald der Button
-- betätigt wird, wird die Funktion ausgeführt.
--
-- @param[type=string]   _Text     Beschriftung des Buttons
-- @param[type=function] _Callback Aktion des Buttons
-- @return self
-- @within QSB.TextWindow
-- @local
--
-- @usage
-- local MyButtonAction = function(_Window)
--     -- Something is done here!
-- end
-- MyWindow:SetAction("Button Text", MyButtonAction);
--
function QSB.TextWindow:SetButton(_Text, _Callback)
    assert(self ~= QSB.TextWindow, "Can not be used in static context!");
    if _Text then
        _Text = API.Localize(_Text);
        assert(type(_Text) == "string");
        assert(type(_Callback) == "function");
    end
    self.ButtonText = _Text;
    self.Action     = _Callback;
    return self;
end

---
-- Zeigt ein erzeigtes Fenster an.
--
-- @within QSB.TextWindow
-- @local
--
-- @usage
-- MyWindow:Show();
--
function QSB.TextWindow:Show()
    assert(self ~= QSB.TextWindow, "Can not be used in static context!");
    QSB.TextWindow.Shown = true;
    self.Shown = true;
    self:Prepare();

    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions",1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ToggleWhisperTarget",1);
    if not self.Action then
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ToggleWhisperTarget",0);
    end
    XGUIEng.SetText("/InGame/Root/Normal/MessageLog/Name","{center}"..self.Caption);
    XGUIEng.SetText("/InGame/Root/Normal/ChatOptions/ToggleWhisperTarget","{center}"..self.ButtonText);
    GUI_Chat.ClearMessageLog();
    GUI_Chat.ChatlogAddMessage(self.Text);

    local stringlen = string.len(self.Text);
    local iterator  = 1;
    local carreturn = 0;
    while (true)
    do
        local s,e = string.find(self.Text, "{cr}", iterator);
        if not e then
            break;
        end
        if e-iterator <= 58 then
            stringlen = stringlen + 58-(e-iterator);
        end
        iterator = e+1;
    end
    if (stringlen + (carreturn*55)) > 1000 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatLogSlider",1);
    end
    if self.Pause then
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 0);
    end
end

---
-- Initialisiert das TextWindow, bevor es angezeigt wird.
--
-- @within QSB.TextWindow
-- @local
--
function QSB.TextWindow:Prepare()
    function GUI_Chat.CloseChatMenu()
        QSB.TextWindow.Shown = false;
        self.Shown = false;
        if self.Callback then
            self:Callback();
        end
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions",0);
        XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog",0);
        XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/BG",1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Close",1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Slider",1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Text",1);
        Game.GameTimeReset(GUI.GetPlayerID());
    end

    function GUI_Chat.ToggleWhisperTargetUpdate()
        if self.Pause then
            Game.GameTimeSetFactor(GUI.GetPlayerID(), 0);
        end
    end

    function GUI_Chat.CheckboxMessageTypeWhisperUpdate()
        XGUIEng.SetText("/InGame/Root/Normal/ChatOptions/TextCheckbox","{center}"..self.Caption);
    end

    function GUI_Chat.ToggleWhisperTarget()
        if self.Action then
            self.Action(self);
        end
    end

    function GUI_Chat.ClearMessageLog()
        g_Chat.ChatHistory = {}
    end

    function GUI_Chat.ChatlogAddMessage(_Message)
        table.insert(g_Chat.ChatHistory, _Message)
        local ChatlogMessage = ""
        for i,v in ipairs(g_Chat.ChatHistory) do
            ChatlogMessage = ChatlogMessage .. v .. "{cr}"
        end
        XGUIEng.SetText("/InGame/Root/Normal/ChatOptions/ChatLog", ChatlogMessage)
    end

    if type(self.Caption) == "table" then
        self.Caption = API.Localize(self.Caption);
    end
    if type(self.ButtonText) == "table" then
        self.ButtonText = API.Localize(self.ButtonText);
    end
    if type(self.Text) == "table" then
        self.Text = API.Localize(self.Text);
    end

    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatModeAllPlayers",0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatModeTeam",0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatModeWhisper",0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatChooseModeCaption",0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/Background/TitleBig",1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/Background/TitleBig/Info",0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatLogCaption",0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/BGChoose",0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/BGChatLog",0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatLogSlider",0);

    XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog",1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/BG",0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Close",0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Slider",0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Text",0);

    XGUIEng.DisableButton("/InGame/Root/Normal/ChatOptions/ToggleWhisperTarget",0);

    XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/MessageLog",0,95);
    XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/MessageLog/Name",0,0);
    XGUIEng.SetTextColor("/InGame/Root/Normal/MessageLog/Name",51,51,121,255);
    XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/ChatOptions/ChatLog",140,150);
    XGUIEng.SetWidgetSize("/InGame/Root/Normal/ChatOptions/Background/DialogBG/1 (2)/2",150,400);
    XGUIEng.SetWidgetPositionAndSize("/InGame/Root/Normal/ChatOptions/Background/DialogBG/1 (2)/3",400,500,350,400);
    XGUIEng.SetWidgetSize("/InGame/Root/Normal/ChatOptions/ChatLog",640,580);
    XGUIEng.SetWidgetSize("/InGame/Root/Normal/ChatOptions/ChatLogSlider",46,660);
    XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/ChatOptions/ChatLogSlider",780,130);
    XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/ChatOptions/ToggleWhisperTarget",110,760);
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleInputOutputCore);

