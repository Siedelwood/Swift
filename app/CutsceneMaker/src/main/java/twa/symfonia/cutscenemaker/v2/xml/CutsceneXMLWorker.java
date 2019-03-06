package twa.symfonia.cutscenemaker.v2.xml;

import java.io.File;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.simpleframework.xml.Serializer;
import org.simpleframework.xml.core.Persister;
import twa.symfonia.cutscenemaker.v2.xml.models.Event;
import twa.symfonia.cutscenemaker.v2.xml.models.Root;

import org.w3c.dom.Document;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

/**
 * Reader for the XML cutscenes that can be created with the internal cutscene editor.
 * 
 * Additionally a starting script event and a closing script event is added if not
 * already present. Those events are used to controll the lua end of the dealing
 * with this feature.
 */
public class CutsceneXMLWorker {
    private Root document;

    /**
     * Constructor
     */
    public CutsceneXMLWorker()
    {}

    /**
     * Returns the root entity of the document.
     * @return Document root entity
     */
    public Root getDocument() {
        return document;
    }

    /**
     * Reads the cutscene document created by the map editor.
     * @param input Input file
     * @throws CutsceneEventException
     */
    public void loadDocument(final File input) throws CutsceneEventException {
        try {
            final Serializer serializer = new Persister();
            document = serializer.read(Root.class, input);
            injectCutsceneStartEvent();
            injectCutsceneClosingEvent();
            document.setDuration(getCutsceneDuration());
            String fileName = input.getName().substring(0, input.getName().lastIndexOf("."));
            document.setFileName(fileName);
        } catch (final Exception e) {
            throw new CutsceneEventException(e);
        }
    }

    /**
     * Writes the cutscene document back to a file.
     * @param output Output file
     * @throws CutsceneEventException
     */
    public void saveDocument(File output) throws CutsceneEventException {
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(output);
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            DOMSource domSource = new DOMSource(doc);
            StreamResult streamResult = new StreamResult(output);
            transformer.transform(domSource, streamResult);
        } catch (final Exception e) {
            throw new CutsceneEventException(e);
        }
    }

    /**
     * Adds a starting script event to the cutscene if there isn't any.
     */
    private void injectCutsceneStartEvent() {
        if (!doesHaveStartingEvent()) {
            final int duration = getCutsceneDuration();
            final Event event = new Event(0, "CutsceneFlightStarted(" +duration+ ")");
            document.getEvent().add(event);
        }
    }

    /**
     * Adds a closing script event to the cutscene if there isn't any.
     */
    private void injectCutsceneClosingEvent() {
        if (!doesHaveClosingEvent()) {
            final int duration = getCutsceneDuration();
            final Event event = new Event(duration, "CutsceneFlightFinished()");
            document.getEvent().add(event);
        }
    }

    /**
     * Returns the duration of the cutscene in 1/10 seconds. The highest turn of all
     * camera events becomes the duration.
     * @return Duration of cutscene
     */
    public int getCutsceneDuration() {
        int cutsceneDuration = 0;
        final List<Event> eventCollection = document.getEvent();
        for (final Event currentFlight : eventCollection) {
            if (currentFlight.getName().equals(CutsceneEventTypes.CAMERA_EVENT)) {
                final int newDuration = currentFlight.getTurn();
                if (newDuration > cutsceneDuration) {
                    cutsceneDuration = newDuration;
                }
            }
        }
        return cutsceneDuration;
    }

    /**
     * Checks if there is a script event that calls the lua function CutsceneFlightStarted.
     * @return Closing event found
     */
    public boolean doesHaveStartingEvent() {
        final List<Event> eventCollection = document.getEvent();
        for (final Event currentFlight : eventCollection) {
            if (currentFlight.getName().equals(CutsceneEventTypes.SCRIPT_EVENT)) {
                final String scriptEvent = currentFlight.getScript();
                if (scriptEvent != null) {
                    final Pattern p = Pattern.compile("^CutsceneFlightStarted\\(.+\\)$");
                    final Matcher m = p.matcher(scriptEvent);
                    if (m.find()) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    /**
     * Checks if there is a script event that calls the lua function CutsceneFlightFinished.
     * @return Closing event found
     */
    public boolean doesHaveClosingEvent() {
        final List<Event> eventCollection = document.getEvent();
        for (final Event currentFlight : eventCollection) {
            if (currentFlight.getName().equals(CutsceneEventTypes.SCRIPT_EVENT)) {
                final String scriptEvent = currentFlight.getScript();
                if (scriptEvent != null) {
                    final Pattern p = Pattern.compile("^CutsceneFlightFinished\\(\\)$");
                    final Matcher m = p.matcher(scriptEvent);
                    if (m.find()) {
                        return true;
                    }
                }
            }
        }
        return false;
    }
}
