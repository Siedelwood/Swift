package twa.symfonia.view.window;

import java.awt.event.ActionEvent;
import java.io.File;

import javax.swing.event.ListSelectionEvent;

import twa.symfonia.config.xml.XmlReaderInterface;
import twa.symfonia.controller.ApplicationException;
import twa.symfonia.controller.ViewController;

/**
 * 
 * 
 * @author angermanager
 *
 */
public class SaveBaseScriptsWindow extends AbstractSaveWindow
{

    /**
     * Constructor
     * 
     * @param w Breite
     * @param h Höhe
     * @throws WindowException 
     */
    public SaveBaseScriptsWindow(final int w, final int h, final XmlReaderInterface reader) throws WindowException
    {
        super(w, h, reader);

        try
        {
            final String exampleTitle = this.reader.getString("UiText/CaptionBaseScriptWindow");
            final String exampleText = this.reader.getString("UiText/DescriptionBaseScriptWindow");

            title.setText(exampleTitle);
            text.setText(exampleText);
        } catch (final Exception e)
        {
            throw new WindowException(e);
        }
    }

    /**
     * {@inheritDoc}
     * 
     * @throws WindowException
     */
    @Override
    public void handleActionEvent(final ActionEvent aE) throws WindowException
    {
        // Datei(en) speichern
        if (aE.getSource() == save)
        {
            try
            {
                ViewController.getInstance().saveBasicScripts(fileNameField.getText());
            } catch (final ApplicationException e)
            {
                throw new WindowException(e);
            }
        }

        // Ziel auswählen
        if (aE.getSource() == choose)
        {
            ViewController.getInstance().chooseFolder(this);
        }

        // Zurück
        if (aE.getSource() == back)
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

    /**
     * {@inheritDoc}
     */
    @Override
    public void onSelectionFinished(File selected)
    {
        selected = (selected == null) ? new File(".") : selected;
        fileNameField.setText(unixfyPath(selected.getAbsolutePath()) + "/Basisskripte");
    }

}
