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
 * Implementation eines XML-Readers für String Tables wie aus dem Spiel bekannt.
 * 
 * @author totalwarANGEL
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
     * {@inheritDoc}
     */
    @Override
    public String getString(final String key) throws XmlReaderException
    {
        return (String) xPath(key, XPathConstants.STRING);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Node getNode(final String key) throws XmlReaderException
    {
        return (Node) xPath(key, XPathConstants.NODE);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public NodeList getNodeSet(final String key) throws XmlReaderException
    {
        return (NodeList) xPath(key, XPathConstants.NODESET);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean getBoolean(final String key) throws XmlReaderException
    {
        return (boolean) xPath(key, XPathConstants.BOOLEAN);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public double getDouble(final String key) throws XmlReaderException
    {
        return (double) xPath(key, XPathConstants.NUMBER);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int getInteger(final String key) throws XmlReaderException
    {
        return (int) xPath(key, XPathConstants.NUMBER);
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
     * @param key Suchpfad
     * @param type Rückgabetyp
     * @return Ergebnis des XPath
     * @throws XmlReaderException
     */
    private Object xPath(final String key, final QName type) throws XmlReaderException
    {
        Object nodes = null;
        try
        {
            // Datei und Key ermitteln
            final int FileIndex = key.indexOf("/");
            final int IdIndex = key.indexOf("/") + 1;
            final String fileName = key.substring(0, FileIndex);
            final String id = key.substring(IdIndex);
            openXml("config/text/" + fileName + ".xml");

            // Text ermitteln
            final String xPathString = "/root/text[@id='" + id + "']/text()";
            final XPathFactory xPathfactory = XPathFactory.newInstance();
            final XPath xpath = xPathfactory.newXPath();
            final XPathExpression expr = xpath.compile(xPathString);
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
