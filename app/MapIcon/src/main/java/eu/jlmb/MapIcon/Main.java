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
		WindowWorker worker = new WindowWorker();
		worker.buildGUI();
	}

}
