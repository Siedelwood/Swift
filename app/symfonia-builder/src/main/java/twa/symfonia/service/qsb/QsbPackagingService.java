package twa.symfonia.service.qsb;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.LineIterator;

/**
 * Packt die QSB inklusive der Zusatzoptionen in den angegebenen Pfad
 * 
 * @author totalwarANGEL
 *
 */
public class QsbPackagingService implements QsbPackagingInterface
{

    /**
     * 
     */
    private boolean minifyQsb;

    /**
     * 
     */
    private final String basePath;

    /**
     * 
     */
    private final String docPath;

    /**
     * 
     */
    LuaMinifyerService minifyer;

    /**
     * 
     * @param basePath
     * @param docPath
     * @param minifyer
     */
    public QsbPackagingService(final String basePath, final String docPath, final LuaMinifyerService minifyer)
    {
	this.basePath = basePath;
	this.docPath = docPath;
	this.minifyer = minifyer;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void pack(final List<String> files, final String dest, final boolean copyDoc, final boolean copyBaseScripts,
	    final boolean copyExamples, final boolean minifyQsb) throws QsbPackagingException
    {
	this.minifyQsb = minifyQsb;

	save(files, dest);

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
	System.out.println("Not implemented");
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void saveBasicScripts(final String path) throws QsbPackagingException
    {
	try
	{
	    final File sourceGlobal = new File(basePath + "/default/globalscript.lua");
	    System.out.println("Save global script as: " + path + "/globalscript.lua");
	    final File destGlobal = new File(path + "/globalscript.lua");
	    FileUtils.copyFile(sourceGlobal, destGlobal);

	    final File sourceLocal = new File(basePath + "/default/localscript.lua");
	    System.out.println("Save local script as: " + path + "/localscript.lua");
	    final File destLocal = new File(path + "/localscript.lua");
	    FileUtils.copyFile(sourceLocal, destLocal);
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
	    final File folder = new File(dest);
	    folder.mkdirs();
	    FileUtils.copyDirectory(new File(docPath), folder);
	}
	catch (final Exception e)
	{
	    throw new QsbPackagingException("Unable to copy documentation!", e);
	}
    }

    /**
     * 
     * @param files
     * @param dest
     * @throws QsbPackagingException
     */
    private void save(final List<String> files, final String dest) throws QsbPackagingException
    {
	try
	{
	    final StringBuffer stringBuffer = new StringBuffer();
	    for (final String s : files)
	    {
		stringBuffer.append(load(s));
	    }

	    final File folder = new File(dest);
	    folder.mkdirs();

	    final BufferedWriter writer = new BufferedWriter(new FileWriter(dest + "/qsb.lua"));
	    if (minifyQsb)
	    {
		writer.write(minifyer.minify(stringBuffer.toString()));
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
     * 
     * @param file
     * @return
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
		// if (minifyQsb)
		// {
		// line = minifyer.minify(line);
		// }
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
