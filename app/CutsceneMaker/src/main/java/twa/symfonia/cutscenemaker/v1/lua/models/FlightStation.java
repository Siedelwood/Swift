package twa.symfonia.cutscenemaker.v1.lua.models;

public class FlightStation {
    private Position camPosition;
    private Position camTarget;
    private double fieldOfView;
    private String flightTitle;
    private String flightText;
    private String flightAction;

    public FlightStation()
    {}

    public FlightStation(Position camPosition, Position camTarget, double fogOfWar, String flightTitle, String flightText, String flightAction) {
        this.camPosition = camPosition;
        this.camTarget = camTarget;
        this.fieldOfView = fogOfWar;
        this.flightTitle = flightTitle;
        this.flightText = flightText;
        this.flightAction = flightAction;
    }

    public void setCamPosition(Position camPosition) {
        this.camPosition = camPosition;
    }

    public void setCamTarget(Position camTarget) {
        this.camTarget = camTarget;
    }

    public void setFieldOfView(double fogOfWar) {
        this.fieldOfView = fogOfWar;
    }

    public void setFlightTitle(String flightTitle) {
        this.flightTitle = flightTitle;
    }

    public void setFlightText(String flightText) {
        this.flightText = flightText;
    }

    public void setFlightAction(String flightAction) {
        this.flightAction = flightAction;
    }

    public Position getCamPosition() {
        return camPosition;
    }

    public Position getCamTarget() {
        return camTarget;
    }

    public double getFieldOfView() {
        return fieldOfView;
    }

    public String getFlightTitle() {
        return flightTitle;
    }

    public String getFlightText() {
        return flightText;
    }

    public String getFlightAction() {
        return flightAction;
    }
}
