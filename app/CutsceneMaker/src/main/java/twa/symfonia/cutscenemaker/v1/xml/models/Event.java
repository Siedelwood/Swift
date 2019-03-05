package twa.symfonia.cutscenemaker.v1.xml.models;

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
