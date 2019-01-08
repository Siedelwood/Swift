-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Local Script - <MAPNAME>                                               # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

-- Trage hier den Pfad ein, under dem deine Lua-Dateien liegen. Kommentiere
-- die Originalzeile am besten nur aus. Vergiss nicht, später den alten Pfad
-- wiederherzustellen, wenn die Map live geht.
g_ContentPath = "maps/externalmap/" ..Framework.GetCurrentMapName() .. "/";

-- Auf true setzen, um Credits zu aktivieren.
g_MapUseCredits = false;

-- Trage hier die Daten Deiner Map ein.
-- Kartenname, Autor und die Tester werden dann automatisch als Vorspann
-- vor dem Start angezeigt. Du kannst außerdem die Kameraposition setzen.
g_CreditsMapName = "A Siedelwood Map";
g_CreditsMapAuthor = "Author";
g_CreditsMapTester = "Tester1, Tester2, Tester3";
g_CreditsLookAt = Logic.GetHeadquarters(1);

-- Diese Funktion wird von den Credits aufgerufen, wen sie zu Ende sind.
function Mission_CreditsFinished()

end

-- Wird aufgerufen, sobald die Map initialisiert ist.
function Mission_SecondMapAction()

end

-- -------------------------------------------------------------------------- --

-- Deine Funktionen

-- -------------------------------------------------------------------------- --

-- Ab hier NICHTS mehr ändern!

function Mission_LocalVictory()
end

function Mission_LocalOnMapStart()
    Script.Load(g_ContentPath.. "questsystembehavior.lua");
    Script.Load(g_ContentPath.. "knighttitlerequirments.lua");

    API.Install();
    InitKnightTitleTables();
    if g_MapUseCredits then
        Mission_LocalShowCredits();
    end
    Mission_SecondMapAction();
end

function Mission_LocalShowCredits()
    Camera.RTS_FollowEntity(GetID(g_CreditsLookAt));
    Mission_LocalDisplayUI(0);

    StartSimpleJobEx( function()
        if  XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 0 then
            local CreditsFinished = function()
                API.Bridge("g_CreditsBoxesFinished = true");
                Camera.RTS_FollowEntity(0);
                Mission_CreditsFinished();
            end

            local Text = {
                de = "Siedelwood präsentiert: {cr}{cr}{@color:19,65,36}" 
                     ..g_CreditsMapName,
                en = "Siedelwood presents: {cr}{cr}{@color:19,65,36}" 
                     ..g_CreditsMapName,
            }
            API.DialogInfoBox("Credits", Text);

            local Text = {
                de = "Autor: " ..g_CreditsMapAuthor.. 
                    "{cr}Tester: " ..g_CreditsMapTester.. ""..
                    "{cr}{cr}{@color:19,65,36}Ihnen gilt unser Dank!",
                en = "Author: " ..g_CreditsMapAuthor..
                    "{cr}Testers: " ..g_CreditsMapTester.. ""..
                    "{cr}{cr}{@color:19,65,36}They earned our thanks!",
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
