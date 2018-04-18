package twa.symfonia.config.xml;

import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public interface XmlReaderInterface
{
    /**
     * Führt den Suchpfad aus und gibt das Ergebnis als String zurück.
     * 
     * @param key Suchpfad
     * @return Ergebnis als String
     * @throws XmlReaderException
     */
    public String getString(final String key) throws XmlReaderException;

    /**
     * Führt den Suchpfad aus und gibt das Ergebnis als Node zurück.
     * 
     * @param key Suchpfad
     * @return Ergebnis als Node
     * @throws XmlReaderException
     */
    public Node getNode(final String key) throws XmlReaderException;

    /**
     * Führt den Suchpfad aus und gibt das Ergebnis als NodeList zurück.
     * 
     * @param key Suchpfad
     * @return Ergebnis als NodeList
     * @throws XmlReaderException
     */
    public NodeList getNodeSet(final String key) throws XmlReaderException;

    /**
     * Führt den Suchpfad aus und gibt das Ergebnis als boolean zurück.
     * 
     * @param key Suchpfad
     * @return Ergebnis als boolean
     * @throws XmlReaderException
     */
    public boolean getBoolean(final String key) throws XmlReaderException;

    /**
     * Führt den Suchpfad aus und gibt das Ergebnis als double zurück.
     * 
     * @param key Suchpfad
     * @return Ergebnis als double
     * @throws XmlReaderException
     */
    public double getDouble(final String key) throws XmlReaderException;

    /**
     * Führt den Suchpfad aus und gibt das Ergebnis als int zurück.
     * 
     * @param key Suchpfad
     * @return Ergebnis als int
     * @throws XmlReaderException
     */
    public int getInteger(final String key) throws XmlReaderException;

    /**
     * Öffnet die XML-Datei und parst sie in ein Document object.
     * 
     * @param path Pfad zum XML
     * @return XML als Document
     * @throws XmlReaderException
     */
    public void openXml(final String path) throws XmlReaderException;
}
