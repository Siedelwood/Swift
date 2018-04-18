package twa.symfonia.config.xml;

/**
 * Exception, falls das Mappen von Bundle-Informationen fehlschlägt.
 * 
 * @author totalwarANGEl
 */
@SuppressWarnings("serial")
public class BundleInfoMapperException extends Exception
{

    /**
     * {@inheritDoc}
     */
    public BundleInfoMapperException()
    {
        super();
    }

    /**
     * {@inheritDoc}
     */
    public BundleInfoMapperException(final String message, final Throwable cause, final boolean enableSuppression,
            final boolean writableStackTrace)
    {
        super(message, cause, enableSuppression, writableStackTrace);
    }

    /**
     * {@inheritDoc}
     */
    public BundleInfoMapperException(final String message, final Throwable cause)
    {
        super(message, cause);
    }

    /**
     * {@inheritDoc}
     */
    public BundleInfoMapperException(final String message)
    {
        super(message);
    }

    /**
     * {@inheritDoc}
     */
    public BundleInfoMapperException(final Throwable cause)
    {
        super(cause);
    }
}
