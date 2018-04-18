package twa.symfonia.view.window;

import java.awt.Font;
import java.awt.event.ActionEvent;

import javax.swing.JLabel;
import javax.swing.SwingConstants;
import javax.swing.event.ListSelectionEvent;

import twa.symfonia.config.Configuration;
import twa.symfonia.config.xml.XmlReaderException;
import twa.symfonia.config.xml.XmlReaderInterface;
import twa.symfonia.controller.ViewController;
import twa.symfonia.view.component.SymfoniaJButton;

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
    private JLabel title;

    /**
     * Beschreibungstext des Fensters.
     */
    private JLabel text;

    /**
     * Buttun zum anzeigen des nächsten Fensters.
     */
    private SymfoniaJButton next;

    /**
     * 
     * @param w Fensterbreite
     * @param h Fensterhöhe
     * @throws WindowException 
     */
    public WelcomeWindow(final int w, final int h, final XmlReaderInterface reader) throws WindowException
    {
        super(w, h, reader);

        final int titleSize = Configuration.getInteger("defaults.font.title.size");
        final int textSize = Configuration.getInteger("defaults.font.text.size");

        try
        {
            final String welcomeTitle = reader.getString("UiText/CaptionWelcomeWindow");
            final String welcomeText = reader.getString("UiText/DescriptionWelcomeWindow");
            final String button = reader.getString("UiText/ButtonNext");

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
            next.setBounds(w - 155, h - 70, 130, 30);
            next.addActionListener(this);
            next.setVisible(true);
            getRootPane().add(next);
        } catch (final XmlReaderException e)
        {
            throw new WindowException(e);
        }

        getRootPane().setVisible(false);
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
