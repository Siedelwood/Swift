package twa.symfonia.jobs;

import twa.symfonia.service.qsb.QsbPackagingException;
import twa.symfonia.service.qsb.QsbPackagingInterface;
import twa.symfonia.view.window.WindowException;
import twa.symfonia.view.window.WorkInProgressWindowInterface;

/**
 * Job zum Speichern der Basisskripte.
 * 
 * @author angermanager
 */
public class SaveBaseScriptsJob extends Thread implements JobInterface
{

    /**
     * Work-In-Progress Fenster
     */
    protected final WorkInProgressWindowInterface saveWindow;

    /**
     * Qsb Packager
     */
    protected final QsbPackagingInterface packager;

    /**
     * Zielverzeichnispfad
     */
    protected final String destination;

    /**
     * Constructor
     * 
     * @param saveWindow Work-In-Progress Fenster
     * @param packager Qsb Packager
     * @param destination Zielverzeichnispfad
     */
    public SaveBaseScriptsJob(final WorkInProgressWindowInterface saveWindow, final QsbPackagingInterface packager,
        final String destination)
    {
        this.saveWindow = saveWindow;
        this.packager = packager;
        this.destination = destination;
    }

    /**
     * Führt den Job aus.
     */
    @Override
    public void run()
    {
        try
        {
            saveWindow.getRootPane().repaint();

            packager.saveBasicScripts(destination);

            try
            {
                saveWindow.ready();
            }
            catch (final WindowException e)
            {
                e.printStackTrace();
            }
        }
        catch (final QsbPackagingException e)
        {
            try
            {
                e.printStackTrace();
                saveWindow.error();
            }
            catch (final WindowException e1)
            {
                e1.printStackTrace();
            }
        }
    }

}
