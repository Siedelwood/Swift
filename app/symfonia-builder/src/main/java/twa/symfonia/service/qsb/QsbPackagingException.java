package twa.symfonia.service.qsb;

/**
 * Exception für den QSB-Packer, falls ein Fehler auftritt.
 * @author totalwarANGEL
 */
@SuppressWarnings("serial")
public class QsbPackagingException extends Exception
{
    /**
     * {@inheritDoc}
     */
    public QsbPackagingException()
    {
        super();
    }

    /**
     * {@inheritDoc}
     */
    public QsbPackagingException(final String message, final Throwable cause, final boolean enableSuppression, final boolean writableStackTrace)
    {
        super(message, cause, enableSuppression, writableStackTrace);
    }

    /**
     * {@inheritDoc}
     */
    public QsbPackagingException(final String message, final Throwable cause)
    {
        super(message, cause);
    }

    /**
     * {@inheritDoc}
     */
    public QsbPackagingException(final String message)
    {
        super(message);
    }

    /**
     * {@inheritDoc}
     */
    public QsbPackagingException(final Throwable cause)
    {
        super(cause);
    }
}
