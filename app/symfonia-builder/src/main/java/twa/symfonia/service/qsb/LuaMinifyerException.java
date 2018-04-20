package twa.symfonia.service.qsb;

/**
 * Exception für den Lua Minifyer, falls ein Fehler auftritt.
 * @author totalwarANGEL
 */
@SuppressWarnings("serial")
public class LuaMinifyerException extends Exception
{
    /**
     * {@inheritDoc}
     */
    public LuaMinifyerException()
    {
        super();
    }

    /**
     * {@inheritDoc}
     */
    public LuaMinifyerException(final String message, final Throwable cause, final boolean enableSuppression, final boolean writableStackTrace)
    {
        super(message, cause, enableSuppression, writableStackTrace);
    }

    /**
     * {@inheritDoc}
     */
    public LuaMinifyerException(final String message, final Throwable cause)
    {
        super(message, cause);
    }

    /**
     * {@inheritDoc}
     */
    public LuaMinifyerException(final String message)
    {
        super(message);
    }

    /**
     * {@inheritDoc}
     */
    public LuaMinifyerException(final Throwable cause)
    {
        super(cause);
    }
}
