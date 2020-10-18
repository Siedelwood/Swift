-- Interface -------------------------------------------------------------------

Core.Data.Interface = {
    ChatOptionsWasShown = false,
    MessageLogWasShown = false,
    PauseScreenShown = false,
    NormalModeHidden = false,
}

---
-- Zeigt den Pausebildschirm als schwarzen Hintergrund an. Wurde dieser schon
-- eingeblendet, macht die Funktion nichts.
-- @within Internal
-- @local
--
function Core:InterfaceActivateBlackBackground()
    if self.Data.Interface.PauseScreenShown then
        return;
    end
    self.Data.Interface.PauseScreenShown = true;

    XGUIEng.PushPage("/InGame/Root/Normal/PauseScreen", false)
    XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 1);
    XGUIEng.SetMaterialColor("/InGame/Root/Normal/PauseScreen", 0, 0, 0, 0, 255);
end

---
-- Blendet den Pausebildschirm aus und stellt Farbe und Transparenz wieder her.
-- Wurde dieser schon deaktiviert, macht die Funktion nichts.
-- @within Internal
-- @local
--
function Core:InterfaceDeactivateBlackBackground()
    if not self.Data.Interface.PauseScreenShown then
        return;
    end
    self.Data.Interface.PauseScreenShown = false;

    XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 0);
    XGUIEng.SetMaterialColor("/InGame/Root/Normal/PauseScreen", 0, 40, 40, 40, 180);
    XGUIEng.PopPage();
end

---
-- Blendet das normale Interface aus. Wurde das Interface schon ausgeblentet,
-- macht die Funktion nichts.
-- @within Internal
-- @local
--
function Core:InterfaceDeactivateNormalInterface()
    if self.Data.Interface.NormalModeHidden then
        return;
    end
    self.Data.Interface.NormalModeHidden = true;

    XGUIEng.PushPage("/InGame/Root/Normal/NotesWindow", false);
    XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/TextMessages", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/SpeechStartAgainOrStop", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/BuildMenu", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/MapFrame", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopRight", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/UpdateFunction", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/Buttons", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/QuestLogButton", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/QuestTimers", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Merchant", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/MissionGoodOrEntityCounter", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/MissionTimer", 0);
    HideOtherMenus();
    if XGUIEng.IsWidgetShownEx("/InGame/Root/Normal/ChatOptions/Background") == 1 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions", 0);
        self.Data.Interface.ChatOptionsWasShown = true;
    end
    if XGUIEng.IsWidgetShownEx("/InGame/Root/Normal/MessageLog/Name") == 1 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog", 0);
        self.Data.Interface.MessageLogWasShown = true;
    end
    if g_GameExtraNo > 0 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Tradepost", 0);
    end
end

---
-- Blendet das normale Interface ein. Wurde das Interface schon eingeblentet,
-- macht die Funktion nichts.
-- @within Internal
-- @local
--
function Core:InterfaceActivateNormalInterface()
    if not self.Data.Interface.NormalModeHidden then
        return;
    end
    self.Data.Interface.NormalModeHidden = false;

    XGUIEng.ShowWidget("/InGame/Root/Normal", 1);
    XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/SpeechStartAgainOrStop", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/BuildMenu", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/MapFrame", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopRight", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/UpdateFunction", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/Buttons", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/QuestLogButton", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/QuestTimers", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Merchant", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message", 1);
    XGUIEng.PopPage();
    
    -- Debug Clock
    if AddOnQuestDebug and AddOnQuestDebug.Local.Data.GameClock then
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock", 1);
    end
    -- Timer
    if g_MissionTimerEndTime then
        XGUIEng.ShowWidget("/InGame/Root/Normal/MissionTimer", 1);
    end
    -- Counter
    if g_MissionGoodOrEntityCounterAmountToReach then
        XGUIEng.ShowWidget("/InGame/Root/Normal/MissionGoodOrEntityCounter", 1);
    end
    -- Chat Options
    if self.Data.Interface.ChatOptionsWasShown then
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions", 1);
        self.Data.Interface.ChatOptionsWasShown = false;
    end
    -- Message Log
    if self.Data.Interface.MessageLogWasShown then
        XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog", 1);
        self.Data.Interface.MessageLogWasShown = false;
    end
    -- Handelsposten
    if g_GameExtraNo > 0 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Tradepost", 1);
    end
end

