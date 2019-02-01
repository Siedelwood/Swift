--[[ NON-PLAYER CHARACTERS

Eines der überbleibsel aus Siedler 5 sind die NPCs. Sie sind normaler Weise
nicht nutzbar. Durch das Bundle kann man sie aber wieder verwenden. Sie ähneln
den interaktiben Objekten und den Händlern (- sind streng genommen ihre
Vorfahren).

NPCs können nur von Helden angesprochen werden und können ausschließlich
Siedler oder andere "lebende" Figuren sein.
]]

-- Es folgt nun ein einfaches Beispiel für einen NPC, der beim Ansprechen durch
-- einen Helden eine Folgefunktion auslöst.

API.NpcCompose {
    Name     = "HorstHackebeil",
    Callback = BriefingButcher1,
}

-- Um später auf den NPC zuzugreifen braucht man nur den Skriptnamen.

-- Um zu prüfen, ob der NPC angesprochen wurde, wird API.NpcHasSpoken()
-- verwendet.
if API.NpcHasSpoken("HorstHackebeil") then
    -- ...
end

-- BriefingButcher1 MUSS eine Funktion im Globalen Skript sein. Diese Funktion
-- kann absolut alles beinhalten. Von einer einfachen Nachricht bis zu einem
-- Großangriff von Feinden. Natürlich kann man auch ein Briefing damit starten.

-- Es ist zu beachten, dass das NPC-System seperat vom Questsystem läuft.
-- API.NpcHasSpoken() gibt true zurück sobald der NPC angesprochen wurde und
-- somit bereits in dem Moment in dem das Callback ausgelöst wird.

-- Möchte man NPC's mit dem Questsystem verdrahten, sollte man die Behavior
-- verwenden, auch wenn sie nicht die volle Funktionalität beinhalten.
