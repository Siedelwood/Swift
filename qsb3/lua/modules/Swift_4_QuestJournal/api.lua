-- Quests API-- ------------------------------------------------------------- --

---
-- Erlaubt es Notizen zu einem Quest hinzuzufügen.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_DisplayCore.api.html">(1) Display Core</a></li>
-- <li><a href="Swift_1_InputOutputCore.api.html">(1) Input/Output Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Aktiviert oder Deaktiviert die Verfügbarkeit der Zusatzinformationen für den
-- übergebenen Quest.
--
-- <b>Hinweis</b>: Die Sichtbarkeit der Zusatzinformationen für einzelne Quests
-- ist generell deaktiviert und muss explizit aktiviert werden.
--
-- @param[type=string]  _Quest Name des Quest
-- @param[type=boolean] _Flag  Zusatzinfos aktivieren
-- @within Anwenderfunktionen
--
-- @usage
-- -- Deaktivieren
-- API.SetQuestNoteEnabled("MyQuest", false);
-- -- Aktivieren
-- API.SetQuestNoteEnabled("MyQuest", true);
--
function API.SetQuestNoteEnabled(_Quest, _Flag)
    if GUI then
        return;
    end
    local Quest = Quests[GetQuestID(_Quest)];
    if Quest then
        Quest.QuestNotes = _Flag == true;
    end
end

---
-- Fugt eine Zusatzinformation für diesen Quests hinzu.
--
-- <b>Hinweis</b>: Die erzeugte ID ist immer eindeutig für alle Einträge,
-- ungeachtet ob sie einem Quest zugeordnet sind oder nicht.
--
-- <b>Hinweis</b>: Der Questname kann durch nil ersetzt werden. In diesem Fall
-- erscheint der Eintrag bei <i>allen</i> Quests (für die das Feature aktiviert
-- ist). Und das so lange, bis er wieder gelöscht wird.
--
-- <b>Hinweis</b>: Formatierungsbefehle sind deaktiviert.
--
-- @param[type=string] _Quest Questname
-- @param              _Text  Text der Zusatzinfo
-- @return[type=number] ID des neuen Eintrags
-- @within Anwenderfunktionen
--
-- @usage
-- local NewEntryID = API.AddQuestNote("MyQuest", "Wichtige Information zum Anzeigen");
--
function API.AddQuestNote(_Quest, _Text)
    _Text = _Text:gsub("\\{.*\\}", "");
    return ModuleQuestJournal.Global:AddQuestNote(_Quest, 0, _Text);
end

---
-- Ändert den Text einer Zusatzinformation.
--
-- <b>Hinweis</b>: Der neue Text bezieht sich auf den Eintrag mit der ID. Ist
-- der Eintrag für alle Quests sichtbar, wird er in allen Quests geändert.
-- Kopien eines Eintrags werden nicht berücksichtigt.
--
-- <b>Hinweis</b>: Formatierungsbefehle sind deaktiviert.
--
-- @param[type=number] _ID   ID des Eintrag
-- @param              _Text Neuer Text
-- @within Anwenderfunktionen
--
-- @usage
-- API.AlterQuestNoteEntry(SomeEntryID, "Das ist der neue Text.");
--
function API.AlterQuestNoteEntry(_ID, _Text)
    _Text = _Text:gsub("\\{.*\\}", "");
    for i= #ModuleQuestJournal.Global.Journal, 1, -1 do
        if ModuleQuestJournal.Global.Journal[i].ID == _ID then
            ModuleQuestJournal.Global.Journal[i][1] = _Text;
            return;
        end
    end
end

---
-- Hebt einen Eintrag aus den Zusatzinformationen als wichtig hervor oder
-- setzt ihn zurück.
--
-- <b>Hinweis</b>: Wichtige Einträge erscheinen immer als erstes und sind durch
-- rote Färbung hervorgehoben. Eigene Farben in einer Nachricht beeinträchtigen
-- die rote hervorhebung.
--
-- @param[type=number]  _ID        ID des Eintrag
-- @param[type=boolean] _Important Wichtig Markierung
-- @within Anwenderfunktionen
--
-- @usage
-- API.HighlightQuestNoteEntry(SomeEntryID, true);
--
function API.HighlightQuestNoteEntry(_ID, _Important)
    for i= #ModuleQuestJournal.Global.Journal, 1, -1 do
        if ModuleQuestJournal.Global.Journal[i].ID == _ID then
            ModuleQuestJournal.Global.Journal[i].Rank = (_Important == true and 1) or 0;
            return;
        end
    end
end

---
-- Kopiert einen Eintrag als neuen Eintrag in einen anderen Quest.
--
-- <b>Hinweis</b>: Wenn Ursprungs-Quest und Ziel-Quest identisch sind, wird der
-- Befehl ignoriert und die zurückgegebene ID ist -1.
--
-- @param[type=number] _ID    ID des Eintrag
-- @param[type=string] _Quest Name des neuen Quest
-- @within Anwenderfunktionen
--
-- @usage
-- local NewEntryID = API.CopyQuestNoteEntry(SomeEntryID, "MyOtherQuest");
--
function API.CopyQuestNoteEntry(_ID, _Quest)
    for i= #ModuleQuestJournal.Global.Journal, 1, -1 do
        if ModuleQuestJournal.Global.Journal[i].ID == _ID and ModuleQuestJournal.Global.Journal[i].Quest ~= nil then
            if ModuleQuestJournal.Global.Journal[i].Quest ~= _Quest then
                ModuleQuestJournal.Global.Journal.ID = ModuleQuestJournal.Global.Journal.ID +1;
                table.insert(ModuleQuestJournal.Global.Journal, {
                    ID = ModuleQuestJournal.Global.Journal.ID,
                    Quest = _Quest,
                    Rank = ModuleQuestJournal.Global.Journal[i].Rank,
                    ModuleQuestJournal.Global.Journal[i][1]
                });
                return ModuleQuestJournal.Global.Journal.ID;
            end
        end
    end
    return -1
end

---
-- Entfernt einen Eintrag aus den Zusatzinformationen.
--
-- <b>Hinweis</b>: Ein Eintrag wird niemals wirklich gelöscht, sondern nur
-- unsichtbar geschaltet.
--
-- @param[type=number] _ID ID des Eintrag
-- @within Anwenderfunktionen
--
-- @usage
-- API.DeleteQuestNoteEntry(SomeEntryID);
--
function API.DeleteQuestNoteEntry(_ID)
    for i= #ModuleQuestJournal.Global.Journal, 1, -1 do
        if ModuleQuestJournal.Global.Journal[i].ID == _ID then
            ModuleQuestJournal.Global.Journal[i].Deleted = true;
            return;
        end
    end
end

---
-- Stellt einen gelöschten Eintrag in den Zusatzinformationen wieder her.
--
-- @param[type=number] _ID ID des Eintrag
-- @within Anwenderfunktionen
--
-- @usage
-- API.RestoreQuestNoteEntry(SomeEntryID);
--
function API.RestoreQuestNoteEntry(_ID)
    for i= #ModuleQuestJournal.Global.Journal, 1, -1 do
        if ModuleQuestJournal.Global.Journal[i].ID == _ID then
            ModuleQuestJournal.Global.Journal[i].Deleted = false;
            return;
        end
    end
end

