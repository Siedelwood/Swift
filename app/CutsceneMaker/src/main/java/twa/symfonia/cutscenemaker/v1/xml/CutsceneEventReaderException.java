package twa.symfonia.cutscenemaker.v1.xml;

public class CutsceneEventReaderException extends Exception {
    public CutsceneEventReaderException() {
    }

    public CutsceneEventReaderException(final String message) {
        super(message);
    }

    public CutsceneEventReaderException(final String message, final Throwable cause) {
        super(message, cause);
    }

    public CutsceneEventReaderException(final Throwable cause) {
        super(cause);
    }

    public CutsceneEventReaderException(final String message, final Throwable cause, final boolean enableSuppression, final boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }
}
