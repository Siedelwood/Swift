package twa.symfonia.cutscenemaker.v2.ini.models;

import java.util.ArrayList;
import java.util.List;

public class FlightData {
    private String startingFunction;
    private String cutsceneName;
    private Boolean restoreGameTime;
    private Boolean hideBorderPins;
    private Boolean bigBars;
    private Double opacity;
    private String finishedFunction;
    private Boolean fastForward;
    private List<FlightEntryData> flightEntries;

    public FlightData() {
        flightEntries = new ArrayList<>();
    }

    public FlightData(String cutsceneName, Boolean restoreGameTime, Boolean hideBorderPins, Boolean bigBars, Double opacity, Boolean fastForward,
                      String startingFunction, String finishedFunction) {
        flightEntries = new ArrayList<>();
        this.cutsceneName = cutsceneName;
        this.restoreGameTime = restoreGameTime;
        this.hideBorderPins = hideBorderPins;
        this.bigBars = bigBars;
        this.opacity = opacity;
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
