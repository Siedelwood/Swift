-- Dialog API --------------------------------------------------------------- --

---
-- Blendet einen Text Zeichen für Zeichen auf schwarzem Grund ein.
--
-- <b>Diese Funktion ist der offizielle Nachfolger der Laufschrift!</b>
--
-- Der Effekt startet erst, nachdem die Map geladen ist. Wenn ein Briefing
-- läuft, wird gewartet, bis das Briefing beendet ist. Wärhend der Effekt
-- läuft, können wiederrum keine Briefings starten.
--
-- <b>Hinweis</b>: Steuerzeichen wie {cr} oder {@color} werden als ein Token
-- gewertet und immer sofort eingeblendet. Steht z.B. {cr}{cr} im Text, werden
-- die Zeichen atomar behandelt, als seien sie ein einzelnes Zeichen.
-- Gibt es mehr als 1 Leerzeichen hintereinander, werden alle zusammenhängenden
-- Leerzeichen auf ein Leerzeichen reduziert!
--
-- @param[type=string]   _Text            Anzuzeigender Text
-- @param[type=string]   _BlackBackground Schwarzen Hintergrund verwenden
-- @param[type=function] _Callback        Funktion nach Ende des Effekt
--
-- @usage
-- local Text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "..
--              " sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
--              " magna aliquyam erat, sed diam voluptua. At vero eos et"..
--              " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
--              " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
--              " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
--              " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
--              " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
--              " et accusam et justo duo dolores et ea rebum. Stet clita"..
--              " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
--              " dolor sit amet.";
-- local Callback = function(_Data)
--     -- Hier kann was passieren
-- end
-- API.SimpleTypewriter(Text, true, Callback);
-- @within Anwenderfunktionen
--
function API.SimpleTypewriter(_Text, _BlackBackground, _Callback)
    if GUI then
        return;
    end
    QSB.SimpleTypewriter
        :New(API.ConvertPlaceholders(API.Localize(_Text)), _Callback)
        :SetBlackBackground(_BlackBackground)
        :Start();
end

