package config;

import java.awt.Color;

/**
 * Interface for configuration readers.
 * 
 * @author angermanager
 *
 */
public interface Configuration
{
    /**
     * 
     * @param prpoerty
     * @return
     */
    public String getString(final String prpoerty);
    
    /**
     * 
     * @param prpoerty
     * @return
     */
    public int getInteger(final String prpoerty);
    
    /**
     * 
     * @param prpoerty
     * @return
     */
    public double getDouble(final String prpoerty);
    
    /**
     * 
     * @param prpoerty
     * @return
     */
    public Color getColor(final String prpoerty);
}
