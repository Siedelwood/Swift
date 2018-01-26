package app.view;

import app.view.swing.window.Window;

/**
 * 
 * 
 * @author angermanager
 *
 */
public interface View
{
    /**
     * 
     * @return Begrüßungsfenster
     */
    public Window getWelcomeWindow();
    
    /**
     * 
     * @return Operationsauswahlfenster
     */
    public Window getOptionSelectionWindow();
    
    /**
     * 
     * @return Paketauswahlfenster
     */
    public Window getSelectBundlesWindow();
}
