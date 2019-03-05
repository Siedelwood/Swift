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
     * @return
     */
    public Flight createFlightWithDefaults(List<Root> flights, boolean hideBorderPins, boolean restoreGameSpeed, boolean transparentBars) {
        return new Flight(createFlightEntriesWithDefaults(flights), restoreGameSpeed, hideBorderPins, transparentBars);
    }

    /**
     * Returns a list of flight entries filled with default values.
     * @param flights List of flights
     * @return
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
}
