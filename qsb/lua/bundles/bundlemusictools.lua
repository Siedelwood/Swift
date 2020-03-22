-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleMusicTools                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle bietet die Möglichkeit Musikstücke abzuspielen. Die
-- Musik kann als einzelne Titel oder als Playlist wiedergegeben werden.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleMusicTools = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Startet ein Musikstück als Stimme.
--
-- <p><b>Alias:</b> StartSong</p>
--
-- Es wird nicht als Musik behandelt, sondern als Sprache! Die Lautstäkre
-- sämtlicher Sprache wird beeinflusst, weshalb immer nur 1 Song gleichzeitig
-- gespielt werden kann! Alle als Sprache abgespielten Sounds werden die
-- gleiche Lautstärke haben, wie die Musik.
--
-- _Description hat folgendes Format:
-- <ul>
-- <li>File     - Path + Dateiname</li>
-- <li>Volume   - Lautstärke</li>
-- <li>length   - abgespielte Länge in Sekunden (nicht zwingend |Musikstück|)</li>
-- <li>Fadeout  - Ausblendzeit in Zehntels. (>= 5 oder 0 für sofort)</li>
-- <li>MuteAtmo - Hintergrundgeräusche aus</li>
-- <li>MuteUI   - GUI-Sounds aus</li>
-- </ul>
--
-- @param[type=table] _Description Definition des Musikstück
-- @within Anwenderfunktionen
--
-- @usage
-- API.StartMusic({
--     File     = "music/s6_10_antagonist.mp3",
--     Volume   = 70,
--     Length   = 49,
--     Fadeout  = 20,
--     MuteAtmo = true;
--     MuteUI   = true,
-- });
--
function API.StartMusic(_Description)
    if GUI then
        API.Fatal("Could not execute API.StartMusic in local script!");
        return;
    end
    BundleMusicTools.Global:StartSong(_Description);
end
StartSong = API.StartMusic;

---
-- Vereinfachter einzeiliger Aufruf für StartSong.
--
-- <p><b>Alias:</b> StartSongSimple</p>
--
-- @param[type=string] _File Pfad zur Datei
-- @param[type=number] _Volume Lautstärke
-- @param[type=number] _Length Abspieldauer (<= Dauer Musikstück)
-- @param[type=number] _FadeOut Ausblenden in Sekunden
-- @within Anwenderfunktionen
--
-- @usage
-- API.StartMusicSimple("music/s6_10_antagonist.mp3", 70, 49, 1)
--
function API.StartMusicSimple(_File, _Volume, _Length, _FadeOut)
    if GUI then
        API.Bridge("API.StartMusicSimple('" .._File.. "', " .._Volume.. ", " .._Length.. ", " .._FadeOut.. ")");
        return;
    end
    local Data = {
        File     = _File,
        Volume   = _Volume,
        Length   = _Length,
        Fadeout  = _FadeOut * 10,
        MuteAtmo = true;
        MuteUI   = true,
    };
    BundleMusicTools.Global:StartSong(Data);
end
StartSongSimple = API.StartMusicSimple;

---
-- Spielt eine Playlist ab.
--
-- <p><b>Alias:</b> StartPlaylist</p>
--
-- Eine im Skript definierte Playlist, nicht
-- eine XML! Die Playlist kann einmal abgearbeitet oder auf Wiederholung
-- gestellt werden. Alle Einträge haben das Format von StartSong!
-- Zusätzlich kann der Wahrheitswert Repeat gesetzt werden, damit
-- sich die Playlist endlos wiederholt.
--
-- @param[type=table] _Playlist Definition der Playlist
-- @within Anwenderfunktionen
--
-- @usage
-- local Playlist = {
--     {
--         File     = "music/s6_10_antagonist.mp3",
--         Volume   = 70,
--         Length   = 49,
--         Fadeout  = 20,
--         MuteAtmo = true;
--         MuteUI   = true,
--     },
--     {
--         File     = "music/s6_04_blaze.mp3",
--         Volume   = 70,
--         Length   = 65,
--         Fadeout  = 20,
--         MuteAtmo = false;
--         MuteUI   = true,
--     },
-- }
-- API.StartPlaylist(Playlist);
--
function API.StartPlaylist(_Playlist)
    if GUI then
        API.Fatal("Could not execute API.StartPlaylist in local script!");
        return;
    end
    BundleMusicTools.Global:StartPlaylist(_Playlist);
end
StartPlaylist = API.StartPlaylist;

---
-- Stoppt gerade gespielte Musik und startet die Playlist mit dem
-- angegebenen Titel. Es muss eine Playlist existieren! Nachdem der
-- Titel abgespielt ist, wird die Playlist normal weiter gespielt.
--
-- <p><b>Alias:</b> StartPlaylistTitle</p>
--
-- @param[type=number] _Title Index des Titels
-- @within Anwenderfunktionen
--
function API.StartPlaylistTitle(_Title)
    if GUI then
        API.Fatal("Could not execute API.StartPlaylistTitle in local script!");
        return;
    end
    BundleMusicTools.Global:StartPlaylistTitle(_Title);
end
StartPlaylistTitle = API.StartPlaylistTitle;

---
-- Stopt Musik und stellt die alte Soundkonfiguration wieder her.
--
-- <p><b>Alias:</b> StopSong</p>
--
-- @within Anwenderfunktionen
--
function API.StopSong()
    if GUI then
        API.Bridge("API.StopSong()");
        return;
    end
    BundleMusicTools.Global:StopSong();
end
StopSong = API.StopSong;

---
-- Stopt den gerade laufenden Song und leert sowohl die Songdaten
-- als auch die Playlist.
--
-- <p><b>Alias:</b> AbortSongOrPlaylist</p>
--
-- @within Anwenderfunktionen
--
function API.AbortMusic()
    if GUI then
        API.Bridge("API.AbortMusic()");
        return;
    end
    BundleMusicTools.Global:AbortMusic();
end
AbortSongOrPlaylist = API.AbortMusic;

---
-- Startet eine Playlist, welche als XML angegeben ist.
--
-- Eine als XML definierte Playlist wird nicht als Voice abgespielt sondern
-- als Music. Als Musik werden MP3-Dateien verwendet. Diese können entweder
-- im Spiel vorhanden sein oder im Ordner Music in der Map gespeichert
-- werden.
--
-- Wenn du eigene Musik verwendest, achte darauf, einen möglichst eindeutigen
-- Namen zu verwenden. Und natürlich auch auf Urheberrecht!
--
-- Beispiel für eine Playlist:
-- <pre>
--<?xml version="1.0" encoding="utf-8"?>
--<PlayList>
--  <PlayListEntry>
--    <FileName>Music\some_music_file.mp3</FileName>
--    <Type>Loop</Type>
--  </PlayListEntry>
--</PlayList>
--<pre>
-- Als Typ können "Loop" oder "Normal" gewählt werden. Normale Musik wird
-- einmalig abgespielt. Ein Loop läuft endlos weiter.
--
-- Außerdem kann zusätzlich zum Typ eine Abspielwahrscheinlichkeit mit
-- angegeben werden:
-- <pre><Chance>10</Chance></pre>
-- Es sind Zahlen von 1 bis 100 möglich.
--
-- <p><b>Alias:</b> StartEventPlaylist</p>
--
-- @param _Playlist Pfad zur Playlist
-- @param _PlayerID (Optional) ID des menschlichen Spielers
-- @within Anwenderfunktionen
--
function API.StartEventPlaylist(_Playlist, _PlayerID)
    if not GUI then
        API.Bridge(string.format("API.StartEventPlaylist('%s', %d)", _Playlist, _PlayerID or 1));
        return;
    end
    if _PlayerID == GUI.GetPlayerID() then
        Sound.MusicStartEventPlaylist(_Playlist)
    end
end
StartEventPlaylist = API.StartEventPlaylist;

---
-- Beendet eine Event Playlist.
--
-- <p><b>Alias:</b> StopEventPlaylist</p>
--
-- @param _Playlist Pfad zur Playlist
-- @param _PlayerID (Optional) ID des menschlichen Spielers
-- @within Anwenderfunktionen
--
function API.StopEventPlaylist(_Playlist, _PlayerID)
    if not GUI then
        API.Bridge(string.format("API.StopEventPlaylist('%s', %d)", _Playlist, _PlayerID or 1));
        return;
    end
    if _PlayerID == GUI.GetPlayerID() then
        Sound.MusicStopEventPlaylist(_Playlist)
    end
end
StopEventPlaylist = API.StopEventPlaylist;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleMusicTools = {
    Global = {
        Data = {
            StartSongData = {},
            StartSongPlaylist = {},
            StartSongQueue = {},
        }
    },
    Local = {
        Data = {
            SoundBackup = {},
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
function BundleMusicTools.Global:Install()

end

---
-- Startet ein Musikstück als Stimme.
--
-- @param[type=table] _Description Beschreibung des Musikstücks
-- @within Internal
-- @local
--
function BundleMusicTools.Global:StartSong(_Description)
    if self.Data.StartSongData.Running then
        table.insert(self.Data.StartSongQueue, _Description);
    else
        assert(type(_Description.File) == "string");
        assert(type(_Description.Volume) == "number");
        assert(type(_Description.Length) == "number");
        _Description.Length = _Description.Length * 10;
        assert(type(_Description.Fadeout) == "number");
        _Description.MuteAtmo = _Description.MuteAtmo == true;
        _Description.MuteUI = _Description.MuteUI == true;
        _Description.CurrentVolume = _Description.Volume;
        _Description.Time = 0;

        self.Data.StartSongData = _Description;
        self.Data.StartSongData.Running = true;

        Logic.ExecuteInLuaLocalState([[
            BundleMusicTools.Local:BackupSound(
                ]].. _Description.Volume ..[[,
                "]].. _Description.File ..[[",
                ]].. tostring(_Description.MuteAtmo) ..[[,
                ]].. tostring(_Description.MuteUI) ..[[
            )
        ]])

        if not self.Data.StartSongJob then
            self.Data.StartSongJob = StartSimpleHiResJob("StartSongControl");
        end
    end
end

---
-- Spielt eine Playlist ab.
--
-- @param[type=table] _Playlist Playlist
-- @within Internal
-- @local
--
function BundleMusicTools.Global:StartPlaylist(_Playlist)
    for i=1, #_Playlist, 1 do
        table.insert(self.Data.StartSongPlaylist, _Playlist[i]);
        self:StartSong(_Playlist[i]);
    end
    self.Data.StartSongPlaylist.Repeat = _Playlist.Repeat == true;
end

---
-- Stoppt gerade gespielte Musik und startet die Playlist mit dem
-- angegebenen Titel. Es muss eine Playlist existieren! Nachdem der
-- Titel abgespielt ist, wird die Playlist normal weiter gespielt.
--
-- @param[type=number] _Title Index des Titels
-- @within Internal
-- @local
--
function BundleMusicTools.Global:StartPlaylistTitle(_Title)
    local playlist = self.Data.StartSongPlaylist;
    local length = #playlist;
    if (length >= _Title) then
        self.Data.StartSongData.Running = false;
        self.Data.StartSongQueue = {};
        self.Data.StartSongData = {};
        self:StopSong();
        EndJob(self.Data.StartSongJob);
        self.Data.StartSongJob = nil;
        for i=_Title, length, 1 do
            self:StartSong(playlist);
        end
    end
end

---
-- Stopt Musik und stellt die alte Soundkonfiguration wieder her.
--
-- @within Internal
-- @local
--
function BundleMusicTools.Global:StopSong()
    local Queue = #self.Data.StartSongQueue;
    local Data = self.Data.StartSongData;
    Logic.ExecuteInLuaLocalState([[
        BundleMusicTools.Local:ResetSound(
            "]].. ((Data.File ~= nil and Data.File) or "") ..[[",
            ]].. Queue ..[[
        )
    ]]);
end

---
-- Stopt den gerade laufenden Song und leert sowohl die Songdaten
-- als auch die Playlist.
--
-- @within Internal
-- @local
--
function BundleMusicTools.Global:AbortMusic()
    self.Data.StartSongPlaylist = {};
    self.Data.StartSongQueue = {};
    self:StopSong();
    self.Data.StartSongData = {};
    EndJob(self.Data.StartSongJob);
    self.Data.StartSongJob = nil;
end

---
-- Kontrolliert den Song / die Playlist. Wenn ein Song durch ist, wird
-- der nächste Song in der Warteschlange gestartet, sofern vorhanden.
-- Ist die Warteschlange leer, endet der Job. Existiert eine Playlist,
-- für die Repeat = true ist, dann wird die Playlist neu gestartet.
--
-- @within Internal
-- @local
--
function BundleMusicTools.Global.StartSongControl()
    if not BundleMusicTools.Global.Data.StartSongData.Running then
        BundleMusicTools.Global.Data.StartSongData = {};
        BundleMusicTools.Global.Data.StartSongJob = nil;
        if #BundleMusicTools.Global.Data.StartSongQueue > 0 then
            local Description = table.remove(BundleMusicTools.Global.Data.StartSongQueue, 1);
            BundleMusicTools.Global:StartSong(Description);
        else
            if BundleMusicTools.Global.Data.StartSongPlaylist.Repeat then
                BundleMusicTools.Global:StartPlaylist(BundleMusicTools.Global.Data.StartSongPlaylist);
            end
        end
        return true;
    end

    local Data = BundleMusicTools.Global.Data.StartSongData;
    -- Zeit zählen
    BundleMusicTools.Global.Data.StartSongData.Time = Data.Time +1;

    if Data.Fadeout < 5 then
        if Data.Time >= Data.Length then
            BundleMusicTools.Global.Data.StartSongData.Running = false;
            BundleMusicTools.Global:StopSong();
        end
    else
        local FadeoutTime = Data.Length - Data.Fadeout+1;
        if Data.Time >= FadeoutTime then
            if Data.Time >= Data.Length then
                BundleMusicTools.Global.Data.StartSongData.Running = false;
                BundleMusicTools.Global:StopSong();
            else
                local VolumeStep = Data.Volume / Data.Fadeout;
                BundleMusicTools.Global.Data.StartSongData.CurrentVolume = Data.CurrentVolume - VolumeStep;
                Logic.ExecuteInLuaLocalState([[
                    Sound.SetSpeechVolume(]]..Data.CurrentVolume..[[)
                ]]);
            end
        end
    end
end
StartSongControl = BundleMusicTools.Global.StartSongControl;

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleMusicTools.Local:Install()

end

---
-- Speichert die Soundeinstellungen.
--
-- @param[type=number]  _Volume Lautstärke
-- @param[type=string]  _Song Pfad zum Titel
-- @param[type=boolean] _MuteAtmo Atmosphäre stumm schalten
-- @param[type=boolean] _MuteUI UI stumm schalten
-- @within Internal
-- @local
--
function BundleMusicTools.Local:BackupSound(_Volume, _Song, _MuteAtmo, _MuteUI)
    if self.Data.SoundBackup.FXSP == nil then
        self.Data.SoundBackup.FXSP = Sound.GetFXSoundpointVolume();
        self.Data.SoundBackup.FXAtmo = Sound.GetFXAtmoVolume();
        self.Data.SoundBackup.FXVol = Sound.GetFXVolume();
        self.Data.SoundBackup.Sound = Sound.GetGlobalVolume();
        self.Data.SoundBackup.Music = Sound.GetMusicVolume();
        self.Data.SoundBackup.Voice = Sound.GetSpeechVolume();
        self.Data.SoundBackup.UI = Sound.Get2DFXVolume();
    end

    Sound.SetFXVolume(100);
    Sound.SetSpeechVolume(_Volume);
    if _MuteAtmo == true then
        Sound.SetFXSoundpointVolume(0);
        Sound.SetFXAtmoVolume(0);
    end
    if _MuteUI == true then
        Sound.Set2DFXVolume(0);
        Sound.SetFXVolume(0);
    end
    Sound.SetMusicVolume(0);
    Sound.PlayVoice("ImportantStuff", _Song);
end

---
-- Stellt die Soundeinstellungen wieder her.
--
-- @param[type=string] _File Pfad zur Datei
-- @param[type=number] _QueueLength Länge der Warteschlange
-- @within Internal
-- @local
--
function BundleMusicTools.Local:ResetSound(_File, _QueueLength)
    if _File ~= nil then
        Sound.StopVoice("ImportantStuff", _File)
    end
    if _QueueLength <= 0 then
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
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleMusicTools");

