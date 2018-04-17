package twa.symfonia.model;

import java.util.List;

/**
 * Model zur internen Representation eines Bundles/AddOns.
 * @author mheller
 *
 */
public class BundleModel
{
    /**
     * ID
     */
    private final String id;
    
    /**
     * Anzeigename
     */
    private final String name;
    
    /**
     * Beschreibungstext
     */
    private final String description;
    
    /**
     * Benötigte Bundles
     */
    private final List<String> dependencies;
    
    /**
     * Ausgeschlossene Bundles
     */
    private final List<String> exclusions;
    
    /**
     * Ist AddOn
     */
    private boolean isAddOn;

    /**
     * 
     * @param id ID
     * @param name Anzeigename
     * @param description Beschreibungstext
     * @param dependencies Benötigte Bundles
     * @param exclusions Ausgeschlossene Bundles
     * @param addOn Ist AddOn
     */
    public BundleModel(final String id, final String name, final String description, final List<String> dependencies, final List<String> exclusions)
    {
        this.id = id;
        this.name = name;
        this.description = description;
        this.dependencies = dependencies;
        this.exclusions = exclusions;
    }

    /**
     * Setzt das Bundle als AddOn.
     * @param isAddOn AddOn
     */
    public void setAddOn(final boolean isAddOn)
    {
        this.isAddOn = isAddOn;
    }

    /**
     * Gibt die ID, den Ordnernamen, des Bundles zurück.
     * @return ID
     */
    public String getId()
    {
        return id;
    }

    /**
     * Gibt den angezeigten Namen des Bundles zurück.
     * @return Name
     */
    public String getName()
    {
        return name;
    }

    /**
     * Gibt den beschreibungstext des Bundles zurück.
     * @return Beschreibungstext
     */
    public String getDescription()
    {
        return description;
    }

    /**
     * Gibt die Liste der Bundles zurück, die für dieses Bundle vorausgesetzt werden.
     * @return Vorausgesetzte bundles
     */
    public List<String> getDependencies()
    {
        return dependencies;
    }

    /**
     * Gibt die Liste der Bundles zurück, die nicht mit diesem Bundle kompatibel sind.
     * @return Ausgeschlossene bundles
     */
    public List<String> getExclusions()
    {
        return exclusions;
    }

    /**
     * Gibt true zurück, wenn das Bundle ein AddOn ist.
     * @return Bundle ist Addon
     */
    public boolean isAddOn()
    {
        return isAddOn;
    }
}
