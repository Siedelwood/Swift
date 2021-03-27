-- Dialog API --------------------------------------------------------------- --

---
-- Das Dialog Modul ermöglicht es Dialogfenster anzuzeigen.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_0_Core.api.html">(1) Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Öffnet einen Info-Dialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- @param[type=string]   _Title  Titel des Dialog
-- @param[type=string]   _Text   Text des Dialog
-- @param[type=function] _Action Callback-Funktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.DialogInfoBox("Wichtige Information", "Diese Information ist Spielentscheidend!");
--
function API.DialogInfoBox(_Title, _Text, _Action)
    if not GUI then
        return;
    end

    _Title = API.ConvertPlaceholders(API.Localize(_Title));
    _Text  = API.ConvertPlaceholders(API.Localize(_Text));
    return ModuleDialogCore.Local:OpenDialog(_Title, _Text, _Action);
end

---
-- Öffnet einen Ja-Nein-Dialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- Um die Entscheigung des Spielers abzufragen, wird ein Callback benötigt.
-- Das Callback bekommt eine Boolean übergeben, sobald der Spieler die
-- Entscheidung getroffen hat.
--
-- @param[type=string]   _Title    Titel des Dialog
-- @param[type=string]   _Text     Text des Dialog
-- @param[type=function] _Action   Callback-Funktion
-- @param[type=boolean]  _OkCancel Okay/Abbrechen statt Ja/Nein
-- @within Anwenderfunktionen
--
-- @usage
-- function YesNoAction(_yes)
--     if _yes then GUI.AddNote("Ja wurde gedrückt"); end
-- end
-- API.DialogRequestBox("Frage", "Möchtest du das wirklich tun?", YesNoAction, false);
--
function API.DialogRequestBox(_Title, _Text, _Action, _OkCancel)
    if not GUI then
        return;
    end
    _Title = API.ConvertPlaceholders(API.Localize(_Title));
    _Text = API.ConvertPlaceholders(API.Localize(_Text));
    return ModuleDialogCore.Local:OpenRequesterDialog(_Title, _Text, _Action, _OkCancel);
end

---
-- Öffnet einen Auswahldialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- In diesem Dialog wählt der Spieler eine Option aus einer Liste von Optionen
-- aus. Anschließend erhält das Callback den Index der selektierten Option.
--
-- @param[type=string]   _Title  Titel des Dialog
-- @param[type=string]   _Text   Text des Dialog
-- @param[type=function] _Action Callback-Funktion
-- @param[type=table]    _List   Liste der Optionen
-- @within Anwenderfunktionen
--
-- @usage
-- function OptionsAction(_idx)
--     GUI.AddNote(_idx.. " wurde ausgewählt!");
-- end
-- local List = {"Option A", "Option B", "Option C"};
-- API.DialogSelectBox("Auswahl", "Wähle etwas aus!", OptionsAction, List);
--
function API.DialogSelectBox(_Title, _Text, _Action, _List)
    if not GUI then
        return;
    end
    _Title = API.ConvertPlaceholders(API.Localize(_Title));
    _Text = API.ConvertPlaceholders(API.Localize(_Text));
    _Text = _Text .. "{cr}";
    return ModuleDialogCore.Local:OpenSelectionDialog(_Title, _Text, _Action, _List);
end

---
-- Öffnet ein einfaches Textfenster mit dem angegebenen Text.
--
-- Die Länge des Textes ist nicht beschränkt. Überschreitet der Text die
-- Größe des Fensters, wird automatisch eine Bildlaufleiste eingeblendet.
--
-- @param[type=string] _Caption Titel des Fenster
-- @param[type=string] _content Inhalt des Fenster
-- @within Anwenderfunktionen
--
-- @usage
-- local Text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "..
--              "sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
--              "magna aliquyam erat, sed diam voluptua. At vero eos et"..
--              " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
--              " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
--              " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
--              " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
--              " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
--              " et accusam et justo duo dolores et ea rebum. Stet clita"..
--              " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
--              " dolor sit amet.";
-- API.SimpleTextWindow("Überschrift", Text);
--
function API.SimpleTextWindow(_Caption, _Content)
    _Caption = API.ConvertPlaceholders(API.Localize(_Caption));
    _Content = API.ConvertPlaceholders(API.Localize(_Content));
    if not GUI then
        Logic.ExecuteInLuaLocalState(
            string.format([[API.SimpleTextWindow("%s", "%s")]], _Caption, _Content)
        );
        return;
    end
    QSB.TextWindow:New(_Caption, _Content):Show();
end

