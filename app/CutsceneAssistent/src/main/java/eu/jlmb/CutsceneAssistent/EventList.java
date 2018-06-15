package eu.jlmb.CutsceneAssistent;

import java.util.ArrayList;
import java.util.TreeMap;

import javax.swing.JOptionPane;
import javax.swing.table.AbstractTableModel;

/**
 * EventList class
 * @author Jean Baumgarten
 */
public class EventList extends AbstractTableModel {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -5660152884204177373L;
	
	private TreeMap<Integer, Event> list;
	private ArrayList<Event> sorted;
	
	/**
	 * Constructor
	 */
	public EventList() {
		this.list = new TreeMap<Integer, Event>();
		this.sorted = this.getSortedEvents();
	}
	
	/**
	 * Gives an available time slot for a given time, -1 if no time slot is free
	 * @param time when the event should happen
	 * @param csNr is the number of the cs part
	 * @param type of the event to check
	 * @return time that is possible
	 */
	public int getSorterSlot(int time, int csNr, int type) {
		for (int i = 0; i < 10; i++) {
			int exactSorter = 100000 * csNr + time * 10 + i;
			if (this.list.get(exactSorter) != null) {
				if (this.list.get(exactSorter).eventType() == type && type != Static.ScriptEvent) {
					return -1;
				}
			} else {
				return exactSorter;
			}
		}
		return -1;
	}
	
	/**
	 * Add an event to the list. Works only if the Slot is free
	 * @param event to add
	 * @return true is was added
	 */
	public boolean addEvent(Event event) {
		int sorter = event.getSorter();
		if (sorter < 0 || this.list.get(event.getSorter()) != null) {
			return false;
		} else {
			this.list.put(sorter, event);
			this.sorted = this.getSortedEvents();
			this.fireTableDataChanged();
			return true;
		}
	}
	
	/**
	 * Removes the event at row
	 * @param row of the event to remove
	 * @return Event that has been removed
	 */
	public Event removeEvent(int row) {
		Event event = this.sorted.get(row);
		this.list.remove(event.getSorter());
		this.sorted = this.getSortedEvents();
		this.fireTableDataChanged();
		return event;
	}
	
	/**
	 * Gives an ArrayList of the Events
	 * @return ArrayList of events
	 */
	private ArrayList<Event> getSortedEvents() {
		ArrayList<Event> arraylist = new ArrayList<Event>();
		for (Integer key : this.list.keySet()) {
			arraylist.add(this.list.get(key));
		}
		return arraylist;
	}
	
	/**
	 * Gives an ArrayList of the Events
	 * @return ArrayList of events
	 */
	public ArrayList<Event> getSorted() {
		return this.sorted;
	}
	
	/**
	 * Implements getColumnCount
	 * @return integer
	 */
	public int getColumnCount() {
		return 4;
	}

	/**
	 * Implements getRowCount
	 * @return integer
	 */
	public int getRowCount() {
		return this.list.size();
	}

	/**
	 * Implements getValueAt
	 * @param row of the event to get the value of
	 * @param column of the event to get the value of
	 * @return Object
	 */
	public Object getValueAt(int row, int column) {
        if (column == 0) {
        	return " " + this.sorted.get(row).getCSNr() + " / " + (row + 1);
        } else if (column == 1) {
        	return this.sorted.get(row).getTime();
        } else if (column == 2) {
        	return Static.getEvent(this.sorted.get(row).eventType());
        } else if (column == 3) {
        	return " " + this.sorted.get(row).getInfo();
        }
        return "Error";
	}
	
	@Override
	public String getColumnName(int column) {
		String[] columns = {
        		"CS/Nr", "T (sek/10)", "Event", "Info"
        };
		return columns[column];
	}
	
	@Override
	public boolean isCellEditable(int row, int column) {
		return column == 1 && row != 0;
	}
	
	@Override
	public void setValueAt(Object value, int row, int column) {
		if (column == 1) {
			int time = Integer.parseInt((String) value);
			Event event = this.sorted.get(row);
			int sorterSlot = this.getSorterSlot(time, event.getCSNr(), event.eventType());
			int oldSorter = event.getSorter();
			if (sorterSlot != -1) {
				this.list.remove(oldSorter);
				event.setTime(time);
				event.setSorter(sorterSlot);
				this.list.put(sorterSlot, event);
				this.sorted = this.getSortedEvents();
			} else {
				JOptionPane.showMessageDialog(null, "Dieser Zeitpunkt ist bereits besetzt.");
			}
			this.fireTableDataChanged();
		}
	}

	/**
	 * Get number of items in the list
	 * @return #Event
	 */
	public int size() {
		return this.list.size();
	}

}
