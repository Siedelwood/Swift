package app.view.swing.window;

import java.awt.Color;
import java.awt.Font;
import java.awt.event.ActionEvent;

import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.SwingConstants;

import app.controler.window.WelcomeWindowController;
import app.view.WelcomeWindowInterface;
import config.Configuration;

/**
 * 
 * 
 * @author angermanager
 *
 */
public class WelcomeWindow extends AbstractSwingWindow implements WelcomeWindowInterface
{
    /**
     * 
     */
    private final Configuration configuration;
    
    /**
     * 
     */
    private final WelcomeWindowController controller;
    
    public WelcomeWindow(final Configuration configuration, final WelcomeWindowController welcomeWindowController)
    {
        super(configuration);
        this.configuration = configuration;
        this.controller = welcomeWindowController;
        
        try
        {   
            final Font fontText = new Font(Font.SANS_SERIF, 0, 11);
            final Font fontHead = new Font(Font.SANS_SERIF, 1, 18);
            
            final int windowX = configuration.getInteger("defaults.window.size.x");
            final int windowY = configuration.getInteger("defaults.window.size.y");
            getRootPane().setBounds(0, 0, windowX, windowY);
            
            /* Headline */
            
            final JLabel header = new JLabel("Willkommen!", SwingConstants.CENTER);
            header.setBounds(10, 10, windowX-20, 30);
            header.setFont(fontHead);
            getRootPane().add(header);
            
            /* Begrüßung */
            
            final JLabel description = new JLabel("Viel viel viel Text.", SwingConstants.LEFT);
            description.setBounds(10, 50, windowX-20, 30);
            description.setFont(fontText);
            getRootPane().add(description);
            
            /* Nächstes Menü */
            final JButton next = new JButton("Weiter");
            next.setBounds(windowX-110, windowY-60, 100, 30);
            next.setBackground(configuration.getColor("defaults.colors.button.normal"));
            next.setForeground(Color.WHITE);
            next.setFont(fontText);
            next.addActionListener(this);
            getRootPane().add(next);
            
        } catch (final Exception e)
        {
            System.err.println("Unable to boot application!");
            e.printStackTrace();
        }
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public void actionPerformed(final ActionEvent e) {
        controller.showOptionSelection(this);
    }
}
