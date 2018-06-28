package eu.jlmb.CutsceneAssistent;

import java.awt.Color;
import java.awt.Container;
import java.awt.Dialog;
import java.awt.Font;
import java.awt.Window.Type;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.text.Format;
import java.text.NumberFormat;
import java.util.ArrayList;

import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JDialog;
import javax.swing.JFormattedTextField;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.SpringLayout;
import javax.swing.SwingConstants;
import javax.swing.border.MatteBorder;
import javax.swing.text.NumberFormatter;

/**
 * CameraEvent Event
 * @author Jean Baumgarten
 */
public class CameraEvent implements Event, ActionListener {
	
	private int eventType = Static.CameraEvent;
	
	private int px;
	private int py;
	private int pz;
	private int lx;
	private int ly;
	private int lz;
	private int csNr;
	private int time;
	private int fov;
	private int farClipPlane;
	private boolean lookFarAway;
	private int sorter;
	
	private boolean changeMode;
	private Workbench bench;
	private Event initial;
	private JDialog frame;
	private JFormattedTextField csField;
	private JFormattedTextField timeField;
	private JFormattedTextField pxField;
	private JFormattedTextField pyField;
	private JFormattedTextField pzField;
	private JFormattedTextField fovField;
	private JCheckBox lookBox;
	private JFormattedTextField lxField;
	private JFormattedTextField lyField;
	private JFormattedTextField lzField;
	private JFormattedTextField farField;
	
	/**
	 * Constructor
	 * @param px positionX
	 * @param py positionY
	 * @param pz positionZ
	 * @param lx lookAtX
	 * @param ly lookAtY
	 * @param lz lookAtZ
	 * @param time to reach position
	 */
	public CameraEvent(int px, int py, int pz, int lx, int ly, int lz, int time) {
		this.px = px;
		this.py = py;
		this.pz = pz;
		this.lx = lx;
		this.ly = ly;
		this.lz = lz;
		this.time = time;
		this.fov = 42;
		this.lookFarAway = true;
		this.farClipPlane = 100000;
		this.csNr = 0;
		this.sorter = -1;
	}
	
	/**
	 * Constructor
	 */
	public CameraEvent() {
		this.px = 0;
		this.py = 0;
		this.pz = 0;
		this.lx = 0;
		this.ly = 0;
		this.lz = 0;
		this.time = 0;
		this.fov = 42;
		this.lookFarAway = true;
		this.farClipPlane = 100000;
		this.csNr = 0;
		this.sorter = -1;
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
	 * Gives the XML data for finishing
	 * @return ArrayList<String> containing the XML data
	 */
	public ArrayList<String> getXML() {
		ArrayList<String> xml = new ArrayList<String>();
		xml.add("    <Event classname=\"ECam::CCutsceneEventCamera\">");
        xml.add("      <EventType>1</EventType>");
        xml.add("      <Turn>" + this.time + "</Turn>");
        xml.add("      <Name>CAMERA_EVENT</Name>");
        xml.add("      <PositionX>" + this.px + ".</PositionX>");
        xml.add("      <PositionY>" + this.py + ".</PositionY>");
        xml.add("      <PositionZ>" + this.pz + ".</PositionZ>");
        xml.add("      <LookAtX>" + this.lx + ".</LookAtX>");
        xml.add("      <LookAtY>" + this.ly + ".</LookAtY>");
        xml.add("      <LookAtZ>" + this.lz + ".</LookAtZ>");
        xml.add("      <Transition>Camera New Fly</Transition>");
        xml.add("      <FOV>" + this.fov + ".</FOV>");
        xml.add("      <FarClipPlane>" + this.farClipPlane + ".</FarClipPlane>");
        xml.add("      <LookFarAway>" + this.lookFarAway + "</LookFarAway>");
        xml.add("    </Event>");
		return xml;
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
		String pos = "Pos: {X=" + this.px + " Y=" + this.py + " Z=" + this.pz + "}, ";
		String la = "LookAt: {X=" + this.lx + " Y=" + this.ly + " Z=" + this.lz + "}";
		return pos + la;
	}

	/**
	 * Gives the amount of columns needed for the event data
	 * @return integer
	 */
	public int getNeededColumns() {
		return 11;
	}

	/**
	 * Generates a copy of the Event
	 * @return Event
	 */
	public Event copy() {
		CameraEvent newEvent = new CameraEvent(this.px, this.py, this.pz, this.lx, this.ly, this.lz, this.time);
		newEvent.fov = this.fov;
		newEvent.lookFarAway = this.lookFarAway;
		newEvent.csNr = this.csNr;
		newEvent.sorter = this.sorter;
		newEvent.farClipPlane = this.farClipPlane;
		return newEvent;
	}

	/**
	 * Gives the data for a given column
	 * @param column asked for
	 * @return String
	 */
	public String getDataForColumn(int column) {
		if (column == 0) {
			return "" + this.csNr;
		} else if (column == 1) {
			return "" + this.time;
		} else if (column == 2) {
			return "" + this.lookFarAway;
		} else if (column == 3) {
			return "" + this.fov;
		} else if (column == 4) {
			return "" + this.farClipPlane;
		} else if (column == 5) {
			return "" + this.px;
		} else if (column == 6) {
			return "" + this.py;
		} else if (column == 7) {
			return "" + this.pz;
		} else if (column == 8) {
			return "" + this.lx;
		} else if (column == 9) {
			return "" + this.ly;
		} else if (column == 10) {
			return "" + this.lz;
		} else {
			return "";
		}
	}

	/**
	 * Sets the changed Data for a given column
	 * @param column to change
	 * @param data to save
	 */
	public void setDataForColumn(int column, String data) {
		if (column == 0) {
			int cs = Integer.parseInt(data);
			this.csNr = (cs >= 0) ? cs : 0;
		} else if (column == 1) {
			int time = Integer.parseInt(data);
			this.time = (time >= 0) ? time : 0;
		} else if (column == 2) {
			this.lookFarAway = data.equals("true");
		} else if (column == 3) {
			this.fov = Integer.parseInt(data);
		} else if (column == 4) {
			this.farClipPlane = Integer.parseInt(data);
		} else if (column == 5) {
			this.px = Integer.parseInt(data);
		} else if (column == 6) {
			this.py = Integer.parseInt(data);
		} else if (column == 7) {
			this.pz = Integer.parseInt(data);
		} else if (column == 8) {
			this.lx = Integer.parseInt(data);
		} else if (column == 9) {
			this.ly = Integer.parseInt(data);
		} else if (column == 10) {
			this.lz = Integer.parseInt(data);
		}
	}

	/**
	 * Get the title for the column
	 * @param column number
	 * @return String
	 */
	public String getColumnTitle(int column) {
		if (column == 0) {
			return "CS Nr";
		} else if (column == 1) {
			return "Zeit";
		} else if (column == 2) {
			return "Weitsicht";
		} else if (column == 3) {
			return "FOV";
		} else if (column == 4) {
			return "Anzeigedistanz";
		} else if (column == 5) {
			return "posX";
		} else if (column == 6) {
			return "posY";
		} else if (column == 7) {
			return "posZ";
		} else if (column == 8) {
			return "lookAtX";
		} else if (column == 9) {
			return "lookAtX";
		} else if (column == 10) {
			return "lookAtX";
		} else {
			return "";
		}
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
			title += "Ändere CameraEvent";
		} else {
			title += "Neues CameraEvent";
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
        
        JLabel labelPos = new JLabel("X Y Z Positionen");
        layout.putConstraint(SpringLayout.WEST, labelPos, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, labelPos, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, labelPos, 20, SpringLayout.SOUTH, this.timeField);
        contentPane.add(labelPos);
		
		this.pxField = new JFormattedTextField(numberFormatter);
		this.pxField.setText("" + this.px);
        layout.putConstraint(SpringLayout.WEST, this.pxField, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.pxField, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.pxField, 10, SpringLayout.SOUTH, labelPos);
		contentPane.add(this.pxField);
		
		this.pyField = new JFormattedTextField(numberFormatter);
		this.pyField.setText("" + this.py);
        layout.putConstraint(SpringLayout.WEST, this.pyField, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.pyField, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.pyField, 10, SpringLayout.SOUTH, this.pxField);
		contentPane.add(this.pyField);
		
		this.pzField = new JFormattedTextField(numberFormatter);
		this.pzField.setText("" + this.pz);
        layout.putConstraint(SpringLayout.WEST, this.pzField, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.pzField, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.pzField, 10, SpringLayout.SOUTH, this.pyField);
		contentPane.add(this.pzField);
        
        JLabel labelLook = new JLabel("X Y Z LookAt");
        layout.putConstraint(SpringLayout.WEST, labelLook, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, labelLook, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, labelLook, 20, SpringLayout.SOUTH, this.pzField);
        contentPane.add(labelLook);
		
		this.lxField = new JFormattedTextField(numberFormatter);
		this.lxField.setText("" + this.lx);
        layout.putConstraint(SpringLayout.WEST, this.lxField, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.lxField, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.lxField, 10, SpringLayout.SOUTH, labelLook);
		contentPane.add(this.lxField);
		
		this.lyField = new JFormattedTextField(numberFormatter);
		this.lyField.setText("" + this.ly);
        layout.putConstraint(SpringLayout.WEST, this.lyField, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.lyField, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.lyField, 10, SpringLayout.SOUTH, this.lxField);
		contentPane.add(this.lyField);
		
		this.lzField = new JFormattedTextField(numberFormatter);
		this.lzField.setText("" + this.lz);
        layout.putConstraint(SpringLayout.WEST, this.lzField, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.lzField, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.lzField, 10, SpringLayout.SOUTH, this.lyField);
		contentPane.add(this.lzField);
        
        JLabel labelFOV = new JLabel("FOV");
        layout.putConstraint(SpringLayout.WEST, labelFOV, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, labelFOV, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, labelFOV, 20, SpringLayout.SOUTH, this.lzField);
        contentPane.add(labelFOV);
		
		this.fovField = new JFormattedTextField(numberFormatter);
		this.fovField.setText("" + this.fov);
        layout.putConstraint(SpringLayout.WEST, this.fovField, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.fovField, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.fovField, 10, SpringLayout.SOUTH, labelFOV);
		contentPane.add(this.fovField);
        
        JLabel labelFCP = new JLabel("FarClipPlane");
        layout.putConstraint(SpringLayout.WEST, labelFCP, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, labelFCP, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, labelFCP, 20, SpringLayout.SOUTH, this.fovField);
        contentPane.add(labelFCP);
		
		this.farField = new JFormattedTextField(numberFormatter);
		this.farField.setText("" + this.farClipPlane);
        layout.putConstraint(SpringLayout.WEST, this.farField, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.farField, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.farField, 10, SpringLayout.SOUTH, labelFCP);
		contentPane.add(this.farField);
		
		this.lookBox = new JCheckBox("Weitsicht");
		this.lookBox.setSelected(this.lookFarAway);
        layout.putConstraint(SpringLayout.WEST, this.lookBox, 20, SpringLayout.WEST, contentPane);
        layout.putConstraint(SpringLayout.EAST, this.lookBox, -20, SpringLayout.EAST, contentPane);
        layout.putConstraint(SpringLayout.NORTH, this.lookBox, 20, SpringLayout.SOUTH, this.farField);
		contentPane.add(this.lookBox);
		
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
		this.csNr = Integer.parseInt(this.csField.getText().replaceAll("\\.", ""));
		this.px = Integer.parseInt(this.pxField.getText().replaceAll("\\.", ""));
		this.py = Integer.parseInt(this.pyField.getText().replaceAll("\\.", ""));
		this.pz = Integer.parseInt(this.pzField.getText().replaceAll("\\.", ""));
		this.lx = Integer.parseInt(this.lxField.getText().replaceAll("\\.", ""));
		this.ly = Integer.parseInt(this.lyField.getText().replaceAll("\\.", ""));
		this.lz = Integer.parseInt(this.lzField.getText().replaceAll("\\.", ""));
		this.fov = Integer.parseInt(this.fovField.getText().replaceAll("\\.", ""));
		this.farClipPlane = Integer.parseInt(this.farField.getText().replaceAll("\\.", ""));
		this.lookFarAway = this.lookBox.isSelected();
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
		save += "" + this.px + "#p#l#";
		save += "" + this.py + "#p#l#";
		save += "" + this.pz + "#p#l#";
		save += "" + this.lx + "#p#l#";
		save += "" + this.ly + "#p#l#";
		save += "" + this.lz + "#p#l#";
		save += "" + this.fov + "#p#l#";
		save += "" + this.farClipPlane + "#p#l#";
		save += "" + this.lookFarAway + "#p#l#";
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
		this.px = Integer.parseInt(elements[2]);
		this.py = Integer.parseInt(elements[3]);
		this.pz = Integer.parseInt(elements[4]);
		this.lx = Integer.parseInt(elements[5]);
		this.ly = Integer.parseInt(elements[6]);
		this.lz = Integer.parseInt(elements[7]);
		this.fov = Integer.parseInt(elements[8]);
		this.farClipPlane = Integer.parseInt(elements[9]);
		this.lookFarAway = "true".equals(elements[10]);
		this.sorter = Integer.parseInt(elements[11]);
	}

}
