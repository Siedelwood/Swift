--[[
Swift_3_TextWindow/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleTextWindow = {
    Properties = {
        Name = "ModuleTextWindow",
    },
    
    Global = {},
    Local = {
        
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
}

-- Global Script ---------------------------------------------------------------

function ModuleTextWindow.Global:OnGameStart()
end

-- Local Script ----------------------------------------------------------------

function ModuleTextWindow.Local:OnGameStart()
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

Swift:RegisterModules(ModuleTextWindow);

