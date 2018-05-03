package twa.symfonia.app;

import java.awt.Dimension;
import java.awt.image.BufferedImage;

import javax.imageio.ImageIO;
import javax.swing.JFrame;

import twa.symfonia.config.Configuration;
import twa.symfonia.controller.ViewController;
import twa.symfonia.service.qsb.LuaMinifyerService;
import twa.symfonia.service.qsb.QsbPackagingService;
import twa.symfonia.service.xml.XmlReaderInterface;
import twa.symfonia.service.xml.XmlReaderStringTableImpl;
import twa.symfonia.view.component.SymfoniaJFrame;
import twa.symfonia.view.splashscreen.SplashScreenInterface;
import twa.symfonia.view.splashscreen.SplashScreenLoadingImpl;
import twa.symfonia.view.window.OptionSelectionWindow;
import twa.symfonia.view.window.WorkInProgressWindowManualContinueImpl;

/**
 * Hauptklasse des Symfonia-Builders.
 *
 * @author angermanager
 */
@SuppressWarnings("serial")
public class SymfoniaQsbBuilder extends SymfoniaJFrame
{

    private static SymfoniaQsbBuilder instance;

    /**
     * Fenster
     */
    private SymfoniaJFrame frame;

    /**
     * QSB Builder
     */
    private QsbPackagingService packager;

    /**
     * 
     */
    private SplashScreenInterface splashScreen;

    /**
     * Constructor
     */
    private SymfoniaQsbBuilder()
    {
    }

    /**
     * Gibt die Sinbleton-Instanz des Symfonia Builders zurück.
     * 
     * @return Singleton
     */
    public static SymfoniaQsbBuilder getInstance()
    {
        if (instance == null)
        {
            instance = new SymfoniaQsbBuilder();
        }
        return instance;
    }

    /**
     * Setzt den Controller der grafischen Oberfläche.
     * 
     * @param controller Controller
     */
    public void setController(final ViewController controller)
    {
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

            // Fenster erzeugen
            frame = new SymfoniaJFrame();
            frame.setTitle("Symfonia Builder");
            frame.setBounds(0, 0, size.width, size.height);
            frame.setResizable(false);
            frame.setLocationRelativeTo(null);
            frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

            // Packager vorbereiten
            String basePath = "qsb/lua";
            String docPath = "doc";
            if (Configuration.isDebug())
            {
                basePath = "../../qsb/lua";
                docPath = "../../doc";
            }
            packager = new QsbPackagingService(basePath, docPath, new LuaMinifyerService());
            final XmlReaderInterface reader = new XmlReaderStringTableImpl();

            // Fenster erzeigen
            createSprlashScreen();
            createWorkInProgressnWindow(reader);
            createOptionSelectionWindow(reader);
        }
        catch (final Exception e)
        {
            throw new ApplicationException(e);
        }
    }

    /**
     * Erzeugt das WorkInProgressWindow.
     * 
     * @param reader XML-Reader
     * @throws ApplicationException
     */
    private void createWorkInProgressnWindow(final XmlReaderInterface reader) throws ApplicationException
    {
        try
        {
            final Dimension size = Configuration.getDimension("defaults.window.size");
            final WorkInProgressWindowManualContinueImpl workingWindow = WorkInProgressWindowManualContinueImpl
                .getInstance();
            workingWindow.initalizeComponents(size.width, size.height, reader);
            frame.add(workingWindow.getRootPane());
        }
        catch (final Exception e)
        {
            throw new ApplicationException(e);
        }
    }

    /**
     * Erzeugt das OptionSelectionWindow.
     * 
     * @param reader XML-Reader
     * @throws ApplicationException
     */
    private void createOptionSelectionWindow(final XmlReaderInterface reader) throws ApplicationException
    {
        try
        {
            final Dimension size = Configuration.getDimension("defaults.window.size");
            final OptionSelectionWindow optionWindow = OptionSelectionWindow.getInstance();
            optionWindow.initalizeComponents(size.width, size.height, reader);
            frame.add(optionWindow.getRootPane());

            optionWindow.loadOptionWindows();
            optionWindow.show();
        }
        catch (final Exception e)
        {
            throw new ApplicationException(e);
        }
    }

    /**
     * Erzeugt den Splashscreen und zeigt ihn an.
     * 
     * @throws ApplicationException
     */
    private void createSprlashScreen() throws ApplicationException
    {
        try
        {
            String imagePath = "splash.jpg";
            if (!Configuration.isDebug())
            {
                imagePath = "resources/" + imagePath;
            }
            final BufferedImage bg = ImageIO.read(getClass().getClassLoader().getResource(imagePath));

            final SplashScreenInterface splashScreen = new SplashScreenLoadingImpl(768, 222, bg);
            splashScreen.display();
            this.splashScreen = splashScreen;
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
     * Gibt den QSB-Builder zurück.
     * 
     * @return Packager
     */
    public QsbPackagingService getPackager()
    {
        return packager;
    }

    /**
     * Gibt den Lade-Splashscreen zurück
     * @return Splashscreen
     */
    public SplashScreenInterface getSplashScreen()
    {
        return splashScreen;
    }

    /**
     * Main
     * 
     * @param args Argumente
     * @throws ApplicationException
     */
    public static void main(final String[] args) throws ApplicationException
    {
        try
        {
            final SymfoniaQsbBuilder builder = SymfoniaQsbBuilder.getInstance();
            builder.setController(ViewController.getInstance());
            builder.build(args);
        }
        catch (final Exception e)
        {
            throw new ApplicationException(e);
        }
    }
}
