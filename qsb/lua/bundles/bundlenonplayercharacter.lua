-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleNonPlayerCharacter                                     # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Bundle wird ein spezieller Modus für Nichtspieler-Charaktere
-- bereitgestellt. Die Helden eines Spielers können mit diesen NPCs sprechen.
-- Dazu muss der Held selektiert sein. Dann kann der Spieler ihm mit einem
-- Rechtsklick befehlen, den NPC anzusprechen. Dabei wird der Mauszeiger zu
-- einer Hand.
--
-- Ein NPC wird durch ein leichtes Glitzern auf der Spielwelt hervorgehoben.
--
-- <a href="#API.NpcCompose">NPCs erzeugen und verwalten</a>
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleNonPlayerCharacter = {};

API = API or {};
QSB = QSB or {};

QSB.NonPlayerCharacterObjects = {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erstellt einen neuen NPC für den angegebenen Siedler.
--
-- Der NPC wird sofort aktiviert und kann angesprochen werden. Er wird durch
-- eine glitzernde Aura hervorgehoben.
--
-- Mögliche Einstellungen für den NPC:
-- <table border="1">
-- <tr>
-- <th><b>Eigenschaft</b></th>
-- <th><b>Beschreibung</b></th>
-- </tr>
-- <tr>
-- <td>Name</td>
-- <td>Stringname des Siedlers, der zum NPC werden soll.</td>
-- </tr>
-- <tr>
-- <td>Hero</td>
-- <td>Skriptname eines Helden, mit dem der NPC sprechen will.</td>
-- </tr>
-- <tr>
-- <td>WrongHeroMessage</td>
-- <td>Eine optionale Nachricht, wenn der falsche Held angesprochen wird.</td>
-- </tr>
-- <tr>
-- <td>Callback</td>
-- <td>Eine Funktion, die aufgerufen wird, wenn der NPC angesprochen wird.</td>
-- </tr>
-- </table>
--
-- <p><b>Alias:</b> CreateNPC</p>
--
-- @param[type=table] _Data Nichtspieler-Charakter
-- @return[type=table] NonPlayerCharacter Objekt
-- @within Anwenderfunktionen
--
-- @usage
-- API.NpcCompose {
--     Name     = "horst",
--     Callback = function(_Npc, _Hero)
--        -- Hier kann was passieren
--     end,
-- }
--
function API.NpcCompose(_Data)
    local WronHeroCallback = function(_Npc)
        if _Npc.WrongHeroMessage then
            API.Note(_Npc.WrongHeroMessage);
        end
    end

    local NPC = QSB.NonPlayerCharacter:New(_Data.Name);
    NPC:SetDialogPartner(_Data.Hero);
    NPC:SetWrongPartnerCallback(WronHeroCallback);
    NPC:SetCallback(_Data.Callback);
    return NPC:Activate();
end
CreateNPC = API.NpcCompose;

---
-- Entfernt den NPC komplett vom Entity. Das Entity bleibt dabei erhalten.
--
-- <p><b>Alias:</b> DestroyNPC</p>
--
-- @param _Entity Nichtspieler-Charakter (Skriptname oder ID)
-- @within Anwenderfunktionen
--
-- @usage
-- API.NpcDispose("horst")
--
function API.NpcDispose(_Entity)
    local ScriptName = Logic.GetEntityName(GetID(_Entity));
    local NPC = QSB.NonPlayerCharacter:GetInstance(ScriptName);
    if not NPC then
        return;
    end
    NPC:Dispose();
end
DestroyNPC = API.NpcDispose;

---
-- Aktiviert einen inaktiven NPC. Wenn ein NPC bereits gesprochen hat, muss
-- er zuvor zurückgesetzt werden.
--
-- <p><b>Alias:</b> EnableNPC</P>
--
-- @param _Entity Nichtspieler-Charakter (Skriptname oder ID)
-- @within Anwenderfunktionen
--
-- @usage
-- API.NpcActivate("horst")
--
function API.NpcActivate(_Entity)
    local ScriptName = Logic.GetEntityName(GetID(_Entity));
    local NPC = QSB.NonPlayerCharacter:GetInstance(ScriptName);
    if not NPC then
        return;
    end
    NPC:Activate();
end
EnableNPC = API.NpcActivate;

---
-- Deaktiviert einen NPC, sodass dieser nicht angesprochen werden kann.
--
-- <p><b>Alias:</b> DisableNPC</P>
--
-- @param _Entity Nichtspieler-Charakter (Skriptname oder ID)
-- @within Anwenderfunktionen
--
-- @usage
-- API.NpcDeactivate("horst")
--
function API.NpcDeactivate(_Entity)
    local ScriptName = Logic.GetEntityName(GetID(_Entity));
    local NPC = QSB.NonPlayerCharacter:GetInstance(ScriptName);
    if not NPC then
        return;
    end
    NPC:Deactivate();
end
DisableNPC = API.NpcDeactivate;

---
-- Setzt einen NPC zurück, sodass er nicht mehr als angesprochen gilt.
--
-- <p><b>Alias:</b> ResetNPC<p>
--
-- @param _Entity Nichtspieler-Charakter (Skriptname oder ID)
-- @within Anwenderfunktionen
--
-- @usage
-- API.NpcReset("horst")
--
function API.NpcReset(_Entity)
    local ScriptName = Logic.GetEntityName(GetID(_Entity));
    local NPC = QSB.NonPlayerCharacter:GetInstance(ScriptName);
    if not NPC then
        return;
    end
    NPC:Reset();
end
ResetNPC = API.NpcReset;

---
-- Prüft, ob der NPC bereits angesprochen wurde. Wenn ein Ansprechpartner
-- vorgegeben ist, muss dieser den NPC ansprechen.
--
-- <p><b>Alias:</b> TalkedToNPC</p>
--
-- @param _Entity Nichtspieler-Charakter (Skriptname oder ID)
-- @return[type=boolean] NPC wurde angesprochen
-- @within Anwenderfunktionen
--
-- @usage
-- API.NpcHasSpoken("horst")
--
function API.NpcHasSpoken(_Entity)
    local ScriptName = Logic.GetEntityName(GetID(_Entity));
    local NPC = QSB.NonPlayerCharacter:GetInstance(ScriptName);
    if not NPC then
        return;
    end
    return NPC:HasTalkedTo();
end
TalkedToNPC = API.NpcHasSpoken;

-- -------------------------------------------------------------------------- --
-- Klassen                                                                    --
-- -------------------------------------------------------------------------- --

QSB.NonPlayerCharacter = {};

---
-- Konstruktor
-- @param[type=string] _ScriptName Skriptname des NPC
-- @within QSB.NonPlayerCharacter
-- @usage
-- -- Einen normalen NPC erzeugen:
-- QSB.NonPlayerCharacter:New("npc")
--     :SetDialogPartner("hero")                 -- Optional
--     :SetCallback(Briefing1)                   -- Optional
--     :Activate();
--
function QSB.NonPlayerCharacter:New(_ScriptName)
    assert(self == QSB.NonPlayerCharacter, 'Can not be used from instance!');
    local npc = API.InstanceTable(self);
    npc.m_NpcName  = _ScriptName;
    npc.m_NpcType  = BundleNonPlayerCharacter.Global.DefaultNpcType
    npc.m_Distance = 350;
    if Logic.IsKnight(GetID(_ScriptName)) then
        npc.m_Distance = 400;
    end
    QSB.NonPlayerCharacterObjects[_ScriptName] = npc;
    npc:CreateMarker();
    return npc;
end

---
-- Gibt das Objekt des NPC zurück, wenn denn eins für dieses Entity existiert.
--
-- Wurde noch kein NPC für diesen Skriptnamen erzeugt, wird nil zurückgegeben.
--
-- @param[type=string] _ScriptName Skriptname des NPC
-- @return[type=table] Interaktives Objekt
-- @within QSB.NonPlayerCharacter
-- @usage -- NPC ermitteln
-- local NPC = QSB.NonPlayerCharacter:GetInstance("horst");
-- -- Etwas mit dem NPC tun
-- NPC:SetDialogPartner("hilda");
--
function QSB.NonPlayerCharacter:GetInstance(_ScriptName)
    assert(self == QSB.NonPlayerCharacter, 'Can not be used from instance!');
    local EntityID = GetID(_ScriptName)
    local ScriptName = Logic.GetEntityName(EntityID);
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Soldier) == 1 then
        local LeaderID = Logic.SoldierGetLeaderEntityID(EntityID);
        if IsExisting(LeaderID) then
            ScriptName = Logic.GetEntityName(LeaderID);
        end
    end
    return QSB.NonPlayerCharacterObjects[ScriptName];
end

---
-- Gibt die Entity ID des letzten angesprochenen NPC zurück.
--
-- @return[type=number] ID des letzten NPC
-- @within QSB.NonPlayerCharacter
--
function QSB.NonPlayerCharacter:GetNpcId()
    assert(self == QSB.NonPlayerCharacter, 'Can not be used from instance!');
    return BundleNonPlayerCharacter.Global.LastNpcEntityID;
end

---
-- Gibt die Entity ID des letzten Helden zurück, der einen NPC
-- angesprochen hat.
--
-- @return[type=number] ID des letzten Heden
-- @within QSB.NonPlayerCharacter
--
function QSB.NonPlayerCharacter:GetHeroId()
    assert(self == QSB.NonPlayerCharacter, 'Can not be used from instance!');
    return BundleNonPlayerCharacter.Global.LastHeroEntityID;
end

---
-- Gibt die Entity ID des NPC zurück. Ist der NPC ein Leader, wird
-- der erste Soldat zurückgegeben, wenn es einen gibt.
--
-- @return[type=number] ID des NPC
-- @within QSB.NonPlayerCharacter
--
function QSB.NonPlayerCharacter:GetID()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    local EntityID = GetID(self.m_NpcName);
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Leader) == 1 then
        local Soldiers = {Logic.GetSoldiersAttachedToLeader(EntityID)};
        if Soldiers[1] > 0 then
            return Soldiers[2];
        end
    end
    return EntityID
end

---
-- Löscht einen NPC.
--
-- @within QSB.NonPlayerCharacter
--
-- @usage -- NPC löschen
-- NPC:Dispose();
--
function QSB.NonPlayerCharacter:Dispose()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    self:Deactivate();
    self:DestroyMarker();
    QSB.NonPlayerCharacterObjects[self.m_NpcName] = nil;
end

---
-- Aktiviert einen inaktiven NPC, sodass er wieder angesprochen werden kann.
--
-- @param[type=number] _Type NPC-Typ [1-4]
-- @return[type=table] self
-- @within QSB.NonPlayerCharacter
-- @usage -- NPC aktivieren:
-- NPC:Activate();
--
function QSB.NonPlayerCharacter:Activate(_Type)
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.m_NpcName) then
        Logic.SetOnScreenInformation(self:GetID(), _Type or self.m_NpcType);
        self:ShowMarker();
    end
    return self;
end

---
-- Deaktiviert einen aktiven NPC, sodass er nicht angesprochen werden kann.
--
-- @return[type=table] self
-- @within QSB.NonPlayerCharacter
-- @usage -- NPC deaktivieren:
-- NPC:Deactivate();
--
function QSB.NonPlayerCharacter:Deactivate()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.m_NpcName) then
        Logic.SetOnScreenInformation(self:GetID(), 0);
        self:HideMarker();
    end
    return self;
end

---
-- <p>Gibt true zurück, wenn der NPC aktiv ist.</p>
--
-- @return[type=boolean] NPC ist aktiv
-- @within QSB.NonPlayerCharacter
--
function QSB.NonPlayerCharacter:IsActive()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    return Logic.GetEntityScriptingValue(self:GetID(), 6) > 0;
end

---
-- Setzt den NPC zurück, sodass er erneut aktiviert werden kann.
--
-- @return[type=table] self
-- @within QSB.NonPlayerCharacter
--
function QSB.NonPlayerCharacter:Reset()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.m_NpcName) then
        Logic.SetOnScreenInformation(self:GetID(), 0);
        self.m_TalkedTo = nil;
        self:HideMarker();
    end
    return self;
end

---
-- Gibt true zurück, wenn der NPC angesprochen wurde. Ist ein
-- spezieller Ansprechpartner definiert, wird nur dann true
-- zurückgegeben, wenn dieser Held mit dem NPC spricht.
--
-- @return[type=boolean] NPC wurde angesprochen
-- @within QSB.NonPlayerCharacter
--
function QSB.NonPlayerCharacter:HasTalkedTo()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if self.m_HeroName then
        return self.m_TalkedTo == GetID(self.m_HeroName);
    end
    return self.m_TalkedTo ~= nil;
end

---
-- Gibt die Entity ID des letzten angesprochenen NPC zurück.
--
-- @param[type=number] _Type Typ des Npc
-- @return[type=number] ID des letzten NPC
-- @within QSB.NonPlayerCharacter
--
function QSB.NonPlayerCharacter:SetType(_Type)
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    self.m_NpcType = _Type;
    if _Type > 1 then
        self:HideMarker();
    end
    return self;
end

---
-- Setzt die Entfernung, die unterschritten werden muss, damit
-- ein NPC als angesprochen gilt.
--
-- @param[type=number] _Distance Aktivierungsdistanz
-- @within QSB.NonPlayerCharacter
--
function QSB.NonPlayerCharacter:SetTalkDistance(_Distance)
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    self.m_Distance = _Distance or 350;
    return self;
end

---
-- Setzt den Ansprechpartner für diesen NPC.
--
-- @param[type=string] _HeroName Skriptname des Helden
-- @return[type=table] self
-- @within QSB.NonPlayerCharacter
--
function QSB.NonPlayerCharacter:SetDialogPartner(_HeroName)
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    self.m_HeroName = _HeroName;
    return self;
end

---
-- Setzt das Callback für den Fall, dass ein falscher Held den
-- NPC anspricht.
--
-- @param[type=function] _Callback Callback
-- @return[type=table] self
-- @within QSB.NonPlayerCharacter
--
function QSB.NonPlayerCharacter:SetWrongPartnerCallback(_Callback)
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    self.m_WrongHeroCallback = _Callback;
    return self;
end

---
-- Setzt das Callback des NPC, dass beim Ansprechen ausgeführt wird.
--
-- @param[type=function] _Callback Callback
-- @return[type=table] self
-- @within QSB.NonPlayerCharacter
--
function QSB.NonPlayerCharacter:SetCallback(_Callback)
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    assert(type(_Callback) == "function", 'callback must be a function!');
    self.m_Callback = _Callback;
    return self;
end

---
-- Rotiert alle nahen Helden zum NPC und den NPC zu dem Helden,
-- der ihn angesprochen hat.
--
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:RotateActors()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    local PlayerID = Logic.EntityGetPlayer(BundleNonPlayerCharacter.Global.LastHeroEntityID);
    local PlayerKnights = {};
    Logic.GetKnights(PlayerID, PlayerKnights);
    for k, v in pairs(PlayerKnights) do
        local x, y, z = Logic.EntityGetPos(v);
        Logic.MoveEntity(v, x, y);
    end
    LookAt(self.m_NpcName, BundleNonPlayerCharacter.Global.LastHeroEntityID);
    LookAt(BundleNonPlayerCharacter.Global.LastHeroEntityID, self.m_NpcName);
end

---
-- Erzeugt das Entity des NPC-Markers.
--
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:CreateMarker()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    local x,y,z = Logic.EntityGetPos(self:GetID());
    local MarkerID = Logic.CreateEntity(Entities.XD_ScriptEntity, x, y, 0, 0);
    DestroyEntity(self.m_MarkerID);
    self.m_MarkerID = MarkerID;
    self:HideMarker();
    return self;
end

---
-- Entfernt das Entity des NPC-Markers.
--
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:DestroyMarker()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if self.m_MarkerID then
        DestroyEntity(self.m_MarkerID);
        self.m_MarkerID = nil;
    end
    return self;
end

---
-- Zeigt den NPC-Marker des NPC an.
--
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:ShowMarker()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if self.m_NpcType == 1 and IsExisting(self.m_MarkerID) then
        local EntityScale = Logic.GetEntityScriptingValue(self:GetID(), -45);
        Logic.SetEntityScriptingValue(self.m_MarkerID, -45, EntityScale);
        Logic.SetModel(self.m_MarkerID, Models.Effects_E_Wealth);
        Logic.SetVisible(self.m_MarkerID, true);
    end
    self.m_MarkerVisibility = true;
    return self;
end

---
-- Versteckt den NPC-Marker des NPC.
--
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:HideMarker()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.m_MarkerID) then
        Logic.SetModel(self.m_MarkerID, Models.Effects_E_NullFX);
        Logic.SetVisible(self.m_MarkerID, false);
    end
    self.m_MarkerVisibility = false;
    return self;
end

---
-- Gibt true zurück, wenn der Marker des NPC sichtbar ist.
--
-- @return[type=boolen] Sichtbarkeit
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:IsMarkerVisible()
    assert(self ~= QSB.NonPlayerCharacter, 'Can not be used in static context!');
    return IsExisting(self.m_MarkerID) and self.m_MarkerVisibility == true;
end

---
-- Kontrolliert die Sichtbarkeit und die Position des NPC-Markers.
--
-- @within QSB.NonPlayerCharacter
-- @local
--
function QSB.NonPlayerCharacter:ControlMarker()
    -- Nur, wenn Standard-NPC
    if self.m_NpcType == 1 then
        if self:IsActive() and not self:HasTalkedTo() then
            -- Blinken
            if self:IsMarkerVisible() then
                self:HideMarker();
            else
                self:ShowMarker();
            end

            -- Repositionierung
            local x1,y1,z1 = Logic.EntityGetPos(self.m_MarkerID);
            local x2,y2,z2 = Logic.EntityGetPos(self:GetID());
            if math.abs(x1-x2) > 20 or math.abs(y1-y2) > 20 then
                Logic.DEBUG_SetPosition(self.m_MarkerID, x2, y2);
            end
        end
        -- Während Briefings immer verstecken
        if IsBriefingActive and IsBriefingActive() then
            self:HideMarker();
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleNonPlayerCharacter = {
    Global = {
        LastNpcEntityID = 0,
        LastHeroEntityID = 0,
        DefaultNpcType = 1,
    },
    Local = {}
};

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function BundleNonPlayerCharacter.Global:Install()
    -- NPC stuff --

    StartSimpleJob("BundleNonPlayerCharacter_ControlMarkerJob");
    StartSimpleHiResJob("BundleNonPlayerCharacter_DialogTriggerJob");

    GameCallback_OnNPCInteraction_Orig_QSB_NPC_Rewrite = GameCallback_OnNPCInteraction
    GameCallback_OnNPCInteraction = function(_EntityID, _PlayerID)
        GameCallback_OnNPCInteraction_Orig_QSB_NPC_Rewrite(_EntityID, _PlayerID)
        Quest_OnNPCInteraction(_EntityID, _PlayerID)
    end

    Quest_OnNPCInteraction = function(_EntityID, _PlayerID)
        local KnightIDs = {};
        Logic.GetKnights(_PlayerID, KnightIDs);

        local ClosestKnightID = 0;
        local ClosestKnightDistance = Logic.WorldGetSize();
        for i= 1, #KnightIDs, 1 do
            local DistanceBetween = Logic.GetDistanceBetweenEntities(KnightIDs[i], _EntityID);
            if DistanceBetween < ClosestKnightDistance then
                ClosestKnightDistance = DistanceBetween;
                ClosestKnightID = KnightIDs[i];
            end
        end
        BundleNonPlayerCharacter.Global.LastHeroEntityID = ClosestKnightID;
        local NPC = QSB.NonPlayerCharacter:GetInstance(_EntityID);
        BundleNonPlayerCharacter.Global.LastNpcEntityID = NPC:GetID();

        if NPC then
            NPC:RotateActors();
            NPC.m_TalkedTo = ClosestKnightID;
            if NPC:HasTalkedTo() then
                NPC:Deactivate();
                if NPC.m_Callback then
                    NPC.m_Callback(NPC, ClosestKnightID);
                end
            else
                if NPC.m_WrongHeroCallback then
                    NPC.m_WrongHeroCallback(NPC, ClosestKnightID);
                end
            end
        end
    end

    -- Quest stuff --

    function QuestTemplate:RemoveQuestMarkers()
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if ((type(self.Objectives[i].Data[1]) == "number" and self.Objectives[i].Data[1] > 0)
                or (type(self.Objectives[i].Data[1]) ~= "number")) and self.Objectives[i].Data[4] then
                    DestroyQuestMarker(self.Objectives[i].Data[2]);
                end
            end
        end
    end

    function QuestTemplate:ShowQuestMarkers()
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if ((type(self.Objectives[i].Data[1]) == "number" and self.Objectives[i].Data[1] > 0)
                or (type(self.Objectives[i].Data[1]) ~= "number")) and self.Objectives[i].Data[4] then
                    ShowQuestMarker(self.Objectives[i].Data[2]);
                end
            end
        end
    end

    function QuestTemplate:RemoveNPCMarkers()
        for i=1, self.Objectives[0] do
            if type(self.Objectives[i].Data) == "table" then
                if self.Objectives[i].Data[1] == -65565 then
                    if type(self.Objectives[i].Data[4]) == "table" then
                        if self.Objectives[i].Data[4].NpcInstance then
                            self.Objectives[i].Data[4].NpcInstance:Dispose();
                            self.Objectives[i].Data[4].NpcInstance = nil;
                        end
                    end
                end
            end
        end
    end

    QuestTemplate.Interrupt_Orig_BundleNonPlayerCharacter = QuestTemplate.Interrupt;
    QuestTemplate.Interrupt = function(_quest, i)
        QuestTemplate.Interrupt_Orig_BundleNonPlayerCharacter(_quest, i);
        _quest:RemoveNPCMarkers();
    end

    QuestTemplate.IsObjectiveCompleted_Orig_BundleNonPlayerCharacter = QuestTemplate.IsObjectiveCompleted;
    QuestTemplate.IsObjectiveCompleted = function(self, objective)
        local objectiveType = objective.Type;
        local data = objective.Data;
        if objective.Completed ~= nil then
            return objective.Completed;
        end

        if objectiveType ~= Objective.Distance then
            return self:IsObjectiveCompleted_Orig_BundleNonPlayerCharacter(objective);
        else
            if data[1] == -65565 then
                if not IsExisting(data[3]) then
                    API.Fatal(data[3].. " is dead! :(");
                    objective.Completed = false;
                else
                    if not data[4].NpcInstance then
                        local NPC = QSB.NonPlayerCharacter(data[3]);
                        NPC:SetDialogPartner(data[2]);
                        data[4].NpcInstance = NPC;
                    end
                    if data[4].NpcInstance:HasTalkedTo(data[2]) then
                        objective.Completed = true;
                    end
                    if not objective.Completed then
                        if not data[4].NpcInstance:IsActive() then
                            data[4].NpcInstance:Activate();
                        end
                    end
                end
            else
                return self:IsObjectiveCompleted_Orig_BundleNonPlayerCharacter(objective);
            end
        end
    end
end

---
-- Setzt den Standardtypen des NPC. Der Typ gibt an, ob Glitter verwendet wird
-- oder auf die NPC-Marker zurückgegriffen wird.
--
-- @param[type=number] _Type Typ des NPC [1-4]
-- @within Internal
-- @local
--
function BundleNonPlayerCharacter.Global:SetDefaultNPCType(_Type)
    self.DefaultNpcType = _Type;
end

---
-- Gibt die ID des kontrollierenden Spielers zurück.
-- 
-- @return[type=number] Kontrollierender Spieler
-- @within Internal
-- @local
--
function BundleNonPlayerCharacter.Global:GetControllingPlayer()
    for i= 1, 8, 1 do
        if Logic.PlayerGetIsHumanFlag(i) == true then
            return i;
        end
    end
    return 0;
end

---
-- Konvertiert eine Ganzzahl in eine Gleitkommazahl.
-- @param[type=number] num Zahl zum Konvertieren
-- @return[type=number] Ganzzahl
-- @within Internal
-- @local
--
function BundleNonPlayerCharacter.Global:IntegerToFloat(num)
    if(num == 0) then 
        return 0;
    end
    local sign = 1
    if(num < 0) then 
        num = 2147483648 + num; sign = -1;
    end
    local frac = (num - math.floor(num/8388608)*8388608);
    local headPart = (num-frac)/8388608
    local expNoSign = (headPart - math.floor(headPart/256)*256);
    local exp = expNoSign-127
    local fraction = 1
    local fp = 0.5
    local check = 4194304
    for i = 23, 0, -1 do
        if(frac - check) > 0 then
            fraction = fraction + fp; frac = frac - check;
        end
        check = check / 2; fp = fp / 2
    end
    return fraction * math.pow(2, exp) * sign
end

---
-- Kontrolliert die "Glitter Marker" der NPCs.
--
-- @within Internal
-- @local
--
function BundleNonPlayerCharacter.Global.ControlMarker()
    for k, v in pairs(QSB.NonPlayerCharacterObjects) do
        v:ControlMarker();
    end
end
BundleNonPlayerCharacter_ControlMarkerJob = BundleNonPlayerCharacter.Global.ControlMarker;

---
-- Prüft, ob ein NPC durch die emulierte Aktivierungsdistanz angesprochen
-- wird. Die Bedingung wird für alle NPCs geprüft. Der erste NPC, der
-- die Bedingung erfüllt, wird aktiviert.
--
-- Der Job prüft nur NPCs, deren Aktivierungsdistanz 350 oder höher ist.
--
-- @within Internal
-- @local
--
function BundleNonPlayerCharacter.Global.DialogTriggerController()
    local PlayerID = BundleNonPlayerCharacter.Global:GetControllingPlayer();
    local PlayersKnights = {};
    Logic.GetKnights(PlayerID, PlayersKnights);
    for i= 1, #PlayersKnights, 1 do
        if Logic.GetCurrentTaskList(PlayersKnights[i]) == "TL_NPC_INTERACTION" then
            for k, v in pairs(QSB.NonPlayerCharacterObjects) do
                if v and v.m_TalkedTo == nil and v.m_Distance >= 350 then
                    local x1 = math.floor(BundleNonPlayerCharacter.Global:IntegerToFloat(Logic.GetEntityScriptingValue(PlayersKnights[i], 19)));
                    local y1 = math.floor(BundleNonPlayerCharacter.Global:IntegerToFloat(Logic.GetEntityScriptingValue(PlayersKnights[i], 20)));
                    local x2, y2 = Logic.EntityGetPos(GetID(k));
                    if x1 == math.floor(x2) and y1 == math.floor(y2) then
                        if IsExisting(k) and IsNear(PlayersKnights[i], k, v.m_Distance) then
                            GameCallback_OnNPCInteraction(GetID(k), PlayerID);
                            return;
                        end
                    end
                end
            end
        end
    end
end
BundleNonPlayerCharacter_DialogTriggerJob = BundleNonPlayerCharacter.Global.DialogTriggerController;

-- Local Script ----------------------------------------------------------------

---
-- Initialisiert das Bundle im lokalen Skript.
-- @within Internal
-- @local
--
function BundleNonPlayerCharacter.Local:Install()
    g_CurrentDisplayedQuestID = 0;

    GUI_Interaction.DisplayQuestObjective_Orig_BundleNonPlayerCharacter = GUI_Interaction.DisplayQuestObjective
    GUI_Interaction.DisplayQuestObjective = function(_QuestIndex, _MessageKey)
        local lang = Network.GetDesiredLanguage();
        if lang ~= "de" then lang = "en" end

        local QuestIndexTemp = tonumber(_QuestIndex);
        if QuestIndexTemp then
            _QuestIndex = QuestIndexTemp;
        end

        local Quest, QuestType = GUI_Interaction.GetPotentialSubQuestAndType(_QuestIndex);
        local QuestObjectivesPath = "/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives";
        XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives", 0);
        local QuestObjectiveContainer;
        local QuestTypeCaption;

        local ParentQuest = Quests[_QuestIndex];
        local ParentQuestIdentifier;
        if ParentQuest ~= nil
        and type(ParentQuest) == "table" then
            ParentQuestIdentifier = ParentQuest.Identifier;
        end
        local HookTable = {};

        g_CurrentDisplayedQuestID = _QuestIndex;

        if QuestType == Objective.Distance then
            QuestObjectiveContainer = QuestObjectivesPath .. "/List";
            QuestTypeCaption = Wrapped_GetStringTableText(_QuestIndex, "UI_Texts/QuestInteraction");
            local ObjectList = {};

            if Quest.Objectives[1].Data[1] == -65565 then
                QuestObjectiveContainer = QuestObjectivesPath .. "/Distance";
                QuestTypeCaption = Wrapped_GetStringTableText(_QuestIndex, "UI_Texts/QuestMoveHere");
                SetIcon(QuestObjectiveContainer .. "/QuestTypeIcon",{7,10});

                local MoverEntityID = GetEntityId(Quest.Objectives[1].Data[2]);
                local MoverEntityType = Logic.GetEntityType(MoverEntityID);
                local MoverIcon = g_TexturePositions.Entities[MoverEntityType];
                if Quest.Objectives[1].Data[1] == -65567 or not MoverIcon then
                    MoverIcon = {16,12};
                end
                SetIcon(QuestObjectiveContainer .. "/IconMover", MoverIcon);

                local TargetEntityID = GetEntityId(Quest.Objectives[1].Data[3]);
                local TargetEntityType = Logic.GetEntityType(TargetEntityID);
                local TargetIcon = g_TexturePositions.Entities[TargetEntityType];
                if not TargetIcon then
                    TargetIcon = {14,10};
                end

                local IconWidget = QuestObjectiveContainer .. "/IconTarget";
                local ColorWidget = QuestObjectiveContainer .. "/TargetPlayerColor";

                SetIcon(IconWidget, TargetIcon);
                XGUIEng.SetMaterialColor(ColorWidget, 0, 255, 255, 255, 0);

                SetIcon(QuestObjectiveContainer .. "/QuestTypeIcon",{16,12});
                local caption = {de = "Gespräch beginnen", en = "Start conversation"};
                QuestTypeCaption = caption[lang];

                XGUIEng.SetText(QuestObjectiveContainer.."/Caption","{center}"..QuestTypeCaption);
                XGUIEng.ShowWidget(QuestObjectiveContainer, 1);
            else
                GUI_Interaction.DisplayQuestObjective_Orig_BundleNonPlayerCharacter(_QuestIndex, _MessageKey);
            end
        else
            GUI_Interaction.DisplayQuestObjective_Orig_BundleNonPlayerCharacter(_QuestIndex, _MessageKey);
        end
    end

    GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_BundleNonPlayerCharacter = GUI_Interaction.GetEntitiesOrTerritoryListForQuest
    GUI_Interaction.GetEntitiesOrTerritoryListForQuest = function( _Quest, _QuestType )
        local EntityOrTerritoryList = {}
        local IsEntity = true

        if _QuestType == Objective.Distance then
            if _Quest.Objectives[1].Data[1] == -65565 then
                local Entity = GetEntityId(_Quest.Objectives[1].Data[3]);
                table.insert(EntityOrTerritoryList, Entity);
            else
                return GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_BundleNonPlayerCharacter( _Quest, _QuestType );
            end

        else
            return GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_BundleNonPlayerCharacter( _Quest, _QuestType );
        end
        return EntityOrTerritoryList, IsEntity
    end
end

Core:RegisterBundle("BundleNonPlayerCharacter");

-- -------------------------------------------------------------------------- --
-- Behavior                                                                   --
-- -------------------------------------------------------------------------- --

---
-- Der Held muss einen Nichtspielercharakter ansprechen.
--
-- Es wird automatisch ein NPC erzeugt und überwacht, sobald der Quest
-- aktiviert wurde.
--
-- @param[type=string] _NpcName  Skriptname des NPC
-- @param[type=string] _HeroName (optional) Skriptname des Helden
-- @within Goal
--
function Goal_NPC(...)
    return b_Goal_NPC:new(...);
end

b_Goal_NPC = {
    Name             = "Goal_NPC",
    Description     = {
        en = "Goal: The hero has to talk to a non-player character.",
        de = "Ziel: Der Held muss einen Nichtspielercharakter ansprechen.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "NPC",  de = "NPC" },
        { ParameterType.ScriptName, en = "Hero", de = "Held" },
    },
}

function b_Goal_NPC:GetGoalTable(__quest_)
    return {Objective.Distance, -65565, self.Hero, self.NPC, self }
end

function b_Goal_NPC:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.NPC = __parameter_
    elseif (__index_ == 1) then
        self.Hero = __parameter_
        if self.Hero == "-" then
            self.Hero = nil
        end
   end
end

function b_Goal_NPC:GetIcon()
    return {14,10}
end

Core:RegisterBehavior(b_Goal_NPC);

