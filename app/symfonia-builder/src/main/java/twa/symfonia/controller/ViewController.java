package twa.symfonia.controller;

import java.awt.Desktop;
import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.HashMap;

import javax.swing.JFileChooser;

import org.apache.commons.io.FileUtils;

import twa.symfonia.app.ApplicationException;
import twa.symfonia.view.window.AbstractSaveWindow;

/**
 * View Controller
 * 
 * @author angermanager
 *
 */
public class ViewController implements ViewControllerInterface
{

    /**
     * Singleton instance
     */
    private static ViewController instance;

    /**
     * Constructor
     */
    private ViewController()
    {
        new HashMap<>();
    }

    /**
     * Returns the singleton instance of the controller.
     * 
     * @return Instance
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
     * {@inheritDoc}
     */
    @Override
    public void selfUpdateMaster()
    {
        System.out.println("Update Master");
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void selfUpdateDevelopment()
    {
        System.out.println("Update Development");
    }

    /**
     * {@inheritDoc}
     * 
     * @return
     */
    @Override
    public void chooseFolder(final AbstractSaveWindow window)
    {
        final JFileChooser chooser = new JFileChooser();
        chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
        chooser.resetChoosableFileFilters();
        final int returnVal = chooser.showOpenDialog(window.getRootPane());
        if (returnVal == JFileChooser.APPROVE_OPTION)
        {
            window.onSelectionFinished(chooser.getSelectedFile());
            return;
        }
        window.onSelectionFinished(null);
    }

    /**
     * Opens an URI with the default browser.
     * 
     * @param uri URI
     * @return Erfolgreich
     */
    private boolean openWebPage(final URI uri)
    {
        final Desktop desktop = Desktop.isDesktopSupported() ? Desktop.getDesktop() : null;
        if (desktop != null && desktop.isSupported(Desktop.Action.BROWSE))
        {
            try
            {
                desktop.browse(uri);
                return true;
            }
            catch (final Exception e)
            {
                e.printStackTrace();
            }
        }
        return false;
    }

    /**
     * Opens an URL with the default browser.
     * 
     * @param String URL
     * @return Erfolgreich
     */
    @Override
    public boolean openWebPage(final String url)
    {

        try
        {
            return openWebPage(new URL(url).toURI());
        }
        catch (final URISyntaxException e)
        {
            e.printStackTrace();
        }
        catch (final MalformedURLException e)
        {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Opens an URL with the default browser.
     * 
     * @param String URL
     * @return Erfolgreich
     */
    @Override
    public boolean openLocalPage(final String url)
    {
        final File f = new File(url);
        if (!f.exists())
        {
            return false;
        }
        return openWebPage(f.toURI());
    }

    /**
     * {@inheritDoc}
     * 
     * @throws ApplicationException
     */
    @Override
    public boolean saveDocumentation(final String source, final String dest) throws ApplicationException
    {
        try
        {
            FileUtils.copyDirectory(new File(source), new File(dest));
        }
        catch (final IOException e)
        {
            throw new ApplicationException("Unable to copy documentation!", e);
        }
        return true;
    }
}
