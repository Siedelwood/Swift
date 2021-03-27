-- -------------------------------------------------------------------------- --
-- Module Dialog Tools                                                        --
-- -------------------------------------------------------------------------- --

ModuleDialogCore = {
    Properties = {
        Name = "ModuleDialogCore",
    },

    Global = {},
    Local = {
        Requester = {
            ActionFunction = nil,
            ActionRequester = nil,
            Next = nil,
            Queue = {},
        },
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
}

-- Global Script ---------------------------------------------------------------

function ModuleDialogCore.Global:OnGameStart()
    API.AddSaveGameAction(function ()
        Logic.ExecuteInLuaLocalState("ModuleDialogCore.Local.DialogAltF4Hotkey()");
    end);
end

-- Local Script ----------------------------------------------------------------

function ModuleDialogCore.Local:OnGameStart()
    self:DialogOverwriteOriginal();
    self:DialogAltF4Hotkey();
end

function ModuleDialogCore.Local:DialogAltF4Hotkey()
    StartSimpleJobEx(function ()
        if not API.IsLoadscreenVisible() then
            Input.KeyBindDown(Keys.ModifierAlt + Keys.F4, "ModuleDialogCore.Local:DialogAltF4Action()", 30, false);
            return true;
        end
    end);
end

function ModuleDialogCore.Local:DialogAltF4Action()
    -- Muss leider sein, sonst werden mehr Elemente in die Queue geladen
    Input.KeyBindDown(Keys.ModifierAlt + Keys.F4, "", 30, false);

    -- Selbstgebauten Dialog öffnen
    self:OpenRequesterDialog(
        XGUIEng.GetStringTableText("UI_Texts/MainMenuExitGame_center"),
        XGUIEng.GetStringTableText("UI_Texts/ConfirmQuitCurrentGame"),
        function (_Yes) 
            if _Yes then 
                Framework.ExitGame(); 
            end
            ModuleDialogCore.Local:DialogAltF4Hotkey();
            Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
        end
    );

    -- Zeit anhelten
    Game.GameTimeSetFactor(GUI.GetPlayerID(), 0);
end

function ModuleDialogCore.Local:Callback()
    if self.Requester.ActionFunction then
        self.Requester.ActionFunction(CustomGame.Knight + 1);
    end
    self:OnDialogClosed();
end

function ModuleDialogCore.Local:CallbackRequester(_yes)
    if self.Requester.ActionRequester then
        self.Requester.ActionRequester(_yes);
    end
    self:OnDialogClosed();
end

function ModuleDialogCore.Local:OnDialogClosed()
    self:DialogQueueStartNext();
    self:RestoreSaveGame();
end

function ModuleDialogCore.Local:DialogQueueStartNext()
    self.Requester.Next = table.remove(self.Requester.Queue, 1);

    DialogQueueStartNext_HiResControl = function()
        local Entry = ModuleDialogCore.Local.Requester.Next;
        if Entry and Entry[1] and Entry[2] then
            local Methode = Entry[1];
            ModuleDialogCore.Local[Methode]( ModuleDialogCore.Local, unpack(Entry[2]) );
            ModuleDialogCore.Local.Requester.Next = nil;
        end
        return true;
    end
    StartSimpleHiResJob("DialogQueueStartNext_HiResControl");
end

function ModuleDialogCore.Local:DialogQueuePush(_Methode, _Args)
    local Entry = {_Methode, _Args};
    table.insert(self.Requester.Queue, Entry);
end

function ModuleDialogCore.Local:OpenDialog(_Title, _Text, _Action)
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
            Action = Action .. "; ModuleDialogCore.Local.Callback(ModuleDialogCore.Local)";
            XGUIEng.SetActionFunction(RequesterDialog_Ok, Action);
        else
            self.Requester.ActionFunction = nil;
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)";
            Action = Action .. "; XGUIEng.PopPage()";
            Action = Action .. "; ModuleDialogCore.Local.Callback(ModuleDialogCore.Local)";
            XGUIEng.SetActionFunction(RequesterDialog_Ok, Action);
        end

        XGUIEng.SetText(RequesterDialog_Message, "{center}" .. _Text);
        XGUIEng.SetText(RequesterDialog_Title, _Title);
        XGUIEng.SetText(RequesterDialog_Title.."White", _Title);
        XGUIEng.PushPage(RequesterDialog,false);

        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", 0);
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame", 0);
        if not KeyBindings_SaveGame_Orig_QSB_Windows then
            KeyBindings_SaveGame_Orig_QSB_Windows = KeyBindings_SaveGame;
            KeyBindings_SaveGame = function() end;
        end
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 0);
    else
        self:DialogQueuePush("OpenDialog", {_Title, _Text, _Action});
    end
end

function ModuleDialogCore.Local:OpenRequesterDialog(_Title, _Text, _Action, _OkCancel)
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
        Action = Action .. "; ModuleDialogCore.Local.CallbackRequester(ModuleDialogCore.Local, true)"
        XGUIEng.SetActionFunction(RequesterDialog_Yes, Action);
        local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)"
        Action = Action .. "; Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; ModuleDialogCore.Local.CallbackRequester(ModuleDialogCore.Local, false)"
        XGUIEng.SetActionFunction(RequesterDialog_No, Action);
    else
        self:DialogQueuePush("OpenRequesterDialog", {_Title, _Text, _Action, _OkCancel});
    end
end

function ModuleDialogCore.Local:OpenSelectionDialog(_Title, _Text, _Action, _List)
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
        Action = Action .. "; ModuleDialogCore.Local.Callback(ModuleDialogCore.Local)";
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

function ModuleDialogCore.Local:RestoreSaveGame()
    if BundleGameHelperFunctions and not BundleGameHelperFunctions.Local.ForbidSave then
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", 1);
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame", 1);
    end
    if KeyBindings_SaveGame_Orig_QSB_Windows then
        KeyBindings_SaveGame = KeyBindings_SaveGame_Orig_QSB_Windows;
        KeyBindings_SaveGame_Orig_QSB_Windows = nil;
    end
end

function ModuleDialogCore.Local:DialogOverwriteOriginal()
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

-- TextWindow class ------------------------------------------------------------

QSB.TextWindow = {
    Shown       = false,
    Caption     = "",
    Text        = "",
    ButtonText  = "",
    Picture     = nil,
    Action      = nil,
    Callback    = function() end,
};

---
-- Erzeugt ein Textfenster, dass einen beliebig großen Text anzeigen kann.
-- Optional kann ein Button genutzt werden, der eine Aktion ausführt, wenn
-- er gedrückt wird.
--
-- <p><b>Alias</b>: TextWindow:New</p>
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
    local window           = API.InstanceTable(self);
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
-- <p><b>Alias</b>: TextWindow:AddParamater</p>
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
-- <p><b>Alias</b>: TextWindow:SetCaption</p>
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
-- <p><b>Alias</b>: TextWindow:SetContent</p>
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
-- <p><b>Alias</b>: TextWindow:SetAction</p>
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
-- <p><b>Alias</b>: TextWindow:SetButton</p>
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
-- <p><b>Alias</b>: TextWindow:Show</p>
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
    Game.GameTimeSetFactor(GUI.GetPlayerID(), 0);
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
            self.Callback(self);
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
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 0);
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

Swift:RegisterModules(ModuleDialogCore);

