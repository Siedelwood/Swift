package twa.symfonia.config.xml;

import java.io.File;
import java.util.regex.PatternSyntaxException;

import javax.xml.namespace.QName;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import twa.symfonia.app.SymfoniaQsbBuilder;

/**
 * 
 * @author mheller
 *
 */
public class XmlReaderStringTableImpl implements XmlReaderInterface
{
    /**
     * XML-Dokument
     */
    private Document xmlDocument;

    /**
     * Constructor
     */
    public XmlReaderStringTableImpl()
    {

    }

    /**
     * Erzeugt eine Instanz des Readers und öffnet die XML-Datei.
     * 
     * @param path Path to XML-File
     * @throws XmlReaderException
     */
    public XmlReaderStringTableImpl(final String path) throws XmlReaderException
    {
        openXml(path);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getString(final String xPath) throws XmlReaderException
    {
        return (String) xPath(xPath, XPathConstants.STRING);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Node getNode(final String xPath) throws XmlReaderException
    {
        return (Node) xPath(xPath, XPathConstants.NODE);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public NodeList getNodeSet(final String xPath) throws XmlReaderException
    {
        return (NodeList) xPath(xPath, XPathConstants.NODESET);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean getBoolean(final String xPath) throws XmlReaderException
    {
        return (boolean) xPath(xPath, XPathConstants.BOOLEAN);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public double getDouble(final String xPath) throws XmlReaderException
    {
        return (double) xPath(xPath, XPathConstants.NUMBER);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int getInteger(final String xPath) throws XmlReaderException
    {
        return (int) xPath(xPath, XPathConstants.NUMBER);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void openXml(final String path) throws XmlReaderException
    {
        Document doc = null;
        try
        {
            final File inputFile = new File(unixfyPath(SymfoniaQsbBuilder.class.getClassLoader().getResource(path)
                    .getPath()));
            final DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder;
            dBuilder = dbFactory.newDocumentBuilder();
            doc = dBuilder.parse(inputFile);
            doc.getDocumentElement().normalize();
        } catch (final Exception e)
        {
            throw new XmlReaderException(e);
        }
        xmlDocument = doc;
    }

    /**
     * Wendet einen XPath auf das übergebene XML-Dokument an und gibt das Ergebnis
     * zurück.
     * 
     * @param xPath XPath
     * @param type Rückgabetyp
     * @return Ergebnis des XPath
     * @throws XmlReaderException
     */
    private Object xPath(final String xPath, final QName type) throws XmlReaderException
    {
        Object nodes = null;
        try
        {
            final XPathFactory xPathfactory = XPathFactory.newInstance();
            final XPath xpath = xPathfactory.newXPath();
            final XPathExpression expr = xpath.compile(xPath);
            nodes = expr.evaluate(xmlDocument, type);
        } catch (final Exception e)
        {
            throw new XmlReaderException(e);
        }
        return nodes;
    }

    /**
     * Wandelt einen Windows-Pfad in einen Unix-Pfad um.
     * 
     * @param path Pfad zum umwandeln
     * @return Umgewandelter Pfad
     */
    private String unixfyPath(final String path)
    {
        try
        {
            final String newPath = path.replaceAll("\\\\", "/");
            return newPath;
        } catch (final PatternSyntaxException e)
        {
            return path;
        }
    }
}
