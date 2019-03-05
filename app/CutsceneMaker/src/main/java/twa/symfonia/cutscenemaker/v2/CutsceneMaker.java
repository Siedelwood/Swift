package twa.symfonia.cutscenemaker.v2;

import twa.symfonia.cutscenemaker.v2.lua.CutsceneFlightParser;
import twa.symfonia.cutscenemaker.v2.lua.CutsceneLuaBuilder;
import twa.symfonia.cutscenemaker.v2.lua.models.Flight;
import twa.symfonia.cutscenemaker.v2.xml.CutsceneXMLWorker;
import twa.symfonia.cutscenemaker.v2.xml.models.Root;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class CutsceneMaker {
    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            System.err.println("Missing arguments...");
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

    public static String createCutscene(final String cutsceneName, final List<String> flights) throws Exception {
        final CutsceneFlightParser parser = new CutsceneFlightParser();
        final CutsceneLuaBuilder builder = new CutsceneLuaBuilder();

        List<Root> data = new ArrayList<>();
        for (int i=0; i<flights.size(); i++) {
            final CutsceneXMLWorker reader = new CutsceneXMLWorker();
            reader.loadDocument(new File(flights.get(i)));
            data.add(reader.getDocument());
        }
        Flight flight = parser.createFlightWithDefaults(data, true, true, false);
        return builder.buildCutsceneString(cutsceneName, flight);
    }
}
