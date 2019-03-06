package twa.symfonia.cutscenemaker.v2.lua;

import twa.symfonia.cutscenemaker.v1.xml.CutsceneEventTypes;
import twa.symfonia.cutscenemaker.v1.xml.models.Event;
import twa.symfonia.cutscenemaker.v2.ini.models.FlightData;
import twa.symfonia.cutscenemaker.v2.ini.models.FlightEntryData;
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
    public Flight createFlightWithDefaults(List<Root> flights, boolean restoreGameSpeed, boolean hideBorderPins, boolean transparentBars) {
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
     * @param flightData Flight entry data
     * @return New flight
     */
    public Flight createFlight(List<Root> flights, FlightData flightData) {
        return new Flight(createFlightEntries(flights, flightData), flightData.isRestoreGameTime(), flightData.isHideBorderPins(), flightData.isTransparentBars());
    }

    /**
     * Creates a list of flight entries for a cutscene.
     * @param flights Cutscene data with all flight entries
     * @param flightData ...
     * @return List of flights
     */
    private List<FlightEntry> createFlightEntries(List<Root> flights, FlightData flightData) {
        List<FlightEntry> entries = new ArrayList<>();


        for (Root flight : flights) {
            FlightEntryData flightEntryData = null;
            for (int j = 0; j < flightData.getFlightEntries().size(); j++) {
                if (flightData.getFlightEntries().get(j).getFlight().equals(flight.getFileName())) {
                    flightEntryData = flightData.getFlightEntries().get(j);
                }
            }

            if (flightEntryData == null) {
                flightEntryData = new FlightEntryData(flight.getFileName(), "", "", "nil", "nil", "nil");
                flightData.getFlightEntries().add(flightEntryData);
            }

            FlightEntry element = createFlightEntry(flightEntryData);
            entries.add(element);
        }
        return entries;
    }

    /**
     * Creates a flight entry from the flight entry data.
     *
     * @param data Flight data
     * @return FlightEntry
     */
    private FlightEntry createFlightEntry(FlightEntryData data) {
        return new FlightEntry(
            data.getFlight(),
            data.getTitle(),
            data.getText(),
            data.getFadeIn(),
            data.getFadeIn(),
            data.getAction()
        );
    }
}
