package twa.symfonia.view.window;

import java.awt.event.ActionEvent;
import java.io.File;

import javax.swing.SwingUtilities;
import javax.swing.event.ListSelectionEvent;

import twa.symfonia.controller.ViewController;
import twa.symfonia.jobs.SaveBaseScriptsJob;
import twa.symfonia.service.qsb.QsbPackagingInterface;
import twa.symfonia.service.xml.XmlReaderInterface;

/**
 * Fenster zum Speichern der Basisskripte.
 * 
 * @author angermanager
 *
 */
public class SaveBaseScriptsWindow extends AbstractSaveWindow
{

    /**
     * Speicher-Service
     */
    private QsbPackagingInterface packager;

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
        }
        catch (final Exception e)
        {
            throw new WindowException(e);
        }
    }

    /**
     * 
     * @param packager
     */
    public void setPackager(final QsbPackagingInterface packager)
    {
        this.packager = packager;
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
            final WorkInProgressWindow workInProgress = (WorkInProgressWindow) ViewController.getInstance()
                .getWindow("WorkInProgressWindow");
            workInProgress.setFinishedWindow("OptionSelectionWindow");
            final SaveBaseScriptsJob packagingJob = new SaveBaseScriptsJob(
                workInProgress, packager, fileNameField.getText()
            );
            workInProgress.show();
            hide();

            SwingUtilities.invokeLater(packagingJob);
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
        fileNameField.setText(unixfyPath(selected.getAbsolutePath()));
    }

}
