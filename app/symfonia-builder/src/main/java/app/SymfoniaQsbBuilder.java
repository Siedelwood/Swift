package app;

import java.awt.Dimension;

import javax.swing.JFrame;

import config.Configuration;
import controller.ViewController;
import view.component.SymfoniaJFrame;
import view.window.OptionSelectionWindow;
import view.window.SelfUpdateWindow;
import view.window.SaveBaseScriptsWindow;
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
