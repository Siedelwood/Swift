package twa.symfonia.view.window;

import java.awt.event.ActionEvent;
import java.io.File;

import javax.swing.SwingUtilities;
import javax.swing.event.ListSelectionEvent;

import twa.symfonia.app.SymfoniaQsbBuilder;
import twa.symfonia.controller.ViewController;
import twa.symfonia.jobs.SaveBaseScriptsJob;
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
     * Singleton-Instanz
     */
    private static SaveBaseScriptsWindow instance;

    /**
     * Constructor
     */
    private SaveBaseScriptsWindow()
    {
        super();
    }

    /**
     * Gibt die Singleton-Instanz dieses Fensters zurück.
     * 
     * @return Singleton
     */
    public static SaveBaseScriptsWindow getInstance()
    {
        if (instance == null)
        {
            instance = new SaveBaseScriptsWindow();
        }
        return instance;
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
     * Initalisiert die Komponenten des Fensters.
     * 
     * @param w Breite
     * @param h Höhe
     * @throws WindowException
     */
    @Override
    public void initalizeComponents(final int w, final int h, final XmlReaderInterface reader) throws WindowException
    {
        super.initalizeComponents(w, h, reader);
        this.reader = reader;

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

        getRootPane().setVisible(false);
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
            final WorkInProgressWindowManualContinueImpl workInProgress = WorkInProgressWindowManualContinueImpl
                .getInstance();
            workInProgress.setFinishedWindow(OptionSelectionWindow.getInstance());

            final SaveBaseScriptsJob packagingJob = new SaveBaseScriptsJob(
                workInProgress, SymfoniaQsbBuilder.getInstance().getPackager(), fileNameField.getText()
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
            OptionSelectionWindow.getInstance().show();
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
