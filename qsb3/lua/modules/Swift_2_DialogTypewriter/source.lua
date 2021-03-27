-- -------------------------------------------------------------------------- --
-- Module Dialog Typewriter                                                   --
-- -------------------------------------------------------------------------- --

ModuleDialogTypewriter = {
    Properties = {
        Name = "ModuleDialogTypewriter",
    },
    
    Global = {},
    Local = {
        
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
}

-- Global Script ---------------------------------------------------------------

function ModuleDialogTypewriter.Global:OnGameStart()
end

-- Local Script ----------------------------------------------------------------

function ModuleDialogTypewriter.Local:OnGameStart()
end

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
    m_PaintBlack = true,
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
-- Setzt, ob der schwarze Hintergrund benutzt wird oder nicht.
-- @param[type=boolean] _Flag Schwarzen Hintergrund zeichnen
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:SetBlackBackground(_Flag)
    self.m_PaintBlack = _Flag == true;
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
-- Startet die Laufschrift. Wenn ein Efekt im Kinomodus aktiv ist, oder die
-- Map noch nicht geladen ist, wird gewartet.
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:Start()
    if self:CanBePlayed() then
        self:Play();
        return;
    end
    StartSimpleHiResJobEx(self.WaitForSceneToBeReady, self);
end

---
-- Spielt die Schreibmaschine ab.
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:Play()
    API.ActivateCinematicState();
    if self.m_PaintBlack then
        API.ActivateBlackScreen();
    end
    API.DeactivateNormalInterface();
    self.m_InitialWaittime = self.m_Delay;
    self:TokenizeText();
    self.m_JobID = StartSimpleHiResJobEx(self.ControllerJob, self);
end

---
-- Stoppt eine aktive Schreibmaschine.
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:Stop()
    API.DeactivateCinematicState();
    API.DeactivateBlackScreen();
    API.ActivateNormalInterface();
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
    if API.IsLoadscreenVisible() then
        return false;
    end
    if API.IsCinematicState() then
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
function QSB.SimpleTypewriter.WaitForSceneToBeReady(_Data)
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
        Logic.ExecuteInLuaLocalState([[
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

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleDialogTypewriter);

