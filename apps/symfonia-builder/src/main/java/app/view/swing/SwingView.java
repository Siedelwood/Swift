package app.view.swing;

import app.controler.ViewController;
import app.controler.window.OptionSelectionWindowController;
import app.controler.window.SelectBundleWindowController;
import app.controler.window.WelcomeWindowController;
import app.view.View;
import app.view.swing.window.OptionSelectionWindow;
import app.view.swing.window.SelectBundleWindow;
import app.view.swing.window.WelcomeWindow;
import app.view.swing.window.Window;
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
    private WelcomeWindow welcomeWindow;
    
    /**
     * 
     */
    private OptionSelectionWindow optionSelectionWindow;
    
    /**
     * 
     */
    private SelectBundleWindow selectBundleWindow;
    
    /**
     * 
     * @param config
     */
    public SwingView(final Configuration configuration, final ViewController controller)
    {
        this.configuration = configuration;
        this.controller = controller;
    }

    /**
     * {@inheritDoc}
     */
    public Window getWelcomeWindow()
    {
        if (welcomeWindow == null) {
            welcomeWindow = new WelcomeWindow(
                this.configuration, 
                new WelcomeWindowController(this.configuration)
            );
        }
        return welcomeWindow;
    }

    /**
     * {@inheritDoc}
     */
    public Window getOptionSelectionWindow()
    {
        if (optionSelectionWindow == null) {
            optionSelectionWindow = new OptionSelectionWindow(
                this.configuration,
                new OptionSelectionWindowController(this.configuration)
            );
        }
        return optionSelectionWindow;
    }

    /**
     * {@inheritDoc}
     */
    public Window getSelectBundlesWindow()
    {
        if (selectBundleWindow == null) {
            selectBundleWindow = new SelectBundleWindow(
                this.configuration, 
                new SelectBundleWindowController(this.configuration)
            );
        }
        return selectBundleWindow;
    }

}
