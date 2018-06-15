package eu.jlmb.MapIcon;

/**
 * 
 * @author Jean Baumgarten
 *
 */
public final class Main {
	
	private Main() {
	}

	/**
	 * main method of the Main class
	 * @param args are unused
	 */
	public static void main(String[] args) {
		PrefManager manager = new PrefManager();
		boolean ready = manager.loadData();
		if (ready) {
			WindowWorker worker = new WindowWorker(manager);
			worker.buildGUI();
		} else {
			FirstStarter starter = new FirstStarter(manager);
			starter.buildGUI();
		}
	}

}
