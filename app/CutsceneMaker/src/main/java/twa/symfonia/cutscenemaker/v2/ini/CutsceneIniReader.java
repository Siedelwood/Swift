package twa.symfonia.cutscenemaker.v2.ini;

import org.ini4j.Ini;
import org.ini4j.Profile;
import twa.symfonia.cutscenemaker.v2.ini.models.FlightData;
import twa.symfonia.cutscenemaker.v2.ini.models.FlightEntryData;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class CutsceneIniReader {
    private Ini iniFile;

    /**
     * Constructor
     */
    public CutsceneIniReader()
    {}

    /**
     *
     * @param ini
     * @throws IOException
     */
    public void loadFile(File ini) throws IOException {
        iniFile = new Ini(ini);
    }

    /**
     *
     * @param cutsceneName
     * @return
     */
    public FlightData getFlightData(String cutsceneName) {
        FlightData data = readCutsceneProperties(cutsceneName);
        List<FlightEntryData> flights = readFlightProperties();
        data.setFlightEntries(flights);
        return data;
    }

    /**
     *
     * @param cutsceneName
     * @return
     */
    private FlightData readCutsceneProperties(String cutsceneName) {
        String restoreGameSpeed = iniFile.get("Cutscene", "RestoreGameSpeed");
        if (restoreGameSpeed == null) {
            restoreGameSpeed = "false";
        }

        String hideBorderPins = iniFile.get("Cutscene", "HideBorderPins");
        if (hideBorderPins == null) {
            hideBorderPins = "false";
        }

        String transperentBars = iniFile.get("Cutscene", "TransparentBars");
        if (transperentBars == null) {
            transperentBars = "false";
        }

        return new FlightData(
                cutsceneName,
                Boolean.parseBoolean(restoreGameSpeed),
                Boolean.parseBoolean(hideBorderPins),
                Boolean.parseBoolean(transperentBars)
        );
    }

    /**
     *
     * @return
     */
    private List<FlightEntryData> readFlightProperties() {
        List<FlightEntryData> data = new ArrayList<>();

        for (Profile.Section section: iniFile.values()) {
            String flightName = section.getName();
            if (!flightName.equals("Cutscene")) {

                String title = section.get("Title");
                if (title == null) {
                    title = "";
                }
                String text = section.get("Text");
                if (text == null) {
                    text = "";
                }
                String action = section.get("Action");
                if (action == null) {
                    action = "nil";
                }
                String fadeIn = section.get("FadeIn");
                if (fadeIn == null) {
                    fadeIn = "nil";
                }
                String fadeOut = section.get("FadeOut");
                if (fadeOut == null) {
                    fadeOut = "nil";
                }

                FlightEntryData flight = new FlightEntryData(flightName, title, text, action, fadeIn, fadeOut);
                data.add(flight);
            }
        }
        return data;
    }
}
