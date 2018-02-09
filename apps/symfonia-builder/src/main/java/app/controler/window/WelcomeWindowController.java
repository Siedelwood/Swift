package app.controler.window;

import app.controler.ViewController;
import app.view.WelcomeWindowInterface;
import config.Configuration;

/**
 * 
 * @author mheller
 *
 */
public class WelcomeWindowController
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
     * @param config
     */
    public WelcomeWindowController(final Configuration config, final ViewController controller) {
        this.configuration = config;
        this.controller = controller;
    }

    /**
     * 
     * @param window
     */
    public void showOptionSelection(final WelcomeWindowInterface window) {
        System.out.println("Foo");
    }
}
