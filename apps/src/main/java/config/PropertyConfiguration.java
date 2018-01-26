package config;

import java.awt.Color;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Properties;

/**
 * 
 * 
 * @author angermanager
 *
 */
public class PropertyConfiguration implements Configuration {
    /**
     * Properties
     */
    protected final Properties properties;
    
    /**
     * {@inheritDoc}
     */
    public PropertyConfiguration(final String file) throws ConfigurationException
    {
        final File f = new File(file);
        FileReader fr = null;
        try
        {
            fr = new FileReader(f);
        } catch (final FileNotFoundException e)
        {
            throw new ConfigurationException("Unable to load property source file!", e);
        }
        
        properties = new Properties();
        try
        {
            properties.load(fr);
        } catch (final IOException e)
        {
            throw new ConfigurationException("Unable to load prpoerties!", e);
        }
    }
    
    /**
     * {@inheritDoc}
     */
    public String getString(final String prpoerty) {
        return properties.getProperty(prpoerty, null);
    }
    
    /**
     * {@inheritDoc}
     */
    public int getInteger(final String prpoerty) {
        return Integer.parseInt(properties.getProperty(prpoerty, "0"));
    }
    
    /**
     * {@inheritDoc}
     */
    public double getDouble(final String prpoerty) {
        return Double.parseDouble(properties.getProperty(prpoerty, "0.0"));
    }
    
    /**
     * {@inheritDoc}
     */
    public Color getColor(final String prpoerty) {
        final String hex = getString(prpoerty);
        return new Color(
            Integer.valueOf(hex.substring(1, 3), 16),
            Integer.valueOf(hex.substring(3, 5), 16),
            Integer.valueOf(hex.substring(5, 7), 16)
        );
    }
}
