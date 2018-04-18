package twa.symfonia.view.component;

import java.awt.Font;
import java.awt.font.TextAttribute;
import java.util.Collections;

import javax.swing.JCheckBox;
import javax.swing.JLabel;

import twa.symfonia.config.Configuration;

/**
 * Erzeugt eine Bundle Kachel für gewöhnliche Bundles.
 * 
 * @author totalwarANGEL
 *
 */
@SuppressWarnings("serial")
public class SymfoniaJBundle extends SymfoniaJPanelGray
{

    /**
     * Id des Bundle (-> Name des Folders)
     */
    protected String id;

    /**
     * Titel des Bundle
     */
    protected JLabel title;

    /**
     * Text des Bundle
     */
    protected JLabel text;

    /**
     * Checkbox
     */
    protected JCheckBox checkbox;

    /**
     * Erzeugt eine Bundle-Kachel mit einem bestimmten Titel und einer bestimmten
     * Größe.
     * 
     * @param id Id des Bundle (-> Name des Folders)
     * @param title Titel des Bundle
     * @param text Text des Bundle
     * @param x Breite
     * @param y Höhe
     */
    public SymfoniaJBundle(final String id, final String title, final String text, final int x, final int y)
    {
        super(null);
        super.applyConfiguration();
        this.id = id;
        setSize(x, y);
        createComponents(title, text, x, y);
    }

    /**
     * Erzeugt die KMomponenten und konfiguriert sie.
     * 
     * @param title Titel des Bundle
     * @param text Text des Bundle
     * @param x Breite
     * @param y Höhe
     */
    protected void createComponents(final String title, final String text, final int x, final int y)
    {
        this.title = new JLabel("<html><b>" + title + "</b></html>");
        this.title.setBounds(40, 5, x - 80, 20);
        this.title.setVisible(true);
        add(this.title);

        this.text = new JLabel("<html><p>" + text + "</p></html>");
        this.text.setBounds(40, 25, x - 80, 50);
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
     * Gibt die ID des Bundles zurück.
     * 
     * @return ID
     */
    public String getID()
    {
        return id;
    }

    /**
     * Setzt das Selected Flag des Bundles.
     * 
     * @param checked Flag
     */
    public void setChecked(final boolean checked)
    {
        checkbox.setSelected(checked);
    }

    /**
     * Gibt zurück, ob das Bundle ausgewählt ist.
     * 
     * @return Ausgewählt
     */
    public boolean isChecked()
    {
        return checkbox.isSelected();
    }

    /**
     * Setzt das Bundle als auswählbar.
     * 
     * @param flag Auswählbar
     */
    public void setUsable(final boolean flag)
    {
        if (flag == false)
        {
            checkbox.setSelected(false);
        }
        checkbox.setEnabled(flag);
    }

    /**
     * Gibt zurück, ob das Bundle auswählbar ist.
     * 
     * @return Auswählbar
     */
    public boolean isUseable()
    {
        return checkbox.isEnabled();
    }
}
