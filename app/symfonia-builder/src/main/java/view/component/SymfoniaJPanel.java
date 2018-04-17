package view.component;

import java.awt.Color;
import java.awt.LayoutManager;

import javax.swing.JPanel;

import config.Configuration;

/**
 * Erzeugt ein Panel mit einem gelborangen Hintergrund.
 * 
 * @author angermanager
 *
 */
@SuppressWarnings("serial")
public class SymfoniaJPanel extends JPanel {

    /**
     * {@inheritDoc}
     */
    public SymfoniaJPanel() {
        super();
        applyConfiguration();
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaJPanel(final boolean b) {
        super(b);
        applyConfiguration();
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaJPanel(final LayoutManager l, final boolean b) {
        super(l, b);
        applyConfiguration();
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaJPanel(final LayoutManager l) {
        super(l);
        applyConfiguration();
    }

    /**
     * Wendet die Konfiguration auf den Button an.
     */
    protected void applyConfiguration() {
        final Color bg = Configuration.getColor("defaults.colors.bg.normal");
        setBackground(bg);
    }

}
