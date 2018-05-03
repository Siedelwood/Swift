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
-- die Eingabe von Befehlen zu steuern, einzelne einfache Lua-Kommandos im
-- Spiel auszuführen und sogar komplette Skripte zu laden.
--
-- Der Debug kann auf zwei verschiedene Arten Aktiviert werden:
-- <ol>
-- <li>Im Skript über API.ActivateDebugMode bz. ActivateDebugMode</li>
-- <li>Im Questassistenten über Reward_DEBUG</li>
-- </ol>
--
-- @module AddOnQuestDebug
-- @set sort=true
--

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
-- <b>Alias:</b> ActivateDebugMode
--
-- @param _CheckAtStart   Prüfe Quests zur Erzeugunszeit
-- @param _CheckAtRun     Prüfe Quests zur Laufzeit
-- @param _TraceQuests    Aktiviert Questverfolgung
-- @param _DevelopingMode Aktiviert Cheats und Konsole
-- @within Public
--
function API.ActivateDebugMode(_CheckAtStart, _CheckAtRun, _TraceQuests, _DevelopingMode)
    if GUI then
        API.Bridge("API.DisbandTravelingSalesman(" ..tostring(_CheckAtStart).. ", " ..tostring(_CheckAtRun).. ", " ..tostring(_TraceQuests).. ", " ..tostring(_DevelopingMode).. ")");
        return;
    end
    AddOnQuestDebug.Global:ActivateDebug(_CheckAtStart, _CheckAtRun, _TraceQuests, _DevelopingMode);
end
ActivateDebugMode = API.ActivateDebugMode;

-- -------------------------------------------------------------------------- --
-- Rewards                                                                    --
-- -------------------------------------------------------------------------- --

---
-- Aktiviert den Debug.
--
-- <b>Hinweis:</b> Die Option "Quest vor Start prüfen" funktioniert nur, wenn
-- der Debug im Skript gestartet wird, bevor CreateQuests() ausgeführt wird.
-- Zu dem Zeitpunkt, wenn ein Quest, der im Assistenten erstellt wurde,
-- ausgelöst wird, wurde CreateQuests bereits ausgeführt! Es ist daher nicht
-- mehr möglich die Quests vorab zu prüfen.
--
-- @see API.ActivateDebugMode
--
-- @param _CheckAtStart   Prüfe Quests zur Erzeugunszeit
-- @param _CheckAtRun     Prüfe Quests zur Laufzeit
-- @param _TraceQuests    Aktiviert Questverfolgung
-- @param _DevelopingMode Aktiviert Cheats und Konsole
-- @return Table mit Behavior
-- @within Rewards
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
        { ParameterType.Custom,     en = "Check quests beforehand", de = "Quest vor Start prüfen" },
        { ParameterType.Custom,     en = "Check quest while runtime", de = "Quests zur Laufzeit prüfen" },
        { ParameterType.Custom,     en = "Use quest trace", de = "Questverfolgung" },
        { ParameterType.Custom,     en = "Activate developing mode", de = "Testmodus aktivieren" },
    },
}

function b_Reward_DEBUG:GetRewardTable(__quest_)
    return { Reward.Custom, {self, self.CustomFunction} }
end

function b_Reward_DEBUG:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.CheckAtStart = AcceptAlternativeBoolean(_Parameter)
    elseif (_Index == 1) then
        self.CheckWhileRuntime = AcceptAlternativeBoolean(_Parameter)
    elseif (_Index == 2) then
        self.UseQuestTrace = AcceptAlternativeBoolean(_Parameter)
    elseif (_Index == 3) then
        self.DelepoingMode = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Reward_DEBUG:CustomFunction(__quest_)
    API.ActivateDebugMode(self.CheckAtStart, self.CheckWhileRuntime, self.UseQuestTrace, self.DelepoingMode);
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
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:Install()

    AddOnQuestDebug.Global.Data.DebugCommands = {
        -- groupless commands
        {"clear",               AddOnQuestDebug.Global.Clear,},
        {"diplomacy",           AddOnQuestDebug.Global.Diplomacy,},
        {"restartmap",          AddOnQuestDebug.Global.RestartMap,},
        {"shareview",           AddOnQuestDebug.Global.ShareView,},
        {"setposition",         AddOnQuestDebug.Global.SetPosition,},
        {"unfreeze",            AddOnQuestDebug.Global.Unfreeze,},
        -- quest control
        {"win",                 AddOnQuestDebug.Global.QuestSuccess,      true,},
        {"winall",              AddOnQuestDebug.Global.QuestSuccess,      false,},
        {"fail",                AddOnQuestDebug.Global.QuestFailure,      true,},
        {"failall",             AddOnQuestDebug.Global.QuestFailure,      false,},
        {"stop",                AddOnQuestDebug.Global.QuestInterrupt,    true,},
        {"stopall",             AddOnQuestDebug.Global.QuestInterrupt,    false,},
        {"start",               AddOnQuestDebug.Global.QuestTrigger,      true,},
        {"startall",            AddOnQuestDebug.Global.QuestTrigger,      false,},
        {"restart",             AddOnQuestDebug.Global.QuestReset,        true,},
        {"restartall",          AddOnQuestDebug.Global.QuestReset,        false,},
        {"printequal",          AddOnQuestDebug.Global.PrintQuests,       1,},
        {"printactive",         AddOnQuestDebug.Global.PrintQuests,       2,},
        {"printdetail",         AddOnQuestDebug.Global.PrintQuests,       3,},
        -- loading scripts into running game and execute them
        {"lload",               AddOnQuestDebug.Global.LoadScript,        true},
        {"gload",               AddOnQuestDebug.Global.LoadScript,        false},
        -- execute short lua commands
        {"lexec",               AddOnQuestDebug.Global.ExecuteCommand,    true},
        {"gexec",               AddOnQuestDebug.Global.ExecuteCommand,    false},
        -- garbage collector printouts
        {"collectgarbage",      AddOnQuestDebug.Global.CollectGarbage,},
        {"dumpmemory",          AddOnQuestDebug.Global.CountLuaLoad,},
    }

    for k,v in pairs(_G) do
        if type(v) == "table" and v.Name and k == "b_"..v.Name and v.CustomFunction and not v.CustomFunction2 then
            v.CustomFunction2 = v.CustomFunction;
            v.CustomFunction = function(self, __quest_)
                if AddOnQuestDebug.Global.Data.CheckAtRun then
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
        BundleQuestGeneration.Global.DebugQuest = AddOnQuestDebug.Global.DebugQuest;
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
-- @param _CheckAtStart   Prüfe Quests zur Erzeugunszeit
-- @param _CheckAtRun     Prüfe Quests zur Laufzeit
-- @param _TraceQuests    Aktiviert Questverfolgung
-- @param _DevelopingMode Aktiviert Cheats und Konsole
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:ActivateDebug(_CheckAtStart, _CheckAtRun, _TraceQuests, _DevelopingMode)
    if self.Data.DebugModeIsActive then
        return;
    end
    self.Data.DebugModeIsActive = true;

    self.Data.CheckAtStart    = _CheckAtStart == true;
    QSB.DEBUG_CheckAtStart    = _CheckAtStart == true;
    
    self.Data.CheckAtRun      = _CheckAtRun == true;
    QSB.DEBUG_CheckAtRun      = _CheckAtRun == true;
    
    self.Data.TraceQuests     = _TraceQuests == true;
    QSB.DEBUG_TraceQuests     = _TraceQuests == true;
    
    self.Data.DevelopingMode  = _DevelopingMode == true;
    QSB.DEBUG_DevelopingMode  = _DevelopingMode == true;

    self:ActivateQuestTrace();
    self:ActivateDevelopingMode();
end

---
-- Aktiviert die Questverfolgung. Jede Statusänderung wird am Bildschirm
-- angezeigt.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:ActivateQuestTrace()
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
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:ActivateDevelopingMode()
    if self.Data.DevelopingMode then
        Logic.ExecuteInLuaLocalState("AddOnQuestDebug.Local:ActivateDevelopingMode()");
    end
end

---
-- Ließt eingegebene Kommandos aus und führt entsprechende Funktionen aus.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:Parser(_Input)
    local tokens = self:Tokenize(_Input);
    for k, v in pairs(self.Data.DebugCommands) do
        if v[1] == tokens[1] then
            for i=1, #tokens do
                local numb = tonumber(tokens[i])
                if numb then
                    tokens[i] = numb;
                end
            end
            v[2](AddOnQuestDebug.Global, tokens, v[3]);
            return;
        end
    end
end

---
-- Zerlegt die Eingabe in einzelne Tokens und gibt diese zurück.
--
-- @return Table mit Tokens
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:Tokenize(_Input)
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
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:CollectGarbage()
    collectgarbage();
    Logic.ExecuteInLuaLocalState("AddOnQuestDebug.Local:CollectGarbage()");
end

---
-- Gibt die Speicherauslastung von Lua zurück.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:CountLuaLoad()
    Logic.ExecuteInLuaLocalState("AddOnQuestDebug.Local:CountLuaLoad()");
    local LuaLoad = collectgarbage("count");
    API.StaticNote("Global Lua Size: " ..LuaLoad)
end

---
-- Zeigt alle Quests nach einem Filter an.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:PrintQuests(_Arguments, _Flags)
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
--
--
function AddOnQuestDebug.Global:PrintDetail(_Arguments)
    local questText = "";
    local questID = GetQuestID(string.gsub(_Arguments[2], " ", ""));

    if Quests[questID] then
        local state        = (Quests[questID].State == QuestState.NotTriggered and "not triggered") or
                              (Quests[questID].State == QuestState.Active and "active") or
                                "over";
        local result        = (Quests[questID].Result == QuestResult.Success and "success") or
                              (Quests[questID].Result == QuestResult.Failure and "failure") or
                              (Quests[questID].Result == QuestResult.Interrupted and "interrupted") or
                                "undecided";

        questText = questText .. "Name: " .. Quests[questID].Identifier .. "{cr}";
        questText = questText .. "State: " .. state .. "{cr}";
        questText = questText .. "Result: " .. result .. "{cr}";
        questText = questText .. "Sender: " .. Quests[questID].SendingPlayer .. "{cr}";
        questText = questText .. "Receiver: " .. Quests[questID].ReceivingPlayer .. "{cr}";
        questText = questText .. "Duration: " .. Quests[questID].Duration .. "{cr}";
        questText = questText .. "Start Text: "  .. tostring(Quests[questID].QuestStartMsg) .. "{cr}";
        questText = questText .. "Failure Text: " .. tostring(Quests[questID].QuestFailureMsg) .. "{cr}";
        questText = questText .. "Success Text: " .. tostring(Quests[questID].QuestSuccessMsg) .. "{cr}";
        questText = questText .. "Description: " .. tostring(Quests[questID].QuestDescription) .. "{cr}";
        questText = questText .. "Objectives: " .. #Quests[questID].Objectives .. "{cr}";
        questText = questText .. "Reprisals: " .. #Quests[questID].Reprisals .. "{cr}";
        questText = questText .. "Rewards: " .. #Quests[questID].Rewards .. "{cr}";
        questText = questText .. "Triggers: " .. #Quests[questID].Triggers .. "{cr}";
    else
        questText = questText .. tostring(_Arguments[2]) .. " not found!";
    end

    Logic.ExecuteInLuaLocalState([[
        GUI.ClearNotes()
        GUI.AddStaticNote("]]..questText..[[")
    ]]);
end

---
-- Läd ein Lua-Skript in das Enviorment.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:LoadScript(_Arguments, _Flags)
    if _Arguments[2] then
        if _Flags == true then
            Logic.ExecuteInLuaLocalState([[Script.Load("]].._Arguments[2]..[[")]]);
        elseif _Flags == false then
            Script.Load(_Arguments[2]);
        end
        if not self.Data.SurpassMessages then
            Logic.DEBUG_AddNote("load script ".._Arguments[2]);
        end
    end
end

---
-- Führt ein Lua-Kommando im Enviorment aus.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:ExecuteCommand(_Arguments, _Flags)
    if _Arguments[2] then
        local args = "";
        for i=2,#_Arguments do
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
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:Clear()
    Logic.ExecuteInLuaLocalState("GUI.ClearNotes()");
end

---
-- Konsolenbefehl: Ändert die Diplomatie zwischen zwei Spielern.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:Diplomacy(_Arguments)
    SetDiplomacyState(_Arguments[2], _Arguments[3], _Arguments[4]);
end

---
--  Konsolenbefehl: Startet die Map umgehend neu.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:RestartMap()
    Logic.ExecuteInLuaLocalState("Framework.RestartMap()");
end

---
-- Konsolenbefehl: Aktiviert/deaktiviert die geteilte Sicht zweier Spieler.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:ShareView(_Arguments)
    Logic.SetShareExplorationWithPlayerFlag(_Arguments[2], _Arguments[3], _Arguments[4]);
end

---
-- Konsolenbefehl: Setzt die Position eines Entity.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:SetPosition(_Arguments)
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
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:QuestSuccess(_QuestName, _ExactName)
    local FoundQuests = FindQuestsByName(_QuestName[2], _ExactName);
    if #FoundQuests == 0 then
        return;
    end
    API.WinAllQuests(unpack(FoundQuests));
end

---
-- Lässt einen Quest, oder mehrere Quests mit ähnlichen Namen, fehlschlagen.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:QuestFailure(_QuestName, _ExactName)
    local FoundQuests = FindQuestsByName(_QuestName[2], _ExactName);
    if #FoundQuests == 0 then
        return;
    end
    API.FailAllQuests(unpack(FoundQuests));
end

---
-- Stoppt einen Quest, oder mehrere Quests mit ähnlichen Namen.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:QuestInterrupt(_QuestName, _ExactName)
    local FoundQuests = FindQuestsByName(_QuestName[2], _ExactName);
    if #FoundQuests == 0 then
        return;
    end
    API.StopAllQuests(unpack(FoundQuests));
end

---
-- Startet einen Quest, oder mehrere Quests mit ähnlichen Namen.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:QuestTrigger(_QuestName, _ExactName)
    local FoundQuests = FindQuestsByName(_QuestName[2], _ExactName);
    if #FoundQuests == 0 then
        return;
    end
    API.StartAllQuests(unpack(FoundQuests));
end

---
-- Setzt den Quest / die Quests zurück, sodass er neu gestartet werden kann.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:QuestReset(_QuestName, _ExactName)
    local FoundQuests = FindQuestsByName(_QuestName[2], _ExactName);
    if #FoundQuests == 0 then
        return;
    end
    API.RestartAllQuests(unpack(FoundQuests));
end

---
-- Überschreibt CreateQuests, sodass Assistentenquests über das Skript erzeugt 
-- werden um diese sinnvoll überprüfen zu können.
--
-- @within AddOnQuestDebug.Global
-- @local
--
function AddOnQuestDebug.Global:OverwriteCreateQuests()
    self.Data.CreateQuestsOriginal = CreateQuests;
    CreateQuests = function()
        if not AddOnQuestDebug.Global.Data.CheckAtStart then
            AddOnQuestDebug.Global.Data.CreateQuestsOriginal();
            return;
        end

        local QuestNames = Logic.Quest_GetQuestNames()
        for i=1, #QuestNames, 1 do
            local QuestName = QuestNames[i]
            local QuestData = {Logic.Quest_GetQuestParamter(QuestName)};

            -- Behavior ermitteln
            local Behaviors = {};
            local Amount = Logic.Quest_GetQuestNumberOfBehaviors(QuestName);
            for j=0, Amount-1, 1 do
                local Name = Logic.Quest_GetQuestBehaviorName(QuestName, j);
                local Template = GetBehaviorTemplateByName(Name);
                assert(Template ~= nil);

                local Parameters = Logic.Quest_GetQuestBehaviorParameter(QuestName, j);
                API.DumpTable(Parameters);
                table.insert(Behaviors, Template:new(unpack(Parameters)));
            end

            API.AddQuest {
                Name        = QuestName,
                Sender      = QuestData[1],
                Receiver    = QuestData[2],
                Time        = QuestData[4],
                Description = QuestData[5],
                Suggestion  = QuestData[6],
                Failure     = QuestData[7],
                Success     = QuestData[8],

                unpack(Behaviors),
            }
        end

        API.StartQuests();
    end
end

---
-- Stellt den Debug nach dem Laden eines Spielstandes wieder her.
--
-- @param _Arguments Argumente der überschriebenen Funktion
-- @param _Original  Referenz auf Save-Funktion
-- @local
--
function AddOnQuestDebug.Global.OnSaveGameLoad(_Arguments, _Original)
    AddOnQuestDebug.Global:ActivateDevelopingMode();
    AddOnQuestDebug.Global:ActivateQuestTrace();
end

---
-- Prüft die Quests in der Initalisierungsliste der Quests auf Korrektheit.
--
-- Es können nur Behavior der Typen Goal.Custom, Reprisal.Custom2,
-- Reward.Custom2 und Triggers.Custom überprüft werden. Die anderen Typen
-- können nicht debugt werden!
--
-- @param _List Liste der Quests
-- @local
--
function AddOnQuestDebug.Global.DebugQuest(self, _Quest)
    if AddOnQuestDebug.Global.Data.CheckAtStart then
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

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within AddOnQuestDebug.Local
-- @local
--
function AddOnQuestDebug.Local:Install()

end

---
-- Führt die Garbage Collection aus um nicht benötigten Speicher freizugeben.
--
-- Die Garbage Collection wird von Lua automatisch in Abständen ausgeführt.
-- Mit dieser Funktion kann man nachhelfen, sollten die Intervalle zu lang
-- sein und der Speicher vollgemüllt werden.
--
-- @within AddOnQuestDebug.Local
-- @local
--
function AddOnQuestDebug.Local:CollectGarbage()
    collectgarbage();
end

---
-- Gibt die Speicherauslastung von Lua zurück.
--
-- @within AddOnQuestDebug.Local
-- @local
--
function AddOnQuestDebug.Local:CountLuaLoad()
    local LuaLoad = collectgarbage("count");
    API.StaticNote("Local Lua Size: " ..LuaLoad)
end

---
-- Aktiviert die Questverfolgung. Jede Statusänderung wird am Bildschirm
-- angezeigt.
--
-- @see AddOnQuestDebug.Global:ActivateDevelopingMode
-- @within AddOnQuestDebug.Local
-- @local
--
function AddOnQuestDebug.Local:ActivateDevelopingMode()
    KeyBindings_EnableDebugMode(1);
    KeyBindings_EnableDebugMode(2);
    KeyBindings_EnableDebugMode(3);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock",1);

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

    Input.KeyBindDown(
        Keys.ModifierShift + Keys.OemPipe,
        "StartSimpleJob('QSB_DEBUG_InputBoxJob')",
        2,
        true
    );
end

Core:RegisterBundle("AddOnQuestDebug");

