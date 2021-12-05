--[[
Swift_4_Typewriter/Source

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleTypewriter = {
    Properties = {
        Name = "ModuleTypewriter",
    },
    
    Global = {},
    Local = {
        
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
}

-- Global Script ---------------------------------------------------------------

function ModuleTypewriter.Global:OnGameStart()
end

-- Local Script ----------------------------------------------------------------

function ModuleTypewriter.Local:OnGameStart()
    QSB.SimpleTypewriterCounter = nil;
    QSB.SimpleTypewriter = nil;
end

-- Typewriter class ------------------------------------------------------------

QSB.SimpleTypewriterCounter = 0;

QSB.SimpleTypewriter = {
    m_Tokens      = {},
    m_Delay       = 15,
    m_Waittime    = 80,
    m_TokenOffset = 1,
    m_Color       = {R= 0, G= 0, B= 0, A = 255},
    m_Index       = 0,
    m_Position    = nil,
    m_Text        = nil,
    m_JobID       = nil,
    m_Callback    = nil,
};

---
-- Erzeugt eine Neue Instanz der Schreibmaschinenschrift.
-- @param[type=string]   _Text     Anzuzeigender Text
-- @param[type=function] _Callback Funktion, die am Ende ausgeführt wird
-- @return[type=table] Neue Instanz
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:New(_Data)
    local typewriter = table.copy(self);
    typewriter.m_Text = API.ConvertPlaceholders(API.Localize(_Data.Text));
    return typewriter;
end

---
-- Setzt das Callback, welches am Ende der Anzeige aufgerufen wird.
-- @param[type=function] _Callback Funktion, die am Ende ausgeführt wird
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:SetCallback(_Callback)
    self.m_Callback = _Callback;
    return self;
end

---
-- Setzt das Entity auf das die Kamera fixiert wird.
-- @param _Position Skriptname oder ID
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:SetPosition(_Position)
    self.m_Position = _Position;
    return self;
end

---
-- Legt fest, wie transparent der Hintergund dargestellt wird.
-- @param[type=number] _Opacity Transparenz des Hintergrund
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:SetOpacity(_Opacity)
    self.m_Color.A = 255 * _Opacity;
    return self;
end

---
-- Legt fest, welche Farbe der Hindergrund hat.
-- @param[type=number] _Red   Rotwert des Hintergrund
-- @param[type=number] _Green Grünwert des Hintergrund
-- @param[type=number] _Blue  Blauwert des Hintergrund
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:SetColor(_Red, _Green, _Blue)
    self.m_Color.R = _Red;
    self.m_Color.G = _Green;
    self.m_Color.B = _Blue;
    return self;
end

---
-- Stellt ein, wie viele Zeichen in einer Interation angezeigt werden.
-- @param[type=number] _Speed Anzahl an Zeichen pro 1/10 Sekunde
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:SetSpeed(_Speed)
    self.m_TokenOffset = _Speed;
    return self;
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
    return self;
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
    QSB.SimpleTypewriterCounter = QSB.SimpleTypewriterCounter +1;
    local Name = "CinmaticEventTypewriter" ..QSB.SimpleTypewriterCounter;
    self.m_CinematicEventName = Name;
    API.StartCinematicEvent(Name, QSB.HumanPlayerID);
    API.ActivateColoredScreen(self.m_Color.R, self.m_Color.G, self.m_Color.B, self.m_Color.A);
    API.DeactivateNormalInterface();
    API.DeactivateBorderScroll(self.m_Position);
    self.m_InitialWaittime = self.m_Delay;
    self:TokenizeText();
    Logic.ExecuteInLuaLocalState([[
        Input.CutsceneMode()
        GUI.ClearNotes()
    ]]);
    self.m_JobID = StartSimpleHiResJobEx(function()
        self:ControllerJob();
    end);
end

---
-- Stoppt eine aktive Schreibmaschine.
-- @within QSB.SimpleTypewriter
-- @local
--
function QSB.SimpleTypewriter:Stop()
    API.FinishCinematicEvent(self.m_CinematicEventName, QSB.HumanPlayerID);
    API.DeactivateColoredScreen();
    API.ActivateNormalInterface();
    API.ActivateBorderScroll();
    Logic.ExecuteInLuaLocalState([[
        Input.GameMode()
        GUI.ClearNotes()
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
    if API.IsLoadscreenVisible() then
        return false;
    end
    if API.IsCinematicEventActive() then
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
function QSB.SimpleTypewriter:ControllerJob()
    if self.m_InitialWaittime > 0 then
        self.m_InitialWaittime = self.m_InitialWaittime -1;
    end
    if self.m_InitialWaittime == 0 then
        self.m_Index = self.m_Index + self.m_TokenOffset;
        if self.m_Index > #self.m_Tokens then
            self.m_Index = #self.m_Tokens;
        end
        local Index = math.floor(self.m_Index + 0.5);

        local Text = "";
        for i= 1, Index, 1 do
            Text = Text .. self.m_Tokens[i];
        end
        Logic.ExecuteInLuaLocalState([[
            GUI.ClearNotes()
            GUI.AddNote("]] ..Text.. [[");
        ]])
        
        if Index == #self.m_Tokens then
            self.m_Waittime = self.m_Waittime -1;
            if self.m_Waittime <= 0 then
                self:Stop();
                if self.m_Callback then
                    self:m_Callback();
                end
                return true;
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleTypewriter);

