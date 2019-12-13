package twa.symfonia.cutscenemaker.v2.lua.models;

import java.util.ArrayList;
import java.util.List;

public class Flight {
    private List<FlightEntry> flightEntries;
    private Boolean restoreGameSpeed;
    private Boolean bigBars;
    private Boolean hideBorderPins;
    private Boolean fastForward;
    private Double opacity;
    private String finishedFunction;
    private String startingFunction;

    public Flight(List<FlightEntry> flightEntries, Boolean restoreGameSpeed, Boolean hideBorderPins, Boolean bigBars, Double opacity, Boolean fastForward,
                  String startingFunction, String finishedFunction) {
        this.flightEntries = flightEntries;
        this.restoreGameSpeed = restoreGameSpeed;
        this.bigBars = bigBars;
        this.opacity = opacity;
        this.hideBorderPins = hideBorderPins;
        this.startingFunction = startingFunction;
        this.finishedFunction = finishedFunction;
        this.fastForward = fastForward;
    }

    public String getStartingFunction() {
        return startingFunction;
    }

    public void setStartingFunction(String startingFunction) {
        this.startingFunction = startingFunction;
    }

    public boolean isFastForward() {
        return fastForward;
    }

    public void setFastForward(boolean fastForward) {
        this.fastForward = fastForward;
    }

    public String getFinishedFunction() {
        return finishedFunction;
    }

    public void setFinishedFunction(String finishedFunction) {
        this.finishedFunction = finishedFunction;
    }

    public Flight() {
        flightEntries = new ArrayList<>();
    }

    public void addStation(FlightEntry station) {
        flightEntries.add(station);
    }

    public List<FlightEntry> getFlightEntries() {
        return flightEntries;
    }

    public void setFlightEntries(List<FlightEntry> flightEntries) {
        this.flightEntries = flightEntries;
    }

    public boolean isRestoreGameSpeed() {
        return restoreGameSpeed;
    }

    public void setRestoreGameSpeed(boolean restoreGameSpeed) {
        this.restoreGameSpeed = restoreGameSpeed;
    }

    public boolean isHideBorderPins() {
        return hideBorderPins;
    }

    public void setHideBorderPins(boolean hideBorderPins) {
        this.hideBorderPins = hideBorderPins;
    }

    public Boolean isBigBars() {
        return bigBars;
    }

    public void setBigBars(Boolean bigBars) {
        this.bigBars = bigBars;
    }

    public Double getOpacity() {
        return opacity;
    }

    public void setOpacity(Double opacity) {
        this.opacity = opacity;
    }
}
