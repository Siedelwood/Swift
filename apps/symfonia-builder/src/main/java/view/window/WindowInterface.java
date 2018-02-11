package view.window;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import view.component.SymfoniaJPanel;

/**
 * Interface für Fenster in der Applikation.
 * 
 * @author angermanager
 *
 */
public interface WindowInterface extends ActionListener, ListSelectionListener
{

    /**
     * Zeigt das fenster an.
     */
    public void show();

    /**
     * Blendet das Fenster aus
     */
    public void hide();

    /**
     * Gibt das Basiselement des Fensters zurück.
     * 
     * @return
     */
    public SymfoniaJPanel getRootPane();

    /**
     * Behandelt Action Events.
     * 
     * @param aE Event
     */
    public void handleActionEvent(final ActionEvent aE);

    /**
     * Behandelt veränderte Werte in Selektionslisten.
     * 
     * @param aE Event
     */
    public void handleValueChanged(final ListSelectionEvent aE);
}
