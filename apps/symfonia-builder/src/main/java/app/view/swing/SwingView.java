package app.view.swing;

import app.controler.ViewController;
import app.view.OptionSelectionWindowInterface;
import app.view.SelectBundleWindowInterface;
import app.view.View;
import app.view.WelcomeWindowInterface;
import app.view.swing.window.OptionSelectionWindow;
import app.view.swing.window.SelectBundleWindow;
import app.view.swing.window.WelcomeWindow;
import config.Configuration;

/**
 * 
 * 
 * @author angermanager
 *
 */
public class SwingView implements View
{
    /**
     * 
     */
    private final Configuration configuration;
    
    /**
     * 
     */
    private final ViewController controller;
    
    /**
     * 
     */
    private WelcomeWindowInterface welcomeWindow;
    
    /**
     * 
     */
    private OptionSelectionWindowInterface optionSelectionWindow;
    
    /**
     * 
     */
    private SelectBundleWindowInterface selectBundleWindow;

    /**
     *
     * @param configuration
     * @param controller
     */
    public SwingView(final Configuration configuration, final ViewController controller)
    {
        this.configuration = configuration;
        this.controller = controller;
    }

    /**
     * {@inheritDoc}
     */
    public WelcomeWindowInterface getWelcomeWindow()
    {
        if (welcomeWindow == null) {
            welcomeWindow = new WelcomeWindow(
                this.configuration, 
                this.controller.getWwController()
            );
        }
        return welcomeWindow;
    }

    /**
     * {@inheritDoc}
     */
    public OptionSelectionWindowInterface getOptionSelectionWindow()
    {
        if (optionSelectionWindow == null) {
            optionSelectionWindow = new OptionSelectionWindow(
                this.configuration,
                this.controller.getOswController()
            );
        }
        return optionSelectionWindow;
    }

    /**
     * {@inheritDoc}
     */
    public SelectBundleWindowInterface getSelectBundlesWindow()
    {
        if (selectBundleWindow == null) {
            selectBundleWindow = new SelectBundleWindow(
                this.configuration, 
                this.controller.getSbwController()
            );
        }
        return selectBundleWindow;
    }

}
