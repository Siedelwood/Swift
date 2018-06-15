package eu.jlmb.CutsceneAssistent;

import java.awt.Color;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.TreeMap;

import javax.swing.JOptionPane;

/**
 * Static class
 * @author Jean Baumgarten
 */
public final class Static {
	
	public static final Color background = Color.decode("#cacbd7");
	public static final Color tabelBackground = Color.decode("#f4fecd");
	public static final Color tableHeaderBG = Color.decode("#9f6020");
	public static final Color uiBorder = Color.decode("#713207");
	
	public static final int ScriptEvent = 0;
	public static final int TextEvent = 1;
	public static final int CameraEvent = 2;
	public static final int FaderEvent = 3;
	
	private Static() { }
	
	/**
	 * Gives the preferred folder
	 * @return Folder as String
	 */
	public static String getPreferedFolder() {
		String path = System.getProperty("user.home") + File.separator
				+ "Documents/Siedelwood Cutscene Assistant/prefs.txt";
		String defaultPath = System.getProperty("user.home") + File.separator + "Desktop/";
        String line = null;
        try {
            FileReader fileReader = new FileReader(path);
            BufferedReader bufferedReader = new BufferedReader(fileReader);
            line = bufferedReader.readLine();
            bufferedReader.close();
            if (line != null && !line.equals("")) {
            	return line;
            } else {
            	Static.savePreferedFolder(defaultPath);
                System.err.println("LoadError");
                return defaultPath;
            }
        } catch (FileNotFoundException ex) {
        	Static.savePreferedFolder(defaultPath);
            System.err.println("LoadError");
            return defaultPath;
        } catch (IOException ex) {
        	Static.savePreferedFolder(defaultPath);
            System.err.println("LoadError");
            return defaultPath;
        }
	}
	
	/**
	 * Sets the preferred folder
	 * @param newPref String
	 */
	public static void savePreferedFolder(String newPref) {
		String path = System.getProperty("user.home") + File.separator
				+ "Documents/Siedelwood Cutscene Assistant/prefs.txt";
		File file = new File(path);
		File parent = file.getParentFile();
		parent.mkdir();
		StandardOpenOption option = StandardOpenOption.CREATE;
		try {
			Files.write(Paths.get(path), newPref.getBytes(StandardCharsets.UTF_8), option);
		} catch (IOException e) {
			System.err.println("SaveError");
		}
	}
	
	/**
	 * gets the type of an event as a String
	 * @param type as integer
	 * @return String
	 */
	public static String getEvent(int type) {
		if (type == Static.ScriptEvent) {
			return "ScriptEvent";
		} else if (type == Static.TextEvent) {
			return "TextEvent";
		} else if (type == Static.CameraEvent) {
			return "CameraEvent";
		} else if (type == Static.FaderEvent) {
			return "FaderEvent";
		} else {
			return "No_Event";
		}
	}
	
	/**
	 * Get the Cutscene data from the Game
	 * @return EventList of the data
	 */
	public static EventList getCutsceneData() {
		String path = System.getProperty("user.home") + File.separator;
		path += "Documents/DIE SIEDLER - Aufstieg eines Königreichs/Profiles/";
		File folder = new File(path);
		File[] listOfFiles = folder.listFiles(new FilenameFilter() {
			public boolean accept(File dir, String name) {
				return name.endsWith(".ini");
			} });
		if (listOfFiles.length == 0) {
            JOptionPane.showMessageDialog(null, "Es konnte keine Profildatei für das Spiel gefunden werden.");
            return new EventList();
		} else {
			BufferedReader br = null;
			FileReader fr = null;
			String infos = "";
			try {
				fr = new FileReader(listOfFiles[0]);
				br = new BufferedReader(fr);
				String sCurrentLine;
				String lastline = "";
				sCurrentLine = br.readLine();
				while (sCurrentLine != null) {
					if (sCurrentLine.startsWith("pages") && lastline.startsWith("[CutsceneAssistent]")) {
						infos = sCurrentLine;
						break;
					}
					lastline = sCurrentLine;
					sCurrentLine = br.readLine();
				}
			} catch (IOException e) {
	            JOptionPane.showMessageDialog(null, e.getLocalizedMessage());
	            return new EventList();
			} finally {
				try {
					if (br != null) {
						br.close();
					}
					if (fr != null) {
						fr.close();
					}
				} catch (IOException ex) {
		            JOptionPane.showMessageDialog(null, ex.getLocalizedMessage());
				}
			}
			
			if ("".equals(infos)) {
	            JOptionPane.showMessageDialog(null, "Profil enthält keine Cutscene Informationen.");
	            return new EventList();
			}
			
			String[] pages = infos.substring(6).split("&");
			if (pages.length == 1) {
	            JOptionPane.showMessageDialog(null, "Es ist keine Cutscene in dem Spiel erstellt worden.");
				return new EventList();
			}
			
			EventList list = new EventList();
			int time = 0;
			int csNr = 0;
			for (String page : pages) {
				String[] v = page.split(",");
				CameraEvent cam;
				if ("0".equals(v[7]) && (time != 0 || csNr != 0)) {
					cam = new CameraEvent(i(v[0]), i(v[1]), i(v[2]), i(v[3]), i(v[4]), i(v[5]), 0);
					cam.setCSNr(++csNr);
					cam.setSorter(100000 * csNr);
					list.addEvent(cam);
					time = i(v[6]) * 10;
				} else {
					cam = new CameraEvent(i(v[0]), i(v[1]), i(v[2]), i(v[3]), i(v[4]), i(v[5]), time);
					cam.setCSNr(csNr);
					cam.setSorter(100000 * csNr + time * 10);
					list.addEvent(cam);
					time += i(v[6]) * 10;
					if (v.length > 8 && "1".equals(v[8])) {
						CameraEvent waitStart = (CameraEvent) cam.copy();
						waitStart.setCSNr(++csNr);
						waitStart.setTime(0);
						waitStart.setSorter(100000 * csNr);
						list.addEvent(waitStart);
						CameraEvent waitEnd = (CameraEvent) cam.copy();
						waitEnd.setCSNr(csNr);
						waitEnd.setTime(10);
						waitEnd.setSorter(100000 * csNr + 100);
						list.addEvent(waitEnd);
						CameraEvent nextCS = (CameraEvent) cam.copy();
						nextCS.setCSNr(++csNr);
						nextCS.setTime(0);
						nextCS.setSorter(100000 * csNr);
						list.addEvent(nextCS);
						time = i(v[6]) * 10;
					}
				}
			}
			return list;
		}
	}
	
	private static int i(String string) {
		String[] part = string.split("\\.");
		return Integer.parseInt(part[0]);
	}
	
}
