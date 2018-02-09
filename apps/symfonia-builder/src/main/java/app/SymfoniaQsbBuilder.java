package app;

import app.controler.ViewController;
import app.exception.SymfoniaQsbBuilderException;
import app.view.View;
import app.view.swing.SwingView;
import config.Configuration;
import config.ConfigurationException;
import config.PropertyConfiguration;

/**
 * 
 * 
 * @author angermanager
 *
 */
@SuppressWarnings("serial")
public class SymfoniaQsbBuilder extends SymfoniaJFrame
{
    /**
     * 
     */
    private final View view;
    
    /**
     * 
     */
    private final Configuration config;

    /**
     * 
     * @param properties
     */
    public SymfoniaQsbBuilder(final View view, final Configuration config) {
        this.view = view;
        this.config = config;
    }
    
    /**
     * 
     */
    public void start() {        
        add(view.getWelcomeWindow().getRootPane());        
        addWindowListener(this);
        
        setSize(
            config.getInteger("defaults.window.size.x"),
            config.getInteger("defaults.window.size.y")
        );
        setResizable(false);
        setLocationRelativeTo(null);
        setVisible(true);
        
        view.getWelcomeWindow().show();
    }
    
    /**
     * 
     * @param args
     * @throws SymfoniaQsbBuilderException 
     */
    public static void main(final String[] args) throws SymfoniaQsbBuilderException {
        try
        {
            final Configuration config = new PropertyConfiguration("conf/app.properties");
            final View view = new SwingView(config, ViewController.getInstance(config));
            final SymfoniaQsbBuilder app = new SymfoniaQsbBuilder(view, config);
            app.start();
            
        } catch (final ConfigurationException e)
        {
            throw new SymfoniaQsbBuilderException("Unable to run application", e);
        }
    }
}
