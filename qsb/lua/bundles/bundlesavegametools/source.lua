-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleSaveGameTools                                          # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle bietet Funktionen an, mit denen Spielstände außerhalb des
-- üblichen Ordners gespeichert und geladen werden können.
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
-- zum nδchsten mφglichen Zeitpunkt gewartet.
--
-- @param _Name	Name des Spielstandes
-- @within Anwenderfunktionen
--
function API.AutoSaveGame(_name)
    assert(_name);
    if not GUI then
        API.Bridge('API.AutoSaveGame("'.._name..'")');
        return;
    end
    BundleSaveGameTools.Local:AutoSaveGame(_name);
end

---
-- Speichert den Spielstand in das angegebene Verzeichnis. Es kφnnen
-- keine Verzeichnise erzeugt werden. Der Pfad beginnt relativ vom
-- Spielstandverzeichnis.
--
-- @param _path	Pfad zum Ziel
-- @param _name	Name des Spielstandes
-- @within Anwenderfunktionen
--
function API.SaveGameToFolder(_path, _name)
    assert(_path);
    assert(_name);
    if not GUI then
        API.Bridge('API.SaveGameToFolder("'.._path..'", "'.._name..'")');
        return;
    end
    BundleSaveGameTools.Local:SaveGameToFolder(_path, _name);
end

---
-- Lδd einen Spielstand aus dem angegebenen Verzeichnis. Der Pfad
-- beginnt relativ vom Spielstandverzeichnis. Optional kann der
-- Ladebildschirm gehalten werden, bis der Spieler das Spiel per
-- Button startet.
--
-- @param _path		  Pfad zum Ziel
-- @param _name		  Name des Spielstandes
-- @param _needButton Startbutton anzeigen (0 oder 1)
-- @within Anwenderfunktionen
--
function API.LoadGameFromFolder(_path, _name, _needButton)
    assert(_path);
    assert(_name);
    assert(_needButton);
    if not GUI then
        API.Bridge('API.LoadGameFromFolder("'.._path..'", "'.._name..'", "'.._needButton..'")');
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
-- @param _map			Name der Map
-- @param _knight		Index des Helden
-- @param _folder		Mapordner
-- @param _needButton	Startbutton nutzen
-- @within Anwenderfunktionen
--
function API.StartMap(_map, _knight, _folder, _needButton)
    assert(_map);
    assert(_knight);
    assert(_folder);
    assert(_needButton);
    if not GUI then
        API.Bridge('API.StartMap("'.._map..'", "'.._knight..'", "'.._needButton..'", "'.._needButton..'")');
        return;
    end
    BundleSaveGameTools.Local:StartMap(_map, _knight, _folder, _needButton);
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
        }
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function BundleSaveGameTools.Global:Install()

end



-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleSaveGameTools.Local:Install()

end

---
-- Speichert das Spiel mit automatisch fortlaufender Nummer im Namen
-- des Spielstandes. Wenn nicht gespeichert werden kann, wird bis
-- zum nächsten mφglichen Zeitpunkt gewartet.
--
-- @param _Name	Name des Spielstandes
-- @within Internal
-- @local
--
function BundleSaveGameTools.Local:AutoSaveGame(_name)
    _name = _name or Framework.GetCurrentMapName();

    local counter = BundleSaveGameTools.Local.Data.AutoSaveCounter +1;
    BundleSaveGameTools.Local.Data.AutoSaveCounter = counter;
    local lang = Network.GetDesiredLanguage();
    if lang ~= "de" then lang = "en" end
    local text = (lang == "de" and "Spiel wird gespeichert...") or
                  "Saving game...";

    if self:CanGameBeSaved() then
        OpenDialog(text, XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center"));
        XGUIEng.ShowWidget("/InGame/Dialog/Ok", 0);
        Framework.SaveGame("Autosave "..counter.." --- ".._name, "--");
    else
        StartSimpleJobEx( function()
            if BundleSaveGameTools.Local:CanGameBeSaved() then
                OpenDialog(text, XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center"));
                XGUIEng.ShowWidget("/InGame/Dialog/Ok", 0);
                Framework.SaveGame("Autosave - "..counter.." --- ".._name, "--");
                return true;
            end
        end);
    end
end

---
-- Prüft, ob das Spiel gerade gespeichert werden kann.
--
-- @return boolean: Kann speichern
-- @within Internal
-- @local
--
function BundleSaveGameTools.Local:CanGameBeSaved()
    if BundleGameHelperFunctions and BundleGameHelperFunctions.Local.Data.ForbidSave then
        return false;
    end
    if IsBriefingActive and IsBriefingActive() then
        return false;
    end
    if XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") ~= 0 then
        return false;
    end
    return true;
end

---
-- Speichert den Spielstand in das angegebene Verzeichnis. Es kφnnen
-- keine Verzeichnise erzeugt werden. Der Pfad beginnt relativ vom
-- Spielstandverzeichnis.
--
-- @param _path	Pfad zum Ziel
-- @param _name	Name des Spielstandes
-- @within Internal
-- @local
--
function BundleSaveGameTools.Local:SaveGameToFolder(_path, _name)
    _name = _name or Framework.GetCurrentMapName();
    Framework.SaveGame(_path .. "/" .. _name, "--");
end

---
-- Läd einen Spielstand aus dem angegebenen Verzeichnis. Der Pfad
-- beginnt relativ vom Spielstandverzeichnis. Optional kann der
-- Ladebildschirm gehalten werden, bis der Spieler das Spiel per
-- Button startet.
--
-- @param _path		  Pfad zum Ziel
-- @param _name		  Name des Spielstandes
-- @param _needButton Startbutton anzeigen (0 oder 1)
-- @within Internal
-- @local
--
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
-- @param _map			Name der Map
-- @param _knight		Index des Helden
-- @param _folder		Mapordner
-- @param _needButton	Startbutton nutzen
-- @within Internal
-- @local
--
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

Core:RegisterBundle("BundleSaveGameTools");
