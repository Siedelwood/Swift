-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleSaveGameTools                                          # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --
---@diagnostic disable: undefined-global

---
-- Dieses Bundle bietet Funktionen an, mit denen Anlegen und Laden von
-- Spielständen kontrolliert werden können.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleSaveGameTools = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Speichert das Spiel mit automatisch fortlaufender Nummer im Namen
-- des Spielstandes. Wenn nicht gespeichert werden kann, wird bis
-- zum nächsten mäglichen Zeitpunkt gewartet.
--
-- @param _name [string] Name des Spielstandes
-- @within Anwenderfunktionen
--
function API.AutoSaveGame(_name)
    assert(_name == nil or type(_name) == "string");
    if not GUI then
        Logic.ExecuteInLuaLocalState('API.AutoSaveGame("'.._name..'")');
        return;
    end
    BundleSaveGameTools.Local:AutoSaveGame(_name);
end

---
-- Speichert den Spielstand in das angegebene Verzeichnis. Es können
-- keine Verzeichnise erzeugt werden. Der Pfad beginnt relativ vom
-- Spielstandverzeichnis.
--
-- @param _path [string] Pfad zum Ziel
-- @param _name [string] Name des Spielstandes
-- @within Anwenderfunktionen
--
function API.SaveGameToFolder(_path, _name)
    assert(_path);
    assert(_name);
    if not GUI then
        Logic.ExecuteInLuaLocalState('API.SaveGameToFolder("'.._path..'", "'.._name..'")');
        return;
    end
    BundleSaveGameTools.Local:SaveGameToFolder(_path, _name);
end

---
-- Läd einen Spielstand aus dem angegebenen Verzeichnis. Der Pfad
-- beginnt relativ vom Spielstandverzeichnis. Optional kann der
-- Ladebildschirm gehalten werden, bis der Spieler das Spiel per
-- Button startet.
--
-- @param _path [string] Pfad zum Ziel
-- @param _name [string] Name des Spielstandes
-- @param _needButton [number] Startbutton anzeigen (0 oder 1)
-- @within Anwenderfunktionen
--
function API.LoadGameFromFolder(_path, _name, _needButton)
    assert(_path);
    assert(_name);
    assert(_needButton);
    if not GUI then
        Logic.ExecuteInLuaLocalState('API.LoadGameFromFolder("'.._path..'", "'.._name..'", "'.._needButton..'")');
        return;
    end
    BundleSaveGameTools.Local:LoadGameFromFolder(_path, _name, _needButton);
end

---
-- Startet eine Map aus dem angegebenen Verzeichnis. Die Verzeichnisse
-- werden durch IDs unterschieden.
-- <ul>
-- <li>Kampagne: -1</li>
-- <li>Development:	1</li>
-- <li>Singleplayer: 0</li>
-- <li>Multiplayer:	2</li>
-- <li>Usermap: 3</li>
-- </ul>
--
-- @param _map [string] Name der Map
-- @param _knight [number] Index des Helden
-- @param _folder [number] Mapordner
-- @param _needButton [number] Startbutton nutzen
-- @within Anwenderfunktionen
--
function API.StartMap(_map, _knight, _folder, _needButton)
    assert(_map);
    assert(_knight);
    assert(_folder);
    assert(_needButton);
    if not GUI then
        Logic.ExecuteInLuaLocalState('API.StartMap("'.._map..'", "'.._knight..'", "'.._needButton..'", "'.._needButton..'")');
        return;
    end
    BundleSaveGameTools.Local:StartMap(_map, _knight, _folder, _needButton);
end

---
-- Sperrt das Speichern von Spielständen oder gibt es wieder frei.
--
-- <p><b>Alias:</b> ForbidSaveGame</p>
--
-- @param[type=boolean] _Flag Speichern gesperrt
-- @within Anwenderfunktionen
--
function API.ForbidSaveGame(_Flag)
    if GUI then
        GUI.SendScriptCommand("API.ForbidSaveGame(".. tostring(_Flag) ..")");
        return;
    end
    Logic.ExecuteInLuaLocalState([[
        BundleSaveGameTools.Local.Data.ForbidSave = ]].. tostring(_Flag) ..[[ == true
        BundleSaveGameTools.Local:DisplaySaveButtons(]].. tostring(_Flag) ..[[)
    ]]);
end
ForbidSaveGame = API.ForbidSaveGame;

---
-- Aktiviert oder deaktiviert die automatische Speicherung der History Edition.
--
-- <b>Hinweis</b>: Diese Funktion hat keinen Effekt beim Originalspiel. Nur die
-- History Edition erzeugt automatische Spielstände.
--
-- @param[type=boolean] _Flag HE Quicksave deaktivieren
-- @within Anwenderfunktionen
--
function API.DisableAutomaticQuickSave(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[BundleSaveGameTools.Local.Data.DisableQuicksaveHE = %s]],
            tostring(_Flag == true)
        ));
        return;
    end
    BundleSaveGameTools.Local.Data.DisableQuicksaveHE = _Flag == true;
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleSaveGameTools = {
    Global = {
        Data = {}
    },
    Local = {
        Data = {
            AutoSaveCounter = 0,
            DisableQuicksaveHE = false,
            ForbidSave = false,
        }
    },
}

-- Global Script ---------------------------------------------------------------

function BundleSaveGameTools.Global:Install()
    API.AddSaveGameAction(function()
        Logic.ExecuteInLuaLocalState([[
            BundleSaveGameTools.Local:AlterQuickSaveHotkey();
        ]])
    end);
end

-- Local Script ----------------------------------------------------------------

function BundleSaveGameTools.Local:Install()
    self:InitForbidSaveGame();
    self:AlterQuickSaveHotkey();
end

function BundleSaveGameTools.Local:AutoSaveGame(_Name)
    _Name = _Name or Framework.GetCurrentMapName();

    local MapName = Tool_GetLocalizedMapName(_Name);
    local Counter = BundleSaveGameTools.Local.Data.AutoSaveCounter +1;
    BundleSaveGameTools.Local.Data.AutoSaveCounter = Counter;

    local Text
	if string.len(MapName) > 15 then
	    Text = XGUIEng.GetStringTableText("UI_Texts/Saving_center") .. "{cr}{cr}" .. MapName
	else
	    Text = "{cr}{cr}" .. XGUIEng.GetStringTableText("UI_Texts/Saving_center") .. "{cr}{cr}" .. MapName
	end

    if self:CanGameBeSaved() then
        OpenDialog(API.Localize(Text), XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center"));
        XGUIEng.ShowWidget("/InGame/Dialog/Ok", 0);
        Framework.SaveGame("Autosave "..Counter.." --- ".._Name, "Saved by QSB");
    else
        StartSimpleJobEx( function()
            if BundleSaveGameTools.Local:CanGameBeSaved() then
                OpenDialog(API.Localize(Text), XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center"));
                XGUIEng.ShowWidget("/InGame/Dialog/Ok", 0);
                Framework.SaveGame("Autosave - "..Counter.." --- ".._Name, "Saved by QSB");
                return true;
            end
        end);
    end
end

function BundleSaveGameTools.Local:CanGameBeSaved()
    if self.Data.ForbidSave then
        return false;
    end
    if not Core:CanGameBeSaved() then
        return false;
    end
    return true;
end

function BundleSaveGameTools.Local:SaveGameToFolder(_path, _name)
    _name = _name or Framework.GetCurrentMapName();
    Framework.SaveGame(_path .. "/" .. _name, "--");
end

function BundleSaveGameTools.Local:LoadGameFromFolder(_path, _name, _needButton)
    _needButton = _needButton or 0;
    assert( type(_name) == "string" );
    local SaveName = _path .. "/" .. _name .. GetSaveGameExtension();
    local Name, Type, Campaign = Framework.GetSaveGameMapNameAndTypeAndCampaign(SaveName);
    InitLoadScreen(false, Type, Name, Campaign, 0);
    Framework.ResetProgressBar();
    Framework.SetLoadScreenNeedButton(_needButton);
    Framework.LoadGame(SaveName);
end

function BundleSaveGameTools.Local:StartMap(_map, _knight, _folder, _needButton)
    _needButton = _needButton or 1;
    _knight = _knight or 0;
    _folder = _folder or 3;
    local name, desc, size, mode = Framework.GetMapNameAndDescription(_map, _folder);
    if name ~= nil and name ~= "" then
        XGUIEng.ShowAllSubWidgets("/InGame",0);
        Framework.SetLoadScreenNeedButton(_needButton);
        InitLoadScreen(false, _folder, _map, 0, _knight);
        Framework.ResetProgressBar();
        Framework.StartMap(_map, _folder, _knight);
    else
        GUI.AddNote("ERROR: invalid mapfile!");
    end
end

-- -------------------------------------------------------------------------- --

function BundleSaveGameTools.Local:InitForbidSaveGame()
    KeyBindings_SaveGame = function(_ByUser)
        -- In der History Edition wird diese Funktion aufgerufen, wenn der
        -- letzte Spielstand der Map älter als 15 Minuten ist. Wenn ein
        -- Briefing oder eine Cutscene aktiv ist oder das Speichern generell
        -- verboten wurde, sollen keine Quicksaves erstellt werden.
        if not BundleSaveGameTools.Local:CanGameBeSaved() then
            return;
        end
        -- Außerdem soll es möglich sein, die Quicksaves der HE zu verbieten,
        -- aber dem Spieler weiterhin Quicksaves zu erlauben
        if not _ByUser and BundleSaveGameTools.Local.Data.DisableQuicksaveHE then
            return;
        end
        KeyBindings_SaveGame_Orig_Core_SaveGame();
    end
end

function BundleSaveGameTools.Local:DisplaySaveButtons(_Flag)
    XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame",  (_Flag and 0) or 1);
    XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", (_Flag and 0) or 1);
end

function BundleSaveGameTools.Local:AlterQuickSaveHotkey()
    Input.KeyBindDown(
        Keys.ModifierControl + Keys.S,
        "KeyBindings_SaveGame(true)",
        2,
        false
    );
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleSaveGameTools");

