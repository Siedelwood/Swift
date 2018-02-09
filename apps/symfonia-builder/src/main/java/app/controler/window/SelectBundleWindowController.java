package app.controler.window;

import app.controler.ViewController;
import config.Configuration;

public class SelectBundleWindowController
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
     * @param controller
     */
    public SelectBundleWindowController(final Configuration config, final ViewController controller)
    {
        this.configuration = config;
        this.controller = controller;
    }

}
