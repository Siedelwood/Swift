package twa.symfonia.view.splashscreen;

import javax.swing.JFrame;

import org.jdesktop.swingx.JXLabel;

/**
 * Abstrakter Splashscreen
 * @author angermanager
 */
@SuppressWarnings("serial")
public abstract class AbstractSplashScreen extends JFrame implements SplashScreenInterface
{

    /**
     * Hintergrund Label
     */
    protected final JXLabel imageLabel;

    /**
     * Constructor
     * @param w Breite
     * @param h Höhe
     */
    public AbstractSplashScreen(final int w, final int h)
    {
        super();

        setBounds(0, 0, w, h);
        setResizable(false);
        setLocationRelativeTo(null);
        setUndecorated(true);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        imageLabel = new JXLabel();
        imageLabel.setBounds(0, 0, w, h);
        imageLabel.setVisible(true);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void display()
    {
        super.add(imageLabel);
        super.setVisible(true);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void dispose()
    {
        super.setVisible(false);
    }
}
