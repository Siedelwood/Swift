package eu.jlmb.MapIcon;

import java.awt.Component;
import java.awt.Container;
import java.awt.Graphics2D;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.prefs.Preferences;

import javax.imageio.ImageIO;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.SpringLayout;
import javax.swing.filechooser.FileNameExtensionFilter;

/**
 * 
 * @author Jean Baumgarten
 *
 */
public class WindowWorker implements ActionListener {

	private JLabel originalDummy = null;
	private JLabel changedDummy = null;
	private BufferedImage image = null;
	private BufferedImage changedImage = null;
	private BufferedImage imageFrame = null;
	private Component frame = null;
	private JLabel transformerPreview = null;
	private JComboBox<String> iconType = null;
	private final String[] iconNames;
	private Preferences preferences;
	private String path;
	
	/**
	 * Constructor of the Working window
	 */
	public WindowWorker() {
		String[] icons = {"Ring", "Original"};
		this.iconNames = icons;
		this.preferences = Preferences.userNodeForPackage(WindowWorker.class);
		this.path = this.preferences.get("dummyPath", "");
		if ("".equals(this.path)) {
			this.path = System.getProperty("user.home") + File.separator;
			this.path += "Documents/DIE SIEDLER - Aufstieg eines Königreichs/MapEditor/Temp/Dummy.png";
		}
	}
	
	/**
	 * Builds the GUI of the window
	 */
	public void buildGUI() {
		JFrame frame = new JFrame("Siedelwood Mapiconator");
        Container contentPane = frame.getContentPane();
        SpringLayout layout = new SpringLayout();
        contentPane.setLayout(layout);

        // make labels to contain the pictures
        this.originalDummy = new JLabel();
        contentPane.add(this.originalDummy);
        layout.putConstraint(SpringLayout.WEST, this.originalDummy, 30, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.originalDummy, 30, SpringLayout.NORTH, contentPane);

        this.changedDummy = new JLabel();
        contentPane.add(this.changedDummy);
        layout.putConstraint(SpringLayout.WEST, this.changedDummy, 30, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.SOUTH, this.changedDummy, -30, SpringLayout.SOUTH, contentPane);

        this.transformerPreview = new JLabel();
        contentPane.add(this.transformerPreview);
        layout.putConstraint(SpringLayout.EAST, this.transformerPreview, -30, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.transformerPreview, 30, SpringLayout.NORTH, contentPane);
        
        // set content in the picture labels
        this.iconType = new JComboBox<String>(this.iconNames);
        this.iconType.setName("iconType");
        contentPane.add(this.iconType);
        layout.putConstraint(SpringLayout.EAST, this.iconType, -30, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.WEST, this.iconType, -130, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.iconType, 30, SpringLayout.SOUTH, this.transformerPreview);
        this.iconType.addActionListener(this);
        
        this.iconChanged();
        
        File file = new File(this.path);
        this.loadStartImage(file);

        // make the buttons
        JButton restart = new JButton("Neu anfangen");
        restart.setName("restart");
        restart.setToolTipText("Überschreibe das Zielbild mit dem Startbild.");
        contentPane.add(restart);
        layout.putConstraint(SpringLayout.WEST, restart, 70, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, restart, 30, SpringLayout.SOUTH, this.originalDummy);
        restart.addActionListener(this);
        
        JButton landscape = new JButton("Landschaft");
        landscape.setName("landscape");
        landscape.setToolTipText("Schneidet alles weg, was keine Landschaft ist.");
        contentPane.add(landscape);
        layout.putConstraint(SpringLayout.EAST, landscape, -10, SpringLayout.WEST, this.iconType);
        layout.putConstraint(SpringLayout.WEST, landscape, -110, SpringLayout.WEST, this.iconType);
        layout.putConstraint(SpringLayout.NORTH, landscape, 30, SpringLayout.SOUTH, this.transformerPreview);
        landscape.addActionListener(this);
        
        JButton overlapp = new JButton("Hinzufügen");
        overlapp.setName("overlapp");
        overlapp.setToolTipText("Malt den gewählten Rahmen auf das Zielbild.");
        contentPane.add(overlapp);
        layout.putConstraint(SpringLayout.EAST, overlapp, -30, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.WEST, overlapp, -130, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, overlapp, 10, SpringLayout.SOUTH, this.iconType);
        overlapp.addActionListener(this);
        
        JButton cutout = new JButton("Ausfüllen");
        cutout.setName("cutout");
        cutout.setToolTipText("Füllt den benutzten Rahmen mit dem Inhalt des Startbildes.");
        contentPane.add(cutout);
        layout.putConstraint(SpringLayout.EAST, cutout, -10, SpringLayout.WEST, overlapp);
        layout.putConstraint(SpringLayout.WEST, cutout, -110, SpringLayout.WEST, overlapp);
        layout.putConstraint(SpringLayout.NORTH, cutout, 10, SpringLayout.SOUTH, this.iconType);
        cutout.addActionListener(this);
        
        JButton save = new JButton("Speichere auf Schreibtisch");
        save.setName("saveDesktop");
        save.setToolTipText("Speichert das erstellte Bild im richtigen Format auf dem Schreibtisch.");
        contentPane.add(save);
        layout.putConstraint(SpringLayout.EAST, save, -30, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.WEST, save, -240, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.SOUTH, save, -30, SpringLayout.SOUTH, contentPane);
        save.addActionListener(this);
        
        JButton save2 = new JButton("Speichere in Downloads");
        save2.setName("saveDownload");
        save2.setToolTipText("Speichert das erstellte Bild im richtigen Format im Download-Ordner.");
        contentPane.add(save2);
        layout.putConstraint(SpringLayout.EAST, save2, -30, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.WEST, save2, -240, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.SOUTH, save2, -10, SpringLayout.NORTH, save);
        save2.addActionListener(this);
        
        JButton save3 = new JButton("Speichere in ...");
        save3.setName("saveOwn");
        save3.setToolTipText("Speichert das erstellte Bild im richtigen Format an einem selbst wählbaren Ort.");
        contentPane.add(save3);
        layout.putConstraint(SpringLayout.EAST, save3, -30, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.WEST, save3, -240, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.SOUTH, save3, -10, SpringLayout.NORTH, save2);
        save3.addActionListener(this);

        // finalize window and show it
        int height = 180 + this.image.getHeight() * 2;
        frame.setSize(500, height > 300 ? height : 300);
        frame.setResizable(false);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
	}
	
	/**
	 * puts the image stored in Dummy.png into the window
	 * @param inputFile is the Dummy.png file
	 */
	private void loadStartImage(File inputFile) {
		File file = inputFile;
        if (file.exists()) {
        	this.trySetStartImages(file);
        } else {
        	String question = "Sollte der Pfad zu Dummy.png auf Ihrem System anders als erwartet sein,";
        	question += " können Sie diesen nun angeben.";
            String title = "Dummy.png konnte nicht gefunden werden!";
            int option = JOptionPane.showConfirmDialog(null, question, title, JOptionPane.CANCEL_OPTION);
            if (option == JOptionPane.OK_OPTION) {
            	JFileChooser opener = new JFileChooser();
                opener.setFileSelectionMode(JFileChooser.FILES_ONLY);
                opener.setFileFilter(new FileNameExtensionFilter("PNG-Images", "png"));
                opener.setAcceptAllFileFilterUsed(false);
                int returnVal = opener.showOpenDialog(this.frame);
                if (returnVal == JFileChooser.APPROVE_OPTION) {
                    file = opener.getSelectedFile();
                    if (file.exists()) {
                    	this.preferences.put("dummyPath", file.getPath());
                    }
                    this.trySetStartImages(file);
                }
            } else {
            	this.originalDummy.setText("Fehler, Datei unauffindbar");
            }
        }
	}
	
	/**
	 * reads in the given file and puts it on the labels that should show the Dummy.png and how it has changed
	 * @param file
	 */
	private void trySetStartImages(File file) {
		try {
            BufferedImage dummy = ImageIO.read(file);
            this.image = dummy;
            this.changedImage = copyImage(dummy);
            this.originalDummy.setIcon(new ImageIcon(dummy));
            this.changedDummy.setIcon(new ImageIcon(dummy));
        } catch (IOException e) {
            this.originalDummy.setText(e.getLocalizedMessage());
        }
	}

	/**
	 * action listener for the buttons
	 * @param e is the event that triggers the action
	 */
	public void actionPerformed(ActionEvent e) {
		String name = "";
		if (e.getSource().getClass() == JButton.class) {
			name = ((JButton) e.getSource()).getName();
		} else if (e.getSource().getClass() == JComboBox.class) {
			name = ((JComboBox) e.getSource()).getName();
		}
		if ("restart".equals(name)) {
			this.restart();
		} else if ("overlapp".equals(name)) {
			this.overlapp();
		} else if ("cutout".equals(name)) {
			this.cutout();
		} else if ("iconType".equals(name)) {
			this.iconChanged();
		} else if ("landscape".equals(name)) {
			this.cutLandscape();
		} else if ("saveDesktop".equals(name)) {
			this.saveOnDesktop();
		} else if ("saveDownload".equals(name)) {
			this.saveInDownloads();
		} else if ("saveOwn".equals(name)) {
			this.saveOnYourOwn();
		}
	}
	
	/**
	 * action behind the restart button
	 * loads Dummy.png again
	 */
	private void restart() {
        File file = new File(this.path);
		this.trySetStartImages(file);
		//this.changedDummy.setIcon(new ImageIcon(this.image));
		//this.changedImage = copyImage(this.image);
	}
	
	/**
	 * action behind the overlapp button
	 * puts the current image frame onto the image
	 */
	private void overlapp() {
		IconCreater creater = new IconCreater(this.changedImage);
		creater.addOverlappImage(this.imageFrame);
		this.changedImage = creater.getIcon();
		this.changedDummy.setIcon(new ImageIcon(this.changedImage));
	}
	
	/**
	 * action behind the cutout button
	 * puts the current image frame onto the image,
	 * after cutting out the landscape of the image itself
	 */
	private void cutout() {
		IconCreater creater = new IconCreater(this.changedImage);
		creater.addCutOutImage(this.imageFrame);
		this.changedImage = creater.getIcon();
		this.changedDummy.setIcon(new ImageIcon(this.changedImage));
	}
	
	/**
	 * action when the combo box has been changed
	 * reloads a new image frame
	 */
	private void iconChanged() {
		int index = this.iconType.getSelectedIndex();
		InputStream stream = WindowWorker.class.getResourceAsStream("/eu/jlmb/dummy_" + iconNames[index] + ".png");
        try {
            BufferedImage preview = ImageIO.read(stream);
            this.imageFrame = preview;
            this.transformerPreview.setIcon(new ImageIcon(preview));
        } catch (IOException e) {
            this.transformerPreview.setText(e.getLocalizedMessage());
        }
	}
	
	/**
	 * action behind the landscape button
	 * cuts out the landscape from the image
	 */
	private void cutLandscape() {
		IconCreater creater = new IconCreater(this.changedImage);
		creater.cutOutLandscape();
		this.changedImage = creater.getIcon();
		this.changedDummy.setIcon(new ImageIcon(this.changedImage));
	}
	
	/**
	 * saves the generated picture on the desktop
	 */
	private void saveOnDesktop() {
		String path = System.getProperty("user.home") + File.separator;
        path += "Desktop/mapicon.png";
        File file = new File(path);
        this.carefullSave(file);
	}
	
	/**
	 * saves the generated picture in the download folder
	 */
	private void saveInDownloads() {
		String path = System.getProperty("user.home") + File.separator;
        path += "Downloads/mapicon.png";
        File file = new File(path);
        this.carefullSave(file);
	}
	
	/**
	 * saves the generated picture in the wanted location
	 * but checks before it it exists already
	 * @param file
	 */
	private void carefullSave(File file) {
		if (file.exists()) {
			String question = "Die Datei existiert bereits an der Speicherstelle. Soll sie überschrieben werden?";
            String title = "Hilfe, ich weiß nicht was tun!";
            int option = JOptionPane.showConfirmDialog(null, question, title, JOptionPane.CANCEL_OPTION);
            if (option == JOptionPane.OK_OPTION) {
            	this.finalSaving(file);
            }
		} else {
			this.finalSaving(file);
		}
		
	}
	
	/**
	 * saves the file at a user chosen place
	 */
	private void saveOnYourOwn() {
		JFileChooser saver = new JFileChooser();
		saver.setFileSelectionMode(JFileChooser.FILES_ONLY);
        saver.setFileFilter(new FileNameExtensionFilter("PNG-Images", "png"));
        saver.setAcceptAllFileFilterUsed(false);
        int returnVal = saver.showSaveDialog(this.frame);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
            File file = saver.getSelectedFile();
            this.finalSaving(file);
        }
	}
	
	/**
	 * saves the generated image at the given file position
	 * @param file where to save the image
	 */
	private void finalSaving(File file) {
		try {
			ImageIO.write(IconCreater.makeOutputImage(this.changedImage), "png", file);
		} catch (IOException e) {
			JOptionPane.showMessageDialog(null, e.getLocalizedMessage());
		}
	}
	
	/**
	 * creates a deep copy of a buffered image
	 * @param image to be copied
	 * @return copy of the image
	 */
	private static BufferedImage copyImage(BufferedImage image) {
	    BufferedImage newImage = new BufferedImage(image.getWidth(), image.getHeight(), image.getType());
	    Graphics2D graphic = newImage.createGraphics();
	    graphic.drawImage(image, 0, 0, null);
	    graphic.dispose();
	    return newImage;
	}
	
}
