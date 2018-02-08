-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleDialogWindows                                          # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Bundle kommen einige Funktionen für das lokale Skript hinzu, die
-- es ermöglichen verschiedene Dialoge oder ein Textfenster anzuzeigen.
--
-- @module BundleDialogWindows
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Öffnet einen Info-Dialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- @param _Title  Titel des Dialog
-- @param _Text   Text des Dialog
-- @param _Action Callback-Funktion
-- @within User-Space
--
function API.OpenDialog(_Title, _Text, _Action)
    if not GUI then
        API.Dbg("API.OpenDialog: Can only be used in the local script!");
        return;
    end
    
    local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    if type(_Title) == "table" then
       _Title = _Title[lang];
    end
    if type(_Text) == "table" then
       _Text = _Text[lang];
    end
    return BundleDialogWindows.Local:OpenDialog(_Title, _Text, _Action);
end

---
-- Öffnet einen Ja-Nein-Dialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- @param _Title    Titel des Dialog
-- @param _Text     Text des Dialog
-- @param _Action   Callback-Funktion
-- @param _OkCancel Okay/Abbrechen statt Ja/Nein
-- @within User-Space
--
function API.OpenRequesterDialog(_Title, _Text, _Action, _OkCancel)
    if not GUI then
        API.Dbg("API.OpenRequesterDialog: Can only be used in the local script!");
        return;
    end
    
    local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    if type(_Title) == "table" then
       _Title = _Title[lang];
    end
    if type(_Text) == "table" then
       _Text = _Text[lang];
    end
    return BundleDialogWindows.Local:OpenRequesterDialog(_Title, _Text, _Action, _OkCancel);
end

---
-- Öffnet einen Auswahldialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- @param _Title  Titel des Dialog
-- @param _Text   Text des Dialog
-- @param _Action Callback-Funktion
-- @param _List   Liste der Optionen
-- @within User-Space
--
function API.OpenSelectionDialog(_Title, _Text, _Action, _List)
    if not GUI then
        API.Dbg("API.OpenSelectionDialog: Can only be used in the local script!");
        return;
    end
    
    if type(_Text) == "table" then
        _Text.de = _Text.de .. "{cr}";
        _Text.en = _Text.en .. "{cr}";
    else
        _Text = _Text .. "{cr}";
    end
    return BundleDialogWindows.Local:OpenSelectionDialog(_Title, _Text, _Action, _List);
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleDialogWindows = {
    Global = {
        Data = {}
    },
    Local = {
        Data = {
            Requester = {
                ActionFunction = nil,
                ActionRequester = nil,
                Next = nil,
                Queue = {},
            },
        },
        TextWindow = {
            Data = {
                Shown       = false,
                Caption     = "",
                Text        = "",
                ButtonText  = "",
                Picture     = nil,
                Action      = nil,
                Callback    = function() end,
            },
        },
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Application-Space
-- @local
--
function BundleDialogWindows.Global:Install()
    TextWindow = BundleDialogWindows.Local.TextWindow;
end



-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Application-Space
-- @local
--
function BundleDialogWindows.Local:Install()
    self:DialogOverwriteOriginal();
end

---
-- Führt das Callback eines Info-Fensters oder eines Selektionsfensters aus.
--
-- @within Application-Space
-- @local
--
function BundleDialogWindows.Local:Callback()
    if self.Data.Requester.ActionFunction then
        self.Data.Requester.ActionFunction(CustomGame.Knight + 1);
    end
    self:OnDialogClosed();
end

---
-- Führt das Callback eines Ja-Nein-Dialogs aus.
--
-- @param _yes Gegebene Antwort
-- @within Application-Space
-- @local
--
function BundleDialogWindows.Local:CallbackRequester(_yes)
    if self.Data.Requester.ActionRequester then
        self.Data.Requester.ActionRequester(_yes);
    end
    self:OnDialogClosed();
end

---
-- Läd den nächsten Dialog aus der Warteschlange und stellt die Speicher-Hotkeys
-- wieder her.
--
-- @within Application-Space
-- @local
--
function BundleDialogWindows.Local:OnDialogClosed()
    self:DialogQueueStartNext();
    self:RestoreSaveGame();
end

---
-- Startet den nächsten Dialog in der Warteschlange, sofern möglich.
--
-- @within Application-Space
-- @local
--
function BundleDialogWindows.Local:DialogQueueStartNext()
    self.Data.Requester.Next = table.remove(self.Data.Requester.Queue, 1);

    DialogQueueStartNext_HiResControl = function()
        local Entry = self.Data.Requester.Next;
        if Entry then
            local Methode = Entry[1];
            self.Data[Methode]( unpack(Entry[2]) );
            self.Data.Requester.Next = nil;
        end
        return true;
    end
    StartSimpleHiResJob("DialogQueueStartNext_HiResControl");
end

---
-- Fügt der Dialogwarteschlange einen neuen Dialog hinten an.
--
-- @param _Methode Dialogfunktion als String
-- @param _Args    Argumente als Table
-- @within Application-Space
-- @local
--
function BundleDialogWindows.Local:DialogQueuePush(_Methode, _Args)
    local Entry = {_Methode, _Args};
    table.insert(self.Data.Requester.Queue, Entry);
end

---
-- Öffnet einen Info-Dialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- @param _Title  Titel des Dialog
-- @param _Text   Text des Dialog
-- @param _Action Callback-Funktion
-- @within Application-Space
-- @local
--
function BundleDialogWindows.Local:OpenDialog(_Title, _Text, _Action)
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
            self.Data.Requester.ActionFunction = _Action;
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; XGUIEng.PopPage()";
            Action = Action .. "; BundleDialogWindows.Local.Callback(BundleDialogWindows.Local)";
            XGUIEng.SetActionFunction(RequesterDialog_Ok, Action);
        else
            self.Data.Requester.ActionFunction = nil;
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; XGUIEng.PopPage()";
            Action = Action .. "; BundleDialogWindows.Local.Callback(BundleDialogWindows.Local)";
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
    else
        self:DialogQueuePush("OpenDialog", {_Title, _Text, _Action});
    end
end

---
-- Öffnet einen Ja-Nein-Dialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- @param _Title    Titel des Dialog
-- @param _Text     Text des Dialog
-- @param _Action   Callback-Funktion
-- @param _OkCancel Okay/Abbrechen statt Ja/Nein
-- @within Application-Space
-- @local
--
function BundleDialogWindows.Local:OpenRequesterDialog(_Title, _Text, _Action, _OkCancel)
    if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
        assert(type(_Title) == "string");
        assert(type(_Text) == "string");
        _Title = "{center}" .. _Title;

        self.OpenDialog(_Title, _Text, _Action);
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

        self.Data.Requester.ActionRequester = nil;
        if _Action then
            assert(type(_Action) == "function");
            self.Data.Requester.ActionRequester = _Action;
        end
        local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; BundleDialogWindows.Local.CallbackRequester(BundleDialogWindows.Local, true)";
        XGUIEng.SetActionFunction(RequesterDialog_Yes, Action);
        local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; BundleDialogWindows.Local.CallbackRequester(BundleDialogWindows.Local, false)"
        XGUIEng.SetActionFunction(RequesterDialog_No, Action);
    else
        self:DialogQueuePush("OpenRequesterDialog", {_Title, _Text, _Action, _OkCancel});
    end
end

---
-- Öffnet einen Auswahldialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- @param _Title  Titel des Dialog
-- @param _Text   Text des Dialog
-- @param _Action Callback-Funktion
-- @param _List   Liste der Optionen
-- @within Application-Space
-- @local
--
function BundleDialogWindows.Local:OpenSelectionDialog(_Title, _Text, _Action, _List)
    if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
        self:OpenDialog(_Title, _Text, _Action);

        local HeroComboBoxID = XGUIEng.GetWidgetID(CustomGame.Widget.KnightsList);
        XGUIEng.ListBoxPopAll(HeroComboBoxID);
        for i=1,#_List do
            XGUIEng.ListBoxPushItem(HeroComboBoxID, Umlaute(_List[i]) );
        end
        XGUIEng.ListBoxSetSelectedIndex(HeroComboBoxID, 0);
        CustomGame.Knight = 0;

        local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. ";BundleDialogWindows.Local.Callback(BundleDialogWindows.Local)";
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
        XGUIEng.SetWidgetScreenPosition(Container .. "HeroComboBoxMain", x1-25, y1-90);
        XGUIEng.SetWidgetScreenPosition(Container .. "HeroComboBoxContainer", x1-25, y1-20);
    else
        self:DialogQueuePush("OpenSelectionDialog", {_Title, _Text, _Action, _List});
    end
end

---
-- Stellt die Hotkeys zum Speichern des Spiels wieder her.
--
-- @within Application-Space
-- @local
--
function BundleDialogWindows.Local:RestoreSaveGame()
    XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", 1);
    XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame", 1);
    if KeyBindings_SaveGame_Orig_QSB_Windows then
        KeyBindings_SaveGame = KeyBindings_SaveGame_Orig_QSB_Windows;
        KeyBindings_SaveGame_Orig_QSB_Windows = nil;
    end
end

---
-- Überschreibt die originalen Dialogfunktionen, um Fehler in den vorhandenen
-- Funktionen zu vermeiden.
--
-- @within Application-Space
-- @local
--
function BundleDialogWindows.Local:DialogOverwriteOriginal()
    OpenDialog_Orig_Windows = OpenDialog;
    OpenDialog = function(_Message, _Title, _IsMPError)
        if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; XGUIEng.PopPage()";
            XGUIEng.SetActionFunction(RequesterDialog_Ok, Action);
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

---
-- Erzeugt ein Textfenster, dass einen beliebig großen Text anzeigen kann.
-- Optional kann ein Button genutzt werden, der eine Aktion ausführt, wenn
-- er gedrückt wird.
--
-- <b>Alias</b>: TextWindow:New
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
-- @return TextWindow: Konfiguriertes Fenster
-- @within TextWindow
--
function BundleDialogWindows.Local.TextWindow:New(...)
    assert(self == BundleDialogWindows.Local.TextWindow, "Can not be used from instance!")
    local window           = API.InstanceTable(self);
    window.Data.Caption    = arg[1] or window.Data.Caption;
    window.Data.Text       = arg[2] or window.Data.Text;
    window.Data.Action     = arg[3];
    window.Data.ButtonText = arg[4] or window.Data.ButtonText;
    window.Data.Callback   = arg[5] or window.Data.Callback;
    return window;
end

---
-- Fügt einen beliebigen Parameter hinzu. Parameter müssen immer als
-- Schlüssel-Wert-Paare angegeben werden und dürfen vorhandene Pare nicht
-- überschreiben.
--
-- <b>Alias</b>: TextWindow:AddParamater
--
-- @param _Key   Schlüssel
-- @param _Value Wert
-- @return self
-- @within TextWindow
--
function BundleDialogWindows.Local.TextWindow:AddParamater(_Key, _Value)
    assert(self ~= BundleDialogWindows.Local.TextWindow, "Can not be used in static context!");
    assert(self.Data[_Key] ~= nil, "Key '" .._Key.. "' already exists!");
    self.Data[_Key] = _Value;
    return self;
end

---
-- Setzt die Überschrift des TextWindow.
--
-- <b>Alias</b>: TextWindow:SetCaption
--
-- @param _Text Titel des Textfenster
-- @return self
-- @within TextWindow
--
function BundleDialogWindows.Local.TextWindow:SetCaption(_Text)
    assert(self ~= BundleDialogWindows.Local.TextWindow, "Can not be used in static context!");
    assert(type(_Text) == "string");
    self.Data.Caption = _Text;
    return self;
end

---
-- Setzt den Inhalt des TextWindow.
--
-- <b>Alias</b>: TextWindow:SetContent
--
-- @param _Text Inhalt des Textfenster
-- @return self
-- @within TextWindow
--
function BundleDialogWindows.Local.TextWindow:SetContent(_Text)
    assert(self ~= BundleDialogWindows.Local.TextWindow, "Can not be used in static context!");
    assert(type(_Text) == "string");
    self.Data.Text = _Text;
    return self;
end

---
-- Setzt die Close Action des TextWindow. Die Funktion wird beim schließen
-- des Fensters ausgeführt.
--
-- <b>Alias</b>: TextWindow:SetAction
--
-- @param _Function Close Callback
-- @return self
-- @within TextWindow
--
function BundleDialogWindows.Local.TextWindow:SetAction(_Function)
    assert(self ~= BundleDialogWindows.Local.TextWindow, "Can not be used in static context!");
    assert(nil or type(_Callback) == "function");
    self.Data.Action = _Function;
    return self;
end

---
-- Setzt einen Aktionsbutton im TextWindow.
--
-- Der Button muss mit einer Funktion versehen werden. Sobald der Button
-- betätigt wird, wird die Funktion ausgeführt.
--
-- <b>Alias</b>: TextWindow:SetButton
--
-- @param _Text     Beschriftung des Buttons
-- @param _Callback Aktion des Buttons
-- @return self
-- @within TextWindow
--
function BundleDialogWindows.Local.TextWindow:SetButton(_Text, _Callback)
    assert(self ~= BundleDialogWindows.Local.TextWindow, "Can not be used in static context!");
    if _Text then
        assert(type(_Text) == "string");
        assert(type(_Callback) == "function");
    end
    self.Data.ButtonText = _Text;
    self.Data.Callback   = _Callback;
    return self;
end

---
-- Zeigt ein erzeigtes Fenster an.
--
-- <b>Alias</b>: TextWindow:Show
--
-- @within TextWindow
--
function BundleDialogWindows.Local.TextWindow:Show()
    assert(self ~= BundleDialogWindows.Local.TextWindow, "Can not be used in static context!");
    BundleDialogWindows.Local.TextWindow.Data.Shown = true;
    self.Data.Shown = true;
    self:Prepare();

    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions",1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ToggleWhisperTarget",1);
    if not self.Data.Action then
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ToggleWhisperTarget",0);
    end
    XGUIEng.SetText("/InGame/Root/Normal/MessageLog/Name","{center}"..self.Data.Caption);
    XGUIEng.SetText("/InGame/Root/Normal/ChatOptions/ToggleWhisperTarget","{center}"..self.Data.ButtonText);
    GUI_Chat.ClearMessageLog();
    GUI_Chat.ChatlogAddMessage(self.Data.Text);

    local stringlen = string.len(self.Data.Text);
    local iterator  = 1;
    local carreturn = 0;
    while (true)
    do
        local s,e = string.find(self.Data.Text, "{cr}", iterator);
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
-- @within Application-Space
-- @local
--
function BundleDialogWindows.Local.TextWindow:Prepare()
    function GUI_Chat.CloseChatMenu()
        BundleDialogWindows.Local.TextWindow.Data.Shown = false;
        self.Data.Shown = false;
        if self.Data.Callback then
            self.Data.Callback(self);
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
        XGUIEng.SetText("/InGame/Root/Normal/ChatOptions/TextCheckbox","{center}"..self.Data.Caption);
    end

    function GUI_Chat.ToggleWhisperTarget()
        if self.Data.Action then
            self.Data.Action(self);
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

    local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    if type(self.Data.Caption) == "table" then
        self.Data.Caption = self.Data.Caption[lang];
    end
    if type(self.Data.ButtonText) == "table" then
        self.Data.ButtonText = self.Data.ButtonText[lang];
    end
    if type(self.Data.Text) == "table" then
        self.Data.Text = self.Data.Text[lang];
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

Core:RegisterBundle("BundleDialogWindows");

