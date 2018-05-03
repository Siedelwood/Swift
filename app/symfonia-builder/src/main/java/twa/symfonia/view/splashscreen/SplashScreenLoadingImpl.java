package twa.symfonia.view.splashscreen;

import java.awt.image.BufferedImage;
import java.io.IOException;

import javax.swing.ImageIcon;

/**
 * Splashscreen beim Laden der Anwendung
 * @author angermanager
 */
@SuppressWarnings("serial")
public class SplashScreenLoadingImpl extends AbstractSplashScreen
{

    /**
     * Constructor
     * @param w Breite
     * @param h Höhe
     * @param imagePath Pfad zum Ladebild
     * @throws IOException
     */
    public SplashScreenLoadingImpl(final int w, final int h, final BufferedImage bg) throws IOException
    {
        super(w, h);

        final ImageIcon icon = new ImageIcon(bg);
        imageLabel.setIcon(icon);

        // this.loadingWheel = new JXLabel();
        // this.loadingWheel.setBounds(w-0, h-0, 100, 100);
        // final ImageIcon wheel = new ImageIcon(loadingWheel);
        // this.loadingWheel.setIcon(wheel);
        // this.loadingWheel.setVisible(true);
        //
        // super.add(this.loadingWheel);
    }
}
