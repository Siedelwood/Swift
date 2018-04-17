package twa.symfonia.view.component;

import java.awt.Dimension;
import java.util.ArrayList;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;

import twa.symfonia.config.Configuration;

/**
 * Zeigt eine Liste von Bundles an.
 * 
 * @author totalwarANGEL
 * 
 */
@SuppressWarnings("serial")
public class SymfoniaJBundleScrollPane extends JScrollPane
{
    /**
     * Viewport
     */
    private JPanel content = null;

    /**
     * Liste der Bundles
     */
    private List<SymfoniaJBundle> bundles;

    /**
     * COnstruktor
     * 
     * @param x Breite
     * @param y Höhe
     * @param bundles Liste der Bundles
     */
    public SymfoniaJBundleScrollPane(final int x, final int y, final List<SymfoniaJBundle> bundles)
    {
        this.bundles = bundles;
        final int amount = bundles.size();
        if (amount == 0)
        {
            return;
        }

        final int bundleHeight = bundles.get(0).getHeight();
        content = new JPanel(null);
        content.setBounds(0, 0, x, (bundleHeight + 6) * amount);
        content.setPreferredSize(new Dimension(x, (bundleHeight + 1) * amount));
        content.setBorder(BorderFactory.createEmptyBorder());
        content.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
        content.setVisible(true);
        add(content);

        int posY = 0;
        for (int i = 0; i < bundles.size(); i++)
        {
            final int height = bundles.get(i).getHeight();
            final Dimension size = bundles.get(i).getSize();
            size.width = x;
            bundles.get(i).setSize(size);
            bundles.get(i).setLocation(0, posY);
            bundles.get(i).setVisible(true);
            content.add(bundles.get(i));
            posY += height + 1;
        }

        setViewportView(content);
        setBounds(0, 0, x + 20, y);
        setPreferredSize(getSize());
        setBorder(BorderFactory.createEmptyBorder());
        setVisible(true);
    }

    /**
     * Gibt die Liste der Bundles zurück, die der Assistent verwaltet.
     * 
     * @return Liste der Bundles
     */
    public List<SymfoniaJBundle> getBundles()
    {
        return bundles;
    }

    /**
     * Gibt die Liste der Bundles zurück, die vom Nutzer selektiert wurden.
     * 
     * @return Liste der Bundles
     */
    public List<SymfoniaJBundle> getSelectedBundles()
    {
        final List<SymfoniaJBundle> selected = new ArrayList<>();
        for (int i = 0; i < bundles.size(); i++)
        {
            if (bundles.get(i).isChecked())
            {
                selected.add(bundles.get(i));
            }
        }
        return selected;
    }

    /**
     * Gibt das Bundle auf dem angegebenen Index zurück.
     * 
     * @return Bundle auf Index
     */
    public SymfoniaJBundle getBundle(final int idx)
    {
        if (bundles.size() > idx)
        {
            return bundles.get(idx);
        }
        return null;
    }

    /**
     * Gibt das Bundle mit der angegebenen ID zurück.
     * 
     * @param id ID des Bundle
     * @return Bundle mit ID
     */
    public SymfoniaJBundle getBundle(final String id)
    {
        for (int i = 0; i < bundles.size(); i++)
        {
            if (bundles.get(i).getID().equals(id))
            {
                return bundles.get(i);
            }
        }
        return null;
    }

    /**
     * Wählt das Bundle an, dass den Index hat.
     * 
     * @param idx Index
     */
    public void select(final int idx)
    {
        if (bundles.size() > idx)
        {
            bundles.get(idx).setChecked(true);
        }
    }

    /**
     * Wählt das Bundle an, dass die ID hat.
     * 
     * @param id ID
     */
    public void select(final String id)
    {
        if (getBundle(id) != null)
        {
            getBundle(id).setChecked(true);
        }
    }

    /**
     * Wählt das Bundle ab, dass den Index hat.
     * 
     * @param idx Index
     */
    public void deselect(final int idx)
    {
        if (bundles.size() > idx)
        {
            bundles.get(idx).setChecked(false);
        }
    }

    /**
     * Wählt das Bundle ab, dass die ID hat.
     * 
     * @param id ID
     */
    public void deselect(final String id)
    {
        if (getBundle(id) != null)
        {
            getBundle(id).setChecked(false);
        }
    }

    /**
     * Wählt alle Bundles an.
     */
    public void selectAll()
    {
        for (int i = 0; i < bundles.size(); i++)
        {
            bundles.get(i).setChecked(true);
        }
    }

    /**
     * Wählt alle Bundles ab.
     */
    public void deselectAll()
    {
        for (int i = 0; i < bundles.size(); i++)
        {
            bundles.get(i).setChecked(false);
        }
    }

    /**
     * Test
     * 
     * @param args
     */
    public static void main(final String[] args)
    {
        final List<SymfoniaJBundle> list = new ArrayList<>();
        for (int i = 0; i < 5; i++)
        {
            list.add(new SymfoniaJBundle("foo", "Bockwurst", "Das ist ein Test", 700, 75));
        }
        final SymfoniaJBundleScrollPane scroll = new SymfoniaJBundleScrollPane(500, 500, list);
        scroll.setLocation(50, 50);

        final JFrame f = new JFrame();
        f.setBounds(0, 0, 700, 700);
        f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        final JPanel p = new JPanel(null);
        p.setBounds(0, 0, 700, 700);
        p.add(scroll);
        f.add(p);

        p.setVisible(true);
        f.setVisible(true);
    }
}
