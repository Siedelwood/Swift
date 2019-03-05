package twa.symfonia.cutscenemaker.v2.xml.models;

import java.util.List;

import org.simpleframework.xml.ElementList;

@org.simpleframework.xml.Root
public class Root {
    @ElementList
    private List<Event> EventCollection;

    private int duration;
    private String fileName;

    public List<Event> getEvent() {
        return EventCollection;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }
}
