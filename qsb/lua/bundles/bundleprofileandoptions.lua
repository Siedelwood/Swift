-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleProfileAndOptions                                      # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Bundle können Profil und Options bequem aus globalen und lokalem
-- Skript angefragt und verändert werden.
--
-- Da das Profil nicht komplett ausgelesen werden kann, muss vorher jeder
-- Wert, der überwacht werden soll, registriert werden. Wenn du einen neuen
-- Eintrag schreibst, ist dieser automatisch registriert.
--
-- Es wird automatisch jede Sekunde ein Full Sync für Profil und Options
-- gemacht. Damit es nicht zu inkonsistenzen kommt, wird auch sofort und
-- nach jeder Änderung ein Full Sync ausgeführt.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleProfileAndOptions = {};

API = API or {};
QSB = QSB or {};

QSB.ProfileIni = {};
QSB.OptionsIni = {};

-- -------------------------------------------------------------------------- --
-- User Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Registiert einen Wert zur Profilüberwachung.
--
-- Um Werte aus dem Profil zu überwachen, müssen Sektion und der Schlüssel
-- zuerst registriert werden. Der jeweilige Wert wird danach sofort aus dem
-- Profil ermittelt.
--
-- @param[type=string] _Section Sektion
-- @param[type=string] ...      Liste von Schlüssel
-- @within Anwenderfunktionen
--
function API.ProfileObserve(_Section, ...)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format([[API.ProfileObserve('%s', unpack(%s))]], _Section, API.ConvertTableToString({...})));
        return;
    end
    QSB.ProfileIni[_Section] = QSB.ProfileIni[_Section] or {};
    for k, v in pairs({...}) do
        QSB.ProfileIni[_Section][v] = "";
    end
    BundleProfileAndOptions.Local:FullProfileSync();
end

---
-- Setzt einen Wert im Profil.
--
-- Nach dem Setzen des Wertes wird ein Full Sync ausgeführt. Der Full Sync
-- kann u.U. einen kurzen Moment (unter 100 MS) dauern.
--
-- @param[type=string] _Section Sektion
-- @param[type=string] _Key     Schlüssel
-- @param              _Value   Wert
-- @within Anwenderfunktionen
--
function API.ProfileAlterEntry(_Section, _Key, _Value)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format("API.ProfileAlterEntry('%s', '%s', '%s')", _Section, _Key, _Value));
        return;
    end
    QSB.ProfileIni[_Section]       = QSB.ProfileIni[_Section] or {};
    QSB.ProfileIni[_Section][_Key] = (tonumber(_Value) ~= nil and math.floor(tonumber(_Value) +0.5)) or _Value;
    Profile.SetString(_Section, _Key, tostring(_Value));
    BundleProfileAndOptions.Local:FullProfileSync();
end

---
-- Gibt einen Wert zu dem Schlüssel innerhalb der Sektion wieder.
--
-- @param[type=string] _Section Sektion
-- @param[type=string] _Key     Schlüssel
-- @param Wert (wird automatisch zur Number, falls möglich)   
-- @within Anwenderfunktionen
--
function API.ProfileGetEntry(_Section, _Key)
    if not GUI then
        Logic.ExecuteInLuaLocalState("BundleProfileAndOptions.Local:FullProfileSync()");
    else
        BundleProfileAndOptions.Local:FullProfileSync();
    end
    if not QSB.ProfileIni[_Section] then
        return nil;
    end
    local Value = QSB.ProfileIni[_Section][_Key];
    return (tonumber(Value) ~= nil and tonumber(Value)) or Value;
end

---
-- Gibt die komplette Sektion wieder.
--
-- @param[type=string] _Section Sektion
-- @return[type=table] Inhalt der Sektion
-- @within Anwenderfunktionen
--
function API.ProfileGetSection(_Section)
    if not GUI then
        Logic.ExecuteInLuaLocalState("BundleProfileAndOptions.Local:FullProfileSync()");
    else
        BundleProfileAndOptions.Local:FullProfileSync();
    end
    return QSB.ProfileIni[_Section];
end

---
-- Registiert einen Wert zur Optionenüberwachung.
--
-- Um Werte aus dem Profil zu überwachen, müssen Sektion und der Schlüssel
-- zuerst registriert werden. Der jeweilige Wert wird danach sofort aus dem
-- Profil ermittelt.
--
-- @param[type=string] _Section Sektion
-- @param[type=string] ...      Liste der Schlüssel
-- @within Anwenderfunktionen
--
function API.OptionsObserve(_Section, ...)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format([[API.OptionsObserve('%s', unpack(%s))]], _Section, API.ConvertTableToString({...})));
        return;
    end
    QSB.OptionsIni[_Section] = QSB.OptionsIni[_Section] or {};
    for k, v in pairs({...}) do
        QSB.OptionsIni[_Section][v] = "";
    end
    BundleProfileAndOptions.Local:FullOptionsSync();
end

---
-- Setzt einen Wert in den Optionen.
--
-- Nach dem Setzen des Wertes wird ein Full Sync ausgeführt. Der Full Sync
-- kann u.U. einen kurzen Moment (unter 100 MS) dauern.
--
-- @param[type=string] _Section Sektion
-- @param[type=string] _Key     Schlüssel
-- @param              _Value   Wert
-- @within Anwenderfunktionen
--
function API.OptionsAlterEntry(_Section, _Key, _Value)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format("API.OptionsAlterEntry('%s', '%s', '%s')", _Section, _Key, _Value));
        return;
    end
    QSB.OptionsIni[_Section]       = QSB.OptionsIni[_Section] or {};
    QSB.OptionsIni[_Section][_Key] = (tonumber(_Value) ~= nil and math.floor(tonumber(_Value) +0.5)) or _Value;
    Options.SetStringValue(_Section, _Key, tostring(_Value));
    BundleProfileAndOptions.Local:FullOptionsSync();
end

---
-- Gibt einen Wert zu dem Schlüssel innerhalb der Sektion wieder.
--
-- @param[type=string] _Section Sektion
-- @param[type=string] _Key     Schlüssel
-- @return Wert (wird automatisch zur Number, falls möglich)   
-- @within Anwenderfunktionen
--
function API.OptionsGetEntry(_Section, _Key)
    if not GUI then
        Logic.ExecuteInLuaLocalState("BundleProfileAndOptions.Local:FullProfileSync()");
    else
        BundleProfileAndOptions.Local:FullProfileSync();
    end
    if not QSB.OptionsIni[_Section] then
        return nil;
    end
    local Value = QSB.OptionsIni[_Section][_Key];
    return (tonumber(Value) ~= nil and tonumber(Value)) or Value;
end

---
-- Gibt die komplette Sektion wieder.
--
-- @param[type=string] _Section Sektion
-- @return[type=table] Inhalt der Sektion
-- @within Anwenderfunktionen
--
function API.OptionsGetSection(_Section)
    if not GUI then
        Logic.ExecuteInLuaLocalState("BundleProfileAndOptions.Local:FullProfileSync()");
    else
        BundleProfileAndOptions.Local:FullProfileSync();
    end
    return QSB.OptionsIni[_Section];
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleProfileAndOptions = {
    Global = {
        Data = {}
    },
    Local = {
        Data = {}
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Internal
-- @local
--
function BundleProfileAndOptions.Global:Install()
    
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Internal
-- @local
--
function BundleProfileAndOptions.Local:Install()
    StartSimpleJobEx(self.OnEverySecond);
end

---
-- Aktualisiert alle Sektionen mit ihren überwachten Schlüssel-Wert-Paren.
--
-- @within Internal
-- @local
--
function BundleProfileAndOptions.Local:FullProfileSync()
    -- Profil auslesen
    for Section, Content in pairs(QSB.ProfileIni) do
        if type(Section) == "string" and Content then
            for Key, _ in pairs(Content) do
                if type(Key) == "string" then
                    local Value = Profile.GetString(Section, Key);
                    QSB.ProfileIni[Section][Key] = (tonumber(Value) ~= nil and tonumber(Value)) or Value;
                end
            end
        end
    end
    -- Ins globale Skript schreiben
    API.Bridge(string.format([[QSB.ProfileIni = %s]], API.ConvertTableToString(QSB.ProfileIni)));
end

---
-- Aktualisiert alle Sektionen mit ihren überwachten Schlüssel-Wert-Paren.
--
-- @within Internal
-- @local
--
function BundleProfileAndOptions.Local:FullOptionsSync()
    -- Options auslesen
    for Section, Content in pairs(QSB.OptionsIni) do
        if type(Section) == "string" and Content then
            for Key, _ in pairs(Content) do
                if type(Key) == "string" then
                    local Value = Options.GetStringValue(Section, Key);
                    QSB.OptionsIni[Section][Key] = (tonumber(Value) ~= nil and tonumber(Value)) or Value;
                end
            end
        end
    end
    -- Ins globale Skript schreiben
    API.Bridge(string.format([[QSB.OptionsIni = %s]], API.ConvertTableToString(QSB.OptionsIni)));
end

-- Führt alle Jobs einmal Sekunde aus.
function BundleProfileAndOptions.Local.OnEverySecond()
    BundleProfileAndOptions.Local:FullProfileSync();
    BundleProfileAndOptions.Local:FullOptionsSync();
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleProfileAndOptions");

