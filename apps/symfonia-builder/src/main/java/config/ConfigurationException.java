package config;

/**
 * 
 * 
 * @author angermanager
 *
 */
public class ConfigurationException extends Exception
{
    /**
     * {@inheritDoc}
     */
    public ConfigurationException()
    {
    }

    /**
     * {@inheritDoc}
     */
    public ConfigurationException(final String message)
    {
        super(message);
    }

    /**
     * {@inheritDoc}
     */
    public ConfigurationException(final Throwable cause)
    {
        super(cause);
    }

    /**
     * {@inheritDoc}
     */
    public ConfigurationException(final String message, final Throwable cause)
    {
        super(message, cause);
    }

    /**
     * {@inheritDoc}
     */
    public ConfigurationException(final String message, final Throwable cause, final boolean enableSuppression,
            final boolean writableStackTrace)
    {
        super(message, cause, enableSuppression, writableStackTrace);
    }
}
