package app.view.swing.window;

import java.awt.event.ActionEvent;
import java.awt.event.WindowEvent;

import javax.swing.JPanel;
import javax.swing.event.ListSelectionEvent;

/**
 * 
 * 
 * @author angermanager
 *
 */
public abstract class AbstractWindow implements Window
{
    private final JPanel rootPane;
    
    /**
     * Constructor
     */
    public AbstractWindow() {
        rootPane = new JPanel();
    }
    
    /**
     * {@inheritDoc}
     */
    public void actionPerformed(final ActionEvent e) {
        
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
        onClosed();
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

    /**
     * {@inheritDoc}
     */
    public void valueChanged(final ListSelectionEvent e) {
        
    }
    
    /**
     * {@inheritDoc}
     */
    public void show() {
        rootPane.setVisible(true);
        onShow();
    }
    
    /**
     * {@inheritDoc}
     */
    public void hide() {
        rootPane.setVisible(false);
        onHide();
    }

    /**
     * {@inheritDoc}
     */
    public JPanel getRootPane() {
        return rootPane;
    }

    /**
     * {@inheritDoc}
     */
    protected void onClosed() {
    }
    
    /**
     * {@inheritDoc}
     */
    protected void onShow() {
        
    }
    
    /**
     * {@inheritDoc}
     */
    protected void onHide() {
        
    }
}
