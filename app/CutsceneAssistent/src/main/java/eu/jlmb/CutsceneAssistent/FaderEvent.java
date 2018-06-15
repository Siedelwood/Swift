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
import javax.swing.JTextField;
import javax.swing.SpringLayout;
import javax.swing.SwingConstants;
import javax.swing.border.MatteBorder;
import javax.swing.text.NumberFormatter;

/**
 * FaderEvent Event
 * @author Jean Baumgarten
 */
public class FaderEvent implements Event, ActionListener {
	
	private int eventType = Static.FaderEvent;
	
	private int time = 0;
	private int csNr = 0;
	private boolean fadeIn = true;
	private int duration = 0;
	private int sorter = -1;

	private boolean changeMode;
	private Workbench bench;
	private Event initial;
	private JDialog frame;
	private JFormattedTextField csField;
	private JFormattedTextField timeField;
	private JTextField durationField;
	private JCheckBox fadeBox;
	
	/**
	 * Constructor
	 */
	public FaderEvent() { }
	
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
	 * Gives the EventType
	 * @return integer defining the EventType
	 */
	public int eventType() {
		return this.eventType;
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
		String script = "";
		if (this.fadeIn) {
			script = "FadeIn über " + this.duration + " Sekunden";
		} else {
			script = "FadeOut über " + this.duration + " Sekunden";
		}
		return script;
	}

	/**
	 * Gives the XML data for finishing
	 * @return ArrayList<String> containing the XML data
	 */
	public ArrayList<String> getXML() {
		String code = "";
		if (this.fadeIn) {
			code = "AddOnGameCutscenes.Local:FadeIn(" + this.duration + ")";
		} else {
			code = "AddOnGameCutscenes.Local:FadeOut(" + this.duration + ")";
		}
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
        xml.add("      <Script>" + code + "</Script>");
        xml.add("    </Event>");
		return xml;
	}

	/**
	 * Generates a copy of the Event
	 * @return Event
	 */
	public Event copy() {
		FaderEvent event = new FaderEvent();
		event.time = this.time;
		event.duration = this.duration;
		event.csNr = this.csNr;
		event.fadeIn = this.fadeIn;
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
			title += "Ändere ScriptEvent";
		} else {
			title += "Neues ScriptEvent";
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
        
        JLabel labelDuration = new JLabel("Fadedauer");
        layout.putConstraint(SpringLayout.WEST, labelDuration, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, labelDuration, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, labelDuration, 20, SpringLayout.SOUTH, this.timeField);
        contentPane.add(labelDuration);
		
		this.durationField = new JFormattedTextField(numberFormatter);
		this.durationField.setText("" + this.duration);
        layout.putConstraint(SpringLayout.WEST, this.durationField, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.durationField, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.durationField, 10, SpringLayout.SOUTH, labelDuration);
		contentPane.add(this.durationField);
		
		this.fadeBox = new JCheckBox("FadeIn (sonst FadeOut)");
		this.fadeBox.setSelected(this.fadeIn);
        layout.putConstraint(SpringLayout.WEST, this.fadeBox, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.fadeBox, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.fadeBox, 20, SpringLayout.SOUTH, this.durationField);
		contentPane.add(this.fadeBox);
		
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

        this.frame.setSize(360, 350);
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
		this.csNr = Integer.parseInt(this.csField.getText().replaceAll("\\.", ""));
		this.fadeIn = this.fadeBox.isSelected();
		this.duration = Integer.parseInt(this.durationField.getText().replaceAll("\\.", ""));
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
		save += "" + this.fadeIn + "#p#l#";
		save += "" + this.duration + "#p#l#";
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
		this.fadeIn = "true".equals(elements[2]);
		this.duration = Integer.parseInt(elements[3]);
		this.sorter = Integer.parseInt(elements[4]);
	}

}
