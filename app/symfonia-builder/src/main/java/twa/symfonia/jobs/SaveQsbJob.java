package twa.symfonia.jobs;

import twa.symfonia.model.QsbPackagingModel;
import twa.symfonia.service.qsb.QsbPackagingInterface;
import twa.symfonia.view.window.WindowException;
import twa.symfonia.view.window.WorkInProgressWindowInterface;

/**
 * Job zum Speichern der QSB.
 * 
 * @author angermanager
 */
public class SaveQsbJob extends Thread implements JobInterface
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
     * Configuration
     */
    protected final QsbPackagingModel configuration;

    /**
     * Constructor
     * 
     * @param saveWindow Work-In-Progress Fenster
     * @param packager Qsb Packager
     * @param configuration Configuration
     */
    public SaveQsbJob(final WorkInProgressWindowInterface saveWindow, final QsbPackagingInterface packager,
        final QsbPackagingModel configuration)
    {
        this.saveWindow = saveWindow;
        this.packager = packager;
        this.configuration = configuration;
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

            packager.pack(
                configuration.getLoadOrder(), configuration.getDestination(), configuration.isCopyDoc(),
                configuration.isCopyBaseScripts(), configuration.isCopyExamples(), configuration.isMinifyQsb()
            );

            try
            {
                saveWindow.ready();
            }
            catch (final WindowException e)
            {
                e.printStackTrace();
            }
        }
        catch (final Exception e)
        {
            try
            {
                saveWindow.error();
            }
            catch (final WindowException e1)
            {
                e1.printStackTrace();
            }
        }
    }
}
