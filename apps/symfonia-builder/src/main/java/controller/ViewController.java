package controller;

import java.util.HashMap;
import java.util.Map;

import view.window.WindowInterface;

/**
 * 
 * @author angermanager
 *
 */
public class ViewController
{

    /**
     * 
     */
    private final Map<String, WindowInterface> windowMap;

    /**
     * 
     */
    private static ViewController instance;

    /**
     * 
     */
    private ViewController()
    {
	windowMap = new HashMap<>();
    }

    /**
     * 
     * @return
     */
    public static ViewController getInstance()
    {
	if (instance == null)
	{
	    instance = new ViewController();
	}
	return instance;
    }

    /**
     * 
     * @param name
     * @param window
     */
    public void addWindow(final String name, final WindowInterface window)
    {
	windowMap.put(name, window);
    }

    /**
     * 
     * @param key
     * @return
     */
    public WindowInterface getWindow(final String key)
    {
	return windowMap.get(key);
    }
}
