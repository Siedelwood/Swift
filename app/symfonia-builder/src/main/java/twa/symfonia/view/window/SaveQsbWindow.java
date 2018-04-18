package twa.symfonia.view.window;

import java.awt.Font;
import java.awt.event.ActionEvent;
import java.io.File;

import javax.swing.JCheckBox;
import javax.swing.JLabel;
import javax.swing.SwingConstants;
import javax.swing.event.ListSelectionEvent;

import org.jdesktop.swingx.JXLabel;

import twa.symfonia.config.Configuration;
import twa.symfonia.config.xml.XmlReaderInterface;
import twa.symfonia.controller.ViewController;

/**
 * Erzeugt das Speicherfenster für die QSB.
 * 
 * @author totalwarANGEL
 */
public class SaveQsbWindow extends AbstractSaveWindow
{
    /**
     * 
     */
    private final JCheckBox saveBasicScripts;

    /**
     * Constructor
     * 
     * @param w Breite
     * @param h Höhe
     * @param reader XML-Reader
     * @throws WindowException
     */
    public SaveQsbWindow(final int w, final int h, final XmlReaderInterface reader) throws WindowException
    {
        super(w, h, reader);

        final int titleSize = Configuration.getInteger("defaults.font.title.size");
        final int textSize = Configuration.getInteger("defaults.font.text.size");

        try
        {
            final String saveTitle = this.reader.getString("UiText/CaptionSaveQsbWindow");
            final String saveText = this.reader.getString("UiText/DescriptionSaveQsbWindow");
            final String useBaseScripts = this.reader.getString("UiText/SaveBaseScripts");

            saveBasicScripts = new JCheckBox();
            saveBasicScripts.setBounds(40, h -180, 20, 20);
            saveBasicScripts.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
            saveBasicScripts.setVisible(true);
            getRootPane().add(saveBasicScripts);

            final JLabel basicScriptLabel = new JLabel(useBaseScripts);
            basicScriptLabel.setBounds(65, h -180, w - 110, 20);
            basicScriptLabel.setFont(new Font(Font.SANS_SERIF, 0, textSize));
            basicScriptLabel.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
            basicScriptLabel.setVisible(true);
            getRootPane().add(basicScriptLabel);

            final JXLabel title = new JXLabel(saveTitle);
            title.setHorizontalAlignment(SwingConstants.CENTER);
            title.setBounds(10, 10, w - 20, 30);
            title.setFont(new Font(Font.SANS_SERIF, 1, titleSize));
            title.setVisible(true);
            getRootPane().add(title);

            final JXLabel text = new JXLabel(saveText);
            text.setLineWrap(true);
            text.setVerticalAlignment(SwingConstants.TOP);
            text.setBounds(10, 50, w - 70, h - 300);
            text.setFont(new Font(Font.SANS_SERIF, 0, textSize));
            text.setVisible(true);
            getRootPane().add(text);
        } catch (final Exception e)
        {
            throw new WindowException(e);
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void onSelectionFinished(final File selected)
    {
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleActionEvent(final ActionEvent aE) throws WindowException
    {
        // QSB zusammenstellen
        if (aE.getSource() == save)
        {
            // ViewController.getInstance().getWindow("SaveQsbWindow").show();
            // hide();
        }

        // Zurück
        if (aE.getSource() == back)
        {
            ViewController.getInstance().getWindow("AddOnSelectionWindow").show();
            hide();
        }

        // Ziel auswählen
        if (aE.getSource() == choose)
        {
            ViewController.getInstance().chooseFolder(this);
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
