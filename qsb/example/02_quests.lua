--[[ QUESTS

Dieses Beispiel befasst sich mit der Erzeugung von Quests im Skript. Alle
Assistentenliebhaber dürfen dieses Beispiel getrost ignorieren.

Quests im Skript zu erzeugen bietet vielfältige Möglichkeiten. Quests müssen
nicht mehr zwingend alle auf einmal erzeugt werden. Sie können in Deutsch und
Englisch lokalisiert werden und es gibt noch einige andere Dinge, die den
Rahmen jedoch sprengen würden.
]]

--[[ Teil 1: Erzeugung von Quests

Um einen Quest im Skript zu erzeugen wird das entsprechende Bundle benötigt:
"BundleQuestGeneration" in der loader.lua. "Questerzeugung" im Assistenten.

Quests werden mit folgender Funktion erzeugt:
]]
API.CreateQuest { ... };

-- Jeder Quests hat voreingestellte Werte, die nicht gesetzt werden müssen.
-- Ein Beispiel für einen minimalen Quest:

API.CreateQuest {Name = "Bockwurst"};

-- Der Quest erhält automatisch ein Goal Goal_InstantSucces und einen Trigger
-- Trigger_AlwaysActive. Der Quest ist zudem komplett unsichtbar.

-- Natürlich ist so ein Quest zu nichts nütze. Ein sinnvoller Quest könnte
-- z.B. so aussehen:

API.CreateQuest {
    Name        = "Bockwurst2",
    Success     = "Ich habe hunger!",

    Trigger_MapScriptFunction("Trg_IsHeroHungry")
}

-- In diesem Fall würde der Quest erst ausgelöst, wenn der Trigger wahr ist.
-- Da automatisch ein Goal_IstantSucces angefügt wird, wenn man kein Goal
-- angibt, würde sofort die Success Message angezeigt.

-- Eine genaue Beschreibung der Einstellungen findest du in der Doku.

--[[ Teil 2: Quests in Schleifen erzeugen

Manchmal ist es monoton prinzipiell die gleichen Questst mehrmals schreiben
zu müssen. Diesen Boiderplate (redundanten Code) will niemand sehen! Wenn man
z.B. 5 Ruinen plündern soll, wäre es schlechter Stil 5 mal das gleiche zu
schreiben. Viel mehr würde man eine Schleife schreiben.
]]

for i= 1, 5, 1 do
    API.CreateQuest {
        -- Hier wird die Laufvariable als Teil des Namens übernommen
        Name        = "PlunderRuin" ..i,

        -- Hier wird die Laufvariable genutzt um die Ruine zu identifizieren.
        -- Bedenke, es muss Ruinen mit den entsprechenden Namen geben!
        -- ("ruin1", "ruin2", "ruin3", "ruin4", "ruin5")
        Goal_ActivateObject("ruin" ..i),
        Trigger_OnQuestSucces("PreviousQuest", 10)
    }
end

-- Versuche das mal im Quest Assistenten. ;)

--[[ Teil 3: Sprachlokalisierung

Wie alles in Symfonia, sind auch die Questtexte für Deutsch und Englisch
-- lokalisierbar. Dadurch kannst Du eine Map entweder komplett zweisprachig
-- machen oder zumindest alle Aufgabentexte übersetzen.
]]

API.CreateQuest {
    Name        = "FindTheSecret",
    Suggestion  = "Hier wurde etwas verborgen!",
    Success     = "Super, ich habe es gefunden!",
    Description = {
        de = "Ergründe das Geheimnis!",
        en = "Uncover the secret!"
    },

    Goal_EntityDistance("hero", "target", "<", 400),
    Trigger_OnQuestSucces("PreviousQuest", 10)
}

-- In diesem Beispiel wurde nur der Aufgabentext übersetzt, der Rest verbleibt
-- deutschprachig. Natürlich können auch Suggestion, Success und Failure so
-- lokalisiert werden. Standardbehavior aus dem Spiel werden sowieso durch das
-- Spiel übersetzt.
