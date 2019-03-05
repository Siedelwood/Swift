package twa.symfonia.cutscenemaker.v2.ini.models;

import java.util.ArrayList;
import java.util.List;

public class FlightData {
    private String cutsceneName;
    private boolean restoreGameTime;
    private boolean hideBorderPins;
    private boolean transparentBars;
    private List<FlightEntryData> flightEntries;

    public FlightData() {
        flightEntries = new ArrayList<>();
    }

    public FlightData(String cutsceneName, boolean restoreGameTime, boolean hideBorderPins, boolean transparentBars) {
        flightEntries = new ArrayList<>();
        this.cutsceneName = cutsceneName;
        this.restoreGameTime = restoreGameTime;
        this.hideBorderPins = hideBorderPins;
        this.transparentBars = transparentBars;
    }

    public List<FlightEntryData> getFlightEntries() {
        return flightEntries;
    }

    public void setFlightEntries(List<FlightEntryData> flightEntries) {
        this.flightEntries = flightEntries;
    }

    public String getCutsceneName() {
        return cutsceneName;
    }

    public void setCutsceneName(String cutsceneName) {
        this.cutsceneName = cutsceneName;
    }

    public boolean isRestoreGameTime() {
        return restoreGameTime;
    }

    public void setRestoreGameTime(boolean restoreGameTime) {
        this.restoreGameTime = restoreGameTime;
    }

    public boolean isHideBorderPins() {
        return hideBorderPins;
    }

    public void setHideBorderPins(boolean hideBorderPins) {
        this.hideBorderPins = hideBorderPins;
    }

    public boolean isTransparentBars() {
        return transparentBars;
    }

    public void setTransparentBars(boolean transparentBars) {
        this.transparentBars = transparentBars;
    }
}
