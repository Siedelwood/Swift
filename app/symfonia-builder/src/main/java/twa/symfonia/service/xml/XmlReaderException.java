package twa.symfonia.service.xml;

/**
 * Exception, falls beim Ermitteln von String Tables Fehler auftreten.
 * 
 * @author totalwarANGEL
 *
 */
@SuppressWarnings("serial")
public class XmlReaderException extends Exception
{
    /**
     * {@inheritDoc}
     */
    public XmlReaderException()
    {
        super();
    }

    /**
     * {@inheritDoc}
     */
    public XmlReaderException(final String message, final Throwable cause, final boolean enableSuppression,
            final boolean writableStackTrace)
    {
        super(message, cause, enableSuppression, writableStackTrace);
    }

    /**
     * {@inheritDoc}
     */
    public XmlReaderException(final String message, final Throwable cause)
    {
        super(message, cause);
    }

    /**
     * {@inheritDoc}
     */
    public XmlReaderException(final String message)
    {
        super(message);
    }

    /**
     * {@inheritDoc}
     */
    public XmlReaderException(final Throwable cause)
    {
        super(cause);
    }
}
