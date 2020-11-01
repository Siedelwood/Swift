

function Q2_CreateQuests()
    API.CreateStagedQuest {
        Name        = "Q2_Main",
        Stages      = {
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