package twa.symfonia.cutscenemaker.v2.lua;

import org.apache.commons.io.IOUtils;
import twa.symfonia.cutscenemaker.v2.CutsceneMaker;
import twa.symfonia.cutscenemaker.v2.lua.models.Flight;
import twa.symfonia.cutscenemaker.v2.lua.models.FlightEntry;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.util.Locale;

/**
 * Creates a cutscene as lua string from the flights added to the service. The resulting string is valid lua and can
 * be copied into the mapscript. The code is human readable formated.
 */
public class CutsceneLuaBuilder {
    private String flightTemplate;
    private String cutsceneTemplate;

    /**
     * Constructor
     */
    public CutsceneLuaBuilder() throws CutsceneBuilderException {
        try {
            //Get template files
            InputStream isCutsceneTpl = CutsceneMaker.class.getResourceAsStream("/resources/v2/cutsceneTemplate.txt");
            if (isCutsceneTpl == null) {
                isCutsceneTpl = CutsceneMaker.class.getResourceAsStream("/v2/cutsceneTemplate.txt");
            }

            InputStream isFlightTpl = CutsceneMaker.class.getResourceAsStream("/resources/v2/flightTemplate.txt");
            if (isFlightTpl == null) {
                isFlightTpl = CutsceneMaker.class.getResourceAsStream("/v2/flightTemplate.txt");
            }

            //Read files
            cutsceneTemplate = new String(IOUtils.toByteArray(isCutsceneTpl), "UTF-8");
            flightTemplate   = new String(IOUtils.toByteArray(isFlightTpl), "UTF-8");
        } catch (final IOException e) {
            throw new CutsceneBuilderException(e);
        }
    }

    /**
     * Returns the created cutscene in a function named by the parameter.
     * @param functionName Name of function
     * @param flight Cutscene to work on
     * @return Lua string with cutscene
     */
    public String buildCutsceneString(String functionName, Flight flight) {
        return String.format(
            Locale.ENGLISH,
            cutsceneTemplate,
            functionName,
            flight.isRestoreGameSpeed(),
            flight.isTransperentBars(),
            flight.isHideBorderPins(),
            buildFlightEntries(flight),
            flight.getFinishedFunction()
        );
    }

    /**
     * Returns a string with a single flight table of the flight.
     * @param flight Flight to convert
     * @return Stations of the flight
     */
    private String buildFlightEntries(final Flight flight) {
        String stations = "";
        for (final FlightEntry station : flight.getFlightEntries()) {
            stations += buildSingleFlightEntry(station);
        }
        return stations;
    }

    /**
     * Returns the station as lua table.
     * @param entry Station to convert
     * @return Station table
     */
    private String buildSingleFlightEntry(final FlightEntry entry) {
        // Get station title
        String title = "";
        if (entry.getTitle() != null) {
            final byte[] content = entry.getTitle().getBytes(Charset.forName("UTF-8"));
            title = new String(content);
        }
        // Get station text
        String text = "";
        if (entry.getText() != null) {
            final byte[] content = entry.getText().getBytes(Charset.forName("UTF-8"));
            text = new String(content);
        }

        return String.format(
            Locale.ENGLISH,
            flightTemplate,
            entry.getFlight(),
            entry.getTitle(),
            entry.getText(),
            entry.getAction(),
            entry.getFadeIn(),
            entry.getFadeOut()
        );
    }
}
