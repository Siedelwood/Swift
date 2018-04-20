package twa.symfonia.controller;

/**
 * Exception, falls in der Applikation ein Fehler auftritt. (Nach außen
 * sichtbare Exception)
 * 
 * @author angermanager
 */
@SuppressWarnings("serial")
public class ApplicationException extends Exception
{
    /**
     * {@inheritDoc}
     */
    public ApplicationException()
    {
    }

    /**
     * {@inheritDoc}
     */
    public ApplicationException(final String message)
    {
        super(message);
    }

    /**
     * {@inheritDoc}
     */
    public ApplicationException(final Throwable cause)
    {
        super(cause);
    }

    /**
     * {@inheritDoc}
     */
    public ApplicationException(final String message, final Throwable cause)
    {
        super(message, cause);
    }

    /**
     * {@inheritDoc}
     */
    public ApplicationException(final String message, final Throwable cause, final boolean enableSuppression,
            final boolean writableStackTrace)
    {
        super(message, cause, enableSuppression, writableStackTrace);
    }

}
