package eu.jlmb.MapIcon;

import java.awt.Container;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;

import javax.imageio.ImageIO;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.SpringLayout;
import javax.swing.SwingConstants;

/**
 * Class for the first Start of the MapIconator
 * @author Jean Baumgarten
 */
public class FirstStarter implements ActionListener {
	
	private final PrefManager manager;
	private JFrame frame;
	
	/**
	 * Constructor
	 * @param manager of the MapIconator
	 */
	public FirstStarter(PrefManager manager) {
		this.manager = manager;
	}
	
	/**
	 * Builds the GUI of the window
	 */
	public void buildGUI() {
		this.frame = new JFrame("Inizialisierung");
        Container contentPane = this.frame.getContentPane();
        SpringLayout layout = new SpringLayout();
        contentPane.setLayout(layout);
        
        JLabel info = new JLabel("Wähle deine Siedler Version:", SwingConstants.CENTER);
        contentPane.add(info);
        layout.putConstraint(SpringLayout.WEST, info, 30, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, info, -30, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, info, -30, SpringLayout.NORTH, contentPane);
        
        JButton setS6 = new JButton();
        setS6.setName("setS6");
        contentPane.add(setS6);
        layout.putConstraint(SpringLayout.WEST, setS6, 30, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, setS6, 30, SpringLayout.SOUTH, info);
        setS6.addActionListener(this);
        
        JButton setS5 = new JButton();
        setS5.setName("setS5");
        contentPane.add(setS5);
        layout.putConstraint(SpringLayout.EAST, setS5, -30, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, setS5, 30, SpringLayout.SOUTH, info);
        setS5.addActionListener(this);
        
        InputStream stream = WindowWorker.class.getResourceAsStream("/eu/jlmb/S5Icon.png");
        try {
            BufferedImage preview = ImageIO.read(stream);
            setS5.setIcon(new ImageIcon(preview));
            setS5.setBorder(null);
        } catch (IOException e) {
			e.printStackTrace();
        }
        stream = WindowWorker.class.getResourceAsStream("/eu/jlmb/S6Icon.png");
        try {
			BufferedImage preview = ImageIO.read(stream);
            setS6.setIcon(new ImageIcon(preview));
            setS6.setBorder(null);
		} catch (IOException e) {
			e.printStackTrace();
		}
        
        this.frame.setSize(490, 220);
        this.frame.setResizable(false);
        this.frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.frame.setLocationRelativeTo(null);
        this.frame.setVisible(true);
	}

	/**
	 * action listener for the buttons
	 * @param e is the event that triggers the action
	 */
	public void actionPerformed(ActionEvent e) {
		String name = ((JButton) e.getSource()).getName();
		if ("setS6".equals(name)) {
			this.manager.setVersion("Die Siedler - Aufstieg eines Königreichs");
		} else if ("setS5".equals(name)) {
			this.manager.setVersion("Die Siedler - Das Erbe der Könige");
		}
		WindowWorker worker = new WindowWorker(this.manager);
		worker.buildGUI();
		this.frame.dispose();
	}
	
}
