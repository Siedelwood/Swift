package twa.symfonia.cutscenemaker.v2;

import twa.symfonia.cutscenemaker.v2.ini.CutsceneIniReader;
import twa.symfonia.cutscenemaker.v2.ini.models.FlightData;
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

/**
 * Main class of the cutscene maker console tool. The cutscene maker converts cutscenes created with the internal
 * cutscene editor to real cutscenes for the QSB-S cutscene system.
 */
public class CutsceneMaker {
    /**
     * Main method
     * @param args Arguments
     * @throws Exception
     */
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

        if ((new File(flightFiles.get(0))).isDirectory()) {
            buildCutscene(cutsceneName, flightFiles.get(0));
        }
        else {
            buildCutsceneWithDefaults(cutsceneName, flightFiles);
        }
    }

    /**
     * Builds the cutscene lua file by reading the ini file in the folder.
     * @param cutsceneName Cutscene name
     * @param directory Directory name
     * @throws Exception
     */
    private static void buildCutscene(String cutsceneName, String directory) throws Exception {
        System.out.println("Creating cutscene \"" + cutsceneName + "\".");
        System.out.println("Reading directory:");
        File[] content = (new File(directory)).listFiles();
        Arrays.sort(content);
        for (int i=0; i<content.length; i++) {
            System.out.println("  - " + content[i].getName());
        }

        final String cutscene = createCutscene(cutsceneName, directory);
        final File script = new File(cutsceneName + ".lua");
        if (script.exists()) {
            script.delete();
        }
        Files.write(Paths.get(cutsceneName + ".lua"), cutscene.getBytes());
        System.out.println("Saved file as \"" + cutsceneName + ".lua\"!");
    }

    /**
     * Builds the cutscene lua file with default values.
     * @param cutsceneName Cutscene name
     * @param flightFiles Flight files
     * @throws Exception
     */
    private static void buildCutsceneWithDefaults(String cutsceneName, List<String> flightFiles) throws Exception {
        System.out.println("Creating cutscene \"" + cutsceneName + "\".");
        System.out.println("Including CS files:");
        for (int i=0; i<flightFiles.size(); i++) {
            System.out.println("  - " + flightFiles.get(i));
        }

        // Do the real work
        final String cutscene = createCutsceneWithDefaults(cutsceneName, flightFiles);
        final File script = new File(cutsceneName + ".lua");
        if (script.exists()) {
            script.delete();
        }
        Files.write(Paths.get(cutsceneName + ".lua"), cutscene.getBytes());
        System.out.println("Saved file as \"" + cutsceneName + ".lua\"!");
    }

    /**
     * Creates a cutscene from the files in the directory.
     * @param cutsceneName Cutscene name
     * @param directory Directory name
     * @return Cutscene as lua string
     * @throws Exception
     */
    private static String createCutscene(final String cutsceneName, String directory) throws Exception {
        final CutsceneFlightParser parser = new CutsceneFlightParser();
        final CutsceneLuaBuilder builder = new CutsceneLuaBuilder();

        File dir = new File(directory);
        if (dir.isDirectory()) {
            File[] content = dir.listFiles();
            Arrays.sort(content);


            FlightData flightData = null;
            File iniFile = getIniFile(content);
            if (iniFile != null) {
                final CutsceneIniReader iniReader = new CutsceneIniReader();
                iniReader.loadFile(iniFile);
                flightData = iniReader.getFlightData(cutsceneName);
            }
            if (flightData == null) {
                System.err.println("Error: could not find flight data! Using defaults instead!");
                return createCutsceneWithDefaults(cutsceneName, getCutsceneFileNames(content));
            }


            List<Root> data = new ArrayList<>();
            for (File file : content) {
                if (file.getName().endsWith(".cs")) {
                    final CutsceneXMLWorker reader = new CutsceneXMLWorker();
                    reader.loadDocument(file);
                    data.add(reader.getDocument());
                    reader.saveDocument(file);
                }
            }

            Flight flight = parser.createFlight(data, flightData);
            return builder.buildCutsceneString(cutsceneName, flight);
        }
        return "";
    }

    /**
     * Returns the file names of all cutscene files in the directory.
     * @param content Directory content
     * @return List of file names
     */
    private static List<String> getCutsceneFileNames(File[] content) {
        List<String> files = new ArrayList<>();
        if (content != null) {
            for (File file : content) {
                if (file.getName().endsWith(".cs")) {
                    files.add(file.getPath());
                }
            }
        }
        return files;
    }

    /**
     * Returns the first ini file in the directory.
     * @param content Directory content
     * @return First ini file
     */
    private static File getIniFile(File[] content) {
        if (content != null) {
            for (File file : content) {
                if (file.getName().endsWith(".ini")) {
                    return file;
                }
            }
        }
        return null;
    }

    /**
     * Creates a cutscene with default values.
     * @param cutsceneName Name of cutscene
     * @param flights File name list
     * @return Cutscene as lua string
     * @throws Exception
     */
    private static String createCutsceneWithDefaults(final String cutsceneName, final List<String> flights) throws Exception {
        final CutsceneFlightParser parser = new CutsceneFlightParser();
        final CutsceneLuaBuilder builder = new CutsceneLuaBuilder();

        List<Root> data = new ArrayList<>();
        for (int i=0; i<flights.size(); i++) {
            final CutsceneXMLWorker reader = new CutsceneXMLWorker();
            reader.loadDocument(new File(flights.get(i)));
            data.add(reader.getDocument());
        }
        Flight flight = parser.createFlightWithDefaults(data, true, true, false, "nil");
        return builder.buildCutsceneString(cutsceneName, flight);
    }
}
