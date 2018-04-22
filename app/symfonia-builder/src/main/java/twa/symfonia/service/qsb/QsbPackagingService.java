package twa.symfonia.service.qsb;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.LineIterator;

import twa.symfonia.model.LoadOrderModel;

/**
 * Packt die QSB inklusive der Zusatzoptionen in den angegebenen Pfad
 * 
 * @author totalwarANGEL
 *
 */
public class QsbPackagingService implements QsbPackagingInterface
{

    /**
     * Flag: Minifier nutzen
     */
    private boolean minifyQsb;

    /**
     * Base Path Lua
     */
    private final String basePath;

    /**
     * Base Path Dokumentation
     */
    private final String docPath;

    /**
     * Lua-Minifier
     */
    LuaMinifyerService minifier;

    /**
     * Constructor
     * 
     * @param basePath Base Path Lua
     * @param docPath Base Path Dokumentation
     * @param minifyer Lua-Minifier
     */
    public QsbPackagingService(final String basePath, final String docPath, final LuaMinifyerService minifyer)
    {
	this.basePath = basePath;
	this.docPath = docPath;
	this.minifier = minifyer;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void pack(final LoadOrderModel loadOrder, final String dest, final boolean copyDoc,
	    final boolean copyBaseScripts, final boolean copyExamples, final boolean minifyQsb)
	    throws QsbPackagingException
    {
	this.minifyQsb = minifyQsb;

	save(loadOrder, dest);

	if (copyBaseScripts)
	{
	    saveBasicScripts(dest);
	}

	if (copyExamples)
	{
	    saveExamples(dest);
	}

	if (copyDoc)
	{
	    saveDocumentation(dest);
	}
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void saveExamples(final String path) throws QsbPackagingException
    {
	try
	{
	    final File folder = new File(path + "/Beispiele");
	    folder.mkdirs();
	    FileUtils.copyDirectory(new File(basePath + "/../example"), folder);
	}
	catch (final Exception e)
	{
	    throw new QsbPackagingException("Unable to save example files!", e);
	}
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void saveBasicScripts(final String path) throws QsbPackagingException
    {
	try
	{
	    final File folder = new File(path + "/Basisskripte");
	    folder.mkdirs();
	    FileUtils.copyDirectory(new File(basePath + "/../default"), folder);
	}
	catch (final Exception e)
	{
	    throw new QsbPackagingException("Unable to save script files!", e);
	}
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void saveDocumentation(final String dest) throws QsbPackagingException
    {
	try
	{
	    final File folder = new File(dest + "/Dokumentation");
	    folder.mkdirs();
	    FileUtils.copyDirectory(new File(docPath), folder);
	}
	catch (final Exception e)
	{
	    throw new QsbPackagingException("Unable to copy documentation!", e);
	}
    }

    /**
     * Speichert die QSB in das Verzeichnis. Die QSB beinhaltet alle Quellen aus
     * der Quellenliste.
     * 
     * @param loadOrder Liste der Quelldateien
     * @param dest Zielverzeichnis
     * @throws QsbPackagingException
     */
    private void save(final LoadOrderModel loadOrder, final String dest) throws QsbPackagingException
    {
	try
	{
	    final StringBuffer stringBuffer = new StringBuffer();

	    String s;
	    while ((s = loadOrder.next()) != null)
	    {
		stringBuffer.append(load(s));
	    }

	    final File folder = new File(dest);
	    folder.mkdirs();

	    final BufferedWriter writer = new BufferedWriter(new FileWriter(dest + "/qsb.lua"));
	    if (minifyQsb)
	    {
		writer.write(minifier.minify(stringBuffer.toString()));
	    }
	    else
	    {
		writer.write(stringBuffer.toString());
	    }
	    writer.flush();
	    writer.close();
	}
	catch (final Exception e)
	{
	    throw new QsbPackagingException(e);
	}
    }

    /**
     * Läd eine Lua-Quelldatei und fügt sie dem Buffer hinzu. Line Separators
     * der Quelldateien werden ignoriert. Es wird \n als Line Separator gesetzt.
     * 
     * @param file Datei zum Laden
     * @return Buffer
     * @throws QsbPackagingException
     */
    private StringBuffer load(final String file) throws QsbPackagingException
    {
	try
	{
	    final StringBuffer stringBuffer = new StringBuffer();
	    final LineIterator it = FileUtils.lineIterator(new File(basePath + file), "UTF-8");
	    while (it.hasNext())
	    {
		final String line = it.nextLine() + "\n";
		stringBuffer.append(line);
	    }
	    stringBuffer.append(" ");
	    return stringBuffer;
	}
	catch (final Exception e)
	{
	    throw new QsbPackagingException(e);
	}
    }
}
