package eu.jlmb.CutsceneAssistent;

import java.awt.Color;
import java.awt.Container;
import java.awt.Dialog;
import java.awt.Font;
import java.awt.Window.Type;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.text.NumberFormat;
import java.util.ArrayList;

import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JDialog;
import javax.swing.JFormattedTextField;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.SpringLayout;
import javax.swing.SwingConstants;
import javax.swing.border.MatteBorder;
import javax.swing.text.NumberFormatter;

/**
 * BarEvent Event
 * @author Jean Baumgarten
 */
public class TextEvent implements Event, ActionListener {
	
	private int eventType = Static.TextEvent;

	private int time = 0;
	private int csNr = 0;
	private boolean show = true;
	private boolean big = true;
	private boolean black = true;
	private String text = "Text";
	private String title = "Titel";
	private boolean centered = false;
	private int sorter = -1;

	private boolean changeMode;
	private JFormattedTextField csField;
	private JFormattedTextField timeField;
	private JTextArea textField;
	private JTextField titleField;
	private JCheckBox centerBox;
	private JCheckBox showBox;
	private JCheckBox bigBox;
	private JCheckBox blackBox;
	private Event initial;

	private JDialog frame;
	private Workbench bench;

	/**
	 * Constructor
	 */
	public TextEvent() { }

	/**
	 * Gives the EventType
	 * @return integer defining the EventType
	 */
	public int eventType() {
		return this.eventType;
	}

	/**
	 * Index of the Event
	 * @return the index
	 */
	public int getSorter() {
		return this.sorter;
	}

	/**
	 * Set sorter element
	 * @param sorter is int
	 */
	public void setSorter(int sorter) {
		this.sorter = sorter;
	}

	/**
	 * Getter for the cutscene number
	 * @return integer
	 */
	public int getCSNr() {
		return this.csNr;
	}

	/**
	 * Setter for the cutscene number
	 * @param number of the cutscene
	 */
	public void setCSNr(int number) {
		this.csNr = number;
	}

	/**
	 * Getter for the event time
	 * @return time
	 */
	public int getTime() {
		return this.time;
	}

	/**
	 * Setter for the event time
	 * @param time of event
	 */
	public void setTime(int time) {
		this.time = time;
	}

	/**
	 * Getter for the Informations
	 * @return Informations
	 */
	public String getInfo() {
		String info = "Zeige ";
		if (this.show) {
			if (this.big) {
				info += "breite ";
			} else {
				info += "dünne ";
			}
			if (this.black) {
				info += "schwarze Balken";
			} else {
				info += "transparente Balken";
			}
		} else {
			info += "keine Balken";
		}
		info += " und ";
		if ("".equals(this.text) && "".equals(this.title)) {
			info += "keinen Text.";
		} else {
			if (this.centered) {
				info += "zentriert ";
			}
			info += "den Text mit Titel \"" + this.title + "\" an.";
		}
		return info;
	}

	/**
	 * Gives the XML data for finishing
	 * @return ArrayList<String> containing the XML data
	 */
	public ArrayList<String> getXML() {
		ArrayList<String> xml = new ArrayList<String>();
		xml.add("    <Event classname=\"ECam::CCutsceneEventScript\">");
        xml.add("      <EventType>2</EventType>");
        xml.add("      <Turn>" + this.time + "</Turn>");
        xml.add("      <Name>SCRIPT_EVENT</Name>");
        xml.add("      <PositionX>0.</PositionX>");
        xml.add("      <PositionY>0.</PositionY>");
        xml.add("      <PositionZ>0.</PositionZ>");
        xml.add("      <LookAtX>0.</LookAtX>");
        xml.add("      <LookAtY>0.</LookAtY>");
        xml.add("      <LookAtZ>0.</LookAtZ>");
        String data = "'" + this.text + "', '" + this.title + "', " + this.centered + ", ";
        data += "" + this.show + ", " + this.big + ", " + this.black;
        xml.add("      <Script>AddOnGameCutscenes.Local:ShowText(" + data + ")</Script>");
        xml.add("    </Event>");
		return xml;
	}

	/**
	 * Generates a copy of the Event
	 * @return Event
	 */
	public Event copy() {
		TextEvent event = new TextEvent();
		event.time = this.time;
		event.show = this.show;
		event.big = this.big;
		event.black = this.black;
		event.text = this.text;
		event.title = this.title;
		event.centered = this.centered;
		event.csNr = this.csNr;
		event.sorter = this.sorter;
		return event;
	}
	
	/**
	 * GUI-Constructor for new or change event
	 * @param bench for giving back data
	 * @param isChanging is an Event if one has to be changed
	 */
	public void gui(Workbench bench, boolean isChanging) {
		this.changeMode = isChanging;
		this.bench = bench;
		this.initial = this.copy();
		String title = "";
		if (isChanging) {
			title += "Ändere TextEvent";
		} else {
			title += "Neues TextEvent";
		}
		
		this.frame = new JDialog(this.bench.getFrame(), title, Dialog.ModalityType.APPLICATION_MODAL);
        this.frame.setType(Type.UTILITY);
        Container contentPane = this.frame.getContentPane();
        SpringLayout layout = new SpringLayout();
        contentPane.setLayout(layout);
        contentPane.setBackground(Static.background);
        MatteBorder border = new MatteBorder(3, 3, 2, 2, Static.uiBorder);
        
        JLabel label = new JLabel(title);
        label.setFont(new Font("Calibri", Font.BOLD, 24));
        label.setForeground(Static.uiBorder);
        label.setHorizontalAlignment(SwingConstants.CENTER);
        layout.putConstraint(SpringLayout.WEST, label, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, label, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, label, 20, SpringLayout.NORTH, contentPane);
        contentPane.add(label);
        
        JLabel labelCS = new JLabel("Cutscene Nummer");
        layout.putConstraint(SpringLayout.WEST, labelCS, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, labelCS, 170, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, labelCS, 20, SpringLayout.SOUTH, label);
        contentPane.add(labelCS);
        
        JLabel labelTime = new JLabel("Zeit");
        labelTime.setHorizontalAlignment(SwingConstants.RIGHT);
        layout.putConstraint(SpringLayout.WEST, labelTime, -170, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.EAST, labelTime, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, labelTime, 20, SpringLayout.SOUTH, label);
        contentPane.add(labelTime);
		
		NumberFormat longFormat = NumberFormat.getIntegerInstance();

		NumberFormatter numberFormatter = new NumberFormatter(longFormat);
		numberFormatter.setAllowsInvalid(false);
		numberFormatter.setMinimum(0);

		this.csField = new JFormattedTextField(numberFormatter);
		this.csField.setText("" + this.csNr);
        layout.putConstraint(SpringLayout.WEST, this.csField, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.csField, 170, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.csField, 10, SpringLayout.SOUTH, labelCS);
		contentPane.add(this.csField);
		
		this.timeField = new JFormattedTextField(numberFormatter);
		this.timeField.setText("" + this.time);
        layout.putConstraint(SpringLayout.WEST, this.timeField, -170, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.timeField, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.timeField, 10, SpringLayout.SOUTH, labelTime);
		contentPane.add(this.timeField);
		
		this.titleField = new JTextField("");
		this.titleField.setText(this.title);
        layout.putConstraint(SpringLayout.WEST, this.titleField, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.titleField, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.titleField, 20, SpringLayout.SOUTH, this.timeField);
		contentPane.add(this.titleField);
		
		this.textField = new JTextArea("", 10, 30);
		this.textField.setText(this.text);
		this.textField.setAutoscrolls(true);
		this.textField.setLineWrap(true);
		this.textField.setWrapStyleWord(true);
		JScrollPane scroller = new JScrollPane(this.textField);
        layout.putConstraint(SpringLayout.WEST, scroller, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, scroller, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, scroller, 20, SpringLayout.SOUTH, this.titleField);
        layout.putConstraint(SpringLayout.SOUTH, scroller, 220, SpringLayout.SOUTH, this.titleField);
		contentPane.add(scroller);
		
		this.centerBox = new JCheckBox("Zentriere Text");
		this.centerBox.setSelected(this.centered);
        layout.putConstraint(SpringLayout.WEST, this.centerBox, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.centerBox, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.centerBox, 20, SpringLayout.SOUTH, scroller);
		contentPane.add(this.centerBox);
		
		this.showBox = new JCheckBox("Zeige Balken");
		this.showBox.setSelected(this.show);
        layout.putConstraint(SpringLayout.WEST, this.showBox, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.showBox, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.showBox, 20, SpringLayout.SOUTH, this.centerBox);
		contentPane.add(this.showBox);
		
		this.bigBox = new JCheckBox("Breite Balken (sonst schmal)");
		this.bigBox.setSelected(this.big);
        layout.putConstraint(SpringLayout.WEST, this.bigBox, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.bigBox, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.bigBox, 20, SpringLayout.SOUTH, this.showBox);
		contentPane.add(this.bigBox);
		
		this.blackBox = new JCheckBox("Schwarze Balken (sonst transparent)");
		this.blackBox.setSelected(this.black);
        layout.putConstraint(SpringLayout.WEST, this.blackBox, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.blackBox, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.blackBox, 20, SpringLayout.SOUTH, this.bigBox);
		contentPane.add(this.blackBox);
		
		JButton saveButton = new JButton("Speichern");
		saveButton.setName("saveButton");
		saveButton.setBackground(Static.tableHeaderBG);
		saveButton.setForeground(Color.white);
		saveButton.setFont(new Font("Calibri", Font.BOLD, 24));
        contentPane.add(saveButton);
        layout.putConstraint(SpringLayout.WEST, saveButton, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, saveButton, 170, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, saveButton, -70, SpringLayout.SOUTH, contentPane);
        layout.putConstraint(SpringLayout.SOUTH, saveButton, -20, SpringLayout.SOUTH, contentPane);
        saveButton.addActionListener(this);
        saveButton.setBorder(border);
        
        JButton abortButton = new JButton("Abbrechen");
        abortButton.setName("abortButton");
        abortButton.setBackground(Static.tableHeaderBG);
        abortButton.setForeground(Color.white);
        abortButton.setFont(new Font("Calibri", Font.BOLD, 24));
        contentPane.add(abortButton);
        layout.putConstraint(SpringLayout.WEST, abortButton, -170, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.EAST, abortButton, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, abortButton, -70, SpringLayout.SOUTH, contentPane);
        layout.putConstraint(SpringLayout.SOUTH, abortButton, -20, SpringLayout.SOUTH, contentPane);
        abortButton.addActionListener(this);
        abortButton.setBorder(border);

        this.frame.setSize(360, 700);
        this.frame.setResizable(false);
        this.frame.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
        this.frame.addWindowListener(new java.awt.event.WindowAdapter() {
            @Override
            public void windowClosing(java.awt.event.WindowEvent windowEvent) {
            	abort();
            }
        });
        this.frame.setLocationRelativeTo(null);
        this.frame.setVisible(true);
	}

	private void save() {
		this.moveValuesIn();
		int sorterSlot = this.bench.getSorterSlot(this.time, this.csNr, this.eventType);
		this.sorter = sorterSlot;
		if (sorterSlot != -1) {
			this.bench.addEventAndRefreshTable(this);
			this.frame.dispose();
		} else {
			JOptionPane.showMessageDialog(null, "Dieser Zeitpunkt ist bereits besetzt.");
		}
	}
	
	private void moveValuesIn() {
		this.time = Integer.parseInt(this.timeField.getText().replaceAll("\\.", ""));
		this.show = this.showBox.isSelected();
		this.big = this.bigBox.isSelected();
		this.black = this.blackBox.isSelected();
		this.text = this.textField.getText();
		this.title = this.titleField.getText();
		this.centered = this.centerBox.isSelected();
		this.csNr = Integer.parseInt(this.csField.getText().replaceAll("\\.", ""));
	}

	private void abort() {
		if (this.changeMode) {
			this.bench.addEventAndRefreshTable(this.initial);
		}
		this.frame.dispose();
	}

	/**
	 * action listener
	 * @param ev is the event that triggers the action
	 */
	public void actionPerformed(ActionEvent ev) {
		String name = ((JButton) ev.getSource()).getName();
		if ("abortButton".equals(name)) {
			this.abort();
		} else if ("saveButton".equals(name)) {
			this.save();
		}
	}

	/**
	 * Generates a saving String
	 * @return String
	 */
	public String generateSave() {
		String save = "" + Static.getEvent(this.eventType) + "#d#l#";
		save += "" + this.time + "#p#l#";
		save += "" + this.csNr + "#p#l#";
		save += "" + this.title + "#p#l#";
		save += "" + this.text + "#p#l#";
		save += "" + this.centered + "#p#l#";
		save += "" + this.show + "#p#l#";
		save += "" + this.big + "#p#l#";
		save += "" + this.black + "#p#l#";
		save += "" + this.sorter + "#p#l#";
		return save;
	}

	/**
	 * Decodes a saving String
	 * @param data String
	 */
	public void decodeSave(String data) {
		String[] elements = data.split("#p#l#");
		this.time = Integer.parseInt(elements[0]);
		this.csNr = Integer.parseInt(elements[1]);
		this.title = elements[2];
		this.text = elements[3];
		this.centered = "true".equals(elements[4]);
		this.show = "true".equals(elements[5]);
		this.big = "true".equals(elements[6]);
		this.black = "true".equals(elements[7]);
		this.sorter = Integer.parseInt(elements[8]);
	}

}
