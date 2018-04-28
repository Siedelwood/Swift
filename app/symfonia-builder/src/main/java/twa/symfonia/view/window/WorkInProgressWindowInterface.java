package twa.symfonia.view.window;

/**
 * Interface für Work-In-Progress Fenster.
 * 
 * @author angermanager
 *
 */
public interface WorkInProgressWindowInterface extends WindowInterface
{

    /**
     * Setzt alle Änderungen im Fenster zurück.
     * 
     * @throws WindowException
     */
    public void reset() throws WindowException;

    /**
     * Setzt den Status auf fertig.
     * 
     * @throws WindowException
     */
    public void ready() throws WindowException;

    /**
     * Setzt den Status auf fehlerhaft.
     * 
     * @throws WindowException
     */
    public void error() throws WindowException;

    /**
     * Setzt das Fenster zu dem gesprungen wird, wenn der Prozess beendet ist.
     * 
     * @param returnPoint
     */
    public void setFinishedWindow(final WindowInterface returnPoint);

}
