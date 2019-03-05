package twa.symfonia.cutscenemaker.v2.lua;

public class CutsceneBuilderException extends Exception {
    public CutsceneBuilderException() {
    }

    public CutsceneBuilderException(final String message) {
        super(message);
    }

    public CutsceneBuilderException(final String message, final Throwable cause) {
        super(message, cause);
    }

    public CutsceneBuilderException(final Throwable cause) {
        super(cause);
    }

    public CutsceneBuilderException(final String message, final Throwable cause, final boolean enableSuppression, final boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }
}
