/**
 * 
 */
package eu.jlmb.CutsceneAssistent;

/**
 * EventType enum
 * @author Jean Baumgarten
 */
public enum EventType {
	
	/** Event types */
	CAMERA_EVENT("CameraEvent"), SCRIPT_EVENT("ScriptEvent"), TEXT_EVENT("TextEvent"), FADER_EVENT("FaderEvent");
	
	private final String text;
	
	/**
	 * Name initializer
	 * @param text of the type
	 */
	EventType(final String text) {
        this.text = text;
    }
	
	@Override
    public String toString() {
        return this.text;
    }
	
}
