package app;

import java.awt.Dimension;

import javax.swing.JFrame;

import controller.ViewController;
import view.component.SymfoniaJFrame;
import view.window.WelcomeWindow;

/**
 *
 *
 * @author angermanager
 *
 */
@SuppressWarnings("serial")
public class SymfoniaQsbBuilder extends SymfoniaJFrame
{

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
    public SymfoniaQsbBuilder()
    {
	controller = ViewController.getInstance();
    }

    /**
     * 
     */
    public void build()
    {
	final Dimension size = Configuration.getDimension("defaults.window.size");

	frame = new SymfoniaJFrame();
	frame.setTitle("Symfonia Builder");
	frame.setBounds(0, 0, size.width, size.height);
	frame.setResizable(false);
	frame.setLocationRelativeTo(null);
	frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

	final WelcomeWindow welcomeWindow = new WelcomeWindow(size.width, size.height);
	frame.add(welcomeWindow.getRootPane());
	controller.addWindow("WelcomeWindow", welcomeWindow);

	frame.setVisible(true);
    }

    /**
     * 
     * @return
     */
    public SymfoniaJFrame getFrame()
    {
	return frame;
    }

    /**
     * 
     * @param args
     */
    public static void main(final String[] args)
    {
	final SymfoniaQsbBuilder builder = new SymfoniaQsbBuilder();
	builder.build();
    }
}
