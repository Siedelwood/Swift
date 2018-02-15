package view.component;

import java.awt.Color;
import java.awt.Graphics;

import javax.swing.Action;
import javax.swing.BorderFactory;
import javax.swing.Icon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;

import config.Configuration;

/**
 * Erzeugt einen braunen Button.
 * 
 * @author angermanager
 *
 */
@SuppressWarnings("serial")
public class SymfoniaJButton extends JButton
{

    /**
     * {@inheritDoc}
     */
    public SymfoniaJButton()
    {
	super();
	super.setContentAreaFilled(false);
	applyConfiguration();
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaJButton(final Action a)
    {
	super(a);
	super.setContentAreaFilled(false);
	applyConfiguration();
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaJButton(final Icon icon)
    {
	super(icon);
	super.setContentAreaFilled(false);
	applyConfiguration();
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaJButton(final String text, final Icon icon)
    {
	super(text, icon);
	super.setContentAreaFilled(false);
	applyConfiguration();
    }

    /**
     * {@inheritDoc}
     */
    public SymfoniaJButton(final String text)
    {
	super(text);
	super.setContentAreaFilled(false);
	applyConfiguration();
    }

    @Override
    protected void paintComponent(final Graphics g)
    {
	final Color bg = Configuration.getColor("defaults.colors.button.pressed");
	if (getModel().isPressed())
	{
	    g.setColor(bg);
	}
	else if (getModel().isRollover())
	{
	    g.setColor(getBackground());
	}
	else
	{
	    g.setColor(getBackground());
	}
	g.fillRect(0, 0, getWidth(), getHeight());
	super.paintComponent(g);
    }

    @Override
    public void setContentAreaFilled(final boolean b)
    {
    }

    /**
     * Wendet die Konfiguration auf den Button an.
     */
    protected void applyConfiguration()
    {
	final int bw = Configuration.getInteger("defaults.border.width");
	final Color bc = Configuration.getColor("defaults.colors.border.normal");
	final Color bg = Configuration.getColor("defaults.colors.button.normal");
	final Color fg = Color.WHITE;

	setBorder(BorderFactory.createLineBorder(bc, bw));
	setForeground(fg);
	setBackground(bg);
    }

    /**
     * Zeigt ein Testfenster mit dem gerenderten Button an.
     * 
     * @param args Programmparameter
     */
    public static void main(final String[] args)
    {
	final JFrame f = new JFrame();
	f.setBounds(0, 0, 200, 200);
	f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

	final JPanel p = new JPanel(null);
	p.setBounds(0, 0, 200, 200);
	p.setVisible(true);
	f.add(p);

	final SymfoniaJButton b = new SymfoniaJButton("Test");
	b.setBounds(30, 30, 130, 35);
	b.setVisible(true);
	p.add(b);

	f.setVisible(true);
    }
}
