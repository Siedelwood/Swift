-- Main ------------------------------------------------------------------------

-- API Stuff --

---
-- Initialisiert alle verfügbaren Bundles und führt ihre Install-Methode aus.
--
-- Bundles werden immer getrennt im globalen und im lokalen Skript gestartet.
-- Diese Funktion muss zwingend im globalen und lokalen Skript ausgeführt
-- werden, bevor die QSB verwendet werden kann.
--
-- @within Anwenderfunktionen
--
function API.Install()
    Core:InitalizeBundles();
end

-- Core Stuff --

Core.Data.BundleInitializerList = {};
Core.Data.InitalizedBundles = {};

---
-- Initialisiert alle verfügbaren Bundles und führt ihre Install-Methode aus.
-- Bundles werden immer getrennt im globalen und im lokalen Skript gestartet.
-- @within Internal
-- @local
--
function Core:InitalizeBundles()
    if not QSB.InitializationFinished then
        -- Initialisierung
        if not GUI then
            QSB.Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";

            self:OverwriteBasePricesAndRefreshRates();
            self:CreateRandomSeedBySystemTime();
            self:SetupGobal_HackCreateQuest();
            self:SetupGlobal_HackQuestSystem();
            self:IdentifyHistoryEdition();

            Trigger.RequestTrigger(Events.LOGIC_EVENT_DIPLOMACY_CHANGED, "", "CoreEventJob_OnDiplomacyChanged", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "CoreEventJob_OnEntityCreated", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "CoreEventJob_OnEntityDestroyed", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "CoreEventJob_OnEntityHurtEntity", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY, "", "CoreEventJob_OnEntityInRangeOfEntity", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "CoreEventJob_OnEverySecond", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "CoreEventJob_OnEveryTurn", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_GOODS_TRADED, "", "CoreEventJob_OnGoodsTraded", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_PLAYER_DIED, "", "CoreEventJob_OnPlayerDied", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_RESEARCH_DONE, "", "CoreEventJob_OnResearchDone", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_TRIBUTE_PAID, "", "CoreEventJob_OnTributePaied", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_WEATHER_STATE_CHANGED, "", "CoreEventJob_OnWatherChanged", 1);
            
            StartSimpleJobEx(Core.EventJob_EventOnEveryRealTimeSecond);
        else
            QSB.Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";

            self:CreateRandomSeedBySystemTime();
            self:SetupLocal_HackRegisterHotkey();
            self:SetupLocal_HistoryEditionAutoSave();

            Trigger.RequestTrigger(Events.LOGIC_EVENT_DIPLOMACY_CHANGED, "", "CoreEventJob_OnDiplomacyChanged", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "CoreEventJob_OnEntityCreated", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "CoreEventJob_OnEntityDestroyed", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "CoreEventJob_OnEntityHurtEntity", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY, "", "CoreEventJob_OnEntityInRangeOfEntity", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "CoreEventJob_OnEverySecond", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "CoreEventJob_OnEveryTurn", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_GOODS_TRADED, "", "CoreEventJob_OnGoodsTraded", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_PLAYER_DIED, "", "CoreEventJob_OnPlayerDied", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_RESEARCH_DONE, "", "CoreEventJob_OnResearchDone", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_TRIBUTE_PAID, "", "CoreEventJob_OnTributePaied", 1); 
            Trigger.RequestTrigger(Events.LOGIC_EVENT_WEATHER_STATE_CHANGED, "", "CoreEventJob_OnWatherChanged", 1);

            StartSimpleJobEx(Core.EventJob_EventOnEveryRealTimeSecond);
            StartSimpleHiResJobEx(Core.EventJob_WaitForLoadScreenHidden);
        end

        -- Aufruf der Module
        for k,v in pairs(self.Data.BundleInitializerList) do
            local Bundle = _G[v];
            if not GUI then
                if Bundle.Global ~= nil and Bundle.Global.Install ~= nil then
                    Bundle.Global:Install();
                    Bundle.Local = nil;
                end
            else
                if Bundle.Local ~= nil and Bundle.Local.Install ~= nil then
                    Bundle.Local:Install();
                    Bundle.Global = nil;
                end
            end
            self.Data.InitalizedBundles[v] = true;
            collectgarbage();
        end
        QSB.InitializationFinished = true;
    end
end

---
-- Fügt fehlende Einträge für Militäreinheiten bei den Basispreisen
-- und Erneuerungsraten hinzu, damit diese gehandelt werden können.
-- @within Internal
-- @local
--
function Core:OverwriteBasePricesAndRefreshRates()
    MerchantSystem.BasePrices[Entities.U_CatapultCart] = MerchantSystem.BasePrices[Entities.U_CatapultCart] or 1000;
    MerchantSystem.BasePrices[Entities.U_BatteringRamCart] = MerchantSystem.BasePrices[Entities.U_BatteringRamCart] or 450;
    MerchantSystem.BasePrices[Entities.U_SiegeTowerCart] = MerchantSystem.BasePrices[Entities.U_SiegeTowerCart] or 600;
    MerchantSystem.BasePrices[Entities.U_AmmunitionCart] = MerchantSystem.BasePrices[Entities.U_AmmunitionCart] or 180;
    MerchantSystem.BasePrices[Entities.U_MilitarySword_RedPrince] = MerchantSystem.BasePrices[Entities.U_MilitarySword_RedPrince] or 150;
    MerchantSystem.BasePrices[Entities.U_MilitarySword] = MerchantSystem.BasePrices[Entities.U_MilitarySword] or 150;
    MerchantSystem.BasePrices[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.BasePrices[Entities.U_MilitaryBow_RedPrince] or 220;
    MerchantSystem.BasePrices[Entities.U_MilitaryBow] = MerchantSystem.BasePrices[Entities.U_MilitaryBow] or 220;

    MerchantSystem.RefreshRates[Entities.U_CatapultCart] = MerchantSystem.RefreshRates[Entities.U_CatapultCart] or 270;
    MerchantSystem.RefreshRates[Entities.U_BatteringRamCart] = MerchantSystem.RefreshRates[Entities.U_BatteringRamCart] or 190;
    MerchantSystem.RefreshRates[Entities.U_SiegeTowerCart] = MerchantSystem.RefreshRates[Entities.U_SiegeTowerCart] or 220;
    MerchantSystem.RefreshRates[Entities.U_AmmunitionCart] = MerchantSystem.RefreshRates[Entities.U_AmmunitionCart] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.RefreshRates[Entities.U_MilitarySword_RedPrince] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitarySword] = MerchantSystem.RefreshRates[Entities.U_MilitarySword] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow] or 150;

    if g_GameExtraNo >= 1 then
        MerchantSystem.BasePrices[Entities.U_MilitaryBow_Khana] = MerchantSystem.BasePrices[Entities.U_MilitaryBow_Khana] or 220;
        MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] or 150;
        MerchantSystem.BasePrices[Entities.U_MilitarySword_Khana] = MerchantSystem.BasePrices[Entities.U_MilitarySword_Khana] or 150;
        MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] = MerchantSystem.RefreshRates[Entities.U_MilitarySword_Khana] or 150;
    end
end

---
-- Überschreibt CreateQuest für die Anbindung an Symfonia.
-- @within Internal
-- @local
--
function Core:SetupGobal_HackCreateQuest()
    CreateQuest = function(_QuestName, _QuestGiver, _QuestReceiver, _QuestHidden, _QuestTime, _QuestDescription, _QuestStartMsg, _QuestSuccessMsg, _QuestFailureMsg)
        local Triggers = {};
        local Goals = {};
        local Reward = {};
        local Reprisal = {};
        local NumberOfBehavior = Logic.Quest_GetQuestNumberOfBehaviors(_QuestName);

        for i=0, NumberOfBehavior-1, 1 do
            -- Behavior ermitteln
            local BehaviorName = Logic.Quest_GetQuestBehaviorName(_QuestName, i);
            local BehaviorTemplate = GetBehaviorTemplateByName(BehaviorName);
            assert( BehaviorTemplate, "No template for name: " .. BehaviorName .. " - using an invalid QuestSystemBehavior.lua?!");
            local NewBehavior = {};
            Table_Copy(NewBehavior, BehaviorTemplate);
            local Parameter = Logic.Quest_GetQuestBehaviorParameter(_QuestName, i);
            for j=1,#Parameter do
                NewBehavior:AddParameter(j-1, Parameter[j]);
            end

            -- Füge als Goal hinzu
            if (NewBehavior.GetGoalTable ~= nil) then
                Goals[#Goals + 1] = NewBehavior:GetGoalTable();
                Goals[#Goals].Context = NewBehavior;
                Goals[#Goals].FuncOverrideIcon = NewBehavior.GetIcon;
                Goals[#Goals].FuncOverrideMsgKey = NewBehavior.GetMsgKey;
            end
            -- Füge als Trigger hinzu
            if (NewBehavior.GetTriggerTable ~= nil) then
                Triggers[#Triggers + 1] = NewBehavior:GetTriggerTable();
            end
            -- Füge als Reprisal hinzu
            if (NewBehavior.GetReprisalTable ~= nil) then
                Reprisal[#Reprisal + 1] = NewBehavior:GetReprisalTable();
            end
            -- Füge als Reward hinzu
            if (NewBehavior.GetRewardTable ~= nil) then
                Reward[#Reward + 1] = NewBehavior:GetRewardTable();
            end
        end

        -- Prüfe Mindestkonfiguration des Quest
        if (#Triggers == 0) or (#Goals == 0) then
            return;
        end

        -- Erzeuge den Quest
        if Core:CheckQuestName(_QuestName) then
            local QuestID = QuestTemplate:New(
                _QuestName,
                _QuestGiver or 1,
                _QuestReceiver or 1,
                Goals,
                Triggers,
                tonumber(_QuestTime) or 0,
                Reward,
                Reprisal,
                nil, nil,
                (not _QuestHidden or ( _QuestStartMsg and _QuestStartMsg ~= "") ),
                (not _QuestHidden or ( _QuestSuccessMsg and _QuestSuccessMsg ~= "") or ( _QuestFailureMsg and _QuestFailureMsg ~= "") ),
                _QuestDescription,
                _QuestStartMsg,
                _QuestSuccessMsg,
                _QuestFailureMsg
            );
            g_QuestNameToID[_QuestName] = QuestID;
        else
            Core:LogToFile("Quest '"..tostring(_QuestName).."': invalid questname! Contains forbidden characters!", LEVEL_ERROR);
            Core:LogToScreen("Quest '"..tostring(_QuestName).."': invalid questname! Contains forbidden characters!", LEVEL_ERROR);
        end
    end
end

---
-- Implementiert die vordefinierten Texte für Custom Behavior und den Aufruf
-- der :Interrupt Methode.
-- @within Internal
-- @local
--
function Core:SetupGlobal_HackQuestSystem()
    QuestTemplate.Trigger_Orig_QSB_Core = QuestTemplate.Trigger
    QuestTemplate.Trigger = function(_quest)
        QuestTemplate.Trigger_Orig_QSB_Core(_quest);
        for i=1,_quest.Objectives[0] do
            if _quest.Objectives[i].Type == Objective.Custom2 and _quest.Objectives[i].Data[1].SetDescriptionOverwrite then
                local Desc = _quest.Objectives[i].Data[1]:SetDescriptionOverwrite(_quest);
                Core:ChangeCustomQuestCaptionText(Desc, _quest);
                break;
            end
        end
    end

    QuestTemplate.Interrupt_Orig_QSB_Core = QuestTemplate.Interrupt;
    QuestTemplate.Interrupt = function(_quest)
        QuestTemplate.Interrupt_Orig_QSB_Core(_quest);
        for i=1, _quest.Objectives[0] do
            if _quest.Objectives[i].Type == Objective.Custom2 and _quest.Objectives[i].Data[1].Interrupt then
                _quest.Objectives[i].Data[1]:Interrupt(_quest, i);
            end
        end
        for i=1, _quest.Triggers[0] do
            if _quest.Triggers[i].Type == Triggers.Custom2 and _quest.Triggers[i].Data[1].Interrupt then
                _quest.Triggers[i].Data[1]:Interrupt(_quest, i);
            end
        end
    end
end

---
-- Prüft, ob das Spiel gerade gespeichert werden kann.
--
-- @return [boolean]  Speichern ist möglich
-- @within Internal
-- @local
--
function Core:CanGameBeSaved()
    -- Briefing ist aktiv
    if IsBriefingActive and IsBriefingActive() then
        return false;
    end
    -- Cutscene ist aktiv
    if IsCutsceneActive and IsCutsceneActive() then
        return false;
    end
    -- Die Map wird noch geladen
    if GUI and XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") ~= 0 then
        return false;
    end
    return true;
end

---
-- Prüft, ob das Bundle bereits initalisiert ist.
--
-- @param[type=string] _Bundle Name des Moduls
-- @return[type=boolean] Bundle initalisiert
-- @within Internal
-- @local
--
function Core:IsBundleRegistered(_Bundle)
    return self.Data.InitalizedBundles[_Bundle] == true;
end

---
-- Registiert ein Bundle, sodass es initialisiert wird.
--
-- @param[type=string] _Bundle Name des Moduls
-- @within Internal
-- @local
--
function Core:RegisterBundle(_Bundle)
    local text = string.format("Error while initialize bundle '%s': does not exist!", tostring(_Bundle));
    assert(_G[_Bundle] ~= nil, text);
    table.insert(self.Data.BundleInitializerList, _Bundle);
end

---
-- Registiert ein AddOn als Bundle, sodass es initialisiert wird.
--
-- Diese Funktion macht prinziplell das Gleiche wie Core:RegisterBundle und
-- existiert nur zur Übersichtlichkeit.
--
-- @param[type=string] _AddOn Name des Moduls
-- @within Internal
-- @local
--
function Core:RegisterAddOn(_AddOn)
    local text = string.format("Error while initialize addon '%s': does not exist!", tostring(_AddOn));
    assert(_G[_AddOn] ~= nil, text);
    table.insert(self.Data.BundleInitializerList, _AddOn);
end

---
-- Bereitet ein Behavior für den Einsatz im Assistenten und im Skript vor.
-- Erzeugt zudem den Konstruktor.
--
-- @param[type=table] _Behavior Behavior-Objekt
-- @within Internal
-- @local
--
function Core:RegisterBehavior(_Behavior)
    if GUI then
        return;
    end
    if _Behavior.RequiresExtraNo and _Behavior.RequiresExtraNo > g_GameExtraNo then
        return;
    end

    if not _G["b_" .. _Behavior.Name] then
        --self:LogToFile("AddQuestBehavior: can not find ".. _Behavior.Name .."!", LEVEL_ERROR);
        --self:LogToScreen("AddQuestBehavior: can not find ".. _Behavior.Name .."!", LEVEL_ERROR);
        Logic.ExecuteInLuaLocalState("GUI.AddStaticNote('" ..tostring(_Behavior.Name).. "')");
    else
        if not _G["b_" .. _Behavior.Name].new then
            _G["b_" .. _Behavior.Name].new = function(self, ...)
                local arg = {...}; -- Notwendiger Fix für LuaJ
                local behavior = API.InstanceTable(self);
                behavior.i47ya_6aghw_frxil = {};
                behavior.v12ya_gg56h_al125 = {};
                for i= 1, #arg, 1 do
                    table.insert(behavior.v12ya_gg56h_al125, arg[i]);
                    if self.Parameter and self.Parameter[i] ~= nil then
                        behavior:AddParameter(i-1, arg[i]);
                    else
                        table.insert(behavior.i47ya_6aghw_frxil, arg[i]);
                    end
                end
                return behavior;
            end
        end

        for i= 1, #g_QuestBehaviorTypes, 1 do
            if g_QuestBehaviorTypes[i].Name == _Behavior.Name then
                return;
            end
        end
        table.insert(g_QuestBehaviorTypes, _Behavior);
    end
end

---
-- Wandelt underschiedliche Darstellungen einer Boolean in eine echte um.
--
-- Jeder String, der mit j, t, y oder + beginnt, wird als true interpretiert.
-- Alles andere als false.
--
-- Ist die Eingabe bereits ein Boolean wird es direkt zurückgegeben.
--
-- @param[type=string] _Input Boolean-Darstellung
-- @return[type=boolean] Konvertierte Boolean
-- @within Internal
-- @local
--
function Core:ToBoolean(_Input)
    if type(_Input) == "boolean" then
        return _Input;
    end
    if string.find(string.lower(tostring(_Input)), "^[tjy\\+].*$") then
        return true;
    end
    return false;
end

---
-- Setzt den Random Seed für die Erzeugung von Zufallszahlen anhand der
-- aktuellen Systemzeit.
--
-- @return[type=number] Random Seed
-- @within Internal
-- @local
--
function Core:CreateRandomSeedBySystemTime()
    local DateTimeString = Framework.GetSystemTimeDateString();

    local s, e = DateTimeString:find(" ");
    local TimeString = DateTimeString:sub(e+2, DateTimeString:len()-1):gsub("'", "");
    TimeString = "1" ..TimeString;

    local RandomSeed = tonumber(TimeString);
    math.randomseed(RandomSeed);
    return RandomSeed;
end

