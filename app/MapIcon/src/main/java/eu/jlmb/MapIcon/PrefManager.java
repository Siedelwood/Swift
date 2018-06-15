package eu.jlmb.MapIcon;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;

/**
 * Preferences Manager for the MapIconator
 * @author Jean Baumgarten
 */
public class PrefManager {
	
	private String version = "Die Siedler - Aufstieg eines Königreichs";
	private String s6Path;
	private String s5Path;
	private final String origS6;
	private final String origS5;
	
	/**
	 * Constructor
	 */
	public PrefManager() {
		this.s6Path = System.getProperty("user.home") + File.separator;
		this.s6Path += "Documents/DIE SIEDLER - Aufstieg eines Königreichs/MapEditor/Temp/Dummy.png";
		this.s5Path = System.getProperty("user.home") + File.separator;
		this.s5Path += "Documents/DIE SIEDLER - DEdK/MapEditor/Temp/Dummy.png";
		this.origS6 = this.s6Path;
		this.origS5 = this.s5Path;
	}
	
	/**
	 * Getter for Version
	 * @return String
	 */
	public String getVersion() {
		return this.version;
	}
	
	/**
	 * Getter for the S6 path
	 * @return String
	 */
	public String getS6Path() {
		return this.s6Path;
	}
	
	/**
	 * Getter for the S5 path
	 * @return String
	 */
	public String getS5Path() {
		return this.s5Path;
	}
	
	/**
	 * Setter for the Version
	 * @param version String
	 * @return true if saving successful
	 */
	public boolean setVersion(String version) {
		this.version = version;
		return this.saveData();
	}
	
	/**
	 * Setter for the S6 path
	 * @param path String
	 * @return true if saving successful
	 */
	public boolean setS6Path(String path) {
		this.s6Path = path;
		return this.saveData();
	}
	
	/**
	 * Setter for the S5 path
	 * @param path String
	 * @return true if saving successful
	 */
	public boolean setS5Path(String path) {
		this.s5Path = path;
		return this.saveData();
	}
	
	/**
	 * Load saved data from preferences file
	 * @return true if successful
	 */
	public boolean loadData() {
        String path = System.getProperty("user.home") + File.separator + "Documents/Siedelwood Mapiconator/prefs.txt";
        String line = null;
        try {
            FileReader fileReader = new FileReader(path);
            BufferedReader bufferedReader = new BufferedReader(fileReader);
            int lineNumber = 0;
            while ((line = bufferedReader.readLine()) != null) {
                if (lineNumber == 0) {
                	String[] values = line.split(";");
                	if (values.length == 3) {
                		String s6 = "Die Siedler - Aufstieg eines Königreichs";
                		String s5 = "Die Siedler - Das Erbe der Könige";
                		this.version = ("S6".equals(values[0])) ? s6 : s5;
                		this.s6Path = ("orig".equals(values[1])) ? this.origS6 : values[1];
                		this.s5Path = ("orig".equals(values[2])) ? this.origS5 : values[2];
                	} else {
                		return false;
                	}
                }
                lineNumber++;
            }
            bufferedReader.close();
            return true;
        } catch (FileNotFoundException ex) {
            this.saveData();
            System.err.println("Error");
            return false;
        } catch (IOException ex) {
        	this.saveData();
            System.err.println("Error");
            return false;
        }
	}
	
	/**
	 * Saves Data to the preferences file
	 * @return true if saving was successful
	 */
	private boolean saveData() {
		String v = ("Die Siedler - Aufstieg eines Königreichs".equals(this.version)) ? "S6" : "S5";
		String s6 = (this.origS6.equals(this.s6Path)) ? "orig" : this.s6Path;
		String s5 = (this.origS5.equals(this.s5Path)) ? "orig" : this.s5Path;
		String content = v + ";" + s6 + ";" + s5;
		String path = System.getProperty("user.home") + File.separator + "Documents/Siedelwood Mapiconator/";
		new File(path).mkdir();
		StandardOpenOption option = StandardOpenOption.CREATE;
		try {
			Files.write(Paths.get(path + "prefs.txt"), content.getBytes(StandardCharsets.UTF_8), option);
			return true;
		} catch (IOException e) {
			return false;
		}
	}

}
