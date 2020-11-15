-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleSoundOptions                                           # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle bietet die Möglichkeit die Lautstärke im Spiel zu regeln.
-- Außerdem kannst du Stimmen abspielen und stoppen.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleSoundOptions = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Startet eine Playlist, welche als XML angegeben ist.
--
-- Eine als XML definierte Playlist wird nicht als Voice abgespielt sondern
-- als Music. Als Musik werden MP3-Dateien verwendet. Diese können entweder
-- im Spiel vorhanden sein oder im Ordner <i>music/</i> im Root-Verzeichnis
-- des Spiels gespeichert werden. Die Playlist gehört ebenfalls ins Root-
-- Verzeichnis nach <i>config/sound/</i>.
--
-- Verzeichnisstruktur für eigene Musik:
-- <pre>map_xyz.s6xmap.unpacked
--|-- music/*
--|-- config/sound/*
--|-- maps/externalmap/map_xyz/*
--|-- ...</pre>
--
-- In der QSB sind bereits die Variablen <i>gvMission.MusicRootPath</i> und
-- <i>gvMission.PlaylistRootPath</i> mit den entsprechenden Pfaden vordefiniert.
--
-- Wenn du eigene Musik verwendest, achte darauf, einen möglichst eindeutigen
-- Namen zu verwenden. Und natürlich auch auf Urheberrecht!
--
-- Beispiel für eine Playlist:
-- <pre>
--&lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&gt;
--&lt;PlayList&gt;
-- &lt;PlayListEntry&gt;
--   &lt;FileName&gt;Music\some_music_file.mp3&lt;/FileName&gt;
--   &lt;Type&gt;Loop&lt;/Type&gt;
-- &lt;/PlayListEntry&gt;
-- &lt;!-- Hier können weitere Einträge folgen. --&gt;
--&lt;/PlayList&gt;
--</pre>
-- Als Typ können "Loop" oder "Normal" gewählt werden. Normale Musik wird
-- einmalig abgespielt. Ein Loop läuft endlos weiter.
--
-- Außerdem kann zusätzlich zum Typ eine Abspielwahrscheinlichkeit mit
-- angegeben werden:
-- <pre>&lt;Chance&gt;10&lt;/Chance&gt;</pre>
-- Es sind Zahlen von 1 bis 100 möglich.
--
-- @param _Playlist Pfad zur Playlist
-- @param _PlayerID (Optional) ID des menschlichen Spielers
-- @within Anwenderfunktionen
--
-- @usage API.StartEventPlaylist(gvMission.PlaylistRootPath .."my_playlist.xml");
--
function API.StartEventPlaylist(_Playlist, _PlayerID)
    _PlayerID = _PlayerID or 1;
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format("API.StartEventPlaylist('%s', %d)", _Playlist, _PlayerID));
        return;
    end
    if _PlayerID == GUI.GetPlayerID() then
        Sound.MusicStartEventPlaylist(_Playlist)
    end
end

---
-- Beendet eine Event Playlist.
--
-- @param _Playlist Pfad zur Playlist
-- @param _PlayerID (Optional) ID des menschlichen Spielers
-- @within Anwenderfunktionen
--
-- @usage API.StopEventPlaylist("config/sound/my_playlist.xml");
--
function API.StopEventPlaylist(_Playlist, _PlayerID)
    _PlayerID = _PlayerID or 1;
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format("API.StopEventPlaylist('%s', %d)", _Playlist, _PlayerID));
        return;
    end
    if _PlayerID == GUI.GetPlayerID() then
        Sound.MusicStopEventPlaylist(_Playlist)
    end
end

---
-- Spielt einen Sound aus dem Spiel ab.
--
-- Wenn eigene Sounds verwendet werden sollen, müssen sie im WAV-Format
-- vorliegen und in die zwei Verzeichnisse für niedrige und hohe Qualität
-- kopiert werden.
--
-- Verzeichnisstruktur für eigene Sounds:
-- <pre>map_xyz.s6xmap.unpacked
--|-- sounds/high/ui/*
--|-- sounds/low/ui/*
--|-- maps/externalmap/map_xyz/*
--|-- ...</pre>
--
-- @param _Sound    Pfad des Sound
-- @param _PlayerID (Optional) ID des menschlichen Spielers
-- @within Anwenderfunktionen
--
-- @usage API.PlaySound("ui\\menu_left_gold_pay");
--
function API.PlaySound(_Sound, _PlayerID)
    _PlayerID = _PlayerID or 1;
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format([[API.PlaySound("%s", %d)]], _Sound, _PlayerID));
        return;
    end
    if _PlayerID == GUI.GetPlayerID() then
        Sound.FXPlay2DSound(_Sound);
    end
end

---
-- Setzt die allgemeine Lautstärke. Die allgemeine Lautstärke beeinflusst alle
-- anderen Laufstärkeregler.
--
-- <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
-- wenn noch keins angelegt wurde.
--
-- @param _Volume Lautstärke
-- @within Anwenderfunktionen
--
-- @usage API.SoundSetVolume(100);
--
function API.SoundSetVolume(_Volume)
    _Volume = (_Volume < 0 and 0) or math.floor(_Volume);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format("API.SoundSetVolume(%d)", _Volume));
        return;
    end
    BundleSoundOptions.Local:AdjustSound(_Volume, nil, nil, nil, nil);
end

---
-- Setzt die Lautstärke der Musik.
--
-- <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
-- wenn noch keins angelegt wurde.
--
-- @param _Volume Lautstärke
-- @within Anwenderfunktionen
--
-- @usage API.SoundSetMusicVolume(100);
--
function API.SoundSetMusicVolume(_Volume)
    _Volume = (_Volume < 0 and 0) or math.floor(_Volume);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format("API.SoundSetMusicVolume(%d)", _Volume));
        return;
    end
    BundleSoundOptions.Local:AdjustSound(nil, _Volume, nil, nil, nil);
end

---
-- Setzt die Lautstärke der Stimmen.
--
-- <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
-- wenn noch keins angelegt wurde.
--
-- @param _Volume Lautstärke
-- @within Anwenderfunktionen
--
-- @usage API.SoundSetVoiceVolume(100);
--
function API.SoundSetVoiceVolume(_Volume)
    _Volume = (_Volume < 0 and 0) or math.floor(_Volume);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format("API.SoundSetVoiceVolume(%d)", _Volume));
        return;
    end
    BundleSoundOptions.Local:AdjustSound(nil, nil, _Volume, nil, nil);
end

---
-- Setzt die Lautstärke der Umgebung.
--
-- <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
-- wenn noch keins angelegt wurde.
--
-- @param _Volume Lautstärke
-- @within Anwenderfunktionen
--
-- @usage API.SoundSetAtmoVolume(100);
--
function API.SoundSetAtmoVolume(_Volume)
    _Volume = (_Volume < 0 and 0) or math.floor(_Volume);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format("API.SoundSetAtmoVolume(%d)", _Volume));
        return;
    end
    BundleSoundOptions.Local:AdjustSound(nil, nil, nil, _Volume, nil);
end

---
-- Setzt die Lautstärke des Interface.
--
-- <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
-- wenn noch keins angelegt wurde.
--
-- @param _Volume Lautstärke
-- @within Anwenderfunktionen
--
-- @usage API.SoundSetUIVolume(100);
--
function API.SoundSetUIVolume(_Volume)
    _Volume = (_Volume < 0 and 0) or math.floor(_Volume);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format("API.SoundSetUIVolume(%d)", _Volume));
        return;
    end
    BundleSoundOptions.Local:AdjustSound(nil, nil, nil, nil, _Volume);
end

---
-- Erstellt ein Backup der Soundeinstellungen, wenn noch keins erstellt wurde.
--
-- @within Anwenderfunktionen
--
-- @usage API.SoundSave();
--
function API.SoundSave()
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.SoundSave()");
        return;
    end
    BundleSoundOptions.Local:SaveSound();
end

---
-- Stellt den Sound wieder her, sofern ein Backup erstellt wurde.
--
-- @within Anwenderfunktionen
--
-- @usage API.SoundRestore();
--
function API.SoundRestore()
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.SoundRestore()");
        return;
    end
    BundleSoundOptions.Local:RestoreSound();
end

---
-- Gibt eine MP3-Datei als Stimme wieder. Diese Funktion kann auch benutzt
-- werden um Geräusche abzuspielen.
--
-- @param[type=string] _File Abzuspielende Datei
-- @within Anwenderfunktionen
--
-- @usage API.PlayVoice("music/puhdys_alt_wie_ein_baum.mp3");
--
function API.PlayVoice(_File)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format("API.PlayVoice('%s')", _File));
        return;
    end
    API.StopVoice();
    Sound.PlayVoice("ImportantStuff", _File);
end
PlaySound = API.PlaySound;

---
-- Stoppt alle als Stimme abgespielten aktiven Sounds.
--
-- @within Anwenderfunktionen
--
-- @usage API.StopSound();
--
function API.StopVoice()
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.StopVoice()");
        return;
    end
    Sound.StopVoice("ImportantStuff");
end
StopSound = API.StopVoice;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleSoundOptions = {
    Local = {
        Data = {
            SoundBackup = {},
        }
    },
}

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleSoundOptions.Local:Install()
end

function BundleSoundOptions.Local:AdjustSound(_Global, _Music, _Voice, _Atmo, _UI)
    self:SaveSound();
    if _Global then
        Sound.SetGlobalVolume(_Global);
    end
    if _Music then
        Sound.SetMusicVolume(_Music);
    end
    if _Voice then
        Sound.SetSpeechVolume(self.Data.SoundBackup.Voice);
    end
    if _Atmo then
        Sound.SetFXSoundpointVolume(_Atmo);
        Sound.SetFXAtmoVolume(_Atmo);
    end
    if _UI then
        Sound.Set2DFXVolume(_UI);
        Sound.SetFXVolume(_UI);
    end
end

function BundleSoundOptions.Local:SaveSound()
    if self.Data.SoundBackup.FXSP == nil then
        self.Data.SoundBackup.FXSP = Sound.GetFXSoundpointVolume();
        self.Data.SoundBackup.FXAtmo = Sound.GetFXAtmoVolume();
        self.Data.SoundBackup.FXVol = Sound.GetFXVolume();
        self.Data.SoundBackup.Sound = Sound.GetGlobalVolume();
        self.Data.SoundBackup.Music = Sound.GetMusicVolume();
        self.Data.SoundBackup.Voice = Sound.GetSpeechVolume();
        self.Data.SoundBackup.UI = Sound.Get2DFXVolume();
    end
end

function BundleSoundOptions.Local:RestoreSound()
    if self.Data.SoundBackup.FXSP ~= nil then
        Sound.SetFXSoundpointVolume(self.Data.SoundBackup.FXSP)
        Sound.SetFXAtmoVolume(self.Data.SoundBackup.FXAtmo)
        Sound.SetFXVolume(self.Data.SoundBackup.FXVol)
        Sound.SetGlobalVolume(self.Data.SoundBackup.Sound)
        Sound.SetMusicVolume(self.Data.SoundBackup.Music)
        Sound.SetSpeechVolume(self.Data.SoundBackup.Voice)
        Sound.Set2DFXVolume(self.Data.SoundBackup.UI)
        self.Data.SoundBackup = {}
    end
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleSoundOptions");

