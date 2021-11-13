-- -------------------------------------------------------------------------- --
-- Module Dialog Tools                                                        --
-- -------------------------------------------------------------------------- --

ModuleInterfaceCore = {
    Properties = {
        Name = "ModuleInterfaceCore",
    },

    Global = {},
    Local = {
        HotkeyDescriptions = {},
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
}

QSB.PlayerNames = {};

-- Global ------------------------------------------------------------------- --

function ModuleInterfaceCore.Global:OnGameStart()
end

-- Local -------------------------------------------------------------------- --

function ModuleInterfaceCore.Local:OnGameStart()
    self:OverrideMissionGoodCounter();
    self:SetupHackRegisterHotkey();
end

function ModuleInterfaceCore.Local:OverrideMissionGoodCounter()
    StartMissionGoodOrEntityCounter = function(_Icon, _AmountToReach)
        if type(_Icon[3]) == "string" then
            ModuleInterfaceCore.Local:SetIcon("/InGame/Root/Normal/MissionGoodOrEntityCounter/Icon", _Icon, 64, _Icon[3]);
        else
            SetIcon("/InGame/Root/Normal/MissionGoodOrEntityCounter/Icon", _Icon);
        end

        g_MissionGoodOrEntityCounterAmountToReach = _AmountToReach;
        g_MissionGoodOrEntityCounterIcon = _Icon;

        XGUIEng.ShowWidget("/InGame/Root/Normal/MissionGoodOrEntityCounter", 1);
    end
end

function ModuleInterfaceCore.Local:SetPlayerPortraitByPrimaryKnight(_PlayerID)
    local KnightID = Logic.GetKnightID(_PlayerID);
    if KnightID == 0 then
        return;
    end
    local KnightType = Logic.GetEntityType(KnightID);
    local KnightTypeName = Logic.GetEntityTypeName(KnightType);
    local HeadModelName = "H" .. string.sub(KnightTypeName, 2, 8) .. "_" .. string.sub(KnightTypeName, 9);

    if not Models["Heads_" .. HeadModelName] then
        HeadModelName = "H_NPC_Generic_Trader";
    end
    g_PlayerPortrait[_PlayerID] = HeadModelName;
end

function ModuleInterfaceCore.Local:SetPlayerPortraitBySettler(_PlayerID, _Portrait)
    local PortraitMap = {
        ["U_KnightChivalry"]           = "H_Knight_Chivalry",
        ["U_KnightHealing"]            = "H_Knight_Healing",
        ["U_KnightPlunder"]            = "H_Knight_Plunder",
        ["U_KnightRedPrince"]          = "H_Knight_RedPrince",
        ["U_KnightSabatta"]            = "H_Knight_Sabatt",
        ["U_KnightSong"]               = "H_Knight_Song",
        ["U_KnightTrading"]            = "H_Knight_Trading",
        ["U_KnightWisdom"]             = "H_Knight_Wisdom",
        ["U_NPC_Amma_NE"]              = "H_NPC_Amma",
        ["U_NPC_Castellan_ME"]         = "H_NPC_Castellan_ME",
        ["U_NPC_Castellan_NA"]         = "H_NPC_Castellan_NA",
        ["U_NPC_Castellan_NE"]         = "H_NPC_Castellan_NE",
        ["U_NPC_Castellan_SE"]         = "H_NPC_Castellan_SE",
        ["U_MilitaryBandit_Ranged_ME"] = "H_NPC_Mercenary_ME",
        ["U_MilitaryBandit_Melee_NA"]  = "H_NPC_Mercenary_NA",
        ["U_MilitaryBandit_Melee_NE"]  = "H_NPC_Mercenary_NE",
        ["U_MilitaryBandit_Melee_SE"]  = "H_NPC_Mercenary_SE",
        ["U_NPC_Monk_ME"]              = "H_NPC_Monk_ME",
        ["U_NPC_Monk_NA"]              = "H_NPC_Monk_NA",
        ["U_NPC_Monk_NE"]              = "H_NPC_Monk_NE",
        ["U_NPC_Monk_SE"]              = "H_NPC_Monk_SE",
        ["U_NPC_Villager01_ME"]        = "H_NPC_Villager01_ME",
        ["U_NPC_Villager01_NA"]        = "H_NPC_Villager01_NA",
        ["U_NPC_Villager01_NE"]        = "H_NPC_Villager01_NE",
        ["U_NPC_Villager01_SE"]        = "H_NPC_Villager01_SE",
    }

    if g_GameExtraNo > 0 then
        PortraitMap["U_KnightPraphat"]           = "H_Knight_Praphat";
        PortraitMap["U_KnightSaraya"]            = "H_Knight_Saraya";
        PortraitMap["U_KnightKhana"]             = "H_Knight_Khana";
        PortraitMap["U_MilitaryBandit_Melee_AS"] = "H_NPC_Mercenary_AS";
        PortraitMap["U_NPC_Castellan_AS"]        = "H_NPC_Castellan_AS";
        PortraitMap["U_NPC_Villager_AS"]         = "H_NPC_Villager_AS";
        PortraitMap["U_NPC_Monk_AS"]             = "H_NPC_Monk_AS";
        PortraitMap["U_NPC_Monk_Khana"]          = "H_NPC_Monk_Khana";
    end

    local HeadModelName = "H_NPC_Generic_Trader";
    local EntityID = GetID(_Portrait);
    if EntityID ~= 0 then
        local EntityType = Logic.GetEntityType(EntityID);
        local EntityTypeName = Logic.GetEntityTypeName(EntityType);
        HeadModelName = PortraitMap[EntityTypeName] or "H_NPC_Generic_Trader";
        if not HeadModelName then
            HeadModelName = "H_NPC_Generic_Trader";
        end
    end
    g_PlayerPortrait[_PlayerID] = HeadModelName;
end

function ModuleInterfaceCore.Local:SetPlayerPortraitByModelName(_PlayerID, _Portrait)
    if not Models["Heads_" .. tostring(_Portrait)] then
        _Portrait = "H_NPC_Generic_Trader";
    end
    g_PlayerPortrait[_PlayerID] = _Portrait;
end

function ModuleInterfaceCore.Local:SetIcon(_WidgetID, _Coordinates, _Size, _Name)
    if type(_Name) == "number" then
        _Name = "icons" .. ((_Name > 0 and _Name+1) or "");
    end
    if _Name == nil then
        _Name = "icons";
    end
    if _Size == nil then
        _Size = 64;
    end
    if _Size == 44 then
        _Name = _Name .. ".png";
    end
    if _Size == 64 then
        _Name = _Name .. "big.png";
    end
    if _Size == 128 then
        _Name = _Name .. "verybig.png";
    end

    local u0, u1, v0, v1;
    u0 = (_Coordinates[1] - 1) * _Size;
    v0 = (_Coordinates[2] - 1) * _Size;
    u1 = (_Coordinates[1]) * _Size;
    v1 = (_Coordinates[2]) * _Size;

    State = 1;
    if XGUIEng.IsButton(_WidgetID) == 1 then
        State = 7;
    end
    XGUIEng.SetMaterialAlpha(_WidgetID, State, 255);
    XGUIEng.SetMaterialTexture(_WidgetID, State, _Name);
    XGUIEng.SetMaterialUV(_WidgetID, State, u0, v0, u1, v1);
end

function ModuleInterfaceCore.Local:TextNormal(_title, _text, _disabledText)
    if _title and _title:find("[A-Za-z0-9]+/[A-Za-z0-9]+$") then
        _title = XGUIEng.GetStringTableText(_title);
    end
    if _text and _text:find("[A-Za-z0-9]+/[A-Za-z0-9]+$") then
        _text = XGUIEng.GetStringTableText(_text);
    end
    _disabledText = _disabledText or "";
    if _disabledText and _disabledText:find("[A-Za-z0-9]+/[A-Za-z0-9]+$") then
        _disabledText = XGUIEng.GetStringTableText(_disabledText);
    end

    local TooltipContainerPath = "/InGame/Root/Normal/TooltipNormal";
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath);
    local TooltipNameWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Name");
    local TooltipDescriptionWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Text");
    local TooltipBGWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/BG");
    local TooltipFadeInContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn");
    local PositionWidget = XGUIEng.GetCurrentWidgetID();
    GUI_Tooltip.ResizeBG(TooltipBGWidget, TooltipDescriptionWidget);
    local TooltipContainerSizeWidgets = {TooltipBGWidget};
    GUI_Tooltip.SetPosition(TooltipContainer, TooltipContainerSizeWidgets, PositionWidget);
    GUI_Tooltip.FadeInTooltip(TooltipFadeInContainer);

    local title = (_title and _title) or "";
    local text = (_text and _text) or "";
    local disabled = "";
    if XGUIEng.IsButtonDisabled(PositionWidget) == 1 and _disabledText then
        disabled = disabled .. "{cr}{@color:255,32,32,255}" .. _disabledText;
    end

    XGUIEng.SetText(TooltipNameWidget, "{center}" .. title);
    XGUIEng.SetText(TooltipDescriptionWidget, text .. disabled);
    local Height = XGUIEng.GetTextHeight(TooltipDescriptionWidget, true);
    local W, H = XGUIEng.GetWidgetSize(TooltipDescriptionWidget);
    XGUIEng.SetWidgetSize(TooltipDescriptionWidget, W, Height);
end

function ModuleInterfaceCore.Local:TextCosts(_title,_text,_disabledText,_costs,_inSettlement)
    _costs = _costs or {};
    local Costs = {};
    -- This transforms the content of the metatable to a new table so that the
    -- internal script does correctly render the costs.
    for i= 1, 4, 1 do
        Costs[i] = _costs[i];
    end
    if _title and _title:find("[A-Za-z0-9]+/[A-Za-z0-9]+$") then
        _title = XGUIEng.GetStringTableText(_title);
    end
    if _text and _text:find("[A-Za-z0-9]+/[A-Za-z0-9]+$") then
        _text = XGUIEng.GetStringTableText(_text);
    end
    if _disabledText and _disabledText:find("^[A-Za-z0-9]+/[A-Za-z0-9]+$") then
        _disabledText = XGUIEng.GetStringTableText(_disabledText);
    end

    local TooltipContainerPath = "/InGame/Root/Normal/TooltipBuy";
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath);
    local TooltipNameWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Name");
    local TooltipDescriptionWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Text");
    local TooltipBGWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/BG");
    local TooltipFadeInContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn");
    local TooltipCostsContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/Costs");
    local PositionWidget = XGUIEng.GetCurrentWidgetID();
    GUI_Tooltip.ResizeBG(TooltipBGWidget, TooltipDescriptionWidget);
    GUI_Tooltip.SetCosts(TooltipCostsContainer, Costs, _inSettlement);
    local TooltipContainerSizeWidgets = {TooltipContainer, TooltipCostsContainer, TooltipBGWidget};
    GUI_Tooltip.SetPosition(TooltipContainer, TooltipContainerSizeWidgets, PositionWidget, nil, true);
    GUI_Tooltip.OrderTooltip(TooltipContainerSizeWidgets, TooltipFadeInContainer, TooltipCostsContainer, PositionWidget, TooltipBGWidget);
    GUI_Tooltip.FadeInTooltip(TooltipFadeInContainer);

    local title = (_title and _title) or "";
    local text = (_text and _text) or "";
    local disabled = "";
    if XGUIEng.IsButtonDisabled(PositionWidget) == 1 and _disabledText then
        disabled = disabled .. "{cr}{@color:255,32,32,255}" .. _disabledText;
    end

    XGUIEng.SetText(TooltipNameWidget, "{center}" .. title);
    XGUIEng.SetText(TooltipDescriptionWidget, text .. disabled);
    local Height = XGUIEng.GetTextHeight(TooltipDescriptionWidget, true);
    local W, H = XGUIEng.GetWidgetSize(TooltipDescriptionWidget);
    XGUIEng.SetWidgetSize(TooltipDescriptionWidget, W, Height);
end

function ModuleInterfaceCore.Local:SetupHackRegisterHotkey()
    function g_KeyBindingsOptions:OnShow()
        if Game ~= nil then
            XGUIEng.ShowWidget("/InGame/KeyBindingsMain/Backdrop", 1);
        else
            XGUIEng.ShowWidget("/InGame/KeyBindingsMain/Backdrop", 0);
        end

        if g_KeyBindingsOptions.Descriptions == nil then
            g_KeyBindingsOptions.Descriptions = {};
            DescRegister("MenuInGame");
            DescRegister("MenuDiplomacy");
            DescRegister("MenuProduction");
            DescRegister("MenuPromotion");
            DescRegister("MenuWeather");
            DescRegister("ToggleOutstockInformations");
            DescRegister("JumpMarketplace");
            DescRegister("JumpMinimapEvent");
            DescRegister("BuildingUpgrade");
            DescRegister("BuildLastPlaced");
            DescRegister("BuildStreet");
            DescRegister("BuildTrail");
            DescRegister("KnockDown");
            DescRegister("MilitaryAttack");
            DescRegister("MilitaryStandGround");
            DescRegister("MilitaryGroupAdd");
            DescRegister("MilitaryGroupSelect");
            DescRegister("MilitaryGroupStore");
            DescRegister("MilitaryToggleUnits");
            DescRegister("UnitSelect");
            DescRegister("UnitSelectToggle");
            DescRegister("UnitSelectSameType");
            DescRegister("StartChat");
            DescRegister("StopChat");
            DescRegister("QuickSave");
            DescRegister("QuickLoad");
            DescRegister("TogglePause");
            DescRegister("RotateBuilding");
            DescRegister("ExitGame");
            DescRegister("Screenshot");
            DescRegister("ResetCamera");
            DescRegister("CameraMove");
            DescRegister("CameraMoveMouse");
            DescRegister("CameraZoom");
            DescRegister("CameraZoomMouse");
            DescRegister("CameraRotate");

            for k,v in pairs(ModuleInterfaceCore.Local.HotkeyDescriptions) do
                if v then
                    v[1] = (type(v[1]) == "table" and API.Localize(v[1])) or v[1];
                    v[2] = (type(v[2]) == "table" and API.Localize(v[2])) or v[2];
                    table.insert(g_KeyBindingsOptions.Descriptions, 1, v);
                end
            end
        end
        XGUIEng.ListBoxPopAll(g_KeyBindingsOptions.Widget.ShortcutList);
        XGUIEng.ListBoxPopAll(g_KeyBindingsOptions.Widget.ActionList);
        for Index, Desc in ipairs(g_KeyBindingsOptions.Descriptions) do
            XGUIEng.ListBoxPushItem(g_KeyBindingsOptions.Widget.ShortcutList, Desc[1]);
            XGUIEng.ListBoxPushItem(g_KeyBindingsOptions.Widget.ActionList,   Desc[2]);
        end
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleInterfaceCore);

