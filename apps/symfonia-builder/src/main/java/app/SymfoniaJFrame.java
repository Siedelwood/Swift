package app;

import java.awt.GraphicsConfiguration;
import java.awt.HeadlessException;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;

import javax.swing.JFrame;

public class SymfoniaJFrame extends JFrame implements WindowListener
{

    public SymfoniaJFrame() throws HeadlessException
    {
        // TODO Auto-generated constructor stub
    }

    public SymfoniaJFrame(final GraphicsConfiguration gc)
    {
        super(gc);
        // TODO Auto-generated constructor stub
    }

    public SymfoniaJFrame(final String title) throws HeadlessException
    {
        super(title);
        // TODO Auto-generated constructor stub
    }

    public SymfoniaJFrame(final String title, final GraphicsConfiguration gc)
    {
        super(title, gc);
        // TODO Auto-generated constructor stub
    }

    /**
     * {@inheritDoc}
     */
    public void windowOpened(final WindowEvent e) {
        
    }

    /**
     * {@inheritDoc}
     */
    public void windowClosing(final WindowEvent e) {
        System.exit(0);
    }

    /**
     * {@inheritDoc}
     */
    public void windowClosed(final WindowEvent e) {
        
    }

    /**
     * {@inheritDoc}
     */
    public void windowIconified(final WindowEvent e) {
        
    }

    /**
     * {@inheritDoc}
     */
    public void windowDeiconified(final WindowEvent e) {
        
    }

    /**
     * {@inheritDoc}
     */
    public void windowActivated(final WindowEvent e) {
        
    }

    /**
     * {@inheritDoc}
     */
    public void windowDeactivated(final WindowEvent e) {
        
    }
}
