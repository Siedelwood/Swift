package twa.symfonia.jobs;

/**
 * Interface für Jobs, die im Hintergrund ausgeführt werden.
 * 
 * @author angermanager
 *
 */
public interface JobInterface
{

    /**
     * Führt den Job aus.
     */
    public void run();
}
