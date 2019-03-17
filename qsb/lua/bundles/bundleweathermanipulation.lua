-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleWeatherManipulation                                    # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Mit diesem Modul können Wetterevents und Wetteranimationen kombiniert
-- gestartet werden.
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleWeatherManipulation = {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erzeugt ein neues Wetterevent und gibt es zurück.
-- @param[type=string]  _GFX Verwendetes Display Set
-- @param[type=boolean] _Rain Niederschlag aktivieren
-- @param[type=boolean] _Snow Niederschlag ist Schnee
-- @param[type=boolean] _Ice Wasser gefriert
-- @param[type=boolean] _Monsoon Blockendes Monsunwasser aktivieren
-- @param[type=number]  _Temp Temperatur während des Events
-- @param[type=table]   _NotGrowing Liste der nicht nachwachsenden Güter
-- @return[type=table] Neues Wetterevent
-- @within WeatherEvent
--
function API.WeatherEventCreate(_GFX, _Rain, _Snow, _Ice, _Monsoon, _Temp, _NotGrowing)
    if GUI then
        fatal("API.WeatherEventCreate: Events must be created in the global script!");
        return;
    end
    
    local Event = WeatherEvent:New();
    Event.GFX = _GFX or Event.GFX;
    Event.Rain = _Rain or Event.Rain;
    Event.Snow = _Snow or Event.Snow;
    Event.Ice = _Ice or Event.Ice;
    Event.Monsoon = _Monsoon or Event.Monsoon;
    Event.Temperature = _Temp or Event.Temperature;
    Event.NotGrowing = NotGrowing or Event.NotGrowing;
    return Event;
end

---
-- Registiert ein Event für eine bestimmte Dauer. Das Event wird auf der
-- "Wartebank" eingereiht.
-- @param[type=table]  _Event     Event-Instanz
-- @param[type=string] _Name      Name des Events
-- @param[type=number] _Duration  Name des Events
-- @within WeatherEvent
--
function API.WeatherEventRegister(_Event, _Name, _Duration)
    if GUI then
        fatal("API.WeatherEventStart: Events must be started in the global script!");
        return;
    end
    if type(_Event) ~= "table" or not _Event.GFX then
        fatal("API.WeatherEventStart: Invalid weather event!");
        return;
    end
    BundleWeatherManipulation.Global:AddEvent(_Event, _Name, _Duration);
end

---
-- Registiert ein Event als Endlosschleife. Das Event wird immer wieder neu
-- starten, kurz bevor es eigentlich endet. Es darf keine anderen Events auf
-- der "Wartebank" geben.
-- @param[type=table]  _Event Event-Instanz
-- @param[type=string] _Name  Name des Events
-- @within WeatherEvent
--
function API.WeatherEventRegisterLoop(_Event, _Name)
    if GUI then
        fatal("API.WeatherEventStartLoop: Events must be started in the global script!");
        return;
    end
    if type(_Event) ~= "table" or not _Event.GFX then
        fatal("API.WeatherEventStartLoop: Invalid weather event!");
        return;
    end
    
    _Event.Loop = function(_Data)
        if _Data.Duration <= 36 then
            BundleWeatherManipulation.Global:AddEvent(_Event, _Data.Name, 120);
            BundleWeatherManipulation.Global:StopEvent();
            BundleWeatherManipulation.Global:ActivateEvent();
        end
    end
    BundleWeatherManipulation.Global:AddEvent(_Event, _Name, 120);
end

---
-- Startet das nächste Wetterevent auf der "Wartebank". Wenn bereits ein Event
-- aktiv ist, wird dieses gestoppt. Allerdings bleibt die Animation erhalten.
-- @within WeatherEvent
--
function API.WeatherEventNext()
    BundleWeatherManipulation.Global:StopEvent();
    BundleWeatherManipulation.Global:ActivateEvent();
end

---
-- Bricht das aktuelle Event inklusive der Animation sofort ab.
-- @within WeatherEvent
--
function API.WeatherEventAbort()
    API.Bridge("Display.StopAllEnvironmentSettingsSequences()");
    BundleWeatherManipulation.Global:StopEvent();
end

---
-- Bricht das aktuelle Event ab und löscht alle eingereihten Events.
-- @within WeatherEvent
--
function API.WeatherEventPurge()
    BundleWeatherManipulation.Global:PurgeAllEvents();
    API.Bridge("Display.StopAllEnvironmentSettingsSequences()");
    BundleWeatherManipulation.Global:StopEvent();
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleWeatherManipulation = {
    Global = {
        Data = {
            EventQueue = {},
            ActiveEvent = nil,
        },
    },
    Local = {
        Data = {
            ActiveEvent = nil,
        },
    },
}

-- Global Script ------------------------------------------------------------ --

---
-- Installiert das Bundle im globalen Skript.
-- @within WeatherEvent
-- @local
--
function BundleWeatherManipulation.Global:Install()
    API.AddSaveGameAction(self.OnSaveGameLoaded);
    StartSimpleJobEx(self.EventController);
end

---
-- Fügt ein Event zur Event Queue hinzu.
-- @param[type=table]  _Event    Wetterevent
-- @param[type=string] _Name     Name des Events
-- @param[type=string] _Duration Dauer des Ereignisses
-- @within WeatherEvent
-- @local
--
function BundleWeatherManipulation.Global:AddEvent(_Event, _Name, _Duration)
    local Event = API.InstanceTable(_Event);
    Event.Duration = _Duration;
    Event.Name = _Name;
    table.insert(self.Data.EventQueue, Event);
    -- self:NextEvent();
end

---
-- Entfernt alle Events aus der Event Queue, die den gleichen Namen haben.
-- @param[type=string] _EventName Name des Events
-- @within WeatherEvent
-- @local
--
function BundleWeatherManipulation.Global:PurgeEvent(_EventName)
    if #self.Data.EventQueue > 0 then
        for i= #self.Data.EventQueue, 1 -1 do
            if self.Data.EventQueue[i].Name == _EventName then
                self.Data.EventQueue:remove(i);
            end
        end
    end
end

---
-- Leer die Event Queue komplett.
-- @within WeatherEvent
-- @local
--
function BundleWeatherManipulation.Global:PurgeAllEvents()
    if #self.Data.EventQueue > 0 then
        for i= #self.Data.EventQueue, 1 -1 do
            self.Data.EventQueue:remove(i);
        end
    end
end

---
-- Startet das nächste Wetterevent in der Wetterwarteschlange, aber nur, wenn
-- kein Event aktiv ist.
-- @within WeatherEvent
-- @local
--
function BundleWeatherManipulation.Global:NextEvent()
    if not self:IsEventActive() then
        if #self.Data.EventQueue > 0 then
            self:ActivateEvent();
        end
    end
end

---
-- Startet das nächste Wetterevent in der Wetterwarteschlange.
-- @within WeatherEvent
-- @local
--
function BundleWeatherManipulation.Global:ActivateEvent()
    if #self.Data.EventQueue == 0 then
        return;
    end

    local Event = table.remove(self.Data.EventQueue, 1);
    self.Data.ActiveEvent = Event;
    API.Bridge([[
        BundleWeatherManipulation.Local.Data.ActiveEvent = ]] ..API.ConvertTableToString(Event).. [[
        BundleWeatherManipulation.Local:DisplayEvent()
    ]]);
    API.Note("Debug: Event activated")

    Logic.WeatherEventClearGoodTypesNotGrowing();
    for i= 1, #Event.NotGrowing, 1 do
        Logic.WeatherEventAddGoodTypeNotGrowing(Event.NotGrowing[i]);
    end
    if Event.Rain then
        Logic.WeatherEventSetPrecipitationFalling(true);
        Logic.WeatherEventSetPrecipitationHeaviness(1);
        Logic.WeatherEventSetWaterRegenerationFactor(1);
        if Event.Snow then
            Logic.WeatherEventSetPrecipitationIsSnow(true);
        end
    end
    if Event.Ice then
        Logic.WeatherEventSetWaterFreezes(true);
    end
    if Event.Monsoon then
        Logic.WeatherEventSetShallowWaterFloods(true);
    end
    Logic.WeatherEventSetTemperature(Event.Temperature);
    Logic.ActivateWeatherEvent();
end

---
-- Stoppt das aktuelle Wettervent und die Wetteranimation.
-- @within WeatherEvent
-- @local
--
function BundleWeatherManipulation.Global:StopEvent()
    API.Bridge("BundleWeatherManipulation.Local.Data.ActiveEvent = nil");
    BundleWeatherManipulation.Global.Data.ActiveEvent = nil;
    Logic.DeactivateWeatherEvent();
end

---
-- Gibt die verbleibende Dauer des aktuellen Wetterevnts zurück. Ist kein
-- Event aktiv, wird 0 zurückgegeben.
-- @return[type=number] Übrige Dauer des Events
-- @within WeatherEvent
-- @local
--
function BundleWeatherManipulation.Global:GetEventRemainingTime()
    if not self:IsEventActive() then
        return 0;
    end
    return self.Data.ActiveEvent.Duration;
end

---
-- Prüft, ob ein Wetterevent aktiv ist.
-- @return[type=boolean] Event ist aktiv
-- @within WeatherEvent
-- @local
--
function BundleWeatherManipulation.Global:IsEventActive()
    return self.Data.ActiveEvent ~= nil;
end

---
-- Startet nach dem Laden eines Spielstandes die Wetteranimation neu mit
-- der verbleibenden Zeit des Events.
-- @within WeatherEvent
-- @local
--
function BundleWeatherManipulation.Global.OnSaveGameLoaded()
    if BundleWeatherManipulation.Global:IsEventActive() then
        API.Bridge([[
            Display.StopAllEnvironmentSettingsSequences()
            BundleWeatherManipulation.Local:DisplayEvent(]] ..BundleWeatherManipulation.Global:GetEventRemainingTime().. [[)
        ]]);
    end
end

---
-- Steuert die Event Queue und startet das jeweils nächste Event.
-- @within WeatherEvent
-- @local
--
function BundleWeatherManipulation.Global.EventController()
    if BundleWeatherManipulation.Global:IsEventActive() then
        BundleWeatherManipulation.Global.Data.ActiveEvent.Duration = BundleWeatherManipulation.Global.Data.ActiveEvent.Duration -1;
        if BundleWeatherManipulation.Global.Data.ActiveEvent.Loop then
            BundleWeatherManipulation.Global.Data.ActiveEvent:Loop();
        end
        
        if BundleWeatherManipulation.Global.Data.ActiveEvent.Duration == 0 then
            BundleWeatherManipulation.Global:StopEvent();
            BundleWeatherManipulation.Global:NextEvent();
        end
    end
end

-- Local Script ------------------------------------------------------------- --

---
-- Installiert das Bundle im globalen Skript.
-- @within WeatherEvent
-- @local
--
function BundleWeatherManipulation.Local:Install()
end

---
-- Startet die Wetteranimation mit der Duration des Events. Optional kann
-- eine andere Duration angegeben werden.
-- @param[type=number] Optionale Dauer der Animation
-- @within WeatherEvent
-- @local
--
function BundleWeatherManipulation.Local:DisplayEvent(_Duration)
    if self:IsEventActive() then
        local SequenceID = Display.AddEnvironmentSettingsSequence(self.Data.ActiveEvent.GFX);
        Display.PlayEnvironmentSettingsSequence(SequenceID, _Duration or self.Data.ActiveEvent.Duration);
    end
end

---
-- Prüft, ob ein Wetterevent aktiv ist.
-- @return[type=boolean] Event ist aktiv
-- @within WeatherEvent
-- @local
--
function BundleWeatherManipulation.Local:IsEventActive()
    return self.Data.ActiveEvent ~= nil;
end

--------------------------------------------------------------------------------

WeatherEvent = {
    GFX = "ne_winter_sequence.xml",
    NotGrowing = {},
    Rain = false,
    Snow = false,
    Ice = false,
    Monsoon = false,
    Temperature = 10,
}

---
-- Erstellt ein neues Wetterevent.
--
-- Ein Wetterevent ist standardmäßig eingestellt. Es gibt keinen Niederschlag,
-- und keinen Monsun, alle Güter wachsen, die Temperatur ist 10°C und als
-- GFX wird ne_winter_sequence.xml verwendet.
--
-- Um Werte anzupassen muss auf die Felder in einem neuen Wetterevent
-- zugegriffen werden. Ein Beispiel:
-- <pre>MyEvent.GFX = "as_winter_sequence.xml"</pre>
--
-- Um Güter, die nicht nachwachsen sollen, hinzuzufügen, muss auf das Table
-- NotGrowing zugegriffen werden. Ein Beispiel:
-- <pre>MyEvent.NotGrowing:insert(Goods.G_Grain)</pre>
--
-- Ein einmal erstelltes Event kann immer wieder verwendet werden! Speichere
-- es also in einer globalen Variable.
--
-- Ein Event hat folgende Felder:
-- <table border="1">
-- <tr>
-- <td><b>Feld</b></td>
-- <td><b>Erklärung</b></td>
-- </tr>
-- <tr>
-- <td>GFX</td>
-- <td>String: Die verwendete Display-Animation. Hierbei muss es sich im eine
-- dynamische Display-Animation handeln.</td>
-- </tr>
-- <tr>
-- <td>NotGrowing</td>
-- <td>Table: Liste aller nicht nachwachsender Güter während des Events.</td>
-- </tr>
-- <tr>
-- <td>Rain</td>
-- <td>Boolean: Niederschlag fällt während des Events.</td>
-- </tr>
-- <tr>
-- <td>Snow</td>
-- <td>Boolean: Der Niederschlag fällt als Schnee.</td>
-- </tr>
-- <tr>
-- <td>Ice</td>
-- <td>Boolean: Wasser gefriert während des Events.</td>
-- </tr>
-- <tr>
-- <td>Monsoon</td>
-- <td>Boolean: Monsunwasser ist während des Events aktiv.</td>
-- </tr>
-- <tr>
-- <td>Temperature</td>
-- <td>Number: Die Temperatur während des Events in °C.</td>
-- </tr>
-- </table>
--
-- @within WeatherEvent
-- @local
-- @usage MyEvent = WeatherEvent:New();
--
function WeatherEvent:New()
    return API.InstanceTable(self);
end

--------------------------------------------------------------------------------

Core:RegisterBundle("BundleWeatherManipulation");

