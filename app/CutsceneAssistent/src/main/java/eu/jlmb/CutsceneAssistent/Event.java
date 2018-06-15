package eu.jlmb.CutsceneAssistent;

import java.util.ArrayList;

/**
 * Event interface
 * @author Jean Baumgarten
 */
public interface Event {
	
	/**
	 * Gives the EventType
	 * @return integer defining the EventType
	 */
	int eventType();
	
	/**
	 * Index of the Event
	 * @return the index
	 */
	int getSorter();
	
	/**
	 * Set sorter element
	 * @param sorter is int
	 */
	void setSorter(int sorter);
	
	/**
	 * Getter for the cutscene number
	 * @return integer
	 */
	int getCSNr();
	
	/**
	 * Setter for the cutscene number
	 * @param number of the cutscene
	 */
	void setCSNr(int number);
	
	/**
	 * Getter for the event time
	 * @return time
	 */
	int getTime();
	
	/**
	 * Setter for the event time
	 * @param time of event
	 */
	void setTime(int time);
	
	/**
	 * Getter for the Informations
	 * @return Informations
	 */
	String getInfo();
	
	/**
	 * Gives the XML data for finishing
	 * @return ArrayList<String> containing the XML data
	 */
	ArrayList<String> getXML();
	
	/**
	 * Generates a copy of the Event
	 * @return Event
	 */
	Event copy();
	
	/**
	 * Generates a saving String
	 * @return String
	 */
	String generateSave();
	
	/**
	 * Decodes a saving String
	 * @param data String
	 */
	void decodeSave(String data);
	
	/**
	 * GUI-Constructor for new or change event
	 * @param bench for giving back data
	 * @param isChanging is an Event if one has to be changed
	 */
	void gui(Workbench bench, boolean isChanging);

}
