package twa.symfonia.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Hält eine Reihenfolge von Strings, die nacheinander iteriert werden können.
 * 
 * @author totalwarANGEL
 *
 */
public class LoadOrderModel
{
    /**
     * Liste mit Strings
     */
    private final List<String> loadOrder;

    /**
     * Iterator
     */
    private int iterator = 0;

    /**
     * Constructor
     */
    public LoadOrderModel()
    {
        loadOrder = new ArrayList<>();
    }

    /**
     * Prüft, ob der Text bereits in der Liste steht.
     * 
     * @param name Text
     * @return Text vorhanden
     */
    public boolean isInside(final String name)
    {
        for (final String s : loadOrder)
        {
            if (s.equals(name))
            {
                return true;
            }
        }
        return false;
    }

    /**
     * Gibt die Liste mit den Texten zurück.
     * 
     * @return Text-Liste
     */
    public List<String> getLoadOrder()
    {
        return loadOrder;
    }

    /**
     * Fügt einen Text der Liste hinzu, wenn er noch nicht enthalten ist.
     * 
     * @param name Text
     */
    public void add(final String name)
    {
        if (!isInside(name))
        {
            loadOrder.add(name);
        }
    }

    /**
     * Iteriert bei jedem Aufruf über die Liste und gibt das nächste Element zurück.
     * Wenn es kein nächstes Element wird null zurückgegeben.
     * 
     * @return Text
     */
    public String next()
    {
        String next = null;
        if (loadOrder.size() > iterator)
        {
            next = loadOrder.get(iterator);
            iterator++;
        }

        return next;
    }

    /**
     * Setzt den Iterator auf die angegebene Position.
     */
    public void rewind(final Integer idx)
    {
        iterator = (idx == null) ? 0 : idx.intValue();
    }
}
