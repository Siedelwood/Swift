package app.view;

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
    public WelcomeWindowInterface getWelcomeWindow();
    
    /**
     * 
     * @return Operationsauswahlfenster
     */
    public OptionSelectionWindowInterface getOptionSelectionWindow();
    
    /**
     * 
     * @return Paketauswahlfenster
     */
    public SelectBundleWindowInterface getSelectBundlesWindow();
}
