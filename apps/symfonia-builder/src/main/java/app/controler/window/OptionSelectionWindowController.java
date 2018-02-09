package app.controler.window;

import app.controler.ViewController;
import config.Configuration;

public class OptionSelectionWindowController
{
    /**
     * 
     */
    private final ViewController controller;
    
    /**
     * 
     */
    private final Configuration configuration;

    public OptionSelectionWindowController(final Configuration config, final ViewController controller)
    {
        this.configuration = config;
        this.controller = controller;
    }

}
