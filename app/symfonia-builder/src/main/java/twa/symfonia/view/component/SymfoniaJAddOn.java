package twa.symfonia.view.component;

import java.awt.Color;
import java.awt.event.ActionListener;
import java.util.List;

import javax.swing.BorderFactory;

import twa.symfonia.config.Configuration;

/**
 * Erzeugt eine AddOn-Bundle Kachel für gewöhnliche Bundles.
 * 
 * @author totalwarANGEL
 *
 */
@SuppressWarnings("serial")
public class SymfoniaJAddOn extends SymfoniaJBundle
{

    /**
     * Liste der Abhängigkeiten (-> Name des Folders)
     */
    protected List<String> dependencies;

    /**
     * Erzeugt eine Bundle-Kachel mit einem bestimmten Titel und einer
     * bestimmten Größe.
     * 
     * @param id Id des Bundle (-> Name des Folders)
     * @param title Titel des Bundle
     * @param text Text des Bundle
     * @param dependencies Liste der Abhängigkeiten (-> Name des Folders)
     * @param x Breite
     * @param y Höhe
     * @param aL Action listener
     */
    public SymfoniaJAddOn(final String id, final String title, final String text, final List<String> dependencies,
	    final int x, final int y, final ActionListener aL)
    {
	super(id, title, text, x, y);
	super.applyConfiguration();
	this.id = id;
	this.dependencies = dependencies;
	setSize(x, y);
	createComponents(title, text, x, y, aL);
    }

    /**
     * Erzeugt die KMomponenten und konfiguriert sie.
     * 
     * @param title Titel des Bundle
     * @param text Text des Bundle
     * @param x Breite
     * @param y Höhe
     * @param aL Action listener
     */
    protected void createComponents(final String title, final String text, final int x, final int y,
	    final ActionListener aL)
    {
	this.checkbox.addActionListener(aL);
	final int bw = Configuration.getInteger("defaults.border.width");
	final Color bc = Configuration.getColor("defaults.colors.border.orange");
	this.checkbox.setBackground(Configuration.getColor("defaults.colors.bg.orange"));
	setBackground(Configuration.getColor("defaults.colors.bg.orange"));
	setBorder(BorderFactory.createLineBorder(bc, bw));
    }

    /**
     * Gibt die Abhängigkeiten des Bundles zurück.
     * 
     * @return IDs Abhängigkeiten
     */
    public List<String> getDependencies()
    {
	return dependencies;
    }

    /**
     * Prüft, ob das Addon von dem Bundle abhängig ist.
     * 
     * @param id ID des Bundles
     * @return IDs Abhängigkeiten
     */
    public boolean dependOn(final String id)
    {
	for (int i = 0; i < dependencies.size(); i++)
	{
	    if (dependencies.get(i).equals(id))
	    {
		return true;
	    }
	}
	return false;
    }
}
