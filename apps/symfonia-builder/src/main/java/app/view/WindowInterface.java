package app.view;

import javax.swing.JPanel;

/**
 * 
 * @author mheller
 *
 */
public interface WindowInterface
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
