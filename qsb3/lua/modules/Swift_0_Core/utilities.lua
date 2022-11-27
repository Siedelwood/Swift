

-- Random Seed

function Swift:CreateRandomSeed()
    local Seed = 0;
    local MapName = Framework.GetCurrentMapName();
    local MapType = Framework.GetCurrentMapTypeAndCampaignName();
    local SeedString = Framework.GetMapGUID(MapName, MapType);
    for PlayerID = 1, 8 do
        if Logic.PlayerGetIsHumanFlag(PlayerID) and Logic.PlayerGetGameState(PlayerID) ~= 0 then
            if GUI.GetPlayerID() == PlayerID then
                local PlayerName = Logic.GetPlayerName(PlayerID);
                local DateText = Framework.GetSystemTimeDateString();
                SeedString = SeedString .. PlayerName .. " " .. DateText;
                for s in SeedString:gmatch(".") do
                    Seed = Seed + ((tonumber(s) ~= nil and tonumber(s)) or s:byte());
                end
                if Framework.IsNetworkGame() then
                    Swift:DispatchScriptCommand(QSB.ScriptCommands.ProclaimateRandomSeed, 0, Seed);
                else
                    GUI.SendScriptCommand("SCP.Core.ProclaimateRandomSeed(" ..Seed.. ")");
                end
            end
            break;
        end
    end
end

function Swift:OverrideOnMPGameStart()
    GameCallback_OnMPGameStart = function()
        Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "VictoryConditionHandler", 1)
    end
end

-- AI

function Swift:InitalizeAIVariables()
    for i= 1, 8 do
        self.m_AIProperties[i] = {};
    end
end

function Swift:DisableLogicFestival()
    Swift.Logic_StartFestival = Logic.StartFestival;
    Logic.StartFestival = function(_PlayerID, _Type)
        if Logic.PlayerGetIsHumanFlag(_PlayerID) ~= true then
            if Swift.m_AIProperties[_PlayerID].ForbidFestival == true then
                return;
            end
        end
        Swift.Logic_StartFestival(_PlayerID, _Type);
    end
end

-- Custom Variable

function Swift:GetCustomVariable(_Name)
    return QSB.CustomVariable[_Name];
end

function Swift:SetCustomVariable(_Name, _Value)
    Swift:UpdateCustomVariable(_Name, _Value);
    local Value = tostring(_Value);
    if type(_Value) ~= "number" then
        Value = [["]] ..Value.. [["]];
    end
    if GUI then
        Swift:DispatchScriptCommand(QSB.ScriptCommands.UpdateCustomVariable, 0, _Name, Value);
    else
        Logic.ExecuteInLuaLocalState(string.format(
            [[Swift:UpdateCustomVariable("%s", %s)]],
            _Name,
            Value
        ));
    end
end

function Swift:UpdateCustomVariable(_Name, _Value)
    if QSB.CustomVariable[_Name] then
        local Old = QSB.CustomVariable[_Name];
        QSB.CustomVariable[_Name] = _Value;
        Swift:DispatchScriptEvent(
            QSB.ScriptEvents.CustomValueChanged,
            _Name,
            Old,
            _Value
        );
    else
        QSB.CustomVariable[_Name] = _Value;
        Swift:DispatchScriptEvent(
            QSB.ScriptEvents.CustomValueChanged,
            _Name,
            nil,
            _Value
        );
    end
end

-- Boolean variants

function Swift:ToBoolean(_Input)
    if type(_Input) == "boolean" then
        return _Input;
    end
    if _Input == 1 or string.find(string.lower(tostring(_Input)), "^[1tjy\\+].*$") then
        return true;
    end
    return false;
end

