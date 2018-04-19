package twa.symfonia.view.window;

import java.awt.Dimension;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.util.List;

import javax.swing.SwingConstants;
import javax.swing.event.ListSelectionEvent;

import org.jdesktop.swingx.JXLabel;

import twa.symfonia.config.Configuration;
import twa.symfonia.controller.ViewController;
import twa.symfonia.service.xml.XmlReaderInterface;
import twa.symfonia.view.component.SymfoniaJBundle;
import twa.symfonia.view.component.SymfoniaJBundleScrollPane;
import twa.symfonia.view.component.SymfoniaJButton;

/**
 * Fenster zur Auswahl der Kernfunktionen der QSB.
 * 
 * @author mheller
 *
 */
public class BundleSelectionWindow extends AbstractWindow
{
    /**
     * Liste der Bundles
     */
    private List<SymfoniaJBundle> bundleList;

    /**
     * Scrollbox der Bundles
     */
    private SymfoniaJBundleScrollPane bundleScrollPane;

    /**
     * Dimension des Fensters
     */
    protected final Dimension size;

    /**
     * Back Button
     */
    protected final SymfoniaJButton back;

    /**
     * Next Button
     */
    protected final SymfoniaJButton next;

    /**
     * Überschrift
     */
    protected final JXLabel title;

    /**
     * Beschreibung
     */
    protected final JXLabel text;

    /**
     * Select all Button
     */
    protected final SymfoniaJButton select;

    /**
     * Deselect all button
     */
    protected final SymfoniaJButton deselect;

    /**
     * Constructor
     * 
     * @param w Breite
     * @param h Höhe
     * @throws WindowException
     */
    public BundleSelectionWindow(final int w, final int h, final XmlReaderInterface reader) throws WindowException
    {
        super(w, h, reader);
        size = new Dimension(w, h);

        final int titleSize = Configuration.getInteger("defaults.font.title.size");
        final int textSize = Configuration.getInteger("defaults.font.text.size");

        try
        {
            final String backButton = this.reader.getString("UiText/ButtonBack");
            final String nextButton = this.reader.getString("UiText/ButtonNext");
            final String selectButton = this.reader.getString("UiText/ButtonSelect");
            final String deselectButton = this.reader.getString("UiText/ButtonDeselect");
            final String selectTitle = this.reader.getString("UiText/CaptionSelectBundleWindow");
            final String selectText = this.reader.getString("UiText/DescriptionSelectBundleWindow");

            title = new JXLabel(selectTitle);
            title.setHorizontalAlignment(SwingConstants.CENTER);
            title.setBounds(10, 10, w - 20, 30);
            title.setFont(new Font(Font.SANS_SERIF, 1, titleSize));
            title.setVisible(true);
            getRootPane().add(title);

            text = new JXLabel(selectText);
            text.setLineWrap(true);
            text.setVerticalAlignment(SwingConstants.TOP);
            text.setBounds(10, 50, w - 70, h - 300);
            text.setFont(new Font(Font.SANS_SERIF, 0, textSize));
            text.setVisible(true);
            getRootPane().add(text);

            back = new SymfoniaJButton(backButton);
            back.setBounds(25, h - 70, 130, 30);
            back.addActionListener(this);
            back.setVisible(true);
            getRootPane().add(back);

            next = new SymfoniaJButton(nextButton);
            next.setBounds(w - 155, h - 70, 130, 30);
            next.addActionListener(this);
            next.setVisible(true);
            getRootPane().add(next);

            select = new SymfoniaJButton(selectButton);
            select.setBounds((w / 2) - 130, h - 130, 130, 30);
            select.addActionListener(this);
            select.setVisible(true);
            getRootPane().add(select);

            deselect = new SymfoniaJButton(deselectButton);
            deselect.setBounds((w / 2) + 4, h - 130, 130, 30);
            deselect.addActionListener(this);
            deselect.setVisible(true);
            getRootPane().add(deselect);
        } catch (final Exception e)
        {
            throw new WindowException(e);
        }

        getRootPane().setVisible(false);
    }

    /**
     * Gibt die Liste der Bundles zurück.
     * 
     * @return Liste der Bundle
     */
    public List<SymfoniaJBundle> getBundleList()
    {
        return bundleList;
    }

    /**
     * Gibt die Scrollbox zurück.
     * 
     * @return Scrollbox
     */
    public SymfoniaJBundleScrollPane getBundleScrollPane()
    {
        return bundleScrollPane;
    }

    /**
     * Setzt die Liste der bekannten Bundles.
     * 
     * @param bundleList Liste der Bundles
     */
    public void setBundleList(final List<SymfoniaJBundle> bundleList)
    {
        this.bundleList = bundleList;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void show()
    {
        bundleScrollPane = new SymfoniaJBundleScrollPane(size.width - 100, size.height - 220, bundleList);
        bundleScrollPane.setLocation(50, 75);
        bundleScrollPane.setVisible(true);
        getRootPane().add(bundleScrollPane);

        getRootPane().setVisible(true);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleActionEvent(final ActionEvent aE) throws WindowException
    {
        // Zurück
        if (aE.getSource() == back)
        {
            ViewController.getInstance().getWindow("OptionSelectionWindow").show();
            bundleScrollPane.setVisible(false);
            hide();
        }

        // Weiter
        if (aE.getSource() == next)
        {
            ViewController.getInstance().getWindow("AddOnSelectionWindow").show();
            bundleScrollPane.setVisible(false);
            hide();
        }

        // Alle auswählen
        if (aE.getSource() == select)
        {
            bundleScrollPane.selectAll();
        }

        // Alle abwählen
        if (aE.getSource() == deselect)
        {
            bundleScrollPane.deselectAll();
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
