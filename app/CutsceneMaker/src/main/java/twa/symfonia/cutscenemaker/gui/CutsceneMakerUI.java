package twa.symfonia.cutscenemaker.gui;

import javax.swing.SwingUtilities;

import twa.symfonia.cutscenemaker.gui.window.CutsceneMakerMainWindow;

public class CutsceneMakerUI
{
    /**
     * 
     * @throws Exception
     */
    public static void startGUI() throws Exception {
        SwingUtilities.invokeLater(() -> {
            try
            {
                final CutsceneMakerMainWindow window = new CutsceneMakerMainWindow(1000, 600);
            } catch (final CutsceneMakerUIException e)
            {
                e.printStackTrace();
            }           
        });
    }
}
