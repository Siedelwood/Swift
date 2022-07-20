--[[
Swift_0_Core/User

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

QSB.RefillAmounts = {};

function Swift:InitalizeCallbackGlobal()
    self:OverrideSaveLoadedCallback();
    self:OverwriteGeologistRefill();
    self:OverrideSoldierPayment();
end

function Swift:InitalizeCallbackLocal()
    self:SetEscapeKeyTrigger();
end

-- Trigger Entity Killed Callbacks

function Swift:TriggerEntityKilledCallbacks(_Entity, _Attacker)
    local DefenderID = GetID(_Entity);
    local AttackerID = GetID(_Attacker or 0);
    if AttackerID == 0 or DefenderID == 0 or Logic.GetEntityHealth(DefenderID) > 0 then
        return;
    end
    local x, y, z     = Logic.EntityGetPos(DefenderID);
    local DefPlayerID = Logic.EntityGetPlayer(DefenderID);
    local DefType     = Logic.GetEntityType(DefenderID);
    local AttPlayerID = Logic.EntityGetPlayer(AttackerID);
    local AttType     = Logic.GetEntityType(AttackerID);

    GameCallback_EntityKilled(DefenderID, DefPlayerID, AttackerID, AttPlayerID, DefType, AttType);
    Logic.ExecuteInLuaLocalState(string.format(
        "GameCallback_Feedback_EntityKilled(%d, %d, %d, %d,%d, %d, %f, %f)",
        DefenderID, DefPlayerID, AttackerID, AttPlayerID, DefType, AttType, x, y
    ));
end

-- Save Game Callback

function Swift:OverrideSaveLoadedCallback()
    if Mission_OnSaveGameLoaded then
        Mission_OnSaveGameLoaded_Orig_Swift = Mission_OnSaveGameLoaded;
        Mission_OnSaveGameLoaded = function()
            Mission_OnSaveGameLoaded_Orig_Swift();
            Swift:RestoreAfterLoad();
            Logic.ExecuteInLuaLocalState("Swift:RestoreAfterLoad()");
            Swift:DispatchScriptEvent(QSB.ScriptEvents.SaveGameLoaded);
            Logic.ExecuteInLuaLocalState("Swift:DispatchScriptEvent(QSB.ScriptEvents.SaveGameLoaded)");
        end
    end
end

function Swift:RestoreAfterLoad()
    debug("Loading save game", true);
    self:OverrideString();
    self:OverrideTable();
    if self:IsGlobalEnvironment() then
        self:GlobalRestoreDebugAfterLoad();
        self:DisableLogicFestival();
        -- self:LogGlobalCFunctions();
    end
    if self:IsLocalEnvironment() then
        self:LocalRestoreDebugAfterLoad();
        self:SetEscapeKeyTrigger();
        self:CreateRandomSeed();
        self:AlterQuickSaveHotkey();
        -- self:LogLocalCFunctions();
    end
end

-- Escape Callback

function Swift:SetEscapeKeyTrigger()
    Input.KeyBindDown(Keys.Escape, "Swift:ExecuteEscapeCallback()", 30, false);
end

function Swift:ExecuteEscapeCallback()
    -- Global
    API.BroadcastScriptEventToGlobal(
        QSB.ScriptEvents.EscapePressed,
        GUI.GetPlayerID()
    )
    -- Local
    Swift:DispatchScriptEvent(QSB.ScriptEvents.EscapePressed, GUI.GetPlayerID());
end

-- Geologist Refill Callback

function Swift:OverwriteGeologistRefill()
    if Framework.GetGameExtraNo() >= 1 then
        GameCallback_OnGeologistRefill_Orig_QSB_SwiftCore = GameCallback_OnGeologistRefill;
        GameCallback_OnGeologistRefill = function(_PlayerID, _TargetID, _GeologistID)
            GameCallback_OnGeologistRefill_Orig_QSB_SwiftCore(_PlayerID, _TargetID, _GeologistID);
            if QSB.RefillAmounts[_TargetID] then
                local RefillAmount = QSB.RefillAmounts[_TargetID];
                local RefillRandom = RefillAmount + math.random(1, math.floor((RefillAmount * 0.2) + 0.5));
                Logic.SetResourceDoodadGoodAmount(_TargetID, RefillRandom);
                if RefillRandom > 0 then
                    if Logic.GetResourceDoodadGoodType(_TargetID) == Goods.G_Iron then
                        Logic.SetModel(_TargetID, Models.Doodads_D_SE_ResourceIron);
                    else
                        Logic.SetModel(_TargetID, Models.R_ResorceStone_Scaffold);
                    end
                end
            end
        end
    end
end

-- Soldier Payment Callback

function Swift:OverrideSoldierPayment()
    GameCallback_SetSoldierPaymentLevel_Orig = GameCallback_SetSoldierPaymentLevel;
    GameCallback_SetSoldierPaymentLevel = function(_PlayerID, _Level)
        if _Level <= 2 then
            return GameCallback_SetSoldierPaymentLevel_Orig(_PlayerID, _Level);
        end
        Swift:ProcessScriptCommand(_PlayerID, _Level);
    end
end

