package twa.symfonia.cutscenemaker.xml;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.simpleframework.xml.Serializer;
import org.simpleframework.xml.core.Persister;

import twa.symfonia.cutscenemaker.xml.models.Event;
import twa.symfonia.cutscenemaker.xml.models.Root;

/**
 * Reader for the XML cutscenes that can be created with the internal cutscene editor.
 */
public class CutsceneXMLReader {
    private List<Event> events;

    /**
     * Constructor
     */
    public CutsceneXMLReader() {
        events = new ArrayList<>();
    }

    /**
     * Returns the events from the cutscene file.
     * @return Event list
     */
    public List<Event> getEvents() {
        return events;
    }

    /**
     * Reads the cutscene document created by the map editor
     * @param input File name or path
     * @throws CutsceneEventReaderException
     */
    public void loadDocument(final File input) throws CutsceneEventReaderException {
        try {
            final Serializer serializer = new Persister();
            events = serializer.read(Root.class, input).getEvent();
        } catch (final Exception e) {
            throw new CutsceneEventReaderException(e);
        }
    }
}
