package twa.symfonia.view.window;

/**
 * 
 * 
 * @author angermanager
 *
 */
@SuppressWarnings("serial")
public class WindowException extends Exception {
    /**
     * {@inheritDoc}
     */
    public WindowException() {
    }

    /**
     * {@inheritDoc}
     */
    public WindowException(final String message) {
        super(message);
    }

    /**
     * {@inheritDoc}
     */
    public WindowException(final Throwable cause) {
        super(cause);
    }

    /**
     * {@inheritDoc}
     */
    public WindowException(final String message, final Throwable cause) {
        super(message, cause);
    }

    /**
     * {@inheritDoc}
     */
    public WindowException(final String message, final Throwable cause, final boolean enableSuppression,
            final boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }

}
