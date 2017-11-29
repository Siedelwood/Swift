-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Synfonia Framework                                                    # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Das Framework läd die einzelnen Bundles und beinhaltet alle geteilte
-- Funktionen. Interne Spielfunktionen, die überschrieben werden, müssen
-- ebenfalls hier definiert werden.
-- @module QsbFramework
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
-- API-Funktionen                                                             --
-- -------------------------------------------------------------------------- --

---
-- Bereitet ein Behavior für den Einsatz im Assistenten und im Skript vor.
-- Erzeugt zudem den Konstruktor.
--
-- Alias: AddQuestBehavior
--
-- @param _Behavior    Behavior-Objekt
--
API.AddQuestBehavior = function(_Behavior)
    return QsbFramework.RegisterBehavior(_Behavior);
end
AddQuestBehavior = API.AddQuestBehavior;

---
-- Prüft, ob der Questname formal korrekt ist. Questnamen dürfen i.d.R. nur
-- die Zeichen A-Z, a-7, 0-9, - und _ enthalten.
--
-- Alias: ValidQuestName
-- 
-- @param _Name     Quest
-- @return boolean
--
API.ValidQuestName = function(_Name)
    return QsbFramework:CheckQuestName(_Name);
end
ValidQuestName = API.ValidQuestName;

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
API.InstanceTable = function(_Source, _Dest)
    return QsbFramework:InstanceTable(_Source, _Dest);
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
-- @return boolean
--
API.TraverseTable = function(_Data, _Table)
    return QsbFramework:TraverseTable(_Data, _Table);
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
API.GetQuestID = function(_Name)
    return QsbFramework:GetIdOfQuest(_Name);
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
API.ValidateQuest = function(_QuestID)
    return QsbFramework:ValidateQuest(_QuestID);
end
IsValidQuest = API.ValidateQuest;

---
-- Registiert ein Bundle, sodass es initialisiert wird.
--
-- @param _Bundle Name des Moduls
-- 
API.RegisterBundle = function(_Bundle)
    return QsbFramework:RegisterBundle(_Bundle);
end

---
-- Initialisiert alle verfügbaren Bundles und führt ihre Install-Methode aus.
-- 
API.InitalizeBundles = function()
    return QsbFramework:InitalizeBundles()
end

---
-- Wandelt underschiedliche Darstellungen einer Boolean in eine echte um.
--
-- Alias: ToBoolean
-- 
-- @param _Input Boolean-Darstellung
--
API.Boolean = function(_Input)
    local Suspicious = tostring(_Input);
    if Suspicious == true or Suspicious == "true" or Suspicious == "Yes" or Suspicious == "On" or Suspicious == "+" then
        return true;
    end
    if Suspicious == false or Suspicious == "false" or Suspicious == "No" or Suspicious == "Off" or Suspicious == "-" then
        return false;
    end
    return false;
end
ToBoolean = API.Boolean;

-- -------------------------------------------------------------------------- --
-- Framework-Funktionen                                                       --
-- -------------------------------------------------------------------------- --

QsbFramework = {
    Data = {}
}

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
-- Kopiert eine komplette Table und gibt die Kopie zurück. Wenn ein Ziel
-- angegeben wird, ist die zurückgegebene Table eine vereinigung der 2
-- angegebenen Tables.
-- Die Funktion arbeitet rekursiv und ist für beide Arten von Index. Die
-- Funktion kann benutzt werden, um Klassen zu instanzieren.
--
-- @param _Source    Quelltabelle
-- @param _Dest      Zieltabelle
-- @return table
-- @within QsbFramework Class
-- @local
--
function QsbFramework:InstanceTable(_Source, _Dest)
    _Dest = _Dest or {};
    for k, v in pairs(_Source) do
        _Dest[k] = (type(v) == "table" and self:InstanceTable(v)) or v;
    end
    return _Dest;
end

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
function QsbFramework:TraverseTable(_Data, _Table)
    for k,v in pairs(_Table) do
        if v == _Data then
            return true;
        end
    end
    return false;
end

---
-- Gibt die ID des Quests mit dem angegebenen Namen zurück. Existiert der
-- Quest nicht, wird nil zurückgegeben.
--
-- @param _Name     Identifier des Quest
-- @return number
-- @within QsbFramework Class
-- @local
--
function QsbFramework:GetIdOfQuest(_Name)
    for i=1, Quests[0] do
        if Quests[i].Identifier == _Name then
            return i;
        end
    end
end

---
-- Prüft, ob die ID zu einem Quest gehört bzw. der Quest existiert. Es kann
-- auch ein Questname angegeben werden.
--
-- @param _QuestID   ID des Quest
-- @return boolean
-- @within QsbFramework Class
-- @local
-- 
function QsbFramework:ValidateQuest(_QuestID)
    return Quests[_QuestID] ~= nil or Quests[self:GetQuestID(_QuestID)] ~= nil;
end

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