package twa.symfonia.jobs;

import java.awt.Dimension;
import java.util.List;

import twa.symfonia.app.SymfoniaQsbBuilder;
import twa.symfonia.config.Configuration;
import twa.symfonia.service.gui.BundleTileBuilderService;
import twa.symfonia.service.xml.XmlReaderInterface;
import twa.symfonia.view.component.SymfoniaJAddOn;
import twa.symfonia.view.component.SymfoniaJBundle;
import twa.symfonia.view.window.AddOnSelectionWindow;
import twa.symfonia.view.window.BundleSelectionWindow;
import twa.symfonia.view.window.OptionSelectionWindow;
import twa.symfonia.view.window.SaveBaseScriptsWindow;
import twa.symfonia.view.window.SaveQsbWindow;
import twa.symfonia.view.window.SelfUpdateWindow;
import twa.symfonia.view.window.WindowException;

/**
 * Job zum Speichern der Basisskripte.
 * 
 * @author angermanager
 */
public class OptionWindowJob extends Thread implements JobInterface
{

    /**
     * XML-Reader
     */
    private final XmlReaderInterface reader;

    /**
     * Constructor
     * 
     * @param optionWindow Work-In-Progress Fenster
     * @param packager Qsb Packager
     * @param destination Zielverzeichnispfad
     */
    public OptionWindowJob(final XmlReaderInterface reader)
    {
        this.reader = reader;
    }

    /**
     * Initalisiert die Optionen des Nutzers.
     * 
     * @throws WindowException
     */
    private void initalizeOpions() throws WindowException
    {
        final Dimension size = Configuration.getDimension("defaults.window.size");

        //
        final SaveQsbWindow saveQsbWindow = SaveQsbWindow.getInstance();
        saveQsbWindow.initalizeComponents(size.width, size.height, reader);
        SymfoniaQsbBuilder.getInstance().getFrame().add(saveQsbWindow.getRootPane());

        initalizeBundleSelection();
        initalizeAddOnSelection();

        //
        final SaveBaseScriptsWindow saveScriptWindow = SaveBaseScriptsWindow.getInstance();
        saveScriptWindow.initalizeComponents(size.width, size.height, reader);
        SymfoniaQsbBuilder.getInstance().getFrame().add(saveScriptWindow.getRootPane());

        //
        final SelfUpdateWindow selfUpdateWindow = SelfUpdateWindow.getInstance();
        selfUpdateWindow.initalizeComponents(size.width, size.height, reader);
        SymfoniaQsbBuilder.getInstance().getFrame().add(selfUpdateWindow.getRootPane());

        initalizeUserInterface();
    }

    /**
     * Stellt das Interface fertig.
     * 
     * @throws WindowException
     */
    private void initalizeUserInterface() throws WindowException
    {
        final OptionSelectionWindow optionWindow = OptionSelectionWindow.getInstance();
        optionWindow.getOptions().get(0).setEnabled(true);
        optionWindow.getOptions().get(1).setEnabled(true);
        optionWindow.getOptions().get(2).setEnabled(true);
        SymfoniaQsbBuilder.getInstance().getSplashScreen().dispose();
        SymfoniaQsbBuilder.getInstance().getFrame().setVisible(true);
    }

    /**
     * Initalisiert die AddOn-Selektion.
     * 
     * @throws WindowException
     */
    private void initalizeAddOnSelection() throws WindowException
    {
        final Dimension size = Configuration.getDimension("defaults.window.size");

        final AddOnSelectionWindow addOnSelectionWindow = AddOnSelectionWindow.getInstance();
        final BundleTileBuilderService bundleListBuilder = new BundleTileBuilderService();
        final String addOnsSourcePath = Configuration.getString("value.path.qsb.addons");
        final List<SymfoniaJAddOn> constructedAddOns = bundleListBuilder
            .prepareAddOns(addOnsSourcePath, addOnSelectionWindow);

        addOnSelectionWindow.initalizeComponents(size.width, size.height, reader);
        addOnSelectionWindow.setBundleList(constructedAddOns);
        SymfoniaQsbBuilder.getInstance().getFrame().add(addOnSelectionWindow.getRootPane());
    }

    /**
     * Initalisiert die Bundle-Selektion.
     * 
     * @throws WindowException
     */
    private void initalizeBundleSelection() throws WindowException
    {
        final Dimension size = Configuration.getDimension("defaults.window.size");

        final BundleSelectionWindow bundleSelectionWindow = BundleSelectionWindow.getInstance();
        final BundleTileBuilderService bundleListBuilder = new BundleTileBuilderService();
        final String bundlesSourcePath = Configuration.getString("value.path.qsb.bundles");
        final List<SymfoniaJBundle> constructedBundles = bundleListBuilder.prepareBundles(bundlesSourcePath);

        bundleSelectionWindow.initalizeComponents(size.width, size.height, reader);
        bundleSelectionWindow.setBundleList(constructedBundles);
        SymfoniaQsbBuilder.getInstance().getFrame().add(bundleSelectionWindow.getRootPane());
    }

    /**
     * Führt den Job aus.
     */
    @Override
    public void run()
    {
        try
        {
            initalizeOpions();
        }
        catch (final Exception e)
        {
            e.printStackTrace();
        }
    }

}
