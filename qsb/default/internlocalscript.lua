-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Intern Local Script                                                    # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Einfach alles so lassen, wie es ist!

-- Reference to global table
GlobalMissionScript = Logic.CreateReferenceToTableInGlobaLuaState("GlobalMissionScript");

function Mission_LocalVictory()
    if OnMissionVictory then
        OnMissionVictory();
    end
end

function Mission_LocalOnMapStart()
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
    Script.Load(g_ContentPath.. "knighttitlerequirments.lua");

    API.Install();
    InitKnightTitleTables();
    if GlobalMissionScript.UseCredits then
        Mission_LocalShowCredits();
    end
    if InitMissionScript then
        InitMissionScript();
    end
    if FirstMapAction then
        FirstMapAction();
    end
end

function Mission_LocalShowCredits()
    Camera.RTS_FollowEntity(GetID(GlobalMissionScript.CreditsLookAt));
    Mission_LocalDisplayUI(0);

    StartSimpleJobEx( function()
        if  XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 0 then
            local CreditsFinished = function()
                API.Bridge("GlobalMissionScript.CreditsFinished = true");
                Camera.RTS_FollowEntity(0);
                if OnCreditsFinished then
                    OnCreditsFinished();
                end
            end

            local Text = {
                de = "Siedelwood präsentiert: {cr}{cr}{@color:94,38,33,255}" 
                     ..GlobalMissionScript.CreditsMapName.. "{cr}{cr}" ..
                     "{@color:56,73,37,255} Mehr auf www.siedelwood-neu.de!",
                en = "Siedelwood presents: {cr}{cr}{@color:94,38,33,255}" 
                     ..GlobalMissionScript.CreditsMapName.. "{cr}{cr}" ..
                     "{@color:56,73,37,255} more at www.siedelwood-neu.de!",
            }
            API.DialogInfoBox("Credits", Text);

            local Text = {
                de = "Autor: " ..GlobalMissionScript.CreditsMapAuthor.. 
                    "{cr}Tester: " ..GlobalMissionScript.CreditsMapTester..
                    "{cr}{cr}{@color:56,73,37,255}Ihnen gilt unser Dank!",
                en = "Author: " ..GlobalMissionScript.CreditsMapAuthor..
                    "{cr}Testers: " ..GlobalMissionScript.CreditsMapTester..
                    "{cr}{cr}{@color:56,73,37,255}They earned our thanks!",
            }
            API.DialogInfoBox("Credits", Text, CreditsFinished);

            return true;
        end
    end);
end

function Mission_LocalDisplayUI(_Flag)
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight", _Flag)
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft", _Flag)
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft", _Flag)
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar", _Flag)
    XGUIEng.ShowWidget("/InGame/Root/Normal/InteractiveObjects", _Flag)
    XGUIEng.ShowWidget("/InGame/Root/Normal/InteractiveObjects/Update", _Flag)
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopRight", _Flag)
    XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Merchant", _Flag)
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopCenter", _Flag)
    if g_PatchIdentifierExtra1 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Tradepost", _Flag)
    end
    XGUIEng.ShowWidget("/InGame/Root/Normal/TextMessages", _Flag)
    XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", _Flag)
    XGUIEng.ShowWidget("/InGame/Root/Normal/ShowUi", _Flag)
    XGUIEng.ShowWidget("/InGame/Root/3dWorldView", _Flag)
end
