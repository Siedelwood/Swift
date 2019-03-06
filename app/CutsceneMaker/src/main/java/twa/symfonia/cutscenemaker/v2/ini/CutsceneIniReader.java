package twa.symfonia.cutscenemaker.v2.ini;

import org.ini4j.Ini;
import twa.symfonia.cutscenemaker.v2.ini.models.FlightData;
import twa.symfonia.cutscenemaker.v2.ini.models.FlightEntryData;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

/**
 * Simple reader for cutscene properties stored in INI files.
 */
public class CutsceneIniReader {
    private Ini iniFile;

    /**
     * Constructor
     */
    public CutsceneIniReader()
    {}

    /**
     * Loads the INI file to the reader and prepares it.
     * @param ini INI file to load
     * @throws IOException
     */
    public void loadFile(File ini) throws IOException {
        iniFile = new Ini(ini);
    }

    /**
     * Returns the flight data of the cutscene.
     * @param cutsceneName Name of cutscene
     * @return Flight data
     */
    public FlightData getFlightData(String cutsceneName) throws UnsupportedEncodingException {
        FlightData data = readCutsceneProperties(cutsceneName);
        List<FlightEntryData> flights = readFlightProperties();
        data.setFlightEntries(flights);
        return data;
    }

    /**
     * Reads the properties of the cutscene and returns flight data with all flight entries data.
     * @param cutsceneName Name of cutscene
     * @return Cutscene data
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

        String finishedFunction = iniFile.get("Cutscene", "FinishedFunction");

        return new FlightData(
                cutsceneName,
                Boolean.parseBoolean(restoreGameSpeed),
                Boolean.parseBoolean(hideBorderPins),
                Boolean.parseBoolean(transperentBars),
                (finishedFunction == null) ? "nil" : finishedFunction
        );
    }

    /**
     * Reads the properties of the cutscene and returns flight entry data.
     * @return List of flight entry data
     */
    private List<FlightEntryData> readFlightProperties() throws UnsupportedEncodingException {
        List<FlightEntryData> data = new ArrayList<>();

        for (String sectionName: iniFile.keySet()) {
            if (!sectionName.equals("Cutscene")) {
                String title = iniFile.get(sectionName, "Title");
                if (title == null) {
                    title = "";
                }
                title = new String(title.getBytes("UTF-8"));

                String text = iniFile.get(sectionName, "Text");
                if (text == null) {
                    text = "";
                }
                text = new String(text.getBytes("UTF-8"));

                String action = iniFile.get(sectionName, "Action");
                if (action == null) {
                    action = "nil";
                }
                String fadeIn = iniFile.get(sectionName, "FadeIn");
                if (fadeIn == null) {
                    fadeIn = "nil";
                }
                String fadeOut = iniFile.get(sectionName, "FadeOut");
                if (fadeOut == null) {
                    fadeOut = "nil";
                }
                FlightEntryData flight = new FlightEntryData(sectionName, title, text, action, fadeIn, fadeOut);
                System.out.println(flight.toString());
                data.add(flight);
            }
        }
        return data;
    }
}
