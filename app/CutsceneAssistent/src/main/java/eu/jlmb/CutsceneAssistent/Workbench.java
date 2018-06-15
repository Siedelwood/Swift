package eu.jlmb.CutsceneAssistent;

import java.awt.Color;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;

import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.ListSelectionModel;
import javax.swing.SpringLayout;
import javax.swing.border.MatteBorder;
import javax.swing.filechooser.FileNameExtensionFilter;
import javax.swing.table.DefaultTableCellRenderer;

/**
 * Workbench of the Assistant
 * @author Jean Baumgarten
 */
public class Workbench implements ActionListener {
	
	private JTable table;
	private JFrame frame;
	private int buttonWidth = 240;
	private int buttonHeight = 50;
	private int totalWidth = 1340;
	private int totalHeight = 800;
	
	private EventList list;
	private Container contentPane;
	private SpringLayout layout;
	private MatteBorder border;
	private String preferredPath = "";
	
	/**
	 * Constructor
	 */
	public Workbench() {
		this.preferredPath = Static.getPreferedFolder();
		this.gui();
	}
	
	private void gui() {
		this.guiCreateFrame();
		this.guiCreateFileControlButtons();
		this.guiCreateEventButtons();
		this.guiCreateTable();
		this.guiFinishFrame();
	}
	
	private void guiCreateFrame() {
		this.frame = new JFrame("Siedelwood Cutscene Assistant");
        this.contentPane = this.frame.getContentPane();
        this.layout = new SpringLayout();
        this.contentPane.setLayout(layout);
        this.border = new MatteBorder(3, 3, 2, 2, Static.uiBorder);
	}
	
	private void guiFinishFrame() {
        this.frame.setSize(totalWidth, totalHeight);
        this.frame.setResizable(false);
        this.frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.frame.setLocationRelativeTo(null);
        this.frame.setVisible(true);
	}
	
	private void guiCreateFileControlButtons() {
		int w = 20 + this.buttonWidth;
		int h = 20 + this.buttonHeight;
		
        JButton exportButton = new JButton("Exportieren");
        exportButton.setName("exportButton");
        exportButton.setBackground(Static.tableHeaderBG);
        exportButton.setForeground(Color.white);
        exportButton.setFont(new Font("Calibri", Font.BOLD, 24));
        this.contentPane.add(exportButton);
        this.layout.putConstraint(SpringLayout.WEST, exportButton, 20, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.EAST, exportButton, w, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.NORTH, exportButton, 20, SpringLayout.NORTH, this.contentPane);
        this.layout.putConstraint(SpringLayout.SOUTH, exportButton, h, SpringLayout.NORTH, this.contentPane);
        exportButton.addActionListener(this);
        
        JButton saveButton = new JButton("Speichern");
        saveButton.setName("saveButton");
        saveButton.setBackground(Static.tableHeaderBG);
        saveButton.setForeground(Color.white);
        saveButton.setFont(new Font("Calibri", Font.BOLD, 24));
        this.contentPane.add(saveButton);
        this.layout.putConstraint(SpringLayout.WEST, saveButton, 20, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.EAST, saveButton, w, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.NORTH, saveButton, 20, SpringLayout.SOUTH, exportButton);
        this.layout.putConstraint(SpringLayout.SOUTH, saveButton, h, SpringLayout.SOUTH, exportButton);
        saveButton.addActionListener(this);
        
        JButton loadButton = new JButton("Laden");
        loadButton.setName("loadButton");
        loadButton.setBackground(Static.tableHeaderBG);
        loadButton.setForeground(Color.white);
        loadButton.setFont(new Font("Calibri", Font.BOLD, 24));
        this.contentPane.add(loadButton);
        this.layout.putConstraint(SpringLayout.WEST, loadButton, 20, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.EAST, loadButton, w, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.NORTH, loadButton, 20, SpringLayout.SOUTH, saveButton);
        this.layout.putConstraint(SpringLayout.SOUTH, loadButton, h, SpringLayout.SOUTH, saveButton);
        loadButton.addActionListener(this);
        
        saveButton.setBorder(border);
        loadButton.setBorder(border);
        exportButton.setBorder(border);
	}
	
	private void guiCreateEventButtons() {
		int w = 20 + this.buttonWidth;
		int h = 20 + this.buttonHeight;
		int f = 100 + 3 * this.buttonHeight;
		
        JButton deleteButton = new JButton("Lösche Event");
        deleteButton.setName("deleteButton");
        deleteButton.setBackground(Static.tableHeaderBG);
        deleteButton.setForeground(Color.white);
        deleteButton.setFont(new Font("Calibri", Font.BOLD, 24));
        this.contentPane.add(deleteButton);
        this.layout.putConstraint(SpringLayout.WEST, deleteButton, 20, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.EAST, deleteButton, w, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.NORTH, deleteButton, f, SpringLayout.NORTH, this.contentPane);
        this.layout.putConstraint(SpringLayout.SOUTH, deleteButton, f + h - 20, SpringLayout.NORTH, this.contentPane);
        deleteButton.addActionListener(this);
        deleteButton.setBorder(border);
        
        JButton changeButton = new JButton("Ändere Event");
        changeButton.setName("changeButton");
        changeButton.setBackground(Static.tableHeaderBG);
        changeButton.setForeground(Color.white);
        changeButton.setFont(new Font("Calibri", Font.BOLD, 24));
        this.contentPane.add(changeButton);
        this.layout.putConstraint(SpringLayout.WEST, changeButton, 20, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.EAST, changeButton, w, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.NORTH, changeButton, 20, SpringLayout.SOUTH, deleteButton);
        this.layout.putConstraint(SpringLayout.SOUTH, changeButton, h, SpringLayout.SOUTH, deleteButton);
        changeButton.addActionListener(this);
        changeButton.setBorder(border);
        
        JButton newTextButton = new JButton("Neues TextEvent");
        newTextButton.setName("newTextButton");
        newTextButton.setBackground(Static.tableHeaderBG);
        newTextButton.setForeground(Color.white);
        newTextButton.setFont(new Font("Calibri", Font.BOLD, 24));
        this.contentPane.add(newTextButton);
        this.layout.putConstraint(SpringLayout.WEST, newTextButton, 20, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.EAST, newTextButton, w, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.NORTH, newTextButton, 40, SpringLayout.SOUTH, changeButton);
        this.layout.putConstraint(SpringLayout.SOUTH, newTextButton, 20 + h, SpringLayout.SOUTH, changeButton);
        newTextButton.addActionListener(this);
        newTextButton.setBorder(border);
        
        /*JButton newFaderButton = new JButton("Neues FaderEvent");
        newFaderButton.setName("newFaderButton");
        newFaderButton.setBackground(Static.tableHeaderBG);
        newFaderButton.setForeground(Color.white);
        newFaderButton.setFont(new Font("Calibri", Font.BOLD, 24));
        this.contentPane.add(newFaderButton);
        this.layout.putConstraint(SpringLayout.WEST, newFaderButton, 20, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.EAST, newFaderButton, w, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.NORTH, newFaderButton, 20, SpringLayout.SOUTH, newTextButton);
        this.layout.putConstraint(SpringLayout.SOUTH, newFaderButton, h, SpringLayout.SOUTH, newTextButton);
        newFaderButton.addActionListener(this);*/
        
        JButton newScriptButton = new JButton("Neues ScriptEvent");
        newScriptButton.setName("newScriptButton");
        newScriptButton.setBackground(Static.tableHeaderBG);
        newScriptButton.setForeground(Color.white);
        newScriptButton.setFont(new Font("Calibri", Font.BOLD, 24));
        this.contentPane.add(newScriptButton);
        this.layout.putConstraint(SpringLayout.WEST, newScriptButton, 20, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.EAST, newScriptButton, w, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.NORTH, newScriptButton, 20, SpringLayout.SOUTH, newTextButton);
        this.layout.putConstraint(SpringLayout.SOUTH, newScriptButton, h, SpringLayout.SOUTH, newTextButton);
        newScriptButton.addActionListener(this);
        newScriptButton.setBorder(border);
        
        JButton newCameraButton = new JButton("Neues CameraEvent");
        newCameraButton.setName("newCameraButton");
        newCameraButton.setBackground(Static.tableHeaderBG);
        newCameraButton.setForeground(Color.white);
        newCameraButton.setFont(new Font("Calibri", Font.BOLD, 24));
        this.contentPane.add(newCameraButton);
        this.layout.putConstraint(SpringLayout.WEST, newCameraButton, 20, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.EAST, newCameraButton, w, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.NORTH, newCameraButton, 20, SpringLayout.SOUTH, newScriptButton);
        this.layout.putConstraint(SpringLayout.SOUTH, newCameraButton, h, SpringLayout.SOUTH, newScriptButton);
        newCameraButton.addActionListener(this);
        newCameraButton.setBorder(border);
	}
	
	private void guiCreateTable() {
        this.list = Static.getCutsceneData();
		int w = 20 + this.buttonWidth;
        
        this.table = new JTable(this.list);
        JScrollPane scrollPane = new JScrollPane(this.table);
        this.contentPane.add(scrollPane);
        this.layout.putConstraint(SpringLayout.WEST, scrollPane, w + 20, SpringLayout.WEST, this.contentPane);
        this.layout.putConstraint(SpringLayout.EAST, scrollPane, -20, SpringLayout.EAST, this.contentPane);
        this.layout.putConstraint(SpringLayout.NORTH, scrollPane, 20, SpringLayout.NORTH, this.contentPane);
        this.layout.putConstraint(SpringLayout.SOUTH, scrollPane, -20, SpringLayout.SOUTH, this.contentPane);
        
        this.table.setRowHeight(40);
        this.table.setFont(new Font("Calibri", Font.BOLD, 18));
        this.table.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        this.table.getTableHeader().setReorderingAllowed(false);
        this.table.getTableHeader().setResizingAllowed(false);
        this.table.getTableHeader().setPreferredSize(new Dimension(scrollPane.getWidth(), 50));
        this.table.getTableHeader().setFont(new Font("Calibri", Font.BOLD, 20));
        this.setTableDimensions();

        this.table.setBackground(Static.tabelBackground);
        scrollPane.getViewport().setBackground(Static.tabelBackground);
        this.table.getTableHeader().setBackground(Static.tableHeaderBG);
        this.table.getTableHeader().setForeground(Color.white);
        this.contentPane.setBackground(Static.background);
        scrollPane.setBorder(border);
	}
	
	private void setTableDimensions() {
        this.table.getColumnModel().getColumn(0).setMaxWidth(80);
        this.table.getColumnModel().getColumn(0).setMinWidth(80);
        DefaultTableCellRenderer rendererC = new DefaultTableCellRenderer();
        rendererC.setHorizontalAlignment(JLabel.CENTER);
        this.table.getColumnModel().getColumn(1).setCellRenderer(rendererC);
        this.table.getColumnModel().getColumn(1).setMaxWidth(100);
        this.table.getColumnModel().getColumn(1).setMinWidth(100);
        this.table.getColumnModel().getColumn(2).setCellRenderer(rendererC);
        this.table.getColumnModel().getColumn(2).setMaxWidth(190);
        this.table.getColumnModel().getColumn(2).setMinWidth(190);
        this.table.setAutoResizeMode(JTable.AUTO_RESIZE_LAST_COLUMN);
	}
	
	/**
	 * Getter for the frame
	 * @return JFrame
	 */
	public JFrame getFrame() {
		return this.frame;
	}
	
	/**
	 * Getter for the EventList
	 * @return the EventList
	 */
	public EventList getEventList() {
		return this.list;
	}
	
	/**
	 * Gives an available time slot for a given time, -1 if no time slot is free
	 * @param time when the event should happen
	 * @param csNr is the number of the cs part
	 * @param type of the event to check
	 * @return time that is possible
	 */
	public int getSorterSlot(int time, int csNr, int type) {
		return this.list.getSorterSlot(time, csNr, type);
	}
	
	/**
	 * Adds an Event and refreshes the table
	 * @param event to add
	 */
	public void addEventAndRefreshTable(Event event) {
		this.list.addEvent(event);
	}
	
	/**
	 * Removes the Event that is currently selected in the table
	 */
	private void removeSelectedEventAndRefreshTable() {
		int row = this.table.getSelectedRow();
		if (row >= 0 & row < this.list.size()) {
			this.list.removeEvent(row);
		}
	}

	/**
	 * Implements actionPerformed
	 * @param ev is something
	 */
	public void actionPerformed(ActionEvent ev) {
		String name = ((JButton) ev.getSource()).getName();
		if ("exportButton".equals(name)) {
			this.chooseExportNameAndLocation();
		} else if ("newTextButton".equals(name)) {
			(new TextEvent()).gui(this, false);
		} else if ("newFaderButton".equals(name)) {
			(new FaderEvent()).gui(this, false);
		} else if ("newScriptButton".equals(name)) {
			(new ScriptEvent()).gui(this, false);
		} else if ("newCameraButton".equals(name)) {
			(new CameraEvent()).gui(this, false);
		} else if ("changeButton".equals(name)) {
			int row = this.table.getSelectedRow();
			if (row >= 0 & row < this.list.size()) {
				Event del = this.list.removeEvent(row);
				del.gui(this, true);
			} else {
				JOptionPane.showMessageDialog(null, "Es ist kein Event ausgewählt.");
			}
		} else if ("deleteButton".equals(name)) {
			String question = "Soll das ausgewählte Event gelöscht werden?";
			question += "\nIst kein Event ausgewählt passiert nichts...";
            String title = "Event Löschen";
            int option = JOptionPane.showConfirmDialog(null, question, title, JOptionPane.YES_NO_OPTION);
            if (option == JOptionPane.YES_OPTION) {
            	removeSelectedEventAndRefreshTable();
            }
		} else if ("loadButton".equals(name)) {
			loadData();
		} else if ("saveButton".equals(name)) {
			saveData();
		}
	}
	
	private void saveData() {
		JFileChooser saver = new JFileChooser();
		saver.setFileSelectionMode(JFileChooser.FILES_ONLY);
		saver.setCurrentDirectory(new File(this.preferredPath));
        saver.setFileFilter(new FileNameExtensionFilter("Text files", "txt"));
        saver.setAcceptAllFileFilterUsed(false);
        int returnVal = saver.showSaveDialog(null);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
            File file = saver.getSelectedFile();
            File parent = file.getParentFile();
            if (parent.exists() && parent.isDirectory()) {
            	Static.savePreferedFolder(parent.getAbsolutePath());
            	this.preferredPath = parent.getAbsolutePath();
            }
            String content = "";
            for (Event event : this.list.getSorted()) {
            	content += event.generateSave() + "#e#l#";
            }
            String path = file.getAbsolutePath();
            if (!path.endsWith(".txt")) {
            	path += ".txt";
            }
    		StandardOpenOption option = StandardOpenOption.CREATE;
    		try {
    			Files.write(Paths.get(path), content.getBytes(StandardCharsets.UTF_8), option);
    		} catch (IOException e) {
    			System.err.println("Error");
    		}
        }
	}
	
	private void loadData() {
		JFileChooser opener = new JFileChooser();
		opener.setFileSelectionMode(JFileChooser.FILES_ONLY);
		opener.setCurrentDirectory(new File(this.preferredPath));
		opener.addChoosableFileFilter(new FileNameExtensionFilter("Text files", "txt"));
		opener.setAcceptAllFileFilterUsed(false);
        int returnVal = opener.showOpenDialog(null);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
            File file = opener.getSelectedFile();
            File parent = file.getParentFile();
            if (parent.exists() && parent.isDirectory()) {
            	Static.savePreferedFolder(parent.getAbsolutePath());
            	this.preferredPath = parent.getAbsolutePath();
            }
            String path = file.getAbsolutePath();
            String line = null;
            try {
                FileReader fileReader = new FileReader(path);
                BufferedReader bufferedReader = new BufferedReader(fileReader);
            	this.list = new EventList();
            	this.table.setModel(this.list);
            	this.setTableDimensions();
            	line = bufferedReader.readLine();
            	if (line != null || !"".equals(line)) {
            		String[] events = line.split("#e#l#");
            		for (String event : events) {
            			String[] eventData = event.split("#d#l#");
            			if (eventData.length >= 2) {
            				if (eventData[0].equals(Static.getEvent(Static.TextEvent))) {
            					TextEvent ev = new TextEvent();
            					ev.decodeSave(eventData[1]);
            					this.addEventAndRefreshTable(ev);
            				} else if (eventData[0].equals(Static.getEvent(Static.ScriptEvent))) {
            					ScriptEvent ev = new ScriptEvent();
            					ev.decodeSave(eventData[1]);
            					this.addEventAndRefreshTable(ev);
            				} else if (eventData[0].equals(Static.getEvent(Static.CameraEvent))) {
            					CameraEvent ev = new CameraEvent();
            					ev.decodeSave(eventData[1]);
            					this.addEventAndRefreshTable(ev);
            				} else if (eventData[0].equals(Static.getEvent(Static.FaderEvent))) {
            					FaderEvent ev = new FaderEvent();
            					ev.decodeSave(eventData[1]);
            					this.addEventAndRefreshTable(ev);
            				}
            			}
            		}
            	}
                bufferedReader.close();
            } catch (FileNotFoundException ex) {
                System.err.println("Error");
            } catch (IOException ex) {
                System.err.println("Error");
            }
        }
	}
	
	private void chooseExportNameAndLocation() {
		JFrame frame = new JFrame();
	    String name = JOptionPane.showInputDialog(
	        frame, 
	        "Wähle einen Namen für die Cutscene", 
	        "Titelwahl", 
	        JOptionPane.QUESTION_MESSAGE
	    );
	    if (name != null) {
	    	JFileChooser saver = new JFileChooser();
	    	saver.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
			saver.setCurrentDirectory(new File(this.preferredPath));
	        int returnVal = saver.showSaveDialog(null);
	        if (returnVal == JFileChooser.APPROVE_OPTION) {
	            File file = saver.getSelectedFile();
	            String path = file.getAbsolutePath();
	            Static.savePreferedFolder(path);
            	this.preferredPath = path;
	            sortCutscenes(name, path + File.separator);
	        }
	    }
	}
	
	private void sortCutscenes(String name, String path) {
		ArrayList<ArrayList<Event>> sortedEvents = new ArrayList<ArrayList<Event>>();
		int number = -1;
		for (Event event : this.list.getSorted()) {
			if (event.getCSNr() != number) {
				sortedEvents.add(new ArrayList<Event>());
				number = event.getCSNr();
			}
			sortedEvents.get(number).add(event);
		}

		String fileName = name;
		int cs = 0;
		for (ArrayList<Event> list : sortedEvents) {
			String string = (cs == 0) ? "" : "appendix" + cs;
			if (cs == number) {
				exportCS(path + fileName + string + ".cs", null, list);
			} else {
				exportCS(path + fileName + string + ".cs", fileName + "appendix" + ++cs, list);
			}
		}
    	JOptionPane.showMessageDialog(null, "Die Cutscenes werden generiert und gespeichert!");
	}
	
	private void exportCS(String path, String loadName, ArrayList<Event> events) {
        ArrayList<Event> list = events;
        ScriptEvent script = new ScriptEvent();
        script.setTime(list.get(list.size() - 1).getTime());
        if (loadName != null) {
        	script.setCode("Camera.StartCutscene('" + loadName + "')");
        	script.setLocal();
        } else {
        	script.setCode("AddOnGameCutscenes.Local:CheckWaitList()");
        	script.setLocal();
        }
        list.add(script);
        
        ArrayList<String> xml = new ArrayList<String>();
        
        xml.add("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        xml.add("<root>");
        xml.add("  <EventCollection>");
        
        for (Event event : events) {
	        xml.addAll(event.getXML());
        }
        
        xml.add("  </EventCollection>");
        xml.add("</root>");
        
		PrintWriter out = null;
		try {
			BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(path));
			OutputStreamWriter osw = new OutputStreamWriter(bos, "UTF-8");
			out = new PrintWriter(osw);
			for (int i = 0; i < xml.size(); i++) {
				out.println(xml.get(i));
			}
		} catch (IOException e1) {
			String a = e1.getLocalizedMessage();
			JOptionPane.showConfirmDialog(null, a, "f", JOptionPane.CANCEL_OPTION);
		} finally {
			if (out != null) {
				out.flush();
		    	out.close();
			}
		}
	}

}
