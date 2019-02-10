-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleNonPlayerCharacter                                     # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- <p>Mit diesem Bundle wird ein spezieller Modus für Nichtspieler-Charaktere
-- bereitgestellt. Die Helden eines Spielers können mit diesen NPCs sprechen.
-- Dazu muss der Held selektiert sein. Dann kann der Spieler ihm mit einem
-- Rechtsklick befehlen, den NPC anzusprechen. Dabei wird der Mauszeiger zu
-- einer Hand.</p>
--
-- <p>Ein NPC wird durch ein leichtes Glitzern auf der Spielwelt hervorgehoben.
-- </p>
--
-- <p><a href="#API.NpcCompose">NPCs erzeugen und verwalten</a></p>
--
-- @within Modulbeschreibung
-- @set sort=false
--
BundleNonPlayerCharacter = {};

API = API or {};
QSB = QSB or {};

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

    local NPC = NonPlayerCharacter:New(_Data.Name);
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
    local NPC = NonPlayerCharacter:GetInstance(ScriptName);
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
    local NPC = NonPlayerCharacter:GetInstance(ScriptName);
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
    local NPC = NonPlayerCharacter:GetInstance(ScriptName);
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
    local NPC = NonPlayerCharacter:GetInstance(ScriptName);
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
    local NPC = NonPlayerCharacter:GetInstance(ScriptName);
    if not NPC then
        return;
    end
    return NPC:HasTalkedTo();
end
TalkedToNPC = API.NpcHasSpoken;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleNonPlayerCharacter = {
    Global = {
        NonPlayerCharacter = {
            Data = {},
        },
        NonPlayerCharacterObjects = {},
        LastNpcEntityID = 0,
        LastHeroEntityID = 0,
    },
    Local = {}
};

---
-- Erzeugt ein neues Objekt von NonPlayerCharacter und bindet es an den
-- angegebenen Siedler. Dadurch wird der Siedler zu einem NPC, ist allerdings
-- noch nicht aktiv.
--
-- <p><b>Alias:</b> NonPlayerCharacter:New</p>
--
-- @param[type=string] _ScriptName Skriptname des NPC
-- @return[type=table] Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
-- @local
--
-- @usage
-- Einen normalen NPC erzeugen:
-- local NPC = NonPlayerCharacter:New("npc")
--     :SetDialogPartner("hero")                -- Optional
--     :SetCallback(Briefing1)                  -- Optional
--     :Activate();
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:New(_ScriptName)
    assert( self == BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used from instance!');
    assert(IsExisting(_ScriptName), 'entity "' .._ScriptName.. '" does not exist!');

    local npc = CopyTableRecursive(self);
    npc.Data.NpcName = _ScriptName;
    npc.Data.Distance = 350;
    if Logic.IsKnight(GetID(_ScriptName)) then
        npc.Data.Distance = 400;
    end
    BundleNonPlayerCharacter.Global.NonPlayerCharacterObjects[_ScriptName] = npc;
    npc:CreateMarker();
    npc:HideMarker();
    return npc;
end

---
-- Gibt das Objekt des NPC zurück, wenn denn eins für dieses Entity existiert.
--
-- Wurde noch kein NPC für diesen Skriptnamen erzeugt, wird nil zurückgegeben.
--
-- <p><b>Alias:</b> NonPlayerCharacter:GetInstance</p>
--
-- @param[type=string] _ScriptName Skriptname des NPC
-- @return[type=table] Interaktives Objekt
-- @within NonPlayerCharacter
-- @local
-- @usage -- NPC ermitteln
-- local NPC = NonPlayerCharacter:GetInstance("horst");
-- -- Etwas mit dem NPC tun
-- NPC:SetDialogPartner("hilda");
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:GetInstance(_ScriptName)
    assert( self == BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used from instance!');
    local EntityID = GetID(_ScriptName)
    local ScriptName = Logic.GetEntityName(EntityID);
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Soldier) == 1 then
        local LeaderID = Logic.SoldierGetLeaderEntityID(EntityID);
        if IsExisting(LeaderID) then
            ScriptName = Logic.GetEntityName(LeaderID);
        end
    end
    return BundleNonPlayerCharacter.Global.NonPlayerCharacterObjects[ScriptName];
end

---
-- Gibt die Entity ID des letzten angesprochenen NPC zurück.
--
-- <p><b>Alias:</b> NonPlayerCharacter:GetNpcId</p>
--
-- @return[type=number] ID des letzten NPC
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:GetNpcId()
    assert( self == BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used from instance!');
    return BundleNonPlayerCharacter.Global.LastNpcEntityID;
end

---
-- Gibt die Entity ID des letzten Helden zurück, der einen NPC
-- angesprochen hat.
--
-- <p><b>Alias:</b> NonPlayerCharacter:GetHeroId</p>
--
-- @return[type=number] ID des letzten Heden
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:GetHeroId()
    assert( self == BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used from instance!');
    return BundleNonPlayerCharacter.Global.LastHeroEntityID;
end

---
-- Gibt die Entity ID des NPC zurück. Ist der NPC ein Leader, wird
-- der erste Soldat zurückgegeben, wenn es einen gibt.
--
-- <p><b>Alias:</b> NonPlayerCharacter:GetID</p>
--
-- @return[type=number] ID des NPC
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:GetID()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    local EntityID = GetID(self.Data.NpcName);
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
-- <p><b>Alias:</b> NonPlayerCharacter:Dispose</p>
--
-- @within NonPlayerCharacter
-- @local
--
-- @usage -- NPC löschen
-- NPC:Dispose();
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:Dispose()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    self:Deactivate();
    self:DestroyMarker();
    BundleNonPlayerCharacter.Global.NonPlayerCharacterObjects[self.Data.NpcName] = nil;
end

---
-- Aktiviert einen inaktiven NPC, sodass er wieder angesprochen werden kann.
--
-- <p><b>Alias:</b> NonPlayerCharacter:Activate</p>
--
-- @return[type=table] Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
-- @local
-- @usage -- NPC aktivieren:
-- NPC:Activate();
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:Activate()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.Data.NpcName) then
        Logic.SetOnScreenInformation(self:GetID(), 1);
        self:ShowMarker();
    end
    return self;
end

---
-- Deaktiviert einen aktiven NPC, sodass er nicht angesprochen werden kann.
--
-- <p><b>Alias:</b> NonPlayerCharacter:Deactivate</p>
--
-- @return[type=table] Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
-- @local
-- @usage -- NPC deaktivieren:
-- NPC:Deactivate();
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:Deactivate()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.Data.NpcName) then
        Logic.SetOnScreenInformation(self:GetID(), 0);
        self:HideMarker();
    end
    return self;
end

---
-- <p>Gibt true zurück, wenn der NPC aktiv ist.</p>
--
-- <p><b>Alias:</b> NonPlayerCharacter:IsActive</p>
--
-- @return[type=boolean] NPC ist aktiv
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:IsActive()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    return Logic.GetEntityScriptingValue(self:GetID(), 6) == 1;
end

---
-- Setzt den NPC zurück, sodass er erneut aktiviert werden kann.
--
-- <p><b>Alias:</b> NonPlayerCharacter:Reset</p>
--
-- @return[type=table] Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:Reset()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.Data.NpcName) then
        Logic.SetOnScreenInformation(self:GetID(), 0);
        self.Data.TalkedTo = nil;
        self:HideMarker();
    end
    return self;
end

---
-- Gibt true zurück, wenn der NPC angesprochen wurde. Ist ein
-- spezieller Ansprechpartner definiert, wird nur dann true
-- zurückgegeben, wenn dieser Held mit dem NPC spricht.
--
-- <p><b>Alias:</b> NonPlayerCharacter:HasTalkedTo</p>
--
-- @return[type=boolean] NPC wurde angesprochen
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:HasTalkedTo()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    if self.Data.HeroName then
        return self.Data.TalkedTo == GetID(self.Data.HeroName);
    end
    return self.Data.TalkedTo ~= nil;
end

---
-- Setzt die Entfernung, die unterschritten werden muss, damit
-- ein NPC als angesprochen gilt.
--
-- @param[type=number] _Distance Aktivierungsdistanz
-- @within QSB.NonPlayerCharacter
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetTalkDistance(_Distance)
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    self.Data.Distance = Distance or 350;
    return self;
end

---
-- Setzt den Ansprechpartner für diesen NPC.
--
-- <p><b>Alias:</b> NonPlayerCharacter:SetDialogPartner</p>
--
-- @param[type=string] _HeroName Skriptname des Helden
-- @return[type=table] Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetDialogPartner(_HeroName)
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    self.Data.HeroName = _HeroName;
    return self;
end

---
-- Setzt das Callback für den Fall, dass ein falscher Held den
-- NPC anspricht.
--
-- <p><b>Alias:</b> NonPlayerCharacter:SetWrongPartnerCallback</p>
--
-- @param[type=function] _Callback Callback
-- @return[type=table] Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetWrongPartnerCallback(_Callback)
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    self.Data.WrongHeroCallback = _Callback;
    return self;
end

---
-- Setzt das Callback des NPC, dass beim Ansprechen ausgeführt wird.
--
-- <p><b>Alias:</b> NonPlayerCharacter:SetCallback</p>
--
-- @param[type=function] _Callback Callback
-- @return[type=table] Instanz von NonPlayerCharacter
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetCallback(_Callback)
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    assert(type(_Callback) == "function", 'callback must be a function!');
    self.Data.Callback = _Callback;
    return self;
end

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

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald der NPC angesprochen wurde.
--
-- Es wird automatisch ein NPC erzeugt und überwacht, sobald der Quest
-- erzeugt wurde.
--
-- @param[type=string] _NpcName  Skriptname des NPC
-- @param[type=string] _HeroName (optional) Skriptname des Helden
-- @within Trigger
--
function Trigger_NPC(...)
    return b_Trigger_NPC:new(...);
end

b_Trigger_NPC = {
    Name = "Trigger_NPC",
    Description = {
        en = "Trigger: Starts the quest after the npc was spoken to.",
        de = "Ausloeser: Startet den Quest, sobald der NPC angesprochen wurde.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "NPC",  de = "NPC" },
        { ParameterType.ScriptName, en = "Hero", de = "Held" },
    },
}

function b_Trigger_NPC:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function b_Trigger_NPC:AddParameter(__index_, __parameter_)
    if (__index_ == 0) then
        self.NPC = __parameter_
    elseif (__index_ == 1) then
        self.Hero = __parameter_
        if self.Hero == "-" then
            self.Hero = nil
        end
    end
end

function b_Trigger_NPC:CustomFunction()
    if not IsExisting(self.NPC) then
        return;
    end
    if not self.NpcInstance then
        local NPC = NonPlayerCharacter:New(self.NPC);
        NPC:SetDialogPartner(self.Hero);
        self.NpcInstance = NPC;
    end
    local TalkedTo = self.NpcInstance:HasTalkedTo(self.Hero);
    if not TalkedTo then
        if not self.NpcInstance:IsActive() then
            self.NpcInstance:Activate();
        end
    end
    return TalkedTo;
end

function b_Trigger_NPC:Reset(__quest_)
    if self.NpcInstance then
        self.NpcInstance:Dispose();
    end
end

function b_Trigger_NPC:DEBUG(__quest_)
    return false;
end

Core:RegisterBehavior(b_Trigger_NPC);

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

-- Global Script ---------------------------------------------------------------

---
-- Initialisiert das Bundle im globalen Skript.
-- @within Internal
-- @local
--
function BundleNonPlayerCharacter.Global:Install()
    NonPlayerCharacter = BundleNonPlayerCharacter.Global.NonPlayerCharacter;

    StartSimpleJob("BundleNonPlayerCharacter_ControlMarkerJob");
    StartSimpleHiResJob("BundleNonPlayerCharacter_DialogTriggerJob");

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GameCallback_OnNPCInteraction_Orig_QSB_NPC_Rewrite = GameCallback_OnNPCInteraction
    GameCallback_OnNPCInteraction = function(_EntityID, _PlayerID)
        GameCallback_OnNPCInteraction_Orig_QSB_NPC_Rewrite(_EntityID, _PlayerID)
        Quest_OnNPCInteraction(_EntityID, _PlayerID)
    end

    Quest_OnNPCInteraction = function(_EntityID, _PlayerID)
        local KnightIDs = {};
        Logic.GetKnights(_PlayerID, KnightIDs);
        -- Akteure ermitteln
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
        local NPC = NonPlayerCharacter:GetInstance(_EntityID);
        BundleNonPlayerCharacter.Global.LastNpcEntityID = NPC:GetID();

        if NPC then
            NPC:RotateActors();
            NPC.Data.TalkedTo = ClosestKnightID;
            if NPC:HasTalkedTo() then
                NPC:Deactivate();
                if NPC.Data.Callback then
                    NPC.Data.Callback(NPC, ClosestKnightID);
                end
            else
                if NPC.Data.WrongHeroCallback then
                    NPC.Data.WrongHeroCallback(NPC, ClosestKnightID);
                end
            end
        end
    end

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
                        local NPC = NonPlayerCharacter:New(data[3]);
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
-- Rotiert alle nahen Helden zum NPC und den NPC zu dem Helden,
-- der ihn angesprochen hat.
--
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:RotateActors()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');

    local PlayerID = Logic.EntityGetPlayer(BundleNonPlayerCharacter.Global.LastHeroEntityID);
    local KnightIDs = {};
    Logic.GetKnights(PlayerID, KnightIDs);
    for i= 1, #KnightIDs, 1 do
        if Logic.GetDistanceBetweenEntities(KnightIDs[i], BundleNonPlayerCharacter.Global.LastNpcEntityID) < 3000 then
            local x,y,z = Logic.EntityGetPos(KnightIDs[i]);
            if Logic.IsEntityMoving(KnightIDs[i]) then
                Logic.MoveEntity(KnightIDs[i], x, y);
            end
            LookAt(KnightIDs[i], self.Data.NpcName);
        end
    end

    local NpcOffset = 0;
    if Logic.IsKnight(GetID(self.Data.NpcName)) then
        NpcOffset = 15;
    end
    LookAt(self.Data.NpcName, BundleNonPlayerCharacter.Global.LastHeroEntityID, NpcOffset);
    LookAt(BundleNonPlayerCharacter.Global.LastHeroEntityID, self.Data.NpcName, 15);
end

---
-- Erzeugt das Entity des NPC-Markers.
--
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:CreateMarker()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    local x,y,z = Logic.EntityGetPos(self:GetID());
    local MarkerID = Logic.CreateEntity(Entities.XD_ScriptEntity, x, y, 0, 0);
    DestroyEntity(self.Data.MarkerID);
    self.Data.MarkerID = MarkerID;
    self:HideMarker();
    return self;
end

---
-- Entfernt das Entity des NPC-Markers.
--
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:DestroyMarker()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    if self.Data.MarkerID then
        DestroyEntity(self.Data.MarkerID);
        self.Data.MarkerID = nil;
    end
    return self;
end

---
-- Zeigt den NPC-Marker des NPC an.
--
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:ShowMarker()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.Data.MarkerID) then
        local EntityScale = Logic.GetEntityScriptingValue(self:GetID(), -45);
        Logic.SetEntityScriptingValue(self.Data.MarkerID, -45, EntityScale);
        Logic.SetModel(self.Data.MarkerID, Models.Effects_E_Wealth);
        Logic.SetVisible(self.Data.MarkerID, true);
    end
    self.Data.MarkerVisibility = true;
    return self;
end

---
-- Versteckt den NPC-Marker des NPC.
--
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:HideMarker()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    if IsExisting(self.Data.MarkerID) then
        Logic.SetModel(self.Data.MarkerID, Models.Effects_E_NullFX);
        Logic.SetVisible(self.Data.MarkerID, false);
    end
    self.Data.MarkerVisibility = false;
    return self;
end

---
-- Gibt true zurück, wenn der Marker des NPC sichtbar ist.
--
-- @return[type=boolen] Sichtbarkeit
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:IsMarkerVisible()
    assert(self ~= BundleNonPlayerCharacter.Global.NonPlayerCharacter, 'Can not be used in static context!');
    return IsExisting(self.Data.MarkerID) and self.Data.MarkerVisibility == true;
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
-- Kontrolliert die Sichtbarkeit und die Position des NPC-Markers.
--
-- @within NonPlayerCharacter
-- @local
--
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:ControlMarker()
    if self:IsActive() and not self:HasTalkedTo() then
        -- Blinken
        if self:IsMarkerVisible() then
            self:HideMarker();
        else
            self:ShowMarker();
        end

        -- Repositionierung
        local x1,y1,z1 = Logic.EntityGetPos(self.Data.MarkerID);
        local x2,y2,z2 = Logic.EntityGetPos(self:GetID());
        if math.abs(x1-x2) > 20 or math.abs(y1-y2) > 20 then
            Logic.DEBUG_SetPosition(self.Data.MarkerID, x2, y2);
        end
    end
    -- Während Briefings immer verstecken
    if IsBriefingActive and IsBriefingActive() then
        self:HideMarker();
    end
end

---
-- Kontrolliert die "Glitter Marker" der NPCs.
--
-- @within Internal
-- @local
--
function BundleNonPlayerCharacter.Global.ControlMarker()
    for k, v in pairs(BundleNonPlayerCharacter.Global.NonPlayerCharacterObjects) do
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
            for k, v in pairs(BundleNonPlayerCharacter.Global.NonPlayerCharacterObjects) do
                if v and v.Data.TalkedTo == nil and v.Data.Distance >= 350 then
                    local x1 = math.floor(BundleNonPlayerCharacter.Global:IntegerToFloat(Logic.GetEntityScriptingValue(PlayersKnights[i], 19)));
                    local y1 = math.floor(BundleNonPlayerCharacter.Global:IntegerToFloat(Logic.GetEntityScriptingValue(PlayersKnights[i], 20)));
                    local x2, y2 = Logic.EntityGetPos(GetID(k));
                    if x1 == math.floor(x2) and y1 == math.floor(y2) then
                        if IsExisting(k) and IsNear(PlayersKnights[i], k, v.Data.Distance) then
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

