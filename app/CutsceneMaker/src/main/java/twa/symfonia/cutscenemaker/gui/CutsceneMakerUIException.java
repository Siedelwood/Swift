package twa.symfonia.cutscenemaker.gui;


/**
 * @author angermanager
 *
 */
public class CutsceneMakerUIException extends Exception
{
    public CutsceneMakerUIException()
    {
        super();
    }

    public CutsceneMakerUIException(final String arg0, final Throwable arg1, final boolean arg2, final boolean arg3)
    {
        super(arg0, arg1, arg2, arg3);
    }

    public CutsceneMakerUIException(final String message, final Throwable cause)
    {
        super(message, cause);
    }

    public CutsceneMakerUIException(final String message)
    {
        super(message);
    }

    public CutsceneMakerUIException(final Throwable cause)
    {
        super(cause);
    }

}
