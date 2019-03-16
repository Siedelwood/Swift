package twa.symfonia.cutscenemaker.v2.ini.models;

import java.util.ArrayList;
import java.util.List;

public class FlightData {
    private String cutsceneName;
    private boolean restoreGameTime;
    private boolean hideBorderPins;
    private boolean transparentBars;
    private String finishedFunction;
    private boolean fastForward;
    private List<FlightEntryData> flightEntries;

    public FlightData() {
        flightEntries = new ArrayList<>();
    }

    public FlightData(String cutsceneName, boolean restoreGameTime, boolean hideBorderPins, boolean transparentBars, boolean fastForward, String finishedFunction) {
        flightEntries = new ArrayList<>();
        this.cutsceneName = cutsceneName;
        this.restoreGameTime = restoreGameTime;
        this.hideBorderPins = hideBorderPins;
        this.transparentBars = transparentBars;
        this.finishedFunction = finishedFunction;
        this.fastForward = fastForward;
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
