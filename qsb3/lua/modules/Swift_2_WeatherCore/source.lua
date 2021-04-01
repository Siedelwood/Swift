-- -------------------------------------------------------------------------- --
-- Module Weather                                                             --
-- -------------------------------------------------------------------------- --

ModuleWeatherCore = {
    Properties = {
        Name = "ModuleWeatherCore",
    },

    Global = {
        EventQueue = {},
        ActiveEvent = nil,
    },
    Local = {
        ActiveEvent = nil,
    },
}

-- Global ------------------------------------------------------------------- --

function ModuleWeatherCore.Global:OnGameStart()
    API.AddSaveGameAction(self.OnSaveGameLoaded);
    API.StartJob(self.EventController);
end

function ModuleWeatherCore.Global:AddEvent(_Event, _Duration)
    local Event = API.InstanceTable(_Event);
    Event.Duration = _Duration;
    table.insert(self.EventQueue, Event);
end

function ModuleWeatherCore.Global:PurgeAllEvents()
    if #self.EventQueue > 0 then
        for i= #self.EventQueue, 1 -1 do
            self.EventQueue:remove(i);
        end
    end
end

function ModuleWeatherCore.Global:NextEvent()
    if not self:IsEventActive() then
        if #self.EventQueue > 0 then
            self:ActivateEvent();
        end
    end
end

function ModuleWeatherCore.Global:ActivateEvent()
    if #self.EventQueue == 0 then
        return;
    end

    local Event = table.remove(self.EventQueue, 1);
    self.ActiveEvent = Event;
    Logic.ExecuteInLuaLocalState([[
        ModuleWeatherCore.Local.ActiveEvent = ]] ..API.ConvertTableToString(Event).. [[
        ModuleWeatherCore.Local:DisplayEvent()
    ]]);

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

function ModuleWeatherCore.Global:StopEvent()
    Logic.ExecuteInLuaLocalState("ModuleWeatherCore.Local.ActiveEvent = nil");
    ModuleWeatherCore.Global.ActiveEvent = nil;
    Logic.DeactivateWeatherEvent();
end

function ModuleWeatherCore.Global:GetEventRemainingTime()
    if not self:IsEventActive() then
        return 0;
    end
    return self.ActiveEvent.Duration;
end

function ModuleWeatherCore.Global:IsEventActive()
    return self.ActiveEvent ~= nil;
end

function ModuleWeatherCore.Global.OnSaveGameLoaded()
    if ModuleWeatherCore.Global:IsEventActive() then
        Logic.ExecuteInLuaLocalState([[
            Display.StopAllEnvironmentSettingsSequences()
            ModuleWeatherCore.Local:DisplayEvent(]] ..ModuleWeatherCore.Global:GetEventRemainingTime().. [[)
        ]]);
    end
end

function ModuleWeatherCore.Global.EventController()
    if ModuleWeatherCore.Global:IsEventActive() then
        ModuleWeatherCore.Global.ActiveEvent.Duration = ModuleWeatherCore.Global.ActiveEvent.Duration -1;
        if ModuleWeatherCore.Global.ActiveEvent.Loop then
            ModuleWeatherCore.Global.ActiveEvent:Loop();
        end
        
        if ModuleWeatherCore.Global.ActiveEvent.Duration == 0 then
            ModuleWeatherCore.Global:StopEvent();
            ModuleWeatherCore.Global:NextEvent();
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleWeatherCore.Local:OnGameStart()
end

function ModuleWeatherCore.Local:DisplayEvent(_Duration)
    if self:IsEventActive() then
        local SequenceID = Display.AddEnvironmentSettingsSequence(self.ActiveEvent.GFX);
        Display.PlayEnvironmentSettingsSequence(SequenceID, _Duration or self.ActiveEvent.Duration);
    end
end

function ModuleWeatherCore.Local:IsEventActive()
    return self.ActiveEvent ~= nil;
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

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleWeatherCore);

