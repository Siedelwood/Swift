package view.component;

import java.awt.Color;
import java.awt.Font;
import java.awt.font.TextAttribute;
import java.util.Collections;

import javax.swing.BorderFactory;
import javax.swing.JCheckBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;

import config.Configuration;

/**
 * Erzeugt eine Bundle Kachel für gewöhnliche Bundles.
 * @author totalwarANGEL
 *
 */
@SuppressWarnings("serial")
public class SymfoniaJBundle extends SymfoniaJPanelGray {
    /**
     * Titel des Bundle
     */
    protected JLabel title;
    
    /**
     * Titel des Bundle
     */
    protected JLabel text;
    
    /**
     * Checkbox
     */
    protected JCheckBox checkbox;

    /**
     * Erzeugt eine Bundle-Kachel mit einem bestimmten Titel und einer
     * bestimmten Größe.
     */
    public SymfoniaJBundle(String title, String text, int x, int y) {
        super(null);
        super.applyConfiguration();
        setSize(x, y);
        createComponents(title, text, x, y);
    }
    
    /**
     * Erzeugt die KMomponenten und konfiguriert sie.
     */
    protected void createComponents(String title, String text, int x, int y) {
        this.title = new JLabel("<html><b>" + title + "</b></html>");
        this.title.setBounds(40, 5, x-80, 20);
        this.title.setVisible(true);
        add(this.title);
        
        this.text = new JLabel("<html><p>" + text + "</p></html>");
        this.text.setBounds(40, 25, x-80, 50);
        this.text.setVisible(true);
        this.text.setVerticalAlignment(JLabel.TOP);
        this.text.setVerticalTextPosition(JLabel.TOP);
        Font font = this.text.getFont();
        font = font.deriveFont(Collections.singletonMap(TextAttribute.WEIGHT, TextAttribute.WEIGHT_SEMIBOLD));
        this.text.setFont(font);
        add(this.text);
        
        this.checkbox = new JCheckBox();
        this.checkbox.setBounds(10, 5, 20, 20);
        this.checkbox.setVisible(true);
        this.checkbox.setBackground(Configuration.getColor("defaults.colors.bg.gray"));
        add(this.checkbox);
    }
    
    /**
     * Setzt das Selected Flag des Bundles.
     * @param checked Flag
     */
    public void setChecked(boolean checked) {
        checkbox.setSelected(true);
    }
    
    /**
     * Gibt zurück, ob das Bundle ausgewählt ist.
     * @return Ausgewählt
     */
    public boolean isChecked() {
        return checkbox.isSelected();
    }
    
    /**
     * Test
     */
    public static void main(String[] args) {
        JFrame f = new JFrame();
        f.setBounds(0, 0, 700, 200);
        f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        
        JPanel p = new JPanel(null);
        p.setBounds(0, 0, 700, 300);
        p.setVisible(true);
        f.add(p);
        
        SymfoniaJBundle b = new SymfoniaJBundle("Bockwurst", "Das ist lecker Bockwurst", 400, 75);
        b.setLocation(50, 25);
        b.setVisible(true);
        p.add(b);
        
        f.setVisible(true);
    }
}
