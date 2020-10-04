-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnLanguageSelection                                       # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Ermöglicht dem Spieler zu Beginn der Map eine von mehreren Sprachen
-- auszuwählen. Hinterlegte Texte werden automatisch in der ausgewählten
-- Sprache angezeigt.
--
-- <b>Achtung:</b> Du musst für alle Sprachen selbst Texte hinterlegen!
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnLanguageSelection = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Aktiviert die Sprachauswahl mit den zuvor eingestellten Sprachen.
--
-- <b>Achtung:</b> Du musst für alle Sprachen, die du eingestellt hast, auch
-- Texte schreiben. Außerdem sind für die meisten Features er QSB nur Deutsch
-- und Englisch vorgesehen, weshalb du außer Briefings, Nachrichten und Quests
-- keine anderen Sprachen als Deutsch und Englisch verwenden kannst.
--
-- Quests dürfen erst erstellt werden, sobald der Spieler den Dialog
-- bestätigt. Nach Bestätigung des Dialogs wird Mission_OnLanguageChanged im
-- globalen und lokalen Skript aufgerufen.
--
-- @within Anwenderfunktionen
--
-- @usage API.LanguageSelectionShow();
--
function API.LanguageSelectionShow()
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.LanguageSelectionShow()");
        return;
    end
    AddOnLanguageSelection.Local:StartSelection();
end

---
-- Löscht die Liste der voreingestellten Sprachen.
--
-- @within Anwenderfunktionen
--
-- @usage API.LanguageSelectionClear();
--
function API.LanguageSelectionClear()
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.LanguageSelectionClear()");
        return;
    end
    AddOnLanguageSelection.Local.Text.Languages = {};
    AddOnLanguageSelection.Local.Data.Languages = {};
end

---
-- Fügt der Liste der Sprachen eine weitere Sprache hinzu.
--
-- @param[type=string] _Short Kurzbezeichnung der Sprache (de, en, fr, ...)
-- @param[type=string] _Name  Anzeigename der Sprache
-- @within Anwenderfunktionen
--
-- @usage API.LanguageSelectionAdd("fr", "Français");
--
function API.LanguageSelectionAdd(_Short, _Name)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.LanguageSelectionAdd("%s", "%s")]],
            _Short,
            _Name
        ));
        return;
    end
    table.insert(AddOnLanguageSelection.Local.Text.Languages, _Name);
    table.insert(AddOnLanguageSelection.Local.Data.Languages, _Short);
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnLanguageSelection = {
    Global = {
        Data = {
            LanguageSelected = false,
        }
    },
    Local = {
        Data = {
            Languages = {"de", "en",},
            LanguageSelected = false,
            DesiredLanguage = 2,
        },
        Text = {
            Languages = {"Deutsch", "English"},
            Dialog = {
                Title = {
                    de = "Sprache wählen",
                    en = "Select language",
                },
                Text = {
                    de = "Wähle die Sprache aus, in der die Handlung erzählt werden soll.",
                    en = "Choose the language in which the story should be told.",
                }
            }
        }
    },
}

-- Global ------------------------------------------------------------------- --

---
-- Initialisiert das Addon.
-- @within Internal
-- @local
--
function AddOnLanguageSelection.Global:Install()
end

---
-- Wird aufgerufen, wenn der Spieler eine Sprache ausgewählt hat.
-- @param[type=string] _Language Ausgewählte Sprache
-- @within Internal
-- @local
--
function AddOnLanguageSelection.Global:LanguageSelectionFinished(_Language)
    QSB.Language = _Language;
    if Mission_OnLanguageChanged then
        Mission_OnLanguageChanged(_Language);
    end
    AddOnLanguageSelection.Global.Data.LanguageSelected = true;
end

-- Local -------------------------------------------------------------------- --

---
-- Initialisiert das Addon.
-- @within Internal
-- @local
--
function AddOnLanguageSelection.Local:Install()
end

---
-- Ermittelt die bevorzugte Sprache aus der Liste der voreingestellten Sprachen.
-- @within Internal
-- @local
--
function AddOnLanguageSelection.Local:GetDesiredLanguage()
    for i= 1, #self.Data.Languages, 1 do
        if QSB.Language == self.Data.Languages[i] then
            self.Data.DesiredLanguage = i;
        end
    end
end

---
-- Zeigt den Auswahldialog für die Sprache an.
-- @within Internal
-- @local
--
function AddOnLanguageSelection.Local:StartSelection()
    StartSimpleHiResJobEx(function()
        if not API.IsLoadscreenVisible() then
            if self.Data.LanguageSelected then
                return;
            end
            
            self:StartCinematicMode();
            self:GetDesiredLanguage();

            API.DialogSelectBox(
                self.Text.Dialog.Title,
                self.Text.Dialog.Text,
                function(_Index)
                    Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
                    local lang = AddOnLanguageSelection.Local.Data.Languages[_Index];
                    GUI.SendScriptCommand(string.format([[
                        AddOnLanguageSelection.Global:LanguageSelectionFinished("%s");
                    ]], lang))
                    self:StopCinematicMode();
                    QSB.Language = lang;
                    if Mission_OnLanguageChanged then
                        Mission_OnLanguageChanged(lang);
                    end
                    AddOnLanguageSelection.Local.Data.LanguageSelected = true;
                end,
                self.Text.Languages
            );
            Game.GameTimeSetFactor(GUI.GetPlayerID(), 0);
            return true;
        end
    end);
end

function AddOnLanguageSelection.Local:StartCinematicMode()
    if BundleBriefingSystem then
        BundleBriefingSystem.Local.Data.BriefingActive = true;
        GUI.SendScriptCommand("BundleBriefingSystem.Global.Data.BriefingActive = true");
    end
    
end

function AddOnLanguageSelection.Local:StopCinematicMode()
    if BundleBriefingSystem then
        BundleBriefingSystem.Local.Data.BriefingActive = false;
        GUI.SendScriptCommand("BundleBriefingSystem.Global.Data.BriefingActive = false");
    end

end

-- -------------------------------------------------------------------------- --

Core:RegisterAddOn("AddOnLanguageSelection");

