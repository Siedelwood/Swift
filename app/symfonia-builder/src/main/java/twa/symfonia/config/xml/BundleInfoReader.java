package twa.symfonia.config.xml;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

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
 * 
 * @author mheller
 *
 */
public class BundleInfoReader
{
    /**
     * 
     * @param path
     * @return
     * @throws BundleInfoReaderException
     */
    public BundleModel parseInfo(final String path) throws BundleInfoReaderException {
        final Document xml = openXml(path);
        
        final String id = (String) xPath(xml, "root/name/id()", XPathConstants.STRING);
        final String title = (String) xPath(xml, "root/name/text()", XPathConstants.STRING);
        final String text = (String) xPath(xml, "root/description/text()", XPathConstants.STRING);
        
        final List<String> dependencyList = new ArrayList<>();
        final NodeList dependencies = (NodeList) xPath(xml, "root/dependencies/dependency", XPathConstants.NODESET);
        for (int i=0; i<dependencies.getLength(); i++) {
            dependencyList.add(dependencies.item(i).getTextContent());
        }
        
        final List<String> exclusionList = new ArrayList<>();
        final NodeList exclusions = (NodeList) xPath(xml, "root/exclusions/exclusion", XPathConstants.NODESET);
        for (int i=0; i<exclusions.getLength(); i++) {
            exclusionList.add(exclusions.item(i).getTextContent());
        }
        
        final BundleModel bundle = new BundleModel(id, text, title, dependencyList, exclusionList);
        return bundle;
    }
    
    /**
     * 
     * @param doc
     * @param xPath
     * @return
     * @throws BundleInfoReaderException 
     */
    private Object xPath(final Document doc, final String xPath, final QName type) throws BundleInfoReaderException {
        Object nodes = null;
        try
        {
            final XPathFactory xPathfactory = XPathFactory.newInstance();
            final XPath xpath = xPathfactory.newXPath();
            final XPathExpression expr = xpath.compile(xPath);
            nodes = expr.evaluate(doc, type);
        } catch (final Exception e)
        {
            throw new BundleInfoReaderException(e);
        }
        return nodes;
    }
    
    /**
     * 
     * @param path
     * @return
     * @throws BundleInfoReaderException
     */
    private Document openXml(final String path) throws BundleInfoReaderException {
        Document doc = null;
        try
        {
            final File inputFile = new File(path);
            final DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder;
            dBuilder = dbFactory.newDocumentBuilder();
            doc = dBuilder.parse(inputFile);
            doc.getDocumentElement().normalize();
        } catch (final Exception e)
        {
            throw new BundleInfoReaderException(e);
        }
        return doc;
    }
    
    /**
     * Test
     * @param args
     * @throws BundleInfoReaderException
     */
    public static void main(final String[] args) throws BundleInfoReaderException
    {
        final BundleInfoReader reader = new BundleInfoReader();
        final BundleModel bundle = reader.parseInfo("../../qsb/lua/bundles/bundlebriefingsystem/info.xml");
        
        System.out.println(bundle.getId());
        System.out.println(bundle.getName());
        System.out.println(bundle.getDescription());
        System.out.println(bundle.getDependencies());
        System.out.println(bundle.getExclusions());
    }
}
