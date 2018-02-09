package app.view.swing.window;

import java.awt.Color;
import java.awt.event.ActionEvent;

import javax.swing.JPanel;
import javax.swing.event.ListSelectionEvent;

import config.Configuration;

/**
 * 
 * 
 * @author angermanager
 *
 */
public abstract class AbstractSwingWindow implements SwingWindowInterface
{
    /**
     * 
     */
    private final JPanel rootPane;
    
    /**
     * 
     */
    private final Configuration configuration;
    
    /**
     * Constructor
     */
    public AbstractSwingWindow(final Configuration configuration) {
        this.configuration = configuration;
        
        rootPane = new JPanel(null);
        rootPane.setBackground(Color.decode(configuration.getString("defaults.colors.bg.normal")));
    }
    
    /**
     * {@inheritDoc}
     */
    public void actionPerformed(final ActionEvent e) {
        
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
    protected void onShow() {
        
    }
    
    /**
     * {@inheritDoc}
     */
    protected void onHide() {
        
    }
}
