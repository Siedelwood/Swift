package app.view.swing.window;

import java.awt.event.ActionListener;
import java.awt.event.WindowListener;

import javax.swing.JPanel;
import javax.swing.event.ListSelectionListener;

/**
 * 
 * 
 * @author angermanager
 *
 */
public interface Window extends ActionListener, WindowListener, ListSelectionListener
{
    /**
     * 
     * @return Root Panel
     */
    public JPanel getRootPane();
    
    /**
     * 
     */
    public void show();
    
    /**
     * 
     */
    public void hide();
}
