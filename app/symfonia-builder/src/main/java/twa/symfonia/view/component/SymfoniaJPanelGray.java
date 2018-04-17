package twa.symfonia.view.component;

import java.awt.Color;
import java.awt.LayoutManager;

import javax.swing.BorderFactory;

import twa.symfonia.config.Configuration;

/**
 * Erzeugt ein Panel mit einem grauen Hintergrund und Rahmen.
 * 
 * @author angermanager
 *
 */
@SuppressWarnings("serial")
public class SymfoniaJPanelGray extends SymfoniaJPanel
{

    /**
     * {@inheritDoc}
     */
    public SymfoniaJPanelGray()
    {
	super();
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaJPanelGray(final boolean b)
    {
	super(b);
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaJPanelGray(final LayoutManager l, final boolean b)
    {
	super(l, b);
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaJPanelGray(final LayoutManager l)
    {
	super(l);
    }

    /**
     * Wendet die Konfiguration auf den Button an.
     */
    @Override
    protected void applyConfiguration()
    {
	final int bw = Configuration.getInteger("defaults.border.width");
	final Color bc = Configuration.getColor("defaults.colors.border.gray");

	setBorder(BorderFactory.createLineBorder(bc, bw));
	final Color bg = Configuration.getColor("defaults.colors.bg.gray");
	setBackground(bg);
    }
}
