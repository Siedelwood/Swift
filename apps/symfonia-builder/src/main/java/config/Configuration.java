package config;

import java.awt.Color;
import java.awt.Dimension;
import java.io.FileReader;
import java.net.URL;
import java.util.Properties;

import app.SymfoniaQsbBuilder;

/**
 * Ließt die Konfiguration aus der app.properties aus.
 * 
 * @author angermanager
 *
 */
public class Configuration
{

    /**
     * Verzeichnit der Properties
     */
    public static URL PATH_TO_CONFIG = SymfoniaQsbBuilder.class.getClassLoader().getResource("app.properties");

    /**
     * Ließt einen String aus den Properties aus und gibt ihn zurück.
     * 
     * @param key Schlüssel des Wertes
     * @return Zeichenkette aus den Properties
     */
    public static String getString(final String key)
    {
	final Properties property = new Properties();
	try
	{
	    property.load(new FileReader(PATH_TO_CONFIG.getPath()));
	    return property.getProperty(key);
	}
	catch (final Exception e)
	{
	    return null;
	}
    }

    /**
     * Ließt einen Integer aus der Properties aus und gibt ihn zurück.
     * 
     * @param key Schlüssel des Wertes
     * @return Ganzzahlwert aus den Properties
     */
    public static int getInteger(final String key)
    {
	try
	{
	    return Integer.parseInt(getString(key));
	}
	catch (final Exception e)
	{
	    return 0;
	}
    }

    /**
     * Gibt eine Fließkommazahl aus den Properties aus und gibt sie zurück.
     * 
     * @param key Schlüssel des Wertes
     * @return Fließkommazahl aus den Properties
     */
    public static double getDouble(final String key)
    {
	try
	{
	    return Double.parseDouble(getString(key));
	}
	catch (final Exception e)
	{
	    return 0.0;
	}
    }

    /**
     * Gibt eine Farbe als Color-Objekt zurück, die in Hex-Notation in den
     * Properties steht.
     * 
     * @param key Schlüssel des Wertes
     * @return Farbe aus den Properties
     */
    public static Color getColor(final String key)
    {
	try
	{
	    return Color.decode(getString(key));
	}
	catch (final Exception e)
	{
	    return new Color(0, 0, 0);
	}
    }

    /**
     * Ließt x und y zu einem beliebigen Eintrag in den Properties aus und gibt
     * ein Dimension-Objekt zurück.
     * 
     * @param key
     * @return
     */
    public static Dimension getDimension(final String key)
    {
	int x, y;
	try
	{
	    x = getInteger(key + ".x");
	    y = getInteger(key + ".y");
	}
	catch (final Exception e)
	{
	    x = 0;
	    y = 0;
	}
	return new Dimension(x, y);
    }
}
