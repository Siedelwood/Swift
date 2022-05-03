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
-- <b>Hinweis</b>: Der Button wird auch dann angezeigt, wenn es noch keine
-- Zusatzinformationen für den Quest gibt.
--
-- <b>Hinweis:</b> Kann nicht im Multiplayer verwendet werden, wegen Konflikt
-- mit dem Chat Options.
--
-- @param[type=string]  _Quest Name des Quest
-- @param[type=boolean] _Flag  Zusatzinfos aktivieren
-- @within Anwenderfunktionen
--
-- @usage
-- -- Deaktivieren
-- API.ShowJournalForQuest("MyQuest", false);
-- -- Aktivieren
-- API.ShowJournalForQuest("MyQuest", true);
--
function API.ShowJournalForQuest(_Quest, _Flag)
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
-- <b>Hinweis:</b> Kann nicht im Multiplayer verwendet werden, wegen Konflikt
-- mit dem Chat Options.
--
-- @param[type=string] _Text  Text der Zusatzinfo
-- @return[type=number] ID des neuen Eintrags
-- @within Anwenderfunktionen
--
-- @usage
-- local NewEntryID = API.CreateJournalEntry("Wichtige Information zum Anzeigen");
--
function API.CreateJournalEntry(_Text)
    _Text = _Text:gsub("\\{.*\\}", "");
    return ModuleQuestJournal.Global:CreateJournalEntry(_Text, 0, false);
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
-- <b>Hinweis:</b> Kann nicht im Multiplayer verwendet werden, wegen Konflikt
-- mit dem Chat Options.
--
-- @param[type=number] _ID   ID des Eintrag
-- @param              _Text Neuer Text
-- @within Anwenderfunktionen
--
-- @usage
-- API.AlterJournalEntry(SomeEntryID, "Das ist der neue Text.");
--
function API.AlterJournalEntry(_ID, _Text)
    _Text = _Text:gsub("\\{.*\\}", "");
    local Entry = ModuleQuestJournal.Global:GetJournalEntry(_ID);
    if Entry then
        ModuleQuestJournal.Global:UpdateJournalEntry(
            _ID,
            _Text,
            Entry.Rank,
            Entry.AlwaysVisible,
            Entry.Deleted
        );
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
-- <b>Hinweis:</b> Kann nicht im Multiplayer verwendet werden, wegen Konflikt
-- mit dem Chat Options.
--
-- @param[type=number]  _ID        ID des Eintrag
-- @param[type=boolean] _Important Wichtig Markierung
-- @within Anwenderfunktionen
--
-- @usage
-- API.HighlightJournalEntry(SomeEntryID, true);
--
function API.HighlightJournalEntry(_ID, _Important)
    local Entry = ModuleQuestJournal.Global:GetJournalEntry(_ID);
    if Entry then
        ModuleQuestJournal.Global:UpdateJournalEntry(
            _ID,
            Entry[1],
            (_Important == true and 1) or 0,
            Entry.AlwaysVisible,
            Entry.Deleted
        );
    end
end

---
-- Entfernt einen Eintrag aus den Zusatzinformationen.
--
-- <b>Hinweis</b>: Ein Eintrag wird niemals wirklich gelöscht, sondern nur
-- unsichtbar geschaltet.
--
-- <b>Hinweis:</b> Kann nicht im Multiplayer verwendet werden, wegen Konflikt
-- mit dem Chat Options.
--
-- @param[type=number] _ID ID des Eintrag
-- @within Anwenderfunktionen
--
-- @usage
-- API.DeleteJournalEntry(SomeEntryID);
--
function API.DeleteJournalEntry(_ID)
    local Entry = ModuleQuestJournal.Global:GetJournalEntry(_ID);
    if Entry then
        ModuleQuestJournal.Global:UpdateJournalEntry(
            _ID,
            Entry[1],
            Entry.Rank,
            Entry.AlwaysVisible,
            true
        );
    end
end

---
-- Stellt einen gelöschten Eintrag in den Zusatzinformationen wieder her.
--
-- <b>Hinweis:</b> Kann nicht im Multiplayer verwendet werden, wegen Konflikt
-- mit dem Chat Options.
--
-- @param[type=number] _ID ID des Eintrag
-- @within Anwenderfunktionen
--
-- @usage
-- API.RestoreJournalEntry(SomeEntryID);
--
function API.RestoreJournalEntry(_ID)
    local Entry = ModuleQuestJournal.Global:GetJournalEntry(_ID);
    if Entry then
        ModuleQuestJournal.Global:UpdateJournalEntry(
            _ID,
            Entry[1],
            Entry.Rank,
            Entry.AlwaysVisible,
            false
        );
    end
end

---
-- Fügt einen Tagebucheintrag zu einem Quest hinzu.
--
-- <b>Hinweis:</b> Kann nicht im Multiplayer verwendet werden, wegen Konflikt
-- mit dem Chat Options.
--
-- @param[type=number]  _ID    ID des Eintrag
-- @param[type=boolean] _Quest Name des Quest
-- @within Anwenderfunktionen
--
-- @usage
-- API.AddJournalEntryToQuest(_ID, _Quest);
--
function API.AddJournalEntryToQuest(_ID, _Quest)
    local Entry = ModuleQuestJournal.Global:GetJournalEntry(_ID);
    if Entry then
        ModuleQuestJournal.Global:AssociateJournalEntryToQuest(_ID, _Quest, true);
    end
end

---
-- Entfernt einen Tagebucheintrag von einem Quest.
--
-- <b>Hinweis:</b> Kann nicht im Multiplayer verwendet werden, wegen Konflikt
-- mit dem Chat Options.
--
-- @param[type=number]  _ID    ID des Eintrag
-- @param[type=boolean] _Quest Name des Quest
-- @within Anwenderfunktionen
--
-- @usage
-- API.RemoveJournalEntryFromQuest(_ID, _Quest);
--
function API.RemoveJournalEntryFromQuest(_ID, _Quest)
    local Entry = ModuleQuestJournal.Global:GetJournalEntry(_ID);
    if Entry then
        ModuleQuestJournal.Global:AssociateJournalEntryToQuest(_ID, _Quest, false);
    end
end

