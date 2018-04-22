package twa.symfonia.view.window;

import java.awt.Dimension;
import java.awt.Font;
import java.awt.event.ActionEvent;

import javax.swing.JProgressBar;
import javax.swing.SwingConstants;
import javax.swing.event.ListSelectionEvent;

import org.jdesktop.swingx.JXLabel;

import twa.symfonia.config.Configuration;
import twa.symfonia.controller.ViewController;
import twa.symfonia.service.xml.XmlReaderInterface;
import twa.symfonia.view.component.SymfoniaJButton;

/**
 * Implementation des Work-In-Progress Fensters.
 * 
 * @author angermanager
 *
 */
public class WorkInProgressWindow extends AbstractWindow implements WorkInProgressWindowInterface
{

    /**
     * Informationstext
     */
    private JXLabel info;

    /**
     * Abschlussbestätigung
     */
    private SymfoniaJButton back;

    /**
     * Fortschrittbalken
     */
    private JProgressBar progressBar;

    /**
     * Fenstertitel
     */
    private JXLabel title;

    /**
     * Back Button
     */
    private String returnPoint;

    /**
     * Constructor
     * 
     * @param w Breite
     * @param h Höhe
     * @param reader XML-Reader
     * @throws WindowException
     */
    public WorkInProgressWindow(final int w, final int h, final XmlReaderInterface reader) throws WindowException
    {
        super(w, h, reader);
        new Dimension(w, h);

        final int titleSize = Configuration.getInteger("defaults.font.title.size");
        final int textSize = Configuration.getInteger("defaults.font.text.size");

        try
        {
            final String workInProgressTitle = this.reader.getString("UiText/WorkInProgressWindowWorking");
            final String workInProgressText = this.reader.getString("UiText/WorkInProgressText");
            final String completeButton = this.reader.getString("UiText/ButtonComplete");

            title = new JXLabel(workInProgressTitle);
            title.setHorizontalAlignment(SwingConstants.CENTER);
            title.setBounds(10, 10, w - 20, 30);
            title.setFont(new Font(Font.SANS_SERIF, 1, titleSize));
            title.setVisible(true);
            getRootPane().add(title);

            info = new JXLabel(workInProgressText);
            info.setLineWrap(true);
            info.setVerticalAlignment(SwingConstants.TOP);
            info.setHorizontalAlignment(SwingConstants.CENTER);
            info.setBounds(90, (h / 2) - 100, w - 180, 50);
            info.setFont(new Font(Font.SANS_SERIF, 0, textSize));
            info.setVisible(true);
            getRootPane().add(info);

            back = new SymfoniaJButton(completeButton);
            back.setBounds((w / 2) - 100, (h / 2) - 50, 200, 30);
            back.addActionListener(this);
            back.setVisible(false);
            getRootPane().add(back);

            progressBar = new JProgressBar();
            progressBar.setBounds(80, (h / 2) - 50, w - 160, 30);
            progressBar.setIndeterminate(true);
            progressBar.setVisible(true);
            getRootPane().add(progressBar);

            hide();

        }
        catch (final Exception e)
        {
            throw new WindowException(e);
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void reset() throws WindowException
    {
        try
        {
            final String workInProgressTitle = this.reader.getString("UiText/WorkInProgressWindowWorking");
            final String workInProgressText = this.reader.getString("UiText/WorkInProgressText");
            title.setText(workInProgressTitle);
            info.setText("<html><center>" + workInProgressText + "</center></html>");
            progressBar.setVisible(true);
            back.setVisible(false);
        }
        catch (final Exception e)
        {
            throw new WindowException(e);
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void ready() throws WindowException
    {
        try
        {
            final String workInProgressTitle = this.reader.getString("UiText/WorkInProgressWindowReady");
            final String workInProgressText = this.reader.getString("UiText/WorkIsDoneText");
            title.setText(workInProgressTitle);
            info.setText("<html><center>" + workInProgressText + "</center></html>");
            progressBar.setVisible(false);
            back.setVisible(true);
        }
        catch (final Exception e)
        {
            throw new WindowException(e);
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void error() throws WindowException
    {
        try
        {
            final String workInProgressTitle = this.reader.getString("UiText/WorkInProgressWindowError");
            final String workInProgressText = this.reader.getString("UiText/WorkHasFailedText");
            title.setText(workInProgressTitle);
            info.setText("<html><center>" + workInProgressText + "</center></html>");
            progressBar.setVisible(false);
            back.setVisible(true);
        }
        catch (final Exception e)
        {
            throw new WindowException(e);
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void setFinishedWindow(final String returnPoint)
    {
        this.returnPoint = returnPoint;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleActionEvent(final ActionEvent aE) throws WindowException
    {
        // Aktion ist beendet
        if (aE.getSource() == back)
        {
            if (returnPoint != null)
            {
                ViewController.getInstance().getWindow(returnPoint).show();
                reset();
                hide();
            }
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
