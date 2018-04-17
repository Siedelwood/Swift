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
import twa.symfonia.view.component.SymfoniaJBundle;
import twa.symfonia.view.component.SymfoniaJBundleScrollPane;
import twa.symfonia.view.component.SymfoniaJButton;

/**
 * 
 * @author mheller
 *
 */
public class BundleSelectionWindow extends AbstractWindow
{
    /**
     * 
     */
    private List<SymfoniaJBundle> bundleList;

    /**
     * 
     */
    private SymfoniaJBundleScrollPane bundleScrollPane;

    private final Dimension size;

    private final SymfoniaJButton back;

    private final SymfoniaJButton next;

    private final JXLabel title;

    private final JXLabel text;

    private final SymfoniaJButton select;

    private final SymfoniaJButton deselect;

    /**
     * 
     * @param w
     * @param h
     */
    public BundleSelectionWindow(final int w, final int h)
    {
        super(w, h);
        size = new Dimension(w, h);

        final int titleSize = Configuration.getInteger("defaults.font.title.size");
        final int textSize = Configuration.getInteger("defaults.font.text.size");

        final String backButton = Configuration.getString("defaults.caption.button.back");
        final String nextButton = Configuration.getString("defaults.caption.button.next");
        final String selectButton = Configuration.getString("defaults.caption.button.select");
        final String deselectButton = Configuration.getString("defaults.caption.button.deselect");
        final String selectTitle = Configuration.getString("defaults.label.title.selectBundle");
        final String selectText = Configuration.getString("defaults.label.text.selectBundle");

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
        select.setBounds((w/2) -130, h - 130, 130, 30);
        select.addActionListener(this);
        select.setVisible(true);
        getRootPane().add(select);
        
        deselect = new SymfoniaJButton(deselectButton);
        deselect.setBounds((w/2) +4, h - 130, 130, 30);
        deselect.addActionListener(this);
        deselect.setVisible(true);
        getRootPane().add(deselect);
        
        getRootPane().setVisible(false);
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
     * 
     * @return
     */
    public List<SymfoniaJBundle> getBundleList()
    {
        return bundleList;
    }

    /**
     * 
     * @param bundleList
     */
    public void setBundleList(final List<SymfoniaJBundle> bundleList)
    {
        this.bundleList = bundleList;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleActionEvent(final ActionEvent aE) throws WindowException
    {
        // Zurück
        if (aE.getSource() == back) {
            ViewController.getInstance().getWindow("OptionSelectionWindow").show();
            bundleScrollPane.setVisible(false);
            hide();
        }
        
        // Weiter
        if (aE.getSource() == next) {
            System.out.println("Display addon selection");
            ViewController.getInstance().getWindow("AddOnSelectionWindow").show();
            bundleScrollPane.setVisible(false);
            hide();
        }
        
        // Alle auswählen
        if (aE.getSource() == select) {
            System.out.println("Select all");
            bundleScrollPane.selectAll();
        }
        
        // Alle abwählen
        if (aE.getSource() == deselect) {
            System.out.println("Deselect all");
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
