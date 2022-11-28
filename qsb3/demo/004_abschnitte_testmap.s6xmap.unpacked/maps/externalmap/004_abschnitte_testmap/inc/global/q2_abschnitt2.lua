function Q2_CreateQuests()
    API.CreateNestedQuest {
        Name        = "Q2_Main",
        Segments    = {
            {
                Suggestion  = "Ich habe mich mit meinen Nachbarn gut gestellt. Nun kann ich den höchsten Titel anstreben",
                Success     = "Geschafft!",

                Goal_KnightTitle("Archduke"),
                Reward_FakeVictory(),
            },
        },

        Reward_Victory(),
        Trigger_OnQuestOver("Q1_Main"),
    };
end

function Q2_SkipQuests()
end