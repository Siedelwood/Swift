package twa.symfonia.cutscenemaker.v2.lua.models;

import twa.symfonia.cutscenemaker.v1.lua.models.Position;

public class FlightEntry {
    private String flight;
    private String title;
    private String text;
    private String fadeIn;
    private String fadeOut;
    private String action;

    public FlightEntry(String flight, String title, String text, String fadeIn, String fadeOut, String action) {
        this.flight = flight;
        this.title = title;
        this.text = text;
        this.fadeIn = fadeIn;
        this.fadeOut = fadeOut;
        this.action = action;
    }

    public FlightEntry() {
    }

    @Override
    public String toString() {

        return String.format(
                "FlightEntry[\"%s\", \"%s\", %s, %s, %s, %s]",
                this.flight,
                this.title,
                this.text,
                this.action,
                this.fadeIn,
                this.fadeOut
        );
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

    public String getFadeIn() {
        String fadeIn = "nil";
        if (this.fadeIn != null && !this.fadeIn.equals("")) {
            fadeIn = this.fadeIn;
        }
        return fadeIn;
    }

    public void setFadeIn(String fadeIn) {
        this.fadeIn = fadeIn;
    }

    public String getFadeOut() {
        String fadeOut = "nil";
        if (this.fadeOut != null && !this.fadeOut.equals("")) {
            fadeOut = this.fadeOut;
        }
        return fadeOut;
    }

    public void setFadeOut(String fadeOut) {
        this.fadeOut = fadeOut;
    }

    public String getAction() {
        String action = "nil";
        if (this.action != null && !this.action.equals("")) {
            action = this.action;
        }
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }
}
