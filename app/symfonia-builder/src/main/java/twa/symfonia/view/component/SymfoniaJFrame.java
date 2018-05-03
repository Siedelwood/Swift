package twa.symfonia.view.component;

import java.awt.GraphicsConfiguration;
import java.awt.HeadlessException;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;

import javax.swing.JFrame;

/**
 * Erzeugt ein Frame mit einem default Window Listener.
 * 
 * @author angermanager
 *
 */
@SuppressWarnings("serial")
public class SymfoniaJFrame extends JFrame implements WindowListener
{

    /**
     * {@inheritDoc}
     */
    public SymfoniaJFrame() throws HeadlessException
    {

    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaJFrame(final GraphicsConfiguration gc)
    {
        super(gc);
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaJFrame(final String title) throws HeadlessException
    {
        super(title);
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaJFrame(final String title, final GraphicsConfiguration gc)
    {
        super(title, gc);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void windowOpened(final WindowEvent e)
    {

    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void windowClosing(final WindowEvent e)
    {

    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void windowClosed(final WindowEvent e)
    {

    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void windowIconified(final WindowEvent e)
    {

    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void windowDeiconified(final WindowEvent e)
    {

    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void windowActivated(final WindowEvent e)
    {

    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void windowDeactivated(final WindowEvent e)
    {

    }
}
