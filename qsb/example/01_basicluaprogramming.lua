--[[ GRUNDLAGEN DER LUA-PROGRAMMIERUNG

Dieses Beispiel befasst sich mit der Skriptsprache Lua ansich, allerdings
im Kontext zum Spiel. Es werden Scopes, Datentypen, Kontrollstrukturen und
die Arbeit mit Jobs erklärt.
]]

--[[ Teil 1: Datentypen

Lua ist eine Skriptsprache, die nicht streng typisiert ist. Das heißt, eine
Variable kann mit Typ A deklariert werden und später durch eine Zuweisung
den Typ B erhalten.

Lua kennt folgende Typen: String, Number, Function, Table, Thread und Userdata.
Hat eine Variable keinen Wert, ist sie nil. Wir werden uns allerdings nur die
ersten 4 Datentypen anschauen, da diese die gebräuchlisten sind.
]]

-- Das ist ein String
local myString = "Ich bin eine Zeichenkette.";

-- Das ist eine Zahl.
local myNumber = 12345.67;

-- Das ist eine Table.
local myTable = {1, 2, 3, 4};

-- Das ist eine Funktion
local myfunction = function()
    
end

--[[ Teil 2: Scopes

Unter einem Scope versteht man den Bereich, in dem ein Wert gültig ist. Scopes
werden auch als die Sichtbarkeit eines Wertes bezeichnet. Wenn eine Variable
außerhalb ihres Scopes benutzt wird, ist sie nil und demzufolge ungültig!
]]

local a = 1;
do
    local b = 2;
end
-- Das kann nicht funktionieren, weil b nur innerhalb des Do-Blocks existiert.
local c = a + b;

a = 1;
do
    b = 2;
end
-- Das funktioniert, weil alle Variablen als Globals deklariert sind.
c = a + b;

local a = 1;
local b;
do
    b = 2;
end
-- Das funktioniert auch, weil b bereits deklariert ist und im Do-Block ihren
-- Wert erhalten hat.
local c = a + b;

--[[ Teil 3: Kontrollstrukturen

Eine Kontrollstruktur ermöglicht erst die Programmierung, weil man durch sie
auf Situationen reagieren kann. Um zu programmieren benötigt man mindestens
ein "entweder ... oder ..." und ein "solange ... mache ...". Beides bringt
Lua mit, also können wir loslegen.
]]

-- Ein einfaches if. Der Inhalt des If-Blocks wird nur ausgeführt, wenn die
-- Bedingung wahr ist.
if someExpression == true then
    -- Mache was spannendes
end

-- Gleiches Prinzip, nur das mit else eine Alternative deklariert wurde, wie
-- AUsgeführt wird, wenn die Bedingung falsch ist.
if someExpression == true then
    -- Mache was spannendes
else
    -- Mache was anderes
end

-- Mit Elseif können mehr als eine Bedingung angefragt werden. Ein Elseif
-- folgt immer auf ein If und es kann ein Else angeführt werden, für den
-- Fall, das keine Bedingung wahr ist und dann etwas passieren soll.
if someExpression == 1 then
    -- Mache was spannendes
elseif someExpression == 2 then
    -- Mache was unspannendes
else
    -- Mache was anderes
end

-- Es gibt noch andere wichtige Strukturen: Loops. Auch gern als Schleifen
-- bezeichnet, ermöglichen sie eine wiederholte Ausführung eines Blocks bis
-- die Bedingung nicht mehr erfüllt ist.

-- Die nummerische For-Schleife
for i= 1, 10, 1 do
    -- Das hier wird 10 Mal ausgeführt
end

-- Die Key-Value-Schleife
for k, v in pairs(someTable) do
    -- Mache was mit jedem Wert v des Keys k
end

-- Die While-Schleife
while (Condition)
do
    -- Das hier wird ausgeführt, solange die Bedingung wahr ist
end

-- Die Repeat-Until-Schleife
repeat
    -- Das hier wird solange ausgeführt, bis die Bedingung falsch ist.
until (Condition);

--[[ Teil 4: Jobs

Jobs sind etwas Siedler-spezifisches. Jobs werden durch einen Trigger
gesteuert, der immer dann auslöst, wenn sein Event passiert. Der einfachste
Job ist der SimpleJob. 

Für sich wiederholende Aufgaben sind Jobs anstelle von Questschleifen zu
verwenden! Das ist einfacher und übersichtlicher!!
]]

function myJob()
    if AreThereEnoughAnimals() == false then
        SpawnAnimals();
    end
end
StartSimpleJob("myJob");
-- Ein einfacher Job, der jede Sekunde eine Bedingung prüft und dann eine
-- Aktion ausführt.

function myJob()
    if Logic.GetTime() % 20 == 0 and AreThereEnoughAnimals() == false then
        SpawnAnimals();
    end
end
StartSimpleJob("myJob");
-- Ein Job, der das Gleiche macht, aber nur alle 20 Sekunden.

-- Man kann auch einen anonymen Job deklarieren. Hier muss man aber darauf
-- achten, dass er sich sauber selbst beendet, wenn er nicht mehr gebraucht
-- wird, da man nicht so leicht an ihn heran kommt, um ihn zu beenden.

StartSimpleJobEx( function()
    if myAbortCondition == true then
        return true
    end
    if Logic.GetTime() % 20 == 0 and AreThereEnoughAnimals() == false then
        SpawnAnimals();
    end
end);

-- Beispiel für einen anonymen Job.

-- Es gibt natürlich noch andere Jobs. Aber für sie gibt es keine vereinfachte
-- Syntax. Sie werden über einen Trigger gestartet, der auf ein Event horcht.

Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "HurtAction", 1);
-- Beispiel für einen Job, der immer dann ausgeführt wird, wenn ein Entity
-- Schaden nimmt.