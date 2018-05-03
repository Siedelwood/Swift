package twa.symfonia.view.window;

import java.awt.Font;
import java.awt.event.ActionEvent;
import java.util.Vector;

import javax.swing.JLabel;
import javax.swing.SwingConstants;
import javax.swing.SwingUtilities;
import javax.swing.event.ListSelectionEvent;

import twa.symfonia.config.Configuration;
import twa.symfonia.controller.ViewController;
import twa.symfonia.jobs.OptionWindowJob;
import twa.symfonia.service.xml.XmlReaderInterface;
import twa.symfonia.view.component.SymfoniaJButton;

/**
 * Fenster zur Selektion der Aufgabe, die der Nutzer ausführen möchte.
 * 
 * @author angermanager
 */
public class OptionSelectionWindow extends AbstractWindow
{

    /**
     * Singleton instance
     */
    private static OptionSelectionWindow instance;

    /**
     * Optionsschalter
     */
    private Vector<SymfoniaJButton> options;

    /**
     * Titel
     */
    private JLabel title;

    /**
     * Beschreibung
     */
    private JLabel text;

    /**
     * Constructor
     */
    public OptionSelectionWindow()
    {
        super();
    }

    /**
     * Gibt die Singleton-Instanz dieses Fensters zurück.
     * 
     * @return Singleton
     */
    public static OptionSelectionWindow getInstance()
    {
        if (instance == null)
        {
            instance = new OptionSelectionWindow();
        }
        return instance;
    }

    /**
     * {@inheritDoc}
     * 
     * @throws WindowException
     */
    @Override
    public void initalizeComponents(final int w, final int h, final XmlReaderInterface reader) throws WindowException
    {
        super.initalizeComponents(w, h, reader);
        this.reader = reader;

        final int titleSize = Configuration.getInteger("defaults.font.title.size");
        final int textSize = Configuration.getInteger("defaults.font.text.size");

        try
        {
            final String optionTitle = this.reader.getString("UiText/CaptionOptionWindow");
            final String optionText = this.reader.getString("UiText/DescriptionOptionWindow");

            title = new JLabel(optionTitle);
            title.setHorizontalAlignment(SwingConstants.CENTER);
            title.setBounds(10, 10, w - 20, 30);
            title.setFont(new Font(Font.SANS_SERIF, 1, titleSize));
            title.setVisible(true);
            getRootPane().add(title);

            text = new JLabel("<html><div align='justify'>" + optionText + "</div></html>");
            text.setVerticalAlignment(SwingConstants.TOP);
            text.setBounds(10, 50, w - 70, h - 300);
            text.setFont(new Font(Font.SANS_SERIF, 0, textSize));
            text.setVisible(true);
            getRootPane().add(text);

            options = new Vector<SymfoniaJButton>();
            for (int i = 0; i < 6; i++)
            {
                final String caption = this.reader.getString("UiText/ButtonOptionWindow" + i);
                final SymfoniaJButton b = new SymfoniaJButton(caption);
                b.setBounds(60, 150 + (i * 35), w - 120, 30);
                b.addActionListener(this);
                b.setVisible(true);
                b.setEnabled(false);
                getRootPane().add(b);
                options.add(b);
            }
        }
        catch (final Exception e)
        {
            throw new WindowException(e);
        }

        getRootPane().setVisible(false);
    }

    /**
     * Läd die Interfaces der Optionen, die dem Nutzer zur Verfügung stehen.
     * 
     * @throws WindowException
     */
    public void loadOptionWindows() throws WindowException
    {
        try
        {
            final OptionWindowJob optionWindowJob = new OptionWindowJob(this.reader);
            SwingUtilities.invokeLater(optionWindowJob);
        }
        catch (final Exception e)
        {
            throw new WindowException(e);
        }
    }

    /**
     * Gibt die Options-Buttons zurück.
     * 
     * @return Options-Buttons
     */
    public Vector<SymfoniaJButton> getOptions()
    {
        return options;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void show()
    {
        super.show();

        System.out.println("Debug: Show " + this.getClass().getName());
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void hide()
    {
        super.hide();

        System.out.println("Debug: Hide " + this.getClass().getName());
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleActionEvent(final ActionEvent aE)
    {
        // QSB zusammenstellen
        if (aE.getSource() == options.get(0))
        {
            BundleSelectionWindow.getInstance().show();
            hide();
        }

        // Dokumentation anzeigen
        if (aE.getSource() == options.get(1))
        {
            if (Configuration.isDebug())
            {
                ViewController.getInstance().openLocalPage("../../doc/index.html");
            }
            else
            {
                ViewController.getInstance().openLocalPage("doc/index.html");
            }
        }

        // Basisskripte exportieren
        if (aE.getSource() == options.get(2))
        {
            SaveBaseScriptsWindow.getInstance().show();
            hide();
        }

        // Self-Update
        if (aE.getSource() == options.get(5))
        {
            SelfUpdateWindow.getInstance().show();
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
