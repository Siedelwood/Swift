package twa.symfonia.config.xml;

/**
 * 
 * @author mheller
 *
 */
@SuppressWarnings("serial")
public class BundleInfoReaderException extends Exception
{
    /**
     * {@inheritDoc}
     */
    public BundleInfoReaderException()
    {
        super();
    }

    /**
     * {@inheritDoc}
     */
    public BundleInfoReaderException(final String message, final Throwable cause, final boolean enableSuppression,
            final boolean writableStackTrace)
    {
        super(message, cause, enableSuppression, writableStackTrace);
    }

    /**
     * {@inheritDoc}
     */
    public BundleInfoReaderException(final String message, final Throwable cause)
    {
        super(message, cause);
    }

    /**
     * {@inheritDoc}
     */
    public BundleInfoReaderException(final String message)
    {
        super(message);
    }

    /**
     * {@inheritDoc}
     */
    public BundleInfoReaderException(final Throwable cause)
    {
        super(cause);
    }
}
