package view.window;

import java.awt.Font;
import java.awt.event.ActionEvent;

import javax.swing.JLabel;
import javax.swing.SwingConstants;
import javax.swing.event.ListSelectionEvent;

import app.Configuration;
import controller.ViewController;
import view.component.SymfoniaJButton;

/**
 * 
 * @author angermanager
 *
 */
public class WelcomeWindow extends AbstractWindow
{

    /**
     * Titel des Fensters (Label).
     */
    private final JLabel title;

    /**
     * Beschreibungstext des Fensters.
     */
    private final JLabel text;

    /**
     * Buttun zum anzeigen des nächsten Fensters.
     */
    private final SymfoniaJButton next;

    /**
     * 
     * @param w Fensterbreite
     * @param h Fensterhöhe
     */
    public WelcomeWindow(final int w, final int h)
    {
	super(w, h);

	final int titleSize = Configuration.getInteger("defaults.font.title.size");
	final int textSize = Configuration.getInteger("defaults.font.text.size");

	final String welcomeTitle = Configuration.getString("defaults.label.title.welcome");
	final String welcomeText = Configuration.getString("defaults.label.text.welcome");
	final String button = Configuration.getString("defaults.caption.button.next");

	title = new JLabel(welcomeTitle);
	title.setHorizontalAlignment(SwingConstants.CENTER);
	title.setBounds(10, 10, w - 20, 30);
	title.setFont(new Font(Font.SANS_SERIF, 1, titleSize));
	title.setVisible(true);
	getRootPane().add(title);

	text = new JLabel("<html><div align='justify'>" + welcomeText + "</div></html>");
	text.setVerticalAlignment(SwingConstants.TOP);
	text.setBounds(10, 50, w - 70, h - 300);
	text.setFont(new Font(Font.SANS_SERIF, 0, textSize));
	text.setVisible(true);
	getRootPane().add(text);

	next = new SymfoniaJButton(button);
	next.setBounds(w - 165, h - 80, 130, 30);
	next.addActionListener(this);
	next.setVisible(true);
	getRootPane().add(next);

	getRootPane().setVisible(true);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleActionEvent(final ActionEvent aE)
    {
	if (aE.getSource() == next)
	{
	    ViewController.getInstance().getWindow("OptionSelectionWindow").show();
	    hide();
	}
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleValueChanged(final ListSelectionEvent a)
    {

    }
}
