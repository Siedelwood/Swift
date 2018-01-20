-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia Core                                                         # --
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
-- @script SymfoniaCore
-- @set sort=true
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
-- @within User Space
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
-- <b>Alias:</b> CopyTableRecursive
--
-- @param _Source    Quelltabelle
-- @param _Dest      Zieltabelle
-- @return Kopie der Tabelle
-- @within User Space
-- @usage Table = {1, 2, 3, {a = true}}
-- Copy = API.InstanceTable(Table)
--
function API.InstanceTable(_Source, _Dest)
    _Dest = _Dest or {};
    assert(type(_Source) == "table")
    assert(type(_Dest) == "table")
    
    for k, v in pairs(_Source) do
        if type(v) == "table" then
            _Dest[k] = API.InstanceTable(v);
        else
            _Dest[k] = v;
        end
    end
    return _Dest;
end
CopyTableRecursive = API.InstanceTable;

---
-- Sucht in einer Table nach einem Wert. Das erste Aufkommen des Suchwerts
-- wird als Erfolg gewertet.
--
-- <b>Alias:</b> Inside
--
-- @param _Data     Datum, das gesucht wird
-- @param _Table    Tabelle, die durchquert wird
-- @return booelan: Wert gefunden
-- @within User Space
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
-- @within User Space
-- @usage Table = {1, 2, 3, {a = true}}
-- API.DumpTable(Table)
--
function API.DumpTable(_Table, _Name)
    local Start = "{";
    if _Name then
        Start = _Name.. " = \n" ..Start;
    end
    Framework.WriteToLog(Start);
    
    for k, v in pairs(_Table) do
        if type(v) == "table" then
            Framework.WriteToLog("[" ..k.. "] = ");
            API.DumpTable(v);
        elseif type(v) == "string" then
            Framework.WriteToLog("[" ..k.. "] = \"" ..v.. "\"");
        else
            Framework.WriteToLog("[" ..k.. "] = " ..tostring(v));
        end
    end
    Framework.WriteToLog("}");
end

-- Quests ----------------------------------------------------------------------

---
-- Gibt die ID des Quests mit dem angegebenen Namen zurück. Existiert der
-- Quest nicht, wird nil zurückgegeben.
--
-- <b>Alias:</b> GetQuestID
--
-- @param _Name     Identifier des Quest
-- @return number: ID des Quest
-- @within User Space
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
-- <b>Alias:</b> IsValidQuest
--
-- @param _QuestID   ID oder Name des Quest
-- @return boolean: Quest existiert
-- @within User Space
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
-- <b>Alias:</b> FailQuestsByName
--
-- @param ...  Liste mit Quests
-- @within User Space
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
-- <b>Alias:</b> FailQuestByName
--
-- @param _QuestName  Name des Quest
-- @within User Space
--
function API.FailQuest(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        Quest:RemoveQuestMarkers();
        Quest:Fail();
    end
end
FailQuestByName = API.FailQuest;

---
-- Startet eine Liste von Quests neu.
--
-- <b>Alias:</b> StartQuestsByName
--
-- @param ...  Liste mit Quests
-- @within User Space
--
function API.RestartAllQuests(...)
    for i=1, #args, 1 do
        API.RestartQuest(args[i]);
    end
end
RestartQuestsByName = API.RestartAllQuests;

---
-- Startet den Quest neu.
--
-- Der Quest muss beendet sein um ihn wieder neu zu starten. Wird ein Quest
-- neu gestartet, müssen auch alle Trigger wieder neu ausgelöst werden, außer
-- der Quest wird manuell getriggert.
--
-- Alle Änderungen an Standardbehavior müssen hier berücksichtigt werden. Wird 
-- ein Standardbehavior in einem Bundle verändern, muss auch diese Funktion 
-- angepasst oder überschrieben werden.
--
-- <b>Alias:</b> RestartQuestByName
--
-- @param _QuestName  Name des Quest
-- @within User Space
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
RestartQuestByName = API.RestartQuest;

---
-- Startet eine Liste von Quests.
--
-- <b>Alias:</b> StartQuestsByName
--
-- @param ...  Liste mit Quests
-- @within User Space
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
-- <b>Alias:</b> StartQuestByName
--
-- @param _QuestName  Name des Quest
-- @within User Space
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
-- <b>Alias:</b> StopQuestsByName
--
-- @param ...  Liste mit Quests
-- @within User Space
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
-- <b>Alias:</b> StopQuestByName
--
-- @param _QuestName  Name des Quest
-- @within User Space
--
function API.StopQuest(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
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
-- <b>Alias:</b> WinQuestsByName
--
-- @param ...  Liste mit Quests
-- @within User Space
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
-- <b>Alias:</b> WinQuestByName
--
-- @param _QuestName  Name des Quest
-- @within User Space
--
function API.WinQuest(_QuestName)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
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
-- <b>Alias:</b> GUI_Note
--
-- @param _Message Anzeigetext
-- @within User Space
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
-- @within User Space
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
-- @within User Space
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
-- @within User Space
--
function API.Log(_Message)
    local Env  = (GUI and "Local") or "Global";
    local Turn = Logic.GetTimeMs();
    Framework.WriteToLog(Env.. ":" ..Turn.. ": " .._Message);
end

---
-- Schreibt eine Nachricht in das Nachrichtenfenster unten in der Mitte.
--
-- @param _Message Anzeigetext
-- @within User Space
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
-- @within User Space
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
-- @within User Space
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
-- <b>Alias:</b> SendCart
--
-- @param _position            Position
-- @param _player              Zielspieler
-- @param _good                Warentyp
-- @param _amount              Warenmenge
-- @param _cartOverlay         (optional) Overlay für Goldkarren
-- @param _ignoreReservation   (optional) Marktplatzreservation ignorieren
-- @return number: Entity-ID des erzeugten Wagens
-- @within User Space
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
-- <b>Alias:</b> ReplaceEntity
--
-- @param _Entity     Entity
-- @param _Type       Neuer Typ
-- @param _NewOwner   (optional) Neuer Besitzer
-- @return number: Entity-ID des Entity
-- @within User Space
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
-- <b>Alias:</b> LookAt
--
-- @param _entity           Entity
-- @param _entityToLookAt   Ziel
-- @param _offsetEntity     Winkel-Offset
-- @within User Space
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
-- @within User Space
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
-- <b>Alias:</b> GetDistance
--
-- @param _pos1 Erste Vergleichsposition
-- @param _pos2 Zweite Vergleichsposition
-- @return number: Entfernung zwischen den Punkten
-- @within User Space
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
-- <b>Alias:</b> GetPosition
--
-- @param _Entity   Entity, dessen Position bestimmt wird.
-- @return table: Positionstabelle {X= x, Y= y, Z= z}
-- @within User Space
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
-- <b>Alias:</b> InteractiveObjectActivate
--
-- @param _ScriptName  Skriptname des IO
-- @param _State       Aktivierungszustand
-- @within User Space
-- @usage API.ActivateIO("Haus1", 0)
-- @usage API.ActivateIO("Hut1")
--
function API.ActivateIO(_ScriptName, _State)
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
-- <b>Alias:</b> InteractiveObjectDeactivate
--
-- @param _ScriptName Skriptname des IO
-- @within User Space
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
-- <b>Alias:</b> GetEntitiesOfCategoryInTerritory
--
-- @param _player    PlayerID [0-8] oder -1 für alle
-- @param _category  Kategorie, der die Entities angehören
-- @param _territory Zielterritorium
-- @within User Space
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
GetEntitiesOfCategoryInTerritory = API.GetEntitiesOfCategoryInTerritory;

-- Overwrite -------------------------------------------------------------------

---
-- Konvertiert alternative Wahrheitswertangaben in der QSB in eine Boolean.
--
-- <p>Wahrheitsert true: true, "true", "yes", "on", "+"</p>
-- <p>Wahrheitswert false: false, "false", "no", "off", "-"</p>
--
-- <b>Alias:</b> AcceptAlternativeBoolean
-- 
-- @param _Value Wahrheitswert
-- @return boolean: Wahrheitswert
-- @within User Space
--
-- @usage local Bool = API.ToBoolean("+")  --> Bool = true
-- local Bool = API.ToBoolean("no") --> Bool = false
--
function API.ToBoolean(_Value)
    return Core:ToBoolean(_Value);
end
AcceptAlternativeBoolean = API.ToBoolean;

---
-- Hängt eine Funktion an Mission_OnSaveGameLoaded an, sodass sie nach dem
-- Laden eines Spielstandes ausgeführt wird.
--
-- @param _Function Funktion, die ausgeführt werden soll
-- @within User Space
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
        BundleInitializerList = {},
    }
}

---
-- Initialisiert alle verfügbaren Bundles und führt ihre Install-Methode aus.
-- Bundles werden immer getrennt im globalen und im lokalen Skript gestartet.
-- @within Application Space
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
-- @within Application Space
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
        if Core:CheckQuestName(_QuestName) then
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
-- @within Application Space
-- @local
--
function Core:SetupGlobal_HackQuestSystem()
    QuestTemplate.Trigger_Orig_QSB_Core = QuestTemplate.Trigger
    QuestTemplate.Trigger = function(_quest)
        QuestTemplate.Trigger_Orig_QSB_Core(_quest);
        for i=1,_quest.Objectives[0] do
            if _quest.Objectives[i].Type == Objective.Custom2 and _quest.Objectives[i].Data[1].SetDescriptionOverwrite then
                local Desc = _quest.Objectives[i].Data[1]:SetDescriptionOverwrite(_quest);
                Core:ChangeCustomQuestCaptionText(_quest.Identifier, Desc);
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
-- @within Application Space
-- @local
--
function Core:RegisterBundle(_Bundle)
    local text = string.format("Error while initialize bundle '%s': does not exist!", tostring(_Bundle));
    assert(_G[_Bundle] ~= nil, text);
    table.insert(self.Data.BundleInitializerList, _G[_Bundle]);
end

---
-- Bereitet ein Behavior für den Einsatz im Assistenten und im Skript vor.
-- Erzeugt zudem den Konstruktor.
--
-- @param _Behavior    Behavior-Objekt
-- @within Application Space
-- @local
--
function Core:RegisterBehavior(_Behavior)
    if GUI then
        return;
    end
    if _Behavior.RequiresExtraNo and _Behavior.RequiresExtraNo > g_GameExtraNo then
        return;
    end

    if not _G["b_" .. _Behavior.Name] then
        dbg("AddQuestBehavior: can not find ".. _Behavior.Name .."!");
    else
        if not _G["b_" .. _Behavior.Name].new then
            _G["b_" .. _Behavior.Name].new = function(self, ...)
                local behavior = API.InstanceTable(self);
                if self.Parameter then
                    for i=1,table.getn(self.Parameter) do
                        behavior:AddParameter(i-1, arg[i]);
                    end
                end
                return behavior;
            end
        end
        table.insert(g_QuestBehaviorTypes, _Behavior);
    end
end

---
-- Prüft, ob der Questname formal korrekt ist. Questnamen dürfen i.d.R. nur
-- die Zeichen A-Z, a-7, 0-9, - und _ enthalten.
--
-- @param _Name     Quest
-- @return boolean: Questname ist fehlerfrei
-- @within Application Space
-- @local
--
function Core:CheckQuestName(_Name)
    return not string.find(_Name, "[ \"§$%&/\(\)\[\[\?ß\*+#,;:\.^\<\>\|]");
end

---
-- Ändert den Text des Beschreibungsfensters eines Quests. Die Beschreibung
-- wird erst dann aktualisiert, wenn der Quest ausgeblendet wird.
--
-- @param _Text   Neuer Text
-- @param _Quest  Identifier des Quest
-- @within Application Space
-- @local
--
function Core:ChangeCustomQuestCaptionText(_Text, _Quest)
    _Quest.QuestDescription = _Text;
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
-- @param _Index
-- @within Application Space
-- @local
--
function Core:AppendFunction(_FunctionName, _AppendFunction, _Index)
    if not self.Data.Append.Functions[_FunctionName] then
        self.Data.Append.Functions[_FunctionName] = {
            Original = self:GetFunctionInString(_FunctionName),
            Attachments = {}
        };

        local batch = function(...)
            for k, v in pairs(self.Data.Append.Functions[_FunctionName].Attachments) do
                if v(arg, self.Data.Append.Functions[_FunctionName].Original) then
                    return;
                end
            end
            self.Data.Append.Functions[_FunctionName].Original(unpack(arg));
        end
        self:ReplaceFunction(_FunctionName, batch);
    end

    _Index = _Index or #self.Data.Append.Functions[_FunctionName].Attachments;
    table.insert(self.Data.Append.Functions[_FunctionName].Attachments, _Index, _AppendFunction);
end

---
-- Überschreibt eine Funktion mit einer anderen.
--
-- Wenn es sich um eine Funktion innerhalb einer Table handelt, dann darf sie
-- sich nicht tiefer als zwei Ebenen under dem Toplevel befinden.
--
-- @local
-- @within Application Space
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
-- @within Application Space
-- @local
--
function Core:GetFunctionInString(_FunctionName, _Reference)
    -- Wenn wir uns in der ersten Rekursionsebene beinden, suche in _G
    if not _Reference then
        local s, e = _FunctionName:find("%.");
        if s then
            local FirstLayer = _FunctionName:sub(1, s-1);
            local Rest = _FunctionName:sub(e+1, _FunctionName:len());
            return self:GetFunctionInString(Rest, _G[FirstLayer]);
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
            return self:GetFunctionInString(Rest, _Reference[FirstLayer]);
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
-- @within Application Space
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

-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleClassicBehaviors                                       # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle enthält alle Behavior, die aus der QSB 3.9 PlusB bekannt sind.
--
-- Die Behavior sind weitesgehend unverändert und es dürfte keine Probleme mit
-- Inkompatibelität geben, wenn die QSB ausgetauscht wird.
--
-- @module BundleClassicBehaviors
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

QSB.EffectNameToID    = QSB.EffectNameToID or {};
QSB.InitalizedObjekts = QSB.InitalizedObjekts or {};
QSB.DestroyedSoldiers = QSB.DestroyedSoldiers or {};

-- -------------------------------------------------------------------------- --
-- User Space                                                                 --
-- -------------------------------------------------------------------------- --

-- Hier siehst du... nichts! ;)

-- -------------------------------------------------------------------------- --
-- Goals                                                                      --
-- -------------------------------------------------------------------------- --

---
-- Ein Interaktives Objekt muss benutzt werden.
--
-- @param _ScriptName Skriptname des interaktiven Objektes
-- @return Table mit Behavior
-- @within Goal
--
function Goal_ActivateObject(...)
    return b_Goal_ActivateObject:new(...);
end

b_Goal_ActivateObject = {
    Name = "Goal_ActivateObject",
    Description = {
        en = "Goal: Activate an interactive object",
        de = "Ziel: Aktiviere ein interaktives Objekt",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Object name", de = "Skriptname" },
    },
}

function b_Goal_ActivateObject:GetGoalTable(_Quest)
    return {Objective.Object, { self.ScriptName } }
end

function b_Goal_ActivateObject:AddParameter(_Index, _Parameter)
   if _Index == 0 then
        self.ScriptName = _Parameter
   end
end

function b_Goal_ActivateObject:GetMsgKey()
    return "Quest_Object_Activate"
end

Core:RegisterBehavior(b_Goal_ActivateObject);

-- -------------------------------------------------------------------------- --

---
-- Einem Spieler müssen Rohstoffe oder Waren gesendet werden.
--
-- In der Regel wird zum Auftraggeber gesendet. Es ist aber möglich auch zu
-- einem anderen Zielspieler schicken zu lassen. Wird ein Wagen gefangen
-- genommen, dann muss erneut geschickt werden. Optional kann auch gesagt
-- werden, dass keine erneute Forderung erfolgt, wenn der Karren von einem
-- Feind abgefangen wird.
--
-- @param _GoodType      Typ der Ware
-- @param _GoodAmount    Menga der Ware
-- @param _OtherTarget   Anderes Ziel als Auftraggeber
-- @param _IgnoreCapture Bei Gefangennahme nicht erneut schicken
-- @return Table mit Behavior
-- @within Goal
--
function Goal_Deliver(...)
    return b_Goal_Deliver:new(...)
end

b_Goal_Deliver = {
    Name = "Goal_Deliver",
    Description = {
        en = "Goal: Deliver goods to quest giver or to another player.",
        de = "Ziel: Liefere Waren zum Auftraggeber oder zu einem anderen Spieler.",
    },
    Parameter = {
        { ParameterType.Custom, en = "Type of good", de = "Ressourcentyp" },
        { ParameterType.Number, en = "Amount of good", de = "Ressourcenmenge" },
        { ParameterType.Custom, en = "To different player", de = "Anderer Empfänger" },
        { ParameterType.Custom, en = "Ignore capture", de = "Abfangen ignorieren" },
    },
}


function b_Goal_Deliver:GetGoalTable(_Quest)
    local GoodType = Logic.GetGoodTypeID(self.GoodTypeName)
    return { Objective.Deliver, GoodType, self.GoodAmount, self.OverrideTarget, self.IgnoreCapture }
end

function b_Goal_Deliver:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.GoodTypeName = _Parameter
    elseif (_Index == 1) then
        self.GoodAmount = _Parameter * 1
    elseif (_Index == 2) then
        self.OverrideTarget = tonumber(_Parameter)
    elseif (_Index == 3) then
        self.IgnoreCapture = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Goal_Deliver:GetCustomData( _Index )
    local Data = {}
    if _Index == 0 then
        for k, v in pairs( Goods ) do
            if string.find( k, "^G_" ) then
                table.insert( Data, k )
            end
        end
        table.sort( Data )
    elseif _Index == 2 then
        table.insert( Data, "-" )
        for i = 1, 8 do
            table.insert( Data, i )
        end
    elseif _Index == 3 then
        table.insert( Data, "true" )
        table.insert( Data, "false" )
    else
        assert( false )
    end
    return Data
end

function b_Goal_Deliver:GetMsgKey()
    local GoodType = Logic.GetGoodTypeID(self.GoodTypeName)
    local GC = Logic.GetGoodCategoryForGoodType( GoodType )

    local tMapping = {
        [GoodCategories.GC_Clothes] = "Quest_Deliver_GC_Clothes",
        [GoodCategories.GC_Entertainment] = "Quest_Deliver_GC_Entertainment",
        [GoodCategories.GC_Food] = "Quest_Deliver_GC_Food",
        [GoodCategories.GC_Gold] = "Quest_Deliver_GC_Gold",
        [GoodCategories.GC_Hygiene] = "Quest_Deliver_GC_Hygiene",
        [GoodCategories.GC_Medicine] = "Quest_Deliver_GC_Medicine",
        [GoodCategories.GC_Water] = "Quest_Deliver_GC_Water",
        [GoodCategories.GC_Weapon] = "Quest_Deliver_GC_Weapon",
        [GoodCategories.GC_Resource] = "Quest_Deliver_Resources",
    }

    if GC then
        local Key = tMapping[GC]
        if Key then
            return Key
        end
    end
    return "Quest_Deliver_Goods"
end

Core:RegisterBehavior(b_Goal_Deliver);

-- -------------------------------------------------------------------------- --

---
-- Es muss ein bestimmter Diplomatiestatus zu einer anderen Datei erreicht
-- werden.
--
-- Dabei muss, je nach angegebener Relation entweder wenigstens oder auch
-- minbdestens erreicht werden.
--
-- Muss z.B. mindestens der Status Handelspartner erreicht werden (mit der
-- Relation >=), so ist der Quest auch dann erfüllt, wenn der Spieler
--  Verbündeter wird.
--
-- Im Gegenzug, bei der Relation <=, wäre der Quest erfüllt, sobald der
-- Spieler Handelspartner oder einen niedrigeren Status erreicht.
--
-- @param _PlayerID Partei, die Entdeckt werden muss
-- @param _State    Diplomatiestatus
-- @return Table mit Behavior
-- @within Goal
--
function Goal_Diplomacy(...)
    return b_Goal_Diplomacy:new(...);
end

b_Goal_Diplomacy = {
    Name = "Goal_Diplomacy",
    Description = {
        en = "Goal: Reach a diplomatic state",
        de = "Ziel: Erreiche einen bestimmten Diplomatiestatus zu einem anderen Spieler.",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Party", de = "Partei" },
        { ParameterType.DiplomacyState, en = "Relation", de = "Beziehung" },
    },
}

function b_Goal_Diplomacy:GetGoalTable(_Quest)
    return { Objective.Diplomacy, self.PlayerID, DiplomacyStates[self.DiplState] }
end

function b_Goal_Diplomacy:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 1) then
        self.DiplState = _Parameter
    end
end

function b_Goal_Diplomacy:GetIcon()
    return {6,3};
end

Core:RegisterBehavior(b_Goal_Diplomacy);

-- -------------------------------------------------------------------------- --

---
-- Das Heimatterritorium des Spielers muss entdeckt werden.
--
-- Das Heimatterritorium ist immer das, wo sich Burg oder Lagerhaus der
-- zu entdeckenden Partei befinden.
--
-- @param _PlayerID ID der zu entdeckenden Partei
-- @return Table mit Behavior
-- @within Goal
--
function Goal_DiscoverPlayer(...)
    return b_Goal_DiscoverPlayer:new(...);
end

b_Goal_DiscoverPlayer = {
    Name = "Goal_DiscoverPlayer",
    Description = {
        en = "Goal: Discover the home territory of another player.",
        de = "Ziel: Entdecke das Heimatterritorium eines Spielers.",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
    },
}

function b_Goal_DiscoverPlayer:GetGoalTable()
    return {Objective.Discover, 2, { self.PlayerID } }
end

function b_Goal_DiscoverPlayer:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    end
end

function b_Goal_DiscoverPlayer:GetMsgKey()
    local tMapping = {
        [PlayerCategories.BanditsCamp] = "Quest_Discover",
        [PlayerCategories.City] = "Quest_Discover_City",
        [PlayerCategories.Cloister] = "Quest_Discover_Cloister",
        [PlayerCategories.Harbour] = "Quest_Discover",
        [PlayerCategories.Village] = "Quest_Discover_Village",
    }
    local PlayerCategory = GetPlayerCategoryType(self.PlayerID)
    if PlayerCategory then
        local Key = tMapping[PlayerCategory]
        if Key then
            return Key
        end
    end
    return "Quest_Discover"
end

Core:RegisterBehavior(b_Goal_DiscoverPlayer);

-- -------------------------------------------------------------------------- --

---
-- Ein Territorium muss erstmalig vom Auftragnehmer betreten werden.
--
-- @param _Territory Name oder ID des Territorium
-- @return Table mit Behavior
-- @within Goal
--
function Goal_DiscoverTerritory(...)
    return b_Goal_DiscoverTerritory:new(...);
end

b_Goal_DiscoverTerritory = {
    Name = "Goal_DiscoverTerritory",
    Description = {
        en = "Goal: Discover a territory",
        de = "Ziel: Entdecke ein Territorium",
    },
    Parameter = {
        { ParameterType.TerritoryName, en = "Territory", de = "Territorium" },
    },
}

function b_Goal_DiscoverTerritory:GetGoalTable()
    return { Objective.Discover, 1, { self.TerritoryID  } }
end

function b_Goal_DiscoverTerritory:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.TerritoryID = tonumber(_Parameter)
        if not self.TerritoryID then
            self.TerritoryID = GetTerritoryIDByName(_Parameter)
        end
        assert( self.TerritoryID > 0 )
    end
end

function b_Goal_DiscoverTerritory:GetMsgKey()
    return "Quest_Discover_Territory"
end

Core:RegisterBehavior(b_Goal_DiscoverTerritory);

-- -------------------------------------------------------------------------- --

---
-- Eine andere Partei muss besiegt werden.
--
-- Die Partei gilt als besiegt, wenn ein Hauptgebäude (Burg, Kirche, Lager)
-- zerstört wurde. <b>Achtung:</b> Funktioniert nicht bei Banditen!
--
-- @param _PlayerID ID des Spielers
-- @return Table mit Behavior
-- @within Goal
--
function Goal_DestroyPlayer(...)
    return b_Goal_DestroyPlayer:new(...);
end

b_Goal_DestroyPlayer = {
    Name = "Goal_DestroyPlayer",
    Description = {
        en = "Goal: Destroy a player (destroy a main building)",
        de = "Ziel: Zerstöre einen Spieler (ein Hauptgebäude muss zerstört werden).",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
    },
}

function b_Goal_DestroyPlayer:GetGoalTable()
    assert( self.PlayerID <= 8 and self.PlayerID >= 1, "Error in " .. self.Name .. ": GetGoalTable: PlayerID is invalid")
    return { Objective.DestroyPlayers, self.PlayerID }
end

function b_Goal_DestroyPlayer:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    end
end

function b_Goal_DestroyPlayer:GetMsgKey()
    local tMapping = {
        [PlayerCategories.BanditsCamp] = "Quest_DestroyPlayers_Bandits",
        [PlayerCategories.City] = "Quest_DestroyPlayers_City",
        [PlayerCategories.Cloister] = "Quest_DestroyPlayers_Cloister",
        [PlayerCategories.Harbour] = "Quest_DestroyEntities_Building",
        [PlayerCategories.Village] = "Quest_DestroyPlayers_Village",
    }

    local PlayerCategory = GetPlayerCategoryType(self.PlayerID)
    if PlayerCategory then
        local Key = tMapping[PlayerCategory]
        if Key then
            return Key
        end
    end
    return "Quest_DestroyEntities_Building"
end

Core:RegisterBehavior(b_Goal_DestroyPlayer)

-- -------------------------------------------------------------------------- --

---
-- Es sollen Informationen aus der Burg gestohlen werden.
--
-- Der Spieler muss einen Dieb entsenden um Informationen aus der Burg zu
-- stehlen. <b>Achtung:</b> Das ist nur bei Feinden möglich!
--
-- @param _PlayerID ID der Partei
-- @return Table mit Behavior
-- @within Goal
--
function Goal_StealInformation(...)
    return b_Goal_StealInformation:new(...);
end

b_Goal_StealInformation = {
    Name = "Goal_StealInformation",
    Description = {
        en = "Goal: Steal information from another players castle",
        de = "Ziel: Stehle Informationen aus der Burg eines Spielers",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
    },
}

function b_Goal_StealInformation:GetGoalTable()

    local Target = Logic.GetHeadquarters(self.PlayerID)
    if not Target or Target == 0 then
        Target = Logic.GetStoreHouse(self.PlayerID)
    end
    assert( Target and Target ~= 0 )
    return {Objective.Steal, 1, { Target } }

end

function b_Goal_StealInformation:AddParameter(_Index, _Parameter)

    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    end

end

function b_Goal_StealInformation:GetMsgKey()
    return "Quest_Steal_Info"

end

Core:RegisterBehavior(b_Goal_StealInformation);

-- -------------------------------------------------------------------------- --

---
-- Alle Einheiten des Spielers müssen zerstört werden.
--
-- @param _PlayerID ID des Spielers
-- @return Table mit Behavior
-- @within Goal
--
function Goal_DestroyAllPlayerUnits(...)
    return b_Goal_DestroyAllPlayerUnits:new(...);
end

b_Goal_DestroyAllPlayerUnits = {
    Name = "Goal_DestroyAllPlayerUnits",
    Description = {
        en = "Goal: Destroy all units owned by player (be careful with script entities)",
        de = "Ziel: Zerstöre alle Einheiten eines Spielers (vorsicht mit Script-Entities)",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
    },
}

function b_Goal_DestroyAllPlayerUnits:GetGoalTable()
    return { Objective.DestroyAllPlayerUnits, self.PlayerID }
end

function b_Goal_DestroyAllPlayerUnits:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    end
end

function b_Goal_DestroyAllPlayerUnits:GetMsgKey()
    local tMapping = {
        [PlayerCategories.BanditsCamp] = "Quest_DestroyPlayers_Bandits",
        [PlayerCategories.City] = "Quest_DestroyPlayers_City",
        [PlayerCategories.Cloister] = "Quest_DestroyPlayers_Cloister",
        [PlayerCategories.Harbour] = "Quest_DestroyEntities_Building",
        [PlayerCategories.Village] = "Quest_DestroyPlayers_Village",
    }

    local PlayerCategory = GetPlayerCategoryType(self.PlayerID)
    if PlayerCategory then
        local Key = tMapping[PlayerCategory]
        if Key then
            return Key
        end
    end
    return "Quest_DestroyEntities"
end

Core:RegisterBehavior(b_Goal_DestroyAllPlayerUnits);

-- -------------------------------------------------------------------------- --

---
-- Ein benanntes Entity muss zerstört werden.
--
-- @param _ScriptName Skriptname des Ziels
-- @return Table mit Behavior
-- @within Goal
--
function Goal_DestroyScriptEntity(...)
    return b_Goal_DestroyScriptEntity:new(...);
end

b_Goal_DestroyScriptEntity = {
    Name = "Goal_DestroyScriptEntity",
    Description = {
        en = "Goal: Destroy an entity",
        de = "Ziel: Zerstöre eine Entität",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
    },
}

function b_Goal_DestroyScriptEntity:GetGoalTable()
    return {Objective.DestroyEntities, 1, { self.ScriptName } }
end

function b_Goal_DestroyScriptEntity:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptName = _Parameter
    end
end

function b_Goal_DestroyScriptEntity:GetMsgKey()
    if Logic.IsEntityAlive(self.ScriptName) then
        local ID = GetID(self.ScriptName)
        if ID and ID ~= 0 then
            ID = Logic.GetEntityType( ID )
            if ID and ID ~= 0 then
                if Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableBuilding ) == 1 then
                    return "Quest_DestroyEntities_Building"

                elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableAnimal ) == 1 then
                    return "Quest_DestroyEntities_Predators"

                elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.Hero ) == 1 then
                    return "Quest_Destroy_Leader"

                elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.Military ) == 1
                    or Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableSettler ) == 1
                    or Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableMerchant ) == 1  then

                    return "Quest_DestroyEntities_Unit"
                end
            end
        end
    end
    return "Quest_DestroyEntities"
end

Core:RegisterBehavior(b_Goal_DestroyScriptEntity);

-- -------------------------------------------------------------------------- --

---
-- Eine Menge an Entities eines Typs müssen zerstört werden.
--
-- Wenn Raubtiere zerstört werden sollen, muss Spieler 0 als Besitzer
-- angegeben werden.
--
-- @param _EntityType Typ des Entity
-- @param _Amount     Menge an Entities des Typs
-- @param _PlayerID   Besitzer des Entity
-- @return Table mit Behavior
-- @within Goal
--
function Goal_DestroyType(...)
    return b_Goal_DestroyType:new(...);
end

b_Goal_DestroyType = {
    Name = "Goal_DestroyType",
    Description = {
        en = "Goal: Destroy entity types",
        de = "Ziel: Zerstöre Entitätstypen",
    },
    Parameter = {
        { ParameterType.Custom, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
        { ParameterType.Custom, en = "Player", de = "Spieler" },
    },
}

function b_Goal_DestroyType:GetGoalTable(_Quest)
    return {Objective.DestroyEntities, 2, Entities[self.EntityName], self.Amount, self.PlayerID }
end

function b_Goal_DestroyType:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.EntityName = _Parameter
    elseif (_Index == 1) then
        self.Amount = _Parameter * 1
        self.DestroyTypeAmount = self.Amount
    elseif (_Index == 2) then
        self.PlayerID = _Parameter * 1
    end
end

function b_Goal_DestroyType:GetCustomData( _Index )
    local Data = {}
    if _Index == 0 then
        for k, v in pairs( Entities ) do
            if string.find( k, "^[ABU]_" ) then
                table.insert( Data, k )
            end
        end
        table.sort( Data )
    elseif _Index == 2 then
        for i = 0, 8 do
            table.insert( Data, i )
        end
    else
        assert( false )
    end
    return Data
end

function b_Goal_DestroyType:GetMsgKey()
    local ID = self.EntityName
    if Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableBuilding ) == 1 then
        return "Quest_DestroyEntities_Building"

    elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableAnimal ) == 1 then
        return "Quest_DestroyEntities_Predators"

    elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.Hero ) == 1 then
        return "Quest_Destroy_Leader"

    elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.Military ) == 1
        or Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableSettler ) == 1
        or Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableMerchant ) == 1  then

        return "Quest_DestroyEntities_Unit"
    end
    return "Quest_DestroyEntities"
end

Core:RegisterBehavior(b_Goal_DestroyType);

-- -------------------------------------------------------------------------- --

do
    GameCallback_EntityKilled_Orig_QSB_Goal_DestroySoldiers = GameCallback_EntityKilled;
    GameCallback_EntityKilled = function(_AttackedEntityID, _AttackedPlayerID, _AttackingEntityID, _AttackingPlayerID, _AttackedEntityType, _AttackingEntityType)
        if _AttackedPlayerID ~= 0 and _AttackingPlayerID ~= 0 then
            QSB.DestroyedSoldiers[_AttackingPlayerID] = QSB.DestroyedSoldiers[_AttackingPlayerID] or {}
            QSB.DestroyedSoldiers[_AttackingPlayerID][_AttackedPlayerID] = QSB.DestroyedSoldiers[_AttackingPlayerID][_AttackedPlayerID] or 0
            if Logic.IsEntityTypeInCategory( _AttackedEntityType, EntityCategories.Military ) == 1
            and Logic.IsEntityInCategory( _AttackedEntityID, EntityCategories.HeavyWeapon) == 0 then
                QSB.DestroyedSoldiers[_AttackingPlayerID][_AttackedPlayerID] = QSB.DestroyedSoldiers[_AttackingPlayerID][_AttackedPlayerID] +1
            end
        end
        GameCallback_EntityKilled_Orig_QSB_Goal_DestroySoldiers(_AttackedEntityID, _AttackedPlayerID, _AttackingEntityID, _AttackingPlayerID, _AttackedEntityType, _AttackingEntityType)
    end
end

---
-- Spieler A muss Soldaten von Spieler B zerstören.
--
-- @param _PlayerA Angreifende Partei
-- @param _PlayerB Zielpartei
-- @param _Amount Menga an Soldaten
-- @return Table mit Behavior
-- @within Goal
--
function Goal_DestroySoldiers(...)
    return b_Goal_DestroySoldiers:new(...);
end

b_Goal_DestroySoldiers = {
    Name = "Goal_DestroySoldiers",
    Description = {
        en = "Goal: Destroy a given amount of enemy soldiers",
        de = "Ziel: Zerstöre eine Anzahl gegnerischer Soldaten",
                },
    Parameter = {
        {ParameterType.PlayerID, en = "Attacking Player", de = "Angreifer", },
        {ParameterType.PlayerID, en = "Defending Player", de = "Verteidiger", },
        {ParameterType.Number, en = "Amount", de = "Anzahl", },
    },
}

function b_Goal_DestroySoldiers:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_DestroySoldiers:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.AttackingPlayer = _Parameter * 1
    elseif (_Index == 1) then
        self.AttackedPlayer = _Parameter * 1
    elseif (_Index == 2) then
        self.KillsNeeded = _Parameter * 1
    end
end

function b_Goal_DestroySoldiers:CustomFunction(_Quest)
    if not _Quest.QuestDescription or _Quest.QuestDescription == "" then
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en"
        local caption = (lang == "de" and "SOLDATEN ZERST�REN {cr}{cr}von der Partei: ") or
                         "DESTROY SOLDIERS {cr}{cr}from faction: "
        local amount  = (lang == "de" and "Anzahl: ") or "Amount: "
        local party = GetPlayerName(self.AttackedPlayer);
        if party == "" or party == nil then
            party = ((lang == "de" and "Spieler ") or "Player ") .. self.AttackedPlayer
        end
        local text = "{center}" .. caption .. party .. "{cr}{cr}" .. amount .. " "..self.KillsNeeded;
        Core:ChangeCustomQuestCaptionText(text, _Quest);
    end

    local currentKills = 0;
    if QSB.DestroyedSoldiers[self.AttackingPlayer] and QSB.DestroyedSoldiers[self.AttackingPlayer][self.AttackedPlayer] then
        currentKills = QSB.DestroyedSoldiers[self.AttackingPlayer][self.AttackedPlayer]
    end
    self.SaveAmount = self.SaveAmount or currentKills
    return self.KillsNeeded <= currentKills - self.SaveAmount or nil
end

function b_Goal_DestroySoldiers:DEBUG(_Quest)
    if Logic.GetStoreHouse(self.AttackingPlayer) == 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Player " .. self.AttackinPlayer .. " is dead :-(")
        return true
    elseif Logic.GetStoreHouse(self.AttackedPlayer) == 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Player " .. self.AttackedPlayer .. " is dead :-(")
        return true
    elseif self.KillsNeeded < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Amount negative")
        return true
    end
end

function b_Goal_DestroySoldiers:GetIcon()
    return {7,12}
end

function b_Goal_DestroySoldiers:Reset()
    self.SaveAmount = nil
end

Core:RegisterBehavior(b_Goal_DestroySoldiers)

---
-- Eine Entfernung zwischen zwei Entities muss erreicht werden.
--
-- Je nach angegebener Relation muss die Entfernung unter- oder überschritten
-- werden um den Quest zu gewinnen.
--
-- @param _ScriptName1  Erstes Entity
-- @param _ScriptName2  Zweites Entity
-- @param _Relation     Relation
-- @param _Distance     Entfernung
-- @return Table mit Behavior
-- @within Goal
--
function Goal_EntityDistance(...)
    return b_Goal_EntityDistance:new(...);
end

b_Goal_EntityDistance = {
    Name = "Goal_EntityDistance",
    Description = {
        en = "Goal: Distance between two entities",
        de = "Ziel: Zwei Entities sollen zueinander eine Entfernung über- oder unterschreiten.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity 1", de = "Entity 1" },
        { ParameterType.ScriptName, en = "Entity 2", de = "Entity 2" },
        { ParameterType.Custom, en = "Relation", de = "Relation" },
        { ParameterType.Number, en = "Distance", de = "Entfernung" },
    },
}

function b_Goal_EntityDistance:GetGoalTable(_Quest)
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_EntityDistance:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Entity1 = _Parameter
    elseif (_Index == 1) then
        self.Entity2 = _Parameter
    elseif (_Index == 2) then
        self.bRelSmallerThan = _Parameter == "<"
    elseif (_Index == 3) then
        self.Distance = _Parameter * 1
    end
end

function b_Goal_EntityDistance:CustomFunction(_Quest)
    if Logic.IsEntityDestroyed( self.Entity1 ) or Logic.IsEntityDestroyed( self.Entity2 ) then
        return false
    end
    local ID1 = GetID( self.Entity1 )
    local ID2 = GetID( self.Entity2 )
    local InRange = Logic.CheckEntitiesDistance( ID1, ID2, self.Distance )
    if ( self.bRelSmallerThan and InRange ) or ( not self.bRelSmallerThan and not InRange ) then
        return true
    end
end

function b_Goal_EntityDistance:GetCustomData( _Index )
    local Data = {}
    if _Index == 2 then
        table.insert( Data, ">" )
        table.insert( Data, "<" )
    else
        assert( false )
    end
    return Data
end

function b_Goal_EntityDistance:DEBUG(_Quest)
    if not IsExisting(self.Entity1) or not IsExisting(self.Entity2) then
        dbg("".._Quest.Identifier.." "..self.Name..": At least 1 of the entities for distance check don't exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Goal_EntityDistance);

-- -------------------------------------------------------------------------- --

---
-- Der Primary Knight des angegebenen Spielers muss sich dem Ziel nähern.
--
-- @param _PlayerID   PlayerID des Helden
-- @param _ScriptName Skriptname des Ziels
-- @return Table mit Behavior
-- @within Goal
--
function Goal_KnightDistance(...)
    return b_Goal_KnightDistance:new(...);
end

b_Goal_KnightDistance = {
    Name = "Goal_KnightDistance",
    Description = {
        en = "Goal: Bring the knight close to a given entity",
        de = "Ziel: Bringe den Ritter nah an eine bestimmte Entität",
    },
    Parameter = {
        { ParameterType.PlayerID,     en = "Player", de = "Spieler" },
        { ParameterType.ScriptName, en = "Target", de = "Ziel" },
    },
}

function b_Goal_KnightDistance:GetGoalTable()
    return {Objective.Distance, Logic.GetKnightID(self.PlayerID), self.Target, 2500, true}
end

function b_Goal_KnightDistance:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 1) then
        self.Target = _Parameter
    end
end

Core:RegisterBehavior(b_Goal_KnightDistance);

---
-- Eine bestimmte Anzahl an Einheiten einer Kategorie muss sich auf dem
-- Territorium befinden.
--
-- Die gegenebe Anzahl kann entweder als Mindestwert oder als Maximalwert
-- gesucht werden.
--
-- @param _Territory  TerritoryID oder TerritoryName
-- @param _PlayerID   PlayerID der Einheiten
-- @param _Category   Kategorie der Einheiten
-- @param _Relation   Mengenrelation (< oder >=)
-- @param _Amount     Menge an Einheiten
-- @return Table mit Behavior
-- @within Goal
--
function Goal_UnitsOnTerritory(...)
    return b_Goal_UnitsOnTerritory:new(...);
end

b_Goal_UnitsOnTerritory = {
    Name = "Goal_UnitsOnTerritory",
    Description = {
        en = "Goal: Place a certain amount of units on a territory",
        de = "Ziel: Platziere eine bestimmte Anzahl Einheiten auf einem Gebiet",
    },
    Parameter = {
        { ParameterType.TerritoryNameWithUnknown, en = "Territory", de = "Territorium" },
        { ParameterType.Custom,  en = "Player", de = "Spieler" },
        { ParameterType.Custom,  en = "Category", de = "Kategorie" },
        { ParameterType.Custom,  en = "Relation", de = "Relation" },
        { ParameterType.Number,  en = "Number of units", de = "Anzahl Einheiten" },
    },
}

function b_Goal_UnitsOnTerritory:GetGoalTable(_Quest)
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_UnitsOnTerritory:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.TerritoryID = tonumber(_Parameter)
        if self.TerritoryID == nil then
            self.TerritoryID = GetTerritoryIDByName(_Parameter)
        end
    elseif (_Index == 1) then
        self.PlayerID = tonumber(_Parameter) * 1
    elseif (_Index == 2) then
        self.Category = _Parameter
    elseif (_Index == 3) then
        self.bRelSmallerThan = (tostring(_Parameter) == "true" or tostring(_Parameter) == "<")
    elseif (_Index == 4) then
        self.NumberOfUnits = _Parameter * 1
    end
end

function b_Goal_UnitsOnTerritory:CustomFunction(_Quest)
    local Units = GetEntitiesOfCategoryInTerritory(self.PlayerID, EntityCategories[self.Category], self.TerritoryID);
    if self.bRelSmallerThan == false and #Units >= self.NumberOfUnits then
        return true;
    elseif self.bRelSmallerThan == true and #Units < self.NumberOfUnits then
        return true;
    end
end

function b_Goal_UnitsOnTerritory:GetCustomData( _Index )
    local Data = {}
    if _Index == 1 then
        table.insert( Data, -1 )
        for i = 1, 8 do
            table.insert( Data, i )
        end
    elseif _Index == 2 then
        for k, v in pairs( EntityCategories ) do
            if not string.find( k, "^G_" ) and k ~= "SheepPasture" then
                table.insert( Data, k )
            end
        end
        table.sort( Data );
    elseif _Index == 3 then
        table.insert( Data, ">=" )
        table.insert( Data, "<" )
    else
        assert( false )
    end
    return Data
end

function b_Goal_UnitsOnTerritory:DEBUG(_Quest)
    local territories = {Logic.GetTerritories()}
    if tonumber(self.TerritoryID) == nil or self.TerritoryID < 0 or not Inside(self.TerritoryID,territories) then
        dbg("".._Quest.Identifier.." "..self.Name..": got an invalid territoryID!");
        return true;
    elseif tonumber(self.PlayerID) == nil or self.PlayerID < 0 or self.PlayerID > 8 then
        dbg("".._Quest.Identifier.." "..self.Name..": got an invalid playerID!");
        return true;
    elseif not EntityCategories[self.Category] then
        dbg("".._Quest.Identifier.." "..self.Name..": got an invalid playerID!");
        return true;
    elseif tonumber(self.NumberOfUnits) == nil or self.NumberOfUnits < 0 then
        dbg("".._Quest.Identifier.." "..self.Name..": amount is negative or nil!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Goal_UnitsOnTerritory);

-- -------------------------------------------------------------------------- --

---
-- Der angegebene Spieler muss einen Buff aktivieren.
--
-- <u>Buffs</u>
-- <li>Buff_Spice: Salz</li>
-- <li>Buff_Colour: Farben</li>
-- <li>Buff_Entertainers: Entertainer anheuern</li>
-- <li>Buff_FoodDiversity: Vielfältige Nahrung</li>
-- <li>Buff_ClothesDiversity: Vielfältige Kleidung</li>
-- <li>Buff_HygieneDiversity: Vielfältige Hygiene</li>
-- <li>Buff_EntertainmentDiversity: Vielfältige Unterhaltung</li>
-- <li>Buff_Sermon: Predigt halten</li>
-- <li>Buff_Festival: Fest veranstalten</li>
-- <li>Buff_ExtraPayment: Bonussold auszahlen</li>
-- <li>Buff_HighTaxes: Hohe Steuern verlangen</li>
-- <li>Buff_NoPayment: Sold streichen</li>
-- <li>Buff_NoTaxes: Keine Steuern verlangen</li>
-- <br/>
-- <u>RdO Buffs</u>
-- <li>Buff_Gems: Edelsteine</li>
-- <li>Buff_MusicalInstrument: Musikinstrumente</li>
-- <li>Buff_Olibanum: Weihrauch</li>
--
-- @param _PlayerID Spieler, der den Buff aktivieren muss
-- @param _Buff     Buff, der aktiviert werden soll
-- @return Table mit Behavior
-- @within Goal
--
function Goal_ActivateBuff(...)
    return b_Goal_ActivateBuff:new(...);
end

b_Goal_ActivateBuff = {
    Name = "Goal_ActivateBuff",
    Description = {
        en = "Goal: Activate a buff",
        de = "Ziel: Aktiviere einen Buff",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Custom, en = "Buff", de = "Buff" },
    },
}

function b_Goal_ActivateBuff:GetGoalTable(_Quest)
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_ActivateBuff:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 1) then
        self.BuffName = _Parameter
        self.Buff = Buffs[_Parameter]
    end
end

function b_Goal_ActivateBuff:CustomFunction(_Quest)
   if not _Quest.QuestDescription or _Quest.QuestDescription == "" then
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en"
        local caption = (lang == "de" and "BONUS AKTIVIEREN{cr}{cr}") or "ACTIVATE BUFF{cr}{cr}"

        local tMapping = {
            ["Buff_Spice"]                        = {de = "Salz", en = "Salt"},
            ["Buff_Colour"]                        = {de = "Farben", en = "Color"},
            ["Buff_Entertainers"]                = {de = "Entertainer", en = "Entertainer"},
            ["Buff_FoodDiversity"]                = {de = "Vielf�ltige Nahrung", en = "Food diversity"},
            ["Buff_ClothesDiversity"]            = {de = "Vielf�ltige Kleidung", en = "Clothes diversity"},
            ["Buff_HygieneDiversity"]            = {de = "Vielf�ltige Reinigung", en = "Hygiene diversity"},
            ["Buff_EntertainmentDiversity"]        = {de = "Vielf�ltige Unterhaltung", en = "Entertainment diversity"},
            ["Buff_Sermon"]                        = {de = "Predigt", en = "Sermon"},
            ["Buff_Festival"]                    = {de = "Fest", en = "Festival"},
            ["Buff_ExtraPayment"]                = {de = "Sonderzahlung", en = "Extra payment"},
            ["Buff_HighTaxes"]                    = {de = "Hohe Steuern", en = "High taxes"},
            ["Buff_NoPayment"]                    = {de = "Kein Sold", en = "No payment"},
            ["Buff_NoTaxes"]                    = {de = "Keine Steuern", en = "No taxes"},
        }

        if g_GameExtraNo >= 1 then
            tMapping["Buff_Gems"]                = {de = "Edelsteine", en = "Gems"}
            tMapping["Buff_MusicalInstrument"]  = {de = "Musikinstrumente", en = "Musical instruments"}
            tMapping["Buff_Olibanum"]            = {de = "Weihrauch", en = "Olibanum"}
        end

        local text = "{center}" .. caption .. tMapping[self.BuffName][lang]
        Core:ChangeCustomQuestCaptionText(text, _Quest)
    end

    local Buff = Logic.GetBuff( self.PlayerID, self.Buff )
    if Buff and Buff ~= 0 then
        return true
    end
end

function b_Goal_ActivateBuff:GetCustomData( _Index )
    local Data = {}
    if _Index == 1 then
        Data = {
            "Buff_Spice",
            "Buff_Colour",
            "Buff_Entertainers",
            "Buff_FoodDiversity",
            "Buff_ClothesDiversity",
            "Buff_HygieneDiversity",
            "Buff_EntertainmentDiversity",
            "Buff_Sermon",
            "Buff_Festival",
            "Buff_ExtraPayment",
            "Buff_HighTaxes",
            "Buff_NoPayment",
            "Buff_NoTaxes"
        }

        if g_GameExtraNo >= 1 then
            table.insert(Data, "Buff_Gems")
            table.insert(Data, "Buff_MusicalInstrument")
            table.insert(Data, "Buff_Olibanum")
        end

        table.sort( Data )
    else
        assert( false )
    end
    return Data
end

function b_Goal_ActivateBuff:GetIcon()
    local tMapping = {
        [Buffs.Buff_Spice] = "Goods.G_Salt",
        [Buffs.Buff_Colour] = "Goods.G_Dye",
        [Buffs.Buff_Entertainers] = "Entities.U_Entertainer_NA_FireEater", --{5, 12},
        [Buffs.Buff_FoodDiversity] = "Needs.Nutrition", --{1, 1},
        [Buffs.Buff_ClothesDiversity] = "Needs.Clothes", --{1, 2},
        [Buffs.Buff_HygieneDiversity] = "Needs.Hygiene", --{16, 1},
        [Buffs.Buff_EntertainmentDiversity] = "Needs.Entertainment", --{1, 4},
        [Buffs.Buff_Sermon] = "Technologies.R_Sermon", --{4, 14},
        [Buffs.Buff_Festival] = "Technologies.R_Festival", --{4, 15},
        [Buffs.Buff_ExtraPayment]    = {1,8},
        [Buffs.Buff_HighTaxes] = {1,6},
        [Buffs.Buff_NoPayment] = {1,8},
        [Buffs.Buff_NoTaxes]    = {1,6},
    }
    if g_GameExtraNo and g_GameExtraNo >= 1 then
        tMapping[Buffs.Buff_Gems] = "Goods.G_Gems"
        tMapping[Buffs.Buff_MusicalInstrument] = "Goods.G_MusicalInstrument"
        tMapping[Buffs.Buff_Olibanum] = "Goods.G_Olibanum"
    end
    return tMapping[self.Buff]
end

function b_Goal_ActivateBuff:DEBUG(_Quest)
    if not self.Buff then
        dbg("".._Quest.Identifier.." "..self.Name..": buff '" ..self.BuffName.. "' does not exist!");
        return true;
    elseif not tonumber(self.PlayerID) or self.PlayerID < 1 or self.PlayerID > 8 then
        dbg("".._Quest.Identifier.." "..self.Name..": got an invalid playerID!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Goal_ActivateBuff);

-- -------------------------------------------------------------------------- --

---
-- Zwei Punkte auf der Spielwelt müssen mit einer Straße verbunden werden.
--
-- @param _Position1 Erster Endpunkt der Straße
-- @param _Position2 Zweiter Endpunkt der Straße
-- @param _OnlyRoads Keine Wege akzeptieren
-- @return Table mit Behavior
-- @within Goal
--
function Goal_BuildRoad(...)
    return b_Goal_BuildRoad:new(...)
end

b_Goal_BuildRoad = {
    Name = "Goal_BuildRoad",
    Description = {
        en = "Goal: Connect two points with a street or a road",
        de = "Ziel: Verbinde zwei Punkte mit einer Strasse oder einem Weg.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity 1",     de = "Entity 1" },
        { ParameterType.ScriptName, en = "Entity 2",     de = "Entity 2" },
        { ParameterType.Custom,     en = "Only roads",     de = "Nur Strassen" },
    },
}

function b_Goal_BuildRoad:GetGoalTable(_Quest)
    return { Objective.BuildRoad, { GetID( self.Entity1 ),
                                     GetID( self.Entity2 ),
                                     false,
                                     0,
                                     self.bRoadsOnly } }

end

function b_Goal_BuildRoad:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Entity1 = _Parameter
    elseif (_Index == 1) then
        self.Entity2 = _Parameter
    elseif (_Index == 2) then
        self.bRoadsOnly = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Goal_BuildRoad:GetCustomData( _Index )
    local Data
    if _Index == 2 then
        Data = {"true","false"}
    end
    return Data
end

function b_Goal_BuildRoad:DEBUG(_Quest)
    if not IsExisting(self.Entity1) or not IsExisting(self.Entity2) then
        dbg("".._Quest.Identifier.." "..self.Name..": first or second entity does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Goal_BuildRoad);

-- -------------------------------------------------------------------------- --


---
-- Eine Mauer muss die Bewegung eines Spielers zwischen 2 Punkten einschränken.
--
-- <b>Achtung:</b> Bei Monsun kann dieses Ziel fälschlicher Weise als erfüllt gewertet
-- werden, wenn der Weg durch Wasser blockiert wird!
--
-- @param _PlayerID  PlayerID, die blockiert wird
-- @param _Position1 Erste Position
-- @param _Position2 Zweite Position
-- @return Table mit Behavior
-- @within Goal
--
function Goal_BuildWall(...)
    return b_Goal_BuildWall:new(...)
end

b_Goal_BuildWall = {
    Name = "Goal_BuildWall",
    Description = {
        en = "Goal: Build a wall between 2 positions bo stop the movement of an (hostile) player.",
        de = "Ziel: Baue eine Mauer zwischen 2 Punkten, die die Bewegung eines (feindlichen) Spielers zwischen den Punkten verhindert.",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Enemy", de = "Feind" },
        { ParameterType.ScriptName, en = "Entity 1", de = "Entity 1" },
        { ParameterType.ScriptName, en = "Entity 2", de = "Entity 2" },
    },
}

function b_Goal_BuildWall:GetGoalTable(_Quest)
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_BuildWall:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 1) then
        self.EntityName1 = _Parameter
    elseif (_Index == 2) then
        self.EntityName2 = _Parameter
    end
end

function b_Goal_BuildWall:CustomFunction(_Quest)
    local eID1 = GetID(self.EntityName1)
    local eID2 = GetID(self.EntityName2)

    if not IsExisting(eID1) then
        return false
    end
    if not IsExisting(eID2) then
        return false
    end
    local x,y,z = Logic.EntityGetPos(eID1)
    if Logic.IsBuilding(eID1) == 1 then
        x,y = Logic.GetBuildingApproachPosition(eID1)
    end
    local Sector1 = Logic.GetPlayerSectorAtPosition(self.PlayerID, x, y)
    local x,y,z = Logic.EntityGetPos(eID2)
    if Logic.IsBuilding(eID2) == 1 then
        x,y = Logic.GetBuildingApproachPosition(eID2)
    end
    local Sector2 = Logic.GetPlayerSectorAtPosition(self.PlayerID, x, y)
    if Sector1 ~= Sector2 then
        return true
    end
    return nil
end

function b_Goal_BuildWall:GetMsgKey()
    return "Quest_Create_Wall"
end

function b_Goal_BuildWall:GetIcon()
    return {3,9}
end

function b_Goal_BuildWall:DEBUG(_Quest)
    if not IsExisting(self.EntityName1) or not IsExisting(self.EntityName2) then
        dbg("".._Quest.Identifier.." "..self.Name..": first or second entity does not exist!");
        return true;
    elseif not tonumber(self.PlayerID) or self.PlayerID < 1 or self.PlayerID > 8 then
        dbg("".._Quest.Identifier.." "..self.Name..": got an invalid playerID!");
        return true;
    end

    if GetDiplomacyState(_Quest.ReceivingPlayer, self.PlayerID) > -1 and not self.WarningPrinted then
        warn("".._Quest.Identifier.." "..self.Name..": player %d is neighter enemy or unknown to quest receiver!");
        self.WarningPrinted = true;
    end
    return false;
end

Core:RegisterBehavior(b_Goal_BuildWall);

-- -------------------------------------------------------------------------- --

---
-- Ein bestimmtes Territorium muss vom Auftragnehmer eingenommen werden.
--
-- @param _Territory Territorium-ID oder Territoriumname
-- @return Table mit Behavior
-- @within Goal
--
function Goal_Claim(...)
    return b_Goal_Claim:new(...)
end

b_Goal_Claim = {
    Name = "Goal_Claim",
    Description = {
        en = "Goal: Claim a territory",
        de = "Ziel: Erobere ein Territorium",
    },
    Parameter = {
        { ParameterType.TerritoryName, en = "Territory", de = "Territorium" },
    },
}

function b_Goal_Claim:GetGoalTable(_Quest)
    return { Objective.Claim, 1, self.TerritoryID }
end

function b_Goal_Claim:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.TerritoryID = tonumber(_Parameter)
        if not self.TerritoryID then
            self.TerritoryID = GetTerritoryIDByName(_Parameter)
        end
    end
end

function b_Goal_Claim:GetMsgKey()
    return "Quest_Claim_Territory"
end

Core:RegisterBehavior(b_Goal_Claim);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss eine Menge an Territorien besitzen.
--
-- Das Heimatterritorium des Spielers wird mitgezählt!
--
-- @param _Amount Anzahl Territorien
-- @return Table mit Behavior
-- @within Goal
--
function Goal_ClaimXTerritories(...)
    return b_Goal_ClaimXTerritories:new(...)
end

b_Goal_ClaimXTerritories = {
    Name = "Goal_ClaimXTerritories",
    Description = {
        en = "Goal: Claim the given number of territories, all player territories are counted",
        de = "Ziel: Erobere die angegebene Anzahl Territorien, alle spielereigenen Territorien werden gezählt",
    },
    Parameter = {
        { ParameterType.Number, en = "Territories" , de = "Territorien" }
    },
}

function b_Goal_ClaimXTerritories:GetGoalTable(_Quest)
    return { Objective.Claim, 2, self.TerritoriesToClaim }
end

function b_Goal_ClaimXTerritories:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.TerritoriesToClaim = _Parameter * 1
    end
end

function b_Goal_ClaimXTerritories:GetMsgKey()
    return "Quest_Claim_Territory"
end

Core:RegisterBehavior(b_Goal_ClaimXTerritories);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss auf dem Territorium einen Entitytyp erstellen.
--
-- @param _Type      Typ des Entity
-- @param _Amount    Menge an Entities
-- @param _Territory Territorium
-- @return Table mit Behavior
-- @within Goal
--
function Goal_Create(...)
    return b_Goal_Create:new(...);
end

b_Goal_Create = {
    Name = "Goal_Create",
    Description = {
        en = "Goal: Create Buildings/Units on a specified territory",
        de = "Ziel: Erstelle Einheiten/Gebäude auf einem bestimmten Territorium.",
    },
    Parameter = {
        { ParameterType.Entity, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
        { ParameterType.TerritoryNameWithUnknown, en = "Territory", de = "Territorium" },
    },
}

function b_Goal_Create:GetGoalTable(_Quest)
    return { Objective.Create, assert( Entities[self.EntityName] ), self.Amount, self.TerritoryID  }
end

function b_Goal_Create:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.EntityName = _Parameter
    elseif (_Index == 1) then
        self.Amount = _Parameter * 1
    elseif (_Index == 2) then
        self.TerritoryID = tonumber(_Parameter)
        if not self.TerritoryID then
            self.TerritoryID = GetTerritoryIDByName(_Parameter)
        end
    end
end

function b_Goal_Create:GetMsgKey()
    return Logic.IsEntityTypeInCategory( Entities[self.EntityName], EntityCategories.AttackableBuilding ) == 1 and "Quest_Create_Building" or "Quest_Create_Unit"
end

Core:RegisterBehavior(b_Goal_Create);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss eine Menge von Rohstoffen produzieren.
--
-- @param _Type   Typ des Rohstoffs
-- @param _Amount Menge an Rohstoffen
-- @return Table mit Behavior
-- @within Goal
--
function Goal_Produce(...)
    return b_Goal_Produce:new(...);
end

b_Goal_Produce = {
    Name = "Goal_Produce",
    Description = {
        en = "Goal: Produce an amount of goods",
        de = "Ziel: Produziere eine Anzahl einer bestimmten Ware.",
    },
    Parameter = {
        { ParameterType.RawGoods, en = "Type of good", de = "Ressourcentyp" },
        { ParameterType.Number, en = "Amount of good", de = "Anzahl der Ressource" },
    },
}

function b_Goal_Produce:GetGoalTable(_Quest)
    local GoodType = Logic.GetGoodTypeID(self.GoodTypeName)
    return { Objective.Produce, GoodType, self.GoodAmount }
end

function b_Goal_Produce:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.GoodTypeName = _Parameter
    elseif (_Index == 1) then
        self.GoodAmount = _Parameter * 1
    end
end

function b_Goal_Produce:GetMsgKey()
    return "Quest_Produce"
end

Core:RegisterBehavior(b_Goal_Produce);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss eine bestimmte Menge einer Ware erreichen.
--
-- @param _Type     Typ der Ware
-- @param _Amount   Menge an Waren
-- @param _Relation Mengenrelation
-- @return Table mit Behavior
-- @within Goal
--
function Goal_GoodAmount(...)
    return b_Goal_GoodAmount:new(...);
end

b_Goal_GoodAmount = {
    Name = "Goal_GoodAmount",
    Description = {
        en = "Goal: Obtain an amount of goods - either by trading or producing them",
        de = "Ziel: Beschaffe eine Anzahl Waren - entweder durch Handel oder durch eigene Produktion.",
    },
    Parameter = {
        { ParameterType.Custom, en = "Type of good", de = "Warentyp" },
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
        { ParameterType.Custom, en = "Relation", de = "Relation" },
    },
}

function b_Goal_GoodAmount:GetGoalTable(_Quest)
    local GoodType = Logic.GetGoodTypeID(self.GoodTypeName)
    return { Objective.Produce, GoodType, self.GoodAmount, self.bRelSmallerThan }
end

function b_Goal_GoodAmount:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.GoodTypeName = _Parameter
    elseif (_Index == 1) then
        self.GoodAmount = _Parameter * 1
    elseif  (_Index == 2) then
        self.bRelSmallerThan = _Parameter == "<" or tostring(_Parameter) == "true"
    end
end

function b_Goal_GoodAmount:GetCustomData( _Index )
    local Data = {}
    if _Index == 0 then
        for k, v in pairs( Goods ) do
            if string.find( k, "^G_" ) then
                table.insert( Data, k )
            end
        end
        table.sort( Data )
    elseif _Index == 2 then
        table.insert( Data, ">=" )
        table.insert( Data, "<" )
    else
        assert( false )
    end
    return Data
end

Core:RegisterBehavior(b_Goal_GoodAmount);

-- -------------------------------------------------------------------------- --

---
-- Die Siedler des Spielers dürfen nicht aufgrund des Bedürfnisses streiken.
--
-- <u>Bedürfnisse</u>
-- <ul>
-- <li>Clothes: Kleidung</li>
-- <li>Entertainment: Unterhaltung</li>
-- <li>Nutrition: Nahrung</li>
-- <li>Hygiene: Hygiene</li>
-- <li>Medicine: Medizin</li>
-- </ul>
--
-- @param _PlayerID ID des Spielers
-- @param _Need     Bedürfnis
-- @return Table mit Behavior
-- @within Goal
--
function Goal_SatisfyNeed(...)
    return b_Goal_SatisfyNeed:new(...);
end

b_Goal_SatisfyNeed = {
    Name = "Goal_SatisfyNeed",
    Description = {
        en = "Goal: Satisfy a need",
        de = "Ziel: Erfuelle ein Beduerfnis",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Need, en = "Need", de = "Beduerfnis" },
    },
}

function b_Goal_SatisfyNeed:GetGoalTable(_Quest)
    return { Objective.SatisfyNeed, self.PlayerID, assert( Needs[self.Need] ) }

end

function b_Goal_SatisfyNeed:AddParameter(_Index, _Parameter)

    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 1) then
        self.Need = _Parameter
    end

end

function b_Goal_SatisfyNeed:GetMsgKey()
    local tMapping = {
        [Needs.Clothes] = "Quest_SatisfyNeed_Clothes",
        [Needs.Entertainment] = "Quest_SatisfyNeed_Entertainment",
        [Needs.Nutrition] = "Quest_SatisfyNeed_Food",
        [Needs.Hygiene] = "Quest_SatisfyNeed_Hygiene",
        [Needs.Medicine] = "Quest_SatisfyNeed_Medicine",
    }

    local Key = tMapping[Needs[self.Need]]
    if Key then
        return Key
    end

    -- No default message
end

Core:RegisterBehavior(b_Goal_SatisfyNeed);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss eine Menge an Siedlern in der Stadt haben.
--
-- @param _Amount Menge an Siedlern
-- @return Table mit Behavior
-- @within Goal
--
function Goal_SettlersNumber(...)
    return b_Goal_SettlersNumber:new(...);
end

b_Goal_SettlersNumber = {
    Name = "Goal_SettlersNumber",
    Description = {
        en = "Goal: Get a given amount of settlers",
        de = "Ziel: Erreiche eine bestimmte Anzahl Siedler.",
    },
    Parameter = {
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
    },
}

function b_Goal_SettlersNumber:GetGoalTable()
    return {Objective.SettlersNumber, 1, self.SettlersAmount }
end

function b_Goal_SettlersNumber:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.SettlersAmount = _Parameter * 1
    end
end

function b_Goal_SettlersNumber:GetMsgKey()
    return "Quest_NumberSettlers"
end

Core:RegisterBehavior(b_Goal_SettlersNumber);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss eine Menge von Ehefrauen in der Stadt haben.
--
-- @param _Amount Menge an Ehefrauen
-- @return Table mit Behavior
-- @within Goal
--
function Goal_Spouses(...)
    return b_Goal_Spouses:new(...);    
end

b_Goal_Spouses = {
    Name = "Goal_Spouses",
    Description = {
        en = "Goal: Get a given amount of spouses",
        de = "Ziel: Erreiche eine bestimmte Ehefrauenanzahl",
    },
    Parameter = {
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
    },
}

function b_Goal_Spouses:GetGoalTable()
    return {Objective.Spouses, self.SpousesAmount }
end

function b_Goal_Spouses:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.SpousesAmount = _Parameter * 1
    end
end

function b_Goal_Spouses:GetMsgKey()
    return "Quest_NumberSpouses"
end

Core:RegisterBehavior(b_Goal_Spouses);

-- -------------------------------------------------------------------------- --

---
-- Ein Spieler muss eine Menge an Soldaten haben.
--
-- <u>Relationen</u>
-- <ul>
-- <li>>= - Anzahl als Mindestmenge</li>
-- <li>< - Weniger als Anzahl</li>
-- </ul>
--
-- @param _PlayerID ID des Spielers
-- @param _Relation Mengenrelation
-- @param _Amount   Menge an Soldaten
-- @return Table mit Behavior
-- @within Goal
--
function Goal_SoldierCount(...)
    return b_Goal_SoldierCount:new(...);
end

b_Goal_SoldierCount = {
    Name = "Goal_SoldierCount",
    Description = {
        en = "Goal: Create a specified number of soldiers",
        de = "Ziel: Erreiche eine Anzahl grösser oder kleiner der angegebenen Menge Soldaten.",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Custom, en = "Relation", de = "Relation" },
        { ParameterType.Number, en = "Number of soldiers", de = "Anzahl Soldaten" },
    },
}

function b_Goal_SoldierCount:GetGoalTable(_Quest)
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_SoldierCount:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 1) then
        self.bRelSmallerThan = tostring(_Parameter) == "true" or tostring(_Parameter) == "<"
    elseif (_Index == 2) then
        self.NumberOfUnits = _Parameter * 1
    end
end

function b_Goal_SoldierCount:CustomFunction(_Quest)
    if not _Quest.QuestDescription or _Quest.QuestDescription == "" then
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en"
        local caption = (lang == "de" and "SOLDATENANZAHL {cr}Partei: ") or
                            "SOLDIERS {cr}faction: "
        local relation = tostring(self.bRelSmallerThan);
        local relationText = {
            ["true"]  = {de = "Weniger als", en = "Less than"},
            ["false"] = {de = "Mindestens", en = "At least"},
        };
        local party = GetPlayerName(self.PlayerID);
        if party == "" or party == nil then
            party = ((lang == "de" and "Spieler ") or "Player ") .. self.PlayerID
        end
        local text = "{center}" .. caption .. party .. "{cr}{cr}" .. relationText[relation][lang] .. " "..self.NumberOfUnits;
        Core:ChangeCustomQuestCaptionText(text, _Quest);
    end

    local NumSoldiers = Logic.GetCurrentSoldierCount( self.PlayerID )
    if ( self.bRelSmallerThan and NumSoldiers < self.NumberOfUnits ) then
        return true
    elseif ( not self.bRelSmallerThan and NumSoldiers >= self.NumberOfUnits ) then
        return true
    end
    return nil
end

function b_Goal_SoldierCount:GetCustomData( _Index )
    local Data = {}
    if _Index == 1 then

        table.insert( Data, ">=" )
        table.insert( Data, "<" )

    else
        assert( false )
    end
    return Data
end

function b_Goal_SoldierCount:GetIcon()
    return {7,11}
end

function b_Goal_SoldierCount:GetMsgKey()
    return "Quest_Create_Unit"
end

function b_Goal_SoldierCount:DEBUG(_Quest)
    if tonumber(self.NumberOfUnits) == nil or self.NumberOfUnits < 0 then
        dbg("".._Quest.Identifier.." "..self.Name..": amount can not be below 0!");
        return true;
    elseif tonumber(self.PlayerID) == nil or self.PlayerID < 1 or self.PlayerID > 8 then
        dbg("".._Quest.Identifier.." "..self.Name..": got an invalid playerID!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Goal_SoldierCount);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss wenigstens einen bestimmten Titel erreichen.
--
-- @param _Title Titel, der erreicht werden muss
-- @return Table mit Behavior
-- @within Goal
--
function Goal_KnightTitle(...)
    return b_Goal_KnightTitle:new(...);
end

b_Goal_KnightTitle = {
    Name = "Goal_KnightTitle",
    Description = {
        en = "Goal: Reach a specified knight title",
        de = "Ziel: Erreiche einen vorgegebenen Titel",
    },
    Parameter = {
        { ParameterType.Custom, en = "Knight title", de = "Titel" },
    },
}

function b_Goal_KnightTitle:GetGoalTable()
    return {Objective.KnightTitle, assert( KnightTitles[self.KnightTitle] ) }
end

function b_Goal_KnightTitle:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.KnightTitle = _Parameter
    end
end

function b_Goal_KnightTitle:GetMsgKey()
    return "Quest_KnightTitle"
end

function b_Goal_KnightTitle:GetCustomData( _Index )
    return {"Knight", "Mayor", "Baron", "Earl", "Marquees", "Duke", "Archduke"}
end

Core:RegisterBehavior(b_Goal_KnightTitle);

-- -------------------------------------------------------------------------- --

---
-- Der angegebene Spieler muss mindestens die Menge an Festen feiern.
--
-- @param _PlayerID ID des Spielers
-- @param _Amount   Menge an Festen
-- @return Table mit Behavior
-- @within Goal
--
function Goal_Festivals(...)
    return b_Goal_Festivals:new(...);
end

b_Goal_Festivals = {
    Name = "Goal_Festivals",
    Description = {
        en = "Goal: The player has to start the given number of festivals.",
        de = "Ziel: Der Spieler muss eine gewisse Anzahl Feste gestartet haben.",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Number, en = "Number of festivals", de = "Anzahl Feste" }
    }
};

function b_Goal_Festivals:GetGoalTable()
    return { Objective.Custom2, {self, self.CustomFunction} };
end

function b_Goal_Festivals:AddParameter(_Index, _Parameter)
    if _Index == 0 then
        self.PlayerID = tonumber(_Parameter);
    else
        assert(_Index == 1, "Error in " .. self.Name .. ": AddParameter: Index is invalid.");
        self.NeededFestivals = tonumber(_Parameter);
    end
end

function b_Goal_Festivals:CustomFunction(_Quest)
    if not _Quest.QuestDescription or _Quest.QuestDescription == "" then
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en"
        local caption = (lang == "de" and "FESTE FEIERN {cr}{cr}Partei: ") or
                            "HOLD PARTIES {cr}{cr}faction: "
        local amount  = (lang == "de" and "Anzahl: ") or "Amount: "
        local party = GetPlayerName(self.PlayerID);
        if party == "" or party == nil then
            party = ((lang == "de" and "Spieler ") or "Player ") .. self.PlayerID
        end
        local text = "{center}" .. caption .. party .. "{cr}{cr}" .. amount .. " "..self.NeededFestivals;
        Core:ChangeCustomQuestCaptionText(text, _Quest);
    end

    if Logic.GetStoreHouse( self.PlayerID ) == 0  then
        return false
    end
    local tablesOnFestival = {Logic.GetPlayerEntities(self.PlayerID, Entities.B_TableBeer, 5,0)}
    local amount = 0
    for k=2, #tablesOnFestival do
        local tableID = tablesOnFestival[k]
        if Logic.GetIndexOnOutStockByGoodType(tableID, Goods.G_Beer) ~= -1 then
            local goodAmountOnMarketplace = Logic.GetAmountOnOutStockByGoodType(tableID, Goods.G_Beer)
            amount = amount + goodAmountOnMarketplace
        end
    end
    if not self.FestivalStarted and amount > 0 then
        self.FestivalStarted = true
        self.FestivalCounter = (self.FestivalCounter and self.FestivalCounter + 1) or 1
        if self.FestivalCounter >= self.NeededFestivals then
            self.FestivalCounter = nil
            return true
        end
    elseif amount == 0 then
        self.FestivalStarted = false
    end
end

function b_Goal_Festivals:DEBUG(_Quest)
    if Logic.GetStoreHouse( self.PlayerID ) == 0 then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": Player " .. self.PlayerID .. " is dead :-(")
        return true
    elseif GetPlayerCategoryType(self.PlayerID) ~= PlayerCategories.City then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ":  Player "..  self.PlayerID .. " is no city")
        return true
    elseif self.NeededFestivals < 0 then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": Number of Festivals is negative")
        return true
    end
    return false
end

function b_Goal_Festivals:Reset()
    self.FestivalCounter = nil
    self.FestivalStarted = nil
end

function b_Goal_Festivals:GetIcon()
    return {4,15}
end

Core:RegisterBehavior(b_Goal_Festivals)

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss eine Einheit gefangen nehmen.
--
-- @param _ScriptName Ziel
-- @return Table mit Behavior
-- @within Goal
--
function Goal_Capture(...)
    return b_Goal_Capture:new(...)
end

b_Goal_Capture = {
    Name = "Goal_Capture",
    Description = {
        en = "Goal: Capture a cart.",
        de = "Ziel: Ein Karren muss erobert werden.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
    },
}

function b_Goal_Capture:GetGoalTable(_Quest)
    return { Objective.Capture, 1, { self.ScriptName } }
end

function b_Goal_Capture:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptName = _Parameter
    end
end

function b_Goal_Capture:GetMsgKey()
   local ID = GetID(self.ScriptName)
   if Logic.IsEntityAlive(ID) then
        ID = Logic.GetEntityType( ID )
        if ID and ID ~= 0 then
            if Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableMerchant ) == 1 then
                return "Quest_Capture_Cart"

            elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.SiegeEngine ) == 1 then
                return "Quest_Capture_SiegeEngine"

            elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.Worker ) == 1
                or Logic.IsEntityTypeInCategory( ID, EntityCategories.Spouse ) == 1
                or Logic.IsEntityTypeInCategory( ID, EntityCategories.Hero ) == 1 then

                return "Quest_Capture_VIPOfPlayer"

            end
        end
    end
end

Core:RegisterBehavior(b_Goal_Capture);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss eine Menge von Einheiten eines Typs von einem
-- Spieler gefangen nehmen.
--
-- @param _Typ      Typ, der gefangen werden soll
-- @param _Amount   Menge an Einheiten
-- @param _PlayerID Besitzer der Einheiten
-- @return Table mit Behavior
-- @within Goal
--
function Goal_CaptureType(...)
    return b_Goal_CaptureType:new(...)
end

b_Goal_CaptureType = {
    Name = "Goal_CaptureType",
    Description = {
        en = "Goal: Capture specified entity types",
        de = "Ziel: Nimm bestimmte Entitätstypen gefangen",
    },
    Parameter = {
        { ParameterType.Custom,     en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number,     en = "Amount", de = "Anzahl" },
        { ParameterType.PlayerID,     en = "Player", de = "Spieler" },
    },
}

function b_Goal_CaptureType:GetGoalTable(_Quest)
    return { Objective.Capture, 2, Entities[self.EntityName], self.Amount, self.PlayerID }
end

function b_Goal_CaptureType:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.EntityName = _Parameter
    elseif (_Index == 1) then
        self.Amount = _Parameter * 1
    elseif (_Index == 2) then
        self.PlayerID = _Parameter * 1
    end
end

function b_Goal_CaptureType:GetCustomData( _Index )
    local Data = {}
    if _Index == 0 then
        for k, v in pairs( Entities ) do
            if string.find( k, "^U_.+Cart" ) or Logic.IsEntityTypeInCategory( v, EntityCategories.AttackableMerchant ) == 1 then
                table.insert( Data, k )
            end
        end
        table.sort( Data )
    elseif _Index == 2 then
        for i = 0, 8 do
            table.insert( Data, i )
        end
    else
        assert( false )
    end
    return Data
end

function b_Goal_CaptureType:GetMsgKey()

    local ID = self.EntityName
    if Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableMerchant ) == 1 then
        return "Quest_Capture_Cart"

    elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.SiegeEngine ) == 1 then
        return "Quest_Capture_SiegeEngine"

    elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.Worker ) == 1
        or Logic.IsEntityTypeInCategory( ID, EntityCategories.Spouse ) == 1
        or Logic.IsEntityTypeInCategory( ID, EntityCategories.Hero ) == 1 then

        return "Quest_Capture_VIPOfPlayer"
    end
end

Core:RegisterBehavior(b_Goal_CaptureType);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss das angegebene Entity beschützen.
--
-- Gefangennahme (bzw. Besitzerwechsel) oder Zerstörung des Entity werden als
-- Fehlschlag gewertet.
--
-- @param _ScriptName
-- @return Table mit Behavior
-- @within Goal
--
function Goal_Protect(...)
    return b_Goal_Protect:new(...)
end

b_Goal_Protect = {
    Name = "Goal_Protect",
    Description = {
        en = "Goal: Protect an entity (entity needs a script name",
        de = "Ziel: Beschuetze eine Entität (Entität benötigt einen Skriptnamen)",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
    },
}

function b_Goal_Protect:GetGoalTable()
    return {Objective.Protect, { self.ScriptName }}
end

function b_Goal_Protect:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptName = _Parameter
    end
end

function b_Goal_Protect:GetMsgKey()
    if Logic.IsEntityAlive(self.ScriptName) then
        local ID = GetID(self.ScriptName)
        if ID and ID ~= 0 then
            ID = Logic.GetEntityType( ID )
            if ID and ID ~= 0 then
                if Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableBuilding ) == 1 then
                    return "Quest_Protect_Building"

                elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.SpecialBuilding ) == 1 then
                    local tMapping = {
                        [PlayerCategories.City]        = "Quest_Protect_City",
                        [PlayerCategories.Cloister]    = "Quest_Protect_Cloister",
                        [PlayerCategories.Village]    = "Quest_Protect_Village",
                    }

                    local PlayerCategory = GetPlayerCategoryType( Logic.EntityGetPlayer(GetID(self.ScriptName)) )
                    if PlayerCategory then
                        local Key = tMapping[PlayerCategory]
                        if Key then
                            return Key
                        end
                    end

                    return "Quest_Protect_Building"

                elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.Hero ) == 1 then
                    return "Quest_Protect_Knight"

                elseif Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableMerchant ) == 1 then
                    return "Quest_Protect_Cart"

                end
            end
        end
    end

    return "Quest_Protect"
end

Core:RegisterBehavior(b_Goal_Protect);

-- -------------------------------------------------------------------------- --

---
-- Der AUftragnehmer muss eine Mine mit einem Geologen wieder auffüllen.
--
-- <b>Achtung:</b> Ausschließlich im Reich des Ostens verfügbar!
--
-- @param _ScriptName Skriptname der Mine
-- @return Table mit Behavior
-- @within Goal
--
function Goal_Refill(...)
    return b_Goal_Refill:new(...)
end

b_Goal_Refill = {
    Name = "Goal_Refill",
    Description = {
        en = "Goal: Refill an object using a geologist",
        de = "Ziel: Eine Mine soll durch einen Geologen wieder aufgefuellt werden.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
    },
   RequiresExtraNo = 1,
}

function b_Goal_Refill:GetGoalTable()
    return { Objective.Refill, { GetID(self.ScriptName) } }
end

function b_Goal_Refill:GetIcon()
    return {8,1,1}
end

function b_Goal_Refill:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptName = _Parameter
    end
end

Core:RegisterBehavior(b_Goal_Refill);

-- -------------------------------------------------------------------------- --

---
-- Der Auftragnehmer muss eine Menge an Rohstoffen in einer Mine erreichen.
--
-- <u>Relationen</u>
-- <ul>
-- <li>> - Mehr als Anzahl</li>
-- <li>< - Weniger als Anzahl</li>
-- </ul>
--
-- @param _ScriptName Skriptname der Mine
-- @param _Relation   Mengenrelation
-- @param _Amount     Menge an Rohstoffen
-- @return Table mit Behavior
-- @within Goal
--
function Goal_ResourceAmount(...)
    return b_Goal_ResourceAmount:new(...)
end

b_Goal_ResourceAmount = {
    Name = "Goal_ResourceAmount",
    Description = {
        en = "Goal: Reach a specified amount of resources in a doodad",
        de = "Ziel: In einer Mine soll weniger oder mehr als eine angegebene Anzahl an Rohstoffen sein.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
        { ParameterType.Custom, en = "Relation", de = "Relation" },
        { ParameterType.Number, en = "Amount", de = "Menge" },
    },
}

function b_Goal_ResourceAmount:GetGoalTable(_Quest)
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_ResourceAmount:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptName = _Parameter
    elseif (_Index == 1) then
        self.bRelSmallerThan = _Parameter == "<"
    elseif (_Index == 2) then
        self.Amount = _Parameter * 1
    end
end

function b_Goal_ResourceAmount:CustomFunction(_Quest)
    local ID = GetID(self.ScriptName)
    if ID and ID ~= 0 and Logic.GetResourceDoodadGoodType(ID) ~= 0 then
        local HaveAmount = Logic.GetResourceDoodadGoodAmount(ID)
        if ( self.bRelSmallerThan and HaveAmount < self.Amount ) or ( not self.bRelSmallerThan and HaveAmount > self.Amount ) then
            return true
        end
    end
    return nil
end

function b_Goal_ResourceAmount:GetCustomData( _Index )
    local Data = {}
    if _Index == 1 then
        table.insert( Data, ">" )
        table.insert( Data, "<" )
    else
        assert( false )
    end
    return Data
end

function b_Goal_ResourceAmount:DEBUG(_Quest)
    if not IsExisting(self.ScriptName) then
        dbg("".._Quest.Identifier.." "..self.Name..": entity '" ..self.ScriptName.. "' does not exist!");
        return true;
    elseif tonumber(self.Amount) == nil or self.Amount < 0 then
        dbg("".._Quest.Identifier.." "..self.Name..": error at amount! (nil or below 0)");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Goal_ResourceAmount);

-- -------------------------------------------------------------------------- --

---
-- Der Quest schlägt sofort fehl.
--
-- @return Table mit Behavior
-- @within Goal
--
function Goal_InstantFailure()
    return b_Goal_InstantFailure:new()
end

b_Goal_InstantFailure = {
    Name = "Goal_InstantFailure",
    Description = {
        en = "Instant failure, the goal returns false.",
        de = "Direkter Misserfolg, das Goal sendet false.",
    },
}

function b_Goal_InstantFailure:GetGoalTable(_Quest)
    return {Objective.DummyFail};
end

Core:RegisterBehavior(b_Goal_InstantFailure);

-- -------------------------------------------------------------------------- --

---
-- Der Quest wird sofort erfüllt. 
--
-- @return Table mit Behavior
-- @within Goal
--
function Goal_InstantSuccess()
    return b_Goal_InstantSuccess:new()
end

b_Goal_InstantSuccess = {
    Name = "Goal_InstantSuccess",
    Description = {
        en = "Instant success, the goal returns true.",
        de = "Direkter Erfolg, das Goal sendet true.",
    },
}

function b_Goal_InstantSuccess:GetGoalTable(_Quest)
    return {Objective.Dummy};
end

Core:RegisterBehavior(b_Goal_InstantSuccess);

-- -------------------------------------------------------------------------- --

---
-- Der Zustand des Quests ändert sich niemals
--
-- @return Table mit Behavior
-- @within Goal
--
function Goal_NoChange()
    return b_Goal_NoChange:new()
end

b_Goal_NoChange = {
    Name = "Goal_NoChange",
    Description = {
        en = "The quest state doesn't change. Use reward functions of other quests to change the state of this quest.",
        de = "Der Questzustand wird nicht verändert. Ein Reward einer anderen Quest sollte den Zustand dieser Quest verändern.",
    },
}

function b_Goal_NoChange:GetGoalTable()
    return { Objective.NoChange }
end

Core:RegisterBehavior(b_Goal_NoChange);

-- -------------------------------------------------------------------------- --

---
-- Führt eine Funktion im Skript als Goal aus.
--
-- Die Funktion muss entweder true, false oder nichts zurückgeben.
-- <ul>
-- <li>true: Erfolgreich abgeschlossen</li>
-- <li>false: Fehlschlag</li>
-- <li>nichts: Zustand unbestimmt</li>
-- </ul>
--
-- @param _FunctionName Name der Funktion
-- @return Table mit Behavior
-- @within Goal
--
function Goal_MapScriptFunction(...)
    return b_Goal_MapScriptFunction:new(...);
end

b_Goal_MapScriptFunction = {
    Name = "Goal_MapScriptFunction",
    Description = {
        en = "Goal: Calls a function within the global map script. Return 'true' means success, 'false' means failure and 'nil' doesn't change anything.",
        de = "Ziel: Ruft eine Funktion im globalen Skript auf, die einen Wahrheitswert zurueckgibt. Rueckgabe 'true' gilt als erfuellt, 'false' als gescheitert und 'nil' ändert nichts.",
    },
    Parameter = {
        { ParameterType.Default, en = "Function name", de = "Funktionsname" },
    },
}

function b_Goal_MapScriptFunction:GetGoalTable(_Quest)
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_MapScriptFunction:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.FuncName = _Parameter
    end
end

function b_Goal_MapScriptFunction:CustomFunction(_Quest)
    return _G[self.FuncName](self, _Quest);
end

function b_Goal_MapScriptFunction:DEBUG(_Quest)
    if not self.FuncName or not _G[self.FuncName] then
        dbg("".._Quest.Identifier.." "..self.Name..": function '" ..self.FuncName.. "' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Goal_MapScriptFunction);

-- -------------------------------------------------------------------------- --

---
-- Eine benutzerdefinierte Variable muss einen bestimmten Wert haben.
--
-- Custom Variables können ausschließlich Zahlen enthalten.
--
-- <p>Vergleichsoperatoren</p>
-- <ul>
-- <li>== - Werte müssen gleich sein</li>
-- <li>~= - Werte müssen ungleich sein</li>
-- <li>> - Variablenwert größer Vergleichswert</li>
-- <li>>= - Variablenwert größer oder gleich Vergleichswert</li>
-- <li>< - Variablenwert kleiner Vergleichswert</li>
-- <li><= - Variablenwert kleiner oder gleich Vergleichswert</li>
-- </ul>
--
-- @param _Name     Name der Variable
-- @param _Relation Vergleichsoperator
-- @param _Value    Wert oder andere Custom Variable mit wert.
-- @return Table mit Behavior
-- @within Goal
--
function Goal_CustomVariables(...)
    return b_Goal_CustomVariables:new(...);
end

b_Goal_CustomVariables = {
    Name = "Goal_CustomVariables",
    Description = {
        en = "Goal: A customised variable has to assume a certain value.",
        de = "Ziel: Eine benutzerdefinierte Variable muss einen bestimmten Wert annehmen.",
    },
    Parameter = {
        { ParameterType.Default, en = "Name of Variable", de = "Variablenname" },
        { ParameterType.Custom,  en = "Relation", de = "Relation" },
        { ParameterType.Default, en = "Value or variable", de = "Wert oder Variable" }
    }
};

function b_Goal_CustomVariables:GetGoalTable()
    return { Objective.Custom2, {self, self.CustomFunction} };
end

function b_Goal_CustomVariables:AddParameter(_Index, _Parameter)
    if _Index == 0 then
        self.VariableName = _Parameter
    elseif _Index == 1 then
        self.Relation = _Parameter
    elseif _Index == 2 then
        local value = tonumber(_Parameter);
        value = (value ~= nil and value) or tostring(_Parameter);
        self.Value = value
    end
end

function b_Goal_CustomVariables:CustomFunction()
    if _G["QSB_CustomVariables_"..self.VariableName] then
        local Value = (type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value];
        if self.Relation == "==" then
            if _G["QSB_CustomVariables_"..self.VariableName] == Value then
                return true;
            end
        elseif self.Relation == "~=" then
            if _G["QSB_CustomVariables_"..self.VariableName] == Value then
                return true;
            end
        elseif self.Relation == "<" then
            if _G["QSB_CustomVariables_"..self.VariableName] < Value then
                return true;
            end
        elseif self.Relation == "<=" then
            if _G["QSB_CustomVariables_"..self.VariableName] <= Value then
                return true;
            end
        elseif self.Relation == ">=" then
            if _G["QSB_CustomVariables_"..self.VariableName] >= Value then
                return true;
            end
        else
            if _G["QSB_CustomVariables_"..self.VariableName] > Value then
                return true;
            end
        end
    end
    return nil;
end

function b_Goal_CustomVariables:GetCustomData( _Index )
    return {"==", "~=", "<=", "<", ">", ">="};
end

function b_Goal_CustomVariables:DEBUG(_Quest)
    local relations = {"==", "~=", "<=", "<", ">", ">="}
    local results    = {true, false, nil}

    if not _G["QSB_CustomVariables_"..self.VariableName] then
        dbg(_Quest.Identifier.." "..self.Name..": variable '"..self.VariableName.."' do not exist!");
        return true;
    elseif not Inside(self.Relation,relations) then
        dbg(_Quest.Identifier.." "..self.Name..": '"..self.Relation.."' is an invalid relation!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Goal_CustomVariables)

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss im Chatdialog ein Passwort eingeben.
--
-- Es können auch mehrere Passwörter verwendet werden. Dazu muss die Liste
-- der Passwörter abgetrennt mit ; angegeben werden.
--
-- <b>Achtung:</b> Ein Passwort darf immer nur aus einem Wort bestehen!
--
-- @param _VarName   Name der Lösungsvariablen
-- @param _Message   Nachricht bei Falscheingabe
-- @param _Passwords Liste der Passwörter
-- @param _Trials    Anzahl versuche (-1 für unendlich)
-- @return Table mit Behavior
-- @within Goal
--
function Goal_InputDialog(...)
    return b_Goal_InputDialog:new(...);
end

b_Goal_InputDialog  = {
    Name = "Goal_InputDialog",
    Description = {
        en = "Goal: Player must type in something. The passwords have to be seperated by ; and whitespaces will be ignored.",
        de = "Ziel: Oeffnet einen Dialog, der Spieler muss Lösungswörter eingeben. Diese sind durch ; abzutrennen. Leerzeichen werden ignoriert.",
    },
    Parameter = {
        {ParameterType.Default, en = "ReturnVariable", de = "Name der Variable" },
        {ParameterType.Default, en = "Message", de = "Nachricht" },
        {ParameterType.Default, en = "Passwords", de = "Lösungswörter" },
        {ParameterType.Number,  en = "Trials Till Correct Password (0 = Forever)", de = "Versuche (0 = unbegrenzt)" },
    }
}

function b_Goal_InputDialog:GetGoalTable(_Quest)
    return { Objective.Custom2, {self, self.CustomFunction}}
end

function b_Goal_InputDialog:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Variable = _Parameter
    elseif (_Index == 1) then
        self.Message = _Parameter
    elseif (_Index == 2) then
        local str = _Parameter;
        self.Password = {};

        str = str;
        str = string.lower(str);
        str = string.gsub(str, " ", "");
        while (string.len(str) > 0)
        do
            local s,e = string.find(str, ";");
            if e then
                table.insert(self.Password, string.sub(str, 1, e-1));
                str = string.sub(str, e+1, string.len(str));
            else
                table.insert(self.Password, str);
                str = "";
            end
        end
    elseif (_Index == 3) then
        self.TryTillCorrect = (_Parameter == nil and -1) or (_Parameter * 1)
    end
end

function b_Goal_InputDialog:CustomFunction(_Quest)
    local function Box( __returnVariable_ )
        if not self.shown then
            self:InitReturnVariable(__returnVariable_)
            self:ShowBox()
            self.shown = true
        end
    end

    if not IsBriefingActive or (IsBriefingActive and IsBriefingActive() == false) then
        if (not self.TryTillCorrect) or (self.TryTillCorrect) == -1 then
            Box( self.Variable, self.Message )
        elseif not self.shown then
            self.TryCounter = self.TryCounter or self.TryTillCorrect
            Box( self.Variable, "" )
            self.TryCounter = self.TryCounter - 1
        end

        if _G[self.Variable] then
            Logic.ExecuteInLuaLocalState([[
                GUI_Chat.Confirm = GUI_Chat.Confirm_Orig_Goal_InputDialog
                GUI_Chat.Confirm_Orig_Goal_InputDialog = nil
                GUI_Chat.Abort = GUI_Chat.Abort_Orig_Goal_InputDialog
                GUI_Chat.Abort_Orig_Goal_InputDialog = nil
            ]]);

            if self.Password then

                self.shown = nil
                _G[self.Variable] = _G[self.Variable];
                _G[self.Variable] = string.lower(_G[self.Variable]);
                _G[self.Variable] = string.gsub(_G[self.Variable], " ", "");
                if Inside(_G[self.Variable], self.Password) then
                    return true
                elseif self.TryTillCorrect and ( self.TryTillCorrect == -1 or self.TryCounter > 0 ) then
                    Logic.DEBUG_AddNote(self.Message);
                    _G[self.Variable] = nil
                    return
                else
                    Logic.DEBUG_AddNote(self.Message);
                    _G[self.Variable] = nil
                    return false
                end
            end
            return true
        end
    end
end

function b_Goal_InputDialog:ShowBox()
    Logic.ExecuteInLuaLocalState([[
        Input.ChatMode()
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput",1)
        XGUIEng.SetText("/InGame/Root/Normal/ChatInput/ChatInput", "")
        XGUIEng.SetFocus("/InGame/Root/Normal/ChatInput/ChatInput")
    ]])
end

function b_Goal_InputDialog:InitReturnVariable(__string_)
    Logic.ExecuteInLuaLocalState([[
        GUI_Chat.Abort_Orig_Goal_InputDialog = GUI_Chat.Abort
        GUI_Chat.Confirm_Orig_Goal_InputDialog = GUI_Chat.Confirm

        GUI_Chat.Confirm = function()
            local _variable = "]]..__string_..[["
            Input.GameMode()

            XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput",0)
            local ChatMessage = XGUIEng.GetText("/InGame/Root/Normal/ChatInput/ChatInput")
            g_Chat.JustClosed = 1
            GUI.SendScriptCommand("_G[ \"".._variable.."\" ] = \""..ChatMessage.."\"")
        end

        GUI_Chat.Abort = function() end
    ]])
end

function b_Goal_InputDialog:DEBUG(_Quest)
    if tonumber(self.TryTillCorrect) == nil or self.TryTillCorrect == 0 then
        local text = string.format("%s %s: TryTillCorrect is nil or 0!",_Quest.Identifier,self.Name);
        dbg(text);
        return true;
    elseif type(self.Message) ~= "string" then
        local text = string.format("%s %s: Message is not valid!",_Quest.Identifier,self.Name);
        dbg(text);
        return true;
    elseif type(self.Variable) ~= "string" then
        local text = string.format("%s %s: Variable is not valid!",_Quest.Identifier,self.Name);
        dbg(text);
        return true;
    end

    for k,v in pairs(self.Password) do
        if type(v) ~= "string" then
            local text = string.format("%s %s: at least 1 password is not valid!",_Quest.Identifier,self.Name);
            dbg(text);
            return true;
        end
    end
    return false;
end

function b_Goal_InputDialog:GetIcon()
    return {12,2}
end

function b_Goal_InputDialog:Reset()
    _G[self.Variable] = nil;
    self.TryCounter = nil;
    self.shown = nil;
end

Core:RegisterBehavior(b_Goal_InputDialog);

-- -------------------------------------------------------------------------- --

---
-- Lässt den Spieler zwischen zwei Antworten wählen.
--
-- Dabei kann zwischen den Labels Ja/Nein und Ok/Abbrechen gewählt werden.
--
-- <b>Hinweis:</b> Es können nur geschlossene Fragen gestellt werden. Dialoge
-- müssen also immer mit Ja oder Nein beantwortbar sein oder auf Okay und
-- Abbrechen passen.
--
-- @param _Title  Fenstertitel
-- @param _Text   Fenstertext
-- @param _Labels Label der Buttons
-- @return Table mit Behavior
-- @within Goal
--
function Goal_Decide(...)
    return b_Goal_Decide:new(...);
end

b_Goal_Decide = {
    Name = "Goal_Decide",
    Description = {
        en = "Opens a Yes/No Dialog. Decision = Quest Result",
        de = "Oeffnet einen Ja/Nein-Dialog. Die Entscheidung bestimmt das Quest-Ergebnis (ja=true, nein=false).",
    },
    Parameter = {
        { ParameterType.Default, en = "Text", de = "Text", },
        { ParameterType.Default, en = "Title", de = "Titel", },
        { ParameterType.Custom, en = "Button labels", de = "Button Beschriftung", },
    },
}

function b_Goal_Decide:GetGoalTable()
    return { Objective.Custom2, { self, self.CustomFunction } }
end

function b_Goal_Decide:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Text = _Parameter
    elseif (_Index == 1) then
        self.Title = _Parameter
    elseif (_Index == 2) then
        self.Buttons = (_Parameter == "Ok/Cancel")
    end
end

function b_Goal_Decide:CustomFunction(_Quest)
    if not IsBriefingActive or (IsBriefingActive and IsBriefingActive() == false) then
        if not self.LocalExecuted then
            if QSB.DialogActive then
                return;
            end
            QSB.DialogActive = true
            local buttons = (self.Buttons and "true") or "nil"
            self.LocalExecuted = true

            local commandString = [[
                Game.GameTimeSetFactor( GUI.GetPlayerID(), 0 )
                OpenRequesterDialog(%q,
                                    %q,
                                    "Game.GameTimeSetFactor( GUI.GetPlayerID(), 1 ); GUI.SendScriptCommand( 'QSB.DecisionWindowResult = true ')",
                                    %s ,
                                    "Game.GameTimeSetFactor( GUI.GetPlayerID(), 1 ); GUI.SendScriptCommand( 'QSB.DecisionWindowResult = false ')")
            ]];
            local commandString = string.format(commandString, self.Text, "{center} " .. self.Title, buttons)
            Logic.ExecuteInLuaLocalState(commandString);

        end
        local result = QSB.DecisionWindowResult
        if result ~= nil then
            QSB.DecisionWindowResult = nil
            QSB.DialogActive = false;
            return result
        end
    end
end

function b_Goal_Decide:Reset()
    self.LocalExecuted = nil;
end

function b_Goal_Decide:GetIcon()
    return {4,12}
end

function b_Goal_Decide:GetCustomData(_Index)
    if _Index == 2 then
        return { "Yes/No", "Ok/Cancel" }
    end
end

Core:RegisterBehavior(b_Goal_Decide);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler kann durch regelmäßiges Begleichen eines Tributes bessere
-- Diplomatie zu einen Spieler erreichen.
--
-- @param _GoldAmount Menge an Gold
-- @param _Periode    Zahlungsperiode in Monaten
-- @param _Time       Zeitbegrenzung
-- @param _StartMsg   Vorschlagnachricht
-- @param _SuccessMsg Erfolgsnachricht
-- @param _FailureMsg Fehlschlagnachricht
-- @param _Restart    Nach nichtbezahlen neu starten
-- @return Table mit Behavior
-- @within Goal
--
function Goal_TributeDiplomacy(...)
    return b_Goal_TributeDiplomacy:new(...);
end

b_Goal_TributeDiplomacy = {
    Name = "Goal_TributeDiplomacy",
    Description = {
        en = "Goal: AI requests periodical tribute for better Diplomacy",
        de = "Ziel: Die KI fordert einen regelmässigen Tribut fuer bessere Diplomatie. Der Questgeber ist der fordernde Spieler.",
    },
    Parameter = {
        { ParameterType.Number, en = "Amount", de = "Menge", },
        { ParameterType.Custom, en = "Length of Period in month", de = "Monate bis zur nächsten Forderung", },
        { ParameterType.Number, en = "Time to pay Tribut in seconds", de = "Zeit bis zur Zahlung in Sekunden", },
        { ParameterType.Default, en = "Start Message for TributQuest", de = "Startnachricht der Tributquest", },
        { ParameterType.Default, en = "Success Message for TributQuest", de = "Erfolgsnachricht der Tributquest", },
        { ParameterType.Default, en = "Failure Message for TributQuest", de = "Niederlagenachricht der Tributquest", },
        { ParameterType.Custom, en = "Restart if failed to pay", de = "Nicht-bezahlen beendet die Quest", },
    },
}

function b_Goal_TributeDiplomacy:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_TributeDiplomacy:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Amount = _Parameter * 1
    elseif (_Index == 1) then
        self.PeriodLength = _Parameter * 150
    elseif (_Index == 2) then
        self.TributTime = _Parameter * 1
    elseif (_Index == 3) then
        self.StartMsg = _Parameter
    elseif (_Index == 4) then
        self.SuccessMsg = _Parameter
    elseif (_Index == 5) then
        self.FailureMsg = _Parameter
    elseif (_Index == 6) then
        self.RestartAtFailure = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Goal_TributeDiplomacy:CustomFunction(_Quest)
    if not self.Time then
        if self.PeriodLength - 150 < self.TributTime then
            Logic.DEBUG_AddNote("b_Goal_TributeDiplomacy: TributTime too long")
        end
    end
    if not self.QuestStarted then
        self.QuestStarted = QuestTemplate:New(_Quest.Identifier.."TributeBanditQuest" , _Quest.SendingPlayer, _Quest.ReceivingPlayer,
                                    {{ Objective.Deliver, {Goods.G_Gold, self.Amount}}},
                                    {{ Triggers.Time, 0 }},
                                    self.TributTime,
                                    nil, nil, nil, nil, true, true,
                                    nil,
                                    self.StartMsg,
                                    self.SuccessMsg,
                                    self.FailureMsg
                                    )
        self.Time = Logic.GetTime()
    end
    local TributeQuest = Quests[self.QuestStarted]
    if self.QuestStarted and TributeQuest.State == QuestState.Over and not self.RestartQuest then
        if TributeQuest.Result ~= QuestResult.Success then
            SetDiplomacyState( _Quest.ReceivingPlayer, _Quest.SendingPlayer, DiplomacyStates.Enemy)
            if not self.RestartAtFailure then
                return false
            end
        else
            SetDiplomacyState( _Quest.ReceivingPlayer, _Quest.SendingPlayer, DiplomacyStates.TradeContact)
        end

        self.RestartQuest = true
    end
    local storeHouse = Logic.GetStoreHouse(_Quest.SendingPlayer)
    if (storeHouse == 0 or Logic.IsEntityDestroyed(storeHouse)) then
        if self.QuestStarted and Quests[self.QuestStarted].State == QuestState.Active then
            Quests[self.QuestStarted]:Interrupt()
        end
        return true
    end
    if self.QuestStarted and self.RestartQuest and ( (Logic.GetTime() - self.Time) >= self.PeriodLength ) then
        TributeQuest.Objectives[1].Completed = nil
        TributeQuest.Objectives[1].Data[3] = nil
        TributeQuest.Objectives[1].Data[4] = nil
        TributeQuest.Objectives[1].Data[5] = nil
        TributeQuest.Result = nil
        TributeQuest.State = QuestState.NotTriggered
        Logic.ExecuteInLuaLocalState("LocalScriptCallback_OnQuestStatusChanged("..TributeQuest.Index..")")
        Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", QuestTemplate.Loop, 1, 0, { TributeQuest.QueueID })
        self.Time = Logic.GetTime()
        self.RestartQuest = nil
    end
end

function b_Goal_TributeDiplomacy:DEBUG(_Quest)
    if self.Amount < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Amount is negative")
        return true
    end
end

function b_Goal_TributeDiplomacy:Reset()
    self.Time = nil
    self.QuestStarted = nil
    self.RestartQuest = nil
end

function b_Goal_TributeDiplomacy:Interrupt(_Quest)
    if self.QuestStarted and Quests[self.QuestStarted] ~= nil then
        if Quests[self.QuestStarted].State == QuestState.Active then
            Quests[self.QuestStarted]:Interrupt()
        end
    end
end

function b_Goal_TributeDiplomacy:GetCustomData(_index)
    if (_index == 1) then
        return { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"}
    elseif (_index == 6) then
        return { "true", "false" }
    end
end

Core:RegisterBehavior(b_Goal_TributeDiplomacy)

-- -------------------------------------------------------------------------- --

---
-- Erlaubt es dem Spieler ein Territorium zu mieten.
--
-- Zerstört der Spieler den Außenposten, schlägt der Quest fehl und das
-- Territorium wird an den Vermieter übergeben.
--
-- @param _Territory  Name des Territorium
-- @param _PlayerID   PlayerID des Zahlungsanforderer
-- @param _Cost       Menge an Gold
-- @param _Periode    Zahlungsperiode in Monaten
-- @param _Time       Zeitbegrenzung
-- @param _StartMsg   Vorschlagnachricht
-- @param _SuccessMsg Erfolgsnachricht
-- @param _FailMsg    Fehlschlagnachricht
-- @param _HowOften   Anzahl an Zahlungen (0 = endlos)
-- @param _OtherOwner Eroberung durch Dritte beendet Quest
-- @param _Abort      Nach nichtbezahlen abbrechen
-- @return Table mit Behavior
-- @within Goal
--
function Goal_TributeClaim(...)
    return b_Goal_TributeClaim:new(...);
end

b_Goal_TributeClaim = {
    Name = "Goal_TributeClaim",
    Description = {
        en = "Goal: AI requests periodical tribute for a specified Territory",
        de = "Ziel: Die KI fordert einen regelmässigen Tribut fuer ein Territorium. Der Questgeber ist der fordernde Spieler.",
                },
    Parameter = {
        { ParameterType.TerritoryName, en = "Territory", de = "Territorium", },
        { ParameterType.PlayerID, en = "PlayerID", de = "PlayerID", },
        { ParameterType.Number, en = "Amount", de = "Menge", },
        { ParameterType.Custom, en = "Length of Period in month", de = "Monate bis zur nächsten Forderung", },
        { ParameterType.Number, en = "Time to pay Tribut in seconds", de = "Zeit bis zur Zahlung in Sekunden", },
        { ParameterType.Default, en = "Start Message for TributQuest", de = "Startnachricht der Tributquest", },
        { ParameterType.Default, en = "Success Message for TributQuest", de = "Erfolgsnachricht der Tributquest", },
        { ParameterType.Default, en = "Failure Message for TributQuest", de = "Niederlagenachricht der Tributquest", },
        { ParameterType.Number, en = "How often to pay (0 = forerver)", de = "Anzahl der Tributquests (0 = unendlich)", },
        { ParameterType.Custom, en = "Other Owner cancels the Quest", de = "Anderer Spieler kann Quest beenden", },
        { ParameterType.Custom, en = "About if a rate is not payed", de = "Nicht-bezahlen beendet die Quest", },
    },
}

function b_Goal_TributeClaim:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_TributeClaim:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.TerritoryID = GetTerritoryIDByName(_Parameter)
    elseif (_Index == 1) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 2) then
        self.Amount = _Parameter * 1
    elseif (_Index == 3) then
        self.PeriodLength = _Parameter * 150
    elseif (_Index == 4) then
        self.TributTime = _Parameter * 1
    elseif (_Index == 5) then
        self.StartMsg = _Parameter
    elseif (_Index == 6) then
        self.SuccessMsg = _Parameter
    elseif (_Index == 7) then
        self.FailureMsg = _Parameter
    elseif (_Index == 8) then
        self.HowOften = _Parameter * 1
    elseif (_Index == 9) then
        self.OtherOwnerCancels = AcceptAlternativeBoolean(_Parameter)
    elseif (_Index == 10) then
        self.DontPayCancels = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Goal_TributeClaim:CustomFunction(_Quest)
    local Outpost = Logic.GetTerritoryAcquiringBuildingID(self.TerritoryID)
    if IsExisting(Outpost) and GetHealth(Outpost) < 25 then
        SetHealth(Outpost, 60)
    end

    if Logic.GetTerritoryPlayerID(self.TerritoryID) == _Quest.ReceivingPlayer
    or Logic.GetTerritoryPlayerID(self.TerritoryID) == self.PlayerID then
        if self.OtherOwner then
            self:RestartTributeQuest()
            self.OtherOwner = nil
        end
        if not self.Time and self.PeriodLength -20 < self.TributTime then
                Logic.DEBUG_AddNote("b_Goal_TributeClaim: TributTime too long")
        end
        if not self.Quest then
            local QuestID = QuestTemplate:New(_Quest.Identifier.."TributeClaimQuest" , self.PlayerID, _Quest.ReceivingPlayer,
                                        {{ Objective.Deliver, {Goods.G_Gold, self.Amount}}},
                                        {{ Triggers.Time, 0 }},
                                        self.TributTime,
                                        nil, nil, nil, nil, true, true,
                                        nil,
                                        self.StartMsg,
                                        self.SuccessMsg,
                                        self.FailureMsg
                                        )
            self.Quest = Quests[QuestID]
            self.Time = Logic.GetTime()
        else
            if self.Quest.State == QuestState.Over then
                if self.Quest.Result == QuestResult.Failure then
                    if IsExisting(Outpost) then
                        Logic.ChangeEntityPlayerID(Outpost, self.PlayerID);
                    end
                    Logic.SetTerritoryPlayerID(self.TerritoryID, self.PlayerID)
                    self.Time = Logic.GetTime()
                    self.Quest.State = false

                    if self.DontPayCancels then
                        _Quest:Interrupt();
                    end
                else
                    if self.Quest.Result == QuestResult.Success then
                        if Logic.GetTerritoryPlayerID(self.TerritoryID) == self.PlayerID then
                            if IsExisting(Outpost) then
                                Logic.ChangeEntityPlayerID(Outpost, _Quest.ReceivingPlayer);
                            end
                            Logic.SetTerritoryPlayerID(self.TerritoryID, _Quest.ReceivingPlayer)
                        end
                    end
                    if Logic.GetTime() >= self.Time + self.PeriodLength then
                        if self.HowOften and self.HowOften ~= 0 then
                            self.TributeCounter = self.TributeCounter or 0
                            self.TributeCounter = self.TributeCounter + 1
                            if self.TributeCounter >= self.HowOften then
                                return false
                            end
                        end
                        self:RestartTributeQuest()
                    end
                end

            elseif self.Quest.State == false then
                if Logic.GetTime() >= self.Time + self.PeriodLength then
                    self:RestartTributeQuest()
                end
            end
        end
    elseif Logic.GetTerritoryPlayerID(self.TerritoryID) == 0 and self.Quest then
        if self.Quest.State == QuestState.Active then
            self.Quest:Interrupt()
        end
    elseif Logic.GetTerritoryPlayerID(self.TerritoryID) ~= self.PlayerID then
        if self.Quest.State == QuestState.Active then
            self.Quest:Interrupt()
        end
        if self.OtherOwnerCancels then
            _Quest:Interrupt()
        end
        self.OtherOwner = true
    end
    local storeHouse = Logic.GetStoreHouse(self.PlayerID)
    if (storeHouse == 0 or Logic.IsEntityDestroyed(storeHouse)) then
        if self.Quest and self.Quest.State == QuestState.Active then
            self.Quest:Interrupt()
        end
        return true
    end
end

function b_Goal_TributeClaim:DEBUG(_Quest)

    if self.TerritoryID == 0 then
        dbg(_Quest.Identifier .. ": " .. self.Name .. ": Unknown Territory")
        return true
    elseif not self.Quest and Logic.GetStoreHouse(self.PlayerID) == 0 then
        dbg(_Quest.Identifier .. ": " .. self.Name .. ": Player " .. self.PlayerID .. " is dead. :-(")
        return true
    elseif self.Amount < 0 then
        dbg(_Quest.Identifier .. ": " .. self.Name .. ": Amount is negative")
        return true
    elseif self.PeriodLength < 1 or self.PeriodLength > 600 then
        dbg(_Quest.Identifier .. ": " .. self.Name .. ": Period Length is wrong")
        return true
    elseif self.HowOften < 0 then
        dbg(_Quest.Identifier .. ": " .. self.Name .. ": HowOften is negative")
        return true
    end

end

function b_Goal_TributeClaim:Reset()
    self.Quest = nil
    self.Time = nil
    self.OtherOwner = nil
end

function b_Goal_TributeClaim:Interrupt(_Quest)
    if type(self.Quest) == "table" then
        if self.Quest.State == QuestState.Active then
            self.Quest:Interrupt()
        end
    end
end

function b_Goal_TributeClaim:RestartTributeQuest()

    self.Time = Logic.GetTime()
    self.Quest.Objectives[1].Completed = nil
    self.Quest.Objectives[1].Data[3] = nil
    self.Quest.Objectives[1].Data[4] = nil
    self.Quest.Objectives[1].Data[5] = nil
    self.Quest.Result = nil
    self.Quest.State = QuestState.NotTriggered
    Logic.ExecuteInLuaLocalState("LocalScriptCallback_OnQuestStatusChanged("..self.Quest.Index..")")
    Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", QuestTemplate.Loop, 1, 0, { self.Quest.QueueID })

end

function b_Goal_TributeClaim:GetCustomData(_index)

    if (_index == 3) then
        return { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"}
    elseif (_index == 9) or (_index == 10) then
        return { "false", "true" }
    end

end

Core:RegisterBehavior(b_Goal_TributeClaim)

-- -------------------------------------------------------------------------- --
-- Reprisal                                                                   --
-- -------------------------------------------------------------------------- --

---
-- Deaktiviert ein interaktives Objekt
--
-- @param _ScriptName Skriptname des interaktiven Objektes
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_ObjectDeactivate(...)
    return b_Reprisal_ObjectDeactivate:new(...);
end

b_Reprisal_ObjectDeactivate = {
    Name = "Reprisal_ObjectDeactivate",
    Description = {
        en = "Reprisal: Deactivates an interactive object",
        de = "Vergeltung: Deaktiviert ein interaktives Objekt",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Interactive object", de = "Interaktives Objekt" },
    },
}

function b_Reprisal_ObjectDeactivate:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_ObjectDeactivate:AddParameter(_Index, _Parameter)

    if (_Index == 0) then
        self.ScriptName = _Parameter
    end

end

function b_Reprisal_ObjectDeactivate:CustomFunction(_Quest)
    InteractiveObjectDeactivate(self.ScriptName);
end

function b_Reprisal_ObjectDeactivate:DEBUG(_Quest)
    if not Logic.IsInteractiveObject(GetID(self.ScriptName)) then
        warn("".._Quest.Identifier.." "..self.Name..": '" ..self.ScriptName.. "' is not a interactive object!");
        self.WarningPrinted = true;
    end
    local eID = GetID(self.ScriptName);
    if QSB.InitalizedObjekts[eID] and QSB.InitalizedObjekts[eID] == _Quest.Identifier then
        dbg("".._Quest.Identifier.." "..self.Name..": you can not deactivate in the same quest the object is initalized!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_ObjectDeactivate);

-- -------------------------------------------------------------------------- --

---
-- Aktiviert ein interaktives Objekt.
--
-- Der Status bestimmt, wie das objekt aktiviert wird.
-- <ul>
-- <li>0: Kann nur mit Helden aktiviert werden</li>
-- <li>1: Kann immer aktiviert werden</li>
-- </ul>
--
-- @param _ScriptName Skriptname des interaktiven Objektes
-- @param _State Status des Objektes
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_ObjectActivate(...)
    return b_Reprisal_ObjectActivate:new(...);
end

b_Reprisal_ObjectActivate = {
    Name = "Reprisal_ObjectActivate",
    Description = {
        en = "Reprisal: Activates an interactive object",
        de = "Vergeltung: Aktiviert ein interaktives Objekt",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Interactive object",  de = "Interaktives Objekt" },
        { ParameterType.Custom,     en = "Availability",         de = "Nutzbarkeit" },
    },
}

function b_Reprisal_ObjectActivate:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_ObjectActivate:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptName = _Parameter
    elseif (_Index == 1) then
        local parameter = 0
        if _Parameter == "Always" or 1 then
            parameter = 1
        end
        self.UsingState = parameter
    end
end

function b_Reprisal_ObjectActivate:CustomFunction(_Quest)
    InteractiveObjectActivate(self.ScriptName, self.UsingState);
end

function b_Reprisal_ObjectActivate:GetCustomData( _Index )
    if _Index == 1 then
        return {"Knight only", "Always"}
    end
end

function b_Reprisal_ObjectActivate:DEBUG(_Quest)
    if not Logic.IsInteractiveObject(GetID(self.ScriptName)) then
        warn("".._Quest.Identifier.." "..self.Name..": '" ..self.ScriptName.. "' is not a interactive object!");
        self.WarningPrinted = true;
    end
    local eID = GetID(self.ScriptName);
    if QSB.InitalizedObjekts[eID] and QSB.InitalizedObjekts[eID] == _Quest.Identifier then
        dbg("".._Quest.Identifier.." "..self.Name..": you can not activate in the same quest the object is initalized!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_ObjectActivate);

-- -------------------------------------------------------------------------- --

---
-- Der diplomatische Status zwischen Sender und Empfänger verschlechtert sich
-- um eine Stufe.
--
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_DiplomacyDecrease()
    return b_Reprisal_DiplomacyDecrease:new();
end

b_Reprisal_DiplomacyDecrease = {
    Name = "Reprisal_DiplomacyDecrease",
    Description = {
        en = "Reprisal: Diplomacy decreases slightly to another player",
        de = "Vergeltung: Der Diplomatiestatus zum Auftraggeber wird um eine Stufe verringert.",
    },
}

function b_Reprisal_DiplomacyDecrease:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_DiplomacyDecrease:CustomFunction(_Quest)
    local Sender = _Quest.SendingPlayer;
    local Receiver = _Quest.ReceivingPlayer;
    local State = GetDiplomacyState(Receiver, Sender);
    if State > -2 then
        SetDiplomacyState(Receiver, Sender, State-1);
    end
end

function b_Reprisal_DiplomacyDecrease:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    end
end

Core:RegisterBehavior(b_Reprisal_DiplomacyDecrease);

-- -------------------------------------------------------------------------- --

---
-- Änder den Diplomatiestatus zwischen zwei Spielern.
--
-- @param _Party1   ID der ersten Partei
-- @param _Party2   ID der zweiten Partei
-- @param _State    Neuer Diplomatiestatus
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_Diplomacy(...)
    return b_Reprisal_Diplomacy:new(...);
end

b_Reprisal_Diplomacy = {
    Name = "Reprisal_Diplomacy",
    Description = {
        en = "Reprisal: Sets Diplomacy state of two Players to a stated value.",
        de = "Vergeltung: Setzt den Diplomatiestatus zweier Spieler auf den angegebenen Wert.",
    },
    Parameter = {
        { ParameterType.PlayerID,         en = "PlayerID 1", de = "Spieler 1" },
        { ParameterType.PlayerID,         en = "PlayerID 2", de = "Spieler 2" },
        { ParameterType.DiplomacyState,   en = "Relation",   de = "Beziehung" },
    },
}

function b_Reprisal_Diplomacy:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_Diplomacy:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID1 = _Parameter * 1
    elseif (_Index == 1) then
        self.PlayerID2 = _Parameter * 1
    elseif (_Index == 2) then
        self.Relation = DiplomacyStates[_Parameter]
    end
end

function b_Reprisal_Diplomacy:CustomFunction(_Quest)
    SetDiplomacyState(self.PlayerID1, self.PlayerID2, self.Relation);
end

function b_Reprisal_Diplomacy:DEBUG(_Quest)
    if not tonumber(self.PlayerID1) or self.PlayerID1 < 1 or self.PlayerID1 > 8 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": PlayerID 1 is invalid!");
        return true;
    elseif not tonumber(self.PlayerID2) or self.PlayerID2 < 1 or self.PlayerID2 > 8 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": PlayerID 2 is invalid!");
        return true;
    elseif not tonumber(self.Relation) or self.Relation < -2 or self.Relation > 2 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": '"..self.Relation.."' is a invalid diplomacy state!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_Diplomacy);

-- -------------------------------------------------------------------------- --

---
-- Ein benanntes Entity wird zerstört.
--
-- @param _ScriptName Skriptname des Entity
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_DestroyEntity(...)
    return b_Reprisal_DestroyEntity:new(...);
end

b_Reprisal_DestroyEntity = {
    Name = "Reprisal_DestroyEntity",
    Description = {
        en = "Reprisal: Replaces an entity with an invisible script entity, which retains the entities name.",
        de = "Vergeltung: Ersetzt eine Entity mit einer unsichtbaren Script-Entity, die den Namen übernimmt.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity", de = "Entity" },
    },
}

function b_Reprisal_DestroyEntity:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_DestroyEntity:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptName = _Parameter
    end
end

function b_Reprisal_DestroyEntity:CustomFunction(_Quest)
    ReplaceEntity(self.ScriptName, Entities.XD_ScriptEntity);
end

function b_Reprisal_DestroyEntity:DEBUG(_Quest)
    if not IsExisting(self.ScriptName) then
        warn(_Quest.Identifier.." " ..self.Name..": '" ..self.ScriptName.. "' is already destroyed!");
        self.WarningPrinted = true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_DestroyEntity);

-- -------------------------------------------------------------------------- --

---
-- Zerstört einen über die QSB erzeugten Effekt.
--
-- @param _EffectName Name des Effekts
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_DestroyEffect(...)
    return b_Reprisal_DestroyEffect:new(...);
end

b_Reprisal_DestroyEffect = {
    Name = "Reprisal_DestroyEffect",
    Description = {
        en = "Reprisal: Destroys an effect",
        de = "Vergeltung: Zerstört einen Effekt",
    },
    Parameter = {
        { ParameterType.Default, en = "Effect name", de = "Effektname" },
    }
}

function b_Reprisal_DestroyEffect:AddParameter(_Index, _Parameter)
    if _Index == 0 then
        self.EffectName = _Parameter;
    end
end

function b_Reprisal_DestroyEffect:GetReprisalTable()
    return { Reprisal.Custom, { self, self.CustomFunction } };
end

function b_Reprisal_DestroyEffect:CustomFunction(_Quest)
    if not QSB.EffectNameToID[self.EffectName] or not Logic.IsEffectRegistered(QSB.EffectNameToID[self.EffectName]) then
        return;
    end
    Logic.DestroyEffect(QSB.EffectNameToID[self.EffectName]);
end

function b_Reprisal_DestroyEffect:DEBUG(_Quest)
    if not QSB.EffectNameToID[self.EffectName] then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Effect " .. self.EffectName .. " never created")
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_DestroyEffect);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler verliert das Spiel.
--
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_Defeat()
    return b_Reprisal_Defeat:new()
end

b_Reprisal_Defeat = {
    Name = "Reprisal_Defeat",
    Description = {
        en = "Reprisal: The player loses the game.",
        de = "Vergeltung: Der Spieler verliert das Spiel.",
    },
}

function b_Reprisal_Defeat:GetReprisalTable(_Quest)
    return {Reprisal.Defeat};
end

Core:RegisterBehavior(b_Reprisal_Defeat);

-- -------------------------------------------------------------------------- --

---
-- Zeigt die Niederlagedekoration am Quest an.
--
-- Es handelt sich dabei um reine Optik! Der Spieler wird nicht verlieren.
--
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_FakeDefeat()
    return b_Reprisal_FakeDefeat:new();
end

b_Reprisal_FakeDefeat = {
    Name = "Reprisal_FakeDefeat",
    Description = {
        en = "Reprisal: Displays a defeat icon for a quest",
        de = "Vergeltung: Zeigt ein Niederlage Icon fuer eine Quest an",
    },
}

function b_Reprisal_FakeDefeat:GetReprisalTable()
    return { Reprisal.FakeDefeat }
end

-- -------------------------------------------------------------------------- --

---
-- Ein Entity wird durch ein neues anderen Typs ersetzt.
--
-- Das neue Entity übernimmt Skriptname und Ausrichtung des alten Entity.
--
-- @param _Entity Skriptname oder ID des Entity
-- @param _Type   Neuer Typ des Entity
-- @param _Owner  Besitzer des Entity
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_ReplaceEntity(...)
    return b_Reprisal_ReplaceEntity:new(...);
end

b_Reprisal_ReplaceEntity = {
    Name = "Reprisal_ReplaceEntity",
    Description = {
        en = "Reprisal: Replaces an entity with a new one of a different type. The playerID can be changed too.",
        de = "Vergeltung: Ersetzt eine Entity durch eine neue anderen Typs. Es kann auch die Spielerzugehörigkeit geändert werden.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Target", de = "Ziel" },
        { ParameterType.Custom, en = "New Type", de = "Neuer Typ" },
        { ParameterType.Custom, en = "New playerID", de = "Neue Spieler ID" },
    },
}

function b_Reprisal_ReplaceEntity:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_ReplaceEntity:AddParameter(_Index, _Parameter)
   if (_Index == 0) then
        self.ScriptName = _Parameter
    elseif (_Index == 1) then
        self.NewType = _Parameter
    elseif (_Index == 2) then
        self.PlayerID = tonumber(_Parameter);
    end
end

function b_Reprisal_ReplaceEntity:CustomFunction(_Quest)
    local eID = GetID(self.ScriptName);
    local pID = self.PlayerID;
    if pID == Logic.EntityGetPlayer(eID) then
        pID = nil;
    end
    ReplaceEntity(self.ScriptName, Entities[self.NewType], pID);
end

function b_Reprisal_ReplaceEntity:GetCustomData(_Index)
    local Data = {}
    if _Index == 1 then
        for k, v in pairs( Entities ) do
            local name = {"^M_","^XS_","^X_","^XT_","^Z_", "^XB_"}
            local found = false;
            for i=1,#name do
                if k:find(name[i]) then
                    found = true;
                    break;
                end
            end
            if not found then
                table.insert( Data, k );
            end
        end
        table.sort( Data )
    elseif _Index == 2 then
        Data = {"-","0","1","2","3","4","5","6","7","8",}
    end
    return Data
end

function b_Reprisal_ReplaceEntity:DEBUG(_Quest)
    if not Entities[self.NewType] then
        dbg(_Quest.Identifier.." "..self.Name..": got an invalid entity type!");
        return true;
    elseif self.PlayerID ~= nil and (self.PlayerID < 1 or self.PlayerID > 8) then
        dbg(_Quest.Identifier.." "..self.Name..": got an invalid playerID!");
        return true;
    end

    if not IsExisting(self.ScriptName) then
        self.WarningPrinted = true;
        warn(_Quest.Identifier.." "..self.Name..": '" ..self.ScriptName.. "' does not exist!");
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_ReplaceEntity);

-- -------------------------------------------------------------------------- --

---
-- Startet einen Quest neu.
--
-- @param _QuestName Name des Quest
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_QuestRestart(...)
    return b_Reprisal_QuestRestart(...)
end

b_Reprisal_QuestRestart = {
    Name = "Reprisal_QuestRestart",
    Description = {
        en = "Reprisal: Restarts a (completed) quest so it can be triggered and completed again",
        de = "Vergeltung: Startet eine (beendete) Quest neu, damit diese neu ausgelöst und beendet werden kann",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Questname" },
    },
}

function b_Reprisal_QuestRestart:GetReprisalTable(_Quest)
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_QuestRestart:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.QuestName = _Parameter
    end
end

function b_Reprisal_QuestRestart:CustomFunction(_Quest)
    self:ResetQuest();
end

function b_Reprisal_QuestRestart:DEBUG(_Quest)
    if not Quests[GetQuestID(self.QuestName)] then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": quest "..  self.QuestName .. " does not exist!")
        return true
    end
end

function b_Reprisal_QuestRestart:ResetQuest()
    RestartQuestByName(self.QuestName);
end

Core:RegisterBehavior(b_Reprisal_QuestRestart);

-- -------------------------------------------------------------------------- --

---
-- Lässt einen Quest fehlschlagen.
--
-- @param _QuestName Name des Quest
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_QuestFailure(...)
    return b_Reprisal_QuestFailure(...)
end

b_Reprisal_QuestFailure = {
    Name = "Reprisal_QuestFailure",
    Description = {
        en = "Reprisal: Lets another active quest fail",
        de = "Vergeltung: Lässt eine andere aktive Quest fehlschlagen",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Questname" },
    },
}

function b_Reprisal_QuestFailure:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_QuestFailure:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.QuestName = _Parameter
    end
end

function b_Reprisal_QuestFailure:CustomFunction(_Quest)
    FailQuestByName(self.QuestName);
end

function b_Reprisal_QuestFailure:DEBUG(_Quest)
    if not Quests[GetQuestID(self.QuestName)] then
        dbg("".._Quest.Identifier.." "..self.Name..": got an invalid quest!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_QuestFailure);

-- -------------------------------------------------------------------------- --

---
-- Wertet einen Quest als erfolgreich.
--
-- @param _QuestName Name des Quest
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_QuestSuccess(...)
    return b_Reprisal_QuestSuccess(...)
end

b_Reprisal_QuestSuccess = {
    Name = "Reprisal_QuestSuccess",
    Description = {
        en = "Reprisal: Completes another active quest successfully",
        de = "Vergeltung: Beendet eine andere aktive Quest erfolgreich",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Questname" },
    },
}

function b_Reprisal_QuestSuccess:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_QuestSuccess:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.QuestName = _Parameter
    end
end

function b_Reprisal_QuestSuccess:CustomFunction(_Quest)
    WinQuestByName(self.QuestName);
end

function b_Reprisal_QuestSuccess:DEBUG(_Quest)
    if not Quests[GetQuestID(self.QuestName)] then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": quest "..  self.QuestName .. " does not exist!")
        return true
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_QuestSuccess);

-- -------------------------------------------------------------------------- --

---
-- Triggert einen Quest.
--
-- @param _QuestName Name des Quest
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_QuestActivate(...)
    return b_Reprisal_QuestActivate(...)
end

b_Reprisal_QuestActivate = {
    Name = "Reprisal_QuestActivate",
    Description = {
        en = "Reprisal: Activates another quest that is not triggered yet.",
        de = "Vergeltung: Aktiviert eine andere Quest die noch nicht ausgelöst wurde.",
                },
    Parameter = {
        {ParameterType.QuestName, en = "Quest name", de = "Questname", },
    },
}

function b_Reprisal_QuestActivate:GetReprisalTable()
    return {Reprisal.Custom, {self, self.CustomFunction} }
end

function b_Reprisal_QuestActivate:AddParameter(_Index, _Parameter)
    if (_Index==0) then
        self.QuestName = _Parameter
    else
        assert(false, "Error in " .. self.Name .. ": AddParameter: Index is invalid")
    end
end

function b_Reprisal_QuestActivate:CustomFunction(_Quest)
    StartQuestByName(self.QuestName);
end

function b_Reprisal_QuestActivate:DEBUG(_Quest)
    if not IsValidQuest(self.QuestName) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Quest: "..  self.QuestName .. " does not exist")
        return true
    end
end

Core:RegisterBehavior(b_Reprisal_QuestActivate)

-- -------------------------------------------------------------------------- --

---
-- Unterbricht einen Quest.
--
-- @param _QuestName Name des Quest
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_QuestInterrupt(...)
    return b_Reprisal_QuestInterrupt(...)
end

b_Reprisal_QuestInterrupt = {
    Name = "Reprisal_QuestInterrupt",
    Description = {
        en = "Reprisal: Interrupts another active quest without success or failure",
        de = "Vergeltung: Beendet eine andere aktive Quest ohne Erfolg oder Misserfolg",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Questname" },
    },
}

function b_Reprisal_QuestInterrupt:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function b_Reprisal_QuestInterrupt:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.QuestName = _Parameter
    end
end

function b_Reprisal_QuestInterrupt:CustomFunction(_Quest)
    if (GetQuestID(self.QuestName) ~= nil) then

        local QuestID = GetQuestID(self.QuestName)
        local Quest = Quests[QuestID]
        if Quest.State == QuestState.Active then
            StopQuestByName(self.QuestName);
        end
    end
end

function b_Reprisal_QuestInterrupt:DEBUG(_Quest)
    if not Quests[GetQuestID(self.QuestName)] then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": quest "..  self.QuestName .. " does not exist!")
        return true
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_QuestInterrupt);

-- -------------------------------------------------------------------------- --

---
-- Unterbricht einen Quest, selbst wenn dieser noch nicht ausgelöst wurde.
--
-- @param _QuestName   Name des Quest
-- @param _EndetQuests Bereits beendete unterbrechen
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_QuestForceInterrupt(...)
    return b_Reprisal_QuestForceInterrupt(...)
end

b_Reprisal_QuestForceInterrupt = {
    Name = "Reprisal_QuestForceInterrupt",
    Description = {
        en = "Reprisal: Interrupts another quest (even when it isn't active yet) without success or failure",
        de = "Vergeltung: Beendet eine andere Quest, auch wenn diese noch nicht aktiv ist ohne Erfolg oder Misserfolg",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Questname" },
        { ParameterType.Custom, en = "Ended quests", de = "Beendete Quests" },
    },
}

function b_Reprisal_QuestForceInterrupt:GetReprisalTable()

    return { Reprisal.Custom,{self, self.CustomFunction} }

end

function b_Reprisal_QuestForceInterrupt:AddParameter(_Index, _Parameter)

    if (_Index == 0) then
        self.QuestName = _Parameter
    elseif (_Index == 1) then
        self.InterruptEnded = AcceptAlternativeBoolean(_Parameter)
    end

end

function b_Reprisal_QuestForceInterrupt:GetCustomData( _Index )
    local Data = {}
    if _Index == 1 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    else
        assert( false )
    end
    return Data
end
function b_Reprisal_QuestForceInterrupt:CustomFunction(_Quest)
    if (GetQuestID(self.QuestName) ~= nil) then

        local QuestID = GetQuestID(self.QuestName)
        local Quest = Quests[QuestID]
        if self.InterruptEnded or Quest.State ~= QuestState.Over then
            Quest:Interrupt()
        end
    end
end

function b_Reprisal_QuestForceInterrupt:DEBUG(_Quest)
    if not Quests[GetQuestID(self.QuestName)] then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": quest "..  self.QuestName .. " does not exist!")
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_QuestForceInterrupt);

-- -------------------------------------------------------------------------- --

---
-- Führt eine Funktion im Skript als Reprisal aus.
--
-- @param _FunctionName Name der Funktion
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_MapScriptFunction(...)
    return b_Reprisal_MapScriptFunction:new(...);
end

b_Reprisal_MapScriptFunction = {
    Name = "Reprisal_MapScriptFunction",
    Description = {
        en = "Reprisal: Calls a function within the global map script if the quest has failed.",
        de = "Vergeltung: Ruft eine Funktion im globalen Kartenskript auf, wenn die Quest fehlschlägt.",
    },
    Parameter = {
        { ParameterType.Default, en = "Function name", de = "Funktionsname" },
    },
}

function b_Reprisal_MapScriptFunction:GetReprisalTable(_Quest)
    return {Reprisal.Custom, {self, self.CustomFunction}};
end

function b_Reprisal_MapScriptFunction:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.FuncName = _Parameter
    end
end

function b_Reprisal_MapScriptFunction:CustomFunction(_Quest)
    return _G[self.FuncName](self, _Quest);
end

function b_Reprisal_MapScriptFunction:DEBUG(_Quest)
    if not self.FuncName or not _G[self.FuncName] then
        dbg("".._Quest.Identifier.." "..self.Name..": function '" ..self.FuncName.. "' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_MapScriptFunction);

-- -------------------------------------------------------------------------- --

---
-- Ändert den Wert einer benutzerdefinierten Variable.
--
-- Benutzerdefinierte Variablen können ausschließlich Zahlen sein.
--
---- <p>Operatoren</p>
-- <ul>
-- <li>= - Variablenwert wird auf den Wert gesetzt</li>
-- <li>- - Variablenwert mit Wert Subtrahieren</li>
-- <li>+ - Variablenwert mit Wert addieren</li>
-- <li>* - Variablenwert mit Wert multiplizieren</li>
-- <li>/ - Variablenwert mit Wert dividieren</li>
-- <li>^ - Variablenwert mit Wert potenzieren</li>
-- </ul>
--
-- @param _Name     Name der Variable
-- @param _Operator Rechen- oder Zuweisungsoperator
-- @param _Value    Wert oder andere Custom Variable
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_CustomVariables(...)
    return b_Reprisal_CustomVariables:new(...);
end

b_Reprisal_CustomVariables = {
    Name = "Reprisal_CustomVariables",
    Description = {
        en = "Reprisal: Executes a mathematical operation with this variable. The other operand can be a number or another custom variable.",
        de = "Vergeltung: Fuehrt eine mathematische Operation mit der Variable aus. Der andere Operand kann eine Zahl oder eine Custom-Varible sein.",
    },
    Parameter = {
        { ParameterType.Default, en = "Name of variable", de = "Variablenname" },
        { ParameterType.Custom,  en = "Operator", de = "Operator" },
        { ParameterType.Default,  en = "Value or variable", de = "Wert oder Variable" }
    }
};

function b_Reprisal_CustomVariables:GetReprisalTable()
    return { Reprisal.Custom, {self, self.CustomFunction} };
end

function b_Reprisal_CustomVariables:AddParameter(_Index, _Parameter)
    if _Index == 0 then
        self.VariableName = _Parameter
    elseif _Index == 1 then
        self.Operator = _Parameter
    elseif _Index == 2 then
        local value = tonumber(_Parameter);
        value = (value ~= nil and value) or tostring(_Parameter);
        self.Value = value
    end
end

function b_Reprisal_CustomVariables:CustomFunction()
    _G["QSB_CustomVariables_"..self.VariableName] = _G["QSB_CustomVariables_"..self.VariableName] or 0;
    local oldValue = _G["QSB_CustomVariables_"..self.VariableName];

    if self.Operator == "=" then
        _G["QSB_CustomVariables_"..self.VariableName] = (type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value];
    elseif self.Operator == "+" then
        _G["QSB_CustomVariables_"..self.VariableName] = oldValue + (type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value];
    elseif self.Operator == "-" then
        _G["QSB_CustomVariables_"..self.VariableName] = oldValue - (type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value];
    elseif self.Operator == "*" then
        _G["QSB_CustomVariables_"..self.VariableName] = oldValue * (type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value];
    elseif self.Operator == "/" then
        _G["QSB_CustomVariables_"..self.VariableName] = oldValue / (type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value];
    elseif self.Operator == "^" then
        _G["QSB_CustomVariables_"..self.VariableName] = oldValue ^ (type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value];

    end
end

function b_Reprisal_CustomVariables:GetCustomData( _Index )
    return {"=", "+", "-", "*", "/", "^"};
end

function b_Reprisal_CustomVariables:DEBUG(_Quest)
    local operators = {"=", "+", "-", "*", "/", "^"};
    if not Inside(self.Operator,operators) then
        dbg(_Quest.Identifier.." "..self.Name..": got an invalid operator!");
        return true;
    elseif self.VariableName == "" then
        dbg(_Quest.Identifier.." "..self.Name..": missing name for variable!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_CustomVariables)

-- -------------------------------------------------------------------------- --

---
-- Erlaubt oder verbietet einem Spieler eine Technologie.
--
-- @param _PlayerID   ID des Spielers
-- @param _Lock       Sperren/Entsperren
-- @param _Technology Name der Technologie
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_Technology(...)
    return b_Reprisal_Technology:new(...);
end

b_Reprisal_Technology = {
    Name = "Reprisal_Technology",
    Description = {
        en = "Reprisal: Locks or unlocks a technology for the given player",
        de = "Vergeltung: Sperrt oder erlaubt eine Technolgie fuer den angegebenen Player",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "PlayerID", de = "SpielerID" },
        { ParameterType.Custom,   en = "Un / Lock", de = "Sperren/Erlauben" },
        { ParameterType.Custom,   en = "Technology", de = "Technologie" },
    },
}

function b_Reprisal_Technology:GetReprisalTable(_Quest)
    return { Reprisal.Custom, {self, self.CustomFunction} }
end

function b_Reprisal_Technology:AddParameter(_Index, _Parameter)
    if (_Index ==0) then
        self.PlayerID = _Parameter*1
    elseif (_Index == 1) then
        self.LockType = _Parameter == "Lock"
    elseif (_Index == 2) then
        self.Technology = _Parameter
    end
end

function b_Reprisal_Technology:CustomFunction(_Quest)
    if self.PlayerID
    and Logic.GetStoreHouse(self.PlayerID) ~= 0
    and Technologies[self.Technology]
    then
        if self.LockType  then
            LockFeaturesForPlayer(self.PlayerID, Technologies[self.Technology])
        else
            UnLockFeaturesForPlayer(self.PlayerID, Technologies[self.Technology])
        end
    else
        return false
    end
end

function b_Reprisal_Technology:GetCustomData(_Index)
    local Data = {}
    if (_Index == 1) then
        Data[1] = "Lock"
        Data[2] = "UnLock"
    elseif (_Index == 2) then
        for k, v in pairs( Technologies ) do
            table.insert( Data, k )
        end
    end
    return Data
end

function b_Reprisal_Technology:DEBUG(_Quest)
    if not Technologies[self.Technology] then
        dbg("".._Quest.Identifier.." "..self.Name..": got an invalid technology type!");
        return true;
    elseif tonumber(self.PlayerID) == nil or self.PlayerID < 1 or self.PlayerID > 8 then
        dbg("".._Quest.Identifier.." "..self.Name..": got an invalid playerID!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_Technology);

-- -------------------------------------------------------------------------- --
-- Rewards                                                                    --
-- -------------------------------------------------------------------------- --

---
-- Deaktiviert ein interaktives Objekt
--
-- @param _ScriptName Skriptname des interaktiven Objektes
-- @return Table mit Behavior
-- @within Reward
--
function Reward_ObjectDeactivate(...)
    return b_Reward_ObjectDeactivate:new(...);
end

b_Reward_ObjectDeactivate = API.InstanceTable(b_Reprisal_ObjectDeactivate);
b_Reward_ObjectDeactivate.Name             = "Reward_ObjectDeactivate";
b_Reward_ObjectDeactivate.Description.de   = "Reward: Deactivates an interactive object";
b_Reward_ObjectDeactivate.Description.en   = "Lohn: Deaktiviert ein interaktives Objekt";
b_Reward_ObjectDeactivate.GetReprisalTable = nil;

b_Reward_ObjectDeactivate.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Core:RegisterBehavior(b_Reward_ObjectDeactivate);

-- -------------------------------------------------------------------------- --

---
-- Aktiviert ein interaktives Objekt.
--
-- Der Status bestimmt, wie das objekt aktiviert wird.
-- <ul>
-- <li>0: Kann nur mit Helden aktiviert werden</li>
-- <li>1: Kann immer aktiviert werden</li>
-- </ul>
--
-- @param _ScriptName Skriptname des interaktiven Objektes
-- @param _State Status des Objektes
-- @return Table mit Behavior
-- @within Reward
--
function Reward_ObjectActivate(...)
    return Reward_ObjectActivate:new(...);
end

b_Reward_ObjectActivate = API.InstanceTable(b_Reprisal_ObjectActivate);
b_Reward_ObjectActivate.Name             = "Reward_ObjectActivate";
b_Reward_ObjectActivate.Description.de   = "Reward: Activates an interactive object";
b_Reward_ObjectActivate.Description.en   = "Lohn: Aktiviert ein interaktives Objekt";
b_Reward_ObjectActivate.GetReprisalTable = nil;

b_Reward_ObjectActivate.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} };
end

Core:RegisterBehavior(b_Reward_ObjectActivate);

-- -------------------------------------------------------------------------- --

---
-- Initialisiert ein interaktives Objekt.
--
-- Interaktive Objekte können Kosten und Belohnungen enthalten, müssen sie
-- jedoch nicht. Ist eine Wartezeit angegeben, kann das Objekt erst nach
-- Ablauf eines Cooldowns benutzt werden.
--
-- @param _ScriptName Skriptname des interaktiven Objektes
-- @param _Distance   Entfernung zur Aktivierung
-- @param _Time       Wartezeit bis zur Aktivierung
-- @param _RType1     Warentyp der Belohnung
-- @param _RAmount    Menge der Belohnung
-- @param _CType1     Typ der 1. Ware
-- @param _CAmount1   Menge der 1. Ware
-- @param _CType2     Typ der 2. Ware
-- @param _CAmount2   Menge der 2. Ware
-- @param _Status     Aktivierung (0: Held, 1: immer, 2: niemals)
-- @return Table mit Behavior
-- @within Reward
--
function Reward_ObjectInit(...)
    return Reward_ObjectInit:new(...);
end

b_Reward_ObjectInit = {
    Name = "Reward_ObjectInit",
    Description = {
        en = "Reward: Setup an interactive object with costs and rewards.",
        de = "Lohn: Initialisiert ein interaktives Objekt mit seinen Kosten und Schätzen.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Interactive object",     de = "Interaktives Objekt" },
        { ParameterType.Number,     en = "Distance to use",     de = "Nutzungsentfernung" },
        { ParameterType.Number,     en = "Waittime",             de = "Wartezeit" },
        { ParameterType.Custom,     en = "Reward good",         de = "Belohnungsware" },
        { ParameterType.Number,     en = "Reward amount",         de = "Anzahl" },
        { ParameterType.Custom,     en = "Cost good 1",         de = "Kostenware 1" },
        { ParameterType.Number,     en = "Cost amount 1",         de = "Anzahl 1" },
        { ParameterType.Custom,     en = "Cost good 2",         de = "Kostenware 2" },
        { ParameterType.Number,     en = "Cost amount 2",         de = "Anzahl 2" },
        { ParameterType.Custom,     en = "Availability",         de = "Verfï¿½gbarkeit" },
    },
}

function b_Reward_ObjectInit:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_ObjectInit:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptName = _Parameter
    elseif (_Index == 1) then
        self.Distance = _Parameter * 1
    elseif (_Index == 2) then
        self.Waittime = _Parameter * 1
    elseif (_Index == 3) then
        self.RewardType = _Parameter
    elseif (_Index == 4) then
        self.RewardAmount = tonumber(_Parameter)
    elseif (_Index == 5) then
        self.FirstCostType = _Parameter
    elseif (_Index == 6) then
        self.FirstCostAmount = tonumber(_Parameter)
    elseif (_Index == 7) then
        self.SecondCostType = _Parameter
    elseif (_Index == 8) then
        self.SecondCostAmount = tonumber(_Parameter)
    elseif (_Index == 9) then
        local parameter = nil
        if _Parameter == "Always" or 1 then
            parameter = 1
        elseif _Parameter == "Never" or 2 then
            parameter = 2
        elseif _Parameter == "Knight only" or 0 then
            parameter = 0
        end
        self.UsingState = parameter
    end
end

function b_Reward_ObjectInit:CustomFunction(_Quest)
    local eID = GetID(self.ScriptName);
    if eID == 0 then
        return;
    end
    QSB.InitalizedObjekts[eID] = _Quest.Identifier;

    Logic.InteractiveObjectClearCosts(eID);
    Logic.InteractiveObjectClearRewards(eID);

    Logic.InteractiveObjectSetInteractionDistance(eID, self.Distance);
    Logic.InteractiveObjectSetTimeToOpen(eID, self.Waittime);

    if self.RewardType and self.RewardType ~= "disabled" then
        Logic.InteractiveObjectAddRewards(eID, Goods[self.RewardType], self.RewardAmount);
    end
    if self.FirstCostType and self.FirstCostType ~= "disabled" then
        Logic.InteractiveObjectAddCosts(eID, Goods[self.FirstCostType], self.FirstCostAmount);
    end
    if self.SecondCostType and self.SecondCostType ~= "disabled" then
        Logic.InteractiveObjectAddCosts(eID, Goods[self.SecondCostType], self.SecondCostAmount);
    end

    Logic.InteractiveObjectSetAvailability(eID,true);
    if self.UsingState then
        for i=1, 8 do
            Logic.InteractiveObjectSetPlayerState(eID,i, self.UsingState);
        end
    end

    Logic.InteractiveObjectSetRewardResourceCartType(eID,Entities.U_ResourceMerchant);
    Logic.InteractiveObjectSetRewardGoldCartType(eID,Entities.U_GoldCart);
    Logic.InteractiveObjectSetCostResourceCartType(eID,Entities.U_ResourceMerchant);
    Logic.InteractiveObjectSetCostGoldCartType(eID, Entities.U_GoldCart);
    RemoveInteractiveObjectFromOpenedList(eID);
    table.insert(HiddenTreasures,eID);
end

function b_Reward_ObjectInit:GetCustomData( _Index )
    if _Index == 3 or _Index == 5 or _Index == 7 then
        local Data = {
            "-",
            "G_Beer",
            "G_Bread",
            "G_Broom",
            "G_Carcass",
            "G_Cheese",
            "G_Clothes",
            "G_Dye",
            "G_Gold",
            "G_Grain",
            "G_Herb",
            "G_Honeycomb",
            "G_Iron",
            "G_Leather",
            "G_Medicine",
            "G_Milk",
            "G_RawFish",
            "G_Salt",
            "G_Sausage",
            "G_SmokedFish",
            "G_Soap",
            "G_Stone",
            "G_Water",
            "G_Wood",
            "G_Wool",
        }

        if g_GameExtraNo >= 1 then
            Data[#Data+1] = "G_Gems"
            Data[#Data+1] = "G_MusicalInstrument"
            Data[#Data+1] = "G_Olibanum"
        end
        return Data
    elseif _Index == 9 then
        return {"-", "Knight only", "Always", "Never",}
    end
end

function b_Reward_ObjectInit:DEBUG(_Quest)
    if Logic.IsInteractiveObject(GetID(self.ScriptName)) == false then
        dbg("".._Quest.Identifier.." "..self.Name..": '"..self.ScriptName.."' is not a interactive object!");
        return true;
    end
    if self.UsingState ~= 1 and self.Distance < 50 then
        warn("".._Quest.Identifier.." "..self.Name..": distance is maybe too short!");
    end
    if self.Waittime < 0 then
        dbg("".._Quest.Identifier.." "..self.Name..": waittime must be equal or greater than 0!");
        return true;
    end
    if self.RewardType and self.RewardType ~= "-" then
        if not Goods[self.RewardType] then
            dbg("".._Quest.Identifier.." "..self.Name..": '"..self.RewardType.."' is invalid good type!");
            return true;
        elseif self.RewardAmount < 1 then
            dbg("".._Quest.Identifier.." "..self.Name..": amount can not be 0 or negative!");
            return true;
        end
    end
    if self.FirstCostType and self.FirstCostType ~= "-" then
        if not Goods[self.FirstCostType] then
            dbg("".._Quest.Identifier.." "..self.Name..": '"..self.FirstCostType.."' is invalid good type!");
            return true;
        elseif self.FirstCostAmount < 1 then
            dbg("".._Quest.Identifier.." "..self.Name..": amount can not be 0 or negative!");
            return true;
        end
    end
    if self.SecondCostType and self.SecondCostType ~= "-" then
        if not Goods[self.SecondCostType] then
            dbg("".._Quest.Identifier.." "..self.Name..": '"..self.SecondCostType.."' is invalid good type!");
            return true;
        elseif self.SecondCostAmount < 1 then
            dbg("".._Quest.Identifier.." "..self.Name..": amount can not be 0 or negative!");
            return true;
        end
    end
    return false;
end

Core:RegisterBehavior(b_Reward_ObjectInit);

-- -------------------------------------------------------------------------- --

---
-- Setzt die benutzten Wagen eines interaktiven Objektes.
--
-- In der Regel ist das Setzen der Wagen unnötig, da die voreingestellten
-- Wagen ausreichen. Will man aber z.B. eine Kutsche fahren lassen, dann
-- muss der Wagentyp geändert werden.
--
-- @param _ScriptName           Skriptname des Objektes
-- @param _CostResourceType     Wagen für Rohstoffkosten
-- @param _CostGoldType         Wagen für Goldkosten
-- @param _RewResourceType      Wagen für Rohstofflieferung
-- @param _RewGoldType          Wagen für Goldlieferung
-- @return Table mit Behavior
-- @within Reward
--
function Reward_ObjectSetCarts(...)
    return b_Reward_ObjectSetCarts:new(...);
end

b_Reward_ObjectSetCarts = {
    Name = "Reward_ObjectSetCarts",
    Description = {
        en = "Reward: Set the cart types of an interactive object.",
        de = "Lohn: Setzt die Wagentypen eines interaktiven Objektes.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Interactive object",         de = "Interaktives Objekt" },
        { ParameterType.Default,     en = "Cost resource type",         de = "Rohstoffwagen Kosten" },
        { ParameterType.Default,     en = "Cost gold type",             de = "Goldwagen Kosten" },
        { ParameterType.Default,     en = "Reward resource type",     de = "Rohstoffwagen Schatz" },
        { ParameterType.Default,     en = "Reward gold type",         de = "Goldwagen Schatz" },
    },
}

function b_Reward_ObjectSetCarts:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_ObjectSetCarts:AddParameter(_Index, _Parameter)
    if _Index == 0 then
        self.ScriptName = _Parameter
    elseif _Index == 1 then
        if not _Parameter or _Parameter == "default" then
            _Parameter = "U_ResourceMerchant";
        end
        self.CostResourceCart = _Parameter
    elseif _Index == 2 then
        if not _Parameter or _Parameter == "default" then
            _Parameter = "U_GoldCart";
        end
        self.CostGoldCart = _Parameter
    elseif _Index == 3 then
        if not _Parameter or _Parameter == "default" then
            _Parameter = "U_ResourceMerchant";
        end
        self.RewardResourceCart = _Parameter
    elseif _Index == 4 then
        if not _Parameter or _Parameter == "default" then
            _Parameter = "U_GoldCart";
        end
        self.RewardGoldCart = _Parameter
    end
end

function b_Reward_ObjectSetCarts:CustomFunction(_Quest)
    local eID = GetID(self.ScriptName);
    Logic.InteractiveObjectSetRewardResourceCartType(eID, Entities[self.RewardResourceCart]);
    Logic.InteractiveObjectSetRewardGoldCartType(eID, Entities[self.RewardGoldCart]);
    Logic.InteractiveObjectSetCostGoldCartType(eID, Entities[self.CostResourceCart]);
    Logic.InteractiveObjectSetCostResourceCartType(eID, Entities[self.CostGoldCart]);
end

function b_Reward_ObjectSetCarts:GetCustomData( _Index )
    if _Index == 2 or _Index == 4 then
        return {"U_GoldCart", "U_GoldCart_Mission", "U_Noblemen_Cart", "U_RegaliaCart"}
    elseif _Index == 1 or _Index == 3 then
        local Data = {"U_ResourceMerchant", "U_Medicus", "U_Marketer"}
        if g_GameExtraNo > 0 then
            table.insert(Data, "U_NPC_Resource_Monk_AS");
        end
        return Data;
    end
end

function b_Reward_ObjectSetCarts:DEBUG(_Quest)
    if (not Entities[self.CostResourceCart]) or (not Entities[self.CostGoldCart])
    or (not Entities[self.RewardResourceCart]) or (not Entities[self.RewardGoldCart]) then
        dbg("".._Quest.Identifier.." "..self.Name..": invalid cart type!");
        return true;
    end

    local eID = GetID(self.ScriptName);
    if QSB.InitalizedObjekts[eID] and QSB.InitalizedObjekts[eID] == _Quest.Identifier then
        dbg("".._Quest.Identifier.." "..self.Name..": you can not change carts in the same quest the object is initalized!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reward_ObjectSetCarts);

-- -------------------------------------------------------------------------- --

---
-- Änder den Diplomatiestatus zwischen zwei Spielern.
--
-- @param _Party1   ID der ersten Partei
-- @param _Party2   ID der zweiten Partei
-- @param _State    Neuer Diplomatiestatus
-- @return Table mit Behavior
-- @within Reward
--
function Reward_Diplomacy(...)
    return b_Reward_Diplomacy:new(...);
end

b_Reward_Diplomacy = API.InstanceTable(b_Reprisal_Diplomacy);
b_Reward_Diplomacy.Name             = "Reward_ObjectDeactivate";
b_Reward_Diplomacy.Description.de   = "Reward: Sets Diplomacy state of two Players to a stated value.";
b_Reward_Diplomacy.Description.en   = "Lohn: Setzt den Diplomatiestatus zweier Spieler auf den angegebenen Wert.";
b_Reward_Diplomacy.GetReprisalTable = nil;

b_Reward_ObjectDeactivate.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Core:RegisterBehavior(b_Reward_Diplomacy);

-- -------------------------------------------------------------------------- --

---
-- Verbessert die diplomatischen Beziehungen zwischen Sender und Empfänger
-- um einen Grad.
--
-- @return Table mit Behavior
-- @within Reward
--
function Reward_DiplomacyIncrease()
    return b_Reward_DiplomacyIncrease:new();
end

b_Reward_DiplomacyIncrease = {
    Name = "Reward_DiplomacyIncrease",
    Description = {
        en = "Reward: Diplomacy increases slightly to another player",
        de = "Lohn: Verbesserug des Diplomatiestatus zu einem anderen Spieler",
    },
}

function b_Reward_DiplomacyIncrease:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_DiplomacyIncrease:CustomFunction(_Quest)
    local Sender = _Quest.SendingPlayer;
    local Receiver = _Quest.ReceivingPlayer;
    local State = GetDiplomacyState(Receiver, Sender);
    if State < 2 then
        SetDiplomacyState(Receiver, Sender, State+1);
    end
end

function b_Reward_DiplomacyIncrease:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    end
end

Core:RegisterBehavior(b_Reward_DiplomacyIncrease);

-- -------------------------------------------------------------------------- --

---
-- Erzeugt Handelsangebote im Lagerhaus des angegebenen Spielers.
--
-- Sollen Angebote gelöscht werden, muss "-" als Ware ausgewählt werden.
--
-- <b>Achtung:</b> Stadtlagerhäuser können keine Söldner anbieten!
--
-- @param _PlayerID Partei, die Anbietet
-- @param _Amount1  Menge des 1. Angebot
-- @param _Type1    Ware oder Typ des 1. Angebot
-- @param _Amount2  Menge des 2. Angebot
-- @param _Type2    Ware oder Typ des 2. Angebot
-- @param _Amount3  Menge des 3. Angebot
-- @param _Type3    Ware oder Typ des 3. Angebot
-- @param _Amount4  Menge des 4. Angebot
-- @param _Type4    Ware oder Typ des 4. Angebot
-- @return Table mit Behavior
-- @within Reward
--
function Reward_TradeOffers(...)
    return b_Reward_TradeOffers:new(...);
end

b_Reward_TradeOffers = {
    Name = "Reward_TradeOffers",
    Description = {
        en = "Reward: Deletes all existing offers for a merchant and sets new offers, if given",
        de = "Lohn: Löscht alle Angebote eines Händlers und setzt neue, wenn angegeben",
    },
    Parameter = {
        { ParameterType.Custom, en = "PlayerID", de = "PlayerID" },
        { ParameterType.Custom, en = "Amount 1", de = "Menge 1" },
        { ParameterType.Custom, en = "Offer 1", de = "Angebot 1" },
        { ParameterType.Custom, en = "Amount 2", de = "Menge 2" },
        { ParameterType.Custom, en = "Offer 2", de = "Angebot 2" },
        { ParameterType.Custom, en = "Amount 3", de = "Menge 3" },
        { ParameterType.Custom, en = "Offer 3", de = "Angebot 3" },
        { ParameterType.Custom, en = "Amount 4", de = "Menge 4" },
        { ParameterType.Custom, en = "Offer 4", de = "Angebot 4" },
    },
}

function b_Reward_TradeOffers:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_TradeOffers:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter
    elseif (_Index == 1) then
        self.AmountOffer1 = tonumber(_Parameter)
    elseif (_Index == 2) then
        self.Offer1 = _Parameter
    elseif (_Index == 3) then
        self.AmountOffer2 = tonumber(_Parameter)
    elseif (_Index == 4) then
        self.Offer2 = _Parameter
    elseif (_Index == 5) then
        self.AmountOffer3 = tonumber(_Parameter)
    elseif (_Index == 6) then
        self.Offer3 = _Parameter
    elseif (_Index == 7) then
        self.AmountOffer4 = tonumber(_Parameter)
    elseif (_Index == 8) then
        self.Offer4 = _Parameter
    end
end

function b_Reward_TradeOffers:CustomFunction()
    if (self.PlayerID > 1) and (self.PlayerID < 9) then
        local Storehouse = Logic.GetStoreHouse(self.PlayerID)
        Logic.RemoveAllOffers(Storehouse)
        for i =  1,4 do
            if self["Offer"..i] and self["Offer"..i] ~= "-" then
                if Goods[self["Offer"..i]] then
                    AddOffer(Storehouse, self["AmountOffer"..i], Goods[self["Offer"..i]])
                elseif Logic.IsEntityTypeInCategory(Entities[self["Offer"..i]], EntityCategories.Military) == 1 then
                    AddMercenaryOffer(Storehouse, self["AmountOffer"..i], Entities[self["Offer"..i]])
                else
                    AddEntertainerOffer (Storehouse , Entities[self["Offer"..i]])
                end
            end
        end
    end
end

function b_Reward_TradeOffers:DEBUG(_Quest)
    if Logic.GetStoreHouse(self.PlayerID ) == 0 then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": Player " .. self.PlayerID .. " is dead. :-(")
        return true
    end
end

function b_Reward_TradeOffers:GetCustomData(_Index)
    local Players = { "2", "3", "4", "5", "6", "7", "8" }
    local Amount = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
    local Offers = {"-",
                    "G_Beer",
                    "G_Bow",
                    "G_Bread",
                    "G_Broom",
                    "G_Candle",
                    "G_Carcass",
                    "G_Cheese",
                    "G_Clothes",
                    "G_Cow",
                    "G_Grain",
                    "G_Herb",
                    "G_Honeycomb",
                    "G_Iron",
                    "G_Leather",
                    "G_Medicine",
                    "G_Milk",
                    "G_RawFish",
                    "G_Sausage",
                    "G_Sheep",
                    "G_SmokedFish",
                    "G_Soap",
                    "G_Stone",
                    "G_Sword",
                    "G_Wood",
                    "G_Wool",
                    "G_Salt",
                    "G_Dye",
                    "U_AmmunitionCart",
                    "U_BatteringRamCart",
                    "U_CatapultCart",
                    "U_SiegeTowerCart",
                    "U_MilitaryBandit_Melee_ME",
                    "U_MilitaryBandit_Melee_SE",
                    "U_MilitaryBandit_Melee_NA",
                    "U_MilitaryBandit_Melee_NE",
                    "U_MilitaryBandit_Ranged_ME",
                    "U_MilitaryBandit_Ranged_NA",
                    "U_MilitaryBandit_Ranged_NE",
                    "U_MilitaryBandit_Ranged_SE",
                    "U_MilitaryBow_RedPrince",
                    "U_MilitaryBow",
                    "U_MilitarySword_RedPrince",
                    "U_MilitarySword",
                    "U_Entertainer_NA_FireEater",
                    "U_Entertainer_NA_StiltWalker",
                    "U_Entertainer_NE_StrongestMan_Barrel",
                    "U_Entertainer_NE_StrongestMan_Stone",
                    }
    if g_GameExtraNo and g_GameExtraNo >= 1 then
        table.insert(Offers, "G_Gems")
        table.insert(Offers, "G_Olibanum")
        table.insert(Offers, "G_MusicalInstrument")
        table.insert(Offers, "G_MilitaryBandit_Ranged_AS")
        table.insert(Offers, "G_MilitaryBandit_Melee_AS")
        table.insert(Offers, "U_MilitarySword_Khana")
        table.insert(Offers, "U_MilitaryBow_Khana")
    end
    if (_Index == 0) then
        return Players
    elseif (_Index == 1) or (_Index == 3) or (_Index == 5) or (_Index == 7) then
        return Amount
    elseif (_Index == 2) or (_Index == 4) or (_Index == 6) or (_Index == 8) then
        return Offers
    end
end

Core:RegisterBehavior(b_Reward_TradeOffers)

-- -------------------------------------------------------------------------- --

---
-- Ein benanntes Entity wird zerstört.
--
-- @param _ScriptName Skriptname des Entity
-- @return Table mit Behavior
-- @within Reward
--
function Reward_DestroyEntity(...)
    return b_Reward_DestroyEntity:new(...);
end

b_Reward_DestroyEntity = API.InstanceTable(b_Reprisal_DestroyEntity);
b_Reward_DestroyEntity.Name = "Reward_DestroyEntity";
b_Reward_DestroyEntity.Description.en = "Reward: Replaces an entity with an invisible script entity, which retains the entities name.";
b_Reward_DestroyEntity.Description.de = "Lohn: Ersetzt eine Entity mit einer unsichtbaren Script-Entity, die den Namen übernimmt.";
b_Reward_DestroyEntity.GetReprisalTable = nil;

b_Reward_DestroyEntity.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Core:RegisterBehavior(b_Reward_DestroyEntity);

-- -------------------------------------------------------------------------- --

---
-- Zerstört einen über die QSB erzeugten Effekt.
--
-- @param _EffectName Name des Effekts
-- @return Table mit Behavior
-- @within Reward
--
function Reward_DestroyEffect(...)
    return b_Reward_DestroyEffect:new(...);
end

b_Reward_DestroyEffect = API.InstanceTable(b_Reprisal_DestroyEffect);
b_Reward_DestroyEffect.Name = "Reward_DestroyEffect";
b_Reward_DestroyEffect.Description.en = "Reward: Destroys an effect.";
b_Reward_DestroyEffect.Description.de = "Lohn: Zerstört einen Effekt.";
b_Reward_DestroyEffect.GetReprisalTable = nil;

b_Reward_DestroyEffect.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } };
end

Core:RegisterBehavior(b_Reward_DestroyEffect);

-- -------------------------------------------------------------------------- --

---
-- Ersetzt ein Entity mit einem Batallion.
--
-- Ist die Position ein Gebäude, werden die Battalione am Eingang erzeugt und
-- Das Entity wird nicht ersetzt.
--
-- @param _Position    Skriptname des Entity
-- @param _PlayerID    PlayerID des Battalion
-- @param _UnitType    Einheitentyp der Soldaten
-- @param _Orientation Ausrichtung in °
-- @param _Soldiers    Anzahl an Soldaten
-- @param _HideFromAI  Vor KI verstecken
-- @return Table mit Behavior
-- @within Reward
--
function Reward_CreateBattalion(...)
    return b_Reward_CreateBattalion:new(...);
end

b_Reward_CreateBattalion = {
    Name = "Reward_CreateBattalion",
    Description = {
        en = "Reward: Replaces a script entity with a battalion, which retains the entities name",
        de = "Lohn: Ersetzt eine Script-Entity durch ein Bataillon, welches den Namen der Script-Entity übernimmt",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script entity", de = "Script Entity" },
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Custom, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number, en = "Orientation (in degrees)", de = "Ausrichtung (in Grad)" },
        { ParameterType.Number, en = "Number of soldiers", de = "Anzahl Soldaten" },
        { ParameterType.Custom, en = "Hide from AI", de = "Vor KI verstecken" },
    },
}

function b_Reward_CreateBattalion:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_CreateBattalion:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptNameEntity = _Parameter
    elseif (_Index == 1) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 2) then
        self.UnitKey = _Parameter
    elseif (_Index == 3) then
        self.Orientation = _Parameter * 1
    elseif (_Index == 4) then
        self.SoldierCount = _Parameter * 1
    elseif (_Index == 5) then
        self.HideFromAI = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Reward_CreateBattalion:CustomFunction(_Quest)
    if not IsExisting( self.ScriptNameEntity ) then
        return false
    end
    local pos = GetPosition(self.ScriptNameEntity)
    local NewID = Logic.CreateBattalionOnUnblockedLand( Entities[self.UnitKey], pos.X, pos.Y, self.Orientation, self.PlayerID, self.SoldierCount )
    local posID = GetID(self.ScriptNameEntity)
    if Logic.IsBuilding(posID) == 0 then
        DestroyEntity(self.ScriptNameEntity)
        Logic.SetEntityName( NewID, self.ScriptNameEntity )
    end
    if self.HideFromAI then
        AICore.HideEntityFromAI( self.PlayerID, NewID, true )
    end
end

function b_Reward_CreateBattalion:GetCustomData( _Index )
    local Data = {}
    if _Index == 2 then
        for k, v in pairs( Entities ) do
            if Logic.IsEntityTypeInCategory( v, EntityCategories.Soldier ) == 1 then
                table.insert( Data, k )
            end
        end
        table.sort( Data )
    elseif _Index == 5 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    else
        assert( false )
    end
    return Data
end

function b_Reward_CreateBattalion:DEBUG(_Quest)
    if not Entities[self.UnitKey] then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": got an invalid entity type!");
        return true;
    elseif not IsExisting(self.ScriptNameEntity) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": spawnpoint does not exist!");
        return true;
    elseif tonumber(self.PlayerID) == nil or self.PlayerID < 1 or self.PlayerID > 8 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": playerID is wrong!");
        return true;
    elseif tonumber(self.Orientation) == nil then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": orientation must be a number!");
        return true;
    elseif tonumber(self.SoldierCount) == nil or self.SoldierCount < 1 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": you can not create a empty batallion!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reward_CreateBattalion);

-- -------------------------------------------------------------------------- --

---
-- Erzeugt eine Menga von Battalionen an der Position.
--
-- @param _Amount      Anzahl erzeugter Battalione
-- @param _Position    Skriptname des Entity
-- @param _PlayerID    PlayerID des Battalion
-- @param _UnitType    Einheitentyp der Soldaten
-- @param _Orientation Ausrichtung in °
-- @param _Soldiers    Anzahl an Soldaten
-- @param _HideFromAI  Vor KI verstecken
-- @return Table mit Behavior
-- @within Reward
--
function Reward_CreateSeveralBattalions(...)
    return b_Reward_CreateSeveralBattalions:new(...);
end

b_Reward_CreateSeveralBattalions = {
    Name = "Reward_CreateSeveralBattalions",
    Description = {
        en = "Reward: Creates a given amount of battalions",
        de = "Lohn: Erstellt eine gegebene Anzahl Bataillone",
    },
    Parameter = {
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
        { ParameterType.ScriptName, en = "Script entity", de = "Script Entity" },
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Custom, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number, en = "Orientation (in degrees)", de = "Ausrichtung (in Grad)" },
        { ParameterType.Number, en = "Number of soldiers", de = "Anzahl Soldaten" },
        { ParameterType.Custom, en = "Hide from AI", de = "Vor KI verstecken" },
    },
}

function b_Reward_CreateSeveralBattalions:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_CreateSeveralBattalions:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Amount = _Parameter * 1
    elseif (_Index == 1) then
        self.ScriptNameEntity = _Parameter
    elseif (_Index == 2) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 3) then
        self.UnitKey = _Parameter
    elseif (_Index == 4) then
        self.Orientation = _Parameter * 1
    elseif (_Index == 5) then
        self.SoldierCount = _Parameter * 1
    elseif (_Index == 6) then
        self.HideFromAI = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Reward_CreateSeveralBattalions:CustomFunction(_Quest)
    if not IsExisting( self.ScriptNameEntity ) then
        return false
    end
    local tID = GetID(self.ScriptNameEntity)
    local x,y,z = Logic.EntityGetPos(tID);
    if Logic.IsBuilding(tID) == 1 then
        x,y = Logic.GetBuildingApproachPosition(tID)
    end

    for i=1, self.Amount do
        local NewID = Logic.CreateBattalionOnUnblockedLand( Entities[self.UnitKey], x, y, self.Orientation, self.PlayerID, self.SoldierCount )
        Logic.SetEntityName( NewID, self.ScriptNameEntity .. "_" .. i )
        if self.HideFromAI then
            AICore.HideEntityFromAI( self.PlayerID, NewID, true )
        end
    end
end

function b_Reward_CreateSeveralBattalions:GetCustomData( _Index )
    local Data = {}
    if _Index == 3 then
        for k, v in pairs( Entities ) do
            if Logic.IsEntityTypeInCategory( v, EntityCategories.Soldier ) == 1 then
                table.insert( Data, k )
            end
        end
        table.sort( Data )
    elseif _Index == 6 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    else
        assert( false )
    end
    return Data
end

function b_Reward_CreateSeveralBattalions:DEBUG(_Quest)
    if not Entities[self.UnitKey] then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": got an invalid entity type!");
        return true;
    elseif not IsExisting(self.ScriptNameEntity) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": spawnpoint does not exist!");
        return true;
    elseif tonumber(self.PlayerID) == nil or self.PlayerID < 1 or self.PlayerID > 8 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": playerDI is wrong!");
        return true;
    elseif tonumber(self.Orientation) == nil then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": orientation must be a number!");
        return true;
    elseif tonumber(self.SoldierCount) == nil or self.SoldierCount < 1 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": you can not create a empty batallion!");
        return true;
    elseif tonumber(self.Amount) == nil or self.Amount < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": amount can not be negative!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reward_CreateSeveralBattalions);

-- -------------------------------------------------------------------------- --

---
-- Erzeugt einen Effekt an der angegebenen Position.
--
-- @param _EffectName  Einzigartiger Effektname
-- @param _TypeName    Typ des Effekt
-- @param _PlayerID    PlayerID des Effekt
-- @param _Location    Position des Effekt
-- @param _Orientation Ausrichtung in °
-- @return Table mit Behavior
-- @within Reward
--
function Reward_CreateEffect(...)
    return b_Reward_CreateEffect:new(...);
end

b_Reward_CreateEffect = {
    Name = "Reward_CreateEffect",
    Description = {
        en = "Reward: Creates an effect at a specified position",
        de = "Lohn: Erstellt einen Effekt an der angegebenen Position",
    },
    Parameter = {
        { ParameterType.Default,    en = "Effect name", de = "Effektname" },
        { ParameterType.Custom,     en = "Type name", de = "Typbezeichnung" },
        { ParameterType.PlayerID,   en = "Player", de = "Spieler" },
        { ParameterType.ScriptName, en = "Location", de = "Ort" },
        { ParameterType.Number,     en = "Orientation (in degrees)(-1: from locating entity)", de = "Ausrichtung (in Grad)(-1: von Positionseinheit)" },
    }
}

function b_Reward_CreateEffect:AddParameter(_Index, _Parameter)

    if _Index == 0 then
        self.EffectName = _Parameter;
    elseif _Index == 1 then
        self.Type = EGL_Effects[_Parameter];
    elseif _Index == 2 then
        self.PlayerID = _Parameter * 1;
    elseif _Index == 3 then
        self.Location = _Parameter;
    elseif _Index == 4 then
        self.Orientation = _Parameter * 1;
    end

end

function b_Reward_CreateEffect:GetRewardTable(_Quest)
    return { Reward.Custom, { self, self.CustomFunction } };
end

function b_Reward_CreateEffect:CustomFunction(_Quest)
    if Logic.IsEntityDestroyed(self.Location) then
        return;
    end
    local entity = assert(GetID(self.Location), _Quest.Identifier .. "Error in " .. self.Name .. ": CustomFunction: Entity is invalid");
    if QSB.EffectNameToID[self.EffectName] and Logic.IsEffectRegistered(QSB.EffectNameToID[self.EffectName]) then
        return;
    end

    local posX, posY = Logic.GetEntityPosition(entity);
    local orientation = tonumber(self.Orientation);
    local effect = Logic.CreateEffectWithOrientation(self.Type, posX, posY, orientation, self.PlayerID);
    if self.EffectName ~= "" then
        QSB.EffectNameToID[self.EffectName] = effect;
    end
end

function b_Reward_CreateEffect:DEBUG(_Quest)
    if QSB.EffectNameToID[self.EffectName] and Logic.IsEffectRegistered(QSB.EffectNameToID[self.EffectName]) then
        dbg("".._Quest.Identifier.." "..self.Name..": effect already exists!");
        return true;
    elseif not IsExisting(self.Location) then
        sbg("".._Quest.Identifier.." "..self.Name..": location '" ..self.Location.. "' is missing!");
        return true;
    elseif self.PlayerID and (self.PlayerID < 0 or self.PlayerID > 8) then
        dbg("".._Quest.Identifier.." "..self.Name..": invalid playerID!");
        return true;
    elseif tonumber(self.Orientation) == nil then
        dbg("".._Quest.Identifier.." "..self.Name..": invalid orientation!");
        return true;
    end
end

function b_Reward_CreateEffect:GetCustomData(_Index)
    assert(_Index == 1, "Error in " .. self.Name .. ": GetCustomData: Index is invalid.");
    local types = {};
    for k, v in pairs(EGL_Effects) do
        table.insert(types, k);
    end
    table.sort(types);
    return types;
end

Core:RegisterBehavior(b_Reward_CreateEffect);

-- -------------------------------------------------------------------------- --

---
-- Ersetzt ein Entity mit dem Skriptnamen durch ein neues Entity.
--
-- Ist die Position ein Gebäude, werden die Entities am Eingang erzeugt und
-- die Position wird nicht ersetzt.
--
-- @param _ScriptName  Skriptname des Entity
-- @param _PlayerID    PlayerID des Effekt
-- @param _TypeName    Einzigartiger Effektname
-- @param _Orientation Ausrichtung in °
-- @param _HideFromAI  Vor KI verstecken
-- @return Table mit Behavior
-- @within Reward
--
function Reward_CreateEntity(...)
    return b_Reward_CreateEntity:new(...);
end

b_Reward_CreateEntity = {
    Name = "Reward_CreateEntity",
    Description = {
        en = "Reward: Replaces an entity by a new one of a given type",
        de = "Lohn: Ersetzt eine Entity durch eine neue gegebenen Typs",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script entity", de = "Script Entity" },
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Custom, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number, en = "Orientation (in degrees)", de = "Ausrichtung (in Grad)" },
        { ParameterType.Custom, en = "Hide from AI", de = "Vor KI verstecken" },
    },
}

function b_Reward_CreateEntity:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_CreateEntity:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptNameEntity = _Parameter
    elseif (_Index == 1) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 2) then
        self.UnitKey = _Parameter
    elseif (_Index == 3) then
        self.Orientation = _Parameter * 1
    elseif (_Index == 4) then
        self.HideFromAI = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Reward_CreateEntity:CustomFunction(_Quest)
    if not IsExisting( self.ScriptNameEntity ) then
        return false
    end
    local pos = GetPosition(self.ScriptNameEntity)
    local NewID;
    if Logic.IsEntityTypeInCategory( self.UnitKey, EntityCategories.Soldier ) == 1 then
        NewID       = Logic.CreateBattalionOnUnblockedLand( Entities[self.UnitKey], pos.X, pos.Y, self.Orientation, self.PlayerID, 1 )
        local l,s = {Logic.GetSoldiersAttachedToLeader(NewID)}
        Logic.SetOrientation(s,self.Orientation)
    else
        NewID = Logic.CreateEntityOnUnblockedLand( Entities[self.UnitKey], pos.X, pos.Y, self.Orientation, self.PlayerID )
    end
    local posID = GetID(self.ScriptNameEntity)
    if Logic.IsBuilding(posID) == 0 then
        DestroyEntity(self.ScriptNameEntity)
        Logic.SetEntityName( NewID, self.ScriptNameEntity )
    end
    if self.HideFromAI then
        AICore.HideEntityFromAI( self.PlayerID, NewID, true )
    end
end

function b_Reward_CreateEntity:GetCustomData( _Index )
    local Data = {}
    if _Index == 2 then
        for k, v in pairs( Entities ) do
            local name = {"^M_*","^XS_*","^X_*","^XT_*","^Z_*"}
            local found = false;
            for i=1,#name do
                if k:find(name[i]) then
                    found = true;
                    break;
                end
            end
            if not found then
                table.insert( Data, k );
            end
        end
        table.sort( Data )

    elseif _Index == 4 or _Index == 5 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    else
        assert( false )
    end
    return Data
end

function b_Reward_CreateEntity:DEBUG(_Quest)
    if not Entities[self.UnitKey] then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": got an invalid entity type!");
        return true;
    elseif not IsExisting(self.ScriptNameEntity) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": spawnpoint does not exist!");
        return true;
    elseif tonumber(self.PlayerID) == nil or self.PlayerID < 0 or self.PlayerID > 8 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": playerID is not valid!");
        return true;
    elseif tonumber(self.Orientation) == nil then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": orientation must be a number!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reward_CreateEntity);

-- -------------------------------------------------------------------------- --

---
-- Erzeugt mehrere Entities an der angegebenen Position
--
-- @param _Amount      Anzahl an Entities
-- @param _ScriptName  Skriptname des Entity
-- @param _PlayerID    PlayerID des Effekt
-- @param _TypeName    Einzigartiger Effektname
-- @param _Orientation Ausrichtung in °
-- @param _HideFromAI  Vor KI verstecken
-- @return Table mit Behavior
-- @within Reward
--
function Reward_CreateSeveralEntities(...)
    return b_Reward_CreateSeveralEntities:new(...);
end

b_Reward_CreateSeveralEntities = {
    Name = "Reward_CreateSeveralEntities",
    Description = {
        en = "Reward: Creating serveral battalions at the position of a entity. They retains the entities name and a _[index] suffix",
        de = "Lohn: Erzeugt mehrere Entities an der Position der Entity. Sie übernimmt den Namen der Script Entity und den Suffix _[index]",
    },
    Parameter = {
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
        { ParameterType.ScriptName, en = "Script entity", de = "Script Entity" },
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Custom, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number, en = "Orientation (in degrees)", de = "Ausrichtung (in Grad)" },
        { ParameterType.Custom, en = "Hide from AI", de = "Vor KI verstecken" },
    },
}

function b_Reward_CreateSeveralEntities:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_CreateSeveralEntities:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Amount = _Parameter * 1
    elseif (_Index == 1) then
        self.ScriptNameEntity = _Parameter
    elseif (_Index == 2) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 3) then
        self.UnitKey = _Parameter
    elseif (_Index == 4) then
        self.Orientation = _Parameter * 1
    elseif (_Index == 5) then
        self.HideFromAI = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Reward_CreateSeveralEntities:CustomFunction(_Quest)
    if not IsExisting( self.ScriptNameEntity ) then
        return false
    end
    local pos = GetPosition(self.ScriptNameEntity)
    local NewID;
    for i=1, self.Amount do
        if Logic.IsEntityTypeInCategory( self.UnitKey, EntityCategories.Soldier ) == 1 then
            NewID       = Logic.CreateBattalionOnUnblockedLand( Entities[self.UnitKey], pos.X, pos.Y, self.Orientation, self.PlayerID, 1 )
            local l,s = {Logic.GetSoldiersAttachedToLeader(NewID)}
            Logic.SetOrientation(s,self.Orientation)
        else
            NewID = Logic.CreateEntityOnUnblockedLand( Entities[self.UnitKey], pos.X, pos.Y, self.Orientation, self.PlayerID )
        end
        Logic.SetEntityName( NewID, self.ScriptNameEntity .. "_" .. i )
        if self.HideFromAI then
            AICore.HideEntityFromAI( self.PlayerID, NewID, true )
        end
    end
end

function b_Reward_CreateSeveralEntities:GetCustomData( _Index )
    local Data = {}
    if _Index == 3 then
        for k, v in pairs( Entities ) do
            local name = {"^M_*","^XS_*","^X_*","^XT_*","^Z_*"}
            local found = false;
            for i=1,#name do
                if k:find(name[i]) then
                    found = true;
                    break;
                end
            end
            if not found then
                table.insert( Data, k );
            end
        end
        table.sort( Data )

    elseif _Index == 5 or _Index == 6 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    else
        assert( false )
    end
    return Data

end

function b_Reward_CreateSeveralEntities:DEBUG(_Quest)
    if not Entities[self.UnitKey] then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": got an invalid entity type!");
        return true;
    elseif not IsExisting(self.ScriptNameEntity) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": spawnpoint does not exist!");
        return true;
    elseif tonumber(self.PlayerID) == nil or self.PlayerID < 1 or self.PlayerID > 8 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": spawnpoint does not exist!");
        return true;
    elseif tonumber(self.Orientation) == nil then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": orientation must be a number!");
        return true;
    elseif tonumber(self.Amount) == nil or self.Amount < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": amount can not be negative!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reward_CreateSeveralEntities);

-- -------------------------------------------------------------------------- --

---
-- Bewegt einen Siedler oder ein Battalion zum angegebenen Zielort.
--
-- @param _Settler     Einheit, die bewegt wird
-- @param _Destination Bewegungsziel
-- @return Table mit Behavior
-- @within Reward
--
function Reward_MoveSettler(...)
    return b_Reward_MoveSettler:new(...);
end

b_Reward_MoveSettler = {
    Name = "Reward_MoveSettler",
    Description = {
        en = "Reward: Moves a (NPC) settler to a destination. Must not be AI controlled, or it won't move",
        de = "Lohn: Bewegt einen (NPC) Siedler zu einem Zielort. Darf keinem KI Spieler gehören, ansonsten wird sich der Siedler nicht bewegen",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Settler", de = "Siedler" },
        { ParameterType.ScriptName, en = "Destination", de = "Ziel" },
    },
}

function b_Reward_MoveSettler:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_MoveSettler:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptNameUnit = _Parameter
    elseif (_Index == 1) then
        self.ScriptNameDest = _Parameter
    end
end

function b_Reward_MoveSettler:CustomFunction(_Quest)
    if Logic.IsEntityDestroyed( self.ScriptNameUnit ) or Logic.IsEntityDestroyed( self.ScriptNameDest ) then
        return false
    end
    local DestID = GetID( self.ScriptNameDest )
    local DestX, DestY = Logic.GetEntityPosition( DestID )
    if Logic.IsBuilding( DestID ) == 1 then
        DestX, DestY = Logic.GetBuildingApproachPosition( DestID )
    end
    Logic.MoveSettler( GetID( self.ScriptNameUnit ), DestX, DestY )
end

function b_Reward_MoveSettler:DEBUG(_Quest)
    if not not IsExisting(self.ScriptNameUnit) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": mover entity does not exist!");
        return true;
    elseif not IsExisting(self.ScriptNameDest) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": destination does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reward_MoveSettler);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler gewinnt das Spiel.
--
-- @return Table mit Behavior
-- @within Reward
--
function Reward_Victory()
    return b_Reward_Victory:new()
end

b_Reward_Victory = {
    Name = "Reward_Victory",
    Description = {
        en = "Reward: The player wins the game.",
        de = "Lohn: Der Spieler gewinnt das Spiel.",
    },
}

function b_Reward_Victory:GetRewardTable(_Quest)
    return {Reward.Victory};
end

Core:RegisterBehavior(b_Reward_Victory);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler verliert das Spiel.
--
-- @return Table mit Behavior
-- @within Reward
--
function Reward_Defeat()
    return b_Reward_Defeat:new()
end

b_Reward_Defeat = {
    Name = "Reward_Defeat",
    Description = {
        en = "Reward: The player loses the game.",
        de = "Lohn: Der Spieler verliert das Spiel.",
    },
}

function b_Reward_Defeat:GetRewardTable(_Quest)
    return { Reward.Custom, {self, self.CustomFunction} }
end

function b_Reward_Defeat:CustomFunction(_Quest)
    _Quest:TerminateEventsAndStuff()
    Logic.ExecuteInLuaLocalState("GUI_Window.MissionEndScreenSetVictoryReasonText(".. g_VictoryAndDefeatType.DefeatMissionFailed ..")")
    Defeated(_Quest.ReceivingPlayer)
end

Core:RegisterBehavior(b_Reward_Defeat);

-- -------------------------------------------------------------------------- --

---
-- Zeigt die Siegdekoration an dem Quest an.
--
-- Dies ist reine Optik! Der Spieler wird dadurch nicht das Spiel gewinnen.
--
-- @return Table mit Behavior
-- @within Reward
--
function Reward_FakeVictory()
    return b_Reward_FakeVictory:new();
end

b_Reward_FakeVictory = {
    Name = "Reward_FakeVictory",
    Description = {
        en = "Reward: Display a victory icon for a quest",
        de = "Lohn: Zeigt ein Siegesicon fuer diese Quest",
    },
}

function b_Reward_FakeVictory:GetRewardTable()
    return { Reward.FakeVictory }
end

Core:RegisterBehavior(b_Reward_FakeVictory);

-- -------------------------------------------------------------------------- --

---
-- Erzeugt eine Armee, die das angegebene Territorium angreift.
--
-- Die Armee wird versuchen Gebäude auf dem Territrium zu zerstören.
-- <ul>
-- <li>Außenposten: Die Armee versucht den Außenposten zu zerstören</li>
-- <li>Stadt: Die Armee versucht das Lagerhaus zu zerstören</li>
-- </ul>
--
-- @param _PlayerID   PlayerID der Angreifer
-- @param _SpawnPoint Skriptname des Entstehungspunkt
-- @param _Territory  Zielterritorium
-- @param _Sword      Anzahl Schwertkämpfer (Battalion)
-- @param _Bow        Anzahl Bogenschützen (Battalion)
-- @param _Cata       Anzahl Katapulte
-- @param _Towers     Anzahl Belagerungstürme
-- @param _Rams       Anzahl Rammen
-- @param _Ammo       Anzahl Munitionswagen
-- @param _Type       Typ der Soldaten
-- @param _Reuse      Freie Truppen wiederverwenden
-- @return Table mit Behavior
-- @within Reward
--
function Reward_AI_SpawnAndAttackTerritory(...)
    return b_Reward_AI_SpawnAndAttackTerritory:new(...);
end

b_Reward_AI_SpawnAndAttackTerritory = {
    Name = "Reward_AI_SpawnAndAttackTerritory",
    Description = {
        en = "Reward: Spawns AI troops and attacks a territory (Hint: Use for hidden quests as a surprise)",
        de = "Lohn: Erstellt KI Truppen und greift ein Territorium an (Tipp: Fuer eine versteckte Quest als Ueberraschung verwenden)",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "AI Player", de = "KI Spieler" },
        { ParameterType.ScriptName, en = "Spawn point", de = "Erstellungsort" },
        { ParameterType.TerritoryName, en = "Territory", de = "Territorium" },
        { ParameterType.Number, en = "Sword", de = "Schwert" },
        { ParameterType.Number, en = "Bow", de = "Bogen" },
        { ParameterType.Number, en = "Catapults", de = "Katapulte" },
        { ParameterType.Number, en = "Siege towers", de = "Belagerungstuerme" },
        { ParameterType.Number, en = "Rams", de = "Rammen" },
        { ParameterType.Number, en = "Ammo carts", de = "Munitionswagen" },
        { ParameterType.Custom, en = "Soldier type", de = "Soldatentyp" },
        { ParameterType.Custom, en = "Reuse troops", de = "Verwende bestehende Truppen" },
    },
}

function b_Reward_AI_SpawnAndAttackTerritory:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_AI_SpawnAndAttackTerritory:AddParameter(_Index, _Parameter)

    if (_Index == 0) then
        self.AIPlayerID = _Parameter * 1
    elseif (_Index == 1) then
        self.Spawnpoint = _Parameter
    elseif (_Index == 2) then
        self.TerritoryID = tonumber(_Parameter)
        if not self.TerritoryID then
            self.TerritoryID = GetTerritoryIDByName(_Parameter)
        end
    elseif (_Index == 3) then
        self.NumSword = _Parameter * 1
    elseif (_Index == 4) then
        self.NumBow = _Parameter * 1
    elseif (_Index == 5) then
        self.NumCatapults = _Parameter * 1
    elseif (_Index == 6) then
        self.NumSiegeTowers = _Parameter * 1
    elseif (_Index == 7) then
        self.NumRams = _Parameter * 1
    elseif (_Index == 8) then
        self.NumAmmoCarts = _Parameter * 1
    elseif (_Index == 9) then
        if _Parameter == "Normal" or _Parameter == false then
            self.TroopType = false
        elseif _Parameter == "RedPrince" or _Parameter == true then
            self.TroopType = true
        elseif _Parameter == "Bandit" or _Parameter == 2 then
            self.TroopType = 2
        elseif _Parameter == "Cultist" or _Parameter == 3 then
            self.TroopType = 3
        else
            assert(false)
        end
    elseif (_Index == 10) then
        self.ReuseTroops = AcceptAlternativeBoolean(_Parameter)
    end

end

function b_Reward_AI_SpawnAndAttackTerritory:GetCustomData( _Index )

    local Data = {}
    if _Index == 9 then
        table.insert( Data, "Normal" )
        table.insert( Data, "RedPrince" )
        table.insert( Data, "Bandit" )
        if g_GameExtraNo >= 1 then
            table.insert( Data, "Cultist" )
        end

    elseif _Index == 10 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )

    else
        assert( false )
    end

    return Data

end

function b_Reward_AI_SpawnAndAttackTerritory:CustomFunction(_Quest)

    local TargetID = Logic.GetTerritoryAcquiringBuildingID( self.TerritoryID )
    if TargetID ~= 0 then
        AIScript_SpawnAndAttackCity( self.AIPlayerID, TargetID, self.Spawnpoint, self.NumSword, self.NumBow, self.NumCatapults, self.NumSiegeTowers, self.NumRams, self.NumAmmoCarts, self.TroopType, self.ReuseTroops)
    end

end

function b_Reward_AI_SpawnAndAttackTerritory:DEBUG(_Quest)
    if self.AIPlayerID < 2 then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": Player " .. self.AIPlayerID .. " is wrong")
        return true
    elseif Logic.IsEntityDestroyed(self.Spawnpoint) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Entity " .. self.SpawnPoint .. " is missing")
        return true
    elseif self.TerritoryID == 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Territory unknown")
        return true
    elseif self.NumSword < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Number of Swords is negative")
        return true
    elseif self.NumBow < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Number of Bows is negative")
        return true
    elseif self.NumBow + self.NumSword < 1 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": No Soldiers?")
        return true
    elseif self.NumCatapults < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Catapults is negative")
        return true
    elseif self.NumSiegeTowers < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": SiegeTowers is negative")
        return true
    elseif self.NumRams < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Rams is negative")
        return true
    elseif self.NumAmmoCarts < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": AmmoCarts is negative")
        return true
    end
    return false;
end

Core:RegisterBehavior(b_Reward_AI_SpawnAndAttackTerritory);

-- -------------------------------------------------------------------------- --

---
-- Erzeugt eine Armee, die sich zum Zielpunkt bewegt und das Gebiet angreift.
--
-- Dabei werden die Soldaten alle erreichbaren Gebäude in Brand stecken. Ist
-- Das Zielgebiet eingemauert, können die Soldaten nicht angreifen und werden
-- sich zurückziehen.
--
-- @param _PlayerID   PlayerID des Angreifers
-- @param _SpawnPoint Skriptname des Entstehungspunktes
-- @param _Target     Skriptname des Ziels
-- @param _Radius     Aktionsradius um das Ziel
-- @param _Sword      Anzahl Schwertkämpfer (Battalione)
-- @param _Bow        Anzahl Bogenschützen (Battalione)
-- @param _Soldier    Typ der Soldaten
-- @param _Reuse      Freie Truppen wiederverwenden
-- @return Table mit Behavior
-- @within Reward
--
function Reward_AI_SpawnAndAttackArea(...)
    return b_Reward_AI_SpawnAndAttackArea:new(...);
end

b_Reward_AI_SpawnAndAttackArea = {
    Name = "Reward_AI_SpawnAndAttackArea",
    Description = {
        en = "Reward: Spawns AI troops and attacks everything within the specified area, except the players main buildings",
        de = "Lohn: Erstellt KI Truppen und greift ein angegebenes Gebiet an, aber nicht die Hauptgebauede eines Spielers",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "AI Player", de = "KI Spieler" },
        { ParameterType.ScriptName, en = "Spawn point", de = "Erstellungsort" },
        { ParameterType.ScriptName, en = "Target", de = "Ziel" },
        { ParameterType.Number, en = "Radius", de = "Radius" },
        { ParameterType.Number, en = "Sword", de = "Schwert" },
        { ParameterType.Number, en = "Bow", de = "Bogen" },
        { ParameterType.Custom, en = "Soldier type", de = "Soldatentyp" },
        { ParameterType.Custom, en = "Reuse troops", de = "Verwende bestehende Truppen" },
    },
}

function b_Reward_AI_SpawnAndAttackArea:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_AI_SpawnAndAttackArea:AddParameter(_Index, _Parameter)

    if (_Index == 0) then
        self.AIPlayerID = _Parameter * 1
    elseif (_Index == 1) then
        self.Spawnpoint = _Parameter
    elseif (_Index == 2) then
        self.TargetName = _Parameter
    elseif (_Index == 3) then
        self.Radius = _Parameter * 1
    elseif (_Index == 4) then
        self.NumSword = _Parameter * 1
    elseif (_Index == 5) then
        self.NumBow = _Parameter * 1
    elseif (_Index == 6) then
        if _Parameter == "Normal" or _Parameter == false then
            self.TroopType = false
        elseif _Parameter == "RedPrince" or _Parameter == true then
            self.TroopType = true
        elseif _Parameter == "Bandit" or _Parameter == 2 then
            self.TroopType = 2
        elseif _Parameter == "Cultist" or _Parameter == 3 then
            self.TroopType = 3
        else
            assert(false)
        end
    elseif (_Index == 7) then
        self.ReuseTroops = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Reward_AI_SpawnAndAttackArea:GetCustomData( _Index )
    local Data = {}
    if _Index == 6 then
        table.insert( Data, "Normal" )
        table.insert( Data, "RedPrince" )
        table.insert( Data, "Bandit" )
        if g_GameExtraNo >= 1 then
            table.insert( Data, "Cultist" )
        end
    elseif _Index == 7 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    else
        assert( false )
    end
    return Data
end

function b_Reward_AI_SpawnAndAttackArea:CustomFunction(_Quest)
    if Logic.IsEntityAlive( self.TargetName ) and Logic.IsEntityAlive( self.Spawnpoint ) then
        local TargetID = GetID( self.TargetName )
        AIScript_SpawnAndRaidSettlement( self.AIPlayerID, TargetID, self.Spawnpoint, self.Radius, self.NumSword, self.NumBow, self.TroopType, self.ReuseTroops )
    end
end

function b_Reward_AI_SpawnAndAttackArea:DEBUG(_Quest)
    if self.AIPlayerID < 2 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Player " .. self.AIPlayerID .. " is wrong")
        return true
    elseif Logic.IsEntityDestroyed(self.Spawnpoint) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Entity " .. self.SpawnPoint .. " is missing")
        return true
    elseif Logic.IsEntityDestroyed(self.TargetName) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Entity " .. self.TargetName .. " is missing")
        return true
    elseif self.Radius < 1 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Radius is to small or negative")
        return true
    elseif self.NumSword < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Number of Swords is negative")
        return true
    elseif self.NumBow < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Number of Bows is negative")
        return true
    elseif self.NumBow + self.NumSword < 1 then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": No Soldiers?")
        return true
    end
    return false;
end

Core:RegisterBehavior(b_Reward_AI_SpawnAndAttackArea);

-- -------------------------------------------------------------------------- --

---
-- Erstellt eine Armee, die das Zielgebiet verteidigt.
--
-- @param _PlayerID     PlayerID des Angreifers
-- @param _SpawnPoint   Skriptname des Entstehungspunktes
-- @param _Target       Skriptname des Ziels
-- @param _Radius       Bewachtes Gebiet
-- @param _Time         Dauer der Bewachung (-1 für unendlich)
-- @param _Sword        Anzahl Schwertkämpfer (Battalione)
-- @param _Bow          Anzahl Bogenschützen (Battalione)
-- @param _CaptureCarts Soldaten greifen Karren an
-- @param _Type         Typ der Soldaten
-- @param _Reuse        Freie Truppen wiederverwenden
-- @return Table mit Behavior
-- @within Reward
--
function Reward_AI_SpawnAndProtectArea(...)
    return b_Reward_AI_SpawnAndProtectArea:new(...);
end

b_Reward_AI_SpawnAndProtectArea = {
    Name = "Reward_AI_SpawnAndProtectArea",
    Description = {
        en = "Reward: Spawns AI troops and defends a specified area",
        de = "Lohn: Erstellt KI Truppen und verteidigt ein angegebenes Gebiet",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "AI Player", de = "KI Spieler" },
        { ParameterType.ScriptName, en = "Spawn point", de = "Erstellungsort" },
        { ParameterType.ScriptName, en = "Target", de = "Ziel" },
        { ParameterType.Number, en = "Radius", de = "Radius" },
        { ParameterType.Number, en = "Time (-1 for infinite)", de = "Zeit (-1 fuer unendlich)" },
        { ParameterType.Number, en = "Sword", de = "Schwert" },
        { ParameterType.Number, en = "Bow", de = "Bogen" },
        { ParameterType.Custom, en = "Capture tradecarts", de = "Handelskarren angreifen" },
        { ParameterType.Custom, en = "Soldier type", de = "Soldatentyp" },
        { ParameterType.Custom, en = "Reuse troops", de = "Verwende bestehende Truppen" },
    },
}

function b_Reward_AI_SpawnAndProtectArea:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_AI_SpawnAndProtectArea:AddParameter(_Index, _Parameter)

    if (_Index == 0) then
        self.AIPlayerID = _Parameter * 1
    elseif (_Index == 1) then
        self.Spawnpoint = _Parameter
    elseif (_Index == 2) then
        self.TargetName = _Parameter
    elseif (_Index == 3) then
        self.Radius = _Parameter * 1
    elseif (_Index == 4) then
        self.Time = _Parameter * 1
    elseif (_Index == 5) then
        self.NumSword = _Parameter * 1
    elseif (_Index == 6) then
        self.NumBow = _Parameter * 1
    elseif (_Index == 7) then
        self.CaptureTradeCarts = AcceptAlternativeBoolean(_Parameter)
    elseif (_Index == 8) then
        if _Parameter == "Normal" or _Parameter == true then
            self.TroopType = false
        elseif _Parameter == "RedPrince" or _Parameter == false then
            self.TroopType = true
        elseif _Parameter == "Bandit" or _Parameter == 2 then
            self.TroopType = 2
        elseif _Parameter == "Cultist" or _Parameter == 3 then
            self.TroopType = 3
        else
            assert(false)
        end
    elseif (_Index == 9) then
        self.ReuseTroops = AcceptAlternativeBoolean(_Parameter)
    end

end

function b_Reward_AI_SpawnAndProtectArea:GetCustomData( _Index )

    local Data = {}
    if _Index == 7 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    elseif _Index == 8 then
        table.insert( Data, "Normal" )
        table.insert( Data, "RedPrince" )
        table.insert( Data, "Bandit" )
        if g_GameExtraNo >= 1 then
            table.insert( Data, "Cultist" )
        end

    elseif _Index == 9 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )

    else
        assert( false )
    end

    return Data

end

function b_Reward_AI_SpawnAndProtectArea:CustomFunction(_Quest)

    if Logic.IsEntityAlive( self.TargetName ) and Logic.IsEntityAlive( self.Spawnpoint ) then
        local TargetID = GetID( self.TargetName )
        AIScript_SpawnAndProtectArea( self.AIPlayerID, TargetID, self.Spawnpoint, self.Radius, self.NumSword, self.NumBow, self.Time, self.TroopType, self.ReuseTroops, self.CaptureTradeCarts )
    end

end

function b_Reward_AI_SpawnAndProtectArea:DEBUG(_Quest)
    if self.AIPlayerID < 2 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Player " .. self.AIPlayerID .. " is wrong")
        return true
    elseif Logic.IsEntityDestroyed(self.Spawnpoint) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Entity " .. self.SpawnPoint .. " is missing")
        return true
    elseif Logic.IsEntityDestroyed(self.TargetName) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Entity " .. self.TargetName .. " is missing")
        return true
    elseif self.Radius < 1 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Radius is to small or negative")
        return true
    elseif self.Time < -1 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Time is smaller than -1")
        return true
    elseif self.NumSword < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Number of Swords is negative")
        return true
    elseif self.NumBow < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Number of Bows is negative")
        return true
    elseif self.NumBow + self.NumSword < 1 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": No Soldiers?")
        return true
    end
    return false;
end

Core:RegisterBehavior(b_Reward_AI_SpawnAndProtectArea);

-- -------------------------------------------------------------------------- --

---
-- Ändert die Konfiguration eines KI-Spielers.
--
-- Optionen:
-- <ul>
-- <li>Courage/FEAR: Angstfaktor (0 bis ?)</li>
-- <li>Reconstruction/BARB: Wiederaufbau von Gebäuden (0 oder 1)</li>
-- <li>Build Order/BPMX: Buildorder ausführen (Nummer der Build Order)</li>
-- <li>Conquer Outposts/FCOP: Außenposten einnehmen (0 oder 1)</li>
-- <li>Mount Outposts/FMOP: Eigene Außenposten bemannen (0 oder 1)</li>
-- <li>max. Bowmen/FMBM: Maximale Anzahl an Bogenschützen (min. 1)</li>
-- <li>max. Swordmen/FMSM: Maximale Anzahl an Schwerkkämpfer (min. 1) </li>
-- <li>max. Rams/FMRA: Maximale Anzahl an Rammen (min. 1)</li>
-- <li>max. Catapults/FMCA: Maximale Anzahl an Katapulten (min. 1)</li>
-- <li>max. Ammunition Carts/FMAC: Maximale Anzahl an Minitionswagen (min. 1)</li>
-- <li>max. Siege Towers/FMST: Maximale Anzahl an Belagerungstürmen (min. 1)</li>
-- <li>max. Wall Catapults/FMBA: Maximale Anzahl an Mauerkatapulten (min. 1)</li>
-- </ul>
--
-- @param _PlayerID PlayerID des KI
-- @param _Fact     Konfigurationseintrag
-- @param _Value    Neuer Wert
-- @return Table mit Behavior
-- @within Reward
--
function Reward_AI_SetNumericalFact(...)
    return b_Reward_AI_SetNumericalFact:new(...);
end

b_Reward_AI_SetNumericalFact = {
    Name = "Reward_AI_SetNumericalFact",
    Description = {
        en = "Reward: Sets a numerical fact for the AI player",
        de = "Lohn: Setzt eine Verhaltensregel fuer den KI-Spieler. ",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "AI Player",      de = "KI Spieler" },
        { ParameterType.Custom,   en = "Numerical Fact", de = "Verhaltensregel" },
        { ParameterType.Number,   en = "Value",          de = "Wert" },
    },
}

function b_Reward_AI_SetNumericalFact:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_AI_SetNumericalFact:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.AIPlayerID = _Parameter * 1
    elseif (_Index == 1) then
        -- mapping of numerical facts
        local fact = {
            ["Courage"]               = "FEAR",
            ["Reconstruction"]        = "BARB",
            ["Build Order"]           = "BPMX",
            ["Conquer Outposts"]      = "FCOP",
            ["Mount Outposts"]        = "FMOP",
            ["max. Bowmen"]           = "FMBM",
            ["max. Swordmen"]         = "FMSM",
            ["max. Rams"]             = "FMRA",
            ["max. Catapults"]        = "FMCA",
            ["max. Ammunition Carts"] = "FMAC",
            ["max. Siege Towers"]     = "FMST",
            ["max. Wall Catapults"]   = "FMBA",
            ["FEAR"]                  = "FEAR", -- > 0
            ["BARB"]                  = "BARB", -- 1 or 0
            ["BPMX"]                  = "BPMX", -- >= 0
            ["FCOP"]                  = "FCOP", -- 1 or 0
            ["FMOP"]                  = "FMOP", -- 1 or 0
            ["FMBM"]                  = "FMBM", -- >= 0
            ["FMSM"]                  = "FMSM", -- >= 0
            ["FMRA"]                  = "FMRA", -- >= 0
            ["FMCA"]                  = "FMCA", -- >= 0
            ["FMAC"]                  = "FMAC", -- >= 0
            ["FMST"]                  = "FMST", -- >= 0
            ["FMBA"]                  = "FMBA", -- >= 0
        }
        self.NumericalFact = fact[_Parameter]
    elseif (_Index == 2) then
        self.Value = _Parameter * 1
    end
end

function b_Reward_AI_SetNumericalFact:CustomFunction(_Quest)
    AICore.SetNumericalFact( self.AIPlayerID, self.NumericalFact, self.Value )
end

function b_Reward_AI_SetNumericalFact:GetCustomData(_Index)
    if (_Index == 1) then
        return {
            "Courage",
            "Reconstruction",
            "Build Order",
            "Conquer Outposts",
            "Mount Outposts",
            "max. Bowmen",
            "max. Swordmen",
            "max. Rams",
            "max. Catapults",
            "max. Ammunition Carts",
            "max. Siege Towers",
            "max. Wall Catapults",
        };
    end
end

function b_Reward_AI_SetNumericalFact:DEBUG(_Quest)
    if Logic.GetStoreHouse(self.AIPlayerID) == 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Player " .. self.AIPlayerID .. " is wrong or dead")
        return true
    elseif not self.NumericalFact then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": invalid numerical fact choosen")
        return true
    else
        if self.NumericalFact == "BARB" or self.NumericalFact == "FCOP" or self.NumericalFact == "FMOP" then
            if self.Value ~= 0 and self.Value ~= 1 then
                dbg(_Quest.Identifier .. " " .. self.Name .. ": BARB, FCOP, FMOP: value must be 1 or 0")
                return true
            end
        elseif self.NumericalFact == "FEAR" then
            if self.Value <= 0 then
                dbg(_Quest.Identifier .. " " .. self.Name .. ": FEAR: value must greater than 0")
                return true
            end
        else
            if self.Value < 0 then
                dbg(_Quest.Identifier .. " " .. self.Name .. ": BPMX, FMBM, FMSM, FMRA, FMCA, FMAC, FMST, FMBA: value must greater than or equal 0")
                return true
            end
        end
    end
    return false
end

Core:RegisterBehavior(b_Reward_AI_SetNumericalFact);

-- -------------------------------------------------------------------------- --

---
-- Stellt den Aggressivitätswert des KI-Spielers nachträglich ein.
--
-- @param _PlayerID         PlayerID des KI-Spielers
-- @param _Aggressiveness   Aggressivitätswert (1 bis 3)
-- @return Table mit Behavior
-- @within Reward
--
function Reward_AI_Aggressiveness(...)
    return b_Reward_AI_Aggressiveness:new(...);
end

b_Reward_AI_Aggressiveness = {
    Name = "Reward_AI_Aggressiveness",
    Description = {
        en = "Reward: Sets the AI player's aggressiveness.",
        de = "Lohn: Setzt die Aggressivität des KI-Spielers fest.",
    },
    Parameter =
    {
        { ParameterType.PlayerID, en = "AI player", de = "KI-Spieler" },
        { ParameterType.Custom, en = "Aggressiveness (1-3)", de = "Aggressivität (1-3)" }
    }
};

function b_Reward_AI_Aggressiveness:GetRewardTable()
    return {Reward.Custom, {self, self.CustomFunction} };
end

function b_Reward_AI_Aggressiveness:AddParameter(_Index, _Parameter)
    if _Index == 0 then
        self.AIPlayer = _Parameter * 1;
    elseif _Index == 1 then
        self.Aggressiveness = tonumber(_Parameter);
    end
end

function b_Reward_AI_Aggressiveness:CustomFunction()
    local player = (PlayerAIs[self.AIPlayer]
        or AIPlayerTable[self.AIPlayer]
        or AIPlayer:new(self.AIPlayer, AIPlayerProfile_City));
    PlayerAIs[self.AIPlayer] = player;
    if self.Aggressiveness >= 2 then
        player.m_ProfileLoop = AIProfile_Skirmish;
        player.Skirmish = player.Skirmish or {};
        player.Skirmish.Claim_MinTime = SkirmishDefault.Claim_MinTime + (self.Aggressiveness - 2) * 390;
        player.Skirmish.Claim_MaxTime = player.Skirmish.Claim_MinTime * 2;
    else
        player.m_ProfileLoop = AIPlayerProfile_City;
    end
end

function b_Reward_AI_Aggressiveness:DEBUG(_Quest)
    if self.AIPlayer < 2 or Logic.GetStoreHouse(self.AIPlayer) == 0 then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": Player " .. self.PlayerID .. " is wrong")
        return true
    end
end

function b_Reward_AI_Aggressiveness:GetCustomData(_Index)
    assert(_Index == 1, "Error in " .. self.Name .. ": GetCustomData: Index is invalid.");
    return { "1", "2", "3" };
end

Core:RegisterBehavior(b_Reward_AI_Aggressiveness)

-- -------------------------------------------------------------------------- --

---
-- Stellt den Feind des Skirmish-KI ein.
--
-- Der Skirmish-KI (maximale Aggressivität) kann nur einen Spieler als Feind
-- behandeln. Für gewöhnlich ist dies der menschliche Spieler.
--
-- @param _PlayerID      PlayerID des KI
-- @param _EnemyPlayerID PlayerID des Feindes
-- @return Table mit Behavior
-- @within Reward
--
function Reward_AI_SetEnemy(...)
    return b_Reward_AI_SetEnemy:new(...);
end

b_Reward_AI_SetEnemy = {
    Name = "Reward_AI_SetEnemy",
    Description = {
        en = "Reward:Sets the enemy of an AI player (the AI only handles one enemy properly).",
        de = "Lohn: Legt den Feind eines KI-Spielers fest (die KI behandelt nur einen Feind korrekt).",
    },
    Parameter =
    {
        { ParameterType.PlayerID, en = "AI player", de = "KI-Spieler" },
        { ParameterType.PlayerID, en = "Enemy", de = "Feind" }
    }
};

function b_Reward_AI_SetEnemy:GetRewardTable()

    return {Reward.Custom, {self, self.CustomFunction} };

end

function b_Reward_AI_SetEnemy:AddParameter(_Index, _Parameter)

    if _Index == 0 then
        self.AIPlayer = _Parameter * 1;
    elseif _Index == 1 then
        self.Enemy = _Parameter * 1;
    end

end

function b_Reward_AI_SetEnemy:CustomFunction()

    local player = PlayerAIs[self.AIPlayer];
    if player and player.Skirmish then
        player.Skirmish.Enemy = self.Enemy;
    end

end

function b_Reward_AI_SetEnemy:DEBUG(_Quest)

    if self.AIPlayer <= 1 or self.AIPlayer >= 8 or Logic.PlayerGetIsHumanFlag(self.AIPlayer) then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": Player " .. self.AIPlayer .. " is wrong")
        return true
    end

end
Core:RegisterBehavior(b_Reward_AI_SetEnemy)

-- -------------------------------------------------------------------------- --

---
-- Ein Entity wird durch ein neues anderen Typs ersetzt.
--
-- Das neue Entity übernimmt Skriptname und Ausrichtung des alten Entity.
--
-- @param _Entity Skriptname oder ID des Entity
-- @param _Type   Neuer Typ des Entity
-- @param _Owner  Besitzer des Entity
-- @return Table mit Behavior
-- @within Reward
--
function Reward_ReplaceEntity(...)
    return b_Reward_ReplaceEntity:new(...);
end

b_Reward_ReplaceEntity = API.InstanceTable(b_Reprisal_ReplaceEntity);
b_Reward_ReplaceEntity.Name = "Reward_ReplaceEntity";
b_Reward_ReplaceEntity.Description.en = "Reward: Replaces an entity with a new one of a different type. The playerID can be changed too.";
b_Reward_ReplaceEntity.Description.de = "Lohn: Ersetzt eine Entity durch eine neue anderen Typs. Es kann auch die Spielerzugehörigkeit geändert werden.";
b_Reward_ReplaceEntity.GetReprisalTable = nil;

b_Reward_ReplaceEntity.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Core:RegisterBehavior(b_Reward_ReplaceEntity);

-- -------------------------------------------------------------------------- --

---
-- Setzt die Menge von Rohstoffen in einer Mine.
--
-- <b>Achtung:</b> Im Reich des Ostens darf die Mine nicht eingestürzt sein!
--
-- @param _ScriptName Skriptname der Mine
-- @param _Amount     Menge an Rohstoffen
-- @return Table mit Behavior
-- @within Reward
--
function Reward_SetResourceAmount(...)
    return b_Reward_SetResourceAmount:new(...);
end

b_Reward_SetResourceAmount = {
    Name = "Reward_SetResourceAmount",
    Description = {
        en = "Reward: Set the current and maximum amount of a resource doodad (the amount can also set to 0)",
        de = "Lohn: Setzt die aktuellen sowie maximalen Resourcen in einem Doodad (auch 0 ist möglich)",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Ressource", de = "Resource" },
        { ParameterType.Number, en = "Amount", de = "Menge" },
    },
}

function b_Reward_SetResourceAmount:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_SetResourceAmount:AddParameter(_Index, _Parameter)

    if (_Index == 0) then
        self.ScriptName = _Parameter
    elseif (_Index == 1) then
        self.Amount = _Parameter * 1
    end

end

function b_Reward_SetResourceAmount:CustomFunction(_Quest)
    if Logic.IsEntityDestroyed( self.ScriptName ) then
        return false
    end
    local EntityID = GetID( self.ScriptName )
    if Logic.GetResourceDoodadGoodType( EntityID ) == 0 then
        return false
    end
    Logic.SetResourceDoodadGoodAmount( EntityID, self.Amount )
end

function b_Reward_SetResourceAmount:DEBUG(_Quest)
    if not IsExisting(self.ScriptName) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": resource entity does not exist!")
        return true
    elseif not type(self.Amount) == "number" or self.Amount < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": resource amount can not be negative!")
        return true
    end
    return false;
end

Core:RegisterBehavior(b_Reward_SetResourceAmount);

-- -------------------------------------------------------------------------- --

---
-- Fügt dem Lagerhaus des Auftragnehmers eine Menge an Rohstoffen hinzu.
--
-- @param _Type   Rohstofftyp
-- @param _Amount Menge an Rohstoffen
-- @return Table mit Behavior
-- @within Reward
--
function Reward_Resources(...)
    return b_Reward_Resources:new(...);
end

b_Reward_Resources = {
    Name = "Reward_Resources",
    Description = {
        en = "Reward: The player receives a given amount of Goods in his store.",
        de = "Lohn: Legt der Partei die angegebenen Rohstoffe ins Lagerhaus.",
    },
    Parameter = {
        { ParameterType.RawGoods, en = "Type of good", de = "Resourcentyp" },
        { ParameterType.Number, en = "Amount of good", de = "Anzahl der Resource" },
    },
}

function b_Reward_Resources:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.GoodTypeName = _Parameter
    elseif (_Index == 1) then
        self.GoodAmount = _Parameter * 1
    end
end

function b_Reward_Resources:GetRewardTable()
    local GoodType = Logic.GetGoodTypeID(self.GoodTypeName)
    return { Reward.Resources, GoodType, self.GoodAmount }
end

Core:RegisterBehavior(b_Reward_Resources);

-- -------------------------------------------------------------------------- --

---
-- Entsendet einen Karren zum angegebenen Spieler.
--
-- Wenn der Spawnpoint ein Gebäude ist, wird der Wagen am Eingang erstellt.
-- Andernfalls kann der Spawnpoint gelöscht werden und der Wagen übernimmt
-- dann den Skriptnamen.
--
-- @param _ScriptName    Skriptname des Spawnpoint
-- @param _Owner         Empfänger der Lieferung
-- @param _Type          Typ des Wagens
-- @param _Good          Typ der Ware
-- @param _Amount        Menge an Waren
-- @param _OtherPlayer   Anderer Empfänger als Auftraggeber
-- @param _NoReservation Platzreservation auf dem Markt ignorieren (Sinnvoll?)
-- @param _Replace       Spawnpoint ersetzen
-- @return Table mit Behavior
-- @within Reward
--
function Reward_SendCart(...)
    return b_Reward_SendCart:new(...);
end

b_Reward_SendCart = {
    Name = "Reward_SendCart",
    Description = {
        en = "Reward: Sends a cart to a player. It spawns at a building or by replacing an entity. The cart can replace the entity if it's not a building.",
        de = "Lohn: Sendet einen Karren zu einem Spieler. Der Karren wird an einem Gebäude oder einer Entity erstellt. Er ersetzt die Entity, wenn diese kein Gebäude ist.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script entity", de = "Script Entity" },
        { ParameterType.PlayerID, en = "Owning player", de = "Besitzer" },
        { ParameterType.Custom, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Custom, en = "Good type", de = "Warentyp" },
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
        { ParameterType.Custom, en = "Override target player", de = "Anderer Zielspieler" },
        { ParameterType.Custom, en = "Ignore reservations", de = "Ignoriere Reservierungen" },
        { ParameterType.Custom, en = "Replace entity", de = "Entity ersetzen" },
    },
}

function b_Reward_SendCart:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_SendCart:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptNameEntity = _Parameter
    elseif (_Index == 1) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 2) then
        self.UnitKey = _Parameter
    elseif (_Index == 3) then
        self.GoodType = _Parameter
    elseif (_Index == 4) then
        self.GoodAmount = _Parameter * 1
    elseif (_Index == 5) then
        self.OverrideTargetPlayer = tonumber(_Parameter)
    elseif (_Index == 6) then
        self.IgnoreReservation = AcceptAlternativeBoolean(_Parameter)
    elseif (_Index == 7) then
        self.ReplaceEntity = AcceptAlternativeBoolean(_Parameter)
    end
end

function b_Reward_SendCart:CustomFunction(_Quest)

    if not IsExisting( self.ScriptNameEntity ) then
        return false;
    end

    local ID = SendCart(self.ScriptNameEntity,
                        self.PlayerID,
                        Goods[self.GoodType],
                        self.GoodAmount,
                        Entities[self.UnitKey],
                        self.IgnoreReservation    );

    if self.ReplaceEntity and Logic.IsBuilding(GetID(self.ScriptNameEntity)) == 0 then
        DestroyEntity(self.ScriptNameEntity);
        Logic.SetEntityName(ID, self.ScriptNameEntity);
    end
    if self.OverrideTargetPlayer then
        Logic.ResourceMerchant_OverrideTargetPlayerID(ID,self.OverrideTargetPlayer);
    end
end

function b_Reward_SendCart:GetCustomData( _Index )
    local Data = {}
    if _Index == 2 then
        Data = { "U_ResourceMerchant", "U_Medicus", "U_Marketer", "U_ThiefCart", "U_GoldCart", "U_Noblemen_Cart", "U_RegaliaCart" }
    elseif _Index == 3 then
        for k, v in pairs( Goods ) do
            if string.find( k, "^G_" ) then
                table.insert( Data, k )
            end
        end
        table.sort( Data )
    elseif _Index == 5 then
        table.insert( Data, "---" )
        for i = 1, 8 do
            table.insert( Data, i )
        end
    elseif _Index == 6 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    elseif _Index == 7 then
        table.insert( Data, "false" )
        table.insert( Data, "true" )
    end
    return Data
end

function b_Reward_SendCart:DEBUG(_Quest)
    if not IsExisting(self.ScriptNameEntity) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": spawnpoint does not exist!");
        return true;
    elseif not tonumber(self.PlayerID) or self.PlayerID < 1 or self.PlayerID > 8 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": got a invalid playerID!");
        return true;
    elseif not Entities[self.UnitKey] then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": entity type '"..self.UnitKey.."' is invalid!");
        return true;
    elseif not Goods[self.GoodType] then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": good type '"..self.GoodType.."' is invalid!");
        return true;
    elseif not tonumber(self.GoodAmount) or self.GoodAmount < 1 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": good amount can not be below 1!");
        return true;
    elseif tonumber(self.OverrideTargetPlayer) and (self.OverrideTargetPlayer < 1 or self.OverrideTargetPlayer > 8) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": overwrite target player with invalid playerID!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reward_SendCart);

-- -------------------------------------------------------------------------- --

---
-- Gibt dem Auftragnehmer eine Menge an Einheiten.
--
-- Die Einheiten erscheinen an der Burg. Hat der Spieler keine Burg, dann
-- erscheinen sie vorm Lagerhaus.
--
-- @param _Type   Typ der Einheit
-- @param _Amount Menge an Einheiten
-- @return Table mit Behavior
-- @within Reward
--
function Reward_Units(...)
    return b_Reward_Units:new(...)
end

b_Reward_Units = {
    Name = "Reward_Units",
    Description = {
        en = "Reward: Units",
        de = "Lohn: Einheiten",
    },
    Parameter = {
        { ParameterType.Entity, en = "Type name", de = "Typbezeichnung" },
        { ParameterType.Number, en = "Amount", de = "Anzahl" },
    },
}

function b_Reward_Units:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.EntityName = _Parameter
    elseif (_Index == 1) then
        self.Amount = _Parameter * 1
    end
end

function b_Reward_Units:GetRewardTable()
    return { Reward.Units, assert( Entities[self.EntityName] ), self.Amount }
end

Core:RegisterBehavior(b_Reward_Units);

-- -------------------------------------------------------------------------- --

---
-- Startet einen Quest neu.
--
-- @param _QuestName Name des Quest
-- @return Table mit Behavior
-- @within Reward
--
function Reward_QuestRestart(...)
    return b_Reward_QuestRestart(...)
end

b_Reward_QuestRestart = API.InstanceTable(b_Reprisal_QuestRestart);
b_Reward_QuestRestart.Name = "Reward_ReplaceEntity";
b_Reward_QuestRestart.Description.en = "Reward: Restarts a (completed) quest so it can be triggered and completed again.";
b_Reward_QuestRestart.Description.de = "Lohn: Startet eine (beendete) Quest neu, damit diese neu ausgelöst und beendet werden kann.";
b_Reward_QuestRestart.GetReprisalTable = nil;

b_Reward_QuestRestart.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Core:RegisterBehavior(b_Reward_QuestRestart);

-- -------------------------------------------------------------------------- --

---
-- Lässt einen Quest fehlschlagen.
--
-- @param _QuestName Name des Quest
-- @return Table mit Behavior
-- @within Reward
--
function Reward_QuestFailure(...)
    return b_Reward_QuestFailure(...)
end

b_Reward_QuestFailure = API.InstanceTable(b_Reprisal_ReplaceEntity);
b_Reward_QuestFailure.Name = "Reward_QuestFailure";
b_Reward_QuestFailure.Description.en = "Reward: Lets another active quest fail.";
b_Reward_QuestFailure.Description.de = "Lohn: Lässt eine andere aktive Quest fehlschlagen.";
b_Reward_QuestFailure.GetReprisalTable = nil;

b_Reward_QuestFailure.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Core:RegisterBehavior(b_Reward_QuestFailure);

-- -------------------------------------------------------------------------- --

---
-- Wertet einen Quest als erfolgreich.
--
-- @param _QuestName Name des Quest
-- @return Table mit Behavior
-- @within Reward
--
function Reward_QuestSuccess(...)
    return b_Reward_QuestSuccess(...)
end

b_Reward_QuestSuccess = API.InstanceTable(b_Reprisal_QuestSuccess);
b_Reward_QuestSuccess.Name = "Reward_QuestSuccess";
b_Reward_QuestSuccess.Description.en = "Reward: Completes another active quest successfully.";
b_Reward_QuestSuccess.Description.de = "Lohn: Beendet eine andere aktive Quest erfolgreich.";
b_Reward_QuestSuccess.GetReprisalTable = nil;

b_Reward_QuestSuccess.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Core:RegisterBehavior(b_Reward_QuestSuccess);

-- -------------------------------------------------------------------------- --

---
-- Triggert einen Quest.
--
-- @param _QuestName Name des Quest
-- @return Table mit Behavior
-- @within Reward
--
function Reward_QuestActivate(...)
    return b_Reward_QuestActivate(...)
end

b_Reward_QuestActivate = API.InstanceTable(b_Reprisal_QuestActivate);
b_Reward_QuestActivate.Name = "Reward_QuestActivate";
b_Reward_QuestActivate.Description.en = "Reward: Activates another quest that is not triggered yet.";
b_Reward_QuestActivate.Description.de = "Lohn: Aktiviert eine andere Quest die noch nicht ausgelöst wurde.";
b_Reward_QuestActivate.GetReprisalTable = nil;

b_Reward_QuestActivate.GetRewardTable = function(self, _Quest)
    return {Reward.Custom, {self, self.CustomFunction} }
end

Core:RegisterBehavior(b_Reward_QuestActivate)

-- -------------------------------------------------------------------------- --

---
-- Unterbricht einen Quest.
--
-- @param _QuestName Name des Quest
-- @return Table mit Behavior
-- @within Reward
--
function Reward_QuestInterrupt(...)
    return b_Reward_QuestInterrupt(...)
end

b_Reward_QuestInterrupt = API.InstanceTable(b_Reprisal_QuestInterrupt);
b_Reward_QuestInterrupt.Name = "Reward_QuestInterrupt";
b_Reward_QuestInterrupt.Description.en = "Reward: Interrupts another active quest without success or failure.";
b_Reward_QuestInterrupt.Description.de = "Lohn: Beendet eine andere aktive Quest ohne Erfolg oder Misserfolg.";
b_Reward_QuestInterrupt.GetReprisalTable = nil;

b_Reward_QuestInterrupt.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Core:RegisterBehavior(b_Reward_QuestInterrupt);

-- -------------------------------------------------------------------------- --

---
-- Unterbricht einen Quest, selbst wenn dieser noch nicht ausgelöst wurde.
--
-- @param _QuestName   Name des Quest
-- @param _EndetQuests Bereits beendete unterbrechen
-- @return Table mit Behavior
-- @within Reward
--
function Reward_QuestForceInterrupt(...)
    return b_Reward_QuestForceInterrupt(...)
end

b_Reward_QuestForceInterrupt = API.InstanceTable(b_Reprisal_QuestForceInterrupt);
b_Reward_QuestForceInterrupt.Name = "Reward_QuestForceInterrupt";
b_Reward_QuestForceInterrupt.Description.en = "Reward: Interrupts another quest (even when it isn't active yet) without success or failure.";
b_Reward_QuestForceInterrupt.Description.de = "Lohn: Beendet eine andere Quest, auch wenn diese noch nicht aktiv ist ohne Erfolg oder Misserfolg.";
b_Reward_QuestForceInterrupt.GetReprisalTable = nil;

b_Reward_QuestForceInterrupt.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Core:RegisterBehavior(b_Reward_QuestForceInterrupt);

-- -------------------------------------------------------------------------- --

---
-- Führt eine Funktion im Skript als Reward aus.
--
-- @param _FunctionName Name der Funktion
-- @return Table mit Behavior
-- @within Reward
--
function Reward_MapScriptFunction(...)
    return b_Reward_MapScriptFunction:new(...);
end

b_Reward_MapScriptFunction = API.InstanceTable(b_Reprisal_MapScriptFunction);
b_Reward_MapScriptFunction.Name = "Reprisal_MapScriptFunction";
b_Reward_MapScriptFunction.Description.en = "Reward: Calls a function within the global map script if the quest has failed.";
b_Reward_MapScriptFunction.Description.de = "Lohn: Ruft eine Funktion im globalen Kartenskript auf, wenn die Quest fehlschlägt.";
b_Reward_MapScriptFunction.GetReprisalTable = nil;

b_Reward_MapScriptFunction.GetRewardTable = function(self, _Quest)
    return {Reward.Custom, {self, self.CustomFunction}};
end

Core:RegisterBehavior(b_Reward_MapScriptFunction);

-- -------------------------------------------------------------------------- --

---
-- Ändert den Wert einer benutzerdefinierten Variable.
--
-- Benutzerdefinierte Variablen können ausschließlich Zahlen sein.
--
---- <p>Operatoren</p>
-- <ul>
-- <li>= - Variablenwert wird auf den Wert gesetzt</li>
-- <li>- - Variablenwert mit Wert Subtrahieren</li>
-- <li>+ - Variablenwert mit Wert addieren</li>
-- <li>* - Variablenwert mit Wert multiplizieren</li>
-- <li>/ - Variablenwert mit Wert dividieren</li>
-- <li>^ - Variablenwert mit Wert potenzieren</li>
-- </ul>
--
-- @param _Name     Name der Variable
-- @param _Operator Rechen- oder Zuweisungsoperator
-- @param _Value    Wert oder andere Custom Variable
-- @return Table mit Behavior
-- @within Reward
--
function Reward_CustomVariables(...)
    return b_Reward_CustomVariables:new(...);
end

b_Reward_CustomVariables = API.InstanceTable(b_Reprisal_CustomVariables);
b_Reward_CustomVariables.Name = "Reward_CustomVariables";
b_Reward_CustomVariables.Description.en = "Reward: Executes a mathematical operation with this variable. The other operand can be a number or another custom variable.";
b_Reward_CustomVariables.Description.de = "Lohn: Fuehrt eine mathematische Operation mit der Variable aus. Der andere Operand kann eine Zahl oder eine Custom-Varible sein.";
b_Reward_CustomVariables.GetReprisalTable = nil;

b_Reward_CustomVariables.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, {self, self.CustomFunction} };
end

Core:RegisterBehavior(b_Reward_CustomVariables)

-- -------------------------------------------------------------------------- --

---
-- Erlaubt oder verbietet einem Spieler eine Technologie.
--
-- @param _PlayerID   ID des Spielers
-- @param _Lock       Sperren/Entsperren
-- @param _Technology Name der Technologie
-- @return Table mit Behavior
-- @within Reward
--
function Reward_Technology(...)
    return b_Reward_Technology:new(...);
end

b_Reward_Technology = API.InstanceTable(b_Reprisal_Technology);
b_Reward_Technology.Name = "Reward_Technology";
b_Reward_Technology.Description.en = "Reward: Locks or unlocks a technology for the given player.";
b_Reward_Technology.Description.de = "Lohn: Sperrt oder erlaubt eine Technolgie fuer den angegebenen Player.";
b_Reward_Technology.GetReprisalTable = nil;

b_Reward_Technology.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, {self, self.CustomFunction} }
end

Core:RegisterBehavior(b_Reward_Technology);

---
-- Gibt dem Auftragnehmer eine Anzahl an Prestigepunkten.
--
-- @param _Amount Menge an Prestige
-- @return Table mit Behavior
-- @within Reward
--
function Reward_PrestigePoints(...)
    return b_Reward_PrestigePoints:mew(...);
end

b_Reward_PrestigePoints  = {
    Name = "Reward_PrestigePoints",
    Description = {
        en = "Reward: Prestige",
        de = "Lohn: Prestige",
    },
    Parameter = {
        { ParameterType.Number, en = "Points", de = "Punkte" },
    },
}

function b_Reward_PrestigePoints :AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Points = _Parameter
    end
end

function b_Reward_PrestigePoints :GetRewardTable()
    return { Reward.PrestigePoints, self.Points }
end

Core:RegisterBehavior(b_Reward_PrestigePoints);

-- -------------------------------------------------------------------------- --

---
-- Besetzt einen Außenposten mit Soldaten.
--
-- @param _ScriptName Skriptname des Außenposten
-- @param _Type       Soldatentyp
-- @return Table mit Behavior
-- @within Reward
--
function Reward_AI_MountOutpost(...)
    return b_Reward_AI_MountOutpost:new(...);
end

b_Reward_AI_MountOutpost = {
    Name = "Reward_AI_MountOutpost",
    Description = {
        en = "Reward: Places a troop of soldiers on a named outpost.",
        de = "Lohn: Platziert einen Trupp Soldaten auf einem Aussenposten der KI.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
        { ParameterType.Custom,      en = "Soldiers type", de = "Soldatentyp" },
    },
}

function b_Reward_AI_MountOutpost:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_AI_MountOutpost:AddParameter(_Index, _Parameter)
    if _Index == 0 then
        self.Scriptname = _Parameter
    else
        self.SoldiersType = _Parameter
    end
end

function b_Reward_AI_MountOutpost:CustomFunction(_Quest)
    local outpostID = assert(
        not Logic.IsEntityDestroyed(self.Scriptname) and GetID(self.Scriptname),
       _Quest.Identifier .. ": Error in " .. self.Name .. ": CustomFunction: Outpost is invalid"
    )
    local AIPlayerID = Logic.EntityGetPlayer(outpostID)
    local ax, ay = Logic.GetBuildingApproachPosition(outpostID)
    local TroopID = Logic.CreateBattalionOnUnblockedLand(Entities[self.SoldiersType], ax, ay, 0, AIPlayerID, 0)
    AICore.HideEntityFromAI(AIPlayerID, TroopID, true)
    Logic.CommandEntityToMountBuilding(TroopID, outpostID)
end

function b_Reward_AI_MountOutpost:GetCustomData(_Index)
    if _Index == 1 then
        local Data = {}
        for k,v in pairs(Entities) do
            if string.find(k, "U_MilitaryBandit") or string.find(k, "U_MilitarySword") or string.find(k, "U_MilitaryBow") then
                Data[#Data+1] = k
            end
        end
        return Data
    end
end

function b_Reward_AI_MountOutpost:DEBUG(_Quest)
    if Logic.IsEntityDestroyed(self.Scriptname) then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Outpost " .. self.Scriptname .. " is missing")
        return true
    end
end

Core:RegisterBehavior(b_Reward_AI_MountOutpost)

-- -------------------------------------------------------------------------- --

---
-- Startet einen Quest neu und lößt ihn sofort aus.
--
-- @param _QuestName Name des Quest
-- @return Table mit Behavior
-- @within Reward
--
function Reward_QuestRestartForceActive(...)
    return b_Reward_QuestRestartForceActive:new(...);
end

b_Reward_QuestRestartForceActive = {
    Name = "Reward_QuestRestartForceActive",
    Description = {
        en = "Reward: Restarts a (completed) quest and triggers it immediately.",
        de = "Lohn: Startet eine (beendete) Quest neu und triggert sie sofort.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Questname" },
    },
}

function b_Reward_QuestRestartForceActive:GetRewardTable()
    return { Reward.Custom,{self, self.CustomFunction} }
end

function b_Reward_QuestRestartForceActive:AddParameter(_Index, _Parameter)
    assert(_Index == 0, "Error in " .. self.Name .. ": AddParameter: Index is invalid.")
    self.QuestName = _Parameter
end

function b_Reward_QuestRestartForceActive:CustomFunction(_Quest)
    local QuestID, Quest = self:ResetQuest(_Quest);
    if QuestID then
        Quest:SetMsgKeyOverride()
        Quest:SetIconOverride()
        Quest:Trigger()
    end
end

b_Reward_QuestRestartForceActive.ResetQuest = b_Reward_QuestRestart.CustomFunction;
function b_Reward_QuestRestartForceActive:DEBUG(_Quest)
    if not Quests[GetQuestID(self.QuestName)] then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": Quest: "..  self.QuestName .. " does not exist")
        return true
    end
end

Core:RegisterBehavior(b_Reward_QuestRestartForceActive)

-- -------------------------------------------------------------------------- --

---
-- Baut das angegebene Gabäude um eine Stufe aus.
--
-- <b>Achtung:</b> Ein Gebäude muss erst fertig ausgebaut sein, bevor ein
-- weiterer Ausbau begonnen werden kann!
--
-- @param _ScriptName Skriptname des Gebäudes
-- @return Table mit Behavior
-- @within Reward
--
function Reward_UpgradeBuilding(...)
    return b_Reward_UpgradeBuilding:new(...);
end

b_Reward_UpgradeBuilding = {
    Name = "Reward_UpgradeBuilding",
    Description = {
        en = "Reward: Upgrades a building",
        de = "Lohn: Baut ein Gebäude aus"
    },
    Parameter =    {
        { ParameterType.ScriptName, en = "Building", de = "Gebäude" }
    }
};

function b_Reward_UpgradeBuilding:GetRewardTable()

    return {Reward.Custom, {self, self.CustomFunction}};

end

function b_Reward_UpgradeBuilding:AddParameter(_Index, _Parameter)

    if _Index == 0 then
        self.Building = _Parameter;
    end

end

function b_Reward_UpgradeBuilding:CustomFunction(_Quest)

    local building = GetID(self.Building);
    if building ~= 0
    and Logic.IsBuilding(building) == 1
    and Logic.IsBuildingUpgradable(building, true)
    and Logic.IsBuildingUpgradable(building, false)
    then
        Logic.UpgradeBuilding(building);
    end

end

function b_Reward_UpgradeBuilding:DEBUG(_Quest)

    local building = GetID(self.Building);
    if not (building ~= 0
            and Logic.IsBuilding(building) == 1
            and Logic.IsBuildingUpgradable(building, true)
            and Logic.IsBuildingUpgradable(building, false) )
    then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Building is wrong")
        return true
    end

end

Core:RegisterBehavior(b_Reward_UpgradeBuilding)

-- -------------------------------------------------------------------------- --



-- -------------------------------------------------------------------------- --
-- Trigger                                                                    --
-- -------------------------------------------------------------------------- --

---
-- Starte den Quest, wenn ein anderer Spieler entdeckt wurde.
--
-- Ein Spieler ist dann entdeckt, wenn sein Heimatterritorium aufgedeckt wird.
--
-- @param _PlayerID Zu entdeckender Spieler
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_PlayerDiscovered(...)
    return b_Trigger_PlayerDiscovered:new(...);
end

b_Trigger_PlayerDiscovered = {
    Name = "Trigger_PlayerDiscovered",
    Description = {
        en = "Trigger: if a given player has been discovered",
        de = "Auslöser: wenn ein angegebener Spieler entdeckt wurde",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
    },
}

function b_Trigger_PlayerDiscovered:GetTriggerTable(_Quest)
    return {Triggers.PlayerDiscovered, self.PlayerID}
end

function b_Trigger_PlayerDiscovered:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter * 1;
    end
end

Core:RegisterBehavior(b_Trigger_PlayerDiscovered);

-- -------------------------------------------------------------------------- --

---
-- Starte den Quest, wenn zwischen dem Empfänger und der angegebenen Partei
-- der geforderte Diplomatiestatus herrscht.
--
-- @param _PlayerID ID der Partei
-- @param _State    Diplomatie-Status
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnDiplomacy(...)
    return b_Trigger_OnDiplomacy:new(...);
end

b_Trigger_OnDiplomacy = {
    Name = "Trigger_OnDiplomacy",
    Description = {
        en = "Trigger: if diplomatic relations have been established with a player",
        de = "Auslöser: wenn ein angegebener Diplomatie-Status mit einem Spieler erreicht wurde.",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.DiplomacyState, en = "Relation", de = "Beziehung" },
    },
}

function b_Trigger_OnDiplomacy:GetTriggerTable(_Quest)
    return {Triggers.Diplomacy, self.PlayerID, assert( DiplomacyStates[self.DiplState] ) }
end

function b_Trigger_OnDiplomacy:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 1) then
        self.DiplState = _Parameter
    end
end

Core:RegisterBehavior(b_Trigger_OnDiplomacy);

-- -------------------------------------------------------------------------- --

---
-- Starte den Quest, sobald ein Bedürfnis nicht erfüllt wird.
--
-- @param _PlayerID ID des Spielers
-- @param _Need     Bedürfnis
-- @param _Amount   Menge an skreikenden Siedlern
-- @return Table mit Behavior
-- @within Trigger
-- 
function Trigger_OnNeedUnsatisfied(...)
    return b_Trigger_OnNeedUnsatisfied:new(...);
end

b_Trigger_OnNeedUnsatisfied = {
    Name = "Trigger_OnNeedUnsatisfied",
    Description = {
        en = "Trigger: if a specified need is unsatisfied",
        de = "Auslöser: wenn ein bestimmtes Beduerfnis nicht befriedigt ist.",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.Need, en = "Need", de = "Beduerfnis" },
        { ParameterType.Number, en = "Workers on strike", de = "Streikende Arbeiter" },
    },
}

function b_Trigger_OnNeedUnsatisfied:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnNeedUnsatisfied:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 1) then
        self.Need = _Parameter
    elseif (_Index == 2) then
        self.WorkersOnStrike = _Parameter * 1
    end
end

function b_Trigger_OnNeedUnsatisfied:CustomFunction(_Quest)
    return Logic.GetNumberOfStrikingWorkersPerNeed( self.PlayerID, Needs[self.Need] ) >= self.WorkersOnStrike
end

function b_Trigger_OnNeedUnsatisfied:DEBUG(_Quest)
    if Logic.GetStoreHouse(self.PlayerID) == 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": " .. self.PlayerID .. " does not exist.")
        return true
    elseif not Needs[self.Need] then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": " .. self.Need .. " does not exist.")
        return true
    elseif self.WorkersOnStrike < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": WorkersOnStrike value negative")
        return true
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_OnNeedUnsatisfied);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, wenn die angegebene Mine erschöpft ist.
-- 
-- @param _ScriptName Skriptname der Mine
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnResourceDepleted(...)
    return b_Trigger_OnResourceDepleted:new(...);
end

b_Trigger_OnResourceDepleted = {
    Name = "Trigger_OnResourceDepleted",
    Description = {
        en = "Trigger: if a resource is (temporarily) depleted",
        de = "Auslöser: wenn eine Ressource (zeitweilig) verbraucht ist",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
    },
}

function b_Trigger_OnResourceDepleted:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnResourceDepleted:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.ScriptName = _Parameter
    end
end

function b_Trigger_OnResourceDepleted:CustomFunction(_Quest)
    local ID = GetID(self.ScriptName)
    return not ID or ID == 0 or Logic.GetResourceDoodadGoodType(ID) == 0 or Logic.GetResourceDoodadGoodAmount(ID) == 0
end

Core:RegisterBehavior(b_Trigger_OnResourceDepleted);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald der angegebene Spieler eine Menge an Rohstoffen
-- im Lagerhaus hat.
--
-- @param  _PlayerID ID des Spielers
-- @param  _Type     Typ des Rohstoffes
-- @param _Amount    Menge an Rohstoffen
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnAmountOfGoods(...)
    return b_Trigger_OnAmountOfGoods:new(...);
end

b_Trigger_OnAmountOfGoods = {
    Name = "Trigger_OnAmountOfGoods",
    Description = {
        en = "Trigger: if the player has gathered a given amount of resources in his storehouse",
        de = "Auslöser: wenn der Spieler eine bestimmte Menge einer Ressource in seinem Lagerhaus hat",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "Player", de = "Spieler" },
        { ParameterType.RawGoods, en = "Type of good", de = "Resourcentyp" },
        { ParameterType.Number, en = "Amount of good", de = "Anzahl der Resource" },
    },
}

function b_Trigger_OnAmountOfGoods:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnAmountOfGoods:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.PlayerID = _Parameter * 1
    elseif (_Index == 1) then
        self.GoodTypeName = _Parameter
    elseif (_Index == 2) then
        self.GoodAmount = _Parameter * 1
    end
end

function b_Trigger_OnAmountOfGoods:CustomFunction(_Quest)
    local StoreHouseID = Logic.GetStoreHouse(self.PlayerID)
    if (StoreHouseID == 0) then
        return false
    end
    local GoodType = Logic.GetGoodTypeID(self.GoodTypeName)
    local GoodAmount = Logic.GetAmountOnOutStockByGoodType(StoreHouseID, GoodType)
    if (GoodAmount >= self.GoodAmount)then
        return true
    end
    return false
end

function b_Trigger_OnAmountOfGoods:DEBUG(_Quest)
    if Logic.GetStoreHouse(self.PlayerID) == 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": " .. self.PlayerID .. " does not exist.")
        return true
    elseif not Goods[self.GoodTypeName] then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Good type is wrong.")
        return true
    elseif self.GoodAmount < 0 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Good amount is negative.")
        return true
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_OnAmountOfGoods);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald ein anderer aktiv ist.
--
-- @param _QuestName Name des Quest
-- @param _Time      Wartezeit
-- return Table mit Behavior
-- @within Trigger
--
function Trigger_OnQuestActive(...)
    return b_Trigger_OnQuestActive(...);
end

b_Trigger_OnQuestActive = {
    Name = "Trigger_OnQuestActive",
    Description = {
        en = "Trigger: if a given quest has been activated. Waiting time optional",
        de = "Auslöser: wenn eine angegebene Quest aktiviert wurde. Optional mit Wartezeit",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Questname" },
        { ParameterType.Number,     en = "Waiting time", de = "Wartezeit"},
    },
}

function b_Trigger_OnQuestActive:GetTriggerTable(_Quest)
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnQuestActive:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.QuestName = _Parameter
    elseif (_Index == 1) then
        self.WaitTime = (_Parameter ~= nil and tonumber(_Parameter)) or 0
    end
end

function b_Trigger_OnQuestActive:CustomFunction(_Quest)
    local QuestID = GetQuestID(self.QuestName)
    if QuestID ~= nil then
        assert(type(QuestID) == "number");

        if (Quests[QuestID].State == QuestState.Active) then
            self.WasActivated = self.WasActivated or true;
        end
        if self.WasActivated then
            if self.WaitTime and self.WaitTime > 0 then
                self.WaitTimeTimer = self.WaitTimeTimer or Logic.GetTime();
                if Logic.GetTime() >= self.WaitTimeTimer + self.WaitTime then
                    return true;
                end
            else
                return true;
            end
        end
    end
    return false;
end

function b_Trigger_OnQuestActive:DEBUG(_Quest)
    if type(self.QuestName) ~= "string" then
        dbg("".._Quest.Identifier.." "..self.Name..": invalid quest name!");
        return true;
    elseif type(self.WaitTime) ~= "number" then
        dbg("".._Quest.Identifier.." "..self.Name..": waitTime must be a number!");
        return true;
    end
    return false;
end

function b_Trigger_OnQuestActive:Interrupt()
    -- does this realy matter after interrupt?
    -- self.WaitTimeTimer = nil;
    -- self.WasActivated = nil;
end

function b_Trigger_OnQuestActive:Reset()
    self.WaitTimeTimer = nil;
    self.WasActivated = nil;
end

Core:RegisterBehavior(b_Trigger_OnQuestActive);

-- -------------------------------------------------------------------------- --

---
-- Startet einen Quest, sobald ein anderer fehlschlägt.
--
-- @param _QuestName Name des Quest
-- @param _Time      Wartezeit
-- return Table mit Behavior
-- @within Trigger
--
function Trigger_OnQuestFailure(...)
    return b_Trigger_OnQuestFailure(...);
end

b_Trigger_OnQuestFailure = {
    Name = "Trigger_OnQuestFailure",
    Description = {
        en = "Trigger: if a given quest has failed. Waiting time optional",
        de = "Auslöser: wenn eine angegebene Quest fehlgeschlagen ist. Optional mit Wartezeit",
    },
    Parameter = {
        { ParameterType.QuestName,     en = "Quest name", de = "Questname" },
        { ParameterType.Number,     en = "Waiting time", de = "Wartezeit"},
    },
}

function b_Trigger_OnQuestFailure:GetTriggerTable(_Quest)
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnQuestFailure:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.QuestName = _Parameter
    elseif (_Index == 1) then
        self.WaitTime = (_Parameter ~= nil and tonumber(_Parameter)) or 0
    end
end

function b_Trigger_OnQuestFailure:CustomFunction(_Quest)
    if (GetQuestID(self.QuestName) ~= nil) then
        local QuestID = GetQuestID(self.QuestName)
        if (Quests[QuestID].Result == QuestResult.Failure) then
            if self.WaitTime and self.WaitTime > 0 then
                self.WaitTimeTimer = self.WaitTimeTimer or Logic.GetTime();
                if Logic.GetTime() >= self.WaitTimeTimer + self.WaitTime then
                    return true;
                end
            else
                return true;
            end
        end
    end
    return false;
end

function b_Trigger_OnQuestFailure:DEBUG(_Quest)
    if type(self.QuestName) ~= "string" then
        dbg("".._Quest.Identifier.." "..self.Name..": invalid quest name!");
        return true;
    elseif type(self.WaitTime) ~= "number" then
        dbg("".._Quest.Identifier.." "..self.Name..": waitTime must be a number!");
        return true;
    end
    return false;
end

function b_Trigger_OnQuestFailure:Interrupt()
    self.WaitTimeTimer = nil;
end

function b_Trigger_OnQuestFailure:Reset()
    self.WaitTimeTimer = nil;
end

Core:RegisterBehavior(b_Trigger_OnQuestFailure);

-- -------------------------------------------------------------------------- --

---
-- Startet einen Quest, wenn ein anderer noch nicht ausgelöst wurde.
--
-- Der Trigger löst auch aus, wenn der Quest bereits beendet wurde, da er
-- dazu vorher ausgelöst wurden sein muss.
--
-- @param _QuestName Name des Quest
-- @param _Time      Wartezeit
-- return Table mit Behavior
-- @within Trigger
--
function Trigger_OnQuestNotTriggered(...)
    return b_Trigger_OnQuestNotTriggered(...);
end

b_Trigger_OnQuestNotTriggered = {
    Name = "Trigger_OnQuestNotTriggered",
    Description = {
        en = "Trigger: if a given quest is not yet active. Should be used in combination with other triggers.",
        de = "Auslöser: wenn eine angegebene Quest noch inaktiv ist. Sollte mit weiteren Triggern kombiniert werden.",
    },
    Parameter = {
        { ParameterType.QuestName,     en = "Quest name", de = "Questname" },
    },
}

function b_Trigger_OnQuestNotTriggered:GetTriggerTable(_Quest)
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnQuestNotTriggered:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.QuestName = _Parameter
    end
end

function b_Trigger_OnQuestNotTriggered:CustomFunction(_Quest)
    if (GetQuestID(self.QuestName) ~= nil) then
        local QuestID = GetQuestID(self.QuestName)
        if (Quests[QuestID].State == QuestState.NotTriggered) then
            return true;
        end
    end
    return false;
end

function b_Trigger_OnQuestNotTriggered:DEBUG(_Quest)
    if type(self.QuestName) ~= "string" then
        dbg("".._Quest.Identifier.." "..self.Name..": invalid quest name!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_OnQuestNotTriggered);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald ein anderer unterbrochen wurde.
--
-- @param _QuestName Name des Quest
-- @param _Time      Wartezeit
-- return Table mit Behavior
-- @within Trigger
--
function Trigger_OnQuestInterrupted(...)
    return b_Trigger_OnQuestInterrupted(...);
end

b_Trigger_OnQuestInterrupted = {
    Name = "Trigger_OnQuestInterrupted",
    Description = {
        en = "Trigger: if a given quest has been interrupted. Should be used in combination with other triggers.",
        de = "Auslöser: wenn eine angegebene Quest abgebrochen wurde. Sollte mit weiteren Triggern kombiniert werden.",
    },
    Parameter = {
        { ParameterType.QuestName,     en = "Quest name", de = "Questname" },
        { ParameterType.Number,     en = "Waiting time", de = "Wartezeit"},
    },
}

function b_Trigger_OnQuestInterrupted:GetTriggerTable(_Quest)
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnQuestInterrupted:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.QuestName = _Parameter
    elseif (_Index == 1) then
        self.WaitTime = (_Parameter ~= nil and tonumber(_Parameter)) or 0
    end
end

function b_Trigger_OnQuestInterrupted:CustomFunction(_Quest)
    if (GetQuestID(self.QuestName) ~= nil) then
        local QuestID = GetQuestID(self.QuestName)
        if (Quests[QuestID].State == QuestState.Over and Quests[QuestID].Result == QuestResult.Interrupted) then
            if self.WaitTime and self.WaitTime > 0 then
                self.WaitTimeTimer = self.WaitTimeTimer or Logic.GetTime();
                if Logic.GetTime() >= self.WaitTimeTimer + self.WaitTime then
                    return true;
                end
            else
                return true;
            end
        end
    end
    return false;
end

function b_Trigger_OnQuestInterrupted:DEBUG(_Quest)
    if type(self.QuestName) ~= "string" then
        dbg("".._Quest.Identifier.." "..self.Name..": invalid quest name!");
        return true;
    elseif type(self.WaitTime) ~= "number" then
        dbg("".._Quest.Identifier.." "..self.Name..": waitTime must be a number!");
        return true;
    end
    return false;
end

function b_Trigger_OnQuestInterrupted:Interrupt()
    self.WaitTimeTimer = nil;
end

function b_Trigger_OnQuestInterrupted:Reset()
    self.WaitTimeTimer = nil;
end

Core:RegisterBehavior(b_Trigger_OnQuestInterrupted);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald ein anderer bendet wurde.
--
-- Dabei ist das Resultat egal. Der Quest kann entweder erfolgreich beendet
-- wurden oder fehlgeschlagen sein.
--
-- @param _QuestName Name des Quest
-- @param _Time      Wartezeit
-- return Table mit Behavior
-- @within Trigger
--
function Trigger_OnQuestOver(...)
    return b_Trigger_OnQuestOver(...);
end

b_Trigger_OnQuestOver = {
    Name = "Trigger_OnQuestOver",
    Description = {
        en = "Trigger: if a given quest has been finished, regardless of its result. Waiting time optional",
        de = "Auslöser: wenn eine angegebene Quest beendet wurde, unabhängig von deren Ergebnis. Wartezeit optional",
    },
    Parameter = {
        { ParameterType.QuestName,     en = "Quest name", de = "Questname" },
        { ParameterType.Number,     en = "Waiting time", de = "Wartezeit"},
    },
}

function b_Trigger_OnQuestOver:GetTriggerTable(_Quest)
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnQuestOver:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.QuestName = _Parameter
    elseif (_Index == 1) then
        self.WaitTime = (_Parameter ~= nil and tonumber(_Parameter)) or 0
    end
end

function b_Trigger_OnQuestOver:CustomFunction(_Quest)
    if (GetQuestID(self.QuestName) ~= nil) then
        local QuestID = GetQuestID(self.QuestName)
        if (Quests[QuestID].State == QuestState.Over and Quests[QuestID].Result ~= QuestResult.Interrupted) then
            if self.WaitTime and self.WaitTime > 0 then
                self.WaitTimeTimer = self.WaitTimeTimer or Logic.GetTime();
                if Logic.GetTime() >= self.WaitTimeTimer + self.WaitTime then
                    return true;
                end
            else
                return true;
            end
        end
    end
    return false;
end

function b_Trigger_OnQuestOver:DEBUG(_Quest)
    if type(self.QuestName) ~= "string" then
        dbg("".._Quest.Identifier.." "..self.Name..": invalid quest name!");
        return true;
    elseif type(self.WaitTime) ~= "number" then
        dbg("".._Quest.Identifier.." "..self.Name..": waitTime must be a number!");
        return true;
    end
    return false;
end

function b_Trigger_OnQuestOver:Interrupt()
    self.WaitTimeTimer = nil;
end

function b_Trigger_OnQuestOver:Reset()
    self.WaitTimeTimer = nil;
end

Core:RegisterBehavior(b_Trigger_OnQuestOver);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald ein anderer Quest erfolgreich abgeschlossen wurde.
--
-- @param _QuestName Name des Quest
-- @param _Time      Wartezeit
-- return Table mit Behavior
-- @within Trigger
--
function Trigger_OnQuestSuccess(...)
    return b_Trigger_OnQuestSuccess:new(...);
end

b_Trigger_OnQuestSuccess = {
    Name = "Trigger_OnQuestSuccess",
    Description = {
        en = "Trigger: if a given quest has been finished successfully. Waiting time optional",
        de = "Auslöser: wenn eine angegebene Quest erfolgreich abgeschlossen wurde. Wartezeit optional",
    },
    Parameter = {
        { ParameterType.QuestName,     en = "Quest name", de = "Questname" },
        { ParameterType.Number,     en = "Waiting time", de = "Wartezeit"},
    },
}

function b_Trigger_OnQuestSuccess:GetTriggerTable(_Quest)
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnQuestSuccess:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.QuestName = _Parameter
    elseif (_Index == 1) then
        self.WaitTime = (_Parameter ~= nil and tonumber(_Parameter)) or 0
    end
end

function b_Trigger_OnQuestSuccess:CustomFunction()
    if (GetQuestID(self.QuestName) ~= nil) then
        local QuestID = GetQuestID(self.QuestName)
        if (Quests[QuestID].Result == QuestResult.Success) then
            if self.WaitTime and self.WaitTime > 0 then
                self.WaitTimeTimer = self.WaitTimeTimer or Logic.GetTime();
                if Logic.GetTime() >= self.WaitTimeTimer + self.WaitTime then
                    return true;
                end
            else
                return true;
            end
        end
    end
    return false;
end

function b_Trigger_OnQuestSuccess:DEBUG(_Quest)
    if type(self.QuestName) ~= "string" then
        dbg("".._Quest.Identifier.." "..self.Name..": invalid quest name!");
        return true;
    elseif type(self.WaitTime) ~= "number" then
        dbg("".._Quest.Identifier.." "..self.Name..": waittime must be a number!");
        return true;
    end
    return false;
end

function b_Trigger_OnQuestSuccess:Interrupt()
    self.WaitTimeTimer = nil;
end

function b_Trigger_OnQuestSuccess:Reset()
    self.WaitTimeTimer = nil;
end

Core:RegisterBehavior(b_Trigger_OnQuestSuccess);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, wenn eine benutzerdefinierte Variable einen bestimmten
-- Wert angenommen hat.
--
-- Benutzerdefinierte Variablen müssen Zahlen sein.
--
-- @param _Name     Name der Variable
-- @param _Relation Vergleichsoperator
-- @param _Value    Wert oder Custom Variable
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_CustomVariables(...)
    return b_Trigger_CustomVariables:new(...);
end

b_Trigger_CustomVariables = {
    Name = "Trigger_CustomVariables",
    Description = {
        en = "Trigger: if the variable has a certain value.",
        de = "Auslöser: wenn die Variable einen bestimmen Wert eingenommen hat.",
    },
    Parameter = {
        { ParameterType.Default, en = "Name of Variable", de = "Variablennamen" },
        { ParameterType.Custom,  en = "Relation", de = "Relation" },
        { ParameterType.Default, en = "Value", de = "Wert" }
    }
};

function b_Trigger_CustomVariables:GetTriggerTable()
    return { Triggers.Custom2, {self, self.CustomFunction} };
end

function b_Trigger_CustomVariables:AddParameter(_Index, _Parameter)
    if _Index == 0 then
        self.VariableName = _Parameter
    elseif _Index == 1 then
        self.Relation = _Parameter
    elseif _Index == 2 then
        local value = tonumber(_Parameter);
        value = (value ~= nil and value) or _Parameter;
        self.Value = value
    end
end

function b_Trigger_CustomVariables:CustomFunction()
    if _G["QSB_CustomVariables_"..self.VariableName] ~= nil then
        if self.Relation == "==" then
            return _G["QSB_CustomVariables_"..self.VariableName] == ((type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value]);
        elseif self.Relation ~= "~=" then
            return _G["QSB_CustomVariables_"..self.VariableName] ~= ((type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value]);
        elseif self.Relation == ">" then
            return _G["QSB_CustomVariables_"..self.VariableName] > ((type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value]);
        elseif self.Relation == ">=" then
            return _G["QSB_CustomVariables_"..self.VariableName] >= ((type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value]);
        elseif self.Relation == "<=" then
            return _G["QSB_CustomVariables_"..self.VariableName] <= ((type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value]);
        else
            return _G["QSB_CustomVariables_"..self.VariableName] < ((type(self.Value) ~= "string" and self.Value) or _G["QSB_CustomVariables_"..self.Value]);
        end
    end
    return false;
end

function b_Trigger_CustomVariables:GetCustomData( _Index )
    if _Index == 1 then
        return {"==", "~=", "<=", "<", ">", ">="};
    end
end

function b_Trigger_CustomVariables:DEBUG(_Quest)
    local relations = {"==", "~=", "<=", "<", ">", ">="}
    local results    = {true, false, nil}

    if not _G["QSB_CustomVariables_"..self.VariableName] then
        dbg(_Quest.Identifier.." "..self.Name..": variable '"..self.VariableName.."' do not exist!");
        return true;
    elseif not Inside(self.Relation,relations) then
        dbg(_Quest.Identifier.." "..self.Name..": '"..self.Relation.."' is an invalid relation!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_CustomVariables)

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest sofort.
--
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_AlwaysActive()
    return b_Trigger_AlwaysActive:new()
end

b_Trigger_AlwaysActive = {
    Name = "Trigger_AlwaysActive",
    Description = {
        en = "Trigger: the map has been started.",
        de = "Auslöser: Start der Karte.",
    },
}

function b_Trigger_AlwaysActive:GetTriggerTable(_Quest)
    return {Triggers.Time, 0 }
end

Core:RegisterBehavior(b_Trigger_AlwaysActive);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest im angegebenen Monat.
--
-- @param _Month Monat
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnMonth(...)
    return b_Trigger_OnMonth:new(...);
end

b_Trigger_OnMonth = {
    Name = "Trigger_OnMonth",
    Description = {
        en = "Trigger: a specified month",
        de = "Auslöser: ein bestimmter Monat",
    },
    Parameter = {
        { ParameterType.Custom, en = "Month", de = "Monat" },
    },
}

function b_Trigger_OnMonth:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnMonth:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Month = _Parameter * 1
    end
end

function b_Trigger_OnMonth:CustomFunction(_Quest)
    return self.Month == Logic.GetCurrentMonth()
end

function b_Trigger_OnMonth:GetCustomData( _Index )
    local Data = {}
    if _Index == 0 then
        for i = 1, 12 do
            table.insert( Data, i )
        end
    else
        assert( false )
    end
    return Data
end

function b_Trigger_OnMonth:DEBUG(_Quest)
    if self.Month < 1 or self.Month > 12 then
        dbg(_Quest.Identifier .. " " .. self.Name .. ": Month has the wrong value")
        return true
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_OnMonth);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest sobald der Monsunregen einsetzt.
--
-- <b>Achtung:</b> Dieses Behavior ist nur für Reich des Ostens verfügbar.
--
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnMonsoon()
    return b_Trigger_OnMonsoon:new();
end

b_Trigger_OnMonsoon = {
    Name = "Trigger_OnMonsoon",
    Description = {
        en = "Trigger: on monsoon.",
        de = "Auslöser: wenn der Monsun beginnt.",
    },
    RequiresExtraNo = 1,
}

function b_Trigger_OnMonsoon:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnMonsoon:CustomFunction(_Quest)
    if Logic.GetWeatherDoesShallowWaterFlood(0) then
        return true
    end
end

Core:RegisterBehavior(b_Trigger_OnMonsoon);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest sobald der Timer abgelaufen ist.
--
-- Der Timer zählt immer vom Start der Map an.
--
-- @param _Time Zeit bis zum Start
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_Time(...)
    return b_Trigger_Time:new(...);
end

b_Trigger_Time = {
    Name = "Trigger_Time",
    Description = {
        en = "Trigger: a given amount of time since map start",
        de = "Auslöser: eine gewisse Anzahl Sekunden nach Spielbeginn",
    },
    Parameter = {
        { ParameterType.Number, en = "Time (sec.)", de = "Zeit (Sek.)" },
    },
}

function b_Trigger_Time:GetTriggerTable(_Quest)
    return {Triggers.Time, self.Time }
end

function b_Trigger_Time:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Time = _Parameter * 1
    end
end

Core:RegisterBehavior(b_Trigger_Time);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest sobald das Wasser gefriert.
--
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnWaterFreezes()
    return b_Trigger_OnWaterFreezes:new();
end

b_Trigger_OnWaterFreezes = {
    Name = "Trigger_OnWaterFreezes",
    Description = {
        en = "Trigger: if the water starts freezing",
        de = "Auslöser: wenn die Gewässer gefrieren",
    },
}

function b_Trigger_OnWaterFreezes:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnWaterFreezes:CustomFunction(_Quest)
    if Logic.GetWeatherDoesWaterFreeze(0) then
        return true
    end
end

Core:RegisterBehavior(b_Trigger_OnWaterFreezes);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest niemals.
--
-- Quests, für die dieser Trigger gesetzt ist, müssen durch einen anderen
-- Quest über Reward_QuestActive oder Reprisal_QuestActive gestartet werden.
--
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_NeverTriggered()
    return b_Trigger_NeverTriggered:new();
end

b_Trigger_NeverTriggered = {
    Name = "Trigger_NeverTriggered",
    Description = {
        en = "Never triggers a Quest. The quest may be set active by Reward_QuestActivate or Reward_QuestRestartForceActive",
        de = "Löst nie eine Quest aus. Die Quest kann von Reward_QuestActivate oder Reward_QuestRestartForceActive aktiviert werden.",
    },
}

function b_Trigger_NeverTriggered:GetTriggerTable()

    return {Triggers.Custom2, {self, function() end} }

end

Core:RegisterBehavior(b_Trigger_NeverTriggered)

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald wenigstens einer von zwei Quests fehlschlägt.
--
-- @param _QuestName1 Name des ersten Quest
-- @param _QuestName2 Name des zweiten Quest
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnAtLeastOneQuestFailure(...)
    return b_Trigger_OnAtLeastOneQuestFailure:new(...);
end

b_Trigger_OnAtLeastOneQuestFailure = {
    Name = "Trigger_OnAtLeastOneQuestFailure",
    Description = {
        en = "Trigger: if one or both of the given quests have failed.",
        de = "Auslöser: wenn einer oder beide der angegebenen Aufträge fehlgeschlagen sind.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest Name 1", de = "Questname 1" },
        { ParameterType.QuestName, en = "Quest Name 2", de = "Questname 2" },
    },
}

function b_Trigger_OnAtLeastOneQuestFailure:GetTriggerTable(_Quest)
    return {Triggers.Custom2, {self, self.CustomFunction}};
end

function b_Trigger_OnAtLeastOneQuestFailure:AddParameter(_Index, _Parameter)
    self.QuestTable = {};

    if (_Index == 0) then
        self.Quest1 = _Parameter;
    elseif (_Index == 1) then
        self.Quest2 = _Parameter;
    end
end

function b_Trigger_OnAtLeastOneQuestFailure:CustomFunction(_Quest)
    local Quest1 = Quests[GetQuestID(self.Quest1)];
    local Quest2 = Quests[GetQuestID(self.Quest2)];
    if (Quest1.State == QuestState.Over and Quest1.Result == QuestResult.Failure)
    or (Quest2.State == QuestState.Over and Quest2.Result == QuestResult.Failure) then
        return true;
    end
    return false;
end

function b_Trigger_OnAtLeastOneQuestFailure:DEBUG(_Quest)
    if self.Quest1 == self.Quest2 then
        dbg(_Quest.Identifier..": "..self.Name..": Both quests are identical!");
        return true;
    elseif not IsValidQuest(self.Quest1) then
        dbg(_Quest.Identifier..": "..self.Name..": Quest '"..self.Quest1.."' does not exist!");
        return true;
    elseif not IsValidQuest(self.Quest2) then
        dbg(_Quest.Identifier..": "..self.Name..": Quest '"..self.Quest2.."' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_OnAtLeastOneQuestFailure);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald wenigstens einer von zwei Quests erfolgreich ist.
--
-- @param _QuestName1 Name des ersten Quest
-- @param _QuestName2 Name des zweiten Quest
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnAtLeastOneQuestSuccess(...)
    return b_Trigger_OnAtLeastOneQuestSuccess:new(...);
end

b_Trigger_OnAtLeastOneQuestSuccess = {
    Name = "Trigger_OnAtLeastOneQuestSuccess",
    Description = {
        en = "Trigger: if one or both of the given quests are won.",
        de = "Auslöser: wenn einer oder beide der angegebenen Aufträge gewonnen wurden.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest Name 1", de = "Questname 1" },
        { ParameterType.QuestName, en = "Quest Name 2", de = "Questname 2" },
    },
}

function b_Trigger_OnAtLeastOneQuestSuccess:GetTriggerTable(_Quest)
    return {Triggers.Custom2, {self, self.CustomFunction}};
end

function b_Trigger_OnAtLeastOneQuestSuccess:AddParameter(_Index, _Parameter)
    self.QuestTable = {};

    if (_Index == 0) then
        self.Quest1 = _Parameter;
    elseif (_Index == 1) then
        self.Quest2 = _Parameter;
    end
end

function b_Trigger_OnAtLeastOneQuestSuccess:CustomFunction(_Quest)
    local Quest1 = Quests[GetQuestID(self.Quest1)];
    local Quest2 = Quests[GetQuestID(self.Quest2)];
    if (Quest1.State == QuestState.Over and Quest1.Result == QuestResult.Success)
    or (Quest2.State == QuestState.Over and Quest2.Result == QuestResult.Success) then
        return true;
    end
    return false;
end

function b_Trigger_OnAtLeastOneQuestSuccess:DEBUG(_Quest)
    if self.Quest1 == self.Quest2 then
        dbg(_Quest.Identifier..": "..self.Name..": Both quests are identical!");
        return true;
    elseif not IsValidQuest(self.Quest1) then
        dbg(_Quest.Identifier..": "..self.Name..": Quest '"..self.Quest1.."' does not exist!");
        return true;
    elseif not IsValidQuest(self.Quest2) then
        dbg(_Quest.Identifier..": "..self.Name..": Quest '"..self.Quest2.."' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_OnAtLeastOneQuestSuccess);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald mindestens X von Y Quests erfolgreich sind.
--
-- @param _MinAmount   Mindestens zu erfüllen (max. 5)
-- @param _QuestAmount Anzahl geprüfter Quests (max. 5 und >= _MinAmount)
-- @param _Quest1      Name des 1. Quest
-- @param _Quest2      Name des 2. Quest
-- @param _Quest3      Name des 3. Quest
-- @param _Quest4      Name des 4. Quest
-- @param _Quest5      Name des 5. Quest
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnAtLeastXOfYQuestsSuccess(...)
    return b_Trigger_OnAtLeastXOfYQuestsSuccess:new(...);
end

b_Trigger_OnAtLeastXOfYQuestsSuccess = {
    Name = "Trigger_OnAtLeastXOfYQuestsSuccess",
    Description = {
        en = "Trigger: if at least X of Y given quests has been finished successfully.",
        de = "Auslöser: wenn X von Y angegebener Quests erfolgreich abgeschlossen wurden.",
    },
    Parameter = {
        { ParameterType.Custom, en = "Least Amount", de = "Mindest Anzahl" },
        { ParameterType.Custom, en = "Quest Amount", de = "Quest Anzahl" },
        { ParameterType.QuestName, en = "Quest name 1", de = "Questname 1" },
        { ParameterType.QuestName, en = "Quest name 2", de = "Questname 2" },
        { ParameterType.QuestName, en = "Quest name 3", de = "Questname 3" },
        { ParameterType.QuestName, en = "Quest name 4", de = "Questname 4" },
        { ParameterType.QuestName, en = "Quest name 5", de = "Questname 5" },
    },
}

function b_Trigger_OnAtLeastXOfYQuestsSuccess:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnAtLeastXOfYQuestsSuccess:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.LeastAmount = tonumber(_Parameter)
    elseif (_Index == 1) then
        self.QuestAmount = tonumber(_Parameter)
    elseif (_Index == 2) then
        self.QuestName1 = _Parameter
    elseif (_Index == 3) then
        self.QuestName2 = _Parameter
    elseif (_Index == 4) then
        self.QuestName3 = _Parameter
    elseif (_Index == 5) then
        self.QuestName4 = _Parameter
    elseif (_Index == 6) then
        self.QuestName5 = _Parameter
    end
end

function b_Trigger_OnAtLeastXOfYQuestsSuccess:CustomFunction()
    local least = 0
    for i = 1, self.QuestAmount do
        local QuestID = GetQuestID(self["QuestName"..i]);
        if IsValidQuest(QuestID) then
			if (Quests[QuestID].Result == QuestResult.Success) then
				least = least + 1
				if least >= self.LeastAmount then
					return true
				end
			end
		end
    end
    return false
end

function b_Trigger_OnAtLeastXOfYQuestsSuccess:DEBUG(_Quest)
    local leastAmount = self.LeastAmount
    local questAmount = self.QuestAmount
    if leastAmount <= 0 or leastAmount >5 then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": LeastAmount is wrong")
        return true
    elseif questAmount <= 0 or questAmount > 5 then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": QuestAmount is wrong")
        return true
    elseif leastAmount > questAmount then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": LeastAmount is greater than QuestAmount")
        return true
    end
    for i = 1, questAmount do
        if not IsValidQuest(self["QuestName"..i]) then
            dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": Quest ".. self["QuestName"..i] .. " not found")
            return true
        end
    end
    return false
end

function b_Trigger_OnAtLeastXOfYQuestsSuccess:GetCustomData(_Index)
    if (_Index == 0) or (_Index == 1) then
        return {"1", "2", "3", "4", "5"}
    end
end

Core:RegisterBehavior(b_Trigger_OnAtLeastXOfYQuestsSuccess)

-- -------------------------------------------------------------------------- --
-- Application Space                                                          --
-- -------------------------------------------------------------------------- --

BundleClassicBehaviors = {
    Global = {},
    Local = {}
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Application Space
-- @local
--
function BundleClassicBehaviors.Global:Install()

end

-- Local Script ----------------------------------------------------------------

---
-- Initialisiert das Bundle im lokalen Skript.
-- @within Application Space
-- @local
--
function BundleClassicBehaviors.Local:Install()

end

Core:RegisterBundle("BundleClassicBehaviors");

-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleSymfoniaBehaviors                                      # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle enthält einige weitere nützliche Standard-Behavior.
--
-- @module BundleSymfoniaBehaviors
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User Space                                                                 --
-- -------------------------------------------------------------------------- --



-- -------------------------------------------------------------------------- --
-- Goals                                                                      --
-- -------------------------------------------------------------------------- --

---
-- Ein Entity muss sich zu einem Ziel bewegen und eine Distanz unterschreiten.
--
-- Optional kann das Ziel mit einem Marker markiert werden.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Target     Skriptname des Ziels
-- @param _Distance   Entfernung
-- @param _UseMarker  Ziel markieren
-- @return Table mit Behavior
-- @within Goal
--
function Goal_MoveToPosition(...)
    return b_Goal_MoveToPosition:new(...);
end

b_Goal_MoveToPosition = {
    Name = "Goal_MoveToPosition",
    Description = {
        en = "Goal: A entity have to moved as close as the distance to another entity. The target can be marked with a static marker.",
        de = "Ziel: Eine Entity muss sich einer anderen bis auf eine bestimmte Distanz nähern. Die Lupe wird angezeigt, das Ziel kann markiert werden.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",      de = "Entity" },
        { ParameterType.ScriptName, en = "Target",      de = "Ziel" },
        { ParameterType.Number,     en = "Distance", de = "Entfernung" },
        { ParameterType.Custom,     en = "Marker",      de = "Ziel markieren" },
    },
}

function b_Goal_MoveToPosition:GetGoalTable(__quest_)
    return {Objective.Distance, self.Entity, self.Target, self.Distance, self.Marker}
end

function b_Goal_MoveToPosition:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Entity = __parameter_
    elseif (__index_ == 1) then
        self.Target = __parameter_
    elseif (__index_ == 2) then
        self.Distance = __parameter_ * 1
    elseif (__index_ == 3) then
        self.Marker = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Goal_MoveToPosition:GetCustomData( __index_ )
    local Data = {};
    if __index_ == 3 then
        Data = {"true", "false"}
    end
    return Data
end

Core:RegisterBehavior(b_Goal_MoveToPosition);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss einen bestimmten Quest abschließen.
--
-- @param _QuestName Name des Quest
-- @return Table mit Behavior
-- @within Goal
--
function Goal_WinQuest(...)
    return b_Goal_WinQuest:new(...);
end

b_Goal_WinQuest = {
    Name = "Goal_WinQuest",
    Description = {
        en = "Goal: The player has to win a given quest",
        de = "Ziel: Der Spieler muss eine angegebene Quest erfolgreich abschliessen.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest Name",      de = "Questname" },
    },
}

function b_Goal_WinQuest:GetGoalTable(__quest_)
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_WinQuest:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Quest = __parameter_;
    end
end

function b_Goal_WinQuest:CustomFunction(__quest_)
    local quest = Quests[GetQuestID(self.Quest)];
    if quest then
        if quest.Result == QuestResult.Failure then
            return false;
        end
        if quest.Result == QuestResult.Success then
            return true;
        end
    end
    return nil;
end

function b_Goal_WinQuest:DEBUG(__quest_)
    if Quests[GetQuestID(self.Quest)] == nil then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": Quest '"..self.Quest.."' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Goal_WinQuest);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss eine bestimmte Menge Gold mit Dieben stehlen.
--
-- Dabei ist es egal von welchem Spieler. Diebe können Gold nur aus
-- Stadtgebäude stehlen.
--
-- @param _Amount       Menge an Gold
-- @param _ShowProgress Fortschritt ausgeben
-- @return Table mit Behavior
-- @within Goal
--
function Goal_StealGold(...)
    return b_Goal_StealGold:new(...)
end

b_Goal_StealGold = {
    Name = "Goal_StealGold",
    Description = {
        en = "Goal: Steal an explicit amount of gold from a players or any players city buildings.",
        de = "Ziel: Diebe sollen eine bestimmte Menge Gold aus feindlichen Stadtgebäuden stehlen.",
    },
    Parameter = {
        { ParameterType.Number, en = "Amount on Gold", de = "Zu stehlende Menge" },
        { ParameterType.Custom, en = "Print progress", de = "Fortschritt ausgeben" },
    },
}

function b_Goal_StealGold:GetGoalTable(__quest_)
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_StealGold:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Amount = __parameter_ * 1;
    elseif (__index_ == 1) then
        __parameter_ = __parameter_ or "true"
        self.Printout = AcceptAlternativeBoolean(__parameter_);
    end
    self.StohlenGold = 0;
end

function b_Goal_StealGold:GetCustomData(__index_)
    if __index_ == 1 then
        return { "true", "false" };
    end
end

function b_Goal_StealGold:SetDescriptionOverwrite(__quest_)
    local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    local amount = self.Amount-self.StohlenGold;
    amount = (amount > 0 and amount) or 0;
    local text = {
        de = "Gold stehlen {cr}{cr}Aus Stadtgebäuden zu stehlende Goldmenge: ",
        en = "Steal gold {cr}{cr}Amount on gold to steal from city buildings: ",
    };
    return "{center}" .. text[lang] .. amount
end

function b_Goal_StealGold:CustomFunction(__quest_)
    Core:ChangeCustomQuestCaptionText(__quest_.Identifier, self:SetDescriptionOverwrite(__quest_));

    if self.StohlenGold >= self.Amount then
        return true;
    end
    return nil;
end

function b_Goal_StealGold:GetIcon()
    return {5,13};
end

function b_Goal_StealGold:DEBUG(__quest_)
    if tonumber(self.Amount) == nil and self.Amount < 0 then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": amount can not be negative!");
        return true;
    end
    return false;
end

function b_Goal_StealGold:Reset()
    self.StohlenGold = 0;
end

Core:RegisterBehavior(b_Goal_StealGold)

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss ein bestimmtes Stadtgebäude bestehlen.
--
-- Eine Kirche wird immer Sabotiert. Ein Lagerhaus verhält sich ähnlich zu
-- einer Burg.
--
-- @param _ScriptName Skriptname des Gebäudes
-- @return Table mit Behavior
-- @within Goal
--
function Goal_StealBuilding(...)
    return b_Goal_StealBuilding:new(...)
end

b_Goal_StealBuilding = {
    Name = "Goal_StealBuilding",
    Description = {
        en = "Goal: The player has to steal from a building. Not a castle and not a village storehouse!",
        de = "Ziel: Der Spieler muss ein bestimmtes Gebäude bestehlen. Dies darf keine Burg und kein Dorflagerhaus sein!",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Building", de = "Gebäude" },
    },
}

function b_Goal_StealBuilding:GetGoalTable(__quest_)
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_StealBuilding:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Building = __parameter_
    end
    self.RobberList = {};
end

function b_Goal_StealBuilding:GetCustomData(__index_)
    if __index_ == 1 then
        return { "true", "false" };
    end
end

function b_Goal_StealBuilding:SetDescriptionOverwrite(__quest_)
    local isCathedral = Logic.IsEntityInCategory(GetID(self.Building), EntityCategories.Cathedrals) == 1;
    local isWarehouse = Logic.GetEntityType(GetID(self.Building)) == Entities.B_StoreHouse;
    local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    local text;

    if isCathedral then
        text = {
            de = "Sabotage {cr}{cr} Sabotiert die mit Pfeil markierte Kirche.",
            en = "Sabotage {cr}{cr} Sabotage the Church of the opponent.",
        };
    elseif isWarehouse then
        text = {
            de = "Lagerhaus bestehlen {cr}{cr} Sendet einen Dieb in das markierte Lagerhaus.",
            en = "Steal from storehouse {cr}{cr} Steal from the marked storehouse.",
        };
    else
        text = {
            de = "Geb�ude bestehlen {cr}{cr} Bestehlt das durch einen Pfeil markierte Gebäude.",
            en = "Steal from building {cr}{cr} Steal from the building marked by an arrow.",
        };
    end
    return "{center}" .. text[lang];
end

function b_Goal_StealBuilding:CustomFunction(__quest_)
    if not IsExisting(self.Building) then
        if self.Marker then
            Logic.DestroyEffect(self.Marker);
        end
        return false;
    end

    if not self.Marker then
        local pos = GetPosition(self.Building);
        self.Marker = Logic.CreateEffect(EGL_Effects.E_Questmarker, pos.X, pos.Y, 0);
    end

    if self.SuccessfullyStohlen then
        Logic.DestroyEffect(self.Marker);
        return true;
    end
    return nil;
end

function b_Goal_StealBuilding:GetIcon()
    return {5,13};
end

function b_Goal_StealBuilding:DEBUG(__quest_)
    local eTypeName = Logic.GetEntityTypeName(Logic.GetEntityType(GetID(self.Building)));
    local IsHeadquarter = Logic.IsEntityInCategory(GetID(self.Building), EntityCategories.Headquarters) == 1;
    if Logic.IsBuilding(GetID(self.Building)) == 0 then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": target is not a building");
        return true;
    elseif not IsExisting(self.Building) then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": target is destroyed :(");
        return true;
    elseif string.find(eTypeName, "B_NPC_BanditsHQ") or string.find(eTypeName, "B_NPC_Cloister") or string.find(eTypeName, "B_NPC_StoreHouse") then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": village storehouses are not allowed!");
        return true;
    elseif IsHeadquarter then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": use Goal_StealInformation for headquarters!");
        return true;
    end
    return false;
end

function b_Goal_StealBuilding:Reset()
    self.SuccessfullyStohlen = false;
    self.RobberList = {};
    self.Marker = nil;
end

function b_Goal_StealBuilding:Interrupt(__quest_)
    Logic.DestroyEffect(self.Marker);
end

Core:RegisterBehavior(b_Goal_StealBuilding)

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss einen Dieb in ein Gebäude hineinschicken.
--
-- Der Quest ist erfolgreich, sobald der Dieb in das Gebäude eindringt. Es
-- muss sich um ein Gebäude handeln, das bestohlen werden kann (Burg, Lager,
-- Kirche, Stadtgebäude mit Einnahmen)!
--
-- Optional kann der Dieb nach Abschluss gelöscht werden. Diese Option macht
-- es einfacher ihn durch z.B. einen Abfahrenden U_ThiefCart zu ersetzen.
--
-- @param _ScriptName  Skriptname des Gebäudes
-- @param _DeleteThief Dieb nach Abschluss löschen
-- @return Table mit Behavior
-- @within Goal
--
function Goal_Infiltrate(...)
    return b_Goal_Infiltrate:new(...)
end

b_Goal_Infiltrate = {
    Name = "Goal_Infiltrate",
    IconOverwrite = {5,13},
    Description = {
        en = "Goal: Infiltrate a building with a thief. A thief must be able to steal from the target building.",
        de = "Ziel: Infiltriere ein Gebäude mit einem Dieb. Nur mit Gebaueden moeglich, die bestohlen werden koennen.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Target Building", de = "Zielgebäude" },
        { ParameterType.Custom,     en = "Destroy Thief", de = "Dieb löschen" },
    },
}

function b_Goal_Infiltrate:GetGoalTable(__quest_)
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_Infiltrate:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Building = __parameter_
    elseif (__index_ == 1) then
        __parameter_ = __parameter_ or "true"
        self.Delete = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Goal_Infiltrate:GetCustomData(__index_)
    if __index_ == 1 then
        return { "true", "false" };
    end
end

function b_Goal_Infiltrate:SetDescriptionOverwrite(__quest_)
    if not __quest_.QuestDescription then
        local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
        local text = {
            de = "Gebäude infriltrieren {cr}{cr}Spioniere das markierte Gebäude mit einem Dieb aus!",
            en = "Infiltrate building {cr}{cr}Spy on the highlighted buildings with a thief!",
        };
        return text[lang];
    else
        return __quest_.QuestDescription;
    end
end

function b_Goal_Infiltrate:CustomFunction(__quest_)
    if not IsExisting(self.Building) then
        if self.Marker then
            Logic.DestroyEffect(self.Marker);
        end
        return false;
    end

    if not self.Marker then
        local pos = GetPosition(self.Building);
        self.Marker = Logic.CreateEffect(EGL_Effects.E_Questmarker, pos.X, pos.Y, 0);
    end

    if self.Infiltrated then
        Logic.DestroyEffect(self.Marker);
        return true;
    end
    return nil;
end

function b_Goal_Infiltrate:GetIcon()
    return self.IconOverwrite;
end

function b_Goal_Infiltrate:DEBUG(__quest_)
    if Logic.IsBuilding(GetID(self.Building)) == 0 then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": target is not a building");
        return true;
    elseif not IsExisting(self.Building) then
        dbg(__quest_.Identifier .. ": " .. self.Name .. ": target is destroyed :(");
        return true;
    end
    return false;
end

function b_Goal_Infiltrate:Reset()
    self.Infiltrated = false;
    self.Marker = nil;
end

function b_Goal_Infiltrate:Interrupt(__quest_)
    Logic.DestroyEffect(self.Marker);
end

Core:RegisterBehavior(b_Goal_Infiltrate);

-- -------------------------------------------------------------------------- --

---
-- Es muss eine Menge an Munition in der Kriegsmaschine erreicht werden.
-- 
-- <u>Relationen</u>
-- <ul>
-- <li>>= - Anzahl als Mindestmenge</li>
-- <li>< - Weniger als Anzahl</li>
-- </ul>
--
-- @param _ScriptName  Name des Kriegsgerät
-- @param _Relation    Mengenrelation
-- @param _Amount      Menge an Munition
-- @return Table mit Behavior
-- @within Goal
--
function Goal_AmmunitionAmount(...)
    return b_Goal_AmmunitionAmount:new(...);
end

b_Goal_AmmunitionAmount = {
    Name = "Goal_AmmunitionAmount",
    Description = {
        en = "Goal: Reach a smaller or bigger value than the given amount of ammunition in a war machine.",
        de = "Ziel: Ueber- oder unterschreite die angegebene Anzahl Munition in einem Kriegsgerät.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
        { ParameterType.Custom, en = "Relation", de = "Relation" },
        { ParameterType.Number, en = "Amount", de = "Menge" },
    },
}

function b_Goal_AmmunitionAmount:GetGoalTable()
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function b_Goal_AmmunitionAmount:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Scriptname = _Parameter
    elseif (_Index == 1) then
        self.bRelSmallerThan = tostring(_Parameter) == "true" or _Parameter == "<"
    elseif (_Index == 2) then
        self.Amount = _Parameter * 1
    end
end

function b_Goal_AmmunitionAmount:CustomFunction()
    local EntityID = GetID(self.Scriptname);
    if not IsExisting(EntityID) then
        return false;
    end
    local HaveAmount = Logic.GetAmmunitionAmount(EntityID);
    if ( self.bRelSmallerThan and HaveAmount < self.Amount ) or ( not self.bRelSmallerThan and HaveAmount >= self.Amount ) then
        return true;
    end
    return nil;
end

function b_Goal_AmmunitionAmount:DEBUG(_Quest)
    if self.Amount < 0 then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": Amount is negative");
        return true
    end
end

function b_Goal_AmmunitionAmount:GetCustomData( _Index )
    if _Index == 1 then
        return {"<", ">="};
    end
end

Core:RegisterBehavior(b_Goal_AmmunitionAmount)

-- -------------------------------------------------------------------------- --
-- Reprisals                                                                  --
-- -------------------------------------------------------------------------- --

---
-- Ändert die Position eines Siedlers oder eines Gebäudes.
--
-- Optional kann das Entity in einem bestimmten Abstand zum Ziel platziert
-- werden und das Ziel anschauen. Die Entfernung darf nicht kleiner sein
-- als 50!
--
-- @param _ScriptName Skriptname des Entity
-- @param _Target     Skriptname des Ziels
-- @param _LookAt     Gegenüberstellen
-- @param _Distance   Relative Entfernung (nur mit _LookAt)
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_SetPosition(...)
    return b_Reprisal_SetPosition:new(...);
end

b_Reprisal_SetPosition = {
    Name = "Reprisal_SetPosition",
    Description = {
        en = "Reprisal: Places an entity relative to the position of another. The entity can look the target.",
        de = "Vergeltung: Setzt eine Entity relativ zur Position einer anderen. Die Entity kann zum Ziel ausgerichtet werden.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",             de = "Entity", },
        { ParameterType.ScriptName, en = "Target position", de = "Zielposition", },
        { ParameterType.Custom,     en = "Face to face",     de = "Ziel ansehen", },
        { ParameterType.Number,     en = "Distance",         de = "Zielentfernung", },
    },
}

function b_Reprisal_SetPosition:GetReprisalTable(__quest_)
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_SetPosition:AddParameter( __index_, __parameter_ )
    if (__index_ == 0) then
        self.Entity = __parameter_;
    elseif (__index_ == 1) then
        self.Target = __parameter_;
    elseif (__index_ == 2) then
        self.FaceToFace = AcceptAlternativeBoolean(__parameter_)
    elseif (__index_ == 3) then
        self.Distance = (__parameter_ ~= nil and tonumber(__parameter_)) or 100;
    end
end

function b_Reprisal_SetPosition:CustomFunction(__quest_)
    if not IsExisting(self.Entity) or not IsExisting(self.Target) then
        return;
    end

    local entity = GetID(self.Entity);
    local target = GetID(self.Target);
    local x,y,z = Logic.EntityGetPos(target);
    if Logic.IsBuilding(target) == 1 then
        x,y = Logic.GetBuildingApproachPosition(target);
    end
    local ori = Logic.GetEntityOrientation(target)+90;

    if self.FaceToFace then
        x = x + self.Distance * math.cos( math.rad(ori) );
        y = y + self.Distance * math.sin( math.rad(ori) );
        Logic.DEBUG_SetSettlerPosition(entity, x, y);
        LookAt(self.Entity, self.Target);
    else
        if Logic.IsBuilding(target) == 1 then
            x,y = Logic.GetBuildingApproachPosition(target);
        end
        Logic.DEBUG_SetSettlerPosition(entity, x, y);
    end
end

function b_Reprisal_SetPosition:GetCustomData(__index_)
    if __index_ == 3 then
        return { "true", "false" }
    end
end

function b_Reprisal_SetPosition:DEBUG(__quest_)
    if self.FaceToFace then
        if tonumber(self.Distance) == nil or self.Distance < 50 then
            dbg(__quest_.Identifier.. " " ..self.Name.. ": Distance is nil or to short!");
            return true;
        end
    end
    if not IsExisting(self.Entity) or not IsExisting(self.Target) then
        dbg(__quest_.Identifier.. " " ..self.Name.. ": Mover entity or target entity does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_SetPosition);

-- -------------------------------------------------------------------------- --

---
-- Ändert den Eigentümer des Entity oder des Battalions.
-- 
-- @param _ScriptName Skriptname des Entity
-- @param _NewOwner   PlayerID des Eigentümers
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_ChangePlayer(...)
    return b_Reprisal_ChangePlayer:new(...)
end

b_Reprisal_ChangePlayer = {
    Name = "Reprisal_ChangePlayer",
    Description = {
        en = "Reprisal: Changes the owner of the entity or a battalion.",
        de = "Vergeltung: Aendert den Besitzer einer Entity oder eines Battalions.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",     de = "Entity", },
        { ParameterType.Custom,     en = "Player",     de = "Spieler", },
    },
}

function b_Reprisal_ChangePlayer:GetReprisalTable(__quest_)
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_ChangePlayer:AddParameter( __index_, __parameter_ )
    if (__index_ == 0) then
        self.Entity = __parameter_;
    elseif (__index_ == 1) then
        self.Player = tostring(__parameter_);
    end
end

function b_Reprisal_ChangePlayer:CustomFunction(__quest_)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    if Logic.IsLeader(eID) == 1 then
        -- local SoldiersAmount = Logic.LeaderGetNumberOfSoldiers(eID);
        -- local SoldiersType = Logic.LeaderGetNumberOfSoldiers(eID);
        -- local Orientation = Logic.GetEntityOrientation(eID);
        -- local EntityName = Logic.GetEntityName(eID);
        -- local x,y,z = Logic.EntityGetPos(eID);
        -- local NewID = Logic.CreateBattalionOnUnblockedLand(SoldiersType, x, y, Orientation, self.Player, SoldiersAmount );
        -- Logic.SetEntityName(NewID, EntityName);
        -- DestroyEntity(eID);
        Logic.ChangeSettlerPlayerID(eID, self.Player);
    else
        Logic.ChangeEntityPlayerID(eID, self.Player);
    end
end

function b_Reprisal_ChangePlayer:GetCustomData(__index_)
    if __index_ == 1 then
        return {"0", "1", "2", "3", "4", "5", "6", "7", "8"}
    end
end

function b_Reprisal_ChangePlayer:DEBUG(__quest_)
    if not IsExisting(self.Entity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_ChangePlayer);

-- -------------------------------------------------------------------------- --

---
-- Ändert die Sichtbarkeit eines Entity.
-- 
-- @param _ScriptName Skriptname des Entity
-- @param _Visible    Sichtbarkeit an/aus
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_SetVisible(...)
    return b_Reprisal_SetVisible:new(...)
end

b_Reprisal_SetVisible = {
    Name = "Reprisal_SetVisible",
    Description = {
        en = "Reprisal: Changes the visibility of an entity. If the entity is a spawner the spawned entities will be affected.",
        de = "Strafe: Setzt die Sichtbarkeit einer Entity. Handelt es sich um einen Spawner werden auch die gespawnten Entities beeinflusst.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",     de = "Entity", },
        { ParameterType.Custom,     en = "Visible",     de = "Sichtbar", },
    },
}

function b_Reprisal_SetVisible:GetReprisalTable(__quest_)
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_SetVisible:AddParameter( __index_, __parameter_ )
    if (__index_ == 0) then
        self.Entity = __parameter_;
    elseif (__index_ == 1) then
        self.Visible = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Reprisal_SetVisible:CustomFunction(__quest_)
    if not IsExisting(self.Entity) then
        return;
    end

    local eID = GetID(self.Entity);
    local pID = Logic.EntityGetPlayer(eID);
    local eType = Logic.GetEntityType(eID);
    local tName = Logic.GetEntityTypeName(eType);

    if string.find(tName, "S_") or string.find(tName, "B_NPC_Bandits")
    or string.find(tName, "B_NPC_Barracks") then
        local spawned = {Logic.GetSpawnedEntities(eID)};
        for i=1, #spawned do
            if Logic.IsLeader(spawned[i]) == 1 then
                local soldiers = {Logic.GetSoldiersAttachedToLeader(spawned[i])};
                for j=2, #soldiers do
                    Logic.SetVisible(soldiers[j], self.Visible);
                end
            else
                Logic.SetVisible(spawned[i], self.Visible);
            end
        end
    else
        if Logic.IsLeader(eID) == 1 then
            local soldiers = {Logic.GetSoldiersAttachedToLeader(eID)};
            for j=2, #soldiers do
                Logic.SetVisible(soldiers[j], self.Visible);
            end
        else
            Logic.SetVisible(eID, self.Visible);
        end
    end
end

function b_Reprisal_SetVisible:GetCustomData(__index_)
    if __index_ == 1 then
        return { "true", "false" }
    end
end

function b_Reprisal_SetVisible:DEBUG(__quest_)
    if not IsExisting(self.Entity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_SetVisible);

-- -------------------------------------------------------------------------- --

---
-- Macht das Entity verwundbar oder unverwundbar.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Vulnerable Verwundbarkeit an/aus
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_SetVulnerability(...)
    return b_Reprisal_SetVulnerability:new(...);
end

b_Reprisal_SetVulnerability = {
    Name = "Reprisal_SetVulnerability",
    Description = {
        en = "Reprisal: Changes the vulnerability of the entity. If the entity is a spawner the spawned entities will be affected.",
        de = "Vergeltung: Macht eine Entity verwundbar oder unverwundbar. Handelt es sich um einen Spawner, sind die gespawnten Entities betroffen",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",              de = "Entity", },
        { ParameterType.Custom,     en = "Vulnerability",      de = "Verwundbar", },
    },
}

function b_Reprisal_SetVulnerability:GetReprisalTable(__quest_)
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_SetVulnerability:AddParameter( __index_, __parameter_ )
    if (__index_ == 0) then
        self.Entity = __parameter_;
    elseif (__index_ == 1) then
        self.Vulnerability = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Reprisal_SetVulnerability:CustomFunction(__quest_)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    local eType = Logic.GetEntityType(eID);
    local tName = Logic.GetEntityTypeName(eType);
    if self.Vulnerability then
        if string.find(tName, "S_") or string.find(tName, "B_NPC_Bandits")
        or string.find(tName, "B_NPC_Barracks") then
            local spawned = {Logic.GetSpawnedEntities(eID)};
            for i=1, #spawned do
                if Logic.IsLeader(spawned[i]) == 1 then
                    local Soldiers = {Logic.GetSoldiersAttachedToLeader(spawned[i])};
                    for j=2, #Soldiers do
                        MakeVulnerable(Soldiers[j]);
                    end
                end
                MakeVulnerable(spawned[i]);
            end
        else
            MakeVulnerable(self.Entity);
        end
    else
        if string.find(tName, "S_") or string.find(tName, "B_NPC_Bandits")
        or string.find(tName, "B_NPC_Barracks") then
            local spawned = {Logic.GetSpawnedEntities(eID)};
            for i=1, #spawned do
                if Logic.IsLeader(spawned[i]) == 1 then
                    local Soldiers = {Logic.GetSoldiersAttachedToLeader(spawned[i])};
                    for j=2, #Soldiers do
                        MakeInvulnerable(Soldiers[j]);
                    end
                end
                MakeInvulnerable(spawned[i]);
            end
        else
            MakeInvulnerable(self.Entity);
        end
    end
end

function b_Reprisal_SetVulnerability:GetCustomData(__index_)
    if __index_ == 1 then
        return { "true", "false" }
    end
end

function b_Reprisal_SetVulnerability:DEBUG(__quest_)
    if not IsExisting(self.Entity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_SetVulnerability);

-- -------------------------------------------------------------------------- --

---
-- Ändert das Model eines Entity.
--
-- In Verbindung mit Reward_SetVisible oder Reprisal_SetVisible können
-- Script Entites ein neues Model erhalten und sichtbar gemacht werden.
-- Das hat den Vorteil, das Script Entities nicht überbaut werden können.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Model      Neues Model
-- @return Table mit Behavior
-- @within Reprisal
--
function Reprisal_SetModel(...)
    return b_Reprisal_SetModel:new(...);
end

b_Reprisal_SetModel = {
    Name = "Reprisal_SetModel",
    Description = {
        en = "Reward: Changes the model of the entity. Be careful, some models crash the game.",
        de = "Lohn: Aendert das Model einer Entity. Achtung: Einige Modelle fuehren zum Absturz.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",     de = "Entity", },
        { ParameterType.Custom,     en = "Model",     de = "Model", },
    },
}

function b_Reprisal_SetModel:GetRewardTable(__quest_)
    return { Reward.Custom, { self, self.CustomFunction } }
end

function b_Reprisal_SetModel:AddParameter( __index_, __parameter_ )
    if (__index_ == 0) then
        self.Entity = __parameter_;
    elseif (__index_ == 1) then
        self.Model = __parameter_;
    end
end

function b_Reprisal_SetModel:CustomFunction(__quest_)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    Logic.SetModel(eID, Models[self.Model]);
end

function b_Reprisal_SetModel:GetCustomData(__index_)
    if __index_ == 1 then
        local Data = {};
        for k,v in pairs(Models) do
            if  not string.find(k,"Animals_") and not string.find(k,"Banners_") and not string.find(k,"Goods_") and not string.find(k,"goods_")
            and not string.find(k,"Heads_") and not string.find(k,"MissionMap_") and not string.find(k,"R_Fish") and not string.find(k,"Units_")
            and not string.find(k,"XD_") and not string.find(k,"XS_") and not string.find(k,"XT_") and not string.find(k,"Z_") then
                table.insert(Data,k);
            end
        end
        return Data;
    end
end

function b_Reprisal_SetModel:DEBUG(__quest_)
    if not IsExisting(self.Entity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reprisal_SetModel);

-- -------------------------------------------------------------------------- --
-- Rewards                                                                    --
-- -------------------------------------------------------------------------- --

---
-- Ändert die Position eines Siedlers oder eines Gebäudes.
--
-- Optional kann das Entity in einem bestimmten Abstand zum Ziel platziert
-- werden und das Ziel anschauen. Die Entfernung darf nicht kleiner sein
-- als 50!
--
-- @param _ScriptName Skriptname des Entity
-- @param _Target     Skriptname des Ziels
-- @param _LookAt     Gegenüberstellen
-- @param _Distance   Relative Entfernung (nur mit _LookAt)
-- @return Table mit Behavior
-- @within Reward
--
function Reward_SetPosition(...)
    return b_Reward_SetPosition:new(...);
end

b_Reward_SetPosition = API.InstanceTable(b_Reprisal_SetPosition);
b_Reward_SetPosition.Name = "Reward_SetPosition";
b_Reward_SetPosition.Description.en = "Reward: Places an entity relative to the position of another. The entity can look the target.";
b_Reward_SetPosition.Description.de = "Lohn: Setzt eine Entity relativ zur Position einer anderen. Die Entity kann zum Ziel ausgerichtet werden.";
b_Reward_SetPosition.GetReprisalTable = nil;

b_Reward_SetPosition.GetRewardTable = function(self, __quest_)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Core:RegisterBehavior(b_Reward_SetPosition);

-- -------------------------------------------------------------------------- --

---
-- Ändert den Eigentümer des Entity oder des Battalions.
-- 
-- @param _ScriptName Skriptname des Entity
-- @param _NewOwner   PlayerID des Eigentümers
-- @return Table mit Behavior
-- @within Reward
--
function Reprisal_ChangePlayer(...)
    return b_Reprisal_ChangePlayer:new(...)
end

b_Reward_ChangePlayer = API.InstanceTable(b_Reprisal_ChangePlayer);
b_Reward_ChangePlayer.Name = "Reward_ChangePlayer";
b_Reward_ChangePlayer.Description.en = "Reward: Changes the owner of the entity or a battalion.";
b_Reward_ChangePlayer.Description.de = "Lohn: Aendert den Besitzer einer Entity oder eines Battalions.";
b_Reward_ChangePlayer.GetReprisalTable = nil;

b_Reward_ChangePlayer.GetRewardTable = function(self, __quest_)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Core:RegisterBehavior(b_Reward_ChangePlayer);

-- -------------------------------------------------------------------------- --

---
-- Bewegt einen Siedler relativ zu einem Zielpunkt.
--
-- Der Siedler wird sich zum Ziel ausrichten und in der angegeben Distanz
-- und dem angegebenen Winkel Position beziehen.
--
-- <b>Hinweis:</b> Funktioniert ähnlich wie MoveEntityToPositionToAnotherOne.
--
-- @param _ScriptName  Skriptname des Entity
-- @param _Destination Skriptname des Ziels
-- @param _Distance    Entfernung
-- @param _Angle       Winkel
-- @return Table mit Behavior
-- @within Reward
--
function Reward_MoveToPosition(...)
    return b_Reward_MoveToPosition:new(...);
end

b_Reward_MoveToPosition = {
    Name = "Reward_MoveToPosition",
    Description = {
        en = "Reward: Moves an entity relative to another entity. If angle is zero the entities will be standing directly face to face.",
        de = "Lohn: Bewegt eine Entity relativ zur Position einer anderen. Wenn Winkel 0 ist, stehen sich die Entities direkt gegen�ber.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Settler", de = "Siedler" },
        { ParameterType.ScriptName, en = "Destination", de = "Ziel" },
        { ParameterType.Number,     en = "Distance", de = "Entfernung" },
        { ParameterType.Number,     en = "Angle", de = "Winkel" },
    },
}

function b_Reward_MoveToPosition:GetRewardTable(__quest_)
    return { Reward.Custom, {self, self.CustomFunction} }
end

function b_Reward_MoveToPosition:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.Entity = __parameter_;
    elseif (__index_ == 1) then
        self.Target = __parameter_;
    elseif (__index_ == 2) then
        self.Distance = __parameter_ * 1;
    elseif (__index_ == 3) then
        self.Angle = __parameter_ * 1;
    end
end

function b_Reward_MoveToPosition:CustomFunction(__quest_)
    if not IsExisting(self.Entity) or not IsExisting(self.Target) then
        return;
    end
    self.Angle = self.Angle or 0;

    local entity = GetID(self.Entity);
    local target = GetID(self.Target);
    local orientation = Logic.GetEntityOrientation(target);
    local x,y,z = Logic.EntityGetPos(target);
    if Logic.IsBuilding(target) == 1 then
        x, y = Logic.GetBuildingApproachPosition(target);
        orientation = orientation -90;
    end
    x = x + self.Distance * math.cos( math.rad(orientation+self.Angle) );
    y = y + self.Distance * math.sin( math.rad(orientation+self.Angle) );
    Logic.MoveSettler(entity, x, y);
    StartSimpleJobEx( function(_entityID, _targetID)
        if Logic.IsEntityMoving(_entityID) == false then
            LookAt(_entityID, _targetID);
            return true;
        end
    end, entity, target);
end

function b_Reward_MoveToPosition:DEBUG(__quest_)
    if tonumber(self.Distance) == nil or self.Distance < 50 then
        dbg(__quest_.Identifier.. " " ..self.Name.. ": Reward_MoveToPosition: Distance is nil or to short!");
        return true;
    elseif not IsExisting(self.Entity) or not IsExisting(self.Target) then
        dbg(__quest_.Identifier.. " " ..self.Name.. ": Reward_MoveToPosition: Mover entity or target entity does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reward_MoveToPosition);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler gewinnt das Spiel mit einem animierten Siegesfest.
--
-- Es ist nicht möglich weiterzuspielen!
--
-- @return Table mit Behavior
-- @within Reprisal
--
function Reward_VictoryWithParty()
    return b_Reward_VictoryWithParty:new();
end

b_Reward_VictoryWithParty = {
    Name = "Reward_VictoryWithParty",
    Description = {
        en = "Reward: The player wins the game with an animated festival on the market.",
        de = "Lohn: Der Spieler gewinnt das Spiel mit einer animierten Siegesfeier.",
    },
    Parameter =    {}
};

function b_Reward_VictoryWithParty:GetRewardTable()
    return {Reward.Custom, {self, self.CustomFunction}};
end

function b_Reward_VictoryWithParty:AddParameter(__index_, __parameter_)
end

function b_Reward_VictoryWithParty:CustomFunction(__quest_)
    Victory(g_VictoryAndDefeatType.VictoryMissionComplete);
    local pID = __quest_.ReceivingPlayer;

    local market = Logic.GetMarketplace(pID);
    if IsExisting(market) then
        local pos = GetPosition(market)
        Logic.CreateEffect(EGL_Effects.FXFireworks01,pos.X,pos.Y,0);
        Logic.CreateEffect(EGL_Effects.FXFireworks02,pos.X,pos.Y,0);

        local PossibleSettlerTypes = {
            Entities.U_SmokeHouseWorker,
            Entities.U_Butcher,
            Entities.U_Carpenter,
            Entities.U_Tanner,
            Entities.U_Blacksmith,
            Entities.U_CandleMaker,
            Entities.U_Baker,
            Entities.U_DairyWorker,

            Entities.U_SpouseS01,
            Entities.U_SpouseS02,
            Entities.U_SpouseS02,
            Entities.U_SpouseS03,
            Entities.U_SpouseF01,
            Entities.U_SpouseF01,
            Entities.U_SpouseF02,
            Entities.U_SpouseF03,
        };
        VictoryGenerateFestivalAtPlayer(pID, PossibleSettlerTypes);

        Logic.ExecuteInLuaLocalState([[
            if IsExisting(]]..market..[[) then
                CameraAnimation.AllowAbort = false
                CameraAnimation.QueueAnimation( CameraAnimation.SetCameraToEntity, ]]..market..[[)
                CameraAnimation.QueueAnimation( CameraAnimation.StartCameraRotation,  5 )
                CameraAnimation.QueueAnimation( CameraAnimation.Stay ,  9999 )
            end
            XGUIEng.ShowWidget("/InGame/InGame/MissionEndScreen/ContinuePlaying", 0);
        ]]);
    end
end

function b_Reward_VictoryWithParty:DEBUG(__quest_)
    return false;
end

Core:RegisterBehavior(b_Reward_VictoryWithParty)

-- -------------------------------------------------------------------------- --

---
-- Ändert die Sichtbarkeit eines Entity.
-- 
-- @param _ScriptName Skriptname des Entity
-- @param _Visible    Sichtbarkeit an/aus
-- @return Table mit Behavior
-- @within Reprisal
--
function Reward_SetVisible(...)
    return b_Reward_SetVisible:new(...)
end

b_Reward_SetVisible = API.InstanceTable(b_Reprisal_SetVisible);
b_Reward_SetVisible.Name = "Reward_ChangePlayer";
b_Reward_SetVisible.Description.en = "Reward: Changes the visibility of an entity. If the entity is a spawner the spawned entities will be affected.";
b_Reward_SetVisible.Description.de = "Lohn: Setzt die Sichtbarkeit einer Entity. Handelt es sich um einen Spawner werden auch die gespawnten Entities beeinflusst.";
b_Reward_SetVisible.GetReprisalTable = nil;

b_Reward_SetVisible.GetRewardTable = function(self, __quest_)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Core:RegisterBehavior(b_Reward_SetVisible);

-- -------------------------------------------------------------------------- --

---
-- Gibt oder entzieht einem KI-Spieler die Kontrolle über ein Entity.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Controlled Durch KI kontrollieren an/aus
-- @return Table mit Behavior
-- @within Reward
--
function Reward_AI_SetEntityControlled(...)
    return b_Reward_AI_SetEntityControlled:new(...);
end

b_Reward_AI_SetEntityControlled = {
    Name = "Reward_AI_SetEntityControlled",
    Description = {
        en = "Reward: Bind or Unbind an entity or a battalion to/from an AI player. The AI player must be activated!",
        de = "Lohn: Die KI kontrolliert die Entity oder der KI die Kontrolle entziehen. Die KI muss aktiv sein!",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",               de = "Entity", },
        { ParameterType.Custom,     en = "AI control entity", de = "KI kontrolliert Entity", },
    },
}

function b_Reward_AI_SetEntityControlled:GetRewardTable(__quest_)
    return { Reward.Custom, { self, self.CustomFunction } }
end

function b_Reward_AI_SetEntityControlled:AddParameter( __index_, __parameter_ )
    if (__index_ == 0) then
        self.Entity = __parameter_;
    elseif (__index_ == 1) then
        self.Hidden = AcceptAlternativeBoolean(__parameter_)
    end
end

function b_Reward_AI_SetEntityControlled:CustomFunction(__quest_)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    local pID = Logic.EntityGetPlayer(eID);
    local eType = Logic.GetEntityType(eID);
    local tName = Logic.GetEntityTypeName(eType);
    if string.find(tName, "S_") or string.find(tName, "B_NPC_Bandits")
    or string.find(tName, "B_NPC_Barracks") then
        local spawned = {Logic.GetSpawnedEntities(eID)};
        for i=1, #spawned do
            if Logic.IsLeader(spawned[i]) == 1 then
                AICore.HideEntityFromAI(pID, spawned[i], not self.Hidden);
            end
        end
    else
        AICore.HideEntityFromAI(pID, eID, not self.Hidden);
    end
end

function b_Reward_AI_SetEntityControlled:GetCustomData(__index_)
    if __index_ == 1 then
        return { "false", "true" }
    end
end

function b_Reward_AI_SetEntityControlled:DEBUG(__quest_)
    if not IsExisting(self.Entity) then
        dbg(__quest_.Identifier .. " " .. self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Reward_AI_SetEntityControlled);

-- -------------------------------------------------------------------------- --

---
-- Macht das Entity verwundbar oder unverwundbar.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Vulnerable Verwundbarkeit an/aus
-- @return Table mit Behavior
-- @within Reward
--
function Reward_SetVulnerability(...)
    return b_Reward_SetVulnerability:new(...);
end

b_Reward_SetVulnerability = API.InstanceTable(b_Reprisal_SetVulnerability);
b_Reward_SetVulnerability.Name = "Reward_SetVulnerability";
b_Reward_SetVulnerability.Description.en = "Reward: Changes the vulnerability of the entity. If the entity is a spawner the spawned entities will be affected.";
b_Reward_SetVulnerability.Description.de = "Lohn: Macht eine Entity verwundbar oder unverwundbar. Handelt es sich um einen Spawner, sind die gespawnten Entities betroffen.";
b_Reward_SetVulnerability.GetReprisalTable = nil;

b_Reward_SetVulnerability.GetRewardTable = function(self, __quest_)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Core:RegisterBehavior(b_Reward_SetVulnerability);

-- -------------------------------------------------------------------------- --

---
-- Ändert das Model eines Entity.
--
-- In Verbindung mit Reward_SetVisible oder Reprisal_SetVisible können
-- Script Entites ein neues Model erhalten und sichtbar gemacht werden.
-- Das hat den Vorteil, das Script Entities nicht überbaut werden können.
--
-- @param _ScriptName Skriptname des Entity
-- @param _Model      Neues Model
-- @return Table mit Behavior
-- @within Reward
--
function Reward_SetModel(...)
    return b_Reward_SetModel:new(...);
end

b_Reward_SetModel = API.InstanceTable(b_Reprisal_SetModel);
b_Reward_SetModel.Name = "Reward_SetModel";
b_Reward_SetModel.Description.en = "Reward: Changes the model of the entity. Be careful, some models crash the game.";
b_Reward_SetModel.Description.de = "Lohn: Aendert das Model einer Entity. Achtung: Einige Modelle fuehren zum Absturz.";
b_Reward_SetModel.GetReprisalTable = nil;

b_Reward_SetModel.GetRewardTable = function(self, __quest_)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Core:RegisterBehavior(b_Reward_SetModel);

-- -------------------------------------------------------------------------- --

---
-- Füllt die Munition in der Kriegsmaschine vollständig auf.
--
-- @param _ScriptName Skriptname des Entity
-- @return Table mit Behavior
-- @within Reward
--
function Reward_RefillAmmunition(...)
    return b_Reward_RefillAmmunition:new(...);
end

b_Reward_RefillAmmunition = {
    Name = "Reward_RefillAmmunition",
    Description = {
        en = "Reward: Refills completely the ammunition of the entity.",
        de = "Lohn: Fuellt die Munition der Entity vollständig auf.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname" },
    },
}

function b_Reward_RefillAmmunition:GetRewardTable()
    return { Reward.Custom, {self, self.CustomFunction} }
end

function b_Reward_RefillAmmunition:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Scriptname = _Parameter
    end
end

function b_Reward_RefillAmmunition:CustomFunction()
    local EntityID = GetID(self.Scriptname);
    if not IsExisting(EntityID) then
        return;
    end

    local Ammunition = Logic.GetAmmunitionAmount(EntityID);
    while (Ammunition < 10)
    do
        Logic.RefillAmmunitions(EntityID);
        Ammunition = Logic.GetAmmunitionAmount(EntityID);
    end
end

function b_Reward_RefillAmmunition:DEBUG(_Quest)
    if not IsExisting(self.Scriptname) then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": '"..self.Scriptname.."' is destroyed!");
        return true
    end
    return false;
end

Core:RegisterBehavior(b_Reward_RefillAmmunition)

-- -------------------------------------------------------------------------- --
-- Trigger                                                                    --
-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald mindestens X von Y Quests fehlgeschlagen sind.
--
-- @param _MinAmount Mindestens zu verlieren (max. 5)
-- @param _QuestAmount Anzahl geprüfter Quests (max. 5 und >= _MinAmount)
-- @param _Quest1      Name des 1. Quest
-- @param _Quest2      Name des 2. Quest
-- @param _Quest3      Name des 3. Quest
-- @param _Quest4      Name des 4. Quest
-- @param _Quest5      Name des 5. Quest
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnAtLeastXOfYQuestsFailed(...)
    return b_Trigger_OnAtLeastXOfYQuestsFailed:new(...);
end

b_Trigger_OnAtLeastXOfYQuestsFailed = {
    Name = "Trigger_OnAtLeastXOfYQuestsFailed",
    Description = {
        en = "Trigger: if at least X of Y given quests has been finished successfully.",
        de = "Ausloeser: wenn X von Y angegebener Quests fehlgeschlagen sind.",
    },
    Parameter = {
        { ParameterType.Custom, en = "Least Amount", de = "Mindest Anzahl" },
        { ParameterType.Custom, en = "Quest Amount", de = "Quest Anzahl" },
        { ParameterType.QuestName, en = "Quest name 1", de = "Questname 1" },
        { ParameterType.QuestName, en = "Quest name 2", de = "Questname 2" },
        { ParameterType.QuestName, en = "Quest name 3", de = "Questname 3" },
        { ParameterType.QuestName, en = "Quest name 4", de = "Questname 4" },
        { ParameterType.QuestName, en = "Quest name 5", de = "Questname 5" },
    },
}

function b_Trigger_OnAtLeastXOfYQuestsFailed:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_OnAtLeastXOfYQuestsFailed:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.LeastAmount = tonumber(_Parameter)
    elseif (_Index == 1) then
        self.QuestAmount = tonumber(_Parameter)
    elseif (_Index == 2) then
        self.QuestName1 = _Parameter
    elseif (_Index == 3) then
        self.QuestName2 = _Parameter
    elseif (_Index == 4) then
        self.QuestName3 = _Parameter
    elseif (_Index == 5) then
        self.QuestName4 = _Parameter
    elseif (_Index == 6) then
        self.QuestName5 = _Parameter
    end
end

function b_Trigger_OnAtLeastXOfYQuestsFailed:CustomFunction()
    local least = 0
    for i = 1, self.QuestAmount do
		local QuestID = GetQuestID(self["QuestName"..i]);
        if IsValidQuest(QuestID) then
			if (Quests[QuestID].Result == QuestResult.Failure) then
				least = least + 1
				if least >= self.LeastAmount then
					return true
				end
			end
        end
    end
    return false
end

function b_Trigger_OnAtLeastXOfYQuestsFailed:DEBUG(_Quest)
    local leastAmount = self.LeastAmount
    local questAmount = self.QuestAmount
    if leastAmount <= 0 or leastAmount >5 then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": LeastAmount is wrong")
        return true
    elseif questAmount <= 0 or questAmount > 5 then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": QuestAmount is wrong")
        return true
    elseif leastAmount > questAmount then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": LeastAmount is greater than QuestAmount")
        return true
    end
    for i = 1, questAmount do
        if not IsValidQuest(self["QuestName"..i]) then
            dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": Quest ".. self["QuestName"..i] .. " not found")
            return true
        end
    end
    return false
end

function b_Trigger_OnAtLeastXOfYQuestsFailed:GetCustomData(_Index)
    if (_Index == 0) or (_Index == 1) then
        return {"1", "2", "3", "4", "5"}
    end
end

Core:RegisterBehavior(b_Trigger_OnAtLeastXOfYQuestsFailed)

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald die Munition in der Kriegsmaschine erschöpft ist.
--
-- @param _ScriptName Skriptname des Entity
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_AmmunitionDepleted(...)
    return b_Trigger_AmmunitionDepleted:new(...);
end

b_Trigger_AmmunitionDepleted = {
    Name = "Trigger_AmmunitionDepleted",
    Description = {
        en = "Trigger: if the ammunition of the entity is depleted.",
        de = "Ausloeser: wenn die Munition der Entity aufgebraucht ist.",
    },
    Parameter = {
        { ParameterType.Scriptname, en = "Script name", de = "Skriptname" },
    },
}

function b_Trigger_AmmunitionDepleted:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_AmmunitionDepleted:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Scriptname = _Parameter
    end
end

function b_Trigger_AmmunitionDepleted:CustomFunction()
    if not IsExisting(self.Scriptname) then
        return false;
    end

    local EntityID = GetID(self.Scriptname);
    if Logic.GetAmmunitionAmount(EntityID) > 0 then
        return false;
    end

    return true;
end

function b_Trigger_AmmunitionDepleted:DEBUG(_Quest)
    if not IsExisting(self.Scriptname) then
        dbg(_Quest.Identifier .. ": Error in " .. self.Name .. ": '"..self.Scriptname.."' is destroyed!");
        return true
    end
    return false
end

Core:RegisterBehavior(b_Trigger_AmmunitionDepleted)

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, wenn exakt einer von beiden Quests erfolgreich ist.
--
-- @param _QuestName1 Name des ersten Quest
-- @param _QuestName2 Name des zweiten Quest
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnExactOneQuestIsWon(...)
    return b_Trigger_OnExactOneQuestIsWon:new(...);
end

b_Trigger_OnExactOneQuestIsWon = {
    Name = "Trigger_OnExactOneQuestIsWon",
    Description = {
        en = "Trigger: if one of two given quests has been finished successfully, but NOT both.",
        de = "Ausloeser: wenn eine von zwei angegebenen Quests (aber NICHT beide) erfolgreich abgeschlossen wurde.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest Name 1", de = "Questname 1" },
        { ParameterType.QuestName, en = "Quest Name 2", de = "Questname 2" },
    },
}

function b_Trigger_OnExactOneQuestIsWon:GetTriggerTable(__quest_)
    return {Triggers.Custom2, {self, self.CustomFunction}};
end

function b_Trigger_OnExactOneQuestIsWon:AddParameter(__index_, __parameter_)
    self.QuestTable = {};

    if (__index_ == 0) then
        self.Quest1 = __parameter_;
    elseif (__index_ == 1) then
        self.Quest2 = __parameter_;
    end
end

function b_Trigger_OnExactOneQuestIsWon:CustomFunction(__quest_)
    local Quest1 = Quests[GetQuestID(self.Quest1)];
    local Quest2 = Quests[GetQuestID(self.Quest2)];
    if Quest2 and Quest1 then
        local Quest1Succeed = (Quest1.State == QuestState.Over and Quest1.Result == QuestResult.Success);
        local Quest2Succeed = (Quest2.State == QuestState.Over and Quest2.Result == QuestResult.Success);
        if (Quest1Succeed and not Quest2Succeed) or (not Quest1Succeed and Quest2Succeed) then
            return true;
        end
    end
    return false;
end

function b_Trigger_OnExactOneQuestIsWon:DEBUG(__quest_)
    if self.Quest1 == self.Quest2 then
        dbg(__quest_.Identifier..": "..self.Name..": Both quests are identical!");
        return true;
    elseif not IsValidQuest(self.Quest1) then
        dbg(__quest_.Identifier..": "..self.Name..": Quest '"..self.Quest1.."' does not exist!");
        return true;
    elseif not IsValidQuest(self.Quest2) then
        dbg(__quest_.Identifier..": "..self.Name..": Quest '"..self.Quest2.."' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_OnExactOneQuestIsWon);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, wenn exakt einer von beiden Quests erfolgreich ist.
--
-- @param _QuestName1 Name des ersten Quest
-- @param _QuestName2 Name des zweiten Quest
-- @return Table mit Behavior
-- @within Trigger
--
function Trigger_OnExactOneQuestIsLost(...)
    return b_Trigger_OnExactOneQuestIsLost:new(...);
end

b_Trigger_OnExactOneQuestIsLost = {
    Name = "Trigger_OnExactOneQuestIsLost",
    Description = {
        en = "Trigger: If one of two given quests has been lost, but NOT both.",
        de = "Ausloeser: Wenn einer von zwei angegebenen Quests (aber NICHT beide) fehlschlägt.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest Name 1", de = "Questname 1" },
        { ParameterType.QuestName, en = "Quest Name 2", de = "Questname 2" },
    },
}

function b_Trigger_OnExactOneQuestIsLost:GetTriggerTable(__quest_)
    return {Triggers.Custom2, {self, self.CustomFunction}};
end

function b_Trigger_OnExactOneQuestIsLost:AddParameter(__index_, __parameter_)
    self.QuestTable = {};

    if (__index_ == 0) then
        self.Quest1 = __parameter_;
    elseif (__index_ == 1) then
        self.Quest2 = __parameter_;
    end
end

function b_Trigger_OnExactOneQuestIsLost:CustomFunction(__quest_)
    local Quest1 = Quests[GetQuestID(self.Quest1)];
    local Quest2 = Quests[GetQuestID(self.Quest2)];
    if Quest2 and Quest1 then
        local Quest1Succeed = (Quest1.State == QuestState.Over and Quest1.Result == QuestResult.Failure);
        local Quest2Succeed = (Quest2.State == QuestState.Over and Quest2.Result == QuestResult.Failure);
        if (Quest1Succeed and not Quest2Succeed) or (not Quest1Succeed and Quest2Succeed) then
            return true;
        end
    end
    return false;
end

function b_Trigger_OnExactOneQuestIsLost:DEBUG(__quest_)
    if self.Quest1 == self.Quest2 then
        dbg(__quest_.Identifier..": "..self.Name..": Both quests are identical!");
        return true;
    elseif not IsValidQuest(self.Quest1) then
        dbg(__quest_.Identifier..": "..self.Name..": Quest '"..self.Quest1.."' does not exist!");
        return true;
    elseif not IsValidQuest(self.Quest2) then
        dbg(__quest_.Identifier..": "..self.Name..": Quest '"..self.Quest2.."' does not exist!");
        return true;
    end
    return false;
end

Core:RegisterBehavior(b_Trigger_OnExactOneQuestIsWon);

-- -------------------------------------------------------------------------- --
-- Application Space                                                          --
-- -------------------------------------------------------------------------- --

BundleSymfoniaBehaviors = {
    Global = {},
    Local = {}
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Application Space
-- @local
--
function BundleSymfoniaBehaviors.Global:Install()
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Theif observation
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    GameCallback_OnThiefDeliverEarnings_Orig_QSB_SymfoniaBehaviors = GameCallback_OnThiefDeliverEarnings;
    GameCallback_OnThiefDeliverEarnings = function(_ThiefPlayerID, _ThiefID, _BuildingID, _GoodAmount)
        GameCallback_OnThiefDeliverEarnings_Orig_QSB_SymfoniaBehaviors(_ThiefPlayerID, _ThiefID, _BuildingID, _GoodAmount);

        for i=1, Quests[0] do
            if Quests[i] and Quests[i].State == QuestState.Active then
                for j=1, Quests[i].Objectives[0] do
                    if Quests[i].Objectives[j].Type == Objective.Custom2 then
                        if Quests[i].Objectives[j].Data[1].Name == "Goal_StealBuilding" then
                            local found;
                            for k=1, #Quests[i].Objectives[j].Data[1].RobberList do
                                local stohlen = Quests[i].Objectives[j].Data[1].RobberList[k];
                                if stohlen[1] == GetID(Quests[i].Objectives[j].Data[1].Building) and stohlen[2] == _ThiefID then
                                    found = true;
                                    break;
                                end
                            end
                            if found then
                                Quests[i].Objectives[j].Data[1].SuccessfullyStohlen = true;
                            end

                        elseif Quests[i].Objectives[j].Data[1].Name == "Goal_StealGold" then
                            Quests[i].Objectives[j].Data[1].StohlenGold = Quests[i].Objectives[j].Data[1].StohlenGold + _GoodAmount;
                            if Quests[i].Objectives[j].Data[1].Printout then
                                local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
                                local msg  = {de = "Talern gestohlen",en = "gold stolen",};
                                local curr = Quests[i].Objectives[j].Data[1].StohlenGold;
                                local need = Quests[i].Objectives[j].Data[1].Amount;
                                API.Note(string.format("%d/%d %s", curr, need, msg[lang]));
                            end
                        end
                    end
                end
            end
        end
    end

    GameCallback_OnThiefStealBuilding_Orig_QSB_SymfoniaBehaviors = GameCallback_OnThiefStealBuilding;
    GameCallback_OnThiefStealBuilding = function(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID)
        GameCallback_OnThiefStealBuilding_Orig_QSB_SymfoniaBehaviors(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID);

        for i=1, Quests[0] do
            if Quests[i] and Quests[i].State == QuestState.Active then
                for j=1, Quests[i].Objectives[0] do
                    if Quests[i].Objectives[j].Type == Objective.Custom2 then
                        if Quests[i].Objectives[j].Data[1].Name == "Goal_Infiltrate" then
                            if  GetID(Quests[i].Objectives[j].Data[1].Building) == _BuildingID and Quests[i].ReceivingPlayer == _ThiefPlayerID then
                                Quests[i].Objectives[j].Data[1].Infiltrated = true;
                                if Quests[i].Objectives[j].Data[1].Delete then
                                    DestroyEntity(_ThiefID);
                                end
                            end

                        elseif Quests[i].Objectives[j].Data[1].Name == "Goal_StealBuilding" then
                            local found;
                            local isCathedral = Logic.IsEntityInCategory(_BuildingID, EntityCategories.Cathedrals) == 1;
                            local isWarehouse = Logic.GetEntityType(_BuildingID) == Entities.B_StoreHouse;
                            if isWarehouse or isCathedral then
                                Quests[i].Objectives[j].Data[1].SuccessfullyStohlen = true;
                            else
                                for k=1, #Quests[i].Objectives[j].Data[1].RobberList do
                                    local stohlen = Quests[i].Objectives[j].Data[1].RobberList[k];
                                    if stohlen[1] == _BuildingID and stohlen[2] == _ThiefID then
                                        found = true;
                                        break;
                                    end
                                end
                            end
                            if not found then
                                table.insert(Quests[i].Objectives[j].Data[1].RobberList, {_BuildingID, _ThiefID});
                            end
                        end
                    end
                end
            end
        end
    end

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Objectives
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    QuestTemplate.IsObjectiveCompleted_Orig_QSB_SymfoniaBehaviors = QuestTemplate.IsObjectiveCompleted;
    QuestTemplate.IsObjectiveCompleted = function(self, objective)
        local objectiveType = objective.Type;
        local data = objective.Data;

        if objective.Completed ~= nil then
            return objective.Completed;
        end

        if objectiveType == Objective.Distance then

            -- Distance with parameter
            local IDdata2 = GetID(data[1]);
            local IDdata3 = GetID(data[2]);
            data[3] = data[3] or 2500;
            if not (Logic.IsEntityDestroyed(IDdata2) or Logic.IsEntityDestroyed(IDdata3)) then
                if Logic.GetDistanceBetweenEntities(IDdata2,IDdata3) <= data[3] then
                    DestroyQuestMarker(IDdata3);
                    objective.Completed = true;
                end
            else
                DestroyQuestMarker(IDdata3);
                objective.Completed = false;
            end
        else
            return self:IsObjectiveCompleted_Orig_QSB_SymfoniaBehaviors(objective);
        end
    end

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Questmarkers
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    function QuestTemplate:RemoveQuestMarkers()
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if self.Objectives[i].Data[4] then
                    DestroyQuestMarker(self.Objectives[i].Data[2]);
                end
            end
        end
    end

    function QuestTemplate:ShowQuestMarkers()
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if self.Objectives[i].Data[4] then
                    ShowQuestMarker(self.Objectives[i].Data[2]);
                end
            end
        end
    end

    function ShowQuestMarker(_Entity)
        local eID = GetID(_Entity);
        local x,y = Logic.GetEntityPosition(eID);
        local Marker = EGL_Effects.E_Questmarker_low;
        if Logic.IsBuilding(eID) == 1 then
            Marker = EGL_Effects.E_Questmarker;
        end
        Questmarkers[eID] = Logic.CreateEffect(Marker, x,y,0);
    end

    function DestroyQuestMarker(_Entity)
        local eID = GetID(_Entity);
        if Questmarkers[eID] ~= nil then
            Logic.DestroyEffect(Questmarkers[eID]);
            Questmarkers[eID] = nil;
        end
    end
end

-- Local Script ----------------------------------------------------------------

---
-- Initialisiert das Bundle im lokalen Skript.
-- @within Application Space
-- @local
--
function BundleSymfoniaBehaviors.Local:Install()

end

Core:RegisterBundle("BundleSymfoniaBehaviors");

-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleQuestGeneration                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Bundle können Aufträge per Skript erstellt werden.
--
-- @module BundleQuestGeneration
-- @set sort=true
--

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erstellt einen Quest, startet ihn jedoch noch nicht.
--
-- <b>Alias:</b> AddQuest
--
-- Ein Quest braucht immer wenigstens ein Goal und einen Trigger. Hat ein Quest
-- keinen Namen, erhält er automatisch einen mit fortlaufender Nummerierung.
--
-- Ein Quest besteht aus verschiedenen Parametern und Behavior, die nicht
-- alle zwingend gesetzt werden müssen. Behavior werden einfach nach den
-- Feldern nacheinander aufgerufen.
-- <p><u>Parameter:</u></p>
-- <ul>
-- <li>Name: Der eindeutige Name des Quests</li>
-- <li>Sender: PlayerID des Auftraggeber (Default 1)</li>
-- <li>Receiver: PlayerID des Auftragnehmer (Default 1)</li>
-- <li>Suggestion: Vorschlagnachricht des Quests</li>
-- <li>Success: Erfolgsnachricht des Quest</li>
-- <li>Failure: Fehlschlagnachricht des Quest</li>
-- <li>Description: Aufgabenbeschreibung (Nur bei Custom)</li>
-- <li>Time: Zeit bis zu, Fehlschlag</li>
-- <li>Loop: Funktion, die während der Laufzeit des Quests aufgerufen wird</li>
-- <li>Callback: Funktion, die nach Abschluss aufgerufen wird</li>
-- </ul>
--
-- @param _Data Questdefinition
-- @within User Space
--
function API.AddQuest(_Data)
    return BundleQuestGeneration.Global:NewQuest(_Data);
end
AddQuest = API.AddQuest;

---
-- Startet alle mittels API.AddQuest initalisierten Quests.
--
-- @within User Space
--
function API.StartQuests()
    return BundleQuestGeneration.Global:StartQuests();
end
StartQuests = API.StartQuests;

-- -------------------------------------------------------------------------- --
-- Application Space                                                          --
-- -------------------------------------------------------------------------- --

BundleQuestGeneration = {
    Global = {
        Data = {
            GenerationList = {},
        }
    },
    Local = {
        Data = {}
    },
}

BundleQuestGeneration.Global.Data.QuestTemplate = {
    MSGKeyOverwrite = nil;
    IconOverwrite   = nil;
    Loop            = nil;
    Callback        = nil;
    SuggestionText  = nil;
    SuccessText     = nil;
    FailureText     = nil;
    Description     = nil;
    Identifier      = nil;
    OpenMessage     = true,
    CloseMessage    = true,
    Sender          = 1;
    Receiver        = 1;
    Time            = 0;
    Goals           = {};
    Reprisals       = {};
    Rewards         = {};
    Triggers        = {};
};

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Application Space
-- @local
--
function BundleQuestGeneration.Global:Install()

end

---
-- Erzeugt einen Quest und trägt ihn in die GenerationList ein.
--
-- @param _Data Daten des Quest.
-- @within Application Space
-- @local
--
function BundleQuestGeneration.Global:NewQuest(_Data)
    if not _Data.Name then
        QSB.AutomaticQuestNameCounter = (QSB.AutomaticQuestNameCounter or 0) +1;
        _Data.Name = string.format("AutoNamed_Quest_%d", QSB.AutomaticQuestNameCounter);
    end

    if not Core:CheckQuestName(_Data.Name) then
        dbg("Quest '"..tostring(_Data.Name).."': invalid questname! Contains forbidden characters!");
        return;
    end

    local QuestData = API.InstanceTable(self.Data.QuestTemplate);
    QuestData.Identifier      = _Data.Name;
    QuestData.MSGKeyOverwrite = nil;
    QuestData.IconOverwrite   = nil;
    QuestData.Loop            = _Data.Loop;
    QuestData.Callback        = _Data.Callback;
    QuestData.SuggestionText  = (type(_Data.Suggestion) == "table" and _Data.Suggestion[lang]) or _Data.Suggestion;
    QuestData.SuccessText     = (type(_Data.Success) == "table" and _Data.Success[lang]) or _Data.Success;
    QuestData.FailureText     = (type(_Data.Failure) == "table" and _Data.Failure[lang]) or _Data.Failure;
    QuestData.Description     = (type(_Data.Description) == "table" and _Data.Description[lang]) or _Data.Description;
    QuestData.OpenMessage     = _Data.Visible == true or _Data.Suggestion ~= nil;
    QuestData.CloseMessage    = _Data.EndMessage == true or (_Data.Failure ~= nil or _Data.Success ~= nil);
    QuestData.Sender          = (_Data.Sender ~= nil and _Data.Sender) or 1;
    QuestData.Receiver        = (_Data.Receiver ~= nil and _Data.Receiver) or 1;
    QuestData.Time            = (_Data.Time ~= nil and _Data.Time) or 0;

    if _Data.Arguments then
        QuestData.Arguments = API.InstanceTable(_Data.Arguments);
    end

    table.insert(self.Data.GenerationList, QuestData);
    local ID = #self.Data.GenerationList;
    self:AttachBehavior(ID, _Data);
    return ID;
end

---
-- Fügt dem Quest mit der ID in der GenerationList seine Behavior hinzu.
--
-- <b>Achtung: </b>Diese Funktion wird vom Code aufgerufen!
--
-- @param _ID   Id des Quests
-- @param _Data Quest Data
-- @within Application Space
-- @local
--
function BundleQuestGeneration.Global:AttachBehavior(_ID, _Data)
    local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    for k,v in pairs(_Data) do
        if k ~= "Parameter" and type(v) == "table" and v.en and v.de then
            _Data[k] = v[lang];
        end
    end

    for k,v in pairs(_Data) do
        if tonumber(k) ~= nil then
            if type(v) ~= "table" then
                dbg(self.Data.GenerationList[_ID].Identifier..": Some behavior entries aren't behavior!");
            else
                if v.GetGoalTable then
                    table.insert(self.Data.GenerationList[_ID].Goals, v:GetGoalTable());

                    local Idx = #self.Data.GenerationList[_ID].Goals;
                    self.Data.GenerationList[_ID].Goals[Idx].Context            = v;
                    self.Data.GenerationList[_ID].Goals[Idx].FuncOverrideIcon   = self.Data.GenerationList[_ID].Goals[Idx].Context.GetIcon;
                    self.Data.GenerationList[_ID].Goals[Idx].FuncOverrideMsgKey = self.Data.GenerationList[_ID].Goals[Idx].Context.GetMsgKey;
                elseif v.GetReprisalTable then
                    table.insert(self.Data.GenerationList[_ID].Reprisals, v:GetReprisalTable());
                elseif v.GetRewardTable then
                    table.insert(self.Data.GenerationList[_ID].Rewards, v:GetRewardTable());
                elseif v.GetTriggerTable then
                    table.insert(self.Data.GenerationList[_ID].Triggers, v:GetTriggerTable());
                else
                    dbg(self.Data.GenerationList[_ID].Identifier..": Could not obtain behavior table!");
                end
            end
        end
    end
end

---
-- Startet alle Quests in der GenerationList.
--
-- @within Application Space
-- @local
--
function BundleQuestGeneration.Global:StartQuests()
    if not self:ValidateQuests() then
        return;
    end

    while (#self.Data.GenerationList > 0)
    do
        local QuestData = table.remove(self.Data.GenerationList, 1);
        if self:DebugQuest(QuestData) then
            API.DumpTable(QuestData, "Quest_" ..QuestData.Identifier)
            local QuestID, Quest = QuestTemplate:New(
                QuestData.Identifier,
                QuestData.Sender,
                QuestData.Receiver,
                QuestData.Goals,
                QuestData.Triggers,
                assert(tonumber(QuestData.Time)),
                QuestData.Rewards,
                QuestData.Reprisals,
                QuestData.Callback,
                QuestData.Loop,
                QuestData.OpenMessage,
                QuestData.CloseMessage,
                QuestData.Description,
                QuestData.SuggestionText,
                QuestData.SuccessText,
                QuestData.FailureText
            );

            if QuestData.MSGKeyOverwrite then
                Quest.MsgTableOverride = self.MSGKeyOverwrite;
            end
            if QuestData.IconOverwrite then
                Quest.IconOverride = self.IconOverwrite;
            end
            if QuestData.Arguments then
                Quest.Arguments = API.InstanceTable(QuestData.Arguments);
            end
        end
    end
end

---
-- Validiert alle Quests in der GenerationList. Verschiedene Standardfehler
-- werden geprüft.
--
-- @within Application Space
-- @local
--
function BundleQuestGeneration.Global:ValidateQuests()
    for k, v in pairs(self.Data.GenerationList) do
        if #v.Goals == 0 then
            table.insert(self.Data.GenerationList[k].Goals, Goal_InstantSuccess());
        end
        if #v.Triggers == 0 then
            table.insert(self.Data.GenerationList[k].Triggers, Trigger_Time(0));
        end

        if #v.Goals == 0 and #v.Triggers == 0 then
            local text = string.format("Quest '" ..v.Identifier.. "' is missing a goal or a trigger!");
            return false;
        end

        local debugText = ""
        -- check if quest table is invalid
        if not v then
            debugText = debugText .. "quest table is invalid!"
        else
            -- check loop callback
            if v.Loop ~= nil and type(v.Loop) ~= "function" then
                debugText = debugText .. self.Identifier..": Loop must be a function!"
            end
            -- check callback
            if v.Callback ~= nil and type(v.Callback) ~= "function" then
                debugText = debugText .. self.Identifier..": Callback must be a function!"
            end
            -- check sender
            if (v.Sender == nil or (v.Sender < 1 or v.Sender > 8))then
                debugText = debugText .. v.Identifier..": Sender is nil or greater than 8 or lower than 1!"
            end
            -- check receiver
            if (v.Receiver == nil or (v.Receiver < 0 or v.Receiver > 8))then
                debugText = debugText .. self.Identifier..": Receiver is nil or greater than 8 or lower than 0!"
            end
            -- check time
            if (v.Time == nil or type(v.Time) ~= "number" or v.Time < 0)then
                debugText = debugText .. v.Identifier..": Time is nil or not a number or lower than 0!"
            end
            -- check visible
            if type(v.OpenMessage) ~= "boolean" then
                debugText = debugText .. v.Identifier..": Visible need to be a boolean!"
            end
            -- check end message
            if type(v.CloseMessage) ~= "boolean" then
                debugText = debugText .. v.Identifier..": EndMessage need to be a boolean!"
            end
            -- check description
            if (v.Description ~= nil and type(v.Description) ~= "string") then
                debugText = debugText .. v.Identifier..": Description is not a string!"
            end
            -- check proposal
            if (v.SuggestionText ~= nil and type(v.SuggestionText) ~= "string") then
                debugText = debugText .. v.Identifier..": Suggestion is not a string!"
            end
            -- check success
            if (v.SuccessText ~= nil and type(v.SuccessText) ~= "string") then
                debugText = debugText .. v.Identifier..": Success is not a string!"
            end
            -- check failure
            if (v.FailureText ~= nil and type(v.FailureText) ~= "string") then
                debugText = debugText .. v.Identifier..": Failure is not a string!"
            end
        end

        if debugText ~= "" then
            dbg(debugText);
            return false;
        end
    end
    return true;
end


---
-- Dummy-Funktion zur Validierung der Behavior eines Quests
--
-- Diese Funktion muss durch ein Debug Bundle überschrieben werden um Quests
-- in der Initalisiererliste zu testen.
--
-- @param _List Liste der Quests
-- @within Application Space
-- @local
--
function BundleQuestGeneration.Global:DebugQuest(_List)
    return true;
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Application Space
-- @local
--
function BundleQuestGeneration.Local:Install()

end

Core:RegisterBundle("BundleQuestGeneration");

-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleQuestDebug                                             # --
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
        BundleQuestGeneration.Global.DebugQuest = BundleQuestDebug.Global.DebugQuest;
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
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:ActivateDebug(_CheckAtStart, _CheckAtRun, _TraceQuests, _DevelopingMode)
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

---
-- Überschreibt CreateQuests, sodass Assistentenquests über das Skript erzeugt 
-- werden um diese sinnvoll überprüfen zu können.
--
-- @within BundleQuestDebug.Global
-- @local
--
function BundleQuestDebug.Global:OverwriteCreateQuests()
    self.Data.CreateQuestOriginal = CreateQuests;
    CreateQuests = function()
        if not BundleQuestDebug.Global.Data.CheckAtStart then
            BundleQuestDebug.Global.Data.CreateQuestsOriginal();
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
function BundleQuestDebug.Global.OnSaveGameLoad(_Arguments, _Original)
    BundleQuestDebug.Global:ActivateDevelopingMode();
    BundleQuestDebug.Global:ActivateQuestTrace();
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
function BundleQuestDebug.Global.DebugQuest(self, _Quest)
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

