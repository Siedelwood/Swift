package twa.symfonia.cutscenemaker.lua;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import twa.symfonia.cutscenemaker.lua.models.Flight;
import twa.symfonia.cutscenemaker.lua.models.FlightStation;

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
            briefingTemplate = new String(Files.readAllBytes(Paths.get("tpl/briefingTemplate.txt")));
            stationTemplate  = new String(Files.readAllBytes(Paths.get("tpl/cameraTemplate.txt")));
            pageTemplate     = new String(Files.readAllBytes(Paths.get("tpl/flightTemplate.txt")));
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
        final StringBuilder flights = new StringBuilder();
        for (final Flight page : this.flights) {
            flights.append(buildFlight(page));
        }
        return String.format(
            Locale.ENGLISH,
            briefingTemplate,
            functionName,
            flights.toString()
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
        final StringBuilder stations = new StringBuilder();
        for (final FlightStation station : flight.getPageStations()) {
            stations.append(buildSingleFlightStation(station));
        }
        return stations.toString();
    }

    /**
     * Returns the station as lua table.
     * @param station Station to convert
     * @return Station table
     */
    private String buildSingleFlightStation(final FlightStation station) {
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
            station.getFlightTitle(),
            station.getFlightText(),
            station.getFlightAction()
        );
    }
}
