package twa.symfonia.cutscenemaker.v2.xml.models;

import org.simpleframework.xml.Attribute;
import org.simpleframework.xml.Element;
import org.simpleframework.xml.Root;

@Root
public class Event {
    @Attribute
    private String classname;

    @Element
    private int EventType;

    @Element
    private int Turn;

    @Element
    private String Name;

    @Element
    private double PositionX;

    @Element
    private double PositionY;

    @Element
    private double PositionZ;

    @Element
    private double LookAtX;

    @Element
    private double LookAtY;

    @Element
    private double LookAtZ;

    @Element(required = false)
    private String Transition;

    @Element(required = false)
    private double FOV;

    @Element(required = false)
    private double FarClipPlane;

    @Element(required = false)
    private boolean LookFarAway;

    @Element(required = false)
    private String Script;

    @Element(required = false)
    private String Text;

    @Element(required = false)
    private String TextRaw;

    public Event()
    {}

    /**
     * Creates an script event for a cutscene.
     * @param turn Moment in time
     * @param script Script to call
     */
    public Event(final int turn, final String script) {
        Turn = turn;
        Script = script;
        classname = "ECam::CCutsceneEventScript";
        Name = "SCRIPT_EVENT";
        EventType = 2;
        PositionX = 0.0;
        PositionY = 0.0;
        PositionZ = 0.0;
        LookAtX = 0.0;
        LookAtY = 0.0;
        LookAtZ = 0.0;
    }

    /**
     * Creates an text event for a cutscene.
     * @param turn Moment in time
     * @param text 
     * @param textRaw
     */
    public Event(final int turn, final String text, final String textRaw) {
        Turn = turn;
        Text = text;
        TextRaw = textRaw;
        classname = "ECam::CCutsceneEventText";
        Name = "TEXT_EVENT";
        EventType = 2;
        PositionX = 0.0;
        PositionY = 0.0;
        PositionZ = 0.0;
        LookAtX = 0.0;
        LookAtY = 0.0;
        LookAtZ = 0.0;
    }

    /**
     * Creates an camera event for a cutscene.
     * @param turn Moment in time
     * @param text 
     * @param textRaw
     */
    public Event(
        final int turn, final int fov, final double pX, final double pY, final double pZ, final double lX, 
        final double lY, final double lZ, final double farClipPlane
    ) {
        Turn = turn;
        classname = "ECam::CCutsceneEventCamera";
        Name = "TEXT_EVENT";
        Transition = "Camera New Fly";
        LookFarAway = true;
        FarClipPlane = farClipPlane;
        FOV = fov;
        EventType = 1;
        PositionX = pX;
        PositionY = pY;
        PositionZ = pZ;
        LookAtX = lX;
        LookAtY = lY;
        LookAtZ = lZ;
    }

    public String getClassname() {
        return classname;
    }

    public int getEventType() {
        return EventType;
    }

    public int getTurn() {
        return Turn;
    }

    public String getName() {
        return Name;
    }

    public double getPositionX() {
        return PositionX;
    }

    public double getPositionY() {
        return PositionY;
    }

    public double getPositionZ() {
        return PositionZ;
    }

    public double getLookAtX() {
        return LookAtX;
    }

    public double getLookAtY() {
        return LookAtY;
    }

    public double getLookAtZ() {
        return LookAtZ;
    }

    public String getTransition() {
        return Transition;
    }

    public double getFOV() {
        return FOV;
    }

    public double getFarClipPlane() {
        return FarClipPlane;
    }

    public boolean isLookFarAway() {
        return LookFarAway;
    }

    public String getScript() {
        return Script;
    }

    public String getText() {
        return Text;
    }

    public String getTextRaw() {
        return TextRaw;
    }
}
