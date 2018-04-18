package twa.symfonia.config.xml;

import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public interface XmlReaderInterface
{
    /**
     * Führt den XPath aus und gibt das Ergebnis als String zurück.
     * 
     * @param xPath Suchpfad
     * @return Ergebnis als String
     * @throws XmlReaderException
     */
    public String getString(final String xPath) throws XmlReaderException;

    /**
     * Führt den XPath aus und gibt das Ergebnis als Node zurück.
     * 
     * @param xPath Suchpfad
     * @return Ergebnis als Node
     * @throws XmlReaderException
     */
    public Node getNode(final String xPath) throws XmlReaderException;

    /**
     * Führt den XPath aus und gibt das Ergebnis als NodeList zurück.
     * 
     * @param xPath Suchpfad
     * @return Ergebnis als NodeList
     * @throws XmlReaderException
     */
    public NodeList getNodeSet(final String xPath) throws XmlReaderException;

    /**
     * Führt den XPath aus und gibt das Ergebnis als boolean zurück.
     * 
     * @param xPath Suchpfad
     * @return Ergebnis als boolean
     * @throws XmlReaderException
     */
    public boolean getBoolean(final String xPath) throws XmlReaderException;

    /**
     * Führt den XPath aus und gibt das Ergebnis als double zurück.
     * 
     * @param xPath Suchpfad
     * @return Ergebnis als double
     * @throws XmlReaderException
     */
    public double getDouble(final String xPath) throws XmlReaderException;

    /**
     * Führt den XPath aus und gibt das Ergebnis als int zurück.
     * 
     * @param xPath Suchpfad
     * @return Ergebnis als int
     * @throws XmlReaderException
     */
    public int getInteger(final String xPath) throws XmlReaderException;

    /**
     * Öffnet die XML-Datei und parst sie in ein Document object.
     * 
     * @param path Pfad zum XML
     * @return XML als Document
     * @throws XmlReaderException
     */
    public void openXml(final String path) throws XmlReaderException;
}
