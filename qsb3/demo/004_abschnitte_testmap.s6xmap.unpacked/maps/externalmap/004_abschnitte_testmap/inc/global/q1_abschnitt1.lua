function Q1_CreateQuests()
    API.CreateNestedQuest {
        Name        = "Q1_Main",
        Segments    = {
            {
                Suggestion  = "Ich muss meinen Nachbarn entdecken.",

                Goal_DiscoverPlayer(2),
                Reward_Diplomacy(1, 2, "EstablishedContact"),
            },
            {
                Suggestion  = "Ich sollte mit dem Dorfältesten sprechen.",

                Goal_NPC("settler"),
                Trigger_OnQuestSuccess("Q1_Main@Segment1"),
            },
            {
                Suggestion  = "Zahlt eine Gebühr und werdet unser Handelspartner.",
                Sender      = 2,

                Goal_Deliver("G_Gold", 50),
                Reward_Diplomacy(1, 2, "TradeContact"),
                Trigger_OnQuestSuccess("Q1_Main@Segment2"),
            },
            {
                Suggestion  = "Wenn Ihr jetzt noch Baron wäret, wären wir sehr glücklich.",
                Sender      = 2,

                Goal_KnightTitle("Baron"),
                Reward_Diplomacy(1, 2, "Allied"),
                Trigger_OnQuestSuccess("Q1_Main@Segment3"),
            },
        },
    };
end

function Q1_SkipQuests()
    API.StaticNote("Erster Abschnitt wurde überprungen!");
    -- Alle Quests des Abschnittes gewinnen
    API.WinQuest("Q1_Main", true);
    -- Diplomatie würde sich zu "verbündet" ändern also hier setzen
    SetDiplomacyState(1, 2, 2);
end