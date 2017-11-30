-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Synfonia Code                                                         # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Das Framework läd die einzelnen Bundles und beinhaltet alle geteilte
-- Funktionen. Interne Spielfunktionen, die überschrieben werden, müssen
-- ebenfalls hier definiert werden.
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
-- @return table
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
-- @param _Data     Datum, das gesucht wird
-- @param _Table    Tabelle, die durchquert wird
-- @return boolean
-- @within QsbFramework Class
-- @local
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
-- Gibt die ID des Quests mit dem angegebenen Namen zurück. Existiert der
-- Quest nicht, wird nil zurückgegeben.
--
-- Alias: GetQuestID
--
-- @param _Name     Identifier des Quest
-- @return number
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
-- @return boolean
--
function API.IsValidateQuest(_QuestID)
    return Quests[_QuestID] ~= nil or Quests[self:GetQuestID(_QuestID)] ~= nil;
end
IsValidQuest = API.IsValidateQuest;

---
-- Hängt eine Funktion an Mission_OnSaveGameLoaded an, sodass sie nach dem
-- Laden eines Spielstandes ausgeführt wird.
--
-- @param _Function Funktion, die ausgeführt werden soll
--
function API.AddSaveGameAction(_Function)
    return QsbFramework:AddSaveGameAction(_Function)
end

-- -------------------------------------------------------------------------- --
-- Application Space                                                          --
-- -------------------------------------------------------------------------- --

QsbFramework = {
    Data = {
        Append = {
            Functions = {},
            Fields = {},
        }
    }
}

---
-- Initialisiert alle verfügbaren Bundles und führt ihre Install-Methode aus.
-- Bundles werden immer getrennt im globalen und im lokalen Skript gestartet.
-- @within QsbFramework Class
-- @local
--
function QsbFramework:InitalizeBundles()
    for k,v in pairs(self.Data.BundleInitializerList) do
        if v.Global ~= nil and v.Global.Install ~= nil and type(v.Global.Install) == "function" and not GUI then
            v.Global:Install();
        end
        if v.Local ~= nil and v.Local.Install ~= nil and type(v.Local.Install) == "function" and GUI then
            v.Local:Install();
        end
    end
end

---
-- Registiert ein Bundle, sodass es initialisiert wird.
--
-- @param _Bundle Name des Moduls
-- @within QsbFramework Class
-- @local
--
function QsbFramework:RegisterBundle(_Bundle)
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
-- @within QsbFramework Class
-- @local
--
function QsbFramework:RegisterBehavior(_Behavior)
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

    _G[_Behavior.Name] = function(...)
        return _G["b_" .. _Behavior.Name]:new(...);
    end
    table.insert(g_QuestBehaviorTypes, _Behavior);
end

---
-- Prüft, ob der Questname formal korrekt ist. Questnamen dürfen i.d.R. nur
-- die Zeichen A-Z, a-7, 0-9, - und _ enthalten.
--
-- @param _Name     Quest
-- @return boolean
-- @within QsbFramework Class
-- @local
--
function QsbFramework:CheckQuestName(_Name)
    return not string.find(__quest_, "[ \"§$%&/\(\)\[\[\?ß\*+#,;:\.^\<\>\|]");
end

---
-- Ändert den Text des Beschreibungsfensters eines Quests. Die Beschreibung
-- wird erst dann aktualisiert, wenn der Quest ausgeblendet wird.
--
-- @param _Text   Neuer Text
-- @param _Quest  Identifier des Quest
-- @within QsbFramework Class
-- @local
--
function QsbFramework:ChangeCustomQuestCaptionText(_Text, _Quest)
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
-- Hängt eine Funktion an Mission_OnSaveGameLoaded an, sodass sie nach dem
-- Laden eines Spielstandes ausgeführt wird.
--
-- @param _Function Funktion, die ausgeführt werden soll
-- @local
--
function QsbFramework:AddSaveGameAction(_Function)
    if not Mission_OnSaveGameLoaded_Orig_QSB_Append then
        Mission_OnSaveGameLoaded_Orig_QSB_Append = Mission_OnSaveGameLoaded;
        Mission_OnSaveGameLoaded = function()
            Mission_OnSaveGameLoaded_Orig_QSB_Append();

            for i=1, #self.Data.Overwrite.Functions.SaveGame, 1 do
                self.Data.Overwrite.Functions.SaveGame[i]();
            end
        end
    end

    self.Data.Append.Functions.SaveGame = self.Data.Append.Functions.SaveGame or {};
    table.insert(self.Data.Append.Functions.SaveGame, _Function);
end
