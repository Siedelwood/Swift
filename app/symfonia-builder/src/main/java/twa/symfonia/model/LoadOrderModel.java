package twa.symfonia.model;

import java.util.ArrayList;
import java.util.List;

/**
 * 
 * @author totalwarANGEL
 *
 */
public class LoadOrderModel
{
    /**
     * 
     */
    private List<String> loadOrder;

    /**
     * 
     */
    private int iterator = 0;

    /**
     * 
     */
    public LoadOrderModel()
    {
        final List<String> loadOrder = new ArrayList<>();
    }

    /**
     * 
     * @param id
     * @return
     */
    public boolean isInside(final String id)
    {
        for (final String s : loadOrder)
        {
            if (s.equals(id))
            {
                return true;
            }
        }
        return false;
    }

    /**
     * 
     * @return
     */
    public List<String> getLoadOrder()
    {
        return loadOrder;
    }

    /**
     * 
     * @param id
     */
    public void add(final String id)
    {
        if (!isInside(id))
        {
            loadOrder.add(id);
        }
    }

    /**
     * 
     * @return
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
     * 
     */
    public void rewind()
    {
        iterator = 0;
    }
}
