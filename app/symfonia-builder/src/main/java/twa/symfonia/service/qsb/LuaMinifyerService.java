package twa.symfonia.service.qsb;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;

import org.apache.commons.io.IOUtils;

/**
 * Minimiert Lua-Code, damit er weniger Speicher verbraucht.
 * 
 * @author totalwarANGEL
 */
public class LuaMinifyerService
{

    /**
     * Minimiert einen Lua-String, sodass unnötige Zeichen entfernt wurden.
     * 
     * @param lua Lua-String
     * @return Minimierten Lua-String
     */
    public String minify(final String lua)
    {
	return removeWhiteSpace(removeLineBreaks(removeComments(lua)));
    }

    /**
     * Minimiert Lua-Code aus dem Stream und gibt minimierten Lua-Code als
     * String zurück.
     * 
     * @param luaStream Stream mit Lua-Code
     * @return Minimierten Lua-String
     * @throws LuaMinifyerException
     */
    public String minify(final InputStream luaStream) throws LuaMinifyerException
    {
	try
	{
	    final StringWriter writer = new StringWriter();
	    IOUtils.copy(luaStream, writer, "UTF-8");
	    final String lua = writer.toString();
	    return minify(lua);
	}
	catch (final IOException e)
	{
	    throw new LuaMinifyerException(e);
	}
    }

    /**
     * Nimmt ein Lua-File und gibt einen String mit dem minimierten Lua-Code
     * zurück.
     * 
     * @param luaFile File Objekt
     * @return Minimierten Lua-String
     * @throws LuaMinifyerException
     */
    public String minify(final File luaFile) throws LuaMinifyerException
    {
	try
	{
	    return minify(new FileInputStream(luaFile));
	}
	catch (final FileNotFoundException e)
	{
	    throw new LuaMinifyerException(e);
	}
    }

    /**
     * Entfernt alle Single-Line Kommentare aus dem Lua-String und gibt den
     * neuen String zurück.
     * 
     * @param lua Lua-String
     * @return Lua-String ohne Kommentare
     */
    private String removeComments(final String lua)
    {
	return lua.replaceAll("--.*\\n", "");
    }

    /**
     * Entfernt alle Linebreaks aus dem Lua-String und gibt den neuen String
     * zurück.
     * 
     * @param lua Lua-String
     * @return Lua-String ohne Line-Breaks
     */
    private String removeLineBreaks(String lua)
    {
	lua = lua.replaceAll(";\\n", ";");
	lua = lua.replaceAll(",\\n", ",");
	lua = lua.replaceAll("\\n", " ");
	return lua;
    }

    /**
     * Entfernt alle unnötigen Whitespaces aus dem Lua-String und gibt den neuen
     * String zurück.
     * 
     * @param lua Lua-String
     * @return Lua-String ohne unnötige Whitespaces
     */
    private String removeWhiteSpace(String lua)
    {
	lua = lua.replaceAll("(\\s\\s+\\.\\.|\\.\\.\\s\\s+)", " .. ");
	lua = lua.replaceAll("(\\(\\s*|\\s*\\(|\\s*\\(\\s*)", "(");
	lua = lua.replaceAll("(\\)\\s*|\\s*\\)|\\s*\\)\\s*)", ")");
	lua = lua.replaceAll("(\\]\\s*|\\s*\\]|\\s*\\]\\s*)", "]");
	lua = lua.replaceAll("(\\[\\s*|\\s*\\[|\\s*\\[\\s*)", "[");
	lua = lua.replaceAll("(\\{\\s*|\\s*\\{|\\s*\\{\\s*)", "{");
	lua = lua.replaceAll("(\\}\\s*|\\s*\\}|\\s*\\}\\s*)", "}");
	lua = lua.replaceAll(";\\s\\s+", "; ");
	lua = lua.replaceAll(",\\s\\s+", ", ");
	lua = lua.replaceAll("\\s\\s+", " ");
	return lua;
    }
}
