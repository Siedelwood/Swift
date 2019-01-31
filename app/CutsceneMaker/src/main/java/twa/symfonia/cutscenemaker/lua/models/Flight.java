package twa.symfonia.cutscenemaker.lua.models;

import java.util.ArrayList;
import java.util.List;

public class Flight {
    private List<FlightStation> pageStations;
    private double duration;

    public Flight() {
        pageStations = new ArrayList<>();
    }

    public void addStation(FlightStation station) {
        pageStations.add(station);
    }

    public List<FlightStation> getPageStations() {
        return pageStations;
    }

    public double getDuration() {
        return duration;
    }

    public void setDuration(double duration) {
        this.duration = duration;
    }
}
