-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleDialogWindows                                          # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Bundle können Dialogfenster ernstellt werden. Über Dialogfenster
-- kann der Spieler informiert werden. Er kann aber auch aufgefordert werden
-- eine Antwort auf eine Frage zu geben. Sollte bereits ein Dialog zu sehen
-- sein, werden neue Dialoge einer Warteschlange hinzugefügt und nacheinander
-- angezeigt.
--
-- Zudem bietet das Bundle ein Textfenster an, welches eine nicht limitierte
-- Menge an Text anzeigen kann. Erreicht der Text eine entsprechende Menge,
-- wird automatisch eine Scrollbar eingeblendet.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleDialogWindows = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Öffnet einen Info-Dialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- <b>Alias</b>: UserOpenDialog
--
-- @param[type=string]   _Title  Titel des Dialog
-- @param[type=string]   _Text   Text des Dialog
-- @param[type=function] _Action Callback-Funktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.DialogInfoBox("Wichtige Information", "Diese Information ist Spielentscheidend!");
--
function API.DialogInfoBox(_Title, _Text, _Action)
    if not GUI then
        return;
    end

    _Title = API.ConvertPlaceholders(API.Localize(_Title));
    _Text  = API.ConvertPlaceholders(API.Localize(_Text));
    return BundleDialogWindows.Local:OpenDialog(_Title, _Text, _Action);
end
UserOpenDialog = API.DialogInfoBox;

---
-- Öffnet einen Ja-Nein-Dialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- Um die Entscheigung des Spielers abzufragen, wird ein Callback benötigt.
-- Das Callback bekommt eine Boolean übergeben, sobald der Spieler die
-- Entscheidung getroffen hat.
--
-- <b>Alias</b>: UserOpenRequesterDialog
--
-- @param[type=string]   _Title    Titel des Dialog
-- @param[type=string]   _Text     Text des Dialog
-- @param[type=function] _Action   Callback-Funktion
-- @param[type=boolean]  _OkCancel Okay/Abbrechen statt Ja/Nein
-- @within Anwenderfunktionen
--
-- @usage
-- function YesNoAction(_yes)
--     if _yes then GUI.AddNote("Ja wurde gedrückt"); end
-- end
-- API.DialogRequestBox("Frage", "Möchtest du das wirklich tun?", YesNoAction, false);
--
function API.DialogRequestBox(_Title, _Text, _Action, _OkCancel)
    if not GUI then
        return;
    end
    _Title = API.ConvertPlaceholders(API.Localize(_Title));
    _Text = API.ConvertPlaceholders(API.Localize(_Text));
    return BundleDialogWindows.Local:OpenRequesterDialog(_Title, _Text, _Action, _OkCancel);
end
UserOpenRequesterDialog = API.DialogRequestBox;

---
-- Öffnet einen Auswahldialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- In diesem Dialog wählt der Spieler eine Option aus einer Liste von Optionen
-- aus. Anschließend erhält das Callback den Index der selektierten Option.
--
-- <b>Alias</b>: UserOpenSelectionDialog
--
-- @param[type=string]   _Title  Titel des Dialog
-- @param[type=string]   _Text   Text des Dialog
-- @param[type=function] _Action Callback-Funktion
-- @param[type=table]    _List   Liste der Optionen
-- @within Anwenderfunktionen
--
-- @usage
-- function OptionsAction(_idx)
--     GUI.AddNote(_idx.. " wurde ausgewählt!");
-- end
-- local List = {"Option A", "Option B", "Option C"};
-- API.DialogSelectBox("Auswahl", "Wähle etwas aus!", OptionsAction, List);
--
function API.DialogSelectBox(_Title, _Text, _Action, _List)
    if not GUI then
        return;
    end
    _Title = API.ConvertPlaceholders(API.Localize(_Title));
    _Text = API.ConvertPlaceholders(API.Localize(_Text));
    _Text = _Text .. "{cr}";
    return BundleDialogWindows.Local:OpenSelectionDialog(_Title, _Text, _Action, _List);
end
UserOpenSelectionDialog = API.DialogSelectBox;

---
-- Öffnet ein einfaches Textfenster mit dem angegebenen Text.
--
-- Die Länge des Textes ist nicht beschränkt. Überschreitet der Text die
-- Größe des Fensters, wird automatisch eine Bildlaufleiste eingeblendet.
--
-- @param[type=string] _Caption Titel des Fenster
-- @param[type=string] _content Inhalt des Fenster
-- @within Anwenderfunktionen
--
-- @usage
-- local Text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "..
--              "sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
--              "magna aliquyam erat, sed diam voluptua. At vero eos et"..
--              " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
--              " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
--              " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
--              " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
--              " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
--              " et accusam et justo duo dolores et ea rebum. Stet clita"..
--              " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
--              " dolor sit amet.";
-- API.SimpleTextWindow("Überschrift", Text);
--
function API.SimpleTextWindow(_Caption, _Content)
    _Caption = API.ConvertPlaceholders(API.Localize(_Caption));
    _Content = API.ConvertPlaceholders(API.Localize(_Content));
    if not GUI then
        API.Bridge("API.SimpleTextWindow('" .._Caption.. "', '" .._Content.. "')");
        return;
    end
    QSB.TextWindow:New(_Caption, _Content):Show();
end

---
-- Blendet einen Text Zeichen für Zeichen auf schwarzem Grund ein.
--
-- Diese Funktion ist der offizielle Nachfolger der Laufschrift!
--
-- Der Effekt startet erst, nachdem die Map geladen ist. Wenn ein Briefing
-- läuft, wird gewartet, bis das Briefing beendet ist. Wärhend der Effekt
-- läuft, können wiederrum keine Briefings starten.
--
-- <b>Hinweis</b>: Steuerzeichen wie {cr} oder {@color} werden als ein Token
-- gewertet und immer sofort eingeblendet. Steht z.B. {cr}{cr} im Text, werden
-- die Zeichen atomar behandelt, als seien sie ein einzelnes Zeichen.
-- Gibt es mehr als 1 Leerzeichen hintereinander, werden alle zusammenhängenden
-- Leerzeichen auf ein Leerzeichen reduziert!
--
-- @param[type=string]   _Text     Anzuzeigender Text
-- @param[type=function] _Callback Funktion nach Ende des Effekt
--
-- @usage
-- local Text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "..
--              "sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
--              "magna aliquyam erat, sed diam voluptua. At vero eos et"..
--              " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
--              " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
--              " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
--              " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
--              " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
--              " et accusam et justo duo dolores et ea rebum. Stet clita"..
--              " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
--              " dolor sit amet.";
-- local Callback = function(_Data)
--     -- Hier kann was passieren
-- end
-- API.SimpleTypewriter(Text, Callback);
-- @within Anwenderfunktionen
--
function API.SimpleTypewriter(_Text, _Callback)
    if GUI then
        return;
    end
    QSB.SimpleTypewriter:New(API.ConvertPlaceholders(API.Localize(_Text)), _Callback):Start();
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleDialogWindows = {
    Global = {
        Data = {
            Loadscreen = true,
        }
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
    },
}

-- Typewriter class ------------------------------------------------------------

QSB.SimpleTypewriter = {
    m_Tokens     = {},
    m_Delay      = 15,
    m_Waittime   = 80,
    m_Speed      = 1,
    m_Index      = 0,
    m_Text       = nil,
    m_JobID      = nil,
    m_Callback   = nil,
};

---
-- Erzeugt eine Neue Instanz der Schreibmaschinenschrift.
-- @param[type=string]   _Text     Anzuzeigender Text
-- @param[type=function] _Callback Funktion, die am Ende ausgeführt wird
-- @return[type=table] Neue Instanz
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:New(_Text, _Callback)
    local typewriter = API.InstanceTable(self);
    typewriter.m_Text = _Text;
    typewriter.m_Callback = _Callback;
    return typewriter;
end

---
-- Stellt ein, wie viele Zeichen in einer Interation angezeigt werden.
-- @param[type=number] _Speed Anzahl an Character pro 1/10 Sekunde
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:SetSpeed(_Speed)
    self.m_Speed = _Speed;
end

---
-- Stellt ein, wie lange nach Ausgabe des letzten Zeichens gewartet wird, bis
-- die Schreibmaschine endet.
-- @param[type=number] _Waittime Zeit in 1/10 Sekunden (8 Sekunden = 80)
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:SetWaittime(_Waittime)
    self.m_Waittime = _Waittime;
end

---
-- Startet die Laufschrift. Wenn ein Briefing aktiv ist, oder die Map noch
-- nicht geladen ist, wird gewartet.
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:Start()
    if self:CanBePlayed() then
        self:Play();
        return;
    end
    StartSimpleHiResJobEx(self.WaitForBriefingEnd, self);
end

---
-- Spielt die Schreibmaschine ab.
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:Play()
    if BundleBriefingSystem then
        BundleBriefingSystem.Global.Data.BriefingActive = true;
    end
    self.m_InitialWaittime = self.m_Delay;
    self:TokenizeText();
    API.Bridge([[
        if BundleBriefingSystem then
            BundleBriefingSystem.Local.Data.BriefingActive = true
        end

        XGUIEng.PushPage("/InGame/Root/Normal/NotesWindow", false)
        XGUIEng.PushPage("/InGame/Root/Normal/PauseScreen", false)
        XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal",0)
        XGUIEng.ShowWidget("/InGame/Root/Normal/NotesWindow",1)
        XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 1)
        XGUIEng.SetMaterialColor("/InGame/Root/Normal/PauseScreen", 0, 0, 0, 0, 255)
        g_Typewriter_GameSpeedBackup = Game.GameTimeGetFactor(GUI.GetPlayerID())
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)
        Input.CutsceneMode()
    ]]);
    self.m_JobID = StartSimpleHiResJobEx(self.ControllerJob, self);
end

---
-- Stoppt eine aktive Schreibmaschine.
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:Stop()
    if BundleBriefingSystem then
        BundleBriefingSystem.Global.Data.BriefingActive = false
    end
    API.Bridge([[
        if BundleBriefingSystem then
            BundleBriefingSystem.Local.Data.BriefingActive = false
        end

        GUI.ClearNotes()
        Game.GameTimeSetFactor(GUI.GetPlayerID(), g_Typewriter_GameSpeedBackup or 1)
        Input.GameMode()
        XGUIEng.PopPage()
        XGUIEng.PopPage()
        XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 0)
        XGUIEng.SetMaterialColor("/InGame/Root/Normal/PauseScreen", 0, 40, 40, 40, 180)
        XGUIEng.ShowWidget("/InGame/Root/Normal/AnimatedCameraMovement", 1)
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight",1)
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft",1)
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft",1)
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar",1)
        XGUIEng.ShowWidget("/InGame/Root/Normal/InteractiveObjects",1)
        XGUIEng.ShowWidget("/InGame/Root/Normal/InteractiveObjects/Update",1)
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopRight",1)
        XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Merchant",1)
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopCenter",1)
        if g_PatchIdentifierExtra1 then
            XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Tradepost",1)
        end
        XGUIEng.ShowWidget("/InGame/Root/Normal/TextMessages",1)
        XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen",0)
        XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay",1)
        XGUIEng.ShowWidget("/InGame/Root/Normal/ShowUi",1)
        XGUIEng.ShowWidget("/InGame/Root/3dWorldView",1)
    ]]);
    EndJob(self.m_JobID);
end

---
-- Spaltet den Text in Tokens auf und speichert die Tokens für die Wiedergabe.
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:TokenizeText()
    self.m_Text = self.m_Text:gsub("%s+", " ");
    local TempTokens = {};
    local Text = self.m_Text;
    while (true) do
        local s1, e1 = Text:find("{");
        local s2, e2 = Text:find("}");
        if not s1 or not s2 then
            table.insert(TempTokens, Text);
            break;
        end
        if s1 > 1 then
            table.insert(TempTokens, Text:sub(1, s1 -1));
        end
        table.insert(TempTokens, Text:sub(s1, e2));
        Text = Text:sub(e2 +1);
    end

    local LastWasPlaceholder = false;
    for i= 1, #TempTokens, 1 do
        if TempTokens[i]:find("{") then
            local Index = #self.m_Tokens;
            if LastWasPlaceholder then
                self.m_Tokens[Index] = self.m_Tokens[Index] .. TempTokens[i];
            else
                table.insert(self.m_Tokens, Index+1, TempTokens[i]);
            end
            LastWasPlaceholder = true;
        else
            local Index = 1;
            while (Index <= #TempTokens[i]) do
                if string.byte(TempTokens[i]:sub(Index, Index)) == 195 then
                    table.insert(self.m_Tokens, TempTokens[i]:sub(Index, Index+1));
                    Index = Index +1;
                else
                    table.insert(self.m_Tokens, TempTokens[i]:sub(Index, Index)); 
                end
                Index = Index +1;
            end
            LastWasPlaceholder = false;
        end
    end
end

---
-- Prüft, ob die Schreibmaschine gestartet werden kann.
-- @return[type=boolean] Schreibmaschine kann starten
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:CanBePlayed()
    if BundleDialogWindows.Global.Data.Loadscreen then
        return false;
    end
    if BundleBriefingSystem and IsBriefingActive() then
        return false;
    end
    if AddOnCutsceneSystem and IsCutsceneActive() then
        return false;
    end
    return true;
end

---
-- Job: Warte solange, bis Briefings beendet sind.
-- @param[type=table] Data
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter.WaitForBriefingEnd(_Data)
    if _Data:CanBePlayed() == true then
        _Data:Play();
        return true;
    end
end

---
-- Job: Kontrolliert die Anzeige der Schreibmaschine.
-- @param[type=table] Data
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter.ControllerJob(_Data)
    if _Data.m_InitialWaittime > 0 then
        _Data.m_InitialWaittime = _Data.m_InitialWaittime -1;
    end
    if _Data.m_InitialWaittime == 0 then
        _Data.m_Index = _Data.m_Index + _Data.m_Speed;
        if _Data.m_Index > #_Data.m_Tokens then
            _Data.m_Index = #_Data.m_Tokens;
        end
        local Index = math.ceil(_Data.m_Index);

        local Text = "";
        for i= 1, Index, 1 do
            Text = Text .. _Data.m_Tokens[i];
        end
        API.Bridge([[
            GUI.ClearNotes()
            GUI.AddNote("]] ..Text.. [[");
        ]])
        
        if Index == #_Data.m_Tokens then
            _Data.m_Waittime = _Data.m_Waittime -1;
            if _Data.m_Waittime <= 0 then
                _Data:Stop();
                if _Data.m_Callback then
                    _Data.m_Callback(_Data);
                end
                return true;
            end
        end
    end
end

-- TextWindow class ------------------------------------------------------------

QSB.TextWindow = {
    Data = {
        Shown       = false,
        Caption     = "",
        Text        = "",
        ButtonText  = "",
        Picture     = nil,
        Action      = nil,
        Callback    = function() end,
    },
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
    assert(self.Data[_Key] ~= nil, "Key '" .._Key.. "' already exists!");
    self.Data[_Key] = _Value;
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
    self.Data.Caption = API.Localize(_Text);
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
    self.Data.Text = API.Localize(_Text);
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
    self.Data.Callback = _Function;
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
    self.Data.ButtonText = _Text;
    self.Data.Action     = _Callback;
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
    QSB.TextWindow.Data.Shown = true;
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
-- @within QSB.TextWindow
-- @local
--
function QSB.TextWindow:Prepare()
    function GUI_Chat.CloseChatMenu()
        QSB.TextWindow.Data.Shown = false;
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

    if type(self.Data.Caption) == "table" then
        self.Data.Caption = API.Localize(self.Data.Caption);
    end
    if type(self.Data.ButtonText) == "table" then
        self.Data.ButtonText = API.Localize(self.Data.ButtonText);
    end
    if type(self.Data.Text) == "table" then
        self.Data.Text = API.Localize(self.Data.Text);
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

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function BundleDialogWindows.Global:Install()
    API.AddSaveGameAction(function ()
        API.Bridge("BundleDialogWindows.Local.DialogAltF4Hotkey()");
    end);
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleDialogWindows.Local:Install()
    self:DialogOverwriteOriginal();
    self:DialogAltF4Hotkey();

    StartSimpleHiResJobEx(function()
        if XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 0 then
            API.Bridge("BundleDialogWindows.Global.Data.Loadscreen = false");
            return true;
        end
    end);
end

---
-- Überschreibt den Alt + F4 Hotkey.
--
-- @within Internal
-- @local
--
function BundleDialogWindows.Local:DialogAltF4Hotkey()
    StartSimpleJobEx(function ()
        if XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 0 then
            Input.KeyBindDown(Keys.ModifierAlt + Keys.F4, "BundleDialogWindows.Local:DialogAltF4Action()", 30, false);
            return true;
        end
    end);
end

---
-- Öffnet den Dialog mit der Frage, ob das Spiel verlassen werden
--
-- @within Internal
-- @local
--
function BundleDialogWindows.Local:DialogAltF4Action()
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
            BundleDialogWindows.Local:DialogAltF4Hotkey();
            Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
        end
    );

    -- Zeit anhelten
    Game.GameTimeSetFactor(GUI.GetPlayerID(), 0);
end

---
-- Führt das Callback eines Info-Fensters oder eines Selektionsfensters aus.
--
-- @within Internal
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
-- @param[type=boolean] _yes Gegebene Antwort
-- @within Internal
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
-- @within Internal
-- @local
--
function BundleDialogWindows.Local:OnDialogClosed()
    self:DialogQueueStartNext();
    self:RestoreSaveGame();
end

---
-- Startet den nächsten Dialog in der Warteschlange, sofern möglich.
--
-- @within Internal
-- @local
--
function BundleDialogWindows.Local:DialogQueueStartNext()
    self.Data.Requester.Next = table.remove(self.Data.Requester.Queue, 1);

    DialogQueueStartNext_HiResControl = function()
        local Entry = BundleDialogWindows.Local.Data.Requester.Next;
        if Entry and Entry[1] and Entry[2] then
            local Methode = Entry[1];
            BundleDialogWindows.Local[Methode]( BundleDialogWindows.Local, unpack(Entry[2]) );
            BundleDialogWindows.Local.Data.Requester.Next = nil;
        end
        return true;
    end
    StartSimpleHiResJob("DialogQueueStartNext_HiResControl");
end

---
-- Fügt der Dialogwarteschlange einen neuen Dialog hinten an.
--
-- @param[type=string] _Methode Dialogfunktion als String
-- @param[type=table] _Args    Argumente als Table
-- @within Internal
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
-- @param[type=string]   _Title  Titel des Dialog
-- @param[type=string]   _Text   Text des Dialog
-- @param[type=function] _Action Callback-Funktion
-- @within Internal
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
-- @param[type=string]   _Title    Titel des Dialog
-- @param[type=string]   _Text     Text des Dialog
-- @param[type=function] _Action   Callback-Funktion
-- @param[type=boolean]  _OkCancel Okay/Abbrechen statt Ja/Nein
-- @within Internal
-- @local
--
function BundleDialogWindows.Local:OpenRequesterDialog(_Title, _Text, _Action, _OkCancel)
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
-- @param[type=string]   _Title  Titel des Dialog
-- @param[type=string]   _Text   Text des Dialog
-- @param[type=function] _Action Callback-Funktion
-- @param[type=table]    _List   Liste der Optionen
-- @within Internal
-- @local
--
function BundleDialogWindows.Local:OpenSelectionDialog(_Title, _Text, _Action, _List)
    if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
        self:OpenDialog(_Title, _Text, _Action);

        local HeroComboBoxID = XGUIEng.GetWidgetID(CustomGame.Widget.KnightsList);
        XGUIEng.ListBoxPopAll(HeroComboBoxID);
        for i=1,#_List do
            XGUIEng.ListBoxPushItem(HeroComboBoxID, _List[i] );
        end
        XGUIEng.ListBoxSetSelectedIndex(HeroComboBoxID, 0);
        CustomGame.Knight = 0;

        local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; BundleDialogWindows.Local.Callback(BundleDialogWindows.Local)";
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
-- @within Internal
-- @local
--
function BundleDialogWindows.Local:RestoreSaveGame()
    if BundleGameHelperFunctions and not BundleGameHelperFunctions.Local.Data.ForbidSave then
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", 1);
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame", 1);
    end
    if KeyBindings_SaveGame_Orig_QSB_Windows then
        KeyBindings_SaveGame = KeyBindings_SaveGame_Orig_QSB_Windows;
        KeyBindings_SaveGame_Orig_QSB_Windows = nil;
    end
end

---
-- Überschreibt die originalen Dialogfunktionen, um Fehler in den vorhandenen
-- Funktionen zu vermeiden.
--
-- @within Internal
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

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleDialogWindows");

