--[[ INTERAKTIVE OBJEKTE

Interaktive Objekte sind jedermann bekannt. Mit dem Skript für interaktive
Objekte können diese vielseitiger eingesetzt werden. Es ist ebenso möglich
normale Landschaftsobjekte, Gebäude und Siedler in interaktive Objekte zu
verwandeln.
]]

--[[ Teil 1: Basics

In der Grundfunktionalität wird ein Objekt definiert und ihm verschiedene
Werte übergeben. Für bereits fertiggestellte interaktive Objekte wird das
AddOn benötigt.
]]

API.CreateObject {
    Name                 = "oldHouse",
    Title                = "Abreißen",
    Text                 = "Sobald der Sprengmeister anwesend ist, könnt"..
                           " Ihr die Ruine beseitigen.",
    Texture              = {3,15},
    State                = 1,
    Condition            = Abriss_Bedingung,
    ConditionUnfulfilled = "Der Sprengmeister ist nicht anwesend!",
    Callback             = Abriss_Aktion,
};

-- Name                     Skriptname des objektes
-- Title                    Titelzeile der Beschreibung
-- Text                     Text der Beschreibung
-- Texture                  Angezeigte Grafik (kann auch aus der Mapdatei
--                          geladen werden)
-- State                    Nutzbarkeit (0 = Held, 1 = immer, 2 = niemals)
--                          Greift nur bei Entities mit I_X_ am Anfang!
-- Condition                Bedingungsfunktion muss boolean zurückgeben
-- ConditionUnfulfilled     Nachricht, wenn Bedingung nicht erfüllt ist
-- Callback                 Ausgelöste Funktion

-- Neben diesen Optionen gibt es noch weitere Optionen:

-- Costs                    Table mit Aktivierungskosten (max. 2 Waren)
--                          {Typ, Menge, Typ, Mene}
-- Reward                   Table mit Belohnung
--                          {Typ, Menge}
-- Distance                 Aktivierungsentfernung
-- Waittime                 Benötigte Zeit bis zur Aktivierung (Diese Option
--                          greift nur bei richtigen interaktiven Objekten)
-- Opener                   Spezieller Held zur Aktivierung
-- WrongKnight              Nachricht, beim fehlenden Opener

--[[ Teil 2: Schatztruhen

Immer wieder gern, werden Schätze versteckt. Mit den Funktionen für fertige
Schatztruhen, kann jeder Mapper ganz einfach Schatztruhen platzieren. Die
Truhen können nicht aus Versehen überbaut werden.
]]

-- Erstellt eine Schatztruhe mit einer zufälligen Mänge Taler. Die Mänge liegt
-- im Bereich von 300 bis 600 Taler.
CreateRandomGoldChest("chest1");

-- Erstellt eine Rohstofftruhe mit einer Zufälligen Menge eines Rohstoffes.
-- Die Mänge liegt zwischen 30 und 60 Einheiten.
CreateRandomResourceChest("chest2");

-- Erstellt eine Truhe mit einer zufälligen Menge an Luxusgütern. Die Menge
-- liegt zwischen 30 und 60 Einheiten.
CreateRandomLuxuryChest("chest3");

-- Wer mehr Kontrolle über seine Schatztruhen will, sollte die Funktion
-- CreateRandomChest() verwenden.
CreateRandomChest("chest4", Goods.G_Salt, 55, 75);

--[[ Teil 3: Minen

Manchmal möchte man, dass der Spieler etwas für seine Minen tun muss. Die
interaktiven Minen müssen erst gegen Entrichten von Kosten aufgebaut werden.
Man kann entscheiden, ob sie auffüllbar sein sollen oder nicht.
]]

-- Erstellen einer Eisenmine:
CreateIOIronMine("mine1", Goods.G_Wood, 20, Goods.G_Gold, 300);
-- Erstellen einer nicht auffüllbaren Eisenmine:
CreateIOIronMine("mine2", Goods.G_Wood, 20, Goods.G_Gold, 300, true);

-- Auch hier gibt es wieder eine komplexere Variante, bei der man mit einigen
-- Angaben mehr, zusätzliche Dinge tun kann.

CreateIOMine(
    "mine2",
    Entities.R_IronMine,
    {Goods.G_Wood, 20, Goods.G_Gold},
    false,
    OnMineConstructed,
    OnMineDepleted
);

-- Durch die Angabe des Entitytyp wird bestimmt, was für eine Mine gebaut wird.
-- OnMineConstructed ist eine optionale Funktion, die aufgerufen wird, wenn die
-- Mine vom Spieler aufgebaut wurde. Sie erhält alle Daten des interaktiven
-- Objektes.
-- OnMineDepleted ist eine optionale Funktion die aufgerufen wird, wenn die
-- Mine erschöpft ist. Sie erhält alle Daten des interaktiven Objektes.

--[[ Teil 4: Baustellen

Will man den Spieler ein Gebäude genau da bauen lassen, wo man es will, sind
dafür einige Dinge notwendig. Dies kann erheblich vereinfacht werden, wenn
die interaktiven Baustellen genutzt werden.
Eine solche Baustelle ermöglicht es dem Spieler sogar, auf anderen Territorien
ein Gebäude in Auftrag zu geben.
]]

-- Erzeugt eine Baustelle ohne besondere Einstellungen
API.CreateIOBuildingSite("haus", 1, Entities.B_Bakery);
-- Baustelle mit Kosten und Aktivierungsdistanz
API.CreateIOBuildingSite("haus", 1, Entities.B_Bakery, {Goods.G_Wood, 4}, 1000);

-- Erzeugt eine Baustelle für ein Trebuchet
API.CreateTrebuchetConstructionSite("trebuchet1", 500, 25);
