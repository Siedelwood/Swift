package twa.symfonia.jobs;

/**
 * Exception, falls etwas während eines Jobs schief geht.
 * @author totalwarANGEL
 *
 */
@SuppressWarnings("serial")
public class JobException extends Exception {

    /**
     * {@inheritDoc}
     */
    public JobException() {
        super();
    }

    /**
     * {@inheritDoc}
     */
    public JobException(String arg0, Throwable arg1, boolean arg2, boolean arg3) {
        super(arg0, arg1, arg2, arg3);
    }

    /**
     * {@inheritDoc}
     */
    public JobException(String arg0, Throwable arg1) {
        super(arg0, arg1);
    }

    /**
     * {@inheritDoc}
     */
    public JobException(String arg0) {
        super(arg0);
    }

    /**
     * {@inheritDoc}
     */
    public JobException(Throwable arg0) {
        super(arg0);
    }

}
