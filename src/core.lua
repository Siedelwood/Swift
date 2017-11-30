-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Synfonia Core                                                         # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Die Hauptaufgabe des Framework ist es, Funktionen zur Installation und der
-- Verwaltung der einzelnen Bundles bereitzustellen. Bundles sind in sich
-- geschlossene Module, die wenig bis gar keine Abhänigkeiten haben. Damit
-- das funktioniert, muss das Framework auch allgemeingültige Funktionen
-- bereitstellen, auf die Bundles aufbauen können.
--
-- Im Framework werden zudem überschriebene Spielfunktionen angelegt und so
-- aufbereitet, dass Bundles ihre Inhalte einfach ergänzen können. Dies wird
-- jedoch nicht für alle Funktionen des Spiels möglich sein.
--
-- Wie die einzelnen Bundles ist auch das Framework in einen User- und einen
-- Application-Space aufgeteilt. Der User-Space enthält Funktionen innerhalb
-- der Bibliothek "API". Alle Bundles ergänzen ihre User-Space-Funktionen dort.
-- Außer den Aliases auf API-Funktionen und den Behavior-Funktionen sind keine
-- anderen öffentlichen Funktionen für den Anwendern sichtbar zu machen!
--
-- Im Application-Space liegen die privaten Funktionen und Variablen, die
-- nicht in der Dokumentation erscheinen. Sie sind mit einem Local-Tag zu
-- versehen! Der Nutzer soll diese Funktionen in der Regel nicht anfassen,
-- daher muss er auch nicht wissen, dass es sie gibt!
--
-- Ziel der Teilung zwischen User-Space und Application-Space ist es, dem
-- Anwender eine saubere und leicht verständliche Oberfläche zu Bieten, mit
-- der er einfach arbeiten kann. Kenntnis über die komplexen Prozesse hinter
-- den Kulissen sind dafür nicht notwendig.
--
-- @module Core
--

API = API or {};
QSB = QSB or {};

ParameterType = ParameterType or {};
g_QuestBehaviorVersion = 1;
g_QuestBehaviorTypes = {};

---
-- AddOn Versionsnummer
-- @local
--
g_GameExtraNo = 0;
if Framework then
    g_GameExtraNo = Framework.GetGameExtraNo();
elseif MapEditor then
    g_GameExtraNo = MapEditor.GetGameExtraNo();
end

-- -------------------------------------------------------------------------- --
-- User Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Initialisiert alle verfügbaren Bundles und führt ihre Install-Methode aus.
--
-- Bundles werden immer getrennt im globalen und im lokalen Skript gestartet.
-- Diese Funktion muss zwingend im globalen und lokalen Skript ausgeführt
-- werden, bevor die QSB verwendet werden kann.
--
function API.Install()
    Core:InitalizeBundles();
end

-- Tables --------------------------------------------------------------------

---
-- Kopiert eine komplette Table und gibt die Kopie zurück. Wenn ein Ziel
-- angegeben wird, ist die zurückgegebene Table eine vereinigung der 2
-- angegebenen Tables.
-- Die Funktion arbeitet rekursiv und ist für beide Arten von Index. Die
-- Funktion kann benutzt werden, um Klassen zu instanzieren.
--
-- Alias: CopyTableRecursive
--
-- @param _Source    Quelltabelle
-- @param _Dest      Zieltabelle
-- @return Kopie der Tabelle
-- @within Table-Funktionen
-- @usage Table = {1, 2, 3, {a = true}}
-- Copy = API.InstanceTable(Table)
--
function API.InstanceTable(_Source, _Dest)
    _Dest = _Dest or {};
    for k, v in pairs(_Source) do
        _Dest[k] = (type(v) == "table" and API.InstanceTable(v)) or v;
    end
    return _Dest;
end
CopyTableRecursive = API.InstanceTable;

---
-- Sucht in einer Table nach einem Wert. Das erste Aufkommen des Suchwerts
-- wird als Erfolg gewertet.
--
-- Alias: Inside
--
-- @param _Data     Datum, das gesucht wird
-- @param _Table    Tabelle, die durchquert wird
-- @return booelan: Wert gefunden
-- @within Table-Funktionen
-- @usage Table = {1, 2, 3, {a = true}}
-- local Found = API.TraverseTable(3, Table)
--
function API.TraverseTable(_Data, _Table)
    for k,v in pairs(_Table) do
        if v == _Data then
            return true;
        end
    end
    return false;
end
Inside = API.TraverseTable;

---
-- Schreibt ein genaues Abbild der Table ins Log. Funktionen, Threads und
-- Metatables werden als Adresse geschrieben.
--
-- @param _Table Tabelle, die gedumpt wird
-- @param _Name Optionaler Name im Log
-- @within Table-Funktionen
-- @usage Table = {1, 2, 3, {a = true}}
-- API.DumpTable(Table)
--
function API.DumpTable(_Table, _Name)
    local Dump = "{\n";
    if _Name then
        Dump = _Name.. " = " ..Dump;
    end
    for k, f in pairs(_Table) do
        if type(v) == "table" then
            Dump = Dump.. "[" ..k.. "] = " .. API.DumpTable(v);
        elseif type(v) == "string" then
            Dump = Dump.. "[" ..k.. "] = \"" ..v.. "\"\n";
        else
            Dump = Dump.. "[" ..k.. "] = " ..tostring(v).. "\n";
        end
    end
    Dump = Dump.. "}\n";

    API.Log("Dump of Table:")
    Framework.WriteToLog(Dump);
end

-- Quests ----------------------------------------------------------------------

---
-- Gibt die ID des Quests mit dem angegebenen Namen zurück. Existiert der
-- Quest nicht, wird nil zurückgegeben.
--
-- Alias: GetQuestID
--
-- @param _Name     Identifier des Quest
-- @return number: ID des Quest
-- @within Quest-Funktionen
--
function API.GetQuestID(_Name)
    for i=1, Quests[0] do
        if Quests[i].Identifier == _Name then
            return i;
        end
    end
end
GetQuestID = API.GetQuestID;

---
-- Prüft, ob die ID zu einem Quest gehört bzw. der Quest existiert. Es kann
-- auch ein Questname angegeben werden.
--
-- Alias: IsValidQuest
--
-- @param _QuestID   ID oder Name des Quest
-- @return boolean: Quest existiert
-- @within Quest-Funktionen
--
function API.IsValidateQuest(_QuestID)
    return Quests[_QuestID] ~= nil or Quests[self:GetQuestID(_QuestID)] ~= nil;
end
IsValidQuest = API.IsValidateQuest;

---
-- Lässt eine Liste von Quests fehlschlagen.
--
-- Der Status wird auf Over und das Resultat auf Failure gesetzt.
--
-- Alias: FailQuestsByName
--
-- @param ...  Liste mit Quests
-- @within Quest-Funktionen
--
function API.FailAllQuests(...)
    for i=1, #args, 1 do
        API.FailQuest(args[i]);
    end
end
FailQuestsByName = API.FailAllQuests;

---
-- Lässt den Quest fehlschlagen.
--
-- Der Status wird auf Over und das Resultat auf Failure gesetzt.
--
-- Alias: FailQuestByName
--
-- @param _QuestName  Name des Quest
-- @within Quest-Funktionen
--
function API.FailQuest(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if Quest.RemoveNPCMarkers then
            Quest:RemoveNPCMarkers();
        end
        Quest:RemoveQuestMarkers();
        Quest:Fail();
    end
end
FailQuestByName = API.FailQuest;

---
-- Startet eine Liste von Quests neu.
--
-- Alias: StartQuestsByName
--
-- @param ...  Liste mit Quests
-- @within Quest-Funktionen
--
function API.RestartAllQuests(...)
    for i=1, #args, 1 do
        API.RestartQuest(args[i]);
    end
end
StartQuestsByName = API.RestartAllQuests;

---
-- Startet den Quest neu.
--
-- Der Quest muss beendet sein um ihn wieder neu zu starten. Wird ein Quest
-- neu gestartet, müssen auch alle Trigger wieder neu ausgelöst werden, außer
-- der Quest wird manuell getriggert.
--
-- Alias: StartQuestByName
--
-- @param _QuestName  Name des Quest
-- @within Quest-Funktionen
--
function API.RestartQuest(_QuestName)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if Quest.Objectives then
            local questObjectives = Quest.Objectives;
            for i = 1, questObjectives[0] do
                local objective = questObjectives[i];
                objective.Completed = nil
                local objectiveType = objective.Type;
                if objectiveType == Objective.Deliver then
                    local data = objective.Data;
                    data[3] = nil
                    data[4] = nil
                    data[5] = nil
                elseif g_GameExtraNo and g_GameExtraNo >= 1 and objectiveType == Objective.Refill then
                    objective.Data[2] = nil
                elseif objectiveType == Objective.Protect or objectiveType == Objective.Object then
                    local data = objective.Data;
                    for j=1, data[0], 1 do
                        data[-j] = nil
                    end
                elseif objectiveType == Objective.DestroyEntities and objective.Data[1] ~= 1 and objective.DestroyTypeAmount then
                    objective.Data[3] = objective.DestroyTypeAmount;

                elseif objectiveType == Objective.Distance then
                    if objective.Data[1] == -65565 then
                        objective.Data[4].NpcInstance = nil;
                    end

                elseif objectiveType == Objective.Custom2 and objective.Data[1].Reset then
                    objective.Data[1]:Reset(Quest, i)
                end
            end
        end
        local function resetCustom(_type, _customType)
            local Quest = Quest;
            local behaviors = Quest[_type];
            if behaviors then
                for i = 1, behaviors[0] do
                    local behavior = behaviors[i];
                    if behavior.Type == _customType then
                        local behaviorDef = behavior.Data[1];
                        if behaviorDef and behaviorDef.Reset then
                            behaviorDef:Reset(Quest, i);
                        end
                    end
                end
            end
        end

        resetCustom("Triggers", Triggers.Custom2);
        resetCustom("Rewards", Reward.Custom);
        resetCustom("Reprisals", Reprisal.Custom);

        Quest.Result = nil
        local OldQuestState = Quest.State
        Quest.State = QuestState.NotTriggered
        Logic.ExecuteInLuaLocalState("LocalScriptCallback_OnQuestStatusChanged("..Quest.Index..")")
        if OldQuestState == QuestState.Over then
            Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", QuestTemplate.Loop, 1, 0, { Quest.QueueID })
        end
        return QuestID, Quest;
    end
end
StartQuestByName = API.StartQuest;

---
-- Startet eine Liste von Quests.
--
-- Alias: StartQuestsByName
--
-- @param ...  Liste mit Quests
-- @within Quest-Funktionen
--
function API.StartAllQuests(...)
    for i=1, #args, 1 do
        API.StartQuest(args[i]);
    end
end
StartQuestsByName = API.StartAllQuests;

---
-- Startet den Quest sofort, sofern er existiert.
--
-- Dabei ist es unerheblich, ob die Bedingungen zum Start erfüllt sind.
--
-- Alias: StartQuestByName
--
-- @param _QuestName  Name des Quest
-- @within Quest-Funktionen
--
function API.StartQuest(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        Quest:SetMsgKeyOverride();
        Quest:SetIconOverride();
        Quest:Trigger();
    end
end
StartQuestByName = API.StartQuest;

---
-- Unterbricht eine Liste von Quests.
--
-- Alias: StopQuestsByName
--
-- @param ...  Liste mit Quests
-- @within Quest-Funktionen
--
function API.StopAllQuests(...)
    for i=1, #args, 1 do
        API.StopQuest(args[i]);
    end
end
StopQuestwByName = API.StopAllQuests;

---
-- Unterbricht den Quest.
--
-- Der Status wird auf Over und das Resultat auf Interrupt gesetzt. Sind Marker
-- gesetzt, werden diese entfernt.
--
-- Alias: StopQuestByName
--
-- @param _QuestName  Name des Quest
-- @within Quest-Funktionen
--
function API.StopQuest(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if Quest.RemoveNPCMarkers then
            Quest:RemoveNPCMarkers();
        end
        Quest:RemoveQuestMarkers();
        Quest:Interrupt(-1);
    end
end
StopQuestByName = API.StopQuest;

---
-- Gewinnt eine Liste von Quests.
--
-- Der Status wird auf Over und das Resultat auf Success gesetzt.
--
-- Alias: WinQuestsByName
--
-- @param ...  Liste mit Quests
-- @within Quest-Funktionen
--
function API.WinAllQuests(...)
    for i=1, #args, 1 do
        API.WinQuest(args[i]);
    end
end
WinQuestsByName = API.WinAllQuests;

---
-- Gewinnt den Quest.
--
-- Der Status wird auf Over und das Resultat auf Success gesetzt.
--
-- Alias: WinQuestByName
--
-- @param _QuestName  Name des Quest
-- @within Quest-Funktionen
--
function API.WinQuest(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if Quest.RemoveNPCMarkers then
            Quest:RemoveNPCMarkers();
        end
        Quest:RemoveQuestMarkers();
        Quest:Success();
    end
end
WinQuestByName = API.WinQuest;

-- Messages --------------------------------------------------------------------

---
-- Schreibt eine Nachricht in das Debug Window. Der Text erscheint links am
-- Bildschirm und ist nicht statisch.
--
-- Alias: GUI_Note
--
-- @param _Message Anzeigetext
-- @within Message-Funktionen
--
function API.Note(_Message)
    _Message = tostring(_Message);
    local MessageFunc = Logic.DEBUG_AddNote;
    if GUI then
        MessageFunc = GUI.AddNote;
    end
    MessageFunc(_Message);
end
GUI_Note = API.Note;

---
-- Schreibt eine Nachricht in das Debug Window. Der Text erscheint links am
-- Bildschirm und verbleibt dauerhaft am Bildschirm.
--
-- @param _Message Anzeigetext
-- @within Message-Funktionen
--
function API.StaticNote(_Message)
    _Message = tostring(_Message);
    if not GUI then
        Logic.ExecuteInLuaLocalState('GUI.AddStaticNote("' .._Message.. '")');
        return;
    end
    GUI.AddStaticNote(_Message);
end

---
-- Löscht alle Nachrichten im Debug Window.
--
-- @within Message-Funktionen
--
function API.ClearNotes()
    if not GUI then
        Logic.ExecuteInLuaLocalState('GUI.ClearNotes()');
        return;
    end
    GUI.ClearNotes();
end

---
-- Schreibt eine einzelne Zeile Text ins Log. Vor dem Text steh, ob aus dem
-- globalen oder lokalen Skript geschrieben wurde und bei welchem Turn des
-- Spiels die Nachricht gesendet wurde.
--
-- @param _Message Nachricht für's Log
-- @within Message-Funktionen
--
function API.Log(_Message)
    local Env  = (GUI and "Local") or "Global";
    local TUrn = Logic.GetTimeMs();
    Framework.WriteToLog(Env.. ":" ..Turn.. ": " .._Message);
end

---
-- Schreibt eine Nachricht in das Nachrichtenfenster unten in der Mitte.
--
-- @param _Message Anzeigetext
-- @within Message-Funktionen
--
function API.Message(_Message)
    _Message = tostring(_Message);
    if not GUI then
        Logic.ExecuteInLuaLocalState('Message("' .._Message.. '")');
        return;
    end
    Message(_Message);
end

---
-- Schreibt eine Fehlermeldung auf den Bildschirm und ins Log.
--
-- @param _Message Anzeigetext
-- @within Message-Funktionen
--
function API.Dbg(_Message)
    API.StaticNote("DEBUG: " .._Message)
    API.Log("DEBUG: " .._Message);
end
dbg = API.Dbg;

---
-- Schreibt eine Warnungsmeldung auf den Bildschirm und ins Log.
--
-- @param _Message Anzeigetext
-- @within Message-Funktionen
--
function API.Warn(_Message)
    API.StaticNote("WARNING: " .._Message)
    API.Log("WARNING: " .._Message);
end
warn = API.Warn;

-- Entities --------------------------------------------------------------------

---
-- Sendet einen Handelskarren zu dem Spieler. Startet der Karren von einem
-- Gebäude, wird immer die Position des Eingangs genommen.
--
-- Alias: SendCart
--
-- @param _position            Position
-- @param _player              Zielspieler
-- @param _good                Warentyp
-- @param _amount              Warenmenge
-- @param _cartOverlay         (optional) Overlay für Goldkarren
-- @param _ignoreReservation   (optional) Marktplatzreservation ignorieren
-- @return number: Entity-ID des erzeugten Wagens
-- @within Entity-Funktionen
-- @usage -- API-Call
-- API.SendCart(Logic.GetStoreHouse(1), 2, Goods.G_Grain, 45)
-- -- Legacy-Call mit ID-Speicherung
-- local ID = SendCart("Position_1", 5, Goods.G_Wool, 5)
--
function API.SendCart(_position, _player, _good, _amount, _cartOverlay, _ignoreReservation)
    local eID = GetID(_position);
    if not IsExisting(eID) then
        return;
    end
    local ID;
    local x,y,z = Logic.EntityGetPos(eID);
    local resCat = Logic.GetGoodCategoryForGoodType(_good);
    local orientation = 0;
    if Logic.IsBuilding(eID) == 1 then
        x,y = Logic.GetBuildingApproachPosition(eID);
        orientation = Logic.GetEntityOrientation(eID)-90;
    end

    if resCat == GoodCategories.GC_Resource then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_ResourceMerchant, x, y,orientation,_player)
    elseif _good == Goods.G_Medicine then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Medicus, x, y,orientation,_player)
    elseif _good == Goods.G_Gold then
        if _cartOverlay then
            ID = Logic.CreateEntityOnUnblockedLand(_cartOverlay, x, y,orientation,_player)
        else
            ID = Logic.CreateEntityOnUnblockedLand(Entities.U_GoldCart, x, y,orientation,_player)
        end
    else
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Marketer, x, y,orientation,_player)
    end
    Logic.HireMerchant( ID, _player, _good, _amount, _player, _ignoreReservation)
    return ID
end
SendCart = API.SendCart;

---
-- Ersetzt ein Entity mit einem neuen eines anderen Typs. Skriptname,
-- Rotation, Position und Besitzer werden übernommen.
--
-- Alias: ReplaceEntity
--
-- @param _Entity     Entity
-- @param _Type       Neuer Typ
-- @param _NewOwner   (optional) Neuer Besitzer
-- @return number: Entity-ID des Entity
-- @within Entity-Funktionen
-- @usage API.ReplaceEntity("Stein", Entities.XD_ScriptEntity)
--
function API.ReplaceEntity(_Entity, _Type, _NewOwner)
    local eID = GetID(_Entity);
    if eID == 0 then
        return;
    end
    local pos = GetPosition(eID);
    local player = _NewOwner or Logic.EntityGetPlayer(eID);
    local orientation = Logic.GetEntityOrientation(eID);
    local name = Logic.GetEntityName(eID);
    DestroyEntity(eID);
    if Logic.IsEntityTypeInCategory(_Type, EntityCategories.Soldier) == 1 then
        return CreateBattalion(player, _Type, pos.X, pos.Y, 1, name, orientation);
    else
        return CreateEntity(player, _Type, pos, name, orientation);
    end
end
ReplaceEntity = API.ReplaceEntity;

---
-- Rotiert ein Entity, sodass es zum Ziel schaut.
--
-- Alias: LookAt
--
-- @param _entity           Entity
-- @param _entityToLookAt   Ziel
-- @param _offsetEntity     Winkel-Offset
-- @within Entity-Funktionen
-- @usage API.LookAt("Hakim", "Alandra")
--
function API.LookAt(_entity, _entityToLookAt, _offsetEntity)
    local entity = GetEntityId(_entity);
    local entityTLA = GetEntityId(_entityToLookAt);
    assert( not (Logic.IsEntityDestroyed(entity) or Logic.IsEntityDestroyed(entityTLA)), "LookAt: One Entity is wrong or dead");
    local eX, eY = Logic.GetEntityPosition(entity);
    local eTLAX, eTLAY = Logic.GetEntityPosition(entityTLA);
    local orientation = math.deg( math.atan2( (eTLAY - eY) , (eTLAX - eX) ) );
    if Logic.IsBuilding(entity) then
        orientation = orientation - 90;
    end
    _offsetEntity = _offsetEntity or 0;
    Logic.SetOrientation(entity, orientation + _offsetEntity);
end
LookAt = API.LookAt;

---
-- Lässt zwei Entities sich gegenseitig anschauen.
--
-- @param _entity           Erstes Entity
-- @param _entityToLookAt   Zweites Entity
-- @within Entity-Funktionen
-- @usage API.Confront("Hakim", "Alandra")
--
function API.Confront(_entity, _entityToLookAt)
    API.LookAt(_entity, _entityToLookAt);
    API.LookAt(_entityToLookAt, _entity);
end

---
-- Bestimmt die Distanz zwischen zwei Punkten. Es können Entity-IDs,
-- Skriptnamen oder Positionstables angegeben werden.
--
-- Alias: GetDistance
-- 
-- @param _pos1 Erste Vergleichsposition
-- @param _pos2 Zweite Vergleichsposition
-- @return number: Entfernung zwischen den Punkten
-- @within Entity-Funktionen
-- @usage local Distance = API.GetDistance("HQ1", Logic.GetKnightID(1))
--
function API.GetDistance( _pos1, _pos2 )
    _pos1 = ((type(_pos1) == "string" or type(_pos1) == "number") and _pos1) or GetPosition(_pos1);
    _pos2 = ((type(_pos2) == "string" or type(_pos2) == "number") and _pos2) or GetPosition(_pos2);
    if type(_pos1) ~= "table" or type(_pos2) ~= "table" then
        return;
    end
    return math.sqrt(((_pos1.X - _pos2.X)^2) + ((_pos1.Y - _pos2.Y)^2));
end
GetDistance = API.GetDistance;

---
-- Lokalisiert ein Entity auf der Map. Es können sowohl Skriptnamen als auch
-- IDs verwendet werden. Wenn das Entity nicht gefunden wird, wird eine
-- Tabelle mit XYZ = 0 zurückgegeben.
--
-- Alias: GetPosition
--
-- @param _Entity   Entity, dessen Position bestimmt wird.
-- @return table: Positionstabelle {X= x, Y= y, Z= z}
-- @within Entity-Funktionen
-- @usage local Position = API.LocateEntity("Hans")
--
function API.LocateEntity(_Entity)
    if (type(_Entity) == "table") then
        return _Entity;
    end
    if (not IsExisting(_Entity)) then
        return {X= 0, Y= 0, Z= 0};
    end
    local x, y, z = Logic.EntityGetPos(GetID(_Entity));
    return {X= x, Y= y, Z= z};
end
GetPosition = API.LocateEntity;

---
-- Aktiviert ein interaktives Objekt, sodass es benutzt werden kann.
-- 
-- Der State bestimmt, ob es immer aktiviert werden kann, oder ob der Spieler
-- einen Helden benutzen muss. Wird der Parameter weggelassen, muss immer ein
-- Held das Objekt aktivieren. 
--
-- Alias: InteractiveObjectActivate
--
-- @param _ScriptName  Skriptname des IO
-- @param _State       Aktivierungszustand
-- @within Entity-Funktionen
-- @useage API.AcrivateIO("Haus1", 0)
-- @usage API.AcrivateIO("Hut1")
--
function API.AcrivateIO(eName, State)
    State = State or 0;
    if GUI then
        GUI.SendScriptCommand('API.AcrivateIO("' .._ScriptName.. '", ' ..State..')');
        return;
    end
    if not IsExisting(eName) then
        return
    end
    Logic.InteractiveObjectSetAvailability(GetID(eName), true);
    for i = 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(eName), i, State);
    end
end
InteractiveObjectActivate = API.AcrivateIO;

---
-- Deaktiviert ein Interaktives Objekt, sodass es nicht mehr vom Spieler
-- aktiviert werden kann.
--
-- Alias: InteractiveObjectDeactivate
--
-- @param _ScriptName Skriptname des IO
-- @within Entity-Funktionen
-- @usage API.DeactivateIO("Hut1")
--
function API.DeactivateIO(_ScriptName)
    if GUI then
        GUI.SendScriptCommand('API.DeactivateIO("' .._ScriptName.. '")');
        return;
    end
    if not IsExisting(_ScriptName) then
        return;
    end
    Logic.InteractiveObjectSetAvailability(GetID(_ScriptName), false);
    for i = 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), i, 2);
    end
end
InteractiveObjectDeactivate = API.DeactivateIO;

---
-- Ermittelt alle Entities in der Kategorie auf dem Territorium und gibt
-- sie als Liste zurück.
--
-- @param _player    PlayerID [0-8] oder -1 für alle
-- @param _category  Kategorie, der die Entities angehören
-- @param _territory Zielterritorium
-- @within Entity-Funktionen
-- @usage local Found = API.GetEntitiesOfCategoryInTerritory(1, EntityCategories.Hero, 5)
--
function API.GetEntitiesOfCategoryInTerritory(_player, _category, _territory)
    local PlayerEntities = {};
    local Units = {};
    if (_player == -1) then
        for i=0,8 do
            local NumLast = 0;
            repeat
                Units = { Logic.GetEntitiesOfCategoryInTerritory(_territory, i, _category, NumLast) };
                PlayerEntities = Array_Append(PlayerEntities, Units);
                NumLast = NumLast + #Units;
            until #Units == 0;
        end
    else
        local NumLast = 0;
        repeat
            Units = { Logic.GetEntitiesOfCategoryInTerritory(_territory, _player, _category, NumLast) };
            PlayerEntities = Array_Append(PlayerEntities, Units);
            NumLast = NumLast + #Units;
        until #Units == 0;
    end
    return PlayerEntities;
end

-- Overwrite -------------------------------------------------------------------

---
-- Hängt eine Funktion an Mission_OnSaveGameLoaded an, sodass sie nach dem
-- Laden eines Spielstandes ausgeführt wird.
--
-- @param _Function Funktion, die ausgeführt werden soll
-- @within Overwrite-Funktionen
-- @usage SaveGame = function()
--     API.Note("foo")
-- end
-- API.AddSaveGameAction(SaveGame)
--
function API.AddSaveGameAction(_Function)
    return Core:AppendFunction("Mission_OnSaveGameLoaded", _Function)
end

-- -------------------------------------------------------------------------- --
-- Application Space                                                          --
-- -------------------------------------------------------------------------- --

Core = {
    Data = {
        Append = {
            Functions = {},
            Fields = {},
        },
    }
}

---
-- Initialisiert alle verfügbaren Bundles und führt ihre Install-Methode aus.
-- Bundles werden immer getrennt im globalen und im lokalen Skript gestartet.
-- @within Core Class
-- @local
--
function Core:InitalizeBundles()
    if not GUI then
        self:SetupGobal_HackCreateQuest();
        self:SetupGlobal_HackQuestSystem();
    end
    
    for k,v in pairs(self.Data.BundleInitializerList) do
        if not GUI then
            if v.Global ~= nil and v.Global.Install ~= nil then
                v.Global:Install();
            end
        else
            if v.Local ~= nil and v.Local.Install ~= nil then
                v.Local:Install();
            end
        end
    end
end

---
-- FIXME
-- @within Initialisierer-Funktionen
-- @local
--
function Core:SetupGobal_HackCreateQuest()
    CreateQuest = function(_QuestName, _QuestGiver, _QuestReceiver, _QuestHidden, _QuestTime, _QuestDescription, _QuestStartMsg, _QuestSuccessMsg, _QuestFailureMsg)
        local Triggers = {}
        local Goals = {}
        local Reward = {}
        local Reprisal = {}
        local NumberOfBehavior = Logic.Quest_GetQuestNumberOfBehaviors(_QuestName)
        for i=0,NumberOfBehavior-1 do
            local BehaviorName = Logic.Quest_GetQuestBehaviorName(_QuestName, i)
            local BehaviorTemplate = GetBehaviorTemplateByName(BehaviorName)
            assert( BehaviorTemplate, "No template for name: " .. BehaviorName .. " - using an invalid QuestSystemBehavior.lua?!" )
            local NewBehavior = {}
            Table_Copy(NewBehavior, BehaviorTemplate)
            local Parameter = Logic.Quest_GetQuestBehaviorParameter(_QuestName, i)
            for j=1,#Parameter do
                NewBehavior:AddParameter(j-1, Parameter[j])
            end
            if (NewBehavior.GetGoalTable ~= nil) then
                Goals[#Goals + 1] = NewBehavior:GetGoalTable()
                Goals[#Goals].Context = NewBehavior
                Goals[#Goals].FuncOverrideIcon = NewBehavior.GetIcon
                Goals[#Goals].FuncOverrideMsgKey = NewBehavior.GetMsgKey
            end
            if (NewBehavior.GetTriggerTable ~= nil) then
                Triggers[#Triggers + 1] = NewBehavior:GetTriggerTable()
            end
            if (NewBehavior.GetReprisalTable ~= nil) then
                Reprisal[#Reprisal + 1] = NewBehavior:GetReprisalTable()
            end
            if (NewBehavior.GetRewardTable ~= nil) then
                Reward[#Reward + 1] = NewBehavior:GetRewardTable()
            end
        end
        if (#Triggers == 0) or (#Goals == 0) then
            return
        end
        if ValidateQuestName(_QuestName) then
            local QuestID = QuestTemplate:New(_QuestName, _QuestGiver, _QuestReceiver,
                                                    Goals,
                                                    Triggers,
                                                    assert( tonumber(_QuestTime) ),
                                                    Reward,
                                                    Reprisal,
                                                    nil, nil,
                                                    (not _QuestHidden or ( _QuestStartMsg and _QuestStartMsg ~= "") ),
                                                    (not _QuestHidden or ( _QuestSuccessMsg and _QuestSuccessMsg ~= "") or ( _QuestFailureMsg and _QuestFailureMsg ~= "") ),
                                                    _QuestDescription, _QuestStartMsg, _QuestSuccessMsg, _QuestFailureMsg)
            g_QuestNameToID[_QuestName] = QuestID
        else
            dbg("Quest '"..tostring(questName).."': invalid questname! Contains forbidden characters!");
        end
    end
end

---
-- FIXME
-- @within Initialisierer-Funktionen
-- @local
--
function Core:SetupGlobal_HackQuestSystem()
    QuestTemplate.Trigger_Orig_QSB_Core = QuestTemplate.Trigger
    QuestTemplate.Trigger = function(_quest)
        QuestTemplate.Trigger_Orig_QSB_Core(_quest);
        for i=1,_quest.Objectives[0] do
            if _quest.Objectives[i].Type == Objective.Custom2 and _quest.Objectives[i].Data[1].SetDescriptionOverwrite then
                local Desc = _quest.Objectives[i].Data[1]:SetDescriptionOverwrite(_quest);
                SetQuestDescriptionText(_quest.Identifier, Desc);
                break;
            end
        end
    end

    QuestTemplate.Interrupt_Orig_QSB_Core = QuestTemplate.Interrupt;
    QuestTemplate.Interrupt = function(_quest)
        QuestTemplate.Interrupt_Orig_QSB_Core(_quest);
        for i=1, _quest.Objectives[0] do
            if _quest.Objectives[i].Type == Objective.Custom2 and _quest.Objectives[i].Data[1].Interrupt then
                _quest.Objectives[i].Data[1]:Interrupt(_quest, i);
            end
        end
        for i=1, _quest.Triggers[0] do
            if _quest.Triggers[i].Type == Triggers.Custom2 and _quest.Triggers[i].Data[1].Interrupt then
                _quest.Triggers[i].Data[1]:Interrupt(_quest, i);
            end
        end
    end
end

---
-- Registiert ein Bundle, sodass es initialisiert wird.
--
-- @param _Bundle Name des Moduls
-- @within Core Class
-- @local
--
function Core:RegisterBundle(_Bundle)
    if not _G[_Bundle] and not GUI then
        local text = string.format("Error while initialize bundle '%s': does not exist!", tostring(_Bundle));
        assert(false, text);
        return;
    end
    table.insert(self.Data.BundleInitializerList, _G[_Bundle]);
end

---
-- Bereitet ein Behavior für den Einsatz im Assistenten und im Skript vor.
-- Erzeugt zudem den Konstruktor.
--
-- @param _Behavior    Behavior-Objekt
-- @within Core Class
-- @local
--
function Core:RegisterBehavior(_Behavior)
    if _Behavior.RequiresExtraNo and _Behavior.RequiresExtraNo > g_GameExtraNo then
        return;
    end

    if not _G["b_" .. _Behavior.Name] then
        dbg("AddQuestBehavior: can not find ".. _Behavior.Name .."!");
        return;
    end

    if not _G["b_" .. _Behavior.Name].new then
        _G["b_" .. _Behavior.Name].new = function(self, ...)
            local behavior = self:CopyTableRecursive(self);
            if self.Parameter then
                for i=1,table.getn(self.Parameter) do
                    behavior:AddParameter(i-1, arg[i]);
                end
            end
            return behavior;
        end
    end

    -- _G[_Behavior.Name] = function(...)
    --     return _G["b_" .. _Behavior.Name]:new(...);
    -- end
    table.insert(g_QuestBehaviorTypes, _Behavior);
end

---
-- Prüft, ob der Questname formal korrekt ist. Questnamen dürfen i.d.R. nur
-- die Zeichen A-Z, a-7, 0-9, - und _ enthalten.
--
-- @param _Name     Quest
-- @return boolean: Questname ist fehlerfrei
-- @within Core Class
-- @local
--
function Core:CheckQuestName(_Name)
    return not string.find(__quest_, "[ \"§$%&/\(\)\[\[\?ß\*+#,;:\.^\<\>\|]");
end

---
-- Ändert den Text des Beschreibungsfensters eines Quests. Die Beschreibung
-- wird erst dann aktualisiert, wenn der Quest ausgeblendet wird.
--
-- @param _Text   Neuer Text
-- @param _Quest  Identifier des Quest
-- @within Core Class
-- @local
--
function Core:ChangeCustomQuestCaptionText(_Text, _Quest)
    _Quest.QuestDescription = Umlaute(__text_);
    Logic.ExecuteInLuaLocalState([[
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/BGDeco",0)
        local identifier = "]].._Quest.Identifier..[["
        for i=1, Quests[0] do
            if Quests[i].Identifier == identifier then
                local text = Quests[i].QuestDescription
                XGUIEng.SetText("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/Text", "]].._Text..[[")
                break;
            end
        end
    ]]);
end

---
-- Erweitert eine Funktion um eine andere Funktion.
-- 
-- Jede hinzugefügte Funktion wird nach der Originalfunktion ausgeführt. Es
-- ist möglich eine neue Funktion an einem bestimmten Index einzufügen. Diese
-- Funktion ist nicht gedacht, um sie direkt auszuführen. Für jede Funktion
-- im Spiel sollte eine API-Funktion erstellt werden.
--
-- @param _FunctionName   
-- @param _AppendFunction 
-- @within Core Class  
-- @local
--
function Core:AppendFunction(_FunctionName, _AppendFunction, _Index)
    if not self.Data.Append.Functions[_FunctionName] then
        self.Data.Append.Functions[_FunctionName] = {
            Original = self:GetFunctionByString(_FunctionName),
            Attachments = {}
        };
        
        local batch = function(...)
            for k, v in pairs(self.Data.Append.Functions[_FunctionName].Attachments) do
                if v(..., self.Data.Append.Functions[_FunctionName].Original) then
                    break;
                end
            end
        end
        self:ReplaceFunction(_FunctionName, batch);
    end
    
    _Index = _Index or #self.Data.Append.Functions[_FunctionName].Function;
    table.insert(self.Data.Append.Functions[_FunctionName].Function, _Index, _AppendFunction);
end

---
-- Überschreibt eine Funktion mit einer anderen.
-- 
-- Wenn es sich um eine Funktion innerhalb einer Table handelt, dann darf sie
-- sich nicht tiefer als zwei Ebenen under dem Toplevel befinden.
--
-- @within Core Class
-- @local
-- @usage A = {foo = function() API.Note("bar") end}
-- B = function() API.Note("muh") end
-- Core:ReplaceFunction("A.foo", B)
-- -- A.foo() == B() => "muh"
--
function Core:ReplaceFunction(_FunctionName, _NewFunction)
    local s, e = _FunctionName:find("%.");
    if s then
        local FirstLayer  = _FunctionName:sub(1, s-1);
        local SecondLayer = _FunctionName:sub(e+1, _FunctionName:len());
        local s, e = SecondLayer:find("%.");
        if s then
            local tmp = SecondLayer;
            local SecondLayer = tmp:sub(1, s-1);
            local ThirdLayer = tmp:sub(e+1, tmp:len());
            _G[FirstLayer][SecondLayer][ThirdLayer] = _NewFunction;
        else
            _G[FirstLayer][SecondLayer] = _NewFunction;
        end
    else
        _G[_FunctionName] = _NewFunction;
        return;
    end
end

---
-- Sucht eine Funktion mit dem angegebenen Namen.
--
-- Ist die Funktionen innerhalb einer Table, so sind alle Ebenen bis zum
-- Funktionsnamen mit anzugeben, abgetrennt durch einen Punkt.
--
-- @param _FunctionName Name der Funktion
-- @param _Reference    Aktuelle Referenz (für Rekursion)
-- @return function: Gefundene Funktion
-- @within Core Class
-- @local
--
function Core:GetFunctionInString(_FunctionName, _Reference)
    -- Wenn wir uns in der ersten Rekursionsebene beinden, suche in _G
    if not _Reference then
        local s, e = _FunctionName:find("%.");
        if s then
            local FirstLayer = _FunctionName:sub(1, s-1);
            local Rest = _FunctionName:sub(e+1, _FunctionName:len());
            return self:GetFunctionByString(Rest, _G[FirstLayer]);
        else
            return _G[_FunctionName];
        end
    end
    -- Andernfalls suche in der Referenz
    if type(_Reference) == "table" then
        local s, e = _FunctionName:find("%.");
        if s then
            local FirstLayer = _FunctionName:sub(1, s-1);
            local Rest = _FunctionName:sub(e+1, _FunctionName:len());
            return self:GetFunctionByString(Rest, _Reference[FirstLayer]);
        else
            return _Reference[_FunctionName];
        end
    end
end

---
-- Wandelt underschiedliche Darstellungen einer Boolean in eine echte um.
--
-- @param _Input Boolean-Darstellung
-- @return boolean: Konvertierte Boolean
-- @within Core Class
-- @local
--
function Core:ToBoolean(_Input)
    local Suspicious = tostring(_Input);
    if Suspicious == true or Suspicious == "true" or Suspicious == "Yes" or Suspicious == "On" or Suspicious == "+" then
        return true;
    end
    if Suspicious == false or Suspicious == "false" or Suspicious == "No" or Suspicious == "Off" or Suspicious == "-" then
        return false;
    end
    return false;
end
