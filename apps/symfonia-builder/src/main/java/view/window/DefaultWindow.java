package view.window;

import java.awt.event.ActionEvent;

import javax.swing.event.ListSelectionEvent;

/**
 * 
 * 
 * @author angermanager
 *
 */
public class DefaultWindow extends AbstractWindow
{
    /**
     * Constructor
     * @param w Breite
     * @param h Höhe
     */
    public DefaultWindow(final int w, final int h)
    {
        super(w, h);
    }

    /**
     * {@inheritDoc}
     * @throws WindowException 
     */
    @Override
    public void handleActionEvent(final ActionEvent aE) throws WindowException
    {
        
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleValueChanged(final ListSelectionEvent a)
    {
        
    }
}
