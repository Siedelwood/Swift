package twa.symfonia.cutscenemaker.v2.lua;

import twa.symfonia.cutscenemaker.v1.xml.CutsceneEventTypes;
import twa.symfonia.cutscenemaker.v1.xml.models.Event;
import twa.symfonia.cutscenemaker.v2.lua.models.Flight;
import twa.symfonia.cutscenemaker.v2.lua.models.FlightEntry;
import twa.symfonia.cutscenemaker.v2.xml.CutsceneXMLWorker;
import twa.symfonia.cutscenemaker.v2.xml.models.Root;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * This class converts a cutscene created with the internal cutscene editor into a flight object.
 *
 * Flight objects can either be filled with dummy flight entries that
 */
public class CutsceneFlightParser {

    /**
     * Constructor
     */
    public CutsceneFlightParser() {
    }

    /**
     * Creates a flight where each entry is filled with defaults.
     * @param flights List of flights
     * @param hideBorderPins Show border pins
     * @param restoreGameSpeed Reset game speed
     * @param transparentBars Show transparent bars
     * @return New flight
     */
    public Flight createFlightWithDefaults(List<Root> flights, boolean hideBorderPins, boolean restoreGameSpeed, boolean transparentBars) {
        return new Flight(createFlightEntriesWithDefaults(flights), restoreGameSpeed, hideBorderPins, transparentBars);
    }

    /**
     * Returns a list of flight entries filled with default values.
     * @param flights List of flights
     * @return List of flights
     */
    private List<FlightEntry> createFlightEntriesWithDefaults(List<Root> flights) {
        List<FlightEntry> entries = new ArrayList<>();
        for (int i=0; i<flights.size(); i++) {
            Root flight = flights.get(i);
            FlightEntry entry = new FlightEntry(flight.getFileName(), "", "", "nil", "nil", "nil");
            entries.add(entry);
        }
        return entries;
    }

    /**
     * Creates a flight were every entry uses real data.
     * @param flightMap Flight entry data
     * @param hideBorderPins Show border pins
     * @param restoreGameSpeed Reset game speed
     * @param transparentBars Show transparent bars
     * @return New flight
     */
    public Flight createFlight(Map<String, List<String>> flightMap, boolean hideBorderPins, boolean restoreGameSpeed, boolean transparentBars) {
        return new Flight(createFlightEntries(flightMap), restoreGameSpeed, hideBorderPins, transparentBars);
    }

    /**
     * Creates a list of flight entries for a cutscene.
     * @param flightMap Map with the data of the flight
     * @return List of flights
     */
    private List<FlightEntry> createFlightEntries(Map<String, List<String>> flightMap) {
        List<FlightEntry> entries = new ArrayList<>();
        for (final Map.Entry<String, List<String>> entry : flightMap.entrySet()) {
            FlightEntry element = createFlightEntry(entry.getKey(), entry.getValue());
            entries.add(element);
        }
        return entries;
    }

    /**
     * Creates a flight entry from the description. The description is a list of strings.
     *
     * The list contains:
     * <ul>
     *     <li>title of flight</li>
     *     <li>text of flight</li>
     *     <li>fade in time</li>
     *     <li>fade out time</li>
     *     <li>action function</li>
     * </ul>
     *
     * @param fileName Name of cutscene file (without .cs)
     * @param flightsDescription Description of flight
     * @return FlightEntry
     */
    private FlightEntry createFlightEntry(String fileName, List<String> flightsDescription) {
        return new FlightEntry(
            fileName,
            flightsDescription.get(0),
            flightsDescription.get(1),
            flightsDescription.get(2),
            flightsDescription.get(3),
            flightsDescription.get(4)
        );
    }
}
