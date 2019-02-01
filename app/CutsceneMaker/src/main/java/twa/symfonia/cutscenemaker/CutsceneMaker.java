package twa.symfonia.cutscenemaker;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import twa.symfonia.cutscenemaker.lua.CutsceneFlightParser;
import twa.symfonia.cutscenemaker.lua.CutsceneLuaBuilder;
import twa.symfonia.cutscenemaker.xml.CutsceneXMLReader;
import twa.symfonia.cutscenemaker.xml.models.Event;

/**
 * Main class of the cutscene maker console tool. The cutscene maker converts cutscenes created with the internal
 * cutscene editor to fake cutscenes for the QSB-S briefing system.
 *
 * Called standalone it will create a lua file in the working directory containing the cutscene.
 *
 * Called by using the static method <i>createCutscene</i> just a string is returned. This mode is for potential usage
 * in a GUI wrapper application.
 */
public class CutsceneMaker {
    /**
     * CutsceneMaker main method
     * @param args Program arguments
     */
    public static void main(final String[] args) throws Exception {
        if (args.length == 0) {
            System.out.println("Starting GUI mode...");
            startGUI();
            return;
        }

        final List<String> flightFiles = new ArrayList<>(Arrays.asList(args));
        final String cutsceneName = flightFiles.get(0);
        flightFiles.remove(0);
        
        // Some checking and output
        if (flightFiles.size() == 0) {
            System.err.println("Flight files missing! Exiting!");
            System.exit(1);
        }
        System.out.println("Creating cutscene \"" + cutsceneName + "\".");
        System.out.println("Including CS files:");
        for (int i=0; i<flightFiles.size(); i++) {
            System.out.println("  - " + flightFiles.get(i));
        }

        // Do the real work
        final String cutscene = createCutscene(cutsceneName, flightFiles);
        final File script = new File(cutsceneName + ".lua");
        if (script.exists()) {
            script.delete();
        }
        Files.write(Paths.get(cutsceneName + ".lua"), cutscene.getBytes());
        System.out.println("Saved file as \"" + cutsceneName + ".lua\"!");
    }

    /**
     * Starts the GUI application.
     * @throws Exception 
     */
    public static void startGUI() throws Exception {
        System.err.println("usage: java -jar CutsceneMaker <cutscene name> <cs-file 1> <cs-file 2> ...");
        throw new Exception("GUI not implemented!");
    }

    /**
     * Creates a cutscene from the listed CS files and returns it as string of lua code.
     * @param cutsceneName Name of cutscene
     * @param flights list of flights
     * @return Cutscene as string
     * @throws Exception
     */
    public static String createCutscene(final String cutsceneName, final List<String> flights) throws Exception {
        final CutsceneFlightParser parser = new CutsceneFlightParser();
        final CutsceneLuaBuilder builder = new CutsceneLuaBuilder();

        for (int i=0; i<flights.size(); i++) {
            final CutsceneXMLReader reader = new CutsceneXMLReader();
            reader.loadDocument(new File(flights.get(i)));
            final List<Event> data = reader.getEvents();
            builder.addFlight(parser.getFlight(data));
        }
        return builder.buildCutsceneString(cutsceneName);
    }
}
