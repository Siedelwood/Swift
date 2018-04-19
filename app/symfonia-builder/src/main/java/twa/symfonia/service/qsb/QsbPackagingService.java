package twa.symfonia.service.qsb;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

import org.apache.commons.io.FileUtils;

/**
 * Packt die QSB inklusive der Zusatzoptionen in den angegebenen Pfad
 * 
 * @author totalwarANGEL
 *
 */
public class QsbPackagingService
{
    /**
     * 
     */
    private boolean copyDoc;

    /**
     * 
     */
    private boolean copyBaseScripts;

    /**
     * 
     */
    private boolean copyExamples;

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
    LuaMinifyerService minifyer;

    /**
     * 
     * @param basePath
     */
    public QsbPackagingService(final String basePath, final LuaMinifyerService minifyer)
    {
        this.basePath = basePath;
        this.minifyer = minifyer;
    }

    /**
     * 
     * @param files
     * @param dest
     * @param copyDoc
     * @param copyBaseScripts
     * @param copyExamples
     * @param minifyQsb
     * @throws QsbPackagingException
     */
    public void pack(
        final List<String> files,
        final String dest,
        final boolean copyDoc,
        final boolean copyBaseScripts,
        final boolean copyExamples,
        final boolean minifyQsb) throws QsbPackagingException
    {
        this.copyDoc = copyDoc;
        this.copyBaseScripts = copyBaseScripts;
        this.copyExamples = copyExamples;
        this.minifyQsb = minifyQsb;

        save(files, dest);
        saveDocumentation("foo", "bar");
    }

    /**
     * 
     * @param source
     * @param dest
     * @throws QsbPackagingException
     */
    public void saveDocumentation(final String source, final String dest) throws QsbPackagingException
    {
        if (copyDoc)
        {
            try
            {
                FileUtils.copyDirectory(new File(source), new File(dest));
            } catch (final IOException e)
            {
                throw new QsbPackagingException("Unable to copy documentation!", e);
            }
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
            String content = "";
            for (final String s : files)
            {
                content += load(s);
            }
            final BufferedWriter writer = new BufferedWriter(new FileWriter(dest + "/qsb.lua"));
            writer.write(content);
        } catch (final Exception e)
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
    private String load(final String file) throws QsbPackagingException
    {
        try
        {
            final byte[] encoded = Files.readAllBytes(Paths.get(basePath + file));
            String content = new String(encoded, "UTF-8");
            if (minifyQsb)
            {
                content = minifyer.minify(content) + " ";
            }
            return content;
        } catch (final Exception e)
        {
            throw new QsbPackagingException(e);
        }
    }
}
