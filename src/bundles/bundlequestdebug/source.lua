-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Synfonia BundleQuestDebug                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- 
--
-- @module BundleQuestDebug
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

BundleQuestDebug = {
    Global =  {
        Data = {},
    },
    Local = {
        Data = {},
    },
}

-- -------------------------------------------------------------------------- --
-- User Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Aktiviert den Debug.
--
-- Der Developing Mode bietet viele Hotkeys und eine Konsole. Die Konsole ist
-- ein mächtiges Werkzeug. Es ist möglich tief in das Spiel einzugreifen und
-- sogar Funktionen während des Spiels zu überschreiben.
--
-- <b>Alias:</b> ActivateDebugMode
--
-- @param _CheckAtStart   Prüfe Quests zur Erzeugunszeit
-- @param _CheckAtRun     Prüfe Quests zur Laufzeit
-- @param _TraceQuests    Aktiviert Questverfolgung
-- @param _DevelopingMode Aktiviert Cheats und Konsole
-- @within User Space
-- 
function API.ActivateDebugMode(_CheckAtStart, _CheckAtRun, _TraceQuests, _DevelopingMode)
    if GUI then
        return;
    end
    BundleQuestDebug.Global:ActivateDebug(_CheckAtStart, _CheckAtRun, _TraceQuests, _DevelopingMode);
end
ActivateDebugMode = API.ActivateDebugMode;

-- -------------------------------------------------------------------------- --
-- Application Space                                                          --
-- -------------------------------------------------------------------------- --

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within BundleQuestDebug.Global
-- @local
-- 
function BundleQuestDebug.Global:Install()
    
    BundleQuestDebug.Global.Data.DebugCommands = {
        -- groupless commands
        {"clear",               BundleQuestDebug.Global.Clear,},
        {"diplomacy",           BundleQuestDebug.Global.Diplomacy,},
        {"restartmap",          BundleQuestDebug.Global.RestartMap,},
        {"shareview",           BundleQuestDebug.Global.ShareView,},
        {"setposition",         BundleQuestDebug.Global.SetPosition,},
        {"unfreeze",            BundleQuestDebug.Global.Unfreeze,},
        -- quest control
        {"win",                 BundleQuestDebug.Global.QuestSuccess,      true,},
        {"winall",              BundleQuestDebug.Global.QuestSuccess,      false,},
        {"fail",                BundleQuestDebug.Global.QuestFailure,      true,},
        {"failall",             BundleQuestDebug.Global.QuestFailure,      false,},
        {"stop",                BundleQuestDebug.Global.QuestInterrupt,    true,},
        {"stopall",             BundleQuestDebug.Global.QuestInterrupt,    false,},
        {"start",               BundleQuestDebug.Global.QuestTrigger,      true,},
        {"startall",            BundleQuestDebug.Global.QuestTrigger,      false,},
        {"restart",             BundleQuestDebug.Global.QuestReset,        true,},
        {"restartall",          BundleQuestDebug.Global.QuestReset,        false,},
        {"printequal",          BundleQuestDebug.Global.PrintQuests,       1,},
        {"printactive",         BundleQuestDebug.Global.PrintQuests,       2,},
        {"printdetail",         BundleQuestDebug.Global.PrintQuests,       3,},
        -- loading scripts into running game and execute them
        {"lload",               BundleQuestDebug.Global.LoadScript,        true},
        {"gload",               BundleQuestDebug.Global.LoadScript,        false},
        -- execute short lua commands
        {"lexec",               BundleQuestDebug.Global.ExecuteCommand,    true},
        {"gexec",               BundleQuestDebug.Global.ExecuteCommand,    false},
        -- garbage collector printouts
        {"collectgarbage",      BundleQuestDebug.Global.CollectGarbage,},
        {"dumpmemory",          BundleQuestDebug.Global.CountLuaLoad,},
    }
    
    for k,v in pairs(_G) do
        if type(v) == "table" and v.Name and k == "b_"..v.Name and v.CustomFunction and not v.CustomFunction2 then
            v.CustomFunction2 = v.CustomFunction;
            v.CustomFunction = function(self, __quest_)
                if BundleQuestDebug.Global.Data.CheckAtRun then
                    if self.DEBUG and not self.FOUND_ERROR and self:DEBUG(__quest_) then
                        self.FOUND_ERROR = true;
                    end
                end
                if not self.FOUND_ERROR then
                    return self:CustomFunction2(__quest_);
                end
            end
        end
    end
    
    if BundleQuestGeneration then
        BundleQuestGeneration.Global.DebugQuests = BundleQuestDebugHelper_DebugQuests;
    end
    
    API.AddSaveGameAction(self.OnSaveGameLoad);
end

---
-- Aktiviert den Debug.
--
-- Der Developing Mode bietet viele Hotkeys und eine Konsole. Die Konsole ist
-- ein mächtiges Werkzeug. Es ist möglich tief in das Spiel einzugreifen und
-- sogar Funktionen während des Spiels zu überschreiben.
--
-- @param _CheckAtStart   Prüfe Quests zur Erzeugunszeit
-- @param _CheckAtRun     Prüfe Quests zur Laufzeit
-- @param _TraceQuests    Aktiviert Questverfolgung
-- @param _DevelopingMode Aktiviert Cheats und Konsole
-- @within BundleQuestDebug.Global
-- @local
-- 
function BundleQuestDebug.Global:ActivateDebug(_CheckAtStart, _CheckAtRun, _TraceQuests, _DevelopingMode)
    if self.Data.DebugModeIsActive then
        return;
    end
    self.Data.DebugModeIsActive = true;
    
    self.Data.CheckAtStart    = _CheckAtStart == true;
    self.Data.CheckAtRun      = _CheckAtRun == true;
    self.Data.TraceQuests     = _TraceQuests == true;
    self.Data.DevelopingMode  = _DevelopingMode == true;
    
    self:ActivateQuestTrace();
    self:ActivateDevelopingMode();
end

---
-- Stellt den Debug nach dem Laden eines Spielstandes wieder her.
-- @local
--
function BundleQuestDebug.Global.OnSaveGameLoad(_Original)
    BundleQuestDebug.Global:ActivateDevelopingMode();
    BundleQuestDebug.Global:ActivateQuestTrace();
end

---
-- Prüft die Quests in der Initalisierungsliste der Quests auf Korrektheit.
--
-- @param _List Liste der Quests
-- @local
--
BundleQuestDebugHelper_DebugQuests = function(self, _Quest)
    if BundleQuestDebug.Global.Data.CheckAtStart then
        if _Quest.Goals then
            for i=1, #_Quest.Goals, 1 do
                if type(_Quest.Goals[i][2]) == "table" and type(_Quest.Goals[i][2][1]) == "table" then
                    if _Quest.Goals[i][2][1].DEBUG and _Quest.Goals[i][2][1]:DEBUG(_Quest) then
                        return false;
                    end
                end
            end
        end
        if _Quest.Reprisals then
            for i=1, #_Quest.Reprisals, 1 do
                if type(_Quest.Reprisals[i][2]) == "table" and type(_Quest.Reprisals[i][2][1]) == "table" then
                    if _Quest.Reprisals[i][2][1].DEBUG and _Quest.Reprisals[i][2][1]:DEBUG(_Quest) then
                        return false;
                    end
                end
            end
        end
        if _Quest.Rewards then
            for i=1, #_Quest.Rewards, 1 do
                if type(_Quest.Rewards[i][2]) == "table" and type(_Quest.Rewards[i][2][1]) == "table" then
                    if _Quest.Rewards[i][2][1].DEBUG and _Quest.Rewards[i][2][1]:DEBUG(_Quest) then
                        return false;
                    end
                end
            end
        end
        if _Quest.Triggers then
            for i=1, #_Quest.Triggers, 1 do
                if type(_Quest.Triggers[i][2]) == "table" and type(_Quest.Triggers[i][2][1]) == "table" then
                    if _Quest.Triggers[i][2][1].DEBUG and _Quest.Triggers[i][2][1]:DEBUG(_Quest) then
                        return false;
                    end
                end
            end
        end
    end
    return true;
end

---
-- Aktiviert die Questverfolgung. Jede Statusänderung wird am Bildschirm
-- angezeigt.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:ActivateQuestTrace()
    if self.Data.TraceQuests then
        DEBUG_EnableQuestDebugKeys();
        DEBUG_QuestTrace(true);
    end
end

---
-- <p>Aktiviert die Questverfolgung. Jede Statusänderung wird am Bildschirm
-- angezeigt.</p>
-- <p>Der Debug stellt einige zusätzliche Tastenkombinationen bereit:</p>
-- <p>Die Konsole des Debug wird mit SHIFT + ^ geöffnet.</p>
-- <p>Die Konsole bietet folgende Kommandos:</p>
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:ActivateDevelopingMode()
    if self.Data.DevelopingMode then
        Logic.ExecuteInLuaLocalState("BundleQuestDebug.Local:ActivateDevelopingMode()");
    end
end

---
-- Ließt eingegebene Kommandos aus und führt entsprechende Funktionen aus.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:Parser(_Input)
    local tokens = self:Tokenize(_Input);
    for k, v in pairs(self.Data.DebugCommands) do
        if v[1] == tokens[1] then
            for i=1, #tokens do
                local numb = tonumber(tokens[i])
                if numb then
                    tokens[i] = numb;
                end
            end
            v[2](BundleQuestDebug.Global, tokens, v[3]);
            return;
        end
    end
end

---
-- Zerlegt die Eingabe in einzelne Tokens und gibt diese zurück.
--
-- @return Table mit Tokens
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:Tokenize(_Input)
    local tokens = {};
    local rest = _Input;
    while (rest and rest:len() > 0)
    do
        local s, e = string.find(rest, " ");
        if e then
            tokens[#tokens+1] = rest:sub(1, e-1);
            rest = rest:sub(e+1, rest:len());
        else
            tokens[#tokens+1] = rest;
            rest = nil;
        end
    end
    return tokens;
end

---
-- Führt die Garbage Collection aus um nicht benötigten Speicher freizugeben.
--
-- Die Garbage Collection wird von Lua automatisch in Abständen ausgeführt.
-- Mit dieser Funktion kann man nachhelfen, sollten die Intervalle zu lang
-- sein und der Speicher vollgemüllt werden.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:CollectGarbage()
    collectgarbage();
    Logic.ExecuteInLuaLocalState("BundleQuestDebug.Local:CollectGarbage()");
end

---
-- Gibt die Speicherauslastung von Lua zurück.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:CountLuaLoad()
    Logic.ExecuteInLuaLocalState("BundleQuestDebug.Local:CountLuaLoad()");
    local LuaLoad = collectgarbage("count");
    API.StaticNote("Global Lua Size: " ..LuaLoad)
end

---
-- Zeigt alle Quests nach einem Filter an.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:PrintQuests(_Arguments, _Flags)
    local questText         = ""
    local counter            = 0;
    
    local accept = function(_quest, _state)
        return _quest.State == _state;
    end
        
    if _Flags == 3 then
        self:PrintDetail(_Arguments);
        return;
    end
    
    if _Flags == 1 then
        accept = function(_quest, _arg)
            return string.find(_quest.Identifier, _arg);
        end
    elseif _Flags == 2 then
        _Arguments[2] = QuestState.Active;
    end
    
    for i= 1, Quests[0] do
        if Quests[i] then
            if accept(Quests[i], _Arguments[2]) then
                counter = counter +1;
                if counter <= 15 then
                    questText = questText .. ((questText:len() > 0 and "{cr}") or "");
                    questText = questText ..  Quests[i].Identifier;
                end
            end
        end
    end

    if counter >= 15 then
        questText = questText .. "{cr}{cr}(" .. (counter-15) .. " weitere Ergebnis(se) gefunden!)";
    end

    Logic.ExecuteInLuaLocalState([[
        GUI.ClearNotes()
        GUI.AddStaticNote("]]..questText..[[")
    ]]);
end

---
-- Läd ein Lua-Skript in das Enviorment.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:LoadScript(_Arguments, _Flags)
    if _Arguments[2] then
        if _Flags == true then
            Logic.ExecuteInLuaLocalState([[Script.Load("]].._Arguments[2]..[[")]]);
        elseif _Flags == false then
            Script.Load(__arguments_[2]);
        end
        if not self.Data.SurpassMessages then
            Logic.DEBUG_AddNote("load script ".._Arguments[2]);
        end
    end
end

---
-- Führt ein Lua-Kommando im Enviorment aus.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:ExecuteCommand(_Arguments, _Flags)
    if _Arguments[2] then
        local args = "";
        for i=2,#__arguments_ do
            args = args .. " " .. _Arguments[i];
        end

        if _Flags == true then
            _Arguments[2] = string.gsub(args,"'","\'");
            Logic.ExecuteInLuaLocalState([[]]..args..[[]]);
        elseif _Flags == false then
            Logic.ExecuteInLuaLocalState([[GUI.SendScriptCommand("]]..args..[[")]]);
        end
    end
end

---
-- Konsolenbefehl: Leert das Debug Window.
--
-- @within BundleQuestDebug.Global
-- @local
-- 
function BundleQuestDebug.Global:Clear()
    Logic.ExecuteInLuaLocalState("GUI.ClearNotes()");
end

---
-- Konsolenbefehl: Ändert die Diplomatie zwischen zwei Spielern.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:Diplomacy(_Arguments)
    SetDiplomacyState(_Arguments[2], _Arguments[3], _Arguments[4]);
end

---
--  Konsolenbefehl: Startet die Map umgehend neu.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:RestartMap()
    Logic.ExecuteInLuaLocalState("Framework.RestartMap()");
end

---
-- Konsolenbefehl: Aktiviert/deaktiviert die geteilte Sicht zweier Spieler.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:ShareView(_Arguments)
    Logic.SetShareExplorationWithPlayerFlag(_Arguments[2], _Arguments[3], _Arguments[4]);
end

---
-- Konsolenbefehl: Setzt die Position eines Entity.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:SetPosition(_Arguments)
    local entity = GetID(_Arguments[2]);
    local target = GetID(_Arguments[3]);
    local x,y,z  = Logic.EntityGetPos(target);
    if Logic.IsBuilding(target) == 1 then
        x,y = Logic.GetBuildingApproachPosition(target);
    end
    Logic.DEBUG_SetSettlerPosition(entity, x, y);
end

---
-- Beendet einen Quest, oder mehrere Quests mit ähnlichen Namen, erfolgreich.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:QuestSuccess(_QuestName, _ExactName)
    local FoundQuests = FindQuestsByName(_QuestName[1], _ExactName);
    if #FoundQuests > 0 then
        return;
    end
    API.WinAllQuests(unpack(FoundQuests));
end

---
-- Lässt einen Quest, oder mehrere Quests mit ähnlichen Namen, fehlschlagen.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:QuestFailure(_QuestName, _ExactName)
    local FoundQuests = FindQuestsByName(_QuestName[1], _ExactName);
    if #FoundQuests > 0 then
        return;
    end
    API.FailAllQuests(unpack(FoundQuests));
end

---
-- Stoppt einen Quest, oder mehrere Quests mit ähnlichen Namen.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:QuestInterrupt(_QuestName, _ExactName)
    local FoundQuests = FindQuestsByName(_QuestName[1], _ExactName);
    if #FoundQuests > 0 then
        return;
    end
    API.StopAllQuests(unpack(FoundQuests));
end

---
-- Startet einen Quest, oder mehrere Quests mit ähnlichen Namen.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:QuestTrigger(_QuestName, _ExactName)
    local FoundQuests = FindQuestsByName(_QuestName[1], _ExactName);
    if #FoundQuests > 0 then
        return;
    end
    API.StartAllQuests(unpack(FoundQuests));
end

---
-- Setzt den Quest / die Quests zurück, sodass er neu gestartet werden kann.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:QuestReset(_QuestName, _ExactName)
    local FoundQuests = FindQuestsByName(_QuestName[1], _ExactName);
    if #FoundQuests > 0 then
        return;
    end
    API.RestartAllQuests(unpack(FoundQuests));
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within BundleQuestDebug.Local
-- @local
-- 
function BundleQuestDebug.Local:Install()
    
end

---
-- Führt die Garbage Collection aus um nicht benötigten Speicher freizugeben.
--
-- Die Garbage Collection wird von Lua automatisch in Abständen ausgeführt.
-- Mit dieser Funktion kann man nachhelfen, sollten die Intervalle zu lang
-- sein und der Speicher vollgemüllt werden.
--
-- @within BundleQuestDebug.Local
-- @local
--
function BundleQuestDebug.Local:CollectGarbage()
    collectgarbage();
end

---
-- Gibt die Speicherauslastung von Lua zurück.
--
-- @within BundleQuestDebug.Local
-- @local
--
function BundleQuestDebug.Local:CountLuaLoad()
    local LuaLoad = collectgarbage("count");
    API.StaticNote("Local Lua Size: " ..LuaLoad)
end

---
-- Aktiviert die Questverfolgung. Jede Statusänderung wird am Bildschirm
-- angezeigt.
--
-- @see BundleQuestDebug.Global:ActivateDevelopingMode
-- @within BundleQuestDebug.Local
-- @local
--
function BundleQuestDebug.Local:ActivateDevelopingMode()
    KeyBindings_EnableDebugMode(1);
    KeyBindings_EnableDebugMode(2);
    KeyBindings_EnableDebugMode(3);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock",1);

    GUI_Chat.Abort = function() end

    GUI_Chat.Confirm = function()
        Input.GameMode();
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput",0);
        BundleQuestDebug.Local.Data.ChatBoxInput = XGUIEng.GetText("/InGame/Root/Normal/ChatInput/ChatInput");
        g_Chat.JustClosed = 1;
        Game.GameTimeSetFactor( GUI.GetPlayerID(), 1 );
    end
    
    QSB_DEBUG_InputBoxJob = function()
        if not BundleQuestDebug.Local.Data.BoxShown then
            Input.ChatMode();
            Game.GameTimeSetFactor( GUI.GetPlayerID(), 0 );
            XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput", 1);
            XGUIEng.SetText("/InGame/Root/Normal/ChatInput/ChatInput", "");
            XGUIEng.SetFocus("/InGame/Root/Normal/ChatInput/ChatInput");
            BundleQuestDebug.Local.Data.BoxShown = true
        elseif BundleQuestDebug.Local.Data.ChatBoxInput then
            BundleQuestDebug.Local.Data.ChatBoxInput = string.gsub(BundleQuestDebug.Local.Data.ChatBoxInput,"'","\'");
            GUI.SendScriptCommand("BundleQuestDebug.Global:Parser('"..BundleQuestDebug.Local.Data.ChatBoxInput.."')");
            BundleQuestDebug.Local.Data.BoxShown = nil;
            return true;
        end
    end
    
    Input.KeyBindDown(
        Keys.ModifierShift + Keys.OemPipe,
        "StartSimpleJob('QSB_DEBUG_InputBoxJob')",
        2,
        true
    );
end

Core:RegisterBundle("BundleQuestDebug");

