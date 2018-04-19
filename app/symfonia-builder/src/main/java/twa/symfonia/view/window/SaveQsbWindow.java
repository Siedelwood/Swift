package twa.symfonia.view.window;

import java.awt.Font;
import java.awt.event.ActionEvent;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JCheckBox;
import javax.swing.JLabel;
import javax.swing.SwingConstants;
import javax.swing.event.ListSelectionEvent;

import org.jdesktop.swingx.JXLabel;

import twa.symfonia.config.Configuration;
import twa.symfonia.controller.ViewController;
import twa.symfonia.service.qsb.QsbPackagingException;
import twa.symfonia.service.qsb.QsbPackagingInterface;
import twa.symfonia.service.xml.XmlReaderInterface;
import twa.symfonia.view.component.SymfoniaJBundle;

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
    private final JCheckBox saveScriptsCheckbox;

    /**
     * 
     */
    private JCheckBox minifyQsbCheckbox;

    /**
     * 
     */
    private JCheckBox saveExampleCheckbox;

    /**
     * 
     */
    private JCheckBox copyDocCheckbox;

    /**
     * 
     */
    private QsbPackagingInterface packager;

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

	    // Options ////////////////////////////////////////

	    final String useBaseScripts = this.reader.getString("UiText/SaveBaseScripts");
	    final String useExampleScripts = this.reader.getString("UiText/SaveExampleScripts");
	    final String useMinifyQsb = this.reader.getString("UiText/MinifyQsbScript");
	    final String useCopyDocu = this.reader.getString("UiText/CopyDocumentation");

	    saveScriptsCheckbox = new JCheckBox();
	    saveScriptsCheckbox.setBounds(40, h - 140, 20, 20);
	    saveScriptsCheckbox.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
	    saveScriptsCheckbox.setVisible(true);
	    getRootPane().add(saveScriptsCheckbox);

	    final JLabel saveScriptLabel = new JLabel(useBaseScripts);
	    saveScriptLabel.setBounds(65, h - 140, w - 110, 20);
	    saveScriptLabel.setFont(new Font(Font.SANS_SERIF, 0, textSize));
	    saveScriptLabel.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
	    saveScriptLabel.setVisible(true);
	    getRootPane().add(saveScriptLabel);

	    saveExampleCheckbox = new JCheckBox();
	    saveExampleCheckbox.setBounds(40, h - 160, 20, 20);
	    saveExampleCheckbox.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
	    saveExampleCheckbox.setVisible(true);
	    getRootPane().add(saveExampleCheckbox);

	    final JLabel saveExampleLabel = new JLabel(useExampleScripts);
	    saveExampleLabel.setBounds(65, h - 160, w - 110, 20);
	    saveExampleLabel.setFont(new Font(Font.SANS_SERIF, 0, textSize));
	    saveExampleLabel.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
	    saveExampleLabel.setVisible(true);
	    getRootPane().add(saveExampleLabel);

	    minifyQsbCheckbox = new JCheckBox();
	    minifyQsbCheckbox.setBounds(40, h - 180, 20, 20);
	    minifyQsbCheckbox.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
	    minifyQsbCheckbox.setVisible(true);
	    getRootPane().add(minifyQsbCheckbox);

	    final JLabel minifyQsbLabel = new JLabel(useMinifyQsb);
	    minifyQsbLabel.setBounds(65, h - 180, w - 110, 20);
	    minifyQsbLabel.setFont(new Font(Font.SANS_SERIF, 0, textSize));
	    minifyQsbLabel.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
	    minifyQsbLabel.setVisible(true);
	    getRootPane().add(minifyQsbLabel);

	    copyDocCheckbox = new JCheckBox();
	    copyDocCheckbox.setBounds(40, h - 120, 20, 20);
	    copyDocCheckbox.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
	    copyDocCheckbox.setVisible(true);
	    getRootPane().add(copyDocCheckbox);

	    final JLabel copyDocLabel = new JLabel(useCopyDocu);
	    copyDocLabel.setBounds(65, h - 120, w - 110, 20);
	    copyDocLabel.setFont(new Font(Font.SANS_SERIF, 0, textSize));
	    copyDocLabel.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
	    copyDocLabel.setVisible(true);
	    getRootPane().add(copyDocLabel);

	    fileNameField.setText(fileNameField.getText() + "/Symfonia");

	    // Not implemented
	    saveExampleCheckbox.setEnabled(false);
	    minifyQsbCheckbox.setEnabled(false);
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
    public void onSelectionFinished(File selected)
    {
	selected = (selected == null) ? new File(".") : selected;
	fileNameField.setText(unixfyPath(selected.getAbsolutePath()) + "/Symfonia");
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
	    final List<String> files = null;

	    try
	    {
		packager.pack(getScriptFiles(), fileNameField.getText(), copyDocCheckbox.isSelected(),
			saveScriptsCheckbox.isSelected(), saveExampleCheckbox.isSelected(),
			minifyQsbCheckbox.isSelected());
	    }
	    catch (final QsbPackagingException e)
	    {
		throw new WindowException(e);
	    }
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
     * 
     * @return
     */
    private List<String> getScriptFiles()
    {
	final List<String> files = new ArrayList<>();
	files.add("/core.lua");

	final BundleSelectionWindow bundleWindow = (BundleSelectionWindow) ViewController.getInstance()
		.getWindow("BundleSelectionWindow");
	for (final SymfoniaJBundle b : bundleWindow.getBundleList())
	{
	    if (b.isChecked())
	    {
		files.add("/bundles/" + b.getID() + "/source.lua");
	    }
	}

	return files;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleValueChanged(final ListSelectionEvent a)
    {
    }

    /**
     * 
     * @param packager
     */
    public void setPackager(final QsbPackagingInterface packager)
    {
	this.packager = packager;
    }

}
