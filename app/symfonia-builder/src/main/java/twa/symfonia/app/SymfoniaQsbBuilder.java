package app;

import java.awt.Dimension;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JFrame;

import config.Configuration;
import controller.ViewController;
import view.component.SymfoniaJAddOn;
import view.component.SymfoniaJBundle;
import view.component.SymfoniaJFrame;
import view.window.AddOnSelectionWindow;
import view.window.BundleSelectionWindow;
import view.window.OptionSelectionWindow;
import view.window.SaveBaseScriptsWindow;
import view.window.SelfUpdateWindow;
import view.window.WelcomeWindow;

/**
 *
 *
 * @author angermanager
 *
 */
@SuppressWarnings("serial")
public class SymfoniaQsbBuilder extends SymfoniaJFrame {

    /**
     * 
     */
    private SymfoniaJFrame frame;

    /**
     * 
     */
    private final ViewController controller;

    /**
     * 
     * @param properties
     */
    public SymfoniaQsbBuilder(final ViewController controller) {
        this.controller = controller;
    }

    /**
     * 
     */
    public void build() {
        final Dimension size = Configuration.getDimension("defaults.window.size");

        frame = new SymfoniaJFrame();
        frame.setTitle("Symfonia Builder");
        frame.setBounds(0, 0, size.width, size.height);
        frame.setResizable(false);
        frame.setLocationRelativeTo(null);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        // Willkommensfenster hinzufügen
        controller.addWindow("WelcomeWindow", new WelcomeWindow(size.width, size.height));
        frame.add(controller.getWindow("WelcomeWindow").getRootPane());

        // Optionsfenster hinzufügen
        controller.addWindow("OptionSelectionWindow", new OptionSelectionWindow(size.width, size.height));
        frame.add(controller.getWindow("OptionSelectionWindow").getRootPane());

        // Selfupdate-Fenster hinzufügen
        controller.addWindow("SelfUpdateWindow", new SelfUpdateWindow(size.width, size.height));
        frame.add(controller.getWindow("SelfUpdateWindow").getRootPane());

        // Beispiele-Speichern-Fenster hinzufügen
        controller.addWindow("SaveBaseScriptsWindow", new SaveBaseScriptsWindow(size.width, size.height));
        frame.add(controller.getWindow("SaveBaseScriptsWindow").getRootPane());
        
        // Bundle-Auswahl-Fenster hinzufügen
        controller.addWindow("BundleSelectionWindow", new BundleSelectionWindow(size.width, size.height));
        final BundleSelectionWindow window = (BundleSelectionWindow) controller.getWindow("BundleSelectionWindow");
        final List<SymfoniaJBundle> bundleList = new ArrayList();
        for (int i=0; i<15; i++) {
            bundleList.add(new SymfoniaJBundle("foo", "Bockwurst", "Das ist ein Test", 700, 60));
        }
        window.setBundleList(bundleList);
        frame.add(controller.getWindow("BundleSelectionWindow").getRootPane());
        
        // AddOn-Bundle-Auswahl-Fenster hinzufügen
        controller.addWindow("AddOnSelectionWindow", new AddOnSelectionWindow(size.width, size.height));
        final AddOnSelectionWindow window1 = (AddOnSelectionWindow) controller.getWindow("AddOnSelectionWindow");
        final List<SymfoniaJAddOn> bundleList1 = new ArrayList();
        for (int i=0; i<4; i++) {
            bundleList1.add(new SymfoniaJAddOn("foo", "Avocado", "Das ist ein Test", null, 700, 60, null));
        }
        window1.setBundleList(bundleList1);
        frame.add(controller.getWindow("AddOnSelectionWindow").getRootPane());

        controller.getWindow("WelcomeWindow").show();
        frame.setVisible(true);
    }

    /**
     * 
     * @return
     */
    public SymfoniaJFrame getFrame() {
        return frame;
    }

    /**
     * 
     * @param args
     */
    public static void main(final String[] args) {
        final SymfoniaQsbBuilder builder = new SymfoniaQsbBuilder(ViewController.getInstance());
        builder.build();
    }
}
