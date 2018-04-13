package view.window;

import java.awt.Font;
import java.awt.event.ActionEvent;

import javax.swing.SwingConstants;
import javax.swing.event.ListSelectionEvent;

import org.jdesktop.swingx.JXLabel;

import config.Configuration;
import controller.ViewController;
import view.component.SymfoniaJButton;

/**
 * 
 * @author mheller
 *
 */
public class SelfUpdateWindow extends AbstractWindow {
    /**
     * Titel des Fensters (Label).
     */
    private final JXLabel title;

    /**
     * Beschreibungstext des Fensters.
     */
    private final JXLabel text;

    /**
     * Buttun zum anzeigen des nächsten Fensters.
     */
    private final SymfoniaJButton updateMaster;

    /**
     * Beschreibungstext des Fensters.
     */
    private final JXLabel updateMasterLabel;

    /**
     * Buttun zum anzeigen des nächsten Fensters.
     */
    private final SymfoniaJButton updateDev;

    /**
     * Beschreibungstext des Fensters.
     */
    private final JXLabel updateDevLabel;

    /**
     * Buttun zum anzeigen des vorherigen Fensters.
     */
    private final SymfoniaJButton back;

    /**
     * {@inheritDoc}
     */
    public SelfUpdateWindow(final int w, final int h) {
        super(w, h);

        final int titleSize = Configuration.getInteger("defaults.font.title.size");
        final int textSize = Configuration.getInteger("defaults.font.text.size");

        final String updateTitle = Configuration.getString("defaults.label.title.update");
        final String updateText = Configuration.getString("defaults.label.text.update");
        final String updateButton = Configuration.getString("defaults.caption.button.update");
        final String backButton = Configuration.getString("defaults.caption.button.back");
        final String updateMasterDesc = Configuration.getString("defaults.label.update.master");
        final String updateDevDesc = Configuration.getString("defaults.label.update.development");

        title = new JXLabel(updateTitle);
        title.setHorizontalAlignment(SwingConstants.CENTER);
        title.setBounds(10, 10, w - 20, 30);
        title.setFont(new Font(Font.SANS_SERIF, 1, titleSize));
        title.setVisible(true);
        getRootPane().add(title);

        text = new JXLabel(updateText);
        text.setLineWrap(true);
        text.setVerticalAlignment(SwingConstants.TOP);
        text.setBounds(10, 50, w - 70, h - 300);
        text.setFont(new Font(Font.SANS_SERIF, 0, textSize));
        text.setVisible(true);
        getRootPane().add(text);

        updateMaster = new SymfoniaJButton(updateButton);
        updateMaster.setBounds((w / 2) - 100, (int) (h * 0.35) + 15, 200, 30);
        updateMaster.addActionListener(this);
        updateMaster.setVisible(true);
        getRootPane().add(updateMaster);

        updateMasterLabel = new JXLabel(updateMasterDesc);
        updateMasterLabel.setVerticalAlignment(SwingConstants.TOP);
        updateMasterLabel.setHorizontalAlignment(SwingConstants.CENTER);
        updateMasterLabel.setBounds(10, (int) (h * 0.35) - 15, w - 40, 30);
        updateMasterLabel.setFont(new Font(Font.SANS_SERIF, 0, textSize));
        updateMasterLabel.setVisible(true);
        getRootPane().add(updateMasterLabel);

        updateDev = new SymfoniaJButton(updateButton);
        updateDev.setBounds((w / 2) - 100, (int) (h * 0.55) + 15, 200, 30);
        updateDev.addActionListener(this);
        updateDev.setVisible(true);
        getRootPane().add(updateDev);

        updateDevLabel = new JXLabel(updateDevDesc);
        updateDevLabel.setVerticalAlignment(SwingConstants.TOP);
        updateDevLabel.setHorizontalAlignment(SwingConstants.CENTER);
        updateDevLabel.setBounds(10, (int) (h * 0.55) - 15, w - 40, 30);
        updateDevLabel.setFont(new Font(Font.SANS_SERIF, 0, textSize));
        updateDevLabel.setVisible(true);
        getRootPane().add(updateDevLabel);

        back = new SymfoniaJButton(backButton);
        back.setBounds(25, h - 70, 130, 30);
        back.addActionListener(this);
        back.setVisible(true);
        getRootPane().add(back);

        getRootPane().setVisible(false);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleActionEvent(final ActionEvent aE) {
        // Zurück
        if (aE.getSource() == back) {
            ViewController.getInstance().getWindow("OptionSelectionWindow").show();
            hide();
        }

        // Update Master
        if (aE.getSource() == updateMaster) {
            ViewController.getInstance().selfUpdateMaster();
        }

        // Update Dev
        if (aE.getSource() == updateDev) {
            ViewController.getInstance().selfUpdateDevelopment();
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleValueChanged(final ListSelectionEvent a) {

    }

}
