--[[
Swift_0_Core/Debug

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Stellt Cheats und Befehle für einfacheres Testen bereit.
--
-- <b>Befehle:</b><br>
-- <i>Diese Befehle können über die Konsole (SHIFT + ^) eingegeben werden, wenn
-- der Debug Mode aktiviert ist.</i><br>
-- <table border="1">
-- <tr>
-- <td><b>Befehl</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>restartmap</td>
-- <td>Map sofort neu starten</td>
-- </tr>
-- </table>
--
-- <b>Cheats:</b><br>
-- <i>Bei aktivierten Debug Mode können diese Cheat Codes verwendet werden.</i><br>
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
-- <td>CTRL + SHIFT + ALT + R</td>
-- <td>Map sofort neu starten.</td>
-- </tr>
-- <td>CTRL + C</td>
-- <td>Zeitanzeige an/aus</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + A</td>
-- <td>Clutter (Gräser) anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + C</td>
-- <td>Grasobjekte anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + E</td>
-- <td>Laubbäume anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + F</td>
-- <td>FoW anzeigen (an/aus) <i>Gebiete werden dauerhaft erkundet!</i></td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + G</td>
-- <td>GUI anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + H</td>
-- <td>Steine und Tannen anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + R</td>
-- <td>Straßen anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + S</td>
-- <td>Schatten anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + T</td>
-- <td>Boden anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + U</td>
-- <td>FoW anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + W</td>
-- <td>Wasser anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + X</td>
-- <td>Render Mode des Wassers umschalten (Einfach und komplex)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + Y</td>
-- <td>Himmel anzeigen (an/aus)</td>
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
-- <td>ALT + F5</td>
-- <td>Bedürfnis nach Nahrung in Gebäude aktivieren</td>
-- </tr>
-- <tr>
-- <td>ALT + F6</td>
-- <td>Bedürfnis nach Kleidung in Gebäude aktivieren</td>
-- </tr>
-- <tr>
-- <td>ALT + F7</td>
-- <td>Bedürfnis nach Hygiene in Gebäude aktivieren</td>
-- </tr>
-- <tr>
-- <td>ALT + F8</td>
-- <td>Bedürfnis nach Unterhaltung in Gebäude aktivieren</td>
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
-- @set sort=true
-- @within Beschreibung
--

Swift.m_Benchmarks           = {};
Swift.m_CheckAtRun           = false;
Swift.m_TraceQuests          = false;
Swift.m_DevelopingCheats     = false;
Swift.m_DevelopingShell      = false;
Swift.m_DebugInputShown      = false;
Swift.m_ProcessDebugCommands = false;

function Swift:InitalizeDebugModeGlobal()
    self:InitalizeQsbDebugEvents();
end

function Swift:InitalizeDebugModeLocal()
    self:InitalizeQsbDebugHotkeys();
    self:InitalizeQsbDebugShell();
    self:InitalizeQsbDebugEvents();
end

function Swift:GlobalRestoreDebugAfterLoad()
    self:InitalizeQuestTrace();
end

function Swift:LocalRestoreDebugAfterLoad()
    self:InitalizeQsbDebugHotkeys();
    self:InitalizeQsbDebugShell();
    self:InitalizeDebugHotkeys();
end

function Swift:InitalizeQsbDebugEvents()
    QSB.ScriptEvents.DebugChatConfirmed = Swift:CreateScriptEvent(
        "Event_DebugModeChatConfirmed",
        nil
    );
    QSB.ScriptEvents.DebugModeStatusChanged = Swift:CreateScriptEvent(
        "Event_DebugModeStatusChanged",
        nil
    );
end

function Swift:ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
    if self:IsLocalEnvironment() then
        return;
    end

    self.m_CheckAtRun       = _CheckAtRun == true;
    self.m_TraceQuests      = _TraceQuests == true;
    self.m_DevelopingCheats = _DevelopingCheats == true;
    self.m_DevelopingShell  = _DevelopingShell == true;

    Swift:DispatchScriptEvent(
        QSB.ScriptEvents.DebugModeStatusChanged,
        self.m_CheckAtRun,
        self.m_TraceQuests,
        self.m_DevelopingCheats,
        self.m_DevelopingShell
    );
    self:InitalizeQuestTrace();
    
    Logic.ExecuteInLuaLocalState(string.format(
        [[
            Swift.m_CheckAtRun       = %s;
            Swift.m_TraceQuests      = %s;
            Swift.m_DevelopingCheats = %s;
            Swift.m_DevelopingShell  = %s;

            Swift:DispatchScriptEvent(
                QSB.ScriptEvents.DebugModeStatusChanged,
                Swift.m_CheckAtRun,
                Swift.m_TraceQuests,
                Swift.m_DevelopingCheats,
                Swift.m_DevelopingShell
            );
            Swift:InitalizeDebugHotkeys();
        ]],
        tostring(self.m_CheckAtRun),
        tostring(self.m_TraceQuests),
        tostring(self.m_DevelopingCheats),
        tostring(self.m_DevelopingShell)
    ));
end

function Swift:InitalizeQuestTrace()
    DEBUG_EnableQuestDebugKeys();
    DEBUG_QuestTrace(self.m_TraceQuests == true);
end

function Swift:InitalizeDebugHotkeys()
    if Network.IsNATReady ~= nil and Framework.IsNetworkGame() then
        return;
    end
    if self.m_DevelopingCheats then
        KeyBindings_EnableDebugMode(1);
        KeyBindings_EnableDebugMode(2);
        KeyBindings_EnableDebugMode(3);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock", 1);
        self.m_GameClock = true;
    else
        KeyBindings_EnableDebugMode(0);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock", 0);
        self.m_GameClock = false;
    end
end

function Swift:InitalizeQsbDebugHotkeys()
    if Framework.IsNetworkGame() then
        return;
    end
    Input.KeyBindDown(Keys.ModifierControl + Keys.ModifierShift + Keys.ModifierAlt + Keys.R, "Swift:ExecuteQsbDebugHotkey('RestartMap')", 30, false);
end

function Swift:ExecuteQsbDebugHotkey(_Type)
    if self.m_DevelopingCheats then
        if _Type == 'RestartMap' then
            Camera.RTS_FollowEntity(0);
            Framework.RestartMap();
        end
    end
end

function Swift:InitalizeQsbDebugShell()
    if not Framework.IsNetworkGame() then
        GUI_Chat.Abort = function()
        end
    end

    GUI_Chat.Confirm = function()
        local MotherWidget = "/InGame/Root/Normal/ChatInput";
        XGUIEng.ShowWidget(MotherWidget, 0);
        local ChatMessage = XGUIEng.GetText("/InGame/Root/Normal/ChatInput/ChatInput");
        g_Chat.JustClosed = 1;
        if not Framework.IsNetworkGame() then
            Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
        end
        Input.GameMode();
        if ChatMessage:len() > 0 and Framework.IsNetworkGame() then
            if Swift.m_DevelopingShell then
                Swift.m_ChatBoxInput = ChatMessage;
            end
            GUI.SendChatMessage(ChatMessage, GUI.GetPlayerID(), g_Chat.CurrentMessageType, g_Chat.CurrentWhisperTarget);
        end
    end

    if not Framework.IsNetworkGame() then
        QSB_DEBUG_InputBoxJob = function()
            -- Not allowed
            if not Swift.m_DevelopingShell then
                return true;
            end
            if ModuleInputOutputCore then
                return true;
            end
            -- Call cheap version
            Swift.m_ProcessDebugCommands = true;
            Swift:DisplayQsbDebugShell();
        end
        Input.KeyBindDown(Keys.ModifierShift + Keys.OemPipe, "Swift:OpenQsbDebugShell()", 30, false);
    end
end

function Swift:OpenQsbDebugShell()
    -- Text input will only be evaluated in the original version of the game
    -- and in Singleplayer History Edition.
    if Network.IsNATReady ~= nil and Framework.IsNetworkGame() then
        return;
    end
    StartSimpleHiResJob('QSB_DEBUG_InputBoxJob');
end

function Swift:IsProcessDebugCommands()
    return self.m_ProcessDebugCommands;
end

function Swift:SetProcessDebugCommands(_Debug)
    self.m_ProcessDebugCommands = _Debug;
end

function Swift:DisplayQsbDebugShell()
    local MotherWidget = "/InGame/Root/Normal/ChatInput";
    if not self.m_DebugInputShown then
        Input.ChatMode();
        if not Framework.IsNetworkGame() then
            Game.GameTimeSetFactor(GUI.GetPlayerID(), 0);
        end
        XGUIEng.ShowWidget(MotherWidget, 1);
        XGUIEng.SetText(MotherWidget.. "/ChatInput", "");
        XGUIEng.SetFocus(MotherWidget.. "/ChatInput");
        self.m_DebugInputShown = true;
    elseif self.m_ChatBoxInput then
        self.m_ChatBoxInput = string.gsub(self.m_ChatBoxInput,"'","\'");
        self:ConfirmQsbDebugShell();
        GUI.SendScriptCommand([[
            Swift:DispatchScriptEvent(
                QSB.ScriptEvents.DebugChatConfirmed, 
                "]]..self.m_ChatBoxInput..[["
            );
        ]]);
        self:DispatchScriptEvent(
            QSB.ScriptEvents.DebugChatConfirmed,
            self.m_ChatBoxInput
        );
        self.m_ProcessDebugCommands = false;
        self.m_DebugInputShown = nil;
        return true;
    end
end

function Swift:ConfirmQsbDebugShell()
    if self:IsProcessDebugCommands() then
        if self.m_ChatBoxInput == "restartmap" then
            Framework.RestartMap();
        else
            if string.find(self.m_ChatBoxInput, "^> .*$") then
                GUI.SendScriptCommand(self.m_ChatBoxInput.sub(self.m_ChatBoxInput, 3), true);
            elseif string.find(self.m_ChatBoxInput, "^>> .*$") then
                GUI.SendScriptCommand(self.m_ChatBoxInput.sub(self.m_ChatBoxInput, 4), false);
            end
        end
    end
end

function Swift:BeginBenchmark(_Identifier)
    self.m_Benchmarks[_Identifier] = XGUIEng.GetSystemTime() * 1000;
end

function Swift:StopBenchmark(_Identifier)
    if self.m_Benchmarks[_Identifier] then
        local StartTime = self.m_Benchmarks[_Identifier];
        local EndTime = XGUIEng.GetSystemTime() * 1000;
        local ElapsedTime = EndTime - StartTime;
        self.m_Benchmarks[_Identifier] = nil;
        Framework.WriteToLog(string.format(
            "Benchmark '%s': Execution took %f ms to complete",
            _Identifier,
            ElapsedTime
        ));
    end
end

