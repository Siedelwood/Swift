package twa.symfonia.model;

/**
 * Datenmodell für die Konfiguration des QSB-Builder.
 * 
 * @author angermanager
 *
 */
public class QsbPackagingModel
{

    /**
     * Load Order
     */
    private final LoadOrderModel filesList;

    /**
     * Zielverzeichnis
     */
    private final String destination;

    /**
     * Dokumentation kopieren
     */
    private final boolean copyDoc;

    /**
     * Basisskripte kopieren
     */
    private final boolean copyBaseScripts;

    /**
     * Beispiele kopieren
     */
    private final boolean copyExamples;

    /**
     * QSB minimieren
     */
    private final boolean minifyQsb;

    /**
     * Constructor
     * 
     * @param filesList Load Order
     * @param destination Zielverzeichnis
     * @param copyDoc Dokumentation kopieren
     * @param copyBaseScripts Basisskripte kopieren
     * @param copyExamples Beispiele kopieren
     * @param minifyQsb QSB minimieren
     */
    public QsbPackagingModel(final LoadOrderModel filesList, final String destination, final boolean copyDoc,
        final boolean copyBaseScripts, final boolean copyExamples, final boolean minifyQsb)
    {
        this.filesList = filesList;
        this.destination = destination;
        this.copyDoc = copyDoc;
        this.copyBaseScripts = copyBaseScripts;
        this.copyExamples = copyExamples;
        this.minifyQsb = minifyQsb;
    }

    /**
     * Gibt die Load Order zurück.
     * 
     * @return Load Order
     */
    public LoadOrderModel getLoadOrder()
    {
        return filesList;
    }

    /**
     * Gibt das Zielverzeichnis zurück.
     * 
     * @return Zielverzeichnis
     */
    public String getDestination()
    {
        return destination;
    }

    /**
     * Gibt zurück, ob die Dokumentation kopiert wird.
     * 
     * @return Dokumentation kopieren
     */
    public boolean isCopyDoc()
    {
        return copyDoc;
    }

    /**
     * Gibt zurück, ob die Basisskripte kopiert werden.
     * 
     * @return Basisskripte kopieren
     */
    public boolean isCopyBaseScripts()
    {
        return copyBaseScripts;
    }

    /**
     * Gibt zurück, ob die Beispielskripte kopiert werden.
     * 
     * @return Beispiele kopieren
     */
    public boolean isCopyExamples()
    {
        return copyExamples;
    }

    /**
     * Gibt zurück, ob die QSB minimiert wird.
     * 
     * @return QSB minimieren
     */
    public boolean isMinifyQsb()
    {
        return minifyQsb;
    }

}
