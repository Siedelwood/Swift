-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnGraphVizIntegration                                     # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es die erstellten Quests als Diagramm darzustellen.
--
-- Das Diagramm wird in einer bestimmten Notation ins Log geschrieben. Diese
-- Notation heißt DOT. Um daraus ein Diagramm zu generieren, musst du
-- GraphViz installieren.
--
-- <h4>Installation von GraphViz</h4>
-- Befolge folgende Schritte, um GraphViz zu installieren:
-- <ol>
-- <li>
-- Lade die Release-Version von GraphViz für Windows 10 herunter.<br/>
-- <a target="_blank" href="https://www2.graphviz.org/Packages/stable/windows/10/msbuild/Release/Win32/">Download</a>
-- </li>
-- <li>
-- Entpacke den Ordner im Archiv in das Programmverzeichnis. Es existiert
-- dann folgendes Verzeichnis:
-- <pre>C:/Programme/GraphViz</pre>
-- </li>
-- <li>
-- Erweitere die PATH Variable um Folgenden Eintrag:
-- <pre>C:/Programme/GraphViz/bin</pre>
-- Starte deinen Rechner neu. Das ist nötig, damit die Änderung an PATH
-- wirksam wird.
-- </li>
-- <li>
-- Teste die Installation in der Eingabeaufforderung.
-- <pre>dot -v</pre>
-- Du solltes u.a. eine Version angezeigt bekommen.
-- <pre>dot - graphviz version 2.44.1 (20200629.0800)
--...</pre>
-- Drücke STRG + C um das Programm zu beenden.
-- </li>
-- </ol>
--
-- <h4>Diagramm mit GraphViz erzeugen</h4>
-- <ol>
-- <li>
-- Lasse zu einen beliebigen Zeitpunkt die Quests umwandeln.<br/>Siehe dazu
-- <a href="#API.ExportQuestsForGraphViz">API.ExportQuestsForGraphViz</a>.
-- </li>
-- <li>
-- Öffne nun die Log-Datei. Die Logs befinden sich in folgendem Verzeichnis:
-- <pre>C:\Users\BENUTZERNAME\Documents\DIE SIEDLER - Aufstieg eines Königreichs\Temp\Logs</pre>
-- </li>
-- <li>
-- Suche im Log nach GraphViz Export. Kopiere den "kryptischen Buchstabensalat"
-- innerhalb des markierten Bereichs in eine Datei (z.B. quests.dot).
-- Ein Log-Eintrag kann so aussehen:
-- <pre>==== GraphViz Export Start ====
--
-- digraph G { graph [    fontname = &quot;Helvetica-Oblique&quot;, fontsize = 30, label = &quot;total_awesome_map&quot; ] 
-- node [ fontname = &quot;Courier-Bold&quot; shape = &quot;box&quot; ] 
--     &quot;TestQuest_0&quot; [  label = &quot;TestQuest_0\n=== 2  -&gt;  1 ===\n\nGoal_InstantSuccess()\nTrigger_Time(5)&quot; ] 
--     &quot;TestQuest_0&quot; -&gt; &quot;TestQuest_1&quot; [color=&quot;#00ff00&quot;] 
--     &quot;TestQuest_1&quot; [  label = &quot;TestQuest_1\n=== 2  -&gt;  1 ===\n\nGoal_InstantSuccess()\nTrigger_OnQuestSuccessWait('TestQuest_0', 5)&quot; ] 
--     &quot;TestQuest_1&quot; -&gt; &quot;TestQuest_2&quot; [color=&quot;#00ff00&quot;] 
--     &quot;TestQuest_2&quot; [  label = &quot;TestQuest_2\n=== 2  -&gt;  1 ===\n\nGoal_InstantSuccess()\nTrigger_OnQuestSuccessWait('TestQuest_1', 5)&quot; ] 
--     &quot;TestQuest_2&quot; -&gt; &quot;TestQuest_3&quot; [color=&quot;#00ff00&quot;] 
--     &quot;TestQuest_3&quot; [  label = &quot;TestQuest_3\n=== 2  -&gt;  1 ===\n\nGoal_InstantSuccess()\nTrigger_OnQuestSuccessWait('TestQuest_2', 5)&quot; ] 
--     &quot;TestQuest_3&quot; -&gt; &quot;TestQuest_4&quot; [color=&quot;#00ff00&quot;] 
--     &quot;TestQuest_4&quot; [  label = &quot;TestQuest_4\n=== 2  -&gt;  1 ===\n\nGoal_InstantSuccess()\nTrigger_OnQuestSuccessWait('TestQuest_3', 5)&quot; ] 
--     &quot;TestQuest_4&quot; -&gt; &quot;TestQuest_5&quot; [color=&quot;#00ff00&quot;] 
--     &quot;TestQuest_5&quot; [  label = &quot;TestQuest_5\n=== 2  -&gt;  1 ===\n\nGoal_InstantSuccess()\nTrigger_OnQuestSuccessWait('TestQuest_4', 5)&quot; ]
-- } 
--
-- ==== GraphViz Export Ende ====</pre>
-- </li>
-- <li>
-- Führe folgenden Befehl zur Erzeugung des Diagrams in der Eingabeaufforderung
-- aus:
-- <pre>dot -Tjpg quests.dot > quests.jpg</pre>
-- Du solltest nun ein JPG im gleichen Verzeichnis vorfinden.
-- </li>
-- </ol>
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnGraphVizIntegration = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erzeugt aus allen Quests die DOT-Notation und schreibt sie ins Log. Aus
-- dem erzeugten Code können mit GraphViz Diagramme erstellt werden.
--
-- @param[type=boolean] _UseBreak Break in LuaDebugger auslösen
--
function API.ExportQuestsForGraphViz(_UseBreak)
    local DOT = AddOnGraphVizIntegration.Global:ExecuteGraphVizExport();
    -- Im LuaDebugger kann man das Diagramm dann aus der Variable kopieren.
    -- Alle anderen müssen ins Log gucken.
    if LuaDebugger and _UseBreak then
        LuaDebugger.Break();
    end
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnGraphVizIntegration = {
    Global =  {
        Data = {},
    },
    Local =  {
        Data = {},
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function AddOnGraphVizIntegration.Global:Install()
    QSB.GraphViz:Init();
end

---
-- Erstellt ein Diagramm und speichert es im Log File.
--
-- <b>Hinweis</b>: Das Diagramm ist in DOT geschrieben. Um daraus ein Diagramm
-- zu erzeugen, wird eine GraphViz installation benötigt.
-- 
-- @return[type=string] DOT-Notation
-- @within Internal
-- @local
--
function AddOnGraphVizIntegration.Global:ExecuteGraphVizExport()
    Framework.WriteToLog("\n\n\n==== GraphViz Export Start ====\n\n\n");
    local DOT = QSB.GraphViz:ConvertQuests();
    AddOnGraphVizIntegration.Global:WriteLinewiseToLog(DOT);
    Framework.WriteToLog("\n\n\n==== GraphViz Export Ende ====\n\n\n");
    return DOT;
end

---
-- Schreibt den übergebenen String zeilenweise ins Log. Eine Zeile wird durch
-- \n abgeschlossen.
-- 
-- @param[type=string] _String Log-Eintrag
-- @within Internal
-- @local
--
function AddOnGraphVizIntegration.Global:WriteLinewiseToLog(_String)
    local Slices = self:SplitString(_String);
    for i= 1, #Slices, 1 do
        Framework.WriteToLog(Slices[i]);
    end
end

---
-- Teilt einen String in Zeilen ein. Eine Zeile wird durch \n abgeschlossen.
-- 
-- @param[type=string] _String Log-Eintrag
-- @return[type=table] In Zeilen geteilter String
-- @within Internal
-- @local
--
function AddOnGraphVizIntegration.Global:SplitString(_String)
    local Table = {};
    local s, e = _String:find("\n");
    while e do
        table.insert(Table, _String:sub(1, e-1));
        _String = _String:sub(e+1);
        s, e = _String:find("\n");
    end
    table.insert(Table, _String);
    return Table;
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function AddOnGraphVizIntegration.Local:Install()
    -- Im lokalen Skript invalidieren, um Speicher zu sparen.
    QSB.GraphViz = nil;
end

-- -------------------------------------------------------------------------- --

QSB.GraphViz = {
    SourceFile = "",
    Quests = {}
}

---
-- Initialisiert den DOT-Parser. 
--
-- @within Internal
-- @local
--
function QSB.GraphViz:Init()
    API = API or {};
    CreateQuest_Orig_AddOnGraphVizIntegration = API.CreateQuest;
    API.CreateQuest = function(_Data)
        local QuestName, QuestAmount = CreateQuest_Orig_AddOnGraphVizIntegration(_Data);
        local Data = QSB.GraphViz:AddQuestDefaults(API.InstanceTable(_Data));
        QSB.GraphViz.Quests[#QSB.GraphViz.Quests+1] = Data;
        return QuestName, QuestAmount;
    end
    AddQuest = API.CreateQuest;
end

---
-- Ergänzt die Questdaten um Defaultwerte.
--
-- @param[type=table] _Data Questdaten
-- @return[type=table] Questdaten um Defaults ergänzt
-- @within Internal
-- @local
--
function QSB.GraphViz:AddQuestDefaults(_Data)
    _Data.Sender        = _Data.Sender or 1;
    _Data.Receiver      = _Data.Receiver or 1;
    _Data.Time          = _Data.Time or 0;
    _Data.Visible       = (_Data.Visible == true or _Data.Suggestion ~= nil);
    _Data.EndMessage    = _Data.EndMessage == true or (_Data.Failure ~= nil or _Data.Success ~= nil);
    if _Data.Suggestion then
        _Data.Suggestion = API.Localize(_Data.Suggestion);
    end
    if _Data.Success then
        _Data.Success = API.Localize(_Data.Success);
    end
    if _Data.Failure then
        _Data.Failure = API.Localize(_Data.Failure);
    end
    if _Data.Description then
        _Data.Description = API.Localize(_Data.Description);
    end
    return _Data;
end

---
-- Erzeugt einen Graph aus allen vorhandenen Quests.
--
-- @return[type=string] GraphViz Output
-- @within Internal
-- @local
--
function QSB.GraphViz:ConvertQuests()
    local MapName = Framework.GetCurrentMapName();
    local DOT = "";
    DOT = DOT .. '\ndigraph G { graph [    fontname = "Helvetica-Oblique", fontsize = 30, label = "'..MapName.. '" ] \nnode [ fontname = "Courier-Bold" shape = "box" ] \n';
    for i= 1, #QSB.GraphViz.Quests, 1 do
        for k, v in pairs(QSB.GraphViz:ConvertQuest(QSB.GraphViz.Quests[i])) do 
            DOT = DOT .. "    " .. v .. " \n";
        end
    end
    DOT = DOT .. '} \n';
    return DOT;
end

---
-- Erzeug DOT-Notation zum übergebenen Quest.
--
-- <b>TODO</b>: Diese Methode ist absolut grottiger Code aus tiefster
-- Siedler-6-Urzeit. Das muss unbedingt mal auseinander gezogen und in
-- guter Code Qualität neu geschrieben werden!
--
-- @param[type=table] _Quest Zu visualisierender Quest
-- @return[type=string] GraphViz Output
-- @within Internal
-- @local
--
function QSB.GraphViz:ConvertQuest(_Quest)
    local result = {};
    local ArrowColorTable = {
        Succeed = 'color="#00ff00"',
        Fail = 'color="#ff0000"',
        Interrupt = 'color="#999999"',
        Default = 'color="#0000ff"'
    };
    local function EscapeString( _String )
        return string.match( string.format( "%q", tostring(_String) ), '^"(.*)"$' ) or "nil";
    end
    local function LimitString( _String, _Limit )
        assert( _String );
        assert( _Limit > 3 );
        if string.len( _String ) <= _Limit then
            return _String;
        else
            return string.sub( _String, 1, _Limit - 3 ) .. "...";
        end
    end

    local fontColor = ""
    local BehaviorList = {}
    local bTableCounter = 0    
    for i= 1, #_Quest, 1 do
        local BehaviorName = _Quest[i].Name;
        local ArrowColor = (string.find( BehaviorName, "Succe" ) and ArrowColorTable.Succeed)
                or (string.find( BehaviorName, "Fail" )and ArrowColorTable.Fail)
                or (string.find( BehaviorName, "Interrupt" )and ArrowColorTable.Interrupt)
                or ArrowColorTable.Default;
        local fontColor = (string.find( BehaviorName, "Wait" ) and 'fontcolor="red"') or "";
        local BDependsOn = string.find(BehaviorName, "Goal") ~= nil or string.find(BehaviorName, "Trigger") ~= nil;

        local BehaviorData = _Quest[i].Name .. "(";
        if _Quest[i].Parameter then
            for j= 1, #_Quest[i].Parameter do
                if (j > 1) then
                    BehaviorData = BehaviorData .. ", ";
                end
                local Parameter = "nil";
                if _Quest[i].v12ya_gg56h_al125[j] then
                    Parameter =_Quest[i].v12ya_gg56h_al125[j];
                    if type(Parameter) == "string" then
                        Parameter = "'" ..Parameter.. "'";
                    end
                end
                BehaviorData = BehaviorData .. tostring(Parameter);
                
                if (_Quest[i].Parameter[j][1] == ParameterType.QuestName) then
                    table.insert(
                        result,
                        (BDependsOn and string.format(
                            '%q -> %q [%s]',
                            _Quest[i].v12ya_gg56h_al125[j],
                            _Quest.Name,
                            ArrowColor
                        )) or 
                        string.format(
                            '%q -> %q [%s, arrowhead = "odot", arrowtail = "invempty" style="dashed"]',
                            _Quest.Name,
                            _Quest[i].QuestName,
                            ArrowColor
                        )
                    );
                end
            end
        end
        BehaviorData = BehaviorData .. ")";
        table.insert(BehaviorList, BehaviorData);
    end

    local Desc = EscapeString(LimitString(_Quest.Description or "", 80));
    Desc = (Desc ~= "" and "\\nDescription: '" ..Desc.. "'") or "";
    local Sugg = EscapeString(LimitString(_Quest.Suggestion or "", 80));
    Sugg = (Sugg ~= "" and "\\nSuggestion: '" ..Sugg.. "'") or "";
    local Fail = EscapeString(LimitString(_Quest.Failure or "", 80));
    Fail = (Fail ~= "" and "\\nFailure: '" ..Fail.. "'") or "";
    local Succ = EscapeString(LimitString(_Quest.Success or "", 80));
    Succ = (Succ ~= "" and "\\nSuccess: '" ..Succ.. "'") or "";

    local SenderReceiver = "\\n=== " .._Quest.Sender.."  ->  " .._Quest.Receiver.. " ===";
    table.sort(BehaviorList);
    table.insert(result, string.format(
        '%q [ %s label = "%s%s%s%s%s%s%s\\n\\n%s" %s%s]',
        _Quest.Name,
        fontColor,
        EscapeString(_Quest.Name),
        SenderReceiver,
        Sugg,
        Fail,
        Succ,
        Desc,
        _Quest.Time ~= 0 and ('\\nTime: ' .. _Quest.Time) or '',
        table.concat(BehaviorList, "\\n"),
        _Quest.Time ~= 0 and 'shape="octagon" ' or '',
        not _Quest.Visible and 'style="filled" fillcolor="#dddddd" ' or '' )
    );
    return result;
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("AddOnGraphVizIntegration");

