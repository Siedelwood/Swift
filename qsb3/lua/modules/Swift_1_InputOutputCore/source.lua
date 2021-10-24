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

function ModuleInputOutputCore.Global:OnEvent(_ID, _Event, _Text)
    if _ID == QSB.ScriptEvents.ChatClosed then
        if _Text == "restartmap" then
            Framework.RestartMap();
        else
            for i= 1, Quests[0], 1 do
                if Quests[i].State == QuestState.Active and QSB.GoalInputDialogQuest == Quests[i].Identifier then
                    for j= 1, #Quests[i].Objectives, 1 do
                        if Quests[i].Objectives[j].Type == Objective.Custom2 then
                            if Quests[i].Objectives[j].Data[1].Name == "Goal_InputDialog" then
                                Quests[i].InputDialogResult = _Text;
                            end
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
    self:DialogOverwriteOriginal();
    self:DialogAltF4Hotkey();
    -- Some kind of wierd timing problem...
    API.StartJob(function()
        self:OverrideDebugInput();
        return true;
    end);
end

function ModuleInputOutputCore.Local:OnEvent(_ID, _Event, _Text)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:OverrideDebugInput();
        self:DialogAltF4Hotkey();
    elseif _ID == QSB.ScriptEvents.ChatClosed then
        if _Text:find("^>.*$") then
            GUI.SendScriptCommand(_Text:sub(3), true);
        elseif _Text:find("^>>.*$") then
            GUI.SendScriptCommand(_Text:sub(4), false);
        end
    end
end

function ModuleInputOutputCore.Local:OverrideQuicksave()
    Swift:AddBlockQuicksaveCondition(function()
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
        -- OpenDialog(
        --     XGUIEng.GetStringTableText("UI_Texts/Saving_center") .. "{cr}{cr}" .. "QuickSave",
        --     XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center")
        -- );
        ModuleInputOutputCore.Local:OpenDialog(
            XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center"),
            XGUIEng.GetStringTableText("UI_Texts/Saving_center") .. "{cr}{cr}" .. "QuickSave"
        );
        XGUIEng.ShowWidget("/InGame/Dialog/Ok", 0);
        Dialog_SetUpdateCallback(KeyBindings_SaveGame_Delayed);
    end
end

-- Override the original usage of the chat box to make it compatible to this
-- module. Otherwise there would be no reaction whatsoever to console commands.
function ModuleInputOutputCore.Local:OverrideDebugInput()
    Swift.InitalizeQsbDebugShell = function(self)
        if not self.m_DevelopingShell then
            return;
        end
        Input.KeyBindDown(Keys.ModifierControl + Keys.X, "API.ShowTextInput()", 2, false);
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

        g_MapAndHeroPreview.SelectKnight = function()
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

        if _OkCancel ~= nil then
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
    if BundleGameHelperFunctions and not BundleGameHelperFunctions.Local.ForbidSave then
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

function ModuleInputOutputCore.Local:ShowInputBox()
    Input.ChatMode();
    Game.GameTimeSetFactor(GUI.GetPlayerID(), 0.0000001);
    XGUIEng.SetText("/InGame/Root/Normal/ChatInput/ChatInput", "");
    XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput", 1);
    XGUIEng.SetFocus("/InGame/Root/Normal/ChatInput/ChatInput");
end

function ModuleInputOutputCore.Local:PrepareInputVariable()
    GUI.SendScriptCommand("API.SendScriptEvent(QSB.ScriptEvents.ChatOpened)");
    API.SendScriptEvent(QSB.ScriptEvents.ChatOpened);

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
end

-- Shared ------------------------------------------------------------------- --

function ModuleInputOutputCore.Shared:Note(_Text)
    _Text = self:ConvertPlaceholders(Swift:Localize(_Text));
    if Swift:IsGlobalEnvironment() then
        Logic.DEBUG_AddNote(_Text);
    else
        GUI.AddNote(_Text);
    end
end

function ModuleInputOutputCore.Shared:StaticNote(_Text)
    _Text = self:ConvertPlaceholders(Swift:Localize(_Text));
    if Swift:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState(string.format([[GUI.AddStaticNote("%s")]], _Text));
        return;
    end
    GUI.AddStaticNote(_Text);
end

function ModuleInputOutputCore.Shared:Message(_Text)
    _Text = self:ConvertPlaceholders(Swift:Localize(_Text));
    if Swift:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState(string.format([[Message("%s")]], _Text));
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

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleInputOutputCore);

