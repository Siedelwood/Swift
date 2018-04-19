package twa.symfonia.app;

import java.awt.Dimension;
import java.util.List;

import javax.swing.JFrame;

import twa.symfonia.config.Configuration;
import twa.symfonia.controller.ApplicationException;
import twa.symfonia.controller.ViewController;
import twa.symfonia.service.gui.BundleTileBuilderService;
import twa.symfonia.service.qsb.LuaMinifyerService;
import twa.symfonia.service.qsb.QsbPackagingInterface;
import twa.symfonia.service.qsb.QsbPackagingService;
import twa.symfonia.service.xml.XmlReaderInterface;
import twa.symfonia.service.xml.XmlReaderStringTableImpl;
import twa.symfonia.view.component.SymfoniaJAddOn;
import twa.symfonia.view.component.SymfoniaJBundle;
import twa.symfonia.view.component.SymfoniaJFrame;
import twa.symfonia.view.window.AddOnSelectionWindow;
import twa.symfonia.view.window.BundleSelectionWindow;
import twa.symfonia.view.window.OptionSelectionWindow;
import twa.symfonia.view.window.SaveBaseScriptsWindow;
import twa.symfonia.view.window.SaveQsbWindow;
import twa.symfonia.view.window.SelfUpdateWindow;
import twa.symfonia.view.window.WelcomeWindow;

/**
 * Hauptklasse des Symfonia-Builders.
 *
 * @author angermanager
 */
@SuppressWarnings("serial")
public class SymfoniaQsbBuilder extends SymfoniaJFrame
{

    /**
     * Fenster
     */
    private SymfoniaJFrame frame;

    /**
     * Controller der View
     */
    private final ViewController controller;

    /**
     * Constructor
     * 
     * @param controller View Controller
     */
    public SymfoniaQsbBuilder(final ViewController controller)
    {
	this.controller = controller;
    }

    /**
     * Baut die Fenster der grafischen Oberfläche.
     * 
     * @param args
     * 
     * @throws ApplicationException
     */
    public void build(final String[] args) throws ApplicationException
    {
	// Activate debug mode
	if (args.length > 0 && args[0] != null)
	{
	    Configuration.setDebug(true);
	    System.out.println("Entering dev mode!");
	}

	try
	{
	    final Dimension size = Configuration.getDimension("defaults.window.size");
	    final BundleTileBuilderService bundleListBuilder = new BundleTileBuilderService();
	    final String bundlesSourcePath = Configuration.getString("value.path.qsb.bundles");
	    final String addOnsSourcePath = Configuration.getString("value.path.qsb.addons");

	    frame = new SymfoniaJFrame();
	    frame.setTitle("Symfonia Builder");
	    frame.setBounds(0, 0, size.width, size.height);
	    frame.setResizable(false);
	    frame.setLocationRelativeTo(null);
	    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

	    String basePath = "qsb/lua";
	    String docPath = "doc";
	    if (Configuration.isDebug())
	    {
		basePath = "../../qsb/lua";
		docPath = "../../doc";
	    }
	    final QsbPackagingInterface packager = new QsbPackagingService(basePath, docPath, new LuaMinifyerService());
	    final XmlReaderInterface reader = new XmlReaderStringTableImpl();

	    // Willkommensfenster hinzufügen
	    controller.addWindow("WelcomeWindow", new WelcomeWindow(size.width, size.height, reader));
	    frame.add(controller.getWindow("WelcomeWindow").getRootPane());

	    // Optionsfenster hinzufügen
	    controller.addWindow("OptionSelectionWindow", new OptionSelectionWindow(size.width, size.height, reader));
	    frame.add(controller.getWindow("OptionSelectionWindow").getRootPane());

	    // Selfupdate-Fenster hinzufügen
	    controller.addWindow("SelfUpdateWindow", new SelfUpdateWindow(size.width, size.height, reader));
	    frame.add(controller.getWindow("SelfUpdateWindow").getRootPane());

	    // Beispiele-Speichern-Fenster hinzufügen
	    controller.addWindow("SaveBaseScriptsWindow", new SaveBaseScriptsWindow(size.width, size.height, reader));
	    ((SaveBaseScriptsWindow) controller.getWindow("SaveBaseScriptsWindow")).setPackager(packager);
	    frame.add(controller.getWindow("SaveBaseScriptsWindow").getRootPane());

	    // QSB-Speichern-Fenster hinzufügen
	    controller.addWindow("SaveQsbWindow", new SaveQsbWindow(size.width, size.height, reader));
	    ((SaveQsbWindow) controller.getWindow("SaveQsbWindow")).setPackager(packager);
	    frame.add(controller.getWindow("SaveQsbWindow").getRootPane());

	    // Bundle-Auswahl-Fenster hinzufügen
	    final List<SymfoniaJBundle> constructedBundles = bundleListBuilder.prepareBundles(bundlesSourcePath);
	    controller.addWindow("BundleSelectionWindow", new BundleSelectionWindow(size.width, size.height, reader));
	    final BundleSelectionWindow bundleWindow = (BundleSelectionWindow) controller
		    .getWindow("BundleSelectionWindow");
	    bundleWindow.setBundleList(constructedBundles);
	    frame.add(controller.getWindow("BundleSelectionWindow").getRootPane());

	    // AddOn-Bundle-Auswahl-Fenster hinzufügen
	    controller.addWindow("AddOnSelectionWindow", new AddOnSelectionWindow(size.width, size.height, reader));
	    final AddOnSelectionWindow addOnWindow = (AddOnSelectionWindow) controller
		    .getWindow("AddOnSelectionWindow");
	    final List<SymfoniaJAddOn> constructedAddOns = bundleListBuilder.prepareAddOns(addOnsSourcePath,
		    addOnWindow);
	    addOnWindow.setBundleList(constructedAddOns);
	    frame.add(controller.getWindow("AddOnSelectionWindow").getRootPane());

	    // Fenster anzeigen
	    controller.getWindow("WelcomeWindow").show();
	    frame.setVisible(true);
	}
	catch (final Exception e)
	{
	    throw new ApplicationException(e);
	}
    }

    /**
     * Gibt das Fenster der grafischen Oberfläche zurück.
     * 
     * @return Fenster
     */
    public SymfoniaJFrame getFrame()
    {
	return frame;
    }

    /**
     * Main
     * 
     * @param args Argumente
     * @throws ApplicationException
     */
    public static void main(final String[] args) throws ApplicationException
    {
	final SymfoniaQsbBuilder builder = new SymfoniaQsbBuilder(ViewController.getInstance());
	builder.build(args);
    }
}
