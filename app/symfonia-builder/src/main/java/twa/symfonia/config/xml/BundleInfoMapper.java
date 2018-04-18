package twa.symfonia.config.xml;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.PatternSyntaxException;

import javax.xml.namespace.QName;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import twa.symfonia.model.BundleModel;

/**
 * Ließt die Informationen eines Bundles oder eines Ordner mit Bundles darin
 * aus.
 * 
 * @author totalwarANGEL
 *
 */
public class BundleInfoMapper
{

    /**
     * Ließt die Info-Datei eines Bundles aus und erstellt daraus ein
     * BundleModel-Objekt.
     * 
     * @param path Pfad zur Info-Datei
     * @return Bundle
     * @throws BundleInfoMapperException
     */
    public BundleModel parseInfo(final String path) throws BundleInfoMapperException
    {
        final Document xml = openXml(path);

        final String id = (String) xPath(xml, "root/id/text()", XPathConstants.STRING);
        final String title = (String) xPath(xml, "root/name/text()", XPathConstants.STRING);
        final String text = (String) xPath(xml, "root/description/text()", XPathConstants.STRING);

        final List<String> dependencyList = new ArrayList<>();
        final NodeList dependencies = (NodeList) xPath(xml, "root/dependencies/dependency", XPathConstants.NODESET);
        for (int i = 0; i < dependencies.getLength(); i++)
        {
            dependencyList.add(dependencies.item(i).getTextContent());
        }

        final List<String> exclusionList = new ArrayList<>();
        final NodeList exclusions = (NodeList) xPath(xml, "root/exclusions/exclusion", XPathConstants.NODESET);
        for (int i = 0; i < exclusions.getLength(); i++)
        {
            exclusionList.add(exclusions.item(i).getTextContent());
        }

        final BundleModel bundle = new BundleModel(id, title, text, dependencyList, exclusionList);
        return bundle;
    }

    /**
     * Versucht alle Bundles in einem Ordner einzulesen und gibt im Erfolgsfall eine
     * Liste von Bundles zurück.
     * 
     * @param path Pfad des Ordners
     * @return Liste der Bundles
     * @throws BundleInfoMapperException
     */
    public List<BundleModel> parseFolder(final String path) throws BundleInfoMapperException
    {
        final List<File> folders = listBundleDirectories(path);
        if (folders.isEmpty())
        {
            throw new BundleInfoMapperException("Folder does not contain valid bundles!");
        }
        final List<BundleModel> bundleList = new ArrayList<>();
        for (final File f : folders)
        {
            bundleList.add(parseInfo(f.getAbsolutePath() + "/info.xml"));
        }
        return bundleList;
    }

    /**
     * Wendet einen XPath auf das übergebene XML-Dokument an und gibt das Ergebnis
     * zurück.
     * 
     * @param doc XML-Dokument
     * @param xPath XPath
     * @param type Rückgabetyp
     * @return Ergebnis des XPath
     * @throws BundleInfoMapperException
     */
    private Object xPath(final Document doc, final String xPath, final QName type) throws BundleInfoMapperException
    {
        Object nodes = null;
        try
        {
            final XPathFactory xPathfactory = XPathFactory.newInstance();
            final XPath xpath = xPathfactory.newXPath();
            final XPathExpression expr = xpath.compile(xPath);
            nodes = expr.evaluate(doc, type);
        } catch (final Exception e)
        {
            throw new BundleInfoMapperException(e);
        }
        return nodes;
    }

    /**
     * Öffnet die XML-Datei und parst sie in ein Document object.
     * 
     * @param path Pfad zum XML
     * @return XML als Document
     * @throws BundleInfoMapperException
     */
    private Document openXml(final String path) throws BundleInfoMapperException
    {
        Document doc = null;
        try
        {
            final File inputFile = new File(unixfyPath(path));
            final DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder;
            dBuilder = dbFactory.newDocumentBuilder();
            doc = dBuilder.parse(inputFile);
            doc.getDocumentElement().normalize();
        } catch (final Exception e)
        {
            throw new BundleInfoMapperException(e);
        }
        return doc;
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

    /**
     * Gibt eine Liste von Bundle-Ordnern zurück. Der Name eines Bundles muss immer
     * entweder mit "bundle" oder mit "addon" beginnen und es muss ein Dateiordner
     * sein.
     * 
     * @param path Pfad des Ordners
     * @return Liste der Bundle-Ordner
     */
    public List<File> listBundleDirectories(final String path)
    {
        final File folder = new File(unixfyPath(path));
        final File[] listOfFiles = folder.listFiles();

        final List<File> directories = new ArrayList<>();
        for (int i = 0; i < listOfFiles.length; i++)
        {
            if (listOfFiles[i].isDirectory())
            {
                if (!listOfFiles[i].getName().endsWith("/.") && !listOfFiles[i].getName().endsWith("/.."))
                {
                    // Vorläufig als Kriterium deaktiviert
                    // if (listOfFiles[i].getName().contains("bundle") ||
                    // listOfFiles[i].getName().contains("addon")) {
                    directories.add(listOfFiles[i]);
                    // }
                }
            }
        }
        return directories;
    }
}
