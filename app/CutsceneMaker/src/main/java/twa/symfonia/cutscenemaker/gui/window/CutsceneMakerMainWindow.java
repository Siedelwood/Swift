package twa.symfonia.cutscenemaker.gui.window;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextField;
import javax.swing.ListSelectionModel;

import twa.symfonia.cutscenemaker.gui.CutsceneMakerUIException;

/**
 * 
 * @author angermanager
 *
 */
public class CutsceneMakerMainWindow extends JFrame implements ActionListener
{
    private final int w;
    private final int h;
    
    private JPanel mainPanel;
    private JPanel exportPanel;
    private JPanel flightPanel;
    private JPanel stationsPanel;
    private JPanel propertiesPanel;
    private JList flightList;
    private final List<JButton> buttons;
    private final List<JTextField> textFields;
    
    private static int BUTTON_EXPORT_SAVE = 0;
    private static int BUTTON_EXPORT_LOAD = 1;
    private static int BUTTON_EXPORT_READY = 2;
    private static int BUTTON_FLIGHT_OPEN = 3;
    
    private static int TEXTFIELD_FLIGHT_PATH = 0;
    
    /**
     * 
     * @param w
     * @param h
     * @throws CutsceneMakerUIException 
     */
    public CutsceneMakerMainWindow(final int w, final int h) throws CutsceneMakerUIException {
        this.w = w;
        this.h = h;
        
        buttons = new ArrayList<>();
        textFields = new ArrayList<>();
        buildWindow();
    }
    
    /**
     * 
     */
    private void buildWindow() throws CutsceneMakerUIException {
        // Dont change order!
        createMainWindow();
        createExportGroup();
        createFlightGroup();
        createStationsGroup();
        createPropertiesGroup();
    }
    
    /**
     * 
     * @throws CutsceneMakerUIException
     */
    private void createMainWindow() throws CutsceneMakerUIException {
        setBounds(0, 0, w, h);
        setLocationRelativeTo(null);
        setResizable(false);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setTitle("Cutscene Maker");
        
        mainPanel = new JPanel(null);
        mainPanel.setBounds(0, 0, w, h);
        add(mainPanel);
        
        setVisible(true);
    }
    
    
    private void createExportGroup() {
        exportPanel = new JPanel(null);
        exportPanel.setBounds(2, h-90, w-10, 60);
        exportPanel.setBorder(BorderFactory.createTitledBorder("Export"));
        exportPanel.setVisible(true);
        
        final JButton load = new JButton("Öffnen");
        load.setBounds(10, 20, 120, 30);
        load.addActionListener(this);
        buttons.add(load);
        exportPanel.add(load);
        
        final JButton save = new JButton("Speichern");
        save.setBounds(w-270, 20, 120, 30);
        save.addActionListener(this);
        buttons.add(save);
        exportPanel.add(save);
        
        final JButton export = new JButton("Exportieren");
        export.setBounds(w-140, 20, 120, 30);
        export.addActionListener(this);
        buttons.add(export);
        exportPanel.add(export);
        
        mainPanel.add(exportPanel);
    }
    
    
    private void createFlightGroup() {
        flightPanel = new JPanel(null);
        flightPanel.setBounds(2, 0, 300, h-90);
        flightPanel.setBorder(BorderFactory.createTitledBorder("Flights"));
        flightPanel.setVisible(true);
        
        final JButton open = new JButton("Laden");
        open.setBounds(10, h-130, 120, 30);
        open.addActionListener(this);
        buttons.add(open);
        flightPanel.add(open);
        
        final JTextField path = new JTextField();
        path.setEditable(false);
        path.setBounds(10, h-155, 280, 20);
        textFields.add(path);
        flightPanel.add(path);
        
        final JScrollPane scrollPane = new JScrollPane();
        flightList = new JList();
        flightList.setBounds(10, 20, 280, h-185);
        flightList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        flightList.setBorder(BorderFactory.createLineBorder(new Color(200, 200, 255), 1));
        flightList.setVisible(true);
        scrollPane.setViewportView(flightList);
        scrollPane.setPreferredSize(new Dimension(280, h-185));
        scrollPane.setVisible(true);
        flightPanel.add(flightList);
        
        mainPanel.add(flightPanel);
    }
    
    
    private void createStationsGroup() {
        stationsPanel = new JPanel(null);
        stationsPanel.setBounds(306, 0, 300, h-90);
        stationsPanel.setBorder(BorderFactory.createTitledBorder("Stationen"));
        stationsPanel.setVisible(true);
        
        mainPanel.add(stationsPanel);
    }
    
    
    private void createPropertiesGroup() {
        propertiesPanel = new JPanel(null);
        propertiesPanel.setBounds(w-390, 0, 380, h-90);
        propertiesPanel.setBorder(BorderFactory.createTitledBorder("Eigenschaften"));
        propertiesPanel.setVisible(true);
        
        mainPanel.add(propertiesPanel);
    }
    
    @Override
    public void actionPerformed(final ActionEvent e)
    {
        // 
        if (e.getSource() == buttons.get(BUTTON_EXPORT_LOAD)) {
            
        }
        
        // 
        if (e.getSource() == buttons.get(BUTTON_EXPORT_SAVE)) {
            
        }
        
        // 
        if (e.getSource() == buttons.get(BUTTON_EXPORT_READY)) {
            
        }
        
        // 
        if (e.getSource() == buttons.get(BUTTON_FLIGHT_OPEN)) {
            
        }
    }
}
