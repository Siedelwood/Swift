package twa.symfonia.cutscenemaker.v1.lua;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import org.apache.commons.io.IOUtils;

import twa.symfonia.cutscenemaker.v1.CutsceneMakerVersion1;
import twa.symfonia.cutscenemaker.v1.lua.models.Flight;
import twa.symfonia.cutscenemaker.v1.lua.models.FlightStation;

/**
 * Creates a cutscene as lua string from the flights added to the service. The resulting string is valid lua and can
 * be copied into the mapscript. The code is human readable formated.
 */
public class CutsceneLuaBuilder {
    private String stationTemplate;
    private String briefingTemplate;
    private String pageTemplate;
    private List<Flight> flights;

    /**
     * Constructor
     */
    public CutsceneLuaBuilder() throws CutsceneBuilderException {
        try {
            //Get template files
            final InputStream isBriefingTpl  = CutsceneMakerVersion1.class.getResourceAsStream("/resources/v1/briefingTemplate.txt");
            final InputStream isCameraTpl    = CutsceneMakerVersion1.class.getResourceAsStream("/resources/v1/cameraTemplate.txt");
            final InputStream isFlightTpl    = CutsceneMakerVersion1.class.getResourceAsStream("/resources/v1/flightTemplate.txt");
            //Read files
            briefingTemplate = new String(IOUtils.toByteArray(isBriefingTpl), "UTF-8");
            stationTemplate  = new String(IOUtils.toByteArray(isCameraTpl), "UTF-8");
            pageTemplate     = new String(IOUtils.toByteArray(isFlightTpl), "UTF-8");
            flights          = new ArrayList<>();
        } catch (final IOException e) {
            throw new CutsceneBuilderException(e);
        }
    }

    /**
     * Adds a flight to the cutscene.
     * @param flight Flight to add to the cutscene
     */
    public void addFlight(final Flight flight) {
        flights.add(flight);
    }

    /**
     * Cleas the flight list.
     */
    public void clearFlight() {
        flights.clear();
    }

    /**
     * Returns the created cutscene in a function named by the parameter.
     * @param functionName Name of the function
     * @return String with cutscene
     */
    public String buildCutsceneString(final String functionName) {
        if (flights.size() == 0) {
            return "";
        }
        String flights = "";
        for (final Flight page : this.flights) {
            flights += buildFlight(page);
        }
        return String.format(
            Locale.ENGLISH,
            briefingTemplate,
            functionName,
            flights
        );
    }

    /**
     * Converts a flight to an AF call and returns it as string.
     * @param flight Flight to convert
     * @return Flight
     */
    private String buildFlight(final Flight flight) {
        return String.format(
            Locale.ENGLISH,
            pageTemplate,
            buildFlightStations(flight),
            flight.getDuration()
        );
    }

    /**
     * Returns a string with all station tables of the flight.
     * @param flight Flight to convert
     * @return Stations of the flight
     */
    private String buildFlightStations(final Flight flight) {
        String stations = "";
        for (final FlightStation station : flight.getPageStations()) {
            stations += buildSingleFlightStation(station);
        }
        return stations;
    }

    /**
     * Returns the station as lua table.
     * @param station Station to convert
     * @return Station table
     */
    private String buildSingleFlightStation(final FlightStation station) {
        // Get station title
        String title = "";
        if (station.getFlightTitle() != null) {
            final byte[] content = station.getFlightTitle().getBytes(Charset.forName("UTF-8"));
            title = new String(content);
        }
        // Get station text
        String text = "";
        if (station.getFlightText() != null) {
            final byte[] content = station.getFlightText().getBytes(Charset.forName("UTF-8"));
            text = new String(content);
        }

        return String.format(
            Locale.ENGLISH,
            stationTemplate,
            station.getCamPosition().getX(),
            station.getCamPosition().getY(),
            station.getCamPosition().getZ(),
            station.getCamTarget().getX(),
            station.getCamTarget().getY(),
            station.getCamTarget().getZ(),
            station.getFieldOfView(),
            title,
            text,
            station.getFlightAction()
        );
    }
}
