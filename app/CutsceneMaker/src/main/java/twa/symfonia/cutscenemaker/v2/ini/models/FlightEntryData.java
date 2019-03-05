package twa.symfonia.cutscenemaker.v2.ini.models;

public class FlightEntryData {
    private String flight;
    private String title;
    private String text;
    private String action;
    private String fadeIn;
    private String fadeOut;

    public FlightEntryData()
    {}

    public FlightEntryData(String flight, String title, String text, String action, String fadeIn, String fadeOut) {
        this.flight = flight;
        this.title = title;
        this.text = text;
        this.action = action;
        this.fadeIn = fadeIn;
        this.fadeOut = fadeOut;
    }

    public String getFlight() {
        return flight;
    }

    public void setFlight(String flight) {
        this.flight = flight;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getFadeIn() {
        return fadeIn;
    }

    public void setFadeIn(String fadeIn) {
        this.fadeIn = fadeIn;
    }

    public String getFadeOut() {
        return fadeOut;
    }

    public void setFadeOut(String fadeOut) {
        this.fadeOut = fadeOut;
    }
}
