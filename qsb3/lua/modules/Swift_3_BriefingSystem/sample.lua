--
-- Beispiele für die Verwendung von Briefings.
--
-- Briefings sollten anstelle von Quests für die Darstellung von Dialogen
-- verwendet werden. Dadurch werden Fehler wie das berüchtigte "Rhian over the
-- sea chapel" vermieden. Außerdem ist der Spieler während eines Briefings
-- gezwungen, diesem auch zu folgen, anstelle sonst wo auf der Map irgend
-- einen Blödsinn anzustellen. Außerdem erübrigt sich durch den vom Briefing
-- einher gehenden "Kontrollverlust" auch das deselektieren von Charakteren.
--
-- Außerdem können die Dialoge mit aufwändigen oder weniger aufwändigen
-- Kameraanimationen untermalt werden, wobei die Kameraanimation nicht an die
-- Seite im Briefing gebunden ist und somit der Dialog flüssig wirkt.
--
-- Alles in allem bringt die Verwendung von Briefings gegenüber von Dialogen
-- nur Vorteile.
--
-- @within Beschreibung
-- @set sort=true
--


-- -------------------------------------------------------------------------- --
-- Einfaches Briefing

-- Unter einem einfaches Briefing versteht man einen Dialog, der ohne spezielle
-- Kameraanimationen oder Spezialseiten (z.B. Multiple Choice) auskommt. Er ist
-- die simpelste Variante und man kann eigentlich nichts falsch machen.
-- Durch die Verwendung von ASP, einer sehr simplen Funktion zum hinzufügen von
-- Seiten zu einem Briefing, ist der Konfiguraionsaufwand minimiert.
--
-- Beim Start des Briefings müssen ein Name vergeben und die ID des Spielers,
-- der das Briefing sieht, angegeben werden. Solltest du das Briefing über die
-- Quests starten, wird automatisch die ID des Questempfängers verwendet. Du
-- musst allerdings immer die Parameterliste der Funktion angeben!

function NormalDialogBriefing(_Name, _PlayerID)
    -- Setze hier die grundlegenden Einstellungen für dein Briefing. Es gibt
    -- mehr Optionen als hier verwendet. Siehe dazu die Doku. Du kannst an
    -- dieser Stelle verschiedene Dinge einstellen, z.B. auch die durchsichtig
    -- die Bars seien sollen.
    local Briefing = {
        DisableFoW = true,
        EnableSky = true,
        DisableBoderPins = true,
    };
    local AP, ASP, AAN = API.AddBriefingPages(Briefing);

    -- Am einfachsten lassen sich Dialogseiten mittels der ASP-Funktion anlegen.
    -- Hier musst du gar nichts weiter einstellen. Anhand der Position (der 3.
    -- Parameter) wird automatisch die Kameraeinstellung errechnet. Mit dem
    -- Boolean am Ende kannst du noch einstellen, ob Nahsicht aktiv ist. Die
    -- Kamera schaut das Entity an, wenn es sich um einen Siedler handelt.
    ASP("", "Marcus", "Ist das nicht ein schöner Tag heute?", "marcus", true);
    ASP("", "Alandra", "In der Tat. Wenn ich Euch nicht sehen müsste, wäre er noch schöner.", "alandra", true);
    ASP("", "Marcus", "Waaas? Wieso seid Ihr so gemein zu mir?", "marcus", true);
    ASP("", "Alandra", "Na weil Ihr der Notnagel der Programmierer des Spiels seid.", "alandra", true);
    ASP("", "Marcus", "Eben. Bin ich nicht schon diskriminiert genug?", "marcus", true);
    -- Bei dieser Seite wurde eine Funktion referenziert, welche aufgerufen
    -- wird, sobald die Seite angezeigt wird.
    ASP("", "Alandra", "Ach, halt die Klappe!", "alandra", true, AlandraVerhautMarcus);

    -- Diese Funktion ist optional. Du kannst sie verwenden, um beim Start des
    -- Briefings eine Aktion auszuführen. Das kann nützlich sein, wenn irgend
    -- etwas zuvor initialisiert oder erzeugt werden muss.
    Briefing.Starting = function(_Data)
    end

    -- Diese Funktion ist optional. Sie wird am Ende des Briefings aufgerufen
    -- und kann dafür benutzt werden, um Werte zu setzen, Entscheidungen des
    -- Spielers abzufragen oder speziell für das Briefing erzeugte Szenerie
    -- wieder zu entfernen.
    Briefing.Finished = function(_Data)
    end

    -- Hier wird das Briefing gestartet.
    API.StartBriefing(Briefing, _Name, _PlayerID);
end


-- -------------------------------------------------------------------------- --
-- Briefing mit Eintscheidung

-- Briefings können Entscheidungen enthalten. In diesem Fall wird der Spieler
-- an einem von dir festgelegten Punkt um eine Auswahl gebeten und kann erst
-- weiter voran kommen, wenn eine Auswahl getroffen wurde. Auf die getroffene
-- Auswahl kannst du dann entsprechend reagieren.

function MultipleChoiceDialogBriefing(_Name, _PlayerID)
    local Briefing = {
        DisableFoW = true,
        EnableSky = true,
        DisableBoderPins = true,
    };
    local AP, ASP, AAN = API.AddBriefingPages(Briefing);

    ASP("", "Marcus", "Ist das nicht ein schöner Tag heute?", "marcus", true);

    -- Mittels der AP-Funktion können Seiten mit erweiterter Funktion erzeugt
    -- werden. Hier für die Auswahl von Optionen. Eine solche Seite kann auch
    -- einen Text haben. Dies hat jedoch zur Folge, dass die Auswahlbox in die
    -- Mitte des Bildschirm rückt. Daher ist es ratsam, bei Multiple Choice auf
    -- Text zu verzichten.
    -- Als Konvention solltest du dir angewöhnen, deinen Choice Pages einen
    -- eindeutigen Namen zu geben. Das ermöglicht dir, an verschiedenen Stellen
    -- auf die Page zuzugreifen.
    -- Alternativ kannst du auch eine Referenz auf die Seite speichern.
    -- In diesem Beispiel machen wir beides.
    local ChoicePage1 = AP {
        Name         = "ChoicePage1",
        Title        = "Alandra",
        Text         = "",
        Position     = "alandra",
        DialogCamera = true,
        -- Dies ist der entscheidende Teil. Hier werden die Optionen festgelegt.
        -- Der Spieler muss sich zwischen einer der Optionen entscheiden. Es
        -- können theoretisch endlos viele Optionen stehen. Als Faustregel gilt
        -- aber, dass nicht mehr als 8 zur Auswahl sein sollten.
        MC           = {
            -- Bei einer Option wird zuerst der Text angegeben und danach das
            -- Ziel des Sprungs. Eine Option muss immer zu einer Seite springen.
            -- Sie kann auch wieder zu ihrer eigenen Seite  springen.
            -- Du kannst auch eine Funktion als Ziel angeben. Diese muss aber
            -- den Namen einer Seite im Briefing zurückgeben. Funktionen als
            -- Sprungziel haben den Charme, dass sofort eine Aktion asugelöst
            -- werden kann und nicht erst am Ende.
            {"Schön ihn mit Euch zu erleben.", "NiceRoute"},
            {"Ohne Euch wäre er schöner!", "MeanRoute"},
        }
    }

    -- Hier beginnt die nette Route. Die erste Seite hat den Namen NiceRoute
    -- erhalten, so wie bei den Optionen angegeben. Der Name der Seite steht
    -- bei ASP immer an erster Stelle, wenn er angegeben wird.
    -- Wählt der Spieler die erste Möglichkeit, wird zu dieser Seite gesprungen.
    ASP("NiceRoute", "Alandra", "In der Tat. Wie schön ihn mit Euch zu erleben.", "alandra", true);
    ASP("", "Marcus", "Danke. Ihr seid wirklich nett zu mir.", "marcus", true);
    ASP("", "Alandra", "Natürlich bin ich das. Ich kann doch gar nicht böse sein.", "alandra", true);
    ASP("", "Marcus", "Das ist wahr. Habt Ihr zufällig noch einen Kräuterschnapps rumliegen?", "marcus", true);
    ASP("", "Alandra", "Klar. Klosterfrau Melissengeist kommt sofort.", "alandra", true);

    -- Diese leere Seite trennt die Routen voneinander ab. Auf diese Weise ist
    -- Das Briefing an dieser Stelle zu Ende. Es wäre genauso möglich, von hier
    -- aus auf eine andere Seite zu springen. Siehe dazu die Doku.
    AP();

    -- Hier beginnt die gemeine Route. Wieder wird die erste Seite der Route
    -- benannt. Hier dann folglich MeanRoute, weil es die zweite Variante ist.
    ASP("MeanRoute", "Alandra", "In der Tat. Wenn ich Euch nicht sehen müsste, wäre er noch schöner.", "alandra", true);
    ASP("", "Marcus", "Waaas? Wieso seid Ihr so gemein zu mir?", "marcus", true);
    ASP("", "Alandra", "Na weil Ihr der Notnagel der Programmierer des Spiels seid.", "alandra", true);
    ASP("", "Marcus", "Eben. Bin ich nicht schon diskriminiert genug?", "marcus", true);
    ASP("", "Alandra", "Ach, halt die Klappe!", "alandra", true);

    -- In der Finished kann auf die ausgewählte Option zugegriffen werden. Dabei
    -- wird stets die ID der ausgewählten Option zurückgegeben. Die IDs beginnen
    -- bei 1 und werden fortlaufend für jede Antwort gezählt. Hat der Spieler
    -- nichts ausgewählt (Seite nicht besucht) oder auf der Seite kann nichts
    -- ausgewählt werden, dann wird 0 zurückgegeben.
    Briefing.Finished = function(_Data)
        -- Für den Zugriff gibt es zweit Varianten:

        -- (1) Globaler Zugriff
        -- Hier könntest du auch von beliebiger anderer Stelle auf die Antwort
        -- zugreifen, wenn du die Table des Briefings global speicherst.
        local Selected = Briefing:GetPage("ChoicePage1"):GetSelected();
        -- (2) Lokaler Zugriff
        -- Du kannst eine Referenz auf die Seite speichern (siehe oben) und dann
        -- hier auf diese Referenz zugreifen, um die Auswahl zu erhalten.
        local Selected = ChoicePage1:GetSelected();

        -- Sobald du die gewählte Option ermittelt hast, kannst du reagieren.
        if Selected == 2 then
            -- Mach was
        end
    end

    API.StartBriefing(Briefing, _Name, _PlayerID);
end

-- -------------------------------------------------------------------------- --
-- Standalone Briefings

-- Briefings können auch außerhalb von Quests verwendet werden. Dies kann
-- nützlich sein, wenn ein Briefing z.B. wiederholt von etwas ausgelöst wird,
-- das nicht an einen Quest gebunden ist.
-- In diesem Fall musst du dem Briefing dennoch einen eindeutigen Namen geben
-- und die PlayerID mitliefern.

NormalDialogBriefing("Briefing1", 1);

-- Später kannst du an beliebiger Stelle auf den Abschluss des Briefings warten.
-- Du kannst einen normalen Trigger innerhalb eines Quests nutzen und den Namen
-- dort angeben. Du kannst aber auch direkt abfragen, z.B. in einem Job.

if API.GetCinematicEventStatus("Briefing1") == QSB.CinematicEventStatus.Concluded then
    -- mach was
end

-- Da Briefings, Dialoge, Cutscenes usw. alle auf ein Kinoevent abgebildet
-- werden, kannst du sie mit den entsprechenden Funktionen überwachen und auf
-- ihren Zustand reagieren.
-- So kannst zu z.B. zu Spielbeginn einfach dein Briefing in der FMA starten
-- und dann ganz normal einen Quest darauf triggern oder etwas anderes tun.



-- -------------------------------------------------------------------------- --
-- Kameraanimationen

-- Zwar sind Briefings nicht dafür gedacht, komplexe Kameraflüge darzustellen,
-- allerdings kann es hilfreich sein, diese Möglichkeit zu haben. Sei es als
-- Platzhalter für später hinzugefügte Cutscenes oder als Gimmick, damit ein
-- Dialog nicht immer die gleiche langweilige Kameraperspektive hat.
--
-- Kameraanimationen sind mehr oder weniger entkoppelt von den Seiten des
-- Briefings. Eine Seite kann mehrere Animationen nacheinander starten, welche
-- dann alle hintereinander abgespielt werden, bis sie durchgelaufen sind, oder
-- abgebrochen werden. Dadurch kann der Spieler die Texte lesen und eine Seite
-- weiter Springen, ohne das die Kamera ihre Bewegung ändert. Dadurch sind
-- Dialoge angenehmer zu lesen.

function AnimiertesDialogBriefing(_Name, _PlayerID)
    local Briefing = {
        DisableFoW = true,
        EnableSky = true,
        DisableBoderPins = true,
        BigBars = false,
    };
    local AP, ASP, AAN = API.AddBriefingPages(Briefing);

    -- Dies ist eine normale Seite, wie du sie schon kennst. Wird bei ASP eine
    -- Position angegeben, wird implizit eine Animation erstellt. Animationen,
    -- die gerade laufen, werden automatisch abgebrochen.
    ASP("", "Marcus", "Ist das nicht ein schöner Tag heute?", "marcus", true);

    -- Wenn eine Seite eine Animation starten soll, braucht sie ebenfalls einen
    -- Namen. Wie das geht, weißt du ja.
    ASP("AnimPage1", "Alandra", "In der Tat. Wenn ich Euch nicht sehen müsste, wäre er noch schöner.");
    -- Zuerst müssen wir die alte Animation loswerden.
    AAN("AnimPage1", true);
    -- Nun können wir beliebig viele Animationen zunzufügen.
    -- (Für eine Beschreibung der Parameter schaue in die Doku!)
    -- Alle diese Animationen kommen in die Warteschlange und werden eine nach
    -- der anderen ausgeführt. Sobald alle Animationen vorbei sind, bleibt die
    -- Kamera stehen, bis es wieder neue Animationen gibt.
    AAN("AnimPage1", "Pos1", 32, 5000, 28, "Pos1", 36, 5500, 27, 30);
    AAN("AnimPage1", "Pos3", 45, 6000, 48, "Pos4", 45, 4500, 48, 30);
    
    -- Bei den nachfolgenden Seiten verzichtest du auf die Positionsangabe. So
    -- wird die laufende Animation nicht überschrieben, wenn die Seite wechselt.
    -- Außerdem kannst du nun den leeren Namen weglassen.
    ASP("Marcus", "Waaas? Wieso seid Ihr so gemein zu mir?");
    ASP("Alandra", "Na weil Ihr der Notnagel der Programmierer des Spiels seid.");
    -- Du kannst auch AP mit minimalem Input verwenden.
    AP {
        Title = "Marcus",
        Text  = "Eben. Bin ich nicht schon diskriminiert genug?",
    }

    Briefing.Finished = function(_Data)
    end
    API.StartBriefing(Briefing, _Name, _PlayerID);
end

