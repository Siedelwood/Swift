package twa.symfonia.service.gui;

import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.List;

import twa.symfonia.model.BundleModel;
import twa.symfonia.service.xml.BundleInfoMapper;
import twa.symfonia.view.component.SymfoniaJAddOn;
import twa.symfonia.view.component.SymfoniaJBundle;

/**
 * Baut die Bundle-Kacheln für die Selektionlisten in der Komponentenauswahl.
 * 
 * @author angermanager
 *
 */
public class BundleTileBuilderService
{

    /**
     * Bereitet die Liste der Bundle-Kacheln für die Selektion vor.
     * 
     * @param path Pfad zum Quellordner
     * @return Liste mit Kacheln
     */
    public List<SymfoniaJBundle> prepareBundles(final String path)
    {
        final List<SymfoniaJBundle> bundleList = new ArrayList<>();
        try
        {
            final BundleInfoMapper mapper = new BundleInfoMapper();
            final List<BundleModel> bundleModels = mapper.parseFolder(path);
            for (final BundleModel bM : bundleModels)
            {
                bundleList.add(new SymfoniaJBundle(bM.getId(), bM.getName(), bM.getDescription(), 700, 64));
            }
        } catch (final Exception e)
        {
            e.printStackTrace();
        }
        return bundleList;
    }

    /**
     * Bereitet die Liste der AddOn-Kacheln für die Selektion vor.
     * 
     * @param path Pfad zum Quellordner
     * @param actionListener Action Listener
     * @return Liste mit Kacheln
     */
    public List<SymfoniaJAddOn> prepareAddOns(final String path, final ActionListener actionListener)
    {
        final List<SymfoniaJAddOn> bundleList = new ArrayList<>();
        try
        {
            final BundleInfoMapper mapper = new BundleInfoMapper();
            final List<BundleModel> bundleModels = mapper.parseFolder(path);
            for (final BundleModel bM : bundleModels)
            {
                bundleList.add(new SymfoniaJAddOn(bM.getId(), bM.getName(), bM.getDescription(), bM.getDependencies(),
                        700, 80, actionListener));
            }
        } catch (final Exception e)
        {
            e.printStackTrace();
        }
        return bundleList;
    }
}
