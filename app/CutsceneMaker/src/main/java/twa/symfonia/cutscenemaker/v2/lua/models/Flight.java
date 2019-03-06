package twa.symfonia.cutscenemaker.v2.lua.models;

import java.util.ArrayList;
import java.util.List;

public class Flight {
    private List<FlightEntry> flightEntries;
    private boolean restoreGameSpeed;
    private boolean transperentBars;
    private boolean hideBorderPins;
    private String finishedFunction;

    public Flight(List<FlightEntry> flightEntries, boolean restoreGameSpeed, boolean transperentBars, boolean hideBorderPins, String finishedFunction) {
        this.flightEntries = flightEntries;
        this.restoreGameSpeed = restoreGameSpeed;
        this.transperentBars = transperentBars;
        this.hideBorderPins = hideBorderPins;
        this.finishedFunction = finishedFunction;
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

    public boolean isTransperentBars() {
        return transperentBars;
    }

    public void setTransperentBars(boolean transperentBars) {
        this.transperentBars = transperentBars;
    }

    public boolean isHideBorderPins() {
        return hideBorderPins;
    }

    public void setHideBorderPins(boolean hideBorderPins) {
        this.hideBorderPins = hideBorderPins;
    }
}
