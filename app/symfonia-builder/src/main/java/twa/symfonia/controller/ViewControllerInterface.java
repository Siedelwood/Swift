package twa.symfonia.controller;

import twa.symfonia.app.ApplicationException;
import twa.symfonia.view.window.AbstractSaveWindow;

/**
 * Interface für View Controller
 * 
 * @author angermanager
 *
 */
public interface ViewControllerInterface
{

    /**
     * Startet das automatische Update und zieht die aktuelle Stable Version vom
     * Master Branch.
     */
    public void selfUpdateMaster();

    /**
     * Startet das automatische Update und zieht den aktuellen Snapshot vom
     * Development Branch.
     */
    public void selfUpdateDevelopment();

    /**
     * Öffnet einen Dialog, indem der Nutzer ein Verzeichnis auswählt und gibt
     * die Auswahl an das Fenster zurück.
     * 
     * @param window Speicherfenster
     */
    public void chooseFolder(final AbstractSaveWindow window);

    /**
     * Öffnet eine URL im Standardbrowser.
     * 
     * @param String URL
     * @return Erfolgreich
     */
    public boolean openWebPage(final String url);

    /**
     * Öffnet eine Datei im Standardbrowser.
     * 
     * @param String URL
     * @return Erfolgreich
     */
    boolean openLocalPage(String url);

    /**
     * Kopiert den ordner mit der Lua-Doc in den angegebenen Pfad.
     * 
     * @param source Pfad zum Quellordner
     * @param dest Pfad des Ziels
     * @return Erfolgreich
     * @throws ApplicationException
     */
    boolean saveDocumentation(String source, String dest) throws ApplicationException;
}
