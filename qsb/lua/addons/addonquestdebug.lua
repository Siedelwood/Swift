-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnQuestDebug                                              # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Erweitert den mitgelieferten Debug des Spiels um eine Vielzahl nützlicher
-- neuer Möglichkeiten.
--
-- Die wichtigste Neuerung ist die Konsole, die es erlaubt Quests direkt über
-- die Eingabe von Befehlen zu steuern, einzelne Lua-Funktionen im Spiel
-- auszuführen und sogar komplette Skripte zu laden.
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnQuestDebug = {};

API = API or {};
QSB = QSB or {};

AddOnQuestDebug = {
    Global =  {
        Data = {},
    },
    Local = {
        Data = {},
    },
}

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Aktiviert den Debug.
--
-- Der Developing Mode bietet viele Hotkeys und eine Konsole. Die Konsole ist
-- ein mächtiges Werkzeug. Es ist möglich tief in das Spiel einzugreifen und
-- sogar Funktionen während des Spiels zu überschreiben.
--
-- Die Konsole kann über <b>SHIFT + ^</b> geöffnet werden.
--
-- <p><b>Alias:</b> ActivateDebugMode</p>
--
-- <h3>Cheats</h3>
-- <table border="1">
-- <tr>
-- <td><b>Cheat</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>SHIFT + ^</td>
-- <td>Konsole öffnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + C</td>
-- <td>Zeitanzeige an/aus</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + F</td>
-- <td>Nebel des Krieges abschalten</td>
-- </tr>
-- <tr>
-- <td>STRG + G</td>
-- <td>GUI ausschalten</td>
-- </tr>
-- <tr>
-- <td>ALT + F10</td>
-- <td>Selektiertes Gebäude anzünden</td>
-- </tr>
-- <tr>
-- <td>ALT + F11</td>
-- <td>Selektierte Einheit verwunden</td>
-- </tr>
-- <tr>
-- <td>ALT + F12</td>
-- <td>Alle Rechte freigeben / wieder sperren</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + 1</td>
-- <td>FPS-Anzeige</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 4</td>
-- <td>Bogenschützen unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 5</td>
-- <td>Schwertkämpfer unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 6</td>
-- <td>Katapultkarren unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 7</td>
-- <td>Ramme unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 8</td>
-- <td>Belagerungsturm unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 9</td>
-- <td>Katapult unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>(Num) +</td>
-- <td>Spiel beschleunigen</td>
-- </tr>
-- <tr>
-- <td>(Num) -</td>
-- <td>Spiel verlangsamen</td>
-- </tr>
-- <tr>
-- <td>(Num) *</td>
-- <td>Geschwindigkeit zurücksetzen</td>
-- </tr>
-- <tr>
-- <td>CTRL + F1</td>
-- <td>+ 50 Gold</td>
-- </tr>
-- <tr>
-- <td>CTRL + F2</td>
-- <td>+ 10 Holz</td>
-- </tr>
-- <tr>
-- <td>CTRL + F3</td>
-- <td>+ 10 Stein</td>
-- </tr>
-- <tr>
-- <td>CTRL + F4</td>
-- <td>+ 10 Getreide</td>
-- </tr>
-- <tr>
-- <td>CTRL + F5</td>
-- <td>+ 10 Milch</td>
-- </tr>
-- <tr>
-- <td>CTRL + F6</td>
-- <td>+ 10 Kräuter</td>
-- </tr>
-- <tr>
-- <td>CTRL + F7</td>
-- <td>+ 10 Wolle</td>
-- </tr>
-- <tr>
-- <td>CTRL + F8</td>
-- <td>+ 10 auf alle Waren</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F1</td>
-- <td>+ 10 Honig</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F2</td>
-- <td>+ 10 Eisen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F3</td>
-- <td>+ 10 Fisch</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F4</td>
-- <td>+ 10 Wild</td>
-- </tr>
-- <tr>
-- <td>CTRL + F9</td>
-- <td>Nahrung für selektiertes Gebäude erhöhen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F9</td>
-- <td>Nahrung für selektiertes Gebäude verringern</td>
-- </tr>
-- <tr>
-- <td>CTRL + F10</td>
-- <td>Kleidung für selektiertes Gebäude erhöhen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F10</td>
-- <td>Kleidung für selektiertes Gebäude verringern</td>
-- </tr>
-- <tr>
-- <td>CTRL + F11</td>
-- <td>Hygiene für selektiertes Gebäude erhöhen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F11</td>
-- <td>Hygiene für selektiertes Gebäude verringern</td>
-- </tr>
-- <tr>
-- <td>CTRL + F12</td>
-- <td>Unterhaltung für selektiertes Gebäude erhöhen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F12</td>
-- <td>Unterhaltung für selektiertes Gebäude verringern</td>
-- </tr>
-- <tr>
-- <td>ALT + CTRL + F10</td>
-- <td>Einnahmen des selektierten Gebäudes erhöhen</td>
-- </tr>
-- <tr>
-- <td>ALT + (Num) 1</td>
-- <td>Burg selektiert → Gold verringern, Werkstatt selektiert → Ware verringern</td>
-- </tr>
-- <tr>
-- <td>ALT + (Num) 2</td>
-- <td>Burg selektiert → Gold erhöhen, Werkstatt selektiert → Ware erhöhen</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 1</td>
-- <td>Kontrolle über Spieler 1</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 2</td>
-- <td>Kontrolle über Spieler 2</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 3</td>
-- <td>Kontrolle über Spieler 3</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 4</td>
-- <td>Kontrolle über Spieler 4</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 5</td>
-- <td>Kontrolle über Spieler 5</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 6</td>
-- <td>Kontrolle über Spieler 6</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 7</td>
-- <td>Kontrolle über Spieler 7</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 8</td>
-- <td>Kontrolle über Spieler 8</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 0</td>
-- <td>Kamera durchschalten</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 1</td>
-- <td>Kamerasprünge im RTS-Mode</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + V</td>
-- <td>Territorien anzeigen</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + B</td>
-- <td>Blocking anzeigen</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + N</td>
-- <td>Gitter verstecken</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + F9</td>
-- <td>DEBUG-Ausgabe einschalten</td>
-- </tr>
-- <tr>
-- <td>ALT + F9</td>
-- <td>Zufälligen Arbeiter verheiraten</td>
-- </tr>
-- </table>
--
-- <h3>Konsolenbefehle</h3>
-- <table border=1>
-- <tr>
-- <th><b>Befehl</b></th>
-- <th><b>Parameter</b></th>
-- <th><b>Beschreibung</b></th>
-- </tr>
-- <tr>
-- <td>clear</td>
-- <td></td>
-- <td>Entfernt alle Textnachrichten im Debug-Window.</td>
-- </tr>
-- <tr>
-- <td>diplomacy</td>
-- <td>PlayerID1, PlayerID2, Diplomacy</td>
-- <td>Ändert die Doplomatischen Beziehungen zwischen zwei Parteien</td>
-- </tr>
-- <tr>
-- <td>restartmap</td>
-- <td></td>
-- <td>Startet die Map sofort neu.</td>
-- </tr>
-- <tr>
-- <td>reveal</td>
-- <td>PlayerID1, PlayerID2</td>
-- <td>Teilt die Sicht zweier Spieler.</td>
-- </tr>
-- <tr>
-- <td>conceal</td>
-- <td>PlayerID1, PlayerID2</td>
-- <td>Hebt die geteilte Sicht wieder auf.</td>
-- </tr>
-- <tr>
-- <td>setposition</td>
-- <td>Entity, Target</td>
-- <td>Versetzt ein Entity zu einer neuen Position.</td>
-- </tr>
-- <tr>
-- <td>version</td>
-- <td></td>
-- <td>Zeigt die Version der QSB an.</td>
-- </tr>
-- <tr>
-- <td>stop</td>
-- <td>QuestName</td>
-- <td>Unterbricht den angegebenen Quest.</td>
-- </tr>
-- <tr>
-- <td>start</td>
-- <td>QuestName</td>
-- <td>Startet den angegebenen Quest.</td>
-- </tr>
-- <tr>
-- <td>win</td>
-- <td>QuestName</td>
-- <td>Schließt den angegebenen Quest erfolgreich ab.</td>
-- </tr>
-- <tr>
-- <td>fail</td>
-- <td>QuestName</td>
-- <td>Lässt den angegebenen Quest fehlschlagen</td>
-- </tr>
-- <tr>
-- <td>restart</td>
-- <td>QuestName</td>
-- <td>Startet den angegebenen Quest neu.</td>
-- </tr>
-- <tr>
-- <td>stopped</td>
-- <td>Pattern</td>
-- <td>Gibt die Namen abgebrochener Quests zurück.</td>
-- </tr>
-- <tr>
-- <td>active</td>
-- <td>Pattern</td>
-- <td>Gibt die Namen aktiver Quests zurück.</td>
-- </tr>
-- <tr>
-- <td>won</td>
-- <td>Pattern</td>
-- <td>Gibt die Namen gewonnener Quests zurück.</td>
-- </tr>
-- <tr>
-- <td>failed</td>
-- <td>Pattern</td>
-- <td>Gibt die Namen fehlgeschlagener Quests zurück.</td>
-- </tr>
-- <tr>
-- <td>waiting</td>
-- <td>Pattern</td>
-- <td>Gibt die Namen nicht ausgelöster Quests zurück.</td>
-- </tr>
-- <tr>
-- <td>find</td>
-- <td>Pattern</td>
-- <td>Gibt die Namen von Quests mit ähnlichen Namen zurück.</td>
-- </tr>
-- <tr>
-- <td><</td>
-- <td>Path</td>
-- <td>Läd ein Skript zur Laufzeit ins globale Skript.</td>
-- </tr>
-- <tr>
-- <td><<</td>
-- <td>Path</td>
-- <td>Läd ein Skript zur Laufzeit ins lokale Skript.</td>
-- </tr>
-- <tr>
-- <td>></td>
-- <td>Command</td>
-- <td>Führt die Eingabe als Lua-Befahl im globalen Skript aus.</td>
-- </tr>
-- <tr>
-- <td>>></td>
-- <td>Command</td>
-- <td>Führt die Eingabe als Lua-Befahl im lokalen Skript aus.</td>
-- </tr>
-- </table>
--
-- @param[type=boolean] _CheckAtRun Prüfe Quests zur Laufzeit
-- @param[type=boolean] _TraceQuests Aktiviert Questverfolgung
-- @param[type=boolean] _DevelopingCheats Aktiviert Cheats
-- @param[type=boolean] _DevelopingShell Aktiviert Eingabe
-- @see Reward_DEBUG
-- @within Anwenderfunktionen
--
function API.ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
    if GUI then
        return;
    end
    AddOnQuestDebug.Global:ActivateDebug(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell);
end
ActivateDebugMode = API.ActivateDebugMode;

-- -------------------------------------------------------------------------- --
-- Rewards                                                                    --
-- -------------------------------------------------------------------------- --

---
-- Aktiviert den Debug.
--
-- @param[type=boolean] _CheckAtRun Prüfe Quests zur Laufzeit
-- @param[type=boolean] _TraceQuests Aktiviert Questverfolgung
-- @param[type=boolean] _DevelopingCheats Aktiviert Cheats
-- @param[type=boolean] _DevelopingShell Aktiviert Eingabe
-- @see API.ActivateDebugMode
--
-- @within Reward
--
function Reward_DEBUG(...)
    return b_Reward_DEBUG:new(...);
end

b_Reward_DEBUG = {
    Name = "Reward_DEBUG",
    Description = {
        en = "Reward: Start the debug mode. See documentation for more information.",
        de = "Lohn: Startet den Debug-Modus. Für mehr Informationen siehe Dokumentation.",
    },
    Parameter = {
        { ParameterType.Custom,     en = "Check quest while runtime", de = "Quests zur Laufzeit prüfen" },
        { ParameterType.Custom,     en = "Use quest trace", de = "Questverfolgung" },
        { ParameterType.Custom,     en = "Activate developing cheats", de = "Cheats aktivieren" },
        { ParameterType.Custom,     en = "Activate developing shell", de = "Eingabe aktivieren" },
    },
}

function b_Reward_DEBUG:GetRewardTable(__quest_)
    return { Reward.Custom, {self, self.CustomFunction} }
end

function b_Reward_DEBUG:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.CheckWhileRuntime = AcceptAlternativeBoolean(_Parameter)
    elseif (_Index == 1) then
        self.UseQuestTrace = AcceptAlternativeBoolean(_Parameter)
    elseif (_Index == 2) then
        self.DevelopingCheats = AcceptAlternativeBoolean(_Parameter)
    elseif (_Index == 3) then
        self.DevelopingShell = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Reward_DEBUG:CustomFunction(__quest_)
    API.ActivateDebugMode(self.CheckWhileRuntime, self.UseQuestTrace, self.DevelopingCheats, self.DevelopingShell);
end

function b_Reward_DEBUG:GetCustomData(_Index)
    return {"true","false"};
end

Core:RegisterBehavior(b_Reward_DEBUG);

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global:Install()
    self.Data.DebugCommands = {
        -- groupless commands
        {"clear",       self.Clear,},
        {"diplomacy",   self.Diplomacy,},
        {"restartmap",  self.RestartMap,},
        {"reveal",      self.ShareView,                1},
        {"conceal",     self.ShareView,                0},
        {"setposition", self.SetPosition,},
        {"version",     self.ShowVersion,},
        -- quest control
        {"win",         self.SetQuestState,            1},
        {"fail",        self.SetQuestState,            2},
        {"stop",        self.SetQuestState,            3},
        {"start",       self.SetQuestState,            4},
        {"restart",     self.SetQuestState,            5},
        {"won",         self.FindQuestsByState,        1},
        {"failed",      self.FindQuestsByState,        2},
        {"stoped",      self.FindQuestsByState,        3},
        {"active",      self.FindQuestsByState,        4},
        {"waiting",     self.FindQuestsByState,        5},
        {"find",        self.FindQuestsByState,        6},
        -- loading scripts into running game and execute them
        {"<<",          self.LoadScript,               true},
        {"<",           self.LoadScript,               false},
        -- execute short lua commands
        {">>",          self.ExecuteLuaCommand,        true},
        {">",           self.ExecuteLuaCommand,        false},
        -- old shit -> "inoffical commands"
        {"shareview",   self.ShareView,                -1},
        {"printequal",  self.FindQuestsByState,        6},
        {"printactive", self.FindQuestsByState,        4},
        {"lexec",       self.ExecuteLuaCommand,        true},
        {"gexec",       self.ExecuteLuaCommand,        false},
        {"lload",       self.LoadScript,               true},
        {"gload",       self.LoadScript,               false},
    }

    for k,v in pairs(_G) do
        if type(v) == "table" and v.Name and k == "b_"..v.Name and v.CustomFunction and not v.CustomFunction2 then
            v.CustomFunction2 = v.CustomFunction;
            v.CustomFunction = function(self, __quest_)
                if AddOnQuestDebug.Global.Data.CheckAtRun then
                    if self.DEBUG and not self.FOUND_ERROR and self:Debug(__quest_) then
                        self.FOUND_ERROR = true;
                    end
                end
                if not self.FOUND_ERROR then
                    return self:CustomFunction2(__quest_);
                end
            end
        end
    end

    self:OverwriteCreateQuests();

    API.AddSaveGameAction(self.OnSaveGameLoad);
end

---
-- Aktiviert den Debug.
--
-- Der Developing Mode bietet viele Hotkeys und eine Konsole. Die Konsole ist
-- ein mächtiges Werkzeug. Es ist möglich tief in das Spiel einzugreifen und
-- sogar Funktionen während des Spiels zu überschreiben.
--
-- @param _CheckAtRun [boolean] Prüfe Quests zur Laufzeit
-- @param _TraceQuests [boolean] Aktiviert Questverfolgung
-- @param _Cheats [boolean] Aktiviert Cheats
-- @param _Shell [boolean] Aktiviert Konsole
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global:ActivateDebug(_CheckAtRun, _TraceQuests, _Cheats, _Shell)
    if self.Data.DebugModeIsActive then
        return;
    end
    self.Data.DebugModeIsActive = true;

    self.Data.CheckAtRun       = _CheckAtRun == true;
    self.Data.TraceQuests      = _TraceQuests == true;
    self.Data.DevelopingCheats = _Cheats == true;
    self.Data.DevelopingShell  = _Shell == true;

    self:ActivateQuestTrace();
    self:ActivateDevelopingCheats();
    self:ActivateDevelopingShell();
end

---
-- Aktiviert die Questverfolgung. Jede Statusänderung wird am Bildschirm
-- angezeigt.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global:ActivateQuestTrace()
    if self.Data.TraceQuests then
        DEBUG_EnableQuestDebugKeys();
        DEBUG_QuestTrace(true);
    end
end

---
-- <p>Aktiviert die Cheats.</p>
-- <p>Es werden die Development-Cheats benutzt und um einige neue erweitert.</p>
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global:ActivateDevelopingCheats()
    if self.Data.DevelopingCheats then
        Logic.ExecuteInLuaLocalState([[
            if not AddOnQuestDebug then
                StartSimpleJobEx(function()
                    if AddOnQuestDebug then
                        AddOnQuestDebug.Local:ActivateDevelopingCheats();
                        return true;
                    end
                end);
            else
                AddOnQuestDebug.Local:ActivateDevelopingCheats();
            end
        ]]);
    end
end

---
-- <p>Aktiviert die Shell.</p>
-- <p>Der Debug stellt einige zusätzliche Tastenkombinationen bereit:</p>
-- <p>Die Konsole des Debug wird mit SHIFT + ^ geöffnet.</p>
-- <p>Die Konsole bietet folgende Kommandos:</p>
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global:ActivateDevelopingShell()
    if self.Data.DevelopingShell then
        Logic.ExecuteInLuaLocalState([[
            if not AddOnQuestDebug then
                StartSimpleJobEx(function()
                    if AddOnQuestDebug then
                        AddOnQuestDebug.Local:ActivateDevelopingShell();
                        return true;
                    end
                end);
            else
                AddOnQuestDebug.Local:ActivateDevelopingShell();
            end
        ]]);
    end
end

---
-- Ließt eingegebene Kommandos und führt entsprechende Funktionen aus.
--
-- Für die Zerlegung der Kommandizeile wird der Tokenizer benutzt.
--
-- Kommandos können auch im Skript oder im Lua Debugger genutzt werden. Dafür
-- muss eval() mit dem Befehl als Argument aufgerufen werden.
--
-- @within Internal
-- @local
-- @see AddOnQuestDebug.Global:Tokenize
--
function AddOnQuestDebug.Global:Parser(_Input)
    local Results = {};
    local Commands = self:Tokenize(_Input);
    for k, v in pairs(Commands) do
        local Action = string.lower(v[1]);
        for i= 1, #self.Data.DebugCommands, 1 do
            if v[1] == self.Data.DebugCommands[i][1] then
                local SelectedCommand = self.Data.DebugCommands[i];
                for j=2, #v, 1 do
                    local Number = tonumber(v[j]);
                    if Number then
                        v[j] = Number;
                    end
                end

                local CommandResult = SelectedCommand[2](v, SelectedCommand[3]);
                if CommandResult then
                    table.insert(Results, CommandResult);
                end
            end
        end
    end
    return Results;
end
function eval(_Input)
    return AddOnQuestDebug.Global:Parser(_Input);
end

---
-- Zerlegt den Eingabestring in einzelne Kommandos und gibt diese als Table
-- zurück. Unterschiedliche Kommandos werden mit && abgetrennt und entsprechend
-- als mehrere Einträge im Table angelegt. Mit dem Wiederholungszeichen &
-- wird das Komanndo für alle angegebenen Eingaben wiederholt.
--
-- Beispiel:
--
-- <pre>
-- Eingabe:
-- "win QuestA & QuestB && fail QuestC && stop QuestD & Quest E"
--
-- Ausgabe:
-- {
-- {"win", "QuestA"}
-- {"win", "QuestB"}
-- {"fail", "QuestC"}
-- {"stop", "QuestD"}
-- {"stop", "QuestE"}
-- }</pre>
--
-- @return Table mit Tokens
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global:Tokenize(_Input)
    local Commands = {};
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

---
-- Läd ein Lua-Skript in das Enviorment.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global.LoadScript(_Arguments, _Flags)
    if _Arguments[2] then
        if _Flags == true then
            Logic.ExecuteInLuaLocalState([[Script.Load("]].._Arguments[2]..[[")]]);
        elseif _Flags == false then
            Script.Load(_Arguments[2]);
        end
        API.Note("load script ".._Arguments[2]);
    end
end

---
-- Ruft eine Funktion (optional mit Parametern) im Enviorment auf.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global.ExecuteCommand(_Arguments, _Flags)
    if _Arguments[2] then
        local args = "";
        for i=3,#_Arguments do
            args = args .. ((i>3 and ",") or "");
            args = args .. " " .. _Arguments[i];
        end

        if _Flags == true then
            Logic.ExecuteInLuaLocalState([[]].. _Arguments[2] .. [[(]] ..args..[[)]]);
        elseif _Flags == false then
            Logic.ExecuteInLuaLocalState([[GUI.SendScriptCommand("]].. _Arguments[2] .. [[(]]..args..[[)")]]);
        end
    end
end

---
-- Führt ein Lua-Command innerhalb des Strings aus.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global.ExecuteLuaCommand(_Arguments, _Flags)
    if _Arguments[2] then
        local args = "";
        for i=2,#_Arguments do
            args = args .. " " .. _Arguments[i];
        end

        if _Flags == true then
            Logic.ExecuteInLuaLocalState([[]]..args..[[]]);
        elseif _Flags == false then
            Logic.ExecuteInLuaLocalState([[GUI.SendScriptCommand("]]..args..[[")]]);
        end
    end
end

---
-- Konsolenbefehl: Leert das Debug Window.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global.Clear()
    Logic.ExecuteInLuaLocalState("GUI.ClearNotes()");
end

---
-- Konsolenbefehl: Ändert die Diplomatie zwischen zwei Spielern.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global.Diplomacy(_Arguments)
    SetDiplomacyState(_Arguments[2], _Arguments[3], _Arguments[4]);
end

---
--  Konsolenbefehl: Startet die Map umgehend neu.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global.RestartMap()
    Logic.ExecuteInLuaLocalState("Framework.RestartMap()");
end

---
-- Konsolenbefehl: Aktiviert/deaktiviert die geteilte Sicht zweier Spieler.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global.ShareView(_Arguments, _Flag)
    if _Flag == -1 then
        Logic.SetShareExplorationWithPlayerFlag(_Arguments[2], _Arguments[3], _Arguments[4]);
    end
    Logic.SetShareExplorationWithPlayerFlag(_Arguments[2], _Arguments[3], _Flag);
end

---
-- Konsolenbefehl: Setzt die Position eines Entity.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global.SetPosition(_Arguments)
    local entity = GetID(_Arguments[2]);
    local target = GetID(_Arguments[3]);
    local x,y,z  = Logic.EntityGetPos(target);
    if Logic.IsBuilding(target) == 1 then
        x,y = Logic.GetBuildingApproachPosition(target);
    end
    Logic.DEBUG_SetSettlerPosition(entity, x, y);
    if Logic.IsLeader(entity) == 1 then
        local Soldiers = {Logic.GetSoldiersAttachedToLeader(entity)};
        for i= 1, #Soldiers, 1 do
            if isExisting(Soldiers[i]) then
                Logic.DEBUG_SetSettlerPosition(Soldiers[i], x, y);
            end
        end
    end
end

---
-- Konsolenbefehl: Zeigt die Version der QSB an.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global.ShowVersion()
    Logic.ExecuteInLuaLocalState("GUI.ClearNotes(); GUI.AddStaticNote(QSB.Version)");
    return QSB.Version;
end

---
-- Konsolenbefehl: Sucht nach allen Quests, auf die den angegebenen Namen
-- enthalten und gibt die Namen der gefundenen Quests zurück.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global.FindQuestNames(_Pattern, _ExactName)
    local FoundQuests = FindQuestsByName(_Pattern, _ExactName);
    if #FoundQuests == 0 then
        return {};
    end
    local NamesOfFoundQuests = {};
    for i= 1, #FoundQuests, 1 do
        table.insert(NamesOfFoundQuests, FoundQuests[i].Identifier);
    end
    return NamesOfFoundQuests;
end

---
-- Konsolenbefehl: Gibt die Namen aller Quests mit dem Status zurück. Die
-- Suche kann mit einem Pattern eingeschränkt werden. Es werden maximal 12
-- Quests angezeigt.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global.FindQuestsByState(_Data, _Flag)
    local QuestsOfState = {};
    for i= 1, Quests[0], 1 do
        if _Flag == 1 and Quests[i].Result == QuestResult.Success then
            table.insert(QuestsOfState, Quests[i]);
        end
        if _Flag == 2 and Quests[i].Result == QuestResult.Failure then
            table.insert(QuestsOfState, Quests[i]);
        end
        if _Flag == 3 and Quests[i].Result == QuestResult.Interrupted then
            table.insert(QuestsOfState, Quests[i]);
        end
        if _Flag == 4 and Quests[i].State == QuestState.Active then
            table.insert(QuestsOfState, Quests[i]);
        end
        if _Flag == 5 and Quests[i].State == QuestState.NotTriggered then
            table.insert(QuestsOfState, Quests[i]);
        end
        if _Flag == 6 and ((_Data[2] and string.find(Quests[i].Identifier, _Data[2])) or not _Data[2]) then
            table.insert(QuestsOfState, Quests[i]);
        end
    end

    local QuestNames = "";
    local Matching = 0;
    for i= 1, #QuestsOfState, 1 do
        if Matching < 15 then
            if _Data[2] then
                if string.find(QuestsOfState[i].Identifier, _Data[2]) then
                    QuestNames = QuestNames .. "- " .. QuestsOfState[i].Identifier .. "{cr}";
                    Matching = Matching +1;
                end
            else
                QuestNames = QuestNames .. "- " .. QuestsOfState[i].Identifier .. "{cr}";
                Matching = Matching +1;
            end
        else
            QuestNames = QuestNames .. "... (" .. (#QuestsOfState-Matching) .. " more)";
            break;
        end
    end

    Logic.ExecuteInLuaLocalState([[
        GUI.ClearNotes()
        GUI.AddStaticNote("Found quests:{cr}]]..QuestNames..[[")
    ]]);
    return "Found quests:{cr}"..QuestNames;
end

---
-- Konsolenbefehl: Setzt den Status eines Quests. Mit der Statusänderung wird
-- ggf. Fortschrit zurückgesetzt.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global.SetQuestState(_Data, _Flag)
    local FoundQuests = AddOnQuestDebug.Global.FindQuestNames(_Data[2], true);
    if #FoundQuests ~= 1 then
        API.Note("Unable to find quest containing '" .._Data[2].. "'");
        return "Unable to find quest containing '" .._Data[2].. "'";
    end
    if _Flag == 1 then
        API.WinQuest(FoundQuests[1], true);
        API.Note("win quest '" ..FoundQuests[1].. "'");
        return "win quest '" ..FoundQuests[1].. "'"
    elseif _Flag == 2 then
        API.FailQuest(FoundQuests[1], true);
        API.Note("fail quest '" ..FoundQuests[1].. "'");
        return "fail quest '" ..FoundQuests[1].. "'"
    elseif _Flag == 3 then
        API.StopQuest(FoundQuests[1], true);
        API.Note("interrupt quest '" ..FoundQuests[1].. "'");
        return "interrupt quest '" ..FoundQuests[1].. "'";
    elseif _Flag == 4 then
        API.StartQuest(FoundQuests[1], true);
        API.Note("trigger quest '" ..FoundQuests[1].. "'");
        return "trigger quest '" ..FoundQuests[1].. "'";
    else
        API.RestartQuest(FoundQuests[1], true);
        API.Note("restart quest '" ..FoundQuests[1].. "'");
        return "restart quest '" ..FoundQuests[1].. "'";
    end
end

---
-- Überschreibt CreateQuests, sodass Assistentenquests über das Skript erzeugt
-- werden um diese sinnvoll überprüfen zu können.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global.OverwriteCreateQuests()
    AddOnQuestDebug.Global.Data.CreateQuestsOriginal = CreateQuests;
    CreateQuests = function()
        local QuestNames = Logic.Quest_GetQuestNames()
        for i=1, #QuestNames, 1 do
            local QuestName = QuestNames[i]
            local QuestData = {Logic.Quest_GetQuestParamter(QuestName)};

            -- Behavior ermitteln
            local Behaviors = {};
            local Amount = Logic.Quest_GetQuestNumberOfBehaviors(QuestName);
            if Amount > 0 then
                for j=0, Amount-1, 1 do
                    local Name = Logic.Quest_GetQuestBehaviorName(QuestName, j);
                    local Template = GetBehaviorTemplateByName(Name);
                    assert(Template ~= nil);

                    local Parameters = Logic.Quest_GetQuestBehaviorParameter(QuestName, j);
                    table.insert(Behaviors, Template:new(unpack(Parameters)));
                end

                local SuggestionText;
                if (QuestData[6] and QuestData[6] ~= "" and QuestData[6] ~= "KEY(NO_MESSAGE)") then
                    SuggestionText = QuestData[6];
                end
                local SuccessText;
                if (QuestData[8] and QuestData[8] ~= "" and QuestData[8] ~= "KEY(NO_MESSAGE)") then
                    SuccessText = QuestData[8];
                end
                local FailureText;
                if (QuestData[7] and QuestData[7] ~= "" and QuestData[7] ~= "KEY(NO_MESSAGE)") then
                    FailureText = QuestData[7];
                end

                API.CreateQuest {
                    Name        = QuestName,
                    Sender      = QuestData[1],
                    Receiver    = QuestData[2],
                    Time        = QuestData[4],
                    Description = QuestData[5],
                    Suggestion  = SuggestionText,
                    Failure     = FailureText,
                    Success     = SuccessText,

                    unpack(Behaviors),
                };
            end
        end
    end
end

---
-- Stellt den Debug nach dem Laden eines Spielstandes wieder her.
--
-- @param _Arguments Argumente der überschriebenen Funktion
-- @param _Original  Referenz auf Save-Funktion
-- @within Internal
-- @local
--
function AddOnQuestDebug.Global.OnSaveGameLoad(_Arguments, _Original)
    AddOnQuestDebug.Global:ActivateDevelopingCheats();
    AddOnQuestDebug.Global:ActivateDevelopingShell();
    AddOnQuestDebug.Global:ActivateQuestTrace();
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function AddOnQuestDebug.Local:Install()
end

---
-- Aktiviert die Development Cheats des Spiels.
--
-- @see AddOnQuestDebug.Global:ActivateDevelopingCheats
-- @within Internal
-- @local
--
function AddOnQuestDebug.Local:ActivateDevelopingCheats()
    KeyBindings_EnableDebugMode(1);
    KeyBindings_EnableDebugMode(2);
    KeyBindings_EnableDebugMode(3);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock",1);
end

---
-- Aktiviert die Kommandokonsole.
--
-- @see AddOnQuestDebug.Global:ActivateDevelopingShell
-- @within Internal
-- @local
--
function AddOnQuestDebug.Local:ActivateDevelopingShell()
    GUI_Chat.Abort = function() end

    GUI_Chat.Confirm = function()
        Input.GameMode();
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput",0);
        AddOnQuestDebug.Local.Data.ChatBoxInput = XGUIEng.GetText("/InGame/Root/Normal/ChatInput/ChatInput");
        g_Chat.JustClosed = 1;
        Game.GameTimeSetFactor( GUI.GetPlayerID(), 1 );
    end

    QSB_DEBUG_InputBoxJob = function()
        if not AddOnQuestDebug.Local.Data.BoxShown then
            Input.ChatMode();
            Game.GameTimeSetFactor( GUI.GetPlayerID(), 0 );
            XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput", 1);
            XGUIEng.SetText("/InGame/Root/Normal/ChatInput/ChatInput", "");
            XGUIEng.SetFocus("/InGame/Root/Normal/ChatInput/ChatInput");
            AddOnQuestDebug.Local.Data.BoxShown = true
        elseif AddOnQuestDebug.Local.Data.ChatBoxInput then
            AddOnQuestDebug.Local.Data.ChatBoxInput = string.gsub(AddOnQuestDebug.Local.Data.ChatBoxInput,"'","\'");
            GUI.SendScriptCommand("AddOnQuestDebug.Global:Parser('"..AddOnQuestDebug.Local.Data.ChatBoxInput.."')");
            AddOnQuestDebug.Local.Data.BoxShown = nil;
            return true;
        end
    end

    Input.KeyBindDown(Keys.ModifierShift + Keys.OemPipe, "StartSimpleJob('QSB_DEBUG_InputBoxJob')", 2);
end

Core:RegisterBundle("AddOnQuestDebug");

