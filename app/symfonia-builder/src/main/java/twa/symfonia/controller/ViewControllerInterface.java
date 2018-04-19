package twa.symfonia.controller;

import twa.symfonia.view.window.AbstractSaveWindow;
import twa.symfonia.view.window.WindowInterface;

/**
 * Interface für View Controller
 * 
 * @author angermanager
 *
 */
public interface ViewControllerInterface
{
    /**
     * 
     * @param name Name des Fensters
     * @param window Instanz des Fensters
     */
    public void addWindow(final String name, final WindowInterface window);

    /**
     * Gibt das Fenster mit dem angegebenen Namen zurück.
     * 
     * @param key Name des Fensters
     * @return Fenster
     */
    public WindowInterface getWindow(final String key);

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
     * Öffnet einen Dialog, indem der Nutzer ein Verzeichnis auswählt und gibt die
     * Auswahl an das Fenster zurück.
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
     * Speichert die Basisskripte im angegebenen Verzeichnis.
     * 
     * @param path Destination path
     * @return Erfolgreich
     * @throws ApplicationException
     */
    boolean saveBasicScripts(String path) throws ApplicationException;

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
