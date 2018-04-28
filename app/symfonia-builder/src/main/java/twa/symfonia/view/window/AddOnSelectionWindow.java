package twa.symfonia.view.window;

import java.awt.Dimension;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.util.List;

import javax.swing.SwingConstants;
import javax.swing.event.ListSelectionEvent;

import org.jdesktop.swingx.JXLabel;

import twa.symfonia.config.Configuration;
import twa.symfonia.service.xml.XmlReaderInterface;
import twa.symfonia.view.component.SymfoniaJAddOn;
import twa.symfonia.view.component.SymfoniaJAddOnScrollPane;
import twa.symfonia.view.component.SymfoniaJBundle;
import twa.symfonia.view.component.SymfoniaJBundleScrollPane;
import twa.symfonia.view.component.SymfoniaJButton;

/**
 * Fenster zur Auswahl der Addons zu selektierten Bundles.
 * 
 * @author mheller
 *
 */
public class AddOnSelectionWindow extends AbstractWindow
{

    /**
     * Singleton instance
     */
    protected static AddOnSelectionWindow instance;

    /**
     * Liste der Bundles
     */
    private List<SymfoniaJAddOn> bundleList;

    /**
     * Scrollbox der Bundles
     */
    private SymfoniaJAddOnScrollPane bundleScrollPane;

    /**
     * Dimension des Fensters
     */
    protected Dimension size;

    /**
     * Back Button
     */
    protected SymfoniaJButton back;

    /**
     * Next Button
     */
    protected SymfoniaJButton next;

    /**
     * Überschrift
     */
    protected JXLabel title;

    /**
     * Beschreibung
     */
    protected JXLabel text;

    /**
     * Select all Button
     */
    protected SymfoniaJButton select;

    /**
     * Deselect all button
     */
    protected SymfoniaJButton deselect;

    /**
     * Constructor
     */
    public AddOnSelectionWindow()
    {
        super();
    }

    /**
     * Initalisiert die Komponenten des Fensters.
     * 
     * @param w Breite
     * @param h Höhe
     * @param reader XML-Reader
     * @throws WindowException
     */
    @Override
    public void initalizeComponents(final int w, final int h, final XmlReaderInterface reader) throws WindowException
    {
        super.initalizeComponents(w, h, reader);
        this.reader = reader;
        size = new Dimension(w, h);

        final int titleSize = Configuration.getInteger("defaults.font.title.size");
        final int textSize = Configuration.getInteger("defaults.font.text.size");

        try
        {
            final String backButton = this.reader.getString("UiText/ButtonBack");
            final String nextButton = this.reader.getString("UiText/ButtonNext");
            final String selectButton = this.reader.getString("UiText/ButtonSelect");
            final String deselectButton = this.reader.getString("UiText/ButtonDeselect");
            final String selectTitle = this.reader.getString("UiText/CaptionSelectAddOnWindow");
            final String selectText = this.reader.getString("UiText/DescriptionSelectAddOnWindow");

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
        }
        catch (final Exception e)
        {
            throw new WindowException(e);
        }

        getRootPane().setVisible(false);
    }

    /**
     * Gibt die Singleton-Instanz dieses Fensters zurück.
     * 
     * @return Singleton
     */
    public static AddOnSelectionWindow getInstance()
    {
        if (instance == null)
        {
            instance = new AddOnSelectionWindow();
        }
        return instance;
    }

    /**
     * Behandelt die Abhängigkeiten der Addons. Addons mit unbefriedigten
     * Abhängigkeiten werden deaktiviert.
     */
    private void disableUnsatisfiedAddOns()
    {
        for (final SymfoniaJAddOn a : getBundleList())
        {
            final BundleSelectionWindow bundleSelection = BundleSelectionWindow.getInstance();
            final SymfoniaJBundleScrollPane bundleScrollBox = bundleSelection.getBundleScrollPane();
            boolean dependenciesSatisfied = true;

            final List<String> dependencies = a.getDependencies();
            for (final String d : dependencies)
            {
                // Behandele Bundles
                final SymfoniaJBundle bundle = bundleScrollBox.getBundle(d);
                if (bundle != null && (bundle.isEnabled() == false || bundle.isChecked() == false))
                {
                    dependenciesSatisfied = false;
                }

                // Behandle Addons
                final SymfoniaJAddOn addon = bundleScrollPane.getBundle(d);
                if (addon != null && (addon.isEnabled() == false || addon.isChecked() == false))
                {
                    dependenciesSatisfied = false;
                }
            }

            if (!dependenciesSatisfied)
            {
                bundleScrollPane.getBundle(a.getID()).setUsable(false);
            }
            else
            {
                bundleScrollPane.getBundle(a.getID()).setUsable(true);
            }
        }
    }

    /**
     * Gibt das Selektionsfeld mit allen seinen Bundles zurück.
     * 
     * @return Bundle-Selektor
     */
    public SymfoniaJAddOnScrollPane getBundleScrollPane()
    {
        return bundleScrollPane;
    }

    /**
     * Gibt die Liste der Bundles zurück.
     * 
     * @return Liste der Bundles
     */
    public List<SymfoniaJAddOn> getBundleList()
    {
        return bundleList;
    }

    /**
     * Setzt die Liste der genutzten Bundles.
     * 
     * @param bundleList Liste der Bundles
     */
    public void setBundleList(final List<SymfoniaJAddOn> bundleList)
    {
        this.bundleList = bundleList;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void show()
    {
        bundleScrollPane = new SymfoniaJAddOnScrollPane(size.width - 100, size.height - 220, bundleList);
        bundleScrollPane.setLocation(50, 75);
        bundleScrollPane.setVisible(true);
        getRootPane().add(bundleScrollPane);

        disableUnsatisfiedAddOns();

        getRootPane().setVisible(true);

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
    public void handleActionEvent(final ActionEvent aE) throws WindowException
    {
        // Zurück
        if (aE.getSource() == back)
        {
            BundleSelectionWindow.getInstance().show();
            bundleScrollPane.setVisible(false);
            hide();
        }

        // Weiter
        else if (aE.getSource() == next)
        {
            bundleScrollPane.setVisible(false);
            hide();
            SaveQsbWindow.getInstance().show();
        }

        // Alle auswählen
        else if (aE.getSource() == select)
        {
            bundleScrollPane.selectAll();
            disableUnsatisfiedAddOns();
        }

        // Alle abwählen
        else if (aE.getSource() == deselect)
        {
            bundleScrollPane.deselectAll();
            disableUnsatisfiedAddOns();
        }

        // Checkboxen
        else
        {
            disableUnsatisfiedAddOns();
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
