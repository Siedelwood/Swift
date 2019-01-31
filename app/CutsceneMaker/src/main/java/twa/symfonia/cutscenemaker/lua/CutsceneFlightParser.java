package twa.symfonia.cutscenemaker.lua;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import twa.symfonia.cutscenemaker.lua.models.Flight;
import twa.symfonia.cutscenemaker.lua.models.FlightStation;
import twa.symfonia.cutscenemaker.lua.models.Position;
import twa.symfonia.cutscenemaker.xml.CutsceneEventTypes;
import twa.symfonia.cutscenemaker.xml.models.Event;

/**
 * This class converts a cutscene created with the internal cutscene editor into a flight object. A flight represents
 * a AF page in the briefing system.
 */
public class CutsceneFlightParser {
    /**
     * Constructor
     */
    public CutsceneFlightParser()
    {}

    public Flight getFlight(final List<Event> data) {
        final Map<Integer, FlightStation> flightMap = buildFlightStationsFromEvents(data);
        return buildFlight(flightMap);
    }

    /**
     * Parses the data from the CS file and puts them together to flight stations.
     * @param data XML data
     * @return Map of flights
     */
    private Map<Integer, FlightStation> buildFlightStationsFromEvents(final List<Event> data) {
        final Map<Integer, FlightStation> flightMap = new LinkedHashMap<>();
        // Create flights by camera events
        for (final Event currentFlight : data) {
            if (currentFlight.getName().equals(CutsceneEventTypes.CAMERA_EVENT)) {
                final Integer turn = currentFlight.getTurn();
                final FlightStation flight = new FlightStation();

                flight.setFieldOfView(currentFlight.getFOV());
                flight.setCamPosition(new Position(
                    currentFlight.getPositionX(),
                    currentFlight.getPositionY(),
                    currentFlight.getPositionZ()
                ));
                flight.setCamTarget(new Position(
                    currentFlight.getLookAtX(),
                    currentFlight.getLookAtY(),
                    currentFlight.getLookAtZ()
                ));

                // Set defaults
                flight.setFlightTitle("");
                flight.setFlightText("");
                flight.setFlightAction("Action   = nil");

                flightMap.put(turn, flight);
            }
        }
        // Get text from suitable text events
        for (final Event currentFlight : data) {
            if (currentFlight.getName().equals(CutsceneEventTypes.TEXT_EVENT)) {
                final Integer turn = currentFlight.getTurn();
                if (flightMap.containsKey(turn)) {
                    final FlightStation flight = flightMap.get(turn);
                    flight.setFlightTitle(currentFlight.getText());
                    flight.setFlightText(currentFlight.getTextRaw());
                }
            }
        }
        // Get script from suitable text events
        for (final Event currentFlight : data) {
            if (currentFlight.getName().equals(CutsceneEventTypes.SCRIPT_EVENT)) {
                final Integer turn = currentFlight.getTurn();
                if (flightMap.containsKey(turn)) {
                    final FlightStation flight = flightMap.get(turn);
                    final String action = currentFlight.getScript();
                    if (action != null){
                        flight.setFlightAction("Action   = " + currentFlight.getScript());
                    }
                }
            }
        }
        return flightMap;
    }

    /**
     * Combines the stations in the flight map to a flight and calculates the duration.
     * @param flightMap Map with stations
     * @return Final flight
     */
    private Flight buildFlight(final Map<Integer, FlightStation> flightMap) {
        final Flight flight = new Flight();
        double duration = 0.0;
        for (final Map.Entry<Integer, FlightStation> entry : flightMap.entrySet()) {
            // Add duration assuming first station was at turn 0
            duration += entry.getKey() * 0.1;
            // Add flight
            flight.addStation(entry.getValue());
        }
        flight.setDuration(duration);
        return flight;
    }
}
