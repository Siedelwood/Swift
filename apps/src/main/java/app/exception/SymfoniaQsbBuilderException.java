package app.exception;

/**
 * 
 * 
 * @author angermanager
 *
 */
public class SymfoniaQsbBuilderException extends Exception
{
    /**
     * {@inheritDoc}
     */
    public SymfoniaQsbBuilderException()
    {
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaQsbBuilderException(final String message)
    {
        super(message);
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaQsbBuilderException(final Throwable cause)
    {
        super(cause);
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaQsbBuilderException(final String message, final Throwable cause)
    {
        super(message, cause);
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaQsbBuilderException(final String message, final Throwable cause, final boolean enableSuppression,
            final boolean writableStackTrace)
    {
        super(message, cause, enableSuppression, writableStackTrace);
    }

}
