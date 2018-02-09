package app.controler;

import app.controler.window.OptionSelectionWindowController;
import app.controler.window.SelectBundleWindowController;
import app.controler.window.WelcomeWindowController;
import app.exception.SymfoniaQsbBuilderException;
import config.Configuration;

/**
 * 
 * 
 * @author angermanager
 *
 */
public class ViewController
{
    /**
     * 
     */
    public static ViewController instance;
    
    /**
     * 
     */
    public WelcomeWindowController wwController;
    
    /**
     * 
     */
    public SelectBundleWindowController sbwController;
    
    /**
     * 
     */
    public OptionSelectionWindowController oswController;
    
    /**
     * 
     */
    public Configuration config;

    /**
     * Constructor
     * @param config 
     */
    private ViewController(final Configuration config)
    {
        this.config = config;
    }

    /**
     * 
     * @return
     */
    public WelcomeWindowController getWwController()
    {
        if (wwController == null) {
            wwController = new WelcomeWindowController(config, this);
        }
        return wwController;
    }

    /**
     * 
     * @return
     */
    public SelectBundleWindowController getSbwController()
    {
        if (sbwController == null) {
            sbwController = new SelectBundleWindowController(config, this);
        }
        return sbwController;
    }

    /**
     * 
     * @return
     */
    public OptionSelectionWindowController getOswController()
    {
        if (oswController == null) {
            oswController = new OptionSelectionWindowController(config, this);
        }
        return oswController;
    }

    /**
     * 
     * @param config
     * @return Singleton
     * @throws SymfoniaQsbBuilderException 
     */
    public static ViewController getInstance() throws SymfoniaQsbBuilderException
    {
        if (instance == null) {
            throw new SymfoniaQsbBuilderException("Instance not initalized!");
        }
        return instance;
    }
    
    /**
     * 
     * @param config
     * @return Singleton
     */
    public static ViewController getInstance(final Configuration config)
    {
        if (instance == null) {
            instance = new ViewController(config);
        }
        return instance;
    }
}
